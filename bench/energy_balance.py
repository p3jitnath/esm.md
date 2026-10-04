"""Extend the shared quiet-node protocol to the diffusive energy balance model."""

import ctypes
import gc
import hashlib
import importlib
import json
import math
import os
from pathlib import Path
import resource
import struct
import sys
import time

import numpy as np
import run as protocol

ROOT, BUILD = protocol.ROOT, protocol.BUILD
RUNS = ROOT / "bench/.runs/budyko_sellers"
HEADER = struct.Struct("<8sQQQ7d")
NAMES = protocol.IMPLEMENTATIONS


def _guarded(shape):
    raw = np.full(math.prod(shape) + 32, protocol.CANARY, dtype=np.uint64)
    values = raw[16:-16].view(np.float64).reshape(shape)
    values.fill(np.nan)
    return values, raw


class Buffers:
    def __init__(self, seed, coeff, par):
        pairs = [_guarded((seed.size + 2,)) for _ in range(4)]
        self.q, self.stage, self.out, self.work = [p[0] for p in pairs]
        cp = _guarded(coeff.shape)
        self.coeff = cp[0]
        self.coeff[:] = coeff
        pp = _guarded((6,))
        self.par = pp[0]
        self.par[:] = par
        self.guards = [p[1] for p in pairs] + [cp[1], pp[1]]
        self.q[1:-1] = seed

    def check(self, coeff, par):
        for raw in self.guards:
            if not (np.all(raw[:16] == protocol.CANARY) and np.all(raw[-16:] == protocol.CANARY)):
                raise AssertionError("An EBM buffer guard changed.")
        protocol._compare(coeff, self.coeff, "coefficient input")
        protocol._compare(par, self.par, "parameter input")

    def advance(self):
        self.q, self.out = self.out, self.q

    def reset(self, seed):
        for array in (self.q, self.stage, self.out, self.work):
            array.fill(np.nan)
        self.q[1:-1] = seed


def write(path, q, coeff, par, steps=0, phase=0):
    content = HEADER.pack(b"ESMEB001", q.size - 2, steps, phase, *par, steps * par[1])
    content += q[1:-1].astype("<f8", copy=False).tobytes()
    if phase == 0:
        content += coeff.astype("<f8", copy=False).tobytes()
    path.write_bytes(content)


class Backend:
    def __init__(self, name):
        self.name = name
        if name.startswith("python"):
            sys.path.insert(0, str(ROOT / "src/budyko_sellers"))
            self.module = importlib.import_module("vanilla" if name.endswith("_vanilla") else "solver")
            self.lib = None
        else:
            self.lib = ctypes.CDLL(str(BUILD / ("libeb_%s.so" % name)))
            pointer = ctypes.POINTER(ctypes.c_double)
            self.lib.eb_step.argtypes = [ctypes.c_int] + [pointer] * 6
            self.lib.eb_step.restype = None
            self.lib.eb_run.argtypes = self.lib.eb_step.argtypes + [ctypes.c_int]
            self.lib.eb_run.restype = None

    def arguments(self, b):
        pointer = ctypes.POINTER(ctypes.c_double)
        return [b.q.size - 2] + [a.ctypes.data_as(pointer) for a in
                               (b.q, b.stage, b.out, b.work, b.coeff, b.par)]

    def step(self, b):
        if self.lib:
            self.lib.eb_step(*self.arguments(b))
        else:
            self.module.step(b.q, b.stage, b.out, b.work, b.coeff, b.par)

    def bind(self, b, steps):
        if self.lib:
            args = self.arguments(b) + [steps]
            return lambda: self.lib.eb_run(*args)
        return lambda: self.module.run(b.q, b.stage, b.out, b.work, b.coeff, b.par, steps)


class Julia(protocol._Julia):
    def __init__(self, name):
        # Reuse the persistent-worker transport and result fields with the 1D worker.
        self.name = name
        executable = os.environ.get("SW_JULIA", str(ROOT / ".runtime/julia-1.12.7/bin/julia"))
        self.log = (RUNS / (name + ".log")).open("w")
        start = time.perf_counter_ns()
        self.process = protocol.subprocess.Popen(
            [executable, "--startup-file=no", "--threads=1", "-O3", "--math-mode=ieee",
             "--cpu-target=neoverse-v2", str(ROOT / "bench/ebm_driver.jl"), name],
            stdin=protocol.subprocess.PIPE, stdout=protocol.subprocess.PIPE, stderr=self.log,
            text=True, bufsize=1, env=dict(os.environ, JULIA_DEPOT_PATH=str(ROOT / ".runtime/julia-depot")))
        ready = self.process.stdout.readline().strip().split("\t")
        if len(ready) != 4 or ready[0] != "READY" or ready[2:] != ["0", "16"]:
            raise RuntimeError("EBM Julia startup failed; see " + self.log.name)
        self.startup_ns = time.perf_counter_ns() - start
        self.metadata = {"version": ready[1], "fpcr": int(ready[2]), "vector_bytes": int(ready[3])}

    def trace(self, label, seed, coeff, par, steps):
        path, trace = RUNS / (label + "-input.bin"), RUNS / (label + "-" + self.name + ".trace")
        prefix = RUNS / (label + "-" + self.name)
        write(path, Buffers(seed, coeff, par).q, coeff, par)
        self.process.stdin.write("TRACE\t%s\t%s\t%s\t%d\n" % (path, trace, prefix, steps))
        self.process.stdin.flush()
        if self.process.stdout.readline().strip() != "OK":
            raise RuntimeError("EBM Julia trace failed; see " + self.log.name)
        return np.memmap(trace, mode="r", dtype="<f8", shape=(steps, 2, seed.size + 2)), trace


def inputs(n, case="climate", dt=None):
    """Create shared static coefficients and explicit analytic-case inputs."""
    delta = 2.0 / n
    mu = -1.0 + (np.arange(n) + 0.5) * delta
    faces = -1.0 + np.arange(n + 1) * delta
    p2 = (3.0 * (mu * mu) - 1.0) * 0.5
    mode = p2 + delta * delta / 8.0
    coeff = np.zeros((3, n + 2))
    C, A, B, D, Tf = 41813000.0, 210.0, 2.0, 0.555, -10.0
    solar = (1365.2 / 4.0) * (1.0 + (-0.48 * p2))
    coeff[1, 1:-1] = (1.0 - (0.3 + 0.078 * p2)) * solar
    coeff[2, 1:-1] = (1.0 - 0.62) * solar
    seed = 12.0 - 40.0 * mode
    if case in ("equilibrium", "relaxation", "mode", "tie", "negative-zero"):
        C, A, B, D, Tf = 1.0, 0.0, 1.0, 0.0, -10.0
        coeff[1:] = 0.0
        seed = np.ones(n)
        if case == "equilibrium":
            A, B = 200.0, 2.0
            coeff[1:, 1:-1] = 224.0
            seed.fill(12.0)
        elif case == "mode":
            D = 1.0 / 16.0
            seed = 1.0 + 0.25 * mode
        elif case in ("tie", "negative-zero"):
            B = 0.0
            coeff[1, 1:-1] = 1.0
            seed.fill(-10.0 if case == "tie" else -0.0)
            Tf = float(seed[0])
    coeff[0, :n + 1] = (D * (1.0 - faces * faces)) / delta
    coeff[0, 0] = coeff[0, n] = 0.0
    limit = B + (coeff[0, 1:n + 1] + coeff[0, :n]) / delta
    if dt is None:
        dt = (0.2 * C) / float(limit.max()) if limit.max() else 0.1
    par = np.array([C, dt, delta, A, B, Tf])
    return seed, coeff, par, mode


def admissible(q, coeff, par):
    t = q[1:-1]
    if not np.all(np.isfinite(t)) or np.min(t) < -100 or np.max(t) > 100:
        raise AssertionError("An EBM stage is outside the admissible domain.")
    limit = (par[1] / par[0]) * np.max(par[4] + (coeff[0, 1:-1] + coeff[0, :-2]) / par[2])
    if limit > 0.4:
        raise AssertionError("The EBM time step exceeds its stability bound.")
    return float(limit)


def halo_check(q):
    bits = q.view(np.uint64)
    if bits[0] != bits[1] or bits[-1] != bits[-2]:
        raise AssertionError("The EBM pole ghost differs from BC01.")


def radiation(q, coeff, par):
    t = q[1:-1]
    return np.where(t <= par[5], coeff[2, 1:-1], coeff[1, 1:-1]) - (par[3] + par[4] * t)


def heat_budget(q, stage, out, coeff, par):
    delta = math.fsum((out[1:-1] - q[1:-1]).tolist()) * par[0] / (q.size - 2)
    source = math.fsum((radiation(q, coeff, par) + radiation(stage, coeff, par)).tolist()) * par[1] / (2 * (q.size - 2))
    residual = abs(delta - source) / (par[0] * (1 + math.fsum(abs(q[1:-1])) / (q.size - 2)))
    if residual > 1e-10:
        raise AssertionError("The EBM global heat budget exceeds A02.")
    return residual


def fingerprint():
    paths = [ROOT / "formulations/budyko_sellers.md", ROOT / "Makefile", Path(__file__),
             ROOT / "bench/run.py", ROOT / "bench/ebm_driver.jl", ROOT / "bench/requirements.txt",
             ROOT / "bench/fp_env.S", ROOT / "bench/counters.c", ROOT / "skills/md2asm/SKILL.md"]
    paths += [p for p in (ROOT / "src/budyko_sellers").iterdir() if p.suffix in (".S", ".f90", ".py", ".jl")]
    paths += [BUILD / ("lib%s.so" % name) for name in
              ("eb_fortran_vanilla", "eb_fortran", "eb_assembly", "fp_env", "counters")]
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(paths)}


def cases():
    yield "equilibrium", 7, 16, 0.1
    for dt in (1/8, 1/16, 1/32):
        yield "relaxation", 7, round(1/dt), dt
    for dt in (1/256, 1/512, 1/1024):
        yield "mode", 16, round(0.5/dt), dt
    for n in (1, 2, 7, 31, 128, 8193):
        yield "climate", n, 8, None
    yield "climate", 31, 1000, None
    for case in ("tie", "negative-zero"):
        yield case, 7, 8, 0.1


def verify(names, metadata):
    backends = [Backend(n) for n in names if not n.startswith("julia")]
    julias = {n: Julia(n) for n in names if n.startswith("julia")}
    metadata["julia"] = {n: w.metadata for n, w in julias.items()}
    records, errors = [], {"relaxation": [], "mode": []}
    try:
        for case, n, steps, dt in cases():
            seed, coeff, par, mode = inputs(n, case, dt)
            label = "%s-%d-%d-%.9g" % (case, n, steps, par[1])
            traces = {name: worker.trace(label, seed, coeff, par, steps) for name, worker in julias.items()}
            buffers = [Buffers(seed, coeff, par) for _ in backends]
            max_residual, max_symmetry = 0.0, 0.0
            for k in range(steps):
                for backend, b in zip(backends, buffers):
                    saved = b.q[1:-1].copy()
                    admissible(b.q, coeff, par)
                    backend.step(b)
                    protocol._compare(saved, b.q[1:-1], "%s input at step %d" % (backend.name,k+1))
                    b.check(coeff, par)
                    max_residual = max(max_residual, heat_budget(b.q,b.stage,b.out,coeff,par))
                    for phase, state in enumerate((b.stage,b.out)):
                        admissible(state,coeff,par); halo_check(state)
                        if case == "negative-zero":
                            protocol._compare(np.zeros(n),state[1:-1],"ordered signed-zero result")
                        expected = buffers[0].stage if phase == 0 else buffers[0].out
                        protocol._compare(expected,state,"%s %s step %d phase %d field T" % (backend.name,label,k+1,phase+1))
                    symmetry = float(np.max(np.abs(b.out[1:-1]-b.out[-2:0:-1])))
                    if symmetry > 1e-10:
                        raise AssertionError("Symmetric EBM input lost reflection symmetry.")
                    max_symmetry = max(max_symmetry,symmetry)
                    if case in ("equilibrium","tie"):
                        for state in (b.stage,b.out):
                            protocol._compare(seed,state[1:-1],case+" exact physical solution")
                for name,(frames,_) in traces.items():
                    for phase, expected in enumerate((buffers[0].stage,buffers[0].out)):
                        protocol._compare(expected,frames[k,phase],"%s %s step %d phase %d field T" % (name,label,k+1,phase+1))
                for b in buffers:
                    b.advance()
            elapsed = steps*par[1]
            exact = seed if case in ("equilibrium","tie") else None
            if case=="relaxation":
                exact=np.full(n,math.exp(-elapsed))
            elif case=="mode":
                exact=math.exp(-elapsed)+0.25*mode*math.exp(-(1+6/16)*elapsed)
            error = float(np.max(np.abs(buffers[0].q[1:-1]-exact))) if exact is not None else None
            if case in errors:
                errors[case].append(error)
            for backend,b in zip(backends,buffers):
                trial=Buffers(seed,coeff,par); backend.bind(trial,steps)(); trial.check(coeff,par)
                protocol._compare(b.stage,trial.stage,backend.name+" repeated stage")
                protocol._compare(b.q,trial.out if steps%2 else trial.q,backend.name+" repeated final")
                if n==1:
                    saved=[a.copy() for a in (trial.q,trial.stage,trial.out,trial.work,trial.coeff,trial.par)]
                    backend.bind(trial,0)()
                    for a,c in zip(saved,(trial.q,trial.stage,trial.out,trial.work,trial.coeff,trial.par)):
                        protocol._compare(a,c,backend.name+" zero steps")
                for phase,state in ((1,b.stage),(2,b.q)):
                    path=RUNS/(label+"-"+backend.name+"-p%d.bin"%phase)
                    write(path,state,coeff,par,steps,phase)
                    reference=RUNS/(label+"-"+NAMES[0]+"-p%d.bin"%phase)
                    if path.read_bytes()!=reference.read_bytes():
                        raise AssertionError("EBM canonical files differ.")
            for name,(frames,path) in traces.items():
                for phase in (1,2):
                    reference=RUNS/(label+"-"+NAMES[0]+"-p%d.bin"%phase)
                    if reference.read_bytes()!=(RUNS/(label+"-"+name+"-p%d.bin"%phase)).read_bytes():
                        raise AssertionError("EBM Julia files differ.")
                del frames; path.unlink()
            record={"case":case,"size":n,"steps":steps,"dt":par[1],"physical_error_kelvin":error,
                    "max_heat_residual":max_residual,"max_symmetry_kelvin":max_symmetry,
                    "input_sha256":hashlib.sha256(seed.tobytes()+coeff.tobytes()+par.tobytes()).hexdigest()}
            records.append(record); print(json.dumps(record),flush=True)
        orders={name:[math.log2(a/b) for a,b in zip(e[:-1],e[1:])] for name,e in errors.items()}
        if not all(1.8<=p<=2.2 for series in orders.values() for p in series):
            raise AssertionError("EBM temporal order fails A01.")
        if errors["relaxation"][-1]>1e-4 or errors["mode"][-1]>1e-6:
            raise AssertionError("EBM analytic error exceeds its frozen limit.")
        report={"passed":True,"implementations":names,"metadata":metadata,"cases":records,"orders":orders,
                "fingerprint":fingerprint(),"software":protocol._software()}
        (RUNS/"verification.json").write_text(json.dumps(report,indent=2)+"\n")
        print(json.dumps({"passed":True,"orders":orders}),flush=True)
    finally:
        for worker in julias.values():
            worker.close()


def native_batch(backend,seed,coeff,par,steps):
    b=Buffers(seed,coeff,par)
    start=time.perf_counter_ns(); backend.bind(b,2)(); warmup=time.perf_counter_ns()-start
    backend.bind(b,2)(); b.reset(seed)
    call=backend.bind(b,steps)
    values=np.zeros(7,dtype=np.uint64)
    enabled=gc.isenabled(); gc.disable()
    try:
        before=protocol._cpu_ticks(); protocol._profile_begin()
        start=time.perf_counter_ns(); call(); elapsed=time.perf_counter_ns()-start
        pmu=protocol._profile_end(values); after=protocol._cpu_ticks()
    finally:
        if enabled: gc.enable()
    b.check(coeff,par)
    final=b.out if steps%2 else b.q
    for state in (b.stage,final): admissible(state,coeff,par); halo_check(state)
    setup = {"first_warmup_ns": warmup}
    if backend.lib is None:
        stats = backend.module.run.stats
        setup.update({"numba_cache_hits":sum(stats.cache_hits.values()),
                      "numba_cache_misses":sum(stats.cache_misses.values())})
    return {"elapsed_ns":elapsed,"setup":setup,"pmu":pmu,
            "foreign_busy_cores_during_batch":protocol._foreign_load(before,after)},b.stage,final


def benchmark(names,metadata,sizes,repeats,target,fixed):
    verified=json.loads((RUNS/"verification.json").read_text())
    if not verified["passed"] or verified["fingerprint"]!=fingerprint() or set(verified["implementations"])!=set(names) or verified["software"]!=protocol._software():
        raise RuntimeError("Verify these exact EBM sources and binaries before timing.")
    if repeats<10 or target<0.1: raise ValueError("Use ten repeats and batches of at least 0.1 seconds.")
    backends={n:Backend(n) for n in names if not n.startswith("julia")}
    julias={n:Julia(n) for n in names if n.startswith("julia")}
    results=[]
    try:
        for index,n in enumerate(sizes):
            seed,coeff,par,_=inputs(n)
            path=RUNS/("timed-%d-input.bin"%n); write(path,Buffers(seed,coeff,par).q,coeff,par)
            def batch(name,steps,expected=None):
                before=protocol._quiet(metadata)
                prefix=RUNS/("timed-%d-"%n+name)
                if name in julias:
                    record=julias[name].batch(path,prefix,steps)
                else:
                    record,stage,final=native_batch(backends[name],seed,coeff,par,steps)
                    if expected is not None:
                        protocol._compare(expected[0],stage,name+" timed stage")
                        protocol._compare(expected[1],final,name+" timed final")
                    write(Path(str(prefix)+"-p1.bin"),stage,coeff,par,steps,1)
                    write(Path(str(prefix)+"-p2.bin"),final,coeff,par,steps,2)
                after=protocol._quiet(metadata)
                if record["foreign_busy_cores_during_batch"]>1:
                    raise protocol._QuietNodeError("Foreign activity disturbed an EBM batch: %.3f cores."%record["foreign_busy_cores_during_batch"])
                if expected is not None:
                    for phase in (1,2):
                        if Path(str(prefix)+"-p%d.bin"%phase).read_bytes()!=(RUNS/("timed-%d-reference-p%d.bin"%(n,phase))).read_bytes():
                            raise AssertionError(name+" EBM timed file differs.")
                record.update({"implementation":name,"before":before,"after":after})
                return record
            pilot=[protocol._retry_quiet(lambda:batch(name,64)) for name in names]
            fastest=min(r["elapsed_ns"] for r in pilot)/64e9
            steps=fixed[index] if fixed else 2*math.ceil(target*1.25/fastest/2)
            if not 1<=steps<=1_000_000: raise RuntimeError("Unsupported EBM batch step count.")
            reference=Buffers(seed,coeff,par); max_residual=0.0
            for _ in range(steps):
                backends[NAMES[0]].step(reference)
                admissible(reference.stage,coeff,par); admissible(reference.out,coeff,par)
                max_residual=max(max_residual,heat_budget(reference.q,reference.stage,reference.out,coeff,par))
                reference.advance()
            expected=reference.stage,reference.q
            for phase,state in enumerate(expected,1): write(RUNS/("timed-%d-reference-p%d.bin"%(n,phase)),state,coeff,par,steps,phase)
            records=[]
            for repeat in range(repeats):
                order=names if (repeat//len(names))%2==0 else names[::-1]
                shift=repeat%len(names); order=order[shift:]+order[:shift]
                for name in order:
                    record=protocol._retry_quiet(lambda:batch(name,steps,expected))
                    if record["elapsed_ns"]<0.1e9: raise RuntimeError("The EBM batch was too short.")
                    record["repeat"]=repeat; records.append(record)
                print(json.dumps({"size":n,"steps":steps,"repeat":repeat,"seconds":{r["implementation"]:r["elapsed_ns"]/1e9 for r in records[-len(names):]}}),flush=True)
            summary={}
            for name in names:
                seconds=np.array([r["elapsed_ns"]/1e9 for r in records if r["implementation"]==name])
                median=float(np.median(seconds))
                summary[name]={"median_seconds":median,"mad_seconds":float(np.median(np.abs(seconds-median))),
                               "min_seconds":float(seconds.min()),"max_seconds":float(seconds.max()),
                               "million_cell_steps_per_second":n*steps/median/1e6}
            result={"size":n,"steps":steps,"output_bytes_identical":True,"max_heat_residual":max_residual,
                    "state_and_work_bytes":7*(n+2)*8,"pilot":pilot,"samples":records,"summary":summary,
                    "native_driver_peak_rss_bytes":resource.getrusage(resource.RUSAGE_SELF).ru_maxrss*1024,
                    "input_sha256":hashlib.sha256(path.read_bytes()).hexdigest()}
            results.append(result); print(json.dumps({"size":n,"summary":summary}),flush=True)
        report={"passed":True,"metadata":metadata,"software":protocol._software(),"fingerprint":fingerprint(),
                "verification_sha256":hashlib.sha256((RUNS/"verification.json").read_bytes()).hexdigest(),
                "julia_startup_ns":{n:w.startup_ns for n,w in julias.items()},
                "protocol":{"repeats":repeats,"target_seconds":target,"fixed_steps":fixed,"warmup_steps":4,
                            "quiet_attempt_limit":3,"quiet_limit_foreign_busy_cores":1.0,
                            "cache_preparation":"fill reusable buffers, then restore the shared input",
                            "garbage_collection":"disabled inside timer","order":"rotating and reversed"},"results":results}
        (RUNS/"timing.json").write_text(json.dumps(report,indent=2)+"\n")
    finally:
        for worker in julias.values(): worker.close()


def main(args,metadata,names):
    """Run the energy-balance extension of the single verification entry point."""
    RUNS.mkdir(parents=True,exist_ok=True)
    if args.mode=="verify": verify(names,metadata)
    elif args.mode=="bench":
        sizes=[int(n) for n in args.sizes.split(",")]
        if not sizes or len(sizes)!=len(set(sizes)) or any(not 1<=n<=65536 for n in sizes):
            raise ValueError("Select unique EBM sizes from 1 through 65536.")
        fixed=[int(n) for n in args.steps_per_size.split(",")] if args.steps_per_size else None
        if fixed and (len(fixed)!=len(sizes) or any(not 1<=n<=1_000_000 for n in fixed)):
            raise ValueError("Supply one supported step count per EBM size.")
        benchmark(names,metadata,sizes,args.repeats,args.target_seconds,fixed)
    else:
        raise ValueError("Use the shared roof mode for hardware calibration.")

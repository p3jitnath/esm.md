"""Verify and compare the implementations under the shallow-water contract."""

import argparse
import ctypes
import gc
import hashlib
import importlib
import json
import math
import os
from pathlib import Path
import platform
import resource
import struct
import subprocess
import sys
import time

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "bench/.build"
RUNS = ROOT / "bench/.runs"
HEADER = struct.Struct("<8sQQQQ5d")
CANARY = np.uint64(0x7FF4DEADBEEF5678)
SCALES = np.array([1.0, math.sqrt(9.81), math.sqrt(9.81)])
ENV = None
COUNTERS = None
CANONICAL = "fortran_vanilla"
IMPLEMENTATIONS = (CANONICAL, "fortran", "assembly", "python_vanilla", "python", "julia_vanilla", "julia")


class _QuietNodeError(RuntimeError):
    pass


def _retry_quiet(call):
    discarded = []
    for attempt in range(3):
        try:
            result = call()
            record = result[1] if isinstance(result, tuple) else result
            record["discarded_attempts"] = discarded
            return result
        except _QuietNodeError as error:
            discarded.append({"attempt": attempt + 1, "reason": str(error)})
            print(json.dumps({"discarded_quiet_batch": discarded[-1]}), file=sys.stderr, flush=True)
    raise _QuietNodeError("Three batches failed the unchanged quiet-node limits: " + discarded[-1]["reason"])


def _allocation():
    global ENV, COUNTERS
    job = os.environ.get("SLURM_JOB_ID")
    if not job or not os.environ.get("SLURM_STEP_ID"):
        raise RuntimeError("Launch verification and timing through srun in an exclusive allocation.")
    node = platform.node().split(".")[0]
    detail = subprocess.check_output(["scontrol", "show", "job", job], text=True)
    occupants = subprocess.check_output(
        ["squeue", "-h", "-w", node, "-o", "%i"], text=True).split()
    if occupants != [job] or "OverSubscribe=NO" not in detail:
        raise RuntimeError("The allocated node is not exclusive to this job.")
    if "NumNodes=1" not in detail or "NumCPUs=%d " % os.cpu_count() not in detail:
        raise RuntimeError("The job must reserve all CPUs on one node.")
    affinity = sorted(os.sched_getaffinity(0))
    if len(affinity) != 1:
        raise RuntimeError("The primary comparison requires one pinned CPU core.")
    env = ctypes.CDLL(str(BUILD / "libfp_env.so"))
    env.sw_fpcr.restype = ctypes.c_uint64
    env.sw_vector_bytes.restype = ctypes.c_uint64
    ENV = env
    COUNTERS = ctypes.CDLL(str(BUILD / "libcounters.so"), use_errno=True)
    COUNTERS.counters_end.argtypes = [ctypes.POINTER(ctypes.c_uint64)]
    fpcr = env.sw_fpcr()
    if fpcr != 0:
        raise RuntimeError("Expected Arm FPCR=0, found %#x." % fpcr)
    if env.sw_vector_bytes() != 16:
        raise RuntimeError("The frozen Neoverse V2 target requires 128-bit SVE vectors.")
    cpu = Path("/sys/devices/system/cpu/cpu%d" % affinity[0])
    placement = subprocess.check_output(["numactl", "--show"], text=True)
    if "policy: bind" not in placement or "membind: 0" not in placement or affinity != [1]:
        raise RuntimeError("The frozen target requires CPU 1 with memory bound to NUMA node 0.")
    clock_policy = {key: (cpu / "cpufreq" / key).read_text().strip() for key in
                    ("scaling_driver","scaling_governor","scaling_min_freq","scaling_max_freq",
                     "cpuinfo_min_freq","cpuinfo_max_freq") if (cpu / "cpufreq" / key).exists()}
    boost = Path("/sys/devices/system/cpu/cpufreq/boost")
    if boost.exists(): clock_policy["boost"] = boost.read_text().strip()
    return {"job": job, "node": node, "affinity": affinity, "clock_policy":clock_policy,
            "fpcr": fpcr, "vector_bytes": env.sw_vector_bytes(),
            "load": os.getloadavg(), "slurm": detail, "memory_placement": placement,
            "numa_nodes": [p.name for p in cpu.glob("node*")],
            "hardware": json.loads(subprocess.check_output(["lscpu", "-J"], text=True)),
            "timer_resolution_ns": time.get_clock_info("perf_counter").resolution * 1e9}


def _cpu_ticks():
    return {int(fields[0][3:]): [int(n) for n in fields[1:9]]
            for fields in (line.split() for line in Path("/proc/stat").read_text().splitlines())
            if fields[0].startswith("cpu") and fields[0][3:].isdigit()}


def _foreign_load(before, after):
    busy = 0.0
    for cpu in before.keys() - os.sched_getaffinity(0):
        delta = np.subtract(after[cpu], before[cpu])
        total = int(delta.sum())
        if total:
            busy += float((total - delta[3] - delta[4]) / total)
    return busy


def _quiet(metadata):
    occupants = subprocess.check_output(
        ["squeue", "-h", "-w", metadata["node"], "-o", "%i"], text=True).split()
    if occupants != [metadata["job"]] or sorted(os.sched_getaffinity(0)) != metadata["affinity"]:
        raise RuntimeError("The benchmark allocation or affinity changed.")
    if ENV.sw_fpcr() != 0:
        raise RuntimeError("A native solver changed FPCR.")
    settled, started = 0, time.monotonic()
    while settled < 2:
        before = _cpu_ticks()
        time.sleep(0.2)
        after = _cpu_ticks()
        load, busy = os.getloadavg()[0], _foreign_load(before, after)
        settled = settled + 1 if load <= 2.0 and busy <= 1.0 else 0
        if time.monotonic() - started > 10:
            raise _QuietNodeError("The node did not settle: load %.3f, foreign busy cores %.3f." % (load, busy))
    frequency = Path("/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq")
    return {"load_1m": load, "foreign_busy_cores": busy,
            "frequency_khz": int(frequency.read_text()), "settle_seconds": time.monotonic() - started}


def _counter_record(values):
    values = [int(v) for v in values]
    if len(values) != 7 or values[0] != 4 or values[1] != values[2]:
        raise RuntimeError("The PMU group was incomplete or multiplexed.")
    return dict(zip(("enabled_ns", "running_ns", "cycles", "instructions", "l1d_refills", "l2d_refills"),
                    values[1:]))


def _profile_begin():
    if COUNTERS.counters_begin() != 0:
        raise OSError(ctypes.get_errno(), "Cannot start the per-thread PMU group.")


def _profile_end(values):
    if COUNTERS.counters_end(values.ctypes.data_as(ctypes.POINTER(ctypes.c_uint64))) != 0:
        raise OSError(ctypes.get_errno(), "Cannot read an unmultiplexed PMU group.")
    return _counter_record(values)


def _guarded(fields, nx, ny):
    count = fields * (nx + 2) * (ny + 2)
    raw = np.full(count + 32, CANARY, dtype=np.uint64)
    array = raw[16:-16].view(np.float64).reshape(fields, ny + 2, nx + 2)
    array.fill(np.nan)
    return array, raw


class _Buffers:
    def __init__(self, seed, parameters):
        _, ny, nx = seed.shape
        pairs = [_guarded(fields, nx, ny) for fields in (3, 3, 3, 5)]
        self.q, self.stage, self.out, self.work = [p[0] for p in pairs]
        self.guards = [p[1] for p in pairs]
        self.parameters = parameters.copy()
        self.q[:, 1:-1, 1:-1] = seed

    def check_guards(self):
        for raw in self.guards:
            if not (np.all(raw[:16] == CANARY) and np.all(raw[-16:] == CANARY)):
                raise AssertionError("A solver changed a buffer guard.")

    def advance(self):
        self.q, self.out = self.out, self.q

    def reset(self, seed):
        for array in (self.q, self.stage, self.out, self.work):
            array.fill(np.nan)
        self.q[:, 1:-1, 1:-1] = seed


class _Backend:
    def __init__(self, name):
        self.name = name
        if name.startswith("python"):
            sys.path.insert(0, str(ROOT / "src/shallow_water"))
            self.module = importlib.import_module("vanilla" if name.endswith("_vanilla") else "solver")
            self.lib = None
        else:
            self.lib = ctypes.CDLL(str(BUILD / ("libsw_%s.so" % name)))
            pointer = ctypes.POINTER(ctypes.c_double)
            self.lib.sw_step.argtypes = [ctypes.c_int, ctypes.c_int] + [pointer] * 5
            self.lib.sw_step.restype = None
            self.lib.sw_run.argtypes = self.lib.sw_step.argtypes + [ctypes.c_int]
            self.lib.sw_run.restype = None

    def _args(self, b):
        pointer = ctypes.POINTER(ctypes.c_double)
        return [b.q.shape[2] - 2, b.q.shape[1] - 2] + [
            a.ctypes.data_as(pointer) for a in (b.q, b.stage, b.out, b.work, b.parameters)]

    def step(self, b):
        if self.lib:
            self.lib.sw_step(*self._args(b))
        else:
            self.module.step(b.q, b.stage, b.out, b.work, b.parameters)

    def run(self, b, steps):
        if self.lib:
            self.lib.sw_run(*self._args(b), steps)
        else:
            self.module.run(b.q, b.stage, b.out, b.work, b.parameters, steps)

    def bind_run(self, b, steps):
        if self.lib:
            arguments = self._args(b) + [steps]
            return lambda: self.lib.sw_run(*arguments)
        arguments = (b.q, b.stage, b.out, b.work, b.parameters, steps)
        return lambda: self.module.run(*arguments)


class _Julia:
    def __init__(self, name):
        self.name = name
        executable = os.environ.get("SW_JULIA", str(ROOT / ".runtime/julia-1.12.7/bin/julia"))
        self.log = (RUNS / (name + ".log")).open("w")
        startup = time.perf_counter_ns()
        self.process = subprocess.Popen(
            [executable, "--startup-file=no", "--threads=1", "-O3", "--math-mode=ieee",
             "--cpu-target=neoverse-v2", str(ROOT / "bench/julia_driver.jl"), name],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=self.log,
            text=True, bufsize=1,
            env=dict(os.environ, JULIA_DEPOT_PATH=str(ROOT / ".runtime/julia-depot")))
        ready = self.process.stdout.readline().strip().split("\t")
        if len(ready) != 4 or ready[0] != "READY" or ready[2] != "0":
            raise RuntimeError("Julia startup failed; see " + self.log.name)
        self.startup_ns = time.perf_counter_ns() - startup
        self.metadata = {"version": ready[1], "fpcr": int(ready[2]), "vector_bytes": int(ready[3])}

    def trace(self, label, seed, parameters, steps):
        input_path = RUNS / (label + "-input.bin")
        _write(input_path, _Buffers(seed, parameters).q, parameters)
        trace_path = RUNS / (label + "-" + self.name + ".trace")
        prefix = RUNS / (label + "-" + self.name)
        self.process.stdin.write("TRACE\t%s\t%s\t%s\t%d\n" % (input_path, trace_path, prefix, steps))
        self.process.stdin.flush()
        reply = self.process.stdout.readline().strip()
        if reply != "OK":
            raise RuntimeError("Julia trace failed: " + reply + "; see " + self.log.name)
        _, ny, nx = seed.shape
        frames = np.memmap(trace_path, mode="r", dtype="<f8", shape=(steps, 2, 3, ny + 2, nx + 2))
        return frames, trace_path

    def close(self):
        if self.process.poll() is None:
            self.process.stdin.write("QUIT\n")
            self.process.stdin.flush()
            self.process.wait(timeout=30)
        self.log.close()

    def batch(self, input_path, prefix, steps):
        self.process.stdin.write("BENCH\t%s\t%s\t%d\n" % (input_path, prefix, steps))
        self.process.stdin.flush()
        reply = self.process.stdout.readline().strip().split("\t")
        if len(reply) != 8 or reply[0] != "BENCH":
            raise RuntimeError("Julia timing failed: " + str(reply) + "; see " + self.log.name)
        return {"elapsed_ns": int(reply[1]), "allocated_bytes": int(reply[2]),
                "foreign_busy_cores_during_batch": float(reply[3]),
                "pmu": _counter_record(reply[4].split(",")),
                "request_seconds": float(reply[5]), "request_compile_seconds": float(reply[6]),
                "worker_peak_rss_bytes": int(reply[7])}


def _initial(case, nx, ny):
    x = (np.arange(nx) + 0.5) / nx
    y = (np.arange(ny) + 0.5) / ny
    q = np.zeros((3, ny, nx), dtype=np.float64)
    q[0] = 1.0
    if case == "uniform":
        q[1], q[2] = 0.25, -0.125
    elif case == "negative-zero":
        q[1:] = -0.0
    elif case.startswith("shear"):
        coord, n = (x, nx) if case.endswith("x") else (y, ny)
        velocity = 0.125 + 0.0625 * np.sinc(1.0 / n) * np.sin(2 * np.pi * coord)
        if case.endswith("x"):
            q[2] = velocity[None, :]
        else:
            q[1] = velocity[:, None]
    elif case.startswith("dam"):
        if case.endswith("x"):
            q[0] = np.where(x[None, :] < 0.5, 2.0, 1.0)
        else:
            q[0] = np.where(y[:, None] < 0.5, 2.0, 1.0)
    elif case == "mixed":
        q[0] += np.sin(2 * np.pi * x)[None, :] * np.cos(2 * np.pi * y)[:, None] / 16
        q[1] = q[0] * (0.125 + np.cos(2 * np.pi * x)[None, :] / 32)
        q[2] = q[0] * (-0.0625 + np.sin(2 * np.pi * y)[:, None] / 64)
    elif case != "rest":
        raise ValueError(case)
    return q


def _parameters(nx, ny, case, duration=None):
    g, dx, dy = 9.81, 1.0 / nx, 1.0 / ny
    bound = 2.0 if case.startswith("dam") else 17.0 / 16
    dt = 0.1 * min(dx, dy) / (math.sqrt(g * bound) + 3.0 / 16)
    steps = math.ceil(duration / dt) if duration is not None else None
    if duration is not None:
        dt = duration / steps
    return np.array([g, dx, dy, dt], dtype=np.float64), steps


def _admissible(q, p):
    state = q[:, 1:-1, 1:-1]
    h = state[0]
    if not np.isfinite(state).all() or h.min() < 1e-6 or h.max() > 1e6:
        raise AssertionError("Non-finite state or invalid depth.")
    u, v = state[1] / h, state[2] / h
    c = np.sqrt(p[0] * h)
    cfl = p[3] * (np.max(np.abs(u) + c) / p[1] + np.max(np.abs(v) + c) / p[2])
    if cfl > 0.4 or np.max(np.abs(u)) > 1000 or np.max(np.abs(v)) > 1000:
        raise AssertionError("The stage violates its admissible or stability bound.")
    return float(cfl)


def _halo_check(q):
    ny, nx = q.shape[1] - 2, q.shape[2] - 2
    bits = q.view(np.uint64)
    rows = 1 + (np.arange(ny + 2) - 1) % ny
    columns = 1 + (np.arange(nx + 2) - 1) % nx
    for i in (0, nx + 1):
        if not np.array_equal(bits[:, :, i], bits[:, rows, 1 + (i - 1) % nx]):
            raise AssertionError("The periodic side halo differs from BC01.")
    for j in (0, ny + 1):
        if not np.array_equal(bits[:, j, :], bits[:, 1 + (j - 1) % ny, columns]):
            raise AssertionError("The periodic row halo differs from BC01.")


def _compare(reference, candidate, label):
    if reference.tobytes() != candidate.tobytes():
        r, c = reference.view(np.uint64), candidate.view(np.uint64)
        location = tuple(np.argwhere(r != c)[0])
        raise AssertionError("%s: first difference at %s: %#018x versus %#018x" % (
            label, location, int(r[location]), int(c[location])))


def _write(path, q, p, step=0, phase=0):
    interior = np.ascontiguousarray(q[:, 1:-1, 1:-1], dtype="<f8")
    header = HEADER.pack(b"ESMSW001", q.shape[2] - 2, q.shape[1] - 2,
                         step, phase, *p, step * p[3])
    path.write_bytes(header + interior.tobytes())


def _riemann_average(n, g, t):
    lo, hi = 1.0, 2.0
    for _ in range(80):
        hm = (lo + hi) * 0.5
        value = 2 * (math.sqrt(g * hm) - math.sqrt(g * 2)) + (hm - 1) * math.sqrt(g * 0.5 * (1 / hm + 1))
        if value > 0:
            hi = hm
        else:
            lo = hm
    hm = (lo + hi) * 0.5
    cl, cm = math.sqrt(g * 2), math.sqrt(g * hm)
    um = 2 * (cl - cm)
    speed = hm * um / (hm - 1)
    boundaries = [0.5 - cl * t, 0.5 + (um - cm) * t, 0.5 + speed * t]
    result = np.zeros((2, n))
    for i in range(n):
        left, right = i / n, (i + 1) / n
        splits = [left] + [b for b in boundaries if left < b < right] + [right]
        for begin, end in zip(splits[:-1], splits[1:]):
            mid, half = (begin + end) / 2, (end - begin) / 2
            for point in (mid - half / math.sqrt(3), mid + half / math.sqrt(3)):
                xi = (point - 0.5) / t
                if xi <= -cl:
                    h, u = 2.0, 0.0
                elif xi < um - cm:
                    h, u = (2 * cl - xi)**2 / (9 * g), 2 * (cl + xi) / 3
                elif xi < speed:
                    h, u = hm, um
                else:
                    h, u = 1.0, 0.0
                result[:, i] += half * n * np.array([h, h * u])
    return result


def _budget_drift(seed, state):
    before = np.array([math.fsum(field.ravel()) for field in seed])
    after = np.array([math.fsum(field.ravel()) for field in state])
    scale = np.array([math.fsum(np.abs(field).ravel()) for field in seed]) + seed.shape[1] * seed.shape[2] * SCALES
    drift = float(np.max(np.abs(after - before) / scale))
    if drift > 1e-10:
        raise AssertionError("Budget drift exceeds A02.")
    return drift


def _cases():
    for case in ("rest", "uniform", "negative-zero"):
        yield case, 7, 5, 16, None
    for direction in ("x", "y"):
        for n in (32, 64, 128):
            yield "shear-" + direction, n, n, None, 1 / 32
        yield "dam-" + direction, 256 if direction == "x" else 8, 8 if direction == "x" else 256, None, 1 / 32
    for nx, ny in ((1, 1), (2, 3), (7, 5), (31, 23)):
        yield "mixed", nx, ny, 8, None
    yield "mixed", 31, 23, 1000, None


def _fingerprint():
    paths = [ROOT / "formulations/shallow_water.md", ROOT / "Makefile", Path(__file__)]
    paths += [p for p in (ROOT / "src/shallow_water").iterdir() if p.suffix in (".S", ".f90", ".py", ".jl")]
    paths += [BUILD / ("lib%s.so" % name) for name in
              ("sw_fortran_vanilla","sw_fortran","sw_assembly","fp_env","roofline","counters")]
    paths += [ROOT / "bench/julia_driver.jl"]
    paths += [ROOT / "bench/fp_env.S", ROOT / "bench/requirements.txt",
              ROOT / "bench/roofline.S", ROOT / "bench/counters.c", ROOT / "skills/md2asm/SKILL.md"]
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(paths)}


def _software():
    import numba
    import llvmlite
    from llvmlite import binding
    return {"python": sys.version, "numpy": np.__version__, "numba": numba.__version__,
            "llvmlite": llvmlite.__version__, "numba_cpu": str(binding.get_host_cpu_name()),
            "numba_cpu_override": numba.config.CPU_NAME,
            "fortran": subprocess.check_output(["gfortran", "--version"], text=True).splitlines()[0],
            "gcc": subprocess.check_output(["gcc", "--version"], text=True).splitlines()[0],
            "assembler": subprocess.check_output(["as", "--version"], text=True).splitlines()[0],
            "linker": subprocess.check_output(["ld", "--version"], text=True).splitlines()[0]}


def _verify(names, metadata):
    if names[0] != CANONICAL:
        raise ValueError("The reviewed vanilla Fortran implementation must be first.")
    backends = [_Backend(name) for name in names if not name.startswith("julia")]
    julias = {name: _Julia(name) for name in names if name.startswith("julia")}
    metadata["julia"] = {name: worker.metadata for name, worker in julias.items()}
    records, shear_errors = [], {"x": [], "y": []}
    for case, nx, ny, steps, duration in _cases():
        seed = _initial(case, nx, ny)
        parameters, duration_steps = _parameters(nx, ny, case, duration)
        steps = steps or duration_steps
        label = "%s-%dx%d-%d" % (case, nx, ny, steps)
        traces = {name: worker.trace(label, seed, parameters, steps) for name, worker in julias.items()}
        buffers = [_Buffers(seed, parameters) for _ in backends]
        max_cfl = 0.0
        for step in range(1, steps + 1):
            for backend, b in zip(backends, buffers):
                before = b.q[:, 1:-1, 1:-1].copy()
                max_cfl = max(max_cfl, _admissible(b.q, parameters))
                backend.step(b)
                _compare(before, b.q[:, 1:-1, 1:-1], "%s input at step %d" % (backend.name, step))
                b.check_guards()
                _halo_check(b.q)
                for phase, array in ((1, b.stage), (2, b.out)):
                    max_cfl = max(max_cfl, _admissible(array, parameters))
                    _halo_check(array)
                    if backend is not backends[0]:
                        _compare(buffers[0].stage if phase == 1 else buffers[0].out,
                                 array, "%s %s %dx%d step %d phase %d" % (backend.name, case, nx, ny, step, phase))
                    if case in ("rest", "uniform", "negative-zero"):
                        error = np.max(np.abs(array[:, 1:-1, 1:-1] - seed) / SCALES[:, None, None])
                        if error > 1e-14:
                            raise AssertionError("A constant state changed at an intermediate stage.")
            for name, (frames, _) in traces.items():
                for phase, reference in enumerate((buffers[0].stage, buffers[0].out)):
                    _compare(reference, frames[step - 1, phase],
                             "%s %s step %d phase %d" % (name, label, step, phase + 1))
            for b in buffers:
                b.advance()
        state = buffers[0].q[:, 1:-1, 1:-1]
        drift = _budget_drift(seed, state)
        error = None
        if case in ("rest", "uniform", "negative-zero"):
            error = float(np.max(np.abs(state - seed) / SCALES[:, None, None]))
            if error > 1e-14:
                raise AssertionError("Constant-state error exceeds V01.")
        elif case.startswith("shear"):
            error = float(np.max(np.mean(np.abs(state - seed), axis=(1, 2)) / SCALES))
            shear_errors[case[-1]].append(error)
        elif case.startswith("dam"):
            exact = _riemann_average(256, parameters[0], steps * parameters[3])
            if case.endswith("x"):
                numerical = state[[0, 1]].mean(axis=1)
            else:
                numerical = state[[0, 2]].mean(axis=2)
            error = float(np.max(np.mean(np.abs(numerical[:, 64:192] - exact[:, 64:192]), axis=1) / SCALES[:2]))
            if error > 0.04:
                raise AssertionError("Dam-break error exceeds V04.")
        for backend, b in zip(backends, buffers):
            trial = _Buffers(seed, parameters)
            backend.run(trial, steps)
            trial.check_guards()
            _compare(b.stage, trial.stage, backend.name + " repeated-entry stage " + label)
            _compare(b.q, trial.out if steps % 2 else trial.q,
                     backend.name + " repeated-entry final " + label)
            _compare(parameters, trial.parameters, backend.name + " parameter buffer " + label)
            if nx == ny == 1:
                snapshots = [a.copy() for a in (trial.q, trial.stage, trial.out, trial.work)]
                backend.run(trial, 0)
                for saved, array in zip(snapshots, (trial.q, trial.stage, trial.out, trial.work)):
                    _compare(saved, array, backend.name + " zero-step mutation")
            for phase, array in ((1, b.stage), (2, b.q)):
                path = RUNS / (label + "-" + backend.name + "-p%d.bin" % phase)
                _write(path, array, parameters, steps, phase)
                reference_path = RUNS / (label + "-" + backends[0].name + "-p%d.bin" % phase)
                if path.read_bytes() != reference_path.read_bytes():
                    raise AssertionError("Canonical output files differ: " + str(path))
        for name, (frames, trace_path) in list(traces.items()):
            for phase in (1, 2):
                reference_path = RUNS / (label + "-" + CANONICAL + "-p%d.bin" % phase)
                julia_path = RUNS / (label + "-" + name + "-p%d.bin" % phase)
                if reference_path.read_bytes() != julia_path.read_bytes():
                    raise AssertionError(name + " canonical output files differ.")
            del traces[name]
            del frames
            trace_path.unlink()
        record = {"case": case, "nx": nx, "ny": ny, "steps": steps,
                  "physical_error": error, "budget_drift": drift, "max_cfl": max_cfl,
                  "input_sha256": hashlib.sha256(seed.tobytes() + parameters.tobytes()).hexdigest()}
        records.append(record)
        print(json.dumps(record), flush=True)
    orders = {}
    for axis, errors in shear_errors.items():
        orders[axis] = [math.log2(a / b) for a, b in zip(errors[:-1], errors[1:])]
        if not all(0.75 <= p <= 1.25 for p in orders[axis]) or errors[-1] > 0.01:
            raise AssertionError("Smooth-shear convergence violates V03.")
    report = {"passed": True, "implementations": names, "metadata": metadata,
              "cases": records, "shear_orders": orders, "fingerprint": _fingerprint(),
              "software": _software()}
    for worker in julias.values():
        worker.close()
    (RUNS / "verification.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"passed": True, "implementations": names, "shear_orders": orders}), flush=True)


def _native_batch(backend, seed, parameters, steps):
    b = _Buffers(seed, parameters)
    warmup_start = time.perf_counter_ns()
    backend.run(b, 2)
    first_warmup_ns = time.perf_counter_ns() - warmup_start
    backend.run(b, 2)
    b.reset(seed)
    call = backend.bind_run(b, steps)
    counter_values = np.zeros(7, dtype=np.uint64)
    enabled = gc.isenabled()
    gc.disable()
    try:
        ticks_before = _cpu_ticks()
        _profile_begin()
        start = time.perf_counter_ns()
        call()
        elapsed = time.perf_counter_ns() - start
        pmu = _profile_end(counter_values)
        ticks_after = _cpu_ticks()
    finally:
        if enabled:
            gc.enable()
    b.check_guards()
    _compare(parameters, b.parameters, backend.name + " timed parameters")
    final = b.out if steps % 2 else b.q
    for array in (b.stage, final):
        _admissible(array, parameters)
        _halo_check(array)
    setup = {"first_warmup_ns": first_warmup_ns}
    if backend.lib is None:
        stats = backend.module.run.stats
        setup.update({"numba_cache_hits": sum(stats.cache_hits.values()),
                      "numba_cache_misses": sum(stats.cache_misses.values())})
    return {"elapsed_ns": elapsed, "setup": setup,
            "foreign_busy_cores_during_batch": _foreign_load(ticks_before, ticks_after),
            "pmu": pmu}, b.stage, final


def _batch(name, backends, julias, seed, parameters, steps, input_path, metadata, expected=None):
    before = _quiet(metadata)
    if name in julias:
        prefix = RUNS / ("timed-%d-" % seed.shape[1] + name)
        record = julias[name].batch(input_path, prefix, steps)
    else:
        record, stage, final = _native_batch(backends[name], seed, parameters, steps)
        prefix = RUNS / ("timed-%d-" % seed.shape[1] + name)
        if expected:
            _compare(expected[0], stage, name + " timed first stage")
            _compare(expected[1], final, name + " timed final state")
        _write(Path(str(prefix) + "-p1.bin"), stage, parameters, steps, 1)
        _write(Path(str(prefix) + "-p2.bin"), final, parameters, steps, 2)
    after = _quiet(metadata)
    foreign = record["foreign_busy_cores_during_batch"]
    if foreign > 1.0:
        raise _QuietNodeError("Foreign CPU activity disturbed a batch: %.3f cores." % foreign)
    if expected:
        for phase in (1, 2):
            candidate = Path(str(prefix) + "-p%d.bin" % phase)
            reference = RUNS / ("timed-%d-reference-p%d.bin" % (seed.shape[1], phase))
            if candidate.read_bytes() != reference.read_bytes():
                raise AssertionError(name + " timed canonical output differs at phase %d." % phase)
    record.update({"implementation": name, "before": before, "after": after,
                   "foreign_busy_cores_during_batch": foreign})
    return record


def _benchmark(names, metadata, sizes, repeats, target, fixed_steps=None):
    verification = json.loads((RUNS / "verification.json").read_text())
    if (not verification.get("passed") or set(verification["implementations"]) != set(names)
            or verification["fingerprint"] != _fingerprint()
            or verification["software"] != _software()):
        raise RuntimeError("Run the complete verifier for these exact sources, binaries, and toolchains first.")
    if repeats < 10 or target < 0.1:
        raise ValueError("Use at least ten repeats and a target batch duration of at least 0.1 seconds.")
    backends = {name: _Backend(name) for name in names if not name.startswith("julia")}
    julias = {name: _Julia(name) for name in names if name.startswith("julia")}
    results = []
    try:
        if {name: worker.metadata for name, worker in julias.items()} != verification["metadata"]["julia"]:
            raise RuntimeError("Julia's version or floating-point environment changed after verification.")
        for index, n in enumerate(sizes):
            _allocation()
            seed, parameters = _initial("mixed", n, n), _parameters(n, n, "mixed")[0]
            input_path = RUNS / ("timed-%d-input.bin" % n)
            _write(input_path, _Buffers(seed, parameters).q, parameters)
            pilot = [_retry_quiet(lambda: _batch(name, backends, julias, seed, parameters, 2, input_path, metadata))
                     for name in names]
            fastest = min(p["elapsed_ns"] for p in pilot) / 2e9
            steps = fixed_steps[index] if fixed_steps else 2 * math.ceil(target * 1.25 / fastest / 2)
            if not 1 <= steps <= 1_000_000:
                raise RuntimeError("Calibration selected an unsupported step count.")
            reference = _Buffers(seed, parameters)
            max_cfl = _admissible(reference.q, parameters)
            for _ in range(steps):
                backends[CANONICAL].step(reference)
                reference.check_guards()
                for array in (reference.stage, reference.out):
                    max_cfl = max(max_cfl, _admissible(array, parameters))
                    _halo_check(array)
                reference.advance()
            expected = reference.stage, reference.q
            drift = _budget_drift(seed, reference.q[:, 1:-1, 1:-1])
            for phase, array in enumerate(expected, 1):
                _write(RUNS / ("timed-%d-reference-p%d.bin" % (n, phase)), array, parameters, steps, phase)
            records = []
            for repeat in range(repeats):
                order = names if (repeat // len(names)) % 2 == 0 else names[::-1]
                shift = repeat % len(names)
                order = order[shift:] + order[:shift]
                for name in order:
                    record = _retry_quiet(lambda: _batch(name, backends, julias, seed, parameters, steps,
                                                        input_path, metadata, expected))
                    if record["elapsed_ns"] < 0.1e9:
                        raise RuntimeError("A batch is too short; increase --target-seconds.")
                    record["repeat"] = repeat
                    records.append(record)
                print(json.dumps({"size": n, "steps": steps, "repeat": repeat,
                                  "seconds": {r["implementation"]: r["elapsed_ns"] / 1e9
                                              for r in records[-len(names):]}}), flush=True)
            summary = {}
            for name in names:
                seconds = np.array([r["elapsed_ns"] / 1e9 for r in records if r["implementation"] == name])
                median = float(np.median(seconds))
                summary[name] = {"median_seconds": median,
                                 "mad_seconds": float(np.median(np.abs(seconds - median))),
                                 "min_seconds": float(seconds.min()), "max_seconds": float(seconds.max()),
                                 "million_cell_steps_per_second": n * n * steps / median / 1e6}
            result = {"size": n, "steps": steps, "max_cfl": max_cfl, "budget_drift": drift, "output_bytes_identical": True,
                      "state_and_work_bytes": 14 * (n + 2)**2 * 8,
                      "native_driver_peak_rss_bytes": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss * 1024,
                      "pilot": pilot, "samples": records, "summary": summary,
                      "input_sha256": hashlib.sha256(input_path.read_bytes()).hexdigest()}
            results.append(result)
            print(json.dumps({"size": n, "summary": summary}), flush=True)
        report = {"passed": True, "metadata": metadata, "software": _software(),
                  "fingerprint": _fingerprint(), "verification_sha256": hashlib.sha256(
                      (RUNS / "verification.json").read_bytes()).hexdigest(),
                  "julia_startup_ns": {name: worker.startup_ns for name, worker in julias.items()},
                  "numba_cache_dir": os.environ.get("NUMBA_CACHE_DIR", "source-local cache"),
                  "protocol": {"repeats": repeats, "target_seconds": target,
                               "fixed_steps": fixed_steps,
                               "quiet_attempt_limit": 3, "quiet_limit_foreign_busy_cores": 1.0,
                               "warmup_steps": 4, "garbage_collection": "disabled inside timer",
                               "cache_preparation": "fill reusable buffers, then restore the shared input",
                               "order": "rotating positions, reversed after each full rotation"},
                  "results": results}
        (RUNS / "timing.json").write_text(json.dumps(report, indent=2) + "\n")
    finally:
        for worker in julias.values():
            worker.close()


def _probe_batch(call, metadata):
    before = _quiet(metadata)
    values = np.zeros(7, dtype=np.uint64)
    enabled = gc.isenabled()
    gc.disable()
    try:
        ticks_before = _cpu_ticks()
        _profile_begin()
        start = time.perf_counter_ns()
        result = call()
        elapsed = time.perf_counter_ns() - start
        pmu = _profile_end(values)
        ticks_after = _cpu_ticks()
    finally:
        if enabled:
            gc.enable()
    foreign = _foreign_load(ticks_before, ticks_after)
    if foreign > 1.0:
        raise _QuietNodeError("Foreign CPU activity disturbed a roofline probe: %.3f cores." % foreign)
    return result, {"elapsed_ns": elapsed, "pmu": pmu, "before": before,
                    "after": _quiet(metadata), "foreign_busy_cores_during_batch": foreign}


def _roofline(metadata, repeats, target):
    if repeats < 10 or target < 0.1:
        raise ValueError("Roofline probes require ten repeats and batches of at least 0.1 seconds.")
    library = ctypes.CDLL(str(BUILD / "libroofline.so"))
    pointer = ctypes.POINTER(ctypes.c_double)
    operands = np.array([0.15, 17 / 16, 9.81 * (17 / 16)])
    address = operands.ctypes.data_as(pointer)
    lanes = metadata["vector_bytes"] // 8
    probes = []
    operations = (("add", operands[0] + operands[1]),
                  ("multiply", operands[0] * operands[1]),
                  ("divide", operands[0] / operands[1]),
                  ("sqrt", math.sqrt(operands[2])),
                  ("sqrt_neon", math.sqrt(operands[2])),
                  ("mixed", operands[0] / operands[1]),
                  ("mixed_neon", operands[0] / operands[1]))
    for name, expected in operations:
        if name.endswith("neon") and lanes != 2:
            continue
        function = getattr(library, "roof_" + name)
        function.argtypes, function.restype = [ctypes.c_uint64, pointer], ctypes.c_double
        if function(0, address) != 0:
            raise AssertionError("The zero-iteration arithmetic probe changed its result.")
        function(1024, address)
        count = 262144
        value, pilot = _retry_quiet(lambda: _probe_batch(lambda: function(count, address), metadata))
        if struct.pack("<d", value) != struct.pack("<d", expected):
            raise AssertionError("Arithmetic probe mismatch: " + name)
        count = max(count, math.ceil(count * target * 1.5e9 / pilot["elapsed_ns"]))
        samples = []
        for repeat in range(repeats):
            value, sample = _retry_quiet(lambda: _probe_batch(lambda: function(count, address), metadata))
            if sample["elapsed_ns"] < 0.1e9 or struct.pack("<d", value) != struct.pack("<d", expected):
                raise AssertionError("The arithmetic probe was too short or its output differed.")
            sample["repeat"] = repeat
            samples.append(sample)
        seconds = np.array([s["elapsed_ns"] / 1e9 for s in samples])
        units = (2 if name.startswith("mixed") else 16) * lanes * count
        record = {"probe": name, "iterations": count, "operands": operands.tolist(),
                  "units": "cell-step equivalents/s" if name.startswith("mixed") else "scalar operations/s",
                  "median_rate": units / float(np.median(seconds)),
                  "median_seconds": float(np.median(seconds)),
                  "mad_seconds": float(np.median(np.abs(seconds - np.median(seconds)))),
                  "pilot": pilot, "samples": samples}
        probes.append(record)
        print(json.dumps({k: record[k] for k in ("probe", "median_rate", "units", "mad_seconds")}), flush=True)
    operand_probes = []
    for label in ('constant', 'seed64', 'seed256', 'seed1024'):
        source_holder = np.full(64, CANARY, dtype=np.uint64)
        out_holder = np.full(56, CANARY, dtype=np.uint64)
        source = source_holder[16:-16].view(np.float64).reshape(4, 8)
        out = out_holder[16:-16].view(np.float64).reshape(3, 8)
        if label == 'constant':
            source[0:2].fill(0.15)
            source[2].fill(17 / 16)
            source[3].fill(9.81 * (17 / 16))
            locations = None
        else:
            n = int(label[4:])
            seed = _initial('mixed', n, n)
            columns = np.arange(0, n, n // 8)
            source[0], source[1], source[2] = seed[1, 0, columns], seed[2, 0, columns], seed[0, 0, columns]
            source[3] = 9.81 * source[2]
            locations = {'row': 0, 'columns': columns.tolist(), 'seed_and_parameters_sha256': hashlib.sha256(seed.tobytes() + _parameters(n,n,'mixed')[0].tobytes()).hexdigest()}
        expected = np.array([source[0] / source[2], source[1] / source[2], [math.sqrt(x) for x in source[3]]])
        source_bytes = source.tobytes()
        addresses = source.ctypes.data_as(pointer), out.ctypes.data_as(pointer)
        for mode in ('sve', 'neon'):
            function = getattr(library, 'roof_varied_' + mode)
            function.argtypes, function.restype = [ctypes.c_uint64, pointer, pointer], ctypes.c_double
            out.fill(np.nan)
            unchanged = out.tobytes()
            if function(0, *addresses) != 0 or out.tobytes() != unchanged:
                raise AssertionError('The zero-iteration mixed probe changed its result.')
            def measure(count):
                value, record = _retry_quiet(lambda: _probe_batch(lambda: function(count, *addresses), metadata))
                if out.tobytes() != expected.tobytes() or source.tobytes() != source_bytes:
                    raise AssertionError('The mixed operand probe changed a declared primitive result.')
                if struct.pack('<d', value) != struct.pack('<d', expected[0, 0]):
                    raise AssertionError('The mixed operand probe returned a different first quotient.')
                for raw in (source_holder, out_holder):
                    if not (np.all(raw[:16] == CANARY) and np.all(raw[-16:] == CANARY)):
                        raise AssertionError('A mixed operand probe changed a buffer guard.')
                return record
            pilot_count = 262144
            pilot = measure(pilot_count)
            count = max(pilot_count, math.ceil(pilot_count * target * 1.5e9 / pilot['elapsed_ns']))
            samples = []
            for repeat in range(repeats):
                record = measure(count)
                if record['elapsed_ns'] < 0.1e9:
                    raise AssertionError('The input-dependent mixed probe was too short.')
                record['repeat'] = repeat
                samples.append(record)
            seconds = np.array([s['elapsed_ns'] / 1e9 for s in samples])
            record = {'input': label, 'mode': mode, 'operands': source.tolist(), 'locations': locations, 'iterations': count, 'median_rate': 4 * count / float(np.median(seconds)), 'median_seconds': float(np.median(seconds)), 'mad_seconds': float(np.median(np.abs(seconds - np.median(seconds)))), 'samples': samples, 'pilot': pilot}
            operand_probes.append(record)
            print(json.dumps({k: record[k] for k in ('input', 'mode', 'median_rate', 'mad_seconds')}), flush=True)
    memory = []
    for level, total_bytes in (("L1", 32 * 1024), ("L2", 512 * 1024),
                               ("L3", 32 * 1024**2), ("DRAM", 512 * 1024**2)):
        for streams, writes, name in ((1, 1, "copy"), (7, 1, "stream7"), (5, 2, "streammix"), (11, 2, "stream11")):
            count = total_bytes // (8 * (streams + writes))
            raw_source = np.full(streams * count + 32, CANARY, dtype=np.uint64)
            raw_out = np.full(writes * count + 32, CANARY, dtype=np.uint64)
            source, out = raw_source[16:-16].view(np.float64), raw_out[16:-16].view(np.float64)
            source.fill(1.0)
            out.fill(np.nan)
            source_address, out_address = source.ctypes.data_as(pointer), out.ctypes.data_as(pointer)
            function = getattr(library, "roof_" + name)
            function.argtypes, function.restype = [pointer, pointer, ctypes.c_uint64, ctypes.c_uint64], None
            function(out_address, source_address, count, 1)
            pilot_iterations = max(2, 16 * 1024**2 // total_bytes)
            _, pilot = _retry_quiet(lambda: _probe_batch(lambda: function(out_address, source_address, count, pilot_iterations), metadata))
            iterations = max(1, math.ceil(pilot_iterations * target * 1.5e9 / pilot["elapsed_ns"]))
            samples = []
            for repeat in range(repeats):
                _, sample = _retry_quiet(lambda: _probe_batch(lambda: function(out_address, source_address, count, iterations), metadata))
                if sample["elapsed_ns"] < 0.1e9 or not np.all(out == (7 if name == "stream7" else 1)):
                    raise AssertionError("Memory probe %s/%s failed: %.6f seconds, output correct=%s." %
                                         (level, name, sample["elapsed_ns"] / 1e9, bool(np.all(out == (7 if name == "stream7" else 1)))))
                for raw in (raw_source, raw_out):
                    if not (np.all(raw[:16] == CANARY) and np.all(raw[-16:] == CANARY)):
                        raise AssertionError("A memory probe changed a buffer guard.")
                sample["repeat"] = repeat
                samples.append(sample)
            if not np.all(source == 1.0):
                raise AssertionError("A memory probe changed its input.")
            seconds = np.array([s["elapsed_ns"] / 1e9 for s in samples])
            record = {"level": level, "probe": name, "source_streams": streams,
                      "destination_streams": writes,
                      "working_bytes": count * (streams + writes) * 8, "field_length": count,
                      "iterations": iterations,
                      "median_bytes_per_second": count * (streams + writes) * 8 * iterations / float(np.median(seconds)),
                      "median_seconds": float(np.median(seconds)),
                      "mad_seconds": float(np.median(np.abs(seconds - np.median(seconds)))),
                      "pilot": pilot, "samples": samples}
            memory.append(record)
            print(json.dumps({k: record[k] for k in ("level", "probe", "working_bytes", "median_bytes_per_second")}), flush=True)
    cache_root = Path("/sys/devices/system/cpu/cpu1/cache")
    caches = [{key: (index / key).read_text().strip() for key in
               ("level", "type", "size", "coherency_line_size", "shared_cpu_list")}
              for index in sorted(cache_root.glob("index*"))]
    report = {"passed": True, "metadata": metadata, "software": _software(), "fingerprint": _fingerprint(),
              "repeats": repeats, "target_seconds": target, "caches": caches,
              "arithmetic": probes, "operand_probes": operand_probes, "memory": memory,
              "interpretation": "Empirical compatible instruction and logical bandwidth ceilings; cache refills do not measure DRAM traffic."}
    (RUNS / "roofline.json").write_text(json.dumps(report, indent=2) + "\n")


def main():
    """Run the selected verification protocol and write its evidence record."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["verify", "bench", "roof"])
    parser.add_argument("--model", choices=["shallow_water", "budyko_sellers"], default="shallow_water")
    parser.add_argument("--implementations", default=",".join(IMPLEMENTATIONS))
    parser.add_argument("--sizes", default="64,256,1024")
    parser.add_argument("--repeats", type=int, default=12)
    parser.add_argument("--target-seconds", type=float, default=0.15)
    parser.add_argument("--steps-per-size", help="Fix one complete-step count for each selected grid during controlled tuning.")
    args = parser.parse_args()
    RUNS.mkdir(parents=True, exist_ok=True)
    names = args.implementations.split(",")
    if len(names) != len(set(names)) or not set(names) <= set(IMPLEMENTATIONS):
        raise ValueError("Select unique implementation names from " + ",".join(IMPLEMENTATIONS))
    if names[0] != CANONICAL:
        raise ValueError("List fortran_vanilla first as the canonical discrete implementation.")
    metadata = _allocation()
    if args.model == "budyko_sellers":
        import energy_balance
        energy_balance.main(args, metadata, names)
        return
    if args.mode == "verify":
        _verify(names, metadata)
    elif args.mode == "roof":
        _roofline(metadata, args.repeats, args.target_seconds)
    else:
        sizes = [int(n) for n in args.sizes.split(",")]
        if not sizes or any(n not in (64, 256, 1024) for n in sizes) or len(sizes) != len(set(sizes)):
            raise ValueError("Choose unique workload sizes from 64, 256, and 1024.")
        steps = [int(n) for n in args.steps_per_size.split(",")] if args.steps_per_size else None
        if steps is not None and (len(steps) != len(sizes) or any(not 1 <= n <= 1_000_000 for n in steps)):
            raise ValueError("Supply one supported step count for each selected size.")
        _benchmark(names, metadata, sizes, args.repeats, args.target_seconds, steps)


if __name__ == "__main__":
    sys.modules["run"] = sys.modules[__name__]
    main()

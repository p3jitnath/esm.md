"""Qualify and time eight complete GPU routes on the frozen input banks."""
import argparse
import ctypes as ct
import hashlib
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import numpy as np

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[3]
OLD = ROOT.parent / "esm.md-gpu"
sys.path.insert(0, str(HERE / "host"))
import runtime
runtime.ROOT = HERE / "python"
runtime.BUILD = HERE / "build"

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    sys.modules[name] = result
    spec.loader.exec_module(result)
    return result

protocol = module("run", OLD / "bench/run.py")
sys.path.insert(0, str(OLD / "bench"))
eb = module("energy_balance", OLD / "bench/energy_balance.py")
BANK = ROOT / ".runtime/goal_20261112/gpu/frozen_inputs"
INPUTS = json.loads((BANK / "manifest.json").read_text())
EXPECTED = json.loads((BANK / "expected_manifest.json").read_text())
base_observation = runtime.observation

def observation(meta, scheduler=True):
    result = base_observation(meta, scheduler=False)
    if scheduler:
        jobs = subprocess.check_output(["squeue", "--all", "-h", "-w", meta["node"], "-o", "%i"], text=True).split()
        steps = subprocess.check_output(["squeue", "--steps", "-h", "-j", meta["job"], "-o", "%i"], text=True).split()
        allowed = {meta["job"] + "." + meta["step"], meta["job"] + ".batch"} | set(meta.get("declared_idle_steps", []))
        if jobs != [meta["job"]] or not set(steps) <= allowed:
            raise RuntimeError("Another allocation or active step is present")
        result.update(active_steps=steps, scheduler_checked_utc_ns=time.time_ns())
    return result
runtime.observation = observation


def fingerprint():
    paths = list((HERE / "host").glob("*.py")) + list((HERE / "host").glob("*.cpp"))
    paths += list((HERE / "build").glob("*.cubin")) + [HERE / "build/libdriver.so"]
    paths += list((HERE / "python/src").glob("*/gpu/*.py"))
    paths += list((HERE / "fortran").glob("*/*/solver.cuf"))
    paths += list((HERE / "julia").glob("*.jl")) + list((HERE / "julia/src").rglob("*.jl"))
    paths += list((HERE / "accepted_sources").rglob("*.cuf")) + list((HERE / "accepted_sources").rglob("*.ptx")) + list((HERE / "accepted_sources").glob("*.json"))
    paths += [BANK / "manifest.json", BANK / "expected_manifest.json", OLD / "bench/run.py", OLD / "bench/energy_balance.py"]
    return {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(paths)}

NAMES = ["assembly", "gpu_esm_fortran", "gpu_fortran", "gpu_fortran_vanilla", "julia", "julia_vanilla", "gpu_python", "gpu_python_vanilla"]

def bank(model, size):
    selected = "ebm" if model == "eb" else model
    row = next(x for x in INPUTS["banks"] if x["model"] == selected and x["shape"][0] == size)
    erow = next(x for x in EXPECTED["banks"] if x["model"] == selected and x["shape"][0] == size)
    shape = [size] if model == "eb" else [size, size]
    if row["shape"] != shape or erow["shape"] != shape or row["complete_steps"] != 1000 or erow["complete_steps"] != 1000 or row["input_identity_sha256"] != erow["input_identity"]:
        raise RuntimeError("Frozen bank manifest binding differs")
    with np.load(row["npz"], allow_pickle=False) as data:
        for name, item in row["arrays"].items():
            values = data[name]
            if list(values.shape) != item["shape"] or values.dtype.str != item["dtype"] or hashlib.sha256(values.tobytes(order="C")).hexdigest() != item["sha256"]:
                raise RuntimeError("Frozen input words or layout differ: " + name)
        if model == "eb":
            host = eb.Buffers(data["q"][1:-1].copy(), data["coeff"].copy(), data["par"].copy())
        else:
            host = protocol._Buffers(data["q"][:,1:-1,1:-1].copy(), data["parameters"].copy())
        for name in data.files:
            np.copyto(getattr(host, name), data[name])
    with np.load(erow["path"], allow_pickle=False) as data:
        if str(data["input_identity"]) != row["input_identity_sha256"] or str(data["canonical_binary_sha256"]) != erow["canonical_binary_sha256"]:
            raise RuntimeError("Canonical expected bank owner differs")
        for name, item in erow["arrays"].items():
            values = data[name]
            if list(values.shape) != item["shape"] or values.dtype.str != item["dtype"] or hashlib.sha256(values.tobytes(order="C")).hexdigest() != item["sha256"]:
                raise RuntimeError("Frozen canonical expected words differ: " + name)
        expected = {name: data[name].copy() for name in ("q", "stage", "out")}
    return host, expected, row, erow

def compare(expected, actual, label):
    left, right = np.ascontiguousarray(expected).view(np.uint64).ravel(), np.ascontiguousarray(actual).view(np.uint64).ravel()
    if left.shape != right.shape:
        raise AssertionError(label + " shape differs")
    unequal = np.flatnonzero(left != right)
    if unequal.size:
        i = int(unequal[0])
        raise AssertionError(f"{label}: first cell {i}, expected 0x{int(left[i]):016x}, actual 0x{int(right[i]):016x}, differing words {unequal.size}")

def validate(model, host, expected, arrays, label):
    for name in ("q", "stage", "out"):
        compare(expected[name], arrays[name], label + " " + name)
    for name in (("coeff", "par") if model == "eb" else ("parameters",)):
        compare(getattr(host, name), arrays[name], label + " immutable " + name)
    for name in ("q", "stage", "out"):
        if model == "eb":
            eb.admissible(arrays[name], host.coeff, host.par)
            eb.halo_check(arrays[name])
        else:
            protocol._admissible(arrays[name], host.parameters)
            protocol._halo_check(arrays[name])

def metadata(mode, expected_uuid):
    job = os.environ["SLURM_JOB_ID"]
    details = subprocess.check_output(["scontrol", "show", "job", job], text=True)
    if "JobState=RUNNING" not in details or "UserId=p3jitnath.u6yq" not in details:
        raise RuntimeError("Allocation ownership changed")
    if mode == "time" and "Exclusive=NODE" not in details:
        raise RuntimeError("Timing requires an owned exclusive allocation")
    name, uuid = ct.create_string_buffer(128), ct.create_string_buffer(41)
    runtime.driver().gpu_info(name, uuid)
    actual_uuid = uuid.value.decode()
    if actual_uuid != expected_uuid:
        raise RuntimeError("Visible GPU UUID differs: " + actual_uuid)
    fp = ct.CDLL(str(ROOT / ".agents/bench/.build/libfp_env.so"))
    fp.sw_fpcr.restype = ct.c_uint64
    if fp.sw_fpcr() != 0:
        raise RuntimeError("FPCR differs from zero")
    result = {"python_executable": sys.executable, "python_version": sys.version, "numpy_version": np.__version__, "cuda_visible_devices": os.environ.get("CUDA_VISIBLE_DEVICES"), "memory_policy_status": [line for line in Path("/proc/self/status").read_text().splitlines() if line.startswith("Mems_allowed_list:")], "job": job, "step": os.environ.get("SLURM_STEP_ID"), "node": subprocess.check_output(["hostname"], text=True).strip(), "affinity": sorted(os.sched_getaffinity(0)), "uuid": actual_uuid, "gpu": name.value.decode(), "slurm": details, "mode": mode, "fpcr": 0}
    result["power_policy"] = subprocess.check_output(["nvidia-smi", "-i", actual_uuid, "--query-gpu=power.limit,power.default_limit,clocks.max.sm,clocks.max.memory", "--format=csv,noheader"], text=True).strip()
    return result

def jit_identity(backend):
    if not hasattr(backend, "module"):
        return {}
    result = {}
    for name, function in vars(backend.module).items():
        if hasattr(function, "inspect_asm"):
            for signature, code in function.inspect_asm().items():
                result[name + ":" + str(signature)] = hashlib.sha256(code.encode()).hexdigest()
    return result

def snapshot(state):
    return {key: array.get() for key, array in state.arrays.items()}

class Julia:
    """Own one separate Julia process with cached graphs and exact input restoration."""

    def __init__(self, name, model, folder):
        self.name, self.model = name, model
        self.prepared = set()
        self.log = (folder / (name + ".log")).open("w")
        executable = ROOT / ".runtime/julia-1.12.7/bin/julia"
        if not executable.is_file():
            executable = OLD / ".runtime/julia-1.12.7/bin/julia"
        environment = dict(os.environ, JULIA_DEPOT_PATH=str(OLD / ".runtime/julia-depot"), GPU_DRIVER_LIBRARY=str(HERE / "build/libdriver.so"), JULIA_NUM_PRECOMPILE_TASKS="1", OPENBLAS_NUM_THREADS="1", OMP_NUM_THREADS="1")
        self.process = subprocess.Popen([str(executable), "--startup-file=no", "--threads=1", "-O3", "--math-mode=ieee", "--project=" + str(OLD / ".runtime/julia-env"), str(HERE / "julia/julia_driver.jl"), model, name], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=self.log, text=True, bufsize=1, env=environment)
        fields = self.process.stdout.readline().strip().split("\t")
        if len(fields) != 3 or fields[0] != "READY":
            raise RuntimeError("Julia startup failed: " + self.log.name)
        self.versions = fields

    def command(self, *fields):
        self.process.stdin.write("\t".join(map(str, fields)) + "\n")
        self.process.stdin.flush()
        result = self.process.stdout.readline().strip().split("\t")
        if not result or result[0] not in ("PREPARED", "TIME", "CHECK", "CLOSED"):
            raise RuntimeError("Julia command failed " + repr(result) + "; see " + self.log.name)
        return result

    def prepare(self, host, size, folder):
        names = ("q", "stage", "out", "work", "coeff", "par") if self.model == "eb" else ("q", "stage", "out", "work", "parameters")
        path = folder / "julia_full_input.bin"
        with path.open("wb") as output:
            output.write(b"ESMJG002")
            np.asarray([size, 1 if self.model == "eb" else size, len(names)], dtype="<u8").tofile(output)
            np.asarray([getattr(host, name).size for name in names], dtype="<u8").tofile(output)
            for name in names:
                np.ascontiguousarray(getattr(host, name), dtype="<f8").tofile(output)
        prefix = folder / self.name
        block = runtime.preferred_block(self.name, self.model)
        result = self.command("PREP", size, path, prefix, 1000, block)
        self.prepared.add(size)
        return result, prefix

    def arrays(self, prefix, host):
        names = ("q", "stage", "out", "work", "coeff", "par") if self.model == "eb" else ("q", "stage", "out", "work", "parameters")
        values = np.fromfile(str(prefix) + ".guarded.raw", dtype="<u8")
        arrays, offset = {}, 0
        for name in names:
            template = getattr(host, name)
            count = template.size
            raw = values[offset:offset + count + 32]
            if raw.size != count + 32 or not (np.all(raw[:16] == runtime.CANARY) and np.all(raw[-16:] == runtime.CANARY)):
                raise AssertionError(self.name + " Julia guards differ: " + name)
            arrays[name] = raw[16:-16].view(np.float64).reshape(template.shape).copy()
            offset += count + 32
        if offset != values.size:
            raise AssertionError("Julia complete snapshot size differs")
        return arrays

    def close(self):
        if self.process.poll() is None:
            self.process.stdin.write("QUIT\n")
            self.process.stdin.flush()
            self.process.wait(timeout=30)
        self.log.close()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["verify", "time"], required=True)
    parser.add_argument("--model", choices=["sw", "eb"], required=True)
    parser.add_argument("--names", default=",".join(NAMES))
    parser.add_argument("--sizes", required=True)
    parser.add_argument("--uuid", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--repeats", type=int, default=12)
    parser.add_argument("--cpu", type=int)
    parser.add_argument("--allow-idle-step", action="append", default=[])
    parser.add_argument("--deadline-epoch", type=float)
    args = parser.parse_args()
    node_lock = None
    if args.mode == "time":
        if args.names.split(",") != NAMES or args.repeats != 12 or args.sizes != ("64,256,1024" if args.model == "sw" else "128,4096,65536"):
            raise RuntimeError("Final collection requires the frozen eight routes, twelve rounds and three sizes")
        if args.deadline_epoch is None or args.deadline_epoch - time.time() < 120:
            raise RuntimeError("Supply a live final collection deadline with cleanup reserve")
        if args.output.exists():
            raise RuntimeError("Retain existing raw collection; use a unique new output path")
        node_lock = (ROOT / ".runtime/goal_20261112/fresh_languages_node.lock").open("a+")
        fcntl.flock(node_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    meta = metadata(args.mode, args.uuid)
    import numba
    from numba import cuda
    import llvmlite
    meta["compiled_python_runtime"] = {"numba": numba.__version__, "llvmlite": llvmlite.__version__, "numba_module": numba.__file__, "cuda_provider": cuda.__file__, "cuda_provider_source_sha256": hashlib.sha256(Path(cuda.__file__).read_bytes()).hexdigest()}
    meta["declared_idle_steps"] = args.allow_idle_step
    meta["deadline_epoch"] = args.deadline_epoch
    meta["start_utc_ns"] = time.time_ns()
    if args.mode == "time" and (meta["affinity"] != [1] or meta["job"] != "8353767"):
        raise RuntimeError("Final timing requires job8353767 and hostCPU1")
    frozen = fingerprint()
    names = args.names.split(",")
    native = {name: runtime.Backend(name, args.model, 64 if name == "gpu_esm_fortran" and args.model == "sw" else None) for name in names if not name.startswith("julia")}
    records, qualifications = [], []
    args.output.parent.mkdir(parents=True, exist_ok=True)
    workers = {name: Julia(name, args.model, args.output.parent) for name in names if name.startswith("julia")}
    try:
        for size in map(int, args.sizes.split(",")):
            host, expected, input_row, expected_row = bank(args.model, size)
            folder = args.output.parent / f"{args.model}_{size}"
            folder.mkdir(parents=True, exist_ok=True)
            state = runtime.State(host, args.model)
            graphs, preparation = {}, {}
            try:
                for name, backend in native.items():
                    state.upload(host)
                    start = time.perf_counter_ns()
                    backend.enqueue(state, 1)
                    runtime.driver().gpu_sync()
                    warm_ns = time.perf_counter_ns() - start
                    state.upload(host)
                    start = time.perf_counter_ns()
                    graphs[name] = backend.capture(state, 1000)
                    capture_ns = time.perf_counter_ns() - start
                    count = ct.c_uint64()
                    runtime.driver().gpu_graph_nodes(graphs[name], ct.byref(count))
                    backend.enqueue(state, 1000)
                    validate(args.model, host, expected, snapshot(state), f"{name}/{size}/1000/ordinary")
                    state.upload(host)
                    runtime.driver().gpu_graph_launch(graphs[name])
                    validate(args.model, host, expected, snapshot(state), f"{name}/{size}/1000/replay")
                    preparation[name] = {"warm_ns": warm_ns, "capture_ns": capture_ns, "graph_nodes": count.value, "compiled_ptx": jit_identity(backend)}
                    qualifications.append({"name": name, "size": size, "steps": 1000, "differing_bytes": 0, "complete_states": ["q", "stage", "out"], "ghosts": True, "guards": True, "immutable_inputs": True, "ordinary_and_graph": True})
                    print(json.dumps({"qualified": name, "size": size}), flush=True)
                for name, worker in workers.items():
                    fields, prefix = worker.prepare(host, size, folder)
                    for suffix in ("-ordinary", "-replay"):
                        validate(args.model, host, expected, worker.arrays(str(prefix) + suffix, host), f"{name}/{size}/1000/{suffix}")
                    preparation[name] = {"graph_nodes": int(fields[2]), "allocation_ns": int(fields[3]), "warm_ns": int(fields[4]), "capture_ns": int(fields[5]), "graph_warm_ns": int(fields[6]), "versions": worker.versions}
                    qualifications.append({"name": name, "size": size, "steps": 1000, "differing_bytes": 0, "complete_states": ["q", "stage", "out"], "ghosts": True, "guards": True, "immutable_inputs": True, "ordinary_and_graph": True})
                    print(json.dumps({"qualified": name, "size": size}), flush=True)
                if args.mode == "time":
                    for repeat in range(args.repeats):
                        order = names[repeat % len(names):] + names[:repeat % len(names)]
                        for name in order:
                            if time.time() > args.deadline_epoch - 60:
                                raise RuntimeError("Final collection reached its cleanup reserve")
                            allowed = {os.getpid()} | {worker.process.pid for worker in workers.values()}
                            before = runtime.quiet(meta, allowed)
                            if name in workers:
                                prefix = folder / (name + "-timed-" + str(repeat))
                                fields = workers[name].command("RUN", size, prefix)
                                seconds = float(fields[1])
                                arrays = workers[name].arrays(prefix, host)
                            else:
                                state.upload(host)
                                until = time.monotonic() + 0.03
                                while time.monotonic() < until:
                                    runtime.driver().gpu_graph_launch(graphs[name])
                                    runtime.driver().gpu_sync()
                                    state.upload(host)
                                elapsed = ct.c_float()
                                runtime.driver().gpu_graph_time(graphs[name], ct.byref(elapsed))
                                seconds = float(elapsed.value) / 1000
                                arrays = snapshot(state)
                            after = runtime.observation(meta)
                            if {int(x.split(",")[0]) for x in after["processes"]} - allowed or after["load"][0] > 2.0:
                                raise RuntimeError("Foreign work disturbed the timed graph")
                            validate(args.model, host, expected, arrays, f"{name}/{size}/1000/repeat{repeat}")
                            records.append({"model": args.model, "size": size, "steps": 1000, "name": name, "repeat": repeat, "order": order, "milliseconds": seconds*1000, "seconds": seconds, "million_cell_steps_per_second": (size if args.model == "eb" else size*size) * 1000 / seconds / 1e6, "differing_bytes": 0, "before": before, "after": after, **preparation[name]})
                            print(json.dumps({k: records[-1][k] for k in ("name", "size", "repeat", "milliseconds")}), flush=True)
                            args.output.write_text(json.dumps({"passed": False, "metadata": meta, "fingerprint": frozen, "qualifications": qualifications, "records": records}, indent=2) + "\n")
            finally:
                for worker in workers.values():
                    if size in worker.prepared:
                        worker.command("CLOSE", size)
                        worker.prepared.remove(size)
                for graph in graphs.values():
                    runtime.driver().gpu_graph_close(graph)
                for array in state.arrays.values():
                    array.close()
        if fingerprint() != frozen:
            raise RuntimeError("Frozen source or binary changed during qualification or collection")
        args.output.write_text(json.dumps({"passed": True, "metadata": meta, "fingerprint": frozen, "qualifications": qualifications, "records": records, "end_utc_ns": time.time_ns(), "timer": "CUDA events around complete 1000step graph; startup, JIT, allocation, transfers, capture, warmup and validation excluded", "input_restoration": "All physical and scratch buffers and immutable constants restored before each replay; thirty milliseconds of matched replay/synchronise/restore warmup before each timed graph", "placement": "Six native/Numba routes share one guarded state; each Julia route uses its own guarded allocations on the same GPU and one pinned host CPU"}, indent=2) + "\n")
    finally:
        for backend in native.values():
            backend.close()
        for worker in workers.values():
            worker.close()
        if node_lock is not None:
            node_lock.close()

if __name__ == "__main__":
    main()

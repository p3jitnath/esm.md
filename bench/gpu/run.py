"""Reuse the frozen scientific verifier with complete GPU implementation adapters."""

import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import time
import os
import numpy as np

import runtime

ROOT = runtime.ROOT
# Load the original evaluator explicitly because this file also has the name run.py.
spec = importlib.util.spec_from_file_location("run", ROOT / "bench/run.py")
protocol = importlib.util.module_from_spec(spec)
sys.modules["run"] = protocol
spec.loader.exec_module(protocol)
sys.path.insert(0, str(ROOT / "bench"))
import energy_balance as eb

CPU_SW, CPU_EB = protocol._Backend, eb.Backend


class Julia:
    """Keep a separate warmed CUDA.jl worker for complete GPU trajectories."""

    def __init__(self, name, model, block=None):
        if block is None:
            block = runtime.preferred_block(name, model)
        self.name, self.model, self.block = name, model, block
        folder = ROOT / "bench/.runs/gpu" / model
        folder.mkdir(parents=True, exist_ok=True)
        self.folder = folder
        self.log = (folder / (name + ".log")).open("w")
        started = time.perf_counter_ns()
        self.process = subprocess.Popen(
            [str(ROOT / ".runtime/julia-1.12.7/bin/julia"), "--startup-file=no", "--threads=1",
             "-O3", "--math-mode=ieee", "--project=" + str(ROOT / ".runtime/julia-env"),
             str(ROOT / "bench/gpu/julia_driver.jl"), model, name],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=self.log, text=True, bufsize=1,
            env=dict(os.environ, JULIA_DEPOT_PATH=str(ROOT / ".runtime/julia-depot"),
                     JULIA_NUM_PRECOMPILE_TASKS="1", OPENBLAS_NUM_THREADS="1", OMP_NUM_THREADS="1"))
        ready = self.process.stdout.readline().strip().split("\t")
        if len(ready) != 3 or ready[0] != "READY":
            raise RuntimeError("CUDA.jl startup failed. See " + self.log.name)
        self.startup_ns = time.perf_counter_ns() - started
        self.metadata = {"version": ready[1], "cuda_jl": ready[2], "startup_ns": self.startup_ns}

    def trace(self, label, seed, *args):
        path = self.folder / (label + "-input.bin")
        trace = self.folder / (label + "-" + self.name + ".trace")
        prefix = self.folder / (label + "-" + self.name)
        if self.model == "eb":
            coeff, par, steps = args
            eb.write(path, eb.Buffers(seed, coeff, par).q, coeff, par)
            shape = (steps, 2, seed.size + 2)
        else:
            par, steps = args
            protocol._write(path, protocol._Buffers(seed, par).q, par)
            shape = (steps, 2, 3, seed.shape[1] + 2, seed.shape[2] + 2)
        self.process.stdin.write("TRACE\t%s\t%s\t%s\t%d\t%d\n" % (path, trace, prefix, steps, self.block))
        self.process.stdin.flush()
        if self.process.stdout.readline().strip() != "OK":
            raise RuntimeError("CUDA.jl trace failed. See " + self.log.name)
        return np.memmap(trace, mode="r", dtype="<f8", shape=shape), trace

    def close(self):
        if self.process.poll() is None:
            self.process.stdin.write("QUIT\n")
            self.process.stdin.flush()
            self.process.wait(timeout=30)
        self.log.close()

    def command(self, action, input_path, prefix, steps):
        self.process.stdin.write("%s\t%s\t%s\t%d\t%d\n" % (action, input_path, prefix, steps, self.block))
        self.process.stdin.flush()
        fields = self.process.stdout.readline().strip().split("\t")
        if not fields or fields[0] not in ("TIME", "CHECK"):
            raise RuntimeError("CUDA.jl command failed. See " + self.log.name)
        return fields


def verify(model, names, metadata, block):
    """Run every inherited physical, trajectory, boundary and canonical-byte check.

    Parameters
    ----------
    model : str
        sw or eb, selecting the frozen scientific contract.
    names : list of str
        Canonical CPU Fortran first, followed by GPU implementations.
    metadata : dict
        Verified allocation and GPU identity.
    block : int
        Threads per GPU block.

    Returns
    -------
    None
        The existing verifier writes its checked evidence to the GPU run folder.
    """
    protocol.RUNS = ROOT / "bench/.runs/gpu/sw"
    eb.RUNS = ROOT / "bench/.runs/gpu/eb"
    protocol.RUNS.mkdir(parents=True, exist_ok=True)
    eb.RUNS.mkdir(parents=True, exist_ok=True)
    protocol._fingerprint = eb.fingerprint = runtime.fingerprint
    protocol._software = lambda: {"python": sys.version, "gpu_requirements": (ROOT / "bench/gpu/requirements.txt").read_text()}
    inherited_sw_cases, inherited_eb_cases = protocol._cases, eb.cases
    inherited_sw_initial, inherited_eb_inputs = protocol._initial, eb.inputs
    def sw_initial(case, nx, ny):
        if case != "tiny-momentum":
            return inherited_sw_initial(case, nx, ny)
        values = inherited_sw_initial("uniform", nx, ny)
        values[1] = np.ldexp(1.0, -1024)
        values[2] = -np.ldexp(1.0, -1024)
        return values
    def eb_inputs(n, case="climate", dt=None):
        if case != "subnormal":
            return inherited_eb_inputs(n, case, dt)
        seed = np.full(n, np.ldexp(3.0, -1074))
        coeff = np.zeros((3, n + 2))
        par = np.array([1.0, 0.1, 2.0 / n, 0.0, 0.0, -10.0])
        return seed, coeff, par, None
    def sw_cases():
        yield from inherited_sw_cases()
        for nx, ny in ((1, 7), (7, 1), (1, 129), (129, 1), (127, 3), (131, 3)):
            yield "mixed", nx, ny, 3, None
        for nx, ny in ((64, 64), (65, 64), (256, 256), (257, 256)):
            yield "mixed", nx, ny, 2, None
        yield "tiny-momentum", 7, 5, 3, None
    def eb_cases():
        yield from inherited_eb_cases()
        for n in (1, 127, 129):
            yield "climate", n, 3, None
        for n in (1, 128, 129):
            yield "subnormal", n, 3, 0.1
    protocol._cases, eb.cases = sw_cases, eb_cases
    protocol._initial, eb.inputs = sw_initial, eb_inputs
    if model == "sw":
        protocol._Julia = lambda name: Julia(name, "sw", block)
        protocol._Backend = lambda name: CPU_SW(name) if name == "fortran_vanilla" else runtime.Backend(name, "sw", block)
        protocol._verify(names, metadata)
    else:
        eb.Julia = lambda name: Julia(name, "eb", block)
        eb.Backend = lambda name: CPU_EB(name) if name == "fortran_vanilla" else runtime.Backend(name, "eb", block)
        eb.NAMES = tuple(names)
        eb.verify(names, metadata)
    folder = protocol.RUNS if model == "sw" else eb.RUNS
    suffix = next((name for name in names if name.startswith("julia")), "native")
    (folder / ("verification-" + suffix + ".json")).write_bytes((folder / "verification.json").read_bytes())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", choices=("sw", "eb"), required=True)
    parser.add_argument("--mode", choices=("verify", "graphs", "benchmark"), default="verify")
    parser.add_argument("--names", default="fortran_vanilla,assembly,gpu_fortran_vanilla,gpu_python_vanilla")
    parser.add_argument("--block", type=int, default=None)
    parser.add_argument("--sizes", default=None)
    parser.add_argument("--counts", default=None)
    parser.add_argument("--repeats", type=int, default=12)
    parser.add_argument("--repeat-start", type=int, default=0)
    parser.add_argument("--output", type=Path, default=None)
    parser.add_argument("--screening", action="store_true", help="Screen candidates with ordinary and replay byte checks before the final frozen gates.")
    args = parser.parse_args()
    names = args.names.split(",")
    julias = [name for name in names if name.startswith("julia")]
    if julias and (len(julias) != 1 or any(name not in ("fortran_vanilla", julias[0]) for name in names)):
        raise ValueError("The GPU permits one process at a time. Verify each Julia variant separately against CPU Fortran.")
    metadata = runtime.allocation(initialize=not julias)
    print(json.dumps({"allocation": metadata}), flush=True)
    if args.mode == "verify":
        verify(args.model, names, metadata, args.block)
    elif args.mode == "graphs":
        import benchmark
        output = args.output or ROOT / "bench/.runs/gpu" / args.model / ("graphs-" + (julias[0] if julias else "native") + ".json")
        benchmark.graphs(protocol, eb, args.model, names, metadata, args.block, CPU_SW, CPU_EB, output, Julia)
    else:
        import benchmark
        if not args.screening:
            benchmark.require_verified(args.model, names)
        sizes = [int(value) for value in (args.sizes or ("128,4096,65536" if args.model == "eb" else "64,256,1024")).split(",")]
        counts = [int(value) for value in (args.counts or ("512,256,128" if args.model == "eb" else "256,128,32")).split(",")]
        if len(sizes) != len(counts) or any(steps < 1 or steps > 1000000 for steps in counts):
            raise ValueError("Each valid workload needs one supported positive step count.")
        output = args.output or ROOT / "bench/.runs/gpu" / (args.model + "-timing.json")
        if julias:
            benchmark.julia(protocol, eb, args.model, julias[0], sizes, counts, args.repeats, metadata, args.block,
                            CPU_SW, CPU_EB, output, Julia, args.repeat_start)
        else:
            benchmark.native(protocol, eb, args.model, names, sizes, counts, args.repeats, metadata, args.block,
                             CPU_SW, CPU_EB, output, args.repeat_start)


if __name__ == "__main__":
    main()

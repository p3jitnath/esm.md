"""Measure compatible memory, rounded arithmetic and launch rates on the solver GPU."""

import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import statistics
import time

import numpy as np

import runtime
import run  # Register the inherited CPU activity helpers used by runtime.quiet.


def properties():
    """Return device attributes read from the installed CUDA driver.

    Returns
    -------
    dict
        Actual cache, memory bus, clock and multiprocessor attributes.
    """
    lib = ct.CDLL("libcuda.so.1")
    lib.cuDeviceGetAttribute.argtypes = [ct.POINTER(ct.c_int), ct.c_int, ct.c_int]
    result = {}
    for name, attribute in (("multiprocessors", 16), ("l2_cache_bytes", 38),
                            ("nominal_clock_khz", 13), ("memory_clock_khz", 36),
                            ("memory_bus_bits", 37), ("max_threads_per_sm", 39)):
        value = ct.c_int()
        if lib.cuDeviceGetAttribute(ct.byref(value), attribute, 0):
            raise RuntimeError("A CUDA device attribute is unavailable.")
        result[name] = value.value
    return result


def expected(name, a, b, iterations):
    """Reproduce the probe rounding for an independent CPU check.

    Parameters
    ----------
    name : str
        copy, ordinary, divide or sqrt.
    a, b : ndarray of float64
        Finite input values from selected thread indices.
    iterations : int
        Positive operation-loop count.

    Returns
    -------
    ndarray of float64
        Exact binary64 reference output in probe order.
    """
    if name == "copy":
        return a.copy()
    chains = [a.copy()] + [a + float(2**k) for k in range(7)]
    for _ in range(iterations):
        if name == "ordinary":
            chains = [(value + b) * 0.5 for value in chains]
        elif name == "divide":
            chains = [value / b for value in chains]
        else:
            chains = [np.sqrt(value) for value in chains]
    result = chains[0]
    for value in chains[1:]:
        result = result + value
    return result


def measure(name, label, n, iterations, launches, metadata, repeats):
    """Validate a calibration entry and record quiet same-stream event timings.

    Returns
    -------
    dict
        Repeated rates, actual resources and telemetry for this probe.
    """
    a = np.linspace(1.0, 1.02, n)
    b = np.full(n, 1.00001)
    arrays = [runtime.Array(value) for value in (a, b, np.full(n, np.nan))]
    probe = runtime.Probe(runtime.BUILD / "probes.cubin", "probe_" + name, block=128)
    graph = ct.c_void_p()
    try:
        probe.enqueue(n, iterations, *arrays)
        actual = arrays[2].get()
        indices = np.unique(np.linspace(0, n - 1, min(n, 129), dtype=int))
        if name != "empty":
            reference = expected(name, a[indices], b[indices], iterations)
            if not np.array_equal(actual[indices].view(np.uint64), reference.view(np.uint64)):
                raise AssertionError("A calibration output differs from its CPU rounding check.")
        runtime.driver().gpu_capture_begin()
        for _ in range(launches):
            probe.enqueue(n, iterations, *arrays)
        runtime.driver().gpu_capture_end(ct.byref(graph))
        samples = []
        for repeat in range(repeats):
            before = runtime.quiet(metadata)
            warmed = time.monotonic()
            while time.monotonic() - warmed < 0.03:
                runtime.driver().gpu_graph_launch(graph)
                runtime.driver().gpu_sync()
            elapsed = ct.c_float()
            runtime.driver().gpu_graph_time(graph, ct.byref(elapsed))
            after = runtime.observation(metadata)
            result = arrays[2].get()
            if name != "empty" and not np.array_equal(result[indices].view(np.uint64), reference.view(np.uint64)):
                raise AssertionError("A timed calibration result changed.")
            samples.append({"repeat": repeat, "seconds": elapsed.value / 1000,
                            "before": before, "after": after})
        for array, original in zip(arrays[:2], (a, b)):
            if not np.array_equal(array.get().view(np.uint64), original.view(np.uint64)):
                raise AssertionError("A calibration input changed.")
        seconds = [sample["seconds"] for sample in samples]
        # Ordinary has eight separate add/multiply chains and no model FMA.
        operations = n * iterations * (16 if name == "ordinary" else 8) * launches
        quantity = n * 16 * iterations * launches if name == "copy" else launches if name == "empty" else operations
        record = {"probe": label, "entry": name, "values": n, "iterations": iterations, "launches": launches,
                  "samples": samples, "median_seconds": statistics.median(seconds),
                  "min_seconds": min(seconds), "max_seconds": max(seconds),
                  "median_rate_per_second": quantity / statistics.median(seconds),
                  "rate_unit": "bytes/s" if name == "copy" else "launches/s" if name == "empty" else "operations/s",
                  "working_set_bytes": 16 * n if name == "copy" else 24 * n,
                  "checked_values": len(indices), "differing_bytes": 0,
                  "output_sha256": hashlib.sha256(result.tobytes()).hexdigest(), **probe.attributes()}
        print(json.dumps({k: record[k] for k in ("probe", "median_rate_per_second", "rate_unit")}), flush=True)
        return record
    finally:
        if graph.value:
            runtime.driver().gpu_graph_close(graph)
        probe.close()
        for array in arrays:
            array.close()


def main():
    """Calibrate ordinary FP64, true division, true square root and GPU copies."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repeats", type=int, default=12)
    parser.add_argument("--output", type=Path, default=runtime.ROOT / "bench/.runs/gpu/calibration.json")
    args = parser.parse_args()
    metadata = runtime.allocation()
    cases = [("copy", "copy-hbm", 2**24, 1, 16), ("copy", "copy-cache", 2**18, 32, 4),
             ("ordinary", "ordinary", 2**18, 256, 1), ("divide", "divide", 2**18, 128, 1),
             ("sqrt", "sqrt", 2**18, 128, 1), ("ordinary", "ordinary-one-sm", 128, 512, 1),
             ("divide", "divide-one-sm", 128, 512, 1),
             ("empty", "launch", 1, 1, 256)]
    records = [measure(*case, metadata, args.repeats) for case in cases]
    nvml = runtime.management()
    handle = nvml.nvmlDeviceGetHandleByUUID(metadata["uuid"])
    hardware = properties()
    hardware.update(memory_total_bytes=nvml.nvmlDeviceGetMemoryInfo(handle).total,
                    driver=nvml.nvmlSystemGetDriverVersion(),
                    power_limit_watts=nvml.nvmlDeviceGetPowerManagementLimit(handle) / 1000,
                    compute_mode=nvml.nvmlDeviceGetComputeMode(handle))
    report = {"passed": True, "metadata": metadata, "hardware": hardware, "records": records,
              "fingerprint": runtime.fingerprint(),
              "scope": "Empirical calibration guides with explicit rounded FP64 and no tensor arithmetic",
              "validation": "Guard checks, unchanged inputs and 129 sampled output values per probe",
              "ordinary_count": "Sixteen loop operations per iteration with fourteen setup and reduction adds excluded",
              "memory_count": "One eight-byte load and one eight-byte store per value and iteration, logical traffic"}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()

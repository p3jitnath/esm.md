"""Connect flat guarded GPU arrays to host-only CUDA launch and timing calls."""

import ctypes as ct
import hashlib
import importlib.util
import os
import re
from pathlib import Path
import subprocess
import time
import weakref

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "bench/.build/gpu"
CANARY = np.uint64(0x7FF4DEADBEEF5678)
_driver = None
_nvml = None


def management():
    """Return NVIDIA telemetry without creating a GPU compute context."""
    global _nvml
    if _nvml is None:
        import pynvml
        pynvml.nvmlInit()
        _nvml = pynvml
    return _nvml


def driver():
    """Return the checked CUDA driver interface, using the primary context.

    Returns
    -------
    ctypes.CDLL
        Host library on CUDA-visible device zero.

    Raises
    ------
    RuntimeError
        A CUDA call fails or the shared library is unavailable.
    """
    global _driver
    if _driver is not None:
        return _driver
    lib = ct.CDLL(str(BUILD / "libdriver.so"))
    u64, pointer, integer = ct.c_uint64, ct.c_void_p, ct.c_int
    signatures = {
        "gpu_init": [integer], "gpu_info": [pointer, pointer],
        "gpu_alloc": [u64, ct.POINTER(u64)], "gpu_free": [u64],
        "gpu_upload": [u64, pointer, u64], "gpu_download": [pointer, u64, u64],
        "gpu_model_open": [ct.c_char_p, integer, integer, integer, ct.POINTER(pointer)],
        "gpu_model_close": [pointer],
        "gpu_model_layout": [pointer, ct.c_uint, ct.c_uint, ct.POINTER(integer), ct.POINTER(integer), ct.POINTER(integer)],
        "gpu_enqueue": [pointer, ct.c_uint, ct.c_uint] + [u64] * 6 + [ct.c_uint],
        "gpu_capture_begin": [], "gpu_capture_end": [ct.POINTER(pointer)],
        "gpu_graph_launch": [pointer], "gpu_graph_close": [pointer],
        "gpu_graph_time": [pointer, ct.POINTER(ct.c_float)],
        "gpu_graph_nodes": [pointer, ct.POINTER(u64)], "gpu_sync": [],
        "gpu_probe_open": [ct.c_char_p, ct.c_char_p, ct.POINTER(pointer)],
        "gpu_probe_launch": [pointer, ct.c_uint, ct.c_uint, u64, u64, u64, ct.c_uint],
        "gpu_probe_close": [pointer],
        "gpu_probe_attributes": [pointer, ct.POINTER(integer), ct.POINTER(integer), ct.POINTER(integer)],
    }
    lib.gpu_error.restype = ct.c_char_p
    lib.gpu_stream.restype = u64
    for name, arguments in signatures.items():
        function = getattr(lib, name)
        function.argtypes = arguments
        function.restype = integer
        function.errcheck = lambda result, function, arguments: _checked(result, lib)
    lib.gpu_init(0)
    _driver = lib
    return lib


def _checked(result, lib):
    if result:
        raise RuntimeError(lib.gpu_error().decode())
    return result


class Array:
    """Own one disjoint FP64 allocation with sixteen guard words on each side."""

    def __init__(self, values):
        self.shape = values.shape
        self.size = values.size
        self.raw = np.full(self.size + 32, CANARY, dtype=np.uint64)
        allocation = ct.c_uint64()
        driver().gpu_alloc(self.raw.nbytes, ct.byref(allocation))
        self.allocation = allocation.value
        self.pointer = self.allocation + 128
        self.raw[16:-16] = np.ascontiguousarray(values).view(np.uint64).ravel()
        driver().gpu_upload(self.allocation, self.raw.ctypes.data, self.raw.nbytes)
        self._view = None

    def put(self, values):
        values = np.ascontiguousarray(values, dtype=np.float64)
        if values.shape != self.shape:
            raise ValueError("A GPU buffer shape changed.")
        driver().gpu_upload(self.pointer, values.ctypes.data, values.nbytes)

    def get(self):
        driver().gpu_download(self.raw.ctypes.data, self.allocation, self.raw.nbytes)
        if not (np.all(self.raw[:16] == CANARY) and np.all(self.raw[-16:] == CANARY)):
            raise AssertionError("A GPU kernel changed a buffer guard.")
        return self.raw[16:-16].view(np.float64).reshape(self.shape).copy()

    @property
    def view(self):
        if self._view is None:
            from numba import cuda
            interface = {
                "shape": (self.size,), "strides": None, "typestr": "<f8",
                "data": (self.pointer, False), "version": 3, "stream": None,
            }
            holder = type("DeviceView", (), {"__cuda_array_interface__": interface})()
            self._view = cuda.as_cuda_array(holder, sync=False)
        return self._view

    def close(self):
        if self.allocation:
            driver().gpu_free(self.allocation)
            self.allocation = 0

    def __del__(self):
        if getattr(self, "allocation", 0):
            self.close()


class State:
    """Keep the exact model layout and immutable inputs in guarded GPU memory."""

    def __init__(self, host, model):
        self.model = model
        self.names = ("q", "stage", "out", "work", "coeff", "par") if model == "eb" else (
            "q", "stage", "out", "work", "parameters")
        self.arrays = {name: Array(getattr(host, name)) for name in self.names}
        self.nx = host.q.size - 2 if model == "eb" else host.q.shape[2] - 2
        self.ny = 1 if model == "eb" else host.q.shape[1] - 2

    def upload(self, host):
        for name, array in self.arrays.items():
            array.put(getattr(host, name))

    def download(self, host):
        for name, array in self.arrays.items():
            getattr(host, name)[:] = array.get()

    def pointers(self):
        par = "par" if self.model == "eb" else "parameters"
        return [self.arrays[name].pointer for name in ("q", "stage", "out", "work")] + [
            self.arrays["coeff"].pointer if self.model == "eb" else 0,
            self.arrays[par].pointer]


class Backend:
    """Launch direct or independently compiled controls on identical buffers."""

    def __init__(self, name, model, block=None):
        if block is None:
            block = preferred_block(name, model)
        self.name, self.model, self.block = name, model, block
        suffix = re.search(r"_b(\d+)$", name)
        source_name = name
        if suffix:
            self.block = int(suffix[1])
            source_name = name[:suffix.start()]
        self.states = weakref.WeakKeyDictionary()
        self.handle = None
        if "python" in name:
            from numba import cuda
            self.stream = cuda.external_stream(driver().gpu_stream())
            source = "vanilla" if source_name.endswith("_vanilla") else "solver"
            path = ROOT / "src" / ("budyko_sellers" if model == "eb" else "shallow_water") / "gpu" / (source + ".py")
            spec = importlib.util.spec_from_file_location(model + "_gpu_" + source, path)
            self.module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(self.module)
        else:
            variant = "assembly" if source_name == "assembly" else source_name.removeprefix("gpu_")
            path = BUILD / (model + "_" + variant + ".cubin")
            self.handle = ct.c_void_p()
            fused = 0 if variant.endswith("_vanilla") or (model == "sw" and variant == "baseline") else 2 if model == "eb" and variant == "baseline" else 1
            driver().gpu_model_open(str(path).encode(), model == "eb", fused, self.block, ct.byref(self.handle))

    def state(self, host):
        if host not in self.states:
            self.states[host] = State(host, self.model)
        return self.states[host]

    def enqueue(self, state, steps):
        if self.handle:
            driver().gpu_enqueue(self.handle, state.nx, state.ny, *state.pointers(), steps)
        else:
            args = [state.arrays[name].view for name in ("q", "stage", "out", "work")]
            dims = (np.int32(state.nx),) if self.model == "eb" else (np.int32(state.nx), np.int32(state.ny))
            if self.model == "eb":
                args += [state.arrays["coeff"].view, state.arrays["par"].view]
            else:
                args += [state.arrays["parameters"].view]
            self.module.enqueue(*dims, *args, steps, self.stream, self.block)

    def run(self, host, steps):
        state = self.state(host)
        state.upload(host)
        self.enqueue(state, steps)
        state.download(host)

    def layout(self, nx, ny):
        if self.handle:
            block, grid_y, grid_z = ct.c_int(), ct.c_int(), ct.c_int()
            driver().gpu_model_layout(self.handle, nx, ny, ct.byref(block), ct.byref(grid_y), ct.byref(grid_z))
            return {"threads": block.value, "grid_y": grid_y.value, "grid_z": grid_z.value}
        return launch_layout(self.name, self.model, nx, ny, self.block)

    def step(self, host):
        self.run(host, 1)

    def bind(self, host, steps):
        return lambda: self.run(host, steps)

    def capture(self, state, steps):
        driver().gpu_capture_begin()
        self.enqueue(state, steps)
        graph = ct.c_void_p()
        driver().gpu_capture_end(ct.byref(graph))
        return graph

    def close(self):
        self.states.clear()
        if self.handle:
            driver().gpu_model_close(self.handle)
            self.handle = None


class Probe:
    """Launch one documented calibration or arithmetic-check entry."""

    def __init__(self, path, symbol, block=256):
        self.handle = ct.c_void_p()
        self.block = block
        driver().gpu_probe_open(str(path).encode(), symbol.encode(), ct.byref(self.handle))

    def enqueue(self, n, iterations, a, b, out):
        driver().gpu_probe_launch(self.handle, n, iterations, a.pointer, b.pointer, out.pointer, self.block)

    def attributes(self):
        registers, shared, multiprocessors = ct.c_int(), ct.c_int(), ct.c_int()
        driver().gpu_probe_attributes(self.handle, ct.byref(registers), ct.byref(shared), ct.byref(multiprocessors))
        return {"registers": registers.value, "shared_bytes": shared.value, "multiprocessors": multiprocessors.value}

    def close(self):
        if self.handle:
            driver().gpu_probe_close(self.handle)
            self.handle = None


def preferred_block(name, model):
    """Use measured defaults while preserving an explicit experimental block size."""
    return 64 if model == "sw" and name in ("assembly", "gpu_fortran", "gpu_python", "julia") else 128


def launch_layout(name, model, nx, ny, block):
    """Record the actual tuned host launch geometry in every timing sample."""
    if model == "sw" and name in ("assembly", "gpu_fortran", "gpu_python", "julia"):
        if nx * ny <= 4096:
            return {"threads": block, "grid_y": 1, "grid_z": 3}
        if nx * ny <= 65536:
            return {"threads": 128, "grid_y": ny, "grid_z": 1}
    if model == "eb" and name in ("assembly", "gpu_fortran", "gpu_python", "julia") and nx <= 128:
        return {"threads": 128, "grid_y": 1, "grid_z": 1, "persistent": True}
    return {"threads": block, "grid_y": 1, "grid_z": 1}


def fingerprint():
    """Hash the scientific input, GPU sources, build route, and actual binaries.

    Returns
    -------
    dict of str to str
        Relative paths mapped to SHA256 identifiers.
    """
    paths = [ROOT / "Makefile", ROOT / "bench/fp_env.S", ROOT / "bench/run.py", ROOT / "bench/energy_balance.py"]
    paths += list((ROOT / "formulations").glob("*.md"))
    paths += list((ROOT / "skills/md2asm/references").glob("*.md"))
    paths += list((ROOT / "skills/md2asm-gpu").rglob("*.md"))
    paths += [p for p in (ROOT / "src").glob("*/gpu/*") if p.suffix in (".ptx", ".cuf", ".py", ".jl")]
    paths += list((ROOT / "src").glob("*/vanilla.f90"))
    paths += [p for p in (ROOT / "bench/gpu").glob("*") if p.is_file() and p.suffix in (".py", ".cpp", ".jl", ".txt", ".ptx", ".sh")]
    paths += [BUILD / (model + "_" + name + ".cubin") for model in ("sw", "eb")
              for name in ("assembly", "fortran", "fortran_vanilla", "pass1")]
    paths += [BUILD / "probes.cubin", BUILD / "libdriver.so", ROOT / "bench/.build/libfp_env.so"]
    paths += list((ROOT / "bench/.build").glob("*fortran_vanilla.so"))
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(paths)}


def allocation(initialize=True):
    """Check the current exclusive node and record the actual selected GPU.

    Returns
    -------
    dict
        Scheduler, host affinity, FPCR, GPU identity, and quiet-node evidence.

    Raises
    ------
    RuntimeError
        The node is shared, unallocated, disturbed, or has the wrong FPCR.
    """
    job = os.environ.get("SLURM_JOB_ID")
    node = subprocess.check_output(["hostname"], text=True).strip()
    if not job:
        raise RuntimeError("GPU work requires a live compute allocation.")
    detail = subprocess.check_output(["scontrol", "show", "job", job], text=True)
    occupants = subprocess.check_output(["squeue", "-h", "-w", node, "-o", "%i"], text=True).split()
    if occupants != [job] or "Exclusive=NODE" not in detail or "JobState=RUNNING" not in detail:
        raise RuntimeError("An exclusive running node allocation is required.")
    if len(os.sched_getaffinity(0)) != 1:
        raise RuntimeError("Pin the evaluation driver to one host CPU.")
    env = ct.CDLL(str(ROOT / "bench/.build/libfp_env.so"))
    env.sw_fpcr.restype = ct.c_uint64
    if env.sw_fpcr() != 0:
        raise RuntimeError("The canonical CPU reference requires FPCR=0.")
    if initialize:
        name, uuid = ct.create_string_buffer(128), ct.create_string_buffer(41)
        driver().gpu_info(name, uuid)
        name, uuid = name.value.decode(), uuid.value.decode()
    else:
        device = os.environ.get("CUDA_VISIBLE_DEVICES", "0").split(",")[0]
        name, uuid = subprocess.check_output(["nvidia-smi", "-i", device,
            "--query-gpu=name,uuid", "--format=csv,noheader"], text=True).strip().split(", ")
    metadata = {"job": job, "step": os.environ.get("SLURM_STEP_ID"), "node": node, "affinity": sorted(os.sched_getaffinity(0)),
                "slurm": detail, "gpu": name, "uuid": uuid,
                "cuda_visible_devices": os.environ.get("CUDA_VISIBLE_DEVICES"), "fpcr": 0}
    metadata["initial_observation"] = observation(metadata)
    return metadata


def observation(metadata, scheduler=True):
    """Read live scheduler occupancy and GPU telemetry outside a timer.

    Parameters
    ----------
    metadata : dict
        Verified node, job, affinity, and GPU UUID.

    Returns
    -------
    dict
        CPU load and selected GPU utilisation, clocks, temperature and power.
    """
    if sorted(os.sched_getaffinity(0)) != metadata["affinity"]:
        raise RuntimeError("The allocation or host affinity changed.")
    nvml = management()
    device = nvml.nvmlDeviceGetHandleByUUID(metadata["uuid"])
    gpu = {"uuid": metadata["uuid"], "utilization.gpu": str(nvml.nvmlDeviceGetUtilizationRates(device).gpu),
           "memory.used": str(nvml.nvmlDeviceGetMemoryInfo(device).used // 1048576),
           "clocks.sm": str(nvml.nvmlDeviceGetClockInfo(device, nvml.NVML_CLOCK_SM)),
           "clocks.mem": str(nvml.nvmlDeviceGetClockInfo(device, nvml.NVML_CLOCK_MEM)),
           "temperature.gpu": str(nvml.nvmlDeviceGetTemperature(device, nvml.NVML_TEMPERATURE_GPU)),
           "power.draw": str(nvml.nvmlDeviceGetPowerUsage(device) / 1000),
           "pstate": "P" + str(nvml.nvmlDeviceGetPerformanceState(device)),
           "throttle_reasons": int(nvml.nvmlDeviceGetCurrentClocksThrottleReasons(device))}
    processes = ["%d, GPU compute process, %s MiB" % (p.pid, p.usedGpuMemory // 1048576)
                 for p in nvml.nvmlDeviceGetComputeRunningProcesses(device)]
    result = {"utc_ns": time.time_ns(), "load": os.getloadavg(), "gpu": gpu, "processes": processes}
    if scheduler:
        occupants = subprocess.check_output(["squeue", "-h", "-w", metadata["node"], "-o", "%i"], text=True).split()
        steps = subprocess.check_output(["squeue", "--steps", "-h", "-j", metadata["job"], "-o", "%i"], text=True).split()
        if occupants != [metadata["job"]] or steps != [metadata["job"] + "." + metadata["step"]]:
            raise RuntimeError("Another Slurm step is active on the benchmark node.")
        result["scheduler_checked_utc_ns"] = time.time_ns()
    return result


def quiet(metadata, allowed_pids=None):
    """Require settled CPU activity, an idle GPU and only authorised processes.

    Parameters
    ----------
    metadata : dict
        Verified live allocation and fixed GPU identity.
    allowed_pids : set of int, optional
        Current evaluation processes permitted to own the selected GPU.

    Returns
    -------
    dict
        The accepted scheduler, CPU and GPU observation.

    Raises
    ------
    RuntimeError
        The node does not meet the fixed quiet limits within ten seconds.
    """
    from run import _cpu_ticks, _foreign_load
    allowed = {os.getpid()} if allowed_pids is None else set(allowed_pids)
    observation(metadata)
    started, settled = time.monotonic(), 0
    while settled < 2:
        before = _cpu_ticks()
        time.sleep(0.2)
        foreign = _foreign_load(before, _cpu_ticks())
        result = observation(metadata, scheduler=False)
        pids = {int(line.split(",")[0]) for line in result["processes"]}
        accepted = result["load"][0] <= 2.0 and foreign <= 1.0 and int(result["gpu"]["utilization.gpu"]) == 0 and pids <= allowed
        settled = settled + 1 if accepted else 0
        if settled < 2 and time.monotonic() - started > 10:
            raise RuntimeError("Quiet limits failed. Load %.3f, foreign cores %.3f, GPU utilisation %s, processes %s" % (
                result["load"][0], foreign, result["gpu"]["utilization.gpu"], sorted(pids)))
    result["foreign_busy_cores"] = foreign
    result["settle_seconds"] = time.monotonic() - started
    return result

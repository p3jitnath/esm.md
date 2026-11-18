"""Draft matched CPU measurements for one accepted spatial configuration.

Run only during the CPU campaign, under the shared node lock and an external
process timeout. This script owns input restoration and timing. The native
coordinator owns every numerical stage, halo update and state publication.
"""

import argparse
import ctypes
import gc
import hashlib
import json
import mmap
import os
from pathlib import Path
import resource
import subprocess
import sys
import time

import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE))
import verify_tiles as check
import frozen_inputs
import canonical_banks

P = ctypes.POINTER(ctypes.c_double)
I = ctypes.c_int
L = ctypes.c_int64
IP = ctypes.POINTER(I)


def pointer(array):
    """Return a borrowed FP64 pointer without copying its array.

    Parameters
    ----------
    array : numpy.ndarray of float64
        Contiguous state, parameter or scratch array whose storage the caller owns.

    Returns
    -------
    ctypes.POINTER(ctypes.c_double)
        Address of the first value; the array's shape and units remain unchanged.

    Notes
    -----
    The caller must keep the array alive throughout the native call. This helper
    neither writes the array nor transfers its storage to the native routine.
    """
    return array.ctypes.data_as(P)


def digest(path):
    """Identify the stored bytes of one retained artifact.

    Parameters
    ----------
    path : str or pathlib.Path
        Existing source, library or evidence file to read without mutation.

    Returns
    -------
    str
        Hexadecimal SHA256 identifier of the complete file.

    Raises
    ------
    OSError
        If the artifact cannot be read.
    """
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def cpu_list(text):
    """Expand a Linux CPU list into integer CPU identifiers.

    Parameters
    ----------
    text : str
        Comma-separated CPU identifiers or inclusive ranges, such as ``0-3,8``.

    Returns
    -------
    list of int
        Expanded identifiers in the order supplied by the input text.

    Raises
    ------
    ValueError
        If an identifier or range endpoint is not an integer.
    """
    result = []
    if not text.strip():
        return result
    for item in text.strip().split(","):
        limits = list(map(int, item.split("-")))
        result.extend(range(limits[0], limits[-1] + 1))
    return result


def placement(threads, mode):
    """Choose distinct CPUs in a compact or balanced memory-domain team.

    Parameters
    ----------
    threads : int
        Number of CPU owners requested within the process's visible allocation.
    mode : {'compact', 'balanced'}
        Fill memory domains in order or distribute workers across visible domains.

    Returns
    -------
    list of int
        Linux CPU identifiers in the planned OpenMP worker order.

    Raises
    ------
    ValueError
        If the requested team is empty or exceeds the visible CPU allocation.
    RuntimeError
        If a domain cannot supply its share of the balanced team.
    OSError
        If the operating-system topology records cannot be read.

    Notes
    -----
    This helper changes no affinity. The launcher must set ``OMP_PLACES`` before
    loading OpenMP. On four equal domains, balanced teams of 248, 128 and 144 use
    62, 32 and 36 CPUs per domain, respectively.
    """
    allowed = os.sched_getaffinity(0)
    domains = []
    for node in sorted(Path("/sys/devices/system/node").glob("node[0-9]*")):
        cores = [x for x in cpu_list((node / "cpulist").read_text()) if x in allowed]
        if cores:
            domains.append(cores)
    if threads < 1 or threads > sum(len(domain) for domain in domains):
        raise ValueError("The requested CPU team exceeds the visible allocation.")
    if mode == "compact":
        return [cpu for domain in domains for cpu in domain][:threads]
    counts = [
        threads // len(domains) + int(i < threads % len(domains))
        for i in range(len(domains))
    ]
    if any(count > len(domain) for count, domain in zip(counts, domains)):
        raise RuntimeError("The requested balanced memory-domain team is unavailable.")
    return [cpu for domain, count in zip(domains, counts) for cpu in domain[:count]]


class GuardedMapping:
    """Own an untouched, page-aligned FP64 array with adjacent guards.

    Parameters
    ----------
    shape : tuple of int
        NumPy array dimensions; their product is the number of FP64 values.

    Attributes
    ----------
    array : numpy.ndarray of float64
        Mutable data view with the requested shape and the caller's physical units.
    raw : numpy.ndarray of uint64
        Bit view of the data plus 16 guard words on each side.
    mapping : mmap.mmap
        Anonymous storage owner that must outlive both array views.

    Raises
    ------
    OSError
        If the operating system cannot allocate the anonymous mapping.
    RuntimeError
        If the data address is not aligned to an operating-system page.

    Notes
    -----
    Construction does not write the data pages. Restore data through their native
    owners before setting guards, so those workers first-touch the pages. A page
    shared by neighbouring tiles can belong to only one memory domain.
    """

    def __init__(self, shape):
        """Allocate uninitialised data pages and their guard views.

        Parameters
        ----------
        shape : tuple of int
            Dimensions of the owned FP64 data array in NumPy order.

        Returns
        -------
        None
            Initialise this instance without writing the data or guard words.

        Raises
        ------
        OSError
            If the anonymous mapping cannot be created.
        RuntimeError
            If the resulting data address is not page aligned.
        """
        count = int(np.prod(shape, dtype=np.int64))
        self.page = mmap.PAGESIZE
        data_bytes = count * 8
        rounded = ((data_bytes + self.page - 1) // self.page) * self.page
        self.mapping = mmap.mmap(
            -1,
            rounded + 2 * self.page,
            flags=mmap.MAP_PRIVATE | mmap.MAP_ANONYMOUS,
            prot=mmap.PROT_READ | mmap.PROT_WRITE,
        )
        self.array = np.ndarray(
            shape, dtype=np.float64, buffer=self.mapping, offset=self.page
        )
        self.raw = np.ndarray(
            (count + 32,), dtype=np.uint64, buffer=self.mapping, offset=self.page - 128
        )
        self.start = self.array.ctypes.data
        self.end = self.start + data_bytes
        if self.start % self.page:
            raise RuntimeError("Anonymous solver data are not page aligned.")

    def set_guards(self):
        """Write the guard words after the owners first-touch the data.

        Returns
        -------
        None
            Mutate the 16 uint64 words immediately before and after the data.

        Notes
        -----
        The FP64 data words remain unchanged. The trailing guard can share the last
        data page, which is why this operation follows native data restoration.
        """
        self.raw[:16] = check.shared.protocol.CANARY
        self.raw[-16:] = check.shared.protocol.CANARY

    def check(self):
        """Check that the native call preserved both boundary guards.

        Returns
        -------
        None
            Leave the owned mapping and its views unchanged.

        Raises
        ------
        AssertionError
            If either set of adjacent uint64 guard words differs from its canary.
        """
        if not (
            np.all(self.raw[:16] == check.shared.protocol.CANARY)
            and np.all(self.raw[-16:] == check.shared.protocol.CANARY)
        ):
            raise AssertionError("A mapped solver buffer guard changed.")

    def numa_record(self):
        """Read the memory-domain records for this live array mapping.

        Returns
        -------
        dict
            Data address, byte count, page size in bytes and raw ``numa_maps`` rows.

        Raises
        ------
        OSError
            If the process's virtual-memory records cannot be read.

        Notes
        -----
        The rows describe whole overlapping virtual mappings. Their page counts can
        include guard pages or neighbouring mappings that the kernel merged. Reading
        these records does not touch or relocate the FP64 data.
        """
        mappings = []
        for line in Path("/proc/self/maps").read_text().splitlines():
            first, last = (int(x, 16) for x in line.split()[0].split("-"))
            if first < self.end and last > self.start:
                mappings.append(first)
        rows = Path("/proc/self/numa_maps").read_text().splitlines()
        return {
            "data_address": hex(self.start),
            "data_bytes": self.end - self.start,
            "page_bytes": self.page,
            "numa_maps": [
                line for line in rows if int(line.split()[0], 16) in mappings
            ],
        }


class PlacedBuffers:
    """Own global states restored by the workers that own numerical tiles.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Shallow-water or energy-balance model selecting the layout.
    seed : numpy.ndarray of float64
        Borrowed immutable interior input. SW has shape ``(3, ny, nx)`` with depth
        in metres and momenta in square metres per second; EBM has ``(n,)`` Celsius
        temperatures.
    parameters : numpy.ndarray of float64
        Frozen model parameters, copied into private storage: four SW or six EBM
        values in the accepted solver contract's units.
    coeff : numpy.ndarray of float64 or None
        Borrowed immutable EBM coefficients with shape ``(3, n+2)``; use ``None``
        for SW. K is a face diffusion coefficient [W m^-2 K^-1]; W and I are
        absorbed solar fluxes for warm and ice-covered cells [W m^-2].
    config : tuple of int
        ``(px, py, batch)`` for SW or ``(threads, batch)`` for EBM, where batch
        counts complete local time steps.
    setup : ctypes.CDLL
        Loaded setup-only library with the accepted C restoration interfaces.

    Attributes
    ----------
    q, stage, out : numpy.ndarray of float64
        Owned mutable padded states: SW ``(3, ny+2, nx+2)`` or EBM ``(n+2,)``.
    cpus : numpy.ndarray of int32
        Observed CPU identifier for each restoration worker.
    actual : ctypes.c_int
        Observed number of restoration workers.

    Notes
    -----
    Construction allocates pages but does not restore a physical state. Call
    ``reset`` before use. The borrowed seed and EBM coefficient input must remain
    alive and unchanged while this object is in use.
    """

    def __init__(self, model, seed, parameters, coeff, config, setup):
        """Allocate the owned states and bind setup-only C interfaces.

        Parameters
        ----------
        model : {'sw', 'ebm'}
            Model selecting the state shape and restoration entry.
        seed : numpy.ndarray of float64
            Borrowed SW ``(3, ny, nx)`` depth/momenta or EBM ``(n,)`` temperatures.
        parameters : numpy.ndarray of float64
            Four SW or six EBM frozen parameters, copied without changing units.
        coeff : numpy.ndarray of float64 or None
            Borrowed EBM ``(3, n+2)`` coefficient input, or ``None`` for SW.
        config : tuple of int
            SW ``(px, py, batch)`` or EBM ``(threads, batch)`` settings.
        setup : ctypes.CDLL
            Native library providing the setup-only restoration entries.

        Returns
        -------
        None
            Initialise owned mappings, private parameter words and worker records.

        Raises
        ------
        OSError
            If a state mapping cannot be allocated.
        AttributeError
            If the setup library lacks a required C entry.

        Notes
        -----
        Seed and coefficient arrays are retained by reference. State values remain
        uninitialised until ``reset`` restores them outside the solver timer.
        """
        self.model, self.seed, self.frozen_coeff = model, seed, coeff
        self.config, self.setup = config, setup
        self.threads = config[0] * config[1] if model == "sw" else config[0]
        shape = (
            (3, seed.shape[1] + 2, seed.shape[2] + 2)
            if model == "sw"
            else (seed.size + 2,)
        )
        self.blocks = [GuardedMapping(shape) for _ in range(3)]
        self.q, self.stage, self.out = [b.array for b in self.blocks]
        self.parameters = parameters.copy()
        self.par = self.parameters
        if model == "ebm":
            self.blocks.append(GuardedMapping(coeff.shape))
            self.coeff = self.blocks[-1].array
        self.cpus = np.full(self.threads, -1, dtype=np.int32)
        self.actual = I()
        setup.cpu_restore_sw.argtypes = [I] * 4 + [P] * 4 + [IP, IP]
        setup.cpu_restore_eb.argtypes = [I] * 2 + [P] * 6 + [IP, IP]
        setup.cpu_restore_sw.restype = I
        setup.cpu_restore_eb.restype = I

    def reset(self):
        """Restore frozen input words through the numerical tile owners.

        Returns
        -------
        None
            Reset q from the seed, fill stage/out and state ghosts with quiet NaNs,
            restore EBM coefficients, and update CPU/team records and buffer guards.

        Raises
        ------
        RuntimeError
            If the native setup reports failure, a shortened team or duplicate CPUs.

        Notes
        -----
        The native helper performs copies and initialisation, with no physical time
        update. Borrowed inputs and copied parameters remain unchanged. State units
        and shapes are those declared by this class.
        """
        records = [self.cpus.ctypes.data_as(IP), ctypes.byref(self.actual)]
        if self.model == "sw":
            px, py, _ = self.config
            nx, ny = self.seed.shape[2], self.seed.shape[1]
            status = self.setup.cpu_restore_sw(
                nx,
                ny,
                px,
                py,
                *[pointer(a) for a in (self.seed, self.q, self.stage, self.out)],
                *records,
            )
        else:
            status = self.setup.cpu_restore_eb(
                self.seed.size,
                self.threads,
                *[
                    pointer(a)
                    for a in (
                        self.seed,
                        self.frozen_coeff,
                        self.q,
                        self.stage,
                        self.out,
                        self.coeff,
                    )
                ],
                *records,
            )
        if (
            status
            or self.actual.value != self.threads
            or len(set(self.cpus.tolist())) != self.threads
        ):
            raise RuntimeError(
                (
                    "Unexpected restoration team",
                    status,
                    self.actual.value,
                    self.cpus.tolist(),
                )
            )
        for block in self.blocks:
            block.set_guards()

    def check_guards(self):
        """Check owned bounds and the immutable EBM coefficient words.

        Returns
        -------
        None
            Leave the states, coefficient input and parameter storage unchanged.

        Raises
        ------
        AssertionError
            If a guard changed or the EBM coefficient copy differs from its input.

        Notes
        -----
        The measurement caller checks parameter words separately.
        """
        for block in self.blocks:
            block.check()
        if self.model == "ebm":
            check.shared.protocol._compare(
                self.frozen_coeff, self.coeff, "immutable coefficients"
            )


def activity_snapshot():
    """Read node and process CPU counters with wall-clock brackets.

    Returns
    -------
    dict
        Six aggregate USER_HZ counters, high-resolution process CPU nanoseconds,
        and monotonic nanosecond brackets for both reads.

    Notes
    -----
    Linux exports user, nice, system, irq, softirq and steal fields separately.
    Export rounding is bounded separately from asynchronous kernel accounting.
    """
    node_start = time.perf_counter_ns()
    with open("/proc/stat", encoding="ascii") as handle:
        values = list(map(int, handle.readline().split()[1:]))
    node_stop = time.perf_counter_ns()
    process_start = time.perf_counter_ns()
    own = time.process_time_ns()
    process_stop = time.perf_counter_ns()
    return {
        "node_ticks": [values[i] for i in (0, 1, 2, 5, 6, 7)],
        "node_read_ns": [node_start, node_stop],
        "process_cpu_ns": own,
        "process_read_ns": [process_start, process_stop],
    }


def activity_delta(before, after, elapsed_ns, node_cpus):
    """Describe the resolution of a node-minus-process CPU observation.

    Parameters
    ----------
    before, after : dict
        Bracketed counter observations surrounding the measured interval.
    elapsed_ns : int
        Solver or quiet-window wall time in nanoseconds.
    node_cpus : int
        Number of physical CPUs covered by the aggregate node counter.

    Returns
    -------
    dict
        Signed residual, raw reads, export-quantisation and read-skew bounds,
        and an explicit resolution classification.

    Notes
    -----
    Six exported fields at each of two snapshots contribute at most twelve
    USER_HZ units of conversion uncertainty. The measured noncoincident read
    windows add node_cpus times their combined duration. This is a resolution
    bound only: delayed kernel CPU accounting is not proved bounded here.
    Short calls rely on exclusive ownership and surrounding quiet windows.
    """
    hz = os.sysconf("SC_CLK_TCK")
    node_seconds = (sum(after["node_ticks"]) - sum(before["node_ticks"])) / hz
    process_ns = after["process_cpu_ns"] - before["process_cpu_ns"]
    residual = node_seconds - process_ns / 1e9
    skew_ns = sum(
        observation["process_read_ns"][1] - observation["node_read_ns"][0]
        for observation in (before, after)
    )
    conversion = 12 / hz
    skew = node_cpus * skew_ns / 1e9
    uncertainty = conversion + skew
    elapsed = elapsed_ns / 1e9
    return {
        "before_counters": before,
        "after_counters": after,
        "user_hz": hz,
        "node_cpus": node_cpus,
        "system_busy_seconds": node_seconds,
        "process_cpu_ns": process_ns,
        "signed_node_minus_process_cpu_seconds": residual,
        "foreign_busy_cores_during_sample": max(0.0, residual / elapsed),
        "export_conversion_uncertainty_cpu_seconds": conversion,
        "read_skew_ns": skew_ns,
        "read_skew_uncertainty_cpu_seconds": skew,
        "activity_counter_uncertainty_seconds": uncertainty,
        "activity_resolution_cores": uncertainty / elapsed,
        "activity_resolution_class": (
            "uninformative_at_one_core"
            if uncertainty >= elapsed
            else "resolves_one_core_conversion_and_skew_only"
        ),
        "adjusted_counter_residual_cores": max(0.0, residual - uncertainty) / elapsed,
        "accounting_lag_bound": None,
        "activity_scope": "Conversion and measured read skew are bounded; asynchronous kernel accounting lag is unbounded. Exclusive allocation and surrounding quiet windows are required independently. A short-call residual does not prove quietness.",
    }


def proc_busy():
    """Return aggregate busy CPU seconds for compatibility diagnostics."""
    observation = activity_snapshot()
    return sum(observation["node_ticks"]) / os.sysconf("SC_CLK_TCK")


def quiet_window():
    """Check a half-second quiet interval after a common settling pause.

    Returns
    -------
    dict
        Raw bracketed counters, resolution bounds, residual and node load.

    Raises
    ------
    RuntimeError
        If the raw node-minus-process estimate exceeds one busy CPU core.

    Notes
    -----
    The same untimed fifty-millisecond pause lets runtime workers finish their
    previous work. The original one-core raw rejection threshold is retained.
    Counter uncertainty remains disclosed and is not proof of absence of work.
    """
    time.sleep(0.05)
    before = activity_snapshot()
    started = time.perf_counter_ns()
    time.sleep(0.5)
    elapsed_ns = time.perf_counter_ns() - started
    after = activity_snapshot()
    record = activity_delta(before, after, elapsed_ns, os.cpu_count())
    record.update(
        window_seconds=elapsed_ns / 1e9,
        foreign_busy_cores=record["foreign_busy_cores_during_sample"],
        load_average=os.getloadavg(),
        settling_seconds=0.05,
    )
    if record["foreign_busy_cores"] > 1.0:
        raise RuntimeError(("Foreign CPU activity disturbed the quiet node", record))
    return record


def verify_allocation(visible_cpus):
    """Require this process to occupy its owned exclusive Slurm node.

    Parameters
    ----------
    visible_cpus : list of int
        Full CPU identifiers saved before OpenMP can pin the main thread.

    Returns
    -------
    dict
        Checked job/node ownership and complete raw Slurm query records.

    Raises
    ------
    RuntimeError
        If this is not a running owned step on the sole job's full CPU node.
    subprocess.SubprocessError
        If a bounded scheduler query fails or exceeds its timeout.
    OSError
        If a required scheduler executable cannot be started.

    Notes
    -----
    Full node CPU ownership and sole-job occupancy are checked together with the
    scheduler's sharing mode. This helper changes no scheduler state.
    """
    job = os.environ.get("SLURM_JOB_ID")
    node = os.uname().nodename.split(".")[0]
    if not job or not os.environ.get("SLURM_STEP_ID"):
        raise RuntimeError("Comparative measurements require an owned Slurm step.")
    outputs = {}

    def query(name, argv):
        """Run one bounded scheduler query and retain its raw output.

        Parameters
        ----------
        name : str
            Unique key in the enclosing allocation-evidence dictionary.
        argv : list of str
            Scheduler executable and its arguments; no shell is used.

        Returns
        -------
        str
            Standard output of the successfully completed query.

        Raises
        ------
        subprocess.SubprocessError
            If the command fails or exceeds ten seconds.
        OSError
            If the executable cannot be started.

        Notes
        -----
        This helper mutates only the enclosing ``outputs`` evidence dictionary.
        """
        result = subprocess.run(
            argv, capture_output=True, text=True, check=True, timeout=10
        )
        outputs[name] = {"argv": argv, "stdout": result.stdout, "stderr": result.stderr}
        return result.stdout

    def fields(text):
        """Split one-line scheduler fields at their first equals sign.

        Parameters
        ----------
        text : str
            Raw scheduler output containing whitespace-separated ``key=value`` fields.

        Returns
        -------
        dict of str to str
            Parsed field values; tokens without an equals sign are ignored.
        """
        return dict(word.split("=", 1) for word in text.split() if "=" in word)

    job_data = fields(query("job", ["scontrol", "show", "job", "--oneliner", job]))
    hosts = query(
        "hosts", ["scontrol", "show", "hostnames", job_data["NodeList"]]
    ).split()
    node_data = fields(query("node", ["scontrol", "show", "node", "--oneliner", node]))
    queues = query(
        "queue",
        [
            "squeue",
            "--noheader",
            "--nodes",
            node,
            "--states=RUNNING,COMPLETING,CONFIGURING",
            "--format=%A|%u|%T",
        ],
    )
    query("process_ownership", ["ps", "-eo", "pid,ppid,uid,stat,comm"])
    uid = job_data.get("UserId", "").rpartition("(")[2].rstrip(")")
    exclusive = (
        job_data.get("OverSubscribe") in ("EXCLUSIVE", "NO")
        or job_data.get("Shared") == "0"
    )
    active = [
        row.split("|", 1)[0].strip() for row in queues.splitlines() if row.strip()
    ]
    total = int(node_data.get("CPUTot", "0"))
    if (
        job_data.get("JobState") != "RUNNING"
        or uid != str(os.getuid())
        or hosts != [node]
        or not exclusive
        or active != [job]
        or total < 1
        or int(node_data.get("CPUAlloc", "0")) != total
        or int(job_data.get("NumCPUs", "0")) != total
        or len(visible_cpus) != total
    ):
        raise RuntimeError(
            ("The live Slurm allocation is not the expected exclusive node", outputs)
        )
    return {
        "job": job,
        "node": node,
        "uid": os.getuid(),
        "exclusive": exclusive,
        "total_cpus": total,
        "observed_unix_time_ns": time.time_ns(),
        "queries": outputs,
    }


def require_acceptance(path, artifacts):
    """Check that numerical acceptance binds every selected artifact.

    Parameters
    ----------
    path : pathlib.Path
        Read-only JSON receipt reporting exact numerical acceptance.
    artifacts : iterable of pathlib.Path
        Existing sources and libraries that the receipt must identify exactly.

    Returns
    -------
    dict
        Absolute receipt path and its SHA256 identifier.

    Raises
    ------
    RuntimeError
        If acceptance is incomplete or an artifact differs from the saved hash.
    json.JSONDecodeError
        If the receipt is not valid JSON.
    OSError
        If a receipt or selected artifact cannot be read.

    Notes
    -----
    Files are read without mutation. Hashes identify the verified revision; the
    numerical verifier, rather than this metadata check, establishes agreement.
    """
    receipt = json.loads(path.read_text())
    if not receipt.get("passed") or not receipt.get("zero_differing_bytes"):
        raise RuntimeError("The tiled numerical acceptance is incomplete.")
    frozen = {}
    for group in ("sources", "artifacts", "libraries"):
        for key, value in receipt.get(group, {}).items():
            if isinstance(value, str):
                frozen[str(Path(key).resolve())] = value
            elif isinstance(value, dict) and "path" in value and "sha256" in value:
                frozen[str(Path(value["path"]).resolve())] = value["sha256"]
    for artifact in artifacts:
        if frozen.get(str(artifact.resolve())) != digest(artifact):
            raise RuntimeError(
                "Acceptance does not bind selected artifact: " + str(artifact)
            )
    return {"path": str(path.resolve()), "sha256": digest(path)}


def local_update_count(model, grid, config, steps):
    """Count owned and overlapping cell updates in a complete call.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Model whose spatial ownership and overlap are counted.
    grid : tuple of int
        SW ``(nx, ny)`` or EBM ``(n,)`` global interior dimensions, in cells.
    config : tuple of int
        SW ``(px, py, batch)`` or EBM ``(threads, batch)`` accepted settings.
    steps : int
        Nonnegative number of complete physical time updates in the native call.

    Returns
    -------
    int
        Total local interior cell updates, including repeated overlap cells.

    Notes
    -----
    This helper assumes an admitted positive batch size. It changes no arrays and
    performs no simulation. Boundary copies and point preparation are additional
    work; the result is a logical work count, not a hardware event counter.
    """
    batch = config[-1]
    owners = config[0] * config[1] if model == "sw" else config[0]
    if owners == 1:
        return int(np.prod(grid)) * steps

    def one_group(k):
        """Count local interior updates in one complete temporal group.

        Parameters
        ----------
        k : int
            Positive number of local time steps in this full or final partial group.

        Returns
        -------
        int
            Cell updates across the enclosing configuration's owned and overlap cells.

        Notes
        -----
        The enclosing model, grid and owner count are read without mutation. EBM
        ranges stop at the true poles; SW overlap wraps at periodic boundaries.
        """
        if model == "sw":
            nx, ny = grid
            px, py, _ = config
            width = nx + (4 * k * px if px > 1 else 0)
            height = ny + (4 * k * py if py > 1 else 0)
            return k * width * height
        n = grid[0]
        return k * sum(
            min(n, (worker + 1) * n // owners + 2 * k)
            - max(1, worker * n // owners + 1 - 2 * k)
            + 1
            for worker in range(owners)
        )

    full, tail = divmod(steps, batch)
    return full * one_group(batch) + (one_group(tail) if tail else 0)


def main():
    """Measure and export one accepted CPU configuration in twelve pairs.

    Returns
    -------
    None
        Write raw timing/placement evidence and its accepted comparison export;
        print the placement plan instead when the run flag is absent.

    Raises
    ------
    ValueError
        If command-line grid, owner, batch, step or repetition settings are invalid.
    RuntimeError
        If authorisation, artifact identity, allocation, affinity, floating-point
        state or quiet-node requirements fail.
    AssertionError
        If exact state words, immutable inputs, guards or physical checks fail.
    OSError
        If a required file, native library or output cannot be accessed.
    subprocess.SubprocessError
        If an allocation query fails or exceeds its timeout.

    Notes
    -----
    Command-line settings select SW depth/momenta or EBM temperature states in the
    shapes and units documented above. Both implementations use the same owned
    global buffers and scratch mapping. The timer contains the complete native
    coordinator call, including local overlap calculations, stage updates,
    publication, barriers and ghost copies. Allocation, restoration, warm-up,
    physical checks and bit comparisons remain outside the timer.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("model", choices=("sw", "ebm"))
    parser.add_argument("n", type=int)
    parser.add_argument("--ny", type=int)
    parser.add_argument("--threads", type=int, required=True)
    parser.add_argument("--requested-threads", type=int)
    parser.add_argument("--dispatch-reason")
    parser.add_argument(
        "--placement", choices=("compact", "balanced"), default="balanced"
    )
    parser.add_argument("--px", type=int)
    parser.add_argument("--py", type=int)
    parser.add_argument("--batch", type=int, required=True)
    parser.add_argument("--steps", type=int, required=True)
    parser.add_argument("--assembly", type=Path, required=True)
    parser.add_argument("--fortran", type=Path, required=True)
    parser.add_argument("--assembly-source", type=Path, required=True)
    parser.add_argument("--fortran-source", type=Path, required=True)
    parser.add_argument(
        "--setup-library", type=Path, default=HERE / "build/libtile_setup.so"
    )
    parser.add_argument(
        "--coordinator", type=Path, default=HERE / "build/libparallel_tiles.so"
    )
    parser.add_argument(
        "--coordinator-source", type=Path, default=HERE / "parallel_tiles.f90"
    )
    parser.add_argument("--acceptance", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--repeats", type=int, default=12)
    parser.add_argument("--campaign-id", default="goal_20261112_cpu_multicore")
    parser.add_argument(
        "--series-kind",
        choices=("primary", "fixed_scaling", "qualification"),
        default="qualification",
    )
    parser.add_argument("--run-id")
    parser.add_argument("--run", action="store_true")
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--canonical-directory", type=Path)
    parser.add_argument(
        "--probe-library", type=Path, default=HERE / "build/libcpu_probe.so"
    )
    args = parser.parse_args()
    allowed_cpus = sorted(os.sched_getaffinity(0))
    selected = placement(args.threads, args.placement)
    if not args.run and not args.verify_only:
        print(
            json.dumps(
                {
                    "physical_cpus": selected,
                    "placement": args.placement,
                    "OMP_PLACES": ",".join("{" + str(c) + "}" for c in selected),
                    "run_requires": "--run and ESM_CPU_CAMPAIGN_PHASE=cpu",
                }
            )
        )
        return
    if not args.verify_only and os.environ.get("ESM_CPU_CAMPAIGN_PHASE") != "cpu":
        raise RuntimeError("CPU comparative timing is not authorised in this phase.")
    if not args.verify_only and (
        args.series_kind == "qualification" or not args.run_id
    ):
        raise ValueError("Final data needs a declared series kind and stable run ID.")
    requested = args.requested_threads or args.threads
    if requested < args.threads or (
        requested != args.threads and not args.dispatch_reason
    ):
        raise ValueError("Any smaller actual team needs an explicit dispatch reason.")
    if args.repeats != 12 or not 1 <= args.steps <= 1_000_000:
        raise ValueError(
            "Final measurements require 12 pairs and admitted step bounds."
        )
    if os.environ.get("OMP_DYNAMIC", "").lower() != "false":
        raise RuntimeError("Set OMP_DYNAMIC=false before starting Python.")
    if args.model == "ebm" and (not 1 <= args.n <= 65_536 or args.threads > args.n):
        raise ValueError(
            "Use admitted bands and one nonempty band range per actual worker."
        )
    if args.model == "sw" and (
        not 1 <= args.n <= 4096 or not 1 <= (args.ny or args.n) <= 4096
    ):
        raise ValueError(
            "The shallow-water grid must remain inside the admitted bounds."
        )
    if not 1 <= args.batch <= (32 if args.model == "sw" else 256):
        raise ValueError("The temporal batch must remain inside the admitted bounds.")
    if mmap.PAGESIZE > 65_536:
        raise RuntimeError(
            "The coordinator's 64 KiB workspace alignment needs extension."
        )
    config = (
        (args.px, args.py, args.batch)
        if args.model == "sw"
        else (args.threads, args.batch)
    )
    if args.model == "sw" and (
        args.px is None or args.py is None or args.px * args.py != args.threads
    ):
        raise ValueError("The shallow-water partition must match the active team.")
    coordinator = args.coordinator.resolve()
    canonical_path = ROOT / (
        ".agents/bench/.build/lib"
        + ("sw" if args.model == "sw" else "eb")
        + "_fortran_vanilla.so"
    )
    artifacts = [
        args.coordinator_source.resolve(),
        HERE / "restore_tiles.f90",
        coordinator,
        args.setup_library,
        args.probe_library.resolve(),
        args.assembly,
        args.fortran,
        canonical_path,
        args.assembly_source,
        args.fortran_source,
    ]
    acceptance = require_acceptance(args.acceptance, artifacts)
    allocation = verify_allocation(allowed_cpus)
    environment = ctypes.CDLL(str(args.probe_library))
    environment.cpu_fpcr.restype = ctypes.c_uint64
    environment.cpu_fpsr.restype = ctypes.c_uint64
    environment.cpu_set_fpsr.argtypes = [ctypes.c_uint64]
    environment.cpu_set_fpsr.restype = None
    if environment.cpu_fpcr() != 0:
        raise RuntimeError(
            "The main thread does not have the admitted FP control bits."
        )
    bank = frozen_inputs.load_bank(args.model, args.n)
    if args.steps != 1000:
        raise ValueError("The shared main workloads use exactly 1000 complete steps.")
    seed, parameters, coeff = bank["seed"], bank["par"], bank["coeff"]
    if args.model == "sw" and args.ny not in (None, seed.shape[1]):
        raise ValueError("The requested shape differs from the frozen input bank.")
    reference = frozen_inputs.make_buffers(bank)
    setup = ctypes.CDLL(str(args.setup_library))
    buffers = PlacedBuffers(args.model, seed, parameters, coeff, config, setup)
    buffers.reset()
    for field in ("q", "stage", "out"):
        check.shared.protocol._compare(
            bank["arrays"][field], getattr(buffers, field), "frozen initial " + field
        )
    if buffers.cpus.tolist() != selected:
        raise RuntimeError(
            (
                "Observed placement differs from the plan",
                selected,
                buffers.cpus.tolist(),
            )
        )
    cached = canonical_banks.load_canonical(
        args.model, args.n, bank["identity"], args.canonical_directory
    )
    for field in ("q", "stage", "out"):
        np.copyto(getattr(reference, field), getattr(cached, field), casting="no")
    canonical_fpsr, canonical_fpcr = cached.fpsr, cached.fpcr
    if environment.cpu_fpcr() != 0:
        raise RuntimeError("The CPU admission floating-point control is not zero.")
    qualified_standard_flags = None if canonical_fpsr is None else canonical_fpsr & 31
    final = reference.out if args.steps % 2 else reference.q
    previous = reference.q if args.steps % 2 else reference.out
    if args.model == "sw":
        check.shared.protocol._budget_drift(seed, final[:, 1:-1, 1:-1])
        for state in (reference.q, reference.stage, reference.out):
            check.shared.protocol._halo_check(state)
            check.shared.protocol._admissible(state, parameters)
    else:
        check.shared.ebm.heat_budget(
            previous, reference.stage, final, coeff, parameters
        )
        for state in (reference.q, reference.stage, reference.out):
            check.shared.ebm.halo_check(state)
            check.shared.ebm.admissible(state, coeff, parameters)
    implementations = {
        name: check.Tiled(args.model, path, config, coordinator)
        for name, path in (("assembly", args.assembly), ("fortran", args.fortran))
    }
    first = next(iter(implementations.values()))
    first.bind(buffers, args.steps)
    workspace = GuardedMapping((first.workspace.size,))
    if first.workspace.size % args.threads:
        raise RuntimeError(
            "The workspace cannot be split into equal worker capacities."
        )
    setup.cpu_touch_workspace.argtypes = [I, L, P, IP, IP]
    setup.cpu_touch_workspace.restype = I
    actual = I()
    cpus = np.full(args.threads, -1, dtype=np.int32)
    status = setup.cpu_touch_workspace(
        args.threads,
        first.workspace.size // args.threads,
        pointer(workspace.array),
        cpus.ctypes.data_as(IP),
        ctypes.byref(actual),
    )
    if status or actual.value != args.threads or cpus.tolist() != selected:
        raise RuntimeError("Workspace first-touch placement is invalid.")
    workspace.set_guards()
    for implementation in implementations.values():
        implementation.raw, implementation.workspace = workspace.raw, workspace.array
        invoke = implementation.bind(buffers, args.steps)
        environment.cpu_set_fpsr(0)
        invoke()
        observed_fpsr = environment.cpu_fpsr()
        observed_fpcr = environment.cpu_fpcr()
        if observed_fpcr != 0 or (
            qualified_standard_flags is not None
            and observed_fpsr & 31 != qualified_standard_flags
        ):
            raise RuntimeError(
                (
                    "Pre-timing floating-point state differs",
                    implementation.name,
                    canonical_fpsr,
                    observed_fpsr,
                    observed_fpcr,
                )
            )
        check.compare_all(
            reference, buffers, ("pre-timing acceptance", implementation.name)
        )
        buffers.check_guards()
        workspace.check()
        if qualified_standard_flags is None:
            qualified_standard_flags = observed_fpsr & 31
        buffers.reset()
    team = check.team_probe(environment, args.threads)
    if team["physical_cpus"] != selected:
        raise RuntimeError("Numerical team affinity changed.")
    report = {
        "passed": False,
        "model": args.model,
        "grid": [args.n, args.ny or args.n] if args.model == "sw" else [args.n],
        "steps": args.steps,
        "batch": args.batch,
        "configuration": config,
        "requested_threads": requested,
        "series_kind": args.series_kind,
        "run_id": args.run_id,
        "launcher_environment": {
            name: os.environ.get(name)
            for name in (
                "OMP_NUM_THREADS",
                "OMP_DYNAMIC",
                "OMP_PROC_BIND",
                "OMP_PLACES",
                "OMP_WAIT_POLICY",
                "OMP_THREAD_LIMIT",
                "GOMP_SPINCOUNT",
                "OPENBLAS_NUM_THREADS",
            )
        },
        "dispatch_reason": args.dispatch_reason,
        "placement": args.placement,
        "actual_threads": args.threads,
        "nonempty_spatial_owners": args.threads,
        "local_interior_updates_with_overlap": local_update_count(
            args.model,
            (args.n, args.ny or args.n) if args.model == "sw" else (args.n,),
            config,
            args.steps,
        ),
        "allocation_visible_cpus": allowed_cpus,
        "team": team,
        "acceptance": acceptance,
        "allocation": allocation,
        "canonical_fpsr": canonical_fpsr,
        "canonical_fpcr": canonical_fpcr,
        "standard_flags": qualified_standard_flags,
        "standard_flag_scope": "Actual standard flags agree across byte-verified routes and repeats. Reused oracle immediate flags remain unknown when absent.",
        "input_identity": bank["identity"],
        "canonical_record": cached.identity,
        "callback_mappings": {
            name: implementation.callback_mapping
            for name, implementation in implementations.items()
        },
        "job": os.environ.get("SLURM_JOB_ID"),
        "node": os.uname().nodename,
        "page_bytes": mmap.PAGESIZE,
        "artifacts": {
            str(p.resolve()): digest(p)
            for p in artifacts
            + [Path(__file__), HERE / "frozen_inputs.py", HERE / "canonical_banks.py"]
        },
        "input_sha256": hashlib.sha256(
            b"".join(a.tobytes() for a in (seed, parameters) if a is not None)
            + (coeff.tobytes() if coeff is not None else b"")
        ).hexdigest(),
        "timer": "One complete native coordinator call, including tile gather, all local steps, overlap arithmetic, barriers, global publication and ghosts. Allocation, placement, warm-up, restoration and checking are outside.",
        "cache_preparation": "Four complete warm-up steps followed by the same owner-based restoration of all global state words.",
        "placement_before": [block.numa_record() for block in buffers.blocks]
        + [workspace.numa_record()],
        "samples": [],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.verify_only:
        report["passed"] = True
        report["verification_only"] = True
        report["independent_final_physics_passed"] = True
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        print(
            json.dumps(
                {
                    "passed": True,
                    "verification_only": True,
                    "model": args.model,
                    "shape": report["grid"],
                    "steps": args.steps,
                    "actual_threads": args.threads,
                }
            )
        )
        return
    for repeat in range(12):
        names = ("assembly", "fortran") if repeat % 2 == 0 else ("fortran", "assembly")
        for name in names:
            implementation = implementations[name]
            buffers.reset()
            implementation.bind(buffers, min(4, args.steps))()
            buffers.check_guards()
            workspace.check()
            check.shared.protocol._compare(
                parameters, buffers.parameters, "warm-up immutable parameters"
            )
            if environment.cpu_fpcr() != 0:
                raise RuntimeError("Warm-up changed floating-point control.")
            buffers.reset()
            invoke = implementation.bind(buffers, args.steps)
            before = quiet_window()
            activity_before = activity_snapshot()
            faults_before = resource.getrusage(resource.RUSAGE_SELF)
            gc_was_enabled = gc.isenabled()
            gc.disable()
            environment.cpu_set_fpsr(0)
            started = time.perf_counter_ns()
            try:
                invoke()
                stopped = time.perf_counter_ns()
                observed_fpsr = environment.cpu_fpsr()
                observed_fpcr = environment.cpu_fpcr()
            finally:
                if gc_was_enabled:
                    gc.enable()
            elapsed = stopped - started
            if observed_fpcr != 0 or (
                qualified_standard_flags is not None
                and observed_fpsr & 31 != qualified_standard_flags
            ):
                raise RuntimeError(
                    (
                        "Timed floating-point state differs",
                        name,
                        repeat,
                        canonical_fpsr,
                        observed_fpsr,
                        observed_fpcr,
                    )
                )
            activity_after = activity_snapshot()
            activity = activity_delta(
                activity_before, activity_after, elapsed, len(allowed_cpus)
            )
            cpu_elapsed = activity["process_cpu_ns"]
            system_elapsed = activity["system_busy_seconds"]
            faults_after = resource.getrusage(resource.RUSAGE_SELF)
            check.compare_all(reference, buffers, (name, repeat))
            buffers.check_guards()
            workspace.check()
            check.shared.protocol._compare(
                parameters, buffers.parameters, "immutable parameters"
            )
            after = quiet_window()
            sample = {
                "implementation": name,
                "repeat": repeat,
                "order": list(names),
                "elapsed_ns": elapsed,
                "process_cpu_ns": cpu_elapsed,
                "fpcr": observed_fpcr,
                "fpsr": observed_fpsr,
                "system_busy_seconds": system_elapsed,
                "foreign_busy_cores_during_sample": max(
                    0.0, (system_elapsed - cpu_elapsed / 1e9) / (elapsed / 1e9)
                ),
                "minor_faults": faults_after.ru_minflt - faults_before.ru_minflt,
                "major_faults": faults_after.ru_majflt - faults_before.ru_majflt,
                "before": before,
                "after": after,
                "zero_differing_bytes": True,
            }
            sample.update(activity)
            enclosing_start = before["before_counters"]
            enclosing_end = after["after_counters"]
            enclosing_ns = (
                enclosing_end["process_read_ns"][1] - enclosing_start["node_read_ns"][0]
            )
            if enclosing_ns < 1_000_000_000:
                raise RuntimeError(
                    "The fixed enclosing activity interval is shorter than one second."
                )
            enclosing = activity_delta(
                enclosing_start, enclosing_end, enclosing_ns, len(allowed_cpus)
            )
            enclosing.update(
                observation_elapsed_ns=enclosing_ns,
                empirical_gate_threshold_cores=1.0,
                included_work="Before quiet window, complete native call, outside-timer byte/guard checks, fixed settle and after quiet window.",
                gate_scope="Mean adjusted counter residual over the enclosing observation; accounting lag remains unknown.",
            )
            sample["enclosing_activity"] = enclosing
            sample["short_activity_diagnostic_only"] = True
            report["samples"].append(sample)
            args.output.write_text(json.dumps(report, indent=2) + "\n")
            if enclosing["adjusted_counter_residual_cores"] > 1.0:
                raise RuntimeError(
                    "The enclosing adjusted counter residual exceeded one core."
                )
            print(
                json.dumps(
                    {"repeat": repeat, "implementation": name, "seconds": elapsed / 1e9}
                ),
                flush=True,
            )
    owner_snapshot = subprocess.run(
        ["ps", "-eo", "pid,ppid,uid,stat,comm"],
        capture_output=True,
        text=True,
        check=True,
        timeout=10,
    )
    report["process_ownership_after"] = {
        "observed_unix_time_ns": time.time_ns(),
        "stdout": owner_snapshot.stdout,
    }
    report["placement_after"] = [block.numa_record() for block in buffers.blocks] + [
        workspace.numa_record()
    ]
    report["summary"] = {}
    updates = (
        seed.size // 3 * args.steps if args.model == "sw" else seed.size * args.steps
    )
    for name in implementations:
        seconds = np.array(
            [
                x["elapsed_ns"] / 1e9
                for x in report["samples"]
                if x["implementation"] == name
            ]
        )
        median = float(np.median(seconds))
        report["summary"][name] = {
            "median_seconds": median,
            "min_seconds": float(seconds.min()),
            "max_seconds": float(seconds.max()),
            "mad_seconds": float(np.median(abs(seconds - median))),
            "million_cell_updates_per_second": updates / median / 1e6,
        }
    for path, frozen_hash in report["artifacts"].items():
        if digest(path) != frozen_hash:
            raise RuntimeError(
                "A selected artifact changed during the paired measurement."
            )
    report["independent_final_physics_passed"] = True
    report["passed"] = True
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    paired = []
    for repeat in range(12):
        samples = {
            row["implementation"]: row
            for row in report["samples"]
            if row["repeat"] == repeat
        }
        assert set(samples) == {"assembly", "fortran"}
        paired.append(
            {
                "repeat": repeat,
                "baseline_seconds": samples["assembly"]["elapsed_ns"] / 1e9,
                "esm_md_seconds": samples["fortran"]["elapsed_ns"] / 1e9,
            }
        )
    revisions = {}
    for label, source, library in (
        ("baseline", args.assembly_source, args.assembly),
        ("esm_md", args.fortran_source, args.fortran),
    ):
        revisions[label] = {
            "source": str(source.resolve()),
            "source_sha256": digest(source),
            "library": str(library.resolve()),
            "library_sha256": digest(library),
        }
    revisions["coordinator"] = {
        "source": str(args.coordinator_source.resolve()),
        "source_sha256": digest(args.coordinator_source),
        "library_sha256": digest(coordinator),
    }
    accepted = {
        "model": args.model,
        "platform": "cpu",
        "series_kind": args.series_kind,
        "run_id": args.run_id,
        "shape": report["grid"],
        "batch_steps": args.steps,
        "temporal_batch_steps": args.batch,
        "complete_cell_updates": int(updates),
        "local_interior_updates_with_overlap": report[
            "local_interior_updates_with_overlap"
        ],
        "cpu_cores": requested,
        "allocation_physical_cpus": allocation["total_cpus"],
        "gpu_devices": 0,
        "campaign_id": args.campaign_id,
        "job_id": str(report["job"]),
        "node": report["node"],
        "timer_scope": report["timer"],
        "active_workers": {"baseline": args.threads, "esm_md": args.threads},
        "nonempty_spatial_owners": args.threads,
        "nonempty_spatial_owners_by_route": {
            "baseline": args.threads,
            "esm_md": args.threads,
        },
        "dispatch_reason": args.dispatch_reason,
        "affinity": {
            "physical_cpus": team["physical_cpus"],
            "OMP_PLACES": os.environ.get("OMP_PLACES"),
            "OMP_PROC_BIND": os.environ.get("OMP_PROC_BIND"),
            "OMP_WAIT_POLICY": os.environ.get("OMP_WAIT_POLICY"),
            "GOMP_SPINCOUNT": os.environ.get("GOMP_SPINCOUNT"),
        },
        "memory_policy": {
            "method": "owner first touch",
            "placement": args.placement,
            "page_bytes": mmap.PAGESIZE,
            "before": report["placement_before"],
            "after": report["placement_after"],
        },
        "source_revisions": revisions,
        "input_identity": bank["identity"],
        "acceptance_record": {
            "prerequisite": acceptance,
            "timed_evidence": str(args.output.resolve()),
            "timed_evidence_sha256": digest(args.output),
        },
        "qualification": {
            "independent_physics_passed": True,
            "exact_outputs_equal": True,
            "timed_final_state_checked": True,
            "exclusive_node": True,
            "quiet_samples": True,
        },
        "paired_samples": paired,
    }
    exported = {
        "schema_version": 1,
        "status": "accepted",
        "paired_records": [accepted],
        "disclosure": "Both numerical routes share the native Fortran/OpenMP spatial coordinator. Reserved CPUs, requested budget, actual workers and nonempty owners are recorded separately. All complete solver work is timed.",
    }
    args.output.with_suffix(".accepted.json").write_text(
        json.dumps(exported, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()

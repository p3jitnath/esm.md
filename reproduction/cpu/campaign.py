"""Collect eight complete CPU solvers with shared ownership and exact checks.

Source preparation and functional verification may use the current shared
allocation under the user's exception. Timings require the owned exclusive
node, its common lock, and the unchanged empirical quiet admission rule.
"""

import argparse
import ctypes
import datetime as dt
import fcntl
import gc
import importlib.util
import json
import os
from pathlib import Path
import resource
import sys
import time
from types import SimpleNamespace

import numpy as np

HERE = Path(__file__).resolve().parent
OLD = HERE.parents[1] / "cpu"
sys.path.insert(0, str(OLD))
import measure_tiles as measured
import verify_tiles as check
import frozen_inputs
import canonical_banks

P = ctypes.POINTER(ctypes.c_double)
I = ctypes.c_int
L = ctypes.c_int64
IP = ctypes.POINTER(I)


def load_module(name, path):
    """Load one private callback provider outside the solver timer.

    Parameters
    ----------
    name : str
        Unique Python module identifier.
    path : pathlib.Path
        Retained provider source to import without modifying it.

    Returns
    -------
    module
        Loaded provider whose numerical callback owners remain alive.
    """
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


class Callback(check.Tiled):
    """Borrow a qualified native JIT callback through the accepted coordinator.

    Parameters
    ----------
    model : str
        Model identifier, sw or ebm.
    name : str
        Stable implementation identifier.
    address : int
        Native C callback address; no Python callback runs on worker threads.
    owner : object
        Runtime and code owner retained for the complete instance lifetime.
    config : tuple of int
        Accepted spatial partition and temporal group size.
    coordinator : pathlib.Path
        Unchanged accepted Fortran/OpenMP coordinator library.

    Notes
    -----
    The inherited bind method owns no numerical stage. It borrows mutable state
    arrays and workspace, then invokes the complete native coordinator.
    """

    def __init__(
        self, model, name, address, owner, config, coordinator, coordinator_shim=None
    ):
        self.model, self.name, self.config = model, name, config
        self.owner = owner
        self.lib = ctypes.CDLL(str(coordinator))
        if model == "sw":
            self.lib.sw_tiles_values.argtypes = [I] * 5
            self.lib.sw_tiles_values.restype = L
            self.lib.sw_run_tiles.argtypes = (
                [ctypes.c_void_p, I, I] + [P] * 4 + [I] * 4 + [P, L]
            )
            self.lib.sw_run_tiles.restype = I
        else:
            self.lib.eb_tiles_values.argtypes = [I] * 3
            self.lib.eb_tiles_values.restype = L
            self.lib.eb_run_tiles.argtypes = (
                [ctypes.c_void_p, I] + [P] * 5 + [I] * 3 + [P, L]
            )
            self.lib.eb_run_tiles.restype = I
        if coordinator_shim is not None:
            entry = "sw_run_tiles" if model == "sw" else "eb_run_tiles"
            signature = getattr(self.lib, entry).argtypes
            setattr(self.lib, entry, ctypes.CFUNCTYPE(I, *signature)(coordinator_shim))
        self.kernel = ctypes.c_void_p(address)
        rows = Path("/proc/self/maps").read_text().splitlines()
        mapping = next(
            (
                row
                for row in rows
                if int(row.split()[0].split("-")[0], 16)
                <= address
                < int(row.split()[0].split("-")[1], 16)
            ),
            None,
        )
        if mapping is None:
            raise RuntimeError(("Unmapped JIT callback", name, hex(address)))
        self.callback_mapping = {
            "kernel": {"address": hex(address), "mapping": mapping},
            "coordinator": str(coordinator),
            "complete_entry_shim": (
                None if coordinator_shim is None else hex(coordinator_shim)
            ),
        }
        self.raw = self.workspace = self.binding = None


def physics(model, bank, reference):
    """Check independent physical balances and boundaries on complete outputs.

    Parameters
    ----------
    model : str
        Model identifier.
    bank : dict
        Frozen physical inputs; borrowed and unchanged.
    reference : object
        Exact q, stage and out outputs, including all ghost cells.

    Returns
    -------
    None
        Raise on failed admissibility, conservation or boundary limits.
    """
    if model == "sw":
        check.shared.protocol._budget_drift(bank["seed"], reference.q[:, 1:-1, 1:-1])
        for state in (reference.q, reference.stage, reference.out):
            check.shared.protocol._halo_check(state)
            check.shared.protocol._admissible(state, bank["par"])
    else:
        check.shared.ebm.heat_budget(
            reference.out, reference.stage, reference.q, bank["coeff"], bank["par"]
        )
        for state in (reference.q, reference.stage, reference.out):
            check.shared.ebm.halo_check(state)
            check.shared.ebm.admissible(state, bank["coeff"], bank["par"])


def build_routes(model, config, condition, names):
    """Load qualified native numerical entries without running a time step.

    Parameters
    ----------
    model : str
        Model identifier.
    config : tuple of int
        Shared coordinator settings.
    condition : dict
        Frozen source and runtime bindings for the workload.
    names : list of str
        Stable route identifiers to prepare.

    Returns
    -------
    dict
        Complete native numerical callbacks retained by implementation id.
    """
    routes = {}
    coordinator = Path(condition["coordinator_library"])
    for name in names:
        if name == "assembly":
            path = Path(condition["baseline_library"])
        elif name == "esm_md_fortran":
            path = Path(condition["fortran_library"])
        elif name.startswith("fortran_"):
            path = (
                HERE / "fortran" / model / name / ("lib" + model + "_" + name + ".so")
            )
        else:
            continue
        routes[name] = check.Tiled(model, path, config, coordinator)
        routes[name].name = name
    for language in ("python", "julia"):
        selected = [name for name in names if name.startswith(language + "_")]
        if not selected:
            continue
        module = load_module(
            "fresh_" + language,
            HERE
            / language
            / ("julia_callbacks.py" if language == "julia" else "callbacks.py"),
        )
        provided = (
            module.build_routes(model, coordinator_path=coordinator)
            if language == "julia"
            else module.build_routes(model)
        )
        for name in selected:
            item = provided[name]
            address = item["address"] if isinstance(item, dict) else item.address
            routes[name] = Callback(
                model,
                name,
                int(address),
                (module, item),
                config,
                coordinator,
                item.get("coordinator_shim") if isinstance(item, dict) else None,
            )
    if set(routes) != set(names):
        raise RuntimeError(("Missing native routes", names, list(routes)))
    return routes


def run(args):
    """Verify or measure one frozen complete workload.

    Parameters
    ----------
    args : argparse.Namespace
        Explicit plan, shape, route set and verification mode.

    Returns
    -------
    None
        Write complete evidence outside each solver timer.

    Raises
    ------
    RuntimeError
        If resources, outputs, floating-point state or quiet admission fail.
    """
    plan = json.loads(args.plan.read_text())
    condition = next(
        c for c in plan["conditions"] if c["model"] == args.model and c["n"] == args.n
    )
    if not args.verify_only and (
        plan["status"] != "FROZEN"
        or os.environ.get("ESM_CPU_CAMPAIGN_PHASE") != "cpu"
        or os.environ.get("SLURM_JOB_ID") != "8353767"
    ):
        raise RuntimeError(
            "Final timing requires the frozen plan and exclusive CPU phase."
        )
    frozen = None
    deadline = None
    if not args.verify_only:
        if args.routes or args.development_threads:
            raise RuntimeError(
                "Final timing requires all eight routes and the frozen full team."
            )
        descriptor = int(os.environ["ESM_CPU_LOCK_FD"])
        held = os.fstat(descriptor)
        expected = (HERE.parents[1] / "fresh_languages_node.lock").stat()
        if (held.st_dev, held.st_ino) != (expected.st_dev, expected.st_ino):
            raise RuntimeError(
                "Inherited common lock descriptor has the wrong owner file."
            )
        lock_record = json.loads(os.pread(descriptor, 8192, 0))
        if (
            lock_record.get("owner") != "cpu_languages"
            or lock_record.get("pid") != os.getppid()
            or lock_record.get("job") != "8353767"
        ):
            raise RuntimeError(
                "The timing child does not belong to the locked controller."
            )
        with (HERE.parents[1] / "fresh_languages_node.lock").open("a+") as probe:
            try:
                fcntl.flock(probe, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                pass
            else:
                fcntl.flock(probe, fcntl.LOCK_UN)
                raise RuntimeError(
                    "The common node lock is not held by the controller."
                )
        deadline = dt.datetime.fromisoformat(
            os.environ["ESM_CPU_DEADLINE"].replace("Z", "+00:00")
        ).timestamp()
        if time.time() >= deadline - 120:
            raise RuntimeError("The collection deadline has no verification reserve.")
        frozen = json.loads((HERE / "freeze.json").read_text())
        if frozen.get("status") != "FROZEN":
            raise RuntimeError("Artifact manifest is not frozen.")
        if str(args.plan.resolve()) not in frozen["artifacts"]:
            raise RuntimeError(
                "The selected plan is absent from the frozen artifact manifest."
            )
        for path, expected_hash in frozen["artifacts"].items():
            if measured.digest(path) != expected_hash:
                raise RuntimeError(
                    ("Frozen artifact differs before numerical entry", path)
                )
    allowed = sorted(os.sched_getaffinity(0))
    threads = args.development_threads or condition["actual_team"]
    if args.development_threads:
        if not args.verify_only or threads > 4:
            raise RuntimeError(
                "The shared development exception admits at most four workers."
            )
        config = (
            (2, 2, min(condition["temporal_cap"], 4))
            if args.model == "sw"
            else (threads, min(condition["temporal_cap"], 8))
        )
    else:
        config = (
            (condition["px"], condition["py"], condition["temporal_cap"])
            if args.model == "sw"
            else (threads, condition["temporal_cap"])
        )
    selected = measured.placement(threads, condition["placement"])
    if os.environ.get("OMP_DYNAMIC", "").lower() != "false":
        raise RuntimeError("OMP_DYNAMIC=false is required.")
    allocation = (
        measured.verify_allocation(allowed)
        if not args.development_threads
        else {
            "job": os.environ.get("SLURM_JOB_ID"),
            "shared_development_exception": True,
            "visible_cpus": allowed,
        }
    )
    names = args.routes.split(",") if args.routes else plan["route_order"]
    if not set(names).issubset(plan["route_order"]):
        raise ValueError("Unknown implementation identifier.")
    implementations = build_routes(args.model, config, condition, names)
    environment = ctypes.CDLL(str(OLD / "build/libcpu_probe.so"))
    environment.cpu_fpcr.restype = ctypes.c_uint64
    environment.cpu_fpsr.restype = ctypes.c_uint64
    environment.cpu_set_fpsr.argtypes = [ctypes.c_uint64]
    environment.cpu_set_fpsr.restype = None
    bank = frozen_inputs.load_bank(args.model, args.n)
    if bank["identity"]["input_identity_sha256"] != condition["input_identity_sha256"]:
        raise RuntimeError("The frozen plan and input bank identities differ.")
    cached = canonical_banks.load_canonical(args.model, args.n, bank["identity"])
    if cached.meta["npz_sha256"] != condition["canonical_npz_sha256"]:
        raise RuntimeError(
            "The frozen plan and canonical output bank identities differ."
        )
    reference = SimpleNamespace(q=cached.q, stage=cached.stage, out=cached.out)
    physics(args.model, bank, reference)
    setup = ctypes.CDLL(condition["setup_library"])
    buffers = measured.PlacedBuffers(
        args.model, bank["seed"], bank["par"], bank["coeff"], config, setup
    )
    buffers.reset()
    if buffers.cpus.tolist() != selected:
        raise RuntimeError(
            ("Restoration affinity differs", buffers.cpus.tolist(), selected)
        )
    first = next(iter(implementations.values()))
    first.bind(buffers, 1000)
    workspace = measured.GuardedMapping((first.workspace.size,))
    setup.cpu_touch_workspace.argtypes = [I, L, P, IP, IP]
    setup.cpu_touch_workspace.restype = I
    cpus = np.full(threads, -1, dtype=np.int32)
    actual = I()
    status = setup.cpu_touch_workspace(
        threads,
        first.workspace.size // threads,
        measured.pointer(workspace.array),
        cpus.ctypes.data_as(IP),
        ctypes.byref(actual),
    )
    if status or actual.value != threads or cpus.tolist() != selected:
        raise RuntimeError("Workspace first touch has invalid team or affinity.")
    workspace.set_guards()
    for impl in implementations.values():
        impl.raw, impl.workspace = workspace.raw, workspace.array
    standard_flags = None if cached.fpsr is None else cached.fpsr & 31
    team = check.team_probe(environment, threads)
    if team["physical_cpus"] != selected:
        raise RuntimeError("Numerical team affinity differs.")
    artifact_paths = [
        Path(__file__),
        args.plan,
        OLD / "measure_tiles.py",
        OLD / "verify_tiles.py",
        OLD / "canonical_banks.py",
        OLD / "frozen_inputs.py",
    ]
    artifact_paths += [
        Path(condition[key])
        for key in (
            "coordinator_library",
            "coordinator_source",
            "baseline_library",
            "baseline_source",
            "fortran_library",
            "fortran_source",
            "setup_library",
        )
    ]
    for language in ("fortran", "python", "julia"):
        if any(name.startswith(language + "_") for name in names):
            candidates = (
                (HERE / language).rglob("*")
                if language == "fortran"
                else (HERE / language).iterdir()
            )
            artifact_paths += [
                path
                for path in candidates
                if path.is_file()
                and path.suffix in (".py", ".jl", ".f90", ".so", ".c")
                and "__pycache__" not in str(path)
            ]
    identities = {str(path.resolve()): measured.digest(path) for path in artifact_paths}
    report = {
        "frozen_manifest": frozen,
        "passed": False,
        "model": args.model,
        "shape": [args.n, args.n] if args.model == "sw" else [args.n],
        "complete_steps": 1000,
        "cpu_budget": 248,
        "actual_workers": threads,
        "nonempty_spatial_owners": threads,
        "configuration": config,
        "allocation": allocation,
        "team": team,
        "input_identity": bank["identity"],
        "canonical_record": cached.identity,
        "canonical_fpsr": cached.fpsr,
        "standard_flag_scope": "Standard flags agree across verified routes; immediate oracle flags remain unknown when absent from the reused bank.",
        "artifacts": identities,
        "callback_mappings": {
            name: impl.callback_mapping for name, impl in implementations.items()
        },
        "verification_only": args.verify_only,
        "development_exception": bool(args.development_threads),
        "samples": [],
        "preflight": [],
        "placement_before": [b.numa_record() for b in buffers.blocks]
        + [workspace.numa_record()],
        "timer_scope": "One complete native coordinator call including gather, both stages, overlap, communication, boundaries, barriers and publication; JIT, allocation, warmup, input restoration, checks and output are outside.",
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)

    def verify_call(name, label, observed=None):
        nonlocal standard_flags
        flags, controls = (
            observed
            if observed is not None
            else (environment.cpu_fpsr(), environment.cpu_fpcr())
        )
        if controls != 0 or (
            standard_flags is not None and flags & 31 != standard_flags
        ):
            raise RuntimeError(
                (
                    "Floating-point environment differs",
                    name,
                    label,
                    flags,
                    controls,
                    standard_flags,
                )
            )
        if standard_flags is None:
            standard_flags = flags & 31
        check.compare_all(reference, buffers, (name, label))
        buffers.check_guards()
        workspace.check()
        check.shared.protocol._compare(
            bank["par"], buffers.parameters, "immutable parameters"
        )
        return flags, controls

    for name, impl in implementations.items():
        buffers.reset()
        impl.bind(buffers, 4)()
        buffers.check_guards()
        workspace.check()
        check.shared.protocol._compare(
            bank["par"], buffers.parameters, "preflight warmup immutable parameters"
        )
        if environment.cpu_fpcr() != 0:
            raise RuntimeError("Preflight warmup changed floating-point controls.")
        buffers.reset()
        environment.cpu_set_fpsr(0)
        impl.bind(buffers, 1000)()
        flags, controls = verify_call(name, "preflight")
        report["preflight"].append(
            {
                "implementation": name,
                "zero_differing_bytes": True,
                "fpsr": flags,
                "fpcr": controls,
            }
        )
    report["standard_flags"] = standard_flags
    report["team_after_preflight"] = check.team_probe(environment, threads)
    if report["team_after_preflight"]["physical_cpus"] != selected:
        raise RuntimeError("Post-preflight numerical team affinity differs.")
    if args.verify_only:
        report.update(
            passed=True, zero_differing_bytes=True, independent_physics_passed=True
        )
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        print(
            json.dumps(
                {
                    "passed": True,
                    "routes": names,
                    "model": args.model,
                    "n": args.n,
                    "workers": threads,
                }
            ),
            flush=True,
        )
        return
    for repeat in range(12):
        shift = repeat % len(names)
        order = names[shift:] + names[:shift]
        for name in order:
            if time.time() >= deadline - 120:
                raise RuntimeError(
                    "Collection deadline reached before the next timed call."
                )
            impl = implementations[name]
            buffers.reset()
            impl.bind(buffers, 4)()
            buffers.check_guards()
            workspace.check()
            check.shared.protocol._compare(
                bank["par"], buffers.parameters, "warmup immutable parameters"
            )
            if environment.cpu_fpcr() != 0:
                raise RuntimeError("Warmup changed floating-point controls.")
            buffers.reset()
            invoke = impl.bind(buffers, 1000)
            before = measured.quiet_window()
            activity_before = measured.activity_snapshot()
            faults_before = resource.getrusage(resource.RUSAGE_SELF)
            was_enabled = gc.isenabled()
            gc.disable()
            environment.cpu_set_fpsr(0)
            started = time.perf_counter_ns()
            try:
                invoke()
                stopped = time.perf_counter_ns()
                flags, controls = environment.cpu_fpsr(), environment.cpu_fpcr()
            finally:
                if was_enabled:
                    gc.enable()
            elapsed = stopped - started
            activity_after = measured.activity_snapshot()
            faults_after = resource.getrusage(resource.RUSAGE_SELF)
            verify_call(name, repeat, (flags, controls))
            after = measured.quiet_window()
            activity = measured.activity_delta(
                activity_before, activity_after, elapsed, len(allowed)
            )
            enclosing_start, enclosing_end = (
                before["before_counters"],
                after["after_counters"],
            )
            enclosing_ns = (
                enclosing_end["process_read_ns"][1] - enclosing_start["node_read_ns"][0]
            )
            if enclosing_ns < 1_000_000_000:
                raise RuntimeError(
                    "The enclosing activity interval is shorter than one second."
                )
            enclosing = measured.activity_delta(
                enclosing_start, enclosing_end, enclosing_ns, len(allowed)
            )
            enclosing.update(
                observation_elapsed_ns=enclosing_ns,
                empirical_gate_threshold_cores=1.0,
                included_work="Before quiet window, solver, outside-timer checks, fixed settle and after quiet window.",
                gate_scope="Empirical adjusted mean residual; asynchronous accounting lag remains unknown.",
            )
            sample = {
                "implementation": name,
                "repeat": repeat,
                "order": order,
                "elapsed_ns": elapsed,
                "fpcr": controls,
                "fpsr": flags,
                "minor_faults": faults_after.ru_minflt - faults_before.ru_minflt,
                "major_faults": faults_after.ru_majflt - faults_before.ru_majflt,
                "before": before,
                "after": after,
                "enclosing_activity": enclosing,
                "zero_differing_bytes": True,
                "short_activity_diagnostic_only": True,
                **activity,
            }
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
    report["team_after_timing"] = check.team_probe(environment, threads)
    if report["team_after_timing"]["physical_cpus"] != selected:
        raise RuntimeError("Post-timing numerical team affinity differs.")
    updates = args.n**2 * 1000 if args.model == "sw" else args.n * 1000
    report["summary"] = {}
    for name in names:
        seconds = np.array(
            [
                row["elapsed_ns"] / 1e9
                for row in report["samples"]
                if row["implementation"] == name
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
    if frozen is not None:
        for path, expected_hash in frozen["artifacts"].items():
            if measured.digest(path) != expected_hash:
                raise RuntimeError(("Frozen artifact differs after timing", path))
    for path, identity in identities.items():
        if measured.digest(path) != identity:
            raise RuntimeError(("Selected artifact changed", path))
    report.update(
        passed=True,
        zero_differing_bytes=True,
        independent_physics_passed=True,
        placement_after=[b.numa_record() for b in buffers.blocks]
        + [workspace.numa_record()],
    )
    args.output.write_text(json.dumps(report, indent=2) + "\n")


def main():
    """Parse explicit workload and verification controls, then run once."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("model", choices=("sw", "ebm"))
    parser.add_argument("n", type=int)
    parser.add_argument("--plan", type=Path, default=HERE / "plan.json")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--development-threads", type=int)
    parser.add_argument("--routes")
    run(parser.parse_args())


if __name__ == "__main__":
    main()

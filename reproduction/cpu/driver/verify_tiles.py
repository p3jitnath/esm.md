"""Check tiled complete calls against the unchanged scientific reference."""

import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".runtime/cpu_fortran_20261108"))
import paired_timing as shared

P = ctypes.POINTER(ctypes.c_double)
I = ctypes.c_int
L = ctypes.c_int64


def digest(path):
    """Return the SHA256 identifier of an existing artifact.

    Parameters
    ----------
    path : str or pathlib.Path
        File whose stored bytes are read without changing them.

    Returns
    -------
    str
        Hexadecimal SHA256 identifier of the file contents.

    Raises
    ------
    OSError
        If the file cannot be read.
    """
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


class Tiled:
    """Bind one complete numerical core to the common Fortran coordinator.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Shallow-water or energy-balance model whose native interface is selected.
    path : pathlib.Path
        Shared library that owns the numerical core and its complete-run entry.
    config : tuple of int
        ``(px, py, batch)`` for shallow water, or ``(threads, batch)`` for energy
        balance. The spatial counts select nonempty owners, and ``batch`` is the
        number of complete local time updates between global publications.
    coordinator_path : pathlib.Path, optional
        Shared library that owns tile gathering, complete local calls, boundaries
        and publication. The local default is used when this argument is absent.

    Attributes
    ----------
    workspace : numpy.ndarray of float64 or None
        One-dimensional private scratch, allocated or borrowed when buffers bind.
        Its values have no common physical unit and are not simulation output.
    raw : numpy.ndarray of uint64 or None
        Workspace words with 16 guard words before and after the numerical span.
    binding : list or None
        Native call arguments that borrow the current global buffer addresses.

    Raises
    ------
    OSError
        If a selected shared library or one of its dependencies cannot be loaded.
    AttributeError
        If a selected library does not export a required native entry.

    Notes
    -----
    Construction binds interfaces without advancing the model. A later call
    returned by ``bind`` changes the caller-owned states and private scratch.
    Shallow-water states contain depth in metres and momenta in square metres
    per second; energy-balance states contain temperatures in degrees Celsius.
    Parameter and coefficient inputs must remain unchanged during a native call.
    """

    def __init__(self, model, path, config, coordinator_path=None):
        """Load the numerical core and describe the coordinator's C arguments.

        Parameters
        ----------
        model : {'sw', 'ebm'}
            Model whose complete-run interface is bound.
        path : pathlib.Path
            Shared numerical library to retain for this instance's lifetime.
        config : tuple of int
            ``(px, py, batch)`` for shallow water or ``(threads, batch)`` for energy
            balance, with counts defined in the class documentation.
        coordinator_path : pathlib.Path, optional
            Coordinator library; ``None`` selects the local default.

        Returns
        -------
        None
            The instance retains library handles and has no workspace or buffers yet.

        Raises
        ------
        OSError
            If a required library or dependency cannot be loaded.
        AttributeError
            If a required native entry is absent.
        """
        self.model = model
        self.core = shared.backend(model, path.stem, path)
        self.name = path.stem
        self.config = config
        self.lib = ctypes.CDLL(
            str(coordinator_path or HERE / "build/libparallel_tiles.so")
        )
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
        prefix = "sw" if model == "sw" else "eb"
        self.kernel = ctypes.cast(
            getattr(self.core.lib, prefix + "_run"), ctypes.c_void_p
        )
        self.callback_mapping = {}
        for label, function, expected in (("kernel", getattr(self.core.lib, prefix + "_run"), path), ("coordinator", getattr(self.lib, prefix + "_run_tiles"), coordinator_path or HERE / "build/libparallel_tiles.so")):
            address = int(ctypes.cast(function, ctypes.c_void_p).value)
            found = None
            for row in Path("/proc/self/maps").read_text().splitlines():
                words = row.split(maxsplit=5)
                low, high = (int(value, 16) for value in words[0].split("-"))
                if low <= address < high:
                    if len(words) != 6 or words[5].endswith(" (deleted)") or Path(words[5]).resolve() != Path(expected).resolve():
                        raise RuntimeError(("Unexpected callback provider", label, row, str(expected)))
                    found = {"address": hex(address), "mapping": row, "path": str(Path(expected).resolve())}
                    break
            if found is None:
                raise RuntimeError(("Unmapped callback", label, hex(address)))
            self.callback_mapping[label] = found
        self.raw = None
        self.workspace = None
        self.binding = None

    def bind(self, buffers, count):
        """Prepare a complete solver call that borrows the supplied buffers.

        Parameters
        ----------
        buffers : object
            Owner of disjoint, contiguous FP64 arrays ``q``, ``stage`` and ``out``.
            For shallow water their NumPy shape is ``(3, ny + 2, nx + 2)``, and
            ``parameters`` has shape ``(4,)``. The three fields are depth [m] and
            two momenta [m2/s]. For energy balance, the states have shape ``(n + 2,)``
            in degrees Celsius, ``coeff`` has shape ``(3, n + 2)``, and ``par`` has
            shape ``(6,)``. The two added cells in each direction are boundary copies.
            Parameters and energy-balance coefficients are borrowed as read-only inputs.
        count : int
            Number of complete time updates, within the coordinator's admitted bounds.

        Returns
        -------
        callable
            No-argument call that advances the model through the native coordinator
            and raises an error if that coordinator reports failure.

        Raises
        ------
        ValueError
            If the grid or tile configuration has no admitted workspace size.
        MemoryError
            If the required private workspace cannot be allocated.

        Notes
        -----
        Binding records addresses without executing a numerical stage. It allocates
        or reuses scratch and replaces this instance's current argument list, so an
        older returned callable also uses the latest binding. Keep the global buffer
        owners alive until each native call finishes. A positive-count call may change
        all three state arrays and scratch; a zero-count call must preserve them.
        """

        def ptr(a):
            """Borrow the address of one contiguous FP64 array.

            Parameters
            ----------
            a : numpy.ndarray of float64
                Existing contiguous input, state or scratch array, with FP64 elements in
                the processor's byte order and one of the declared shapes.

            Returns
            -------
            ctypes.POINTER(ctypes.c_double)
                Pointer to the existing first element; no data are copied or changed.

            Notes
            -----
            The enclosing binding keeps using this address until it is replaced. The
            caller must keep the array's owner alive throughout the native call.
            """
            return a.ctypes.data_as(P)

        if self.model == "sw":
            nx, ny = buffers.q.shape[2] - 2, buffers.q.shape[1] - 2
            px, py, batch = self.config
            needed = self.lib.sw_tiles_values(nx, ny, px, py, batch)
            fn = self.lib.sw_run_tiles
            prefix = [self.kernel, nx, ny] + [
                ptr(a)
                for a in (buffers.q, buffers.stage, buffers.out, buffers.parameters)
            ]
            suffix = [count, px, py, batch]
        else:
            n = buffers.q.size - 2
            threads, batch = self.config
            needed = self.lib.eb_tiles_values(n, threads, batch)
            fn = self.lib.eb_run_tiles
            prefix = [self.kernel, n] + [
                ptr(a)
                for a in (
                    buffers.q,
                    buffers.stage,
                    buffers.out,
                    buffers.coeff,
                    buffers.par,
                )
            ]
            suffix = [count, threads, batch]
        if needed < 0:
            raise ValueError((self.model, self.config, needed))
        if self.raw is None or self.workspace.size != needed:
            self.raw = np.empty(needed + 32, dtype=np.uint64)
            self.raw[:16] = shared.protocol.CANARY
            self.raw[-16:] = shared.protocol.CANARY
            self.workspace = self.raw[16:-16].view(np.float64)
        self.binding = prefix + suffix + [ptr(self.workspace), needed]

        def call():
            """Execute the instance's currently bound complete solver call.

            Returns
            -------
            None
                The native coordinator publishes its results into the borrowed buffers.

            Raises
            ------
            RuntimeError
                If the coordinator returns a nonzero status for the bound arguments.

            Notes
            -----
            The native call owns every numerical stage and boundary update. Positive
            counts change ``q``, ``stage``, ``out`` and private scratch, while the frozen
            parameters and coefficients remain input-only. A zero count preserves every
            state and scratch word. Restore inputs before an independent comparison.
            """
            status = fn(*self.binding)
            if status:
                raise RuntimeError((self.model, self.name, self.config, status))

        return call

    def check_workspace(self):
        """Check the guard words beside the bound private workspace.

        Returns
        -------
        None
            Both 16-word guard regions remain unchanged when the check passes.

        Raises
        ------
        AssertionError
            If a native call wrote outside the declared workspace span.

        Notes
        -----
        Call ``bind`` first. This check reads the guards without changing scratch
        and does not compare unspecified values inside the workspace.
        """
        assert np.all(self.raw[:16] == shared.protocol.CANARY)
        assert np.all(self.raw[-16:] == shared.protocol.CANARY)


def compare_all(expected, candidate, label):
    """Compare all stored words in the three padded state buffers.

    Parameters
    ----------
    expected, candidate : object
        Buffer owners with matching FP64 ``q``, ``stage`` and ``out`` arrays.
        Shallow-water shapes are ``(3, ny + 2, nx + 2)`` with depth [m] and
        momenta [m2/s]; energy-balance shapes are ``(n + 2,)`` in degrees Celsius.
        Every boundary cell is included, and neither owner's arrays are changed.
    label : object
        Case description retained in the first-mismatch diagnostic.

    Returns
    -------
    None
        All three arrays have identical stored words when the check passes.

    Raises
    ------
    AssertionError
        If a word differs. The error identifies the first field and cell index,
        together with the expected and observed hexadecimal bit patterns.

    Notes
    -----
    Integer views preserve the distinction between signed zeros and between
    NaN payloads. Comparing both ``q`` and ``out`` checks the previous and final
    states regardless of the solver's odd/even step-count buffer selection.
    """
    for field in ("q", "stage", "out"):
        a = getattr(expected, field)
        b = getattr(candidate, field)
        if not np.array_equal(a.view(np.uint64), b.view(np.uint64)):
            flat = np.flatnonzero(
                a.view(np.uint64).ravel() != b.view(np.uint64).ravel()
            )
            i = int(flat[0])
            raise AssertionError(
                {
                    "label": label,
                    "field": field,
                    "index": np.unravel_index(i, a.shape),
                    "expected_bits": hex(int(a.view(np.uint64).ravel()[i])),
                    "observed_bits": hex(int(b.view(np.uint64).ravel()[i])),
                }
            )


def team_probe(lib, threads):
    """Check actual worker CPUs, control words and floating-point behaviour.

    Parameters
    ----------
    lib : ctypes.CDLL
        Native library that exports ``cpu_team_probe`` for the current target.
    threads : int
        Requested number of workers and length of each native output record.

    Returns
    -------
    dict
        Requested count, observed physical CPU identifiers, floating-point control
        words and value-probe results, each retained in ordinary Python values.

    Raises
    ------
    AssertionError
        If a worker has an unexpected nonzero control word, a value probe fails,
        or workers do not occupy distinct physical CPUs.

    Notes
    -----
    The helper allocates integer output records and sets the native signature.
    Its native probes check gradual underflow, nearest rounding with ties to even,
    and negative zero, restoring each worker's saved status after those probes.
    No simulation state is supplied. These placement and environment checks do
    not replace the numerical call's output and exception-status comparisons.
    """
    ctrl = np.zeros(threads, dtype=np.uint64)
    status = np.zeros(threads, dtype=np.uint64)
    cpus = np.zeros(threads, dtype=np.int32)
    probes = np.zeros(threads, dtype=np.int32)
    lib.cpu_team_probe.argtypes = [
        I,
        ctypes.POINTER(ctypes.c_uint64),
        ctypes.POINTER(ctypes.c_uint64),
        ctypes.POINTER(I),
        ctypes.POINTER(I),
    ]
    lib.cpu_team_probe.restype = None
    lib.cpu_team_probe(
        threads,
        ctrl.ctypes.data_as(ctypes.POINTER(ctypes.c_uint64)),
        status.ctypes.data_as(ctypes.POINTER(ctypes.c_uint64)),
        cpus.ctypes.data_as(ctypes.POINTER(I)),
        probes.ctypes.data_as(ctypes.POINTER(I)),
    )
    assert np.all(ctrl == 0), ctrl
    assert np.all(probes == 0), probes
    assert len(set(cpus.tolist())) == threads, cpus
    return {
        "threads": threads,
        "physical_cpus": cpus.tolist(),
        "fpcr": ctrl.tolist(),
        "probe_status": probes.tolist(),
    }


def main():
    """Run the selected exact-state, physical and floating-point checks.

    Returns
    -------
    None
        Write the requested JSON acceptance record and print its compact summary.

    Raises
    ------
    AssertionError
        If states, boundary copies, immutable inputs, physical limits, conserved
        budgets, workspace guards or floating-point control fail a required check.
    RuntimeError
        If a complete native coordinator call returns an error status.
    OSError
        If a required library or artifact cannot be read, or the report cannot
        be written.

    Notes
    -----
    Command-line settings select models, libraries, grids and optional scratch
    poisoning. Each comparison starts from the same frozen input and checks all
    three padded state arrays against the unchanged Fortran reference. Zero-step
    calls also preserve every workspace word. Positive-step cases check physical
    admissibility and the relevant shallow-water or energy-balance budgets.
    Floating-point exception-status differences are recorded separately and set
    ``passed`` and ``status_passed`` false; they do not themselves raise an error.
    The record identifies the selected source and library bytes. This verifier
    collects no comparative performance measurements.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--compact-edges", action="store_true")
    parser.add_argument("--sw-long-batches", action="store_true")
    parser.add_argument(
        "--poison-workspace",
        action="store_true",
        help="Fill unspecified scratch with signalling NaNs to expose inactive reads.",
    )
    parser.add_argument("--output", default="small-acceptance.json")
    parser.add_argument(
        "--coordinator", type=Path, default=HERE / "build/libparallel_tiles.so"
    )
    parser.add_argument(
        "--coordinator-source", type=Path, default=HERE / "parallel_tiles.f90"
    )
    parser.add_argument(
        "--models", nargs="+", choices=("sw", "ebm"), default=("sw", "ebm")
    )
    parser.add_argument(
        "--sw-assembly",
        type=Path,
        default=ROOT / ".runtime/cpu_fortran_20261108/build/libsw_assembly.so",
    )
    parser.add_argument(
        "--sw-fortran",
        type=Path,
        default=ROOT / ".runtime/sw/fortran_port_20261108/build/libsw_public_final.so",
    )
    parser.add_argument(
        "--ebm-assembly",
        type=Path,
        default=ROOT / ".runtime/cpu_fortran_20261108/build/libeb_assembly.so",
    )
    parser.add_argument(
        "--ebm-fortran",
        type=Path,
        default=ROOT / ".runtime/ebm/fortran_port_20261108/libeb_fortran.so",
    )
    parser.add_argument(
        "--probe-library", type=Path, default=HERE / "build/libcpu_probe.so"
    )
    args = parser.parse_args()
    lib = ctypes.CDLL(str(args.probe_library))
    lib.cpu_fpcr.restype = ctypes.c_uint64
    lib.cpu_fpsr.restype = ctypes.c_uint64
    lib.cpu_set_fpsr.argtypes = [ctypes.c_uint64]
    teams = [team_probe(lib, t) for t in (1, 2, 4)]
    paths = {
        "sw": [args.sw_assembly.resolve(), args.sw_fortran.resolve()],
        "ebm": [args.ebm_assembly.resolve(), args.ebm_fortran.resolve()],
    }
    libraries = [args.coordinator.resolve(), args.probe_library.resolve()]
    libraries += [p for model in args.models for p in paths[model]]
    libraries += [
        ROOT
        / (
            ".agents/bench/.build/lib"
            + ("sw" if model == "sw" else "eb")
            + "_fortran_vanilla.so"
        )
        for model in args.models
    ]
    records = []
    fpsr_records = []
    counts = (0, 1, 2, 3, 8, 9) if args.quick else (0, 1, 2, 3, 4, 5, 7, 8, 9, 17, 33)
    if args.sw_long_batches:
        counts = tuple(sorted(set(counts) | {15, 16, 31, 32}))
    for model in args.models:
        canonical = shared.backend(
            model,
            "canonical",
            ROOT
            / (
                ".agents/bench/.build/lib"
                + ("sw" if model == "sw" else "eb")
                + "_fortran_vanilla.so"
            ),
        )
        sizes = (
            [(1, 1), (3, 2), (17, 11), (64, 64)]
            if model == "sw"
            else [1, 2, 17, 65, 128, 4096]
        )
        if not args.quick:
            sizes += (
                [(129, 65), (256, 256)]
                if model == "sw"
                else [31, 33, 127, 129, 257, 1025, 65536]
            )
        if args.compact_edges and model == "sw":
            sizes += [
                (1, 2),
                (1, 3),
                (2, 1),
                (2, 2),
                (2, 3),
                (3, 1),
                (3, 3),
                (31, 1),
                (63, 2),
                (65, 3),
            ]
        for size in sizes:
            if model == "sw":
                nx, ny = size
                seed = shared.protocol._initial("mixed", nx, ny)
                par = shared.protocol._parameters(nx, ny, "mixed")[0]
                make = lambda: shared.protocol._Buffers(seed, par)
                configs = [(1, 1, 1)]
                if nx >= 2:
                    configs += [
                        (2, 1, b)
                        for b in (
                            (1, 2, 4, 8, 16, 32)
                            if args.sw_long_batches
                            else (1, 2, 4, 8)
                        )
                    ]
                if nx >= 2 and ny >= 2:
                    configs += [
                        (2, 2, b)
                        for b in (
                            (1, 2, 4, 8, 16, 32)
                            if args.sw_long_batches
                            else (1, 2, 4, 8)
                        )
                    ]
            else:
                seed, coeff, par, _ = shared.ebm.inputs(size)
                if size > 2:
                    seed[:] = -25 + ((np.arange(size) * 37) % 113) * (60 / 113)
                    seed[size // 2] = -10
                make = lambda: shared.ebm.Buffers(seed, coeff, par)
                configs = [(1, 1)] + [
                    (t, b) for t in (2, 4) if t <= size for b in (1, 2, 4, 8)
                ]
            for count in counts:
                expected = make()
                if args.poison_workspace:
                    expected.work.view(np.uint64)[:] = np.uint64(0x7FF0000000000001)
                lib.cpu_set_fpsr(0)
                if model == "sw":
                    canonical.run(expected, count)
                else:
                    canonical.bind(expected, count)()
                canonical_fpsr = lib.cpu_fpsr()
                for config in configs:
                    for path in paths[model]:
                        candidate = Tiled(model, path, config, args.coordinator)
                        trial = make()
                        invoke = candidate.bind(trial, count)
                        if args.poison_workspace:
                            candidate.workspace.view(np.uint64)[:] = np.uint64(
                                0x7FF0000000000001
                            )
                        saved_workspace = (
                            candidate.workspace.view(np.uint64).copy()
                            if count == 0
                            else None
                        )
                        lib.cpu_set_fpsr(0)
                        invoke()
                        observed_fpsr = lib.cpu_fpsr()
                        if count == 0:
                            assert np.array_equal(
                                saved_workspace, candidate.workspace.view(np.uint64)
                            )
                        compare_all(
                            expected, trial, (model, size, count, config, path.name)
                        )
                        if model == "sw":
                            trial.check_guards()
                            shared.protocol._compare(
                                par, trial.parameters, "immutable parameters"
                            )
                            if count:
                                for state in (trial.q, trial.stage, trial.out):
                                    shared.protocol._halo_check(state)
                                shared.protocol._admissible(trial.stage, par)
                                final = trial.out if count % 2 else trial.q
                                shared.protocol._admissible(final, par)
                                shared.protocol._budget_drift(
                                    seed, final[:, 1:-1, 1:-1]
                                )
                        else:
                            trial.check(coeff, par)
                            if count:
                                previous = trial.q if count % 2 else trial.out
                                final = trial.out if count % 2 else trial.q
                                for state in (trial.q, trial.stage, trial.out):
                                    shared.ebm.halo_check(state)
                                    shared.ebm.admissible(state, coeff, par)
                                shared.ebm.heat_budget(
                                    previous, trial.stage, final, coeff, par
                                )
                        candidate.check_workspace()
                        assert lib.cpu_fpcr() == 0
                        fpsr_records.append(
                            {
                                "model": model,
                                "size": size,
                                "steps": count,
                                "config": config,
                                "core": path.name,
                                "canonical": canonical_fpsr,
                                "observed": observed_fpsr,
                            }
                        )
                records.append(
                    {
                        "model": model,
                        "size": size,
                        "steps": count,
                        "configurations": len(configs),
                    }
                )
    status_passed = not any(x["canonical"] != x["observed"] for x in fpsr_records)
    report = {
        "passed": status_passed,
        "state_passed": True,
        "status_passed": status_passed,
        "zero_differing_bytes": True,
        "compared_buffers": ["q", "stage", "out"],
        "workspace_guards": True,
        "zero_step_workspace_unchanged": True,
        "physical_checks": [
            "SW admissibility and conserved budgets",
            "EBM admissibility and final-step heat budget",
        ],
        "teams": teams,
        "cases": records,
        "fpsr_observations": fpsr_records,
        "fpsr_mismatches": sum(x["canonical"] != x["observed"] for x in fpsr_records),
        "sources": {
            str(p): digest(p)
            for p in [
                args.coordinator_source.resolve(),
                HERE / "fp_context.c",
                Path(__file__),
            ]
        },
        "libraries": {str(p): digest(p) for p in libraries},
        "poison_workspace": args.poison_workspace,
        "job": os.environ.get("SLURM_JOB_ID"),
        "node": os.uname().nodename,
    }
    (HERE / args.output).write_text(json.dumps(report, indent=2) + "\n")
    print(
        json.dumps(
            {
                "passed": report["passed"],
                "state_passed": True,
                "cases": len(records),
                "fpsr_mismatches": report["fpsr_mismatches"],
            }
        )
    )


if __name__ == "__main__":
    main()

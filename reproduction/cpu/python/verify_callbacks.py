"""Check changed native Python callback interfaces without recording timings."""

import ctypes
import json
import os
from pathlib import Path
import re
import sys

import numpy as np

HERE = Path(__file__).resolve().parent
CPU = HERE.parents[2] / "cpu"
sys.path.insert(0, str(CPU))
import verify_tiles as check
import frozen_inputs
import canonical_banks
from callbacks import build_routes, compilation_record

I = ctypes.c_int
U = ctypes.c_uint64
UP = ctypes.POINTER(U)


def candidate(model, route, config, coordinator):
    """Bind a retained JIT callback to the accepted complete coordinator.

    Parameters
    ----------
    model : {"sw", "ebm"}
        Model whose native interface is selected.
    route : str
        One of the two compiled Python route identifiers.
    config : tuple of int
        Spatial worker partition followed by complete steps per local group.
    coordinator : pathlib.Path
        Accepted production solver library, also supplying its coordinator.

    Returns
    -------
    verify_tiles.Tiled
        Complete solver with its Python CFunc owner kept alive.
    """
    item = check.Tiled(model, coordinator, config, coordinator)
    item.keepalive = build_routes(model)[route]
    item.kernel = ctypes.c_void_p(item.keepalive.address)
    item.name = route
    return item


def physics(model, trial, seed, coeff, par, count):
    """Reuse the independent conservation, physical-range and boundary checks.

    Parameters
    ----------
    model : {"sw", "ebm"}
        Physical model of the supplied disjoint buffers.
    trial : object
        Padded state owner changed by the complete callback.
    seed, coeff, par : numpy.ndarray or None
        Immutable initial interior, coefficient and parameter inputs in model units.
    count : int
        Complete step count selecting the final state buffer.

    Returns
    -------
    None
        All required checks pass without changing simulation storage.
    """
    if model == "sw":
        trial.check_guards()
        check.shared.protocol._compare(par, trial.parameters, "immutable parameters")
        if count:
            for state in (trial.q, trial.stage, trial.out):
                check.shared.protocol._halo_check(state)
                check.shared.protocol._admissible(state, par)
            final = trial.out if count % 2 else trial.q
            check.shared.protocol._budget_drift(seed, final[:, 1:-1, 1:-1])
    else:
        trial.check(coeff, par)
        if count:
            previous = trial.q if count % 2 else trial.out
            final = trial.out if count % 2 else trial.q
            for state in (trial.q, trial.stage, trial.out):
                check.shared.ebm.halo_check(state)
                check.shared.ebm.admissible(state, coeff, par)
            check.shared.ebm.heat_budget(previous, trial.stage, final, coeff, par)


def main():
    """Check callbacks, all returned states, guards and IEEE context at four cores.

    Returns
    -------
    None
        Save the actual functional result and inspect emitted machine instructions.

    Raises
    ------
    AssertionError
        If an output, boundary, physical limit, input, guard or environment differs.
    RuntimeError
        If a native solver refuses its supported arguments.
    """
    plan = json.loads((CPU / "collection/plan.json").read_text())
    coordinators = {
        model: Path(
            next(
                row["coordinator_library"]
                for row in plan["conditions"]
                if row["model"] == model
            )
        )
        for model in ("sw", "ebm")
    }
    probe = ctypes.CDLL(str(CPU / "build/libcpu_probe.so"))
    probe.cpu_fpcr.restype = U
    probe.cpu_fpsr.restype = U
    probe.cpu_set_fpcr.argtypes = [U]
    probe.cpu_set_fpsr.argtypes = [U]
    probe.cpu_seed_team.argtypes = [I, U, U]
    probe.cpu_read_team.argtypes = [I, UP, UP]
    teams = [check.team_probe(probe, t) for t in (1, 4)]
    compilers = {model: compilation_record(model) for model in ("sw", "ebm")}
    records = []
    ieee = []
    try:
        for model in ("sw", "ebm"):
            refpath = (
                CPU.parents[2]
                / ".agents/bench/.build"
                / ("lib" + ("sw" if model == "sw" else "eb") + "_fortran_vanilla.so")
            )
            reference = check.shared.backend(model, "canonical", refpath)
            sizes = (
                [(1, 1), (3, 2), (17, 11), (129, 5)]
                if model == "sw"
                else [1, 2, 17, 128, 8193]
            )
            for size in sizes:
                if model == "sw":
                    nx, ny = size
                    seed = check.shared.protocol._initial("mixed", nx, ny)
                    par = check.shared.protocol._parameters(nx, ny, "mixed")[0]
                    coeff = None
                    make = lambda: check.shared.protocol._Buffers(seed, par)
                    config = (2, 2, 4) if min(size) >= 2 else (1, 1, 4)
                else:
                    seed, coeff, par, _ = check.shared.ebm.inputs(size)
                    make = lambda: check.shared.ebm.Buffers(seed, coeff, par)
                    config = (min(4, size), 4)
                for count in (0, 1, 9, 33):
                    expected = make()
                    probe.cpu_set_fpsr(0)
                    (
                        reference.run(expected, count)
                        if model == "sw"
                        else reference.bind(expected, count)()
                    )
                    expected_flags = probe.cpu_fpsr()
                    for route in build_routes(model):
                        trial = make()
                        solver = candidate(model, route, config, coordinators[model])
                        invoke = solver.bind(trial, count)
                        work_before = (
                            solver.workspace.view(np.uint64).copy()
                            if count == 0
                            else None
                        )
                        probe.cpu_set_fpsr(0)
                        invoke()
                        flags = probe.cpu_fpsr()
                        assert probe.cpu_fpcr() == 0
                        assert (flags & 31) == (expected_flags & 31), (
                            model,
                            size,
                            count,
                            route,
                            flags,
                            expected_flags,
                        )
                        check.compare_all(expected, trial, (model, size, count, route))
                        solver.check_workspace()
                        if count == 0:
                            assert np.array_equal(
                                work_before, solver.workspace.view(np.uint64)
                            )
                        physics(model, trial, seed, coeff, par, count)
                        records.append(
                            dict(
                                model=model,
                                size=size,
                                steps=count,
                                route=route,
                                config=config,
                                flags=int(flags),
                                canonical_flags=int(expected_flags),
                            )
                        )
            for size in [64, 256, 1024] if model == "sw" else [128, 4096, 65536]:
                bank = frozen_inputs.load_bank(model, size)
                expected = canonical_banks.load_canonical(model, size, bank["identity"])
                config = (2, 2, 4) if model == "sw" else (4, 4)
                for route in build_routes(model):
                    trial = frozen_inputs.make_buffers(bank)
                    solver = candidate(model, route, config, coordinators[model])
                    invoke = solver.bind(trial, 1000)
                    probe.cpu_set_fpsr(0)
                    invoke()
                    flags = probe.cpu_fpsr()
                    assert probe.cpu_fpcr() == 0 and (flags & 15) == 0
                    check.compare_all(expected, trial, (model, size, 1000, route))
                    solver.check_workspace()
                    physics(
                        model, trial, bank["seed"], bank["coeff"], bank["par"], 1000
                    )
                    records.append(
                        dict(
                            model=model,
                            size=size,
                            steps=1000,
                            route=route,
                            config=config,
                            flags=int(flags),
                            input_identity=bank["identity"],
                        )
                    )
        for model in ("sw", "ebm"):
            refpath = (
                CPU.parents[2]
                / ".agents/bench/.build"
                / ("lib" + ("sw" if model == "sw" else "eb") + "_fortran_vanilla.so")
            )
            reference = check.shared.backend(model, "canonical", refpath)
            if model == "sw":
                seed = check.shared.protocol._initial("mixed", 17, 11)
                par = check.shared.protocol._parameters(17, 11, "mixed")[0]
                make = lambda: check.shared.protocol._Buffers(seed, par)
                config = (2, 2, 4)
            else:
                seed, coeff, par, _ = check.shared.ebm.inputs(128)
                make = lambda: check.shared.ebm.Buffers(seed, coeff, par)
                config = (4, 64)
            for incoming in (0, 1, 16, 129):
                expected = make()
                probe.cpu_set_fpcr(0)
                probe.cpu_set_fpsr(incoming)
                (
                    reference.run(expected, 9)
                    if model == "sw"
                    else reference.bind(expected, 9)()
                )
                expected_flags = probe.cpu_fpsr()
                for route in build_routes(model):
                    trial = make()
                    solver = candidate(model, route, config, coordinators[model])
                    invoke = solver.bind(trial, 9)
                    probe.cpu_seed_team(4, 0x1400000, 129)
                    probe.cpu_set_fpcr(0)
                    probe.cpu_set_fpsr(incoming)
                    invoke()
                    flags = probe.cpu_fpsr()
                    assert probe.cpu_fpcr() == 0
                    assert (flags & 31) == (expected_flags & 31)
                    check.compare_all(expected, trial, ("IEEE", model, route, incoming))
                    controls = np.zeros(4, dtype=np.uint64)
                    statuses = controls.copy()
                    probe.cpu_read_team(
                        4, controls.ctypes.data_as(UP), statuses.ctypes.data_as(UP)
                    )
                    assert controls.tolist() == [0, 0x1400000, 0x1400000, 0x1400000]
                    assert all((int(x) & 31) == 1 for x in statuses[1:])
                    ieee.append(
                        dict(
                            model=model,
                            route=route,
                            incoming=incoming,
                            flags=int(flags),
                            controls=controls.tolist(),
                            statuses=statuses.tolist(),
                        )
                    )
    finally:
        probe.cpu_seed_team(4, 0, 0)
    instruction_audit = {}
    for model in ("sw", "ebm"):
        for route, callback in build_routes(model).items():
            assembly = callback._library.get_asm_str()
            path = HERE / (model + "_" + route + ".s")
            path.write_text(assembly)
            forbidden = [
                line
                for line in assembly.splitlines()
                if re.search(
                    r"\b(?:fmla|fmls|fnmla|fnmls|fmadd|fnmadd|fmsub|fnmsub|frecpe|frecps|frsqrte|frsqrts)\b",
                    line,
                )
            ]
            assert not forbidden, forbidden
            instruction_audit[model + "_" + route] = dict(
                assembly=str(path), forbidden=[]
            )
    result = dict(
        passed=True,
        performance_measurement=False,
        zero_differing_bytes=True,
        compared_buffers=["q", "stage", "out"],
        includes_all_ghosts=True,
        cases=records,
        ieee_context=ieee,
        teams=teams,
        compiler=compilers,
        instructions=instruction_audit,
        coordinators={k: str(v) for k, v in coordinators.items()},
        job=os.environ["SLURM_JOB_ID"],
        node=os.uname().nodename,
    )
    (HERE / "functional_acceptance.json").write_text(
        json.dumps(result, indent=2) + "\n"
    )
    print(
        json.dumps(
            dict(
                passed=True,
                functional_cases=len(records),
                ieee_cases=len(ieee),
                complete_bank_cases=12,
            )
        )
    )


if __name__ == "__main__":
    main()

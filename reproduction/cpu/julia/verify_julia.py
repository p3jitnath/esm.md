"""Qualify Julia callbacks against the unchanged canonical Fortran calculation."""

import ctypes
import json
import os
from pathlib import Path
import sys
import numpy as np

HERE = Path(__file__).resolve().parent
CPU = HERE.parents[2] / "cpu"
sys.path.insert(0, str(CPU))
import verify_tiles as check
import julia_callbacks as provider

COORDINATORS = {
    "sw": CPU / "fortran_sw/selected/build/libsw_selected.so",
    "ebm": CPU
    / "fortran_ebm/final_compact_deferred_tuned/libebm_final_compact_deferred_tuned.so",
}
P = ctypes.POINTER(ctypes.c_double)
I = ctypes.c_int
L = ctypes.c_int64


class JuliaTiled(check.Tiled):
    """Borrow the common coordinator while retaining the Julia callback runtime."""

    def __init__(self, model, config, record):
        """Bind one retained serial callback and its complete GC-safe entry."""
        path = COORDINATORS[model]
        super().__init__(model, path, config, path)
        self.kernel = ctypes.c_void_p(record["address"])
        self.record = record
        name = "sw_run_tiles" if model == "sw" else "eb_run_tiles"
        original = getattr(self.lib, name)
        self.complete = ctypes.CFUNCTYPE(I, *original.argtypes)(
            record["coordinator_shim"]
        )
        # This CDLL instance is private to this route, so replacing its attribute
        # leaves every independently constructed route's entry unchanged.
        setattr(self.lib, name, self.complete)


def main():
    """Check complete states, ghosts, guards, immutable inputs, flags and physics."""
    records = []
    env = ctypes.CDLL(str(CPU / "build/libcpu_probe.so"))
    env.cpu_fpcr.restype = ctypes.c_uint64
    env.cpu_fpsr.restype = ctypes.c_uint64
    env.cpu_set_fpsr.argtypes = [ctypes.c_uint64]
    team = check.team_probe(env, 4)
    for model in ("sw", "ebm"):
        routes = provider.build_routes(model, COORDINATORS[model])
        canonical = check.shared.backend(
            model,
            "canonical",
            Path(".agents/bench/.build")
            / (
                "libsw_fortran_vanilla.so"
                if model == "sw"
                else "libeb_fortran_vanilla.so"
            ),
        )
        sizes = (
            [(1, 1), (3, 2), (17, 11), (129, 65)]
            if model == "sw"
            else [1, 2, 17, 128, 4096]
        )
        for size in sizes:
            if model == "sw":
                nx, ny = size
                seed = check.shared.protocol._initial("mixed", nx, ny)
                par = check.shared.protocol._parameters(nx, ny, "mixed")[0]
                make = lambda: check.shared.protocol._Buffers(seed, par)
                configs = [(1, 1, 1)]
                if nx >= 2 and ny >= 2:
                    configs += [(2, 2, 2), (2, 2, 4)]
            else:
                seed, coeff, par, _ = check.shared.ebm.inputs(size)
                if size > 2:
                    seed[:] = -25 + ((np.arange(size) * 37) % 113) * (60 / 113)
                    seed[size // 2] = -10
                make = lambda: check.shared.ebm.Buffers(seed, coeff, par)
                configs = [(1, 1)] + ([(4, 2), (4, 4)] if size >= 4 else [])
            for count in (0, 1, 2, 3, 4, 5, 8, 9):
                expected = make()
                env.cpu_set_fpsr(0)
                if model == "sw":
                    canonical.run(expected, count)
                else:
                    canonical.bind(expected, count)()
                flags = env.cpu_fpsr() & 31
                for config in configs:
                    for label, route in routes.items():
                        buffers = make()
                        selected = JuliaTiled(model, config, route)
                        selected.bind(buffers, 0)()
                        call = selected.bind(buffers, count)
                        saved = (
                            selected.workspace.view(np.uint64).copy()
                            if count == 0
                            else None
                        )
                        env.cpu_set_fpsr(0)
                        call()
                        observed = env.cpu_fpsr() & 31
                        assert observed == flags, (
                            model,
                            size,
                            count,
                            config,
                            label,
                            flags,
                            observed,
                        )
                        assert env.cpu_fpcr() == 0
                        check.compare_all(
                            expected, buffers, (model, size, count, config, label)
                        )
                        selected.check_workspace()
                        if count == 0:
                            assert np.array_equal(
                                saved, selected.workspace.view(np.uint64)
                            )
                        if model == "sw":
                            buffers.check_guards()
                            check.shared.protocol._compare(
                                par, buffers.parameters, "immutable parameters"
                            )
                            if count:
                                for state in (buffers.q, buffers.stage, buffers.out):
                                    check.shared.protocol._halo_check(state)
                                check.shared.protocol._admissible(buffers.stage, par)
                                final = buffers.out if count % 2 else buffers.q
                                check.shared.protocol._admissible(final, par)
                                check.shared.protocol._budget_drift(
                                    seed, final[:, 1:-1, 1:-1]
                                )
                        else:
                            buffers.check(coeff, par)
                            if count:
                                previous = buffers.q if count % 2 else buffers.out
                                final = buffers.out if count % 2 else buffers.q
                                for state in (buffers.q, buffers.stage, buffers.out):
                                    check.shared.ebm.halo_check(state)
                                    check.shared.ebm.admissible(state, coeff, par)
                                check.shared.ebm.heat_budget(
                                    previous, buffers.stage, final, coeff, par
                                )
                        records.append(
                            {
                                "model": model,
                                "size": size,
                                "count": count,
                                "config": config,
                                "route": label,
                                "standard_flags": observed,
                            }
                        )
        print("MODEL PASSED", model, len(records), flush=True)
    provider._RUNTIME.jl_eval_string(
        b'println("ALLOCATIONS ",FreshJuliaCallbacks.ALLOCATIONS)'
    )
    result = {
        "passed": True,
        "scope": "Functional qualification on four allocated shared-node CPUs; no comparative timing.",
        "team": team,
        "cases": records,
    }
    (HERE / "small_acceptance.json").write_text(json.dumps(result, indent=2) + "\n")
    print("PASSED", len(records), flush=True)


if __name__ == "__main__":
    main()

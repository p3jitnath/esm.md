"""Check the six current thousand-step banks without collecting timings."""

import ctypes
import json
from pathlib import Path
import sys
import numpy as np
from verify_julia import JuliaTiled, COORDINATORS, CPU, HERE
import verify_tiles as check
import frozen_inputs
import canonical_banks
import julia_callbacks as provider


def main():
    """Compare both Julia controls with every complete frozen output bank."""
    env = ctypes.CDLL(str(CPU / "build/libcpu_probe.so"))
    env.cpu_fpcr.restype = ctypes.c_uint64
    env.cpu_fpsr.restype = ctypes.c_uint64
    env.cpu_set_fpsr.argtypes = [ctypes.c_uint64]
    result = {
        "passed": False,
        "steps": 1000,
        "team": check.team_probe(env, 4),
        "scope": "Functional qualification on four shared-node CPUs; no comparative timing.",
        "cases": [],
    }
    for model, sizes, batches in (
        ("sw", (64, 256, 1024), (16, 8, 4)),
        ("ebm", (128, 4096, 65536), (256, 256, 256)),
    ):
        routes = provider.build_routes(model, COORDINATORS[model])
        for size, batch in zip(sizes, batches):
            bank = frozen_inputs.load_bank(model, size)
            cached = canonical_banks.load_canonical(model, size, bank["identity"])
            for label, record in routes.items():
                buffers = frozen_inputs.make_buffers(bank)
                selected = JuliaTiled(
                    model, (2, 2, batch) if model == "sw" else (4, batch), record
                )
                selected.bind(buffers, 4)()
                # Reconstruct from the immutable bank so every scratch and initial
                # state word, not only the interior seed, has its frozen value.
                buffers = frozen_inputs.make_buffers(bank)
                call = selected.bind(buffers, 1000)
                env.cpu_set_fpsr(0)
                call()
                observed = int(env.cpu_fpsr())
                assert env.cpu_fpcr() == 0
                if cached.fpsr is not None:
                    assert observed & 31 == cached.fpsr & 31, (
                        model,
                        size,
                        label,
                        cached.fpsr,
                        observed,
                    )
                check.compare_all(cached, buffers, (model, size, label, 1000))
                selected.check_workspace()
                if model == "sw":
                    buffers.check_guards()
                    check.shared.protocol._compare(
                        bank["par"], buffers.parameters, "immutable parameters"
                    )
                    for state in (buffers.q, buffers.stage, buffers.out):
                        check.shared.protocol._halo_check(state)
                    check.shared.protocol._admissible(buffers.stage, bank["par"])
                    check.shared.protocol._admissible(buffers.q, bank["par"])
                    check.shared.protocol._budget_drift(
                        bank["seed"], buffers.q[:, 1:-1, 1:-1]
                    )
                else:
                    buffers.check(bank["coeff"], bank["par"])
                    for state in (buffers.q, buffers.stage, buffers.out):
                        check.shared.ebm.halo_check(state)
                        check.shared.ebm.admissible(state, bank["coeff"], bank["par"])
                    check.shared.ebm.heat_budget(
                        buffers.out,
                        buffers.stage,
                        buffers.q,
                        bank["coeff"],
                        bank["par"],
                    )
                result["cases"].append(
                    {
                        "model": model,
                        "size": size,
                        "route": label,
                        "steps": 1000,
                        "actual_team": 4,
                        "config": selected.config,
                        "zero_differing_bytes": True,
                        "fpcr": 0,
                        "fpsr": observed,
                        "canonical_fpsr": cached.fpsr,
                        "input_identity_sha256": bank["input_identity_sha256"],
                        "canonical_identity": cached.identity,
                    }
                )
                print("PASSED", model, size, label, flush=True)
    result["passed"] = True
    (HERE / "current_bank_acceptance.json").write_text(
        json.dumps(result, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()

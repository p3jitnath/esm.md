"""Check complete Fortran callback states against the fixed canonical exports."""

import ctypes
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import sys

import numpy as np

ROOT = Path.cwd()
HERE = ROOT / ".runtime/goal_20261112/fresh_languages/cpu/fortran"
CPU = ROOT / ".runtime/goal_20261112/cpu"
sys.path.insert(0, str(CPU))
import canonical_banks
import frozen_inputs
import verify_tiles as check

U = ctypes.c_uint64
probe = ctypes.CDLL(str(CPU / "build/libcpu_probe.so"))
probe.cpu_fpcr.restype = U
probe.cpu_fpsr.restype = U
probe.cpu_set_fpcr.argtypes = [U]
probe.cpu_set_fpsr.argtypes = [U]

build = json.loads((HERE / "build.json").read_text())
records = []
historical = json.loads((ROOT / "paper/pasc27/poster/data/historical/benchmark.json").read_text())
for row in build["records"]:
    old_model = "shallow_water" if row["model"] == "sw" else "budyko_sellers"
    old_name = "solver.f90" if row["route_id"] == "fortran_tuned" else "vanilla.f90"
    key = "src/" + old_model + "/" + old_name
    assert historical["models"][old_model]["fingerprint"][key] == row["source_sha256"]

for model, sizes in (("sw", (64, 256, 1024)), ("ebm", (128, 4096, 65536))):
    if model == "sw":
        coordinator = CPU / "fortran_sw/selected/build/libsw_selected.so"
        config = (2, 2, 2)
    else:
        coordinator = CPU / "fortran_ebm/final_compact_deferred/libebm_final_compact_deferred.so"
        config = (4, 64)
    for size in sizes:
        bank = frozen_inputs.load_bank(model, size)
        canonical = canonical_banks.load_canonical(model, size, bank["identity"])
        standard_flags = None
        for row in (item for item in build["records"] if item["model"] == model):
            trial = frozen_inputs.make_buffers(bank)
            candidate = check.Tiled(model, Path(row["library"]), config, coordinator)
            invoke = candidate.bind(trial, 1000)
            probe.cpu_set_fpcr(0)
            probe.cpu_set_fpsr(0)
            invoke()
            fpcr, fpsr = int(probe.cpu_fpcr()), int(probe.cpu_fpsr())
            assert fpcr == 0, (model, size, row["route_id"], fpcr)
            if standard_flags is None:
                standard_flags = fpsr & 31
            assert fpsr & 31 == standard_flags, (model, size, row["route_id"], fpsr, standard_flags)
            check.compare_all(canonical, trial, (model, size, row["route_id"], 1000))
            candidate.check_workspace()
            if model == "sw":
                trial.check_guards()
                check.shared.protocol._compare(bank["par"], trial.parameters, "immutable parameters")
                for state in (trial.q, trial.stage, trial.out):
                    check.shared.protocol._halo_check(state)
                    check.shared.protocol._admissible(state, bank["par"])
                physical = {"budget_drift": check.shared.protocol._budget_drift(bank["seed"], trial.q[:, 1:-1, 1:-1])}
            else:
                trial.check(bank["coeff"], bank["par"])
                for state in (trial.q, trial.stage, trial.out):
                    check.shared.ebm.halo_check(state)
                    check.shared.ebm.admissible(state, bank["coeff"], bank["par"])
                physical = {"heat_budget": check.shared.ebm.heat_budget(trial.out, trial.stage, trial.q, bank["coeff"], bank["par"])}
            records.append({
                "model": model, "size": size, "route_id": row["route_id"],
                "complete_steps": 1000, "config": list(config), "actual_workers": 4,
                "source": row["source"], "source_sha256": row["source_sha256"],
                "library": row["library"], "library_sha256": row["library_sha256"],
                "coordinator": str(coordinator), "input_identity": bank["identity"],
                "canonical": canonical.identity,
                "zero_differing_bytes": True, "complete_arrays": ["q", "stage", "out"],
                "all_ghost_cells": True, "guards": True, "immutable_inputs": True,
                "fpcr": fpcr, "fpsr": fpsr, "standard_flags": fpsr & 31,
                "canonical_immediate_flags_known": canonical.fpsr is not None,
                "physical": physical,
            })
            print(json.dumps({"passed": True, "model": model, "size": size, "route": row["route_id"]}), flush=True)
report = {
    "passed": True, "utc": datetime.now(timezone.utc).isoformat(),
    "job": os.environ.get("SLURM_JOB_ID"), "node": os.uname().nodename,
    "scope": "Shared-node functional qualification with four workers; no performance measurements. Final248/128 team qualification remains required on the exclusive node.",
    "historical_sources_match_recorded_fingerprints": True,
    "canonical_status_scope": "Saved canonical exports do not retain immediate flags. Both controls agree in supported standard flags; independent small fixtures compare flags with a fresh canonical call.",
    "physical_scope": "Reused unchanged historical scientific fixtures; current trajectories pass admissibility, boundaries and final-step budget checks.",
    "records": records,
}
(HERE / "bank-acceptance.json").write_text(json.dumps(report, indent=2) + "\n")

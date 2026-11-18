"""Freeze reviewed CPU source, input identities and runtime records once."""

import datetime as dt
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
OLD = HERE.parents[1] / "cpu"


def main():
    """Bind the complete reviewed cohort before final team qualification."""
    destination = HERE / "freeze.json"
    if destination.exists():
        raise RuntimeError(
            "A frozen cohort already exists; preserve it as its own revision."
        )
    for path in (
        HERE / "fortran/build.json",
        HERE / "python/manifest.json",
        HERE / "julia/manifest.json",
        HERE / "fortran/collector_review.json",
    ):
        if not path.is_file():
            raise RuntimeError(
                ("Required immutable readiness record is absent", str(path))
            )
    review = json.loads((HERE / "fortran/collector_review.json").read_text())
    if not review.get("passed"):
        raise RuntimeError("The focused collector review has unresolved findings.")
    plan_path = HERE / "plan.json"
    plan = json.loads(plan_path.read_text())
    if plan["status"] != "DRAFT":
        raise RuntimeError("Only a reviewed draft can be frozen once.")
    paths = {plan_path, Path(__file__)}
    paths.update(
        HERE / name
        for name in (
            "campaign.py",
            "collect.py",
            "qualify.py",
            "collector_format_r4.json",
        )
    )
    paths.update(
        OLD / name
        for name in (
            "measure_tiles.py",
            "verify_tiles.py",
            "frozen_inputs.py",
            "canonical_banks.py",
            "restore_tiles.f90",
            "fp_context.c",
            "build/libcpu_probe.so",
        )
    )
    for condition in plan["conditions"]:
        for key in (
            "baseline_library",
            "baseline_source",
            "fortran_library",
            "fortran_source",
            "coordinator_library",
            "coordinator_source",
            "setup_library",
            "acceptance",
            "canonical_bank_metadata",
        ):
            paths.add(Path(condition[key]))
    # Scan only the small owned control folders; Julia dependencies stay outside.
    suffixes = {".py", ".jl", ".f90", ".c", ".so", ".json"}
    for language in ("python", "julia"):
        paths.update(
            path
            for path in (HERE / language).iterdir()
            if path.is_file() and path.suffix in suffixes
        )
    paths.update(
        path
        for path in (HERE / "fortran").rglob("*")
        if path.is_file() and path.suffix in suffixes and "__pycache__" not in str(path)
    )
    artifacts = {
        str(path.resolve()): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(paths)
    }
    for name, expected in review["reviewed_sources"].items():
        if artifacts.get(str(Path(name).resolve())) != expected:
            raise RuntimeError(
                ("Reviewed collector revision changed before freeze", name)
            )
    plan.update(
        status="FROZEN", frozen_utc=dt.datetime.now(dt.timezone.utc).isoformat()
    )
    plan_path.write_text(json.dumps(plan, indent=2) + "\n")
    artifacts[str(plan_path.resolve())] = hashlib.sha256(
        plan_path.read_bytes()
    ).hexdigest()
    record = {
        "status": "FROZEN",
        "frozen_utc": plan["frozen_utc"],
        "complete_steps": 1000,
        "routes": plan["route_order"],
        "repeats": 12,
        "artifacts": artifacts,
        "large_input_scope": "Reuse accepted input/canonical identities from the plan; existing bank loaders verify the selected arrays. No input is regenerated or broadly re-audited.",
        "ready_scope": "Small-team functional checks and focused protocol review passed; final248/128 qualification and fresh timing remain pending.",
    }
    destination.write_text(json.dumps(record, indent=2) + "\n")
    print(
        json.dumps(
            {
                "status": "FROZEN",
                "artifacts": len(artifacts),
                "manifest": str(destination),
                "sha256": hashlib.sha256(destination.read_bytes()).hexdigest(),
            }
        ),
        flush=True,
    )


if __name__ == "__main__":
    main()

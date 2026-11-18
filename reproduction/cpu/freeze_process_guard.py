"""Freeze the reviewed process-admission revision before accepted CPU timing."""

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
TELEMETRY = HERE / "telemetry_diagnosis"
PREPARATION = HERE / "freeze_process_guard_preparation.json"
FINAL = HERE / "freeze_process_guard_r1.json"


def digest(path):
    """Identify one retained source or metadata file without changing it.

    Parameters
    ----------
    path : pathlib.Path
        Existing small source, library or acceptance record.

    Returns
    -------
    str
        SHA256 identifier of the complete stored bytes.
    """
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    """Freeze preparation, then add actual live validation in a final manifest."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--validation", type=Path)
    parser.add_argument("--validator-review", type=Path, required=True)
    parser.add_argument("--guard-preparation", type=Path, required=True)
    args = parser.parse_args()
    if args.prepare == (args.validation is not None):
        raise ValueError("Select either preparation or one actual validation receipt.")
    review_path = TELEMETRY / "measurement_revision_review.json"
    review = json.loads(review_path.read_text())
    validator_review = json.loads(args.validator_review.read_text())
    guard_preparation = json.loads(args.guard_preparation.read_text())
    if not all(
        item.get("passed") for item in (review, validator_review, guard_preparation)
    ):
        raise RuntimeError(
            "A required source or metadata review has unresolved findings."
        )
    plan_path = HERE / "plan_process_guard.json"
    plan = json.loads(plan_path.read_text())
    if (
        plan["status"] != "DRAFT"
        or plan["measurement_protocol"] != "direct_foreign_tgid_fork_v1"
        or plan["max_quiet_attempts_per_position"] != 8
    ):
        raise RuntimeError("The reviewed measurement plan is not the expected draft.")
    if args.prepare:
        if PREPARATION.exists():
            raise RuntimeError(
                "Preserve the earlier preparation revision before another freeze."
            )
        old = json.loads((HERE / "freeze.json").read_text())
        artifacts = dict(old["artifacts"])
        reviewed = dict(review["reviewed_sources"])
        reviewed.update(validator_review.get("reviewed_sources", {}))
        for path, expected in reviewed.items():
            if digest(Path(path)) != expected:
                raise RuntimeError(
                    ("Reviewed measurement or validation source changed", path)
                )
        paths = [
            HERE / "freeze.json",
            HERE / "campaign_process_guard.py",
            HERE / "collect_process_guard.py",
            plan_path,
            Path(__file__),
            TELEMETRY / "process_guard.py",
            TELEMETRY / "validate_process_guard.py",
            TELEMETRY / "measurement_revision_preparation_r2.json",
            review_path,
            args.validator_review,
            args.guard_preparation,
        ]
        for path in paths:
            artifacts[str(path.resolve())] = digest(path)
        record = {
            "status": "FROZEN_PREPARATION",
            "prepared_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
            "measurement_protocol": plan["measurement_protocol"],
            "max_quiet_attempts_per_position": 8,
            "threshold_cores": 1.0,
            "artifacts": artifacts,
            "old_failed_cohort_manifest": {
                "path": str(HERE / "freeze.json"),
                "sha256": digest(HERE / "freeze.json"),
            },
            "scientific_gate": {
                "path": str(HERE / "final_team_gates_r2/index.json"),
                "sha256": digest(HERE / "final_team_gates_r2/index.json"),
                "scope": "Unchanged48complete1000-step numerical conditions accepted; measurement-only source revision.",
            },
            "live_guard_validation_pending": True,
            "accepted_performance_points": 0,
            "scope": "Preparation/source checks are frozen. Live idle, known foreign load and lifecycle controls remain required before accepted timing. No old refused time is accepted.",
        }
        PREPARATION.write_text(json.dumps(record, indent=2) + "\n")
        print(
            json.dumps(
                {
                    "status": record["status"],
                    "manifest": str(PREPARATION),
                    "sha256": digest(PREPARATION),
                    "artifacts": len(artifacts),
                }
            ),
            flush=True,
        )
        return
    if FINAL.exists():
        raise RuntimeError("A final measurement revision already exists; preserve it.")
    preparation = json.loads(PREPARATION.read_text())
    if preparation["status"] != "FROZEN_PREPARATION":
        raise RuntimeError("The source preparation is not frozen.")
    for path, expected in preparation["artifacts"].items():
        if digest(Path(path)) != expected:
            raise RuntimeError(
                ("Frozen preparation changed before validation acceptance", path)
            )
    validation = json.loads(args.validation.read_text())
    if not validation.get("passed"):
        raise RuntimeError("The actual guard controls did not all pass.")
    science_index = json.loads((HERE / "final_team_gates_r2/index.json").read_text())
    if (
        validation.get("job") != "8353767"
        or validation.get("node") != science_index["node"]
    ):
        raise RuntimeError("The actual validation used a different allocation or node.")
    if (
        validation.get("source_sha256")
        != preparation["artifacts"][
            str((TELEMETRY / "validate_process_guard.py").resolve())
        ]
    ):
        raise RuntimeError("Actual validation uses a different validator revision.")
    if (
        validation.get("guard_sha256")
        != preparation["artifacts"][str((TELEMETRY / "process_guard.py").resolve())]
    ):
        raise RuntimeError(
            "Actual validation uses a different admission helper revision."
        )
    cases = validation.get("cases", [])
    if len(cases) != 3 or not all(case.get("passed") for case in cases):
        raise RuntimeError(
            "Actual validation must contain three accepted fixed controls."
        )
    if {case.get("name") for case in cases} != {
        "idle",
        "two_persistent_foreign_cpus",
        "transient_process_lifecycle",
    }:
        raise RuntimeError("Actual validation contains different control cases.")
    if not all(1.2 <= case["inner_seconds"] <= 1.3 for case in cases):
        raise RuntimeError(
            "Actual validation uses different inner observation durations."
        )
    record = dict(preparation)
    record.update(
        status="FROZEN",
        frozen_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
        live_guard_validation_pending=False,
        preparation_manifest={"path": str(PREPARATION), "sha256": digest(PREPARATION)},
        guard_validation={
            "path": str(args.validation.resolve()),
            "sha256": digest(args.validation),
        },
    )
    record["artifacts"] = dict(preparation["artifacts"])
    plan.update(status="FROZEN", frozen_utc=record["frozen_utc"])
    plan_path.write_text(json.dumps(plan, indent=2) + "\n")
    record["artifacts"][str(plan_path.resolve())] = digest(plan_path)
    record["artifacts"][str(PREPARATION.resolve())] = digest(PREPARATION)
    record["artifacts"][str(args.validation.resolve())] = digest(args.validation)
    FINAL.write_text(json.dumps(record, indent=2) + "\n")
    print(
        json.dumps(
            {
                "status": "FROZEN",
                "manifest": str(FINAL),
                "sha256": digest(FINAL),
                "artifacts": len(record["artifacts"]),
            }
        ),
        flush=True,
    )


if __name__ == "__main__":
    main()

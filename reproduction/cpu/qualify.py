"""Check all complete CPU routes at their final nonempty worker teams."""

import argparse
import datetime as dt
import json
import os
from pathlib import Path
import subprocess
import sys

import collect

HERE = Path(__file__).resolve().parent


def main():
    """Run six bounded exact-output checks on the approved exclusive node."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output-directory", type=Path, default=HERE / "final_team_gates"
    )
    args = parser.parse_args()
    if os.environ.get("SLURM_JOB_ID") != "8353767":
        raise RuntimeError(
            "Final team qualification requires the approved exclusive node."
        )
    plan = json.loads((HERE / "plan.json").read_text())
    args.output_directory.mkdir(parents=True, exist_ok=True)
    index = {
        "passed": False,
        "job": os.environ["SLURM_JOB_ID"],
        "node": os.uname().nodename,
        "started_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "performance_measurements": False,
        "conditions": [],
    }
    for condition in plan["conditions"]:
        output = args.output_directory / (condition["run_id"] + ".json")
        if output.exists():
            raise RuntimeError(
                "Qualification evidence already exists; preserve the original revision."
            )
        env = os.environ.copy()
        cpus = collect.placement(condition["actual_team"], condition["placement"])
        env.update(
            OMP_NUM_THREADS=str(condition["actual_team"]),
            OMP_DYNAMIC="false",
            OMP_PROC_BIND="close",
            OMP_PLACES=",".join("{" + str(c) + "}" for c in cpus),
            OMP_WAIT_POLICY=condition["wait_policy"],
            GOMP_SPINCOUNT=condition["spin_count"],
            OPENBLAS_NUM_THREADS="1",
            MKL_NUM_THREADS="1",
            NUMEXPR_NUM_THREADS="1",
            JULIA_NUM_THREADS="1",
            JULIA_NUM_GC_THREADS="1",
            JULIA_CPU_TARGET="neoverse-v2",
            JULIA_DEPOT_PATH=str(HERE / "julia/depot"),
        )
        argv = [
            str(collect.PYTHON),
            str(HERE / "campaign.py"),
            condition["model"],
            str(condition["n"]),
            "--verify-only",
            "--output",
            str(output),
        ]
        completed = subprocess.run(
            argv,
            env=env,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            timeout=300,
        )
        log = output.with_suffix(".log")
        log.write_text(completed.stdout + completed.stderr)
        record = {
            "condition": condition["run_id"],
            "returncode": completed.returncode,
            "output": str(output),
            "log": str(log),
        }
        index["conditions"].append(record)
        (args.output_directory / "index.json").write_text(
            json.dumps(index, indent=2) + "\n"
        )
        if completed.returncode:
            raise RuntimeError(("Final team qualification failed", record))
        report = json.loads(output.read_text())
        if (
            not report.get("passed")
            or report.get("development_exception")
            or len(report["preflight"]) != 8
            or report["actual_workers"] != condition["actual_team"]
        ):
            raise RuntimeError(
                ("Final team qualification evidence is incomplete", record)
            )
        record["passed"] = True
        print(
            json.dumps(
                {
                    "passed": True,
                    "model": condition["model"],
                    "n": condition["n"],
                    "actual_workers": condition["actual_team"],
                    "routes": 8,
                }
            ),
            flush=True,
        )
    index.update(
        passed=True,
        finished_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
        zero_differing_bytes=True,
    )
    (args.output_directory / "index.json").write_text(
        json.dumps(index, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()

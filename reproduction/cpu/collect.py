"""Run the frozen eight-route CPU cohort under the common node lock."""

import argparse
import datetime as dt
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
PYTHON = HERE.parents[2] / "python/bin/python"
NODE_LOCK = HERE.parents[1] / "fresh_languages_node.lock"


def write(path, value):
    """Save controller metadata outside the solver timer.

    Parameters
    ----------
    path : pathlib.Path
        Private output file owned by this controller.
    value : dict
        JSON-compatible observations and decisions.

    Returns
    -------
    None
        Replace only this controller's output record.
    """
    path.write_text(json.dumps(value, indent=2) + "\n")


def cpulist(text):
    """Expand the Linux list of granted CPU identifiers.

    Parameters
    ----------
    text : str
        Comma-separated integer identifiers or inclusive ranges.

    Returns
    -------
    list of int
        Expanded identifiers in source order.
    """
    if not text.strip():
        return []
    values = []
    for item in text.strip().split(","):
        ends = list(map(int, item.split("-")))
        values.extend(range(ends[0], ends[-1] + 1))
    return values


def placement(count, mode):
    """Apply the unchanged accepted CPU placement recipe.

    Parameters
    ----------
    count : int
        Number of distinct nonempty owners.
    mode : str
        Compact or balanced placement across memory domains.

    Returns
    -------
    list of int
        CPUs in OpenMP worker order, all within the granted process mask.
    """
    allowed = os.sched_getaffinity(0)
    domains = []
    for node in sorted(Path("/sys/devices/system/node").glob("node[0-9]*")):
        cores = [c for c in cpulist((node / "cpulist").read_text()) if c in allowed]
        if cores:
            domains.append(cores)
    if mode == "compact":
        selected = [c for group in domains for c in group][:count]
    else:
        sizes = [
            count // len(domains) + int(i < count % len(domains))
            for i in range(len(domains))
        ]
        if any(n > len(group) for n, group in zip(sizes, domains)):
            raise RuntimeError("Balanced placement cannot supply the frozen team.")
        selected = [c for n, group in zip(sizes, domains) for c in group[:n]]
    if len(selected) != count or len(set(selected)) != count:
        raise RuntimeError("Placement cannot supply distinct worker CPUs.")
    return selected


def main():
    """Collect six complete workloads, retaining refusals and exact failures."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--deadline", required=True, help="Absolute UTC ISO deadline")
    parser.add_argument("--plan", type=Path, default=HERE / "plan.json")
    parser.add_argument("--condition-timeout", type=int, default=600)
    args = parser.parse_args()
    deadline = dt.datetime.fromisoformat(
        args.deadline.replace("Z", "+00:00")
    ).timestamp()
    if (
        os.environ.get("SLURM_JOB_ID") != "8353767"
        or os.environ.get("ESM_CPU_CAMPAIGN_PHASE") != "cpu"
    ):
        raise RuntimeError(
            "CPU final collection requires the approved exclusive job and phase."
        )
    plan = json.loads(args.plan.read_text())
    if (
        plan["status"] != "FROZEN"
        or plan["complete_steps"] != 1000
        or plan["repeats"] != 12
        or len(plan["route_order"]) != 8
    ):
        raise RuntimeError(
            "The final plan is not frozen as an eight-route twelve-round cohort."
        )
    raw = HERE / "collection"
    raw.mkdir(exist_ok=True)
    if (raw / "result.json").exists():
        raise RuntimeError(
            "This collection already has a result; preserve it before another revision."
        )
    state = {
        "passed": False,
        "job": os.environ["SLURM_JOB_ID"],
        "node": os.uname().nodename,
        "started_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "deadline_utc": args.deadline,
        "plan_sha256": hashlib.sha256(args.plan.read_bytes()).hexdigest(),
        "common_node_lock": str(NODE_LOCK),
        "attempts": [],
    }
    with NODE_LOCK.open("a+") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        lock.seek(0)
        lock.truncate()
        lock.write(
            json.dumps(
                {
                    "owner": "cpu_languages",
                    "pid": os.getpid(),
                    "job": os.environ["SLURM_JOB_ID"],
                    "started_utc": state["started_utc"],
                }
            )
            + "\n"
        )
        lock.flush()
        for condition in plan["conditions"]:
            accepted = False
            for attempt in (1, 2):
                remaining = deadline - time.time()
                if remaining < 180:
                    raise RuntimeError(
                        "Less than three minutes remain before the collection deadline."
                    )
                prefix = raw / (condition["run_id"] + "_attempt" + str(attempt))
                output = prefix.with_suffix(".json")
                if output.exists() or prefix.with_suffix(".log").exists():
                    raise RuntimeError(
                        "Attempt files already exist; a collection cannot overwrite evidence."
                    )
                env = os.environ.copy()
                cpus = placement(condition["actual_team"], condition["placement"])
                env.update(
                    ESM_CPU_LOCK_FD=str(lock.fileno()),
                    ESM_CPU_DEADLINE=args.deadline,
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
                    str(PYTHON),
                    str(HERE / "campaign.py"),
                    condition["model"],
                    str(condition["n"]),
                    "--plan",
                    str(args.plan),
                    "--output",
                    str(output),
                ]
                record = {
                    "condition": condition["run_id"],
                    "attempt": attempt,
                    "argv": argv,
                    "output": str(output),
                    "physical_cpus": cpus,
                    "started_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                }
                state["attempts"].append(record)
                write(raw / "state.json", state)
                with prefix.with_suffix(".log").open("x") as log:
                    child = subprocess.Popen(
                        argv,
                        env=env,
                        stdin=subprocess.DEVNULL,
                        stdout=log,
                        stderr=subprocess.STDOUT,
                        start_new_session=True,
                        pass_fds=(lock.fileno(),),
                    )
                    record["pid"] = child.pid
                    limit = min(args.condition_timeout, remaining - 120)
                    try:
                        status = child.wait(timeout=limit)
                    except BaseException as error:
                        if child.poll() is None:
                            os.killpg(child.pid, signal.SIGTERM)
                            try:
                                child.wait(timeout=10)
                            except subprocess.TimeoutExpired:
                                os.killpg(child.pid, signal.SIGKILL)
                                child.wait(timeout=10)
                        record.update(
                            failure=(
                                "process_timeout"
                                if isinstance(error, subprocess.TimeoutExpired)
                                else "controller_interrupted"
                            ),
                            timeout_seconds=limit,
                            returncode=child.returncode,
                            child_reaped=True,
                            closed_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
                        )
                        write(raw / "state.json", state)
                        if isinstance(error, subprocess.TimeoutExpired):
                            raise RuntimeError(
                                "Condition process timeout is fatal, never a quiet refusal."
                            ) from error
                        raise
                record.update(
                    returncode=status,
                    finished_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
                )
                if status == 0:
                    report = json.loads(output.read_text())
                    if (
                        not report.get("passed")
                        or len(report.get("samples", [])) != 96
                        or not report.get("zero_differing_bytes")
                    ):
                        raise RuntimeError(
                            "Condition exited without complete exact accepted evidence."
                        )
                    counts = {
                        name: sum(
                            row["implementation"] == name for row in report["samples"]
                        )
                        for name in plan["route_order"]
                    }
                    if set(counts.values()) != {12}:
                        raise RuntimeError(
                            "The condition does not contain twelve runs per route."
                        )
                    record["accepted"] = accepted = True
                    break
                text = prefix.with_suffix(".log").read_text()
                last = text.strip().splitlines()[-1] if text.strip() else ""
                quiet = (
                    last.startswith(
                        'RuntimeError: ("Foreign CPU activity disturbed the quiet node",'
                    )
                    or last.startswith(
                        "RuntimeError: ('Foreign CPU activity disturbed the quiet node',"
                    )
                    or last
                    == "RuntimeError: The enclosing adjusted counter residual exceeded one core."
                )
                scheduler = (
                    last.startswith("subprocess.TimeoutExpired:")
                    and "scontrol" in last
                    and "timed out after 10 seconds" in last
                    and "in verify_allocation" in text
                    and not output.exists()
                )
                record["classification"] = (
                    "quiet_refusal"
                    if quiet
                    else (
                        "scheduler_admission_timeout"
                        if scheduler
                        else "fatal_unknown_or_numerical"
                    )
                )
                write(raw / "state.json", state)
                if record["classification"] == "fatal_unknown_or_numerical":
                    raise RuntimeError(("Fatal condition failure", record))
            if not accepted:
                state["incomplete_condition"] = condition["run_id"]
                write(raw / "result.json", state)
                raise RuntimeError(
                    "The condition exhausted its two predeclared admission attempts."
                )
        state.update(
            passed=True, finished_utc=dt.datetime.now(dt.timezone.utc).isoformat()
        )
        write(raw / "result.json", state)
        print(
            json.dumps(
                {
                    "passed": True,
                    "conditions": 6,
                    "routes": 8,
                    "accepted_elapsed_time_words": 576,
                }
            ),
            flush=True,
        )


if __name__ == "__main__":
    try:
        main()
    except BaseException as error:
        state_path = HERE / "collection/state.json"
        terminal = json.loads(state_path.read_text()) if state_path.exists() else {}
        terminal.update(
            passed=False,
            terminal_status="FAILED",
            failure_type=type(error).__name__,
            failure=str(error),
            finished_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
        )
        (HERE / "collection").mkdir(exist_ok=True)
        write(HERE / "collection/terminal.json", terminal)
        raise
    else:
        terminal = json.loads((HERE / "collection/result.json").read_text())
        terminal["terminal_status"] = "COMPLETE"
        write(HERE / "collection/terminal.json", terminal)

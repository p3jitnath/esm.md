"""Observe non-owned process CPU time without subtracting mixed node clocks.

This is an empirical admission guard. The caller places the first complete
snapshot before its existing before-quiet window, and the second after its
existing after-quiet window. ``elapsed_ns`` is the unchanged inner enclosing
interval. Thus process reads cover that interval and some additional time.

The Linux 6.4 process reader uses adjusted thread-group CPU time and exports
user and system values in USER_HZ units. See fs/proc/array.c:503-558 and
kernel/sched/cputime.c:285-326,589-611 in the v6.4 kernel source. A thread group
is counted once, including accumulated CPU time from its exited threads.

The global /proc/stat processes value is total_forks. copy_process increments
it for successful task creation, including new threads. See
https://github.com/torvalds/linux/blob/v6.4/kernel/fork.c#L2505-L2558 and
https://github.com/torvalds/linux/blob/v6.4/fs/proc/stat.c#L161-L171 . Requiring
unchanged fork counts and identities detects observable lifecycle changes,
including a task created and removed between the two PID censuses. These
unlocked observations are not an atomic whole-node certificate.

Text conversion and scan spans are recorded without reducing the observed
activity. Pending scheduler updates remain unbounded. Interrupt, softirq and
steal counters are included conservatively; any overlap can cause refusal.
The existing quiet-window checks remain a separate caller requirement.
"""

import os
from pathlib import Path
import time

LIMIT_CORES = 1.0
SCHEMA_VERSION = 1
PROC = Path("/proc")


class ObservationRefusal(RuntimeError):
    """Identify a qualified observation, lifecycle or activity refusal.

    Parameters
    ----------
    reason : str
        Stable reason beginning with data_quality, lifecycle or activity.
    metadata : dict
        Raw observations and the applicable admission result.

    Attributes
    ----------
    reason : str
        Stable reason available to a bounded refusal classifier.
    metadata : dict
        Evidence retained without discarding failed observations.
    classification : str
        Always ``observation_refusal``. Unrelated exceptions are not converted.
    """

    classification = "observation_refusal"

    def __init__(self, reason, metadata):
        self.reason = reason
        self.metadata = metadata
        super().__init__(reason)


def _refuse(reason, **metadata):
    """Raise a qualified refusal with explicit evidence.

    Parameters
    ----------
    reason : str
        Data-quality, lifecycle or activity reason.
    **metadata : object
        Named evidence retained for the caller.

    Raises
    ------
    ObservationRefusal
        Always; no numerical state is changed.
    """
    metadata.update(
        passed=False,
        admitted=False,
        classification="observation_refusal",
        reason=reason,
    )
    raise ObservationRefusal(reason, metadata)


def _parse_pid_stat(text, expected_pid):
    """Read whole-thread-group CPU words from one Linux process stat record.

    Parameters
    ----------
    text : str
        Complete /proc/PID/stat text, whose command can contain parentheses.
    expected_pid : int
        Positive directory PID to match with the record.

    Returns
    -------
    dict
        PID, starttime_ticks, utime_ticks, stime_ticks and thread count. Times
        are nonnegative USER_HZ units; start time identifies the task lifetime.

    Raises
    ------
    ObservationRefusal
        If the observed record is malformed or identifies another process.
    """
    left, right = text.find(" ("), text.rfind(")")
    if left < 1 or right < left + 2:
        _refuse("data_quality.malformed_pid_stat", pid=expected_pid)
    words = text[right + 1 :].split()
    try:
        if len(words) < 20:
            raise ValueError("Short process record")
        values = dict(
            pid=int(text[:left]),
            starttime_ticks=int(words[19]),
            utime_ticks=int(words[11]),
            stime_ticks=int(words[12]),
            threads=int(words[17]),
        )
    except ValueError as error:
        _refuse("data_quality.malformed_pid_stat", pid=expected_pid, detail=str(error))
    if values["pid"] != expected_pid or expected_pid <= 0:
        _refuse("data_quality.pid_identity", expected=expected_pid, observed=values)
    if (
        any(
            values[key] < 0 for key in ("starttime_ticks", "utime_ticks", "stime_ticks")
        )
        or values["threads"] < 1
    ):
        _refuse("data_quality.negative_pid_counts", observed=values)
    return values


def _parse_node_stat(text):
    """Read fork and interrupt counters without a node user-time subtraction.

    Parameters
    ----------
    text : str
        Complete /proc/stat text from one read.

    Returns
    -------
    dict
        Global forks plus aggregate irq_ticks, softirq_ticks and steal_ticks.
        CPU counter units are USER_HZ; forks is a cumulative task count.

    Raises
    ------
    ObservationRefusal
        If required observed fields are absent, malformed or negative.
    """
    rows = text.splitlines()
    cpu = [row.split()[1:] for row in rows if row.startswith("cpu ")]
    forks = [row.split()[1:] for row in rows if row.startswith("processes ")]
    try:
        if len(cpu) != 1 or len(cpu[0]) < 8 or len(forks) != 1 or len(forks[0]) != 1:
            raise ValueError("Missing or repeated node counters")
        result = dict(
            forks=int(forks[0][0]),
            irq_ticks=int(cpu[0][5]),
            softirq_ticks=int(cpu[0][6]),
            steal_ticks=int(cpu[0][7]),
        )
    except ValueError as error:
        _refuse("data_quality.malformed_node_stat", detail=str(error))
    if any(value < 0 for value in result.values()):
        _refuse("data_quality.negative_node_counts", observed=result)
    return result


def _node_snapshot():
    """Read required node counters within a monotonic time bracket.

    Returns
    -------
    dict
        Parsed node counters and read_ns start/end nanoseconds.

    Raises
    ------
    ObservationRefusal
        If the procfs file cannot be read or its required fields are invalid.
    """
    started = time.monotonic_ns()
    try:
        text = (PROC / "stat").read_text(encoding="ascii")
    except (OSError, UnicodeError) as error:
        _refuse("data_quality.node_read", detail=str(error))
    finished = time.monotonic_ns()
    result = _parse_node_stat(text)
    result["read_ns"] = [started, finished]
    return result


def snapshot():
    """Read every visible process group with fork counters around the census.

    Returns
    -------
    dict
        Schema1 raw process records, their read brackets, census brackets,
        node_before/node_after counters, USER_HZ and the node CPU count.
        This function launches no subprocess or numerical work.

    Raises
    ------
    ObservationRefusal
        If any listed process cannot be read, any required field is invalid,
        or the global fork counter changes during this census.

    Notes
    -----
    Numeric top-level /proc directories identify thread groups. Each stat read
    includes all their live threads and retained exited-thread CPU time. No
    permission or disappearance error is ignored. The calling namespace must
    expose all node processes for the intended whole-node empirical scope.
    """
    started = time.monotonic_ns()
    first = _node_snapshot()
    census_started = time.monotonic_ns()
    try:
        pids = sorted(
            int(item.name) for item in PROC.iterdir() if item.name.isdecimal()
        )
    except OSError as error:
        _refuse("data_quality.pid_enumeration", detail=str(error), node_before=first)
    records = []
    for pid in pids:
        read_started = time.monotonic_ns()
        try:
            text = (PROC / str(pid) / "stat").read_text(
                encoding="utf-8", errors="surrogateescape"
            )
        except OSError as error:
            _refuse(
                "data_quality.pid_read",
                pid=pid,
                detail=str(error),
                node_before=first,
                completed_processes=records,
            )
        read_finished = time.monotonic_ns()
        row = _parse_pid_stat(text, pid)
        row["read_ns"] = [read_started, read_finished]
        records.append(row)
    census_finished = time.monotonic_ns()
    last = _node_snapshot()
    result = dict(
        schema_version=SCHEMA_VERSION,
        started_ns=started,
        finished_ns=time.monotonic_ns(),
        census_read_ns=[census_started, census_finished],
        user_hz=os.sysconf("SC_CLK_TCK"),
        node_cpus=os.cpu_count(),
        processes=records,
        node_before=first,
        node_after=last,
    )
    if first["forks"] != last["forks"]:
        _refuse("lifecycle.forks_during_census", snapshot=result)
    return result


def _index(observation):
    """Check and index raw metadata by process ID without changing it.

    Parameters
    ----------
    observation : dict
        A complete Schema1 snapshot.

    Returns
    -------
    dict
        PID-to-record index for unique nonnegative observed process records.

    Raises
    ------
    ObservationRefusal
        If known record, counter or time-bracket requirements fail.
    """
    if (
        observation["schema_version"] != SCHEMA_VERSION
        or observation["user_hz"] <= 0
        or observation["node_cpus"] < 1
    ):
        _refuse("data_quality.snapshot_header", snapshot=observation)
    start, finish = observation["started_ns"], observation["finished_ns"]
    cstart, cfinish = observation["census_read_ns"]
    if not start <= cstart <= cfinish <= finish:
        _refuse("data_quality.census_bracket", snapshot=observation)
    result = {}
    for row in observation["processes"]:
        pid = row["pid"]
        if (
            pid <= 0
            or pid in result
            or any(
                row[key] < 0
                for key in ("starttime_ticks", "utime_ticks", "stime_ticks")
            )
            or row["threads"] < 1
        ):
            _refuse("data_quality.pid_record", observed=row)
        if not cstart <= row["read_ns"][0] <= row["read_ns"][1] <= cfinish:
            _refuse("data_quality.pid_read_bracket", observed=row)
        result[pid] = row
    if not result:
        _refuse("data_quality.empty_census", snapshot=observation)
    if (
        not observation["node_before"]["read_ns"][1] <= cstart
        or not cfinish <= observation["node_after"]["read_ns"][0]
    ):
        _refuse("data_quality.node_census_order", snapshot=observation)
    for node in (observation["node_before"], observation["node_after"]):
        if any(
            node[key] < 0
            for key in ("forks", "irq_ticks", "softirq_ticks", "steal_ticks")
        ):
            _refuse("data_quality.node_counts", observed=node)
        if not start <= node["read_ns"][0] <= node["read_ns"][1] <= finish:
            _refuse("data_quality.node_read_bracket", observed=node)
    return result


def summarize(before, after, elapsed_ns, owned_identity):
    """Apply the unchanged one-core threshold to directly observed foreign work.

    Parameters
    ----------
    before, after : dict
        Snapshots entirely outside the old enclosing quiet interval.
    elapsed_ns : int
        Positive wall nanoseconds of that unchanged inner enclosing interval.
        The caller guarantees that all before reads precede its start and all
        after reads follow its end. The solver timer remains unchanged.
    owned_identity : dict
        Exactly one benchmark thread group, with positive integer ``pid`` and
        nonnegative ``starttime_ticks``. All its threads share this group.
        Every other identity, including helpers with the same UID, is foreign.

    Returns
    -------
    dict
        Passed admission, raw observations, per-group deltas and read spans,
        conservative extra interrupt time, export/read-span diagnostics and
        explicit empirical limits. Only nonzero foreign rows are returned. The
        caller retains the full input snapshots separately. Uncertainty is
        never subtracted.

    Raises
    ------
    ObservationRefusal
        For known observation, lifecycle or observed activity failures.
    ValueError
        If elapsed_ns or the caller-owned identity is invalid.

    Notes
    -----
    Whole groups must persist with identical PID/start identities. All four
    bracketing fork counters must match. Unknown programmer errors propagate.
    The raw threshold is exactly one CPU-second per wall second; its finite
    export units and pending updates prevent a rigorous quietness guarantee.
    """
    if not isinstance(elapsed_ns, int) or elapsed_ns <= 0:
        raise ValueError("elapsed_ns must be positive integer nanoseconds")
    owner_pid = owned_identity["pid"]
    owner_start = owned_identity["starttime_ticks"]
    if (
        not isinstance(owner_pid, int)
        or owner_pid <= 0
        or not isinstance(owner_start, int)
        or owner_start < 0
    ):
        raise ValueError("The owned PID/start identity is invalid")
    left, right = _index(before), _index(after)
    raw = dict(
        before=before,
        after=after,
        elapsed_ns=elapsed_ns,
        owned_identity=dict(pid=owner_pid, starttime_ticks=owner_start),
    )
    if (
        before["user_hz"] != after["user_hz"]
        or before["node_cpus"] != after["node_cpus"]
    ):
        _refuse("data_quality.clock_or_cpu_count", **raw)
    if after["started_ns"] - before["finished_ns"] < elapsed_ns:
        _refuse("data_quality.inner_interval_bracketing", **raw)
    forks = [
        node["forks"]
        for item in (before, after)
        for node in (item["node_before"], item["node_after"])
    ]
    if len(set(forks)) != 1:
        _refuse("lifecycle.global_fork_count_changed", fork_counts=forks, **raw)
    identities_left = {(pid, row["starttime_ticks"]) for pid, row in left.items()}
    identities_right = {(pid, row["starttime_ticks"]) for pid, row in right.items()}
    if identities_left != identities_right:
        _refuse(
            "lifecycle.pid_start_set_changed",
            removed=sorted(identities_left - identities_right),
            added=sorted(identities_right - identities_left),
            **raw,
        )
    if (owner_pid, owner_start) not in identities_left:
        _refuse("lifecycle.owned_identity_absent", **raw)
    hz = before["user_hz"]
    foreign = []
    owned = None
    for pid, first in left.items():
        last = right[pid]
        du = last["utime_ticks"] - first["utime_ticks"]
        ds = last["stime_ticks"] - first["stime_ticks"]
        if du < 0 or ds < 0:
            _refuse("data_quality.process_counter_decreased", pid=pid, **raw)
        row = dict(
            pid=pid,
            starttime_ticks=first["starttime_ticks"],
            utime_delta_ticks=du,
            stime_delta_ticks=ds,
            cpu_seconds=(du + ds) / hz,
            before_read_ns=first["read_ns"],
            after_read_ns=last["read_ns"],
            observation_span_ns=last["read_ns"][1] - first["read_ns"][0],
            overcoverage_ns_upper=last["read_ns"][1] - first["read_ns"][0] - elapsed_ns,
        )
        if pid == owner_pid:
            owned = row
        else:
            foreign.append(row)
    extra = {}
    nodes = [
        item[key] for item in (before, after) for key in ("node_before", "node_after")
    ]
    for key in ("irq_ticks", "softirq_ticks", "steal_ticks"):
        if any(
            right_node[key] < left_node[key]
            for left_node, right_node in zip(nodes, nodes[1:])
        ):
            _refuse("data_quality.extra_counter_decreased", field=key, **raw)
        extra[key] = after["node_after"][key] - before["node_before"][key]
    foreign_ticks = sum(
        row["utime_delta_ticks"] + row["stime_delta_ticks"] for row in foreign
    )
    extra_ticks = sum(extra.values())
    total_ticks = foreign_ticks + extra_ticks
    scan_ns = sum(
        item["census_read_ns"][1] - item["census_read_ns"][0]
        for item in (before, after)
    )
    result = dict(
        passed=True,
        admitted=True,
        classification="admitted",
        threshold_cores=LIMIT_CORES,
        elapsed_ns=elapsed_ns,
        owned_identity=raw["owned_identity"],
        owned_diagnostic=owned,
        foreign_processes=[
            row
            for row in foreign
            if row["utime_delta_ticks"] + row["stime_delta_ticks"] > 0
        ],
        foreign_group_count=len(foreign),
        foreign_nonzero_group_count=sum(
            row["utime_delta_ticks"] + row["stime_delta_ticks"] > 0 for row in foreign
        ),
        foreign_cpu_seconds=foreign_ticks / hz,
        extra_interrupt_delta_ticks=extra,
        extra_interrupt_cpu_seconds=extra_ticks / hz,
        observed_total_cpu_seconds=total_ticks / hz,
        observed_total_cores=total_ticks * 1e9 / (hz * elapsed_ns),
        fork_counts=forks,
        user_hz=hz,
        foreign_export_delta_error_seconds_lt=2 * len(foreign) / hz,
        extra_export_delta_error_seconds_lt=3 / hz,
        combined_export_delta_error_seconds_lt=(2 * len(foreign) + 3) / hz,
        census_read_span_ns=scan_ns,
        continuous_runtime_scan_span_cpu_seconds_upper=before["node_cpus"]
        * scan_ns
        / 1e9,
        outer_overcoverage_ns_upper=after["finished_ns"]
        - before["started_ns"]
        - elapsed_ns,
        uncertainty_subtracted=False,
        pending_update_bound=None,
        scope="Empirical direct visible non-owned TGID CPU deltas, plus conservatively added raw IRQ/softirq/steal. Export conversion and scan spans are diagnostics; delayed scheduler accounting is not bounded. Stable identities and global fork counts are unlocked observations. The caller separately requires unchanged idle quiet checks and complete node visibility. No rigorous absence-of-disturbance claim follows.",
        snapshot_brackets_ns=[
            [item["started_ns"], item["finished_ns"]] for item in (before, after)
        ],
        snapshot_census_read_ns=[item["census_read_ns"] for item in (before, after)],
        node_counter_reads=nodes,
    )
    if total_ticks * 1_000_000_000 > hz * elapsed_ns:
        _refuse("activity.observed_foreign_and_interrupts_above_one_core", **result)
    return result

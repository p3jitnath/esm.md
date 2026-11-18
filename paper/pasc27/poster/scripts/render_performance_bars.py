"""Render matched CPU and GPU useful-update rates from accepted raw timings."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import statistics

ROOT = Path(__file__).resolve().parent.parent
POSTER = ROOT
LOCAL = ROOT / "scripts"
ARCHIVE = ROOT / "data/archive"
ESM_BLUE = "#0072B2"
BASELINE_ORANGE = "#D55E00"
REPEATS = 12


def load_style(font_family: str | None = None, font_file: Path | None = None):
    """Load the sibling publication helper and an optional explicit font file.

    Parameters
    ----------
    font_family : str or None
        Declared family for a supplied font file.
    font_file : pathlib.Path or None
        Optional runtime file. It is registered but never copied into the bundle.

    Returns
    -------
    module
        Local publication style, audit and export functions.
    """
    spec = importlib.util.spec_from_file_location(
        "publication_plot_style", LOCAL / "publication_plot_style.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    if font_file is not None:
        if font_family is None:
            raise ValueError("Declare the family of the supplied font file.")
        module.configure_font_file(font_family, font_file)
    return module


def positive(value: float) -> float:
    """Return a finite positive recorded value or reject the observation."""
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise ValueError("Recorded times and rates must be finite and positive.")
    return number


def summary(values: list[float]) -> dict:
    """Summarise twelve recorded values with their median and observed range."""
    if len(values) != REPEATS:
        raise ValueError("A condition must contain twelve recorded observations.")
    numbers = [positive(value) for value in values]
    return {
        "median": statistics.median(numbers),
        "minimum": min(numbers),
        "maximum": max(numbers),
        "count": len(numbers),
    }


def summarise_pair(record: dict, historical: bool) -> dict:
    """Calculate throughput and paired ranges from one accepted condition.

    Parameters
    ----------
    record : dict
        Single-domain workload, placement, source identities and twelve paired times in seconds.
    historical : bool
        Whether the input is an explicitly labelled historical inspection draft.

    Returns
    -------
    dict
        Useful-update rate points, raw-rate ranges and time and throughput summaries.

    Raises
    ------
    ValueError
        If timing, placement, pair counts or recorded acceptance flags are incomplete.

    Notes
    -----
    Metadata checks do not independently establish scientific acceptance. That evidence belongs to the numerical campaign.
    """
    if record["model"] not in ("sw", "ebm") or record["platform"] not in ("cpu", "gpu"):
        raise ValueError("Unknown model or platform.")
    expected_dimensions = 2 if record["model"] == "sw" else 1
    if len(record["shape"]) != expected_dimensions or any(
        type(n) is not int or n < 1 for n in record["shape"]
    ):
        raise ValueError("The shape must describe the actual positive interior grid.")
    if (
        type(record["cpu_cores"]) is not int
        or record["cpu_cores"] < 1
        or type(record["gpu_devices"]) is not int
        or record["gpu_devices"] != int(record["platform"] == "gpu")
    ):
        raise ValueError("Record the real processor placement.")
    if type(record["batch_steps"]) is not int or record["batch_steps"] < 1:
        raise ValueError("A timed batch must contain complete steps.")
    if not historical:
        flags = record["qualification"]
        required = [
            "independent_physics_passed",
            "exact_outputs_equal",
            "timed_final_state_checked",
            "exclusive_node",
            "quiet_samples",
        ]
        if not all(flags.get(name) is True for name in required):
            raise ValueError(
                "Only accepted quiet-node comparisons may reach a final figure."
            )
        for name in (
            "campaign_id",
            "job_id",
            "node",
            "timer_scope",
            "affinity",
            "memory_policy",
            "source_revisions",
            "input_identity",
            "acceptance_record",
        ):
            if not record.get(name):
                raise ValueError(f"Missing campaign field {name}.")
    if not historical:
        revisions = record["source_revisions"]
        if not isinstance(revisions, dict) or not all(
            revisions.get(key) for key in ("baseline", "esm_md")
        ):
            raise ValueError("Both measured source revisions must be identified.")
    pairs = record["paired_samples"]
    if (
        len(pairs) != REPEATS
        or any(type(pair["repeat"]) is not int for pair in pairs)
        or {pair["repeat"] for pair in pairs} != set(range(REPEATS))
    ):
        raise ValueError("All twelve distinct matched pairs must be present.")
    updates = math.prod(record["shape"]) * record["batch_steps"]
    baseline_times = [positive(pair["baseline_seconds"]) for pair in pairs]
    esm_times = [positive(pair["esm_md_seconds"]) for pair in pairs]
    baseline = [updates / value / 1e6 for value in baseline_times]
    esm = [updates / value / 1e6 for value in esm_times]
    base_time_stats, esm_time_stats = summary(baseline_times), summary(esm_times)
    base_stats, esm_stats = summary(baseline), summary(esm)
    base_stats["point"] = updates / base_time_stats["median"] / 1e6
    esm_stats["point"] = updates / esm_time_stats["median"] / 1e6
    paired_ratios = [new / old for new, old in zip(esm, baseline)]
    throughput = {
        "point": esm_stats["median"] / base_stats["median"],
        "minimum": min(paired_ratios),
        "maximum": max(paired_ratios),
        "paired_median": statistics.median(paired_ratios),
        "count": REPEATS,
    }
    paired_time_ratios = [new / old for new, old in zip(esm_times, baseline_times)]
    time = {
        "point": esm_time_stats["median"] / base_time_stats["median"],
        "minimum": min(paired_time_ratios),
        "maximum": max(paired_time_ratios),
        "paired_median": statistics.median(paired_time_ratios),
        "count": REPEATS,
    }
    point_ratio = dict(throughput)
    point_ratio["point"] = esm_stats["point"] / base_stats["point"]
    return {
        "rate_point_definition": "useful interior-cell updates divided by median elapsed seconds",
        "throughput_unit": "million complete cell updates per second",
        "time_unit": "s",
        "baseline": base_stats,
        "esm_md": esm_stats,
        "ratio": point_ratio,
        "throughput_ratio": point_ratio,
        "median_rate_ratio": throughput,
        "time_ratio": time,
        "baseline_seconds": base_time_stats,
        "esm_md_seconds": esm_time_stats,
    }


def workload_label(model: str, shape: list[int]) -> str:
    """Describe an actual grid without changing its dimensions."""
    if model == "sw":
        return (
            f"{shape[0]:,}²" if shape[0] == shape[1] else f"{shape[0]:,}×{shape[1]:,}"
        )
    return f"{shape[0]:,}"


def validate_cpu_configuration(
    record: dict, *, expected_series_kind: str | None = None, status: str = "accepted"
) -> dict | None:
    """Check CPU series identity, actual teams and separate ownership counts.

    Parameters
    ----------
    record : dict
        Recorded placement metadata. GPU records have no new CPU requirements.
    expected_series_kind : {'primary', 'fixed_scaling'} or None
        Required CPU series for the consumer.
    status : str
        Document status. Only explicit historical diagnostics bypass these new fields.

    Returns
    -------
    dict or None
        CPU policy summary, or None for GPU records and historical diagnostics.

    Raises
    ------
    ValueError
        If series identity, counts or the exact fixed-team rule is inconsistent.
    """
    if record.get("platform") != "cpu":
        return None
    if status == "historical":
        return None
    if status != "accepted":
        raise ValueError(
            "CPU configuration checks require accepted or explicit historical status."
        )
    kind = record.get("series_kind")
    if kind not in ("primary", "fixed_scaling"):
        raise ValueError(
            "CPU records must declare primary or fixed_scaling series_kind."
        )
    if expected_series_kind is not None and kind != expected_series_kind:
        raise ValueError(
            "CPU series_kind must be " + expected_series_kind + " for this consumer."
        )
    run_id = record.get("run_id")
    if not isinstance(run_id, str) or not run_id.strip():
        raise ValueError("Each CPU condition needs a nonempty run_id.")
    budget = record.get("cpu_cores")
    if type(budget) is not int or budget < 1:
        raise ValueError(
            "The configured CPU ceiling or budget must be a positive integer."
        )
    model = record.get("model")
    shape = record.get("shape")
    if (
        model not in ("sw", "ebm")
        or not isinstance(shape, list)
        or len(shape) != (2 if model == "sw" else 1)
        or any(type(value) is not int or value < 1 for value in shape)
    ):
        raise ValueError(
            "CPU metadata needs the supported positive interior-grid shape."
        )
    teams = record.get("active_workers")
    owners = record.get("nonempty_spatial_owners_by_route")
    if not isinstance(teams, dict) or not isinstance(owners, dict):
        raise ValueError(
            "CPU teams and nonempty owners must be separate per-route maps."
        )
    supported_team = budget if model == "sw" else min(budget, shape[0])
    for route in ("baseline", "esm_md"):
        team, owned = teams.get(route), owners.get(route)
        if type(team) is not int or team < 1 or team > supported_team:
            raise ValueError(
                "The actual CPU team exceeds its ceiling or supported grid bound."
            )
        if type(owned) is not int or owned < 1 or owned > min(team, math.prod(shape)):
            raise ValueError(
                "Nonempty spatial owners must be positive and cannot exceed the actual team or cell count."
            )
        if kind == "fixed_scaling" and team != supported_team:
            raise ValueError(
                "Fixed scaling requires the budget-sized SW team or the exact min(budget,bands) EBM team."
            )
    return {
        "series_kind": kind,
        "run_id": run_id,
        "cpu_cores": budget,
        "active_workers": dict(teams),
        "nonempty_spatial_owners_by_route": dict(owners),
        "shared_worker_team": teams["baseline"] == teams["esm_md"],
        "fixed_ebm_cap_applied": kind == "fixed_scaling"
        and model == "ebm"
        and budget > shape[0],
    }


def audit_selected_records(
    document: dict,
    records: list[dict],
    *,
    expected_steps: int | None = None,
    expected_series_kind: str | None = None,
) -> dict:
    """Check accepted record metadata without fonts, figures or scientific reruns.

    Parameters
    ----------
    document : dict
        Current accepted input document.
    records : list of dict
        Relevant conditions already chosen by a selector.
    expected_steps : int or None
        Required complete step count when supplied.
    expected_series_kind : {'primary', 'fixed_scaling'} or None
        Required CPU series. GPU requirements remain unchanged.

    Returns
    -------
    dict
        A metadata-consistency report that makes no scientific-verification claim.
    """
    if document.get("schema_version") != 1 or document.get("status") != "accepted":
        raise ValueError("Audit-only requires a current accepted input file.")
    if expected_steps is not None and (
        type(expected_steps) is not int or expected_steps < 1
    ):
        raise ValueError("Expected steps must be a positive integer.")
    if not records:
        raise ValueError("The metadata audit needs at least one selected condition.")
    cpu_identities = set()
    for record in document.get("paired_records", records):
        policy = validate_cpu_configuration(record, status="accepted")
        if policy is None:
            continue
        identity = (policy["series_kind"], policy["run_id"])
        if identity in cpu_identities:
            raise ValueError(
                "CPU conditions must have unique (series_kind, run_id) identities across the input."
            )
        cpu_identities.add(identity)
    conditions = []
    for record in records:
        policy = validate_cpu_configuration(
            record, expected_series_kind=expected_series_kind, status="accepted"
        )
        statistics = summarise_pair(record, False)
        if expected_steps is not None and record["batch_steps"] != expected_steps:
            raise ValueError(
                "A selected condition differs from the requested complete step count."
            )
        item = {
            key: record[key]
            for key in (
                "model",
                "platform",
                "shape",
                "cpu_cores",
                "gpu_devices",
                "batch_steps",
            )
        }
        item["paired_samples"] = statistics["baseline"]["count"]
        if policy is not None:
            item.update(policy)
        conditions.append(item)
    return {
        "audit_kind": "recorded_metadata_consistency",
        "consistent": True,
        "scientific_verification_performed": False,
        "scope": "Recorded qualification flags, evidence identifiers, placement metadata and twelve timing pairs were checked. Physical verification and timing were not performed.",
        "expected_steps": expected_steps,
        "condition_count": len(conditions),
        "cpu_series_kinds": sorted(
            {row["series_kind"] for row in conditions if row["platform"] == "cpu"}
        ),
        "run_ids": [row["run_id"] for row in conditions if "run_id" in row],
        "conditions": conditions,
    }


def select_pairs(document: dict, model: str, cpu_cores: int | None) -> list[dict]:
    """Select declared workloads without borrowing a one-core result from another campaign."""
    records = [r for r in document["paired_records"] if r["model"] == model]
    for record in records:
        validate_cpu_configuration(
            record, expected_series_kind="primary", status=document.get("status")
        )
    cores = {r["cpu_cores"] for r in records if r["platform"] == "cpu"}
    if cpu_cores is None:
        if len(cores) != 1:
            raise ValueError(
                "Select a CPU core count explicitly when several were measured."
            )
        cpu_cores = next(iter(cores))
    selected = [
        r for r in records if r["platform"] == "gpu" or r["cpu_cores"] == cpu_cores
    ]
    for platform in ("cpu", "gpu"):
        matching = [r for r in selected if r["platform"] == platform]
        if len(matching) != 3:
            raise ValueError(
                "The matched panel requires three actual workloads on each platform."
            )
        if len({tuple(r["shape"]) for r in matching}) != 3:
            raise ValueError(
                "A duplicate workload must not replace a missing condition."
            )
    return sorted(
        selected, key=lambda r: (r["platform"] == "gpu", math.prod(r["shape"]))
    )


def historical_input() -> dict:
    """Adapt accepted November matched samples for clearly labelled local inspection."""
    source = ARCHIVE / "accepted_matches_20261108.json"
    raw = json.loads(source.read_text())
    if not raw["all_output_bytes_identical"] or raw["repetitions"] != REPEATS:
        raise ValueError("Historical matched records are not accepted.")
    records = []
    for platform in ("cpu", "gpu"):
        for model in ("sw", "ebm"):
            origin = raw["sources"][platform + "_" + model]
            for row in raw["models"][platform][model]:
                shape = [row["size"], row["size"]] if model == "sw" else [row["size"]]
                record = {
                    "model": model,
                    "platform": platform,
                    "shape": shape,
                    "batch_steps": row["steps"],
                    "cpu_cores": 1,
                    "gpu_devices": int(platform == "gpu"),
                    "campaign_id": "historical-20261108",
                    "node": origin["node"],
                    "job_id": origin["job"],
                    "timer_scope": origin["timer"],
                    "acceptance_record": origin["source_record"],
                    "paired_samples": [
                        {
                            "repeat": sample["repeat"],
                            "baseline_seconds": sample["assembly_seconds"],
                            "esm_md_seconds": sample["fortran_seconds"],
                        }
                        for sample in row["paired_samples"]
                    ],
                }
                actual = summarise_pair(record, True)
                if not math.isclose(
                    actual["median_rate_ratio"]["point"],
                    row["ratio"]["point"],
                    rel_tol=1e-12,
                ):
                    raise ValueError("Historical pairing changed during adaptation.")
                records.append(record)
    return {
        "schema_version": 1,
        "status": "historical",
        "disclosure": "Historical inspection only, no new multicore or GPU measurement.",
        "paired_records": records,
        "source_record": str(source.relative_to(ROOT)),
    }


def caption_definition(document: dict, model: str, cpu_cores: int | None) -> str:
    """Define the displayed rates, timing ranges and actual processor placement.

    Parameters
    ----------
    document : dict
        Matched raw times and their recorded placement and acceptance evidence.
    model : {'sw', 'ebm'}
        Physical model shown in the six facets.
    cpu_cores : int or None
        Configured physical-core budget, selected explicitly when several exist.

    Returns
    -------
    str
        Caption text for the manuscript or the native poster notes.
    """
    selected = select_pairs(document, model, cpu_cores)
    cores = selected[0]["cpu_cores"]
    placement = (
        "one physical CPU core"
        if cores == 1
        else f"a ceiling of {cores:,} physical CPU cores"
    )
    sentences = [
        f"The top row uses {placement}, and the bottom row uses one GPU device. Each column identifies the same interior grid on the two platforms.",
        "Orange bars show the hand-tuned baseline and blue bars show ESM.md. Each point equals useful updates divided by median elapsed seconds from twelve matched runs. Useful updates are the interior-cell count multiplied by the total number of complete steps.",
        "Thin lines span the observed minimum and maximum individual rates for each implementation, rather than confidence intervals. Each facet has its own zero-based linear rate axis, with a common stated unit.",
        "Required boundary, overlap, gathering and coordination work remains inside the recorded solver time. Redundant tile work does not add to useful updates. Active worker counts are retained separately from the configured CPU budget. Unrounded rates, all twelve raw timing pairs and the exact timer scope remain in the data.",
    ]
    if document["status"] == "accepted":
        cpu = [row for row in selected if row["platform"] == "cpu"]
        if all(
            row["active_workers"]["baseline"] == row["active_workers"]["esm_md"]
            for row in cpu
        ):
            sentences.append(
                "Within each grid, both routes use the same selected actual worker team. Team sizes and nonempty spatial owners are recorded separately from the ceiling."
            )
        else:
            sentences.append(
                "Actual per-route worker teams and nonempty spatial owners are retained separately from the ceiling."
            )
    if document["status"] == "historical":
        sentences.append(
            "This historical stand-in contains genuine one-core matched CPU observations and no new GPU or multicore result."
        )
    return " ".join(sentences)


def render(
    document: dict,
    model: str,
    output: Path,
    profile: str,
    cpu_cores: int | None,
    style,
    rate_unit: str = "auto",
    font_family: str | None = None,
) -> dict:
    """Draw accepted matched rates and retain their full scientific metadata.

    Parameters
    ----------
    document : dict
        Accepted CPU and GPU conditions, or explicitly historical matched records.
    model : {'sw', 'ebm'}
        Model with three matching interior grids per platform.
    output : pathlib.Path
        Local output prefix for PDF, PNG, SVG and the evidence JSON.
    profile : {'paper', 'poster'}
        Final-size typography and established publication box.
    cpu_cores : int or None
        Selected configured physical-core budget.
    style : module
        Refreshed graph-plotting helper.
    rate_unit : {'auto', 'million', 'billion'}
        Common absolute-rate unit used by all six independent linear axes.
    font_family : str or None
        Explicit family override. Omission preserves the paper or poster profile.

    Returns
    -------
    dict
        Plot receipt, rates, raw times, actual coverage and provenance.
    """
    import matplotlib

    matplotlib.use("Agg")
    from direct_rate_layout import draw_rate_panels

    if document.get("schema_version") != 1 or document.get("status") not in (
        "accepted",
        "historical",
    ):
        raise ValueError("Use accepted records or an explicitly historical stand-in.")
    records = select_pairs(document, model, cpu_cores)
    conditions = [
        {
            **record,
            "statistics": summarise_pair(record, document["status"] == "historical"),
        }
        for record in records
    ]
    by_platform = {
        platform: [
            condition for condition in conditions if condition["platform"] == platform
        ]
        for platform in ("cpu", "gpu")
    }
    if {tuple(row["shape"]) for row in by_platform["cpu"]} != {
        tuple(row["shape"]) for row in by_platform["gpu"]
    }:
        raise ValueError("The CPU and GPU facets must identify the same three grids.")
    geometry = draw_rate_panels(
        conditions,
        model,
        output,
        profile,
        style,
        ROOT,
        ESM_BLUE,
        BASELINE_ORANGE,
        workload_label,
        historical=document["status"] == "historical",
        rate_unit=rate_unit,
        font_family=font_family,
    )
    summaries = [
        {
            "model": row["model"],
            "platform": row["platform"],
            "shape": row["shape"],
            "cpu_cores": row["cpu_cores"],
            "gpu_devices": row["gpu_devices"],
            "batch_steps": row["batch_steps"],
            "active_workers": row.get("active_workers"),
            **{
                key: row[key]
                for key in ("series_kind", "run_id", "nonempty_spatial_owners_by_route")
                if key in row
            },
            **row["statistics"],
        }
        for row in conditions
    ]
    platform_metadata = {}
    for platform, rows in by_platform.items():
        ratios = [row["statistics"]["throughput_ratio"] for row in rows]
        platform_metadata[platform] = {
            "cpu_core_budgets": sorted({row["cpu_cores"] for row in rows}),
            "gpu_devices": sorted({row["gpu_devices"] for row in rows}),
            "active_workers": [row.get("active_workers") for row in rows],
            "workloads": [
                {"shape": row["shape"], "batch_steps": row["batch_steps"]}
                for row in rows
            ],
            "pairs_per_condition": REPEATS,
            "throughput_unit": "million useful interior-cell updates per second",
            "baseline_point_rates": [
                row["statistics"]["baseline"]["point"] for row in rows
            ],
            "esm_md_point_rates": [
                row["statistics"]["esm_md"]["point"] for row in rows
            ],
            "point_throughput_ratio_minimum": min(ratio["point"] for ratio in ratios),
            "point_throughput_ratio_maximum": max(ratio["point"] for ratio in ratios),
            "observed_paired_ratio_minimum": min(ratio["minimum"] for ratio in ratios),
            "observed_paired_ratio_maximum": max(ratio["maximum"] for ratio in ratios),
        }
        if platform == "cpu" and document["status"] == "accepted":
            platform_metadata[platform].update(
                {
                    "series_kind": "primary",
                    "run_ids": [row["run_id"] for row in rows],
                    "nonempty_spatial_owners_by_route": [
                        row["nonempty_spatial_owners_by_route"] for row in rows
                    ],
                    "shared_worker_team_by_workload": [
                        row["active_workers"]["baseline"]
                        == row["active_workers"]["esm_md"]
                        for row in rows
                    ],
                }
            )
    receipt = {
        **geometry,
        "final_width_inches": geometry["final_canvas_mm"][0] / 25.4,
        "final_height_inches": geometry["final_canvas_mm"][1] / 25.4,
        "final_width_mm": geometry["final_canvas_mm"][0],
        "final_height_mm": geometry["final_canvas_mm"][1],
        "presentation": "matched_absolute_rates",
        "mode": "matched_rates",
        "model": model,
        "profile": profile,
        "status": document["status"],
        "external_caption": True,
        "caption_text": caption_definition(document, model, cpu_cores)
        + (
            " Actual CPU worker-team counts are printed inside the poster CPU bars."
            if profile == "poster" and document["status"] == "accepted"
            else ""
        ),
        "point_definition": "useful_updates / median_seconds",
        "observed_range_definition": "minimum and maximum of twelve individual useful-update rates",
        "comparison_coverage": {
            "historical_language_conditions": 0,
            "matched_conditions": len(conditions),
            "selected_cpu_core_counts": sorted(
                {row["cpu_cores"] for row in by_platform["cpu"]}
            ),
            "available_cpu_core_counts": sorted(
                {
                    row["cpu_cores"]
                    for row in document["paired_records"]
                    if row["model"] == model and row["platform"] == "cpu"
                }
            ),
        },
        "paired_summaries": summaries,
        "metadata_by_platform": platform_metadata,
        "cpu_count_definition": "configured primary CPU ceiling, with actual per-route teams and nonempty owners reported separately",
        "paired_input": document,
        "style_identity": {
            "path": "scripts/publication_plot_style.py",
            "sha256": hashlib.sha256(
                (LOCAL / "publication_plot_style.py").read_bytes()
            ).hexdigest(),
        },
        "layout_identity": {
            "path": "scripts/direct_rate_layout.py",
            "sha256": hashlib.sha256(
                (LOCAL / "direct_rate_layout.py").read_bytes()
            ).hexdigest(),
        },
        "renderer_identity": {
            "path": str(Path(__file__).resolve().relative_to(ROOT)),
            "sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        },
    }
    output.with_suffix(".json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    """Render real matched measurements without displaying historical controls."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path)
    parser.add_argument("--historical", action="store_true")
    parser.add_argument("--model", choices=["sw", "ebm"], required=True)
    parser.add_argument("--profile", choices=["paper", "poster"], default="paper")
    parser.add_argument("--mode", choices=["matched_rates"], default="matched_rates")
    parser.add_argument("--cpu-cores", type=int)
    parser.add_argument(
        "--rate-unit", choices=["auto", "million", "billion"], default="auto"
    )
    parser.add_argument(
        "--external-caption",
        action="store_true",
        help="Definitions are always returned as caption text.",
    )
    parser.add_argument("--output", type=Path)
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--expected-steps", type=int)
    parser.add_argument(
        "--font-family", choices=["Helvetica Neue", "Open Sans", "Nimbus Sans"]
    )
    parser.add_argument("--font-file", type=Path)
    args = parser.parse_args()
    if args.audit_only and (args.historical or args.input is None):
        parser.error("Audit-only requires an accepted --input file.")
    if not args.audit_only and args.output is None:
        parser.error("Rendering requires --output.")
    if args.expected_steps is not None and args.expected_steps < 1:
        parser.error("Expected steps must be a positive integer.")
    if args.historical == bool(args.input):
        parser.error(
            "Choose exactly one accepted input or a historical matched stand-in."
        )
    document = (
        historical_input() if args.historical else json.loads(args.input.read_text())
    )
    if document.get("schema_version") != 1:
        parser.error("Unsupported input schema version.")
    if args.audit_only or args.expected_steps is not None:
        try:
            records = select_pairs(document, args.model, args.cpu_cores)
            report = audit_selected_records(
                document,
                records,
                expected_steps=args.expected_steps,
                expected_series_kind="primary",
            )
        except (ValueError, KeyError, TypeError) as error:
            parser.error(str(error))
        if args.audit_only:
            print(json.dumps(report, indent=2))
            return
    if document["status"] == "historical" and "historical" not in args.output.name:
        parser.error("Historical stand-in filenames must say historical.")
    input_path = ROOT / document["source_record"] if args.historical else args.input
    document["render_input_identity"] = {
        "path": str(input_path),
        "sha256": hashlib.sha256(input_path.read_bytes()).hexdigest(),
    }
    font_family = args.font_family or (
        "Open Sans" if args.profile == "poster" else "Helvetica Neue"
    )
    receipt = render(
        document,
        args.model,
        args.output,
        args.profile,
        args.cpu_cores,
        load_style(font_family, args.font_file),
        args.rate_unit,
        font_family=font_family,
    )
    print(
        json.dumps(
            {
                key: receipt[key]
                for key in (
                    "presentation",
                    "mode",
                    "model",
                    "profile",
                    "status",
                    "comparison_coverage",
                    "minimum_effective_font_pt",
                    "final_width_inches",
                    "final_height_inches",
                    "outputs",
                )
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

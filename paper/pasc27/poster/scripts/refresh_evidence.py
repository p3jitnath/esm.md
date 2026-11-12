"""Record accepted poster measurements and checks bound to the saved artwork."""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
import math
from pathlib import Path
import statistics

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]

from poster_comparison_input import load_display_comparison


def digest(path: Path) -> str:
    """Return the SHA256 identifier of a retained file.

    Parameters
    ----------
    path : pathlib.Path
        File whose bytes identify the artifact.

    Returns
    -------
    str
        Hexadecimal SHA256 identifier.
    """
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_performance() -> dict:
    """Read only an accepted manifest for the new matched-rate poster.

    Returns
    -------
    dict
        Accepted relative source paths, renderer receipts and native prose.

    Raises
    ------
    ValueError
        If the new data are missing, pending or outside the declared scope.
    """
    path = POSTER / "data/accepted-performance-update.json"
    if not path.is_file():
        raise ValueError("Accepted poster performance input is required.")
    data = json.loads(path.read_text())
    if (
        data.get("status") != "accepted"
        or data.get("presentation") != "matched_absolute_rates"
        or data.get("selected_cpu_cores") != 248
        or data.get("cpu_resource_interpretation") != "configured_ceiling"
    ):
        raise ValueError("The new poster measurements are not accepted.")
    return data


def condition_key(row: dict) -> tuple:
    """Identify one complete workload and its selected resource configuration.

    Parameters
    ----------
    row : dict
        One accepted timing condition or renderer summary.

    Returns
    -------
    tuple
        Model-independent platform, shape, steps and resource identifiers.
    """
    return (
        row["platform"],
        tuple(row["shape"]),
        row["batch_steps"],
        row["cpu_cores"],
        row["gpu_devices"],
    )


def review_rates(data: dict) -> tuple[dict, dict]:
    """Compare each plotted rate with original accepted elapsed-time words.

    Parameters
    ----------
    data : dict
        Accepted poster manifest with two complete render receipts.

    Returns
    -------
    reviews : dict
        Actual condition, series and observation counts by platform.
    sources : dict
        Retained source paths, hashes and measurement-policy metadata.

    Raises
    ------
    ValueError
        If source times, resources, qualification or plotted rates disagree.

    Notes
    -----
    This independently checks recorded observations. It does not run a solver
    or replace physical verification. A unit in the last place (ULP) is the
    spacing between neighbouring 64-bit floating-point values. One ULP is
    allowed when equivalent rate expressions round differently.
    """
    sources = {}
    raw_sources = {}
    for platform in ("cpu", "gpu"):
        relative = data["measurement_sources"][platform]
        if (
            not isinstance(relative, str)
            or not relative
            or Path(relative).is_absolute()
        ):
            raise ValueError("Accepted measurement sources need relative poster paths.")
        path = POSTER / relative
        if not path.resolve().is_relative_to(POSTER.resolve()):
            raise ValueError("Measurement source paths must stay inside the poster.")
        source = json.loads(path.read_text())
        if source.get("status") != "accepted":
            raise ValueError("An original measurement source is not accepted.")
        raw_sources[platform] = source["paired_records"]
        sources[platform] = {
            "path": relative,
            "sha256": digest(path),
            "measurement_protocol": source.get("measurement_protocol"),
            "power_policy": source.get("power_policy"),
            "quiet_policy": source.get("quiet_policy"),
        }
    reviews = {
        platform: {
            "status": "passed",
            "conditions": 0,
            "series": 0,
            "pairs": 0,
            "elapsed_observations": 0,
            "maximum_rate_difference_in_ULPs": 0.0,
        }
        for platform in ("cpu", "gpu")
    }
    for model in ("sw", "ebm"):
        receipt = data["render_metadata"][model]
        coverage = receipt["comparison_coverage"]
        if (
            receipt.get("status") != "accepted"
            or receipt.get("presentation") != "matched_absolute_rates"
            or receipt.get("mode") != "matched_rates"
            or receipt.get("model") != model
            or receipt.get("profile") != "poster"
            or coverage["selected_cpu_core_counts"] != [248]
            or coverage["matched_conditions"] != 6
            or coverage["historical_language_conditions"] != 0
            or receipt.get("point_definition") != "useful_updates / median_seconds"
            or receipt.get("observed_range_definition")
            != "minimum and maximum of twelve individual useful-update rates"
        ):
            raise ValueError("A render receipt has the wrong accepted scope.")
        rows = [
            r for r in receipt["paired_input"]["paired_records"] if r["model"] == model
        ]
        summaries = receipt["paired_summaries"]
        if (
            len(rows) != 6
            or len(summaries) != 6
            or any(
                sum(r["platform"] == platform for r in rows) != 3
                for platform in ("cpu", "gpu")
            )
        ):
            raise ValueError("Each model requires three CPU and three GPU conditions.")
        keys = [condition_key(row) for row in rows]
        if len(set(keys)) != 6 or {condition_key(row) for row in summaries} != set(
            keys
        ):
            raise ValueError("A matched workload is missing or duplicated.")
        for summary in summaries:
            row = rows[keys.index(condition_key(summary))]
            platform = row["platform"]
            originals = [
                r
                for r in raw_sources[platform]
                if r["model"] == model
                and condition_key(r) == condition_key(row)
                and (
                    platform != "cpu"
                    or (
                        r.get("series_kind") == "primary"
                        and r.get("run_id") == row.get("run_id")
                    )
                )
            ]
            copied_words = sorted(
                (
                    pair["repeat"],
                    float(pair["baseline_seconds"]).hex(),
                    float(pair["esm_md_seconds"]).hex(),
                )
                for pair in row["paired_samples"]
            )
            original_words = (
                sorted(
                    (
                        pair["repeat"],
                        float(pair["baseline_seconds"]).hex(),
                        float(pair["esm_md_seconds"]).hex(),
                    )
                    for pair in originals[0]["paired_samples"]
                )
                if len(originals) == 1
                else []
            )
            if len(originals) != 1 or original_words != copied_words:
                raise ValueError(
                    "Copied elapsed-time words differ from their accepted source."
                )
            original = originals[0]
            identity_fields = (
                "campaign_id",
                "job_id",
                "node",
                "timer_scope",
                "source_revisions",
                "input_identity",
                "acceptance_record",
            )
            if platform == "cpu":
                identity_fields += (
                    "active_workers",
                    "nonempty_spatial_owners_by_route",
                )
            if any(row[key] != original[key] for key in identity_fields):
                raise ValueError(
                    "A copied timing or resource identity differs from its source."
                )
            if (
                row["campaign_id"] not in data["accepted_campaign_ids"]
                or row["batch_steps"] != 1000
            ):
                raise ValueError("A condition has the wrong campaign or step count.")
            flags = (
                "independent_physics_passed",
                "exact_outputs_equal",
                "timed_final_state_checked",
                "exclusive_node",
                "quiet_samples",
            )
            if not all(row["qualification"].get(flag) is True for flag in flags):
                raise ValueError(
                    "A condition lacks its scientific and timing acceptance."
                )
            pairs = row["paired_samples"]
            if len(pairs) != 12 or {r["repeat"] for r in pairs} != set(range(12)):
                raise ValueError("Twelve distinct paired observations are required.")
            if platform == "cpu":
                teams = row["active_workers"]
                owners = row["nonempty_spatial_owners_by_route"]
                if (
                    row["cpu_cores"] != 248
                    or row.get("series_kind") != "primary"
                    or not isinstance(row.get("run_id"), str)
                    or not row["run_id"].strip()
                    or teams["baseline"] != teams["esm_md"]
                    or any(
                        type(teams[r]) is not int
                        or type(owners[r]) is not int
                        or not 1 <= owners[r] <= teams[r] <= 248
                        for r in ("baseline", "esm_md")
                    )
                ):
                    raise ValueError(
                        "CPU ceiling, common team or owner metadata disagree."
                    )
            elif row["gpu_devices"] != 1:
                raise ValueError("The GPU comparison requires one device.")
            updates = math.prod(row["shape"]) * row["batch_steps"]
            for route in ("baseline", "esm_md"):
                seconds = [pair[route + "_seconds"] for pair in pairs]
                if any(not math.isfinite(t) or t <= 0 for t in seconds):
                    raise ValueError("Every elapsed time must be positive and finite.")
                rates = [updates / (t * 1_000_000) for t in seconds]
                expected = {
                    "point": updates / (statistics.median(seconds) * 1_000_000),
                    "minimum": min(rates),
                    "maximum": max(rates),
                }
                for statistic, value in expected.items():
                    if not math.isfinite(value) or value <= 0:
                        raise ValueError(
                            "A derived accepted rate is not positive and finite."
                        )
                    actual = summary[route][statistic]
                    if not math.isfinite(actual) or actual <= 0:
                        raise ValueError("A plotted rate is not positive and finite.")
                    difference = abs(actual - value) / max(
                        math.ulp(actual), math.ulp(value)
                    )
                    if difference > 1:
                        raise ValueError(
                            "A plotted rate differs from accepted elapsed times."
                        )
                    reviews[platform]["maximum_rate_difference_in_ULPs"] = max(
                        reviews[platform]["maximum_rate_difference_in_ULPs"], difference
                    )
            reviews[platform]["conditions"] += 1
            reviews[platform]["series"] += 2
            reviews[platform]["pairs"] += len(pairs)
            reviews[platform]["elapsed_observations"] += 2 * len(pairs)
    return reviews, sources


def refresh() -> dict:
    """Write current evidence only after accepted data and saved-artwork reviews.

    Returns
    -------
    dict
        Evidence map bound to the current input, PPTX, PDF and PNG.

    Raises
    ------
    ValueError
        If measurements or the current structural and visual reviews are pending.

    Notes
    -----
    No model simulation or comparative timing is performed. A separate human
    must review the actual final PDF before this function writes evidence.
    """
    data = load_performance()
    display = load_display_comparison(POSTER, data)
    archived = display.get("comparison_class") == "archived_language_controls"
    display_hash = display.get("display_comparison_input_sha256")
    input_path = POSTER / "data/accepted-performance-update.json"
    input_hash = digest(input_path)
    reviews, source_records = review_rates(data)
    review_dir = ROOT / ".runtime/poster_update_20261108/final_review"
    checks = json.loads((review_dir / "structural-check.json").read_text())
    visual = json.loads((review_dir / "visual-review.json").read_text())
    artifacts = {
        name: digest(POSTER / name)
        for name in (
            "esm-md-a0-landscape.pptx",
            "esm-md-a0-landscape.pdf",
            "esm-md-a0-landscape.png",
        )
    }
    if (
        checks.get("passed") is not True
        or checks.get("accepted_performance_input_sha256") != input_hash
        or checks.get("artifact_sha256") != artifacts
        or checks.get("display_comparison_input_sha256") != display_hash
    ):
        raise ValueError("The saved-artwork checks are missing or stale.")
    if (
        visual.get("status") != "passed"
        or visual.get("pdf_sha256") != artifacts["esm-md-a0-landscape.pdf"]
        or visual.get("accepted_performance_input_sha256") != input_hash
        or visual.get("display_comparison_input_sha256") != display_hash
    ):
        raise ValueError("The final PDF needs a fresh human visual review.")
    old = json.loads((POSTER / "data/historical/poster_evidence.json").read_text())
    profile = json.loads((POSTER / "project-profile.json").read_text())
    physics = json.loads((POSTER / "figure-evidence.json").read_text())
    comparison = {
        "status": "accepted",
        "presentation": "matched_absolute_rates",
        "source_records": source_records,
        "input_sha256": input_hash,
        "series": ["ESM.md", "Hand-tuned baseline"],
        "point_definition": "Useful updates divided by median elapsed seconds",
        "range_definition": "Observed minimum and maximum of twelve individual rates",
        "independent_recorded_rate_review": reviews,
        "new_numerical_runs": False,
        "plotted_data": {
            model: data["render_metadata"][model]["paired_summaries"]
            for model in ("sw", "ebm")
        },
    }
    current_comparison = comparison
    display_reviews = reviews
    if archived:
        original_payload = (POSTER / display["source_evidence"]["path"]).read_bytes()
        if (
            hashlib.sha256(original_payload).hexdigest()
            != display["source_evidence"]["sha256"]
        ):
            raise ValueError("The original recorded comparison evidence changed.")
        original = json.loads(original_payload)
        display_reviews = {}
        for platform in ("cpu", "gpu"):
            measurements = [
                item
                for model in ("sw", "ebm")
                for series in original["plotted_data"][model][platform]
                for item in series["measurements"]
            ]
            display_reviews[platform] = {
                "status": "exact_original_evidence_preserved",
                "conditions": len(measurements),
                "individual_rates": sum(item["count"] for item in measurements),
                "method": "Exact original point/range/raw-rate subtree comparison, without recomputing the historical statistic",
            }
        comparison = {
            "status": "recorded_comparison",
            "comparison_class": "archived_language_controls",
            "presentation": "language_comparisons",
            "source_evidence": display["source_evidence"],
            "source_records": original["source_records"],
            "cohorts": original["cohorts"],
            "series": original["series"],
            "point_definition": original["aggregation"],
            "scope": original["scope"],
            "historical_qualification_scope": display["historical_qualification_scope"],
            "plotted_data": original["plotted_data"],
            "independent_recorded_value_review": display_reviews,
            "render_metadata": display["render_metadata"],
            "display_input_sha256": display_hash,
            "current_matched_source": display["current_matched_source"],
            "new_numerical_runs": False,
        }
    comparison_path = POSTER / (
        "data/archived-language-figure-evidence-20261112.json"
        if archived
        else "data/performance-figure-evidence-20261112.json"
    )
    comparison_path.write_text(json.dumps(comparison, indent=2) + "\n")
    files = {}
    for directory in ("scripts", "data", "figures", "assets"):
        for path in sorted((POSTER / directory).rglob("*")):
            if (
                path.is_file()
                and "__pycache__" not in path.parts
                and path.suffix != ".pyc"
            ):
                files[str(path.relative_to(POSTER))] = {
                    "sha256": digest(path),
                    "bytes": path.stat().st_size,
                }
    for name in (
        *artifacts,
        "project-profile.json",
        "README.md",
        "requirements.txt",
        "requirements_plotting.txt",
        "PLOT_PROFILE.md",
    ):
        path = POSTER / name
        if path.exists():
            files[name] = {"sha256": digest(path), "bytes": path.stat().st_size}
    report = {
        "date_utc": datetime.now(timezone.utc).date().isoformat(),
        "format": "A0 landscape, 1189 by 841 mm, one native PowerPoint slide and vector PDF",
        "title": profile["identity"]["title"],
        "author": profile["identity"]["author"],
        "affiliation": profile["identity"]["department"]
        + ", "
        + profile["identity"]["university"],
        "implementation_label": "ESM.md",
        "generation_route": "Markdown physics and fixed contracts guide Fortran and CUDA Fortran candidates, which compilers translate to machine code",
        "branding": old.get("branding", {}),
        "references": old.get("references", []),
        "acknowledgement": old.get("acknowledgement", {}),
        "physics": physics,
        "performance_source": (
            "data/archived-language-comparison-update.json"
            if archived
            else "data/accepted-performance-update.json"
        ),
        "performance_source_sha256": display_hash if archived else input_hash,
        "current_matched_source": {
            "path": "data/accepted-performance-update.json",
            "sha256": input_hash,
        },
        "current_matched_evidence": current_comparison,
        "performance_method": (
            original["aggregation"]
            if archived
            else "Two matched routes at three grids per model and platform, using useful updates divided by median elapsed seconds and observed twelve-run rate ranges"
        ),
        "graph_policy": (
            "Show the true 8 November Fortran ESM.md and six separate October controls with originally reported absolute rates. Retain current 12 November matched outcomes only in the separately dated Summary."
            if archived
            else "Show ESM.md and the hand-tuned baseline through absolute rates, without historical controls or normalized panels"
        ),
        "axis_scales": {
            "CPU": (
                "Per-grid scales and limits recorded in the archived-language render receipts"
                if archived
                else "Independent zero-based linear rate axes per grid"
            ),
            "GPU": (
                "Per-grid scales and limits recorded in the archived-language render receipts"
                if archived
                else "Independent zero-based linear rate axes per grid"
            ),
        },
        "figure_unit_labels": profile["poster"].get("figure_unit_labels"),
        "independent_plotted_input_reviews": {
            **display_reviews,
            "new_numerical_runs": False,
        },
        "scope": (
            original["scope"]
            + [
                display["historical_qualification_scope"],
                "The separately dated 12 November Summary uses the unchanged current matched input and its own stronger acceptance.",
            ]
            if archived
            else [
                "Main CPU conditions have a configured 248-core ceiling and the same actual team for both routes within each paired workload. Teams can differ across grids, with nonempty spatial owners recorded separately.",
                data["cpu_worker_disclosure"],
                "CPU timing includes the complete coordinator and required neighbouring-cell work. GPU records use one device and retain their declared event scope and transfer exclusions.",
                "Original elapsed-time words, source identities and accepted power and quiet policies remain in the copied source records.",
                "Independent physical verification and exact complete-output agreement apply to the recorded inputs and configurations, without establishing performance on another architecture.",
                "The unchanged physical figures show accepted model states rather than observations.",
            ]
        ),
        "comparison_evidence": comparison,
        "comparison_evidence_source": str(comparison_path.relative_to(POSTER)),
        "formulation_rename": json.loads(
            (POSTER / "data/dam-break-rename.json").read_text()
        ),
        "summary": display["poster_text"],
        "structural_and_qr_checks": checks,
        "visual_review": visual,
        "desktop_powerpoint_inspection": False,
        "tools": {
            name: importlib.metadata.version(name)
            for name in [
                "numpy",
                "matplotlib",
                "python-pptx",
                "reportlab",
                "svglib",
                "PyMuPDF",
                "Pillow",
                "zxing-cpp",
            ]
        },
        "files": files,
    }
    (POSTER / "evidence.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


if __name__ == "__main__":
    result = refresh()
    print(
        json.dumps(
            {
                "title": result["title"],
                "files": len(result["files"]),
                "checks": result["structural_and_qr_checks"]["passed"],
            },
            indent=2,
        )
    )

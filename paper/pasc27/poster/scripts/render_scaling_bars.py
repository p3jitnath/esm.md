"""Draw CPU complete-update throughput at every recorded core count."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path

LOCAL = Path(__file__).resolve().parent

from render_performance_bars import (
    BASELINE_ORANGE,
    ESM_BLUE,
    REPEATS,
    ROOT,
    historical_input,
    load_style,
    summarise_pair,
    workload_label,
    validate_cpu_configuration,
    audit_selected_records,
)

REQUESTED_CORES = (1, 2, 4, 8, 16, 32, 64, 72, 128, 144, 248)


def positive_integer(value: int, name: str) -> int:
    """Return a positive integer field.

    Parameters
    ----------
    value : int
        Actual count read from JSON; booleans and fractional values are invalid.
    name : str
        Field name used in an error message.

    Returns
    -------
    int
        Unchanged validated count.

    Raises
    ------
    ValueError
        If the value is not a positive integer.
    """
    if type(value) is not int or value < 1:
        raise ValueError(f"{name} must be a positive integer.")
    return value


def select_conditions(document: dict, model: str) -> tuple[list[tuple], dict]:
    """Validate CPU conditions and expose actual workload and core coverage.

    Parameters
    ----------
    document : dict
        Accepted or explicitly historical CPU-only paired records. Times are in seconds.
    model : {'sw', 'ebm'}
        Model whose three interior-grid shapes will be drawn.

    Returns
    -------
    shapes : list of tuple
        Three actual workload shapes, sorted by interior-cell count and dimensions.
    conditions : dict
        Records and rate summaries keyed by shape and actual CPU count.

    Raises
    ------
    ValueError
        If a record is invalid, duplicated, belongs to a GPU or lacks a required workload.

    Notes
    -----
    Different core coverage is allowed across workloads and is disclosed explicitly.
    Every supplied CPU condition for the selected model is drawn once. Numerical
    acceptance remains the campaign's responsibility rather than this metadata check.
    """
    if document.get("schema_version") != 1 or document.get("status") not in (
        "accepted",
        "historical",
    ):
        raise ValueError(
            "Use accepted CPU records or an explicit historical inspection."
        )
    if model not in ("sw", "ebm"):
        raise ValueError("Select a supported model.")
    records = document.get("paired_records")
    if not isinstance(records, list) or not records:
        raise ValueError("At least one recorded condition is required.")
    conditions = {}
    for record in records:
        if record.get("platform") != "cpu" or record.get("gpu_devices") != 0:
            raise ValueError("A scaling input must contain CPU records only.")
        validate_cpu_configuration(
            record, expected_series_kind="fixed_scaling", status=document["status"]
        )
        cores = positive_integer(record["cpu_cores"], "cpu_cores")
        positive_integer(record["batch_steps"], "batch_steps")
        for dimension in record["shape"]:
            positive_integer(dimension, "shape dimension")
        for pair in record["paired_samples"]:
            if type(pair["repeat"]) is not int:
                raise ValueError("Pair identifiers must be integers.")
        if document["status"] == "accepted":
            revisions = record.get("source_revisions", {})
            if not isinstance(revisions, dict) or not all(
                revisions.get(key) for key in ("esm_md", "baseline")
            ):
                raise ValueError("Both measured source revisions must be identified.")
        values = summarise_pair(record, document["status"] == "historical")
        if record["model"] != model:
            continue
        shape = tuple(record["shape"])
        identity = (shape, cores)
        if identity in conditions:
            raise ValueError(
                "A duplicate workload/core condition needs explicit separation."
            )
        conditions[identity] = {"record": record, "summaries": values}
    shapes = sorted(
        {shape for shape, _ in conditions}, key=lambda shape: (math.prod(shape), shape)
    )
    if len(shapes) != 3:
        raise ValueError("A model figure requires all three recorded workload shapes.")
    return shapes, conditions


def coverage_record(document: dict, shapes: list[tuple], conditions: dict) -> dict:
    """Describe actual CPU coverage without filling gaps.

    Parameters
    ----------
    document : dict
        Canonical input with optional requested core budgets.
    shapes : list of tuple
        Three actual workload shapes.
    conditions : dict
        Validated conditions keyed by shape and core budget.

    Returns
    -------
    dict
        Observed and missing budgets, batch lengths and unchanged worker metadata.

    Raises
    ------
    ValueError
        If the requested budgets are invalid or repeated.
    """
    requested = document.get("requested_cpu_cores", list(REQUESTED_CORES))
    if not isinstance(requested, list) or not requested:
        raise ValueError("Requested CPU counts must be a nonempty integer list.")
    requested = [positive_integer(value, "requested core count") for value in requested]
    if len(set(requested)) != len(requested):
        raise ValueError("Requested CPU counts must be unique.")
    requested = sorted(requested)
    workloads = []
    for shape in shapes:
        observed = sorted(core for grid, core in conditions if grid == shape)
        workloads.append(
            {
                "shape": list(shape),
                "observed_cpu_cores": observed,
                "requested_but_unmeasured": [
                    core for core in requested if core not in observed
                ],
                "additional_measured_cores": [
                    core for core in observed if core not in requested
                ],
                "batch_steps_by_core": {
                    str(core): conditions[shape, core]["record"]["batch_steps"]
                    for core in observed
                },
                "series_kind_by_core": {
                    str(core): conditions[shape, core]["record"].get("series_kind")
                    for core in observed
                },
                "run_id_by_core": {
                    str(core): conditions[shape, core]["record"].get("run_id")
                    for core in observed
                },
                "nonempty_spatial_owners_by_core": {
                    str(core): conditions[shape, core]["record"].get(
                        "nonempty_spatial_owners_by_route"
                    )
                    for core in observed
                },
                "active_workers_by_core": {
                    str(core): conditions[shape, core]["record"].get("active_workers")
                    for core in observed
                },
            }
        )
    return {
        "requested_cpu_cores": requested,
        "workloads": workloads,
        "interpolated_conditions": 0,
    }


def caption_text(document: dict, model: str, coverage: dict) -> str:
    """Return rate definitions and the full observed coverage.

    Parameters
    ----------
    document : dict
        Canonical CPU input and accepted or historical status.
    model : {'sw', 'ebm', 'both'}
        Models included in the figure.
    coverage : dict
        Coverage for one model or a dictionary keyed by both model names.

    Returns
    -------
    str
        Caption defining useful updates, point estimates, ranges and actual budgets.
    """
    models = ("sw", "ebm") if model == "both" else (model,)
    coverage_by_model = coverage if model == "both" else {model: coverage}
    parts = [
        (
            "CPU useful-update rates for the shallow-water and energy-balance models."
            if model == "both"
            else "CPU useful-update rates for the "
            + ("shallow-water" if model == "sw" else "energy-balance")
            + " model."
        ),
        "Blue bars show ESM.md and orange bars show the hand-tuned baseline.",
        "A useful update counts one interior cell once per complete step. Required boundary calculations and redundant tile work remain inside the timer, without being counted as extra useful updates.",
        "Each point equals the useful update count divided by the median of twelve recorded times. Thin lines span the minimum and maximum of the twelve individual rates and are not confidence intervals.",
        "Each timing pair uses the same processor, grid, complete step count and buffers for the two implementations.",
        "Every measured CPU core budget has its own categorical position. No missing budget is interpolated. Each grid has an independent linear rate axis that starts at zero, with the same rate unit throughout the figure.",
        "The CPU core budget is the configured solver budget. The active worker count can be smaller for a small grid and is retained separately when supplied.",
    ]
    for name in models:
        for item in coverage_by_model[name]["workloads"]:
            grid = workload_label(name, item["shape"])
            unit = "cells" if name == "sw" else "bands"
            counts = ", ".join(f"{value:,}" for value in item["observed_cpu_cores"])
            parts.append(
                f"The {name.upper()} {grid} {unit} workload has measurements at budgets {counts}."
            )
            missing = item["requested_but_unmeasured"]
            if missing:
                parts.append(
                    "Requested budgets not measured for this workload are "
                    + ", ".join(f"{value:,}" for value in missing)
                    + "."
                )
            extra = item["additional_measured_cores"]
            if extra:
                parts.append(
                    "Additional measured budgets shown are "
                    + ", ".join(f"{value:,}" for value in extra)
                    + "."
                )
    if "ebm" in coverage_by_model:
        for item in coverage_by_model["ebm"]["workloads"]:
            capped = [
                budget
                for budget in item["observed_cpu_cores"]
                if budget > item["shape"][0]
            ]
            if capped and document["status"] == "accepted":
                parts.append(
                    "For the "
                    + workload_label("ebm", item["shape"])
                    + "-band EBM grid, budgets "
                    + ", ".join(f"{budget:,}" for budget in capped)
                    + " use exactly "
                    + f"{item['shape'][0]:,}"
                    + " actual workers per route under the frozen band-count cap. The axis shows the configured budget, not a claim that every budgeted worker belongs to that team."
                )
    parts.append(
        "The source record retains all times, batch lengths, source revisions, placement, worker counts, input identities and acceptance evidence."
    )
    if document["status"] == "historical":
        parts.append(
            "This historical inspection contains genuine one-core matched records only and no new scaling result."
        )
    return " ".join(parts)


def rate_tick(value: float, position: float, high: float) -> str:
    """Format an absolute rate with commas and enough decimal places.

    Parameters
    ----------
    value : float
        Tick value in the displayed rate unit.
    position : float
        Tick position passed by Matplotlib.
    high : float
        Largest observed rate in this facet and unit.

    Returns
    -------
    str
        Plain numeric rate without scientific notation or an offset.
    """
    del position
    places = max(0, min(6, 2 - math.floor(math.log10(high))))
    text = f"{value:,.{places}f}"
    return text.rstrip("0").rstrip(".") if places else text


def draw_scaling(
    document: dict,
    model: str,
    output: Path,
    style,
    rate_unit: str = "auto",
    font_family: str = "Helvetica Neue",
) -> dict:
    """Draw every observed CPU budget in three or six grid facets.

    Parameters
    ----------
    document : dict
        CPU-only canonical input with twelve timing pairs per condition.
    model : {'sw', 'ebm', 'both'}
        One model or both models in shallow-water then energy-balance rows.
    output : pathlib.Path
        Local prefix for PDF, PNG, SVG and the complete evidence JSON.
    style : module
        The selected publication typography and export helper.
    rate_unit : {'auto', 'million', 'billion'}
        Shared useful-update rate unit. Automatic selection uses billions when needed.
    font_family : str
        Explicit paper family. The default remains Helvetica Neue.

    Returns
    -------
    dict
        Complete data, coverage, caption, physical geometry and output identities.

    Raises
    ------
    ValueError
        If data are invalid, duplicate or incomplete, or a requested unit is unknown.
    RuntimeError
        If figure type, geometry or visible text fails the required checks.

    Notes
    -----
    Each bar is useful updates divided by median seconds, rather than the median
    of individual rates. Whiskers retain each implementation's observed rate range.
    """
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import Patch
    from matplotlib.ticker import FuncFormatter, MaxNLocator

    if model not in ("sw", "ebm", "both"):
        raise ValueError("Select sw, ebm or both models.")
    if rate_unit not in ("auto", "million", "billion"):
        raise ValueError("Select a supported absolute rate unit.")
    models = ("sw", "ebm") if model == "both" else (model,)
    selections = {name: select_conditions(document, name) for name in models}
    coverage_by_model = {
        name: coverage_record(document, shapes, conditions)
        for name, (shapes, conditions) in selections.items()
    }
    high_million = max(
        values["summaries"][key]["maximum"]
        for _, conditions in selections.values()
        for values in conditions.values()
        for key in ("baseline", "esm_md")
    )
    unit = (
        "billion"
        if rate_unit == "billion" or rate_unit == "auto" and high_million >= 1_000
        else "million"
    )
    divisor = 1_000.0 if unit == "billion" else 1.0
    canvas = (6.3, 4.0901)
    font = font_family
    size = 8.5
    settings = {
        "font.size": size,
        "axes.labelsize": size,
        "xtick.labelsize": size,
        "ytick.labelsize": size,
        "legend.fontsize": size,
        "axes.linewidth": 0.7,
        "pdf.fonttype": 42,
        "svg.fonttype": "path",
    }
    facets = [
        (name, item) for name in models for item in coverage_by_model[name]["workloads"]
    ]
    budget_order = sorted(
        {core for _, item in facets for core in item["observed_cpu_cores"]}
    )
    with style.publication_style(settings, font_family=font, project_root=ROOT):
        figure, axis_grid = plt.subplots(1, len(facets), figsize=canvas, squeeze=False)
        axes = axis_grid[0]
        figure.subplots_adjust(
            left=0.105, right=0.995, bottom=0.145, top=0.735, wspace=0.24
        )
        panels = []
        bar_patches = []
        for index, (axis, (name, item)) in enumerate(zip(axes, facets)):
            _, conditions = selections[name]
            shape = tuple(item["shape"])
            cores = item["observed_cpu_cores"]
            positions = [budget_order.index(core) for core in cores]
            high = 0.0
            for key, colour, offset in [
                ("baseline", BASELINE_ORANGE, -0.19),
                ("esm_md", ESM_BLUE, 0.19),
            ]:
                values = [conditions[shape, core]["summaries"][key] for core in cores]
                points = [value["point"] / divisor for value in values]
                low = [
                    (value["point"] - value["minimum"]) / divisor for value in values
                ]
                upper = [
                    (value["maximum"] - value["point"]) / divisor for value in values
                ]
                container = axis.barh(
                    [position + offset for position in positions],
                    points,
                    height=0.28,
                    color=colour,
                    edgecolor="#333333",
                    linewidth=0.25,
                    zorder=2,
                )
                bar_patches.extend(container.patches)
                axis.errorbar(
                    points,
                    [position + offset for position in positions],
                    xerr=[low, upper],
                    fmt="none",
                    color="#222222",
                    elinewidth=0.6,
                    capsize=1.1,
                    zorder=3,
                )
                high = max(high, max(value["maximum"] / divisor for value in values))
            tick_top = MaxNLocator(nbins=2, min_n_ticks=2).tick_values(0, high * 1.12)[
                -1
            ]
            axis.set_xlim(0, tick_top)
            axis.set_xticks([0, tick_top / 2, tick_top])
            axis.get_xticklabels()[0].set_horizontalalignment("left")
            axis.get_xticklabels()[-1].set_horizontalalignment("right")
            axis.set_ylim(len(budget_order) - 0.35, -0.65)
            axis.set_yticks(
                range(len(budget_order)), [f"{core:,}" for core in budget_order]
            )
            axis.tick_params(axis="y", labelleft=index == 0, length=2, pad=2)
            axis.tick_params(axis="x", length=2, pad=2)
            axis.xaxis.set_major_formatter(
                FuncFormatter(
                    lambda value, position, ceiling=high: rate_tick(
                        value, position, ceiling
                    )
                )
            )
            style.finish_axis(axis)
            axis.grid(axis="x", color="#DCE2E5", linewidth=0.5, zorder=0)
            if index == 0:
                axis.set_ylabel("Configured CPU budget [cores]", labelpad=5)
            box = axis.get_position()
            if box.height * canvas[1] < 1.2:
                raise RuntimeError("Horizontal budget rows need a taller data panel.")
            panels.append(
                {
                    "model": name,
                    "shape": list(shape),
                    "cpu_cores": cores,
                    "axis_inches": [box.width * canvas[0], box.height * canvas[1]],
                    "x_limits": list(axis.get_xlim()),
                    "y_limits": list(axis.get_ylim()),
                    "rate_axis": "x",
                    "budget_axis": "y",
                    "y_categories": [
                        {"cpu_cores": core, "position": position}
                        for core, position in zip(cores, positions)
                    ],
                }
            )
            centre = (box.x0 + box.x1) / 2
            grid_name = workload_label(name, list(shape)) + (
                "\n[cells]" if name == "sw" else "\n[bands]"
            )
            figure.text(
                centre,
                0.81,
                grid_name,
                fontsize=size,
                ha="center",
                va="center",
                linespacing=1.1,
            )
            axis.text(
                -0.02,
                1.035,
                "abcdef"[index],
                transform=axis.transAxes,
                fontsize=9.5,
                fontweight="bold",
                ha="right",
                va="bottom",
            )
        for name in models:
            matching = [axis for axis, (owner, _) in zip(axes, facets) if owner == name]
            centre = (
                matching[0].get_position().x0 + matching[-1].get_position().x1
            ) / 2
            figure.text(
                centre,
                0.89,
                "SW" if name == "sw" else "EBM",
                fontsize=9.5,
                fontweight="bold",
                ha="center",
                va="center",
            )
        handles = [
            Patch(
                facecolor=BASELINE_ORANGE,
                edgecolor="#333333",
                label="Hand-tuned baseline",
            ),
            Patch(facecolor=ESM_BLUE, edgecolor="#333333", label="ESM.md"),
        ]
        figure.legend(
            handles=handles,
            loc="upper center",
            bbox_to_anchor=(0.55, 0.995),
            ncol=2,
            frameon=False,
            handlelength=1.2,
            columnspacing=1.2,
        )
        figure.text(
            0.55,
            0.02,
            f"Useful rate [{unit} updates/s]",
            fontsize=size,
            ha="center",
            va="bottom",
        )
        issues = style.audit_figure(
            figure, expected_font=font, min_font_size=size, project_root=ROOT
        )
        allowed_width_findings = [
            issue
            for issue in issues
            if issue.startswith("Axis ") and "enlarge or split the figure" in issue
        ]
        blocking = [issue for issue in issues if issue not in allowed_width_findings]
        if blocking:
            raise RuntimeError(
                "Horizontal scaling audit failed. " + ". ".join(blocking)
            )
        figure.canvas.draw()
        renderer = figure.canvas.get_renderer()
        from matplotlib.text import Text

        text_artists = [
            artist
            for artist in figure.findobj(match=Text)
            if artist.get_visible() and artist.get_text().strip()
        ]
        canvas_box = figure.bbox
        for artist in text_artists:
            text_box = artist.get_window_extent(renderer)
            if (
                text_box.x0 < canvas_box.x0 - 0.5
                or text_box.x1 > canvas_box.x1 + 0.5
                or text_box.y0 < canvas_box.y0 - 0.5
                or text_box.y1 > canvas_box.y1 + 0.5
            ):
                raise RuntimeError(
                    "A horizontal scaling label exceeds the declared canvas. "
                    + repr(artist.get_text())
                )
        y_boxes = [
            label.get_window_extent(renderer)
            for label in axes[0].get_yticklabels()
            if label.get_visible()
        ]
        y_boxes = sorted(y_boxes, key=lambda box: box.y0)
        y_gap = (
            min(right.y0 - left.y1 for left, right in zip(y_boxes, y_boxes[1:]))
            * 72
            / figure.dpi
        )
        if y_gap < 0.5:
            raise RuntimeError("Configured budget labels touch or overlap.")
        x_boxes = [
            label.get_window_extent(renderer)
            for axis in axes
            for label in axis.get_xticklabels()
            if label.get_visible()
        ]
        x_boxes = sorted(x_boxes, key=lambda box: box.x0)
        x_gap = (
            min(right.x0 - left.x1 for left, right in zip(x_boxes, x_boxes[1:]))
            * 72
            / figure.dpi
        )
        if x_gap < 0.5:
            raise RuntimeError("Adjacent rate ticks touch or overlap.")
        pitch = (
            abs(
                axes[0].transData.transform((0, 1))[1]
                - axes[0].transData.transform((0, 0))[1]
            )
            * 72
            / figure.dpi
        )
        label_height = max(box.height for box in y_boxes) * 72 / figure.dpi
        old_two_row_pitch = 4.0901 * 0.74 / 2.44 * 72 / (len(budget_order) + 0.3)
        row_metrics = {
            "budget_centre_spacing_pt": pitch,
            "maximum_budget_label_height_pt": label_height,
            "minimum_budget_label_gap_pt": y_gap,
            "minimum_rate_tick_gap_pt": x_gap,
            "bar_height_pt": 0.28 * pitch,
            "within_pair_bar_gap_pt": (0.38 - 0.28) * pitch,
            "range_linewidth_pt": 0.6,
            "range_cap_full_height_pt": 2.2,
            "two_rows_at_4_0901in_projected_spacing_pt": old_two_row_pitch,
            "two_rows_projected_label_gap_pt": old_two_row_pitch - label_height,
        }
        if len(bar_patches) != len(document["paired_records"]) * 2:
            if model == "both":
                raise RuntimeError(
                    "A measured condition was omitted from the horizontal bars."
                )
        output.parent.mkdir(parents=True, exist_ok=True)
        files = list(style.save_figure(figure, output))
        for file in files:
            figure.savefig(file, bbox_inches=figure.bbox_inches, pad_inches=0, dpi=300)
        svg = output.with_suffix(".svg")
        figure.savefig(svg, bbox_inches=figure.bbox_inches, pad_inches=0)
        files.append(svg)
        plt.close(figure)
    import pymupdf

    pdf = pymupdf.open(output.with_suffix(".pdf"))
    page = pdf[0]
    if "assembly" in page.get_text().lower():
        raise RuntimeError("A prohibited chart label was rendered.")
    spans = [
        span
        for block in page.get_text("dict")["blocks"]
        for line in block.get("lines", [])
        for span in line["spans"]
        if span["text"].strip()
    ]
    scale = 6.3 * 72 / page.rect.width
    minimum = min(span["size"] for span in spans) * scale
    final_height = page.rect.height * scale / 72
    if minimum < 8:
        raise RuntimeError(
            "Horizontal scaling text is below eight points at final width."
        )
    for panel in panels:
        panel["final_axis_inches"] = [length * scale for length in panel["axis_inches"]]
    page.get_pixmap(matrix=pymupdf.Matrix(2, 2)).save(
        output.with_name(output.name + "-review.png")
    )
    pdf.close()
    summaries = []
    for name in models:
        shapes, conditions = selections[name]
        for shape in shapes:
            for cores in sorted(core for grid, core in conditions if grid == shape):
                item = conditions[shape, cores]
                summaries.append(
                    {
                        "model": name,
                        "shape": list(shape),
                        "cpu_cores": cores,
                        "gpu_devices": item["record"]["gpu_devices"],
                        "batch_steps": item["record"]["batch_steps"],
                        **(
                            {"active_workers": item["record"]["active_workers"]}
                            if "active_workers" in item["record"]
                            else {}
                        ),
                        **{
                            key: item["record"][key]
                            for key in (
                                "series_kind",
                                "run_id",
                                "nonempty_spatial_owners_by_route",
                            )
                            if key in item["record"]
                        },
                        **item["summaries"],
                    }
                )
    selected_coverage = (
        coverage_by_model if model == "both" else coverage_by_model[model]
    )
    evidence = {
        "presentation": "cpu_scaling_absolute_rates",
        "mode": "cpu_scaling",
        "model": model,
        "font_family": font,
        "models": list(models),
        "status": document["status"],
        "canvas_inches": list(canvas),
        "bar_orientation": "horizontal",
        "layout": "one_row_six_facets" if model == "both" else "one_row_three_facets",
        "row_metrics": row_metrics,
        "generic_width_findings": allowed_width_findings,
        "permitted_layout_exception": "The requested six-facet strip keeps all budgets at fixed page height. Generic narrow-panel findings are retained, with independent text, row-spacing and canvas-bound checks.",
        "final_width_inches": 6.3,
        "final_height_inches": final_height,
        "minimum_effective_font_pt": minimum,
        "rate_unit": f"{unit} useful updates/s",
        "rate_scale_from_million": 1 / divisor,
        "point_definition": "useful_updates / median_seconds",
        "series_kind": (
            "fixed_scaling"
            if document["status"] == "accepted"
            else "historical_diagnostic"
        ),
        "cpu_count_definition": "configured fixed-scaling budget. SW teams equal the budget. EBM teams equal min(budget,bands), with nonempty owners recorded separately.",
        "range_definition": "minimum and maximum of the twelve individual useful-update rates",
        "facets": panels,
        "coverage": selected_coverage,
        "coverage_by_model": coverage_by_model,
        "condition_count": len(summaries),
        "grid_count": len(panels),
        "raw_time_count": len(summaries) * REPEATS * 2,
        "caption_text": caption_text(document, model, selected_coverage),
        "paired_summaries": summaries,
        "paired_input": document,
        "input_identity": document.get("render_input_identity"),
        "renderer_identity": {
            "path": str(Path(__file__).resolve().relative_to(ROOT)),
            "sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        },
        "summary_helper_identity": {
            "path": "scripts/render_performance_bars.py",
            "sha256": hashlib.sha256(
                (LOCAL / "render_performance_bars.py").read_bytes()
            ).hexdigest(),
        },
        "findings": issues,
        "outputs": {
            str(path): hashlib.sha256(Path(path).read_bytes()).hexdigest()
            for path in files
        },
    }
    output.with_suffix(".json").write_text(json.dumps(evidence, indent=2) + "\n")
    return evidence


def main():
    """Render accepted CPU data or an explicitly historical matched-data inspection."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path)
    parser.add_argument("--historical", action="store_true")
    parser.add_argument("--model", choices=["sw", "ebm", "both"], required=True)
    parser.add_argument(
        "--rate-unit", choices=["auto", "million", "billion"], default="auto"
    )
    parser.add_argument("--output", type=Path)
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--expected-steps", type=int)
    parser.add_argument(
        "--font-family",
        choices=["Helvetica Neue", "Open Sans", "Nimbus Sans"],
        default="Helvetica Neue",
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
        parser.error("Choose one accepted input or historical inspection.")
    if args.historical:
        document = historical_input()
        document["paired_records"] = [
            record
            for record in document["paired_records"]
            if record["platform"] == "cpu"
        ]
        input_path = ROOT / document["source_record"]
    else:
        input_path = args.input
        document = json.loads(input_path.read_text())
    if args.audit_only or args.expected_steps is not None:
        try:
            models = ("sw", "ebm") if args.model == "both" else (args.model,)
            selections = {name: select_conditions(document, name) for name in models}
            records = [
                item["record"]
                for _, conditions in selections.values()
                for item in conditions.values()
            ]
            report = audit_selected_records(
                document,
                records,
                expected_steps=args.expected_steps,
                expected_series_kind="fixed_scaling",
            )
            report["coverage_by_model"] = {
                name: coverage_record(document, shapes, conditions)
                for name, (shapes, conditions) in selections.items()
            }
        except (ValueError, KeyError, TypeError) as error:
            parser.error(str(error))
        if args.audit_only:
            print(json.dumps(report, indent=2))
            return
    if document["status"] == "historical" and "historical" not in args.output.name:
        parser.error(
            "A historical output filename must identify its historical status."
        )
    document["render_input_identity"] = {
        "path": str(input_path),
        "sha256": hashlib.sha256(input_path.read_bytes()).hexdigest(),
    }
    evidence = draw_scaling(
        document,
        args.model,
        args.output,
        load_style(args.font_family, args.font_file),
        args.rate_unit,
        font_family=args.font_family,
    )
    print(
        json.dumps(
            {
                key: evidence[key]
                for key in [
                    "presentation",
                    "mode",
                    "model",
                    "status",
                    "minimum_effective_font_pt",
                    "final_height_inches",
                    "condition_count",
                    "grid_count",
                    "raw_time_count",
                ]
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

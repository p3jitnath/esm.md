"""Draw horizontal matched-rate pairs in platform rows and grid columns."""

from __future__ import annotations

import hashlib
import math
import statistics
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter, MaxNLocator


def _conditions_by_grid(conditions, model):
    """Validate six conditions and the reciprocal-median-time rate definition."""
    if model not in ("sw", "ebm") or len(conditions) != 6:
        raise ValueError(
            "Supply six matched CPU/GPU conditions for one supported model."
        )
    selected = {}
    budgets = set()
    for record in conditions:
        platform = record["platform"]
        shape = tuple(record["shape"])
        if record["model"] != model or platform not in ("cpu", "gpu"):
            raise ValueError("Every condition must belong to this model and CPU/GPU.")
        if len(shape) != (2 if model == "sw" else 1) or any(
            type(value) is not int or value < 1 for value in shape
        ):
            raise ValueError("Use positive integer interior-grid dimensions.")
        if type(record["batch_steps"]) is not int or record["batch_steps"] < 1:
            raise ValueError(
                "A complete-update batch needs a positive integer step count."
            )
        if platform == "cpu":
            cores = record["cpu_cores"]
            if type(cores) is not int or cores < 1 or record["gpu_devices"] != 0:
                raise ValueError(
                    "CPU conditions need an explicit positive core budget."
                )
            budgets.add(cores)
        elif record["gpu_devices"] != 1:
            raise ValueError("The GPU row requires exactly one device per condition.")
        key = (platform, shape)
        if key in selected:
            raise ValueError("A repeated grid cannot replace a missing condition.")
        pairs = record["paired_samples"]
        if len(pairs) != 12 or {pair["repeat"] for pair in pairs} != set(range(12)):
            raise ValueError("Every condition needs twelve distinct raw timing pairs.")
        useful_updates = math.prod(shape) * record["batch_steps"]
        for series, time_key in (
            ("baseline", "baseline_seconds"),
            ("esm_md", "esm_md_seconds"),
        ):
            times = [float(pair[time_key]) for pair in pairs]
            if any(not math.isfinite(value) or value <= 0 for value in times):
                raise ValueError(
                    "Raw complete-update times must be finite and positive."
                )
            rates = [useful_updates / value / 1e6 for value in times]
            expected = {
                "point": useful_updates / statistics.median(times) / 1e6,
                "median": statistics.median(rates),
                "minimum": min(rates),
                "maximum": max(rates),
            }
            measured = record["statistics"][series]
            if measured["count"] != 12 or any(
                not math.isclose(float(measured[name]), value, rel_tol=1e-11)
                for name, value in expected.items()
            ):
                raise ValueError(
                    "Rate statistics must retain raw ranges and useful updates / median seconds."
                )
        selected[key] = record
    shapes = sorted(
        {shape for platform, shape in selected if platform == "cpu"},
        key=lambda shape: (math.prod(shape), shape),
    )
    if (
        len(budgets) != 1
        or len(shapes) != 3
        or any(("gpu", shape) not in selected for shape in shapes)
    ):
        raise ValueError(
            "Use three shared grids and one explicitly selected CPU budget."
        )
    return shapes, selected, next(iter(budgets))


def _number(value):
    """Format an absolute rate with readable digits and thousands separators."""
    if value == 0:
        return "0"
    if value < 0.001 or value >= 1e7:
        return f"{value:.3g}"
    decimals = max(0, 2 - math.floor(math.log10(abs(value))))
    return f"{value:,.{decimals}f}"


def draw_rate_panels(
    conditions,
    model,
    output,
    profile,
    style,
    root,
    blue,
    orange,
    workload_label,
    historical=False,
    rate_unit="auto",
    font_family=None,
):
    """Draw six facets of matched, absolute useful-update throughput.

    Parameters
    ----------
    conditions : list of dict
        Six original CPU/GPU conditions. Each contains twelve raw time pairs and
        ``statistics`` for ``baseline`` and ``esm_md`` in millions of useful
        updates per second. The point is useful updates divided by median time;
        the separate median and range describe the twelve individual rates.
    model : {'sw', 'ebm'}
        Model whose three shared interior grids will form the figure columns.
    output : pathlib.Path or str
        Local export prefix for PDF, PNG and SVG; no caption or provenance is written.
    profile : {'paper', 'poster'}
        Final-size typography and canvas geometry.
    style : module
        Selected publication helper with font registration, audit and export functions.
    root : pathlib.Path or str
        Project root used to locate the selected fonts.
    blue, orange : str
        ESM.md and baseline colours, respectively.
    workload_label : callable
        Existing function that formats the actual model and interior-grid shape.
    historical : bool, optional
        Show a visible stand-in disclosure. Existing historical CPU data use one core.
    rate_unit : {'auto', 'million', 'billion'}, optional
        Common absolute unit for all six facets. Auto selects billions when any
        individual rate reaches one billion updates per second.
    font_family : str or None, optional
        Explicit font selection. Omission preserves the paper or poster family.

    Returns
    -------
    dict
        Export hashes, final-size font and canvas checks, visible units, and every
        facet's linear limits and physical dimensions. The caller owns the caption,
        complete numerical record, acceptance evidence and publication decision.

    Raises
    ------
    ValueError
        If conditions, rates, selected CPU budget or requested profile are invalid.
    RuntimeError
        If font size, panel dimensions, numeric labels or final export do not fit.

    Notes
    -----
    Each facet has its own zero-based linear rate axis. Each bar point is useful
    interior updates divided by median complete-update time. Whiskers are the
    observed minimum and maximum individual rates, not a confidence interval.
    Native canvases remain fixed during export so final font and poster fit are
    checked against the actual placement width rather than a tight crop.
    """
    shapes, selected, budget = _conditions_by_grid(conditions, model)
    if profile not in ("paper", "poster"):
        raise ValueError("Select the paper or poster typography profile.")
    if historical and budget != 1:
        raise ValueError("The existing historical stand-in has a one-core CPU budget.")
    if rate_unit not in ("auto", "million", "billion"):
        raise ValueError("Use a common absolute million or billion rate unit.")
    largest = max(
        float(record["statistics"][series]["maximum"])
        for record in conditions
        for series in ("baseline", "esm_md")
    )
    if rate_unit == "auto":
        rate_unit = "billion" if largest >= 1000 else "million"
    divisor = 1000 if rate_unit == "billion" else 1
    unit_label = f"Rate [{rate_unit} useful updates/s]"
    poster = profile == "poster"
    width, height = (14.2, 5.6) if poster else (6.3, 3.35)
    font_size = 25 if poster else 8.5
    font = font_family or ("Open Sans" if poster else "Helvetica Neue")
    final_width_mm = 364.249 if poster else width * 25.4
    final_minimum = 24.5 if poster else 8
    settings = {
        "font.size": font_size,
        "axes.labelsize": font_size,
        "xtick.labelsize": font_size,
        "ytick.labelsize": font_size,
        "legend.fontsize": font_size,
        "axes.linewidth": 0.7 if not poster else 1.0,
        "pdf.fonttype": 42,
        "svg.fonttype": "path",
    }
    output = Path(output)
    geometry = []
    with style.publication_style(settings, font_family=font, project_root=root):
        figure, axes = plt.subplots(2, 3, figsize=(width, height), squeeze=False)
        figure.subplots_adjust(
            left=0.17,
            right=0.975,
            bottom=0.23 if poster else 0.12,
            top=0.80 if poster else 0.79,
            hspace=0.65 if poster else 0.50,
            wspace=0.28,
        )
        annotations = []
        worker_annotations = []
        platform_annotations = []
        for row, platform in enumerate(("cpu", "gpu")):
            for column, shape in enumerate(shapes):
                axis = axes[row, column]
                record = selected[platform, shape]
                bars = []
                for position, series, colour in (
                    (1, "baseline", orange),
                    (0, "esm_md", blue),
                ):
                    sample = record["statistics"][series]
                    point = float(sample["point"]) / divisor
                    low = float(sample["minimum"]) / divisor
                    high = float(sample["maximum"]) / divisor
                    rectangle = axis.barh(
                        position,
                        point,
                        height=0.90 if poster else 0.64,
                        color=colour,
                        edgecolor="#333333",
                        linewidth=0.3 if not poster else 0.5,
                        zorder=2,
                    )[0]
                    if poster and platform == "cpu" and not historical:
                        teams = record.get("active_workers")
                        workers = teams.get(series) if isinstance(teams, dict) else None
                        if workers is not None:
                            if type(workers) is not int or workers < 1:
                                raise ValueError(
                                    "A supplied CPU worker count must be a positive integer."
                                )
                            worker_label = axis.text(
                                point / 2,
                                position,
                                f"{workers:,}",
                                ha="center",
                                va="center",
                                fontsize=font_size,
                                color="black" if series == "baseline" else "white",
                                zorder=4,
                            )
                            worker_annotations.append((axis, rectangle, worker_label))
                    axis.errorbar(
                        point,
                        position,
                        xerr=[[max(0, point - low)], [max(0, high - point)]],
                        fmt="none",
                        color="#222222",
                        elinewidth=0.65 if not poster else 1.0,
                        capsize=2 if not poster else 4,
                        zorder=3,
                    )
                    bars.append((position, series, point, high))
                highest = max(item[3] for item in bars)
                required_right = highest * (1.47 if poster else 1.30)
                tick_right = MaxNLocator(nbins=2, min_n_ticks=2).tick_values(
                    0, required_right
                )[-1]
                axis.set_xlim(0, tick_right)
                axis.set_xticks(
                    [0, tick_right] if poster else [0, tick_right / 2, tick_right]
                )
                axis.set_ylim(-0.5, 1.5)
                if column == 0:
                    axis.set_yticks([1, 0], ["Hand-tuned\nbaseline", "ESM.md"])
                else:
                    axis.set_yticks([])
                axis.tick_params(axis="y", length=0, pad=5 if poster else 3)
                axis.xaxis.set_major_formatter(
                    FuncFormatter(lambda value, _: _number(value))
                )
                axis.tick_params(
                    axis="x", length=4 if poster else 2, pad=3 if poster else 1.5
                )
                style.finish_axis(axis)
                axis.spines["left"].set_visible(False)
                axis.grid(axis="x", color="#DCE2E5", linewidth=0.5, zorder=0)
                for position, series, point, high in bars:
                    label = axis.text(
                        high + highest * 0.045,
                        position,
                        _number(point),
                        ha="left",
                        va="center",
                        fontsize=font_size,
                        color="#222222",
                    )
                    annotations.append((axis, label))
                box = axis.get_position()
                geometry.append(
                    {
                        "platform": platform,
                        "shape": list(shape),
                        "cpu_core_budget": budget if platform == "cpu" else None,
                        "gpu_devices": 1 if platform == "gpu" else 0,
                        "axis_inches": [box.width * width, box.height * height],
                        "x_limits": list(axis.get_xlim()),
                        "rate_limits": list(axis.get_xlim()),
                        "rate_axis": "x",
                        "platform_row": row,
                        "grid_column": column,
                        "point_labels": {
                            series: _number(
                                float(record["statistics"][series]["point"]) / divisor
                            )
                            for series in ("baseline", "esm_md")
                        },
                    }
                )
            first = axes[row, 0].get_position()
            label = (
                f"CPU budget {budget:,} [cores]"
                if platform == "cpu"
                else "GPU 1 [device]"
            )
            row_heading = figure.text(
                0.56,
                first.y1 + (0.06 if row == 0 else 0.05),
                label,
                ha="center",
                va="center",
                fontsize=font_size,
            )
            platform_annotations.append(row_heading)
        for column, shape in enumerate(shapes):
            box = axes[0, column].get_position()
            label = workload_label(model, list(shape)) + (
                " [cells]" if model == "sw" else " [bands]"
            )
            figure.text(
                (box.x0 + box.x1) / 2,
                0.96,
                label,
                ha="center",
                va="center",
                fontsize=font_size,
            )
        footer = unit_label
        if worker_annotations:
            footer += " · CPU workers inside bars"
        footer_artist = figure.text(
            0.56,
            0.005,
            footer,
            fontsize=font_size,
            ha="center",
            va="bottom",
        )
        if historical:
            figure.text(
                0.996,
                0.50,
                "HISTORICAL STAND-IN",
                rotation=90,
                ha="right",
                va="center",
                fontsize=font_size,
                color="#555555",
            )
        style_findings = style.audit_figure(
            figure, expected_font=font, min_font_size=font_size, project_root=root
        )
        strip_size_findings = [
            item
            for item in style_findings
            if item.startswith("Axis ") and " x " in item
        ]
        findings = [item for item in style_findings if item not in strip_size_findings]
        if findings:
            plt.close(figure)
            raise RuntimeError(
                "Direct-rate figure audit failed. " + ". ".join(findings)
            )
        renderer = figure.canvas.get_renderer()
        for heading in [footer_artist, *platform_annotations]:
            heading_box = heading.get_window_extent(renderer)
            for axis in axes.flat:
                for tick in axis.xaxis.get_major_ticks():
                    if tick.label1.get_visible() and heading_box.overlaps(
                        tick.label1.get_window_extent(renderer)
                    ):
                        raise RuntimeError(
                            "A platform heading or common rate footer overlaps a rate tick label."
                        )
        for axis, label in annotations:
            text_box = label.get_window_extent(renderer)
            axis_box = axis.get_window_extent(renderer)
            if (
                text_box.x0 < axis_box.x0 - 0.5
                or text_box.x1 > axis_box.x1 + 0.5
                or text_box.y0 < axis_box.y0 - 0.5
                or text_box.y1 > axis_box.y1 + 0.5
            ):
                plt.close(figure)
                raise RuntimeError(
                    f"Numeric point label {label.get_text()!r} exceeds strip "
                    f"{figure.axes.index(axis) + 1} ({profile})."
                )
        inset = figure.dpi / 72
        for axis, rectangle, label in worker_annotations:
            text_box = label.get_window_extent(renderer)
            bar_box = rectangle.get_window_extent(renderer)
            if (
                text_box.x0 < bar_box.x0 + inset
                or text_box.x1 > bar_box.x1 - inset
                or text_box.y0 < bar_box.y0 + inset
                or text_box.y1 > bar_box.y1 - inset
            ):
                plt.close(figure)
                raise RuntimeError(
                    f"CPU worker count {label.get_text()!r} does not fit inside its bar in strip {figure.axes.index(axis) + 1}."
                )
        files = list(style.save_figure(figure, output))
        # Keep the exact paper and poster placement canvases after the shared export.
        for path in files:
            figure.savefig(path, bbox_inches=figure.bbox_inches, pad_inches=0, dpi=300)
        svg = output.with_suffix(".svg")
        figure.savefig(svg, bbox_inches=figure.bbox_inches, pad_inches=0)
        files.append(svg)
        plt.close(figure)
    import pymupdf

    with pymupdf.open(output.with_suffix(".pdf")) as pdf:
        page = pdf[0]
        visible_text = page.get_text()
        if "assembly" in visible_text.lower():
            raise RuntimeError("A prohibited chart word was rendered.")
        spans = [
            span
            for block in page.get_text("dict")["blocks"]
            for line in block.get("lines", [])
            for span in line["spans"]
            if span["text"].strip()
        ]
        if not spans or unit_label not in visible_text:
            raise RuntimeError("The final PDF has missing rate units or text.")
        scale = final_width_mm / (page.rect.width / 72 * 25.4)
        minimum_font = min(span["size"] for span in spans) * scale
        final_height_mm = page.rect.height / 72 * 25.4 * scale
        if minimum_font + 1e-6 < final_minimum:
            raise RuntimeError("Final-size type is below the required minimum.")
        if poster and final_height_mm > 145 + 1e-6:
            raise RuntimeError("The final poster figure exceeds its 145 mm slot.")
    return {
        "profile": profile,
        "native_canvas_inches": [width, height],
        "final_canvas_mm": [final_width_mm, final_height_mm],
        "font_family": font,
        "native_font_pt": font_size,
        "minimum_effective_font_pt": minimum_font,
        "visible_units": unit_label,
        "rate_divisor_from_millions": divisor,
        "bar_orientation": "horizontal",
        "panel_arrangement": "CPU and GPU rows by three grid columns",
        "ordinary_panel_size_findings": strip_size_findings,
        "strip_geometry_basis": "Two-bar strips retain the requested fixed canvas and type size. Text and worker labels receive explicit bounds checks.",
        "geometry": geometry,
        "findings": findings,
        "export_policy": "full_canvas",
        "outputs": {
            str(path): hashlib.sha256(Path(path).read_bytes()).hexdigest()
            for path in files
        },
    }

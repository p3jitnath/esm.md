"""Draw the eight-route language comparison in the retained scatter style."""

from __future__ import annotations
import argparse
import hashlib
import importlib.util
import json
import math
from pathlib import Path

from poster_comparison_input import validate_fresh_input

ROOT = Path(__file__).resolve().parents[1]
ROUTES = (
    "assembly",
    "esm",
    "fortran_tuned",
    "fortran_vanilla",
    "julia_tuned",
    "julia_vanilla",
    "python_tuned",
    "python_vanilla",
)
LABELS = (
    "Assembly",
    "ESM.md",
    "Fortran Tuned",
    "Fortran Vanilla",
    "Julia Tuned",
    "Julia Vanilla",
    "Python Tuned",
    "Python Vanilla",
)
GROUP_LABELS = ("Assembly", "ESM.md", "Fortran", "Julia", "Python")
GROUP_POSITIONS = (0, 1, 2.5, 4.5, 6.5)
COLOURS = ("#681FB1", "#00A6A2", "#29347A")
MARKERS = ("o", "s", "D")
SIZES = {"sw": (64, 256, 1024), "ebm": (128, 4096, 65536)}


def tick_text(value):
    """Return a plain numeric tick with grouped thousands.

    Parameters
    ----------
    value : float
        Positive rate, or zero for a linear axis.

    Returns
    -------
    str
        Plain decimal text without scientific notation.
    """
    if value >= 1 or value == 0:
        return f"{value:,.0f}"
    return f"{value:.8f}".rstrip("0").rstrip(".")


def display_series(data, layout_draft):
    """Select the explicit archived adapter or accepted fresh observations.

    Parameters
    ----------
    data : dict
        Accepted compact plotting input, or unchanged archived language data.
    layout_draft : bool
        Required explicit permission to draw archived data as a private layout.

    Returns
    -------
    tuple of list of dict and str
        Displayed observations and their rendering status.

    Raises
    ------
    ValueError
        If input status, route coverage, units or observation records are invalid.

    Notes
    -----
    Metadata consistency does not independently establish scientific acceptance.
    The root-reviewed numerical and timing evidence remains separate.
    """
    if "plotted_data" in data:
        if not layout_draft:
            raise ValueError("Archived observations require --layout-draft.")
        records = []
        for model in SIZES:
            for device in ("CPU", "GPU"):
                rows = data["plotted_data"][model][device.lower()]
                if len(rows) != 7 or [row["label"] for row in rows] != data["series"]:
                    raise ValueError(
                        "Keep the seven original archived routes unchanged."
                    )
                divisor = 1 if device == "CPU" else 1000
                for index, row in enumerate(rows):
                    for item in row["measurements"]:
                        records.append(
                            {
                                "route": ROUTES[index + 1],
                                "label": LABELS[index + 1],
                                "model": model,
                                "device": device,
                                "size": item["size"],
                                "point": float(item["median"]) / divisor,
                                "low": float(item["minimum"]) / divisor,
                                "high": float(item["maximum"]) / divisor,
                                "rates": [
                                    float(v) / divisor
                                    for v in item["million_updates_per_second"]
                                ],
                                "source_measurement": item,
                                "resource": (
                                    {"cpu_budget": 1, "actual_workers": 1}
                                    if device == "CPU"
                                    else {"gpu_count": 1}
                                ),
                            }
                        )
        return records, "private_archived_layout_draft"
    validated = validate_fresh_input(data)
    return validated["series"], "accepted"


def portable_path(path, poster_root, accepted):
    """Keep accepted publication identities relative to their poster directory.

    Parameters
    ----------
    path, poster_root : pathlib.Path
        Artifact path and its publication directory.
    accepted : bool
        Whether the artifact is part of an accepted fresh publication.

    Returns
    -------
    str
        Poster-relative identity, or an explicit private draft path.

    Raises
    ------
    ValueError
        If an accepted artifact is outside the poster directory.
    """
    try:
        return Path(path).resolve().relative_to(Path(poster_root).resolve()).as_posix()
    except ValueError:
        if accepted:
            raise ValueError(
                "Accepted plotting files must stay inside the poster directory."
            ) from None
        return str(path)


def render(data, model, profile, output, poster_root, layout_draft, font_file=None):
    """Draw the reference scatter style without changing supplied rates.

    Parameters
    ----------
    data : dict
        Accepted fresh observations or explicitly private archived observations.
    model : {'sw','ebm'}
        Model shown by the two processor axes.
    profile : {'poster','paper'}
        Physical size and typography.
    output : pathlib.Path
        Prefix for PDF, SVG, PNG and the encoding receipt.
    poster_root : pathlib.Path
        Existing publication styles and font assets.
    layout_draft : bool
        Whether the archived private adapter is allowed.
    font_file : pathlib.Path or None
        Permitted external font registration, without copying the file.

    Returns
    -------
    dict
        Original input identity, exact displayed observations and export checks.

    Raises
    ------
    ValueError
        If observations, units or coverage are incomplete.
    RuntimeError
        If required typography or label bounds cannot be met.
    """
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    from matplotlib.ticker import FuncFormatter
    import pymupdf

    records, status = display_series(data, layout_draft)
    if status == "accepted":
        portable_path(output, poster_root, True)
    poster = profile == "poster"
    width, height, size = (14.2, 6.6, 25) if poster else (6.3, 3.35, 8.5)
    font = "Open Sans" if poster else "Helvetica Neue"
    spec = importlib.util.spec_from_file_location(
        "plotting_module", poster_root / "scripts/render_performance_bars.py"
    )
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    style = helper.load_style(font, font_file)
    settings = {
        "font.size": size,
        "axes.labelsize": size,
        "xtick.labelsize": size,
        "ytick.labelsize": size,
        "legend.fontsize": size,
        "axes.linewidth": 0.7,
        "hatch.linewidth": 0.6 if poster else 0.35,
        "pdf.fonttype": 42,
        "svg.fonttype": "path",
    }
    if poster:
        settings.update(
            {
                "text.color": "#000000",
                "axes.labelcolor": "#000000",
                "xtick.color": "#000000",
                "ytick.color": "#000000",
            }
        )
    displayed, axis_records = [], []
    with style.publication_style(settings, font_family=font, project_root=poster_root):
        figure, axes = plt.subplots(1, 2, figsize=(width, height), sharey=True)
        figure.subplots_adjust(
            left=0.255 if poster else 0.24,
            right=0.985,
            bottom=0.18 if poster else 0.22,
            top=0.82,
            wspace=0.19,
        )
        for axis, device in zip(axes, ("CPU", "GPU")):
            axis.axhspan(0.53, 1.47, color="#EEF1F4", zorder=0)
            for boundary in (0.5, 1.5, 3.5, 5.5):
                axis.axhline(
                    boundary,
                    color="#69757E",
                    alpha=0.15,
                    linewidth=0.8 if poster else 0.5,
                    zorder=1,
                )
            subset = [
                item
                for item in records
                if item["model"] == model and item["device"] == device
            ]
            bounds = []
            for route_index, route in enumerate(ROUTES):
                selected = [item for item in subset if item["route"] == route]
                if not selected and route == "assembly" and status != "accepted":
                    axis.text(
                        0.5,
                        0,
                        "Pending",
                        transform=axis.get_yaxis_transform(),
                        ha="center",
                        va="center",
                        fontsize=size,
                        color="#000000" if poster else "#777777",
                    )
                    continue
                if sorted(item["size"] for item in selected) != list(SIZES[model]):
                    raise ValueError(
                        "Every displayed route needs its three workload grids."
                    )
                for grid, grid_size in enumerate(SIZES[model]):
                    item = next(item for item in selected if item["size"] == grid_size)
                    point, low, high = [
                        float(item[key]) for key in ("point", "low", "high")
                    ]
                    if not 0 < low <= point <= high or len(item["rates"]) != 12:
                        raise ValueError(
                            "Each point needs its original twelve observations and range."
                        )
                    y = route_index + (grid - 1) * 0.29
                    vanilla = route_index in (3, 5, 7)
                    axis.errorbar(
                        point,
                        y,
                        xerr=[[point - low], [high - point]],
                        fmt="none",
                        color=COLOURS[grid],
                        ecolor=COLOURS[grid],
                        elinewidth=1.35 if poster else 0.7,
                        capsize=2.5 if poster else 1.4,
                        capthick=1.25 if poster else 0.65,
                        zorder=2,
                    )
                    axis.scatter(
                        [point],
                        [y],
                        marker=MARKERS[grid],
                        s=(9.0 if poster else 4.0) ** 2,
                        facecolors="white" if vanilla else COLOURS[grid],
                        edgecolors=COLOURS[grid],
                        linewidths=1.4 if poster else 0.65,
                        hatch=(
                            ("//////" if poster else "////////////")
                            if vanilla
                            else None
                        ),
                        zorder=3,
                    )
                    bounds.extend([low, high])
                    displayed.append(
                        {
                            "model": model,
                            "device": device,
                            "route": route,
                            "label": LABELS[route_index],
                            "size": grid_size,
                            "grid_marker": MARKERS[grid],
                            "grid_colour": COLOURS[grid],
                            "marker_fill": "hatched" if vanilla else "solid",
                            "y": y,
                            "point": point,
                            "low": low,
                            "high": high,
                            "source_record": item,
                        }
                    )
            axis.set_ylim(7.65, -0.65)
            axis.set_yticks(GROUP_POSITIONS, GROUP_LABELS)
            axis.tick_params(
                axis="y",
                length=0,
                pad=8 if poster else 4,
                labelleft=device == "CPU",
                labelright=False,
            )
            axis.tick_params(
                axis="x", length=3 if poster else 2, pad=5 if poster else 3
            )
            axis.xaxis.set_major_formatter(
                FuncFormatter(lambda value, _: tick_text(value))
            )
            axis.set_xscale("log")
            lo, hi = min(bounds) / 1.4, max(bounds) * 1.5
            axis.set_xlim(lo, hi)
            axis.set_xticks(
                [
                    10**power
                    for power in range(
                        math.floor(math.log10(lo)), math.ceil(math.log10(hi)) + 1
                    )
                    if lo <= 10**power <= hi
                ]
            )
            axis.minorticks_off()
            if device == "CPU":
                axis.get_yticklabels()[1].set_fontweight("bold")
                budgets = sorted({item["resource"]["cpu_budget"] for item in subset})
                if len(budgets) != 1:
                    raise ValueError(
                        "A processor axis needs one declared configured CPU budget."
                    )
                core_label = str(budgets[0])
                title = (
                    f"CPU · {core_label} cores · log"
                    if status == "accepted"
                    else f"CPU · {budgets[0]} [core] · log"
                )
            else:
                title = (
                    "GPU · 1 GH200 · log"
                    if status == "accepted"
                    else "GPU · 1 [device] · log"
                )
            axis.xaxis.set_major_formatter(
                FuncFormatter(lambda value, _: tick_text(value))
            )
            style.finish_axis(axis)
            axis.spines["left"].set_visible(False)
            axis.spines["bottom"].set_color("#8B979F")
            axis.grid(
                axis="x", color="#D8DFE3", linewidth=0.6 if poster else 0.5, zorder=0
            )
            position = axis.get_position()
            figure.text(
                (position.x0 + position.x1) / 2,
                0.875,
                title,
                fontsize=size,
                ha="center",
                va="center",
            )
            figure.text(
                (position.x0 + position.x1) / 2,
                0.055 if poster else 0.085,
                (
                    "Cell updates [million/s]"
                    if device == "CPU"
                    else "Cell updates [billion/s]"
                ),
                fontsize=size,
                ha="center",
                va="center",
            )
            axis_records.append(
                {
                    "device": device,
                    "scale": "logarithmic absolute rates",
                    "limits": [float(value) for value in axis.get_xlim()],
                    "ticks": [float(value) for value in axis.get_xticks()],
                    "axis_inches": [position.width * width, position.height * height],
                    "header": title,
                }
            )
        handles = [
            Line2D(
                [],
                [],
                color=colour,
                marker=marker,
                linestyle="none",
                markersize=9 if poster else 4,
                label=(
                    f"{grid_size:,}² cells" if model == "sw" else f"{grid_size:,} bands"
                ),
            )
            for grid_size, colour, marker in zip(SIZES[model], COLOURS, MARKERS)
        ]
        handles.extend(
            [
                axes[0].scatter(
                    [],
                    [],
                    marker="o",
                    s=(11 if poster else 5) ** 2,
                    facecolors="#59636B",
                    edgecolors="#59636B",
                    linewidths=1.4 if poster else 0.65,
                    label="Tuned",
                ),
                axes[0].scatter(
                    [],
                    [],
                    marker="o",
                    s=(11 if poster else 5) ** 2,
                    facecolors="white",
                    edgecolors="#59636B",
                    linewidths=1.4 if poster else 0.65,
                    hatch="//////" if poster else "////////////",
                    label="Vanilla",
                ),
            ]
        )
        legend = figure.legend(
            handles=handles,
            loc="upper center",
            bbox_to_anchor=(0.55, 1.005),
            ncol=5,
            frameon=False,
            fontsize=size,
            columnspacing=0.7,
            handletextpad=0.35,
            handlelength=1.1,
            borderpad=0,
        )
        if status != "accepted":
            figure.text(
                0.015,
                0.875,
                "LAYOUT ONLY",
                fontsize=size,
                color="#000000" if poster else "#777777",
                ha="left",
                va="center",
            )
        figure.canvas.draw()
        renderer = figure.canvas.get_renderer()
        original_bounds = figure.get_tightbbox(renderer)
        shift_inches = width / 2 - (original_bounds.x0 + original_bounds.x1) / 2
        shift_fraction = shift_inches / width
        for axis in axes:
            axis.set_position(axis.get_position().translated(shift_fraction, 0))
        for annotation in figure.texts:
            x, y = annotation.get_position()
            annotation.set_position((x + shift_fraction, y))
        anchor = legend.get_bbox_to_anchor().transformed(figure.transFigure.inverted())
        legend.set_bbox_to_anchor(
            anchor.translated(shift_fraction, 0), transform=figure.transFigure
        )
        figure.canvas.draw()
        renderer = figure.canvas.get_renderer()
        centred_bounds = figure.get_tightbbox(renderer)
        centre_error = (centred_bounds.x0 + centred_bounds.x1 - width) / 2
        if (
            abs(centre_error) > 1e-8
            or abs(centred_bounds.width - original_bounds.width) > 1e-8
        ):
            raise RuntimeError(
                "Horizontal centring changed the artwork width or missed the canvas centre."
            )
        if centred_bounds.x0 < 0 or centred_bounds.x1 > width:
            raise RuntimeError("The centred artwork exceeds the fixed canvas.")
        alignment = {
            "method": "One horizontal translation of all axes, figure text and legend from their combined tight bounds.",
            "shift_inches": shift_inches,
            "shift_canvas_fraction": shift_fraction,
            "original_bounds_inches": list(original_bounds.extents),
            "centred_bounds_inches": list(centred_bounds.extents),
            "left_margin_inches": centred_bounds.x0,
            "right_margin_inches": width - centred_bounds.x1,
            "centre_error_inches": centre_error,
            "canvas_inches": [width, height],
        }
        issues = style.audit_figure(
            figure, expected_font=font, min_font_size=size, project_root=poster_root
        )
        if issues:
            raise RuntimeError("Figure style audit failed. " + ". ".join(issues))
        renderer = figure.canvas.get_renderer()
        legend_box = legend.get_window_extent(renderer)
        if legend_box.x0 < 0 or legend_box.x1 > figure.bbox.x1:
            raise RuntimeError(
                "The combined grid and control legend exceeds the canvas."
            )
        for axis in axes:
            boxes = [
                tick.get_window_extent(renderer)
                for tick in axis.get_yticklabels()
                if tick.get_visible()
            ]
            if any(a.overlaps(b) for a, b in zip(boxes, boxes[1:])):
                raise RuntimeError("Implementation row labels overlap.")
        output.parent.mkdir(parents=True, exist_ok=True)
        files = [output.with_suffix(suffix) for suffix in (".pdf", ".png", ".svg")]
        for file in files:
            figure.savefig(
                file,
                bbox_inches=figure.bbox_inches,
                pad_inches=0,
                dpi=400 if poster else 300,
            )
        plt.close(figure)
    with pymupdf.open(output.with_suffix(".pdf")) as document:
        page = document[0]
        spans = [
            s
            for block in page.get_text("dict")["blocks"]
            for line in block.get("lines", [])
            for s in line["spans"]
            if s["text"].strip()
        ]
        final_width = 364.249 if poster else 160.02
        scale = final_width / (page.rect.width / 72 * 25.4)
        minimum = min(span["size"] for span in spans) * scale
        final_height = page.rect.height / 72 * 25.4 * scale
        if minimum < (24.5 if poster else 8) - 1e-6:
            raise RuntimeError("The exported text is below the final-size minimum.")
    return {
        "status": status,
        "model": model,
        "profile": profile,
        "presentation": "reference_language_scatter",
        "fresh_measurement": status == "accepted",
        "cohort": data.get("cohort"),
        "point_definition": data.get("point_definition"),
        "displayed_rate_definition": data.get("displayed_rate_definition"),
        "row_order": list(LABELS),
        "row_routes": list(ROUTES),
        "visible_group_labels": list(GROUP_LABELS),
        "group_positions": list(GROUP_POSITIONS),
        "vanilla_marker_hatch_rows": [3, 5, 7],
        "hatched_background_bands": False,
        "marker_size_pt": 9.0 if poster else 4.0,
        "within_row_grid_offset": 0.29,
        "group_separator_positions": [0.5, 1.5, 3.5, 5.5],
        "group_separator_alpha": 0.15,
        "esm_highlight_row_index": 1,
        "grid_colour_shape_key": [
            {"size": grid, "colour": colour, "marker": marker}
            for grid, colour, marker in zip(SIZES[model], COLOURS, MARKERS)
        ],
        "axes": axis_records,
        "horizontal_alignment": alignment,
        "final_width_mm": final_width,
        "final_height_mm": final_height,
        "minimum_effective_font_pt": minimum,
        "displayed_measurements": displayed,
        "source_input": data if status != "accepted" else None,
        "accepted_source_ids": data.get("sources", {}),
        "acceptance_ids": data.get("acceptance", {}),
        "scope": (
            "Archived data are private layout-only observations and Assembly remains empty Pending."
            if status != "accepted"
            else "Accepted supplied summaries are drawn unchanged. Metadata checks do not repeat scientific verification."
        ),
        "findings": issues,
        "outputs": {
            portable_path(file, poster_root, status == "accepted"): hashlib.sha256(
                file.read_bytes()
            ).hexdigest()
            for file in files
        },
    }


def main():
    """Render a selected publication profile and write its encoding receipt."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--model", choices=("sw", "ebm"), required=True)
    parser.add_argument("--profile", choices=("poster", "paper"), required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--poster-root", type=Path, default=ROOT)
    parser.add_argument("--layout-draft", action="store_true")
    parser.add_argument("--font-file", type=Path)
    args = parser.parse_args()
    input_bytes = args.input.read_bytes()
    data = json.loads(input_bytes)
    if data.get("status") == "accepted":
        for path in (args.input, args.output, Path(__file__)):
            portable_path(path, args.poster_root, True)
    receipt = render(
        data,
        args.model,
        args.profile,
        args.output,
        args.poster_root,
        args.layout_draft,
        args.font_file,
    )
    receipt["input_identity"] = {
        "path": portable_path(
            args.input, args.poster_root, receipt["status"] == "accepted"
        ),
        "sha256": hashlib.sha256(input_bytes).hexdigest(),
    }
    receipt["renderer_identity"] = {
        "path": portable_path(
            Path(__file__), args.poster_root, receipt["status"] == "accepted"
        ),
        "sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    }
    args.output.with_suffix(".json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(
        json.dumps(
            {
                key: receipt[key]
                for key in (
                    "status",
                    "model",
                    "profile",
                    "final_width_mm",
                    "final_height_mm",
                    "minimum_effective_font_pt",
                )
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

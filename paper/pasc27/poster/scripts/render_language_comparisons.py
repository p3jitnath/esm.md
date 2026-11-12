"""Draw the retained Fortran, Julia and compiled-Python comparison cohorts."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from render_performance_bars import load_style

ROOT = Path(__file__).resolve().parents[1]
COLOURS = ("#0072B2", "#681FB1", "#681FB1", "#00A6A2", "#00A6A2", "#29347A", "#29347A")


def number(value):
    """Return a readable rate with three significant digits and digit groups.

    Parameters
    ----------
    value : float
        Positive rate in the facet's stated unit, or zero for an axis tick.

    Returns
    -------
    str
        Rate text with commas between groups of three digits.
    """
    import math

    if value == 0:
        return "0"
    decimals = max(0, 2 - math.floor(math.log10(abs(value))))
    return f"{value:,.{decimals}f}"


def render(data, model, profile, output, style, font):
    """Draw six independent horizontal rate facets from the retained points.

    Parameters
    ----------
    data : dict
        Original plotted points, raw timing records and immutable source hashes.
    model : {'sw', 'ebm'}
        Shallow-water or energy-balance model.
    profile : {'paper', 'poster'}
        Requested physical canvas and established typography.
    output : pathlib.Path
        Output prefix for editable PDF and SVG, PNG and provenance JSON.
    style : module
        Sibling publication style, font registration and audit helpers.
    font : str
        Explicit Helvetica Neue paper or Open Sans poster family.

    Returns
    -------
    dict
        Exact input points, export hashes and measured bounds and typography.

    Raises
    ------
    ValueError
        If any implementation row or original twelve-sample rate record is missing.
    RuntimeError
        If type, labels, observed ranges or final export bounds do not fit.

    Notes
    -----
    Points retain the original median of twelve individual rates. Whiskers show
    their observed minimum and maximum. The November and October cohorts use
    separate recorded runs and nodes, without a cross-cohort paired ratio.
    """
    import matplotlib.pyplot as plt
    from matplotlib.ticker import FuncFormatter, MaxNLocator
    import pymupdf

    poster = profile == "poster"
    width, height, size = (14.2, 5.6, 25) if poster else (6.3, 3.35, 8.5)
    final_width_mm = 364.249 if poster else 160.02
    settings = {
        "font.size": size,
        "axes.labelsize": size,
        "xtick.labelsize": size,
        "ytick.labelsize": size,
        "axes.linewidth": 0.7,
        "pdf.fonttype": 42,
        "svg.fonttype": "path",
    }
    annotations, facets, shared_text = [], [], []
    with style.publication_style(settings, font_family=font, project_root=ROOT):
        figure, axes = plt.subplots(1, 6, figsize=(width, height), squeeze=False)
        axes = axes[0]
        figure.subplots_adjust(
            left=0.19, right=0.985, bottom=0.14, top=0.78, wspace=0.32
        )
        for column, axis in enumerate(axes):
            platform = "cpu" if column < 3 else "gpu"
            grid = column % 3
            divisor = 1.0 if platform == "cpu" else 1000.0
            rows = data["plotted_data"][model][platform]
            if len(rows) != 7 or [row["label"] for row in rows] != data["series"]:
                raise ValueError("Retain all seven original implementation rows.")
            max_rate = 0.0
            labels = []
            for row_index, row in enumerate(rows):
                item = row["measurements"][grid]
                point, low, high = [
                    float(item[k]) / divisor for k in ("median", "minimum", "maximum")
                ]
                if (
                    not (0 < low <= point <= high)
                    or len(item["million_updates_per_second"]) != 12
                ):
                    raise ValueError(
                        "Every original point needs twelve positive recorded rates."
                    )
                vanilla = row_index in (2, 4, 6)
                axis.barh(
                    row_index,
                    point,
                    height=0.64,
                    color="white" if vanilla else COLOURS[row_index],
                    edgecolor=COLOURS[row_index],
                    linewidth=0.6 if poster else 0.4,
                    hatch="///" if vanilla else None,
                    zorder=2,
                )
                axis.errorbar(
                    point,
                    row_index,
                    xerr=[[point - low], [high - point]],
                    fmt="none",
                    color="#222222",
                    elinewidth=0.8 if poster else 0.6,
                    capsize=2 if poster else 1.2,
                    zorder=3,
                )
                label = axis.text(
                    high,
                    row_index,
                    f"{point:,.1f}" if platform == "cpu" else number(point),
                    ha="left",
                    va="center",
                    fontsize=size,
                )
                labels.append((label, high))
                annotations.append((axis, label))
                max_rate = max(max_rate, high)
            axis.axhline(0.5, color="#829099", linewidth=0.6)
            axis.set_ylim(6.5, -0.5)
            axis.set_xlim(0, max_rate * 2)
            axis.set_yticks(range(7), data["series"] if column == 0 else [""] * 7)
            axis.tick_params(axis="y", length=0, pad=6 if poster else 3)
            axis.tick_params(
                axis="x", length=3 if poster else 2, pad=3 if poster else 2
            )
            axis.xaxis.set_major_formatter(
                FuncFormatter(lambda value, _: number(value))
            )
            style.finish_axis(axis)
            axis.spines["left"].set_visible(False)
            axis.grid(axis="x", color="#DCE2E5", linewidth=0.5, zorder=0)
            figure.canvas.draw()
            renderer = figure.canvas.get_renderer()
            axis_box = axis.get_window_extent(renderer)
            fraction = max(
                label.get_window_extent(renderer).width / axis_box.width
                for label, _ in labels
            )
            if fraction >= 0.85:
                raise RuntimeError(
                    "A numeric rate label leaves too little width for its bar."
                )
            required = max_rate / (0.96 - fraction)
            limit = MaxNLocator(nbins=2).tick_values(0, required)[-1]
            axis.set_xlim(0, limit)
            axis.set_xticks([0, limit])
            axis.get_xticklabels()[0].set_ha("left")
            axis.get_xticklabels()[-1].set_ha("right")
            for label, high in labels:
                label.set_x(high + 0.025 * limit)
            box = axis.get_position()
            size_value = rows[0]["measurements"][grid]["size"]
            grid_label = f"{size_value:,}²" if model == "sw" else f"{size_value:,}"
            shared_text.append(
                figure.text(
                    (box.x0 + box.x1) / 2,
                    0.855,
                    grid_label,
                    ha="center",
                    va="center",
                    fontsize=size,
                )
            )
            facets.append(
                {
                    "platform": platform,
                    "size": size_value,
                    "rate_axis": "x",
                    "rate_unit": (
                        "million updates/s"
                        if platform == "cpu"
                        else "billion updates/s"
                    ),
                    "rate_divisor_from_millions": divisor,
                    "limits": [0, float(limit)],
                    "axis_inches": [box.width * width, box.height * height],
                }
            )
        for platform, first, last in (("cpu", 0, 2), ("gpu", 3, 5)):
            a, b = axes[first].get_position(), axes[last].get_position()
            text = (
                "CPU 1 [core] · [million updates/s]"
                if platform == "cpu"
                else "GPU 1 [device] · [billion updates/s]"
            )
            shared_text.append(
                figure.text(
                    (a.x0 + b.x1) / 2, 0.995, text, ha="center", va="top", fontsize=size
                )
            )
        shared_text.append(
            figure.text(
                0.015,
                0.855,
                "Grid [cells]" if model == "sw" else "Grid [bands]",
                ha="left",
                va="center",
                fontsize=size,
            )
        )
        findings = style.audit_figure(
            figure, expected_font=font, min_font_size=size, project_root=ROOT
        )
        generic = [
            item for item in findings if item.startswith("Axis ") and " x " in item
        ]
        other = [item for item in findings if item not in generic]
        if other:
            raise RuntimeError("Figure style audit failed. " + ". ".join(other))
        renderer = figure.canvas.get_renderer()
        for axis, label in annotations:
            a, b = axis.get_window_extent(renderer), label.get_window_extent(renderer)
            if (
                b.x0 < a.x0 - 0.5
                or b.x1 > a.x1 + 0.5
                or b.y0 < a.y0 - 0.5
                or b.y1 > a.y1 + 0.5
            ):
                raise RuntimeError("A bar-end rate label extends beyond its facet.")
        text_boxes = [text.get_window_extent(renderer) for text in shared_text]
        for i, box in enumerate(text_boxes):
            if (
                box.x0 < -0.5
                or box.x1 > figure.bbox.x1 + 0.5
                or box.y0 < -0.5
                or box.y1 > figure.bbox.y1 + 0.5
            ):
                raise RuntimeError(
                    "A shared resource or grid label exceeds the canvas."
                )
            if any(box.overlaps(other_box) for other_box in text_boxes[i + 1 :]):
                raise RuntimeError("Shared resource or grid labels overlap.")
        ticks = [
            tick.label1.get_window_extent(renderer)
            for tick in axes[0].yaxis.get_major_ticks()
        ]
        if any(a.overlaps(b) for a, b in zip(ticks, ticks[1:])):
            raise RuntimeError("Implementation row labels overlap.")
        output.parent.mkdir(parents=True, exist_ok=True)
        files = list(style.save_figure(figure, output))
        for file in files:
            figure.savefig(file, bbox_inches=figure.bbox_inches, pad_inches=0, dpi=300)
        svg = output.with_suffix(".svg")
        figure.savefig(svg, bbox_inches=figure.bbox_inches, pad_inches=0)
        files.append(svg)
        plt.close(figure)
    with pymupdf.open(output.with_suffix(".pdf")) as pdf:
        page = pdf[0]
        spans = [
            s
            for b in page.get_text("dict")["blocks"]
            for line in b.get("lines", [])
            for s in line["spans"]
            if s["text"].strip()
        ]
        scale = final_width_mm / (page.rect.width / 72 * 25.4)
        minimum = min(span["size"] for span in spans) * scale
        final_height_mm = page.rect.height / 72 * 25.4 * scale
        if minimum < (24.5 if poster else 8) - 1e-6:
            raise RuntimeError("The exported text is below its final-size minimum.")
        if "assembly" in page.get_text().lower():
            raise RuntimeError("A prohibited chart word was rendered.")
    return {
        "presentation": "language_comparisons",
        "mode": "separate_language_cohorts",
        "model": model,
        "profile": profile,
        "bar_orientation": "horizontal",
        "layout": "two three-grid blocks with CPU left and GPU right",
        "final_width_mm": final_width_mm,
        "final_height_mm": final_height_mm,
        "minimum_effective_font_pt": minimum,
        "native_font_pt": size,
        "facets": facets,
        "generic_size_findings": generic,
        "findings": other,
        "caption_text": "Rates retain the original seven-row comparison. ESM.md uses the Fortran runs from 8 November 2026 on nid010573, job 8199657. The six language controls use October runs on nid011277 (CPU, job 7072889) or nid010353 (GPU, job 7143612). CPU results use one Neoverse V2 core and GPU results use one GH200 device. Points are the saved medians of twelve individual rates, with observed minimum and maximum whiskers. The cohorts use separate runs and nodes, so these bars do not establish a freshly paired speedup. Python is compiled with Numba. Each facet has an independent zero-based linear rate axis. These comparisons remain separate from the 12 November matched primary measurements.",
        "series": data["series"],
        "plotted_data": data["plotted_data"],
        "authentic_plotted_data": data["plotted_data"][model],
        "source_evidence": data["source_evidence"],
        "source_records": data["source_records"],
        "cohorts": data["cohorts"],
        "aggregation": data["aggregation"],
        "raw_timing_records": data.get("raw_timing_records", []),
        "outputs": {
            str(file): hashlib.sha256(file.read_bytes()).hexdigest() for file in files
        },
    }


def main():
    """Render the immutable retained language-comparison input."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--model", choices=("sw", "ebm"), required=True)
    parser.add_argument("--profile", choices=("paper", "poster"), required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--font-file", type=Path)
    parser.add_argument(
        "--source-evidence",
        type=Path,
        default=ROOT / "data/performance-figure-evidence.json",
    )
    args = parser.parse_args()
    data = json.loads(args.input.read_text())
    original = json.loads(args.source_evidence.read_text())
    if data["plotted_data"] != original["plotted_data"]:
        raise ValueError(
            "Retain the exact original plotted points and individual rates."
        )
    data["source_evidence"] = {
        "path": "data/" + args.source_evidence.name,
        "sha256": hashlib.sha256(args.source_evidence.read_bytes()).hexdigest(),
    }
    font = "Open Sans" if args.profile == "poster" else "Helvetica Neue"
    style = load_style(font, args.font_file)
    receipt = render(data, args.model, args.profile, args.output, style, font)
    receipt["input_identity"] = {
        "path": str(args.input),
        "sha256": hashlib.sha256(args.input.read_bytes()).hexdigest(),
    }
    receipt["renderer_identity"] = {
        "path": "scripts/render_language_comparisons.py",
        "sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    }
    args.output.with_suffix(".json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(
        json.dumps(
            {
                k: receipt[k]
                for k in (
                    "model",
                    "profile",
                    "minimum_effective_font_pt",
                    "final_width_mm",
                    "final_height_mm",
                    "outputs",
                )
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

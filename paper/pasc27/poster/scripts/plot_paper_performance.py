"""Render manuscript performance figures from the reviewed poster observations."""

import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import shutil
import sys

POSTER = Path(__file__).resolve().parents[1]
REPOSITORY = POSTER.parents[2]
WORK = REPOSITORY / "paper/pasc27/submission/.scratch/figure_units/performance"
PREVIEWS = WORK / "previews"
OUTPUT = REPOSITORY / "paper/pasc27/submission/figures"
SOURCE = POSTER / "data/performance-figure-evidence.json"
STYLE = POSTER / "scripts/style"
os.environ.setdefault("MPLCONFIGDIR", str(WORK / "matplotlib-cache"))
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter, LogLocator
import pymupdf

sys.path.insert(0, str(STYLE))
import mpl_style as style

style.FONT_FILES = (
    POSTER / "assets/OpenSans-Regular.ttf",
    POSTER / "assets/OpenSans-Bold.ttf",
)

FONT = "Helvetica Neue"
COLOURS = ("#681FB1", "#00A6A2", "#29347A")
MARKERS = ("o", "s", "D")


def draw_model(data, model, filename):
    """Draw all seven implementations at three workloads on both targets.

    Parameters
    ----------
    data : dict
        Reviewed observations with exact twelve-run medians and observed ranges.
    model, filename : str
        Model identifier and the two-word PDF filename without its extension.

    Returns
    -------
    dict
        Final PDF identity, physical dimensions, font audit and observation counts.

    Raises
    ------
    RuntimeError
        If typography, geometry or accepted observation counts fail their checks.

    Notes
    -----
    The function reads existing summaries and performs no numerical simulation or
    timing. CPU and GPU retain separate linear and logarithmic absolute rate axes.
    """
    settings = {
        "font.size": 8,
        "axes.labelsize": 8,
        "xtick.labelsize": 8,
        "ytick.labelsize": 8,
        "axes.linewidth": 0.7,
        "lines.linewidth": 0.7,
        "legend.fontsize": 8,
        "pdf.fonttype": 42,
    }
    with style.publication_style(settings, font_family=FONT, project_root=REPOSITORY):
        figure, axes = plt.subplots(1, 2, figsize=(7.2, 2.65), sharey=True)
        figure.subplots_adjust(
            left=0.18, right=0.985, bottom=0.25, top=0.78, wspace=0.17
        )
        conditions = 0
        observations = 0
        for axis, platform, letter in zip(axes, ("cpu", "gpu"), ("a", "b")):
            rows = data["plotted_data"][model][platform]
            if len(rows) != 7:
                raise RuntimeError("The figure requires all seven implementation rows.")
            axis.axhspan(-0.47, 0.47, color="#EEF1F4", zorder=0)
            axis.axhline(0.53, color="#A1AAB2", linewidth=0.6)
            for y, row in enumerate(rows):
                if len(row["measurements"]) != 3:
                    raise RuntimeError("Each implementation requires three workloads.")
                for index, point in enumerate(row["measurements"]):
                    if point["count"] != 12:
                        raise RuntimeError(
                            "Every plotted condition requires twelve runs."
                        )
                    conditions += 1
                    observations += point["count"]
                    median = point["median"]
                    axis.errorbar(
                        median,
                        y + (index - 1) * 0.23,
                        xerr=[[median - point["minimum"]], [point["maximum"] - median]],
                        fmt=MARKERS[index],
                        markersize=3.5,
                        color=COLOURS[index],
                        ecolor=COLOURS[index],
                        elinewidth=0.7,
                        capsize=1.4,
                        capthick=0.7,
                        zorder=3,
                    )
            axis.set_ylim(6.6, -0.65)
            axis.set_yticks(range(7), [row["label"] for row in rows])
            axis.tick_params(axis="y", length=0, pad=4)
            if platform == "cpu":
                axis.set_xlim(0, 110 if model == "sw" else 800)
                axis.set_xticks([0, 50, 100] if model == "sw" else [0, 400, 800])
                axis.set_xlabel("Rate [million cell updates/s]", labelpad=4)
                axis.get_yticklabels()[0].set_fontweight("bold")
            else:
                bounds = [
                    point[bound]
                    for row in rows
                    for point in row["measurements"]
                    for bound in ("minimum", "maximum")
                ]
                axis.set_xscale("log")
                axis.set_xlim(min(bounds) / 1.4, max(bounds) * 1.5)
                axis.xaxis.set_major_locator(
                    LogLocator(base=10, subs=(1.0,), numticks=5)
                )
                axis.xaxis.set_major_formatter(
                    FuncFormatter(lambda value, position: f"{value:,.0f}")
                )
                axis.tick_params(axis="x", which="minor", bottom=False)
                axis.set_xlabel("Rate [million cell updates/s] (log scale)", labelpad=4)
                axis.tick_params(axis="y", left=False)
            style.finish_axis(axis)
            axis.spines["left"].set_visible(False)
            axis.grid(axis="x", color="#D8DFE3", linewidth=0.5, zorder=0)
            position = axis.get_position()
            figure.text(
                position.x0 - 0.035,
                0.86,
                letter,
                fontsize=10,
                fontweight="bold",
                ha="right",
                va="center",
            )
            figure.text(
                (position.x0 + position.x1) / 2,
                0.86,
                (
                    "CPU · one Neoverse V2 core"
                    if platform == "cpu"
                    else "GPU · one GH200 device"
                ),
                fontsize=9,
                ha="center",
                va="center",
            )
        sizes = [
            point["size"]
            for point in data["plotted_data"][model]["cpu"][0]["measurements"]
        ]
        handles = [
            Line2D(
                [],
                [],
                color=colour,
                marker=marker,
                linestyle="none",
                markersize=4,
                label=f"{size:,}² cells" if model == "sw" else f"{size:,} bands",
            )
            for size, colour, marker in zip(sizes, COLOURS, MARKERS)
        ]
        figure.legend(
            handles=handles,
            loc="upper center",
            bbox_to_anchor=(0.60, 1.005),
            ncol=3,
            frameon=False,
            fontsize=8,
            columnspacing=1.5,
            handletextpad=0.5,
        )
        figure.text(
            0.57,
            0.025,
            "ESM.md and language controls · separate measurement campaigns",
            fontsize=7.5,
            ha="center",
            va="bottom",
        )
        issues = style.audit_figure(figure, expected_font=FONT, min_font_size=7)
        if issues:
            raise RuntimeError("Figure audit failed. " + ". ".join(issues))
        files = style.save_figure(figure, PREVIEWS / filename)
        plt.close(figure)
    final = OUTPUT / (filename + ".pdf")
    shutil.copyfile(files[0], final)
    document = pymupdf.open(final)
    page = document[0]
    text = page.get_text()
    if "assembly" in text.lower():
        raise RuntimeError("A disallowed series label reached the figure.")
    fonts = [
        span["size"]
        for block in page.get_text("dict")["blocks"]
        if "lines" in block
        for line in block["lines"]
        for span in line["spans"]
        if span["text"].strip()
    ]
    width, height = page.rect.width, page.rect.height
    page.get_pixmap(matrix=pymupdf.Matrix(2, 2)).save(
        PREVIEWS / (filename + "-pdf.png")
    )
    document.close()
    effective_minimum = min(fonts) * (7.0 * 72 / width)
    if effective_minimum < 7:
        raise RuntimeError(
            "Text is below seven points at a conservative seven-inch inclusion width."
        )
    return {
        "file": str(final.relative_to(REPOSITORY)),
        "sha256": hashlib.sha256(final.read_bytes()).hexdigest(),
        "bytes": final.stat().st_size,
        "source_canvas_inches": [7.2, 2.65],
        "pdf_points": [width, height],
        "source_minimum_font_points": min(fonts),
        "minimum_font_at_7in_width": effective_minimum,
        "font": FONT,
        "conditions": conditions,
        "observations": observations,
        "axes": {
            "a": "CPU linear absolute throughput",
            "b": "GPU logarithmic absolute throughput",
        },
        "findings": issues,
    }


def main():
    """Write only the two final manuscript PDFs and local reproducibility evidence."""
    PREVIEWS.mkdir(parents=True, exist_ok=True)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    data = json.loads(SOURCE.read_text())
    records = [
        draw_model(data, "sw", "water-performance"),
        draw_model(data, "ebm", "energy-performance"),
    ]
    evidence = {
        "source": str(SOURCE.relative_to(REPOSITORY)),
        "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        "retained_source_records": data["source_records"],
        "graph_style": str(STYLE.relative_to(REPOSITORY)),
        "font": FONT,
        "versions": {
            name: importlib.metadata.version(name)
            for name in ("matplotlib", "numpy", "PyMuPDF")
        },
        "figures": records,
        "scope": "The existing 84 reviewed medians and ranges are unchanged. The two cohorts retain separate dates, nodes and timing protocols. No model or timing was run.",
    }
    (WORK / "figure-evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(json.dumps(records, indent=2))


if __name__ == "__main__":
    main()

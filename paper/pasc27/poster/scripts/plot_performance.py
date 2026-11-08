"""Plot absolute esm.md CPU and GPU throughput for the research poster."""

import hashlib
import json
import os
import sys
from pathlib import Path

POSTER = Path(__file__).resolve().parents[1]
os.environ.setdefault("MPLCONFIGDIR", str(POSTER / ".build/matplotlib"))
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import LogFormatterMathtext, LogLocator

sys.path.insert(0, str(POSTER / "scripts/style"))
import mpl_style as style

style.SUPPORTED_FONT_FAMILIES += ("Open Sans",)
style.FONT_FILES = (
    POSTER / "assets/OpenSans-Regular.ttf",
    POSTER / "assets/OpenSans-Bold.ttf",
)


def plot_model(data, model, output_name):
    """Draw the generated solver's actual rates and observed timing variation.

    Parameters
    ----------
    data : dict
        Curated accepted twelve-run timing measurements.
    model, output_name : str
        Model key and stable figure filename without an extension.

    Returns
    -------
    dict
        Export paths, physical dimensions, font size and audit findings.

    Raises
    ------
    RuntimeError
        If the figure fails a typography or geometry check.

    Notes
    -----
    Only esm.md rates are drawn. CPU and GPU are distinct hardware categories.
    Whiskers show observed minima and maxima, rather than confidence intervals.
    Horizontal axes are logarithmic, so each major step is a tenfold rate change.
    """
    settings = {
        "font.size": 24,
        "axes.labelsize": 24,
        "xtick.labelsize": 24,
        "ytick.labelsize": 25,
        "axes.linewidth": 1.4,
        "lines.linewidth": 2,
        "svg.fonttype": "path",
        "mathtext.fontset": "dejavusans",
    }
    colours = {"cpu": "#681FB1", "gpu": "#00BDB6"}
    markers = {"cpu": "o", "gpu": "D"}
    with style.publication_style(
        settings, font_family="Open Sans", project_root=POSTER
    ):
        figure, axes = plt.subplots(1, 3, figsize=(14.2, 5.65), sharey=True)
        figure.subplots_adjust(
            left=0.135, right=0.985, bottom=0.23, top=0.77, wspace=0.20
        )
        figure.text(
            0.56, 0.995, "esm.md", ha="center", va="top", fontsize=27, fontweight="bold"
        )
        for index, axis in enumerate(axes):
            for y, platform in enumerate(("cpu", "gpu")):
                row = data["models"][platform][model][index]
                point = row["fortran"]
                median, low, high = point["median"], point["minimum"], point["maximum"]
                axis.errorbar(
                    median,
                    y,
                    xerr=[[median - low], [high - median]],
                    fmt=markers[platform],
                    markersize=8,
                    color=colours[platform],
                    ecolor="#232830",
                    elinewidth=2,
                    capsize=7,
                    capthick=2,
                    zorder=3,
                )
                axis.annotate(
                    f"{median:,.2f}",
                    (median, y),
                    xytext=(10 if index == 0 and platform == "cpu" else 0, 13),
                    textcoords="offset points",
                    ha="center",
                    va="bottom",
                    fontsize=25,
                    color="#232830",
                    fontweight="bold",
                )
            size = data["models"]["cpu"][model][index]["size"]
            label = f"{size}² cells" if model == "sw" else f"{size:,} bands"
            figure.text(
                (axis.get_position().x0 + axis.get_position().x1) / 2,
                0.88,
                label,
                ha="center",
                va="center",
                fontsize=26,
                fontweight="bold",
            )
            axis.set_xscale("log")
            axis.set_xlim((50, 50000) if model == "sw" else (300, 500000))
            axis.set_ylim(1.55, -0.6)
            axis.set_yticks([0, 1], ["CPU\n1 core", "GPU\n1 device"])
            axis.xaxis.set_major_locator(LogLocator(base=10, subs=(1.0,)))
            axis.xaxis.set_major_formatter(LogFormatterMathtext(base=10))
            axis.tick_params(axis="y", length=0, pad=12)
            axis.tick_params(axis="x", which="minor", bottom=False)
            style.finish_axis(axis)
            axis.spines["left"].set_visible(False)
            axis.grid(axis="x", which="major", color="#D5DFDF", linewidth=0.9, zorder=0)
            if index:
                axis.spines["left"].set_visible(False)
                axis.tick_params(axis="y", left=False)
        figure.text(
            0.56,
            0.045,
            "Million complete cell updates/s  ·  log scale",
            ha="center",
            va="center",
            fontsize=24,
        )
        issues = style.audit_figure(figure, expected_font="Open Sans", min_font_size=24)
        if issues:
            raise RuntimeError("Figure audit failed. " + ". ".join(issues))
        paths = style.save_figure(figure, POSTER / "figures" / output_name)
        figure.savefig(
            POSTER / "figures" / (output_name + ".svg"),
            bbox_inches="tight",
            pad_inches=0.08,
        )
        plt.close(figure)
    return {
        "files": [str(path.relative_to(POSTER)) for path in paths]
        + ["figures/" + output_name + ".svg"],
        "displayed_series": "esm.md",
        "displayed_quantity": "absolute throughput",
        "canvas_inches": [14.2, 5.65],
        "minimum_text_points": 24,
        "whiskers": "Observed minimum and maximum of twelve accepted runs",
        "horizontal_scale": "Logarithmic. Each major step is a tenfold rate change.",
        "findings": issues,
    }


def main():
    """Export absolute CPU and GPU rates from the self-contained timing snapshot."""
    source = POSTER / "data/results-current.json"
    data = json.loads(source.read_text())
    if data["repetitions"] != 12 or not data["all_output_bytes_identical"]:
        raise ValueError("The poster requires verified twelve-run comparisons.")
    records = {
        "shallow_water": plot_model(data, "sw", "performance-shallow_water"),
        "budyko_sellers": plot_model(data, "ebm", "performance-budyko_sellers"),
    }
    (POSTER / "data/performance-figure-evidence.json").write_text(
        json.dumps(
            {
                "data_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                "figures": records,
            },
            indent=2,
        )
        + "\n"
    )
    print("Absolute esm.md performance figures exported")


if __name__ == "__main__":
    main()

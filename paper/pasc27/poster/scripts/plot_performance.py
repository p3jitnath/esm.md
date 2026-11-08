"""Compare accepted current and historical CPU and GPU implementation rates."""

import argparse
import hashlib
import json
import os
import statistics
import sys
from pathlib import Path

POSTER = Path(__file__).resolve().parents[1]
os.environ.setdefault("MPLCONFIGDIR", str(POSTER / ".build/matplotlib"))
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import LogFormatterMathtext, LogLocator

sys.path.insert(0, str(POSTER / "scripts/style"))
import mpl_style as style

style.SUPPORTED_FONT_FAMILIES += ("Open Sans",)
style.FONT_FILES = (
    POSTER / "assets/OpenSans-Regular.ttf",
    POSTER / "assets/OpenSans-Bold.ttf",
)
CONTROL_NAMES = (
    "fortran",
    "fortran_vanilla",
    "julia",
    "julia_vanilla",
    "python",
    "python_vanilla",
)
GPU_NAMES = (
    "gpu_fortran",
    "gpu_fortran_vanilla",
    "julia",
    "julia_vanilla",
    "gpu_python",
    "gpu_python_vanilla",
)
LABELS = (
    "esm.md",
    "Fortran Tuned",
    "Fortran Vanilla",
    "Julia Tuned",
    "Julia Vanilla",
    "Python Tuned",
    "Python Vanilla",
)
COLOURS = ("#681FB1", "#00A6A2", "#29347A")
MARKERS = ("o", "s", "D")


def rate_summary(seconds, updates):
    """Convert twelve complete-run times to a common absolute update rate.

    Parameters
    ----------
    seconds : sequence of float
        Positive elapsed seconds for twelve accepted observations.
    updates : int
        Complete cell updates in each timed batch.

    Returns
    -------
    dict
        Median, observed minimum and maximum, count, and individual rates in millions per second.

    Raises
    ------
    ValueError
        If the retained observations do not contain twelve positive times.
    """
    if len(seconds) != 12 or any(value <= 0 for value in seconds):
        raise ValueError(
            "Every plotted condition requires twelve positive observations."
        )
    rates = [updates / value / 1e6 for value in seconds]
    return {
        "median": statistics.median(rates),
        "minimum": min(rates),
        "maximum": max(rates),
        "count": 12,
        "million_updates_per_second": rates,
    }


def prepare_data():
    """Collect the fixed current and historical records without running any model.

    Returns
    -------
    dict
        Portable plot observations, cohort identities, source hashes and scope.

    Notes
    -----
    Each cohort retains its own accepted checks. This operation does not perform a
    new comparison of output states between the two cohorts.
    """
    paths = {
        "current": POSTER / "data/results-current.json",
        "historical_cpu": POSTER / "data/historical/benchmark.json",
        "historical_gpu": POSTER / "data/historical/gpu-benchmark.json",
    }
    current, old_cpu, old_gpu = (json.loads(paths[name].read_text()) for name in paths)
    if (
        current["repetitions"] != 12
        or not current["all_output_bytes_identical"]
        or not old_gpu["passed"]
        or old_gpu["repeats"] != 12
    ):
        raise ValueError(
            "Only the retained accepted twelve-run records may be plotted."
        )
    plotted = {}
    for model, historical_model, gpu_model in (
        ("sw", "shallow_water", "sw"),
        ("ebm", "budyko_sellers", "eb"),
    ):
        plotted[model] = {}
        for platform in ("cpu", "gpu"):
            rows = []
            current_rows = current["models"][platform][model]
            for index, label in enumerate(LABELS):
                measurements = []
                for current_row in current_rows:
                    size = current_row["size"]
                    if index == 0:
                        point = dict(current_row["fortran"])
                        point["million_updates_per_second"] = [
                            row["fortran_million_updates_per_second"]
                            for row in current_row["paired_samples"]
                        ]
                        steps = current_row["steps"]
                        source_name = "fortran"
                    elif platform == "cpu":
                        old = next(
                            row
                            for row in old_cpu["models"][historical_model]["results"]
                            if row["size"] == size
                        )
                        if not old["output_bytes_identical"]:
                            raise ValueError(
                                "An archived CPU condition was not accepted."
                            )
                        steps, source_name = old["steps"], CONTROL_NAMES[index - 1]
                        seconds = [
                            value / 1e9
                            for value in old["implementations"][source_name][
                                "elapsed_ns"
                            ]
                        ]
                        point = rate_summary(
                            seconds, size ** (2 if model == "sw" else 1) * steps
                        )
                    else:
                        old = next(
                            row
                            for row in old_gpu["models"][gpu_model]["results"]
                            if row["size"] == size
                        )
                        steps, source_name = old["steps"], GPU_NAMES[index - 1]
                        seconds = [
                            row["milliseconds"] / 1e3
                            for row in old["summary"][source_name]["samples"]
                        ]
                        point = rate_summary(seconds, old["cells"] * steps)
                    if steps != current_row["steps"]:
                        raise ValueError("Current and historical batch lengths differ.")
                    measurements.append(
                        {
                            "size": size,
                            "steps": steps,
                            "source_variant": source_name,
                            **point,
                        }
                    )
                rows.append(
                    {
                        "label": label,
                        "cohort": "November 2026" if index == 0 else "October 2026",
                        "measurements": measurements,
                    }
                )
            plotted[model][platform] = rows
    return {
        "data_sha256": hashlib.sha256(paths["current"].read_bytes()).hexdigest(),
        "source_records": {
            name: {
                "path": str(path.relative_to(POSTER)),
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            }
            for name, path in paths.items()
        },
        "series": list(LABELS),
        "aggregation": "Median of twelve individual rates, with observed minimum and maximum. No confidence interval or cross-cohort paired ratio is inferred.",
        "cohorts": {
            "current": {"date": "2026-11-08", "job": "8199657", "node": "nid010573"},
            "historical_cpu": {
                "date": "2026-10-05",
                "job": "7072889",
                "node": "nid011277",
            },
            "historical_gpu": {
                "date": "2026-10-08",
                "job": "7143612",
                "node": "nid010353",
            },
        },
        "scope": [
            "The cohorts use separate runs and nodes. Comparisons show recorded absolute rates and do not establish a freshly paired speedup.",
            "CPU rates use complete-run wall time on one Neoverse V2 core. GPU rates use complete-graph CUDA event time on one GH200 device.",
            "Compilation, setup and verification are excluded. GPU transfers and graph construction are also excluded.",
            "The workload grids, batch lengths and retained input generators agree. Each cohort passed its own recorded physical and exact-output checks.",
            "Python is compiled with Numba. These records do not describe interpreted Python.",
        ],
        "plotted_data": plotted,
        "figures": {},
    }


def plot_model(data, model, output_name):
    """Draw CPU and GPU facets with shared implementation rows and grid encodings.

    Parameters
    ----------
    data : dict
        Frozen plotted observations and their source identities.
    model, output_name : str
        Model identifier and stable output filename stem.

    Returns
    -------
    dict
        Export paths, dimensions, minimum font size, axes and audit findings.
    """
    settings = {
        "font.size": 24,
        "axes.labelsize": 24,
        "xtick.labelsize": 24,
        "ytick.labelsize": 24,
        "axes.linewidth": 1.3,
        "svg.fonttype": "path",
        "mathtext.fontset": "dejavusans",
    }
    with style.publication_style(
        settings, font_family="Open Sans", project_root=POSTER
    ):
        figure, axes = plt.subplots(1, 2, figsize=(14.2, 5.65), sharey=True)
        figure.subplots_adjust(
            left=0.255, right=0.985, bottom=0.33, top=0.81, wspace=0.18
        )
        for axis, platform in zip(axes, ("cpu", "gpu")):
            rows = data["plotted_data"][model][platform]
            axis.axhspan(-0.48, 0.48, color="#EEF1F4", zorder=0)
            axis.axhline(0.53, color="#9CA8B0", linewidth=0.9)
            for y, row in enumerate(rows):
                for grid, point in enumerate(row["measurements"]):
                    median = point["median"]
                    axis.errorbar(
                        median,
                        y + (grid - 1) * 0.23,
                        xerr=[[median - point["minimum"]], [point["maximum"] - median]],
                        fmt=MARKERS[grid],
                        markersize=6.8,
                        color=COLOURS[grid],
                        ecolor=COLOURS[grid],
                        elinewidth=1.6,
                        capsize=2.8,
                        capthick=1.3,
                        zorder=3,
                    )
            axis.set_ylim(6.6, -0.65)
            axis.set_yticks(range(7), LABELS)
            axis.tick_params(axis="y", length=0, pad=10)
            figure.text(
                (axis.get_position().x0 + axis.get_position().x1) / 2,
                0.85,
                "CPU · one core" if platform == "cpu" else "GPU · one device",
                ha="center",
                va="center",
                fontsize=25,
            )
            if platform == "cpu":
                axis.set_xlim(0, 110 if model == "sw" else 800)
                axis.set_xticks([0, 50, 100] if model == "sw" else [0, 400, 800])
                axis.set_xlabel("Million updates/s", labelpad=10)
            else:
                values = [
                    point[bound]
                    for row in rows
                    for point in row["measurements"]
                    for bound in ("minimum", "maximum")
                ]
                axis.set_xscale("log")
                axis.set_xlim(min(values) / 1.4, max(values) * 1.5)
                axis.xaxis.set_major_locator(
                    LogLocator(base=10, subs=(1.0,), numticks=5)
                )
                axis.xaxis.set_major_formatter(LogFormatterMathtext(base=10))
                axis.tick_params(axis="x", which="minor", bottom=False)
                axis.set_xlabel("Million updates/s · log scale", labelpad=10)
            style.finish_axis(axis)
            axis.spines["left"].set_visible(False)
            axis.grid(axis="x", color="#D5DFDF", linewidth=0.9, zorder=0)
            if platform == "gpu":
                axis.tick_params(axis="y", left=False)
            else:
                axis.get_yticklabels()[0].set_fontweight("bold")
        sizes = [
            row["size"] for row in data["plotted_data"][model]["cpu"][0]["measurements"]
        ]
        handles = [
            Line2D(
                [],
                [],
                color=colour,
                marker=marker,
                linestyle="none",
                markersize=8,
                label=f"{size}² cells" if model == "sw" else f"{size:,} bands",
            )
            for size, colour, marker in zip(sizes, COLOURS, MARKERS)
        ]
        figure.legend(
            handles=handles,
            loc="upper center",
            bbox_to_anchor=(0.62, 1.01),
            ncol=3,
            frameon=False,
            fontsize=24,
            columnspacing=1.0,
            handletextpad=0.4,
        )
        figure.text(
            0.56,
            0.012,
            "esm.md Nov 2026 · Oct 2026 controls · Python uses Numba",
            ha="center",
            va="bottom",
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
        "displayed_series": list(LABELS),
        "canvas_inches": [14.2, 5.65],
        "minimum_text_points": 24,
        "whiskers": "Observed minimum and maximum of twelve retained runs per condition",
        "axes": {
            "cpu": "Linear absolute throughput",
            "gpu": "Logarithmic absolute throughput",
        },
        "findings": issues,
    }


def main():
    """Prepare reviewable inputs and export the two model comparison figures."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data-only",
        action="store_true",
        help="Write fixed plotted observations for independent review without rendering.",
    )
    args = parser.parse_args()
    evidence = prepare_data()
    if not args.data_only:
        evidence["figures"] = {
            "shallow_water": plot_model(evidence, "sw", "performance-shallow_water"),
            "budyko_sellers": plot_model(evidence, "ebm", "performance-budyko_sellers"),
        }
    target = POSTER / "data/performance-figure-evidence.json"
    temporary = POSTER / ".build/performance-figure-evidence.tmp"
    temporary.parent.mkdir(parents=True, exist_ok=True)
    temporary.write_text(json.dumps(evidence, indent=2, ensure_ascii=False) + "\n")
    temporary.replace(target)
    print(
        "Current and historical performance observations prepared"
        if args.data_only
        else "Current and historical CPU/GPU comparison figures exported"
    )


if __name__ == "__main__":
    main()

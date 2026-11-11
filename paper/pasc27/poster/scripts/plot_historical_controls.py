"""Retain the six archived language controls as a separate historical cohort."""

import json
import os
import sys
from pathlib import Path

POSTER = Path(__file__).resolve().parents[1]
os.environ.setdefault("MPLCONFIGDIR", str(POSTER / ".build/matplotlib"))
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

sys.path.insert(0, str(POSTER / "scripts/style"))
import mpl_style as style

style.SUPPORTED_FONT_FAMILIES += ("Open Sans",)
style.FONT_FILES = (
    POSTER / "assets/OpenSans-Regular.ttf",
    POSTER / "assets/OpenSans-Bold.ttf",
)


def main():
    """Draw archived controls without combining them with the new measurement cohort."""
    data = json.loads((POSTER / "data/historical/benchmark.json").read_text())
    names = (
        "fortran",
        "fortran_vanilla",
        "julia",
        "julia_vanilla",
        "python",
        "python_vanilla",
    )
    labels = (
        "Fortran · tuned",
        "Fortran · vanilla",
        "Julia · tuned",
        "Julia · vanilla",
        "Python · tuned",
        "Python · vanilla",
    )
    colours = {"fortran": "#681FB1", "julia": "#00BDB6", "python": "#29347A"}
    settings = {
        "font.size": 24,
        "axes.labelsize": 24,
        "xtick.labelsize": 24,
        "ytick.labelsize": 24,
        "svg.fonttype": "path",
        "axes.linewidth": 1.3,
    }
    evidence = {
        "scope": "Historical six-language-control cohort. These figures are separate from the new esm.md measurements.",
        "aggregation": "Twelve-run median and observed minimum–maximum range",
        "series": list(names),
        "figures": {},
    }
    with style.publication_style(
        settings, font_family="Open Sans", project_root=POSTER
    ):
        for model in ("shallow_water", "budyko_sellers"):
            figure, axes = plt.subplots(1, 3, figsize=(14.2, 6.4), sharey=True)
            figure.subplots_adjust(
                left=0.255, right=0.985, bottom=0.18, top=0.84, wspace=0.20
            )
            figure.text(
                0.61,
                0.995,
                "Historical language controls",
                ha="center",
                va="top",
                fontsize=27,
                fontweight="bold",
            )
            for index, (axis, row) in enumerate(
                zip(axes, data["models"][model]["results"])
            ):
                updates = (
                    row["size"] ** (2 if model == "shallow_water" else 1)
                    * row["steps"]
                    / 1e6
                )
                for y, name in enumerate(names):
                    value = row["summary"][name]
                    median = value["million_cell_steps_per_second"]
                    low, high = (
                        updates / value["max_seconds"],
                        updates / value["min_seconds"],
                    )
                    vanilla = name.endswith("_vanilla")
                    colour = colours[name.removesuffix("_vanilla")]
                    axis.barh(
                        y,
                        median,
                        height=0.64,
                        color="white" if vanilla else colour,
                        edgecolor=colour,
                        hatch="//" if vanilla else None,
                        linewidth=1.5,
                    )
                    axis.errorbar(
                        median,
                        y,
                        xerr=[[median - low], [high - median]],
                        fmt="none",
                        ecolor="#232830",
                        capsize=4,
                        elinewidth=1.5,
                    )
                    axis.annotate(
                        f"{median:.1f}",
                        (high, y),
                        xytext=(7, 0),
                        textcoords="offset points",
                        ha="left",
                        va="center",
                        fontsize=24,
                    )
                axis.set_ylim(5.6, -0.65)
                axis.set_xlim(0, 130 if model == "shallow_water" else 760)
                axis.set_xticks(
                    [0, 50, 100] if model == "shallow_water" else [0, 300, 600]
                )
                axis.set_yticks(range(6), labels)
                axis.tick_params(axis="y", length=0, pad=10)
                grid = (
                    f"{row['size']}² cells"
                    if model == "shallow_water"
                    else f"{row['size']:,} bands"
                )
                figure.text(
                    (axis.get_position().x0 + axis.get_position().x1) / 2,
                    0.89,
                    grid,
                    ha="center",
                    va="center",
                    fontsize=26,
                    fontweight="bold",
                )
                axis.set_xlabel("Rate [million updates/s]", labelpad=10)
                style.finish_axis(axis)
                axis.spines["left"].set_visible(False)
                axis.grid(axis="x", color="#D5DFDF", zorder=0)
                if index:
                    axis.tick_params(axis="y", left=False)
            findings = style.audit_figure(
                figure, expected_font="Open Sans", min_font_size=24
            )
            if findings:
                raise RuntimeError("Figure audit failed. " + ". ".join(findings))
            target = POSTER / "figures/historical" / ("language-controls-" + model)
            style.save_figure(figure, target)
            figure.savefig(
                target.with_suffix(".svg"), bbox_inches="tight", pad_inches=0.08
            )
            plt.close(figure)
            evidence["figures"][model] = {
                "minimum_text_points": 24,
                "findings": findings,
                "cohort": "Archived October 2026 CPU study on one Neoverse V2 core",
            }
    (POSTER / "data/historical/figure-evidence.json").write_text(
        json.dumps(evidence, indent=2) + "\n"
    )
    print("Historical six-control figures exported")


if __name__ == "__main__":
    main()

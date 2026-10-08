"""Draw the accepted GPU timings in the same throughput units as the CPU plots."""

import argparse
import importlib.util
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
os.environ.setdefault("MPLCONFIGDIR", str(ROOT / ".runtime/cache/matplotlib"))
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

NAMES = ("assembly", "gpu_fortran", "gpu_fortran_vanilla", "julia", "julia_vanilla",
         "gpu_python", "gpu_python_vanilla")
LABELS = ("Assembly", "Fortran · tuned", "Fortran · vanilla", "Julia · tuned",
          "Julia · vanilla", "Python · tuned", "Python · vanilla")
COLOURS = {"assembly": "#133844", "fortran": "#681FB1", "julia": "#00BDB6", "python": "#29347A"}


def main():
    """Export audited PDF and PNG figures from the frozen comparison records."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, default=ROOT / "bench/gpu/results.json")
    parser.add_argument("--output", type=Path, default=ROOT / "bench/gpu/figures")
    default_style = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))) / "skills/graph-plotting"
    parser.add_argument("--style-bundle", type=Path,
                        default=Path(os.environ.get("GRAPH_PLOTTING_SKILL_DIR", str(default_style))))
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location("gpu_plot_style", args.style_bundle / "scripts/mpl_style.py")
    style = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(style)
    data = json.loads(args.data.read_text())
    if not data["passed"] or data["repeats"] < 12:
        raise ValueError("Figures require at least twelve accepted final repetitions.")
    audits = {}
    overrides = {"font.size": 8, "axes.labelsize": 8, "xtick.labelsize": 8,
                 "ytick.labelsize": 8, "hatch.linewidth": 0.6, "svg.fonttype": "path"}
    with style.publication_style(overrides, font_family="Nimbus Sans", project_root=ROOT):
        for model, values in data["models"].items():
            fig = plt.figure(figsize=(8.5, 3.35))
            for j, workload in enumerate(values["results"]):
                ax = fig.add_axes([0.19 + j * 0.268, 0.245, 0.227, 0.61])
                summary = workload["summary"]
                med = np.array([summary[n]["million_cell_steps_per_second"] for n in NAMES])
                low = np.array([summary[n]["min_million_cell_steps_per_second"] for n in NAMES])
                high = np.array([summary[n]["max_million_cell_steps_per_second"] for n in NAMES])
                if not (np.all(low <= med) and np.all(med <= high)):
                    raise ValueError("A timing median falls outside its recorded range.")
                limit = high.max() * 1.27
                for i, name in enumerate(NAMES):
                    family = name.removeprefix("gpu_").removesuffix("_vanilla")
                    colour, vanilla = COLOURS[family], name.endswith("_vanilla")
                    ax.barh(i, med[i], height=0.64, color="white" if vanilla else colour,
                            edgecolor=colour, linewidth=0.85, hatch="///" if vanilla else None, zorder=2)
                    ax.errorbar(med[i], i, xerr=[[med[i] - low[i]], [high[i] - med[i]]],
                                fmt="none", ecolor="#232830", capsize=2.2, elinewidth=0.75, zorder=3)
                    label = f"{med[i]:,.0f}" if med[i] >= 1000 else f"{med[i]:.1f}"
                    ax.annotate(label, xy=(high[i], i), xytext=(4, 0), textcoords="offset points",
                                ha="left", va="center", fontsize=8, color="#232830")
                ax.set_ylim(6.55, -0.6)
                ax.set_xlim(0, limit)
                ax.set_yticks(range(7), LABELS if j == 0 else [""] * 7)
                ax.tick_params(axis="y", length=0, pad=5)
                ax.xaxis.set_major_locator(matplotlib.ticker.MaxNLocator(3, min_n_ticks=3))
                ax.ticklabel_format(axis="x", style="plain", useOffset=False)
                ax.set_xlabel("Million/s", labelpad=5)
                style.finish_axis(ax)
                ax.spines["left"].set_visible(False)
                ax.grid(axis="x", color="#CBD6D8", linewidth=0.5, zorder=0)
                size = workload["size"]
                grid = f"{size:,}² cells" if model == "sw" else f"{size:,} bands"
                fig.text(0.3035 + j * 0.268, 0.925, grid, ha="center", va="center",
                         fontsize=9, fontweight="bold")
            fig.text(0.19, 0.10, "Million complete cell updates per second · higher is faster", fontsize=8)
            fig.text(0.19, 0.045, "Median of 12 runs · whiskers show the minimum and maximum · each panel starts at zero", fontsize=8)
            findings = style.audit_figure(fig, expected_font="Nimbus Sans", min_font_size=7,
                                          project_root=ROOT)
            if findings:
                raise RuntimeError(str(findings))
            stem = args.output / ("performance-" + ("shallow-water" if model == "sw" else "budyko-sellers"))
            paths = style.save_figure(fig, stem)
            fig.savefig(stem.with_suffix(".svg"), bbox_inches="tight")
            audits[model] = {"findings": findings, "font": "Nimbus Sans", "inches": list(fig.get_size_inches()),
                             "exports": [str(path.relative_to(ROOT)) for path in paths],
                             "unit": "Million complete cell updates per second", "zero_baseline": True,
                             "source_data_sha256": hashlib.sha256(args.data.read_bytes()).hexdigest(),
                             "plot_source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                             "style_helper_sha256": hashlib.sha256((args.style_bundle / "scripts/mpl_style.py").read_bytes()).hexdigest(),
                             "matplotlib_version": matplotlib.__version__,
                             "uncertainty": "Observed minimum and maximum across twelve repetitions"}
            plt.close(fig)
    (args.output / "audit.json").write_text(json.dumps(audits, indent=2) + "\n")


if __name__ == "__main__":
    main()

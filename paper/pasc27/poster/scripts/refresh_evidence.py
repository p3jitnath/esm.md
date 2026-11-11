"""Record the sources and checks for the current published poster files."""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
from pathlib import Path

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]


def digest(path: Path) -> str:
    """Return a SHA256 identifier for one retained file.

    Parameters
    ----------
    path : pathlib.Path
        File whose bytes identify the recorded artifact.

    Returns
    -------
    str
        Hexadecimal SHA256 identifier.
    """
    return hashlib.sha256(path.read_bytes()).hexdigest()


def refresh() -> dict:
    """Join poster claims to copied measurements and actual exported files.

    Returns
    -------
    dict
        Evidence map written to the poster project.

    Notes
    -----
    This records existing numerical evidence. It performs no model simulation
    and does not invent missing verification or desktop inspection.
    """
    old = json.loads((POSTER / "data/historical/poster_evidence.json").read_text())
    data = json.loads((POSTER / "data/results-current.json").read_text())
    profile = json.loads((POSTER / "project-profile.json").read_text())
    physics = json.loads((POSTER / "figure-evidence.json").read_text())
    checks_path = (
        ROOT / ".runtime/poster_update_20261108/final_review/structural-check.json"
    )
    checks = (
        json.loads(checks_path.read_text())
        if checks_path.exists()
        else {"status": "pending"}
    )
    visual_path = checks_path.parent / "visual-review.json"
    visual = (
        json.loads(visual_path.read_text())
        if visual_path.exists()
        else {"status": "pending"}
    )
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
        "esm-md-a0-landscape.pptx",
        "esm-md-a0-landscape.pdf",
        "esm-md-a0-landscape.png",
        "project-profile.json",
        "README.md",
        "requirements.txt",
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
        "generation_route": "Physics in Markdown to structured Fortran, then compiler-generated CPU or GPU instructions",
        "branding": old.get("branding", {}),
        "references": old.get("references", []),
        "acknowledgement": old.get("acknowledgement", {}),
        "physics": physics,
        "performance_source": "data/results-current.json",
        "performance_source_sha256": digest(POSTER / "data/results-current.json"),
        "performance_method": "Absolute complete-cell-update rates for esm.md and six language controls, with median and observed min-max across twelve runs per condition",
        "graph_policy": "Assembly series and assembly-ratio axes are omitted from every visible performance graph. Raw controls remain in source data for provenance.",
        "axis_scales": {"CPU": "linear", "GPU": "logarithmic"},
        "figure_unit_labels": profile["poster"].get("figure_unit_labels"),
        "independent_plotted_input_reviews": {
            "CPU": {"status": "pass", "groups": 42, "per_run_observations": 504},
            "GPU": {
                "status": "pass",
                "groups": 42,
                "per_run_observations": 504,
                "maximum_elapsed_derived_rate_difference": "one FP64 ULP",
            },
            "method": "Read-only comparison of all plotted groups and samples with accepted source records, including counts, grids, steps, labels, aggregation, ranges and cohorts",
            "new_numerical_runs": False,
        },
        "historical_controls": "Six vanilla/tuned Fortran, Julia and compiled-Python controls from October 2026 appear alongside November 2026 esm.md. The visible date note separates these cohorts. CPU and GPU use separate timers.",
        "scope": [
            "CPU timing uses wall time on one Neoverse V2 core. GPU timing uses device events on one GH200. These measure complete-update compute throughput, not end-to-end forecast time.",
            "The six CPU median rates remain below the paired assembly controls, so this snapshot does not establish CPU parity.",
            "Rates include complete numerical updates and exclude setup, verification and file output as recorded by each protocol.",
            "Exact acceptance covers the recorded inputs and tested configurations, and does not establish x86 performance.",
            "Physical figures are unchanged accepted canonical model states rather than observations.",
            "The current esm.md and archived language controls use separate dates, nodes and jobs. Absolute rates preserve their recorded ranges, and are not freshly paired speedup estimates.",
        ],
        "comparison_evidence": json.loads(
            (POSTER / "data/performance-figure-evidence.json").read_text()
        ),
        "formulation_rename": json.loads(
            (POSTER / "data/dam-break-rename.json").read_text()
        ),
        "summary": data["summary"],
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
                "checks": result["structural_and_qr_checks"].get("passed"),
            },
            indent=2,
        )
    )

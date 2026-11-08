"""Record the sources and checks for the current published poster files."""

from __future__ import annotations

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
        "project-profile.json",
        "README.md",
        "requirements.txt",
    ):
        path = POSTER / name
        if path.exists():
            files[name] = {"sha256": digest(path), "bytes": path.stat().st_size}
    report = {
        "date_utc": "2026-11-08",
        "format": "A0 landscape, 1189 by 841 mm, one native PowerPoint slide and vector PDF",
        "title": profile["identity"]["title"],
        "author": profile["identity"]["author"],
        "affiliation": profile["identity"]["department"]
        + ", "
        + profile["identity"]["university"],
        "implementation_label": "esm.md",
        "generation_route": "Physics in Markdown to structured Fortran, then compiler-generated CPU or GPU instructions",
        "branding": old.get("branding", {}),
        "references": old.get("references", []),
        "acknowledgement": old.get("acknowledgement", {}),
        "physics": physics,
        "performance_source": "data/results-current.json",
        "performance_source_sha256": digest(POSTER / "data/results-current.json"),
        "performance_method": "Absolute esm.md complete-cell-update rates, median and observed min-max across twelve accepted runs per condition",
        "graph_policy": "Assembly series and assembly-ratio axes are omitted from every visible performance graph. Raw controls remain in source data for provenance.",
        "historical_controls": "Six earlier tuned/vanilla language controls are shown separately, with their earlier cohort explicitly identified.",
        "scope": [
            "CPU timing uses one Neoverse V2 core, GPU timing uses one GH200 device, with separate platform workloads.",
            "The six CPU median rates remain below the paired assembly controls, so this snapshot does not establish CPU parity.",
            "Rates include complete numerical updates and exclude setup, verification and file output as recorded by each protocol.",
            "Exact acceptance covers the recorded inputs and tested configurations, and does not establish x86 performance.",
            "Physical figures are unchanged accepted canonical model states rather than observations.",
            "The CPU and GPU rates apply to the recorded hardware, workloads and timing intervals.",
        ],
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

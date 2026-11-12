"""Bind fresh accepted measurements to the checked poster and its visual review."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import tempfile

from poster_comparison_input import load_fresh_comparison

POSTER = Path(__file__).resolve().parents[1]
MANIFEST = "data/fresh-language-poster-manifest.json"
COMPARISON = "data/fresh-language-figure-evidence.json"
ARTIFACTS = (
    "esm-md-a0-landscape.pptx",
    "esm-md-a0-landscape.pdf",
    "esm-md-a0-landscape.png",
)


def digest(path: Path) -> str:
    """Return the SHA256 identifier of a file.

    Parameters
    ----------
    path : pathlib.Path
        File whose exact bytes identify the record.

    Returns
    -------
    str
        Hexadecimal file identifier.
    """
    return hashlib.sha256(path.read_bytes()).hexdigest()


def owned_file(poster: Path, relative: str) -> Path:
    """Resolve a required file that remains inside the poster directory.

    Parameters
    ----------
    poster : pathlib.Path
        Resolved poster root.
    relative : str
        Nonempty poster-relative file path.

    Returns
    -------
    pathlib.Path
        Existing resolved file owned by the poster.

    Raises
    ------
    ValueError
        If the path is missing, absolute or outside the poster.
    """
    if not isinstance(relative, str) or not relative or Path(relative).is_absolute():
        raise ValueError("Evidence files require poster-relative paths.")
    path = (poster / relative).resolve()
    if not path.is_relative_to(poster) or not path.is_file():
        raise ValueError(
            f"A bound poster file is missing or outside the poster {relative}."
        )
    return path


def read_source_record(path: Path, role: str) -> tuple[dict, dict]:
    """Read a check record and identify the same bytes without a private path.

    Parameters
    ----------
    path : pathlib.Path
        JSON check or visual-review record.
    role : str
        Stable record role when the producer supplies no explicit identifier.

    Returns
    -------
    tuple of dict and dict
        Parsed record and its identifier and exact SHA256.
    """
    payload = path.read_bytes()
    data = json.loads(payload)
    if not isinstance(data, dict):
        raise ValueError("A check or review record must be a JSON object.")
    identifier = data.get("id", role)
    if (
        not isinstance(identifier, str)
        or not identifier.strip()
        or "/" in identifier
        or "\\" in identifier
    ):
        raise ValueError(
            "A check or review record needs an identifier rather than a file path."
        )
    return data, {"id": identifier, "sha256": hashlib.sha256(payload).hexdigest()}


def save_text(path: Path, payload: str) -> None:
    """Replace a prepared text record after writing it in the same directory.

    Parameters
    ----------
    path : pathlib.Path
        Destination for the completed JSON text.
    payload : str
        Fully validated text that will replace the destination.

    Returns
    -------
    None
        Writes and atomically replaces the requested file.
    """
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=path.parent,
            prefix=".fresh-evidence-",
            delete=False,
        ) as stream:
            temporary = Path(stream.name)
            stream.write(payload)
        temporary.replace(path)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()


def refresh(
    poster: Path, checks_path: Path, visual_review_path: Path, write: bool = False
) -> dict:
    """Audit fresh evidence and optionally write its two public records.

    Parameters
    ----------
    poster : pathlib.Path
        Poster directory containing accepted input, artwork and profile.
    checks_path : pathlib.Path
        Current structural, chart, font, geometry and actual QR checks.
    visual_review_path : pathlib.Path
        Human approval of the actual final PDF and its crops.
    write : bool, default=False
        Explicitly write the evidence records after every binding passes.

    Returns
    -------
    dict
        Fresh evidence report bound to the same cohort and exact saved artwork.

    Raises
    ------
    ValueError
        If input, accepted charts, resources, checks, review or profile are stale.
    OSError
        If a required file cannot be read or an authorised write cannot finish.

    Notes
    -----
    The shared loader validates all 96 conditions and 1,152 accepted elapsed
    times. This function records their supplied acceptance limits. It does not
    repeat numerical verification, run a model or measure performance.
    """
    poster = Path(poster).resolve()
    manifest = load_fresh_comparison(poster)
    data = manifest["validated_input"]
    cohort, input_sha = data["cohort"], manifest["input_sha256"]
    manifest_sha = manifest["manifest_sha256"]
    artifacts = {name: digest(owned_file(poster, name)) for name in ARTIFACTS}
    checks, check_identity = read_source_record(
        Path(checks_path), "fresh_language_poster_structural_checks"
    )
    visual, visual_identity = read_source_record(
        Path(visual_review_path), "fresh_language_poster_visual_review"
    )
    if (
        checks.get("passed") is not True
        or checks.get("cohort") != cohort
        or checks.get("input_sha256") != input_sha
        or checks.get("manifest_sha256") != manifest_sha
        or checks.get("artifact_sha256") != artifacts
        or checks.get("qualified_observations") != 1152
    ):
        raise ValueError(
            "The saved-artwork checks are missing or stale for this fresh cohort."
        )
    if (
        visual.get("status") != "approved"
        or visual.get("cohort") != cohort
        or visual.get("input_sha256") != input_sha
        or visual.get("artifacts") != artifacts
        or not isinstance(visual.get("review_scope"), str)
        or not visual["review_scope"].strip()
    ):
        raise ValueError("The actual final artwork needs a matching visual approval.")
    profile_path = owned_file(poster, "project-profile.json")
    profile_payload = profile_path.read_bytes()
    profile = json.loads(profile_payload)
    profile_sha = hashlib.sha256(profile_payload).hexdigest()
    if checks.get("profile_sha256") != profile_sha:
        raise ValueError("The poster profile changed after the saved-artwork checks.")
    if profile.get("evidence", {}).get("measurements") != MANIFEST:
        raise ValueError(
            "The poster profile still identifies a different measurement input."
        )
    expected_qr = profile["poster"]["qr"]["url"]
    qr_checks = checks.get("qr_final_pdf_checks", [])
    if (
        checks.get("qr_decoded_from_actual_pdf") is not True
        or checks.get("qr_url") != expected_qr
        or len(qr_checks) != 2
        or any(item.get("decoded") != [expected_qr] for item in qr_checks)
    ):
        raise ValueError("The latest actual PDF QR checks are missing or stale.")
    physics_path = owned_file(poster, "figure-evidence.json")
    physics_payload = physics_path.read_bytes()
    physics = {
        "source": {
            "path": "figure-evidence.json",
            "sha256": hashlib.sha256(physics_payload).hexdigest(),
        },
        "scope": "The unchanged physical illustrations retain their own accepted states and checks. They are separate from the frozen benchmark input banks.",
        "record": json.loads(physics_payload),
    }
    resource_map = {}
    for item in data["series"]:
        key = (item["model"], item["device"], item["size"])
        entry = {
            "model": item["model"],
            "device": item["device"],
            "size": item["size"],
            "resource": item["resource"],
        }
        if key in resource_map and resource_map[key] != entry:
            raise ValueError(
                "Routes at one workload have different declared resources."
            )
        resource_map[key] = entry
    public_checks = {
        **check_identity,
        "passed": True,
        "cohort": cohort,
        "input_sha256": input_sha,
        "manifest_sha256": manifest_sha,
        "profile_sha256": profile_sha,
        "artifact_sha256": artifacts,
        "qualified_observations": 1152,
        "qr_url": expected_qr,
        "qr_decoded_from_actual_pdf": True,
        "qr_final_pdf_checks": [
            {
                "pdf_scale": item["pdf_scale"],
                "pixels": item["pixels"],
                "decoded": item["decoded"],
            }
            for item in qr_checks
        ],
        "visual_inspection_required": checks.get("visual_inspection_required") is True,
        "desktop_powerpoint_inspected": checks.get("desktop_powerpoint_inspected")
        is True,
    }
    public_visual = {
        **visual_identity,
        "status": "approved",
        "cohort": cohort,
        "input_sha256": input_sha,
        "artifacts": artifacts,
        "review_scope": visual["review_scope"],
    }
    comparison = {
        "status": "accepted",
        "measurement_class": "fresh_eight_route_languages",
        "cohort": cohort,
        "input": manifest["input"],
        "input_identity": manifest["input_identity"],
        "manifest": {"path": MANIFEST, "sha256": manifest_sha},
        "conditions": 96,
        "elapsed_observations": 1152,
        "complete_steps": 1000,
        "repeats": 12,
        "initial_states": data["initial_states"],
        "point_definition": data["point_definition"],
        "displayed_rate_definition": data["displayed_rate_definition"],
        "range_definition": data["range_definition"],
        "cell_update_definition": data["cell_update_definition"],
        "route_order": data["route_order"],
        "normaliser_sha256": data["normaliser_sha256"],
        "sources": {
            source_id: {key: source[key] for key in ("id", "sha256")}
            for source_id, source in data["sources"].items()
        },
        "acceptance": {
            key: data["acceptance"][key]
            for key in (
                "collector_reports_passed",
                "complete_fresh_timings",
                "independent_physics",
                "limits",
                "source_ids",
            )
        },
        "collector_evidence": {
            key: data["evidence"][key] for key in ("id", "sha256", "scope")
        },
        "resources": [resource_map[key] for key in sorted(resource_map)],
        "figures": manifest["figures"],
        "render_metadata": manifest["render_metadata"],
        "chart_output_sha256": {
            model: manifest["loaded_render_metadata"][model]["outputs"]
            for model in ("sw", "ebm")
        },
        "encoding_audit": manifest["encoding_audit"],
        "axis_scales": {
            model: manifest["loaded_render_metadata"][model]["axes"]
            for model in ("sw", "ebm")
        },
        "poster_text": manifest["poster_text"],
        "checks": check_identity,
        "visual_review": visual_identity,
        "evidence_binding_runs_models": False,
        "scope": "Only the newly accepted eight-route cohort supplies the performance plots, notes and Summary. Metadata binding does not strengthen the original numerical, quiet-node or timer limits.",
    }
    old = json.loads(owned_file(poster, "evidence.json").read_text())
    identity = profile["identity"]
    report = {
        "date_utc": datetime.now(timezone.utc).date().isoformat(),
        "format": "A0 landscape, 1189 by 841 mm, one native PowerPoint slide and PDF",
        "scatter_artwork": "The PowerPoint uses PNG scatterplots to preserve marker hatches. Editable plotting source, SVG and PDF exports remain separate.",
        "title": identity["title"],
        "author": identity["author"],
        "affiliation": identity["affiliation"],
        "implementation_label": "ESM.md",
        "generation_route": "Markdown physics and frozen contracts guide Fortran and CUDA Fortran candidates. Compilers build these solvers, while the separate PTX baseline is assembled.",
        "physics": physics,
        "performance_source": manifest["input"]["path"],
        "performance_source_sha256": input_sha,
        "performance_manifest": {"path": MANIFEST, "sha256": manifest_sha},
        "comparison_evidence_source": COMPARISON,
        "comparison_evidence": comparison,
        "summary": manifest["poster_text"],
        "structural_and_qr_checks": public_checks,
        "visual_review": public_visual,
        "desktop_powerpoint_inspection": checks.get("desktop_powerpoint_inspected")
        is True,
        "profile": {"path": "project-profile.json", "sha256": profile_sha},
        "artifacts": artifacts,
    }
    for key in ("branding", "references", "acknowledgement", "formulation_rename"):
        if key in old:
            report[key] = old[key]
    comparison_text = json.dumps(comparison, indent=2, allow_nan=False) + "\n"
    report["comparison_evidence_sha256"] = hashlib.sha256(
        comparison_text.encode()
    ).hexdigest()
    if write:
        comparison_path = poster / COMPARISON
        if comparison_path.exists() and comparison_path.read_text() != comparison_text:
            raise ValueError(
                "A different fresh evidence record already exists. Preserve it before replacement."
            )
        save_text(comparison_path, comparison_text)
        save_text(
            poster / "evidence.json",
            json.dumps(report, indent=2, allow_nan=False) + "\n",
        )
    return report


def main() -> None:
    """Audit by default and write evidence only with an explicit write flag."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--poster-root", type=Path, default=POSTER)
    parser.add_argument("--checks", type=Path, required=True)
    parser.add_argument("--visual-review", type=Path, required=True)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    report = refresh(args.poster_root, args.checks, args.visual_review, args.write)
    print(
        json.dumps(
            {
                "status": "written" if args.write else "audit_passed",
                "cohort": report["comparison_evidence"]["cohort"],
                "conditions": 96,
                "elapsed_observations": 1152,
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

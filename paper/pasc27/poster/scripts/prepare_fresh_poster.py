"""Bind accepted fresh inputs, chart receipts and native poster prose."""

from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from poster_comparison_input import (
    load_fresh_input,
    derive_poster_text,
    validate_fresh_comparison,
)

POSTER = Path(__file__).resolve().parents[1]


def prepare(poster, write=False):
    """Validate a complete prospective manifest before an explicit write.

    Parameters
    ----------
    poster : pathlib.Path
        Self-contained poster project directory.
    write : bool
        Create the manifest only after its files pass validation.

    Returns
    -------
    dict
        Cohort, input identity, condition count and write status.

    Raises
    ------
    ValueError
        If accepted input, encoding audit or chart files are missing or stale.
    FileExistsError
        If a write would replace an existing frozen manifest.
    """
    poster = Path(poster).resolve()
    data, input_sha = load_fresh_input(poster)

    def identity(relative):
        path = (poster / relative).resolve()
        if not path.is_relative_to(poster) or not path.is_file():
            raise ValueError(f"A required publication artifact is missing {relative}.")
        return {
            "path": relative,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        }

    input_record = identity("data/fresh-language-comparison-input.json")
    if input_record["sha256"] != input_sha:
        raise ValueError("The accepted input changed during manifest preparation.")
    figures = {}
    metadata = {}
    for model, stem in (
        ("sw", "language_water_rates"),
        ("ebm", "language_energy_rates"),
    ):
        prefix = "figures/poster/" + stem
        figures[model] = {kind: prefix + "." + kind for kind in ("png", "svg", "pdf")}
        metadata[model] = identity(prefix + ".json")
    manifest = {
        "version": 1,
        "status": "accepted",
        "presentation": "reference_language_scatter",
        "measurement_class": "fresh_eight_route_languages",
        "cohort": data["cohort"],
        "native_picture_format": "png",
        "input": input_record,
        "encoding_audit": identity("data/fresh-language-encoding-audit.json"),
        "figures": figures,
        "render_metadata": metadata,
        "poster_text": derive_poster_text(data),
    }
    validate_fresh_comparison(poster, manifest)
    if write:
        with (poster / "data/fresh-language-poster-manifest.json").open("x") as stream:
            stream.write(json.dumps(manifest, indent=2, allow_nan=False) + "\n")
    return {
        "status": "validated",
        "cohort": data["cohort"],
        "input_sha256": input_sha,
        "conditions": len(data["series"]),
        "written": write,
        "manifest": "data/fresh-language-poster-manifest.json",
    }


def main():
    """Write a manifest only when the caller explicitly selects --write."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--poster-root", type=Path, default=POSTER)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    print(json.dumps(prepare(args.poster_root, args.write), indent=2))


if __name__ == "__main__":
    main()

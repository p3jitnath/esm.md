"""Load display inputs while retaining the accepted matched-comparison input."""

from hashlib import sha256
import json
import math
from pathlib import Path

_GOLDEN_EVIDENCE_SHA256 = (
    "6047270dfc7faddede361130fba1d7b4a6c697132de24c2c8ad857cbff6da749"
)


def load_display_comparison(poster, current):
    """Load and bind an explicitly requested archived language comparison.

    Parameters
    ----------
    poster : pathlib.Path or str
        Poster directory that owns the source records and artwork.
    current : dict
        Previously validated November 12 matched-comparison input.

    Returns
    -------
    dict
        The unchanged current input when no alternate display file exists.
        Otherwise, the archived input with its computed display input hash.

    Raises
    ------
    ValueError
        If the archived scope, stored rates, source records or artwork differ.
    OSError
        If a declared source record or artwork cannot be read.

    Notes
    -----
    Archived points are medians of twelve stored individual rates. This loader
    does not derive rates from times or infer paired gains. The caller retains
    its separate checks of the accepted current matched comparison.
    """
    poster = Path(poster).resolve()
    display_path = poster / "data/archived-language-comparison-update.json"
    if not display_path.exists():
        return current

    def bound_file(record):
        """Read a poster-owned file and check its declared SHA256.

        Parameters
        ----------
        record : dict
            Relative file path and expected SHA256.

        Returns
        -------
        tuple of pathlib.Path and bytes
            Resolved path and the exact bytes whose hash was checked.

        Raises
        ------
        ValueError
            If the path or hash differs from the declared poster input.
        OSError
            If the file cannot be read.
        """
        if not isinstance(record, dict):
            raise ValueError("A source or artwork identity is missing.")
        relative, expected = record.get("path"), record.get("sha256")
        if (
            not isinstance(relative, str)
            or not relative
            or Path(relative).is_absolute()
        ):
            raise ValueError("Comparison files require relative paths.")
        path = (poster / relative).resolve()
        if not path.is_file():
            path = Path(relative).resolve()
        if not path.is_relative_to(poster) or not path.is_file():
            raise ValueError("A comparison file is outside the poster or missing.")
        payload = path.read_bytes()
        if not isinstance(expected, str) or sha256(payload).hexdigest() != expected:
            raise ValueError(f"The comparison file hash differs for {relative}.")
        return path, payload

    if not display_path.resolve().is_relative_to(poster):
        raise ValueError("The display input must remain inside the poster directory.")
    display_payload = display_path.read_bytes()
    active = json.loads(display_payload)
    if (
        active.get("comparison_class") != "archived_language_controls"
        or active.get("status") != "recorded_comparison"
        or active.get("presentation") != "language_comparisons"
    ):
        raise ValueError("The alternate display is not a recorded language comparison.")
    for field in ("cpu_worker_disclosure", "historical_qualification_scope"):
        if not isinstance(active.get(field), str) or not active[field].strip():
            raise ValueError(f"The archived comparison requires {field}.")

    current_source = active.get("current_matched_source", {})
    if current_source.get("path") != "data/accepted-performance-update.json":
        raise ValueError("The unchanged current matched input must be identified.")
    if json.loads(bound_file(current_source)[1]) != current:
        raise ValueError("The bound matched input differs from the validated input.")

    evidence_source = active.get("source_evidence", {})
    if (
        evidence_source.get("path") != "data/performance-figure-evidence.json"
        or evidence_source.get("sha256") != _GOLDEN_EVIDENCE_SHA256
    ):
        raise ValueError(
            "The original language-comparison evidence must be identified."
        )
    proof = json.loads(bound_file(evidence_source)[1])
    records = proof.get("source_records", {})
    expected_sources = {
        "current": "data/results-current.json",
        "historical_cpu": "data/historical/benchmark.json",
        "historical_gpu": "data/historical/gpu-benchmark.json",
    }
    if set(records) != set(expected_sources):
        raise ValueError("All three original comparison source records are required.")
    for role, expected_path in expected_sources.items():
        if records[role].get("path") != expected_path:
            raise ValueError("An original comparison source path differs.")
        bound_file(records[role])

    labels = proof.get("series", [])
    if len(labels) != 7 or len(set(labels)) != 7 or labels[0] != "ESM.md":
        raise ValueError("The archived comparison requires its seven original series.")
    for model, sizes in (("sw", [64, 256, 1024]), ("ebm", [128, 4096, 65536])):
        metadata = active.get("render_metadata", {}).get(model, {})
        plotted = proof.get("plotted_data", {}).get(model)
        if (
            metadata.get("presentation") != "language_comparisons"
            or metadata.get("mode") != "separate_language_cohorts"
            or metadata.get("authentic_plotted_data") != plotted
            or not isinstance(plotted, dict)
            or set(plotted) != {"cpu", "gpu"}
        ):
            raise ValueError(
                "Rendered language data differ from the original evidence."
            )
        for platform in ("cpu", "gpu"):
            series = plotted[platform]
            if len(series) != 7 or [item.get("label") for item in series] != labels:
                raise ValueError("Every platform requires the seven original series.")
            for item in series:
                measurements = item.get("measurements", [])
                if (
                    len(measurements) != 3
                    or [row.get("size") for row in measurements] != sizes
                ):
                    raise ValueError("Every series requires its three original grids.")
                for row in measurements:
                    rates = row.get("million_updates_per_second", [])
                    if (
                        row.get("count") != 12
                        or len(rates) != 12
                        or any(
                            isinstance(rate, bool)
                            or not isinstance(rate, (int, float))
                            or not math.isfinite(rate)
                            or rate <= 0
                            for rate in rates
                        )
                    ):
                        raise ValueError(
                            "Every condition requires twelve stored rates."
                        )
                    if (
                        item["label"] == "ESM.md"
                        and row.get("source_variant") != "fortran"
                    ):
                        raise ValueError("The archived ESM.md route must be Fortran.")
        outputs = metadata.get("outputs")
        if not isinstance(outputs, dict) or not outputs:
            raise ValueError("Exported language figures require their output hashes.")
        bound_outputs = {
            bound_file({"path": path, "sha256": digest})[0].resolve()
            for path, digest in outputs.items()
        }
        figures = active.get("figures", {}).get(model, {})
        for kind in ("svg", "png"):
            relative = figures.get(kind)
            if (
                not isinstance(relative, str)
                or Path(relative).is_absolute()
                or Path(relative).suffix != "." + kind
            ):
                raise ValueError("Each language figure requires SVG and PNG artwork.")
            candidates = ((poster / relative).resolve(), Path(relative).resolve())
            if not any(path in bound_outputs for path in candidates):
                raise ValueError("Figure artwork is not bound to the render outputs.")

    active["display_comparison_input_sha256"] = sha256(display_payload).hexdigest()
    return active

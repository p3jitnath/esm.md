"""Bind accepted fresh measurements to the poster.

A cohort is a complete collection of measurements made with one protocol.
A SHA256 hash identifies exact file bytes. The separate encoding audit checks
measured values against retained source records. This module checks declared
shapes, resources and file bindings.
"""

from hashlib import sha256
import json
import math
from pathlib import Path
import re

ROUTES = (
    "assembly",
    "esm",
    "fortran_tuned",
    "fortran_vanilla",
    "julia_tuned",
    "julia_vanilla",
    "python_tuned",
    "python_vanilla",
)
LABELS = (
    "Assembly",
    "ESM.md",
    "Fortran Tuned",
    "Fortran Vanilla",
    "Julia Tuned",
    "Julia Vanilla",
    "Python Tuned",
    "Python Vanilla",
)
SIZES = {"sw": (64, 256, 1024), "ebm": (128, 4096, 65536)}
SOURCE_ROUTES = {
    "CPU": (
        "assembly",
        "esm_md_fortran",
        "fortran_tuned",
        "fortran_vanilla",
        "julia_tuned",
        "julia_vanilla",
        "python_tuned",
        "python_vanilla",
    ),
    "GPU": (
        "assembly",
        "gpu_esm_fortran",
        "gpu_fortran",
        "gpu_fortran_vanilla",
        "julia",
        "julia_vanilla",
        "gpu_python",
        "gpu_python_vanilla",
    ),
}
POINT_DEFINITION = "updates / median_seconds"
DISPLAYED_RATE_DEFINITION = "updates / median_seconds / scale"
RANGE_DEFINITION = "min(rates), max(rates), where rates = updates / raw_seconds / scale"
_SHA256 = re.compile(r"[0-9a-f]{64}")
_COMPUTE_ID = object()


def _require(condition, message):
    """Reject a failed metadata condition.

    Parameters
    ----------
    condition : bool
        Whether the required condition holds.
    message : str
        Explanation of the failed condition.

    Raises
    ------
    ValueError
        If the condition does not hold.
    """
    if not condition:
        raise ValueError(message)


def _positive(value):
    """Check that a JSON number is positive and finite.

    Parameters
    ----------
    value : object
        Value from the input document.

    Returns
    -------
    bool
        True for a positive finite integer or floating-point number.
    """
    try:
        return type(value) in (int, float) and value > 0 and math.isfinite(value)
    except OverflowError:
        return False


def _condition_key(record):
    """Read a complete model, processor, grid and route identity.

    Parameters
    ----------
    record : dict
        One input observation or displayed point.

    Returns
    -------
    tuple
        Model, processor, grid size and route.

    Raises
    ------
    ValueError
        If an identity field has the wrong type or value.
    """
    _require(isinstance(record, dict), "A condition must be an object.")
    model, device, size, route = [
        record.get(k) for k in ("model", "device", "size", "route")
    ]
    _require(
        isinstance(model, str)
        and model in SIZES
        and device in ("CPU", "GPU")
        and type(size) is int
        and size in SIZES[model]
        and isinstance(route, str)
        and route in ROUTES,
        "A condition has an unsupported model, processor, grid or route.",
    )
    return model, device, size, route


def _bound_file(poster, relative, expected=_COMPUTE_ID):
    """Read a poster-owned file and check its optional SHA256 identity.

    Parameters
    ----------
    poster : pathlib.Path
        Resolved poster directory.
    relative : str or pathlib.Path
        File path relative to that directory.
    expected : str, optional
        Required SHA256. Omit it when computing a new input identity.

    Returns
    -------
    tuple
        File bytes and their SHA256.

    Raises
    ------
    ValueError
        If the path escapes the poster, is missing, or has a different identity.
    OSError
        If the declared file cannot be read.
    """
    _require(
        isinstance(relative, (str, Path)), "A poster file requires a relative path."
    )
    relative = Path(relative)
    path = (poster / relative).resolve()
    _require(
        not relative.is_absolute() and path.is_relative_to(poster) and path.is_file(),
        f"A bound file is outside the poster or missing {relative}.",
    )
    payload = path.read_bytes()
    digest = sha256(payload).hexdigest()
    if expected is not _COMPUTE_ID:
        _require(
            isinstance(expected, str) and _SHA256.fullmatch(expected),
            "A bound file requires a SHA256.",
        )
        _require(digest == expected, f"The bound file identity differs for {relative}.")
    return payload, digest


def validate_fresh_input(data):
    """Check the accepted cohort shape and its measurement declarations.

    Parameters
    ----------
    data : dict
        Fresh observations for eight routes, six grids and two processors.

    Returns
    -------
    dict
        The same input object, without mutation.

    Raises
    ------
    ValueError
        If acceptance, coverage, resources, source identities or values are incomplete.

    Notes
    -----
    This checks metadata only. The separate accepted encoding audit owns raw
    timing and statistical recomputation and full source-document binding.
    """
    _require(isinstance(data, dict), "The fresh input must be an object.")
    _require(
        type(data.get("schema_version")) is int and data["schema_version"] == 1,
        "The fresh input schema version differs.",
    )
    _require(
        data.get("status") == "accepted" and "plotted_data" not in data,
        "Only accepted fresh observations are supported.",
    )
    for field in ("cohort", "job", "node", "gpu_uuid"):
        _require(
            isinstance(data.get(field), str) and data[field].strip(),
            f"The fresh input requires {field}.",
        )
    _require(
        data.get("point_definition") == POINT_DEFINITION
        and data.get("displayed_rate_definition") == DISPLAYED_RATE_DEFINITION
        and data.get("range_definition") == RANGE_DEFINITION,
        "The fresh point and range definitions differ.",
    )
    _require(
        data.get("cell_update_definition")
        == "All fields at one interior cell advanced through one complete step.",
        "The complete cell-update definition differs.",
    )
    _require(
        data.get("initial_states") == {"sw": "MIXED", "ebm": "CLIMATE"},
        "Both model initial-state banks must be identified.",
    )
    _require(
        data.get("gpu_model") == "NVIDIA GH200 120GB", "The recorded GPU model differs."
    )
    _require(
        type(data.get("complete_steps")) is int
        and data["complete_steps"] == 1000
        and type(data.get("repeats")) is int
        and data["repeats"] == 12,
        "Fresh cases require 1,000 steps and twelve runs.",
    )
    _require(
        data.get("route_order") == list(ROUTES),
        "All eight separate routes are required in their declared order.",
    )
    _require(
        isinstance(data.get("normaliser_sha256"), str)
        and _SHA256.fullmatch(data["normaliser_sha256"]),
        "The normaliser identity is missing.",
    )
    acceptance, sources, evidence = [
        data.get(k) for k in ("acceptance", "sources", "evidence")
    ]
    _require(
        isinstance(acceptance, dict)
        and acceptance.get("collector_reports_passed") is True
        and acceptance.get("complete_fresh_timings") is True,
        "The complete collector acceptance is missing.",
    )
    for field in ("independent_physics", "limits"):
        _require(
            isinstance(acceptance.get(field), str) and acceptance[field].strip(),
            f"Acceptance requires its {field} scope.",
        )
    _require(
        isinstance(sources, dict)
        and sources
        and acceptance.get("source_ids") == list(sources),
        "Accepted source IDs must match the declared sources.",
    )
    for source_id, source in sources.items():
        _require(
            isinstance(source_id, str)
            and source_id.strip()
            and isinstance(source, dict)
            and source.get("id") == source_id
            and isinstance(source.get("sha256"), str)
            and _SHA256.fullmatch(source["sha256"]),
            "A source acceptance identity is incomplete.",
        )
    _require(
        isinstance(evidence, dict)
        and isinstance(evidence.get("id"), str)
        and evidence["id"].strip()
        and isinstance(evidence.get("sha256"), str)
        and _SHA256.fullmatch(evidence["sha256"])
        and isinstance(evidence.get("scope"), str)
        and evidence["scope"].strip(),
        "The retained collector evidence identity is missing.",
    )
    series = data.get("series")
    _require(
        isinstance(series, list) and len(series) == 96,
        "The fresh input requires 96 conditions.",
    )
    seen, identifiers = set(), set()
    for item in series:
        key = _condition_key(item)
        _require(key not in seen, "A fresh condition is duplicated.")
        seen.add(key)
        model, device, size, route = key
        index = ROUTES.index(route)
        _require(
            isinstance(item.get("id"), str)
            and item["id"].strip()
            and item["id"] not in identifiers,
            "Every condition requires a unique ID.",
        )
        identifiers.add(item["id"])
        _require(
            item.get("label") == LABELS[index]
            and item.get("source_route") == SOURCE_ROUTES[device][index],
            "A route label or source route differs.",
        )
        shape = [size, size] if model == "sw" else [size]
        updates = (size * size if model == "sw" else size) * 1000
        _require(
            item.get("shape") == shape
            and type(item.get("complete_steps")) is int
            and item["complete_steps"] == 1000
            and type(item.get("updates")) is int
            and item["updates"] == updates,
            "A condition has a different workload or update count.",
        )
        expected_unit = (
            "million_cell_updates_per_second"
            if device == "CPU"
            else "billion_cell_updates_per_second"
        )
        expected_scale = 1e6 if device == "CPU" else 1e9
        _require(
            item.get("unit") == expected_unit
            and type(item.get("scale")) in (int, float)
            and item["scale"] == expected_scale,
            "A condition has different displayed units or scaling.",
        )
        for field in ("raw_seconds", "rates"):
            values = item.get(field)
            _require(
                isinstance(values, list)
                and len(values) == 12
                and all(_positive(v) for v in values),
                f"Each condition requires twelve positive finite {field}.",
            )
        _require(
            item.get("repeat_ids") == list(range(12))
            and all(type(v) is int for v in item["repeat_ids"]),
            "The twelve repeat IDs differ.",
        )
        indices = item.get("sample_indices")
        _require(
            isinstance(indices, list)
            and len(indices) == 12
            and all(type(v) is int and v >= 0 for v in indices)
            and len(set(indices)) == 12,
            "The twelve source sample indices are incomplete.",
        )
        _require(
            all(
                _positive(item.get(k))
                for k in ("median_seconds", "point", "low", "high")
            )
            and item["low"] <= item["point"] <= item["high"],
            "A recorded point or observed range is invalid.",
        )
        _require(
            isinstance(item.get("evidence_source"), str)
            and item["evidence_source"] in sources,
            "A condition lacks its accepted source ID.",
        )
        resource = item.get("resource")
        _require(
            isinstance(resource, dict), "Every condition requires resource metadata."
        )
        if device == "CPU":
            team = 128 if model == "ebm" and size == 128 else 248
            _require(
                type(item.get("actual_workers")) is int
                and item["actual_workers"] == team
                and type(resource.get("cpu_budget")) is int
                and resource["cpu_budget"] == 248
                and type(resource.get("actual_workers")) is int
                and resource["actual_workers"] == team
                and item.get("gpu_uuid") is None,
                "CPU worker counts or the configured budget differ.",
            )
        else:
            _require(
                item.get("actual_workers") is None
                and item.get("gpu_uuid") == data["gpu_uuid"]
                and resource.get("gpu_uuid") == data["gpu_uuid"]
                and type(resource.get("gpu_count")) is int
                and resource["gpu_count"] == 1
                and type(resource.get("host_cpu")) is int
                and resource["host_cpu"] == 1,
                "A GPU condition differs from the declared device or host resources.",
            )
    expected = {
        (model, device, size, route)
        for model, sizes in SIZES.items()
        for device in ("CPU", "GPU")
        for size in sizes
        for route in ROUTES
    }
    _require(
        seen == expected, "The complete fresh route and workload coverage differs."
    )
    return data


def load_fresh_input(poster, path="data/fresh-language-comparison-input.json"):
    """Load fresh observations and calculate their exact file identity.

    Parameters
    ----------
    poster : str or pathlib.Path
        Poster directory containing its portable data files.
    path : str or pathlib.Path
        Input path relative to that directory.

    Returns
    -------
    tuple of dict and str
        Validated input and its SHA256.

    Raises
    ------
    ValueError
        If the file or its fresh metadata is invalid.
    OSError
        If the input file cannot be read.
    """
    payload, digest = _bound_file(Path(poster).resolve(), path)
    return validate_fresh_input(json.loads(payload)), digest


def derive_poster_text(data):
    """Prepare cohort notes and a general contribution summary.

    Parameters
    ----------
    data : dict
        Accepted fresh cohort with complete route and workload coverage.

    Returns
    -------
    dict
        Three chart notes and three Summary bullets.

    Raises
    ------
    ValueError
        If the accepted cohort is incomplete.

    Notes
    -----
    The Summary describes the demonstrated workflow and reusable lessons.
    Detailed performance comparisons remain in the accepted figure records.
    """
    validate_fresh_input(data)
    summaries = [
        "A readable physics specification guides solver generation.",
        "Verification is based on physical checks and byte agreement.",
        "Reusable skills preserve measured lessons for future work.",
    ]
    return {
        "chart_notes": [
            "Runs use frozen input banks for 1,000 steps. Points divide updates by median time. Lines show the range of 12 individual rates.",
            "One cell update advances all fields at one interior cell through a complete step. Timing includes overlap work.",
            "CPU uses 248 workers, with 128 for EBM at 128 bands. GPU uses one GH200 device.",
        ],
        "takeaways": summaries,
    }


def validate_fresh_comparison(poster, manifest):
    """Validate a proposed manifest against fresh data and exported artwork.

    Parameters
    ----------
    poster : str or pathlib.Path
        Poster directory containing the bound files.
    manifest : dict
        Proposed fresh manifest. It need not have been saved.

    Returns
    -------
    dict
        Manifest with validated_input, input_sha256, input_identity,
        loaded_render_metadata and loaded_encoding_audit added.

    Raises
    ------
    ValueError
        If any declared file, cohort, text, acceptance or artwork binding differs.
    OSError
        If a bound file cannot be read.

    Notes
    -----
    The accepted encoding audit owns timing, statistical and full source checks.
    This loader checks that its identity belongs to the displayed fresh input.
    """
    poster = Path(poster).resolve()
    active = manifest
    _require(
        isinstance(active, dict)
        and type(active.get("version")) is int
        and active["version"] == 1
        and active.get("status") == "accepted"
        and active.get("presentation") == "reference_language_scatter"
        and active.get("measurement_class") == "fresh_eight_route_languages"
        and active.get("native_picture_format") == "png",
        "The fresh poster manifest has a different acceptance or presentation.",
    )
    identity = active.get("input")
    _require(isinstance(identity, dict), "The fresh input identity is missing.")
    input_payload, digest = _bound_file(
        poster, identity.get("path"), identity.get("sha256")
    )
    data = validate_fresh_input(json.loads(input_payload))
    _require(
        active.get("cohort") == data["cohort"],
        "The manifest and fresh input cohorts differ.",
    )
    binding = active.get("encoding_audit")
    _require(
        isinstance(binding, dict), "The accepted encoding audit identity is missing."
    )
    audit = json.loads(
        _bound_file(poster, binding.get("path"), binding.get("sha256"))[0]
    )
    _require(
        isinstance(audit, dict)
        and audit.get("status") == "passed"
        and audit.get("passed") is True
        and audit.get("cohort") == data["cohort"]
        and audit.get("input_sha256") == digest,
        "The encoding audit is not accepted for this fresh input.",
    )
    expected_counts = {"conditions": 96, "raw_times": 1152, "individual_rates": 1152}
    _require(
        audit.get("checked_counts") == expected_counts
        and all(type(v) is int for v in audit["checked_counts"].values()),
        "The encoding audit coverage differs.",
    )
    for field, count in (
        ("points", 96),
        ("point_and_range_values", 288),
        ("elapsed_times", 1152),
        ("distinct_routes", 8),
        ("workloads_per_processor", 6),
        ("runs_per_point", 12),
    ):
        _require(
            type(audit.get(field)) is int and audit[field] == count,
            f"The encoding audit count differs for {field}.",
        )
    _require(
        isinstance(audit.get("audit_id"), str)
        and audit["audit_id"].strip()
        and isinstance(audit.get("audit_source_sha256"), str)
        and _SHA256.fullmatch(audit["audit_source_sha256"])
        and isinstance(audit.get("scope"), str)
        and audit["scope"].strip(),
        "The encoding audit identity or scope is missing.",
    )
    required_flags = (
        "raw_timing_source_binding_checked",
        "statistics_recomputed_exactly",
        "complete_local_source_documents_checked",
    )
    scope_flags = audit.get("scope_flags", {})
    _require(
        isinstance(scope_flags, dict)
        and all(scope_flags.get(k) is True for k in required_flags)
        and audit.get("all_original_documents_retained_locally") is True
        and audit.get("all_point_and_range_values_recomputed_exactly") is True
        and audit.get("public_input_contains_private_paths_or_raw_documents") is False
        and audit.get("archived_timing_sources_used") is False,
        "The encoding audit lacks its required fresh-data scope.",
    )
    _require(
        active.get("poster_text") == derive_poster_text(data),
        "The poster notes or Summary differ from accepted points.",
    )
    figures, bindings = active.get("figures"), active.get("render_metadata")
    _require(
        isinstance(figures, dict)
        and set(figures) == set(SIZES)
        and isinstance(bindings, dict)
        and set(bindings) == set(SIZES),
        "Both model figure and receipt bindings are required.",
    )
    renderer_path = "scripts/render_language_scatter.py"
    _, renderer_digest = _bound_file(poster, renderer_path)
    renderer_identity = {"path": renderer_path, "sha256": renderer_digest}
    loaded = {}
    for model in SIZES:
        record = bindings[model]
        _require(isinstance(record, dict), "A render receipt identity is missing.")
        receipt = json.loads(
            _bound_file(poster, record.get("path"), record.get("sha256"))[0]
        )
        _require(
            isinstance(receipt, dict)
            and receipt.get("status") == "accepted"
            and receipt.get("fresh_measurement") is True
            and receipt.get("presentation") == "reference_language_scatter"
            and receipt.get("profile") == "poster"
            and receipt.get("model") == model
            and receipt.get("cohort") == data["cohort"]
            and receipt.get("point_definition") == data["point_definition"]
            and receipt.get("displayed_rate_definition")
            == data["displayed_rate_definition"],
            "A poster receipt differs from the accepted fresh cohort.",
        )
        _require(
            receipt.get("input_identity") == identity,
            "A render receipt is bound to a different fresh input.",
        )
        _require(
            receipt.get("renderer_identity") == renderer_identity,
            "A render receipt differs from the current renderer source identity.",
        )
        expected = {
            _condition_key(item): item
            for item in data["series"]
            if item["model"] == model
        }
        displayed = receipt.get("displayed_measurements")
        _require(
            isinstance(displayed, list) and len(displayed) == 48,
            "A model receipt must retain all 48 fresh conditions.",
        )
        seen = set()
        for point in displayed:
            key = _condition_key(point)
            _require(
                key in expected and key not in seen,
                "A rendered condition is missing, duplicated or from another model.",
            )
            seen.add(key)
            original = expected[key]
            _require(
                point.get("source_record") == original
                and point.get("label") == original["label"]
                and all(
                    _positive(point.get(k)) and point[k] == original[k]
                    for k in ("point", "low", "high")
                ),
                "A rendered point or source record differs from the accepted input.",
            )
        outputs, artwork = receipt.get("outputs"), figures[model]
        _require(
            isinstance(outputs, dict)
            and isinstance(artwork, dict)
            and set(artwork) == {"png", "svg", "pdf"},
            "Each fresh figure requires PNG, SVG and PDF bindings.",
        )
        _require(
            all(isinstance(value, str) for value in artwork.values())
            and set(outputs) == set(artwork.values()),
            "A render receipt has missing or undeclared artwork outputs.",
        )
        for kind, relative in artwork.items():
            _require(
                isinstance(relative, str)
                and Path(relative).suffix == "." + kind
                and relative in outputs,
                "Artwork is not bound to the declared render receipt.",
            )
            _bound_file(poster, relative, outputs[relative])
        loaded[model] = receipt
    return {
        **active,
        "validated_input": data,
        "input_sha256": digest,
        "input_identity": identity,
        "loaded_render_metadata": loaded,
        "loaded_encoding_audit": audit,
    }


def load_fresh_comparison(poster):
    """Load and validate the saved fresh poster manifest.

    Parameters
    ----------
    poster : str or pathlib.Path
        Poster directory containing the manifest and bound files.

    Returns
    -------
    dict
        Manifest augmented with its parsed file identity, validated data and receipts.

    Raises
    ------
    ValueError
        If the manifest or any bound observation, receipt or artwork differs.
    OSError
        If a bound file cannot be read.
    """
    poster = Path(poster).resolve()
    payload, digest = _bound_file(poster, "data/fresh-language-poster-manifest.json")
    result = validate_fresh_comparison(poster, json.loads(payload))
    return {**result, "manifest_sha256": digest}

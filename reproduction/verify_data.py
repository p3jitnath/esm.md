"""Verify the PASC27 source and data bindings and print the comparison rates."""

import csv
import gzip
import hashlib
import json
import math
from pathlib import Path
from statistics import median
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
REPRODUCTION = ROOT / "reproduction"
DATA = ROOT / "paper/pasc27/poster/data"


def read(path):
    """Read a UTF-8 JSON record."""
    return json.loads(path.read_text(encoding="utf-8"))


def digest(path):
    """Return the SHA-256 identity of a file's bytes."""
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def require(condition, message):
    """Fail with the affected record rather than silently accepting it."""
    if not condition:
        raise ValueError(message)


def array_check(value, metadata, name):
    """Check the saved shape, binary type and ordered array bytes."""
    require(
        list(value.shape) == metadata["shape"]
        and value.dtype.str == metadata["dtype"]
        and hashlib.sha256(value.tobytes(order="C")).hexdigest() == metadata["sha256"],
        f"Array identity mismatch for {name}.",
    )


def check_arrays(expected_manifest):
    """Check every frozen input and canonical stage or state in the release."""
    directory = REPRODUCTION / "inputs"
    manifest = read(directory / "manifest.json")
    require(
        manifest["input_manifest_sha256"] == expected_manifest,
        "Input manifest identity mismatch.",
    )
    require(len(manifest["banks"]) == 6, "Expected six workload banks.")
    for bank in manifest["banks"]:
        source = bank["inputs"]
        path = directory / source["file"]
        require(
            digest(path) == source["file_sha256"],
            f"Input archive identity mismatch for {path.name}.",
        )
        with np.load(path, allow_pickle=False) as arrays:
            require(
                set(arrays.files) == set(source["arrays"]),
                f"Unexpected arrays in {path.name}.",
            )
            for name, metadata in source["arrays"].items():
                array_check(arrays[name], metadata, f"{path.name}/{name}")
        for name, metadata in bank["canonical_outputs"]["arrays"].items():
            path = directory / metadata["file"]
            require(
                digest(path) == metadata["file_sha256"],
                f"Reference archive identity mismatch for {path.name}.",
            )
            with gzip.open(path, "rb") as stream:
                array_check(np.load(stream, allow_pickle=False), metadata, path.name)


def main():
    """Recompute the paper rates from the elapsed times and report them as CSV."""
    manifest = read(REPRODUCTION / "source_manifest.json")
    for source in manifest["source_snapshots"]:
        require(
            digest(ROOT / source["path"]) == source["sha256"],
            f"Source identity mismatch for {source['path']}.",
        )
    comparison = DATA / "fresh-language-comparison-input.json"
    require(
        digest(comparison) == manifest["comparison_input_sha256"],
        "Comparison input identity mismatch.",
    )
    series = read(comparison)["series"]
    require(len(series) == 96, "Expected 96 language comparison conditions.")
    check_arrays(manifest["record_sha256"]["input_banks"])
    output = csv.writer(sys.stdout)
    output.writerow(
        (
            "study",
            "device",
            "model",
            "grid",
            "cpu_budget",
            "route",
            "point_billion_per_s",
            "min_billion_per_s",
            "max_billion_per_s",
        )
    )
    for item in series:
        times = item["raw_seconds"]
        require(
            len(times) == 12 and all(math.isfinite(t) and t > 0 for t in times),
            f"Invalid times for {item['id']}.",
        )
        rates = [item["updates"] / time / item["scale"] for time in times]
        point = item["updates"] / median(times) / item["scale"]
        require(
            all(
                math.isclose(actual, saved, rel_tol=1e-12)
                for actual, saved in zip(
                    (point, min(rates), max(rates)),
                    (item["point"], item["low"], item["high"]),
                )
            ),
            f"Rate mismatch for {item['id']}.",
        )
        to_billions = item["scale"] / 1e9
        output.writerow(
            (
                "comparison",
                item["device"],
                item["model"],
                item["size"],
                item["resource"].get("cpu_budget", ""),
                item["route"],
                point * to_billions,
                min(rates) * to_billions,
                max(rates) * to_billions,
            )
        )
    scaling_path = DATA / "cpu-scaling-results-20261112.json"
    require(
        digest(scaling_path) == manifest["scaling_input_sha256"],
        "Scaling input identity mismatch.",
    )
    scaling = read(scaling_path)["paired_records"]
    require(len(scaling) == 66, "Expected 66 scaling conditions.")
    for item in scaling:
        pairs = item["paired_samples"]
        require(len(pairs) == 12, f"Invalid pair count for {item['run_id']}.")
        updates = item["complete_cell_updates"]
        for route in ("baseline", "esm_md"):
            times = [pair[f"{route}_seconds"] for pair in pairs]
            require(
                all(math.isfinite(t) and t > 0 for t in times),
                f"Invalid times for {item['run_id']}.",
            )
            output.writerow(
                (
                    "scaling",
                    "CPU",
                    item["model"],
                    item["shape"][0],
                    item["cpu_cores"],
                    route,
                    updates / median(times) / 1e9,
                    updates / max(times) / 1e9,
                    updates / min(times) / 1e9,
                )
            )


if __name__ == "__main__":
    main()

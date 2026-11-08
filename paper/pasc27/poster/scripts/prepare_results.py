"""Curate accepted twelve-pair CPU and GPU timing records for the poster."""

import argparse
import hashlib
import json
import statistics
from pathlib import Path

POSTER = Path(__file__).resolve().parents[1]
REPOSITORY = Path(__file__).resolve().parents[4]
DEFAULT_SOURCES = {
    "cpu_sw": ".runtime/cpu_fortran_20261108/sw_final_timing.json",
    "cpu_ebm": ".runtime/cpu_fortran_20261108/ebm_final_timing.json",
    "gpu_sw": ".runtime/sw/gpu_fortran_20261108/final_evaluation/bench/.runs/gpu/sw/timing.json",
    "gpu_ebm": ".runtime/ebm/gpu_fortran_20261108/final_evaluation/bench/.runs/gpu/eb/timing.json",
}

CURRENT_SOURCE_PATH_ALIASES = {
    "note": "Historical timing source names map to current public paths. Original timing paths and hashes remain unchanged.",
    "paths": {
        "src/ebm/energy_balance_solver.f90": "src/ebm/solver.f90",
        "src/ebm/gpu/budyko_sellers.ptx": ".archive/sw_ebm_assembly/src/ebm/gpu/solver.ptx",
        "src/ebm/gpu/energy_balance_solver.cuf": "src/ebm/gpu/solver.cuf",
        "src/sw/gpu/2d_rusanov_ssprk2.ptx": ".archive/sw_ebm_assembly/src/sw/gpu/solver.ptx",
        "src/sw/gpu/shallow_water_solver.cuf": "src/sw/gpu/solver.cuf",
        "src/sw/shallow_water_solver.f90": "src/sw/solver.f90",
    },
}


def summary(values):
    """Return the median and observed range of finite positive observations.

    Parameters
    ----------
    values : sequence of float
        Positive observations in a single declared unit.

    Returns
    -------
    dict
        Median, minimum, maximum and sample count. No confidence interval is inferred.
    """
    if not values or any(not (0 < value < float("inf")) for value in values):
        raise ValueError("Timing observations must be finite and positive.")
    return {
        "median": statistics.median(values),
        "minimum": min(values),
        "maximum": max(values),
        "count": len(values),
    }


def collect_cpu(document):
    """Extract accepted CPU observations while retaining actual repeat pairings.

    Parameters
    ----------
    document : dict
        Completed native timing report with twelve repeats and complete state checks.

    Returns
    -------
    list of dict
        One row per grid with seconds and million complete cell updates per second.
    """
    if not document.get("passed") or document["protocol"]["repeats"] != 12:
        raise ValueError("The poster requires a completed twelve-pair report.")
    output = []
    for grid in document["results"]:
        if not grid.get("zero_differing_output_bytes") or not grid.get(
            "all_three_state_buffers_identical"
        ):
            raise ValueError(
                "A CPU grid does not establish complete exact state agreement."
            )
        samples = [
            {
                "name": entry["implementation"],
                "repeat": entry["repeat"],
                "seconds": entry["elapsed_ns"] / 1e9,
                "million_updates_per_second": grid["updates"]
                * 1e3
                / entry["elapsed_ns"],
            }
            for entry in grid["samples"]
        ]
        output.append(grid_record(grid["size"], grid["steps"], samples))
    return output


def collect_gpu(document):
    """Extract accepted GPU event observations from the same physical update.

    Parameters
    ----------
    document : dict
        Completed GPU timing report with twelve accepted repeats for each variant.

    Returns
    -------
    list of dict
        One row per grid with event seconds, rates and paired rate ratios.
    """
    if not document.get("passed"):
        raise ValueError("A GPU report is not accepted.")
    output = []
    for size in sorted({entry["size"] for entry in document["records"]}):
        entries = [entry for entry in document["records"] if entry["size"] == size]
        if any(entry["differing_bytes"] for entry in entries):
            raise ValueError("A timed GPU output differs from its canonical reference.")
        samples = [
            {
                "name": entry["name"],
                "repeat": entry["repeat"],
                "seconds": entry["milliseconds"] / 1e3,
                "million_updates_per_second": entry["million_cell_steps_per_second"],
            }
            for entry in entries
        ]
        output.append(grid_record(size, entries[0]["steps"], samples))
    return output


def grid_record(size, steps, samples):
    """Summarise one grid and pair observations by their retained repeat number.

    Parameters
    ----------
    size, steps : int
        Grid dimension or band count, and complete steps per timed batch.
    samples : list of dict
        Two variants with twelve repeat-indexed rate and elapsed-time observations.

    Returns
    -------
    dict
        Source observations and their rate summaries. The ratio is Fortran divided by assembly.
    """
    names = {item["name"] for item in samples}
    candidates = names - {"assembly"}
    if len(candidates) != 1:
        raise ValueError("A matched poster comparison requires exactly two variants.")
    fortran = candidates.pop()
    grouped = {
        name: {item["repeat"]: item for item in samples if item["name"] == name}
        for name in ("assembly", fortran)
    }
    if any(set(values) != set(range(12)) for values in grouped.values()):
        raise ValueError(
            "Each implementation must have twelve matching repeat indices."
        )
    pairs = []
    for repeat in range(12):
        assembly = grouped["assembly"][repeat]
        generated = grouped[fortran][repeat]
        ratio = assembly["seconds"] / generated["seconds"]
        rate_ratio = (
            generated["million_updates_per_second"]
            / assembly["million_updates_per_second"]
        )
        if abs(ratio / rate_ratio - 1) > 1e-12:
            raise ValueError("Rate and elapsed-time ratios disagree.")
        pairs.append(
            {
                "repeat": repeat,
                "assembly_seconds": assembly["seconds"],
                "fortran_seconds": generated["seconds"],
                "assembly_million_updates_per_second": assembly[
                    "million_updates_per_second"
                ],
                "fortran_million_updates_per_second": generated[
                    "million_updates_per_second"
                ],
                "fortran_to_assembly": ratio,
            }
        )
    assembly_summary = summary(
        [p["assembly_million_updates_per_second"] for p in pairs]
    )
    fortran_summary = summary([p["fortran_million_updates_per_second"] for p in pairs])
    paired_summary = summary([p["fortran_to_assembly"] for p in pairs])
    point = fortran_summary["median"] / assembly_summary["median"]
    if not paired_summary["minimum"] <= point <= paired_summary["maximum"]:
        raise ValueError("The rate-ratio point lies outside the observed paired range.")
    return {
        "size": size,
        "steps": steps,
        "paired_samples": pairs,
        "assembly": assembly_summary,
        "fortran": fortran_summary,
        "ratio": {
            "point": point,
            "paired_median": paired_summary["median"],
            "minimum": paired_summary["minimum"],
            "maximum": paired_summary["maximum"],
            "count": paired_summary["count"],
        },
    }


def public_identities(document):
    """Retain source hashes through portable names without private absolute paths.

    Parameters
    ----------
    document : dict
        The accepted timing record.

    Returns
    -------
    dict
        Repository-relative source or reference artifact names and hashes.

    Notes
    -----
    Original timing names remain unchanged. A separate map records current source paths.
    """
    if "source" in document:
        item = document["source"]
        path = item["path"].split("/esm.md/", 1)[-1]
        return {path: item["sha256"]}
    output = {}
    for path, value in document["fingerprint"].items():
        if "/esm.md/" in path:
            name = path.split("/esm.md/", 1)[1]
        elif "/esm.md-gpu/" in path:
            name = "historical_gpu_controls/" + path.split("/esm.md-gpu/", 1)[1]
        else:
            name = Path(path).name
        output[name] = value
    return output


def main():
    """Write portable plotting data and source identities without private process metadata.

    Notes
    -----
    Selected record paths are repository relative where possible. External paths use
    only their filename, while the recorded hash identifies the imported contents.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    for key, default in DEFAULT_SOURCES.items():
        parser.add_argument(
            "--" + key.replace("_", "-"), type=Path, default=REPOSITORY / default
        )
    args = parser.parse_args()
    result = {
        "schema": "esm-poster-matched-rates-1",
        "implementation": "esm.md – Fortran",
        "metric": "million complete cell updates per second",
        "ratio": "Fortran rate divided by assembly rate",
        "aggregation": "Ratio of median rates from twelve matched pairs",
        "uncertainty": "Observed minimum and maximum paired ratio. This is not a confidence interval.",
        "current_source_path_aliases": CURRENT_SOURCE_PATH_ALIASES,
        "repetitions": 12,
        "all_output_bytes_identical": True,
        "models": {},
        "sources": {},
    }
    for platform in ("cpu", "gpu"):
        result["models"][platform] = {}
        for model in ("sw", "ebm"):
            key = platform + "_" + model
            source = getattr(args, key)
            try:
                source_record = source.resolve().relative_to(REPOSITORY).as_posix()
            except ValueError:
                source_record = source.name
            payload = source.read_bytes()
            document = json.loads(payload)
            rows = collect_cpu(document) if platform == "cpu" else collect_gpu(document)
            result["models"][platform][model] = rows
            metadata = document["metadata"]
            result["sources"][key] = {
                "source_record": source_record,
                "sha256": hashlib.sha256(payload).hexdigest(),
                "target": (
                    "one Neoverse V2 CPU core"
                    if platform == "cpu"
                    else "one NVIDIA GH200 GPU"
                ),
                "job": metadata.get("job"),
                "node": metadata.get("node"),
                "timer": document.get(
                    "timer", document.get("protocol", {}).get("timer")
                ),
                "input_and_code_identities": public_identities(document),
            }
    result["ratios"] = {
        platform: {
            model: {str(row["size"]): row["ratio"] for row in rows}
            for model, rows in models.items()
        }
        for platform, models in result["models"].items()
    }
    result["summary"] = {}
    result["displayed_series"] = "esm.md"
    for platform, models in result["models"].items():
        candidates = [
            (row["fortran"]["median"], model, row["size"])
            for model, rows in models.items()
            for row in rows
        ]
        rate, model, size = max(candidates)
        model_name = "EBM" if model == "ebm" else "SW"
        amount = f"{rate / 1000:.1f} billion" if rate >= 1000 else f"{rate:.0f} million"
        hardware = "one CPU core" if platform == "cpu" else "one GPU"
        result["summary"][
            platform
        ] = f"{model_name} reaches {amount} updates/s on {hardware}."
    output = POSTER / "data/results-current.json"
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
    print(output)
    for key, value in result["summary"].items():
        print(key, value)


if __name__ == "__main__":
    main()

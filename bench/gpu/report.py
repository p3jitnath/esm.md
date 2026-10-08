"""Condense accepted GPU measurements without changing their numerical meaning."""

import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess

import runtime

NAMES = ("assembly", "gpu_fortran", "gpu_fortran_vanilla", "julia", "julia_vanilla", "gpu_python", "gpu_python_vanilla")


def summary(rows, cells, steps):
    """Summarise matched complete-step times and observed throughput ranges."""
    seconds = [r["milliseconds"] / 1000 for r in rows]
    median = statistics.median(seconds)
    updates = cells * steps / 1e6
    return {"million_cell_steps_per_second": updates / median,
            "min_million_cell_steps_per_second": updates / max(seconds),
            "max_million_cell_steps_per_second": updates / min(seconds),
            "median_seconds": median, "min_seconds": min(seconds), "max_seconds": max(seconds),
            "median_microseconds_per_step": median * 1e6 / steps,
            "relative_std_percent": statistics.stdev(seconds) / median * 100,
            "relative_mad_percent": statistics.median(abs(t - median) for t in seconds) / median * 100,
            "samples": [{k: r[k] for k in ("repeat", "milliseconds", "block", "launch_layout", "graph_nodes",
                                          "capture_ns", "compile_warm_ns", "allocation_ns", "upload_ns",
                                          "download_ns", "host_wait_ns")} for r in rows]}


def telemetry(rows):
    """Keep the ranges of actual quiet-node and GPU observations."""
    observations = [r[phase] for r in rows for phase in ("before", "after")]
    gpu = {}
    for field in ("clocks.sm", "clocks.mem", "temperature.gpu", "power.draw", "memory.used"):
        values = [float(o["gpu"][field]) for o in observations]
        gpu[field] = {"minimum": min(values), "maximum": max(values)}
    gpu["throttle_reasons"] = sorted({o["gpu"]["throttle_reasons"] for o in observations})
    return {"gpu": gpu, "max_one_minute_cpu_load": max(o["load"][0] for o in observations),
            "window_utc_ns": {"first": min(o["utc_ns"] for o in observations),
                              "last": max(o["utc_ns"] for o in observations)},
            "max_foreign_busy_cores_before_warmup": max(r["before"]["foreign_busy_cores"] for r in rows),
            "max_idle_gpu_utilisation_before_warmup": max(int(r["before"]["gpu"]["utilization.gpu"]) for r in rows),
            "observations": len(observations)}


def roofline(rows, calibration, model):
    """Give empirical execution guides with declared operation and traffic counts."""
    rates = {r["probe"]: r for r in calibration["records"]}
    result = []
    for size in sorted({r["size"] for r in rows}):
        selected = [r for r in rows if r["size"] == size and r["name"] == "assembly"]
        steps = selected[0]["steps"]
        cells = size**2 if model == "sw" else size
        achieved = cells * steps / statistics.median(r["milliseconds"] / 1000 for r in selected)
        if model == "sw":
            ordinary, divisions, roots = (203, 16, 2) if cells <= 4096 else (199, 4, 2)
            traffic = 328
            launches = (4 + 1 / steps) / cells
            working = 14 * (size + 2)**2 * 8 + 32 + 5 * 256
            ordinary_rate = rates["ordinary"]["median_rate_per_second"]
            division_rate = rates["divide"]["median_rate_per_second"]
        else:
            roots = 0
            if size <= 128:
                ordinary, divisions, traffic = 27 - 8 / size, 1 / steps, 0
                launches = 1 / (steps * cells)
            else:
                if steps % 4:
                    raise AssertionError("The declared primary temporal guide needs full four-step batches.")
                blocks = (size + 111) // 112
                ordinary_total, loaded = 0, 0
                for block in range(blocks):
                    for thread in range(128):
                        band = 112 * block + thread - 7
                        if not 1 <= band <= size:
                            continue
                        loaded += 1
                        pole_work = 2 * (band == 1) + 2 * (band == size)
                        for step in range(4):
                            if 2 * step + 1 <= thread <= 126 - 2 * step:
                                ordinary_total += 12 - pole_work
                            if 2 * step + 2 <= thread <= 125 - 2 * step:
                                ordinary_total += 15 - pole_work
                ordinary = ordinary_total / (size * 4)
                divisions = blocks * 128 / (size * 4)
                traffic = 32 * loaded / (size * 4) + 14
                launches = 0.5 / cells
            working = 7 * (size + 2) * 8 + 48 + 6 * 256
            ordinary_rate = rates["ordinary-one-sm" if size <= 128 else "ordinary"]["median_rate_per_second"]
            division_rate = rates["divide-one-sm" if size <= 128 else "divide"]["median_rate_per_second"]
        guides = {"ordinary_arithmetic": ordinary_rate / ordinary,
                  "rounded_division": division_rate / divisions,
                  "launch": rates["launch"]["median_rate_per_second"] / launches}
        if roots:
            guides["rounded_square_root"] = rates["sqrt"]["median_rate_per_second"] / roots
        if traffic:
            memory = "copy-cache" if working <= calibration["hardware"]["l2_cache_bytes"] else "copy-hbm"
            guides["logical_memory"] = rates[memory]["median_rate_per_second"] / traffic
        limiting = min(guides, key=guides.get)
        guide = guides[limiting]
        result.append({"size": size, "ordinary_ops_per_update": ordinary, "divisions_per_update": divisions,
                       "square_roots_per_update": roots, "logical_bytes_per_update": traffic,
                       "allocated_model_bytes": working, "estimated_launches_per_update": launches,
                       "guide_updates_per_second": guide, "limiting_guide": limiting,
                       "achieved_fraction_of_guide": achieved / guide, "individual_guides": guides,
                       "assumptions": "Independent operation-class rates, optimistic neighbour reuse, logical rather than measured memory transactions, and no claim of a hard upper bound"})
    return result


def main():
    """Write compact raw samples, summaries, paired gains and provenance."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=Path, default=runtime.ROOT / "bench/.runs/gpu")
    parser.add_argument("--output", type=Path, default=runtime.ROOT / "bench/gpu/results.json")
    args = parser.parse_args()
    frozen = runtime.fingerprint()
    calibration = json.loads((args.runs / "calibration.json").read_text())
    models = {}
    for model in ("sw", "eb"):
        path = args.runs / "final" / model / "timing.json"
        report = json.loads(path.read_text())
        if not report["passed"] or report["fingerprint"] != frozen or report["repeats"] != 12:
            raise RuntimeError("Final timings require the frozen sources and twelve accepted repetitions.")
        rows = report["records"]
        workloads = []
        for size in sorted({r["size"] for r in rows}):
            selected = [r for r in rows if r["size"] == size]
            steps = {r["steps"] for r in selected}
            if len(steps) != 1:
                raise AssertionError("Step counts differ between implementations.")
            steps = steps.pop()
            cells = size**2 if model == "sw" else size
            summaries = {}
            for name in NAMES:
                samples = sorted((r for r in selected if r["name"] == name), key=lambda r: r["repeat"])
                if [r["repeat"] for r in samples] != list(range(12)) or any(r["differing_bytes"] for r in samples):
                    raise AssertionError("A final implementation lacks twelve exact accepted samples.")
                summaries[name] = summary(samples, cells, steps)
            gains = {}
            for tuned, vanilla in (("gpu_fortran", "gpu_fortran_vanilla"), ("julia", "julia_vanilla"), ("gpu_python", "gpu_python_vanilla")):
                gain = summaries[vanilla]["median_seconds"] / summaries[tuned]["median_seconds"]
                if gain <= 1:
                    raise AssertionError("A tuned language control did not improve on vanilla.")
                paired = [v["milliseconds"] / t["milliseconds"] for t, v in zip(summaries[tuned]["samples"], summaries[vanilla]["samples"])]
                gains[tuned] = {"ratio_of_medians": gain, "paired_minimum": min(paired),
                                "paired_median": statistics.median(paired), "paired_maximum": max(paired)}
            folder = args.runs / "final" / model / (model + "-%d-%d" % (size, steps))
            references = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in folder.glob("reference-p*.bin")}
            workloads.append({"size": size, "cells": cells, "steps": steps, "summary": summaries,
                              "tuned_gain_vs_vanilla": gains, "canonical_reference_hashes": references,
                              "telemetry": telemetry(selected)})
        verification = {}
        for group in ("native", "julia", "julia_vanilla"):
            evidence = json.loads((args.runs / model / ("verification-" + group + ".json")).read_text())
            graphs = json.loads((args.runs / model / ("graphs-" + group + ".json")).read_text())
            audit = json.loads((args.runs / "audit" / (model + "-" + group + ".json")).read_text())
            if any(not r["passed"] or r["fingerprint"] != frozen for r in (evidence, graphs, audit)):
                raise AssertionError("Current scientific, replay and instruction evidence is required.")
            verification[group] = {"passed": True, "cases": evidence["cases"], "graph_cases": graphs["records"],
                                   "instruction_audit": audit["records"]}
        paired = json.loads((args.runs / "aggressive" / (model + "-paired.json")).read_text())
        if not paired["passed"] or paired["fingerprint"] != frozen:
            raise AssertionError("The paired first-pass comparison must use the current frozen binaries.")
        tuning = []
        for size in sorted({r["size"] for r in paired["records"]}):
            current = sorted((r for r in paired["records"] if r["size"] == size and r["name"] == "assembly"), key=lambda r:r["repeat"])
            baseline = sorted((r for r in paired["records"] if r["size"] == size and r["name"] == "gpu_pass1"), key=lambda r:r["repeat"])
            if any([r["repeat"] for r in selected] != list(range(12)) or any(r["differing_bytes"] for r in selected) for selected in (current,baseline)):
                raise AssertionError("Assembly tuning requires twelve paired samples.")
            ratios = [a["milliseconds"] / b["milliseconds"] for a,b in zip(baseline,current)]
            tuning.append({"size": size, "median_paired_gain": statistics.median(ratios),
                           "minimum_paired_gain": min(ratios), "maximum_paired_gain": max(ratios),
                           "pass1_million_cell_steps_per_second": (size**2 if model == "sw" else size) * baseline[0]["steps"] / (statistics.median(r["milliseconds"] for r in baseline) * 1000),
                           "aggressive_million_cell_steps_per_second": (size**2 if model == "sw" else size) * current[0]["steps"] / (statistics.median(r["milliseconds"] for r in current) * 1000),
                           "samples": [{"repeat": a["repeat"], "pass1_milliseconds": a["milliseconds"],
                                        "aggressive_milliseconds": b["milliseconds"]} for a,b in zip(baseline,current)]})
        lead_path = args.runs / "lead" / (model + "-paired.json")
        lead = json.loads(lead_path.read_text())
        if not lead["passed"] or lead["fingerprint"] != frozen:
            raise AssertionError("The further paired comparison needs the current frozen source and binary set.")
        lead_tuning = []
        before_name = "gpu_before_b64" if model == "sw" else "gpu_before"
        for size in sorted({r["size"] for r in lead["records"]}):
            current = sorted((r for r in lead["records"] if r["size"] == size and r["name"] == "assembly"), key=lambda r:r["repeat"])
            before = sorted((r for r in lead["records"] if r["size"] == size and r["name"] == before_name), key=lambda r:r["repeat"])
            if any([r["repeat"] for r in selected] != list(range(12)) or any(r["differing_bytes"] for r in selected) for selected in (current,before)):
                raise AssertionError("The further pass requires twelve exact paired samples.")
            ratios = [a["milliseconds"] / b["milliseconds"] for a,b in zip(before,current)]
            lead_tuning.append({"size": size, "baseline_commit": "8c302c8", "median_paired_gain": statistics.median(ratios),
                                "minimum_paired_gain": min(ratios), "maximum_paired_gain": max(ratios),
                                "samples": [{"repeat": a["repeat"], "before_milliseconds": a["milliseconds"],
                                             "final_milliseconds": b["milliseconds"]} for a,b in zip(before,current)]})
        models[model] = {"results": workloads, "verification": verification, "assembly_optimisation": tuning,
                         "further_assembly_optimisation": lead_tuning,
                         "roofline_guides": roofline(rows, calibration, model), "metadata": report["metadata"],
                         "process_groups": report["chunks"], "raw_evidence": str(path.relative_to(runtime.ROOT)),
                         "raw_evidence_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                         "paired_evidence_sha256": hashlib.sha256((args.runs / "aggressive" / (model + "-paired.json")).read_bytes()).hexdigest(),
                         "further_paired_evidence_sha256": hashlib.sha256(lead_path.read_bytes()).hexdigest()}
    if not calibration["passed"] or calibration["fingerprint"] != frozen:
        raise AssertionError("Calibration must use the same frozen source and binary set.")
    division = json.loads((args.runs / "division-check.json").read_text())
    if not division["passed"] or division["fingerprint"] != frozen or len(division["records"]) != 3:
        raise AssertionError("All three current cubins need the independent exact-division edge check.")
    software = {}
    for name, command in (("ptxas", ["ptxas", "--version"]), ("nvfortran", ["nvfortran", "--version"]),
                          ("gpu_host_compiler", ["g++", "--version"]), ("cpu_reference_compiler", ["gfortran", "--version"]),
                          ("python", [str(runtime.ROOT / ".runtime/python/bin/python"), "--version"]),
                          ("julia", [str(runtime.ROOT / ".runtime/julia-1.12.7/bin/julia"), "--version"])):
        software[name] = subprocess.check_output(command, stderr=subprocess.STDOUT, text=True).strip()
    data = {"passed": True, "repeats": 12, "unit": "Million complete cell updates per second",
            "upstream": "6536b88572b8c3970361849342d7355a3440900f", "first_pass_commit": "2ef5dc5",
            "models": models, "fingerprint": frozen, "software": software,
            "requirements": (runtime.ROOT / "bench/gpu/requirements.txt").read_text(),
            "calibration": calibration, "exact_division_check": division,
            "timer": "CUDA events around one graph replay of complete steps",
            "excluded_costs": "Startup, compilation, allocation, transfers, graph construction and validation are recorded separately"}
    data["python_packages"] = subprocess.check_output([str(runtime.ROOT / ".runtime/python/bin/python"), "-m", "pip", "freeze"], text=True).splitlines()
    data["analysis_source_sha256"] = {str(p.relative_to(runtime.ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                                     for p in (runtime.ROOT / "bench/gpu/report.py", runtime.ROOT / "bench/gpu/plot.py")}
    data["generation_route"] = "Direct PTX authored from the frozen model contracts and assembled with ptxas, with numerical stages executed on the GPU"
    data["generation_model"] = "Codex interactive session, exact model variant not recorded"
    data["implementation_source_commit"] = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=runtime.ROOT, text=True).strip()
    args.output.write_text(json.dumps(data, indent=2) + "\n")
    for model, values in models.items():
        for r in values["results"]:
            print(model, r["size"], {name:round(r["summary"][name]["million_cell_steps_per_second"],2) for name in NAMES})


if __name__ == "__main__":
    main()

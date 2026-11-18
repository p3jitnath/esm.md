"""Build unchanged historical Fortran controls with strict target options."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
from datetime import datetime, timezone

ROOT = Path.cwd()
HERE = ROOT / ".runtime/goal_20261112/fresh_languages/cpu/fortran"
ORIGINAL = ROOT / ".runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826"
FC = "/opt/cray/pe/gcc-native/14/bin/gfortran"
FLAGS = [
    "-O3", "-mcpu=neoverse-v2", "-msve-vector-bits=128", "-fPIC",
    "-fno-fast-math", "-fno-unsafe-math-optimizations", "-ffp-contract=off",
    "-fprotect-parens", "-frounding-math", "-fsignaling-nans",
    "-ffree-line-length-none",
]

def digest(path):
    """Return the SHA256 identity of one small source or library file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()

records = []
for model, old_model in (("sw", "shallow_water"), ("ebm", "budyko_sellers")):
    for route, old_name in (("fortran_vanilla", "vanilla.f90"), ("fortran_tuned", "solver.f90")):
        target = HERE / model / route
        target.mkdir(parents=True, exist_ok=True)
        original = ORIGINAL / "src" / old_model / old_name
        source = target / "kernel.f90"
        shutil.copyfile(original, source)
        assert source.read_bytes() == original.read_bytes()
        library = target / ("lib" + model + "_" + route + ".so")
        extra = [] if route.endswith("vanilla") else [
            "--param=max-unswitch-insns=600", "-fopenmp-simd"
        ]
        if model == "ebm" and route.endswith("tuned"):
            extra += ["-funroll-loops", "-finline-limit=1000"]
        command = [FC] + FLAGS + extra + [
            "-J" + str(target), "-shared",
            "-fopt-info-vec-all=" + str(target / "vectorisation.txt"),
            str(source), "-o", str(library)
        ]
        result = subprocess.run(command, text=True, capture_output=True)
        (target / "compile.log").write_text(result.stdout + result.stderr)
        if result.returncode:
            raise RuntimeError((command, result.returncode, result.stderr))
        disassembly = subprocess.run(
            ["/usr/bin/objdump", "-d", str(library)], check=True,
            text=True, capture_output=True
        ).stdout
        (target / "disassembly.txt").write_text(disassembly)
        fused = [line for line in disassembly.splitlines()
                 if any(op in line.split("\t")[-1].split(" ")[0]
                        for op in ("fmla", "fmls", "fmadd", "fmsub", "fnmadd", "fnmsub"))]
        if fused:
            raise RuntimeError(("Forbidden contracted FP instruction", fused[:5]))
        records.append({
            "model": model, "route_id": route,
            "source": str(source), "source_sha256": digest(source),
            "original": str(original), "original_sha256": digest(original),
            "source_unchanged": True, "library": str(library),
            "library_sha256": digest(library),
            "entry": "sw_run" if model == "sw" else "eb_run",
            "step_entry": "sw_step" if model == "sw" else "eb_step",
            "command": command, "forbidden_fused_instructions": 0,
            "tuning_scope": "Historical distinct source and qualified source/build choices; no fresh performance claim.",
        })
report = {
    "schema_version": 1, "status": "BUILT_NOT_YET_QUALIFIED",
    "utc": datetime.now(timezone.utc).isoformat(),
    "job": os.environ.get("SLURM_JOB_ID"), "node": os.uname().nodename,
    "compiler": subprocess.run([FC, "--version"], check=True, text=True, capture_output=True).stdout.splitlines()[0],
    "shared_node_performance_measurement": False,
    "records": records,
}
(HERE / "build.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps({"status": report["status"], "routes": len(records), "manifest": str(HERE / "build.json")}))

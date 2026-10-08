"""Rotate native and sequential Julia timing groups on one allocated GPU."""

import argparse
import json
from pathlib import Path
import subprocess
import sys

import runtime

NATIVE = ["assembly", "gpu_fortran_vanilla", "gpu_fortran", "gpu_python_vanilla", "gpu_python"]
GROUPS = ["native", "julia_vanilla", "julia"]


def main():
    """Collect twelve matched repetitions without overlapping GPU processes."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", choices=("eb", "sw"), required=True)
    parser.add_argument("--repeats", type=int, default=12)
    parser.add_argument("--block", type=int, default=None)
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()
    folder = args.output or runtime.ROOT / "bench/.runs/gpu/final" / args.model
    folder.mkdir(parents=True, exist_ok=True)
    # NVIDIA management queries do not retain a CUDA compute context.
    metadata = runtime.allocation(initialize=False)
    records, chunks = [], []
    frozen = runtime.fingerprint()
    for repeat in range(args.repeats):
        order = GROUPS[repeat % 3:] + GROUPS[:repeat % 3]
        if repeat // 3 % 2:
            order = order[::-1]
        for group in order:
            output = folder / ("%02d-%s.json" % (repeat, group))
            log = folder / ("%02d-%s.log" % (repeat, group))
            command = [sys.executable, str(runtime.ROOT / "bench/gpu/run.py"), "--model", args.model,
                       "--mode", "benchmark", "--names", ",".join(NATIVE) if group == "native" else group,
                       "--repeats", "1", "--repeat-start", str(repeat),
                       "--output", str(output)]
            if args.block is not None:
                command += ["--block", str(args.block)]
            with log.open("w") as stream:
                result = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT)
            if result.returncode:
                raise RuntimeError("Timing group failed. See " + str(log))
            report = json.loads(output.read_text())
            if not report["passed"] or report["fingerprint"] != frozen:
                raise RuntimeError("A source or binary changed during the final comparison.")
            for key in ("job", "node", "affinity", "uuid", "step"):
                if report["metadata"][key] != metadata[key]:
                    raise RuntimeError("The final comparison changed placement.")
            chunks.append({"repeat": repeat, "group": group, "order": order,
                           "path": str(output.relative_to(runtime.ROOT)),
                           "julia": report.get("julia")})
            for record in report["records"]:
                record["process_group_order"] = order
                record["process_group"] = group
                records.append(record)
            print(json.dumps({"model": args.model, "repeat": repeat, "group": group,
                              "accepted_samples": len(records)}), flush=True)
    report = {"passed": True, "model": args.model, "metadata": metadata,
              "implementations": NATIVE + GROUPS[1:], "records": records, "chunks": chunks,
              "fingerprint": frozen, "repeats": args.repeats,
              "timer": "Same-stream CUDA events around complete GPU updates in a CUDA graph",
              "placement": "Shared native arrays within each repetition and separate sequential Julia workers on the same GPU",
              "order": "Rotated process groups with alternating direction and rotated native implementations"}
    (folder / "timing.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()

"""Archive actual PTX and machine instructions for all seven GPU implementations."""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess

import runtime

spec = importlib.util.spec_from_file_location("gpu_evaluator", runtime.ROOT / "bench/gpu/run.py")
evaluator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(evaluator)
import benchmark


def archive(path, text):
    """Write inspected compiler output and identify the exact archived bytes."""
    if not text.strip() or (path.suffix == ".sass" and not re.search(r"\bEXIT\b", text)):
        raise RuntimeError("The instruction tool did not produce a complete machine-code dump.")
    path.write_text(text)
    return {"path": str(path.relative_to(runtime.ROOT)),
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(), "bytes": path.stat().st_size,
            "sass_dfma_instructions": len(re.findall(r"\bDFMA\b", text)),
            "sass_dadd_instructions": len(re.findall(r"\bDADD\b", text)),
            "sass_dmul_instructions": len(re.findall(r"\bDMUL\b", text))}


def main():
    """Inspect native cubins or one separate sequential Julia worker."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", choices=("sw", "eb"), required=True)
    parser.add_argument("--group", choices=("native", "julia", "julia_vanilla"), default="native")
    parser.add_argument("--output", type=Path, default=runtime.ROOT / "bench/.runs/gpu/audit")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    metadata = runtime.allocation(initialize=args.group == "native")
    records = []
    if args.group == "native":
        for name in ("assembly", "fortran", "fortran_vanilla"):
            cubin = runtime.BUILD / (args.model + "_" + name + ".cubin")
            text = subprocess.check_output(["cuobjdump", "--dump-resource-usage", "--dump-sass", str(cubin)], text=True)
            records.append({"name": name, **archive(args.output / (args.model + "-" + name + ".sass"), text),
                            "cubin_sha256": hashlib.sha256(cubin.read_bytes()).hexdigest()})
            if name.startswith("fortran"):
                source = "vanilla" if name.endswith("_vanilla") else "solver"
                ptx = runtime.BUILD / (args.model + "_" + name) / (source + ".n001.ptx")
                records[-1]["ptx"] = archive(args.output / (args.model + "-" + name + ".ptx"), ptx.read_text())
        for name in ("gpu_python", "gpu_python_vanilla"):
            backend = runtime.Backend(name, args.model)
            try:
                for size in (1, 129):
                    host = benchmark.inputs(evaluator.protocol, evaluator.eb, args.model, size)
                    backend.run(host, 1)
                for symbol, kernel in vars(backend.module).items():
                    if not hasattr(kernel, "inspect_asm") or not kernel.signatures or kernel.targetoptions.get("device"):
                        continue
                    prefix = args.output / (args.model + "-" + name + "-" + symbol)
                    ptx = "\n".join(str(value) for value in kernel.inspect_asm().values())
                    sass = "\n".join(str(value) for value in kernel.inspect_sass().values())
                    records.append({"name": name, "kernel": symbol,
                                    "ptx": archive(prefix.with_suffix(".ptx"), ptx),
                                    "sass": archive(prefix.with_suffix(".sass"), sass),
                                    "registers": [int(v) for v in kernel.get_regs_per_thread().values()],
                                    "fastmath": kernel.targetoptions.get("fastmath", False)})
            finally:
                backend.close()
    else:
        worker = evaluator.Julia(args.group, args.model)
        try:
            for size in (1, 129):
                host = benchmark.inputs(evaluator.protocol, evaluator.eb, args.model, size)
                prefix = args.output / (args.model + "-" + args.group + "-" + str(size))
                input_path = prefix.with_suffix(".bin")
                if args.model == "eb":
                    evaluator.eb.write(input_path, host.q, host.coeff, host.par)
                else:
                    evaluator.protocol._write(input_path, host.q, host.parameters)
                worker.process.stdin.write("AUDIT\t%s\t%s\t%d\n" % (input_path, prefix, worker.block))
                worker.process.stdin.flush()
                if worker.process.stdout.readline().strip() != "AUDITED":
                    raise RuntimeError("Julia instruction inspection failed. See " + worker.log.name)
                records.append({"name": args.group, "size": size,
                                "ptx": archive(prefix.with_suffix(".ptx"), prefix.with_suffix(".ptx").read_text()),
                                "sass": archive(prefix.with_suffix(".sass"), prefix.with_suffix(".sass").read_text())})
        finally:
            worker.close()
    report = {"passed": True, "metadata": metadata, "model": args.model, "group": args.group,
              "records": records, "fingerprint": runtime.fingerprint(),
              "interpretation": "DFMA inside correctly rounded divide or square-root refinements is not a fused model operation"}
    (args.output / (args.model + "-" + args.group + ".json")).write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"model": args.model, "group": args.group, "inspected_kernels": len(records)}), flush=True)


if __name__ == "__main__":
    main()

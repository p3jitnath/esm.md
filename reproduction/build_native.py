"""Build study solvers and native controls in a clean checkout."""

import argparse
import os
from pathlib import Path
import platform
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
REPRODUCTION = ROOT / "reproduction"
MODELS = ("sw", "ebm")
FP_FLAGS = (
    "-fno-fast-math",
    "-fno-unsafe-math-optimizations",
    "-ffp-contract=off",
    "-fprotect-parens",
    "-frounding-math",
    "-fsignaling-nans",
)
CPU_TARGET = ("-mcpu=neoverse-v2", "-msve-vector-bits=128")
GPU_TARGET = "-gpu=cc90,nofma,noflushz,nordc,keep,ptxinfo,cuda12.6"


def tool(variable, default):
    """Resolve an installed tool from its override or PATH."""
    name = os.environ.get(variable, default)
    path = shutil.which(name)
    if path is None:
        raise SystemExit(f"Set {variable} to an installed {default} executable.")
    return str(Path(path).absolute())


def run(arguments, directory):
    """Run a compiler in its output directory."""
    directory.mkdir(parents=True, exist_ok=True)
    subprocess.run(arguments, cwd=directory, check=True)


def cpu_build(output, study):
    """Build portable CPU solvers or the measured native CPU routes."""
    compiler = tool("FC", "gfortran")
    flags = (*FP_FLAGS, *CPU_TARGET) if study else FP_FLAGS
    for model in MODELS:
        if study:
            source = REPRODUCTION / "cpu/measured" / model / "solver.f90"
        else:
            source = ROOT / "src" / model / "solver.f90"
        model_output = output / model
        run(
            [
                compiler,
                "-O3",
                "-fPIC",
                "-shared",
                "-fopenmp",
                *flags,
                str(source),
                "-o",
                "esm_md.so",
            ],
            model_output,
        )
        if not study:
            continue
        for style in ("tuned", "vanilla"):
            source = (
                REPRODUCTION / "cpu/fortran" / model / f"fortran_{style}" / "kernel.f90"
            )
            run(
                [
                    compiler,
                    "-O3",
                    "-fPIC",
                    "-shared",
                    "-ffree-line-length-none",
                    *flags,
                    str(source),
                    "-o",
                    f"fortran_{style}.so",
                ],
                model_output / f"fortran_{style}",
            )
    if study:
        cc = tool("CC", "gcc")
        assembly = REPRODUCTION / "cpu/baseline"
        for model, name, source in (
            ("sw", "assembly_compact", assembly / "sw/sw_compact.S"),
            ("sw", "assembly_masked", assembly / "sw/sw_solver.S"),
            ("ebm", "assembly", assembly / "ebm/solver.S"),
        ):
            run(
                [
                    cc,
                    "-O3",
                    "-mcpu=neoverse-v2",
                    "-shared",
                    "-fPIC",
                    str(source),
                    "-o",
                    name + ".so",
                ],
                output / model,
            )


def gpu_build(output):
    """Compile the measured CUDA Fortran sources and assemble the PTX baselines."""
    nvfortran = tool("NVFORTRAN", "nvfortran")
    ptxas = tool("PTXAS", "ptxas")
    gpu = REPRODUCTION / "gpu"
    for model in MODELS:
        for route in ("esm_md", "fortran_tuned", "fortran_vanilla"):
            from_study = route == "esm_md"
            source = (
                gpu / "accepted_sources" / model / "solver.cuf"
                if from_study
                else gpu
                / "fortran"
                / model
                / route.removeprefix("fortran_")
                / "solver.cuf"
            )
            directory = output / model / route
            run(
                [
                    nvfortran,
                    "-O3",
                    "-cuda",
                    "-Kieee",
                    GPU_TARGET,
                    "-c",
                    str(source),
                    "-o",
                    "solver.o",
                ],
                directory,
            )
            if model == "ebm" and from_study:
                run(
                    [
                        ptxas,
                        "-arch=sm_90",
                        "--fmad=false",
                        "--register-usage-level=0",
                        "solver.n001.ptx",
                        "-o",
                        "esm_md.cubin",
                    ],
                    directory,
                )
            else:
                (binary,) = directory.glob("solver.n*.cubin")
                shutil.copyfile(binary, directory / (route + ".cubin"))
        run(
            [
                ptxas,
                "-arch=sm_90",
                "--fmad=false",
                str(gpu / "accepted_sources" / model / "solver.ptx"),
                "-o",
                "assembly.cubin",
            ],
            output / model,
        )
    cuda = Path(os.environ.get("CUDA_HOME", str(Path(ptxas).resolve().parents[1])))
    cxx = tool("CXX", "g++")
    run(
        [
            cxx,
            "-O3",
            "-std=c++17",
            "-shared",
            "-fPIC",
            "-I" + str(cuda / "include"),
            str(gpu / "host/driver.cpp"),
            "-L" + str(cuda / "lib64/stubs"),
            "-lcuda",
            "-o",
            "libdriver.so",
        ],
        output,
    )


def main():
    """Select a build profile."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", choices=("cpu", "cpu-study", "gpu-study"))
    args = parser.parse_args()
    work = ROOT / ".scratch/native" / args.profile
    if args.profile == "gpu-study":
        gpu_build(work)
    else:
        study = args.profile == "cpu-study"
        if study and platform.machine().lower() not in ("aarch64", "arm64"):
            parser.error(
                "The CPU study profile needs AArch64 with Neoverse V2 support."
            )
        cpu_build(work, study)
    print(work)


if __name__ == "__main__":
    main()

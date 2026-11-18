# Reproduce the Study

Use the [project README](../README.md) for the portable CPU build and data check. The [source manifest](source_manifest.json) identifies the exact measured sources and drivers for Figures 4 and 5.

## Implementations and Targets

| Route | CPU source | GPU source |
| --- | --- | --- |
| ESM.md | [Fortran](cpu/measured/) | [CUDA Fortran](gpu/accepted_sources/) |
| Assembly or PTX | [Handwritten AArch64 assembly](cpu/baseline/) | [Direct PTX](gpu/accepted_sources/) |
| Fortran controls | [Tuned and vanilla](cpu/fortran/) | [Tuned and vanilla](gpu/fortran/) |
| Julia controls | [Tuned and vanilla](cpu/julia/) | [Tuned and vanilla](gpu/julia/) |
| Compiled Python controls | [Tuned and vanilla](cpu/python/) | [Tuned and vanilla](gpu/python/) |

The measured CPU build uses GNU Fortran and GCC 14.3 on Neoverse V2 with 128-bit SVE for Fortran. It uses compact SW assembly on 64² and 256² grids and masked SW assembly on the 1,024² grid. All CPU routes share the ESM.md domain coordinator.

## Native Study Builds

```bash
python reproduction/build_native.py cpu-study
python reproduction/build_native.py gpu-study
```

Set `FC` and `CC` to select the GNU compilers. The GPU build uses NVIDIA Fortran from HPC SDK 24.11, CUDA 12.6 and compute capability 9.0. Set `NVFORTRAN`, `PTXAS`, `CUDA_HOME` and `CXX` if needed. Outputs go to `.scratch/native/`. The measured Julia and Python controls used Julia 1.12.7, CUDA.jl 6.4.2, Python 3.11.7 and Numba 0.68.0.

## Frozen Workloads

The [input manifest](inputs/manifest.json) lists six model and grid pairs with their shapes, types and hashes. The input files are compressed NumPy archives, and the reference arrays use gzip. Read each reference with `numpy.load` on a file opened in binary mode with `gzip.open`.

The 1,000-step runs use the smooth mixed SW state and the EBM climate state. The CPU runs use 248 workers, except for the 128-band EBM, which uses 128. GPU runs use one GH200. The recorded [CPU](cpu/) and [GPU](gpu/) drivers retain the original cluster paths. Configure those paths for new runs, reproduce the workload and timer boundaries, and verify physical behaviour and exact outputs before timing on a quiet, exclusive node.

The [data checker](verify_data.py) verifies the frozen arrays and recomputes the language and scaling rates in billions of updates per second. The [poster guide](../paper/pasc27/poster/README.md) links the figure scripts and separate physics examples.

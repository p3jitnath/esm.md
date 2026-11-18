# Reproducing the study artifacts

Start with the [project README](../README.md) for the model formulations and portable CPU build. The [source manifest](source_manifest.json) associates the retained implementation and driver files with the frozen CPU and GPU records for Figures 4 and 5. The active solvers under src/ have their current documentation. The copies under reproduction/ preserve the exact measured source bytes.

## Implementations and targets

| Route | CPU source | GPU source |
| --- | --- | --- |
| ESM.md | [Measured Fortran](cpu/measured/) | [Measured CUDA Fortran](gpu/accepted_sources/) |
| Assembly or PTX baseline | [Handwritten AArch64 assembly](cpu/baseline/) | [Direct PTX](gpu/accepted_sources/) |
| Fortran controls | [Tuned and vanilla](cpu/fortran/) | [Tuned and vanilla](gpu/fortran/) |
| Julia controls | [Tuned and vanilla](cpu/julia/) | [Tuned and vanilla](gpu/julia/) |
| Compiled Python controls | [Tuned and vanilla](cpu/python/) | [Tuned and vanilla](gpu/python/) |

The AArch64 study uses the compact SW assembly on the 64² and 256² grids and the masked SW assembly on the 1,024² grid. The matching ESM.md Fortran library supplies the single-domain CPU coordinator for all implementations. The native CPU build uses GNU Fortran and GCC 14.3 with Neoverse V2 and 128-bit SVE for Fortran. The portable CPU build omits those processor options.

```bash
python reproduction/build_native.py cpu-study
python reproduction/build_native.py gpu-study
```

Set FC and CC if the GNU compilers are outside PATH. The GPU profile uses NVIDIA Fortran from HPC SDK 24.11 and ptxas from CUDA 12.6 for compute capability 9.0. Set NVFORTRAN, PTXAS and, where needed, CUDA_HOME for a local toolkit. CXX selects the compiler for the common CUDA driver library. The build writes its shared libraries, generated PTX and cubins to .scratch/native/. It builds the Fortran and direct PTX routes and host driver. Julia and Python use their own runtime compilers, with Julia 1.12.7, CUDA.jl 6.4.2, Python 3.11.7 and Numba 0.68.0 in the measured campaign.

The [CPU](cpu/) and [GPU](gpu/) experiment drivers are frozen provenance for the original scheduling, verification and timing. Their launch configuration and cluster paths belong to the original campaign. For a fresh measurement, configure paths and binary locations for the new node and use the same workload, arithmetic and timer boundaries. Verify numerical outputs and physical checks before timing, then use an exclusive, quiet allocation. The paper used 248 CPU workers except for the 128-band EBM, which used 128 workers. GPU runs used one GH200. The CPU scaling study was a separate campaign.

## Saved inputs and canonical outputs

[The bank manifest](inputs/manifest.json) gives the six model and grid combinations with the original archive identities, array shapes, types and SHA-256 values. The compressed NPZ inputs preserve each array's exact bytes. The state and stage references are gzip-compressed NumPy arrays. Read them with NumPy's load function on a file opened with gzip.open in binary read mode. The canonical q, stage and out arrays follow the storage and publication rules in the model specifications.

The 1,000-step workload uses the smooth mixed SW state and the EBM climate state. The dam-break and the evolved temperature illustrations have separate saved data in the [poster project](../paper/pasc27/poster/data/). The [data check](verify_data.py) verifies both input and reference arrays and recomputes the language-comparison and scaling rate points and observed endpoints from the published elapsed times. Its CSV reports all rates in billions of complete cell updates per second.

The [plotting entry points](../paper/pasc27/poster/README.md) rebuild the scientific figures and poster from the accepted input. The paper's Helvetica Neue setup uses a locally supplied font. The saved paper figures can be used directly and the poster bundles its Open Sans fonts.

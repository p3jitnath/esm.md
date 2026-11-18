# ESM.md PASC27 study

This branch accompanies *ESM.md: From Markdown Physics to Verified, Optimised Earth System Model Solvers* by Pritthijit Nath, Sebastian Schemm and Mark J. Webb. It contains the source and data for the periodic shallow-water and zonal-mean energy-balance experiments on CPUs and GPUs.

| Model | Physics and numerical method | CPU and GPU code |
| --- | --- | --- |
| Shallow water (SW) | [Formulation](formulations/sw/shallow_water.md) and [solver specification](formulations/sw/shallow_water_specification.md) | [Fortran](src/sw/solver.f90) and [CUDA Fortran](src/sw/gpu/solver.cuf) |
| Energy balance (EBM) | [Formulation](formulations/ebm/budyko_sellers.md) and [solver specification](formulations/ebm/budyko_sellers_specification.md) | [Fortran](src/ebm/solver.f90) and [CUDA Fortran](src/ebm/gpu/solver.cuf) |

The [shared specifications](formulations/general/) describe how the CPU workers and GPU kernels advance a grid. The [md2fort](skills/md2fort/SKILL.md) and [md2fort-gpu](skills/md2fort-gpu/SKILL.md) skills describe the generation and verification workflow.

## Check the data and build the solvers

Run from the repository root with Python 3.11 or later, NumPy and GNU Fortran. The first command verifies the frozen source and array hashes and writes the rates as a CSV file. The second compiles the two portable CPU solvers.

```bash
python -m pip install numpy==2.4.6
mkdir -p .scratch
python reproduction/verify_data.py > .scratch/rates.csv
python reproduction/build_native.py cpu
```

The [reproduction guide](reproduction/README.md) gives the native study builds, source map and measurement conditions. It explains how to use the six [frozen input and reference banks](reproduction/inputs/manifest.json) and identifies the assembly, PTX, tuned and vanilla controls.

## Results and poster

The [language comparison dataset](paper/pasc27/poster/data/fresh-language-comparison-input.json) contains 96 conditions and 1,152 elapsed times. The [separate CPU scaling dataset](paper/pasc27/poster/data/cpu-scaling-results-20261112.json) covers six grids and 11 CPU budgets, with 12 timing pairs per condition. For each condition, the rate is the number of complete interior cell updates divided by the median elapsed time. The plotted endpoints are the smallest and largest rates observed across the individual runs.

The [poster project](paper/pasc27/poster/) includes the [PDF](paper/pasc27/poster/esm-md-a0-landscape.pdf), [editable PowerPoint](paper/pasc27/poster/esm-md-a0-landscape.pptx) and plotting sources. Its data directory also retains the input and reference files for the separate physical illustrations.

The ESM.md software is available under the [MIT License](LICENSE). The poster marks, artwork and fonts retain their separate terms and credit. See the [language logo credits](paper/pasc27/poster/assets/language-logos/ATTRIBUTION.md) and [poster asset sources](paper/pasc27/poster/assets/asset-urls.json).

When reusing these artifacts, cite the study title and the commit of this branch that you used.

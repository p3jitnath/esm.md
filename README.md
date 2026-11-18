# ESM.md - PASC’27

This branch accompanies *ESM.md: From Markdown Physics to Verified, Optimised Earth System Model Solvers* by Pritthijit Nath, Sebastian Schemm and Mark J. Webb. It contains the code and data for the shallow-water and energy-balance experiments.

## Model Sources

| Model | Physics and method | Active solvers |
| --- | --- | --- |
| Shallow water (SW) | [Formulation](formulations/sw/shallow_water.md), [specification](formulations/sw/shallow_water_specification.md) | [Fortran](src/sw/solver.f90), [CUDA Fortran](src/sw/gpu/solver.cuf) |
| Energy balance (EBM) | [Formulation](formulations/ebm/budyko_sellers.md), [specification](formulations/ebm/budyko_sellers_specification.md) | [Fortran](src/ebm/solver.f90), [CUDA Fortran](src/ebm/gpu/solver.cuf) |

The [shared specifications](formulations/general/) describe parallel execution. The [md2fort](skills/md2fort/SKILL.md) and [md2fort-gpu](skills/md2fort-gpu/SKILL.md) skills guide generation and verification.

## Build and Check

From the repository root, use Python 3.11 or later with NumPy to check the saved inputs and recalculate the published rates. Use GNU Fortran to build both portable CPU solvers.

```bash
python -m pip install numpy==2.4.6
mkdir -p .scratch
python reproduction/verify_data.py > .scratch/rates.csv
python reproduction/build_native.py cpu
```

The [reproduction guide](reproduction/README.md) maps the study builds, frozen inputs and comparison sources.

## Results and Poster

The [language comparisons](paper/pasc27/poster/data/fresh-language-comparison-input.json) cover 96 conditions with 12 runs each. The [CPU scaling sweep](paper/pasc27/poster/data/cpu-scaling-results-20261112.json) covers six grids and 11 CPU budgets. Each point divides the number of complete interior cell updates by the median elapsed time, and each range spans the lowest and highest observed rates.

The [poster project](paper/pasc27/poster/) includes the [PDF](paper/pasc27/poster/esm-md-a0-landscape.pdf), [PowerPoint](paper/pasc27/poster/esm-md-a0-landscape.pptx) and plotting scripts. The software uses the [MIT licence](LICENSE). The [poster assets](paper/pasc27/poster/assets/asset-urls.json) and [logos](paper/pasc27/poster/assets/language-logos/ATTRIBUTION.md) retain their own terms and credits.

## How to Cite

Cite this code and data release with [CITATION.cff](CITATION.cff) or the BibTeX below.

```bibtex
@misc{nath2026esmmd,
  author = {Nath, Pritthijit and Schemm, Sebastian and Webb, Mark J.},
  title  = {{ESM.md} - {PASC’27}},
  year   = {2026},
  url    = {https://github.com/p3jitnath/esm.md/tree/83295ed7b522f8b6ca63c384d8ddcb2892fcb75f}
}
```

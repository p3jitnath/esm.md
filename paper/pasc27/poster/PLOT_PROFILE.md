# Publication Plot Profiles

Install [the plotting requirements](requirements_plotting.txt) and run the scripts from this directory. Poster plots use the bundled Open Sans fonts. Paper plots use Helvetica Neue from the local system or `--font-file`. Use a permitted local file for Helvetica Neue.

## Language Comparisons

The active [input](data/fresh-language-comparison-input.json) and [encoding audit](data/fresh-language-encoding-audit.json) cover eight routes, two models, two processors and three grids, with 12 runs of 1,000 steps per condition. Each point divides the complete interior cell-update count by the median time. The horizontal range spans the lowest and highest individual rates. CPU uses a 248-core budget, with 128 workers for the 128-band EBM, and GPU uses one NVIDIA GH200.

Both panels use logarithmic rate axes, with millions of updates per second on CPU and billions on GPU. Colour and shape identify grid sizes. Filled marks show tuned controls and hatched marks show vanilla controls. Each language uses one shared row label.

```bash
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model sw --profile poster --output figures/poster/language_water_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model ebm --profile poster --output figures/poster/language_energy_rates
```

For the paper, use `--profile paper`, save to `figures/paper/` and supply `--font-file "$PAPER_FONT_FILE"` if the font is unregistered. The [poster guide](README.md) describes export and evidence checks.

## Paired Rates and Scaling

`render_performance_bars.py` uses the [paired CPU and GPU data](data/accepted-main-input.json). `render_scaling_bars.py` uses the [separate CPU sweep](data/cpu-scaling-results-20261112.json), which covers eleven budgets across six grids. Both scripts use zero-based linear axes. CPU budget, actual worker team and workers with assigned cells are distinct quantities. In the scaling sweep the SW team follows the budget and EBM uses the smaller of the budget and the number of bands.

```bash
python scripts/render_scaling_bars.py --input data/cpu-scaling-results-20261112.json --model both --expected-steps 1000 --output figures/cpu_scaling
```

Use `--audit-only` on either script to check the supplied metadata and timing pairs without creating a plot. Physics and timing qualification are recorded separately from plotting. The [workload specification](data/main_workload_specification.json) describes the planned protocol, and earlier observations retain their own input records.

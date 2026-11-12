# Publication plot profile

This project reproduces eight-route language scatter figures, retained matched CPU and GPU rate figures, and CPU scaling figures for the paper and poster. The scripts find sibling code and assets from their own location. They do not require a project runtime folder or a skill cache. Supply accepted current data through `--input` and choose an output prefix through `--output`.

The paper default remains Helvetica Neue. This is a declared installed font dependency, resolved with standard Matplotlib font registration and fallback disabled. If the family is not registered, provide a permitted local file through `--font-file`. That file is registered at runtime and is never copied or redistributed by these scripts. The bundle contains no Helvetica binary.

Poster figures use the unchanged Open Sans regular and bold files from the existing poster assets, with their complete notice and provenance. No other font binary is included. An explicitly selected external family must resolve through standard Matplotlib registration or a caller-supplied runtime font file. The default profiles never silently switch families.

`requirements_plotting.txt` records the tested direct runtime packages. They provide Matplotlib drawing, NumPy arrays and PyMuPDF PDF inspection. The recorded environment uses Python 3.11. Installing these packages also installs their declared dependencies.

The helper provenance file records the pinned source identity, source hash, font-loading adaptation and packaged font hashes. Its palette, Matplotlib settings, audit functions and export implementation retain the pinned helper. The final script snapshot record identifies the draft sources and the portable path changes.

Production commands consume the published accepted files through `--input`. Historical diagnostic compatibility can accept a caller-supplied historical input, which keeps its visible diagnostic status. Only that explicit historical status bypasses the new CPU policy fields. Accepted current records cannot use the diagnostic bypass.

Each rate point is the useful interior-cell update count divided by the median of twelve recorded times. Thin lines retain the observed minimum and maximum of the twelve individual rates. All timing samples, processor budgets, supplied active-worker counts, source identities and acceptance metadata remain in the receipt JSON. The displayed rates are absolute. Matched and scaling bars use zero-based linear axes. The language scatter profile uses CPU and GPU rate axes labelled log, with positive margins around the observed ranges.

`data/main_workload_contract.json` records the frozen workload and measurement protocol only. It is not performance acceptance proof. Current input records need their own actual qualification flags and independent verification and timing evidence. Plotting checks the supplied records rather than carrying out those scientific checks. The ledger is not read by the plotting scripts.

## Fresh language scatter figures

`scripts/render_language_scatter.py` supplies the active language comparison for both publication profiles. Its accepted input is `data/fresh-language-comparison-input.json`, with the independent receipt in `data/fresh-language-encoding-audit.json`. The complete cohort contains 96 conditions across eight routes, two models, two processors and three grids, with 12 elapsed times per condition and 1,000 complete steps. Partial input and archived observations cannot enter the accepted poster binding. The normaliser and independent encoding audit establish raw-timing and statistical fidelity. The plotting and poster scripts check that the accepted cohort, resources, chart records and output hashes agree with those supplied records.

For each condition, the point is the useful cell-update count divided by the median elapsed time, then converted once to the displayed unit. The horizontal range is the observed minimum and maximum of the 12 individual rates. One cell update advances all fields at one interior cell through a complete step, and timing includes overlap work. CPU units are millions of cell updates per second and GPU units are billions. CPU uses a configured budget of 248 cores and actual teams of 248, except that EBM at 128 bands uses 128 workers. The SW CPU header states 248 cores and the EBM CPU header states ≤248 cores. GPU uses one NVIDIA GH200 120GB device. The input retains the actual resource identities and frozen SW MIXED and EBM CLIMATE input banks. The unchanged physical illustrations have separate evidence, including the SW dam-break test at 0.03125 s.

Each model figure places CPU on the left and GPU on the right. Five left labels cover eight physical rows, with single Assembly and ESM.md rows followed by paired tuned and vanilla rows for Fortran, Julia and compiled Python. Grid resolution uses purple circles, teal squares and navy diamonds. Tuned markers are solid, while vanilla markers have coloured diagonal hatching inside white faces and coloured outlines. No background band is hatched. The ESM.md row has a pale grey highlight and bold label, with faint horizontal separators between language groups. Grid shapes and solid or hatched markers have a compact shared key. Both rate axes use plain numeric log ticks and state their scale in the headers. Positive margins keep the smallest-grid points and ranges clear of the plot edges. Units stay below the ticks, and horizontal ranges remain visible behind the markers.

Run the commands below from the poster directory only after the complete input and independent audit are accepted for publication. Prefix each command with the owned Slurm allocation required by AGENTS.md. The accepted output stems replace the current language exports without creating another set of names.

```bash
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model sw --profile poster --output figures/poster/language_water_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model ebm --profile poster --output figures/poster/language_energy_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model sw --profile paper --font-file "$PAPER_FONT_FILE" --output figures/paper/language_water_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model ebm --profile paper --font-file "$PAPER_FONT_FILE" --output figures/paper/language_energy_rates
```

The poster profile is 364.249 by 169.299 mm with at least 25.247 pt text. The paper profile is 6.3 by 3.35 inches with 8.5 pt text. Each export retains a JSON receipt and PNG, SVG and PDF files. The native PowerPoint embeds the 400 DPI PNG so marker hatching survives saved-PowerPoint export, while source SVG and PDF copies remain available. Inspect hatches, labels and ranges in the actual final PDF at the placement size.

`scripts/prepare_fresh_poster.py` binds the input, independent audit, two poster chart receipts and derived native notes and Summary in `data/fresh-language-poster-manifest.json`. Its default is read-only, and `--write` creates a manifest only after validation. The builder and checker use this manifest without a historical fallback. The final workflow and evidence commands are in [README.md](README.md). The retained matched and scaling products below keep their own inputs and evidence and supply no substitute observation for the fresh eight-route cohort.

## Retained matched and scaling figures

The matched-rate figures use three grid columns, with CPU above GPU. Each facet has two horizontal bars, with the orange hand-tuned baseline above blue ESM.md, method labels at the left of each platform row, and numeric rates beside the bar ends. Every facet has an independent zero-based linear rate axis. Paper facets show three rate ticks, and poster facets show the zero and upper-limit ticks to keep the larger text clear of the row headings. Read its tick values when comparing absolute magnitudes across grids or platforms. This keeps both low-rate and high-rate workloads readable without broken or normalised bar axes.

The collector schemas are in `data/schemas/`. For current results, set `MATCHED_RATE_DATA` and `CPU_SCALING_DATA` to the completed accepted files. Set `PAPER_FONT_FILE` to the permitted local Helvetica Neue collection when standard Matplotlib registration cannot find that family. The scripts retain the paper family and never copy that external font binary.

```bash
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model sw --profile paper --cpu-cores 248 --font-file "$PAPER_FONT_FILE" --expected-steps 1000 --output figures/water_rates
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model ebm --profile poster --cpu-cores 248 --expected-steps 1000 --output figures/energy_rates
python scripts/render_scaling_bars.py --input "$CPU_SCALING_DATA" --model both --font-file "$PAPER_FONT_FILE" --expected-steps 1000 --output figures/cpu_scaling
```

An explicit `--font-family` option names a declared installed family and never downloads or bundles a replacement. It is not an automatic fallback. Historical diagnostics require caller-supplied input with explicit historical status. No historical archive is supplied by the installation payload.

The published data contain accepted current matched comparisons and the full eleven-budget CPU sweep. The horizontal revision uses those exact recorded times. Each revised export requires its own final-size, bar-end label, worker-label and visual review before publication.

## Matched and scaling CPU series and actual teams

Accepted CPU records declare `series_kind` as `primary` or `fixed_scaling`, a nonempty `run_id`, and separate `active_workers` and `nonempty_spatial_owners_by_route` maps for `baseline` and `esm_md`. Actual worker-team sizes count the OpenMP team. Nonempty-owner counts identify team members with nonempty spatial ownership. A configured budget, a team size and a nonempty-owner count describe different quantities and must not be relabelled as one another.

The main comparison requires `primary` CPU records under the configured ceiling. The current protocol selects one actual team for the baseline and uses that same team for both routes at each workload. Generic records retain per-route team fields, and the receipt states whether the teams are equal. This is not a claim that each route received an independently optimised team size.

Scaling requires `fixed_scaling` records. The SW team equals `cpu_cores` for both routes. The frozen EBM interface requires the team to equal `min(cpu_cores, bands)`. Thus the 128-band case at configured budgets 144 and 248 uses an actual 128-worker team, which is disclosed in the caption and records. Arbitrary adaptive reductions do not qualify as fixed scaling. Each route's nonempty-owner count must remain positive and no larger than its actual team or the number of interior cells.

The two selectors reject the wrong CPU series instead of merging or relabelling it. Keep primary CPU/GPU input and fixed-scaling CPU input as distinct products. GPU records retain their existing requirements and do not need the new CPU-only fields.

## Matched and scaling metadata-only audit

`--audit-only` checks current accepted records without loading rendering libraries, style helpers or fonts. It prints a metadata-consistency report with series kinds, run IDs, actual teams and owner counts. It checks twelve raw timing pairs, recorded qualification flags and evidence identifiers. It does not repeat physical verification or establish scientific acceptance. No figure or output file is written, and `--output` is required only when rendering.

```bash
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model sw --cpu-cores 248 --audit-only --expected-steps 1000
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model ebm --cpu-cores 248 --audit-only --expected-steps 1000
python scripts/render_scaling_bars.py --input "$CPU_SCALING_DATA" --model both --audit-only --expected-steps 1000
```

The same optional `--expected-steps 1000` check is available before a normal render. The frozen workload ledger describes the protocol only, and actual per-condition qualification evidence remains a separate requirement. Earlier historical layout checks remain preparation evidence. Final current-data figures and the complete scaling set need their own accepted-data render and label-bound audits.

Poster CPU bars show actual supplied route worker counts inside the bars, in black on orange and white on blue, with a shared footer note. Counts come only from `active_workers`, never from the budget or owner counts. The paper table carries actual team counts, so paper graphics retain only numeric rate labels. A rectangle-bound check rejects any worker text that does not fit inside its bar. The earlier published vertical version passed these current-data checks. The horizontal exports record their own text size, bar-end label bounds and worker-label bounds in their receipts, with independent visual review before promotion.

The combined CPU scaling figure places the six grids in one row, with shallow water first and energy balance second. All eleven configured budgets appear from top to bottom and share the budget labels at the left. Each grid keeps an independent zero-based horizontal rate axis. This arrangement preserves the paper placement size and gives every budget a readable row. The receipt retains the general narrow-panel findings, actual row spacing, text bounds and the 128-band EBM worker cap.

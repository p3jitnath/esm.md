# Publication plot profile

This bundle prepares matched CPU and GPU rate figures and CPU scaling figures for the poster project. The scripts find sibling code, assets and archived inspection data from their own location. They do not require a project runtime folder or a skill cache. Supply accepted current data through `--input` and choose an output prefix through `--output`.

The paper default remains Helvetica Neue. This is a declared installed font dependency, resolved with standard Matplotlib font registration and fallback disabled. If the family is not registered, provide a permitted local file through `--font-file`. That file is registered at runtime and is never copied or redistributed by these scripts. The bundle contains no Helvetica binary.

Poster figures use the unchanged Open Sans regular and bold files from the existing poster assets, with their complete notice and provenance. No other font binary is included. An explicitly selected external family must resolve through standard Matplotlib registration or a caller-supplied runtime font file. The default profiles never silently switch families.

`requirements_plotting.txt` records the tested direct runtime packages. They provide Matplotlib drawing, NumPy arrays and PyMuPDF PDF inspection. The recorded environment uses Python 3.11. Installing these packages also installs their declared dependencies.

The helper provenance file records the pinned source identity, source hash, font-loading adaptation and packaged font hashes. Its palette, Matplotlib settings, audit functions and export implementation retain the pinned helper. The final script snapshot record identifies the draft sources and the portable path changes.

The installation payload supplies no performance observations or historical stand-ins. Production commands consume current accepted files through `--input`. Historical diagnostic compatibility can accept a caller-supplied historical input, which keeps its visible diagnostic status. Only that explicit historical status bypasses the new CPU policy fields. Accepted current records cannot use the diagnostic bypass.

Each rate point is the useful interior-cell update count divided by the median of twelve recorded times. Thin lines retain the observed minimum and maximum of the twelve individual rates. All timing samples, processor budgets, supplied active-worker counts, source identities and acceptance metadata remain in the receipt JSON. The displayed rate axes are absolute and start at zero.

`data/main_workload_contract.json` records the frozen workload and measurement protocol only. It is not performance acceptance proof. Current input records need their own actual qualification flags and independent verification and timing evidence. Plotting checks the supplied records rather than carrying out those scientific checks. The ledger is not read by the plotting scripts.

Each facet has an independent zero-based linear rate axis. Read its tick values when comparing absolute magnitudes across grids or platforms. This keeps both low-rate and high-rate workloads readable without broken or normalised bar axes.

The collector schemas are in `data/schemas/`. For current results, set `MATCHED_RATE_DATA` and `CPU_SCALING_DATA` to the completed accepted files. Set `PAPER_FONT_FILE` to the permitted local Helvetica Neue collection when standard Matplotlib registration cannot find that family. The scripts retain the paper family and never copy that external font binary.

```bash
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model sw --profile paper --cpu-cores 248 --font-file "$PAPER_FONT_FILE" --expected-steps 1000 --output figures/water_rates
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model ebm --profile poster --cpu-cores 248 --expected-steps 1000 --output figures/energy_rates
python scripts/render_scaling_bars.py --input "$CPU_SCALING_DATA" --model both --font-file "$PAPER_FONT_FILE" --expected-steps 1000 --output figures/cpu_scaling
```

An explicit `--font-family` option names a declared installed family and never downloads or bundles a replacement. It is not an automatic fallback. Historical diagnostics require caller-supplied input with explicit historical status. No historical archive is supplied by the installation payload.

No accepted current performance records or figures are supplied in this bundle. Final accepted data and figures still need their own final-size and label-bound checks after collection. Historical one-core checks do not establish the full eleven-budget scaling layout.

## CPU series and actual teams

Accepted CPU records declare `series_kind` as `primary` or `fixed_scaling`, a nonempty `run_id`, and separate `active_workers` and `nonempty_spatial_owners_by_route` maps for `baseline` and `esm_md`. Actual worker-team sizes count the OpenMP team. Nonempty-owner counts identify team members with nonempty spatial ownership. A configured budget, a team size and a nonempty-owner count describe different quantities and must not be relabelled as one another.

The main comparison requires `primary` CPU records under the configured ceiling. The current protocol selects one actual team for the baseline and uses that same team for both routes at each workload. Generic records retain per-route team fields, and the receipt states whether the teams are equal. This is not a claim that each route received an independently optimised team size.

Scaling requires `fixed_scaling` records. The SW team equals `cpu_cores` for both routes. The frozen EBM interface requires the team to equal `min(cpu_cores, bands)`. Thus the 128-band case at configured budgets 144 and 248 uses an actual 128-worker team, which is disclosed in the caption and records. Arbitrary adaptive reductions do not qualify as fixed scaling. Each route's nonempty-owner count must remain positive and no larger than its actual team or the number of interior cells.

The two selectors reject the wrong CPU series instead of merging or relabelling it. Keep primary CPU/GPU input and fixed-scaling CPU input as distinct products. GPU records retain their existing requirements and do not need the new CPU-only fields.

## Metadata-only audit

`--audit-only` checks current accepted records without loading rendering libraries, style helpers or fonts. It prints a metadata-consistency report with series kinds, run IDs, actual teams and owner counts. It checks twelve raw timing pairs, recorded qualification flags and evidence identifiers. It does not repeat physical verification or establish scientific acceptance. No figure or output file is written, and `--output` is required only when rendering.

```bash
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model sw --cpu-cores 248 --audit-only --expected-steps 1000
python scripts/render_performance_bars.py --input "$MATCHED_RATE_DATA" --model ebm --cpu-cores 248 --audit-only --expected-steps 1000
python scripts/render_scaling_bars.py --input "$CPU_SCALING_DATA" --model both --audit-only --expected-steps 1000
```

The same optional `--expected-steps 1000` check is available before a normal render. The frozen workload ledger describes the protocol only, and actual per-condition qualification evidence remains a separate requirement. Earlier historical layout checks remain preparation evidence. Final current-data figures and the complete scaling set need their own accepted-data render and label-bound audits.

Poster CPU bars show actual supplied route worker counts inside the bars, in black on orange and white on blue, with a shared legend note. Counts come only from `active_workers`, never from the budget or owner counts. Paper graphics keep their existing labels because the paper table carries team counts. A rectangle-bound check rejects any worker text that does not fit inside its bar. This display addition has not been rendered against current CPU data yet. Its accepted-data font, bound and visual review remains required.

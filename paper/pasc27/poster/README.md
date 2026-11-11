# esm.md Poster Project

This directory contains the editable A0 landscape PowerPoint and PDF, all plotting and build scripts, figure data, approved artwork and provenance. It preserves the approved University of Cambridge layout, Open Sans type, paisley banner, sponsor marks and footer. The generated implementation is labelled `esm.md` in the performance graphs.

## Rebuild

Run these commands from the repository root. Rebuilding uses copied measurements and accepted reference model states, so no model simulation is needed. The tested Python environment is pinned in `requirements.txt`.

```bash
python3 -m venv .runtime/poster_environment
.runtime/poster_environment/bin/python -m pip install -r paper/pasc27/poster/requirements.txt
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/plot_physics.py
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/plot_performance.py
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/plot_historical_controls.py
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/build_poster.py
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/check_poster.py
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/refresh_evidence.py
```

The paper figure sources are also included under `scripts/`. With the separate paper repository at `paper/pasc27/submission/`, regenerate its four final PDFs with the following commands. These scripts use the same accepted data and the bundled plotting helper. They preserve the paper’s Helvetica Neue profile, which requires a locally licensed collection under `~/fonts/helvetica/` or `$GRAPH_PLOTTING_FONT_DIR/helvetica/`. Diagnostic exports stay under the paper’s ignored `.scratch/` directory.

```bash
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/plot_paper_physics.py
.runtime/poster_environment/bin/python paper/pasc27/poster/scripts/plot_paper_performance.py
```

All axis and colour-bar unit labels use square brackets, such as `Depth [m]`, `Temperature [°C]` and `Rate [million updates/s]`. This changes the label notation while preserving values, scales, colour limits and timing definitions.

The final files are `esm-md-a0-landscape.pptx` and `esm-md-a0-landscape.pdf`. A 150 dpi PNG export of the saved PDF is available as `esm-md-a0-landscape.png`, with 7022 by 4967 pixels. Temporary renders and check logs stay under the ignored `.runtime/poster_update_20261108/` folder. Local `.build/` and Python caches are excluded from publication. Text, headings, workflow blocks and positions remain native editable PowerPoint objects. Scientific artwork is embedded as SVG with PNG fallbacks, and its editable plotting sources and data are included here. Install the bundled Open Sans fonts when editing the PowerPoint on another computer.

## Measurements and Meaning

The active performance panels compare seven implementations at three workloads on each platform. The generated solver is labelled `esm.md`. The six controls are vanilla and tuned Fortran, Julia and compiled Python. Vanilla means the unchanged control source compiled with the recorded strict, target-aware optimisation settings. Tuned means the retained measured source optimisation. Vanilla Python is also compiled, and the timers exclude compilation. CPU means central processing unit and GPU means graphics processing unit. CPU measurements use one Neoverse V2 core, and GPU measurements use one NVIDIA GH200 device.

Current `esm.md` measurements come from November 2026. The CPU controls were measured on 5 October 2026 and GPU controls on 8 October 2026. These are separate groups of runs on the same hardware types and model workloads, with their original dates, jobs and nodes preserved. They show absolute update rates and do not form a freshly paired speedup experiment. The graphs label the October and November groups visibly.

Points show medians and whiskers show observed minimum–maximum ranges across twelve runs per condition. Colours and marker shapes identify the three grids. Higher update rates are faster. CPU horizontal axes are linear, so equal distances show equal rate changes. GPU horizontal axes are logarithmic, where successive major ticks differ by a factor of ten. One complete cell update advances every model field through both time stages and the boundaries. CPU and GPU facets have separate scales and timing boundaries.

CPU rates use wall-clock time for repeated complete updates. GPU device timers measure a launch graph after warm-up. This graph stores the sequence of GPU kernel launches for complete time steps. Compilation, setup, input restoration, transfers, verification and file writing remain outside the recorded intervals as applicable. These rates measure numerical computation rather than end-to-end forecast time. Raw Assembly control data remain in immutable source evidence and outside-chart comparisons. No chart contains an Assembly series or label.

The six current CPU median rates remain below the paired Assembly controls, so this snapshot does not establish CPU parity. The restored language comparisons use the earlier controls described above and do not alter that limit.

The physical figures use unchanged accepted reference Fortran output. `formulations/sw/dam_break.md` has the same bytes and physics revision 1.0 as its earlier filename. Water shows a periodic dam release at 0.03125 seconds. The energy-balance globe shows a latitude-band temperature field after the simulated time recorded in `figure-evidence.json`. Country outlines provide geographic context and do not add longitude-dependent temperature information. These are model demonstrations rather than observed weather.

Earlier CPU and GPU control data remain under `data/historical/`, with standalone historical plots under `figures/historical/`. The active panels now show these language controls alongside `esm.md`, retaining the date distinction. The original pre-update poster is preserved locally under `.runtime/poster_original_20261108/`.

## Sources and Checks

`data/results-current.json` retains each accepted current run record’s original node, allocation and source identities. `data/dam-break-rename.json` maps the formulation rename and comment-only source-header changes without rewriting those original records. `data/solver-filename-renames.json` records the filename rename checkpoint. The active CPU and GPU Fortran sources use `solver.f90` and `gpu/solver.cuf` for each model. The replaced handwritten CPU assembly and GPU PTX were then moved to `.archive/sw_ebm_assembly/`, with their paths and hashes recorded in its manifest. Raw benchmark identities remain unchanged.

`project-profile.json` records the approved design and institution assets. `evidence.json` maps claims to their measurement files and scientific sources. `assets/asset-urls.json` and the other provenance files retain official artwork sources. The bundled plotting-style helper and its formatting check are recorded in `scripts/style/provenance.json`. The Python sources use Black 25.1.0. The unit-label update retains the previous plotting calculations and checks that formatting preserves each syntax tree. Its evidence is recorded in `data/unit-label-update.json`.

The build uses the bundled native template and vector artwork. `check_poster.py` checks actual saved PowerPoint geometry and fonts, then decodes the actual exported PDF QR at two render sizes. Final-size visual inspection remains a separate recorded check. Desktop Microsoft PowerPoint inspection is not claimed. The QR opens the repository, and full reference identifiers remain in metadata while visible URLs stay out of the printed footer.

The approved paisley SVG is used directly. `scripts/trace_banner.py` preserves the historical tracing procedure for provenance and is not needed for ordinary poster rebuilds. Recreating that historical step also needs `vtracer==0.6.15`; it does not download or redraw institution logos.

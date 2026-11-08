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

The final files are `esm-md-a0-landscape.pptx` and `esm-md-a0-landscape.pdf`. Temporary renders and check logs stay under the ignored `.runtime/poster_update_20261108/` folder. Local `.build/` and Python caches are excluded from publication. Text, headings, workflow blocks and positions remain native editable PowerPoint objects. Scientific artwork is embedded as SVG with PNG fallbacks, and its editable plotting sources and data are included here. Install the bundled Open Sans fonts when editing the PowerPoint on another computer.

## Measurements and Meaning

`data/results-current.json` contains the accepted measurements used by the poster. Active performance panels show only the compiled Fortran implementation labelled `esm.md`, on one central processing unit (CPU) core or one graphics processing unit (GPU). The CPU is Neoverse V2 and the GPU is NVIDIA GH200. Each plotted rate uses twelve accepted runs. Points show median rates and whiskers show observed minimum–maximum ranges. The horizontal scale is logarithmic, so successive major tick labels differ by a factor of ten. One complete cell update advances every model field through both time stages and the boundaries.

CPU and GPU timings have separate workloads and timing boundaries. CPU rates cover repeated numerical updates. GPU device timers measure a launch graph after warm-up. This graph stores the sequence of GPU kernel launches for complete time steps. Compilation, setup, input restoration, transfers, verification and file writing remain outside the reported intervals as applicable. Visible graphs have no assembly series or hidden assembly-ratio axis. Raw assembly control data remain in the copied evidence snapshots so the paired experiments can be traced.

The six CPU median rates remain below the paired assembly controls, so this snapshot does not establish CPU parity.

The physical figures use unchanged accepted reference Fortran output. Water shows a periodic dam release at 0.03125 seconds. The energy-balance globe shows a latitude-band temperature field after the simulated time recorded in `figure-evidence.json`. Country outlines provide geographic context and do not add longitude-dependent temperature information. These are model demonstrations rather than observed weather.

Earlier optimised and baseline Fortran, Julia and compiled-Python controls remain separately under `data/historical/` and `figures/historical/`. They come from an older experiment and are not mixed into the fresh CPU/GPU result panels. Their separate historical plots omit the assembly series. The original seven-way graphics remain only in the local pre-update backup.

## Sources and Checks

`data/results-current.json` retains each accepted run record’s original node, allocation and source identities. `data/solver-filename-renames.json` records the filename rename checkpoint. The active CPU and GPU Fortran sources use `solver.f90` and `gpu/solver.cuf` for each model. The replaced handwritten CPU assembly and GPU PTX were then moved to `.archive/sw_ebm_assembly/`, with their paths and hashes recorded in its manifest. Raw benchmark identities remain unchanged.

`project-profile.json` records the approved design and institution assets. `evidence.json` maps claims to their measurement files and scientific sources. `assets/asset-urls.json` and the other provenance files retain official artwork sources. The bundled plotting-style helper and its formatting check are recorded in `scripts/style/provenance.json`. Black 25.1.0 leaves all nine poster Python files unchanged after formatting, and its syntax-tree check confirms that formatting preserved behaviour.

The build uses the bundled native template and vector artwork. `check_poster.py` checks actual saved PowerPoint geometry and fonts, then decodes the actual exported PDF QR at two render sizes. Final-size visual inspection remains a separate recorded check. Desktop Microsoft PowerPoint inspection is not claimed. The QR opens the repository, and full reference identifiers remain in metadata while visible URLs stay out of the printed footer.

The approved paisley SVG is used directly. `scripts/trace_banner.py` preserves the historical tracing procedure for provenance and is not needed for ordinary poster rebuilds. Recreating that historical step also needs `vtracer==0.6.15`; it does not download or redraw institution logos.

# ESM.md Poster Project

This directory contains the editable A0 landscape PowerPoint and PDF, plotting and build sources, accepted data, approved artwork and provenance. It preserves the University of Cambridge layout, Open Sans type, paisley banner, sponsor marks and footer. The title matches the paper as “ESM.md: From Markdown Physics to Verified, Optimised Earth System Model Solvers”. Its native editable 72 pt text has no underlines and fits on one line. Performance graphs label the generated route ESM.md and the comparison route Hand-tuned baseline.

## Rebuild

Run commands through an owned Slurm allocation, following AGENTS.md. The tested export environment is pinned in requirements.txt, with the portable plot dependencies in requirements_plotting.txt. For a fresh local environment, install both files into a Git-ignored environment under .runtime/.

The rebuild uses accepted copied measurements and saved physical states. It does not run a model or collect timings. Before plotting, audit data/accepted-main-input.json with the portable renderer’s audit-only option. The main input must contain only the accepted primary comparisons. The current protocol uses 1,000 complete steps, and fixed-budget scaling has a separate input and export.

```bash
python3 paper/pasc27/poster/scripts/render_performance_bars.py --input paper/pasc27/poster/data/accepted-main-input.json --model sw --cpu-cores 248 --audit-only --expected-steps 1000
python3 paper/pasc27/poster/scripts/render_performance_bars.py --input paper/pasc27/poster/data/accepted-main-input.json --model ebm --cpu-cores 248 --audit-only --expected-steps 1000
python3 paper/pasc27/poster/scripts/render_performance_bars.py --input paper/pasc27/poster/data/accepted-main-input.json --model sw --profile poster --mode matched_rates --cpu-cores 248 --output paper/pasc27/poster/figures/poster/water_rates
python3 paper/pasc27/poster/scripts/render_performance_bars.py --input paper/pasc27/poster/data/accepted-main-input.json --model ebm --profile poster --mode matched_rates --cpu-cores 248 --output paper/pasc27/poster/figures/poster/energy_rates
python3 - <<'PYCODE'
from pathlib import Path
import json
poster = Path("paper/pasc27/poster")
path = poster / "data/accepted-performance-update.json"
manifest = json.loads(path.read_text())
for model, stem in (("sw", "water_rates"), ("ebm", "energy_rates")):
    receipt = poster / "figures/poster" / (stem + ".json")
    manifest["render_metadata"][model] = json.loads(receipt.read_text())
path.write_text(json.dumps(manifest, indent=2) + "\n")
PYCODE
python3 paper/pasc27/poster/scripts/build_poster.py
python3 paper/pasc27/poster/scripts/check_poster.py
```

After replotting, replace each render_metadata entry in data/accepted-performance-update.json with the new matching JSON render receipt before building. The source manifest and final review hashes then identify the new artwork, while the accepted measurement words remain unchanged. Run the commands above from the repository root. Prefix each command with srun and the allocation options required by AGENTS.md. The build requires data/accepted-performance-update.json with status accepted, two matching accepted render receipts and final native prose. Missing or pending measurements stop the build and checker. A fresh human review of the exported PDF is required before scripts/refresh_evidence.py writes evidence.json. The exact source schema is data/schemas/poster-update.schema.json.

The final files are esm-md-a0-landscape.pptx, esm-md-a0-landscape.pdf and the saved-PDF PNG esm-md-a0-landscape.png. The PNG is 7,022 by 4,967 pixels at 150 dpi. The checker also exports local review crops and decodes the actual PDF QR at two sizes. Temporary builds and review records stay under .runtime/poster_update_20261108/ outside Git. Text, headings, workflow blocks and positions remain native editable PowerPoint objects. Scientific artwork is embedded as SVG with PNG fallbacks. Install the bundled Open Sans fonts when editing the PowerPoint elsewhere.

## Methods and skills

[md2fort](../../../skills/md2fort/SKILL.md) guides portable Fortran development for central processing units (CPUs). [md2fort-gpu](../../../skills/md2fort-gpu/SKILL.md) guides generation, verification and optimisation for graphics processing units (GPUs) through CUDA Fortran and a separate comparison path written in PTX, NVIDIA’s virtual GPU instruction code. The supplied inputs are Markdown physics, a frozen numerical contract and prior verified source. The LLM proposes source candidates, while people choose scope and review source and evidence. Independent physical checks and complete byte agreement precede instruction inspection and timing. Compilers translate Fortran and CUDA Fortran, while direct PTX uses a GPU assembler. Revised native Methods, workflow and performance prose are blue for review.

## Measurements and meaning

Each model figure compares two implementations at three matched grids. The main CPU comparison declares a configured ceiling of 248 cores. Both routes use the same actual team within each paired workload, and that team can differ between grids. Actual worker counts appear inside the CPU bars beneath the rates. The CPU budget 248 cores row label describes the configured ceiling. An actual team is a group of CPU workers started together. A nonempty spatial owner has at least one interior grid cell to update. Their counts are retained separately for each route. A small number of latitude bands can limit useful ownership. The allocated node size, configured ceiling, actual team and nonempty owners describe different quantities. The GPU comparison uses one device.

A useful cell update advances each interior cell once through the complete time step. Required neighbouring-cell and boundary calculations remain part of that work. Each plotted point divides the useful update count by the median elapsed seconds over twelve observations. This can differ from the median of twelve individually computed rates, which the JSON receipt retains separately. Whiskers show the observed minimum and maximum individual rates. Higher bars are faster. Each grid has its own zero-based linear axis, and the receipt declares the visible unit and divisor from millions. Axis and colour-bar units appear in square brackets, with commas between each group of three integer digits.

CPU timings include complete numerical updates and their coordinator, including collection of partial states, buffer copies and worker synchronisation. GPU timings use the declared warmed device-event interval. Compilation, setup, verification and file output remain outside their stated timers, with GPU transfers and graph construction excluded where recorded. The accepted source files retain exact timer scopes, node and job identities, affinity, memory placement, quiet policy and GPU power-management observations. These measurements describe complete-update computation on the recorded hardware and inputs. They do not establish performance on another architecture or end-to-end forecast time.

Physical figures use unchanged accepted Fortran states. formulations/sw/dam_break.md preserves the formulation bytes and physics revision 1.0 from its earlier filename. The water example shows a periodic dam release at 0.03125 s. The energy-balance globe shows latitude-band temperatures after the time recorded in figure-evidence.json. Country outlines provide context without adding longitude-dependent temperature variation. These examples are model calculations rather than observations.

## Sources and checks

The active manifest data/accepted-performance-update.json names the actual CPU and GPU source records, accepted campaigns, final figure files, render receipts and native Summary text. data/gpu-results-20261112.json retains the accepted GPU source observations. CPU source paths are recorded in the manifest. The comparison evidence is generated as data/performance-figure-evidence-20261112.json after independent recorded-rate, structural, QR and visual checks. Original elapsed-time words remain unchanged in their accepted source records. Older data/*.json and data/historical/ files remain immutable evidence and do not supply the new active figures.

project-profile.json records the design, current workflow and measurement scope. evidence.json maps claims to source identities, actual input reviews and final artwork hashes. The structural and manual visual receipts must name the same accepted input and final PDF, so an earlier review cannot verify later exports. Desktop Microsoft PowerPoint inspection is not claimed. The QR opens the project repository, and reference identifiers remain in metadata without visible footer URLs.

The portable plotting source and its helper, schema, style provenance and permitted font notices live under this directory. PLOT_PROFILE.md records typography and export rules. Open Sans is bundled for the poster. The paper’s Helvetica Neue profile requires a locally licensed installation and is not redistributed. Python sources use Black 25.1.0.

The unchanged physical figures can be rebuilt with scripts/plot_physics.py when needed. Earlier performance scripts and figures retain their original evidence and are outside the active rebuild sequence. data/figure-label-update.json records the earlier display-label checkpoint. data/unit-label-update.json records the earlier unit-notation checkpoint. data/dam-break-rename.json and data/solver-filename-renames.json preserve the source renames. The active solver entry points are solver.f90 and gpu/solver.cuf for each model, with replaced comparison sources retained in the project’s local archive.

Approved assets and their provenance remain under assets/. The paisley source and official institution marks preserve their proportions and clear space. scripts/trace_banner.py records the historical tracing procedure and is not part of an ordinary rebuild.

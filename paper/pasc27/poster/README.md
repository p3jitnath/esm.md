# ESM.md research poster

This project retains the editable A0 PowerPoint, saved PDF, final PNG, source artwork and accepted plotting input. Its model sections are **3.2 Shallow-Water Model** and **3.3 Energy-Balance Model**. The author line and numbered affiliations follow the paper in ../submission/main.tex and are stored in project-profile.json. Poster text is black, while paper review colours follow their separate instructions.

Run file work through an owned Slurm allocation, following the repository AGENTS.md. The tested export packages are listed in requirements.txt and requirements_plotting.txt. Use an ignored local environment and keep Helvetica Neue outside the published assets. Poster artwork uses the supplied Open Sans files.

The fresh performance entry points require data/fresh-language-comparison-input.json and data/fresh-language-encoding-audit.json. The normaliser and independent encoding audit produce these only after every collector passes and the root agent accepts the cohort. The compact input contains 96 route and workload conditions, all 1,152 elapsed times, 1,000 complete steps, source identities and actual resources. The independent audit owns timing and statistical fidelity. Poster scripts check the accepted cohort and its figure, text and export bindings.

Each point is the complete useful cell-update count divided by the median elapsed time, then converted to the stated rate unit. Horizontal lines retain the observed minimum and maximum of twelve individual rates. CPU rates use millions of cell updates per second, and GPU rates use billions. The CPU budget is 248 cores, with 128 actual workers for the 128-band EBM. GPU records identify one GH200 device. Producer acceptance limits remain attached to the input and evidence.

Run these commands from the poster directory after accepted data and the data go are available. The renderer uses one implementation for both publication profiles and reuses the existing figure stems.

```bash
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model sw --profile poster --output figures/poster/language_water_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model ebm --profile poster --output figures/poster/language_energy_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model sw --profile paper --font-file "$PAPER_FONT_FILE" --output figures/paper/language_water_rates
python scripts/render_language_scatter.py --input data/fresh-language-comparison-input.json --model ebm --profile paper --font-file "$PAPER_FONT_FILE" --output figures/paper/language_energy_rates
python scripts/prepare_fresh_poster.py --write
python scripts/build_poster.py
python scripts/check_poster.py --output "$POSTER_REVIEW_DIR"
```

The paper profile is 6.3 by 3.35 inches with 8.5 pt text. The poster profile is 364.249 by 169.299 mm with at least 25.247 pt text. Both CPU and GPU use explicitly labelled logarithmic rate axes with positive margins and plain numeric ticks. Grid resolution uses purple circles, teal squares and navy diamonds. Tuned markers are solid. Vanilla markers have coloured diagonal hatching on white faces. Five left labels share eight physical subrows, and the ESM.md row stays pale grey and bold. The PowerPoint embeds the 400 DPI PNGs so marker hatches survive export, while editable SVG and vector PDF copies remain beside the source data.

The manifest data/fresh-language-poster-manifest.json binds the compact input, independent encoding receipt, both model chart receipts, every plotted file and the displayed notes and Summary. Preparation is read-only unless --write is selected. The builder and checker refuse missing, incomplete or stale fresh bindings. The Summary describes readable physics, verification and reusable optimisation lessons. Detailed rates and ranges remain in the comparison plots and their accepted input.

Inspect the actual saved PDF at full-page size and in close-ups. Record visual approval with the exact cohort, input hash and artifact hashes, then bind the final evidence.

```bash
python scripts/refresh_evidence.py --checks "$POSTER_CHECKS" --visual-review "$POSTER_VISUAL_REVIEW" --write
```

The final files are esm-md-a0-landscape.pptx, esm-md-a0-landscape.pdf and esm-md-a0-landscape.png. The checker decodes the actual PDF QR and records native geometry, black fonts, chart identities and current text. Desktop PowerPoint inspection is a separate check and is claimed only if it occurs.

The physical illustrations retain figure-evidence.json and their unchanged artwork as a separate scope. The SW picture is a periodic dam-break test at 0.03125 s. The performance banks use SW MIXED and EBM CLIMATE states. These illustrations supply no benchmark timing observation. The formulation card retains dam_break.md, its equation, symbol definitions and units.

The formulation card shows equation P01 from dam_break.md. Run `python scripts/render_formulation_equation.py` to compile its editable TeX with pdfLaTeX and Computer Modern. The vector PDF and SVG preserve the equation, while the transparent PNG provides 400 DPI at its 24 mm poster height. This command updates only the equation artwork and its evidence.

The poster uses SVG logos in place of the Assembly, Fortran, Julia and Python row labels, while ESM.md remains text. Sources, licences and attribution are recorded in [the logo credits](assets/language-logos/ATTRIBUTION.md) and [provenance](assets/language-logos/provenance.json). The ASM artwork is the blue hexagon SVG supplied by the author. The original file is retained, and an outlined copy keeps its lettering independent of installed fonts. The other three logos retain their original artwork and licences. All four remain vectors in the plot SVG, PDF and native PowerPoint overlays. CairoSVG preserves their gradients and creates print-resolution fallbacks. The paper figures retain their text labels.

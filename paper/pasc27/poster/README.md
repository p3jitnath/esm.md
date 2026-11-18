# ESM.md Research Poster

The A0 poster pairs a physical illustration with a performance plot in each model column. The saved [PowerPoint](esm-md-a0-landscape.pptx), [PDF](esm-md-a0-landscape.pdf) and [PNG](esm-md-a0-landscape.png) use the authors and affiliations in [project-profile.json](project-profile.json).

## Build and Check

Run from this directory in the allocation specified by [AGENTS.md](../../../AGENTS.md). Install the packages in [requirements.txt](requirements.txt) and [requirements_plotting.txt](requirements_plotting.txt) in a local environment.

```bash
python scripts/build_poster.py
python scripts/check_poster.py --output "$POSTER_REVIEW_DIR"
```

These commands use the saved figure manifest. The checker verifies the saved PowerPoint and PDF and exports the final PNG. It checks layout, text, chart identities and the QR code. Review the saved PDF at poster size and in close-ups.

## Figure Sources

The [plot guide](PLOT_PROFILE.md) gives the paper and poster render commands. The active plots use 1,152 times from 96 conditions. The poster embeds print-resolution charts to preserve marker hatching, with SVG logos overlaid in PowerPoint. See the [logo credits](assets/language-logos/ATTRIBUTION.md).

The [physics evidence](figure-evidence.json) covers the separate illustrations, including the periodic dam break at 0.03125 s. For a change to equation P01, run `python scripts/render_formulation_equation.py` to compile its TeX with pdfLaTeX and Computer Modern. The script exports PDF, SVG and a transparent 400 DPI PNG.

## Refresh Accepted Evidence

After accepting a replacement cohort and its encoding audit, retain the old manifest separately before running `python scripts/prepare_fresh_poster.py --write`. Build and check the poster, then record visual approval for that cohort and its exact file hashes. Retain any superseded figure evidence separately before binding the new checks.

```bash
python scripts/refresh_evidence.py --checks "$POSTER_CHECKS" --visual-review "$POSTER_VISUAL_REVIEW" --write
```

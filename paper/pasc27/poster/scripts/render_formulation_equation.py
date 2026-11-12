"""Render the formulation's water-conservation equation with pdfLaTeX."""

from hashlib import sha256
from pathlib import Path
import json
import os
import re
import shutil
import subprocess

import pymupdf

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]


def render_mass_equation():
    """Create vector artwork and a 400 DPI fallback from equation P01.

    Returns
    -------
    dict
        Formulation identity, Computer Modern font checks and output hashes.
        The raster is sized for a 24 mm high equation on the A0 poster.

    Raises
    ------
    FileNotFoundError
        If pdfLaTeX or the formulation is unavailable.
    RuntimeError
        If the source equation or Computer Modern fonts cannot be verified.
    subprocess.CalledProcessError
        If LaTeX cannot compile the source.

    Notes
    -----
    Writes editable TeX, vector PDF and SVG, and transparent PNG artwork to
    figures/. Build logs and intermediate files stay in the ignored runtime.
    The first fenced mathematics block is the existing continuity equation.
    """
    formulation = ROOT / "formulations/sw/dam_break.md"
    match = re.search(r"```math\s*\n(.*?)\n```", formulation.read_text(), re.S)
    if match is None:
        raise RuntimeError("The formulation has no water-conservation equation.")
    equation = match.group(1).strip()
    executable = shutil.which("pdflatex")
    if executable is None:
        raise FileNotFoundError("pdfLaTeX is required for the poster equation.")
    stem = POSTER / "figures/physics-note-mass"
    tex = stem.with_suffix(".tex")
    tex.write_text(
        "\\documentclass{article}\n"
        "\\usepackage{amsmath}\n"
        "\\pagestyle{empty}\n"
        "\\begin{document}\n\\noindent\n"
        "\\(\\displaystyle\n" + equation + "\n\\)\n"
        "\\end{document}\n"
    )
    build = ROOT / ".runtime/poster_equation_latex"
    build.mkdir(parents=True, exist_ok=True)
    environment = {**os.environ, "SOURCE_DATE_EPOCH": "0", "FORCE_SOURCE_DATE": "1"}
    with (build / "pdflatex-console.log").open("w") as output:
        subprocess.run(
            [
                executable,
                "-no-shell-escape",
                "-halt-on-error",
                "-interaction=batchmode",
                "-output-directory",
                str(build),
                str(tex),
            ],
            cwd=build,
            env=environment,
            stdout=output,
            stderr=subprocess.STDOUT,
            check=True,
            timeout=60,
        )
    pdf = stem.with_suffix(".pdf")
    with pymupdf.open(build / pdf.name) as original:
        if len(original) != 1:
            raise RuntimeError("The equation must fit on one LaTeX page.")
        bounds = pymupdf.Rect()
        for _, box, *_ in original[0].get_bboxlog():
            bounds |= pymupdf.Rect(box)
        bounds += (-1, -1, 1, 1)
        with pymupdf.open() as cropped:
            page = cropped.new_page(width=bounds.width, height=bounds.height)
            page.show_pdf_page(page.rect, original, 0, clip=bounds)
            cropped.save(pdf, garbage=4, deflate=True, no_new_id=True)
    with pymupdf.open(pdf) as document:
        if len(document) != 1:
            raise RuntimeError("The poster equation needs exactly one PDF page.")
        page = document[0]
        fonts = sorted({item[3].split("+")[-1] for item in page.get_fonts()})
        if not any(name.startswith("CMMI") for name in fonts) or not any(
            name.startswith("CMR") for name in fonts
        ):
            raise RuntimeError("The equation did not use Computer Modern.")
        stem.with_suffix(".svg").write_text(page.get_svg_image(text_as_path=True))
        scale = 24 * 72 / 25.4 / page.rect.height
        page.get_pixmap(
            matrix=pymupdf.Matrix(scale * 400 / 72, scale * 400 / 72), alpha=True
        ).save(stem.with_suffix(".png"))
        nominal_font_pt = 10 * scale
    return {
        "source": "formulations/sw/dam_break.md",
        "equation_id": "P01",
        "meaning": "Conservation of water",
        "formulation_sha256": sha256(formulation.read_bytes()).hexdigest(),
        "source_equation_matches_formulation": True,
        "backend": "pdfLaTeX",
        "font": "Computer Modern",
        "pdf_fonts": fonts,
        "poster_height_mm": 24,
        "nominal_math_font_pt": nominal_font_pt,
        "fallback_dpi": 400,
        "outputs": {
            extension: sha256(
                stem.with_suffix("." + extension).read_bytes()
            ).hexdigest()
            for extension in ("tex", "pdf", "svg", "png")
        },
    }


if __name__ == "__main__":
    record = render_mass_equation()
    evidence = POSTER / "figure-evidence.json"
    metadata = json.loads(evidence.read_text())
    metadata["physics_note_equation"] = record
    metadata["figure_audits"]["physics-note-mass"] = record
    evidence.write_text(json.dumps(metadata, indent=2) + "\n")
    print(json.dumps(record, indent=2))

"""Check the actual A0 PowerPoint and PDF, including the printed QR code."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pymupdf
from pptx import Presentation
import zxingcpp

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]


def check(output: Path) -> dict:
    """Inspect the saved poster files and retain a focused review record.

    Parameters
    ----------
    output : pathlib.Path
        Directory for temporary PDF renders and the JSON check record.

    Returns
    -------
    dict
        Canvas, native-object, type-size and decoded-QR findings.

    Raises
    ------
    AssertionError
        If geometry, required text, fonts or the final PDF QR is invalid.

    Notes
    -----
    Visual inspection of the saved renders is still required. The function
    reads the delivered files, leaves both documents unchanged and exports
    the saved PDF as a 150 dpi PNG.
    """
    output.mkdir(parents=True, exist_ok=True)
    pptx = POSTER / "esm-md-a0-landscape.pptx"
    pdf = POSTER / "esm-md-a0-landscape.pdf"
    profile = json.loads((POSTER / "project-profile.json").read_text())
    presentation = Presentation(pptx)
    assert len(presentation.slides) == 1
    width, height = presentation.slide_width / 36000, presentation.slide_height / 36000
    assert abs(width - 1189) < 0.1 and abs(height - 841) < 0.1
    slide = presentation.slides[0]
    texts = []
    sizes = []
    names = set()
    for shape in slide.shapes:
        names.add(shape.name)
        x, y, w, h = [
            value / 36000
            for value in (shape.left, shape.top, shape.width, shape.height)
        ]
        assert (
            x >= -0.1 and y >= -0.1 and x + w <= width + 0.1 and y + h <= height + 0.1
        ), shape.name
        if not shape.has_text_frame:
            continue
        texts.append(shape.text)
        for paragraph in shape.text_frame.paragraphs:
            for run in paragraph.runs:
                assert run.font.name == "Open Sans", (shape.name, run.font.name)
                if run.font.size:
                    sizes.append(run.font.size.pt)
    all_text = "\n".join(texts)
    assert "dam_break.md" in all_text
    assert "2d_periodic.md" not in all_text
    assert "md2fort" in all_text and "md2fort-gpu" in all_text
    assert "md2asm" not in all_text
    methods = next(shape for shape in slide.shapes if shape.name == "method-details")
    for index in (0, 2):
        assert all(
            str(run.font.color.rgb) == "0000FF"
            for run in methods.text_frame.paragraphs[index].runs
        )
    skill_step = next(shape for shape in slide.shapes if shape.name == "method-step-2")
    assert skill_step.text == "b. md2fort"
    assert all(
        str(run.font.color.rgb) == "0000FF"
        for run in skill_step.text_frame.paragraphs[0].runs
    )
    title = next(shape for shape in slide.shapes if shape.name == "poster-title")
    assert title.text == profile["identity"]["title"]
    title_runs = list(title.text_frame.paragraphs[0].runs)
    underlined = [run.text for run in title_runs if run.font.underline]
    assert underlined == [], underlined
    assert "Verified Assembly" not in all_text
    assert "Assembly is" not in all_text
    assert "relative to assembly" not in all_text
    assert min(sizes) >= 22
    assert {
        "result-clusters",
        "result-spatial",
        "result-error",
        "result-calibration",
        "github-repository-qr",
    } <= names
    qr = next(shape for shape in slide.shapes if shape.name == "github-repository-qr")
    qr_mm = [value / 36000 for value in (qr.left, qr.top, qr.width, qr.height)]
    decoded = []
    with pymupdf.open(pdf) as document:
        assert len(document) == 1
        page = document[0]
        assert abs(page.rect.width * 25.4 / 72 - width) < 0.1
        assert abs(page.rect.height * 25.4 / 72 - height) < 0.1
        assert document.metadata["title"] == title.text
        title_bounds = pymupdf.Rect(
            *[
                value / 12700
                for value in (
                    title.left,
                    title.top,
                    title.left + title.width,
                    title.top + title.height,
                )
            ]
        )
        title_lines = [
            line
            for block in page.get_text("dict", clip=title_bounds)["blocks"]
            if "lines" in block
            for line in block["lines"]
        ]
        assert len(title_lines) == 1, title_lines
        assert "".join(span["text"] for span in title_lines[0]["spans"]) == title.text
        title_underlines = [
            path
            for path in page.get_drawings()
            if path["type"] == "s"
            and abs(path["width"] - title_runs[0].font.size.pt * 0.05) < 1e-5
            and title_bounds.x0 <= path["rect"].x0 <= path["rect"].x1 <= title_bounds.x1
            and title_bounds.y0 <= path["rect"].y0 <= path["rect"].y1 <= title_bounds.y1
        ]
        assert len(title_underlines) == 0, len(title_underlines)
        x, y, w, h = qr_mm
        clip = pymupdf.Rect(
            x * 72 / 25.4, y * 72 / 25.4, (x + w) * 72 / 25.4, (y + h) * 72 / 25.4
        )
        for scale in (1.5, 3.0):
            pixmap = page.get_pixmap(
                matrix=pymupdf.Matrix(scale, scale), clip=clip, alpha=False
            )
            image = np.frombuffer(pixmap.samples, dtype=np.uint8).reshape(
                pixmap.height, pixmap.width, pixmap.n
            )
            values = [item.text for item in zxingcpp.read_barcodes(image)]
            assert values == [profile["poster"]["qr"]["url"]], values
            pixmap.save(output / f"qr-{scale:g}.png")
            decoded.append(
                {
                    "pdf_scale": scale,
                    "pixels": [pixmap.width, pixmap.height],
                    "decoded": values,
                }
            )
        poster_png = POSTER / "esm-md-a0-landscape.png"
        printed = page.get_pixmap(dpi=150, alpha=False)
        assert (printed.width, printed.height) == (7022, 4967)
        printed.save(poster_png)
        page.get_pixmap(matrix=pymupdf.Matrix(0.85, 0.85)).save(
            output / "final-poster.png"
        )
        for name, bounds in {
            "performance": (408, 510, 1165, 790),
            "footer": (25, 791, 1165, 839),
            "banner": (25, 76, 1165, 193),
        }.items():
            clip = pymupdf.Rect(*[value * 72 / 25.4 for value in bounds])
            page.get_pixmap(matrix=pymupdf.Matrix(1.5, 1.5), clip=clip).save(
                output / f"{name}.png"
            )
    report = {
        "passed": True,
        "canvas_mm": [width, height],
        "slides": 1,
        "native_objects": len(slide.shapes),
        "native_text_frames": len(texts),
        "minimum_native_font_pt": min(sizes),
        "title": title.text,
        "native_title_underlined_letters": underlined,
        "exported_title_lines": len(title_lines),
        "exported_title_underlines": len(title_underlines),
        "qr_final_pdf_checks": decoded,
        "pptx_sha256": hashlib.sha256(pptx.read_bytes()).hexdigest(),
        "pdf_sha256": hashlib.sha256(pdf.read_bytes()).hexdigest(),
        "png_sha256": hashlib.sha256(poster_png.read_bytes()).hexdigest(),
        "png_pixels": [7022, 4967],
        "png_dpi": 150,
        "visual_inspection_required": True,
        "desktop_powerpoint_inspected": False,
    }
    (output / "structural-check.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / ".runtime/poster_update_20261108/final_review",
    )
    print(json.dumps(check(parser.parse_args().output), indent=2))

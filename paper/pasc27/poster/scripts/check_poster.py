"""Check the saved fresh-cohort poster, including its text, artwork and QR."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np
import pymupdf
from pptx import Presentation
import zxingcpp

from poster_comparison_input import load_fresh_comparison

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]
ROUTES = (
    "assembly",
    "esm",
    "fortran_tuned",
    "fortran_vanilla",
    "julia_tuned",
    "julia_vanilla",
    "python_tuned",
    "python_vanilla",
)
GROUPS = ("Assembly", "ESM.md", "Fortran", "Julia", "Python")
COLOURS = ("#681FB1", "#00A6A2", "#29347A")
MARKERS = ("o", "s", "D")
TITLES = {"sw": "3.2 Shallow-Water Model", "ebm": "3.3 Energy-Balance Model"}


def _digest(path: Path) -> str:
    """Return the SHA256 identity of an actual saved file.

    Parameters
    ----------
    path : pathlib.Path
        File to identify without mutation.

    Returns
    -------
    str
        Hexadecimal SHA256 identity.
    """
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _chart_identity(poster: Path, manifest: dict, model: str) -> dict:
    """Check source-bound artwork and the approved scatter encoding.

    Parameters
    ----------
    poster : pathlib.Path
        Poster root containing the bound input and figure files.
    manifest : dict
        Fresh comparison already checked by the common input loader.
    model : {'sw', 'ebm'}
        Model whose CPU and GPU artwork is checked.

    Returns
    -------
    dict
        Actual artwork identities, visible text and rendering limits.

    Notes
    -----
    The independent encoding receipt checks the recorded rates. This function
    checks their figure binding and visual encoding without repeating that audit.
    """
    metadata = manifest["loaded_render_metadata"][model]
    chart = manifest["figures"][model]
    assert metadata["status"] == "accepted"
    assert metadata["presentation"] == "reference_language_scatter"
    assert metadata["profile"] == "poster" and metadata["model"] == model
    assert metadata["fresh_measurement"] is True
    assert tuple(metadata["row_routes"]) == ROUTES
    assert tuple(metadata["visible_group_labels"]) == GROUPS
    assert metadata["esm_highlight_row_index"] == 1
    assert metadata["vanilla_marker_hatch_rows"] == [3, 5, 7]
    assert metadata["hatched_background_bands"] is False
    assert metadata["group_separator_alpha"] == 0.15
    assert metadata["group_separator_positions"] == [0.5, 1.5, 3.5, 5.5]
    assert metadata["source_input"] is None
    assert metadata["minimum_effective_font_pt"] >= 24.5
    assert abs(metadata["final_width_mm"] - 364.249) < 0.01
    assert abs(metadata["final_height_mm"] - 169.2988312921818) < 0.01
    expected_sizes = (64, 256, 1024) if model == "sw" else (128, 4096, 65536)
    key = metadata["grid_colour_shape_key"]
    assert [(item["size"], item["colour"], item["marker"]) for item in key] == list(
        zip(expected_sizes, COLOURS, MARKERS)
    )
    points = metadata["displayed_measurements"]
    assert len(points) == 48
    assert all(
        item["marker_fill"]
        == ("hatched" if item["route"].endswith("vanilla") else "solid")
        for item in points
    )
    axes = {axis["device"]: axis for axis in metadata["axes"]}
    assert set(axes) == {"CPU", "GPU"}
    for axis in axes.values():
        assert axis["scale"] == "logarithmic absolute rates"
        limits = np.asarray(axis["limits"], dtype=float)
        assert limits.shape == (2,) and np.isfinite(limits).all()
        assert 0 < limits[0] < limits[1]
    assert axes["CPU"]["header"] == "CPU · 248 cores · log"
    assert axes["GPU"]["header"] == "GPU · 1 GH200 · log"
    alignment = metadata["horizontal_alignment"]
    assert abs(alignment["centre_error_inches"]) < 1e-8
    assert (
        abs(alignment["left_margin_inches"] - alignment["right_margin_inches"]) < 1e-8
    )
    identities = {}
    for suffix in ("svg", "png", "pdf"):
        path = poster / chart[suffix]
        digest = _digest(path)
        assert any(
            Path(name).suffix == "." + suffix and expected == digest
            for name, expected in metadata["outputs"].items()
        ), (model, suffix)
        identities[suffix] = {"path": chart[suffix], "sha256": digest}
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
    svg = ET.fromstring((poster / chart["svg"]).read_bytes(), parser=parser)
    labels = []
    for element in svg.iter():
        if element.tag == "{http://www.w3.org/2000/svg}text":
            labels.append("".join(element.itertext()))
        elif element.tag == "{http://www.w3.org/2000/svg}g" and element.get(
            "id", ""
        ).startswith("text_"):
            labels.extend(
                child.text or "" for child in element if child.tag is ET.Comment
            )
    labels = [" ".join(value.split()) for value in labels if value.strip()]
    visible = " ".join(labels)
    assert all(label in labels for label in GROUPS), (model, labels)
    assert "Tuned" in labels and "Vanilla" in labels
    assert "Configurations" not in visible
    assert not re.search(r"layout only|\bpending\b", visible, re.IGNORECASE)
    assert "Cell updates [million/s]" in labels
    assert "Cell updates [billion/s]" in labels
    assert axes["CPU"]["header"] in labels and axes["GPU"]["header"] in labels
    assert any(
        element.tag == "{http://www.w3.org/2000/svg}pattern" for element in svg.iter()
    ), (model, "Marker hatching is absent from SVG.")
    with pymupdf.open(poster / chart["pdf"]) as document:
        assert len(document) == 1
        fonts = [
            span["size"]
            for block in document[0].get_text("dict")["blocks"]
            for line in block.get("lines", [])
            for span in line["spans"]
            if span["text"].strip()
        ]
        scale = 364.249 / (document[0].rect.width / 72 * 25.4)
        assert min(fonts) * scale >= 24.5
    return {
        **identities,
        "visible_chart_text": labels,
        "native_picture_format": "png",
        "hatched_marker_pattern_in_svg": True,
        "axes": metadata["axes"],
        "minimum_effective_font_pt": metadata["minimum_effective_font_pt"],
    }


def _accepted_performance(poster: Path) -> tuple[dict, dict]:
    """Load the one accepted fresh cohort before any check outputs are written.

    Parameters
    ----------
    poster : pathlib.Path
        Root containing the fresh input, manifest and encoding receipt.

    Returns
    -------
    tuple of dict and dict
        Validated manifest and actual figure checks for both models.
    """
    manifest = load_fresh_comparison(poster)
    assert manifest["cohort"] == manifest["validated_input"]["cohort"]
    assert manifest["native_picture_format"] == "png"
    charts = {
        model: _chart_identity(poster, manifest, model) for model in ("sw", "ebm")
    }
    return manifest, charts


def _box(shape) -> tuple[float, float, float, float]:
    """Return a native frame in millimetres without changing it.

    Parameters
    ----------
    shape : pptx.shapes.base.BaseShape
        Saved PowerPoint object whose frame is read.

    Returns
    -------
    tuple of float
        Left, top, width and height in millimetres.
    """
    return tuple(
        value / 36000 for value in (shape.left, shape.top, shape.width, shape.height)
    )


def _require_box(shape, expected: tuple[float, float, float, float]) -> None:
    """Require the approved frame within one tenth of a millimetre.

    Parameters
    ----------
    shape : pptx.shapes.base.BaseShape
        Saved PowerPoint object whose frame is checked.
    expected : tuple of float
        Required left, top, width and height in millimetres.

    Raises
    ------
    AssertionError
        If an actual frame coordinate differs by at least 0.1 mm.
    """
    assert all(
        abs(actual - wanted) < 0.1 for actual, wanted in zip(_box(shape), expected)
    ), (shape.name, _box(shape), expected)


def _text_height(shape) -> float:
    """Return the declared native line and paragraph height in millimetres.

    Parameters
    ----------
    shape : pptx.shapes.autoshape.Shape
        Native text box with saved lines, font sizes and paragraph gaps.

    Returns
    -------
    float
        Required text height under the builder's 1.12 line-spacing contract.
    """
    paragraphs = shape.text_frame.paragraphs
    height = 0.0
    for index, paragraph in enumerate(paragraphs):
        runs = [run for run in paragraph.runs if run.text]
        if not runs:
            continue
        size = runs[0].font.size.pt
        height += len(paragraph.text.splitlines()) * size * 1.12 * 25.4 / 72
        if index < len(paragraphs) - 1 and paragraph.space_after:
            height += paragraph.space_after.pt * 25.4 / 72
    return height


def check(output: Path, poster: Path = POSTER) -> dict:
    """Inspect the actual fresh poster and retain a focused review record.

    Parameters
    ----------
    output : pathlib.Path
        Private directory for PDF review crops and the JSON check receipt.
    poster : pathlib.Path
        Root of the self-contained poster project.

    Returns
    -------
    dict
        Accepted cohort, artifact, native-text, geometry and QR checks.

    Raises
    ------
    AssertionError
        If the saved artwork, native text, fonts or final QR differ.
    ValueError
        If the common loader refuses missing or unaccepted fresh measurements.

    Notes
    -----
    This checker reuses the independent encoding audit and does not rerun a
    solver, timing or source audit. Human review of the final PDF is still needed.
    """
    poster = Path(poster).resolve()
    manifest, chart_checks = _accepted_performance(poster)
    input_sha256 = manifest["input_sha256"]
    pptx = poster / "esm-md-a0-landscape.pptx"
    pdf = poster / "esm-md-a0-landscape.pdf"
    profile_payload = (poster / "project-profile.json").read_bytes()
    profile = json.loads(profile_payload)
    profile_sha256 = hashlib.sha256(profile_payload).hexdigest()
    assert profile["poster"]["performance_section_titles"] == TITLES
    assert profile["poster"]["text_colour"] == "#000000"
    assert (
        profile["evidence"]["measurements"]
        == "data/fresh-language-poster-manifest.json"
    )
    presentation = Presentation(pptx)
    assert len(presentation.slides) == 1
    width, height = presentation.slide_width / 36000, presentation.slide_height / 36000
    assert abs(width - 1189) < 0.1 and abs(height - 841) < 0.1
    slide = presentation.slides[0]
    assert len(slide.shapes) == 63, len(slide.shapes)
    names = set()
    texts, sizes = [], []
    native_runs = 0
    for shape in slide.shapes:
        names.add(shape.name)
        x, y, w, h = _box(shape)
        assert (
            x >= -0.1 and y >= -0.1 and x + w <= width + 0.1 and y + h <= height + 0.1
        ), shape.name
        if not shape.has_text_frame:
            continue
        texts.append(shape.text)
        for paragraph in shape.text_frame.paragraphs:
            for run in paragraph.runs:
                if not run.text:
                    continue
                native_runs += 1
                assert run.font.name == "Open Sans", (shape.name, run.font.name)
                assert str(run.font.color.rgb) == "000000", shape.name
                if run.font.size:
                    sizes.append(run.font.size.pt)
    all_text = "\n".join(texts)
    assert "dam_break.md" in all_text and "2d_periodic.md" not in all_text
    assert set(re.findall(r"\bmd2fort(?:-gpu)?\b", all_text)) == {
        "md2fort",
        "md2fort-gpu",
    }
    assert "md2asm" not in all_text
    assert not re.search(r"layout only|\bpending\b", all_text, re.IGNORECASE)
    by_name = {shape.name: shape for shape in slide.shapes}
    assert "results-summary" not in names and "energy-summary" not in names
    assert len(by_name["motivation-context"].text_frame.paragraphs) == 4
    assert len(by_name["method-details"].text_frame.paragraphs) == 5
    assert len(by_name["error-caption"].text_frame.paragraphs) == 3
    assert len(by_name["takeaways"].text_frame.paragraphs) == 3
    for index, expected in enumerate(
        ("a. Inputs", "b. LLM + skills", "c. Verify/time"), 1
    ):
        assert " ".join(by_name[f"method-step-{index}"].text.split()) == expected
    for name, title in (
        ("results-comparison", TITLES["sw"]),
        ("results-diagnostics", TITLES["ebm"]),
    ):
        assert " ".join(by_name[name].text.split()) == title
    scope_text = " ".join(manifest["poster_text"]["chart_notes"])
    assert "frozen input banks" in scope_text.lower() and re.search(
        r"\b1,?000\b", scope_text
    )
    assert all(
        word in scope_text.lower()
        for word in ("median", "12", "fields", "cell", "overlap", "248", "128")
    )
    for name, key in (("error-caption", "chart_notes"), ("takeaways", "takeaways")):
        expected = " ".join(manifest["poster_text"][key])
        assert " ".join(by_name[name].text.split()) == " ".join(expected.split()), name
        assert all(
            run.font.size.pt == 26
            for paragraph in by_name[name].text_frame.paragraphs
            for run in paragraph.runs
            if run.text
        )
        assert _text_height(by_name[name]) <= by_name[name].height / 36000 + 0.1, name
    assert all(
        run.font.size.pt == 34
        for paragraph in by_name["method-details"].text_frame.paragraphs
        for run in paragraph.runs
        if run.text
    )
    _require_box(by_name["error-caption"], (418.037389, 724, 358.587194, 64))
    _require_box(by_name["takeaways"], (802.10325, 753, 282.249194, 37))
    _require_box(by_name["method-details"], (33.9715, 546, 358.587194, 154))
    _require_box(
        by_name["result-clusters"], (412.375389, 240.710528, 364.249194, 196.578917)
    )
    _require_box(by_name["result-spatial"], (805.162417, 232, 346.806889, 214))
    equation = by_name["physics-note-equation"]
    equation_x, equation_y, equation_w, equation_h = _box(equation)
    assert abs(equation_x + equation_w / 2 - (28.309524 + 364.249194 / 2)) < 0.1
    assert abs(equation_y - 424) < 0.1 and abs(equation_h - 24) < 0.1
    assert equation_w < 350
    equation_record = json.loads((poster / "figure-evidence.json").read_text())[
        "physics_note_equation"
    ]
    assert equation_record["backend"] == "pdfLaTeX"
    assert equation_record["font"] == "Computer Modern"
    assert equation_record["source_equation_matches_formulation"]
    assert equation_record["nominal_math_font_pt"] >= 22
    for extension, digest in equation_record["outputs"].items():
        assert _digest(poster / f"figures/physics-note-mass.{extension}") == digest
    assert (
        _digest(poster.parents[2] / equation_record["source"])
        == equation_record["formulation_sha256"]
    )
    assert (
        equation.image.blob == (poster / "figures/physics-note-mass.png").read_bytes()
    )
    equation_vector = equation._element.xpath('.//*[local-name()="svgBlip"]')
    assert len(equation_vector) == 1
    relation = equation_vector[0].get(
        "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed"
    )
    assert (
        equation.part.related_part(relation).blob
        == (poster / "figures/physics-note-mass.svg").read_bytes()
    )
    physical_checks = {}
    for model, name, stem in (
        ("sw", "result-clusters", "shallow-water"),
        ("ebm", "result-spatial", "energy-balance"),
    ):
        picture = by_name[name]
        png = poster / "figures" / (stem + ".png")
        svg = poster / "figures" / (stem + ".svg")
        png_payload = png.read_bytes()
        svg_payload = svg.read_bytes()
        assert picture.image.blob == png_payload, name
        nodes = picture._element.xpath('.//*[local-name()="svgBlip"]')
        assert len(nodes) == 1, name
        relation = nodes[0].get(
            "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed"
        )
        assert picture.part.related_part(relation).blob == svg_payload, name
        physical_checks[model] = {
            "png": {
                "path": "figures/" + png.name,
                "sha256": hashlib.sha256(png_payload).hexdigest(),
            },
            "svg": {
                "path": "figures/" + svg.name,
                "sha256": hashlib.sha256(svg_payload).hexdigest(),
            },
        }
    for model, name, x in (
        ("sw", "result-error", 412.375389),
        ("ebm", "result-calibration", 796.44125),
    ):
        picture = by_name[name]
        _require_box(picture, (x, 546, 364.249194, 169.298806))
        assert (
            hashlib.sha256(picture.image.blob).hexdigest()
            == chart_checks[model]["png"]["sha256"]
        )
        assert all(
            abs(value) < 1e-12
            for value in (
                picture.crop_left,
                picture.crop_right,
                picture.crop_top,
                picture.crop_bottom,
            )
        )
        assert abs(picture.rotation) < 1e-9
        assert not picture._element.xpath('.//*[local-name()="svgBlip"]'), name
        pixels = picture.image.size
        effective_dpi = pixels[0] / (picture.width / 36000 / 25.4)
        assert effective_dpi >= 390, (name, effective_dpi)
        chart_checks[model]["native_png_pixels"] = list(pixels)
        chart_checks[model]["native_effective_dpi"] = effective_dpi
    title = by_name["poster-title"]
    assert title.text == profile["identity"]["title"]
    assert by_name["poster-authors"].text == profile["identity"]["author_line"]
    assert by_name["poster-affiliations"].text == profile["identity"]["affiliation"]
    assert presentation.core_properties.author == profile["identity"]["author"]
    title_runs = list(title.text_frame.paragraphs[0].runs)
    assert not any(run.font.underline for run in title_runs)
    assert "Verified Assembly" not in all_text
    assert min(sizes) >= 22
    qr = by_name["github-repository-qr"]
    _require_box(qr, (1089.690472, 716.688889, 71, 71))
    qr_mm = _box(qr)
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    decoded = []
    with pymupdf.open(pdf) as document:
        assert len(document) == 1
        page = document[0]
        assert abs(page.rect.width * 25.4 / 72 - width) < 0.1
        assert abs(page.rect.height * 25.4 / 72 - height) < 0.1
        assert document.metadata["title"] == title.text
        assert document.metadata["author"] == profile["identity"]["author"]
        title_bounds = pymupdf.Rect(
            title.left / 12700,
            title.top / 12700,
            (title.left + title.width) / 12700,
            (title.top + title.height) / 12700,
        )
        title_lines = [
            line
            for block in page.get_text("dict", clip=title_bounds)["blocks"]
            for line in block.get("lines", [])
        ]
        assert len(title_lines) == 1
        assert "".join(span["text"] for span in title_lines[0]["spans"]) == title.text
        title_underlines = [
            path
            for path in page.get_drawings()
            if path["type"] == "s"
            and abs(path["width"] - title_runs[0].font.size.pt * 0.05) < 1e-5
            and title_bounds.x0 <= path["rect"].x0 <= path["rect"].x1 <= title_bounds.x1
            and title_bounds.y0 <= path["rect"].y0 <= path["rect"].y1 <= title_bounds.y1
        ]
        assert not title_underlines
        x, y, w, h = qr_mm
        clip = pymupdf.Rect(
            x * 72 / 25.4, y * 72 / 25.4, (x + w) * 72 / 25.4, (y + h) * 72 / 25.4
        )
        for scale in (1.5, 3):
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
        poster_png = poster / "esm-md-a0-landscape.png"
        printed = page.get_pixmap(dpi=150, alpha=False)
        assert (printed.width, printed.height) == (7022, 4967)
        printed.save(poster_png)
        page.get_pixmap(matrix=pymupdf.Matrix(0.85, 0.85)).save(
            output / "final-poster.png"
        )
        for name, bounds in {
            "performance": (408, 510, 1165, 790),
            "methods": (25, 510, 397, 790),
            "footer": (25, 791, 1165, 839),
            "banner": (25, 76, 1165, 193),
        }.items():
            region = pymupdf.Rect(*[value * 72 / 25.4 for value in bounds])
            page.get_pixmap(matrix=pymupdf.Matrix(1.5, 1.5), clip=region).save(
                output / f"{name}.png"
            )
    report = {
        "id": "fresh_language_poster_structural_checks",
        "passed": True,
        "cohort": manifest["cohort"],
        "input_sha256": input_sha256,
        "input_identity": manifest["input_identity"],
        "manifest_sha256": manifest["manifest_sha256"],
        "profile_sha256": profile_sha256,
        "artifact_sha256": {
            path.name: _digest(path) for path in (pptx, pdf, poster_png)
        },
        "qualified_series": len(manifest["validated_input"]["series"]),
        "qualified_observations": sum(
            len(item["raw_seconds"]) for item in manifest["validated_input"]["series"]
        ),
        "encoding_audit": manifest["loaded_encoding_audit"],
        "charts": chart_checks,
        "unchanged_physical_illustrations": physical_checks,
        "presentation": manifest["presentation"],
        "native_picture_format": "png",
        "poster_text_colour": "000000",
        "canvas_mm": [width, height],
        "slides": 1,
        "native_objects": len(slide.shapes),
        "native_text_frames": len(texts),
        "native_text_runs_black": native_runs,
        "minimum_native_font_pt": min(sizes),
        "title": title.text,
        "native_title_underlined_letters": [],
        "exported_title_lines": len(title_lines),
        "exported_title_underlines": 0,
        "qr_url": profile["poster"]["qr"]["url"],
        "qr_decoded_from_actual_pdf": True,
        "qr_final_pdf_checks": decoded,
        "png_pixels": [7022, 4967],
        "png_dpi": 150,
        "visual_inspection_required": True,
        "desktop_powerpoint_inspected": False,
    }
    (output / "structural-check.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--poster-root", type=Path, default=POSTER)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / ".runtime/poster_update_20261108/final_review",
    )
    args = parser.parse_args()
    print(json.dumps(check(args.output, args.poster_root), indent=2))

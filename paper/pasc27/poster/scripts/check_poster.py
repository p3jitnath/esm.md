"""Check the actual A0 PowerPoint and PDF, including the printed QR code."""

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

from poster_comparison_input import load_display_comparison

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]


def _chart_identity(manifest: dict, model: str, resources: list) -> dict:
    """Check actual chart bytes and labels for the displayed comparison.

    Parameters
    ----------
    manifest : dict
        Validated comparison input with figure paths and render receipts.
    model : str
        Model identifier, either sw or ebm.
    resources : list
        Validated CPU resource records associated with this chart.

    Returns
    -------
    dict
        SVG and PNG identities, chart labels and supplied CPU resources.

    Raises
    ------
    AssertionError
        If artwork differs from its receipt or required labels are missing.
    """
    metadata = manifest["render_metadata"][model]
    chart = manifest["figures"][model]
    identities = {}
    for suffix in ("svg", "png"):
        path = POSTER / chart[suffix]
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        assert any(
            Path(recorded_path).suffix == "." + suffix and recorded_hash == digest
            for recorded_path, recorded_hash in metadata["outputs"].items()
        ), (model, suffix, "Chart bytes differ from the render receipt.")
        identities[suffix] = {"path": chart[suffix], "sha256": digest}
    svg_path = POSTER / chart["svg"]
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
    svg = ET.fromstring(svg_path.read_bytes(), parser=parser)
    labels = []
    for element in svg.iter():
        if element.tag == "{http://www.w3.org/2000/svg}text":
            labels.append("".join(element.itertext()))
        elif element.tag == "{http://www.w3.org/2000/svg}g" and element.get(
            "id", ""
        ).startswith("text_"):
            # Matplotlib path-font exports store each drawable label here.
            labels.extend(
                child.text or "" for child in element if child.tag is ET.Comment
            )
    visible = " ".join(labels)
    assert "ESM.md" in visible, (model, "Missing implementation label.")
    assert not re.search(r"\bassembly\b", visible, re.IGNORECASE), model
    rate_labels = [
        value
        for value in labels
        if re.search(r"updates\s*/\s*s|updates per second", value)
    ]
    assert rate_labels and all("[" in value and "]" in value for value in rate_labels)
    return {
        **identities,
        "visible_chart_text": labels,
        "cpu_resources": resources,
    }


def _accepted_performance() -> tuple[dict, str, dict]:
    """Validate the accepted input and actual chart files before writing outputs.

    Returns
    -------
    manifest : dict
        Accepted campaign, chart and caption records for both models.
    input_sha256 : str
        SHA256 identifier of the supplied performance input.
    charts : dict
        Actual SVG/PNG identities, visible labels and CPU resource records.

    Raises
    ------
    AssertionError
        If acceptance, metric, resource or actual chart checks fail.
    """
    manifest_path = POSTER / "data/accepted-performance-update.json"
    payload = manifest_path.read_bytes()
    manifest = json.loads(payload)
    assert manifest.get("status") == "accepted", "Performance results are pending."
    assert manifest.get("presentation") == "matched_absolute_rates"
    assert manifest.get("cpu_resource_interpretation") == "configured_ceiling"
    assert manifest.get("selected_cpu_cores") == 248
    assert (
        isinstance(manifest.get("cpu_worker_disclosure"), str)
        and manifest["cpu_worker_disclosure"].strip()
    )
    campaigns = manifest["accepted_campaign_ids"]
    assert campaigns and all(isinstance(value, str) and value for value in campaigns)
    for platform in ("cpu", "gpu"):
        source_path = POSTER / manifest["measurement_sources"][platform]
        assert source_path.is_file(), source_path
    charts = {}
    for model in ("sw", "ebm"):
        metadata = manifest["render_metadata"][model]
        assert metadata.get("status") == "accepted"
        assert metadata.get("presentation") == "matched_absolute_rates"
        assert metadata.get("mode") == "matched_rates"
        assert metadata.get("profile") == "poster" and metadata.get("model") == model
        assert metadata.get("point_definition") == "useful_updates / median_seconds"
        assert metadata.get("observed_range_definition") == (
            "minimum and maximum of twelve individual useful-update rates"
        )
        coverage = metadata["comparison_coverage"]
        assert coverage["selected_cpu_core_counts"] == [248]
        assert coverage["matched_conditions"] == 6
        assert coverage["historical_language_conditions"] == 0
        assert len(metadata["paired_summaries"]) == 6
        paired = metadata["paired_input"]
        assert paired.get("status") == "accepted"
        rows = [row for row in paired["paired_records"] if row["model"] == model]
        assert len(rows) == 6
        assert all(
            sum(row["platform"] == platform for row in rows) == 3
            for platform in ("cpu", "gpu")
        )
        for platform in ("cpu", "gpu"):
            shapes = {
                tuple(row["shape"]) for row in rows if row["platform"] == platform
            }
            assert len(shapes) == 3, (model, platform, "Workloads are duplicated.")
        resources = []
        for row in rows:
            assert row["campaign_id"] in campaigns
            assert len(row["paired_samples"]) == 12
            assert all(
                row["qualification"].get(flag) is True
                for flag in (
                    "independent_physics_passed",
                    "exact_outputs_equal",
                    "timed_final_state_checked",
                    "exclusive_node",
                    "quiet_samples",
                )
            )
            if row["platform"] != "cpu":
                continue
            assert row["cpu_cores"] == 248 and row.get("series_kind") == "primary"
            assert isinstance(row.get("run_id"), str) and row["run_id"]
            teams = row["active_workers"]
            owners = row["nonempty_spatial_owners_by_route"]
            for route in ("baseline", "esm_md"):
                team, owner = teams[route], owners[route]
                assert type(team) is int and type(owner) is int
                assert 1 <= owner <= team <= 248
            assert teams["baseline"] == teams["esm_md"], "Paired CPU teams differ."
            resources.append(
                {
                    "shape": row["shape"],
                    "run_id": row["run_id"],
                    "configured_ceiling": 248,
                    "active_workers": teams,
                    "nonempty_spatial_owners_by_route": owners,
                }
            )
        charts[model] = _chart_identity(manifest, model, resources)
    return manifest, hashlib.sha256(payload).hexdigest(), charts


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
    performance, input_sha256, matched_chart_checks = _accepted_performance()
    display = load_display_comparison(POSTER, performance)
    display_input_sha256 = None
    if display is performance:
        chart_checks = matched_chart_checks
    else:
        display_input_sha256 = display["display_comparison_input_sha256"]
        display_path = POSTER / "data/archived-language-comparison-update.json"
        assert (
            display_input_sha256
            == hashlib.sha256(display_path.read_bytes()).hexdigest()
        )
        chart_checks = {
            model: _chart_identity(display, model, []) for model in ("sw", "ebm")
        }
    output.mkdir(parents=True, exist_ok=True)
    pptx = POSTER / "esm-md-a0-landscape.pptx"
    pdf = POSTER / "esm-md-a0-landscape.pdf"
    profile = json.loads((POSTER / "project-profile.json").read_text())
    presentation = Presentation(pptx)
    assert len(presentation.slides) == 1
    width, height = presentation.slide_width / 36000, presentation.slide_height / 36000
    assert abs(width - 1189) < 0.1 and abs(height - 841) < 0.1
    slide = presentation.slides[0]
    assert len(slide.shapes) == 65, len(slide.shapes)
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
    skills = set(re.findall(r"\bmd2fort(?:-gpu)?\b", all_text))
    assert skills == {"md2fort", "md2fort-gpu"}, skills
    assert "md2asm" not in all_text
    by_name = {shape.name: shape for shape in slide.shapes}
    methods = by_name["method-details"]
    assert len(methods.text_frame.paragraphs) == 5
    expected_steps = ("a. Inputs", "b. LLM + skills", "c. Verify/time")
    for index, expected in enumerate(expected_steps, 1):
        assert " ".join(by_name[f"method-step-{index}"].text.split()) == expected
    blue_shapes = {
        "method-details",
        "results-summary",
        "energy-summary",
        "error-caption",
        "takeaways",
        *[f"method-step-{index}" for index in (1, 2, 3)],
        *[f"method-detail-{index}" for index in (1, 2, 3)],
    }
    expected_text = {
        "results-summary": display["poster_text"]["sw_intro"],
        "energy-summary": display["poster_text"]["ebm_intro"],
        "error-caption": display["poster_text"]["caption"]
        + " "
        + display["cpu_worker_disclosure"],
        "takeaways": " ".join(display["poster_text"]["takeaways"]),
    }
    for name, expected in expected_text.items():
        assert " ".join(by_name[name].text.split()) == " ".join(expected.split()), name
    for name in blue_shapes:
        shape = by_name[name]
        runs = [
            run
            for paragraph in shape.text_frame.paragraphs
            for run in paragraph.runs
            if run.text
        ]
        assert runs and all(str(run.font.color.rgb) == "0000FF" for run in runs), name
    for model, name in (("sw", "result-error"), ("ebm", "result-calibration")):
        picture = by_name[name]
        assert (
            hashlib.sha256(picture.image.blob).hexdigest()
            == chart_checks[model]["png"]["sha256"]
        )
        svg_nodes = [
            node
            for node in picture._element.iter()
            if node.tag
            == "{http://schemas.microsoft.com/office/drawing/2016/SVG/main}svgBlip"
        ]
        archived_png = (
            display.get("comparison_class") == "archived_language_controls"
            and display.get("native_picture_format") == "png"
        )
        if archived_png:
            assert not svg_nodes, name
        else:
            assert len(svg_nodes) == 1, name
            relation = svg_nodes[0].get(
                "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed"
            )
            svg_blob = picture.part.related_part(relation).blob
            assert (
                hashlib.sha256(svg_blob).hexdigest()
                == chart_checks[model]["svg"]["sha256"]
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
            "methods": (25, 510, 397, 790),
            "footer": (25, 791, 1165, 839),
            "banner": (25, 76, 1165, 193),
        }.items():
            clip = pymupdf.Rect(*[value * 72 / 25.4 for value in bounds])
            page.get_pixmap(matrix=pymupdf.Matrix(1.5, 1.5), clip=clip).save(
                output / f"{name}.png"
            )
    report = {
        "passed": True,
        "accepted_performance_input_sha256": input_sha256,
        "artifact_sha256": {
            path.name: hashlib.sha256(path.read_bytes()).hexdigest()
            for path in (pptx, pdf, poster_png)
        },
        "performance_presentation": performance["presentation"],
        "cpu_resource_interpretation": performance["cpu_resource_interpretation"],
        "matched_chart_checks": matched_chart_checks,
        "display_presentation": display["presentation"],
        "display_chart_checks": chart_checks,
        "blue_text_frames": sorted(blue_shapes),
        "changed_prose_colour": "0000FF",
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
    if display_input_sha256 is not None:
        report["display_comparison_input_sha256"] = display_input_sha256
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

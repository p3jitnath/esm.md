"""Create editable A0 artwork and export the saved PowerPoint to vector PDF."""

from pathlib import Path
from io import BytesIO
import json, math
import re
from pptx import Presentation
from pptx.util import Mm, Pt
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE, MSO_CONNECTOR, MSO_SHAPE_TYPE
from pptx.enum.text import PP_ALIGN
from pptx.oxml.xmlchemy import OxmlElement
from pptx.opc.package import Part
from pptx.opc.packuri import PackURI
from pptx.opc.constants import RELATIONSHIP_TYPE as RT
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
from reportlab.graphics import renderPDF
from svglib.svglib import svg2rlg
import pymupdf

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]
OUT = POSTER
PROFILE = json.loads((POSTER / "project-profile.json").read_text())
IDENTITY = PROFILE["identity"]
BUILD = ROOT / ".runtime/poster_update_20261108"
FONT = "Open Sans"
TITLE_RUNS = [
    ("ESM.md: From ", False),
    ("M", False),
    ("ark", False),
    ("d", False),
    ("own Physics to Verified, Optimised ", False),
    ("E", False),
    ("arth ", False),
    ("S", False),
    ("ystem ", False),
    ("M", False),
    ("odel Solvers", False),
]
POSTER_TITLE = "".join(value for value, _ in TITLE_RUNS)
REPO_URL = "https://github.com/p3jitnath/esm.md"
# Performance artwork and prose use one accepted fresh cohort.
from poster_comparison_input import load_fresh_comparison

DISPLAY_UPDATE = load_fresh_comparison(OUT)
DISPLAY_PICTURE_KEY = "png"
BUILD.mkdir(parents=True, exist_ok=True)
W, H = 1189, 841
INK = "232830"
DARK = "133844"
BLUE = "8EE8D8"
LIGHT = "D1F9F1"
TEAL = "00BDB6"
for bold, name in [(False, "Regular"), (True, "Bold")]:
    pdfmetrics.registerFont(
        TTFont(
            "OpenSans-Bold" if bold else "OpenSans",
            OUT / "assets" / f"OpenSans-{name}.ttf",
        )
    )
TEMPLATE = OUT / "assets/templates/template-a3-landscape.pptx"
prs = Presentation(TEMPLATE)
prs.slide_width = Mm(W)
prs.slide_height = Mm(H)
prs.core_properties.title = POSTER_TITLE
prs.core_properties.author = IDENTITY["author"]
slide = prs.slides[0]
original_shapes = list(slide.shapes)
used = set()
reused_template_shapes = []


def reuse(kind, name, x, y, w, h):
    """Reuse a native template object and move it to its requested frame.

    Parameters
    ----------
    kind : MSO_SHAPE_TYPE
        Required PowerPoint object type.
    name : str
        Stable name for the resulting object.
    x, y, w, h : float
        Left, top, width and height in millimetres.

    Returns
    -------
    Shape or None
        The reused object, or None when a new object must be created.

    Notes
    -----
    Mutates the slide and the set of consumed template objects.
    """
    role_map = {
        "poster-author": "poster-authors",
        "poster-affiliation": "poster-affiliations",
        "sponsor-label": "sponsors-label",
        "skill-heading": "section-methods",
        "summary-heading": "section-summary",
        "references": "vancouver-references",
    }
    source_name = role_map.get(name, name)
    matches = [
        a for a in original_shapes if a.shape_id not in used and a.shape_type == kind
    ]
    exact = next((a for a in matches if a.name == source_name), None)
    a = exact if exact is not None else (matches[0] if matches else None)
    if a is None:
        return None
    used.add(a.shape_id)
    reused_template_shapes.append(
        {"id": a.shape_id, "original_name": a.name, "final_name": name}
    )
    a.left = Mm(x)
    a.top = Mm(y)
    a.width = Mm(w)
    a.height = Mm(h)
    a.name = name
    parent = a._element.getparent()
    parent.remove(a._element)
    parent.append(a._element)
    if a.has_text_frame:
        a.text_frame.clear()
    return a


rectangles = []
text_records = []


def colour(s):
    """Convert a hexadecimal colour to a PowerPoint RGB value.

    Parameters
    ----------
    s : str
        Six hexadecimal RGB digits, with an optional leading hash.

    Returns
    -------
    RGBColor
        The corresponding colour.
    """
    return RGBColor.from_string(s.lstrip("#"))


def rect(name, x, y, w, h, fill=LIGHT, line=None):
    """Add an editable rectangle using poster coordinates.

    Parameters
    ----------
    name : str
        Stable object name.
    x, y, w, h : float
        Left, top, width and height in millimetres.
    fill : str
        Hexadecimal RGB fill colour.
    line : str or None
        Hexadecimal border colour, or None for no border.

    Returns
    -------
    Shape
        Native rectangle added to the slide.

    Notes
    -----
    Records its frame for structural review.
    """
    a = reuse(MSO_SHAPE_TYPE.AUTO_SHAPE, name, x, y, w, h)
    if a is None:
        a = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Mm(x), Mm(y), Mm(w), Mm(h))
    a.name = name
    a.fill.solid()
    a.fill.fore_color.rgb = colour(fill)
    if line:
        a.line.color.rgb = colour(line)
        a.line.width = Pt(1.2)
    else:
        a.line.fill.background()
    rectangles.append((name, x, y, w, h))
    return a


def line(name, x1, y1, x2, y2, c=TEAL, width=1):
    """Add an editable straight connector.

    Parameters
    ----------
    name : str
        Stable object name.
    x1, y1, x2, y2 : float
        Endpoint coordinates in millimetres.
    c : str
        Hexadecimal RGB colour.
    width : float
        Line width in points.

    Returns
    -------
    Shape
        Native connector added to the slide.
    """
    a = slide.shapes.add_connector(
        MSO_CONNECTOR.STRAIGHT, Mm(x1), Mm(y1), Mm(x2), Mm(y2)
    )
    a.name = name
    a.line.color.rgb = colour(c)
    a.line.width = Pt(width)
    return a


def wrapped(t, width, size, bold=False):
    """Wrap text using the actual approved font metrics.

    Parameters
    ----------
    t : str
        Text to wrap.
    width, size : float
        Available width and font size in points.
    bold : bool
        Whether to use the bold font metrics.

    Returns
    -------
    str
        Text with explicit line breaks.
    """
    out = []
    for raw in str(t).split("\n"):
        words = re.split(r"[^\S\u00a0]+", raw.strip())
        current = ""
        for word in words:
            candidate = (current + " " + word).strip()
            if (
                current
                and pdfmetrics.stringWidth(
                    candidate, "OpenSans-Bold" if bold else "OpenSans", size
                )
                > width
            ):
                out.append(current)
                current = word
            else:
                current = candidate
        out.append(current)
    return "\n".join(out)


def text(
    name,
    t,
    x,
    y,
    w,
    h,
    size=28,
    bold=False,
    c=INK,
    bullets=False,
    align=PP_ALIGN.LEFT,
    bullet_indent=0.7,
    paragraph_gap_pt=None,
):
    """Add an editable text frame with checked line height.

    Parameters
    ----------
    name : str
        Stable object name.
    t : str or list of str
        Text or separate paragraphs.
    x, y, w, h : float
        Frame coordinates and dimensions in millimetres.
    size : float
        Font size in points.
    bold, bullets : bool
        Whether to use bold type or native bullet marks.
    c : str
        Hexadecimal RGB text colour.
    align : PP_ALIGN
        Native paragraph alignment.
    bullet_indent : float
        Font-size multiple reserved for wrapping a native bullet paragraph.
    paragraph_gap_pt : float or None
        Space after each paragraph in points. None retains the original spacing.

    Returns
    -------
    Shape
        The editable text object.

    Raises
    ------
    ValueError
        If measured line height exceeds the requested frame.

    Notes
    -----
    Appends the exact text and geometry to the review record.
    """
    a = reuse(MSO_SHAPE_TYPE.TEXT_BOX, name, x, y, w, h)
    if a is None:
        a = slide.shapes.add_textbox(Mm(x), Mm(y), Mm(w), Mm(h))
    a.name = name
    tf = a.text_frame
    tf.clear()
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    tf.word_wrap = False
    items = t if isinstance(t, list) else [t]
    line_count = 0
    paragraph_gap = 5 if paragraph_gap_pt is None else paragraph_gap_pt
    for i, item in enumerate(items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        value = wrapped(
            item, (w * 72 / 25.4) - (size * bullet_indent if bullets else 0), size, bold
        )
        p.text = value
        p.alignment = align
        p.space_before = Pt(0)
        p.space_after = Pt(paragraph_gap if bullets else 0)
        p.line_spacing = 1.12
        if bullets:
            pp = p._p.get_or_add_pPr()
            pp.set("marL", str(int(Pt(size * 0.65))))
            pp.set("indent", str(-int(Pt(size * 0.65))))
            b = OxmlElement("a:buChar")
            b.set("char", "•")
            pp.append(b)
        for run in p.runs:
            run.font.name = FONT
            run.font.size = Pt(size)
            run.font.bold = bold
            run.font.color.rgb = colour(c)
        line_count += len(value.split("\n"))
    gaps = len(items) if paragraph_gap_pt is None else max(0, len(items) - 1)
    required = (line_count * size * 1.12 + gaps * paragraph_gap) * 25.4 / 72
    if required > h + 2:
        raise ValueError((name, "text exceeds frame", required, h))
    text_records.append(
        {
            "name": name,
            "mm": [x, y, w, h],
            "font_pt": size,
            "text": str(t),
            "lines": line_count,
            "alignment": str(align),
        }
    )
    return a


svg_index = 0


def image(name, path, x, y, w, h):
    """Embed proportionate artwork with an SVG and PNG fallback.

    Parameters
    ----------
    name : str
        Stable object name.
    path : pathlib.Path or str
        SVG or raster asset path. An SVG also requires its PNG fallback.
    x, y, w, h : float
        Available frame in millimetres.

    Returns
    -------
    Shape
        Native PowerPoint picture with preserved proportions.

    Raises
    ------
    FileNotFoundError
        If a required asset or fallback is missing.
    """
    global svg_index
    path = Path(path)
    fallback = path.with_suffix(".png") if path.suffix == ".svg" else path
    from PIL import Image

    iw, ih = Image.open(fallback).size
    scale = min(w / iw, h / ih)
    dw, dh = iw * scale, ih * scale
    a = slide.shapes.add_picture(
        str(fallback),
        Mm(x + (w - dw) / 2),
        Mm(y + (h - dh) / 2),
        width=Mm(dw),
        height=Mm(dh),
    )
    a.name = name
    if path.suffix == ".svg":
        svg_index += 1
        part = Part(
            PackURI(f"/ppt/media/poster-vector-{svg_index}.svg"),
            "image/svg+xml",
            slide.part.package,
            path.read_bytes(),
        )
        rid = slide.part.relate_to(part, RT.IMAGE)
        blip = a._element.blipFill.blip
        extlst = OxmlElement("a:extLst")
        ext = OxmlElement("a:ext")
        ext.set("uri", "{96DAC541-7B7A-43D3-8B79-37D633B846F1}")
        from lxml import etree

        node = etree.Element(
            "{http://schemas.microsoft.com/office/drawing/2016/SVG/main}svgBlip"
        )
        node.set(
            "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed",
            rid,
        )
        ext.append(node)
        extlst.append(ext)
        blip.append(extlst)
    return a


def method_icon(name, paths, x, y):
    # Small vector symbols show the role of each workflow stage.
    """Build and embed one approved vector workflow symbol.

    Parameters
    ----------
    name : str
        Stable symbol and asset name.
    paths : str
        SVG path markup in the approved 72 by 48 coordinate frame.
    x, y : float
        Upper-left poster position in millimetres.

    Returns
    -------
    Shape
        Embedded vector symbol and its raster fallback.
    """
    asset = OUT / "assets" / ("method-" + name + ".svg")
    asset.write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="72" height="48" viewBox="0 0 72 48"><g fill="none" stroke="#133844" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">'
        + paths
        + "</g></svg>"
    )
    drawing = svg2rlg(str(asset))
    icon_pdf = BytesIO()
    renderPDF.drawToFile(drawing, icon_pdf)
    with pymupdf.open(stream=icon_pdf.getvalue(), filetype="pdf") as document:
        document[0].get_pixmap(matrix=pymupdf.Matrix(4, 4), alpha=True).save(
            str(asset.with_suffix(".png"))
        )
    return image("method-symbol-" + name, asset, x, y, 45, 30)


# Fill the supplied landscape template at A0, retaining its three columns.
scale = W / 420
a, b, c = 10 * scale, 145.6666667 * scale, 281.3333333 * scale
cw = 128.6666667 * scale
from PIL import Image

cambridge_size = Image.open(OUT / "assets/cambridge-logo.png").size
cambridge_width = 50 * cambridge_size[0] / cambridge_size[1]
image(
    "University of Cambridge",
    OUT / "assets/cambridge-logo.svg",
    a,
    18,
    cambridge_width,
    50,
)
epsrc_asset = OUT / "assets/epsrc-horizontal.png"
epsrc_size = Image.open(epsrc_asset).size
epsrc_width = 50 * epsrc_size[0] / epsrc_size[1]
epsrc_left = W - a - epsrc_width
label_width = pdfmetrics.stringWidth("Sponsors:", "OpenSans-Bold", 34) * 25.4 / 72
text(
    "sponsors-label",
    "Sponsors:",
    epsrc_left - 8 - label_width,
    32,
    label_width + 2,
    18,
    34,
    bold=True,
)
image("UKRI EPSRC", epsrc_asset, epsrc_left, 18, epsrc_width, 50)
# A padded title band keeps the text clear of every edge.
band_width = 400 * scale
band = rect("title-band", a, 79, band_width, 111, BLUE)
band.fill.gradient()
band.fill.gradient_angle = 0
for stop, pos, shade in zip(
    band.fill.gradient_stops,
    PROFILE["poster"]["banner"]["background_gradient_stops"],
    (BLUE, "FFFFFF"),
):
    stop.position = pos
    stop.color.rgb = colour(shade)
# Traced paisley outlines use uniform transparency over the Cambridge banner.
graphic = image(
    "banner-paisley-outline", OUT / "assets/paisley-banner.svg", 480, 79, 674, 111
)
graphic.left = Mm(480)
graphic.top = Mm(79)
graphic.width = Mm(674)
graphic.height = Mm(111)
inset = 24
poster_title = text(
    "poster-title",
    POSTER_TITLE,
    a + inset,
    96,
    band_width - 2 * inset,
    36,
    72,
    bold=True,
    c=DARK,
)
title_paragraph = poster_title.text_frame.paragraphs[0]
title_paragraph.clear()
for value, underlined in TITLE_RUNS:
    run = title_paragraph.add_run()
    run.text = value
    run.font.name = FONT
    run.font.size = Pt(72)
    run.font.bold = True
    run.font.color.rgb = colour(DARK)
    run.font.underline = underlined
text(
    "poster-subtitle",
    "A framework for ESM development directly from physics formulations",
    a + inset,
    133,
    band_width - 2 * inset,
    18,
    38,
    c=DARK,
)
text(
    "poster-authors",
    IDENTITY["author_line"],
    a + inset,
    152,
    band_width - 2 * inset,
    14,
    30,
    bold=True,
    c=DARK,
)
text(
    "poster-affiliations",
    IDENTITY["affiliation"],
    a + inset,
    169,
    band_width - 2 * inset,
    12,
    24,
    c=DARK,
)


def heading(name, title, x, y, w=cw, c=DARK):
    # Centre the visible letters with 4 mm above and below and 10 mm at each side.
    """Add an editable section heading with measured padding.

    Parameters
    ----------
    name, title : str
        Stable object name and displayed heading.
    x, y, w : float
        Left, top and width in millimetres.
    c : str
        Hexadecimal RGB colour for the heading text.

    Returns
    -------
    None
        Adds the background and text to the current slide.
    """
    size = 39
    padding = 4
    inset = 10
    face = pymupdf.Font(fontfile=str(OUT / "assets/OpenSans-Bold.ttf"))
    height = (face.ascender - face.descender) * size * 25.4 / 72 + 2 * padding
    offset = padding + (face.ascender - 0.86) * size * 25.4 / 72
    rect(name + "-background", x, y, w, height, LIGHT)
    text(
        name,
        title,
        x + inset,
        y + offset,
        w - 2 * inset,
        height - offset,
        size,
        bold=True,
        c=c,
    )


heading("section-motivation", "1  Motivation", a, 199)
heading("section-results", "3.1  Shallow-Water Behaviour", b, 199)
heading("physical-energy", "Energy Balance [1,2]", c, 199)
motivation_details = text(
    "motivation-context",
    [
        "ESMs link the atmosphere, ocean and land to study climate and environmental change.",
        "Developing ESMs requires clear physical assumptions, reliable numerical methods and efficient code for large computers.",
        "We test whether an LLM can turn readable physics formulations into fast, verified Fortran.",
        "We compare SW and EBM models with tuned and vanilla Fortran, Julia and compiled Python on CPUs and GPUs.",
    ],
    a + 5.662,
    237,
    cw - 5.662,
    130,
    34,
    bullets=True,
    c="000000",
    bullet_indent=0.65,
    paragraph_gap_pt=6,
)
rect("motivation-image-slot", a, 370, cw, 132, "F3FBF9", TEAL)
text(
    "physics-note-name",
    "dam_break.md",
    a + 7,
    377,
    cw - 14,
    15,
    31,
    bold=True,
    c=DARK,
    align=PP_ALIGN.CENTER,
)
text(
    "physics-note-standard",
    "Writing Convention | ASD-STE100-CONV",
    a + 7,
    393,
    cw - 14,
    12,
    26,
    bold=True,
    c=DARK,
)
text(
    "physics-note-symbols",
    "Depth h [m], velocities u and v [m/s], positions x and y [m], and time t [s].",
    a + 7,
    407,
    cw - 14,
    16,
    26,
)
physics_equation = image(
    "physics-note-equation",
    OUT / "figures/physics-note-mass.svg",
    a + 7,
    424,
    cw - 14,
    24,
)
text(
    "physics-note-meaning",
    "The depth changes when water flows into or out of a small region.",
    a + 7,
    451,
    cw - 14,
    12,
    26,
)
text(
    "physics-note-example",
    "A dam-break example starts with depth 2 m in the left half, depth 1 m in the right half, and zero velocity everywhere.",
    a + 7,
    465,
    cw - 14,
    22,
    26,
)
text(
    "physics-note-boundaries",
    "The 1 m × 1 m square has periodic boundaries that join opposite sides.",
    a + 7,
    489,
    cw - 14,
    12,
    26,
)
image("result-clusters", OUT / "figures/shallow-water.svg", b, 232, cw, 214)
text(
    "cluster-caption",
    "A separate periodic dam-break test develops moving waves at 0.03125 s while preserving mass. The surface and depth profile are verified. The dashed curve shows the initial state.",
    b + 2 * scale,
    455,
    cw - 2 * scale,
    47,
    30,
    bullets=True,
)
image("result-spatial", OUT / "figures/energy-balance.svg", c, 232, cw, 214)
meta = json.loads((OUT / "figure-evidence.json").read_text())
text(
    "spatial-caption",
    f"Sun’s radiation warms the tropics more than the poles. Heat transport reduces the contrast. Dashed and solid lines show initial and evolved temperatures. The globe shows latitude-band results after {meta['ebm_time_years']:.1f} years with country outlines for context.",
    c + 2 * scale,
    455,
    cw - 2 * scale,
    50,
    30,
    bullets=True,
)
heading("section-methods", "2  Methods & Skill Creation", a, 514)
heading("results-comparison", "3.2 Shallow-Water Model", b, 514, c="000000")
heading("results-diagnostics", "3.3 Energy-Balance Model", c, 514, c="000000")


text(
    "method-details",
    [
        "We developed md2fort and md2fort-gpu from two verified physics models and their numerical contracts.",
        "A contract records the grid, time update, data layout and calculation order. Every version follows these rules.",
        "The LLM uses the skills to write Fortran and CUDA Fortran. Compilers build these solvers. The PTX baseline is assembled.",
        "We check independent physics and every output byte before timing complete updates on quiet, exclusive nodes.",
        "Only measured gains enter the skills. We reuse storage, avoid repeated work and update several cells together.",
    ],
    a + 5.662,
    546,
    cw - 5.662,
    154,
    34,
    bullets=True,
    c="000000",
    bullet_indent=0.65,
    paragraph_gap_pt=12,
)
workflow = [
    (
        "a.  Inputs",
        "Markdown, contract\nand verified context",
        "physics",
        '<circle cx="54" cy="8" r="4" stroke="#00BDB6"/><path d="M54 1v1M54 14v2M47 8h1M60 8h1M49 3l1 1M58 12l1 1M49 13l1-1M58 4l1-1" stroke="#00BDB6"/><path d="M7 26c7-8 12-8 19 0s12 8 19 0 12-8 19 0M7 33c7-8 12-8 19 0s12 8 19 0 12-8 19 0M7 40c7-8 12-8 19 0s12 8 19 0 12-8 19 0"/>',
    ),
    (
        "b.  LLM + skills",
        "Fortran/CUDA\nsource candidates",
        "assembly",
        '<rect x="17" y="10" width="38" height="28" rx="3"/><path d="M24 4v6M32 4v6M40 4v6M48 4v6M24 38v6M32 38v6M40 38v6M48 38v6M11 17h6M11 24h6M11 31h6M55 17h6M55 24h6M55 31h6"/><path d="M29 19l-5 5 5 5M43 19l5 5-5 5M38 17l-4 14" stroke="#00BDB6"/>',
    ),
    (
        "c.  Verify/time",
        "Physics and bytes\ninspect, time, select",
        "verify",
        '<path d="M3 38V10M3 38h40"/><path d="M6 31C12 31 11 15 17 15S25 31 37 27M9 27C15 27 14 11 20 11S28 27 40 23M12 23C18 23 17 7 23 7S31 23 43 19" stroke="#00BDB6"/><path d="M6 31l6-8M11.5 23l6-8M17 15l6-8M24.25 22.5l6-8M37 27l6-8"/><circle cx="60" cy="26" r="11"/><path d="M53 26l5 5 9-12" stroke="#00BDB6" stroke-width="3"/>',
    ),
]
for i, (title, detail, symbol, paths) in enumerate(workflow):
    x = a + i * (38.222222 * scale + 7 * scale)
    node_width = 38.222222 * scale
    rect("method-node-" + str(i + 1), x, 708, node_width, 78, "F3FBF9", TEAL)
    text(
        "method-step-" + str(i + 1),
        title,
        x + 6,
        713,
        node_width - 12,
        16,
        31,
        bold=True,
        c="000000",
    )
    method_icon(symbol, paths, x + (node_width - 45) / 2, 731)
    text(
        "method-detail-" + str(i + 1),
        detail,
        x + 6,
        763,
        node_width - 12,
        23,
        26,
        c="000000",
        bullets=True,
    )
    if i < 2:
        arrow = line(
            "method-link-" + str(i),
            x + node_width + 3,
            747,
            x + 45.222222 * scale - 3,
            747,
            DARK,
            2.5,
        )
        end = OxmlElement("a:tailEnd")
        end.set("type", "triangle")
        end.set("w", "med")
        end.set("len", "med")
        arrow._element.spPr.get_or_add_ln().append(end)
shallow_water_comparison = image(
    "result-error",
    OUT / DISPLAY_UPDATE["figures"]["sw"][DISPLAY_PICTURE_KEY],
    b,
    546,
    cw,
    170,
)
shallow_water_comparison.top = Mm(546)
energy_balance_comparison = image(
    "result-calibration",
    OUT / DISPLAY_UPDATE["figures"]["ebm"][DISPLAY_PICTURE_KEY],
    c,
    546,
    cw,
    170,
)
energy_balance_comparison.top = Mm(546)
text(
    "error-caption",
    DISPLAY_UPDATE["poster_text"]["chart_notes"],
    b + 2 * scale,
    724,
    cw - 2 * scale,
    64,
    26,
    bullets=True,
    c="000000",
    paragraph_gap_pt=3,
)
summary_top = 723
heading("section-summary", "4  Summary", c, summary_top, cw - 72)
text(
    "takeaways",
    DISPLAY_UPDATE["poster_text"]["takeaways"],
    c + 2 * scale,
    753,
    cw - 82,
    37,
    26,
    bullets=True,
    c="000000",
    paragraph_gap_pt=3,
)
# High error correction protects the central logo and the four-module white border.
import qrcode
from qrcode.image.svg import SvgPathFillImage
import numpy as np
import zxingcpp

qr = qrcode.QRCode(
    error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=16, border=4
)
qr.add_data(REPO_URL)
qr.make(fit=True)
from lxml import etree
from copy import deepcopy

qr_buffer = BytesIO()
qr.make_image(image_factory=SvgPathFillImage).save(qr_buffer)
qr_svg = etree.fromstring(qr_buffer.getvalue())
svg_namespace = "{http://www.w3.org/2000/svg}"
qr_units = float(qr_svg.get("viewBox").split()[2])
module_units = qr_units / (qr.modules_count + 2 * qr.border)
pad_units = 11 * module_units
pad_origin = (qr_units - pad_units) / 2
etree.SubElement(
    qr_svg,
    svg_namespace + "rect",
    x=str(pad_origin),
    y=str(pad_origin),
    width=str(pad_units),
    height=str(pad_units),
    fill="white",
)
logo = etree.parse(str(OUT / "assets/github-invertocat.svg")).getroot()
lx, ly, lw, lh = map(float, logo.get("viewBox").split())
logo_scale = 10 * module_units / max(lw, lh)
logo_group = etree.SubElement(
    qr_svg,
    svg_namespace + "g",
    transform=f"translate({(qr_units-lw*logo_scale)/2-lx*logo_scale},{(qr_units-lh*logo_scale)/2-ly*logo_scale}) scale({logo_scale})",
)
for child in logo:
    logo_group.append(deepcopy(child))
qr_path = OUT / "assets/github-qr.svg"
qr_path.write_bytes(etree.tostring(qr_svg, xml_declaration=True, encoding="UTF-8"))
qr_drawing = svg2rlg(str(qr_path))
qr_pdf = BytesIO()
renderPDF.drawToFile(qr_drawing, qr_pdf)
with pymupdf.open(stream=qr_pdf.getvalue(), filetype="pdf") as document:
    document[0].get_pixmap(matrix=pymupdf.Matrix(4, 4), alpha=False).save(
        str(qr_path.with_suffix(".png"))
    )
qr_preview = Image.open(qr_path.with_suffix(".png")).convert("RGB")
assert [item.text for item in zxingcpp.read_barcodes(np.asarray(qr_preview))] == [
    REPO_URL
]
# Align the visible black pattern, keeping its white scan border above the box.
qr_size = 71
qr_white_border = qr_size * qr.border / (qr.modules_count + 2 * qr.border)
qr_box = [c + cw - qr_size, summary_top - qr_white_border, qr_size, qr_size]
qr_shape = image("github-repository-qr", qr_path, *qr_box)
qr_shape.click_action.hyperlink.address = REPO_URL
line("references-divider", a, 792, a + 400 * scale, 792, "A6BFBE", 1)
footer_split = 608
ack_left = footer_split + 14
reference_width = footer_split - 10 - a
ack_width = 368 * scale - 10 - ack_left
text("references-heading", "References", a, 797, reference_width, 9, 23, bold=True)
line("footer-section-separator", footer_split, 795, footer_split, 836, INK, 1.5)
text(
    "acknowledgements-heading",
    "Acknowledgements",
    ack_left,
    797,
    ack_width,
    9,
    23,
    bold=True,
)
text(
    "footer-acknowledgement",
    "We thank OpenAI for access to GPT 6.1 Sol through the ChatGPT for Academic Researchers programme.",
    ack_left,
    808,
    ack_width,
    27,
    22,
)
reference_rows = [
    (
        "1. Budyko MI. The effect of solar radiation variations on the climate of the Earth. Tellus. 1969. 21(5), 611–619.",
        "https://doi.org/10.1111/j.2153-3490.1969.tb00466.x",
    ),
    (
        "2. Sellers WD. A Global Climatic Model Based on the Energy Balance of the Earth-Atmosphere System. J Appl Meteorol. 1969. 8(3), 392–400.",
        "https://doi.org/10.1175/1520-0450(1969)008%3C0392%3AAGCMBO%3E2.0.CO%3B2",
    ),
]
text(
    "vancouver-references",
    "\n".join(citation for citation, url in reference_rows),
    a,
    808,
    reference_width,
    27,
    22,
)
pasc_asset = OUT / "assets/pasc27.png"
pasc_size = Image.open(pasc_asset).size
pasc_height = 40
pasc_width = pasc_height * pasc_size[0] / pasc_size[1]
pasc_shape = image(
    "conference-logo", pasc_asset, W - a - pasc_width, 795, pasc_width, pasc_height
)
# Notes bind the benchmark scope separately from the physical illustrations.
slide.notes_slide.notes_text_frame.text = (
    "The performance figures and Summary use only accepted fresh cohort "
    + DISPLAY_UPDATE["cohort"]
    + ". Compact input SHA256 "
    + DISPLAY_UPDATE["input_sha256"]
    + ". The cohort has 96 route and workload conditions, 1,152 accepted elapsed "
    "times, 1,000 complete steps and eight routes. Points divide useful updates "
    "by median elapsed time. Lines show the observed minimum and maximum of "
    "twelve individual rates. CPU uses a 248-core budget, capped at 128 workers "
    "for the 128-band EBM. GPU uses one GH200 device. The independent encoding "
    "audit and source acceptance limits are retained with the compact input. "
    "Frozen benchmark banks use SW MIXED and EBM CLIMATE states. The separate "
    "periodic dam-break and climate illustration inputs remain bound by "
    "figure-evidence.json and do not supply benchmark timing observations. "
    "md2fort and md2fort-gpu guide Fortran and CUDA Fortran candidates, which "
    "are compiled. Independent physics and complete byte checks precede "
    "comparative timing. The PTX "
    "baseline uses its separate assembly route. The accepted current points "
    "supply both figures and the Summary."
)
for a in original_shapes:
    if a.shape_id not in used:
        a._element.getparent().remove(a._element)
path = OUT / "esm-md-a0-landscape.pptx"
# Apply black to native text without changing artwork colours.
for shape in slide.shapes:
    if shape.has_text_frame:
        for paragraph in shape.text_frame.paragraphs:
            paragraph.font.color.rgb = colour("000000")
            for run in paragraph.runs:
                run.font.color.rgb = colour("000000")
prs.save(path)
(BUILD / "layout.json").write_text(
    json.dumps(
        {
            "canvas_mm": [W, H],
            "native_text": text_records,
            "rectangles": rectangles,
            "performance_presentation": DISPLAY_UPDATE["presentation"],
            "performance_sources": DISPLAY_UPDATE["figures"],
        },
        indent=2,
    )
    + "\n"
)
print("PPTX created", path, flush=True)
# Export the saved native PowerPoint objects, including their embedded SVGs.
saved = Presentation(path)
page_w = saved.slide_width / 12700
page_h = saved.slide_height / 12700
pdfpath = OUT / "esm-md-a0-landscape.pdf"
pdf = canvas.Canvas(str(pdfpath), pagesize=(page_w, page_h), pageCompression=1)
pdf.setTitle(POSTER_TITLE)
pdf.setAuthor(IDENTITY["author"])
from pptx.enum.dml import MSO_FILL_TYPE

for sh in saved.slides[0].shapes:
    x, y, w, h = [v / 12700 for v in (sh.left, sh.top, sh.width, sh.height)]
    if sh.shape_type == MSO_SHAPE_TYPE.PICTURE:
        nodes = sh._element.xpath('.//*[local-name()="svgBlip"]')
        if nodes:
            rid = nodes[0].get(
                "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed"
            )
            svg = sh.part.related_part(rid).blob
            drawing = svg2rlg(BytesIO(svg))
            pdf.saveState()
            clip = pdf.beginPath()
            clip.rect(x, page_h - y - h, w, h)
            pdf.clipPath(clip, stroke=0, fill=0)
            pdf.translate(x, page_h - y - h)
            pdf.scale(w / drawing.width, h / drawing.height)
            renderPDF.draw(drawing, pdf, 0, 0)
            pdf.restoreState()
        else:
            pdf.drawImage(
                ImageReader(BytesIO(sh.image.blob)),
                x,
                page_h - y - h,
                width=w,
                height=h,
                mask="auto",
            )
        address = sh.click_action.hyperlink.address
        if address:
            pdf.linkURL(
                address, (x, page_h - y - h, x + w, page_h - y), relative=0, thickness=0
            )
        continue
    if sh.shape_type == MSO_SHAPE_TYPE.LINE:
        pdf.saveState()
        alpha = sh._element.xpath(".//a:ln/a:solidFill/a:srgbClr/a:alpha")
        if alpha:
            pdf.setStrokeAlpha(int(alpha[0].get("val")) / 100000)
        pdf.setStrokeColorRGB(*[c / 255 for c in sh.line.color.rgb])
        pdf.setLineWidth(sh.line.width.pt if sh.line.width else 1)
        pdf.line(
            sh.begin_x / 12700,
            page_h - sh.begin_y / 12700,
            sh.end_x / 12700,
            page_h - sh.end_y / 12700,
        )
        if sh._element.xpath('.//a:ln/a:tailEnd[@type="triangle"]'):
            tip_x, tip_y = sh.end_x / 12700, page_h - sh.end_y / 12700
            angle = math.atan2(-(sh.end_y - sh.begin_y), sh.end_x - sh.begin_x)
            length = 3 * sh.line.width.pt
            base_x, base_y = tip_x - length * math.cos(
                angle
            ), tip_y - length * math.sin(angle)
            head = pdf.beginPath()
            head.moveTo(tip_x, tip_y)
            head.lineTo(
                base_x - length * 0.6 * math.sin(angle),
                base_y + length * 0.6 * math.cos(angle),
            )
            head.lineTo(
                base_x + length * 0.6 * math.sin(angle),
                base_y - length * 0.6 * math.cos(angle),
            )
            head.close()
            pdf.setFillColorRGB(*[c / 255 for c in sh.line.color.rgb])
            pdf.drawPath(head, fill=1, stroke=0)
        pdf.restoreState()
        continue
    if sh.shape_type == MSO_SHAPE_TYPE.AUTO_SHAPE:
        fill = sh.fill.type == MSO_FILL_TYPE.SOLID
        stroke = sh.line.fill.type == MSO_FILL_TYPE.SOLID
        if fill:
            pdf.setFillColorRGB(*[c / 255 for c in sh.fill.fore_color.rgb])
        if stroke:
            pdf.setStrokeColorRGB(*[c / 255 for c in sh.line.color.rgb])
            pdf.setLineWidth(sh.line.width.pt if sh.line.width else 1)
        if sh.fill.type == MSO_FILL_TYPE.GRADIENT:
            # Read the native PowerPoint gradient and preserve it as vector PDF shading.
            assert sh.fill.gradient_angle == 0
            from reportlab.lib.colors import Color

            pdf.saveState()
            clip = pdf.beginPath()
            clip.rect(x, page_h - y - h, w, h)
            pdf.clipPath(clip, stroke=0, fill=0)
            stops = list(sh.fill.gradient_stops)
            shades = [Color(*[v / 255 for v in stop.color.rgb]) for stop in stops]
            pdf.linearGradient(
                x,
                page_h - y - h,
                x + w,
                page_h - y - h,
                shades,
                [v.position for v in stops],
            )
            pdf.restoreState()
        else:
            pdf.rect(x, page_h - y - h, w, h, fill=int(fill), stroke=int(stroke))
    if sh.has_text_frame:
        ypos = page_h - y
        for p in sh.text_frame.paragraphs:
            if not p.text:
                continue
            run = p.runs[0]
            font = run.font
            size = font.size.pt if font.size else 28
            bold = bool(font.bold)
            family = "OpenSans-Bold" if bold else "OpenSans"
            pdf.setFont(family, size)
            pdf.setFillColorRGB(*[v / 255 for v in font.color.rgb])
            bullet = bool(p._p.xpath("./a:pPr/a:buChar"))
            for j, tline in enumerate(p.text.splitlines()):
                baseline = ypos - size * 0.86
                indent = size * 0.65 if bullet else 0
                if bullet and j == 0:
                    pdf.drawString(x, baseline, "•")
                line_x = (
                    x + (w - pdfmetrics.stringWidth(tline, family, size)) / 2
                    if p.alignment == PP_ALIGN.CENTER
                    else x + indent
                )
                pdf.drawString(line_x, baseline, tline)
                # Preserve native title underlines in the saved-slide export.
                if sh.name == "poster-title":
                    prefix = ""
                    for title_run in p.runs:
                        if title_run.font.underline:
                            start = line_x + pdfmetrics.stringWidth(
                                prefix, family, size
                            )
                            end = start + pdfmetrics.stringWidth(
                                title_run.text, family, size
                            )
                            pdf.setStrokeColorRGB(*[v / 255 for v in font.color.rgb])
                            pdf.setLineWidth(size * 0.05)
                            pdf.line(
                                start, baseline - size * 0.1, end, baseline - size * 0.1
                            )
                        prefix += title_run.text
                # Keep each native reference URL clickable in the PDF export.
                for linked_run in p.runs:
                    address = linked_run.hyperlink.address
                    label = address.removeprefix("https://") if address else None
                    if label and label in tline:
                        link_x = line_x + pdfmetrics.stringWidth(
                            tline.split(label, 1)[0], family, size
                        )
                        link_width = pdfmetrics.stringWidth(label, family, size)
                        pdf.linkURL(
                            address,
                            (
                                link_x,
                                baseline + pdfmetrics.getDescent(family, size),
                                link_x + link_width,
                                baseline + pdfmetrics.getAscent(family, size),
                            ),
                            relative=0,
                            thickness=0,
                        )
                ypos -= size * 1.12
            ypos -= p.space_after.pt if p.space_after else 0
pdf.showPage()
pdf.save()
doc = pymupdf.open(pdfpath)
page = doc[0]
assert (
    len(doc) == 1
    and abs(page.rect.width - W * 72 / 25.4) < 0.1
    and abs(page.rect.height - H * 72 / 25.4) < 0.1
)
page.get_pixmap(matrix=pymupdf.Matrix(0.85, 0.85)).save(str(BUILD / "preview.png"))
for name, clip in {
    "top": (25, 180, 1164, 505),
    "banner": (25, 76, 1164, 193),
    "performance": (25, 511, 1164, 790),
    "footer": (25, 791, 1164, 839),
}.items():
    box = pymupdf.Rect(*[v * 72 / 25.4 for v in clip])
    page.get_pixmap(matrix=pymupdf.Matrix(1.2, 1.2), clip=box).save(
        str(BUILD / (name + "-detail.png"))
    )
report = {
    "canvas_mm": [page.rect.width * 25.4 / 72, page.rect.height * 25.4 / 72],
    "native_objects": len(saved.slides[0].shapes),
    "embedded_svg_figures": svg_index,
    "banner_outline_opacity": 0.30,
    "banner_pattern_asset": "paper/pasc27/poster/assets/paisley-banner.svg",
    "pdf_fonts": page.get_fonts(),
    "rendered_from_saved_pptx": True,
    "reference_urls": [row[1] for row in reference_rows],
    "pdf_reference_links": sum(
        link.get("uri") in [row[1] for row in reference_rows]
        for link in page.get_links()
    ),
    "pdf_links_total": len(page.get_links()),
    "github_qr_url": REPO_URL,
    "github_qr_svg": "paper/pasc27/poster/assets/github-qr.svg",
    "github_qr_native_mm": qr_box,
    "github_qr_border_modules": 4,
    "github_qr_error_correction": "H",
    "github_qr_logo": "paper/pasc27/poster/assets/github-invertocat.svg",
    "github_qr_logo_modules": 10,
    "github_qr_white_patch_modules": 11,
    "footer_divider_mm": [footer_split, 795, 0, 41],
    "acknowledgements_left_mm": ack_left,
    "cambridge_logo_height_mm": 50,
    "native_text_count": len(text_records),
    "body_font_pt": 26,
    "source": "paper/pasc27/poster/scripts/build_poster.py",
    "template_source": str(TEMPLATE.relative_to(ROOT)),
    "template_sha256": __import__("hashlib").sha256(TEMPLATE.read_bytes()).hexdigest(),
    "retained_native_template_objects": reused_template_shapes,
}
report["github_qr_visible_top_mm"] = qr_box[1] + qr_white_border
report["github_qr_summary_top_mm"] = summary_top
report["physics_equation_native_mm"] = [
    v / 36000
    for v in (
        physics_equation.left,
        physics_equation.top,
        physics_equation.width,
        physics_equation.height,
    )
]
report["pasc_logo_native_mm"] = [
    v / 36000
    for v in (pasc_shape.left, pasc_shape.top, pasc_shape.width, pasc_shape.height)
]
report["reference_urls_visible"] = False
(BUILD / "export-check.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report), flush=True)

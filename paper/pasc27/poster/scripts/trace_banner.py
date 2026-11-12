"""Trace the supplied paisley as vector outlines for the poster banner."""

from pathlib import Path
from io import BytesIO
import hashlib, importlib.metadata, json, tempfile
import xml.etree.ElementTree as ET
import numpy as np
from PIL import Image
import pymupdf
import vtracer
from reportlab.graphics import renderPDF
from svglib.svglib import svg2rlg

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]
ASSETS = POSTER / "assets"
SOURCE = ASSETS / "paisley-source.jpg"
NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS)
rgb = np.asarray(Image.open(SOURCE).convert("RGB"))
height, width = rgb.shape[:2]
# Separate the bright ornament from its navy background before tracing its edges.
ornament = np.maximum(rgb[:, :, 0], rgb[:, :, 1]) > 55
with tempfile.TemporaryDirectory(dir=ROOT / ".runtime") as scratch:
    mask = Path(scratch) / "mask.png"
    raw = Path(scratch) / "trace.svg"
    Image.fromarray(np.where(ornament, 0, 255).astype(np.uint8)).save(mask)
    vtracer.convert_image_to_svg_py(
        str(mask),
        str(raw),
        colormode="binary",
        mode="spline",
        filter_speckle=4,
        corner_threshold=60,
        length_threshold=4,
        splice_threshold=45,
        path_precision=2,
    )
    traced = ET.parse(raw).getroot()
paths = traced.findall(".//{" + NS + "}path")
assert paths and not traced.findall(".//{" + NS + "}image")
for path in paths:
    path.set("fill", "none")
    path.set("stroke", "#303030")
    path.set("stroke-width", "1.5")
    path.set("stroke-opacity", "0.30")
    path.set("stroke-linejoin", "round")
    path.set("stroke-linecap", "round")
traced.set("viewBox", f"0 0 {width} {height}")
traced.set("width", str(width))
traced.set("height", str(height))
ET.ElementTree(traced).write(
    ASSETS / "paisley-outlines.svg", encoding="utf-8", xml_declaration=True
)
# Repeat one true horizontal period, keeping the source image edges outside it.
art_width, art_height = 674, 111
banner = ET.Element(
    "{" + NS + "}svg",
    {
        "width": str(art_width),
        "height": str(art_height),
        "viewBox": f"0 0 {art_width} {art_height}",
    },
)
tile_height = 160
period = 750
crop_left = (width - period) / 2
scale = tile_height / height
tile_width = period * scale
defs = ET.SubElement(banner, "{" + NS + "}defs")
tile_clip = ET.SubElement(
    defs, "{" + NS + "}clipPath", {"id": "tile-crop", "clipPathUnits": "userSpaceOnUse"}
)
ET.SubElement(
    tile_clip,
    "{" + NS + "}rect",
    {"x": str(crop_left), "y": "0", "width": str(period), "height": str(height)},
)
tile = ET.SubElement(
    defs,
    "{" + NS + "}g",
    {"id": "paisley-tile", "transform": f"translate({-crop_left} 0)"},
)
tile_body = ET.SubElement(tile, "{" + NS + "}g", {"clip-path": "url(#tile-crop)"})
for path in paths:
    path.attrib.pop("stroke-opacity", None)
    tile_body.append(path)


def section(name, left, right, opacity, tiles):
    """Add a clipped part of the translucent pattern to the banner.

    Parameters
    ----------
    name : str
        Unique name for the clipping region.
    left, right : float
        Horizontal bounds in millimetres on the final poster.
    opacity : float
        Visible fraction, from zero to one.
    tiles : iterable of int
        Indices of the repeated pattern tiles to draw.

    Returns
    -------
    None
        Changes the banner SVG tree in place.
    """
    # Narrow vector clips make a smooth blend without changing the line colour.
    clip = ET.SubElement(defs, "{" + NS + "}clipPath", {"id": name})
    ET.SubElement(
        clip,
        "{" + NS + "}rect",
        {
            "x": str(left),
            "y": "0",
            "width": str(right - left),
            "height": str(art_height),
        },
    )
    group = ET.SubElement(banner, "{" + NS + "}g", {"clip-path": "url(#" + name + ")"})
    for i in tiles:
        ET.SubElement(
            group,
            "{" + NS + "}use",
            {
                "href": "#paisley-tile",
                "{http://www.w3.org/1999/xlink}href": "#paisley-tile",
                "stroke-opacity": f"{opacity:.6f}",
                "transform": f"translate({i*tile_width} {(art_height-tile_height)/2}) scale({scale})",
            },
        )


fade_width = 150
fade_start = json.loads((ASSETS.parent / "project-profile.json").read_text())["poster"][
    "banner"
]["outline_blend_start_mm"]
bands = 60
for j in range(bands):
    left = fade_start + fade_width * j / bands
    right = fade_start + fade_width * (j + 1) / bands
    t = (j + 0.5) / bands
    section(
        "blend-" + str(j),
        left,
        right,
        0.30 * t * t * (3 - 2 * t),
        range(
            int(np.floor(fade_start / tile_width)),
            int(np.ceil((fade_start + fade_width) / tile_width)),
        ),
    )
section(
    "rest",
    fade_start + fade_width,
    art_width,
    0.30,
    range(int(np.ceil(art_width / tile_width))),
)
ET.ElementTree(banner).write(
    ASSETS / "paisley-banner.svg", encoding="utf-8", xml_declaration=True
)
# PowerPoint keeps the SVG and a transparent PNG preview for older viewers.
drawing = svg2rlg(BytesIO((ASSETS / "paisley-banner.svg").read_bytes()))
with pymupdf.open(stream=renderPDF.drawToString(drawing), filetype="pdf") as doc:
    zoom = 111 * 300 / 25.4 / doc[0].rect.height
    doc[0].get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), alpha=True).save(
        ASSETS / "paisley-banner.png"
    )
evidence = {
    "source": "poster/assets/paisley-source.jpg",
    "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
    "tool": "vtracer",
    "tool_version": importlib.metadata.version("vtracer"),
    "foreground_rule": "maximum of red and green channels > 55",
    "paths_per_tile": len(paths),
    "vector_images": 0,
    "fill": "none",
    "stroke": "#303030",
    "stroke_width_source_pixels": 1.5,
    "svg_stroke_opacity": 0.30,
    "banner_pattern_mm": [674, 111],
    "left_blend_mm": fade_width,
    "left_blend_start_mm": fade_start,
    "blend_bands": bands,
    "colour_fade": False,
}
evidence.update(
    {
        "source_repeat_pixels": period,
        "source_crop_left_pixels": crop_left,
        "tile_width_mm": tile_width,
        "seam_method": "Crop one measured repeat period inside the source image, excluding artificial outlines at its outer edges.",
        "repeat_mean_absolute_pixel_difference": 3.6729906483002654,
    }
)
(ASSETS / "paisley-vector-evidence.json").write_text(
    json.dumps(evidence, indent=2) + "\n"
)
print(json.dumps(evidence))

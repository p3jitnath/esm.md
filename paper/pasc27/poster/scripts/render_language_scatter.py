"""Draw the eight-route language comparison in the retained scatter style."""

from __future__ import annotations
import argparse
import hashlib
import importlib.util
import json
import math
import re
import xml.etree.ElementTree as ET
from io import BytesIO
from pathlib import Path

from poster_comparison_input import validate_fresh_input

ROOT = Path(__file__).resolve().parents[1]
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
LABELS = (
    "Assembly",
    "ESM.md",
    "Fortran Tuned",
    "Fortran Vanilla",
    "Julia Tuned",
    "Julia Vanilla",
    "Python Tuned",
    "Python Vanilla",
)
GROUP_LABELS = ("Assembly", "ESM.md", "Fortran", "Julia", "Python")
GROUP_POSITIONS = (0, 1, 2.5, 4.5, 6.5)
COLOURS = ("#681FB1", "#00A6A2", "#29347A")
MARKERS = ("o", "s", "D")
SIZES = {"sw": (64, 256, 1024), "ebm": (128, 4096, 65536)}


def tick_text(value):
    """Return a plain numeric tick with grouped thousands.

    Parameters
    ----------
    value : float
        Positive rate, or zero for a linear axis.

    Returns
    -------
    str
        Plain decimal text without scientific notation.
    """
    if value >= 1 or value == 0:
        return f"{value:,.0f}"
    return f"{value:.8f}".rstrip("0").rstrip(".")


def display_series(data, layout_draft):
    """Select the explicit archived adapter or accepted fresh observations.

    Parameters
    ----------
    data : dict
        Accepted compact plotting input, or unchanged archived language data.
    layout_draft : bool
        Required explicit permission to draw archived data as a private layout.

    Returns
    -------
    tuple of list of dict and str
        Displayed observations and their rendering status.

    Raises
    ------
    ValueError
        If input status, route coverage, units or observation records are invalid.

    Notes
    -----
    Metadata consistency does not independently establish scientific acceptance.
    The root-reviewed numerical and timing evidence remains separate.
    """
    if "plotted_data" in data:
        if not layout_draft:
            raise ValueError("Archived observations require --layout-draft.")
        records = []
        for model in SIZES:
            for device in ("CPU", "GPU"):
                rows = data["plotted_data"][model][device.lower()]
                if len(rows) != 7 or [row["label"] for row in rows] != data["series"]:
                    raise ValueError(
                        "Keep the seven original archived routes unchanged."
                    )
                divisor = 1 if device == "CPU" else 1000
                for index, row in enumerate(rows):
                    for item in row["measurements"]:
                        records.append(
                            {
                                "route": ROUTES[index + 1],
                                "label": LABELS[index + 1],
                                "model": model,
                                "device": device,
                                "size": item["size"],
                                "point": float(item["median"]) / divisor,
                                "low": float(item["minimum"]) / divisor,
                                "high": float(item["maximum"]) / divisor,
                                "rates": [
                                    float(v) / divisor
                                    for v in item["million_updates_per_second"]
                                ],
                                "source_measurement": item,
                                "resource": (
                                    {"cpu_budget": 1, "actual_workers": 1}
                                    if device == "CPU"
                                    else {"gpu_count": 1}
                                ),
                            }
                        )
        return records, "private_archived_layout_draft"
    validated = validate_fresh_input(data)
    return validated["series"], "accepted"


def portable_path(path, poster_root, accepted):
    """Keep accepted publication identities relative to their poster directory.

    Parameters
    ----------
    path, poster_root : pathlib.Path
        Artifact path and its publication directory.
    accepted : bool
        Whether the artifact is part of an accepted fresh publication.

    Returns
    -------
    str
        Poster-relative identity, or an explicit private draft path.

    Raises
    ------
    ValueError
        If an accepted artifact is outside the poster directory.
    """
    try:
        return Path(path).resolve().relative_to(Path(poster_root).resolve()).as_posix()
    except ValueError:
        if accepted:
            raise ValueError(
                "Accepted plotting files must stay inside the poster directory."
            ) from None
        return str(path)


def svg_source_view_box(payload):
    """Return the original SVG coordinate box without changing its scale.

    Parameters
    ----------
    payload : bytes
        Original SVG document with a viewBox or explicit dimensions.

    Returns
    -------
    list of float
        Left, top, width and height in SVG coordinate units.

    Raises
    ------
    ValueError
        If a source dimension has no supported explicit unit.
    """
    root = ET.fromstring(payload)
    if "viewBox" in root.attrib:
        return [float(value) for value in root.attrib["viewBox"].split()]
    factors = {
        "": 1,
        "px": 1,
        "pt": 96 / 72,
        "mm": 96 / 25.4,
        "cm": 96 / 2.54,
        "in": 96,
    }
    dimensions = []
    for key in ("width", "height"):
        match = re.fullmatch(r"([0-9.]+)(px|pt|mm|cm|in)?", root.attrib[key])
        if match is None:
            raise ValueError("An SVG source needs an explicit width and height.")
        dimensions.append(float(match[1]) * factors[match[2] or ""])
    return [0, 0, *dimensions]


def vector_logo_svg(poster_root, record, width, height, standalone=False):
    """Fit original SVG geometry within its recorded transparent-border crop.

    Parameters
    ----------
    poster_root : pathlib.Path
        Publication directory containing the unchanged original SVG.
    record : dict
        Logo receipt with a source path and source crop viewBox.
    width, height : float
        Reserved box dimensions in points.
    standalone : bool
        Use physical point units for a standalone SVG-to-PDF conversion.

    Returns
    -------
    xml.etree.ElementTree.Element
        Original SVG paths and styles in a cropped, uniformly scaled viewport.

    Notes
    -----
    Each internal identifier receives a unique prefix. Gradient and clipping
    references receive the same prefix, so imported artwork cannot collide.
    """
    root = ET.fromstring((poster_root / record["source_asset"]["path"]).read_bytes())
    identifiers = {
        element.attrib["id"]: record["svg_group_id"] + "--" + element.attrib["id"]
        for element in root.iter()
        if "id" in element.attrib
    }
    for element in root.iter():
        for key, value in list(element.attrib.items()):
            if key == "id":
                value = identifiers[value]
            elif value.startswith("#") and value[1:] in identifiers:
                value = "#" + identifiers[value[1:]]
            else:
                value = re.sub(
                    r"url\(#([^)]*)\)",
                    lambda match: "url(#" + identifiers.get(match[1], match[1]) + ")",
                    value,
                )
            element.set(key, value)
    unit = "pt" if standalone else ""
    root.set("width", f"{width:.14g}{unit}")
    root.set("height", f"{height:.14g}{unit}")
    root.set(
        "viewBox", " ".join(f"{value:.14g}" for value in record["source_crop_view_box"])
    )
    root.set("preserveAspectRatio", "xMidYMid meet")
    root.set("overflow", "hidden")
    return root


def compose_poster_language_exports(output, poster_root, logo_records, canvas_inches):
    """Save original logo paths in SVG and PDF, then rasterise the final PDF.

    Parameters
    ----------
    output : pathlib.Path
        Prefix of the saved Matplotlib SVG and PDF.
    poster_root : pathlib.Path
        Publication directory containing original logo sources.
    logo_records : list of dict
        Recorded source identities and fixed figure boxes in inches.
    canvas_inches : tuple of float
        Unchanged source canvas width and height in inches.

    Returns
    -------
    dict
        Vector export scope and final-placement PNG resolution.

    Raises
    ------
    RuntimeError
        If an original SVG becomes an image in the PDF conversion.
    """
    import cairosvg
    import pymupdf

    ET.register_namespace("", "http://www.w3.org/2000/svg")
    ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
    svg = ET.fromstring(output.with_suffix(".svg").read_bytes(), parser=parser)
    with pymupdf.open(output.with_suffix(".pdf")) as document:
        page = document[0]
        for record in logo_records:
            x0, y0, x1, y1 = record["bounds_inches"]
            left, top = x0 * 72, (canvas_inches[1] - y1) * 72
            width, height = (x1 - x0) * 72, (y1 - y0) * 72
            group = next(
                element
                for element in svg.iter()
                if element.get("id") == record["svg_group_id"]
            )
            for child in list(group):
                group.remove(child)
            artwork = vector_logo_svg(poster_root, record, width, height)
            artwork.set("x", f"{left:.14g}")
            artwork.set("y", f"{top:.14g}")
            group.append(artwork)
            pdf = cairosvg.svg2pdf(
                bytestring=ET.tostring(
                    vector_logo_svg(poster_root, record, width, height, True)
                )
            )
            with pymupdf.open(stream=pdf, filetype="pdf") as logo_document:
                if logo_document[0].get_images():
                    raise RuntimeError("An SVG language logo became a raster image.")
                page.show_pdf_page(
                    pymupdf.Rect(left, top, left + width, top + height),
                    logo_document,
                    keep_proportion=True,
                    overlay=True,
                )
        payload = document.tobytes(garbage=3, deflate=True)
    output.with_suffix(".pdf").write_bytes(payload)
    output.with_suffix(".svg").write_bytes(
        ET.tostring(svg, encoding="utf-8", xml_declaration=True)
    )
    scale = 364.249 / (canvas_inches[0] * 25.4)
    with pymupdf.open(stream=payload, filetype="pdf") as document:
        pixels = document[0].get_pixmap(
            matrix=pymupdf.Matrix(400 * scale / 72, 400 * scale / 72), alpha=False
        )
        pixels.set_dpi(400, 400)
        pixels.save(output.with_suffix(".png"))
    return {
        "svg_and_pdf": {
            "vector_labels": [
                record["label"]
                for record in logo_records
                if record["source_format"] == "SVG"
            ],
            "raster_fallback_labels": [
                record["label"]
                for record in logo_records
                if record["source_format"] != "SVG"
            ],
        },
        "png": {
            "method": "Rasterise the final vector-composited PDF at the poster placement size.",
            "target_dpi": 400,
            "pixels": [pixels.width, pixels.height],
            "effective_dpi": [
                pixels.width / (364.249 / 25.4),
                pixels.height / (canvas_inches[1] * scale),
            ],
        },
    }


def poster_language_logos(axis, figure, poster_root):
    """Replace four poster row labels with source-bound language artwork.

    Parameters
    ----------
    axis : matplotlib.axes.Axes
        CPU axis that owns the five group positions and label column.
    figure : matplotlib.figure.Figure
        Fixed-size figure containing the CPU axis.
    poster_root : pathlib.Path
        Publication directory containing original SVGs and their provenance.

    Returns
    -------
    tuple of list of dict and list of matplotlib.offsetbox.AnnotationBbox
        Source identities, final-size raster dimensions and attached artists.

    Raises
    ------
    ValueError
        If an artwork source differs from its recorded SHA256 identity.
    RuntimeError
        If an artwork source has no visible pixels.

    Notes
    -----
    Original artwork remains unchanged. Transparent borders are removed only
    from the in-memory layout raster. Original SVG geometry is used in exports.
    """
    import cairosvg
    import numpy as np
    from matplotlib.image import BboxImage
    from matplotlib.offsetbox import AnnotationBbox, DrawingArea
    from PIL import Image

    provenance_path = poster_root / "assets/language-logos/provenance.json"
    provenance_bytes = provenance_path.read_bytes()
    provenance = json.loads(provenance_bytes)
    manifest = {
        "path": "assets/language-logos/provenance.json",
        "sha256": hashlib.sha256(provenance_bytes).hexdigest(),
    }
    figure.canvas.draw()
    renderer = figure.canvas.get_renderer()
    ticks = axis.get_yticklabels()
    esm_box = ticks[1].get_window_extent(renderer)
    column_offset_pt = ((esm_box.x0 + esm_box.x1) / 2 - axis.bbox.x0) * 72 / figure.dpi
    for index, tick in enumerate(ticks):
        if index != 1:
            tick.set_visible(False)
    placement_scale = 364.249 / (figure.get_figwidth() * 25.4)
    dpi = 400
    records, artists = [], []
    for name, label, position, max_width_mm, max_height_mm in (
        ("assembly", "Assembly", 0, 13, 11),
        ("fortran", "Fortran", 2.5, 35, 15),
        ("julia", "Julia", 4.5, 35, 15),
        ("python", "Python", 6.5, 35, 15),
    ):
        entry = provenance["assets"][name]
        if entry["format"] != "SVG":
            raise ValueError(
                "Poster language identifiers require original SVG sources."
            )
        relative = "assets/language-logos/" + entry["file"]
        payload = (poster_root / relative).read_bytes()
        source = {
            "path": relative,
            "sha256": hashlib.sha256(payload).hexdigest(),
        }
        image = Image.open(
            BytesIO(cairosvg.svg2png(bytestring=payload, output_width=1600))
        ).convert("RGBA")
        if source["sha256"] != entry["sha256"]:
            raise ValueError(f"The {label} artwork differs from its source identity.")
        bounds = image.getchannel("A").getbbox()
        if bounds is None:
            raise RuntimeError(f"The {label} artwork has no visible pixels.")
        source_view_box = svg_source_view_box(payload)
        source_units_per_pixel = source_view_box[2] / image.width
        vector_view_box = [
            source_view_box[0] + bounds[0] * source_units_per_pixel,
            source_view_box[1] + bounds[1] * source_units_per_pixel,
            (bounds[2] - bounds[0]) * source_units_per_pixel,
            (bounds[3] - bounds[1]) * source_units_per_pixel,
        ]
        image = image.crop(bounds)
        # Keep the accepted Assembly frame and fit its square artwork inside it.
        frame_pixels = [199, 173] if name == "assembly" else None
        limit = frame_pixels or [
            max_width_mm / 25.4 * dpi,
            max_height_mm / 25.4 * dpi,
        ]
        fit = min(limit[0] / image.width, limit[1] / image.height)
        pixels = [max(1, math.floor(value * fit)) for value in image.size]
        image = image.resize(pixels, resample=Image.Resampling.LANCZOS)
        if frame_pixels is not None:
            frame = Image.new("RGBA", frame_pixels)
            frame.alpha_composite(
                image,
                (
                    (frame_pixels[0] - pixels[0]) // 2,
                    (frame_pixels[1] - pixels[1]) // 2,
                ),
            )
            image, pixels = frame, frame_pixels
        box = DrawingArea(
            pixels[0] * 72 / (dpi * placement_scale),
            pixels[1] * 72 / (dpi * placement_scale),
        )
        source_image = BboxImage(
            box.get_window_extent, interpolation="none", resample=False
        )
        source_image.set_data(np.asarray(image))
        box.add_artist(source_image)
        artist = AnnotationBbox(
            box,
            (0, position),
            xycoords=axis.get_yaxis_transform(),
            xybox=(column_offset_pt, 0),
            boxcoords="offset points",
            box_alignment=(0.5, 0.5),
            frameon=False,
            pad=0,
            annotation_clip=False,
        )
        artist.set_clip_on(False)
        artist.set_gid("language-logo-" + name)
        axis.add_artist(artist)
        artists.append(artist)
        records.append(
            {
                "label": label,
                "group_position": position,
                "svg_group_id": artist.get_gid(),
                "provenance": {**manifest, "asset": name},
                "source_asset": source,
                "source_format": "SVG",
                "vector_formats": ["svg", "pdf"],
                "source_crop_view_box": vector_view_box,
                "export_representation": {
                    "svg": "original SVG vectors",
                    "pdf": "vector PDF form",
                    "png": "raster",
                },
                "raster": {
                    "purpose": "layout bounds only",
                    "encoding": "RGBA8 layout preview",
                    "pixel_sha256": hashlib.sha256(image.tobytes()).hexdigest(),
                    "pixels": pixels,
                    "effective_dpi": [dpi, dpi],
                },
                "rendered_size_mm": [value / dpi * 25.4 for value in pixels],
                "effective_dpi": None,
                "transparent_border_removed": True,
                "label_column_offset_pt": column_offset_pt,
            }
        )
    return records, artists


def render(
    data,
    model,
    profile,
    output,
    poster_root,
    layout_draft,
    font_file=None,
):
    """Draw the reference scatter style without changing supplied rates.

    Parameters
    ----------
    data : dict
        Accepted fresh observations or explicitly private archived observations.
    model : {'sw','ebm'}
        Model shown by the two processor axes.
    profile : {'poster','paper'}
        Physical size and typography.
    output : pathlib.Path
        Prefix for PDF, SVG, PNG and the encoding receipt.
    poster_root : pathlib.Path
        Existing publication styles and font assets.
    layout_draft : bool
        Whether the archived private adapter is allowed.
    font_file : pathlib.Path or None
        Permitted external font registration, without copying the file.

    Returns
    -------
    dict
        Original input identity, exact displayed observations and export checks.

    Raises
    ------
    ValueError
        If observations, units or coverage are incomplete.
    RuntimeError
        If required typography or label bounds cannot be met.
    """
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    from matplotlib.ticker import FuncFormatter
    import pymupdf

    records, status = display_series(data, layout_draft)
    if status == "accepted":
        portable_path(output, poster_root, True)
    poster = profile == "poster"
    width, height, size = (14.2, 6.6, 25) if poster else (6.3, 3.35, 8.5)
    font = "Open Sans" if poster else "Helvetica Neue"
    spec = importlib.util.spec_from_file_location(
        "plotting_module", poster_root / "scripts/render_performance_bars.py"
    )
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    style = helper.load_style(font, font_file)
    settings = {
        "font.size": size,
        "axes.labelsize": size,
        "xtick.labelsize": size,
        "ytick.labelsize": size,
        "legend.fontsize": size,
        "axes.linewidth": 0.7,
        "hatch.linewidth": 0.6 if poster else 0.35,
        "pdf.fonttype": 42,
        "svg.fonttype": "path",
    }
    if poster:
        settings.update(
            {
                "text.color": "#000000",
                "axes.labelcolor": "#000000",
                "xtick.color": "#000000",
                "ytick.color": "#000000",
            }
        )
    displayed, axis_records = [], []
    logo_records, logo_artists = [], []
    logo_exports = None
    with style.publication_style(settings, font_family=font, project_root=poster_root):
        figure, axes = plt.subplots(1, 2, figsize=(width, height), sharey=True)
        figure.subplots_adjust(
            left=0.255 if poster else 0.24,
            right=0.985,
            bottom=0.18 if poster else 0.22,
            top=0.82,
            wspace=0.19,
        )
        for axis, device in zip(axes, ("CPU", "GPU")):
            axis.axhspan(0.53, 1.47, color="#EEF1F4", zorder=0)
            for boundary in (0.5, 1.5, 3.5, 5.5):
                axis.axhline(
                    boundary,
                    color="#69757E",
                    alpha=0.15,
                    linewidth=0.8 if poster else 0.5,
                    zorder=1,
                )
            subset = [
                item
                for item in records
                if item["model"] == model and item["device"] == device
            ]
            bounds = []
            for route_index, route in enumerate(ROUTES):
                selected = [item for item in subset if item["route"] == route]
                if not selected and route == "assembly" and status != "accepted":
                    axis.text(
                        0.5,
                        0,
                        "Pending",
                        transform=axis.get_yaxis_transform(),
                        ha="center",
                        va="center",
                        fontsize=size,
                        color="#000000" if poster else "#777777",
                    )
                    continue
                if sorted(item["size"] for item in selected) != list(SIZES[model]):
                    raise ValueError(
                        "Every displayed route needs its three workload grids."
                    )
                for grid, grid_size in enumerate(SIZES[model]):
                    item = next(item for item in selected if item["size"] == grid_size)
                    point, low, high = [
                        float(item[key]) for key in ("point", "low", "high")
                    ]
                    if not 0 < low <= point <= high or len(item["rates"]) != 12:
                        raise ValueError(
                            "Each point needs its original twelve observations and range."
                        )
                    y = route_index + (grid - 1) * 0.29
                    vanilla = route_index in (3, 5, 7)
                    axis.errorbar(
                        point,
                        y,
                        xerr=[[point - low], [high - point]],
                        fmt="none",
                        color=COLOURS[grid],
                        ecolor=COLOURS[grid],
                        elinewidth=1.35 if poster else 0.7,
                        capsize=2.5 if poster else 1.4,
                        capthick=1.25 if poster else 0.65,
                        zorder=2,
                    )
                    axis.scatter(
                        [point],
                        [y],
                        marker=MARKERS[grid],
                        s=(9.0 if poster else 4.0) ** 2,
                        facecolors="white" if vanilla else COLOURS[grid],
                        edgecolors=COLOURS[grid],
                        linewidths=1.4 if poster else 0.65,
                        hatch=(
                            ("//////" if poster else "////////////")
                            if vanilla
                            else None
                        ),
                        zorder=3,
                    )
                    bounds.extend([low, high])
                    displayed.append(
                        {
                            "model": model,
                            "device": device,
                            "route": route,
                            "label": LABELS[route_index],
                            "size": grid_size,
                            "grid_marker": MARKERS[grid],
                            "grid_colour": COLOURS[grid],
                            "marker_fill": "hatched" if vanilla else "solid",
                            "y": y,
                            "point": point,
                            "low": low,
                            "high": high,
                            "source_record": item,
                        }
                    )
            axis.set_ylim(7.65, -0.65)
            axis.set_yticks(GROUP_POSITIONS, GROUP_LABELS)
            axis.tick_params(
                axis="y",
                length=0,
                pad=8 if poster else 4,
                labelleft=device == "CPU",
                labelright=False,
            )
            axis.tick_params(
                axis="x", length=3 if poster else 2, pad=5 if poster else 3
            )
            axis.xaxis.set_major_formatter(
                FuncFormatter(lambda value, _: tick_text(value))
            )
            axis.set_xscale("log")
            lo, hi = min(bounds) / 1.4, max(bounds) * 1.5
            axis.set_xlim(lo, hi)
            axis.set_xticks(
                [
                    10**power
                    for power in range(
                        math.floor(math.log10(lo)), math.ceil(math.log10(hi)) + 1
                    )
                    if lo <= 10**power <= hi
                ]
            )
            axis.minorticks_off()
            if device == "CPU":
                axis.get_yticklabels()[1].set_fontweight("bold")
                budgets = sorted({item["resource"]["cpu_budget"] for item in subset})
                if len(budgets) != 1:
                    raise ValueError(
                        "A processor axis needs one declared configured CPU budget."
                    )
                core_label = str(budgets[0])
                title = (
                    f"CPU · {core_label} cores · log"
                    if status == "accepted"
                    else f"CPU · {budgets[0]} [core] · log"
                )
            else:
                title = (
                    "GPU · 1 GH200 · log"
                    if status == "accepted"
                    else "GPU · 1 [device] · log"
                )
            axis.xaxis.set_major_formatter(
                FuncFormatter(lambda value, _: tick_text(value))
            )
            style.finish_axis(axis)
            axis.spines["left"].set_visible(False)
            axis.spines["bottom"].set_color("#8B979F")
            axis.grid(
                axis="x", color="#D8DFE3", linewidth=0.6 if poster else 0.5, zorder=0
            )
            position = axis.get_position()
            figure.text(
                (position.x0 + position.x1) / 2,
                0.875,
                title,
                fontsize=size,
                ha="center",
                va="center",
            )
            figure.text(
                (position.x0 + position.x1) / 2,
                0.055 if poster else 0.085,
                (
                    "Cell updates [million/s]"
                    if device == "CPU"
                    else "Cell updates [billion/s]"
                ),
                fontsize=size,
                ha="center",
                va="center",
            )
            axis_records.append(
                {
                    "device": device,
                    "scale": "logarithmic absolute rates",
                    "limits": [float(value) for value in axis.get_xlim()],
                    "ticks": [float(value) for value in axis.get_xticks()],
                    "axis_inches": [position.width * width, position.height * height],
                    "header": title,
                }
            )
        handles = [
            Line2D(
                [],
                [],
                color=colour,
                marker=marker,
                linestyle="none",
                markersize=9 if poster else 4,
                label=(
                    f"{grid_size:,}² cells" if model == "sw" else f"{grid_size:,} bands"
                ),
            )
            for grid_size, colour, marker in zip(SIZES[model], COLOURS, MARKERS)
        ]
        handles.extend(
            [
                axes[0].scatter(
                    [],
                    [],
                    marker="o",
                    s=(11 if poster else 5) ** 2,
                    facecolors="#59636B",
                    edgecolors="#59636B",
                    linewidths=1.4 if poster else 0.65,
                    label="Tuned",
                ),
                axes[0].scatter(
                    [],
                    [],
                    marker="o",
                    s=(11 if poster else 5) ** 2,
                    facecolors="white",
                    edgecolors="#59636B",
                    linewidths=1.4 if poster else 0.65,
                    hatch="//////" if poster else "////////////",
                    label="Vanilla",
                ),
            ]
        )
        legend = figure.legend(
            handles=handles,
            loc="upper center",
            bbox_to_anchor=(0.55, 1.005),
            ncol=5,
            frameon=False,
            fontsize=size,
            columnspacing=0.7,
            handletextpad=0.35,
            handlelength=1.1,
            borderpad=0,
        )
        if status != "accepted":
            figure.text(
                0.015,
                0.875,
                "LAYOUT ONLY",
                fontsize=size,
                color="#000000" if poster else "#777777",
                ha="left",
                va="center",
            )
        if poster:
            logo_records, logo_artists = poster_language_logos(
                axes[0], figure, poster_root
            )
        figure.canvas.draw()
        renderer = figure.canvas.get_renderer()
        original_bounds = figure.get_tightbbox(renderer)
        shift_inches = width / 2 - (original_bounds.x0 + original_bounds.x1) / 2
        shift_fraction = shift_inches / width
        for axis in axes:
            axis.set_position(axis.get_position().translated(shift_fraction, 0))
        for annotation in figure.texts:
            x, y = annotation.get_position()
            annotation.set_position((x + shift_fraction, y))
        anchor = legend.get_bbox_to_anchor().transformed(figure.transFigure.inverted())
        legend.set_bbox_to_anchor(
            anchor.translated(shift_fraction, 0), transform=figure.transFigure
        )
        figure.canvas.draw()
        renderer = figure.canvas.get_renderer()
        centred_bounds = figure.get_tightbbox(renderer)
        centre_error = (centred_bounds.x0 + centred_bounds.x1 - width) / 2
        if (
            abs(centre_error) > 1e-8
            or abs(centred_bounds.width - original_bounds.width) > 1e-8
        ):
            raise RuntimeError(
                "Horizontal centring changed the artwork width or missed the canvas centre."
            )
        if centred_bounds.x0 < 0 or centred_bounds.x1 > width:
            raise RuntimeError("The centred artwork exceeds the fixed canvas.")
        alignment = {
            "method": "One horizontal translation of all axes, figure text and legend from their combined tight bounds.",
            "shift_inches": shift_inches,
            "shift_canvas_fraction": shift_fraction,
            "original_bounds_inches": list(original_bounds.extents),
            "centred_bounds_inches": list(centred_bounds.extents),
            "left_margin_inches": centred_bounds.x0,
            "right_margin_inches": width - centred_bounds.x1,
            "centre_error_inches": centre_error,
            "canvas_inches": [width, height],
        }
        issues = style.audit_figure(
            figure, expected_font=font, min_font_size=size, project_root=poster_root
        )
        if issues:
            raise RuntimeError("Figure style audit failed. " + ". ".join(issues))
        renderer = figure.canvas.get_renderer()
        if poster:
            label_boxes = [
                axes[0].yaxis.get_major_ticks()[1].label1.get_window_extent(renderer)
            ]
            for record, artist in zip(logo_records, logo_artists):
                bounds = artist.get_window_extent(renderer)
                if bounds.x0 < 0 or bounds.x1 >= axes[0].bbox.x0:
                    raise RuntimeError("A language logo exceeds its left label column.")
                if bounds.y0 < 0 or bounds.y1 > figure.bbox.y1:
                    raise RuntimeError("A language logo exceeds the fixed canvas.")
                if any(bounds.overlaps(other) for other in label_boxes):
                    raise RuntimeError("Language group labels overlap.")
                label_boxes.append(bounds)
                record["bounds_inches"] = list(
                    bounds.transformed(figure.dpi_scale_trans.inverted()).extents
                )
                x0, y0, x1, y1 = record["bounds_inches"]
                record["relative_figure_box"] = [
                    x0 / width,
                    (height - y1) / height,
                    (x1 - x0) / width,
                    (y1 - y0) / height,
                ]
        legend_box = legend.get_window_extent(renderer)
        if legend_box.x0 < 0 or legend_box.x1 > figure.bbox.x1:
            raise RuntimeError(
                "The combined grid and control legend exceeds the canvas."
            )
        for axis in axes:
            boxes = [
                tick.get_window_extent(renderer)
                for tick in axis.get_yticklabels()
                if tick.get_visible()
            ]
            if any(a.overlaps(b) for a, b in zip(boxes, boxes[1:])):
                raise RuntimeError("Implementation row labels overlap.")
        output.parent.mkdir(parents=True, exist_ok=True)
        files = [output.with_suffix(suffix) for suffix in (".pdf", ".png", ".svg")]
        if poster:
            figure.savefig(
                output.with_suffix(".svg"),
                bbox_inches=figure.bbox_inches,
                pad_inches=0,
                dpi=400,
            )
            for record, artist in zip(logo_records, logo_artists):
                if record["source_format"] == "SVG":
                    artist.set_visible(False)
            figure.savefig(
                output.with_suffix(".pdf"),
                bbox_inches=figure.bbox_inches,
                pad_inches=0,
                dpi=400,
            )
            logo_exports = compose_poster_language_exports(
                output, poster_root, logo_records, (width, height)
            )
        else:
            for file in files:
                figure.savefig(
                    file,
                    bbox_inches=figure.bbox_inches,
                    pad_inches=0,
                    dpi=300,
                )
        plt.close(figure)
    with pymupdf.open(output.with_suffix(".pdf")) as document:
        page = document[0]
        spans = [
            s
            for block in page.get_text("dict")["blocks"]
            for line in block.get("lines", [])
            for s in line["spans"]
            if s["text"].strip()
        ]
        final_width = 364.249 if poster else 160.02
        scale = final_width / (page.rect.width / 72 * 25.4)
        minimum = min(span["size"] for span in spans) * scale
        final_height = page.rect.height / 72 * 25.4 * scale
        if minimum < (24.5 if poster else 8) - 1e-6:
            raise RuntimeError("The exported text is below the final-size minimum.")
    return {
        "status": status,
        "model": model,
        "profile": profile,
        "presentation": "reference_language_scatter",
        "fresh_measurement": status == "accepted",
        "cohort": data.get("cohort"),
        "point_definition": data.get("point_definition"),
        "displayed_rate_definition": data.get("displayed_rate_definition"),
        "row_order": list(LABELS),
        "row_routes": list(ROUTES),
        "visible_group_labels": list(GROUP_LABELS),
        "group_label_encoding": (
            "poster_language_logos_with_esm_text" if poster else "text"
        ),
        "text_group_labels": ["ESM.md"] if poster else list(GROUP_LABELS),
        "language_logos": logo_records,
        "language_logo_exports": logo_exports,
        "group_positions": list(GROUP_POSITIONS),
        "vanilla_marker_hatch_rows": [3, 5, 7],
        "hatched_background_bands": False,
        "marker_size_pt": 9.0 if poster else 4.0,
        "within_row_grid_offset": 0.29,
        "group_separator_positions": [0.5, 1.5, 3.5, 5.5],
        "group_separator_alpha": 0.15,
        "esm_highlight_row_index": 1,
        "grid_colour_shape_key": [
            {"size": grid, "colour": colour, "marker": marker}
            for grid, colour, marker in zip(SIZES[model], COLOURS, MARKERS)
        ],
        "axes": axis_records,
        "horizontal_alignment": alignment,
        "final_width_mm": final_width,
        "final_height_mm": final_height,
        "minimum_effective_font_pt": minimum,
        "displayed_measurements": displayed,
        "source_input": data if status != "accepted" else None,
        "accepted_source_ids": data.get("sources", {}),
        "acceptance_ids": data.get("acceptance", {}),
        "scope": (
            "Archived data are private layout-only observations and Assembly remains empty Pending."
            if status != "accepted"
            else "Accepted supplied summaries are drawn unchanged. Metadata checks do not repeat scientific verification."
        ),
        "findings": issues,
        "outputs": {
            portable_path(file, poster_root, status == "accepted"): hashlib.sha256(
                file.read_bytes()
            ).hexdigest()
            for file in files
        },
    }


def main():
    """Render a selected publication profile and write its encoding receipt."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--model", choices=("sw", "ebm"), required=True)
    parser.add_argument("--profile", choices=("poster", "paper"), required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--poster-root", type=Path, default=ROOT)
    parser.add_argument("--layout-draft", action="store_true")
    parser.add_argument("--font-file", type=Path)
    args = parser.parse_args()
    input_bytes = args.input.read_bytes()
    data = json.loads(input_bytes)
    if data.get("status") == "accepted":
        for path in (args.input, args.output, Path(__file__)):
            portable_path(path, args.poster_root, True)
    receipt = render(
        data,
        args.model,
        args.profile,
        args.output,
        args.poster_root,
        args.layout_draft,
        args.font_file,
    )
    receipt["input_identity"] = {
        "path": portable_path(
            args.input, args.poster_root, receipt["status"] == "accepted"
        ),
        "sha256": hashlib.sha256(input_bytes).hexdigest(),
    }
    receipt["renderer_identity"] = {
        "path": portable_path(
            Path(__file__), args.poster_root, receipt["status"] == "accepted"
        ),
        "sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    }
    args.output.with_suffix(".json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(
        json.dumps(
            {
                key: receipt[key]
                for key in (
                    "status",
                    "model",
                    "profile",
                    "final_width_mm",
                    "final_height_mm",
                    "minimum_effective_font_pt",
                )
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

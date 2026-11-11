"""Render manuscript physical illustrations from accepted binary states."""

import hashlib
import importlib.metadata
import json
import os
import struct
import sys
from pathlib import Path

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]
FINAL = ROOT / "paper/pasc27/submission/figures"
LOCAL = FINAL.parent / ".scratch/figure_units/physics"
STYLE = POSTER / "scripts/style"
os.environ.setdefault("MPLCONFIGDIR", str(LOCAL / "matplotlib"))
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pymupdf
import shapefile
from matplotlib.patches import Circle

sys.path.insert(0, str(STYLE))
import mpl_style as style

# Keep the bundled style self-contained while preserving the licensed paper font.
style.FONT_FILES = (
    POSTER / "assets/OpenSans-Regular.ttf",
    POSTER / "assets/OpenSans-Bold.ttf",
)

SOURCES = {}
AUDITS = {}


def source_bytes(name):
    """Read a retained binary state and record its identity.

    Parameters
    ----------
    name : str
        Accepted source filename below the poster data folder.

    Returns
    -------
    bytes
        Unmodified contents of the retained state file.
    """
    path = POSTER / "data" / name
    contents = path.read_bytes()
    SOURCES[str(path.relative_to(ROOT))] = hashlib.sha256(contents).hexdigest()
    return contents


def export_figure(figure, name, auxiliary_axis=None):
    """Audit a figure and save fixed-size vector artwork with local previews.

    Parameters
    ----------
    figure : matplotlib.figure.Figure
        Figure containing the accepted observations and readable text.
    name : str
        Hyphenated final PDF filename stem.
    auxiliary_axis : matplotlib.axes.Axes or None
        Optional colour-bar axis whose short height is intentional.

    Returns
    -------
    None
        Writes the final PDF and local preview and audit records.

    Raises
    ------
    RuntimeError
        If a material font, data-panel geometry or clipping issue is found.

    Notes
    -----
    Ordinary panels keep the style helper's default size limits. Only the
    explicitly identified colour bar receives a recorded geometry exception.
    """
    figure.canvas.draw()
    findings = style.audit_figure(
        figure, expected_font="Helvetica Neue", min_font_size=7
    )
    auxiliary_findings = []
    if auxiliary_axis is not None:
        prefix = f"Axis {figure.axes.index(auxiliary_axis) + 1} is "
        auxiliary_findings = [item for item in findings if item.startswith(prefix)]
        findings = [item for item in findings if not item.startswith(prefix)]
    if findings:
        raise RuntimeError(str(findings))
    LOCAL.mkdir(parents=True, exist_ok=True)
    FINAL.mkdir(parents=True, exist_ok=True)
    style.save_figure(figure, LOCAL / name)
    # The tight vector export retains every label, and its actual dimensions are recorded.
    final = FINAL / (name + ".pdf")
    figure.savefig(
        final,
        bbox_inches="tight",
        metadata={
            "Title": name.replace("-", " "),
            "Creator": "Matplotlib from retained canonical model states",
        },
    )
    plt.close(figure)
    with pymupdf.open(final) as document:
        page = document[0]
        page.get_pixmap(matrix=pymupdf.Matrix(3, 3), alpha=False).save(
            LOCAL / (name + "-final.png")
        )
        sizes = [
            span["size"]
            for block in page.get_text("dict")["blocks"]
            if "lines" in block
            for line in block["lines"]
            for span in line["spans"]
            if span["text"].strip()
        ]
        boxes = [
            span["bbox"]
            for block in page.get_text("dict")["blocks"]
            if "lines" in block
            for line in block["lines"]
            for span in line["spans"]
            if span["text"].strip()
        ]
        if min(sizes) < 7 - 1e-5:
            raise RuntimeError("The saved PDF contains text below seven points.")
        outside = [
            box
            for box in boxes
            if box[0] < -0.25
            or box[1] < -0.25
            or box[2] > page.rect.width + 0.25
            or box[3] > page.rect.height + 0.25
        ]
        if outside:
            raise RuntimeError("The saved PDF has clipped text. " + str(outside))
        AUDITS[name] = {
            "pdf": str(final.relative_to(ROOT)),
            "canvas_points": list(page.rect),
            "actual_canvas_inches": [page.rect.width / 72, page.rect.height / 72],
            "minimum_pdf_font_points": min(sizes),
            "effective_minimum_at_7_inch_width": min(sizes) * 504 / page.rect.width,
            "findings": findings,
            "reviewed_auxiliary_geometry_findings": auxiliary_findings,
            "sha256": hashlib.sha256(final.read_bytes()).hexdigest(),
        }


def water_figure():
    """Draw the accepted water-depth surface and a representative cross-section.

    Returns
    -------
    dict
        Time, grid, field limits and unchanged continuous colour mapping.
    """
    header = struct.Struct("<8sQQQQ5d")
    final_bytes = source_bytes("dam-x-256x8-370-fortran_vanilla-p2.bin")
    initial_bytes = source_bytes("dam-x-256x8-370-input.bin")
    values = header.unpack_from(final_bytes)
    nx, ny = int(values[1]), int(values[2])
    state = np.frombuffer(final_bytes, dtype="<f8", offset=header.size).reshape(
        3, ny, nx
    )
    initial = np.frombuffer(initial_bytes, dtype="<f8", offset=header.size).reshape(
        3, ny, nx
    )
    if values[0] != b"ESMSW001" or not np.isfinite(state).all():
        raise ValueError("The accepted shallow-water state is not readable.")
    x = (np.arange(nx) + 0.5) / nx
    y = (np.arange(ny) + 0.5) / ny
    xx, yy = np.meshgrid(x, y)
    figure = plt.figure(figsize=(7.2, 2.7))
    surface = figure.add_axes([0.005, 0.13, 0.53, 0.84], projection="3d")
    surface.plot_surface(
        xx,
        yy,
        state[0],
        cmap="jet",
        vmin=1,
        vmax=2,
        rstride=1,
        cstride=3,
        linewidth=0.22,
        edgecolor="#5F7882",
        antialiased=True,
    )
    surface.view_init(elev=24, azim=-55)
    surface.set_box_aspect((1.3, 1, 0.55))
    surface.set_xlabel("x [m]", labelpad=2)
    surface.set_ylabel("y [m]", labelpad=2)
    surface.set_zlabel("Depth [m]", labelpad=1)
    surface.set_xlim(0, 1)
    surface.set_ylim(0, 1)
    surface.set_zlim(1, 2)
    surface.set_xticks([0, 0.5, 1])
    surface.set_yticks([0, 1])
    surface.set_zticks([1, 1.5, 2])
    surface.tick_params(labelsize=8, pad=0)
    cross = figure.add_axes([0.625, 0.20, 0.35, 0.73])
    cross.plot(
        x,
        initial[0, 0],
        color="#29347A",
        linestyle="--",
        linewidth=1.0,
        label="Initial",
    )
    cross.plot(x, state[0, 0], color="#00BDB6", linewidth=1.25, label="Evolved")
    cross.set_xlabel("x [m]")
    cross.set_ylabel("Depth [m]")
    cross.set_xlim(0, 1)
    cross.set_ylim(0.95, 2.1)
    cross.set_xticks([0, 0.5, 1])
    cross.set_yticks([1, 1.5, 2])
    style.finish_axis(cross)
    style.place_legend(cross, loc="upper right", frameon=False, fontsize=8)
    figure.text(0.025, 0.96, "a", fontweight="bold", fontsize=10)
    figure.text(0.55, 0.96, "b", fontweight="bold", fontsize=10)
    export_figure(figure, "water-behaviour")
    return {
        "grid": [nx, ny],
        "steps": int(values[3]),
        "time_seconds": values[-1],
        "cross_section_y_m": float(y[0]),
        "depth_range_m": [float(state[0].min()), float(state[0].max())],
        "colour_map": "jet",
        "colour_limits_m": [1, 2],
        "surface_view": {
            "elevation_degrees": 24,
            "azimuth_degrees": -55,
            "row_stride": 1,
            "column_stride": 3,
        },
    }


def geographic_outlines(axis):
    """Add the retained geographic context without modifying the thermal field.

    Parameters
    ----------
    axis : matplotlib.axes.Axes
        Axis for the orthographic globe centred on twenty degrees east.

    Returns
    -------
    int
        Number of country rings projected and clipped to the globe.
    """
    path = POSTER / "assets/natural-earth/ne_110m_admin_0_countries.shp"
    SOURCES[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
    reader = shapefile.Reader(str(path))
    edge = Circle((0, 0), 1, fill=False, edgecolor="#133844", linewidth=0.5)
    axis.add_patch(edge)
    rings = 0
    for country in reader.shapes():
        stops = list(country.parts) + [len(country.points)]
        for start, stop in zip(stops[:-1], stops[1:]):
            points = np.asarray(country.points[start:stop], dtype=float)
            dense = []
            for first, last in zip(points[:-1], points[1:]):
                dlon = (last[0] - first[0] + 180) % 360 - 180
                dlat = last[1] - first[1]
                count = max(1, int(np.ceil(max(abs(dlon), abs(dlat)))))
                weight = np.arange(count) / count
                dense.extend(
                    np.column_stack(
                        (first[0] + weight * dlon, first[1] + weight * dlat)
                    )
                )
            dense = np.asarray(dense)
            lon = np.radians(dense[:, 0] - 20)
            latitude = np.radians(dense[:, 1])
            xx = np.cos(latitude) * np.sin(lon)
            yy = np.sin(latitude)
            visible = np.cos(latitude) * np.cos(lon) >= 0
            xx[~visible] = np.nan
            yy[~visible] = np.nan
            (line,) = axis.plot(
                xx, yy, color="#133844", linewidth=0.35, alpha=0.78, zorder=4
            )
            line.set_clip_path(edge)
            rings += 1
    return rings


def energy_figure():
    """Draw the accepted latitude-only temperature field and its profile.

    Returns
    -------
    dict
        Model time, temperatures, units and geographic-context limits.
    """
    header = struct.Struct("<8sQQQ7d")
    raw = source_bytes("timed-128-reference-p2.bin")
    start = source_bytes("timed-128-input.bin")
    values = header.unpack_from(raw)
    n = int(values[1])
    temperature = np.frombuffer(raw, dtype="<f8", offset=header.size, count=n)
    initial = np.frombuffer(start, dtype="<f8", offset=header.size, count=n)
    if values[0] != b"ESMEB001" or not np.isfinite(temperature).all():
        raise ValueError("The accepted energy-balance state is not readable.")
    latitude = np.degrees(np.arcsin(-1 + (np.arange(n) + 0.5) * 2 / n))
    figure = plt.figure(figsize=(7.2, 2.7))
    globe = figure.add_axes([0.025, 0.20, 0.43, 0.79])
    grid = np.linspace(-1, 1, 500)
    gx, gy = np.meshgrid(grid, grid)
    indices = np.clip(((gy + 1) * n / 2).astype(int), 0, n - 1)
    field = np.ma.array(temperature[indices], mask=gx * gx + gy * gy > 1)
    cmap = plt.get_cmap("coolwarm").copy()
    cmap.set_bad("white", 1)
    limits = [float(temperature.min()), float(temperature.max())]
    image = globe.imshow(
        field,
        origin="lower",
        extent=(-1, 1, -1, 1),
        cmap=cmap,
        vmin=limits[0],
        vmax=limits[1],
        interpolation="nearest",
    )
    for angle in (-60, -30, 0, 30, 60):
        yy = np.sin(np.radians(angle))
        xx = np.sqrt(1 - yy * yy)
        globe.plot([-xx, xx], [yy, yy], color="white", linewidth=0.4, alpha=0.7)
    for angle in (-60, -30, 30, 60):
        yy = np.linspace(-1, 1, 200)
        xx = np.sin(np.radians(angle)) * np.sqrt(np.maximum(0, 1 - yy * yy))
        globe.plot(xx, yy, color="white", linewidth=0.35, alpha=0.45)
    rings = geographic_outlines(globe)
    globe.set_aspect("equal")
    globe.set_axis_off()
    profile = figure.add_axes([0.56, 0.20, 0.415, 0.73])
    profile.plot(
        latitude,
        initial,
        color="#29347A",
        linestyle="--",
        linewidth=1.0,
        label="Initial",
    )
    profile.plot(
        latitude, temperature, color="#00BDB6", linewidth=1.25, label="Evolved"
    )
    profile.set_xlabel("Latitude [degrees]")
    profile.set_ylabel("Temperature [°C]")
    profile.set_xlim(-90, 90)
    profile.set_xticks([-90, 0, 90])
    style.finish_axis(profile)
    style.place_legend(profile, loc="upper right", frameon=False, fontsize=8)
    cax = figure.add_axes([0.09, 0.14, 0.30, 0.04])
    colourbar = figure.colorbar(image, cax=cax, orientation="horizontal")
    colourbar.set_label("Temperature [°C]", fontsize=8, labelpad=2)
    colourbar.ax.tick_params(labelsize=8, length=2, pad=1)
    colourbar.set_ticks([-10, 0, 10, 20])
    figure.text(0.025, 0.96, "a", fontweight="bold", fontsize=10)
    figure.text(0.50, 0.96, "b", fontweight="bold", fontsize=10)
    export_figure(figure, "energy-behaviour", auxiliary_axis=cax)
    return {
        "bands": n,
        "steps": int(values[2]),
        "time_seconds": values[-1],
        "time_years": values[-1] / 31557600,
        "colour_map": "coolwarm",
        "temperature_limits_degC": limits,
        "geography": {
            "country_rings": rings,
            "projection": "Orthographic, centred on 20 degrees east and the equator",
            "geographic_context_only": True,
        },
        "longitude_dependent_temperature": False,
    }


def main():
    """Render both accepted physical illustrations and write their local source record."""
    settings = {
        "font.size": 8,
        "axes.labelsize": 8,
        "xtick.labelsize": 8,
        "ytick.labelsize": 8,
        "legend.fontsize": 8,
        "lines.linewidth": 0.8,
        "axes.linewidth": 0.7,
        "pdf.fonttype": 42,
    }
    with style.publication_style(
        settings, font_family="Helvetica Neue", project_root=ROOT
    ):
        physical = {"water": water_figure(), "energy": energy_figure()}
    record = {
        "font": "Helvetica Neue",
        "source_data_sha256": SOURCES,
        "physical": physical,
        "figure_audits": AUDITS,
        "graph_style": str(STYLE.relative_to(ROOT)),
        "tools": {
            name: importlib.metadata.version(name)
            for name in ["numpy", "matplotlib", "pyshp", "PyMuPDF"]
        },
    }
    (LOCAL / "physical-figure-audit.json").write_text(
        json.dumps(record, indent=2) + "\n"
    )
    print(json.dumps(record, indent=2))


if __name__ == "__main__":
    main()

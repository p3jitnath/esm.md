"""Build reproducible poster figures from accepted simulation records."""

from pathlib import Path
import sys, os, json, struct, shutil, hashlib

POSTER = Path(__file__).resolve().parents[1]
ROOT = POSTER.parents[2]
OUT = POSTER
os.environ["MPLCONFIGDIR"] = str(ROOT / ".runtime/cache/matplotlib")
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager
import numpy as np
import shapefile
from matplotlib.patches import Circle
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

FONT = OUT / "assets/OpenSans-variable.ttf"
for weight, name in [(400, "Regular"), (700, "Bold")]:
    target = OUT / "assets" / f"OpenSans-{name}.ttf"
    if not target.exists():
        ft = instantiateVariableFont(
            TTFont(FONT), {"wght": weight, "wdth": 100}, inplace=False
        )
        for record in ft["name"].names:
            if record.nameID in (1, 16):
                record.string = "Open Sans".encode(record.getEncoding())
            elif record.nameID in (2, 17):
                record.string = name.encode(record.getEncoding())
            elif record.nameID == 4:
                record.string = ("Open Sans " + name).encode(record.getEncoding())
            elif record.nameID == 6:
                record.string = ("OpenSans-" + name).encode(record.getEncoding())
        ft.save(target)
    font_manager.fontManager.addfont(target)
sys.path.insert(0, str(POSTER / "scripts/style"))
import mpl_style as style

style.SUPPORTED_FONT_FAMILIES += ("Open Sans",)
style.FONT_FILES = (
    OUT / "assets/OpenSans-Regular.ttf",
    OUT / "assets/OpenSans-Bold.ttf",
)
from mpl_style import (
    publication_style,
    audit_figure,
    finish_axis,
    place_legend,
    save_figure,
)

DATA = json.loads((OUT / "data/historical/benchmark.json").read_text())
C = {
    "assembly": "#133844",
    "fortran": "#681FB1",
    "julia": "#00BDB6",
    "python": "#29347A",
}
names = (
    "assembly",
    "fortran",
    "fortran_vanilla",
    "julia",
    "julia_vanilla",
    "python",
    "python_vanilla",
)
labels = (
    "Assembly",
    "Fortran · tuned",
    "Fortran · vanilla",
    "Julia · tuned",
    "Julia · vanilla",
    "Python · tuned",
    "Python · vanilla",
)
audits = {}


def export(fig, name, minfont=22):
    """Audit and save a physical figure in editable and raster forms.

    Parameters
    ----------
    fig : matplotlib.figure.Figure
        Figure to inspect and close after export.
    name : str
        Filename stem below the figures directory.
    minfont : float
        Smallest permitted type size in points.

    Returns
    -------
    None
        Saves PDF, SVG and PNG artwork and appends an audit record.

    Raises
    ------
    RuntimeError
        If the font or geometry audit reports a material issue.
    """
    issues = audit_figure(
        fig, expected_font="Open Sans", min_font_size=minfont, min_panel_height=0.1
    )
    # The short horizontal colour bar is intentionally exempt from ordinary panel height.
    if issues:
        raise RuntimeError(name + ": " + str(issues))
    paths = save_figure(fig, OUT / "figures" / name)
    fig.savefig(OUT / "figures" / f"{name}.svg", bbox_inches="tight", pad_inches=0.08)
    audits[name] = {
        "findings": issues,
        "inches": list(fig.get_size_inches()),
        "minimum_font_pt": minfont,
        "exports": [str(x.relative_to(ROOT)) for x in paths],
    }
    plt.close(fig)


over = {
    "font.size": 24,
    "axes.labelsize": 24,
    "axes.titlesize": 28,
    "xtick.labelsize": 24,
    "ytick.labelsize": 24,
    "legend.fontsize": 24,
    "lines.linewidth": 2.1,
    "axes.linewidth": 1.3,
    "svg.fonttype": "path",
    "mathtext.fontset": "dejavusans",
}
with publication_style(over, font_family="Open Sans", project_root=ROOT):
    # The shallow-water figure uses an accepted, byte-identical dam-release case.
    sh = struct.Struct("<8sQQQQ5d")
    source = OUT / "data/dam-x-256x8-370-fortran_vanilla-p2.bin"
    initial = OUT / "data/dam-x-256x8-370-input.bin"
    b = source.read_bytes()
    head = sh.unpack_from(b)
    nx, ny = int(head[1]), int(head[2])
    final = np.frombuffer(b, dtype="<f8", offset=sh.size).reshape(3, ny, nx)
    first = np.frombuffer(initial.read_bytes(), dtype="<f8", offset=sh.size).reshape(
        3, ny, nx
    )
    assert head[0] == b"ESMSW001" and np.isfinite(final).all()
    x = (np.arange(nx) + 0.5) / nx
    y = (np.arange(ny) + 0.5) / ny
    fig = plt.figure(figsize=(13.8, 8.1))
    ax = fig.add_axes([0.00, 0.16, 0.64, 0.79], projection="3d")
    X, Y = np.meshgrid(x, y)
    cmap = plt.get_cmap("jet")
    ax.plot_surface(
        X,
        Y,
        final[0],
        cmap=cmap,
        vmin=1,
        vmax=2,
        rstride=1,
        cstride=3,
        linewidth=0.35,
        edgecolor="#5F7882",
        antialiased=True,
    )
    ax.view_init(elev=24, azim=-55)
    ax.set_xlabel("x [m]", labelpad=48)
    ax.set_ylabel("y [m]", labelpad=44)
    ax.set_zlabel("Depth [m]", labelpad=30)
    ax.set_xticks([0, 0.5, 1])
    ax.set_yticks([0, 1])
    ax.set_zticks([1, 1.5, 2])
    ax.tick_params(pad=2, labelsize=24)
    ax.tick_params(axis="y", pad=32)
    ax.tick_params(axis="z", pad=14)
    ax.set_box_aspect((1.3, 1, 0.55))
    ax2 = fig.add_axes([0.68, 0.21, 0.29, 0.72])
    ax2.plot(
        x, first[0, 0], color="#29347A", linestyle="--", linewidth=2.5, label="Initial"
    )
    ax2.plot(x, final[0, 0], color="#00BDB6", linewidth=3.3, label="Evolved")
    ax2.set_xlabel("x [m]")
    ax2.set_ylabel("Depth [m]")
    ax2.set_xlim(0, 1)
    ax2.set_ylim(0.95, 2.1)
    ax2.set_xticks([0, 0.5, 1])
    ax2.set_yticks([1, 1.5, 2])
    finish_axis(ax2)
    ax2.yaxis.tick_right()
    ax2.yaxis.set_label_position("right")
    ax2.spines["right"].set_visible(True)
    ax2.spines["left"].set_visible(False)
    place_legend(ax2, loc="upper right", frameon=False, fontsize=24)
    export(fig, "shallow-water", 24)
    # Temperature values come from the timed canonical 128-band simulation.
    eh = struct.Struct("<8sQQQ7d")
    epath = OUT / "data/timed-128-reference-p2.bin"
    ipath = OUT / "data/timed-128-input.bin"
    raw = epath.read_bytes()
    h = eh.unpack_from(raw)
    n = int(h[1])
    temp = np.frombuffer(raw, dtype="<f8", offset=eh.size, count=n)
    init = np.frombuffer(ipath.read_bytes(), dtype="<f8", offset=eh.size, count=n)
    mu = -1 + (np.arange(n) + 0.5) * 2 / n
    lat = np.degrees(np.arcsin(mu))
    assert h[0] == b"ESMEB001" and np.isfinite(temp).all()
    years = h[-1] / 31557600
    fig = plt.figure(figsize=(13.8, 8.1))
    ax = fig.add_axes([0.015, 0.21, 0.48, 0.78])
    grid = np.linspace(-1, 1, 500)
    gx, gy = np.meshgrid(grid, grid)
    indices = np.minimum(n - 1, np.maximum(0, ((gy + 1) * n / 2).astype(int)))
    globe = np.ma.array(temp[indices], mask=gx * gx + gy * gy > 1)
    cmap = plt.get_cmap("coolwarm")
    cmap.set_bad("white", 1.0)
    im = ax.imshow(
        globe,
        origin="lower",
        extent=(-1, 1, -1, 1),
        cmap=cmap,
        vmin=float(temp.min()),
        vmax=float(temp.max()),
        interpolation="nearest",
    )
    for la in (-60, -30, 0, 30, 60):
        yy = np.sin(np.radians(la))
        xx = np.sqrt(1 - yy * yy)
        ax.plot([-xx, xx], [yy, yy], color="white", linewidth=1.4, alpha=0.7)
    for angle in (-60, -30, 30, 60):
        yy = np.linspace(-1, 1, 200)
        xx = np.sin(np.radians(angle)) * np.sqrt(np.maximum(0, 1 - yy * yy))
        ax.plot(xx, yy, color="white", linewidth=1.2, alpha=0.45)
    # Country outlines give geographic context without changing the model field.
    country_file = OUT / "assets/natural-earth/ne_110m_admin_0_countries.shp"
    countries = shapefile.Reader(str(country_file))
    globe_edge = Circle((0, 0), 1, fill=False, edgecolor="#133844", linewidth=1.2)
    ax.add_patch(globe_edge)
    country_rings = 0
    for country in countries.shapes():
        limits = list(country.parts) + [len(country.points)]
        for start, stop in zip(limits[:-1], limits[1:]):
            points = np.asarray(country.points[start:stop], dtype=float)
            dense = []
            for first, last in zip(points[:-1], points[1:]):
                delta_lon = (last[0] - first[0] + 180) % 360 - 180
                delta_lat = last[1] - first[1]
                count = max(1, int(np.ceil(max(abs(delta_lon), abs(delta_lat)))))
                weight = np.arange(count) / count
                dense.extend(
                    np.column_stack(
                        (first[0] + weight * delta_lon, first[1] + weight * delta_lat)
                    )
                )
            dense = np.asarray(dense)
            lon = np.radians(dense[:, 0] - 20)
            latitude = np.radians(dense[:, 1])
            xx = np.cos(latitude) * np.sin(lon)
            yy = np.sin(latitude)
            front = np.cos(latitude) * np.cos(lon) >= 0
            assert np.all(xx * xx + yy * yy <= 1 + 1e-12)
            xx[~front] = np.nan
            yy[~front] = np.nan
            (outline,) = ax.plot(
                xx, yy, color="#133844", linewidth=1.15, alpha=0.78, zorder=4
            )
            outline.set_clip_path(globe_edge)
            country_rings += 1
    ax.set_aspect("equal")
    ax.set_axis_off()
    cax = fig.add_axes([0.04, 0.12, 0.42, 0.035])
    cb = fig.colorbar(im, cax=cax, orientation="horizontal")
    cb.set_label("Temperature [°C]", fontsize=24, labelpad=5)
    cb.ax.tick_params(labelsize=24)
    ax2 = fig.add_axes([0.62, 0.21, 0.355, 0.74])
    ax2.plot(lat, init, color="#29347A", linestyle="--", linewidth=2.5, label="Initial")
    ax2.plot(lat, temp, color="#00BDB6", linewidth=3.3, label="Evolved")
    ax2.set_xlabel("Latitude [degrees]")
    ax2.set_ylabel("Temperature [°C]")
    ax2.set_xlim(-90, 90)
    ax2.set_xticks([-90, 0, 90])
    finish_axis(ax2)
    place_legend(ax2, loc="best", frameon=False, fontsize=24)
    export(fig, "energy-balance", 24)
    # This is the water-conservation equation from P01 in the actual formulation.
    fig = plt.figure(figsize=(12, 1.2))
    fig.patch.set_alpha(0)
    fig.text(
        0.5,
        0.52,
        r"$\frac{\partial h}{\partial t}+\frac{\partial(hu)}{\partial x}+\frac{\partial(hv)}{\partial y}=0$",
        ha="center",
        va="center",
        fontsize=40,
        color="#133844",
    )
    export(fig, "physics-note-mass", 40)
metadata = {
    "dam_time_seconds": head[-1],
    "ebm_time_years": years,
    "ebm_temperature_range_degC": [float(temp.min()), float(temp.max())],
    "source_sha256": {
        p.name: hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (source, initial, epath, ipath)
    },
    "figure_audits": audits,
    "font": "Open Sans",
    "graph_style": "scripts/style/mpl_style.py",
    "bar_value_padding_pt": 8,
    "surface_tick_padding_pt": {"x": 2, "y": 32, "depth": 14},
    "surface_axis_label_padding_pt": {"x": 48, "y": 44, "depth": 30},
}
metadata["geography"] = {
    "source": "assets/natural-earth/provenance.json",
    "country_rings": country_rings,
    "projection": "Orthographic, centred on 20 degrees east and the equator",
    "geographic_context_only": True,
    "data_sha256": hashlib.sha256(country_file.read_bytes()).hexdigest(),
}
metadata["physics_note_equation"] = {
    "source": "formulations/sw/dam_break.md",
    "equation_id": "P01",
    "meaning": "Conservation of water",
    "formulation_sha256": hashlib.sha256(
        (ROOT / "formulations/sw/dam_break.md").read_bytes()
    ).hexdigest(),
}
metadata["continuous_colormaps"] = {
    "shallow_water": {"name": "jet", "limits_m": [1, 2]},
    "energy_balance": {
        "name": "coolwarm",
        "limits_degC": [float(temp.min()), float(temp.max())],
    },
}
metadata["surface_mesh"] = {
    "edge_colour": "#5F7882",
    "line_width_pt": 0.35,
    "row_stride": 1,
    "column_stride": 3,
    "requested_by_author": True,
}
(OUT / "figure-evidence.json").write_text(json.dumps(metadata, indent=2) + "\n")
print(json.dumps(metadata), flush=True)

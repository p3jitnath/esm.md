"""Publication style adapted from the pinned graph-plotting helper.

Only font lookup and explicit font-file registration change. The remaining style, audit and export APIs retain the
pinned implementation. See publication_plot_style_provenance.json beside this file.
"""

from contextlib import contextmanager
from pathlib import Path
import warnings

import matplotlib as mpl
import numpy as np
from matplotlib import font_manager

ASSET_DIRECTORY = Path(__file__).resolve().parent.parent / "assets"
FONT_FILES = tuple(
    ASSET_DIRECTORY / name for name in ("OpenSans-Regular.ttf", "OpenSans-Bold.ttf")
)
SUPPORTED_FONT_FAMILIES = ("Nimbus Sans", "Helvetica", "Helvetica Neue", "Open Sans")

OBSERVED_COLOUR = "#222222"
BASE_COLOUR = "#4C78A8"
CORRECTED_COLOUR = "#E45756"
NEUTRAL_COLOUR = "#595959"
PALETTE = (BASE_COLOUR, CORRECTED_COLOUR, "#54A24B", "#B279A2", "#F2CF5B")


_EXPLICIT_FONT_FILES = {}


def configure_font_file(font_family, font_file):
    """Register a caller-supplied font file without searching external directories.

    Parameters
    ----------
    font_family : str
        Declared family that must match the supplied file.
    font_file : str or pathlib.Path
        Runtime input chosen by the caller. The file is never copied into the bundle.

    Raises
    ------
    FileNotFoundError
        If the supplied font file is absent.
    ValueError
        If its reported family differs from the declared family.
    """
    path = Path(font_file).expanduser().resolve()
    if not path.is_file():
        raise FileNotFoundError("The supplied font file is absent.")
    actual_family = font_manager.FontProperties(fname=str(path)).get_name()
    if actual_family != font_family:
        raise ValueError(
            "The supplied font family is "
            + actual_family
            + ", rather than "
            + font_family
            + "."
        )
    font_manager.fontManager.ttflist[:] = [
        entry for entry in font_manager.fontManager.ttflist if entry.name != font_family
    ]
    font_manager.fontManager.addfont(str(path))
    _EXPLICIT_FONT_FILES[font_family] = path


def register_fonts(font_family="Helvetica Neue", project_root=None):
    """Resolve the declared family without silently substituting another font.

    Parameters
    ----------
    font_family : str
        Manuscript figures require Helvetica Neue by default and posters require Open Sans.
    project_root : pathlib.Path or None
        Retained for compatibility. It does not change font lookup.

    Raises
    ------
    FileNotFoundError
        If a bundled Open Sans file or the declared installed family is absent.
    ValueError
        If the family is outside the supported profiles.

    Notes
    -----
    Open Sans uses relative publication assets. Other declared font families use
    standard Matplotlib registration with fallback disabled. A caller may supply
    an optional font file at runtime, without adding it to the publication bundle.
    """
    del project_root
    if font_family not in SUPPORTED_FONT_FAMILIES:
        raise ValueError("Unsupported publication font family " + str(font_family))
    if font_family in _EXPLICIT_FONT_FILES:
        font_manager.fontManager.addfont(str(_EXPLICIT_FONT_FILES[font_family]))
    elif font_family == "Open Sans":
        if any(not path.is_file() for path in FONT_FILES):
            raise FileNotFoundError("Missing bundled Open Sans regular or bold asset.")
        allowed = {path.resolve() for path in FONT_FILES}
        font_manager.fontManager.ttflist[:] = [
            entry
            for entry in font_manager.fontManager.ttflist
            if entry.name != font_family or Path(entry.fname).resolve() in allowed
        ]
        for path in FONT_FILES:
            font_manager.fontManager.addfont(str(path))
    try:
        font_manager.findfont(
            font_manager.FontProperties(family=font_family), fallback_to_default=False
        )
    except ValueError as error:
        raise FileNotFoundError(
            "Required font family "
            + font_family
            + " is not registered. Install that family or provide an explicit font file at runtime. No fallback family was selected."
        ) from error


def rc_params(overrides=None, font_family="Helvetica Neue"):
    """Return the canonical manuscript rcParams, optionally overridden."""
    params = {
        "font.family": "sans-serif",
        "font.sans-serif": [font_family, "Nimbus Sans", "DejaVu Sans"],
        "font.size": 8,
        "axes.labelsize": 8,
        "axes.titlesize": 9,
        "axes.linewidth": 0.7,
        "xtick.labelsize": 8,
        "ytick.labelsize": 8,
        "xtick.major.width": 0.7,
        "ytick.major.width": 0.7,
        "xtick.minor.width": 0.5,
        "ytick.minor.width": 0.5,
        "legend.fontsize": 8,
        "legend.frameon": False,
        "lines.linewidth": 1.2,
        "patch.linewidth": 0.7,
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
        "svg.fonttype": "none",
        "mathtext.fontset": "custom",
        "mathtext.rm": font_family,
        "mathtext.it": "{}:italic".format(font_family),
        "mathtext.bf": "{}:bold".format(font_family),
        "savefig.bbox": "tight",
    }
    if overrides:
        params.update(overrides)
    return params


@contextmanager
def publication_style(
    overrides=None,
    font_family="Helvetica Neue",
    project_root=None,
):
    """Apply the declared font profile and canonical style without leaking global state."""
    register_fonts(font_family, project_root=project_root)
    with mpl.rc_context(rc=rc_params(overrides, font_family=font_family)):
        yield


def finish_axis(axis):
    """Apply the standard open-frame treatment to a Cartesian axis."""
    axis.spines[["top", "right"]].set_visible(False)
    axis.tick_params(direction="out")


def set_panel_title(axis, title, pad=3.0, linespacing=1.15, **kwargs):
    """Set a compact 9-pt panel title with controlled frame clearance."""
    kwargs.setdefault("fontsize", 9)
    title_artist = axis.set_title(title, pad=pad, **kwargs)
    title_artist.set_linespacing(linespacing)
    return title_artist


def add_sample_sizes(axis, counts, positions=None, y=-0.12, **kwargs):
    """Place ``n=`` annotations directly beneath categorical tick labels."""
    counts_tuple = tuple(counts)
    positions_tuple = tuple(axis.get_xticks() if positions is None else positions)
    if len(counts_tuple) != len(positions_tuple):
        raise ValueError("Provide exactly one sample size per category position")
    kwargs.setdefault("fontsize", 7)
    kwargs.setdefault("color", NEUTRAL_COLOUR)
    kwargs.setdefault("ha", "center")
    kwargs.setdefault("va", "top")
    artists = []
    for position, count in zip(positions_tuple, counts_tuple):
        artist = axis.text(
            position,
            y,
            "n={}".format(count),
            transform=axis.get_xaxis_transform(),
            **kwargs,
        )
        artist.set_gid("sample-size")
        artists.append(artist)
    return tuple(artists)


def add_panel_labels(
    axes,
    labels=None,
    *,
    x=-0.12,
    y=None,
):
    """Add panel labels vertically centred with each axis title."""
    axes_tuple = tuple(axes)
    labels_tuple = (
        tuple(labels)
        if labels is not None
        else tuple(chr(ord("a") + index) for index in range(len(axes_tuple)))
    )
    if len(axes_tuple) != len(labels_tuple):
        raise ValueError("Provide exactly one label per axis")
    for axis, label in zip(axes_tuple, labels_tuple):
        title = axis.title
        label_y = title.get_position()[1] if y is None and title.get_text() else 1.03
        if y is not None:
            label_y = y
        if title.get_text() and y is None:
            title.set_verticalalignment("center")
        panel_text = axis.text(
            x,
            label_y,
            label,
            transform=axis.transAxes,
            fontweight="bold",
            fontsize=10,
            ha="left",
            va="center",
        )
        panel_text.set_gid("panel-label")


def place_legend(axis, over_data=False, **kwargs):
    """Create a legend with a background appropriate to its placement.

    Keep legends outside the data region or in deliberately reserved whitespace
    when possible. Set ``over_data=True`` only when an inside legend is
    unavoidable, especially on maps; this adds a semi-transparent white frame.
    """
    if over_data:
        kwargs.setdefault("frameon", True)
        kwargs.setdefault("facecolor", "white")
        kwargs.setdefault("framealpha", 0.82)
        kwargs.setdefault("edgecolor", "none")
    else:
        kwargs.setdefault("frameon", False)
    return axis.legend(**kwargs)


def shared_symmetric_limits(*arrays, **kwargs):
    """Return common zero-centred limits for comparable difference fields.

    Pass ``percentile=98`` (or another value in ``(0, 100]``) for robust
    limits. Without it, the largest finite absolute value sets the limits.
    """
    percentile = kwargs.pop("percentile", None)
    if kwargs:
        raise TypeError("Unexpected keyword argument: {}".format(next(iter(kwargs))))
    finite_values = []
    for values in arrays:
        flattened = np.asarray(values, dtype=float).ravel()
        finite_values.append(np.abs(flattened[np.isfinite(flattened)]))
    finite_values = [values for values in finite_values if values.size]
    if not finite_values:
        raise ValueError("At least one finite value is required")
    combined = np.concatenate(finite_values)
    if percentile is None:
        limit = float(np.max(combined))
    else:
        if not 0 < percentile <= 100:
            raise ValueError("percentile must be in (0, 100]")
        limit = float(np.percentile(combined, percentile))
    if limit == 0:
        limit = 1.0
    return -limit, limit


def audit_figure(
    figure,
    expected_font="Helvetica Neue",
    allow_titles=False,
    min_font_size=7.0,
    min_panel_width=1.35,
    min_panel_height=1.2,
    project_root=None,
):
    """Return actionable style findings for a figure before export.

    This checks deterministic properties only. It does not replace visual
    review for clipping, accessibility, scientific validity, or clutter.
    """
    if min_font_size < 7.0:
        raise ValueError("min_font_size cannot be lower than the 7-pt minimum")
    with warnings.catch_warnings(record=True) as parser_warnings:
        warnings.simplefilter("always")
        register_fonts(expected_font, project_root=project_root)
        figure.canvas.draw()
    findings = []
    for warning in parser_warnings:
        findings.append("Font-parser warning: {}".format(warning.message))
    figure_width, figure_height = figure.get_size_inches()

    for index, axis in enumerate(figure.axes, start=1):
        if not allow_titles and axis.get_title().strip():
            findings.append(
                "Axis {} has an internal title; move nonessential explanation "
                "to the caption.".format(index)
            )
        if axis.get_title().strip() and axis.title.get_fontsize() != 9:
            findings.append(
                "Axis {} title is {:.1f} pt; use the 9-pt panel-title default.".format(
                    index, axis.title.get_fontsize()
                )
            )
        position = axis.get_position()
        panel_width = position.width * figure_width
        panel_height = position.height * figure_height
        if panel_width < min_panel_width or panel_height < min_panel_height:
            findings.append(
                "Axis {} is {:.2f} x {:.2f} in; enlarge or split the figure.".format(
                    index, panel_width, panel_height
                )
            )

        negative_padding = []
        for axis_name, axis_object in (("x", axis.xaxis), ("y", axis.yaxis)):
            for tick in axis_object.get_major_ticks():
                if tick.get_pad() < 0:
                    negative_padding.append(axis_name)
                    break
        if negative_padding:
            findings.append(
                "Axis {} uses negative {}-tick padding; keep coordinate labels "
                "outside the data region.".format(index, "/".join(negative_padding))
            )

        legend = axis.get_legend()
        if legend is not None and legend.get_visible():
            renderer = figure.canvas.get_renderer()
            legend_box = legend.get_window_extent(renderer)
            overlapping_artists = 0
            for patch in axis.patches:
                if patch is axis.patch or not patch.get_visible():
                    continue
                patch_box = patch.get_window_extent(renderer)
                if legend_box.overlaps(patch_box):
                    overlapping_artists += 1
            if overlapping_artists:
                findings.append(
                    "Axis {} legend overlaps {} plotted patch(es); move it to "
                    "reserved whitespace or outside the axes.".format(
                        index, overlapping_artists
                    )
                )

            is_map = hasattr(axis, "projection")
            if is_map and legend_box.overlaps(axis.get_window_extent(renderer)):
                if not legend.get_frame_on():
                    findings.append(
                        "Axis {} map legend is inside the map without a frame; "
                        "use place_legend(..., over_data=True).".format(index)
                    )
                else:
                    red, green, blue, alpha = legend.get_frame().get_facecolor()
                    if min(red, green, blue) < 0.95 or not 0.6 <= alpha <= 0.9:
                        findings.append(
                            "Axis {} map legend needs a semi-transparent white "
                            "background (alpha 0.6–0.9).".format(index)
                        )

    labelled_axes = []
    for axis in figure.axes:
        panel_labels = [
            text_item
            for text_item in axis.texts
            if text_item.get_gid() == "panel-label"
        ]
        if panel_labels:
            labelled_axes.append((axis, panel_labels[0]))
    titled_labelled_axes = [item for item in labelled_axes if item[0].get_title()]
    if titled_labelled_axes and len(titled_labelled_axes) != len(labelled_axes):
        findings.append(
            "Panel titles use inconsistent mechanisms; attach every panel title "
            "to its axis before calling add_panel_labels()."
        )
    renderer = figure.canvas.get_renderer()
    for index, (axis, panel_label) in enumerate(labelled_axes, start=1):
        if panel_label.get_fontsize() != 10 or panel_label.get_fontweight() != "bold":
            findings.append("Panel label {} must be 10 pt bold.".format(index))
        if not axis.get_title():
            continue
        label_box = panel_label.get_window_extent(renderer)
        title_box = axis.title.get_window_extent(renderer)
        label_centre = (label_box.y0 + label_box.y1) / 2
        title_centre = (title_box.y0 + title_box.y1) / 2
        if abs(label_centre - title_centre) > 2:
            findings.append(
                "Panel label {} is not vertically centred with its axis title; "
                "use add_panel_labels() without a custom y value.".format(index)
            )

    for axis_index, axis in enumerate(figure.axes, start=1):
        sample_sizes = [
            text_item
            for text_item in axis.texts
            if text_item.get_gid() == "sample-size"
        ]
        for sample_size in sample_sizes:
            sample_y = sample_size.get_position()[1]
            if sample_size.get_fontsize() != 7:
                findings.append(
                    "Axis {} sample-size text must be 7 pt.".format(axis_index)
                )
            if not -0.14 <= sample_y <= -0.10:
                findings.append(
                    "Axis {} sample-size text is at y={:.2f}; start within "
                    "-0.10 to -0.14 and adjust visually.".format(axis_index, sample_y)
                )

    undersized_text = []
    unexpected_fonts = {}
    for text_item in figure.findobj(match=mpl.text.Text):
        if not text_item.get_text().strip():
            continue
        if text_item.get_fontsize() < min_font_size:
            undersized_text.append(text_item.get_text())
        resolved_font = text_item.get_fontproperties().get_name()
        if resolved_font != expected_font:
            unexpected_fonts.setdefault(resolved_font, []).append(text_item.get_text())

    if undersized_text:
        findings.append(
            "{} text item(s) are below {:.1f} pt, including: {}.".format(
                len(undersized_text),
                min_font_size,
                ", ".join(repr(value) for value in undersized_text[:3]),
            )
        )
    for font_name, values in sorted(unexpected_fonts.items()):
        findings.append(
            "{} text item(s) resolve to {} instead of {}, including: {}.".format(
                len(values),
                font_name,
                expected_font,
                ", ".join(repr(value) for value in values[:3]),
            )
        )

    return findings


def save_figure(
    figure,
    output_stem,
    *,
    dpi=300,
    transparent=False,
):
    """Save vector PDF and high-resolution PNG files and return their paths."""
    stem = Path(output_stem)
    stem.parent.mkdir(parents=True, exist_ok=True)
    pdf_path = stem.with_suffix(".pdf")
    png_path = stem.with_suffix(".png")
    figure.savefig(pdf_path, bbox_inches="tight", transparent=transparent)
    figure.savefig(png_path, dpi=dpi, bbox_inches="tight", transparent=transparent)
    return pdf_path, png_path

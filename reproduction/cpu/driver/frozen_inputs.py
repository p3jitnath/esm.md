"""Load frozen GPU host words into the existing guarded CPU layouts."""

import hashlib
import json
from pathlib import Path
import sys

import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DEFAULT_BANKS = ROOT / ".runtime/goal_20261112/gpu/frozen_inputs"
sys.path.insert(0, str(ROOT / ".runtime/cpu_fortran_20261108"))
import paired_timing as shared


def file_sha256(path):
    """Identify a file without loading all its bytes at once.

    Parameters
    ----------
    path : str or pathlib.Path
        Existing source, bank or metadata file, read without mutation.

    Returns
    -------
    str
        Hexadecimal SHA256 identifier of the complete stored file.

    Raises
    ------
    OSError
        If the file cannot be read.
    """
    result = hashlib.sha256()
    with Path(path).open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            result.update(chunk)
    return result.hexdigest()


def array_sha256(array):
    """Identify the exact bytes of one contiguous stored array.

    Parameters
    ----------
    array : numpy.ndarray
        C-contiguous array whose original dtype and stored words are retained.

    Returns
    -------
    str
        SHA256 identifier of the C-order data bytes, without array metadata.

    Raises
    ------
    ValueError
        If the input is not C-contiguous.

    Notes
    -----
    Hashing reads the array without arithmetic, byte-order conversion or writes.
    """
    if not array.flags.c_contiguous:
        raise ValueError("Exact bank byte hashing requires a C-contiguous array.")
    return hashlib.sha256(memoryview(array).cast("B")).hexdigest()


def make_buffers(bank):
    """Copy every frozen word into a fresh legacy guarded buffer owner.

    Parameters
    ----------
    bank : dict
        Validated result of load_bank. Its full arrays and guard records are
        borrowed as immutable inputs.

    Returns
    -------
    object
        Legacy SW _Buffers or EBM Buffers object owning independent mutable
        q, stage, out, work and parameter/coefficient arrays. SW state shape is
        (3, ny+2, nx+2), with depth [m] and momenta [m^2/s]; EBM states have
        (n+2,) Celsius values. All ghosts and scratch words are copied.

    Raises
    ------
    ValueError
        If guard records or fixture field layouts do not match the bank.
    AssertionError
        If a copied array or restored guard differs from the frozen words.

    Notes
    -----
    Fixture constructors allocate storage and copy supplied words; no analytic
    input generator is called. The final uint64 copies retain every NaN payload
    and signed-zero bit. The returned owner can be mutated without changing
    this bank, its seed or a second owner made from the same bank.
    """
    arrays = bank["arrays"]
    model = bank["model"]
    if model == "sw":
        buffers = shared.protocol._Buffers(bank["seed"], bank["par"])
        field_names = ("q", "stage", "out", "work", "parameters")
    else:
        buffers = shared.ebm.Buffers(bank["seed"], bank["coeff"], bank["par"])
        field_names = ("q", "stage", "out", "work", "coeff", "par")
    for name in field_names:
        target = getattr(buffers, name)
        frozen = arrays[name]
        if target.shape != frozen.shape or target.dtype != frozen.dtype:
            raise ValueError("Legacy fixture differs from the frozen field: " + name)
        target.view(np.uint64)[...] = frozen.view(np.uint64)
        if not np.array_equal(target.view(np.uint64), frozen.view(np.uint64)):
            raise AssertionError("Frozen field copy differs: " + name)
    records = bank["guard_words"]
    if len(records) != len(buffers.guards):
        raise ValueError("Frozen guard count differs from the legacy fixture.")
    for raw, record in zip(buffers.guards, records):
        prefix = np.array([int(word, 16) for word in record["prefix"]], dtype=np.uint64)
        suffix = np.array([int(word, 16) for word in record["suffix"]], dtype=np.uint64)
        if prefix.shape != (16,) or suffix.shape != (16,):
            raise ValueError("Frozen guards must each contain sixteen words.")
        raw[:16], raw[-16:] = prefix, suffix
        if not np.array_equal(raw[:16], prefix) or not np.array_equal(
            raw[-16:], suffix
        ):
            raise AssertionError("Frozen guard copy differs.")
    if model == "sw":
        buffers.check_guards()
    else:
        buffers.check(bank["coeff"], bank["par"])
    return buffers


def load_bank(model, size, directory=None):
    """Load and validate one frozen input without rebuilding physical inputs.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Shallow-water or energy-balance bank to select.
    size : int
        SW square-grid width or EBM latitude-band count. The frozen manifest
        must contain exactly one matching bank for the 1,000-step experiment.
    directory : str or pathlib.Path, optional
        Frozen manifest/bank directory; the campaign GPU input directory is
        used by default.

    Returns
    -------
    dict
        model, size, full readonly arrays, readonly seed_view and C-contiguous
        seed copy, readonly par, readonly coeff or None, guard_words, identity,
        input_identity_sha256, and a fresh mutable legacy buffers owner.
        The seed shape is SW (3, size, size) or EBM (size,); padded states add
        two cells per spatial dimension. SW fields are depth [m] and momenta
        [m^2/s]. EBM temperatures use degrees Celsius; parameters and coefficients
        retain their original units and every stored word.

    Raises
    ------
    ValueError
        If selection, metadata, dtype, shape, byte count or recorded hashes
        differ, or the host cannot use the stored FP64 byte order directly.
    OSError
        If a frozen artifact cannot be read.
    json.JSONDecodeError
        If the manifest or per-bank metadata are not valid JSON.

    Notes
    -----
    The NPZ and each array are checked against recorded byte hashes before
    constructing mutable buffers. The original input identity and generator
    source identities are preserved verbatim. No numerical stage or analytic
    initial-condition generator is invoked. Keep this returned dictionary alive
    while using its borrowed seed view or readonly parameter/coefficient arrays.
    """
    if (
        model not in ("sw", "ebm")
        or not isinstance(size, int)
        or isinstance(size, bool)
    ):
        raise ValueError("Select model sw or ebm and an integer bank size.")
    directory = Path(directory) if directory is not None else DEFAULT_BANKS
    manifest_path = directory / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    shape = [size, size] if model == "sw" else [size]
    matches = [
        row
        for row in manifest["banks"]
        if row["model"] == model and row["shape"] == shape
    ]
    if manifest.get("schema_version") != 1 or len(matches) != 1:
        raise ValueError("The frozen manifest has no unique matching bank.")
    prefix = "sw" if model == "sw" else "eb"
    metadata_path = directory / (prefix + "_" + str(size) + ".json")
    metadata = json.loads(metadata_path.read_text())
    if metadata != matches[0]:
        raise ValueError("Per-bank metadata differ from the frozen manifest.")
    if manifest["complete_steps"] != 1000 or metadata["complete_steps"] != 1000:
        raise ValueError("The frozen bank is not the 1,000-step experiment.")
    npz_path = directory / (prefix + "_" + str(size) + ".npz")
    if file_sha256(npz_path) != metadata["npz_sha256"]:
        raise ValueError("Frozen NPZ bytes differ from their recorded identity.")
    expected_shapes = {
        name: (3, size + 2, size + 2) if model == "sw" else (size + 2,)
        for name in ("q", "stage", "out")
    }
    expected_shapes["work"] = (5, size + 2, size + 2) if model == "sw" else (size + 2,)
    parameter_name = "parameters" if model == "sw" else "par"
    expected_shapes[parameter_name] = (4,) if model == "sw" else (6,)
    if model == "ebm":
        expected_shapes["coeff"] = (3, size + 2)
    arrays = {}
    with np.load(npz_path, allow_pickle=False) as archive:
        if set(archive.files) != set(expected_shapes) or set(metadata["arrays"]) != set(
            expected_shapes
        ):
            raise ValueError("Frozen array names differ from the admitted layout.")
        for name, expected_shape in expected_shapes.items():
            array = archive[name]
            recorded = metadata["arrays"][name]
            if (
                array.shape != expected_shape
                or list(array.shape) != recorded["shape"]
                or array.dtype.str != recorded["dtype"]
                or array.dtype.str != "<f8"
                or not array.dtype.isnative
                or not array.flags.c_contiguous
                or recorded["order"] != "C"
                or array.nbytes != recorded["bytes"]
                or array_sha256(array) != recorded["sha256"]
            ):
                raise ValueError("Frozen field bytes or layout differ: " + name)
            array.setflags(write=False)
            arrays[name] = array
    seed_view = arrays["q"][:, 1:-1, 1:-1] if model == "sw" else arrays["q"][1:-1]
    seed_view.setflags(write=False)
    seed = seed_view.copy(order="C")
    seed.setflags(write=False)
    identity = {
        "model": model,
        "shape": shape,
        "complete_steps": 1000,
        "input_identity_sha256": metadata["input_identity_sha256"],
        "npz": str(npz_path.resolve()),
        "npz_sha256": metadata["npz_sha256"],
        "metadata": str(metadata_path.resolve()),
        "metadata_sha256": file_sha256(metadata_path),
        "manifest": str(manifest_path.resolve()),
        "manifest_sha256": file_sha256(manifest_path),
        "arrays": metadata["arrays"],
        "generator_sources": manifest["generator_sources"],
        "loader_sources": {
            str(path.resolve()): file_sha256(path)
            for path in (
                Path(__file__),
                Path(shared.__file__),
                Path(shared.protocol.__file__),
                Path(shared.ebm.__file__),
            )
        },
    }
    bank = {
        "model": model,
        "size": size,
        "arrays": arrays,
        "seed": seed,
        "seed_view": seed_view,
        "par": arrays[parameter_name],
        "coeff": arrays.get("coeff"),
        "guard_words": metadata["guard_words"],
        "identity": identity,
        "input_identity_sha256": metadata["input_identity_sha256"],
    }
    bank["buffers"] = make_buffers(bank)
    return bank

"""Export or read the fixed canonical CPU states for frozen input banks."""

import argparse
import ctypes
import json
import os
from pathlib import Path
from types import SimpleNamespace

import numpy as np

from frozen_inputs import array_sha256, file_sha256, load_bank, shared

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
STEPS = 1000
FIELDS = ("q", "stage", "out")
SEMANTICS = {
    "q": {"role": "final_state", "step": 1000},
    "out": {"role": "previous_state", "step": 999},
    "stage": {"role": "first_stage", "step": 1000},
    "includes_ghost_cells": True,
    "array_order": "C; SW uses field,y,x and EBM uses latitude band",
}


def _paths(model, size, directory):
    """Locate one canonical bank without calculating a missing result.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Model selecting the file prefix and expected state dimensions.
    size : int
        Positive global side length for SW or latitude-band count for EBM.
    directory : str or pathlib.Path or None
        Export folder; ``None`` selects ``HERE/canonical_banks``.

    Returns
    -------
    tuple of pathlib.Path
        NPZ path followed by its same-stem JSON receipt path.

    Raises
    ------
    ValueError
        If the model or global size is invalid.
    """
    if model not in ("sw", "ebm") or size < 1:
        raise ValueError("Select a supported model and a positive global size.")
    prefix = "sw" if model == "sw" else "eb"
    folder = Path(directory) if directory is not None else HERE / "canonical_banks"
    stem = folder / (prefix + "_" + str(size))
    return stem.with_suffix(".npz"), stem.with_suffix(".json")


def _describe_array(array):
    """Describe every stored word of one padded FP64 state.

    Parameters
    ----------
    array : numpy.ndarray of float64
        Contiguous state, including ghosts. SW has shape ``(3, ny+2, nx+2)``
        with depth [m] and momenta [m^2/s]; EBM has ``(n+2,)`` Celsius values.

    Returns
    -------
    dict
        Shape, dtype string, byte count and SHA256 of the exact C-order bytes.

    Notes
    -----
    This helper changes no values and keeps signed zeros and all output bits.
    """
    return {
        "shape": list(array.shape),
        "dtype": array.dtype.str,
        "bytes": int(array.nbytes),
        "sha256": array_sha256(array),
    }


def load_canonical(model, size, bank_identity=None, directory=None):
    """Read a verified 1,000-step export without calculating a fallback.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Model whose complete padded q, stage and out arrays are required.
    size : int
        SW global side length or EBM global latitude-band count.
    bank_identity : str or dict or None, optional
        Expected recorded input SHA256, or an identity dictionary containing
        ``input_identity_sha256``. When omitted, the export's two recorded
        input-identity fields must still agree with each other.
    directory : str or pathlib.Path or None, optional
        Export folder; ``None`` selects ``HERE/canonical_banks``.

    Returns
    -------
    types.SimpleNamespace
        Read-only q, stage and out arrays, the full JSON ``meta``, input/export
        ``identity``, and the after-call ``fpcr`` and ``fpsr`` values, or None when unavailable.
        q is step 1,000, out is step 999, and stage is step 1,000's first stage.

    Raises
    ------
    ValueError
        If model, size, input identity, state semantics, shape, dtype, byte
        count or any recorded SHA256 differs from the requested bank.
    OSError
        If the NPZ or JSON export cannot be read.
    json.JSONDecodeError
        If the receipt is not valid JSON.

    Notes
    -----
    All padded words, including every ghost, are retained. This function loads
    files only; it never creates initial conditions or executes a solver.
    Callers should pass the frozen bank identity when comparing an export to
    a separately loaded input bank. Reused exports preserve unknown post-oracle
    FPCR/FPSR as None and label the current admission probes separately.
    """
    npz_path, metadata_path = _paths(model, size, directory)
    meta = json.loads(metadata_path.read_text())
    shape = [size, size] if model == "sw" else [size]
    if (
        meta.get("passed") is not True
        or meta.get("model") != model
        or meta.get("shape") != shape
        or meta.get("complete_steps") != STEPS
        or meta.get("semantics") != SEMANTICS
    ):
        raise ValueError(
            "The canonical receipt has different model, grid or step semantics."
        )
    identity = meta.get("input_identity", {})
    recorded = meta.get("input_identity_sha256")
    if (
        not isinstance(recorded, str)
        or identity.get("input_identity_sha256") != recorded
    ):
        raise ValueError("The canonical input-identity fields disagree.")
    expected = (
        bank_identity.get("input_identity_sha256")
        if isinstance(bank_identity, dict)
        else bank_identity
    )
    if bank_identity is not None and expected != recorded:
        raise ValueError(
            "The canonical export belongs to a different frozen input bank."
        )
    if file_sha256(npz_path) != meta.get("npz_sha256"):
        raise ValueError("The canonical NPZ bytes differ from their receipt.")
    padded = (3, size + 2, size + 2) if model == "sw" else (size + 2,)
    arrays = {}
    with np.load(npz_path, allow_pickle=False) as archive:
        if set(archive.files) != set(FIELDS):
            raise ValueError("The canonical NPZ must contain exactly q, stage and out.")
        for name in FIELDS:
            array = archive[name]
            descriptor = meta.get("arrays", {}).get(name)
            if (
                array.shape != padded
                or array.dtype != np.dtype("<f8")
                or not array.flags.c_contiguous
                or _describe_array(array) != descriptor
            ):
                raise ValueError(
                    "The canonical padded state differs from its receipt: " + name
                )
            array.setflags(write=False)
            arrays[name] = array
    reused = meta.get("canonical_mode") == "reuse_expected"
    if reused:
        adopted = meta.get("expected") or {}
        producer = (meta.get("producer_manifest") or {}).get("bank") or {}
        if (
            producer.get("model") != model
            or producer.get("shape") != shape
            or producer.get("complete_steps") != STEPS
            or producer.get("input_identity") != recorded
            or producer.get("file_sha256") != adopted.get("sha256")
            or producer.get("canonical_binary_sha256")
            != meta["canonical_library"]["sha256"]
            or producer.get("immediate_post_oracle_fpcr_fpsr_recorded") is not False
            or meta.get("canonical_solver_executed") is not False
            or meta.get("solver_call_count") != 0
            or meta.get("fpcr") is not None
            or meta.get("fpsr") is not None
            or meta.get("post_oracle_status_known") is not False
            or meta.get("admission_fpcr") != 0
            or meta.get("current_probe_fpcr") != 0
            or adopted.get("input_identity") != recorded
            or adopted.get("canonical_binary_sha256")
            != meta["canonical_library"]["sha256"]
            or adopted.get("provider_sha256_matches_current") is not True
        ):
            raise ValueError(
                "The reused canonical status/provenance record is invalid."
            )
    elif meta.get("fpcr") != 0 or not isinstance(meta.get("fpsr"), int):
        raise ValueError("The executed canonical floating-point status is invalid.")
    return SimpleNamespace(
        **arrays,
        meta=meta,
        identity={
            "input_identity": identity,
            "input_identity_sha256": recorded,
            "npz_path": str(npz_path.resolve()),
            "npz_sha256": meta["npz_sha256"],
            "metadata_path": str(metadata_path.resolve()),
            "metadata_sha256": file_sha256(metadata_path),
            "canonical_library": meta["canonical_library"],
            "canonical_source": meta["canonical_source"],
        },
        fpcr=meta["fpcr"],
        fpsr=meta["fpsr"],
        admission_fpcr=meta.get("admission_fpcr"),
        current_probe_fpcr=meta.get("current_probe_fpcr"),
    )


def _read_expected(path, bank, artifact_sha256, provider_sha256=None):
    """Read existing padded states and validate their input/provider identity.

    Parameters
    ----------
    path : pathlib.Path
        Frozen expected NPZ containing q, stage, out and scalar provenance.
    bank : dict
        Validated frozen input bank whose layout and identity must match.
    artifact_sha256 : str
        Expected-file hash pinned before any calculation or adoption.
    provider_sha256 : str or None, optional
        Required canonical provider hash for reuse. A fresh comparison can
        omit this restriction while retaining the producer's recorded hash.

    Returns
    -------
    states : dict of numpy.ndarray
        Complete stored FP64 states, including every ghost, without mutation.
    record : dict
        Expected-file, input and provider identities for the joined receipt.

    Raises
    ------
    AssertionError
        If metadata, provider identity, state dtype or padded shape differs.

    Notes
    -----
    This helper reads stored words and executes no model update. The expected
    bank's 1,000-step interpretation is bound by the caller's producer manifest;
    its NPZ format does not include a separate step-count member.
    """
    with np.load(path, allow_pickle=False) as expected:
        required = set(FIELDS) | {"input_identity", "canonical_binary_sha256"}
        if not required.issubset(expected.files):
            raise AssertionError("The expected NPZ lacks a state or provenance field.")
        for name in ("input_identity", "canonical_binary_sha256"):
            if expected[name].shape != ():
                raise AssertionError("Expected metadata must be scalar: " + name)
        identity = expected["input_identity"].item()
        provider = expected["canonical_binary_sha256"].item()
        if isinstance(identity, bytes):
            identity = identity.decode("ascii")
        if isinstance(provider, bytes):
            provider = provider.decode("ascii")
        if identity != bank["input_identity_sha256"]:
            raise AssertionError(
                "The expected result uses a different frozen input bank."
            )
        if not isinstance(provider, str):
            raise AssertionError(
                "The expected canonical provider identifier is not text."
            )
        if provider_sha256 is not None and provider != provider_sha256:
            raise AssertionError(
                "The expected canonical provider differs from the current library."
            )
        states = {}
        for name in FIELDS:
            state = expected[name]
            target = getattr(bank["buffers"], name)
            if (
                state.shape != target.shape
                or state.dtype != target.dtype
                or not state.flags.c_contiguous
            ):
                raise AssertionError("The expected padded layout differs: " + name)
            states[name] = state
    return states, {
        "path": str(path.resolve()),
        "sha256": artifact_sha256,
        "input_identity": identity,
        "canonical_binary_sha256": provider,
        "provider_sha256_matches_current": (
            provider == provider_sha256 if provider_sha256 is not None else None
        ),
    }


def main():
    """Export a 1,000-step canonical result by execution or verified reuse.

    Returns
    -------
    None
        Write all padded q, stage and out words plus their checked provenance.

    Raises
    ------
    AssertionError
        If provider/input identities, physical checks, guards, immutable words
        or exact padded-state comparisons fail.
    RuntimeError
        If admitted controls or a pinned artifact change.
    OSError
        If an input, native metadata probe or evidence file cannot be accessed.
    ValueError
        If a frozen bank fails its stored layout or byte-hash requirements.

    Notes
    -----
    The reuse-expected mode adopts existing states only after provider and
    input hashes agree. It calls no solver. Independent physical checks still
    run on the copied states. Its unavailable post-oracle controls/status stay
    None, while current-process admission probes are labelled separately.
    The explicit fresh route retains immediate after-call FP observations.
    Both routes preserve q at step 1,000, out at step 999 and stage at step
    1,000's first stage, including every ghost.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("model", choices=("sw", "ebm"))
    parser.add_argument("size", type=int)
    parser.add_argument("--output-dir", type=Path, default=HERE / "canonical_banks")
    expected_group = parser.add_mutually_exclusive_group()
    expected_group.add_argument(
        "--expected",
        type=Path,
        help="Execute the reference and compare it with an existing expected NPZ.",
    )
    expected_group.add_argument(
        "--reuse-expected",
        type=Path,
        help="Adopt provider-identical expected states without executing a solver.",
    )
    parser.add_argument(
        "--environment-library",
        type=Path,
        default=HERE / "build/libenvironment_probe.so",
    )
    parser.add_argument(
        "--expected-manifest",
        type=Path,
        default=ROOT
        / ".runtime/goal_20261112/gpu/frozen_inputs/expected_manifest.json",
        help="Producer manifest binding reused expected files to their executed step count.",
    )
    args = parser.parse_args()
    npz_path, metadata_path = _paths(args.model, args.size, args.output_dir)
    bank = load_bank(args.model, args.size)
    buffers = bank["buffers"]
    reuse = args.reuse_expected is not None
    expected_path = args.reuse_expected if reuse else args.expected
    prefix = "sw" if args.model == "sw" else "eb"
    library = ROOT / ".agents/bench/.build" / ("lib" + prefix + "_fortran_vanilla.so")
    source = (
        shared.ARCHIVE
        / "src"
        / ("shallow_water" if args.model == "sw" else "budyko_sellers")
        / "vanilla.f90"
    )
    contract_path = ROOT / ".agents/bench/goal_20261112/main_workload_contract.json"
    contract = json.loads(contract_path.read_text())
    shape = [args.size, args.size] if args.model == "sw" else [args.size]
    matching_cases = [
        row
        for row in contract["main_cases"]
        if row["model"] == args.model and row["shape"] == shape
    ]
    if (
        contract.get("status") != "workload_frozen"
        or contract.get("input_bank_manifest_sha256")
        != bank["identity"]["manifest_sha256"]
        or len(matching_cases) != 1
        or matching_cases[0]["complete_steps"] != STEPS
        or matching_cases[0]["input_identity"] != bank["input_identity_sha256"]
    ):
        raise ValueError(
            "The frozen workload contract does not bind this input and step count."
        )
    pinned_paths = [
        library,
        source,
        args.environment_library,
        Path(__file__),
        contract_path,
        HERE / "frozen_inputs.py",
        Path(shared.__file__),
        Path(shared.protocol.__file__),
        Path(shared.ebm.__file__),
    ]
    producer_bank = None
    producer_receipt = None
    if reuse:
        producer_manifest = json.loads(args.expected_manifest.read_text())
        matching_outputs = [
            row
            for row in producer_manifest["banks"]
            if row["model"] == args.model and row["shape"] == shape
        ]
        if producer_manifest.get("schema_version") != 1 or len(matching_outputs) != 1:
            raise ValueError("The producer manifest has no unique matching output.")
        producer_bank = matching_outputs[0]
        if (
            producer_bank["complete_steps"] != STEPS
            or producer_bank["input_identity"] != bank["input_identity_sha256"]
            or Path(producer_bank["path"]).resolve() != expected_path.resolve()
            or producer_bank["canonical_binary_sha256"] != file_sha256(library)
            or set(producer_bank["checked_state_buffers"]) != set(FIELDS)
            or producer_bank["immediate_post_oracle_fpcr_fpsr_recorded"] is not False
        ):
            raise ValueError(
                "The producer output does not bind this provider, input and step count."
            )
        producer_receipt = Path(producer_bank["producer_validation_receipt"])
        pinned_paths.extend([args.expected_manifest, producer_receipt])
    if expected_path is not None:
        pinned_paths.append(expected_path)
    pinned = {str(path.resolve()): file_sha256(path) for path in pinned_paths}
    if reuse and producer_bank["file_sha256"] != pinned[str(expected_path.resolve())]:
        raise ValueError("The expected-file hash differs from its producer manifest.")
    environment = ctypes.CDLL(str(args.environment_library))
    environment.cpu_fpcr.restype = ctypes.c_uint64
    environment.cpu_fpsr.restype = ctypes.c_uint64
    environment.cpu_set_fpsr.argtypes = [ctypes.c_uint64]
    environment.cpu_set_fpsr.restype = None
    admission_fpcr = environment.cpu_fpcr()
    current_probe_fpsr = environment.cpu_fpsr()
    if admission_fpcr != 0:
        raise RuntimeError(
            "The canonical export requires the admitted floating-point control."
        )
    expected_record = None
    expected_binary = None
    fpcr = fpsr = before_fpcr = before_fpsr = None
    if reuse:
        states, expected_record = _read_expected(
            expected_path,
            bank,
            pinned[str(expected_path.resolve())],
            provider_sha256=pinned[str(library.resolve())],
        )
        expected_binary = expected_record["canonical_binary_sha256"]
        for name in FIELDS:
            recorded = producer_bank["arrays"][name]
            if (
                list(states[name].shape) != recorded["shape"]
                or states[name].dtype.str != recorded["dtype"]
                or array_sha256(states[name]) != recorded["sha256"]
            ):
                raise ValueError(
                    "Reused array differs from its producer record: " + name
                )
            target = getattr(buffers, name)
            target.view(np.uint64)[...] = states[name].view(np.uint64)
            shared.protocol._compare(states[name], target, "Adopted canonical " + name)
        expected_record["full_padded_states_bitwise_equal"] = True
        expected_record["comparison_scope"] = (
            "Exact adoption of existing oracle words; no repeat solver call."
        )
    else:
        canonical = shared.backend(args.model, "canonical", library)
        invoke = (
            canonical.bind_run(buffers, STEPS)
            if args.model == "sw"
            else canonical.bind(buffers, STEPS)
        )
        environment.cpu_set_fpsr(0)
        before_fpcr = environment.cpu_fpcr()
        before_fpsr = environment.cpu_fpsr()
        invoke()
        fpsr = environment.cpu_fpsr()
        fpcr = environment.cpu_fpcr()
        if before_fpcr != 0 or before_fpsr != 0 or fpcr != 0:
            raise RuntimeError("The canonical call changed floating-point control.")
    if args.model == "sw":
        buffers.check_guards()
        shared.protocol._compare(
            bank["par"], buffers.parameters, "immutable parameters"
        )
        admissibility = {}
        for name in FIELDS:
            array = getattr(buffers, name)
            shared.protocol._halo_check(array)
            admissibility[name] = shared.protocol._admissible(array, bank["par"])
        physics = {
            "state_admissibility": admissibility,
            "conserved_budget_drift": shared.protocol._budget_drift(
                bank["seed"], buffers.q[:, 1:-1, 1:-1]
            ),
        }
    else:
        buffers.check(bank["coeff"], bank["par"])
        admissibility = {}
        for name in FIELDS:
            array = getattr(buffers, name)
            shared.ebm.halo_check(array)
            admissibility[name] = shared.ebm.admissible(
                array, bank["coeff"], bank["par"]
            )
        physics = {
            "state_admissibility": admissibility,
            "final_step_heat_budget_residual": shared.ebm.heat_budget(
                buffers.out, buffers.stage, buffers.q, bank["coeff"], bank["par"]
            ),
        }
    arrays = {name: getattr(buffers, name) for name in FIELDS}
    if not reuse and expected_path is not None:
        states, expected_record = _read_expected(
            expected_path, bank, pinned[str(expected_path.resolve())]
        )
        expected_binary = expected_record["canonical_binary_sha256"]
        for name in FIELDS:
            shared.protocol._compare(
                states[name], arrays[name], "Expected versus CPU canonical " + name
            )
        expected_record["full_padded_states_bitwise_equal"] = True
        expected_record["comparison_scope"] = (
            "Independent fresh canonical call versus existing oracle words."
        )
    current_probe_fpcr = environment.cpu_fpcr()
    if current_probe_fpcr != 0:
        raise RuntimeError("Independent checks changed the admitted control state.")
    descriptors = {name: _describe_array(array) for name, array in arrays.items()}
    for path, expected in pinned.items():
        if file_sha256(path) != expected:
            raise RuntimeError("A pinned canonical artifact changed: " + path)
    npz_path.parent.mkdir(parents=True, exist_ok=True)
    np.savez(npz_path, **arrays)
    report = {
        "passed": True,
        "model": args.model,
        "shape": [args.size, args.size] if args.model == "sw" else [args.size],
        "complete_steps": STEPS,
        "input_identity": bank["identity"],
        "input_identity_sha256": bank["input_identity_sha256"],
        "arrays": descriptors,
        "npz_sha256": file_sha256(npz_path),
        "semantics": SEMANTICS,
        "canonical_mode": "reuse_expected" if reuse else "executed_reference",
        "canonical_solver_executed": not reuse,
        "solver_call_count": 0 if reuse else 1,
        "expected": expected_record,
        "expected_canonical_binary_sha256": expected_binary,
        "complete_steps_basis": (
            "Validated producer manifest records the executed 1,000 steps; the NPZ has no step-count member."
            if reuse
            else "Exactly 1,000 complete steps passed to the unchanged provider."
        ),
        "workload_contract": {
            "path": str(contract_path.resolve()),
            "sha256": pinned[str(contract_path.resolve())],
            "case": matching_cases[0],
            "scope": "Declared input and step-count contract, not an observation of the oracle call.",
        },
        "producer_manifest": (
            {
                "path": str(args.expected_manifest.resolve()),
                "sha256": pinned[str(args.expected_manifest.resolve())],
                "bank": producer_bank,
                "validation_receipt": {
                    "path": str(producer_receipt.resolve()),
                    "sha256": pinned[str(producer_receipt.resolve())],
                },
            }
            if reuse
            else None
        ),
        "canonical_library": {
            "path": str(library.resolve()),
            "sha256": pinned[str(library.resolve())],
        },
        "canonical_source": {
            "path": str(source.resolve()),
            "sha256": pinned[str(source.resolve())],
        },
        "source_identities": pinned,
        "post_oracle_status_known": not reuse,
        "fpcr": fpcr,
        "fpsr": fpsr,
        "admission_fpcr": admission_fpcr,
        "current_probe_fpcr": current_probe_fpcr,
        "current_probe_fpsr_before_checks": current_probe_fpsr,
        "current_probe_scope": "This export process; distinct from the original oracle's unavailable post-call status in reuse mode.",
        "before_call_fpcr": before_fpcr,
        "before_call_fpsr": before_fpsr,
        "physics": physics,
        "guards_unchanged": True,
        "immutable_inputs_unchanged": True,
        "job": os.environ.get("SLURM_JOB_ID"),
        "node": os.uname().nodename,
        "affinity": sorted(os.sched_getaffinity(0)),
    }
    metadata_path.write_text(json.dumps(report, indent=2) + "\n")
    print(
        json.dumps(
            {
                "passed": True,
                "model": args.model,
                "shape": report["shape"],
                "complete_steps": STEPS,
                "canonical_mode": report["canonical_mode"],
                "solver_call_count": report["solver_call_count"],
                "npz": str(npz_path),
                "metadata": str(metadata_path),
            }
        )
    )


if __name__ == "__main__":
    main()

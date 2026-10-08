"""Check the exact power-of-two path against CPU FP64 division at rounding edges."""

import argparse
import json
from pathlib import Path

import numpy as np

import runtime


def operands():
    """Return finite operands spanning signs, underflow, overflow and tie rounding.

    Returns
    -------
    tuple of ndarray of float64
        Numerators and nonzero finite divisors in matching one-dimensional arrays.
    """
    powers = np.ldexp(np.ones(2098), np.arange(-1074, 1024))
    tiny = np.nextafter(0.0, 1.0)
    normal = np.finfo(np.float64).tiny
    special = np.array([0.0, -0.0, tiny, -tiny, 3 * tiny, -3 * tiny,
                        np.nextafter(normal, 0.0), normal, -normal,
                        0.5, np.nextafter(0.5, 1.0), 1.0, -1.0,
                        np.finfo(np.float64).max, -np.finfo(np.float64).max])
    a = np.tile(special, powers.size)
    b = np.repeat(powers, special.size)
    rng = np.random.default_rng(20261008)
    raw = rng.integers(0, 2**64, size=65536, dtype=np.uint64)
    raw = raw[((raw >> np.uint64(52)) & np.uint64(2047)) != 2047]
    random_a = raw.view(np.float64)
    random_b = powers[rng.integers(0, powers.size, size=random_a.size)]
    # Adjacent divisors and negative divisors must take the ordinary division path.
    random_b[::2] = np.nextafter(random_b[::2], np.inf)
    random_b[::3] = -random_b[::3]
    return np.concatenate((a, random_a)), np.concatenate((b, random_b))


def main():
    """Compare raw result bits from the actual assembly inverse helper."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cubins", default="bench/.build/gpu/probes.cubin")
    parser.add_argument("--output", type=Path, default=runtime.ROOT / "bench/.runs/gpu/division-check.json")
    args = parser.parse_args()
    metadata = runtime.allocation()
    a, b = operands()
    with np.errstate(over="ignore", under="ignore"):
        expected = a / b
    arrays = [runtime.Array(value) for value in (a, b, np.full(a.size, np.nan))]
    records = []
    try:
        for path in args.cubins.split(","):
            probe = runtime.Probe(runtime.ROOT / path, "division_check")
            try:
                probe.enqueue(a.size, 0, *arrays)
                actual = arrays[2].get()
                mismatch = np.flatnonzero(actual.view(np.uint64) != expected.view(np.uint64))
                if mismatch.size:
                    i = int(mismatch[0])
                    raise AssertionError("Division at index %d differs. Inputs %016x %016x, reference %016x, GPU %016x" % (
                        i, a.view(np.uint64)[i], b.view(np.uint64)[i], expected.view(np.uint64)[i], actual.view(np.uint64)[i]))
                for array, original in zip(arrays[:2], (a, b)):
                    if not np.array_equal(array.get().view(np.uint64), original.view(np.uint64)):
                        raise AssertionError("A division-check input changed.")
                records.append({"cubin": path, "values": a.size, "differing_bytes": 0, **probe.attributes()})
            finally:
                probe.close()
        report = {"passed": True, "metadata": metadata, "records": records,
                  "reference": "One NumPy FP64 division with FPCR=0",
                  "fingerprint": runtime.fingerprint()}
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(records), flush=True)
    finally:
        for array in arrays:
            array.close()


if __name__ == "__main__":
    main()

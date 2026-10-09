"""Check the pressure math library against independent high-precision values.

The library supplies exp and log to both Fortran and direct assembly. Decimal
arithmetic provides a separate numerical reference and does not use this library.
"""
import argparse
import ctypes
from decimal import Decimal, localcontext
import json
import math
from pathlib import Path
import random
import struct


def bits(value):
    """Return the binary64 encoding of a value.

    Parameters
    ----------
    value : float
        Dimensionless input value.

    Returns
    -------
    int
        Unsigned 64-bit representation.
    """
    return struct.unpack("<Q", struct.pack("<d", value))[0]


def oracle(name, value, precision):
    """Evaluate an elementary function with decimal arithmetic.

    Parameters
    ----------
    name : {"exp", "log"}
        Elementary function to evaluate.
    value : float
        Exact binary64 input, interpreted as dimensionless.
    precision : int
        Number of decimal significant digits.

    Returns
    -------
    Decimal
        Independent high-precision result.
    """
    with localcontext() as ctx:
        ctx.prec = precision
        x = Decimal.from_float(value)
        return x.exp() if name == "exp" else x.ln()


def check(library, fpcr_library):
    """Check sampled accuracy, range boundaries and exact identities.

    Parameters
    ----------
    library : pathlib.Path
        Shared library containing the frozen scalar exp and log functions.

    fpcr_library : pathlib.Path
        Shared helper that reads the Arm floating-point control register.

    Returns
    -------
    dict
        Case counts and largest observed error in output spacing units.

    Raises
    ------
    RuntimeError
        A value differs from the independently checked accuracy requirement.

    Notes
    -----
    A unit in the last place, called an ulp, is the spacing beside the rounded
    reference value. These observations do not prove a global error bound.
    """
    control_lib = ctypes.CDLL(str(fpcr_library.resolve()))
    control_lib.openifs_fpcr.restype = ctypes.c_uint64
    control = control_lib.openifs_fpcr()
    if control & 0x03c80000:
        raise RuntimeError('Floating-point rounding or underflow control')
    lib = ctypes.CDLL(str(library.resolve()), use_errno=True)
    rng = random.Random(20261009)
    values = {
        "exp": [0.0, -0.0, 1.0, -1.0, 2.0],
        "log": [1.0, math.nextafter(1.0, 0.0), math.nextafter(1.0, math.inf),
                float.fromhex("0x0.0000000000001p-1022"),
                float.fromhex("0x1.fffffffffffffp+1023")],
    }
    for boundary in (-745.2, -745.1332191019411, -744.0, -708.3964185322641,
                     -512.0, -1.0, -2.0**-54, 2.0**-54, 1.0, 512.0,
                     709.0, 709.782712893384):
        values["exp"].extend([math.nextafter(boundary, -math.inf), boundary,
                              math.nextafter(boundary, math.inf)])
    for exponent in (-1074, -1022, -1000, -100, -1, 0, 1, 100, 1000, 1023):
        x = 2.0**exponent
        values["log"].extend([y for y in (math.nextafter(x, 0.0), x,
                                          math.nextafter(x, math.inf)) if y > 0.0])
    # Exercise range reduction and every table interval near a pressure input.
    for k in range(129):
        x = 0.6875 + k * 0.6875 / 128.0
        values["log"].extend([math.nextafter(x, 0.0), x, math.nextafter(x, math.inf)])
        x = k * math.log(2.0) / 128.0
        values["exp"].extend([math.nextafter(x, -math.inf), x,
                              math.nextafter(x, math.inf)])
    values["exp"].extend(rng.uniform(-745.2, 709.782712893384) for _ in range(8000))
    values["exp"].extend(rng.uniform(-1.0, 1.0) for _ in range(2000))
    for _ in range(10000):
        encoding = rng.randrange(1, 0x7ff0000000000000)
        values["log"].append(struct.unpack("<d", struct.pack("<Q", encoding))[0])
    result = {}
    for name, inputs in values.items():
        function = getattr(lib, name)
        function.argtypes = [ctypes.c_double]
        function.restype = ctypes.c_double
        largest = Decimal(0)
        for value in inputs:
            actual = function(value)
            exact = oracle(name, value, 110)
            rounded = float(exact)
            refined = oracle(name, value, 220)
            if bits(rounded) != bits(float(refined)):
                raise RuntimeError("Independent precision checks disagree")
            if math.isinf(rounded):
                if actual != rounded:
                    raise RuntimeError("Overflow result differs")
                continue
            spacing = Decimal.from_float(math.ulp(rounded))
            with localcontext() as ctx:
                ctx.prec = 230
                error = abs(Decimal.from_float(actual) - refined) / spacing
            if not math.isfinite(actual) or error > 1:
                raise RuntimeError(f"{name} input={value.hex()} actual={actual.hex()} error={error} ulp")
            largest = max(largest, error)
        result[name] = {"cases": len(inputs), "largest_observed_error_ulp": float(largest)}
    if bits(lib.exp(0.0)) != bits(1.0) or bits(lib.exp(-0.0)) != bits(1.0):
        raise RuntimeError("Exponential zero identity")
    if bits(lib.log(1.0)) != bits(0.0):
        raise RuntimeError("Logarithm one identity")
    if control_lib.openifs_fpcr() != control:
        raise RuntimeError('Changed floating-point control register')
    result['fpcr'] = f'{control:016x}'
    return result


def main():
    """Write compact evidence for the independently checked math library."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("library", type=Path)
    parser.add_argument("record", type=Path)
    parser.add_argument("--fpcr-library", type=Path,
                        default=Path(".runtime/openifs/strict-math/libfpcr.so"))
    args = parser.parse_args()
    result = {"oracle": "Decimal with 110 and 220 significant digits",
              "accuracy_requirement_ulp": 1.0, "global_bound_proved": False,
              "seed": 20261009, "functions": check(args.library, args.fpcr_library)}
    args.record.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()

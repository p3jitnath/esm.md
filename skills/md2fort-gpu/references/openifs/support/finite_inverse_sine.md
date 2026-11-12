# Complete Finite Inverse Sine

Revision 1 defines the direct GPU inverse-sine function for finite inputs from minus one through one. The input is dimensionless and the result is an angle in radians. FP64 means a floating-point number stored in 64 bits. The [assembly source](../../../../../src/openifs/support/gpu/finite_inverse_sine.ptx) retains the [ordered inverse-sine calculation](../../../../md2fort/references/openifs/support/asin_original_rounding.md) derived from GNU libc 2.38 and the IBM Accurate Mathematical Library under LGPL-2.1-or-later.

## Arithmetic And Tables

Each ordinary operation rounds once to nearest, with ties to even. The function preserves signed zero and gradual underflow, where very small values retain fewer significant digits. Calls to the [exact product-sum helper](../finite_mathematical_functions.md) round an exact product plus its addend once, as required inside this mathematical function. The caller's physical expressions keep their separate rounding points.

The source chooses a small-input polynomial, one of six table intervals, or an inverse-root calculation near the endpoints. A polynomial is a sum of coefficients times powers of its input. Preserve the original interval boundaries, table indices, coefficient order and every rounding point. The source contract supplies their complete formulas. The root calculation splits a value by separately adding and subtracting two to the power 24. Tiny subnormal inputs retain the discarded square that sets their original arithmetic flags. Exact endpoints return the signed stored half-pi constant, and zero retains its sign.

Three immutable tables contain 2,724 FP64 words. Their separate inverse-sine names allow the inverse-cosine function to remain linked unchanged. The function reads these tables but changes no global storage.

## Function Interface

The callable name is `md2asm_gpu_asin_unit_interval`. Its one PTX `.param.b64` argument carries the input's exact 64-bit representation. The caller admits the finite interval before calling. The result is one eight-byte-aligned, 32-byte parameter object.

| Byte offset | Stored value | Meaning |
| --- | --- | --- |
| 0 | 64-bit result | Angle in radians |
| 8 | 32-bit flags | Newly raised Arm floating-point status bits |
| 12 | 32-bit error event | Zero, which preserves incoming `errno` |
| 16 | 64-bit FAST count | Actual exact product-sum calls using the shorter integer path |
| 24 | 64-bit WIDE count | Actual calls using the wider integer path |

Each call owns its parameter storage and temporary registers. It needs no input buffer, shared memory or barrier. The caller combines new flags with incoming flags by integer OR. Returned totals for helper paths use wrapping integer arithmetic and remain separate from stored counters, whose updates follow the selected source call sites. Store arguments immediately before each child call and consume its return words immediately afterward. The [mathematical support contract](../mathematical_support.md) defines the flag positions and shared helper interfaces.

The source targets PTX 8.5 and `sm_90`. Assemble with `ptxas -c -arch=sm_90 --fmad=false`, then link the accepted operator and exact product-sum objects once with `nvlink`. The function is a device callable, so a parent supplies its launch and complete input checks.

## Accepted Checks

All 9,650 retained finite inputs match the separate original result, flags, error state and actual helper counts across 308,800 complete result bytes. Seeded incoming status, empty input, refusal boundaries, unchanged owners and ordinary device storage also pass through the separate guarded verification entry. Independent high-precision checks on these same inputs find errors below one spacing between adjacent FP64 values. Source review compares every coefficient word and the complete ordered calculation. These results qualify this mathematical component. Full forecast acceptance and timing remain separate.

# Finite Cartesian Direction Angle

Revision 1 defines the direct GPU `ATAN2` function. Cartesian components describe a vector by horizontal value `x` and vertical value `y`. Both inputs are finite FP64 values with matching units, such as metres per second. FP64 stores a floating-point number in 64 bits. The result is the vector's angle from the positive x-axis, in radians from minus pi through pi. The [assembly source](../../../../../src/openifs/support/gpu/finite_direction_angle.ptx) preserves the [ordered CPU direction-angle contract](../../../../md2fort/references/openifs/support/direction_angle_original_rounding.md), derived from GNU libc 2.38 and the IBM Accurate Mathematical Library under LGPL-2.1-or-later.

## Arithmetic And Domain

The function supports both signs of zero, subnormal values and all finite input magnitudes. A subnormal is a very small value with fewer significant digits. Axis cases preserve the source signs and stored pi constants. Both-zero inputs follow the source library's fixed mode-2 convention. The caller admits this finite domain before the call.

Every ordinary FP64 operation rounds once to nearest, with ties to even and gradual underflow. The function separately scales very small or large components before forming a ratio, then retains the original ratio correction, interval choice, table index and polynomial order. It uses the complete 241-row arctangent table under separate immutable names. Its [exact product-sum helper](../finite_mathematical_functions.md) rounds each declared exact product plus addend once. This mathematical helper retains the source arithmetic while the caller's physical expressions keep their own separate rounding points. The linked CPU contract defines every branch and coefficient.

## Function Interface

The callable `md2asm_gpu_atan2_finite` receives two PTX `.param.b64` words in `y, x` order. It returns one eight-byte-aligned, 32-byte parameter object. Each call owns its temporary registers and parameter storage, reads immutable coefficient data and changes no global buffer. No shared memory or barrier is needed.

| Byte offset | Stored value | Meaning |
| --- | --- | --- |
| 0 | 64-bit result | Angle in radians |
| 8 | 32-bit flags | Newly raised Arm floating-point status bits |
| 12 | 32-bit error event | Zero, or 34 for the source underflow-to-zero write |
| 16 | 64-bit FAST count | Actual exact product-sum calls using the shorter integer path |
| 24 | 64-bit WIDE count | Actual calls using the wider integer path |

A zero event preserves the caller's `errno` error value. Event 34 records an actual error-slot write even when the incoming value is already 34. The parent preserves its position in the original operation order. Combine returned flags with incoming flags by integer OR. Returned totals for helper paths use wrapping integer arithmetic and remain separate from stored counters, whose updates follow the selected source call sites. Store child arguments immediately before each call and consume returned values immediately afterward. The [mathematical support contract](../mathematical_support.md) defines the shared status rules.

The target is PTX 8.5 and `sm_90`. Assemble with `ptxas -c -arch=sm_90 --fmad=false` and link the accepted operator and exact product-sum objects once with `nvlink`. A parent owns the launch, complete input checks and storage lifetime.

## Accepted Checks

All 41,576 retained finite input pairs match the separate original across 1,330,432 complete result bytes. The comparison includes returned values, immediate flags, actual error events and actual helper counts. Seeded incoming status, signed axes, exponent extremes, empty work, invalid inputs, protected buffers and ordinary device storage pass. Independent high-precision geometry checks are reused for these same inputs, and source and native-instruction reviews pass. This qualifies a mathematical support function. It adds no weather-routine count or complete-forecast timing result.

# Solar Irradiance Numerical Contract

[The direct lookup](../../../../../src/openifs/physics/solar_irradiance.S) implements [Sun's Irradiance](../../../../../formulations/openifs/physics/solar_irradiance.md), revision 1, equation SI1, for queued `yomsolarirradiance::get_solar_irradiance`.

## Supported Table and Date

NTIME is at least two. Both FP64 tables contain logical indices 1 through NTIME, with strictly increasing finite dates and positive finite irradiance in W m⁻². The input year is finite and strictly between the first and final records. Its selected interval width and date difference are finite. The accepted irradiance result is positive and finite. Native and paired entries reject the endpoint domain rather than supplying an unverified replacement for the original endpoint branches.

The retained forecast loads 450 records from `total_solar_irradiance_CMIP6_47r1.nc`. Its table runs from 1850.5 to 2299.5. All 28 reported dates in the accepted forecast, 2004.786 to 2004.789, are interior. The complete table inputs and narrow source evidence remain local.

## ABI and Storage

The AArch64 application binary interface, or ABI, receives three addresses in `x0–x2`. They point to the GNU Fortran class wrapper, input FP64 year and output FP64 irradiance. The 16-byte class wrapper holds the plain-object data address at byte 0 and a type-table address at byte 8. A metadata-only source probe measures the plain object at 136 bytes. Its GNU rank-one allocatable descriptors start at bytes 0 and 64, and its four-byte NTIME integer starts at byte 128.

Each descriptor holds its data address at byte 0, element offset at byte 8, eight-byte element size at byte 16, element span at byte 32, stride at byte 40, lower bound at byte 48 and upper bound at byte 56. Table element k is at `data+8*(offset+k*stride)`. Allocatable tables have unit stride. The measured source proof and critical cases preserve complete table, object and class owners, including descriptor bytes.

All owners are disjoint and FP64 addresses are aligned to eight bytes. The direct leaf uses no stack frame, array allocation, external numerical call or x18. It preserves `x19–x29`, the low 64 bits of `v8–v15`, stack alignment and the floating-point control register, FPCR.

## Ordered Calculation and Bytes

Scan table intervals from logical index 1 upward. Select the first interval satisfying `year>=lower_year` and `year<upper_year`. Internal date ties therefore select the interval that starts at that date. Form the separately rounded differences `year-lower_year` and `upper_year-lower_year`, then divide to obtain the weight. Subtract the two irradiance values, multiply by the rounded weight, then add the lower irradiance. No fused multiply-add or reassociation is permitted.

Canonical output is the complete eight-byte little-endian irradiance scalar. Every input owner retains its bytes. Arithmetic uses ordered FP64, round-to-nearest with ties to even, gradual underflow and signed zeros. Approximate division, reduced precision and fast-math are excluded. The direct body is emitted as AArch64 assembly and built with an assembler and linker. No driver supplies a missing numerical stage.

## Verification State

Critical verification passes 464 protected placements, 2 784 independent 100-digit interpolation, positive irradiance and interval-bound relations, and 3 712 complete original/native output bytes with zero differences. Cases include the complete actual climate table, rising, falling and constant irradiance, internal date ties, dates next to both endpoints, signed-zero dates, subnormal constant irradiance, uneven time intervals and shifted allocation lower bounds. Complete read-only owners, saved registers and FPCR pass. The paired live smoke passes eighteen genuine calls, 144 output bytes and 54 independent physical relations with zero differences. Both unsupported endpoint dates and a NaN date trap before output. No original endpoint result is repaired or claimed. The focused instruction review excludes fused and approximate arithmetic. Full forecast acceptance still requires genuine forecast calls and the combined saved-file comparison. All work uses exclusive job 7240564 on nid010555, CPU 32 and local memory.

## Positive Optimisation Lesson

Keep the two table addresses and their strides in registers while scanning. This complete scalar lookup needs no work arrays or allocation, and it performs only the selected interval's arithmetic.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| yomsolarirradiance::get_solar_irradiance | 28 | 224 | Source lookup pairs and unchanged private-child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

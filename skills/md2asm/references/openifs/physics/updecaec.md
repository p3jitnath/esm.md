# Complete Monthly Aerosol Update

## Physics And Scope

The [physical input](../../../../../formulations/openifs/physics/monthly_aerosol_fields.md) defines monthly interpolation and cumulative pressure profiles. The original routine is `UPDECAEC` in `arpifs/phys_ec/updecaec.F90`. Its complete numerical children are the direct Gregorian calendar, both direct interpolation ranks, the accepted complete pressure routine and the complete five-species aerosol-profile routine.

The supported deterministic domain uses `NAERMACC` equal to zero or one. Both two-dimensional and three-dimensional monthly mass fields are supported, as are seasonal dust profiles and a fixed volcanic forcing year. Dates use the Gregorian calendar from 1600 through 9998. Elapsed minutes are nonnegative and at most 144,000,000. The final date must remain before year 10000.

## Complete Update

The tropospheric calendar preserves the source's 365.25-day year, 525,960-minute wrap, twelve frozen monthly midpoints and February day length of 1452.8571 minutes. A February start on the twenty-ninth uses the preceding day in this seasonal calendar. The exact positive remainder uses the accepted integer and fractional decomposition from the ozone update.

Each monthly value follows the source order `a2 + w * (a1 - a2)`. Subtraction, multiplication and addition round separately in FP64. The complete two-dimensional child updates all five 72 by 46 optical-thickness fields. When `NAERMACC` is one, it also updates eleven enabled mass fields. The complete three-dimensional child updates eleven species fields and two reference-pressure fields when `LAER3D` is true. These enabled mass fields are the original MACC field group.

The volcanic calendar advances the Gregorian date through the complete direct `UPDCAL` child. Monthly means are centred at midnight on the sixteenth. For each endpoint year, first take the greater of that year and ISYEAR, then take the lesser of the result and IEYEAR. A positive fixed forcing year replaces both endpoints after these limits. The volcanic table has its own year bounds, and both final selected years must lie inside them. This complete volcanic stage always runs. The weights use the final Gregorian year's month lengths. Time interpolation rounds two products and their sum separately. Latitude interpolation then follows `right - fraction * (right - left)` in the source order.

When seasonal dust is enabled, the monthly weight updates its scale height. The complete pressure child computes all half-level and full-level pressures from the supplied hybrid coefficients. Full-level scratch is retained, while this parent consumes half levels. Each half-level pressure is divided by surface pressure before complete `SU_AERV` updates all five boundary profiles. Each profile has `NFLEVG + 1` values. The shared original-compatible POWER primitive supplies the qualified FP64 power operation.

The final small optical-thickness constant is the original FP64 value `1.0e-12`. Formatted diagnostic text and profiling records are outside canonical numerical output.

## Interface And Owners

The application binary interface, or ABI, describes how arguments enter the routine and which registers it preserves. Five address arguments point to geometry, radiation, physics, the initial integer date and elapsed integer minutes. Integers are signed 32-bit values, dates use `YYYYMMDD`, and arrays contain FP64 values. The 416-byte frame is aligned to sixteen bytes and preserves x19 through x29, the return address and the required lower 64 bits of v8 through v15. It does not use x18. Ordinary allocation holds private pressure scratch and supplies no numerical calculation.

The verified GNU type sizes are 17,096 bytes for geometry, 2,040 bytes for radiation and 175,976 bytes for physics. Their member offsets are frozen in the retained genuine Fortran probe. A descriptor is a small record that stores an array address, element size, strides and bounds. GNU FP64 descriptors use an eight-byte element size, contiguous strides and declared bounds. Monthly axes have twelve entries. Tegen and volcanic latitude indices start at one. The volcanic descriptor records its year bounds separately from ISYEAR and IEYEAR. A boundary profile can include unused values before or after logical indices one through NFLEVG + 1; those values keep their original bytes. Disabled three-dimensional fields do not consume NMCLEV. Tropospheric arrays have shape 72 by 46 by 12. Volcanic arrays have shape 24 by year count by 12, with the second-axis lower and upper bounds stored in their descriptor. Volcanic latitudes decrease strictly and cover both poles.

Each enabled mass-field dimension is positive and at most 4096. Their product is at most 16,777,216, and the pressure grid has one through 512 layers. Complete inputs are read-only. Every output has its full extent and is disjoint from consumed inputs and other outputs.

Canonical output contains complete radiation and physics object bytes, all five boundary profiles, and every enabled two-dimensional and three-dimensional mass field in recorded order. Descriptors retain the caller's pointer words. Inputs, disabled fields and padding remain unchanged. Output uses native little-endian FP64 bytes, with zero differing bytes as the acceptance limit.

## Direct Build

The parent is [updecaec.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/updecaec.S). Its leaves are [aerosol_calendar.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/aerosol_calendar.S) and [monthly_aerosol_interpolation.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/monthly_aerosol_interpolation.S). Assemble each, then link accepted complete `GPHPRE` under the private name `md2asm_updecaec_private_gphpre` and complete `SU_AERV`. Private aliases prevent replacement of unrelated global children. Original-compatible POWER remains a uniquely named dependency. Full commands and object identities remain local.

## Focused Evidence

The source passed before emission. Sixteen protected source/native placements compare 3,092,672 complete owner bytes with zero differences. The original gate checks 591,264 independent monthly, volcanic and pressure-profile relations at 120 decimal digits. Checking both implementations gives 1,182,528 relations. The largest newly checked POWER error is 0.499220 ULP, where one ULP is the gap between adjacent FP64 values.

The cases cover all five species, year rollover, ordinary and leap-year February, elapsed time beyond one year, year clamping, a fixed year, both aerosol modes, seasonal profiles on and off, and complete two-dimensional and three-dimensional fields. Protected starts and ends, read-only complete inputs, inactive owners, padding, immediate saved registers and FPCR equal to zero pass. Unchanged calendar and interpolation proofs are reused.

 Comparative timing remains open.

The live paired adapter passes four focused calls over 722,224 complete returned bytes with zero differences, 134,804 independent relations at 120 decimal digits and 134,794 live relations. It clones the complete radiation and physics objects and all output owners. Only the source copy's output descriptor addresses are changed. The adapter checks that every descriptor stays unchanged, then restores its caller address before complete byte comparison. It does not change any numerical bits. Fresh floating-point status and immediate register checks pass.

Private call counters record 53 two-dimensional interpolation calls over 531,856 extent bytes, 26 three-dimensional calls and one complete profile call. These extent counts identify child work; the complete parent bytes establish agreement. Four prewrite checks reject a bad stride, output/input sharing, an invalid date and a latitude lower-bound error while preserving all 183,232 public bytes in each case. Both libraries load from another working directory. The accepted sixteen-call parent gate, 102 calendar checks and 64 interpolation checks are reused. No separate forecast or timing run is added.

The actual source packet selects year 1850 when ISYEAR is 2100 and IEYEAR is 1850, because the two limits retain their original order. The complete table covers years 1850 through 2100. Four focused corrected paired calls, including fixed years 2004 and 2100, pass 2,647,744 complete bytes with zero differences, 1,782,889 independent 120-digit relations and 616,406 live relations. Four unsupported selected-year cases stop before any of their 822,976 public bytes change. Fresh status, immediate ABI and FPCR checks pass. The native body, physical equations and earlier complete proofs remain unchanged.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| updecaec | 26 | 21,397,376 | Complete returned routine owners |
| updecaec::update_arr_2d | 416 | 21,397,376 | Native private monthly-interpolation child, complete monthly-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

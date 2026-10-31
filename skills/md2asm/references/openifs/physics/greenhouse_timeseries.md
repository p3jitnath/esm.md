# Greenhouse-Gas Lookup Contract

[The direct lookup](../../../../../src/openifs/physics/greenhouse_timeseries.S) implements [Greenhouse-Gas Time Series](../../../../../formulations/openifs/physics/greenhouse_timeseries.md), revision 1, equations G1–G2. It replaces the complete queued `yomghgtimeseries::get_ghg_concentrations` interior-date body. The immediate caller is UPDRGAS, which calls this lookup before converting its seven volume ratios into mass ratios.

## Inputs and Source Domain

A date must be finite and strictly between the first and final table dates. NTIME is at least two. Dates are finite and strictly increasing. All seven gas tables have finite nonnegative values. The selected time width and time difference must be finite. Each allocatable vector has unit stride, includes logical indices 1 through NTIME, and may have a lower allocation bound below one.

The original endpoint branches set IVAL while the final expressions use JT, which those branches do not assign. This accepted domain excludes both endpoints and dates outside them. The direct entry rejects those dates before reading a gas interval. It does not invent clamped values. The actual frozen forecast has 28 reported dates from 2004.786 to 2004.789, inside the supplied 0.5–2500.5-year table.

The source reader gives separate HCFC22 and carbon tetrachloride tables positive zero when those optional variables are absent. This is the supplied equivalent-CFC11 input convention. The lookup receives those complete tables and performs all seven calculations itself.

## ABI and Storage

The GNU Fortran application binary interface, or ABI, receives nine addresses. SELF, year and the first six gas outputs use x0–x7. The final carbon tetrachloride output uses the first eight-byte caller stack slot. Each gas output is one aligned eight-byte FP64 owner.

SELF is a 16-byte class wrapper with its data pointer at byte zero. It points to the measured 520-byte plain TGHGTIMESERIES object. The eight 64-byte GNU rank-one descriptors start at bytes 0, 64, 128, 192, 256, 320, 384 and 448, for year, CO2, CH4, N2O, CFC11, CFC12, HCFC22 and CCl4. NTIME is a four-byte integer at byte 512. Descriptor fields are data at byte 0, element offset at 8, element size at 16, span at 32, stride at 40, and lower and upper bounds at 48 and 56. Logical index j uses data plus eight times the element offset plus j times stride.

The class, plain object, year and complete table owners are read-only. The seven output owners are disjoint and do not alias any input. Tables and outputs have eight-byte alignment. The direct leaf uses caller-saved integer and floating-point registers, preserves x19–x29 and the low 64 bits of v8–v15, avoids x18, leaves the stack unchanged and preserves FPCR.

## Ordered Calculation and Output

Scan the intervals from left to right. Select the first j with year at least RYEAR(j) and strictly below RYEAR(j+1). Preserve an internal tie by selecting the interval that begins at the matching table date. Form delta = year - RYEAR(j), width = RYEAR(j+1) - RYEAR(j), then weight = delta / width, with a separate FP64 rounding after each operation.

For each gas, load a = table(j) and b = table(j+1). Form difference = b - a, product = weight * difference, then result = a + product. Store the gases in the original order CO2, CH4, N2O, CFC11, CFC12, HCFC22 and CCl4. No driver provides an interpolation stage.

Arithmetic uses round-to-nearest with ties to even, gradual underflow and preserved signed zeros. Fused multiply-add, reassociation, approximate division and fast-math are forbidden. Canonical output is the seven raw little-endian FP64 values in that order, totalling 56 bytes. Acceptance requires zero differing output bytes, complete read-only owners, independent interpolation bounds, protected buffers, immediate saved-register checks and FPCR zero.

## Checks and Positive Optimisation

Reuse the accepted solar lookup's independent weighted-average proof. For each gas, compare with `((t_1-t)*a+(t-t_0)*b)/(t_1-t_0)` at 100 decimal digits, using its established rounding bound. Check nonnegativity and that the result lies between the surrounding values. Added checks cover seven distinct output owners, the ninth-address stack argument, source-defined zero gas tables and shifted descriptor lower bounds. Actual table dates and caller evidence are retained locally.

Reuse the single interval scan and rounded weight across all seven independent gas outputs. Keep the descriptor object in one register and emit the seven short interpolation blocks directly. This complete leaf needs no stack frame, allocation or external numerical helper.

## Verification State

The focused verifier passes 100 protected placements, 5 600 complete output bytes and 4 200 independent 100-digit gas interpolation relations with zero differences. All eight table owners, the class, plain object and year remain unchanged. Distinct gas values, two source-defined zero gases, subnormal values, signed zero dates, internal ties, near-endpoint dates and shifted allocation bounds pass the immediate ABI and FPCR checks.

The paired smoke passes twelve genuine calls, 672 output bytes and 252 live gas relations with zero differences. The first date, final date and NaN dates are rejected before numerical execution. The full original endpoint branch is outside the accepted domain. Forecast acceptance still requires genuine live calls and saved-file comparison.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| yomghgtimeseries::get_ghg_concentrations | 28 | 1,568 | Source lookup pairs and unchanged private-child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

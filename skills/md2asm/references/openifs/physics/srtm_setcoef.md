# Shortwave Atmospheric Preparation Contract

Revision 1 implements SRTM_SETCOEF from OpenIFS 48.1.1. Its [physics note](../../../../../formulations/openifs/physics/shortwave_atmospheric_inputs.md), revision 1.0, supplies SAI-1 through SAI-3. The [direct assembly](../../../../../src/openifs/physics/srtm_setcoef.S) must calculate every gas amount, index and interpolation factor. A local driver supplies no missing numerical stage.

## Ordered Arithmetic

FP64 stores each real in 64 bits. RN means one FP64 operation with nearest rounding and an even result at an exact halfway point. All source arithmetic uses separate RN operations, gradual underflow and preserved signed zeros. FPCR, the Arm floating-point control register, equals zero. Use no fused arithmetic, reassociation, approximate division or reduced-precision operation.

Reuse the accepted non-fused scalar LOG route and its independent high-precision evidence. For each daylight cell, compute L = LOG(p), J = INT(RN(36 − RN(5 × RN(L + c)))), and clamp J to the integers 1 through 58. INT discards the fractional part towards zero. The pressure shift c is the exact FP64 promotion of the source REAL4 literal 0.04. Compute F = RN(5 × RN(PREFLOG[J] − L)).

For both reference temperature rows J and J+1, compute z = RN(RN(T − TREF[row]) / 15). Clamp INT(RN(3+z)) to integers 1 through 4, then subtract that clamped index minus three from z. This yields the two temperature fractions t and t1. Preserve each subtraction, division and integer conversion.

Compute w = RN(N_w/N_d), s = RN(RN(p × RN(296/1013)) / T), and f = RN(s/RN(1+w)). A cell is below the table tropopause when J < 13. Count these lower cells independently in each daylight column. Lower cells compute the foreign temperature coordinate RN(RN(332−T)/36), with its index clamped to 1 through 2, and a = RN(wf). The self coordinate is RN(RN(T−188)/c7), where c7 promotes the source REAL4 literal 7.2. Its index clamps INT(coordinate)−7 to 1 through 9. Subtract the corresponding integer row from each coordinate to obtain its fraction.

Upper cells use foreign index three, fraction RN(RN(RN(T−188)/36)−1), and positive-zero self factors, self fractions and self indices. Their foreign factors still obey SAI-3. Night cells and rows after KLEV retain every supplied output bit.

Scale water, carbon dioxide, ozone, methane and oxygen amounts using the frozen FP64 promotion of the source REAL4 literal 1.E−20. Form the total column as RN(RN(scale × N_d) + stored water amount). When a scaled carbon dioxide, methane or oxygen amount equals zero, replace it with RN(floor × N_d), using the promoted source REAL4 literal 1.E−32. These are frozen parameter values, with every live arithmetic operation in FP64. The unused Z_CO2REG local has no returned value and no consumer.

Let C = RN(1−F). Store FAC10 = RN(Ct), FAC00 = RN(C × RN(1−t)), FAC11 = RN(Ft1) and FAC01 = RN(F × RN(1−t1)). These four factors interpolate the surrounding pressure and temperature table values. Preserve this storage order and every dependency.

## Twenty-Nine-Address ABI

The application binary interface, or ABI, defines arguments and preserved registers. x0 through x7 contain the first eight addresses below. Incoming stack bytes zero through 160 contain the other twenty-one addresses in order. The original entry is srtm_setcoef_ at offset 0x881560. The default direct entry is md2asm_srtm_setcoef.

Define B = KFDIA − KIDIA + 1, H = KLEV and V = YDDIMV%NFLEVG. YDDIMV is a 32-byte object whose first INTEGER4 value is V. Every dummy matrix starts at its explicit KIDIA label, so the supplied address already points to the first selected column. Columns are contiguous, followed by layers. PWKL has columns, thirty-five gases and then layers, so its gas and layer pitches differ from the ordinary matrices.

| Position | Argument | Owner |
| ---: | --- | --- |
| 1 | YDDIMV | 32-byte TDIMV input |
| 2 | KIDIA | One INTEGER4 input |
| 3 | KFDIA | One INTEGER4 input |
| 4 | KLEV | One INTEGER4 input |
| 5 | PAVEL | B × V FP64 input |
| 6 | PTAVEL | B × V FP64 input |
| 7 | PCOLDRY | B × V FP64 input |
| 8 | PWKL | B × 35 × V FP64 input |
| 9 | KLAYTROP | B INTEGER4 output |
| 10 | PCOLCH4 | B × V FP64 output |
| 11 | PCOLCO2 | B × V FP64 output |
| 12 | PCOLH2O | B × V FP64 output |
| 13 | PCOLMOL | B × V FP64 output |
| 14 | PCOLO2 | B × V FP64 output |
| 15 | PCOLO3 | B × V FP64 output |
| 16 | PFORFAC | B × V FP64 output |
| 17 | PFORFRAC | B × V FP64 output |
| 18 | KINDFOR | B × V INTEGER4 output |
| 19 | PSELFFAC | B × V FP64 output |
| 20 | PSELFFRAC | B × V FP64 output |
| 21 | KINDSELF | B × V INTEGER4 output |
| 22 | PFAC00 | B × V FP64 output |
| 23 | PFAC01 | B × V FP64 output |
| 24 | PFAC10 | B × V FP64 output |
| 25 | PFAC11 | B × V FP64 output |
| 26 | KJP | B × V INTEGER4 output |
| 27 | KJT | B × V INTEGER4 output |
| 28 | KJT1 | B × V INTEGER4 output |
| 29 | PRMU0 | B FP64 solar-cosine input |

Inputs and outputs are disjoint, and output owners are mutually disjoint. FP64 addresses align to eight bytes, and INTEGER4 addresses align to four bytes. Preserve x18, x19 through x30 and the low halves of v8 through v15. Keep the stack aligned to sixteen bytes. The direct caller has no scalar return.

## Inputs And Independent Acceptance

Support 0 ≤ B ≤ 4096 and 0 ≤ H ≤ V ≤ 512, with positive first labels. Empty work has KFDIA = KIDIA − 1. Used pressure and temperature are positive and finite, dry-air amount is positive and finite, and selected gas amounts are nonnegative and finite. Require finite intermediate factors and integer conversions within their signed 32-bit range. The solar cosine is finite in [−1,1]. Unused night inputs and unselected gas species may carry arbitrary bits.

Reuse the accepted genuine PREFLOG and TREF setup and the scalar LOG proof. Check the original routine's independent physical equations before emitting the parent. Use high-precision density and water-fraction relations, exact molecular amount balances, the four-factor partition sum and source-defined integer/table bounds. Track source parameter rounding separately from FP64 arithmetic error. Exact byte comparisons preserve all source constants and all output bits.

Use both protected buffer placements for changed labels, daylight, night and mixed columns, empty intervals, zero layers, odd column counts, vertical tails, absent trace gases and capacity limits. Inputs stay read-only and outputs stay within their complete owners. Compare all twenty returned owners in ABI order, with little-endian INTEGER4 and FP64 bytes. Zero differing bytes is the acceptance limit. The focused observer checks preserved registers and FPCR. Actual calls and the ten saved forecast files must pass before acceptance.

The physical and numerical contract is frozen before direct emission. The original passed eighteen protected calls, 2,494,864 complete returned bytes and 146,590 independent physical relations before direct emission. Native checks passed the same eighteen placements and complete bytes with zero differences, 293,180 independent relations and the immediate twenty-nine-address ABI. The cases include 4,096 columns, 512 layers, zero layers, changed labels, vertical tails, zero trace gases, night and mixed columns. Inputs remain read-only, guards are unchanged and FPCR is zero. The paired smoke passed two genuine captured calls, 40,192 returned bytes with zero differences and 4,336 live relations.  No speed gain is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 128,614,400 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.

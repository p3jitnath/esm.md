# Longwave Band 6 Contract

Revision 1 implements the complete `RRTM_TAUMOL6` calculation from the [physics note](../../../../../formulations/openifs/physics/longwave_water_trace_gas_absorption.md). It returns absorption depth and Planck fraction at the eight spectral points from 69 through 76 of the 140-point longwave array. Both atmospheric branches and the complete empirical carbon-dioxide adjustment are included.

## Inputs And Scope

Use the genuine unchanged Band 6 tables, including the 65-row water table, 19-row carbon-dioxide table, ten-row self continuum, four-row foreign continuum, CFC coefficients and Planck fractions. Reuse the accepted full radiation setup followed by `SURRTRF` reference-atmosphere setup. The Band 6 grouping joins eight pairs of original spectral points. Its water mixture stride `NSPA(6)` is one.

Columns number zero through 4096, and supplied levels number zero through 512. The active level count is at most the supplied count. An empty column or active-level range preserves every output byte. The tropopause index lies between zero and the active level count. Inputs and both output owners are disjoint. Every array is contiguous, with columns varying first. Pressure indices in a consumed lower cell are one through twelve, temperature indices are one through four, and the adjacent self, foreign and minor indices are one through nine, one through three and one through eighteen. Upper cells do not consume any of these indices or the lower gas and continuum fields.

Consumed gas amounts, continua and aerosol depths are nonnegative and finite. The dry-air column and consumed carbon-dioxide reference fraction are positive. The interpolation fractions and four weights are finite, with magnitude at most `2^20`. Intermediate results remain finite. The source permits extrapolated table weights, while independent nonnegative-absorption checks apply to bounded physical weights. Preserve inactive spectral points, unused supplied levels and all immutable input bytes.

## Ordered Calculation

Use FP64, the 64-bit floating-point format, with round-to-nearest, ties to even, gradual underflow and signed zeros, with FPCR zero. Preserve every source rounding point. Do not fuse, contract, reassociate, approximate or reduce precision. Real power uses the uniquely named accepted original-rounding POWER primitive. Keep its existing independent accuracy, source-bit, exception and integer-emulation proof unchanged.

For each active lower cell, divide the carbon-dioxide column by dry air, multiply by `1e20` and divide by the selected reference fraction. Compare that rounded ratio with three. If it is greater, subtract two, evaluate the complete power with FP64 exponent `0.77`, add two, then multiply successively by the reference fraction, dry column and `1e-20`. Otherwise retain the original column bits.

Form the two water rows from pressure and temperature. Preserve the weighted line order `fac00*A0 + fac10*A0_next + fac01*A1 + fac11*A1_next`, then multiply by the water column. Each continuum and minor coefficient uses `base + fraction*(next-base)` with its own rounding points. Multiply self and foreign interpolants by their factors. Add water, self, foreign, CFC-11, CFC-12, adjusted carbon-dioxide and aerosol terms in that order. Upper cells start from positive zero and add CFC-11, CFC-12 and aerosol terms in that order. Copy the exact selected Planck word for each spectral point.

## Interface And Output

The [assembly](../../../../../src/openifs/physics/rrtm_taumol6.S) exports `md2asm_rrtm_taumol6` and the original-compatible symbol `rrtm_taumol6_`. The application binary interface (ABI) defines argument locations and preserved caller state. All 27 arguments are addresses, ordered as TDIMV, first column, last column, active levels, depth, trace gases, aerosols, four line weights, foreign factor, foreign fraction, foreign index, pressure index, two temperature indices, water, carbon dioxide, dry air, tropopause, self factor, self fraction, self index, Planck fraction, minor fraction and minor index. The first eight addresses use `x0` through `x7` and the remaining nineteen use the incoming stack. These explicit-shape arrays have no entry descriptors. The local column extent is last minus first plus one, and TDIMV supplies the level extent at byte zero.

Eight-byte aligned FP64 arrays store canonical depth and Planck owners in native-endian column, then spectral-point, then level order. Integer arrays contain four-byte values. Restore `x19` through `x29`, the return address and the low halves of `v8` through `v15`. Leave `x18` unchanged and preserve sixteen-byte stack alignment. The fixed frame is 512 bytes, with no dynamic workspace. The driver supplies no omitted numerical stage.

## Acceptance

Before emission, independently check the new table atoms, raw water record and weighted reductions. Reuse unchanged reference-atmosphere and scalar-math evidence. Verify original output against the unrounded sum of physical absorption components, expressing adjacent interpolation as a convex or extrapolated weighted pair. Compute the empirical carbon-dioxide law in wider arithmetic. Require finite outputs, nonnegative bounded absorption, exact selected Planck words and every untouched output byte. The empirical Planck data sum to approximately one, without changing or normalising any source word.

The original passed 72 protected calls over 2,338,560 returned depth and fraction bytes and 14,400 independent physical relations. The cases include 1,920 adjusted carbon-dioxide spectral cells, both atmospheric branches, all four water corners, signed zeros, subnormal products, interpolation edges, empty ranges and unused upper-cell inputs. The new table gate passed 808 independent reduction relations and 576 exact source literal words, reusing 413 reference-atmosphere words. Its largest error used 0.00883 of the declared rounding budget. The native gate passed the same 72 protected calls, 2,338,560 returned bytes and 14,400 physical relations with zero differences. Six immediate 27-address ABI cases and six paired cases each passed 58,240 returned bytes and 320 relations. The direct object has no fused or approximate instruction. Actual forecast acceptance requires positive genuine calls and zero differing saved files. Detailed controls and records remain under `.runtime/openifs/weather24h-longwave6/`. Timing is a later gate.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| rrtm_taumol6 | 6,400 | 4,082,892,800 | Native private band, compared complete gas-parent owners and child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

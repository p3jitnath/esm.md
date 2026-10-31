# Longwave Band 8 Contract

Revision 1 implements complete `RRTM_TAUMOL8` from the [physics note](../../../../../formulations/openifs/physics/longwave_water_ozone_minor_gas_absorption.md). It returns optical depth and Planck fraction at the eight spectral points from 89 through 96 of the 140-point longwave array. Both atmospheric branches and the complete carbon-dioxide adjustment are included.

## Inputs And Scope

Use genuine unchanged Band 8 tables. The water and ozone tables have 65 and 235 rows. Each region has nineteen-row carbon-dioxide and nitrous oxide tables. The lower region also has a nineteen-row ozone table, ten self-continuum rows and four foreign-continuum rows. Both regions have fixed Planck fractions and CFC-12 and CFC-22 coefficients. The accepted full radiation and reference-atmosphere setup is reused. Eight pairs of original spectral points are reduced. Both species strides are one.

Columns number zero through 4096 and supplied levels zero through 512. Active levels do not exceed supplied levels. Empty ranges preserve outputs. Tropopause indices lie between zero and active levels. Lower pressure indices are one through twelve and upper indices thirteen through fifty-eight. Both temperature indices are one through four. Consumed self, foreign and minor indices are one through nine, one through three and one through eighteen. Upper cells do not consume water or water-continuum inputs. Only trace-gas slots three and four are consumed.

Consumed gas, continuum and aerosol amounts are finite and nonnegative. Dry-air columns and selected reference carbon-dioxide fractions are positive. Interpolation fractions and four weights are finite, with magnitude at most `2^20`. Intermediate results remain finite. Extrapolated weights are supported, while independent nonnegative absorption applies to bounded physical weights. Output owners are disjoint from each other and from inputs. Preserve all untouched outputs and input bytes.

## Ordered Calculation

Use FP64 with round-to-nearest, ties to even, gradual underflow, signed zeros and FPCR zero. Preserve every source rounding point. Do not fuse, contract, reassociate, approximate or reduce precision. Reuse the unchanged unique original-rounding POWER primitive with exponent `0.65`.

In both regions, divide carbon dioxide by dry air, multiply by `1e20` and divide by the selected reference fraction. Compare that rounded ratio with three. Above it, subtract two, evaluate power, add two and multiply successively by the reference fraction, dry column and `1e-20`. Otherwise retain the original carbon-dioxide bits.

Form four pressure–temperature terms in order, `fac00*A0 + fac10*A0_next + fac01*A1 + fac11*A1_next`, then multiply by water below the tropopause or ozone above it. Every continuum and minor coefficient uses `base + fraction*(next-base)` with separate rounding points. Below the tropopause, add self continuum, foreign continuum, adjusted carbon dioxide, ozone, nitrous oxide, CFC-12, CFC-22 and aerosol in order. Above it, add adjusted carbon dioxide, nitrous oxide, CFC-12, CFC-22 and aerosol. Copy the exact selected regional Planck word.

## Interface And Output

The [assembly](../../../../../src/openifs/physics/rrtm_taumol8.S) exports `md2asm_rrtm_taumol8` and original-compatible `rrtm_taumol8_`. The application binary interface (ABI) defines argument locations and preserved state. All 29 arguments are addresses in original order. They are TDIMV, first column, last column, active levels, depth, trace gases, aerosols, four weights, foreign factor, foreign fraction, foreign index, pressure index, two temperature indices, water, ozone, nitrous oxide, carbon dioxide, dry air, tropopause, self factor, self fraction, self index, Planck fraction, minor fraction and minor index.

The first eight addresses use `x0` through `x7` and twenty-one use the incoming stack. Explicit-shape arrays have no entry descriptors. TDIMV supplies levels at byte zero. Eight-byte aligned FP64 arrays store columns, then spectral points, then levels in native-endian order. Integers are four-byte words. Preserve inactive spectral points and supplied-level tails. Restore `x19` through `x29`, the return address and low halves of `v8` through `v15`, leave `x18` unchanged and preserve sixteen-byte stack alignment. The fixed frame is 640 bytes, without dynamic workspace. No driver supplies a numerical stage.

## Acceptance

Before emission, the original passes 72 protected calls, 2,338,560 complete output bytes and 14,400 independent physical relations. Wider arithmetic reconstructs the physical absorption sum with weighted table pairs and the complete carbon-dioxide law. Cases cover 3,072 lower and 4,128 upper spectral cells, 4,800 adjusted cells, all four corners, interpolation boundaries, signed zeros, tiny products, empty ranges and unused upper inputs. All 2,223,360 untouched bytes remain unchanged.

The new table gate passes 3,304 independent reductions and 1,808 exact literal words, reusing 413 reference-atmosphere words. Raw record eight contains 38,400 bytes. Its 100-digit calculation uses at most 0.0100 of the rounding budget. Empirical Planck sums are approximately one, without normalisation. Require zero differing output bytes, independent physical agreement, protected bounds, immutable inputs, immediate ABI checks and paired actual-call agreement. The native body passes the same 72 calls, 2,338,560 returned bytes and 14,400 independent relations with zero differences. Six immediate 29-address ABI cases and six paired cases each pass 58,240 returned bytes and 320 physical relations across both atmospheric regions. The direct object has no fused or approximate instruction. Actual forecast acceptance and timing are later gates. Local tools and records remain under `.runtime/openifs/weather24h-longwave8/`.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| rrtm_taumol8 | 6,400 | 4,082,892,800 | Native private band, compared complete gas-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

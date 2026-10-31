# Longwave Band 9 Contract

Revision 1 implements complete `RRTM_TAUMOL9` from the [physics note](../../../../../formulations/openifs/physics/longwave_water_methane_nitrous_oxide.md). It returns depth and Planck fraction at twelve spectral points, 97 through 108 of the 140-point array. Both atmospheric branches, both pressure corners, mixture endpoint corrections and nitrous oxide adjustment are included.

## Inputs And Scope

Use unchanged genuine Band 9 tables. Lower and upper absorption tables have 585 and 235 rows. The lower table has nine mixture nodes, five temperatures and thirteen pressures. The upper table has one species node, five temperatures and forty-seven pressures. Lower nitrous oxide has nine mixture nodes and nineteen minor-temperature nodes. Its upper table has nineteen temperature nodes. Self and foreign continua have ten and four rows. Lower Planck fractions have nine mixture nodes. Upper fractions have one value per spectral point. Reuse the accepted full radiation and reference-atmosphere setup. Spectral reduction joins eight single points followed by four pairs.

Columns number zero through 4096 and supplied levels zero through 512. Active levels do not exceed supplied levels. Empty ranges preserve outputs. Tropopause indices lie between zero and active levels. Lower pressure indices are one through twelve, upper indices thirteen through fifty-eight, and both temperature indices one through four. Consumed self, foreign and minor indices are one through nine, one through three and one through eighteen. The mixture cap is positive and smaller than one.

Consumed gas columns, continuum factors and aerosols are finite and nonnegative. Dry-air columns and selected reference fractions are positive. Consumed mixtures have positive finite totals and finite nonnegative ratios. Table weights and interpolation fractions are finite, with magnitude at most `2^20`. All intermediate values remain finite. Upper cells do not consume water, lower mixture ratios or water-continuum inputs. Layer-switch and low-layer arguments are unused. Output owners are disjoint from each other and from inputs.

## Ordered Calculation

Use FP64, round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Preserve every source rounding point. Do not fuse, contract, reassociate, approximate or reduce precision. Reuse the qualified unique original-rounding POWER helper with exponent `0.65` and its unchanged proof.

Compute reference water-to-methane ratios at pressure nodes nine and three. In every active cell, divide nitrous oxide by dry air, multiply by `1e20` and divide by its selected reference fraction. Compare the rounded ratio with `1.5`. Above it, subtract `0.5`, evaluate power, add `0.5` and multiply successively by reference fraction, dry column and `1e-20`. Otherwise preserve the supplied nitrous oxide bits.

Below the tropopause, form each mixture `Q = water + ratio*methane`, divide water by `Q` and cap it. Multiply by eight, truncate the nonnegative integer part and subtract it for the interpolation fraction. The central interval from `0.125` through `0.875` uses four weighted adjacent terms. Either endpoint uses six terms from the fourth-power correction. Square the displacement and square again, then form the original three weights. The high-end route reverses weights and starts one node earlier. Sum terms left to right, multiply each pressure sum by its separately rounded mixture total, and add main depths, self continuum, foreign continuum, corrected nitrous oxide and aerosol in order.

Each continuum uses `base + fraction*(next-base)`. Lower nitrous oxide interpolates mixture nodes at each of two minor-temperature nodes, then interpolates those two results. Lower Planck interpolation uses the reference ratio at pressure node nine. Above the tropopause, form four methane pressure–temperature terms in order, multiply by methane, then add corrected nitrous oxide and aerosol. Copy the upper Planck word exactly.

## Interface And Output

The [assembly](../../../../../src/openifs/physics/rrtm_taumol9.S) exports `md2asm_rrtm_taumol9` and `rrtm_taumol9_`. The application binary interface (ABI) defines argument and register obligations. All 32 arguments are addresses in original order. They are TDIMV, first column, last column, active levels, depth, aerosols, four weights, foreign factor, foreign fraction, foreign index, pressure index, two temperature indices, mixture cap, water, nitrous oxide, methane, dry air, tropopause, layer switch, low layer, self factor, self fraction, self index, Planck fraction, two water–methane ratios, minor fraction and minor index.

The first eight addresses use `x0` through `x7`, and twenty-four use the incoming stack. Explicit-shape arrays have no entry descriptors. TDIMV supplies levels at byte zero. Eight-byte aligned FP64 owners store columns, then spectral points, then levels in native-endian order. Integers are four-byte words. Preserve inactive spectral points, level tails and inputs. Restore `x19` through `x29`, the return address and low halves of `v8` through `v15`. Leave `x18` unchanged and preserve sixteen-byte stack alignment. The fixed frame is 768 bytes, without dynamic workspace or driver-supplied stages.

## Acceptance

Before emission, the original passes 200 protected calls, 5,376,000 returned bytes and 48,960 independent physical relations. Wider arithmetic reconstructs the physical component sum and nitrous oxide law with weighted table pairs. Cases cover 10,944 lower and 13,536 upper spectral cells, 17,856 adjusted cells, all endpoint combinations, threshold neighbours, corners, signed zeros, tiny products, empty ranges and unused upper inputs. All 4,984,320 untouched output bytes are preserved.

The new table gate passes 12,408 independent reduction relations and 3,424 exact literal words, reusing 413 reference-atmosphere words. Raw record nine contains 104,960 bytes. A 100-digit calculation uses at most 0.0101 of its rounding budget. Empirical Planck sums are approximately one, without normalisation. Require zero differing complete output bytes, immutable inputs, protected bounds, immediate ABI checks and paired actual-call agreement. The native body passes the same 200 calls, 5,376,000 output bytes and 48,960 independent relations with zero differences. Six immediate 32-address ABI cases and six paired cases each pass 67,200 complete output bytes and 528 physical relations, including both atmospheric branches. The direct object contains no fused or approximate instruction. Forecast acceptance and timing are later gates. Local tools and records remain under `.runtime/openifs/weather24h-longwave9/`.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| rrtm_taumol9 | 6,400 | 4,082,892,800 | Native private band, compared complete gas-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

# Longwave Band 3 Contract

Revision 1 implements complete `RRTM_TAUMOL3` from the [physics note](../../../../../formulations/openifs/physics/longwave_water_carbon_dioxide_nitrous_oxide.md). It returns depth and Planck fraction at sixteen spectral points from 23 through 38 of the 140-point array. Both water–carbon-dioxide mixtures, both regions, complete nitrous oxide adjustment and all continuum terms are included.

## Inputs And Scope

Use genuine unchanged Band 3 tables and accepted full radiation and reference-atmosphere setup. The lower main table has 585 rows, with nine mixture nodes, five temperatures and thirteen pressures. The upper main table has 1175 rows, with five mixture nodes, five temperatures and forty-seven pressures. Both nitrous oxide tables have nineteen minor-temperature nodes, with nine lower or five upper mixture nodes. Lower and upper Planck tables have nine and five mixture nodes. Self and foreign continua have ten and four rows. All sixteen original spectral points remain separate.

Columns number zero through 4096 and supplied levels zero through 512. Active levels do not exceed supplied levels. Empty ranges preserve outputs. Tropopause indices lie between zero and active levels. Lower pressure indices are one through twelve and upper indices thirteen through fifty-eight. Both temperature indices are one through four. Foreign indices are one through three and minor indices one through eighteen in both regions. Self indices are one through nine below the tropopause and unused above it. The mixture cap is positive and smaller than one.

Gas columns, consumed continuum factors and aerosols are finite and nonnegative. Dry air and selected reference fractions are positive. Every consumed mixture total is finite and positive. Main ratios are finite and nonnegative. Interpolation fractions and table weights are finite, with magnitude at most `2^20`. All intermediate results remain finite. Output owners are disjoint from each other and from inputs.

## Ordered Calculation

Use FP64, round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Preserve each source rounding point. Do not fuse, contract, reassociate, approximate or reduce precision. Reuse unchanged original-rounding POWER evidence and its unique symbol for exponent `0.65`.

In both regions, divide nitrous oxide by dry air, multiply by `1e20` and divide by its selected reference fraction. Compare with `1.5`. Above it, subtract `0.5`, evaluate power, add `0.5` and multiply successively by reference fraction, dry column and `1e-20`. Otherwise retain nitrous oxide bits.

For each pressure corner, form `Q = water + ratio*carbon_dioxide`, divide water by `Q` and cap it. Scale by eight below the tropopause or four above it. Truncate the nonnegative integer part and subtract it for the interpolation fraction. Lower central mixtures use four table terms and lower endpoints use the complete six-term fourth-power correction. Upper mixtures always use four terms at adjacent five-node mixture positions. Sum each corner left to right, multiply by its separately rounded `Q` and add the two depths.

Lower Planck and minor mixtures use reference ratios at pressure nodes nine and three. Both upper mixtures use node thirteen. Each minor table first interpolates adjacent mixture nodes at two temperatures, then interpolates those two results. Each continuum uses `base + fraction*(next-base)`. Below the tropopause, add self continuum, foreign continuum, adjusted nitrous oxide and aerosol in order. Above it, add foreign continuum, adjusted nitrous oxide and aerosol. Both Planck outputs interpolate adjacent regional mixture nodes. Retain the original rounded product of minor and mixture fractions, although it does not contribute to returned fields.

## Interface And Output

The [assembly](../../../../../src/openifs/physics/rrtm_taumol3.S) exports `md2asm_rrtm_taumol3` and `rrtm_taumol3_`. The application binary interface (ABI) defines argument locations and preserved state. All thirty arguments are addresses in original order. They are TDIMV, first column, last column, active levels, depth, aerosols, four weights, foreign factor, foreign fraction, foreign index, pressure index, two temperature indices, mixture cap, water, carbon dioxide, nitrous oxide, dry air, tropopause, self factor, self fraction, self index, Planck fraction, two water–carbon-dioxide ratios, minor fraction and minor index.

The first eight addresses use `x0` through `x7`, and twenty-two use the incoming stack. Explicit-shape arrays have no entry descriptors. TDIMV supplies levels at byte zero. Eight-byte aligned FP64 arrays store columns, then spectral points, then levels in native-endian order. Integers are four-byte words. Preserve inactive spectral points, supplied-level tails and all inputs. Restore `x19` through `x29`, the return address and low halves of `v8` through `v15`. Leave `x18` unchanged and keep sixteen-byte stack alignment. The fixed frame is 768 bytes without dynamic workspace. No driver supplies a numerical stage.

## Acceptance

Before emission, the original passes 200 protected calls, 5,376,000 returned bytes and 65,280 independent physical relations. Wider arithmetic reconstructs all absorption components, both mixture sizes, the nitrous oxide law and Planck interpolation. Cases cover 14,592 lower and 18,048 upper spectral cells, 23,808 adjusted cells, mixture endpoints, threshold neighbours, table corners, signed zeros, tiny products, empty ranges and unused upper self inputs. All 4,853,760 untouched output bytes remain unchanged.

The new table gate passes 32,864 independent reduction relations and 4,704 exact literal words, reusing 413 reference-atmosphere words. Raw record three contains 225,280 bytes. A 100-digit calculation checks the unchanged one-point weights. Empirical Planck sums are approximately one without normalisation. Require zero differing full output bytes, physical agreement, protected bounds, immutable inputs, immediate ABI checks and a paired adapter. Actual forecast acceptance and timing are later gates. Local tools and records remain under `.runtime/openifs/weather24h-longwave3/`.

The direct body passes the same 200 calls and 5,376,000 complete bytes with zero differences and all 65,280 physical relations. Six focused calls each pass the immediate ABI and paired adapter gates over 67,200 bytes and 704 physical relations, including 128 lower and 224 upper cells. The object contains no fused or approximate floating-point instructions. These results establish readiness for the combined forecast gate. They do not establish forecast acceptance or measured speed.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| rrtm_taumol3 | 6,400 | 4,082,892,800 | Native private band, compared complete gas-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

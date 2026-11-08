# Complete Longwave Band 13 Contract

The [physics input](../../../../../formulations/openifs/physics/longwave_water_nitrous_oxide_minor_gas_absorption.md) describes absorption from 2080 to 2250 inverse centimetres. The original interface is RRTM_TAUMOL13. Keep every calculation in both height regions, including interpolation of the carbon monoxide coefficient followed by multiplication by positive zero. No numerical method or physical table changes.

## Supported Inputs

Use 0 to 4096 columns and 0 to 512 active levels. Supplied levels must cover active levels and cannot exceed 512. Each column's tropopause selects the lower or upper branch. Read only fields used by that branch. The mixture cap is finite and strictly between zero and one. Gas columns, continuum factors and aerosol depth are finite and nonnegative where consumed. Dry-air column is positive in the lower branch. Every consumed water–nitrous-oxide mixture sum must be positive and finite. Continuum fractions are finite with magnitude at most $`2^{20}`$, while minor-gas fractions are from zero to one. RRTM_SETCOEF clamps each continuum table index but leaves its fraction unclamped. This lets the original calculation extend the line between its adjacent table values beyond that temperature interval. Four main interpolation weights are finite with magnitude at most $`2^{20}`$.

Lower pressure index is 1 to 12. Both lower temperature indices are 1 to 4. The lower self index is 1 to 9 and foreign index is 1 to 3. The minor index is 1 to 18 in both regions. Upper pressure, main weights, water, nitrous oxide, carbon dioxide, dry air, continuum and mixture-ratio arrays are unused. Their contents need not be finite. Preserve every input and every output cell outside this band's active cells.

## Tables And Interpolation

The accepted all-band setup supplies four spectral points, with global points 131 to 134. ABSA has 585 rows and nine mixture nodes. Each lower carbon dioxide and carbon monoxide table has 171 rows, ordered as nine mixture nodes within nineteen temperatures. Upper ozone has nineteen rows. Self and foreign tables have ten and four rows. Lower Planck data have four points at nine mixture nodes. Upper Planck data have four fixed entries. Keep the original reduction groups of 3, 3, 4 and 6 points.

Let RN mean one separately rounded FP64 result. At each lower pressure corner, form $`Q=\operatorname{RN}(C_w+\operatorname{RN}(r_m C_n))`$ with that corner's supplied gas ratio $`r_m`$. Divide water by $`Q`$, cap the result, multiply by eight, and split it into an integer node and fractional part. Lower table bases are $`9[5(JP-1)+JT-1]`$ and $`9[5JP+JT1-1]`$, before adding the mixture node. Retain the accepted [ordered mixture interpolation](rrtm_taumol5.md), with six terms below 0.125 or above 0.875 and four terms elsewhere. Compute each table sum from left to right, multiply by its own $`Q`$, then add the two corner contributions.

Interpolate the self and foreign coefficients by $`a+\operatorname{RN}[f(b-a)]`$, multiply each by its supplied factor, and add them after the two main terms. Keep each subtraction, multiplication and addition separately rounded.

Minor carbon dioxide uses the reference ratio CHI_MLS(1,1)/CHI_MLS(4,1). Minor carbon monoxide uses CHI_MLS(1,3)/CHI_MLS(4,3). Planck data use CHI_MLS(1,5)/CHI_MLS(4,5). Compute each ratio once in FP64. Each reference mixture uses the same capped water-over-mixture division and eight-node split. For each minor coefficient, interpolate mixture at the two neighbouring temperatures, then interpolate those two results by the supplied minor fraction.

## Carbon Dioxide And Complete Output

The carbon dioxide adjustment first forms $`\operatorname{RN}\{\operatorname{RN}[10^{20}\operatorname{RN}(C_c/C_d)]/\chi_{64}\}`$. The denominator $`\chi_{64}`$ is the FP64 literal 3.55E-4. If the ratio exceeds three, subtract two, call the accepted source-compatible POWER operation with exponent 0.68, add two, then multiply successively by $`\chi_{32}`$, dry-air column and the FP64 literal 1E-20. Here $`\chi_{32}`$ is the original real32 literal 3.55E-4 promoted exactly to FP64. Its distinct representation is required for byte agreement. Otherwise use the supplied carbon dioxide column. The qualified helper reproduces the original internally rounded steps through integer operations and contains no fused floating-point instructions.

The lower optical-depth sum is main corner zero, main corner one, self absorption, foreign absorption, adjusted carbon dioxide times its minor coefficient, positive zero times its carbon monoxide coefficient, and aerosol depth, in that exact order. Aerosols use band thirteen. Lower Planck output interpolates neighbouring mixture entries. Upper output is ozone column times the temperature-interpolated upper coefficient, then aerosol depth. Upper Planck output is the fixed table entry. All arrays use FP64 with round-to-nearest, ties to even, gradual underflow and preserved signed zeros. FPCR must be zero. Forbid contraction, reassociation, reduced precision and approximate arithmetic.

## Interface And Output

The [assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/rrtm_taumol13.S) exports md2asm_rrtm_taumol13 and rrtm_taumol13_. The application binary interface (ABI) defines argument addresses and preserved machine state. All thirty-one arguments are addresses in original order. They are TDIMV, first column, last column, active levels, optical depth, aerosols, four weights, foreign factor, foreign fraction, foreign index, pressure index, two temperature indices, cap, water, nitrous oxide, carbon dioxide, ozone, dry air, tropopause, self factor, self fraction, self index, Planck fraction, two water–nitrous-oxide ratios, minor fraction and minor index.

The first eight addresses use x0 through x7. Twenty-three use the incoming stack. TDIMV supplies the level count at byte zero. Explicit-shape arrays use raw pointers without descriptors. Eight-byte aligned FP64 arrays store columns, then spectral points, then levels in native-endian order. Integers use four bytes. Output owners include all 140 spectral points and supplied-level tails. Preserve x19 through x29, the return address and low halves of v8 through v15. Leave x18 unchanged and keep sixteen-byte stack alignment. Use a fixed 768-byte frame. No driver supplies a numerical stage.

## Acceptance

Before assembly emission, the original passes 200 protected calls, 5,376,000 complete returned bytes and 16,320 independent physical relations. These cover 3,648 lower and 4,512 upper spectral cells, 2,112 adjusted carbon dioxide cells, all mixture branches, threshold neighbours, table corners, signed zeros, tiny products, empty ranges and unused upper inputs. All 5,245,440 inactive output bytes remain unchanged.

The table gate passes 3,880 independent reduction relations and 6,160 exact literal words, with 413 reference-atmosphere words reused. Raw record thirteen contains 74,880 bytes. A 100-digit calculation checks the original weighted reductions and Planck sums without normalising empirical tables. Require zero different complete output bytes, independent physical agreement, immutable inputs, protected bounds, immediate ABI checks and a paired adapter. Actual forecast acceptance and timing are later gates. Local records remain under .runtime/openifs/weather24h-longwave13/.

The direct body passes the same 200 calls, all 5,376,000 complete output bytes and all 16,320 independent relations with zero differences. Six focused calls each pass immediate ABI and paired adapter checks over 67,200 bytes and 176 physical relations, covering 32 lower and 56 upper cells. The direct object has no fused or approximate floating-point instructions. These results establish readiness for combined forecast checks, without a forecast acceptance or speed claim.

The first genuine forecast call exposed continuum fractions outside zero to one. Its foreign fractions extend to 1.201145, and its self fractions extend to −4.005727. A focused protected source, native and paired replay preserves all 340,480 returned bytes with zero differences and passes 1,216 independent absorption relations. The table indices and every input remain unchanged. Only the local adapter now admits this bounded original extrapolation. The earlier numerical and table proofs are reused.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| rrtm_taumol13 | 6,400 | 4,082,892,800 | Native private band, compared complete gas-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

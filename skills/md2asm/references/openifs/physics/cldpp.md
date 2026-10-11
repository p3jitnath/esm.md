# Cloud Cover Diagnostic Contract

The physical input is [cloud_cover_diagnostics.md](../../../../../formulations/openifs/physics/cloud_cover_diagnostics.md), revision 1. The queued name is `cldpp` from `arpifs/phys_ec/cldpp.F90`. The direct body is [cldpp.S](../../../../../src/openifs/physics/cldpp.S). The immediate `CLDPRG_LAYER` caller supplies `STATE%A`, cloud liquid and ice mass fractions, pressure, temperature and the configured Gaussian latitude.

## Complete Declared Calculation

Support the new radiation scheme and its exponential-random overlap code 1. When cloud diagnostics are requested, reject `LUSEPRE2017RAD=true` or another overlap code before output stores. When diagnostics are off, preserve the five diagnostic owners and perform the complete final fraction and water filter. Support one through 2048 columns, three through 512 layers, cropped columns and an empty interval. The original one-layer and empty cloud-class routes are outside this domain.

1. Compute the sine of each active configured latitude from the complete qualified 32-row grid. Every exact operand and returned word is recorded. All sine results match the accepted cloud-decorrelation input words. Reuse that unchanged direct child to calculate the overlap distance, including its constant, linear and smooth latitude branches.
2. Compute the layer-centre separation in the original order `(RD/RG)*0.5*(T_j+T_next)*log(p_next/p_j)*0.001`, then calculate `exp(-separation/distance)`. Each FP64 operation rounds separately. Use the accepted strict EXP and LOG routes.
3. Find the first middle and low layers using the source's ordered pressure ratios and strict threshold comparisons. Require a grid that resolves all three cloud classes, so every cumulative child call has at least one layer. In particular, the top layer begins above the high boundary, the first middle layer is below the low boundary and a low layer exists. Do not replace an undefined empty-group source result with zero.
4. Bound the cloud fractions for diagnostics between zero and one. Call the complete unchanged cumulative exponential-random child for the whole column and each class, with the original optional beta flag absent. Read its last cumulative element as the returned cover. The source-unused `PCC` diagnostic is never written.
5. For every active layer, form `MIN(MAX(PA,REPCLC),1-REPCLC)` and store it as the radiation cloud fraction. If it is strictly greater than the cutoff, copy both original water words. Otherwise, store positive zero for both. Preserve inactive words and all diagnostic words when diagnostics are off.

The filter retains the supplied water exactly where cloud remains, including its sign and every supplied bit. It discards water from the radiation input where the cloud is too small. Check and report this condition without claiming conservation of the removed condensate. The original physical gate must pass independently before emission.

## Interface and Bounds

The application binary interface (ABI) defines the argument addresses and preserved registers. All 26 GNU Fortran arguments are ordinary addresses, in their original order. The first eight use `x0` through `x7`, and the other 18 start at the caller's stack pointer.

| Object | Size in bytes | Consumed members |
| --- | --- | --- |
| `TRADIATION` | 22472 | Overlap code at 536 |
| `TERAD` | 2040 | Legacy flag at 512 and latitude mode at 160 |
| `TERDI` | 176 | Cutoff at 88 |
| `TECLD` | 264 | High boundary at 152, low boundary at 160 and constant distance at 136 |
| `TRIP` | 175976 | No member in the declared domain |

The next four arguments are four-byte start, end, column and layer counts. Pressure at layer boundaries has `KLEV+1` levels. Full-level pressure, cloud, liquid, ice and temperature have `KLEV` levels. Latitude and longitude have one element per column. The four-byte diagnostic flag follows these arrays. The five diagnostic vectors follow that flag, then the three full-level radiation fields. Arrays are contiguous and column-first.

Require positive finite full-level pressures that increase downward, nonnegative boundary pressures, positive temperature and surface pressure, ordered high and low thresholds between zero and one and a positive overlap distance. The cloud cutoff is finite between zero and one half. Cloud fractions are finite and can include small values outside zero to one that the source clips. Water is finite in cells where the source copies it. These fields are copy-only payloads here, so retain finite signed values exactly. The supplying forecast routine must check whether its condensate is physically admissible. This diagnostic does not calculate, clip or repair condensate. Unused water NaN words and longitude words remain unchanged. Pressure, temperature, latitude and class settings are not consumed when diagnostics are off.

Check every active Gaussian latitude word and every cloud-class extent before any output store. Every mutable owner is distinct from the other owners. FP64 buffers are eight-byte aligned, and integers are four-byte aligned. Preserve `x19` through `x29`, the lower 64 bits of `v8` through `v15`, stack alignment, signed zeros and FPCR zero. Profiling may be enabled.

Keep a sine row, distance row and class-index row, then four one-column arrays for fractions, overlap weights and the two cumulative child outputs. Calculate each column's overlap weights directly into its packed row. This removes the original full layer-by-column overlap matrix while retaining each cell's arithmetic order and rounding points.

## Independent Acceptance

Use 120-digit geometry and probability calculations, including the shared cloudy area, conditional clear probability and the four returned covers. Check class boundaries, clear and opaque limits, masking thresholds, signed zeros, cropped and empty columns, complete read-only inputs, source-unused NaNs and exact original/native output owners. Reuse unchanged child proofs. The original-only gate passed 16 protected calls, 76,104 complete output bytes and 24,927 independent physical relations. The complete native comparison then passed the same 16 placements, 76,104 output bytes with zero differences, 49,854 independent relations, register preservation and FPCR. The new 32-operand sine qualification used 150-digit arithmetic and had a largest error of 0.393 units in the last place, where one unit is the gap between neighbouring FP64 values. Six paired calls passed 16,544 complete owner bytes with zero differences and matching fresh floating-point status flags. A focused signed-zero cloud case preserved every output bit. Five unsupported configuration cases stopped before changing any owner. Reuse the accepted child proofs without another sweep. A focused signed-copy check also passed the observed ice word `bb40000000000000` in one cloudy and one masked cell, over 448 complete output bytes with zero differences on original, unchanged native and corrected paired routes. The cloudy word remains exact and the masked word becomes source positive zero. The paired routes retain every cloud-probability check, and no arithmetic or tolerance changes. Genuine forecast calls and raw saved forecast files remain required before this routine can be counted. No timing is claimed.

The live wrapper records `MD2ASM_CLDPP_REPORT`, with `primary_calls` separated from calls made only by another wrapper's original source shadow. It compares all eight output owners, including the unchanged `PCC`, and preserves all complete consumed input owners. No `TRIP` member is consumed in this domain, so its live consumed extent is zero. The protected critical gate also preserved its complete 175,976-byte opaque owner. The source and native calls start with fresh floating-point status flags, compare those flags, and return the incoming flags combined with the native flags. Profiling can remain enabled.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cldpp | 4,300 | 51,187,200 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

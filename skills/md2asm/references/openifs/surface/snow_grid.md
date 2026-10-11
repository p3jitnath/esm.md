# Vertical Snow Grid

Revision 1.0 freezes the complete OpenIFS 48.1.1 `SRFSN_VGRID_MOD::SRFSN_VGRID` child from `surf/module/srfsn_vgrid_mod.F90`. The [physical input](../../../../../formulations/openifs/surface/snow_layers.md) states volume conservation. [Direct assembly](../../../../../src/openifs/surface/snow_grid.S) produces every layer depth and the active-layer count.

## Ordered Arithmetic

Use FP64, the 64-bit floating-point format, with each operation separately rounded to nearest and ties to even. FPCR is zero. Preserve signed zeros and gradual underflow, and forbid fused operations, reassociation and approximate division. Let `RN` mean one FP64 rounding.

For each processed column, divide each layer mass by its density, then add these rounded depths from first layer to last, starting at positive zero. Separately add masses in the same layer order from positive zero. A mass sum at least 5000 kilograms per square metre selects glacier bounds. Presence of the optional `LEMIN` address changes that threshold to 2000, regardless of its logical value.

For ordinary snow with total depth at most 0.25 metres, use the supplied ordinary bounds. Also use these bounds for deeper snow when terrain-height variation is below 50 metres, or below 80 when `LEMIN` is present. Otherwise let `d=RN(H-0.25)` and `q=RN(0.10*d)`. Every minimum becomes `MIN(0.25,RN(0.10+q))`. Every maximum becomes `MIN(0.30,RN(0.15+q))`, except that the first maximum uses the new minimum and the last maximum is negative one. The last rule also applies when there is only one layer.

Select the first occurrence of the smallest maximum. Its value must be nonpositive and every other maximum must be nonnegative. Replace the selected maximum with exactly ten billion metres for screening. Add minimum depths cumulatively from first to last. A no-snow mask forces one active layer. Otherwise select the largest cumulative minimum not above the rounded total depth, keeping at least one active layer.

Zero every processed output depth. With one active layer, copy the rounded total into the first layer. Otherwise the first screened depth is `MIN(H,max_1)`. Subtract it from `H` and divide by the active count minus one. The original default-real subtraction in this denominator is exact for the declared counts, so integer subtraction followed by FP64 conversion gives the same value. Each other active depth is the minimum of this shared amount and its screened maximum. Add screened depths sequentially, starting at the first depth.

If `RN(H-screened_sum)>10*epsilon`, put remaining depth in the selected accumulation layer, or in the last active layer when the selected layer is inactive. The stored update is `RN(RN(old_depth+H)-screened_sum)`, preserving the source's left-to-right additions. Do not replace it with `old_depth+RN(H-screened_sum)`. Here `epsilon=2^-52`. Layers beyond the active count remain positive zero.

## ABI and Bounds

The application binary interface, ABI, defines argument addresses and preserved registers. `md2asm_snow_grid` receives fifteen addresses in original order. Arguments 1–4 are four-byte `KIDIA`, `KFDIA`, `KLON` and `KLEVSN`. Arguments 5–8 are GNU descriptors for the no-snow mask, terrain-height variation, mass and density. Arguments 9–12 describe ordinary and glacier minimum and maximum depth vectors. Arguments 13–14 describe returned depth and active-layer count. Argument 15 is null or an address of a four-byte optional logical. The public alias is `__srfsn_vgrid_mod_MOD_srfsn_vgrid`.

The column count is between zero and 4096 and the layer count between one and 4096. The processed range is inclusive and lies within the columns, or is empty with `KFDIA=KIDIA-1`. Rank-one GNU descriptors occupy 64 bytes and rank-two descriptors 88. Base, element size and span are at bytes 0, 16 and 32. Each dimension has stride, lower and upper bounds at bytes 40, 48 and 56, then 64, 72 and 80 for dimension two. Zero stride metadata in dimension one selects one, matching the original interface. Other strides are independent signed element counts. All logical element addresses are distinct. Column and layer extents cover the requested shapes, and all offsets fit their integer widths.

Integer and logical elements occupy four bytes and real elements eight. Real and descriptor addresses are aligned to eight bytes and integer and logical addresses to four. Owners are disjoint. Inputs, count words, descriptors and the optional logical remain unchanged. Only processed columns and declared layers change in the output depth owner, and only processed elements change in the active-count owner. Preserve inactive columns, extra layers and physical gaps.

All used input values and intermediate results are finite. Terrain-height variation, mass and minimum bounds are nonnegative, and density is positive. Each selected set of maximum bounds has a nonpositive minimum and no other negative values. The body preserves `x19` through `x29`, the low 64 bits of `v8` through `v15`, the aligned stack pointer and FPCR, and does not use `x18`. A 304-byte fixed frame and sixteen bytes per layer hold the saved registers, argument strides and two bound vectors. No external numerical helper is used.

## Independent Checks and Acceptance

Before native emission, check the original against an independent high-precision total-depth sum and the final sum of returned physical depths. The frozen conservation bound is `4096*epsilon` times the absolute depth sums, plus `32*(10*epsilon)` metres and 1024 smallest positive FP64 subnormals. The absolute term accounts for the original residual threshold. Check nonnegative depths, active-count bounds, cumulative-minimum selection, exactly zero inactive layers, accumulation placement and no-snow behaviour.

A protected corpus covers ordinary, terrain-dependent and glacier bounds, threshold edges, first-minimum ties, empty ranges, optional absence and both logical values, one layer, signed independent strides and counts up to 4096. A register observer checks the native ABI and FPCR. Compare both complete output owners with the original, including physical gaps and inactive tails. Canonical bytes contain processed layer depths in increasing layer and column order, followed by the processed four-byte active counts, all little-endian. Accept zero differing bytes. A paired actual-call relay must pass before forecast acceptance. No whole-forecast completion or speed gain is claimed.

## Checked Checkpoint

The original passed the independent physical check before assembly emission. The complete native corpus passed 672 calls, 22,914,048 returned-owner bytes and 511,056 independent relations with zero differing bytes. It checked ordinary, terrain and glacier bounds, no-snow cases, all optional-input states, first-minimum ties, protected owners, signed strides, registers and FPCR. Inactive words accounted for 18,811,152 preserved bytes.

Four focused cases also passed with exactly 64-byte protected rank-one descriptors, zero-stride metadata and signed-zero screening bounds. They compared 1224 returned-owner bytes and 77 independent relations. The paired adapter passed 80 calls, 46,720 returned-owner bytes and 1232 independent relations with zero differing bytes. The local records retain inputs, source versions, the small fixture correction, commands and library identities. No performance claim is made.

The body reuses each mass load for both ordered reductions and zeros the disjoint depth owner during that pass. It keeps the two reduction orders and every separately rounded operation unchanged. No numerical child is supplied by a driver.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_vgrid_mod::srfsn_vgrid | 2,236 | 2,361,216 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

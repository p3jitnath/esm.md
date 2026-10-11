# Surface Tile Boundary Contract

The input is [surface_tile_fractions.md](../../../../../formulations/openifs/surface/surface_tile_fractions.md), revision 1, equations TF1 and TF2. The unchanged original is `surf/module/surfbc_ctl_mod.F90`. The native entry is `md2asm_surface_tile_boundary`.

## Inputs and Interface

The complete original interface has 45 addresses. Positions below begin at zero.

| Positions | Contents |
| --- | --- |
| 0–4 | First row, last row, full row count, tile count and nominal snow-layer count |
| 5–8 | Low vegetation, photosynthesis, high vegetation and soil category fields |
| 9–16 | Unused terrain spread, climatic covers, urban cover, climatic leaf areas and interactive leaf areas |
| 17–24 | Land mask, sea-ice fraction, lake fraction, lake thickness, signed latitude coordinate, snow mass, canopy water and snow density |
| 25–29 | Land, sea-ice, lake, northern-hemisphere and ocean-mixing logical outputs |
| 30–33 | The four integer category outputs |
| 34–40 | Corrected covers, leaf areas, canopy capacity and tile fractions |
| 41–44 | Soil, vegetation, lake and ocean parameter objects |

The first eight addresses use `x0` through `x7`, and the remaining 37 use caller-stack slots. Scalars and logical values are 32-bit, and real values are FP64. Arrays use the measured GNU assumed-shape descriptors. Array indices start at one in this interface even when the actual descriptor lower bound differs. Signed and gapped strides are supported, and GNU's zero first-stride marker means a unit stride. Component lookup tables retain their own bounds.

The full row count is 1 to 4,096. A selection can be empty, otherwise its rows lie within that count. Tile count is 8 to 16, with at least 9 tiles when lakes are enabled. Snow sums use the complete second extent of the snow descriptor, from 0 to 512, rather than assuming that the unused nominal snow count is its extent. Snow mass and density shapes agree when density is consumed.

Vegetation categories round into the allocated lookup-table bounds. The supported table indices lie from 0 to 20. Category conversion uses nearest-integer rounding with ties away from zero, as in the original `NINT`. Cover parameters, masks, sea-ice and lake fractions lie in `[0,1]`. Out-of-range finite urban cover becomes positive zero. Snow mass ranges from 0 to one million kg per square metre, and consumed density ranges from 1 to 2,000 kg per cubic metre. Stored canopy water can range from minus one million to one million kg per square metre. The original wet-cover rule maps a nonpositive value to zero wet cover without changing the stored word. This local partition check does not certify a negative stored value as a physical water mass. The stored lake-ice thickness diagnostic ranges from −100 to 100 metres. The original threshold maps a nonpositive value to zero frozen cover without changing that input. This calculation does not certify that a stored negative thickness is a physical ice depth. Leaf areas lie from 0 to 100. Each corrected bare-cover residual and canopy capacity is nonnegative and positive respectively. Parameter flags use logical zero or one. Tile-screening threshold is from 0 to 0.05. The snow-cover coefficient ranges from 0 to one million, and the positive canopy-capacity coefficient is at most one million. The lake-ice threshold ranges from 0 to 10 metres. Finite category and urban inputs and the leaf-area selection parameter have absolute values at most one million.

## Complete Ordered Calculation

Convert the four categories first. Lake frozen fraction is `max(0,min(1,10*thickness))` only above the caller's ice-thickness threshold. Leaf areas come from the component lookup tables, climatic fields or interactive fields, with all three original branches retained. Corrected vegetation covers are their climatic values multiplied by their lookup factors.

Land means the land mask exceeds 0.5. The lake flag includes every land point and resolved lakes when lakes are enabled. Sea ice requires neither land nor lake and a sea-ice fraction above the caller's threshold. The northern flag tests the sign of the supplied coordinate, and the ocean-mixing flag requires an enabled ocean parameter and an open-ocean point.

Legacy snow cover is `max(0,min(1,sum(mass)*RQSNCR))`. The newer rule is `max(0,min(1,(100*sum(mass/density))*RQSNCR))`. Each complete snow sum starts at positive zero and visits layers in increasing logical order. Each newer-rule division rounds before its addition. Canopy capacity is `RWLMAX*((((1-low)-high)+(low*low_LAI))+(high*high_LAI))`, preserving each original subtraction, product and addition. Wet fraction is `max(0,min(1,water/capacity))`.

Zero every selected tile first. With lakes enabled, open ocean divides into water and sea ice with the source's upper ice cap. Other rows use the caller's lake fraction, or one for a resolved lake. Urban cover is reduced if lake plus urban area exceeds one. Calculate each low, high, bare, wet, snow and lake fraction in the original factor order. With more than nine tiles, retain the complete replacement urban formulas. With lakes disabled, retain its separate original formulas and sea-ice branch, including their distinct rounding dependencies.

If the screening threshold is positive, set a tile below it to positive zero, sum retained tiles in increasing tile order and divide each retained tile by that sum. Preserve strict less-than screening and the complete source's final negative-area, total-area and bare-cover predicates. Valid input physics does not trigger its abort branch.

## Storage and Arithmetic

The parameter layout is recorded locally in `.runtime/openifs/surface_tile_boundary_7240564/layout.json`. Soil, vegetation, lake and ocean object sizes are 2,416, 776, 856 and 736 bytes. The body reads only the recorded consumed fields and component tables. Unused terrain data and inactive leaf-area or density values do not supply numerical stages.

The native body calculates each independent selected row completely, with ordered snow and tile reductions. Output owners include the full logical arrays, inactive rows, stride gaps and extra tiles. Those bytes remain unchanged outside the declared writes. Canonical values are little-endian FP64, signed 32-bit integer and 32-bit logical zero or one.

The Arm stack stays 16-byte aligned, and the body preserves `x18`, `x19` through `x29` and the required low halves of `v8` through `v15`. Owners align to at least their element width. The floating-point control register is zero and is preserved. Every product, sum, subtraction and division rounds separately with ties to even and gradual underflow. Integer conversion retains `NINT`'s distinct ties-away rule. No fused, approximate or reduced-precision arithmetic is permitted.

## Scientific Acceptance

Before emission, the original passes independent long-double tile-area balances from TF1 and TF2, category and surface classifications, canopy capacity, lake partition, snow partition and screened fractions. The independent limit is `2048*FP64epsilon*(absolute_scale+1)+2048*smallest_subnormal`. This checks the physical partition without copying the source's operation order.

One protected verifier covers both page edges, partial rows, negative and gapped strides, all lake and urban branches, the three leaf-area choices, both snow-cover rules and screening. Complete original and native owners must have zero differing bytes. The immediate 45-address wrapper checks the Arm register and FPCR obligations. The paired actual-call relay admits the declared domain before writes, checks unchanged inputs and complete output owners, then returns the unchanged original bytes.

The captured forecast call 178 supplies the lake-ice diagnostic −2⁻⁵⁷ metres. Its zero frozen-cover branch passes the unchanged independent tile-area checks. Focused protected cases cover this value, the signed lower bound and negative zero with lakes enabled and disabled, urban tiles, screening and signed strides. Each source, native and paired set compares 61,992 complete returned bytes with zero differences and checks 2,250 independent area relations. Earlier numerical body, interface and original-domain proofs remain unchanged.

The captured forecast call 2293 supplies stored canopy water −2⁻⁶⁸ kg per square metre. Its clipped dry-cover branch passes the unchanged independent area checks. The source, direct body and paired relay each pass this complete 3,744-byte case with zero differences and 600 area relations. New protected cases cover that word, the signed lower bound and negative zero across lakes, urban tiles, screening and signed strides. Each set checks 61,992 complete bytes and 2,250 relations. Only this canopy-input admission changes; snow, every other guard, output bytes and numerical assembly remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfbc_ctl_mod::surfbc_ctl | 4,300 | 16,099,200 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

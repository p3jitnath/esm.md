# Conservative Snow Regridding

Revision 1.0 freezes the complete OpenIFS 48.1.1 `SRFSN_REGRID_MOD::SRFSN_REGRID` child from `surf/module/srfsn_regrid_mod.F90`. The [physical input](../../../../../formulations/openifs/surface/snow_remap.md) states depth, mass and heat conservation. The [direct body](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/snow_regrid.S) returns every layer's mass, density, liquid water and temperature.

## Frozen Numerical Method

Use FP64, the 64-bit floating-point format, with separate nearest-even rounding after each operation. FPCR is zero. Preserve signed zeros and gradual underflow. Use no fused operation, expression contraction, reassociation or approximate division. Let `RN` mean one FP64 rounding.

The freezing temperature is the FP64 value of 273.16 kelvin. Latent heat is `RN(2834500-2500800)` joules per kilogram, and ice heat capacity is `RN(2050000/920)` joules per kilogram per kelvin. For each old layer, depth is `RN(m/rho)`. Heat is `RN(RN(RN(cp*m)*RN(T-Tf))-RN(L*RN(m-w)))`. Add old depths and requested new depths cumulatively from positive zero, separately and in increasing layer order. Also sum `RN(m-w)` from positive zero in that order. A no-snow mask or exactly zero ice sum copies all four old fields without remapping.

For a remapped column, the overlap between new layer `i` and old layer `j` is `MAX(0,RN(MIN(new_bottom,old_bottom)-MAX(new_top,old_top)))`. A positive overlap is divided by that old layer's rounded depth. A zero overlap keeps positive zero and does not divide. For each returned layer, add these rounded fractions times old mass from first old layer to last, starting at positive zero. Independently add fractions times old heat in the same order. The original inline `MATMUL` uses these separately rounded products and additions, with no fused instruction or external numerical helper.

With positive requested depth, divide the new mass by that depth to recover density. Recover temperature as `MIN(Tf,RN(Tf+RN(RN(new_heat+RN(L*new_mass))/RN(cp*new_mass))))`. Recover liquid water as `MAX(0,MIN(new_mass,RN(new_mass+RN(new_heat/L))))`. With zero requested depth, retain the old density and temperature and write positive zero liquid water. New mass still comes from the complete remap. The original depth, overlap, mass and heat conditions define the supported domain and are checked independently during acceptance.

## ABI and Storage

The application binary interface, ABI, defines argument addresses and preserved registers. `md2asm_snow_regrid` receives fourteen addresses in original order. The first four are four-byte `KIDIA`, `KFDIA`, `KLON` and `KLEVSN`. The next ten are GNU descriptors for the no-snow mask, old mass, old density, old liquid water, old temperature, requested depth, returned mass, returned density, returned liquid water and returned temperature. The public alias is `__srfsn_regrid_mod_MOD_srfsn_regrid`.

The column count is between zero and 4096 and the layer count between one and 4096. The inclusive column range is within the columns, or is empty with `KFDIA=KIDIA-1`. Every real descriptor has exactly the declared layer extent because the original whole-layer sections use that complete extent. Column extents cover the requested columns. Rank-one descriptors occupy 64 bytes and rank-two descriptors 88. Base, element size and span are at bytes 0, 16 and 32. The first dimension's stride, lower and upper bounds are at bytes 40, 48 and 56, and the second dimension's at bytes 64, 72 and 80. A zero first stride selects one. Other strides are independent signed element counts, with distinct logical element addresses.

Logical and integer data are four bytes and real data eight. Integer and logical addresses are aligned to four bytes, and real and descriptor addresses to eight. All owners are disjoint and address calculations fit their integer widths. Keep all inputs, descriptors and count words unchanged. Change only processed columns in the four returned owners, preserving inactive columns and physical gaps. Canonical bytes contain those four fields in argument order, then increasing layer and column order, all little-endian. Accept zero differing bytes.

All used inputs and intermediates are finite. Every positive requested depth has positive remapped mass. Both depth grids cover the same physical interval within the frozen depth condition, and mass and heat satisfy the conservation conditions below. The body preserves `x19` through `x29`, the low 64 bits of `v8` through `v15`, the aligned stack pointer and FPCR, and leaves `x18` unused. A 384-byte fixed frame and `32*KLEVSN+16` scratch bytes hold argument strides, old depth and heat, and both cumulative depth vectors. No numerical helper or retained overlap matrix is needed.

## Independent Physical Check

Before assembly emission, verify the original against independently evaluated mass and heat totals using higher precision. Use physical ice heat capacity `2050000/920` and latent heat `333700`. The frozen mass bound is `1000000*epsilon` times the sum of absolute old and new masses, plus 64 smallest positive FP64 values. The heat bound uses the same factor times the absolute old and new heats plus latent heat times the absolute mass sum, then the same smallest-value term. These bounds account for the original geometric conservation tolerance and separately rounded phase recovery. Here `epsilon=2^-52`.

Also calculate new-layer mass from high-precision geometric intersections, check density times requested depth against returned mass, and check nonnegative liquid water, its mass limit, mixed-temperature bounds and exact copies for no-snow or all-liquid columns. A zero requested depth must retain old density and temperature and return positive zero water. The density relation has bound `4096*epsilon` times its two absolute mass terms, plus 64 smallest positive FP64 values.

One protected verifier covers empty ranges, one layer, no snow, all liquid, mixed phases, cold snow, merged layers, reversed depth partitions, zero-depth layers, independent signed strides and zero-stride metadata. It compares all four complete returned owners and checks preserved gaps, registers and FPCR. A paired actual-call adapter must then pass before forecast acceptance.

## Checked Checkpoint

The original passed 470 independent physical cases before assembly emission. The complete native corpus passed those 470 calls with zero differing bytes across 4,699,200 returned-owner bytes and 118,784 independent relations. It preserved 3,596,352 inactive bytes. Two further 4096-layer cases with a reversed depth partition passed 786,432 returned-owner bytes and 24,580 relations, also with zero differences. Protected owners and descriptors, signed strides, zero-stride metadata, registers and FPCR passed.

The paired adapter passed 56 calls, 32,256 returned-owner bytes and 644 independent relations with zero differing bytes. Local records retain source versions, commands, identities and a corrected private argument-address fixture. No numerical contract or conservation bound changed after emission, and no speed gain is claimed.

## Reusable Storage Improvement

Compute an overlap fraction once, then use it for both independent ordered products. Stream these fractions in increasing old-layer order so the mass and heat sums keep their original rounding points. This removes the dense overlap matrix while preserving every checked output byte. At 4096 layers, that matrix alone occupies 134,217,728 bytes, whereas the direct body uses 131,088 scratch bytes plus its 384-byte fixed frame. Measure whole-step speed separately before making a timing claim.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_regrid_mod::srfsn_regrid | 2,150 | 8,256,000 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

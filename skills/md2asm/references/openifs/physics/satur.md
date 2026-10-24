# Saturation Humidity Contract

Revision 1 implements `SATUR` from [the saturation formulation](../../../../../formulations/openifs/physics/saturation.md), revision 1. The original source is `ifs-source/arpifs/phys_ec/satur.F90`, SHA-256 `67f2c224d0a143735fccea3a01cdf52cac886202108a86506be25421d580f7ed`. The [direct assembly](../../../../../src/openifs/physics/satur.S) emits the complete phase weighting, vapour-pressure law and humidity conversion. It calls the unchanged accepted scalar `EXP` function for the two exponential values.

## Domain And Ordered Mathematics

Let $`K`$ count horizontal columns and $`N`$ count levels. Support $`0\leq K\leq4096`$ and $`0\leq N\leq1024`$, valid one-based selected column and level ranges, and empty ranges. Process columns `KIDIA` through `KFDIA` at each level `KTDIA` through `KLEV`. Temperature lies in $`[160,330]`$ K, and pressure is positive finite FP64. Real values use FP64, the 64-bit floating-point format. This scope includes phase transitions, a capped pressure ratio and nonzero subnormal results, which are values smaller than the smallest normal FP64 value.

Freeze the source-defined global constants as binary FP64 inputs. `R2ES` is the rounded product $`e_0R_d/R_v`$, and `RETV` is the rounded value $`R_v/R_d-1`$. Ordinary phase weighting uses `RTICE` and `RTWAT_RTICE_R`. Nonlinear mode with `KFLAG=1` instead uses the convective threshold `RTICECU` and its inverse interval `RTWAT_RTICECU_R`. Linear mode always uses the ordinary threshold. Both modes use `RTWAT` as the water threshold.

First clip temperature between the selected ice and water thresholds. Subtract the ice threshold, multiply by the stored inverse interval, square the rounded product, then take its minimum with one. This gives the liquid fraction $`\alpha`$. For each phase, separately round `T-RTT`, multiply by `R3LES` or `R3IES`, separately round `T-R4LES` or `T-R4IES`, divide the two results, then call `EXP`.

Linear mode first multiplies each exponential by `R2ES`. Multiply the water result by $`\alpha`$, separately subtract $`1-\alpha`$, multiply that result by the ice value, then add the two products. Nonlinear mode performs the same two weighted products and sum on the unscaled exponentials, then multiplies the completed sum by `R2ES`. Preserve this difference in intermediate rounding.

Divide the resulting scaled pressure by the supplied air pressure and cap this ratio $`r`$ at 0.5. Separately multiply `RETV*r`, subtract that product from one, divide one by the difference, and multiply $`r`$ by the resulting correction. This is the frozen implementation of Equation S3. Its cap keeps the denominator positive for the supported constants. Every subtraction, product, sum and division rounds separately. Require FPCR zero for nearest rounding with ties to even, gradual underflow and preserved signed zeros. There is no fused arithmetic, reassociation, approximate division or reduced precision.

The scalar exponential is the already qualified `libpressure-math.so` route from Arm optimized-routines v26.01. Its GNU 12.3 build disables fast FMA, contraction and fast-math. The reused 10,428-case qualification found a largest error of 0.50214 units in the last place. The focused saturation check requires a one-unit bound for its arguments. This evidence is limited to the checked arguments and does not prove a global exponential error bound or qualify the complete external mathematics library.

## Original GNU ABI And Storage

The application binary interface, or ABI, fixes ten ordinary argument pointers. Registers `x0` through `x7` address `KIDIA`, `KFDIA`, `KLON`, `KTDIA`, `KLEV`, `LDPHYLIN`, `PAPRSF` and `PT`. Caller stack offsets zero and eight hold the `PQSAT` and `KFLAG` pointers. Integers and logical values use four bytes, and each matrix owner holds $`8KN`$ bytes in Fortran order. The byte address of one-based column $`g`$ and level $`j`$ is `base+8*((g-1)+K*(j-1))`.

Integer pointers align to four bytes and matrix pointers align to eight bytes. Input owners can share storage. The output owner is disjoint from every input and scalar owner. All complete matrices have valid bounds. An empty matrix can have a zero address because no element is accessed. Selected cells receive their humidity values, while every other output byte keeps its incoming value.

The default entry symbol is `satur_` with no scalar result. `ORIGINAL_SYMBOL` can change only the symbol. The assembly preserves `x19` through `x30` and the low 64 bits of `v8` through `v15`, leaves `x18` untouched, restores its aligned 256-byte frame and uses no array scratch. Frozen constants are loaded once per nonempty call. The accepted `EXP` dependency obeys the same Arm ABI.

## Physical Checks And Canonical Bytes

The genuine strict OpenIFS shared-library routine passed 20 critical cases with 42,160 complete output bytes and 20,864 independent physical relations. An independent 220-digit exponential interval encloses each mathematical vapour-pressure value. Exact rational arithmetic carries the actual rounding errors through the stated operations. The check verifies phase bounds, pressure between the pure-phase limits, agreement with the physical humidity interval and the ideal-gas residual. It also checks nonnegative finite humidity within the cap-derived limit.

The corpus covers both arithmetic modes and phase flags, temperatures at and beside each threshold, selected interior columns and levels, odd column counts, capped ratios, empty dimensions and ranges, the column and level limits, and nonzero subnormal results. Canonical bytes are the complete output matrix in Fortran order and little-endian FP64, including untouched cells. Acceptance requires zero differing bytes with no masking or normalisation.

The native body passed 40 guarded calls, 84,320 complete returned bytes and 41,728 independent physical relations with zero differences. Four returned values are nonzero subnormals. The checks confirm unchanged inputs and globals, both protected buffer placements, preserved registers, stack restoration and FPCR zero. The composable paired relay passed 20 calls and 42,160 complete returned bytes. It runs the original on a complete output clone, writes and returns the native output, and compares every byte. No comparative timing or speed claim is available for this routine.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 17,150 genuine calls. The same-input comparison covers 46,998,400 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.

## Runtime owned binding

The operational CALLPAR site uses KFLAG two at 17 columns and 137 levels. The unchanged accepted body reads its ten consumed constants from assembly-owned physical and thermal records. Both linear-mode branches therefore use the ordinary mixed-phase constants. The two convective constants remain unread at this site and need their later setup updates before a different flag can be admitted. The two linked exponential calls reach the exact accepted mathematical implementation and its constant tables. Whole object identities, actual addresses and reused independent numerical evidence pass without replaying an accepted bank. Complete CALLPAR forwarding and the operational forecast remain separate.

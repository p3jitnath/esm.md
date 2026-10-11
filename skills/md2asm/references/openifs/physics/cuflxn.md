# CUFLXN Numerical Contract

CUFLXN completes convective transport and falling precipitation. Its physical input is [Convective Final Fluxes](../../../../../formulations/openifs/physics/convective_final_fluxes.md). The direct body is [cuflxn.S](../../../../../src/openifs/physics/cuflxn.S). The source calculation and normal-physics model remain unchanged.

## Domain and Arithmetic

Use FP64, round to nearest with ties to even, gradual underflow and separate multiplication, addition and division. Do not fuse or rearrange expressions. The supported configuration has `LPHYLIN=false`. All three switches `LMFDSNOW`, `LMFWETB` and `LMFGLAC` retain both branches. The linearised branch requires a different phase rule and is excluded before output writes.

Retain the source order of environmental transport subtraction, subcloud taper, downdraft limiting, rain and snow transport with melting and detrainment, cloud-area calculation, and precipitation evaporation. Level loops run from 2 to `KLEV`, with increasing selected columns within each level. Preserve each negative rain or snow repair and the source's 10⁻¹² kg m⁻² s⁻¹ evaporation cutoff. The cutoff can discard at most that incoming flux in a layer.

Use the accepted scalar exponential route for saturation and the accepted convective phase rule. The evaporation power has exponent 0.5777 and uses the distinct approved original-compatible power function. Its internal rounding is part of the frozen scalar primitive. The solver's own arithmetic remains unfused. Retain the source's default-real `0.6` cloud-cover multiplier as the FP64 value 0.6000000238418579.

## Storage and Interface

The Arm application binary interface has 43 ordinary pointer arguments in the original order. The first eight pointers use `x0` through `x7` and the remaining 35 use the incoming stack. Integers and logical values are 32-bit. Matrices are contiguous, with the column index varying first. Buffers need 8-byte alignment for FP64 and 4-byte alignment for integer values.

`PTEN`, `PQEN`, `PQSEN`, `PTENH`, `PQENH`, `PAP`, the convective mass and transported heat or water fields, `PLUDE`, `PLRAIN`, precipitation sources, melting, frozen cloud water and detrainment rates contain `KLON*KLEV` values. `PAPH`, `PGEOH`, `PMFLXR` and `PMFLXS` contain `KLON*(KLEV+1)` values with original one-based level indexing. `PLUDELI` and `PSNDE` each have two complete `KLON*KLEV` components. Cloud flags and levels contain `KLON` 32-bit values. `PRAIN` contains `KLON` FP64 values, and `KTOPM2` is one 32-bit scalar.

Retain the two configuration owners, 120 bytes for `TEPHLI` and 344 bytes for `TECUMF`, as read-only numerical inputs. The consumed `TECUMF` offsets are `RMFCFL` 56, `RCPECONS` 184, `RCVRFACTOR` 192, `RCUCOV` 200, `RTAUMEL` 208, `RHEBC` 216, `LMFDSNOW` 268, `LMFWETB` 272 and `LMFGLAC` 276. `LPHYLIN` is at offset 4 in `TEPHLI`.

The live gate supports 1 through 2048 columns and 1 through 512 levels, with positive dimensions and valid selected columns. Each active cloud base lies from 1 through `KLEV-1`, and its cloud top lies from 1 through `KLEV`. The downdraft top also uses this range, or the caller's zero encoding for an absent downdraft. The source disables that downdraft before flux calculations and never indexes a field using its zero top. Require positive, increasing consumed pressures and finite physical temperatures and fluxes. Read-only and mutable owners must not overlap. Preserve unconsumed boundary words and inactive-column payloads exactly.

The stack frame is 1024 bytes and stays 16-byte aligned. Save and restore `x19` through `x29` and the required low halves of `v8` through `v15`. A private allocation contains three FP64 column vectors and one 32-bit column vector, or 28 bytes per column. Release it before return.

The exact pointer order is the original GNU interface.

```text
YDEPHLI, YDECUMF, KIDIA, KFDIA, KLON, KLEV, PTSPHY,
PTEN, PQEN, PQSEN, PTENH, PQENH, PAPH, PAP, PGEOH, LDLAND, LDCUM,
KCBOT, KCTOP, KDTOP, KTOPM2, KTYPE, LDDRAF,
PMFU, PMFD, PMFUS, PMFDS, PMFUQ, PMFDQ, PMFUL, PLUDE, PLUDELI,
PLRAIN, PSNDE, PDMFUP, PDMFDP, PDPMEL, PLGLAC,
PMFLXR, PMFLXS, PRAIN, PMFUDE_RATE, PMFDDE_RATE
```

## Returned Bytes and Physical Checks

Compare complete owners for `PQSEN`, `KTOPM2`, `KTYPE`, `LDDRAF`, all transported mass, heat and water fields, `PLUDE`, `PLUDELI`, `PSNDE`, precipitation sources, melting, frozen cloud water, rain and snow fluxes, `PRAIN` and downdraft detrainment rate. Preserve original unassigned words. Before its precipitation pass, the source clears all columns in the top and bottom rain and snow rows and the first snow-detrainment row, even outside the selected interval. Later calculations write the final bottom rain and snow fluxes.

Check the sinking mass bound, the mathematical subcloud taper, removal of environmental heat and water transport, nonnegative rain and snow, phase-water balance, available snow for melting, and the pressure-weighted moisture capacity for evaporation. The independent melting check uses a passive snapshot between the melting and evaporation passes. A verification driver records existing arrays and supplies no numerical stage.

The immediate caller recomputes precipitation flux differences after CUFLXN before updating moisture. Keep the original branch-defined precipitation diagnostic bytes. Do not interpret `PRAIN`, which excludes later evaporation, as the final surface precipitation flux.

The original routine passed 17 protected cases and 13,179 independent relations, with 254,116 complete returned bytes unchanged by the passive snapshot. These cases cover all three configuration switches, cropped columns, inactive convection, empty intervals, arbitrary unused top payloads and up to 512 levels. The direct body passed these 17 cases and four focused precipitation cases, with 260,020 complete returned bytes and 117,056 intermediate snapshot bytes identical to the original. The checks covered 27,136 independent relations and the immediate Arm register and floating-point control obligations. The four added cases independently triggered the negative-total, negative-rain and negative-snow repairs and the small-flux cutoff.

Three focused calls also passed with the production body, which omits verification snapshots. Fourteen and ten newly consumed power operands passed independent 120-digit accuracy checks and matched the original result bits. Their largest measured error was 0.489667 units in the last place, where one unit is the spacing between adjacent FP64 values.

The paired relay passed seven genuine calls, 18,364 complete returned bytes and 621 live physical relations, with zero differing bytes. Two unsupported configurations were rejected before any of 2,952 shared output bytes changed. The live guard leaves source profiling active. Forecast saved-file acceptance is still pending, so this routine is ready rather than counted as accepted.

One focused original/native call also verified the immediate caller's zero downdraft-top encoding. It compared 4,420 complete returned bytes and 1,992 intermediate bytes, passed 388 physical relations and the immediate ABI check, and left the numerical stages unchanged. Its paired call passed the same 4,420 bytes and 148 live relations. The complete ready record now covers 22 protected calls, 264,440 returned bytes, 119,048 intermediate bytes and 27,524 physical relations. Eight genuine paired calls compared 22,784 bytes with zero differences.

The unused downdraft-top marker can also equal N+1 when the downdraft flag is false. The source compares this marker as an integer and never uses it to index a field. The focused original/native and hook-enabled paired calls each return 4,420 identical bytes. An enabled downdraft at N+1 and any marker above N+1 are rejected before changing 8,840 shared output bytes. Every numerical stage and the earlier interface proofs remain unchanged.

The phase-water check uses the separate magnitudes of incoming rain, incoming snow, updraft and downdraft precipitation sources, twice the melting flux, and both detrainment terms. Let their sum be A, in kg m⁻² s⁻¹. With u=2⁻⁵³ and γ₁₂=12u/(1−12u), its error limit is γ₁₂A plus 32 times the smallest positive FP64 subnormal. This bound covers the ordered phase split, phase additions and a repair transfer. A cancelled net source does not give a valid rounding scale. Genuine discarded detrainment and nonfinite water terms still reject.

Actual call 295 in diagnostic r40 has zero returned phase change and a water-source residual of −2⁻⁷⁰ kg m⁻² s⁻¹. Its rain and snow detrainment are the two separately rounded phase products; their sum differs from the source by one quarter of its FP64 spacing. A 120-digit check explains both product errors, and all 159 captured phase relations satisfy the derived limit. Two protected complete source/native placements compare 147,464 returned bytes and every original/native phase word with zero differences, exact fresh numeric status and immediate ABI. The corrected relay passes two focused pairs from /tmp, 75,208 returned bytes and seven critical bound cases. It restores the already matched source/native status after its independent checks, preserving all caller sticky bits. Numerical assembly, source stages, other physical checks, input admission and earlier proofs are unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cuflxn | 2,150 | 223,944,000 | Native private convection child, compared complete convection-parent owners and child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

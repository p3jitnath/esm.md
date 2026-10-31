# Aerosol Vertical-Profile Setup

The physical input is [aerosol_vertical_profiles.md](../../../../../formulations/openifs/physics/aerosol_vertical_profiles.md), revision 1. The complete direct body is [su_aerv.S](../../../../../src/openifs/physics/su_aerv.S). The queued original name is `su_aerv`, from `arpifs/phys_ec/su_aerv.F90`. It updates five cumulative optical-depth profiles.

The numerical method is a direct evaluation at the supplied pressure levels. For each type, divide 8434 by its height scale, separately round that division to FP64, then take the maximum with one. Write positive zero to all five first profile elements. If the first pressure coordinate compares unequal to zero, overwrite those words with the five power evaluations. For levels 2 through `KLEV+1`, evaluate all five powers in sea-salt, dust, organic-matter, black-carbon and sulphate order. Later signed-zero inputs therefore pass through the genuine power operation. Do not replace them with an unconditional zero store.

Use only the approved private primitive `md2asm_pow_original_rounding_candidate(double,double)`. Its unchanged independent accuracy and original bit, status and error-number proofs are reused. It reproduces the original primitive's internal rounding with integer operations and has no fused FP instructions. All profile division and storage remain direct assembly stages. A verification wrapper may compare new power operands, but it returns the approved primitive result and supplies no omitted profile calculation.

The independent check evaluates the power with a 120-digit logarithm and exponential, then checks cumulative bounds, increasing profiles, nonnegative layer fractions and their telescoping total. A telescoping total means that adjacent differences cancel, so the sum of all layer fractions equals the bottom cumulative fraction minus the top fraction. Require zero differing source/native bytes independently of these physical checks.

## Interface and Bounds

The application binary interface, or ABI, is AAPCS64. `x0` is the address of `YDERAD`, `x1` is the address of the four-byte `KLEV` scalar, and `x2` is the first address of `PETAH`. The radiation object is 2040 bytes, using the already accepted GNU `TERAD` layout. The new consumed members are listed below.

| Type | Height member and byte offset | Profile descriptor and byte offset |
| --- | --- | --- |
| Sea salt | `RAESHSS` at 656 | `CVDAESS` at 1480 |
| Dust | `RAESHDU` at 664 | `CVDAEDU` at 1544 |
| Organic matter | `RAESHOM` at 672 | `CVDAEOM` at 1608 |
| Black carbon | `RAESHBC` at 680 | `CVDAEBC` at 1672 |
| Sulphate | `RAESHSU` at 688 | `CVDAESU` at 1736 |

Each profile is a GNU allocated rank-one FP64 array. Its 64-byte descriptor holds the data address at byte 0, element offset at byte 8, element length at byte 16, stride at byte 40, lower bound at byte 48 and upper bound at byte 56. Logical profile index $`j`$ is at `data+8*(offset+j*stride)`. Admit unit stride with `offset=-lower`, `lower<=1` and `upper>=KLEV+1`. Preserve complete owners, including any extra lower or upper elements.

Admit `0<=KLEV<=512` and `KLEV+1` finite pressure coordinates in increasing order, each between zero and one. Signed zeros are admitted and preserved by the source rules. Height scales are finite and between 1 and 1000000 metres. These limits give a finite exponent between one and 8434. Check every consumed value and descriptor before changing any profile element.

The input vector and profile buffers are eight-byte aligned. The object is eight-byte aligned, and the level scalar is four-byte aligned. Profile owners are separate from the object, level scalar, input vector and each other. The radiation object's bytes, including its five descriptors and height values, remain read-only. Only profile indices 1 through `KLEV+1` change.

Preserve `x19`–`x29`, the lower 64 bits of `v8`–`v15` and 16-byte stack alignment across all private power calls. Check the floating-point control register before execution. Use round-to-nearest, ties to even, gradual underflow and the exact source order. No fused solver arithmetic, approximate division, reassociation or field normalization is admitted. Profiling may be enabled in the caller.

## Acceptance

Compare the five complete profile owners as raw little-endian bytes, with zero differing bytes. Check complete read-only inputs, shifted profile lower bounds, first and later signed-zero coordinates, the surface boundary, height-exponent clamping, underflow, protected buffers and immediate ABI and floating-point state. Qualify only new consumed power operands, reusing the unchanged primitive proof.

The direct body computes the five height exponents and descriptor addresses once per call, then keeps each pressure coordinate in a preserved FP64 register across its five private power calls. It uses no temporary profile arrays and retains the original level and species order. These choices preserve all accepted bytes. No comparative timing is claimed.

The genuine original physical check passed 28 protected calls, 15344 independent relations and 33720 complete profile bytes. The complete native comparison passed the same 28 calls with zero differing bytes, 30688 source and native physical relations, read-only complete input owners, immediate ABI and FPCR checks. The new power corpus contains 2312 distinct input pairs, checked through the complete original profiles at 120 decimal digits and identical native output bytes. Its largest observed power error is 0.503686 ulp, where an ulp is the spacing between adjacent FP64 values. The unchanged primitive proof is reused.

Four genuine paired calls passed 2280 complete profile bytes with zero differences, 735 live physical relations, source/native floating-point status and immediate ABI checks. They include the small underflow case. Three prewrite rejections preserve 720 shared mutable bytes for an invalid last pressure coordinate, height and descriptor extent. The paired relay admits profiling, compares all five complete buffers and the complete read-only radiation object, and distinguishes primary calls from source-verification shadows. Actual forecast calls and saved forecast files remain required before this queued routine is accepted.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| su_aerv | 26 | 21,397,376 | Native private aerosol-profile child, complete monthly-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

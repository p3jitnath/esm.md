# Supported Cloud Optical Mixture Contract

Revision 1.0. The input is [cloud_optical_mixture.md](../../../../../formulations/openifs/physics/cloud_optical_mixture.md). The original routine is `radiation_cloud_optics::cloud_optics` in `radiation/module/radiation_cloud_optics.F90`. The coarse forecast selects liquid model 2, SOCRATES, and ice model 2, Fu. This contract supports those two models. Other model codes require separate direct children and are rejected by the paired relay.

## Interface and Bounds

There are twelve argument addresses. Registers `x0`, `x1` and `x2` point to INTEGER4 level count, first column and last column. Registers `x3`, `x4` and `x5` point directly to the configuration, thermodynamics and cloud objects. Registers `x6` and `x7` point to longwave total depth and single-scattering albedo. Stack arguments at 0, 8, 16 and 24 point to longwave asymmetry, shortwave total depth, shortwave single-scattering albedo and shortwave asymmetry.

The objects contain 20,040, 264 and 792 bytes respectively. Their GNU rank-two FP64 descriptors occupy 88 bytes. The first word is the data pointer, followed by the element offset. Strides at 40 and 64 count elements. Bounds are at 48, 56, 72 and 80. Element `A(i,j)` is at `base+8*(offset+i*stride1+j*stride2)`. Cloud liquid amount, ice amount, liquid radius, ice radius and cloud fraction begin at bytes 0, 88, 176, 264 and 352. Thermodynamics pressure begins at byte 0. These arrays are contiguous, one-based, and include every requested column and layer edge.

| Configuration field | Byte |
| --- | ---: |
| Longwave cloud scattering | 608 |
| Apply shortwave delta scaling with gases | 628 |
| Liquid and ice model codes | 696, 700 |
| Fu longwave compatibility switch | 7964 |
| Message verbosity | 7972 |
| Embedded cloud optical coefficient object | 11128 |
| Shortwave and longwave band counts | 20004, 20008 |
| Longwave scattering band count | 20024 |
| Homogeneous cloud flag | 20028 |

The coefficient object has four consecutive rank-two descriptors for liquid longwave, liquid shortwave, ice longwave and ice shortwave tables. Their offsets are 0, 88, 176 and 264 within that object. Reuse the complete accepted [SOCRATES](calc_liq_optics_socrates.md), [Fu longwave](calc_ice_optics_fu_lw.md), [Fu shortwave](calc_ice_optics_fu_sw.md), and [cloud delta scaling](delta_eddington_scat_od.md) contracts and direct bodies. Bind the private symbol `md2asm_cloud_delta` to `delta_eddington_scat_od.S` with `ORIGINAL_SYMBOL=md2asm_cloud_delta`. Its three addresses contain total optical depth, scattering optical depth and ordinary dimensionless asymmetry `g`.

Output arrays have band as the fastest index, followed by level and requested column. There are `max(0,last-first+1)` output columns. The longwave depth uses the longwave band count. Longwave albedo and asymmetry use the scattering band count, which equals the longwave count when scattering is enabled and is zero otherwise. All three shortwave outputs use the shortwave band count. Arrays, objects, scalars and coefficient tables do not overlap. FP64 data are eight-byte aligned and INTEGER4 data are four-byte aligned.

Counts are nonnegative, active band counts are positive, and all array sizes fit signed 64-bit arithmetic. The complete private stack footprint is at most 1,048,576 bytes. Positive cloud fractions are at most one and have positive combined liquid or ice water. Mixing ratios are finite and nonnegative, with signed zero permitted. Pressure increases downwards. Particle radii and optical coefficients obey their reused child contracts. Active combined total and scattering depths have the positive denominators used below. Empty levels or columns produce zero output bytes. Verbosity is below two in the supported run.

## Complete Ordered Calculation

Set longwave depth and all shortwave outputs to positive zero. Set longwave albedo and asymmetry to positive zero only when longwave cloud scattering is enabled. Visit levels and then selected columns in increasing order. Skip a cell whose cloud fraction is not positive.

Subtract adjacent edge pressures first. For a homogeneous cloud, divide the difference by 9.80665. Otherwise multiply 9.80665 by cloud fraction, then divide the difference by that rounded product. Multiply this factor separately by liquid and ice mixing ratios to form their in-cloud water paths. Do not replace either division by multiplication with a reciprocal.

For positive liquid water, run the complete accepted SOCRATES child on longwave and shortwave tables. When shortwave delta scaling is not deferred to the gas stage, apply the accepted scalar delta child to every liquid shortwave band. For absent liquid, set all six liquid arrays to positive zero.

For positive ice water, run the complete accepted Fu longwave child. If the compatibility flag is true, replace its scattering depth by total depth minus scattering depth. Run the complete Fu shortwave child. Apply the accepted delta child to ice shortwave bands when scaling is not deferred, and always apply it to ice longwave bands. For absent ice, set all six ice arrays to positive zero.

For longwave scattering, add liquid and ice total depths and separately add their scattering depths. Compute each asymmetry numerator as two separately rounded products followed by one sum. Divide by the scattering sum when that sum is positive, and otherwise store positive zero. Divide the scattering sum by the total-depth sum to obtain the albedo. When longwave scattering is disabled, compute absorption depth in the source order `((liquid_total-liquid_scattering)+ice_total)-ice_scattering`.

For shortwave, add both total depths and both scattering depths. Compute the same ordered asymmetry numerator, then divide it by the scattering sum. Divide the scattering sum by the total-depth sum for the albedo. Store complete output arrays in their declared order.

Every FP64 operation rounds separately to nearest with ties to even. Keep gradual underflow, signed zeros and FPCR zero. Do not fuse, reassociate, reduce precision or approximate division. The direct caller owns every stage and binds all four complete direct child bodies inside its native closure.

## Acceptance

Compare every declared output byte and preserve all input, descriptor, object and coefficient bytes. Require zero differences. Independently derive simple manufactured optical states and their physical mixtures with 100-digit arithmetic, including pressure-to-water conversion and forward scattering. The comparison bound is `512*2^-52*max(1,abs(expected_value))`. Check nonnegative depth, albedo and asymmetry between zero and one. Reuse the accepted child corpora and their real coefficient evidence.

The small critical verifier covers clear, liquid-only, ice-only and mixed cells, homogeneous and fractional clouds, both shortwave scaling choices, both longwave scattering choices, the Fu compatibility switch, empty and cropped ranges, subnormal water paths, protected buffers and saved registers. Live forecast acceptance is recorded separately.

The direct source is [cloud_optics.S](../../../../../src/openifs/physics/cloud_optics.S). Its fixed frame is 496 bytes, with twelve band arrays in aligned private storage. It preserves `x19` through `x29` and the link register, uses only caller-saved FP registers, and leaves FPCR unchanged.

The native critical check passed 1,056 protected placements and 82,432 independent optical relations. It compared 1,931,264 source and native output bytes with zero differences. Input bytes, buffer bounds, saved registers and FPCR passed. The live relay reuses this independent mixture proof and checks complete output bytes, clear-cell zeros and physical optical limits during the forecast. Its selected model codes are checked before every call.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 700,416,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.

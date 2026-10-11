# Snow Warm-Start Mass Contract

Revision 2 implements complete `SURFWS_MASSADJ_MOD::SURFWS_MASSADJ` from [Snow Mass At Warm Start](../../../../../formulations/openifs/surface/snow_mass_adjustment.md), SM-1, in [snow_mass_adjustment.S](../../../../../src/openifs/surface/snow_mass_adjustment.S). It preserves all original active numerical stages.

## Ordered Method

For a selected column, let $`a`$ be its active layer count, $`d_k`$ the supplied full layer depth, $`D`$ the supplied profile depth and $`M`$ the target snow mass. Compute the relative mass error by summing `rho[k]*d[k]` in increasing layer order, subtracting `M` and dividing by `M`. The frozen small value is `100000*2^-52`.

Try 100 bottom-density changes, with `delta=50-count*50/50.5`. Construct the exponential profile from the current top density and the proposed bottom value. Its denominator is the signed larger of the small value and `abs(MAX(epsilon,EXP(-D*c))-1)`. The first-layer anchor retains the original unbounded exponential, while the trial profile uses the exponential floor. Clamp each active trial density to the supplied density bounds. Keep a trial only when its absolute relative error is strictly smaller.

Normal snow also tries 40 top-density changes, with `delta=20-count*20/20.5`. This stage floors the first anchor exponential and retains the unfloored exponentials in the active profile. An accepted trial copies the full density profile, including the original inactive-layer value of 100. Then perform up to 999 written filling updates, using the source-selected upper or lower layer groups and density increments 0.1, 0.005 or 0.01. Glacier filling changes the first `a-2` layers by 0.01. Each step keeps the original comparison and summation order.

Form every active layer mass as `rho[k]*d[k]`. If the sum differs from the target, apply the source depth-weighted correction to the first `a-2` layers, recomputing their densities. Rebuild a corrected layer mass from density times depth only when its density is clamped, preserving the original correction otherwise. Assign the remaining mass residual to layer `a-1` without changing its density. Consequently its implied depth can change. Other layers retain their provisional depths within the frozen rounding limit.

For normal snow, form liquid capacity as `mass*(B+((C-B)*MAX(0,A-rho))/A)`. Below `RTT-0.5*AMP`, and at or above `RTT`, the original warm-start phase value is zero. Inside the transition, it is `1+SIN((RPI*(T-RTT))/AMP)`. Multiply capacity by that phase value. This is the original initialization rule, including its value at the upper endpoint. Glacier liquid water is zero in every layer.

All FP64 operations round separately with FPCR zero, round-to-nearest with ties to even and gradual underflow. Reuse the accepted strict EXP and uniquely named original-compatible SIN. No fused or approximate solver instruction is admitted.

## Domain And ABI

The 24 addresses contain first column, last column, column count, layer count, active-layer descriptor, depth threshold, provisional depth, full depth, provisional midpoint, full midpoint, supplied single-layer density, target mass, maximum density, profile depth, coefficient table, coefficient index, glacier threshold, temperature, density, mass, liquid water, top density, TCST and TSOIL. The first eight use `x0..x7`. The remaining addresses use the caller stack. The last four numerical arrays are the returned owners.

Support 1–4,096 columns, 1–512 allocated layers, signed GNU rank-one and rank-two strides, partial and empty column ranges. A descriptor states the data address, dimensions and entry distances. Consumed arrays cover every declared column and layer. A triggered one-active-layer column must initially satisfy `density*full_depth==target_mass` exactly. This prevents the original residual from indexing layer zero. Below-threshold columns remain untouched.

The melting temperature and pi retain their original FP64 values. Positive temperature amplitude, liquid-capacity constants and density limits keep the complete diagnosis physical. Triggered columns have positive finite target mass, full layer depths and densities. Selected finite signed coefficients and nonnegative profile midpoints keep all rounded EXP arguments in `[-700,700]`. A negative coefficient is a growing exponential curve, which the original shallow-snow initialization tables use. Guard the magnitude of each consumed depth-times-coefficient product before writes. The branch bounds each rounded SIN argument in magnitude by two radians, within the accepted helper domain. Returned active mass and liquid are nonnegative, liquid does not exceed mass, and density is positive.

Four-byte integer arrays use GNU integer type 1. Real arrays use eight-byte FP64 and GNU type 3. Rank-one and rank-two descriptors occupy 64 and 88 bytes. TCST and TSOIL occupy 128 and 2,416 bytes. Real owners and descriptors are aligned to eight bytes. Separate the four complete returned owners from all input data, configurations and descriptor storage.

Canonical bytes include each complete returned density, mass, liquid and top-density owner in increasing address order, including inactive columns, inactive layers and stride padding. Preserve every unmodified payload bit. Preserve `x19..x29`, low 64 bits of `d8..d15`, the aligned stack and FPCR. Original profiling is allowed. The direct body supplies all numerical stages.

## Evidence

Before emission, 26 protected original placements pass over 234,720 complete returned bytes with 6,142 independent 110-digit relations. The small checks cover snow and glacier mass, liquid capacity, the exponential floor, signed strides, empty and skipped ranges, a safe single active layer and all 512 active layers. The fixed mass and liquid limits are retained in the local frozen contract. Accepted scalar maths and unchanged type layouts are reused. The complete native body passes the same 26 protected placements with zero differing bytes and 12,284 source and native physical relations. Cached full-owner checks preserve 186,848 inactive or padding bytes without repeating any numerical body. Immediate 24-address register checks and the paired adapter each pass two calls over 57,344 bytes with zero differences. Two smaller paired cases additionally pass an empty range and a safe single active layer over 3,120 bytes. Thirteen required prewrite cases preserve 15,392 shared bytes, including the unsafe single-layer residual and a negative derived layer mass. The machine route has no fused or approximate instruction and no OpenIFS Fortran numerical call. These paired checks do not establish an autonomous assembly forecast. Records are under `.runtime/openifs/snow_mass_adjustment_7240564/`.

The complete controller supplies two selected negative density coefficients from the genuine initialization tables. Six focused original placements pass before the admission change, then six native, six immediate ABI and six paired calls each pass 19,712 complete bytes with zero differences and 900 source and native physical relations. They also cover a growing exponential at the 700 argument edge. Two new excess-growth checks preserve 16,512 shared output bytes before rejection. The arithmetic body, original controls and positive-coefficient proofs are unchanged. The revised relay is retained under `negative-decay-r2/`.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfws_massadj_mod::surfws_massadj | 86 | 330,240 | Native private snow-mass child, complete warm-start parent owners and unchanged child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

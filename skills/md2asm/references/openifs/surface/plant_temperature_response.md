# Plant Temperature Response Contract

The complete direct entries replace `farquhar_mod::arrhenius_fn` and `farquhar_mod::arrhenius_modified_fn`. They implement equations AR1 and AR2 in [the physical formulation](../../../../../formulations/openifs/surface/plant_temperature_response.md). This is a scalar response calculation, so it has no time update or grid.

## Inputs and Arithmetic

The admitted inputs have positive finite leaf temperature, reference temperature and gas constant, with finite signed effective activation energy and nonnegative finite deactivation energy and entropy. Each ordered exponential argument is in the closed interval from −700 to 700. Every ordered intermediate and result is finite. The complete source-supported scalar formula is retained for each admitted call.

For AR1, subtract reference temperature from leaf temperature, multiply by activation energy, then divide by the rounded product of reference temperature, gas constant and leaf temperature, in that order. Apply the accepted scalar exponential route. This ordered form implements the same physical expression as AR1.

For AR2, compute AR1 first. Form the reference exponential argument by multiplying reference temperature by entropy, subtracting deactivation energy, then dividing by reference temperature times gas constant. Add one to its exponential result and multiply by AR1. Form the leaf argument by multiplying leaf temperature by entropy, subtracting deactivation energy, then dividing by gas constant times leaf temperature. Divide the stored numerator by one plus this final exponential result. All operations use FP64 with separate multiplication and addition instructions. Round to nearest with ties to even, gradual underflow and signed zeros are preserved. Fused arithmetic, approximate arithmetic and reassociation are excluded.

The qualified scalar EXP implementation remains the common frozen maths dependency. Its accepted proof is reused. The direct functions do not call the original plant-response bodies or ask a driver to provide a numerical stage.

## Interface and Bounds

The GNU Arm application binary interface passes addresses in integer registers and returns the FP64 response in `d0`. The basic function has five address arguments for leaf temperature, reference temperature, activation energy, the unused `TAGF` object and the `TCST` object. The adjusted function has seven addresses, with deactivation energy and entropy inserted before the two objects.

Each scalar input occupies eight readable bytes and has eight-byte alignment. The retained GNU metadata probe gives `TAGF` size 1472 bytes and `TCST` size 128 bytes, with gas constant at byte offset 24. Both objects are read-only, and the unused object has no numerical role. The direct functions write no input bytes.

The basic entry uses a tail branch to the accepted exponential route and needs no stack. The adjusted entry uses an aligned 80-byte stack frame and preserves `x29`, `x30` and the low 64 bits of `v8` through `v15`. It uses no platform register `x18`. Both entries preserve all other required saved registers and the floating-point control register.

## Output and Acceptance

The canonical output is the eight little-endian bytes returned in `d0`. Source and native outputs must have zero differing bytes. Full scalar and object owners remain unchanged. Protected placements check the first and last readable input bytes, and an immediate observer checks saved-register obligations and the floating-point control register.

Independent high-precision checks use the reciprocal-temperature form of AR1 and the high-temperature activity ratio in AR2. They check normalisation at reference temperature, positive rates, basic thermal monotonicity for the supplied energy sign, zero-activation behaviour and the effect of the activity factor. These physical checks are applied separately to source and native results. Exact source agreement alone does not establish physical correctness.

The basic tail call and the adjusted function's register-held scalar inputs reuse the accepted EXP route without allocation. Numerical inputs remain live across the three exponential calls in saved floating-point registers. The focused verifier passed 458 protected placements and 2908 independent source and native physical relations. All 3664 compared return bytes were identical. The genuine paired smoke passed eight basic calls and twelve adjusted calls, with 160 return bytes identical and 128 independent source and native relations. Input owners, saved registers and floating-point control passed. These are critical and relay results. Full

## Signed Temperature Response

The complete source caller uses an effective energy of −24,460 J/mol for its carbon-dioxide versus oxygen selectivity response. This response decreases as temperature increases. Both signs follow AR1 with the same ordered assembly operations. Revision 2 admits signed effective energy while preserving the positive-temperature, gas-constant, deactivation, entropy and exponential-range bounds. The retained source is `surf/module/sufarquhar_mod.F90` and its selectivity call is in `farquhar_mod.F90`. Earlier numerical, interface and scalar EXP proofs remain valid.

The signed-energy extension passes thirteen cases in 26 protected source/native placements, with 208 returned bytes identical and 160 independent relations at 100 decimal digits. The corrected paired guard also passes 26 calls and all 208 returned bytes, with 160 live source/native relations. Cases include the recorded 267.3138719506443 K leaf temperature, the −24,460 J/mol source parameter, a second negative energy, the reference state and the modified response. The numerical assembly and earlier proofs are unchanged.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| farquhar_mod::arrhenius_fn | 91,354 | 730,832 | Complete returned routine owners |
| farquhar_mod::arrhenius_modified_fn | 45,357 | 362,856 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

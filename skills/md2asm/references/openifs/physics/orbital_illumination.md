# Orbital Illumination Contract

Revision 1 freezes the orbital stage selected by the original UPDTIM caller and its fctast.func.h functions. This supports the complete [model-time parent](model_time_and_forcing.md). It does not add a weather routine by itself.

## Inputs And Output

Time t is measured in seconds from the original orbital reference. The supported range is 0 through 315,576,000 seconds. The day D is 86,400 seconds, the mean Sun–Earth distance a is 149,597,870,000 metres and Earth’s obliquity e is 0.409093 radians. Obliquity is the tilt of Earth’s rotation axis. These constants retain their captured FP64 bits.

The direct Arm interface receives the time value in d0 and an aligned output address in x0. The output has exactly three FP64 values, in the order distance r in metres, declination delta in radians and time correction E in seconds. Declination describes the Sun’s angle north or south of the equator. The time correction relates mean clock time to the Sun’s apparent daily position. The output owns 24 writable bytes and overlaps no consumed constant. The function preserves x18, x19 through x29, the return address, the low 64 bits of v8 through v15 and the 16-byte stack alignment. Its frame has a fixed size.

## Ordered Arithmetic

Set theta to t divided by the separately rounded product D times 365.25. Set L to 1.7535 plus 6.283076 times theta, M to 6.240075 plus 6.283020 times theta and S to 4.8951 plus 6.283076 times theta. Every decimal coefficient first rounds to FP64. Every product, sum, subtraction and division then rounds separately in the original left-to-right expression order.

Distance is a times the ordered expression 1.0001 minus 0.0163 times sin(L), plus 0.0037 times cos(L). Solar longitude is 4.8952 plus 6.283320 times theta, minus 0.0075 times sin(L), minus 0.0326 times cos(L), minus 0.0003 times sin(2L), plus 0.0002 times cos(2L). Declination is asin of sin(e) times the sine of that solar longitude.

Time correction is 591.8 times sin(2S), minus 459.4 times sin(M), plus the left-associated product 39.5 times sin(M) times cos(2S), minus 12.7 times sin(4S), minus 4.8 times sin(2M). Reusing an identical already rounded operand preserves its bits. It does not permit reassociation or contraction.

Use the qualified direct sine, cosine and inverse-sine assembly with its exact integer product-sum child. Give this parent’s helper entries explicit bindings. The control library remains separate, and no Fortran or C function supplies an orbital calculation. FPCR is zero, with nearest-even rounding, gradual underflow and preserved signed zeros. Do not change numerical flags or errno merely to conceal a difference.

## Acceptance And Current State

The closed genuine original time-update packet passes 32 independent scalar relations using 120-digit analytic sine and inverse-sine series, clock identities, positive orbital distance and solar forcing. This source check runs before direct emission and reuses the accepted gas, ozone and aerosol physical checks. The declared scalar allowance is 256 FP64 epsilons times the relevant output or equation scale. This check covers the captured point and does not prove the complete parent or every supported helper input.

The direct orbital stage has passed its protected ABI and exact original/native output checks. Complete parent ownership and normal saved-file acceptance remain pending. The complete parent must also preserve all selected gas, ozone and aerosol stages, their pointed-to arrays and their original call order. No autonomous forecast or speed result is claimed.

## Focused Stage Checks

The changed stage passes 58 protected source/native calls over both output-buffer edges, comparing 1,392 bytes exactly. All calls preserve the Arm ABI, inherited arithmetic status and errno, and pass 348 independent analytic and admissibility relations. The complete UPDTIM parent and normal forecast gate remain pending. This supporting stage adds zero weather routines.

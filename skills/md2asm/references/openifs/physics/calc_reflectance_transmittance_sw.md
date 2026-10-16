# Shortwave Layer Reflection And Transmission Contract

Revision 2 implements [P01 and P02](../../../../../formulations/openifs/physics/two_stream_shortwave_transport.md) from `radiation_two_stream::calc_reflectance_transmittance_sw` in the unchanged OpenIFS file `radiation/module/radiation_two_stream.F90`. This child returns five layer coefficients. Its callers combine layers and remain separate routines.

## Numerical Method And Ordered Arithmetic

The original method uses the analytical two-stream layer solution of Meador and Weaver. Let RN mean one FP64 rounding to nearest, with ties to even. Every operator in the following sequence rounds separately, and parentheses retain the listed dependencies. Inputs `g1`, `g2` and `g3` are the three coupling coefficients, `w` is the scattering fraction, `t` is optical depth and `mu` is the solar-angle cosine. `EXP` is the shared accepted non-fused scalar exponential route. The square root and division use native correctly rounded instructions.

```text
z = 1 - g3
alpha1 = (g1*z) + (g2*g3)
alpha2 = (g1*g3) + (g2*z)
k = sqrt(max((g1-g2)*(g1+g2), FP64(1e-12)))
m = mu
if abs(1-k*mu) < 1000*2^-52
    m = mu * RN(1-1000*2^-52)
e0 = EXP(-max(t/m, 0))
e = EXP(-(k*t))
e2 = e*e
ke2 = (2*k)*e
f = 1 / ((k+g1) + ((k-g1)*e2))
ref_diff = (g2*(1-e2))*f
trans_diff = ke2*f
km = k*m
kg3 = k*g3
kg4 = k*z
f = ((m*w)*f)/(1-(km*km))
r = f * (((1-km)*(alpha2+kg3) - ((1+km)*(alpha2-kg3))*e2)
         - ((ke2*(g3-alpha2*m))*e0))
s = f * ((ke2*(z+alpha1*m))
         - e0*((1+km)*(alpha1+kg4) - ((1-km)*(alpha1-kg4))*e2))
ref_dir = max(0, min(r,1))
trans_dir_diff = max(0, min(s,1-ref_dir))
trans_dir_dir = e0
```

Negation, comparisons and copies preserve their original behaviour. Constants `1e-12`, the branch threshold and the adjusted-angle multiplier use their original FP64 bits. Require FPCR zero, gradual underflow and preserved signed zeros. The supported physical corpus has finite nonnegative optical depth, daylight angles and coefficients from the shortwave coefficient routine after the declared scattering treatment. The method also preserves the original zero-angle behaviour wherever its ordered expressions have defined numerical results. Do not use fused arithmetic, approximate division or reassociation.

## Interface And Storage

The Arm application binary interface supplies ordinary addresses rather than array descriptors. Registers `x0` and `x1` address an INTEGER4 count and FP64 angle. Registers `x2` through `x6` address contiguous FP64 optical depth, scattering fraction and three coupling arrays. Register `x7` addresses diffuse reflection. At the entry stack pointer, bytes zero, eight, 16 and 24 supply pointers to diffuse transmission, direct reflection, scattered direct transmission and unscattered direct transmission. Each reached cell is eight aligned bytes. Inputs and the five output arrays are disjoint, and the caller supplies the requested count. A nonpositive count writes no output.

The direct assembly owns a 256-byte stack frame aligned to 16 bytes and preserves `x19` through `x30` and `d8` through `d15`, leaving the platform register `x18` untouched. Its two scalar EXP calls preserve those registers through the standard ABI. After the second and final EXP call, caller-saved registers `d16` through `d22` hold rounded intermediate values until their final use. A caller-saved register can be changed by an external call, so these additional values are created only after all such calls for that cell. A paired stack load reads the same two adjacent eight-byte intermediate slots within the fixed frame. No scratch array or omitted layer stage is supplied by a driver. Only the five declared output arrays are mutable, and all input and neighbouring bytes remain unchanged.

The scalar schedule starts the independent square root before the two coupling sums and starts optical-depth division before three independent products. Each operation keeps its ordered FP64 operands and rounding point. Both EXP arguments and their call order remain fixed, and every operation that precedes either call remains before that call. The same scalar loop handles every selected cell, including an odd count, with the original angle comparison and adjustment.

## Scientific And Byte Acceptance

A small independent verifier computes the exponential of the three-by-three matrix of P01 and P02 with 100 decimal digits, then imposes the layer boundaries. This method does not repeat the original reflection formulas. Nineteen cases cover absorption, partial and conservative scattering, zero depth and angles beside the guarded singularity. Outward intervals account for half an ulp, the spacing between representable values, at each arithmetic rounding and one ulp at each accepted EXP evaluation. The square-root-floor effect is recorded separately by comparing the exact regularised expression with the unregularised boundary solution. Energy limits use these derived enclosures, rather than a fitted tolerance.

The original has a known conditioning limit. In the conservative transparent case, diffuse transmission differs from one by about `2.88e-11`. Near the guarded singularity, the largest critical boundary-solution error is about `2.21e-4`, within its broad derived rounding enclosure. These limitations belong to the unchanged numerical method and must be reported. Exact byte agreement cannot remove them, and the exponential accuracy record is a tested domain result rather than a global proof.

Compare all complete returned owners with the strict original, requiring zero differing bytes. Critical cases also protect input immutability, output bounds, empty counts, the branch threshold and exponential underflow. The native assembly is written directly from this contract and built with the assembler and linker. Original instructions are inspected only to confirm interface and rounding, and do not supply generated solver code. Keep critical and live forecast acceptance distinct, with local records under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Scalar Schedule Checks

The changed schedule passes the accepted 1,344-call critical corpus over 1,599,360 returned output bytes with zero differences. It retains read-only inputs, protected output bounds, empty counts, angle branches, signed zeros, tiny inputs and FPCR zero. A local extension of that same corpus compares immediate FPSR and errno after fresh and seeded incoming flags, with zero differences. FPSR is the floating-point status register, whose set bits record numerical events and remain set until cleared. FPCR is the floating-point control register, which remains zero for the declared rounding mode and gradual underflow.

Replay of the 19 accepted independent 100-digit matrix-exponential boundary solutions compares 760 output bytes with zero differences. It reuses the original physical acceptance and its unchanged conditioning limits, rather than repeating the independent calculation. A focused expression review of both angle branches confirms the same five outputs, each rounded operation and its ordered inputs, the angle comparison and both EXP arguments in call order. The ordinary branch has 73 arithmetic operations, including its two EXP calls, and the adjusted branch has 74. The complete object retains ordinary FP64 instructions and the original register obligations.

The changed [autonomous forecast](../input/standalone_weather_forecast.md) matches all 27,486,113 compared numerical-state bytes and all 618,140 saved-file bytes. All 59 matched final views and the native ABI pass. The [README](../../../../../README.md) reports matched complete-process performance and the unchanged whole-forecast physical and process-boundary limits. Detailed component results stay locally under `.runtime/openifs/reflection_schedule_7484780/`.

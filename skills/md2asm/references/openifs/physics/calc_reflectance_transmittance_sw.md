# Shortwave Layer Reflection And Transmission Contract

Revision 4 implements [P01 and P02](../../../../../formulations/openifs/physics/two_stream_shortwave_transport.md) from `radiation_two_stream::calc_reflectance_transmittance_sw` in the unchanged OpenIFS file `radiation/module/radiation_two_stream.F90`. This child returns five layer coefficients. Its callers combine layers and remain separate routines.

## Numerical Method And Ordered Arithmetic

The original method uses the analytical two-stream layer solution of Meador and Weaver. Let RN mean one FP64 rounding to nearest, with ties to even. Every operator in the following sequence rounds separately, and parentheses retain the listed dependencies. Inputs `g1`, `g2` and `g3` are the three coupling coefficients, `w` is the scattering fraction, `t` is optical depth and `mu` is the solar-angle cosine. `EXP` is the shared accepted non-fused exponential route. Its paired and four-value ordinary paths keep the same separate operations and table words in each lane. The square root and division use native correctly rounded instructions.

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

The paired entry owns a 256-byte stack frame aligned to 16 bytes and preserves `x19` through `x30` and `d8` through `d15`, leaving the platform register `x18` untouched. It carries two independent cells in the two FP64 lanes of each vector. Its private four-value EXP child takes two argument pairs in `q0` and `q1` and returns the same lane order. It preserves all 128 bits of `q8` through `q15` and `q24` through `q31`, so the parent retains rounded state across the call. The accepted scalar body remains in the same physics source under the fixed private name `md2asm_mcica_reflect_scalar_fallback`. No driver supplies a scratch array or an omitted numerical stage. Only the five declared output arrays are mutable, and input and neighbouring bytes remain unchanged.

Integer guards first require a finite solar-angle cosine from zero to one, finite nonnegative optical depth no greater than one million, a finite scattering fraction from zero to one and coupling-coefficient magnitudes no greater than eight. Signed zeros are retained. Values outside these bounds use the accepted scalar body. Each admitted lane preserves the listed arithmetic dependencies and rounding points. An inactive angle adjustment multiplies positive zero by the frozen adjustment factor, then integer selection retains the original angle. This adds no floating-point flags in that lane.

The parent copies the first EXP argument for both cells from `q28` to `q0` and the second argument from `q29` to `q1`, then calls `md2asm_try_exp_four_counted`. This child checks all four input words before changing the shared counter or executing EXP arithmetic. Each must be exact signed zero or have magnitude from $`2^{-54}`$ inclusive to $`512`$ exclusive, with FPCR zero as a precondition. A refusal preserves both argument pairs and changes no FPSR flag, `errno` or counter; the parent then calls its accepted scalar body for both cells. Any already executed parent prefix contains only accepted scalar operations, so its sticky flags form a subset of the final scalar flags. No production status logger or flag clear intervenes. The scalar range-error path preserves its FPSR snapshot, including prefix bits.

A successful child evaluates all four independent EXP values with the frozen per-lane operations and table words. It adds four modulo $`2^{64}`$ to the existing scalar alias counter, equal to the two prior paired contributions at final observation. The parent copies the results back to `q28` and `q29`, then executes its unchanged two-cell output tree. Final output bytes, FPSR, FPCR, `errno` and the scalar-equivalent EXP count agree with scalar cell order. Displaced intermediate status and counter snapshots have no equality claim. An odd final cell uses the same scalar body.

The retained scalar schedule starts the independent square root before the coupling sums and starts optical-depth division before three independent products. Its two EXP arguments and scalar call order remain fixed. After its final EXP call, caller-saved registers hold rounded values until their final use. The scalar and paired paths share the same original angle threshold, literal bits and output bounds.

## Scientific And Byte Acceptance

A small independent verifier computes the exponential of the three-by-three matrix of P01 and P02 with 100 decimal digits, then imposes the layer boundaries. This method does not repeat the original reflection formulas. The accepted cases cover absorption, partial and conservative scattering, zero depth and angles beside the guarded singularity. Outward intervals account for half an ulp, the spacing between representable values, at each arithmetic rounding and one ulp at each accepted EXP evaluation. The square-root-floor effect is recorded separately by comparing the exact regularised expression with the unregularised boundary solution. Energy limits use these derived enclosures, rather than a fitted tolerance.

The original has a known conditioning limit. In the conservative transparent case, diffuse transmission differs from one by about `2.88e-11`. Near the guarded singularity, the largest critical boundary-solution error is about `2.21e-4`, within its broad derived rounding enclosure. These limitations belong to the unchanged numerical method and must be reported. Exact byte agreement cannot remove them, and the exponential accuracy record is a tested domain result rather than a global proof.

Compare all complete returned owners with the strict original, requiring zero differing bytes. Critical cases also protect input immutability, output bounds, empty counts, the branch threshold and exponential underflow. The native assembly is written directly from this contract and built with the assembler and linker. Original instructions are inspected only to confirm interface and rounding, and do not supply generated solver code. Keep critical and live forecast acceptance distinct, with local records under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Current Critical Evidence

| Requirement | Current check | Result |
| --- | --- | --- |
| Complete outputs, read-only inputs, bounds and original status | 1,344 protected calls, 1,599,360 output bytes | Zero differences |
| Four-value admission, mixed angle masks and public ABI | 39 cases under eight incoming status seeds, 312 scalar-versus-paired comparisons, 23,680 output bytes | Zero differences |
| Independent boundary solutions in paired lanes and an odd remainder | 19 accepted solutions, 20 calls, 41 cells, 1,640 output bytes | Zero differences |

The protected corpus reaches 10,450 successful private four-value EXP calls and retains exactly two scalar-equivalent EXP contributions per cell. The edge corpus reaches 120 successful four-value calls, and the independent physical replay reaches 20. A verification-only integer observer counts successes; the production and timed helpers contain no observer. Immediate FPSR and `errno`, unchanged FPCR zero, nonpositive counts, signed zeros, tiny values, special values and odd remainders pass. FPSR records numerical events in bits that remain set until cleared. The new cases also check the public saved registers, platform register `x18` and stack pointer. The independent oracle and its stated conditioning limits remain unchanged. The four-value helper separately passes 60,480 exact-output, status, counter and full private-register calls in its [EXP contract](../support/scalar_exponential.md). Its four-lane refusal leaves both input vectors and status unchanged. The independent accuracy proof is reused because every admitted lane retains the accepted scalar arithmetic.

The direct physics source contains the qualified four-value parent followed by the exact accepted scalar body. Matched component timing on the retained 112-cell physical layer reduces the median complete-call time from 1634.25 to 1608.25 nanoseconds, with eleven of twelve pairs favouring the candidate. One slower block remains included under the frozen protocol. This result does not measure the admission frequency of genuine forecast calls.

The selected [autonomous forecast](../input/standalone_weather_forecast.md) passes the complete numerical-state comparison over all 685 owners, 560 descriptor relations and 27,486,113 raw bytes with zero differences. All ten saved files match over 618,140 bytes, and all 59 controlled final views match the accepted R26 run. The native ABI mask is zero, and its natural final FPCR, FPSR and `errno` are zero, 25 and zero. No numerical value is masked, no status is reset and no output is repaired. The known optional-argument and incoming-status differences keep aggregate process-boundary identity false. Accepted component and saved-trajectory physics remain in force; global heat and water budgets and whole-process identity remain unproved.

Three matched ordinary forecast pairs retain all ten files and 59 R25 final views exactly, with checks outside timing. The combined grouped-RNG and four-value-EXP batch reduces the median complete-process time from 24.98 to 24.38 seconds. Every pair favours the batch, with baseline times from 24.94 to 25.07 seconds and candidate times from 23.86 to 24.89 seconds. This complete-batch result does not assign its gain to either routine alone. The [README](../../../../../README.md) gives the matched comparison. Detailed critical, ABI and measurement receipts stay locally under `.runtime/openifs/four_value_reflection_7484780/`, `.runtime/openifs/four_value_exponential_7484780/` and `.runtime/openifs/grouped_stream_radiation_batch_7484780/`.

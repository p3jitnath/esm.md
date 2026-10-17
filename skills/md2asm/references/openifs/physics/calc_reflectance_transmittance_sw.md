# Shortwave Layer Reflection And Transmission Contract

Revision 6 implements [P01 and P02](../../../../../formulations/openifs/physics/two_stream_shortwave_transport.md) from `radiation_two_stream::calc_reflectance_transmittance_sw` in the unchanged OpenIFS file `radiation/module/radiation_two_stream.F90`. This child returns five layer coefficients. Its callers combine layers and remain separate routines.

## Numerical Method And Ordered Arithmetic

The original method uses the analytical two-stream layer solution of Meador and Weaver. Let RN mean one FP64 rounding to nearest, with ties to even. Every operator in the following sequence rounds separately, and parentheses retain the listed dependencies. Inputs `g1`, `g2` and `g3` are the three coupling coefficients, `w` is the scattering fraction, `t` is optical depth and `mu` is the solar-angle cosine. `EXP` is the shared accepted non-fused exponential route. Its paired, four-value and eight-value ordinary paths keep the same separate operations and table words in each lane. The square root and division use native correctly rounded instructions.

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

The entry groups four reached cells when their runtime inputs pass the integer guards. Its 384-byte stack frame stays aligned to 16 bytes and preserves `x19` through `x30` and `d8` through `d15`, leaving the platform register `x18` untouched. The original incoming stack arguments are read at the new frame offsets 384 and 400. Bytes 256 through 383 hold eight rounded intermediate vectors for the first pair. The second pair keeps its eight intermediate vectors in `q8` through `q15`, which the private eight-value EXP child preserves in full. The parent rereads the same immutable coupling coefficients and scattering fraction after the call. Only the five output arrays are mutable.

Integer guards require a finite solar-angle cosine from zero to one, finite nonnegative optical depth no greater than one million, a finite scattering fraction from zero to one and coupling-coefficient magnitudes no greater than eight. Signed zeros are retained. All four cells pass these raw-input guards before any speculative arithmetic. A refusal enters the complete accepted two-cell path, which retains its own guards, four-value child and scalar fallback. Fewer than four remaining cells use that same path, and an odd final cell uses the accepted scalar body. An invalid angle uses the scalar body for the complete requested count. These choices depend on runtime words and shape, with no stored forecast-specific result.

The four-cell path saves a copy of FPSR, the floating-point status register, before preparing the EXP arguments. Its 32-bit snapshot at stack offset 196 is separate from the 32-bit fallback count at offset 192. Each pair prepares its two expressions `-max(t/m,0)` and `-(k*t)` with the listed rounding points. An inactive angle adjustment multiplies positive zero by the frozen adjustment factor, then integer selection retains the original angle, adding no flags in that lane. The two preparations contain hardware arithmetic, immutable reads and private stack writes, with no output store, counter change, service or status observer.

The child `md2asm_try_exp_eight_counted` takes the first pair's two argument vectors in `q0` and `q1` and the second pair's vectors in `q2` and `q3`. It admits all eight words before changing a result or the shared count. Each word must be exact signed zero or have finite magnitude from $`2^{-54}`$ inclusive to $`512`$ exclusive. FPCR zero is an entry requirement. Refusal preserves all four input vectors, FPSR, FPCR, `errno` and the counter. The parent then restores its saved FPSR word and enters the complete original two-cell path through a bypass that cannot retry the four-cell attempt. This replay includes the original input loads, guards, arithmetic prefix and four-value child, retaining its exact refusal behaviour.

Successful admission adds eight modulo $`2^{64}`$ to the existing scalar-equivalent EXP counter and returns four result vectors in the same order. The parent executes the two unchanged output trees, storing the first pair before the second. All admitted EXP results are normal and finite, and no external service or flag clear intervenes before both trees finish. FPSR bits record numerical events and remain set until cleared, so moving independent cell work changes the order of this flag union without changing its final value. Final output bytes, FPSR, FPCR, `errno` and the counter agree with scalar cell order; displaced intermediate observations have no equality claim.

The exact accepted scalar body remains in the same physics source as `md2asm_mcica_reflect_scalar_fallback`. Its square root, coupling sums, division schedule, EXP arguments and scalar call order remain fixed. After the final scalar EXP call, caller-saved registers retain rounded values until their final use. All routes share the original angle threshold, literal bits and output bounds. No driver supplies a scratch array or numerical stage.

The optional private shortwave build uses `MD2ASM_SW_PRIVATE_COUNTERS` and the hidden entry `md2asm_sw_private_reflect`. It keeps the same twelve-pointer ABI and receives a 64-byte counter prefix in `x28`, aligned to 64 bytes. The prefix stores the fast product-sum, wide product-sum and scalar-equivalent EXP totals at byte offsets zero, eight and 16. Reflection changes only the EXP word, modulo $`2^{64}`$, through its accepted private scalar, four-value and eight-value children. The saved register `x29` holds the direct-reflection output pointer, while `x28` retains the counter base. Both registers are restored for the caller. The 384-byte vector frame, 256-byte scalar frame, all raw guards, ordered arithmetic, status snapshots, refusal replay and remainder paths remain unchanged. The default build produces the complete original object without this private interface.

The private build passes the retained protected, edge and rollback gates listed below with zero differing bytes and exact FPSR, FPCR, `errno` and counts. The verification bridge also checks the seven other prefix words and the returned `x28` base, while leaving `x29` and `x18` exposed to the original ABI probe. These observations are absent from production. The complete caller is covered by the [shortwave parent contract](solver_mcica_sw.md).

## Scientific And Byte Acceptance

A small independent verifier computes the exponential of the three-by-three matrix of P01 and P02 with 100 decimal digits, then imposes the layer boundaries. This method does not repeat the original reflection formulas. The accepted cases cover absorption, partial and conservative scattering, zero depth and angles beside the guarded singularity. Outward intervals account for half an ulp, the spacing between representable values, at each arithmetic rounding and one ulp at each accepted EXP evaluation. The square-root-floor effect is recorded separately by comparing the exact regularised expression with the unregularised boundary solution. Energy limits use these derived enclosures, rather than a fitted tolerance.

The original has a known conditioning limit. In the conservative transparent case, diffuse transmission differs from one by about `2.88e-11`. Near the guarded singularity, the largest critical boundary-solution error is about `2.21e-4`, within its broad derived rounding enclosure. These limitations belong to the unchanged numerical method and must be reported. Exact byte agreement cannot remove them, and the exponential accuracy record is a tested domain result rather than a global proof.

Compare all complete returned owners with the strict original, requiring zero differing bytes. Critical cases also protect input immutability, output bounds, empty counts, the branch threshold and exponential underflow. The native assembly is written directly from this contract and built with the assembler and linker. Original instructions are inspected only to confirm interface and rounding, and do not supply generated solver code. Keep critical and live forecast acceptance distinct, with local records under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

After the eight-value exponential succeeds, start the second pair's unchanged reciprocal while the first pair finishes its outputs. The second pair's squared exponential stays in q30 and its reciprocal in q31. Each q register holds two FP64 values. The first pair's final cap uses q18 only after its earlier value is no longer needed. The early read uses the same immutable input address inside the complete four-cell guard. All ten ordered output stores and all 96 rounded floating-point operations in this interval retain their exact operand trees. No call or status observation occurs between the independent operations, and the frame and refusal paths remain unchanged.

## Current Critical Evidence

| Requirement | Current check | Result |
| --- | --- | --- |
| Complete outputs, read-only inputs, bounds and original status | 1,344 protected calls, 1,599,360 output bytes | Zero differences |
| Admission, refusal in each cell, four- through nine-cell shapes and public ABI | 57 cases under eight status seeds, 456 comparisons, 912 ABI calls, 51,520 output bytes | Zero differences |
| FPSR restoration before complete original-path replay | Two mixed zero-angle cases under eight status seeds, 16 comparisons, 32 ABI calls, 2,560 output bytes | Zero differences |
| Independent boundary solutions in four-cell groups and a remainder | 19 accepted solutions, 20 calls, 81 cells, 3,240 output bytes | Zero differences |

The added cases reach the new eight-value path and its full refusal in either pair. They check immediate FPSR and `errno`, unchanged FPCR zero, scalar-equivalent EXP counts, saved registers, platform register `x18` and stack pointer. The rollback check also compares FPSR at the first replayed four-value child against the original two-cell entry, using preparations that raise different flags. A verification-only integer observer reads this boundary and counts helper paths; production and timed code contain no observer. The default build retains the exact 612-byte scalar function, and both builds retain the original two-cell arithmetic. The eight-value child separately passes 120,960 exact-output, status, counter and full private-register calls in its [EXP contract](../support/scalar_exponential.md). Existing independent accuracy and conditioning limits remain in force.

The changed [autonomous forecast](../input/standalone_weather_forecast.md) passes the complete numerical-state comparison over all 685 owners, 560 descriptor relations and 27,486,113 raw bytes with zero differences. All ten saved files match over 618,140 bytes, and all 59 controlled final views match the accepted R26 run. The native ABI mask is zero, and its natural final FPCR, FPSR and `errno` are zero, 25 and zero. The observation gates read returned state without masking values, changing status or repairing outputs. Known optional-argument and incoming-status differences keep aggregate process-boundary identity false. Accepted component and saved-trajectory physics remain in force; global heat and water budgets and whole-process identity remain unproved.

Three matched ordinary forecast pairs retain all ten saved files and 59 R25 final views exactly, with checks outside timing. The joint batch combines this division schedule with signed-row reuse in transport interpolation. It reduces the median complete-process time from 20.00 [20.00–20.01] to 19.94 [19.94–19.95] seconds. All three wall-time and user CPU pairs improve. The [README](../../../../../README.md) reports this combined result, with no separate whole-forecast gain assigned to either part. Independent physical checks are reused because every equation and ordered operand tree remains unchanged. Other forecast-input performance remains unmeasured, and detailed measurements stay local.

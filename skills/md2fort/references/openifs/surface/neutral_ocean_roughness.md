# Neutral Ocean Roughness Contract

Revision 1.0 implements the complete contained PZ0WN calculation for [surface roughness](../../../../../formulations/openifs/surface/surface_roughness.md), equation R01. It supplies the initial neutral ocean roughness inside the complete VUPDZ0 parent. No general surface-parent acceptance is claimed here.

## Method

Newton's method improves a trial friction velocity by subtracting the wind-profile error divided by its slope. Use the original fifteen-iteration limit, constants and fallback. The method preserves the reviewed source's exact ordered calculations.

FP64 is the 64-bit floating-point format. RN means one separate rounding to nearest with ties to even. All operations below have their own rounding point. Preserve signed zeros, gradual underflow and FPCR equal to zero. Forbid fused operations, reassociation and approximate division or square root. Use the unchanged accepted opaque LOG route.

Let W be wind speed in metres per second, G be geopotential in square metres per square second, a be the dimensionless Charnock wave coefficient, g be gravity, n be effective viscosity and k be the dimensionless profile coefficient. First form z as RN of G divided by g, q as RN of the smaller of a and 0.1 divided by g, and s as RN of k times W. Initialise u as RN of W times the square root of RN of 0.0008 plus RN of 0.00008 times W.

Each iteration stores old as the larger of u and 0.000001, without replacing u. Compute c as RN of q times RN of u squared, v as RN of n divided by u and r as RN of c plus v. Compute x as RN of z divided by RN of z plus r. Compute l as RN of one divided by LOG of RN of one plus RN of z divided by r. LOG is the qualified scalar mathematical function.

Compute f as RN of u minus RN of s times l. Compute d as one minus the separately rounded chain s times RN of l squared, then times x, then times RN of RN of two times c minus v, then divided by RN of u times r. If d is nonzero, replace u with RN of u minus RN of f divided by d.

Stop when the rounded absolute difference between updated u and old is at most RN of u times 0.00001, and the absolute value of the pre-update f is at most 0.00001. Both comparisons must be ordered, so a NaN does not satisfy either. NaN means a floating-point value that is not a real number.

After convergence, replace u with its maximum against 0.000001 and return RN of RN of n divided by u plus RN of q times RN of u squared. If all fifteen iterations fail, return the fixed positive roughness of 0.01 metres. This is the source's defined fallback rather than an exact neutral-profile root.

## Input And ABI

Use finite positive W, G, g, n and k, with finite nonnegative a. The parent supplies a positive wind floor. Normal converged scientific cases have positive finite logarithm arguments and finite intermediates. The complete source-defined iteration and fallback remain present.

Export md2asm_neutral_ocean_roughness with the Arm scalar C ABI. Registers d0 through d5 contain W, G, a, g, n and k. Return roughness in d0. Preserve x19 through x29, the link register and the required portions of v8 through v15. Keep the stack aligned to sixteen bytes and do not use x18. The fixed private frame is 192 bytes. The caller supplies no array or writable output pointer.

## Evidence

Before direct emission, the unchanged statement body was exposed under a unique local original-control name, without changing its mathematics. Seventy-two source cases passed independent eighty-digit bisection of the physical neutral profile. Four additional cases exercise the Charnock cap. The maximum observed relative roughness error is 1.1118859577200759 times ten to the power minus eleven, below the declared 0.0002 limit. These are sampled physical checks and do not establish a global error bound.

The direct body must match every returned FP64 byte, including caps, iteration termination and fallback. Its parent must count genuine contained-child executions when initialising the forecast. Keep the original source, exposed control, critical inputs and results locally. All seventy-six original and native scalar outputs match exactly across 608 bytes. Six additional focused cases match 48 bytes, check immediate saved registers and FPCR, and cover different physical constants and the no-root fallback. The fallback case has wind above the independent bound of twice the square root of z divided by q, divided by k, so no neutral-profile solution exists. The direct object contains no fused or approximate floating-point instruction. No timing claim is made.

The complete [surface roughness parent](surface_roughness.md) binds this child directly for initial stress. Its paired smoke records five genuine original neutral stages and five complete direct child calls. Forecast acceptance and the exact queue count remain pending the next saved-file gate.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vupdz0_mod::pz0wn | 2,048 | 37,152,000 | Native private wave child, compared complete parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

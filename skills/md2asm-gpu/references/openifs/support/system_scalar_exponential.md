# System Scalar Exponential on the GPU

Revision 2 defines the direct [PTX exponential](../../../../../src/openifs/support/gpu/system_scalar_exponential.ptx) for the selected glibc 2.38 mathematical-library provider. Its build identifier is `67ce5f5f4d0b0cc920e2307fdedd62c2a43c3925`. The input and result are dimensionless FP64 values, meaning numbers stored in 64 bits. Keep this provider distinct from the separately qualified [scalar exponential](../mathematical_support.md).

The numerical source is the frozen glibc `e_exp.c`, `e_exp_data.c` and AArch64 `math_private.h` snapshot. Its source algorithm and data are copyright 2018–2023 Free Software Foundation, Inc., under LGPL-2.1-or-later. The local source snapshot records the precise versions. Select this function when the caller's resolved library provider requires this arithmetic route.

## Ordered Calculation

Let $`R(a)`$ mean one FP64 rounding to nearest with ties to even. Let $`S(a,b,c)`$ mean one rounding of the exact real value $`ab+c`$. The qualified [integer product sum](../finite_mathematical_functions.md) implements $`S`$. This retains the selected library calculation without contracting weather-model expressions.

The reduction uses 128 table intervals. First form $`z=R(x\,\mathrm{InvLn2N})`$, then round it to an integer with ties away from zero and without raising inexact status. Convert that bounded integer exactly to the FP64 value $`k_d`$. Form $`r_1=S(k_d,\mathrm{NegLn2hiN},x)`$ and $`r=S(k_d,\mathrm{NegLn2loN},r_1)`$. The integer selects the frozen table pair and scale exponent.

Preserve this complete polynomial order, using the frozen coefficient words.

```math
r_2=R(r r), \quad p_{23}=S(r,C_3,C_2), \quad p_{45}=S(r,C_5,C_4)
```

```math
t_0=R(\mathrm{tail}+r), \quad t_1=S(r_2,p_{23},t_0), \quad r_4=R(r_2 r_2)
```

```math
u=S(r_4,p_{45},t_1), \quad y=S(\mathrm{scale},u,\mathrm{scale})
```

Large positive scales retain the source exponent adjustment, followed by a separate rounded multiplication by $`2^{1009}`$. Large negative scales retain the separate shared product $`R(\mathrm{scale}\,u)`$, the complete high/low residual correction and the final multiplication by $`2^{-1022}`$. Preserve the original positive-zero choice, minimum-normal squared operation and every intermediate rounding. The PTX contains the complete fixed branch graph and constant words.

For finite absolute inputs below $`2^{-54}`$, return $`R(1+x)`$. Negative infinity returns positive zero, and positive infinity returns itself. NaNs retain their sign and payload, with invalid status raised only for a signalling input. Finite absolute inputs of at least 1024 follow the source overflow or underflow multiplication. Preserve the Arm rule that tests an inexact tiny result before rounding.

## Device Interface

`md2asm_gpu_exp_system_rounding` takes one raw 64-bit word and returns one eight-byte-aligned 16-byte object. Bytes 0–7 hold the result, bytes 8–11 hold newly raised Arm floating-point flags, and bytes 12–15 hold an actual error-write event. Event zero preserves `errno`, the C library error slot. Event 34 writes `ERANGE` when a finite input produces zero or positive infinity.

The caller combines new flags with incoming flags using integer OR. The function reads its immutable table and changes no caller buffer. Temporary registers and parameter storage are private to each call. No shared storage or barrier is required. Its internal exact-product-sum work does not increment the original CPU FAST/WIDE counters, because the selected native library does not call those instrumented helpers.

## Accepted Scope

Complete result, flag and error-event records match the selected CPU provider, including seeded status, special values, subnormal results, reduction ties and protected buffers. Independent high-precision exponential checks and the numerical-source review pass. These checks establish the declared component scope, rather than a proof of correct rounding for every input. Complete model callers and saved forecasts still need their own acceptance. Detailed corpora and measurements remain local under `.runtime/`.

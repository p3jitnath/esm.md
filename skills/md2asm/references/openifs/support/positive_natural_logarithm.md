# Positive Natural Logarithm

Revision 1 defines `md2asm_log_positive_normal`, the direct natural-logarithm child used by the spectral packing fit. The natural logarithm gives the exponent of the mathematical constant $`e`$ that produces a positive input. The original numerical source is Arm optimized-routines v26.01, commit `649ccc8411e7c4862965710f25c570d854a1483f`, with its nonfused FP64 path and exact coefficient words. This entry supports finite inputs from $`2^{-52}`$ through the largest finite FP64 value. Other inputs and FPCR other than zero stop with exit 116.

Let $`R(q)`$ mean one FP64 rounding to nearest, with ties to even. The ordinary path splits $`x=2^kz`$ exactly, with $`11/16\le z<11/8`$, and selects one of 128 records. In that record, $`v`$ is the reciprocal centre, $`c`$ is the centre logarithm, and $`c_h,c_l`$ are the centre parts. Constants $`L_h,L_l`$ split $`\log2`$. The stored $`A`$ and $`B`$ values are polynomial coefficients. The ordinary calculation is:

```math
r=R(R(R(z-c_h)-c_l)v),\quad w=R(R(kL_h)+c),\quad h=R(w+r),
\ell=R(R(R(w-h)+r)+R(kL_l)),\quad r_2=R(rr),
u=R(A_3+R(rA_4)),\quad v_1=R(R(A_1+R(rA_2))+R(r_2u)),
y=R(R(R(\ell+R(r_2A_0))+R(R(rr_2)v_1))+h).
```

For $`15/16\le x<4361/4096`$, exactly one returns positive zero without adding a flag. Other near-one inputs form $`r=R(x-1)`$, $`r_2=R(rr)`$ and $`r_3=R(rr_2)`$, then use:

```math
t_0=R(R(R(B_7+R(rB_8))+R(r_2B_9))+R(r_3B_{10})),
t_1=R(R(R(B_4+R(rB_5))+R(r_2B_6))+R(r_3t_0)),
p=R(r_3R(R(R(B_1+R(rB_2))+R(r_2B_3))+R(r_3t_1))),
w_0=R(r\,2^{27}),\quad r_h=R(R(r+w_0)-w_0),\quad r_l=R(r-r_h),
w=R(R(r_hr_h)B_0),\quad h=R(r+w),\quad \ell_0=R(R(r-h)+w),
\ell=R(\ell_0+R(R(B_0r_l)R(r_h+r))),\quad y=R(R(p+\ell)+h).
```

Every operation keeps the separate FP64 rounding point shown above. Fused operations and reassociation are excluded.

FP64 uses 64-bit floating-point numbers. The operand and result use register `d0`. The application binary interface (ABI) defines which registers a caller can expect to keep. FPCR controls floating-point arithmetic, FPSR holds its status flags, and errno is the runtime error number. The leaf uses no stack and calls no external service. It preserves `x18`, saved general registers, the required low halves of `v8` through `v15`, FPCR, errno and inherited FPSR flags. FPSR also records flags from the frozen arithmetic. A serial diagnostic counter records accepted calls. The read-only coefficient owner is 4240 bytes, aligned to 16 bytes, with logarithm constants at offset 0, five ordinary coefficients at 16, eleven near-one coefficients at 56, and two 128-record tables at 144 and 2192. No input buffer is mutated.

Focused checks matched 6730 distinct operands in 13460 exact result, status and errno comparisons, with eight seeded Arm ABI cases and all 4240 coefficient bytes equal to the original data. The actual spectral-fit packet supplied 1331 distinct LOG operands; 5324 comparisons also matched its inherited status cases, including FPSR 25. The retained high-precision check of the unchanged original algorithm sampled 10421 inputs and observed a maximum error of about 0.50116 units in the last place. A unit in the last place is the spacing between adjacent FP64 values near the result; this sample gives no universal error bound.

The required T21 forecast reached 5280 direct LOG calls through 120 direct spectral fits. All 685 final-owner records and all ten saved files matched the frozen reference byte for byte, with exact required status. This is the scoped positive-normal child; it does not export the general `log` interface. The surrounding original output writers remain Fortran. Build [the leaf](../../../../../src/openifs/support/positive_natural_logarithm.S) with [its coefficient table](../../../../../src/openifs/support/positive_natural_logarithm_tables.S) and the [spectral packing fit](../output/spectral_packing_fit.md).

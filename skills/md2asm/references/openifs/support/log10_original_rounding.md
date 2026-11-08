# Original-Rounding Base-Ten Logarithm

Revision 1 defines the private function `md2asm_log10_original_rounding`. It takes a finite FP64 ratio $`x`$ in $`[2^{-40},32]`$ and returns its base-ten logarithm. FP64 is the 64-bit floating-point format. The Arm floating-point control register, FPCR, must be zero, which selects nearest-even rounding and gradual underflow. The complete output is the 64-bit word in `d0`. The floating-point status register, FPSR, and the error indicator, `errno`, follow the original valid-input route.

The [physical input](../../../../../formulations/openifs/support/base_ten_logarithm.md) gives the basic equation. The [direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/log10_original_rounding.S) implements the complete admitted range. The base-ten split comes from Sun Microsystems' 1993 logarithm, and its normalized natural logarithm and literal data come from GNU libc 2.38 at commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`. The Sun notice permits redistribution with attribution. The GNU-derived component uses LGPL-2.1-or-later.

## Ordered Calculation

Write $`R(v)`$ for nearest-even rounding to FP64. Every ordinary sum, subtraction and product below has its own $`R`$. Write $`S(a,b,c)=R(ab+c)`$ for a single-rounding step inside the original mathematical primitive. The accepted integer child `md2asm_round_product_sum_candidate` computes $`S`$ without a fused floating-point instruction. Each caller retains its separate arithmetic rounding points.

Let $`k=\lfloor\log_2(x)\rfloor`$, let $`i=1`$ when $`k<0`$ and zero otherwise, and let $`n=k+i`$. Integer bit operations give $`m=x\,2^{-n}`$ exactly. Thus $`m\in[0.5,2)`$, $`k\in[-40,5]`$ and $`n\in[-39,5]`$. Let $`L(m)`$ be the normalized natural logarithm below. The base-ten calculation is

```math
v=R(cL(m)),\qquad z=S(n,\ell,v),\qquad y=S(n,h,z).
```

The exact words for $`c`$, $`h`$ and $`\ell`$ are `0x3fdbcb7b1526e50e`, `0x3fd34413509f6000` and `0x3d59fef311f12b36`. They approximate $`1/\ln(10)`$ and the high and low parts of $`\log_{10}(2)`$. Keeping these parts separate preserves the original output words.

### Normalized Natural Logarithm

The assembly stores the original 128 reciprocal centres $`v_j`$ and centre logarithms $`l_j`$, two split constants $`a_h,a_l`$ for $`\ln(2)`$, five coefficients $`A_0,\ldots,A_4`$ and eleven coefficients $`B_0,\ldots,B_{10}`$. All 274 FP64 words match the installed original library.

Away from one, let $`U`$ be the 64-bit word of $`m`$ and set $`t=U-\texttt{3fe6000000000000}`$ with unsigned wraparound. Extract $`j=(t\gg45)\mathbin{\&}127`$, $`q=t\gg52`$ with a signed shift, and $`U_z=U-(t\mathbin{\&}\texttt{fff0000000000000})`$. Here $`\&`$ means bitwise AND and $`\gg`$ means right shift. Reading $`U_z`$ as FP64 gives $`z`$ exactly. Form

```math
r=S(z,v_j,-1),\quad w=S(q,a_h,l_j),\quad H=R(w+r),
b=S(q,a_l,R(R(w-H)+r)),\quad r_2=R(r^2),\quad r_3=R(rr_2).
```

Then evaluate $`p=S(r,A_4,A_3)`$, $`u=S(r,A_2,A_1)`$ and $`u=S(r_2,p,u)`$. The result is $`L(m)=R(H+S(r_3,u,S(r_2,A_0,b)))`$.

For $`0.9375\le m<1+\texttt{0x1.09p-4}`$, form $`r=R(m-1)`$, $`r_2=R(r^2)`$ and $`r_3=R(rr_2)`$. Evaluate these three coefficient groups in their stated order.

```math
u=S(r,B_8,B_7),\quad u=S(r_2,B_9,u),\quad u=S(r_3,B_{10},u),
p=S(r,B_5,B_4),\quad p=S(r_2,B_6,p),\quad p=S(r_3,u,p),
u=S(r,B_2,B_1),\quad u=S(r_2,B_3,u),\quad u=S(r_3,p,u).
```

A split correction retains the small terms. Set $`r_h=S(-r,2^{27},S(r,2^{27},r))`$, $`r_l=R(r-r_h)`$, $`s=R(r_h^2)`$ and $`H=S(s,B_0,r)`$. Then set $`b=S(s,B_0,R(r-H))`$ and $`b=S(R(B_0r_l),R(r_h+r),b)`$. Return $`L(m)=R(H+S(u,r_3,b))`$. The exact input $`m=1`$ returns positive zero.

## Interface And Bounds

The AArch64 application binary interface, ABI, takes the ratio and returns the result in `d0`. The function has no caller-owned buffer. It checks the complete input word and FPCR before arithmetic, and unsupported values stop before a result is returned. It preserves `x19..x29`, the low 64 bits of `d8..d15`, the stack pointer and FPCR, with a 128-byte private frame aligned to 16 bytes. Table indices stay in 0..127, and normalized-log table loads stay within 274 immutable words. Three adjacent words hold the base-ten constants.

The routine calls only the uniquely named accepted integer-rounding child. Its library uses that child's basename and an absolute runtime search path. It neither replaces global `log10` nor calls the original numerical body. Each caller must prove its positive ratio lies inside the admitted range and verify its complete physical calculation.

## Evidence And Limits

Before direct emission, 6,144 original calls pass the frozen ordered graph and 24,576 independent 160-digit logarithm, finite-result, monotonicity and zero relations. They cover exponent boundaries, every normalized table interval, both near-one endpoints, the physical soil-moisture range and all three source branches. Their complete return words cover 49,152 bytes. A unit in the last place is the spacing between adjacent FP64 numbers beside the result. The largest observed error is 1.45903756 of these units, within the declared limit of two. This is sampled accuracy evidence, not a global error bound.

Direct assembly passes the same 6,144 inputs and 49,152 complete return bytes with zero differences in words, fresh FPSR or errno. Fourteen immediate scalar ABI cases pass 112 bytes and all required saved registers. Sixteen inherited-status cases preserve the original sticky flags and a nonzero errno, and ten unsupported-input or FPCR cases stop before returning. The direct object has 25 qualified integer-rounding calls, with no fused floating-point or approximate instructions. Three calls from /tmp pass 24 complete return bytes through the absolute child search path. Detailed source identities, inputs, output words and checks remain local under `.runtime/openifs/original_log10_7240564/`. Forecast acceptance, comparative timing and any weather-routine count remain caller gates.

## Radiation Entry

Revision 2 adds `md2asm_log10_radiation_original_rounding` for finite inputs in $`[2^{-40},2^{20}]`$ while keeping the original soil entry and its guard unchanged. Both entries use the same complete numerical body and literal table. The normalized mantissa, table index and integer-rounding dependencies are unchanged. The new upper range gives $`k,n\in[5,20]`$ above the old limit. Original surface cloud-particle calculations have LOG10 inputs up to 327 over ocean and $`\exp(0.13w+1.89)`$ over land. Wind $`w\in[0,80]`$ m/s places those inputs below $`2^{20}`$.

The original immutable soil library retains its accepted identity. Only the extra radiation range is qualified anew. Before adding its direct entry, 4,620 original calls pass 36,960 return bytes and 18,480 independent 160-digit relations. The largest observed error is 0.746375 result spacings, below the unchanged two-spacing limit. The new entry uses the same `d0` interface, 128-byte frame and complete status obligations, with no global math override.

The added native entry passes all 4,620 frozen source return words with zero differences in 36,960 bytes, fresh FPSR or errno, without repeating source calls. Six scalar ABI cases preserve registers and inherited status. Five old-domain boundary calls, nine unsupported-entry or control cases and one call from /tmp pass. Normalising away the extra entry and its shared-body label reproduces the preserved original published source exactly. The old soil entry guard and frozen library remain unchanged. Detailed radiation records are local under `.runtime/openifs/original_log10_radiation_7240564/`.

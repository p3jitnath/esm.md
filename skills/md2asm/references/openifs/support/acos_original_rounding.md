# Original-Rounding Inverse Cosine

This contract defines `md2asm_acos_original_rounding`. It converts a finite FP64 cosine $`x\in[-1,1]`$ into an angle in radians. It supports both signed zeros, subnormal inputs and the exact endpoints. The Arm floating-point control register, FPCR, must be zero, which selects nearest-even rounding and gradual underflow. The complete output is the 64-bit word returned in `d0`. The floating-point status register, FPSR, and the error indicator, `errno`, follow the original valid-input route.

The [physical input](../../../../../formulations/openifs/support/inverse_cosine_angle.md) gives the geometry. [Direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/acos_original_rounding.S) implements the complete declared domain. The method and literal tables come from GNU libc 2.38 at commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`. Its IBM Accurate Mathematical Library source defines short polynomials, centred interpolation tables and a root correction near the endpoints. This derived component uses LGPL-2.1-or-later.

## Rounding And Constants

Write $`R(v)`$ for rounding a real value $`v`$ to FP64 with ties to even. Every ordinary sum, subtraction, product and division below has its own $`R`$. Write $`S(a,b,c)=R(ab+c)`$ for an original internal single-rounding step. The accepted integer helper `md2asm_round_product_sum_direct` computes $`S`$ without a fused floating-point instruction. These steps belong to the opaque mathematical primitive. The caller's separate arithmetic rounding points remain separate.

The split half-circle constants are $`h`$ with word `0x3ff921fb54442d18` and $`\ell`$ with word `0x3c91a62633145c07`. Their sum approximates $`\pi/2`$. Six coefficients $`f_1,\ldots,f_6`$, four root-correction coefficients $`r_0,\ldots,r_3`$, and $`t_{27}=2^{27}`$ use their original binary words. All 2,568 interpolation cells, 128 inverse-root cells and 28 power-of-two cells match the original library. The assembly stores those words directly.

Let $`H`$ be the high 32 bits of $`\lvert x\rvert`$, and let $`T[n]`$ be cell $`n`$ of the original interpolation table. Integer bit operations select the interval and centre. They do not round the input.

## Complete Calculation

For $`\lvert x\rvert<2^{-55}`$, return $`h`$. For $`2^{-55}\le\lvert x\rvert<1/8`$, form $`z=R(x^2)`$ and evaluate the recurrence from $`q=f_6`$ through indices 5, 4, 3, 2 and 1.

```math
q\leftarrow S(q,z,f_i),\qquad
r=R(h-x),\qquad
c=R(R(R(h-r)-x)+\ell),\qquad
a=R\left(r+S(-q,R(zx),c)\right).
```

Table intervals use the following integer indices. The rightmost column gives the last polynomial coefficient relative to the selected centre.

| Input magnitude | Centre index $`n`$ | Last coefficient $`L`$ |
| --- | --- | --- |
| $`1/8\le\lvert x\rvert<1/4`$ | $`11((H\mathbin{\&}\texttt{fffff})\gg15)`$ | 6 |
| $`1/4\le\lvert x\rvert<1/2`$ | $`352+11((H\mathbin{\&}\texttt{fffff})\gg14)`$ | 6 |
| $`1/2\le\lvert x\rvert<3/4`$ | $`1056+3((H\mathbin{\&}\texttt{fe000})\gg11)`$ | 7 |
| $`3/4\le\lvert x\rvert<0.921875`$ | $`992+13((H\mathbin{\&}\texttt{fe000})\gg13)`$ | 8 |
| $`0.921875\le\lvert x\rvert<0.953125`$ | $`884+14((H\mathbin{\&}\texttt{fe000})\gg13)`$ | 9 |
| $`0.953125\le\lvert x\rvert<0.96875`$ | $`768+15((H\mathbin{\&}\texttt{fe000})\gg13)`$ | 10 |

Here $`\&`$ means bitwise AND, and $`\gg`$ means integer right shift. The numbers in `texttt` are hexadecimal masks. Starting from $`d=R(\lvert x\rvert-T[n])`$ and $`q=T[n+L]`$, evaluate the recurrence through $`j=L-1,\ldots,2`$.

```math
q\leftarrow S(q,d,T[n+j]),\qquad
p=S(R(d^2),q,T[n+L+1]),\qquad
t=S(T[n+1],d,p).
```

Positive inputs return $`R(R(h-T[n+L+2])+R(\ell-t))`$. Negative inputs return $`R(R(h+T[n+L+2])+R(\ell+t))`$.

For $`0.96875\le\lvert x\rvert<1`$, form $`z=R((1-\lvert x\rvert)/2)`$. The inverse-root table and exact power-of-two scale supply the first approximation $`t`$. Their indices are $`(H_z\mathbin{\&}\texttt{1fffff})\gg14`$ and $`511-(H_z\gg21)`$, where $`H_z`$ is the high word of $`z`$. Multiply those two selected values with one rounding. Then compute

```math
u=S(-R(t^2),z,1),\qquad
q=S(r_3,u,r_2),\qquad
q=S(q,u,r_1),\qquad
q=S(q,u,r_0),\qquad
t=R(tq),\qquad c=R(tz).
```

The following correction preserves the original split root and its residual.

```math
v=S(-R(t/2),c,1.5),\qquad
y=S(-t_{27},c,S(t_{27},c,c)),\qquad
w=S(v,c,y),\qquad
e=R\left(S(-y,y,z)/w\right).
```

Evaluate the same five-step $`f_i`$ recurrence at $`z`$, and multiply its result by $`z`$ to obtain $`p`$. Form $`b=R(pR(y+e))`$. Positive inputs return twice $`R(y+R(e+b))`$. Negative inputs return twice $`R(R(h-y)+R(R(\ell-e)-b))`$. Each doubling is an ordinary rounded sum of the result with itself. Exact inputs 1 and −1 return positive zero and the original rounded $`2h`$, respectively.

## Interface And Bounds

The AArch64 ABI takes the input and returns the result in `d0`. The routine has no caller-owned array. It checks the input words and FPCR before arithmetic. Unsupported values stop before a result is returned. It preserves `x19..x29`, the low 64 bits of `d8..d15`, the stack pointer and FPCR, and keeps its private stack aligned to 16 bytes. It calls only the uniquely named accepted integer rounding child. It does not replace global `acos` or call the original numerical body.

The native library uses the accepted child's basename and an absolute local runtime search path. This allows the same library to load when the forecast runs from another directory. Each caller must admit only supported cosine values and qualify its complete numerical and physical calculation.

## Actual Evidence

Before assembly emission, 9,630 original calls pass independent 160-digit inverse-projection checks over all nine source branches. Their complete return words cover 77,040 bytes. The largest observed error is 0.50254135 units in the last place, within the frozen limit of one. The checks also establish the half-circle range, the cosine projection and monotonicity. This is sampled accuracy evidence, not a global error bound.

The same corpus confirms the recorded original rounding graph before direct generation. Original source, source hashes, literal identities, inputs, controls and detailed results remain local under `.runtime/openifs/original_acos_7240564/`. Direct assembly passes the same 9,630 calls and 77,040 complete result bytes with zero differences in words, fresh FPSR or errno. An immediate unary ABI probe passes 30 calls and 240 bytes, including all preserved registers. Twenty-four sticky-status cases preserve the original flags and a nonzero errno. Eight unsupported input or FPCR cases stop as required. The machine code has no fused floating-point or approximate instructions. Three calls from another working directory pass 24 complete result bytes with the accepted child loaded through its absolute runtime search path. The private frame is 128 bytes and stays aligned to 16 bytes.

## Complete Direct Arithmetic Child

The [integer rounding contract](rounded_product_sum.md) defines the complete direct assembly child. Its one-rounding result is an explicit atomic math-helper operation and must not contract primary weather expressions. The shared inverse-cosine body and literal data retain the accepted arithmetic graph. Its internal child now binds the complete direct integer implementation of the same already qualified primitive. The accepted inverse-cosine source proof and the exact integer domain proof are reused. The inverse-sine compilation unit includes this body once to share its constants.

# Original-compatible inverse tangent

Revision 1. This support primitive returns the angle whose tangent is the dimensionless input $`x`$. The result is in radians. Its [direct AArch64 source](../../../../../src/openifs/support/atan_original_rounding.S) implements the complete finite-input route of the matched GNU libc 2.38 scalar `atan`.

```math
\operatorname{atan}(x)=\int_0^x\frac{1}{1+t^2}\,\mathrm{d}t,\qquad
\operatorname{atan}(-x)=-\operatorname{atan}(x).
```

For positive $`x`$, the reciprocal identity $`\operatorname{atan}(x)=\pi/2-\operatorname{atan}(1/x)`$ lets the method use small arguments. A short polynomial handles values near zero, and a table supplies local polynomials for the middle range.

## Frozen arithmetic

FP64 means the 64-bit floating-point format. Let $`R(a)`$ round a value once to FP64, using nearest with ties to even. Let $`S(a,b,c)=R(ab+c)`$ round the exact product and sum once. Each ordinary product, sum, subtraction and division below has its own $`R`$ step. The primitive uses `md2asm_round_product_sum_candidate` to calculate $`S`$ with integers. This accepted child reproduces the original math library's internal single-rounding steps without fused floating-point instructions. The weather solver's separately rounded arithmetic remains unchanged.

The constants and all 1,687 words in the 241-row, seven-column table match the retained original library exactly. A row stores its centre $`c_0`$, angle $`c_1`$ and five polynomial coefficients $`c_2`$ through $`c_6`$. The constants $`h`$ and $`\ell`$ are the original high and low parts of $`\pi/2`$. Coefficient values and complete table bits appear in the assembly.

The small polynomial and local table polynomial are evaluated in this exact order. Start with the highest coefficient, then follow the listed indices from left to right. Each step uses the result from the previous step.

```math
\begin{aligned}
p_{13}&=d_{13},&
p_k&=S(v,p_{k+2},d_k),&
k&=11,9,7,5,3,&P(v)&=p_3,\\
q_6&=c_6,&
q_k&=S(z,q_{k+1},c_k),&
k&=5,4,3,2,&Q(z)&=q_2.
\end{aligned}
```

For a table argument $`w`$, compute $`r=S(w,256,2^{52})`$, then $`i=\operatorname{int}(R(r-2^{52}))-16`$. This selects the nearest centre, using even ties. Both table branches prove $`0\le i\le240`$, so every seven-word row read stays within the immutable table.

Let $`u=\lvert x\rvert`$. The positive branch result below receives the original sign, except that the odd polynomial already uses signed $`x`$.

| Input range | Complete ordered route |
| --- | --- |
| $`u<a`$ | Return the original word. For subnormal $`u`$, first evaluate $`R(u^2)`$ to reproduce the original underflow status. Here $`a`$ has bits `3e4bb67a00000000`. |
| $`a\le u<1/16`$ | Compute $`v=R(x^2)`$, $`p=P(v)`$ and $`y=S(R(xv),p,x)`$. |
| $`1/16\le u<1`$ | Select the row from $`u`$, compute $`z=R(u-c_0)`$ and $`y=S(z,Q(z),c_1)`$. |
| $`1\le u<16`$ | Compute $`w=R(1/u)`$, $`t=R(wu)`$, $`q=S(w,u,-t)`$ and $`e_r=R(R(1-t)-q)`$. Select the row from $`w`$, then compute $`z=S(e_r,w,R(w-c_0))`$ and $`y=R(R(h-c_1)+S(-z,Q(z),\ell))`$. |
| $`16\le u<E`$ | Compute $`w=R(1/u)`$, $`v=R(w^2)`$, $`t=R(wu)`$, $`q=S(w,u,-t)`$, $`e_r=R(R(1-t)-q)`$, $`t_3=R(h-w)`$ and $`c=R(R(h-t_3)-w)`$. The result is $`y=R(t_3+S(-R(wv),P(v),S(-e_r,w,R(\ell+c))))`$. |
| $`u\ge E`$ | Return the original signed high part of $`\pi/2`$. Here $`E`$ has bits `43349ff200000000`. |

The source contains 28 static calls to the rounding child. The four polynomial branches use six, six, eight and eight calls respectively. There are no omitted stages, approximate divisions, reduced-precision calculations or global `atan` overrides.

## Scalar interface

`md2asm_atan_original_rounding(double x)` receives and returns FP64 in register `d0`, following the Arm application binary interface, which specifies function arguments and preserved registers. Its domain contains every finite FP64 input with floating-point control register FPCR equal to zero. This gives nearest rounding, gradual underflow and the required exception behaviour. Non-finite inputs or another FPCR value abort before the calculation.

The function preserves `x19` through `x29`, the low 64 bits of `d8` through `d15`, FPCR and the stack pointer. Its own 112-byte frame keeps the required 16-byte stack alignment. Scratch registers belong to the function, and no caller-owned buffers are read or written. The only data reads are the bounded immutable coefficients. Signed zeros remain exact. Canonical results include the returned 64-bit word, floating-point status register FPSR and the caller's error indicator `errno`.

## Actual checks and scope

The independent original gate passed before assembly emission. A 160-digit decimal calculation uses half-angle reduction, an alternating series and an independently calculated value of $`\pi`$. For extremely small inputs, the interval between $`x-x^3/3`$ and $`x`$ bounds the angle without loss of useful precision. The frozen 13,188-case corpus covers all six branches, neighbouring thresholds, every table-selection tie and its reciprocal, finite extremes, signed zeros, subnormals and representative weather operands.

The native gate returns zero differing bytes over 105,504 result bytes, with exact fresh FPSR and `errno` agreement on all 13,188 calls. The largest observed independent error is 0.502243 units in the last place, where one such unit is the spacing between nearby FP64 numbers. It remains within the frozen one-unit sampled limit. This sampled result does not establish a global correct-rounding bound.

The immediate scalar ABI passes 26 calls and 208 returned bytes with zero differences. Twelve cases preserve inherited FPSR and nonzero error state. Five unsupported-input or FPCR cases abort as required. The source revision, table identity and instruction inspection are retained locally. The unchanged integer rounding proof is reused. Weather callers still need their own physical, complete-byte and genuine forecast checks after linking this unique primitive.

## Source and generation

The LLM wrote the AArch64 instructions directly from the mathematical definition and frozen original rounding route, then built them with an assembler and linker. No compiler-generated assembly or intermediate representation supplies the implementation. The matching GNU libc source is commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`, retrieved through normal GitHub SSH into the ignored local archive.

The algorithm and coefficient literals derive from the IBM Accurate Math Library in GNU libc, copyright 2001–2023 Free Software Foundation, Inc. This component is distributed under the [GNU Lesser General Public License, version 2.1 or later](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html). It comes without warranty. The matching original files, licence notices, source hashes, independent proof, ordered rounding record and local build commands remain in `.runtime/openifs/original_atan_7240564/`.

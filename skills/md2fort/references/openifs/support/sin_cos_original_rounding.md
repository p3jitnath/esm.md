# Sine and cosine matching the original library

Revision 1. The [physical input](../../../../../formulations/openifs/support/periodic_angle_projections.md) defines direction projections. The [direct AArch64 source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/sin_cos_original_rounding.S) supplies private SIN and COS primitives that match the installed GNU libc 2.38 scalar functions.

## Supported angles

The input is a finite angle $`x`$ in radians with $`\lvert x\rvert\le2^{20}`$. This range contains more than 160,000 full turns and supports ordinary seasonal and solar phases, accumulated calendar angles and coarse spectral phases when each caller proves its own bound. The complete source route inside this range is included. A weather caller must keep its complete physical and output checks after using these helpers. No general finite-input claim or global SIN/COS replacement is made.

FP64 is the 64-bit floating-point format. Require the floating-point control register FPCR to be zero, which gives nearest rounding with ties to even and gradual underflow. Preserve signed zeros. A nonfinite argument, an argument outside the bound or another FPCR value aborts before numerical work.

## Frozen arithmetic

Let $`R(a)`$ round a value once to FP64. Let $`S(a,b,c)=R(ab+c)`$ round the exact product and sum once. Ordinary products, sums and differences each retain their own $`R`$ step. Only the original math primitive's internal single-rounding steps use the already accepted integer child `md2asm_round_product_sum_direct`. There are no fused floating-point instructions, approximate operations or reduced precision. This separate primitive boundary preserves the weather solver's ordinary rounding rules.

The original coefficient bits and all 440 words of the 110-row table match the installed library. Each row stores a sine value $`s_n`$, its small correction $`e_s`$, a cosine value $`c_n`$ and its correction $`e_c`$. The row centre is $`n/128`$ radians. The original constants $`h`$ and $`\ell`$ are the high and low parts of $`\pi/2`$. All literal bits remain in the assembly and retained source archive.

Write $`u=\lvert x\rvert`$. The direct-range threshold $`B`$ has bits `3feb600000000000`, and the complementary-range threshold $`C`$ has bits `400368fd00000000`.

| Input range | Complete SIN route | Complete COS route |
| --- | --- | --- |
| $`u<2^{-27}`$ | Return the original word; force the original underflow status with $`R(x^2)`$ for subnormal input. | Return positive one. |
| $`2^{-27}\le u<2^{-26}`$ | Return the original word. | Use the cosine table route. |
| $`2^{-26}\le u<B`$ | Use the Taylor route for $`u<0.126`$, then the sine table route. | Use the cosine table route. |
| $`B\le u<C`$ | Use the cosine route with $`R(h-u)`$ and $`\ell`$, then restore the input sign. | Set $`y=R(h-u)`$, $`a=R(y+\ell)`$, $`d=R(R(y-a)+\ell)`$ and use the sine route with $`a,d`$. |
| $`C\le u\le2^{20}`$ | Reduce the angle, choose sine or cosine from the quadrant, then apply its sign. | Use the same reduction with the next quadrant. |

For a sine argument split into high part $`a`$ and small correction $`d`$, the Taylor route first sets $`v=R(a^2)`$. It evaluates the original coefficients from highest order to lowest with four $`S`$ steps, producing $`P(v)`$. Then it returns $`R(a+S(v,S(P(v),a,-R(0.5d)),d))`$. The frozen coefficients are `s5` through `s1`.

The table routes select $`n`$ from the low 32 bits of $`R(2^{45}\times1.5+\lvert a\rvert)`$. This rounds the centre to multiples of $`1/128`$ with even ties. Every admitted route proves $`0\le n\le109`$, so all four-word reads remain within the immutable table. The sine route reverses $`d`$ when $`a\le0`$ and restores the original high-part sign at the end. The cosine route reverses $`d`$ only when $`a<0`$.

Let $`r`$ be the separately rounded difference between $`\lvert a\rvert`$ and the selected centre. Define $`v=R(r^2)`$, $`A=S(v,\mathrm{sn5},\mathrm{sn3})`$ and $`D=S(v,S(v,\mathrm{cs6},\mathrm{cs4}),\mathrm{cs2})`$. The sine table route follows these ordered steps:

```math
\begin{aligned}
p&=R(rv),&s&=R(r+S(p,A,d)),&c&=S(r,d,R(vD)),\\
k_1&=S(s,e_c,e_s),&k_2&=S(-c,s_n,k_1),&k_3&=S(c_n,s,k_2).
\end{aligned}
```

Return $`R(s_n+k_3)`$ with the original high-part sign. The cosine table route first includes the small correction in $`r`$ and recomputes $`v,A,D`$ from that value. It then sets $`s=S(R(rv),A,r)`$ and $`c=R(vD)`$. Its three correction steps are $`k_1=S(-s,e_s,e_c)`$, $`k_2=S(-c,c_n,k_1)`$ and $`k_3=S(-s,s_n,k_2)`$. Return $`R(c_n+k_3)`$.

Moderate reduction first sets $`t=S(x,\mathrm{hpinv},\mathrm{toint})`$ and $`q=R(t-\mathrm{toint})`$. The low two bits of $`t`$ select the quadrant. The remaining steps retain the original internal single-rounding route:

```math
\begin{aligned}
y_1&=S(-q,\mathrm{mp1},x),&y_2&=S(-q,\mathrm{mp2},y_1),\\
b&=S(-q,\mathrm{pp3},y_2),&e&=S(-q,\mathrm{pp3},R(y_2-b)),\\
a&=S(-q,\mathrm{pp4},b),&d&=R(e+S(-q,\mathrm{pp4},R(b-a))).
\end{aligned}
```

The resulting high and low parts enter the complete sine or cosine route. The declared angle bound lies below the source's large-reduction threshold, so its separate large-angle algorithm is outside this contract. The assembly has 28 static calls to the rounding child: seven for reduction, six for Taylor sine, eight for table sine and seven for table cosine.

## Scalar interface

`md2asm_sin_original_rounding(double x)` and `md2asm_cos_original_rounding(double x)` receive and return FP64 in `d0`. The Arm application binary interface, or ABI, defines these registers and the values that a function must preserve. Both entries preserve `x19` through `x29`, the low 64 bits of `d8` through `d15`, the stack pointer and FPCR. The 112-byte frame stays aligned to sixteen bytes. Neither entry reads or writes caller-owned buffers, and every constant read has a proved table bound.

Canonical results contain the returned 64-bit word, fresh floating-point status register FPSR and unchanged error indicator `errno`. Sticky status means that an incoming exception bit remains set; the helpers preserve it and add exactly the original primitive's new bits. No numeric flag is masked.

## Actual checks

The original scientific gate passed before direct emission. A 170-digit decimal check derives $`\pi`$ independently with the Machin formula, reduces angles by that value and evaluates alternating sine and cosine series. An alternating series adds terms with opposite signs; its first omitted term bounds the remaining error. For extremely small inputs, $`\lvert x\rvert^3/6`$ bounds the sine difference from $`x`$, and $`x^2/2`$ bounds the cosine difference from one. The check also verifies the unit circle, sine's odd symmetry and cosine's even symmetry.

The frozen corpus contains 32,332 signed angles and 64,664 scalar calls. It covers every supported source branch, all table-centre ties and neighbours, quadrant boundaries, cancellation near multiples of $`\pi/2`$, seasonal harmonics, coarse spectral phases, the domain endpoints, signed zeros and subnormals. There are 161,660 independent physical relations. The native comparison returns zero differing bytes over 517,312 result bytes, with exact fresh FPSR and `errno` on every call. Exact value, status and error-indicator comparisons are counted separately.

The largest observed errors are 0.508923 ULP for sine and 0.508538 ULP for cosine. One ULP is the gap between adjacent FP64 values. Both are below the frozen one-ULP sampled limit; this sampling does not establish a global correct-rounding bound. Seventy-two immediate ABI calls pass over 576 result bytes. Forty-four inherited-status and nonzero-errno cases pass, and sixteen unsupported-input or FPCR cases abort as required. The accepted integer child and unary ABI probe are reused. Instruction review finds no fused or approximate floating-point operation. No whole-forecast or timing result is claimed.

## Source and generation

The LLM emitted the AArch64 instructions directly from the physical definition, frozen rounding equations and literal coefficients, then used an assembler and linker. Compiler-generated assembly and intermediate representations do not supply the implementation. The matching source is GNU libc commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`, retrieved through normal GitHub SSH into a separate local sparse checkout.

The algorithm and literal coefficients derive from the IBM Accurate Math Library in GNU libc, copyright 2001–2023 Free Software Foundation, Inc. This component uses the [GNU Lesser General Public License, version 2.1 or later](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and comes without warranty. Original source, licence notices, hashes, complete rounding records, failures and actual build commands remain in `.runtime/openifs/original_sin_cos_7240564/`.

## Complete Direct Arithmetic Child

The [integer rounding contract](rounded_product_sum.md) defines the complete direct assembly child. Its one-rounding result is an explicit atomic math-helper operation and must not contract primary weather expressions. The direct integer child binding passes all 64664 retained sine and cosine results over 517312 bytes, with zero differing result bytes, status or errno. The original independent projection proof and immediate helper interface checks are reused.

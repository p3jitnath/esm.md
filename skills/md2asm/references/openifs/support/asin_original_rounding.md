# Original-Rounding Inverse Sine

This contract defines `md2asm_asin_original_rounding`. It converts a finite FP64 sine $`x\in[-1,1]`$ into an angle in radians, including signed zeros, subnormal inputs and exact endpoints. FP64 is the 64-bit floating-point format. The Arm floating-point control register, FPCR, must be zero, which selects nearest-even rounding and gradual underflow. The complete output is the 64-bit word in register `d0`. The floating-point status register, FPSR, and the error indicator, `errno`, follow the original valid-input route.

The [physical input](../../../../../formulations/openifs/support/inverse_sine_angle.md) gives the geometry. [Direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/asin_original_rounding.S) implements the complete declared domain. The numerical method comes from GNU libc 2.38 at commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`, with its IBM Accurate Mathematical Library polynomials and tables. This derived component uses LGPL-2.1-or-later.

## Rounded Calculation

Write $`R(v)`$ for rounding a real value $`v`$ to FP64 with ties to even, and $`S(a,b,c)=R(ab+c)`$ for an original internal single-rounding step. Each ordinary operation below has its own $`R`$. The accepted integer helper `md2asm_round_product_sum_direct` computes $`S`$ without a fused floating-point instruction. These steps are inside the mathematical primitive, preserving the caller's separate rounding points.

The coefficients, split half-circle constants $`h`$ and $`\ell`$, table $`T`$, inverse-root table and power-of-two table are the unchanged words in the [inverse-cosine contract](acos_original_rounding.md). The assembly includes that already qualified direct source to share its literal data. Let $`H`$ be the high 32 bits of $`\lvert x\rvert`$. Bit operations select the table interval without rounding the input.

For $`\lvert x\rvert<2^{-26}`$, return the input word. A nonzero subnormal input also performs the original discarded $`R(x^2)`$ operation to preserve underflow and inexact status. For $`2^{-26}\le\lvert x\rvert<1/8`$, form $`z=R(x^2)`$ and start with $`q=f_6`$. Apply the recurrence through indices 5, 4, 3, 2 and 1.

```math
q\leftarrow S(q,z,f_i),\qquad a=S(q,R(zx),x).
```

For $`1/8\le\lvert x\rvert<0.96875`$, use the same centre index $`n`$ and last coefficient $`L`$ as the inverse-cosine table. Set $`d=R(\lvert x\rvert-T[n])`$ and $`q=T[n+L]`$, then apply the recurrence for $`j=L-1,\ldots,2`$.

```math
q\leftarrow S(q,d,T[n+j]),\qquad
p=S(R(d^2),q,T[n+L+1]),\qquad
t=S(T[n+1],d,p),\qquad a=R(T[n+L+2]+t).
```

Apply the original input sign to $`a`$ with a bit-preserving sign change. For $`0.96875\le\lvert x\rvert<1`$, set $`z=R((1-\lvert x\rvert)/2)`$. The inverse-root tables supply $`t`$ at the same indices as the inverse-cosine contract. Compute the root correction as follows.

```math
u=S(-R(t^2),z,1),\qquad
q=S(r_3,u,r_2),\qquad q=S(q,u,r_1),\qquad q=S(q,u,r_0),\qquad
t=R(tq),\qquad c=R(tz),\qquad v=S(-R(t/2),c,1.5).
```

Split the root at $`b=2^{24}`$, preserving each rounding point.

```math
y=R(R(c+b)-b),\qquad
e=R\!\left(\frac{S(-y,y,z)}{S(v,c,y)}\right).
```

Evaluate the five-step $`f_i`$ recurrence at $`z`$ and multiply the result by $`z`$ to give $`p`$. The final positive angle is

```math
a=R\!\left(S(-y,2,h)+S(-R(2R(y+e)),p,S(-e,2,\ell))\right).
```

Apply the original sign to this angle. Exact inputs 1 and −1 return $`h`$ and $`-h`$, respectively.

## Interface And Acceptance

The AArch64 application binary interface, or ABI, passes the input and result in `d0`. The routine has no caller-owned buffer. It checks input words and FPCR before numerical work, preserves `x19..x29`, the low 64 bits of `d8..d15`, the stack pointer and FPCR, and keeps its 128-byte frame aligned to 16 bytes. It calls only the uniquely named accepted integer rounding child. It does not replace global `asin` or call the original numerical body. The included inverse-cosine body retains its unchanged unique name and tables.

Require zero differing return bytes, fresh FPSR and errno on the frozen input corpus. Independently check the sine projection, angle range, monotonicity and error within one unit in the last place, using 160-digit arithmetic. A unit in the last place is the spacing between neighbouring FP64 values. Tiny inputs also use an analytic bound on the omitted cubic correction. Accuracy observations are sampled evidence, not a global error bound. Check each new branch, threshold neighbour, signed zero, subnormal and endpoint through the reused immediate unary ABI probe, preserving caller sticky flags and nonzero errno. Reject invalid inputs and unsupported FPCR before returning. Load the integer child through its accepted basename and absolute local runtime search path.

## Actual Evidence

Before emission, 9,650 original calls pass the complete ordered graph and 40,623 independent relations using 160-digit angle geometry. The corpus includes all nine source branches and their threshold neighbours. The largest sampled error is 0.503021 units in the last place, within the one-unit limit. The unchanged literal identities and integer-rounding child proof are reused from inverse cosine.

The direct routine passes the same 9,650 calls and 77,200 complete result bytes with zero differences in output, fresh FPSR or errno. Thirty-six immediate ABI calls compare 288 bytes and preserve every required register. Thirty-two sticky-status cases and eight unsupported-input checks pass. Three calls from another working directory compare 24 bytes with the child loaded through its absolute runtime search path. The 24 static child-call sites contain no hardware fused or approximate floating-point instructions. The source, controls, failed initial endpoint case and accepted records remain local under `.runtime/openifs/original_asin_7240564/`. No weather forecast count or performance comparison is added by this dependency.

## Complete Direct Arithmetic Child

The [integer rounding contract](rounded_product_sum.md) defines the complete direct assembly child. Its one-rounding result is an explicit atomic math-helper operation and must not contract primary weather expressions. The direct integer child binding passes the retained 9650 original inverse-sine results over 77200 bytes, with unchanged status and errno. The original independent angle proof and immediate helper interface checks are reused.

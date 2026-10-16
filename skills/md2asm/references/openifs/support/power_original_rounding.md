# Original-Rounding Power

Implementation revision 2 implements [POW-01](../../../../../formulations/openifs/support/scalar_power.md) through the unique entry `md2asm_pow_original_rounding_candidate`. FP64 is the 64-bit floating-point format. The arguments are numerical values $`x`$ and $`y`$, and the result approximates $`x^y`$. Callers define physical units. This direct body preserves the frozen GLIBC 2.38 boundary at commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`, including its exact return word, cumulative arithmetic status and `errno`, the system error indicator.

The [parent](../../../../../src/openifs/support/power_original_rounding.S), [integer child](../../../../../src/openifs/support/power_integer_rounding.S) and [coefficient owners](../../../../../src/openifs/support/power_coefficient_tables.S) form one direct assembly implementation. The LLM emitted their instructions from the equations and frozen source dependency order. Compiler assembly and intermediate representations did not supply the body. The coefficient words retain the already rounded source bytes. GNU-derived algorithm and data retain the LGPL-2.1-or-later notice.

## Frozen Calculation

Let $`R(q)`$ mean one nearest-even rounding of $`q`$ to FP64. Ordinary products, sums, subtractions and divisions each retain their separate rounding. Let $`S(a,b,c)=R(ab+c)`$ mean one rounding of the exact product plus addend inside this mathematical boundary. Twenty source locations call the integer child for $`S`$; branches determine which locations run. The ordinary path executes nineteen calls. Primary weather arithmetic keeps its declared separate rounding points.

For a finite positive magnitude, integer bit operations write $`x=2^kz`$ exactly and choose one of 128 logarithm records. Each record contains a reciprocal centre $`v`$, its logarithm $`c`$ and a small logarithm remainder $`c_t`$. The original word offset is `0x3fe6955500000000`; extracting seven index bits gives a bounded index from 0 to 127. The constants $`L_h,L_l`$ split $`\ln(2)`$, and $`A_0,\ldots,A_6`$ are fixed polynomial coefficients. Evaluate the following dependencies in order.

```math
r=S(z,v,-1),\quad t_1=S(k,L_h,c),\quad t_2=R(t_1+r),
\ell_1=S(k,L_l,c_t),\quad \ell_2=R(R(t_1-t_2)+r),
a=R(A_0r),\quad a_2=R(ra),\quad a_3=R(ra_2),\quad H=R(t_2+a_2),
\ell_3=S(a,r,-a_2),\quad \ell_4=R(R(t_2-H)+a_2),
p_6=S(r,A_6,A_5),\quad p_4=S(r,A_4,A_3),\quad p_2=S(r,A_2,A_1),
u=S(a_2,p_6,p_4),\quad p=S(a_2,u,p_2),
w=R(R(R(\ell_1+\ell_2)+\ell_3)+\ell_4),\quad \ell=S(a_3,p,w),
L=R(H+\ell),\quad L_t=R(R(H-L)+\ell).
```

Here $`L+L_t`$ retains the small remainder of the logarithm. Form $`e_h=R(yL)`$ and $`e_l=S(y,L_t,S(y,L,-e_h))`$. The exponential reduction multiplies $`e_h`$ by the fixed inverse logarithm factor, then uses `FRINTA` and `FCVTAS` for the original nearest-integer index with ties away from zero. This index rule remains distinct from nearest-even FP64 arithmetic. With the rounded index $`d`$, the two negative logarithm constants $`n_h,n_l`$ and the selected exponential table remainder $`t`$, form

```math
r=R(S(d,n_l,S(d,n_h,e_h))+e_l),\quad r_2=R(rr),
p_{23}=S(r,C_3,C_2),\quad p_{45}=S(r,C_5,C_4),
b=S(r_2,p_{23},R(t+r)),\quad q=S(R(r_2r_2),p_{45},b).
```

The ordinary result is $`S(s,q,s)`$, where $`s`$ is the signed table scale. Large positive exponents adjust that scale by $`2^{-1009}`$, apply $`S`$, then multiply by $`2^{1009}`$. Small results first increase the scale by $`2^{1022}`$. Their correction preserves the original separate product and sum, retains a high part and remainder before scaling by $`2^{-1022}`$, fixes a rounded zero's sign, and executes the original explicit underflow operation. Tiny exponential arguments return the signed rounded value $`R(1+e_h)`$. The assembly retains all branch thresholds and operation order.

## Exact Integer Child

A finite FP64 input has the exact form $`(-1)^sM2^E`$. Its sign is $`s`$. For a normal number, the integer significand $`M`$ includes the implicit leading bit and $`E`$ is the stored exponent minus 1075. For a zero or subnormal number, $`M`$ is the stored fraction and $`E=-1074`$. The child forms the exact product and addend on the shared scale $`2^{-2148}`$.

Two arrays of 67 unsigned 64-bit words hold these exact magnitudes, with the lowest word first. Their 4288-bit capacity exceeds the required 4197-bit bound for every finite input and its possible sum. Equal signs select addition with carry between words. Different signs select magnitude comparison followed by subtraction with borrow. The result replaces the product array, so every read stays within the two complete arrays.

For a normal result, retain the highest 53 bits. For a subnormal result, shift by 1074 bits on the fixed integer scale. The first discarded bit locates halfway, while all lower bits distinguish a value above halfway. Round upward above halfway, or at halfway when the retained integer is odd. Exact cancellation returns positive zero. Two zero terms return negative zero only when both term signs are negative. A zero product with a nonzero addend returns that addend unchanged.

The child adds inexact to FPSR when discarded bits are nonzero. A tiny inexact value before rounding also adds underflow, including a value that rounds to the minimum normal number. Overflow adds overflow and inexact and returns the signed infinity. Incoming flags remain set, and `errno` stays unchanged. Nonfinite internal operands stop through `_exit(116)`. The fast and wide diagnostic counters retain the frozen operand classification; the [compact exact path](compact_product_sum.md) handles its proved subset before the unchanged bounded word calculation.

## Interface And Status

The AArch64 application binary interface passes the parent's operands in `d0` and `d1` and returns the result in `d0`. The child `md2asm_round_product_sum_candidate` takes `d0`, `d1` and `d2` and returns `d0`. Both require FPCR zero, which selects nearest-even arithmetic and gradual underflow. They preserve `x18`, `x19` through `x29`, the low 64 bits of `v8` through `v15`, and sixteen-byte stack alignment. The parent has a 256-byte frame; the child uses a 16-byte return-address frame for the compact call or a separate 1728-byte general frame. Neither receives a numerical buffer.

The read-only exponential owner `md2asm_original_pow_exp_data` contains 2160 bytes: fourteen header words and 256 table words. The logarithm owner `md2asm_original_pow_log_data` contains 4168 bytes: nine header words and 128 four-word records. Both start on a sixteen-byte boundary, and their seven-bit indices keep every load in bounds. Each exported diagnostic counter occupies one aligned eight-byte word. Diagnostic status-clear and status-read entries intentionally clear or read FPSR; numerical calls preserve cumulative status.

The parent retains the original branches for signed zeros, negative bases, integer exponents, infinities and NaNs, including the original signaling status and payload selection. Invalid finite powers set Linux `EDOM=33`; the original overflow, zero-underflow and division-by-zero routes set `ERANGE=34`. Their arithmetic sets the original flags before the C runtime `__errno_location` identifies the thread's error indicator. The runtime boundary preserves `x18`. The only other required service is `_exit`; the direct library has no C numerical fallback, libm or Fortran call.

## Actual Checks And Limits

The child passes 6846 retained exact-rational cases with zero differing result words or status values. The parent passes 8775 original result/status/`errno` comparisons and 1320 additional special-value and inherited-status cases. Both seeded register checks pass. The complete 6328 coefficient bytes agree. All 146652 unique operand/result/status records from 161841 recorded internal calls also pass exact-rational and original rounding checks.

Independent logarithm and exponential calculations at 110 and 220 decimal digits check 8726 positive-power inputs. The largest observed error is 0.501344 units in the last place, where one unit is the spacing between adjacent FP64 values near the result. This is a sampled result, without a global accuracy bound. A complete 25-step forecast also passes: all 685 final owners, containing 27,486,113 bytes, and all ten saved files, containing 618,140 bytes, have zero differing bytes. Canonical metadata, raw entry and return status, and the native ABI also agree. The loaded route uses the direct POWER owner with positive integer-child calls and no original C POWER mapping. This gate checks the complete final returned state and saved files; it does not add a raw state capture after every step. Independent physical evidence and the reference's declared lake-energy limitation remain unchanged. These earlier checks qualified the power route. The later compact-path contract records autonomous-forecast acceptance, and the README records matched complete-process timing.

The verification input includes two complete allocated owners whose unused tails were not initialized by the original setup. The six active bands remain exact: the sea-ice albedo owner retains its first 576 initialized bytes out of 1344, and RSUN retains its first 48 initialized bytes out of 112. Before the first native time-loop call, the observer asserts these active values and descriptors, then binds only the respective unused 768-byte and 64-byte input tails from the frozen original records. Complete before and after inputs are retained. Every final owner byte remains in the comparison; no returned output is repaired or normalized.

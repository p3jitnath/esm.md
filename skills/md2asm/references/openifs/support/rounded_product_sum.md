# Exact Integer Rounding Inside An Atomic Math Helper

Revision 5. The unique scalar entry is `md2asm_round_product_sum_direct(double a, double b, double c)`. Its mathematical result is one round-to-nearest, ties-to-even conversion of the exact value $`ab+c`$ to FP64, the 64-bit floating-point format. This has fused-result semantics inside the already qualified original math-helper contract. It must not replace the weather solver's separately rounded multiplication and addition. The inputs must be finite and the floating-point control register, FPCR, must be zero. A rounded overflow returns the correctly signed infinity and the original status flags.

## Exact Integer Calculation

An FP64 word has a sign, an eleven-bit exponent field $`e`$ and a fifty-two-bit stored fraction $`f`$. For a normal number, let $`M=2^{52}+f`$ and $`E=e-1075`$. For a zero or subnormal number, let $`M=f`$ and $`E=-1074`$. Its exact value is $`(-1)^sM2^E`$, where $`s`$ is the sign bit.

```math
ab+c=(-1)^{s_a+s_b}M_aM_b2^{E_a+E_b}+(-1)^{s_c}M_c2^{E_c}.
```

First try the [compact exact path](compact_product_sum.md), which stores each exact magnitude in two 64-bit integer words when proved operand bounds permit it. After compact refusal, try the [wide exact path](wide_product_sum.md). Each child refusal preserves the floating-point inputs and status. Remaining cases use the unchanged general calculation below.

Use the common exact scale $`2^{-2148}`$. Insert the 106-bit product and the 53-bit addend into separate unsigned arrays of 67 words, with 64 bits per word. The representation has 4,288 bits and covers the accepted complete finite-input domain. The lowest product exponent is -2148, and the largest product and sum require fewer than 4,197 bits. Each insertion writes only the addressed word and, for a nonzero within-word shift, its next word. Their complete ranges stay inside the 67-word arrays.

When the signs match, add corresponding words with a propagated carry. Otherwise compare the exact magnitudes from the highest word down, then subtract the smaller from the larger with a propagated borrow and retain the larger term's sign. Exact cancellation returns positive zero. When both terms are zero, return negative zero only if both the product sign and addend sign are negative. A zero product with a nonzero addend returns that addend unchanged.

Find the highest set bit $`h`$ in the exact unsigned sum. Its unbiased exponent is $`h-2148`$. For a normal result, retain the upper 53 bits by shifting right by $`h-52`$. For a subnormal result, shift right by 1,074 bits so that the lowest retained bit has value $`2^{-1074}`$. Examine the discarded guard bit and every lower bit. Round upward when the discarded value is above halfway, or is exactly halfway and the retained integer is odd. A carry out of the normal significand increases the exponent. Preserve the sign when the rounded result is zero.

The floating-point status register, FPSR, records numerical exceptions. Add the inexact flag to FPSR when any discarded bit is nonzero. For a tiny inexact result before rounding, also add underflow, including a result that rounds upward to the minimum normal value. For overflow, add both overflow and inexact. Preserve every inherited status bit and errno, the library error indicator. This reuses the accepted original Arm status contract and exact-rational domain proof from `.runtime/openifs/weather24h-original-power-assessment/diagnostic-contract.md` and `integer-rounding-critical.json`.

## Interface And Actual Checks

The Arm application binary interface receives $`a`$, $`b`$ and $`c`$ in d0, d1 and d2, and returns the FP64 word in d0. Both children need no frame. Each wrapper call saves the return address in 16 bytes and removes that frame before returning or entering the next path. The wrapper reuses its validated input words and exponent fields through the compact child’s hidden preclassified entry, as defined in that child’s ABI. Its original FPCR and finite-input checks remain before the call. The general 1,712-byte frame holds three complete 67-word arrays and saved registers, with 16-byte stack alignment. Preserve x18, x19 through x29, d8 through d15, the stack pointer, FPCR and errno. There are no caller-owned buffers. Its numerical calls reach only the two private direct assembly children. The assembly uses integer products, shifts, exact carry and borrow operations, integer word comparisons and bit copies. It updates FPSR only by adding the declared exception bits.

Within the general frame, scratch occupies bytes 96 through 1,703, counted from the stack pointer. Clear exactly 1,608 bytes with twenty-five 64-byte groups and an eight-byte tail. Caller-saved `v3` holds zero for these stores, while `d0` through `d2` remain intact during clearing. The saved-register region and final eight padding bytes stay outside the writes. The general arithmetic, fallback choice and frame size remain unchanged. The compact child adds status bits only when at least one is absent, as defined in its linked contract.

The original general body passes all 6,846 retained deterministic finite cases against the accepted C verification control and the original atomic primitive, with zero differing result bytes, status values or errno values. This covers 54,768 returned bytes. The previous independent exact-rational proof is reused. Nine immediate three-input ABI calls and eighteen inherited-status cases pass. Five non-finite or unsupported-FPCR cases reject before calculation. The C helper is retained solely as a verification control, and the direct calculation has no C numerical dependency.

The LLM wrote these instructions directly from the already accepted integer equations and domain proof. No compiler-generated assembly or intermediate representation supplied the body. The local stack and instruction details were recorded with the emitted direct body. These retained checks qualify the original atomic math rounding route. The compact path retains the critical and complete-forecast checks stated in its linked contract, preserving the same mathematical result and status. The linked compact and wide contracts record the accepted current routes and complete-forecast checks.

The [basic input](../../../../../formulations/openifs/support/rounded_product_sum.md) and [direct source](../../../../../src/openifs/support/rounded_product_sum.S) publish one shared scalar body. Link it once for every mathematical helper that uses this accepted internal operation.

The preclassified call retains every numerical instruction, frame bound and other caller. Its [focused checks and complete-forecast acceptance](compact_product_sum.md#accepted-checks) include exact results, inherited status, saved registers and the original domain refusals.

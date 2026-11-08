# Wide Atomic Product And Sum

Revision 3. The entry `md2asm_try_wide_product_sum` calculates $`\operatorname{RN}(ab+c)`$, where RN rounds the exact expression once to FP64, the 64-bit floating-point format, with ties to even. This is an internal atomic helper. It keeps the accepted mathematical helper's rounding point and must not replace the weather solver's separately rounded multiplication and addition. The [basic input](../../../../../formulations/openifs/support/rounded_product_sum.md) defines this operation.

## Bounded Exact Representation

Write the nonzero exact product as $`(-1)^{s_p}P2^{E_p}`$ and the nonzero addend as $`(-1)^{s_c}C2^{E_c}`$. The signs $`s_p`$ and $`s_c`$ are zero or one. The unsigned integers $`P`$ and $`C`$ need at most 106 and 53 bits. Let $`b_P`$ and $`b_C`$ be their bit lengths, meaning their numbers of binary digits, and $`E_0=\min(E_p,E_c)`$. The original wide class means

```math
\max\bigl(b_P+E_p-E_0,\ b_C+E_c-E_0\bigr)>127.
```

Use this original class without removing trailing zeros. A wide product has its leading bit at least 75 positions above the addend. A wide addend has its leading bit at least 22 positions above the product. Thus the wide term determines the result's sign, and exact cancellation is impossible in this path.

Let $`H=\max(E_p+b_P-1,E_c+b_C-1)`$ be that dominant leading-bit exponent. Choose the unit $`2^S`$ with $`S=H-126`$, making the dominant scaled magnitude an exact integer $`A`$ with leading bit 126. Right-shift the smaller raw integer to obtain its exact floor $`q`$ and a fraction $`f`$ with $`0\le f<1`$. Keep one flag $`j`$ that is one exactly when $`f>0`$. Two 64-bit words hold the integer calculation.

For equal signs, set $`N=A+q`$. For opposite signs, retain the floor with an explicit borrow.

```math
N=\begin{cases}
A-q,&j=0,\\
A-q-1,&j=1.
\end{cases}
```

The exact magnitude is $`(N+f')2^S`$, where $`0\le f'<1`$ and $`f'`$ is nonzero exactly when $`j=1`$. The result integer's highest bit $`h`$ is 125, 126 or 127. Retain its upper 53 bits by shifting right by $`h-52`$, which is 73, 74 or 75. The first removed bit is the guard. The logical OR of all lower integer bits and $`j`$ is the sticky value. Round upward when the guard is one and either the sticky value is nonzero or the retained integer is odd. This preserves exact ties and subtraction immediately below powers of two.

## Admission, Status And Interface

Require finite inputs and floating-point control register FPCR equal to zero. Both exact terms must be nonzero, and their original common-scale alignment must belong to the wide class. Admit only an exact magnitude at least $`2^{-1022}`$, the minimum normal FP64 value. Other inputs leave the floating-point arguments and status unchanged for the accepted general assembly. A subnormal value is a nonzero FP64 value whose magnitude is below this normal limit. The final exact magnitude controls admission, including a subnormal dominant addend lifted into the normal range by addition.

Set inexact exactly when a nonzero part is removed. A rounded overflow returns signed infinity and adds overflow plus inexact. Preserve every inherited bit of the floating-point status register, FPSR, as well as FPCR and errno, the library error indicator. Write FPSR only when at least one required bit is absent.

The Arm application binary interface, or ABI, receives $`a,b,c`$ in d0, d1 and d2. Success returns w0 equal to zero and the result in d0. Refusal returns w0 equal to one with d0, d1, d2 and FPSR unchanged. Only x0 through x17, integer condition flags and successful d0 are scratch. Preserve x18 through x30, d8 through d15, the stack pointer, FPCR and errno. The leaf has no buffer, memory access, frame, external call or floating-point arithmetic instruction. Each caller removes its temporary 16-byte saved-return frame before returning or starting its general body. A wide success increments the power caller's original wide counter once.

## Generation And Actual Checks

The LLM emitted the AArch64 integer instructions directly from these equations and their domain proof, then built the source with an assembler. No compiled high-level numerical body or compiler intermediate representation supplies this leaf. The compact child remains the first choice, followed by this wide child and the accepted general assembly. No original numerical fallback is introduced.

Both public caller routes pass 7,861 finite cases against the retained exact-rational and original atomic controls, with zero result, status, errno or FPCR differences. All 2,048 ABI calls, 10,240 inherited-status cases and 20 caller refusals pass. The new public prepared route also passes 9,191 raw-state and immediate-status observations against the original complete public wide entry, including 139 prepared tiny refusals. Independent mathematical evidence is reused. The changed controlled forecast passes the [complete 685-owner numerical comparison](compact_product_sum.md#accepted-checks). Separately, all nine ordinary comparison runs match ten canonical weather files and 59 final views outside the timer. These include three monitor-on milestone 14 runs, three monitor-off milestone 14 runs and three monitor-off public-handoff runs. The arithmetic comparison uses the two monitor-off variants under the same `EC_PMON=0` setting. The existing physical and process-boundary limits remain unchanged.

The selected controlled full forecast passes all 685 numerical owners, 560 descriptor relations and 27,486,113 raw bytes, with zero differences. All ten canonical files and the 59 matched final views pass, and the native ABI mask is zero. This uses the unchanged declared source-unused input revision. Inactive optional harness arguments and incoming process status remain visibly different, so this establishes numerical-state and file identity. The accepted physical checks and their stated limits remain unchanged. The [README](../../../../../README.md) reports the accepted matched complete-process measurements. The [direct source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/wide_product_sum.S) implements this contract.

## Private POWER Mask Return

The same source also builds the private status-return child with `MD2ASM_PRODUCT_SUM_DEFERRED_STATUS`. A successful private call returns its required exception mask in `w1` and leaves FPSR unchanged. Exact returns explicitly supply mask zero. All numerical instructions, admission rules and other interface obligations remain those of this contract. The complete private object is byte-for-byte identical to its accepted object. The [POWER parent contract](power_original_rounding.md#private-status-collection) keeps its existing mask collection, observation boundaries, fallback storage and accepted evidence.

## Prepared Entries

The hidden entries `md2asm_private_wide_deferred_prepared` and `md2asm_try_wide_product_sum_prepared` reuse the state from a tagged [compact refusal](compact_product_sum.md#prepared-wide-handoff). This immediate integer-only handoff has already checked finite inputs and FPCR zero and proved the original wide class. The private entry returns a required exception mask, while the public entry uses the existing immediate cumulative FPSR update. Both use the following exact register state.

| Register | Exact Value |
| --- | --- |
| `w1` | One for addend dominance, two for product dominance |
| `x12:x11` | Complete unsigned product, high word followed by low word |
| `x8` | Unsigned addend significand |
| `w13`, `w14` | Product and addend binary exponents |
| `w9`, `w10` | Product and addend signs, each zero or one |
| `w15` | Nonnegative difference between these exponents |
| `w16` | Dominant aligned integer's bit length |

Subtract `w15` from `w16` to recover the dominant raw bit length. Form the exclusive OR of the signs, reuse the existing addend swap when needed, then enter the unchanged normalisation and rounding body. Each prepared route returns the same result or tiny-result refusal as its matching complete entry. The public route commits the original FPSR union, while the private route returns its required mask. All saved-register, floating-input, status and stack obligations remain unchanged. Neither entry adds a buffer, external service or floating-point arithmetic instruction. The private object remains byte-for-byte identical.

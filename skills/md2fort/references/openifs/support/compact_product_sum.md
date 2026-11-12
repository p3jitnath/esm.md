# Compact Exact Product And Sum

Revision 7. This is a compact path for the [accepted atomic product and sum](rounded_product_sum.md). An atomic operation has one declared rounding point. It computes the exact real value $`ab+c`$, then rounds once to FP64, the eight-byte floating-point format, using round-to-nearest with ties to even. The weather solver retains its declared intermediate rounding points.

## Exact Integer Calculation

Write each finite input as $`x=(-1)^sM2^E`$, where $`s`$ is its sign, $`M`$ its nonnegative integer significand and $`E`$ its binary scale exponent. The parent contract gives the exact normal and subnormal decomposition. Each input significand needs at most 53 bits, and the exact product needs at most 106 bits.

```math
P=M_aM_b,\quad C=M_c,\quad E_p=E_a+E_b,
E_0=\begin{cases}E_p & C=0,\\ \min(E_p,E_c) & C\ne 0.\end{cases}
```

```math
P_0=P2^{E_p-E_0},\qquad C_0=C2^{E_c-E_0}.
```

When the addend is zero, set $`E_0=E_p`$ and keep the product without alignment. For two nonzero terms, check that each aligned magnitude uses at most 127 bits. Their sum is then less than $`2^{128}`$, so two 64-bit integer words hold every result bit. Keep the existing common scale without removing trailing zeros, preserving the original fast and wide call classifications.

For equal signs, add the magnitudes with carry into the high word. For opposite signs, subtract the smaller magnitude with borrow and retain the larger magnitude's sign. Exact cancellation returns positive zero. A zero product returns a nonzero addend unchanged. If both terms are zero, return negative zero only when both term signs are negative.

## Rounding And Status

Let $`h`$ be the index of the highest bit equal to one in the exact nonzero magnitude, counting from zero. The result exponent is $`E_0+h`$. For a nonzero product, the compact path rounds normal results. The general assembly handles a combined nonzero integer result below the minimum normal exponent −1022 before rounding, including underflow. The separate zero-product identity can return an exact subnormal addend unchanged.

Keep 53 significant bits, shifting left when the exact result uses fewer. Otherwise, the guard bit is the first discarded bit, and the sticky value records whether any lower discarded bit is nonzero. Increase the retained integer when guard is one and either sticky is nonzero or the retained integer is odd. A significand carry increases the exponent. An exponent above 1023 returns the correctly signed infinity with overflow and inexact status.

The floating-point status register, FPSR, records numerical exceptions. Discarded nonzero bits add inexact, bit value 16. Overflow adds overflow and inexact, combined value 20. Read FPSR and write its exact bitwise union with the required bits only when at least one required bit is absent. If all required bits are already set, return without writing the register. This preserves every inherited bit, including when only one of the two overflow-related bits is already set. Exact results and fallback leave FPSR unchanged.

## Assembly Interface

The application binary interface, or ABI, defines arguments and preserved registers. Entry `md2asm_try_compact_product_sum` accepts finite inputs with the floating-point control register FPCR equal to zero.

| Register Or State | Meaning |
| --- | --- |
| d0, d1, d2 on entry | FP64 inputs $`a`$, $`b`$ and $`c`$ |
| w0 equal to 0 on return | Success, with the exact rounded result in d0 |
| w0 equal to 1 on return | General path, with d0, d1, d2 and FPSR unchanged |
| x0 through x17 and condition flags | Scratch registers |
| x18 through x30, v8 through v15, SP and FPCR | Preserved registers and stack pointer |
| errno | Preserved library error indicator |

The hidden entry `md2asm_try_compact_product_sum_preclassified` reuses inputs that the direct wrapper has already checked. It requires FPCR zero, finite operands unchanged in `d0` through `d2`, their exact raw words in `x0` through `x2`, and their stored eleven-bit exponents in `x3` through `x5`. It begins after the public entry’s repeated checks and shares every numerical instruction and return rule. The direct wrapper keeps its original upfront refusals, and other callers keep the complete public entry.

The helper calls no function, creates no frame and reads no caller buffer. Both paths use authored integer assembly. Wrappers preserve their existing domain checks and remove their 16-byte return-address frame before the general arithmetic. Their bounded zero stores clear exactly 1,608 bytes in the [direct wrapper](rounded_product_sum.md) or 1,072 bytes in the [power child](power_original_rounding.md), using caller-saved `v3`; their general frames remain 1,712 and 1,728 bytes. The compact leaf does not use `v3`. The power child's compact success increments its original fast counter once. After compact refusal, the callers try the [wide exact path](wide_product_sum.md), then the general body, preserving the original classification.

## Accepted Checks

Both helper wrappers retain their accepted 7,860-case comparisons against independent exact fractions and the original atomic control, with zero differences in result bits, status, FPCR or errno. The unchanged status update also retains its 28,416 comparisons across all 128 combinations of the seven defined incoming FPSR bits. These checks cover signed zeros, subnormal inputs, word-crossing shifts, cancellation, ties and overflow.

The private entry changes only the direct wrapper's call target. Its focused checks give the following results.

| Check | Coverage | Result |
| --- | --- | --- |
| Exact results and status | 7,860 finite cases | No differences |
| Incoming status retained | 1,280 cases | No differences |
| Registers and stack | 9,140 seeded calls | ABI mask zero |
| Original domain refusal | 14 nonfinite or unsupported-FPCR calls | Same abort |

The changed [autonomous forecast](../input/standalone_weather_forecast.md) matches all 685 numerical owners, 560 descriptor relationships and 27,486,113 raw bytes. All ten saved files over 618,140 bytes and 59 controlled final-field views match exactly. The native ABI mask is zero, with natural FPCR, FPSR and errno of zero, 25 and zero. All nine ordinary runs in the frozen three-variant comparison also retain every saved file and 59 final views outside the timer. The arithmetic comparison uses the same supported `EC_PMON=0` setting for both implementations. Energy and power diagnostic columns become zero under that setting and remain outside canonical weather output. The [README](../../../../../README.md) reports the small complete-process result on this T21 case, with timing resolution and input scope. Known process-boundary differences and whole-forecast physical-budget limits remain unchanged. The independent physical evidence is reused, and performance on other forecast inputs remains unmeasured.

## Private POWER Mask Return

The same source also builds the private status-return child with `MD2ASM_PRODUCT_SUM_DEFERRED_STATUS`. A successful private call returns its required exception mask in `w1` and leaves FPSR unchanged. Exact returns explicitly supply mask zero. All numerical instructions, admission rules and other interface obligations remain those of this contract. The private build remains byte-identical to its accepted object; its status-return interface is unchanged. The [POWER parent contract](power_original_rounding.md#private-status-collection) defines mask collection, every observation boundary, fallback storage and the changed-path checks.

## Normal-Input Decoder

A finite stored exponent from 1 through 2046 identifies a normal nonzero input. Both the ordinary public helper and private POWER child use the same short decoder when all three exponents lie in that range. Setting significand bit 52 gives the same three integers as the complete decoder, so the path skips two impossible zero-factor checks and three zero-exponent corrections. This removes eight integer instructions before the unchanged exact multiplication.

If any exponent is zero, the complete decoder handles zeros and subnormal values. Repeating an earlier hidden-bit OR leaves the integer unchanged. Both routes reach the same signs, exponents, exact product and refusal state. Public FPCR and finite-input checks, all rounding and status rules, fast/wide classifications and preserved registers remain in force. The compiled private object remains identical to the accepted revision-5 object, so its existing complete POWER and prepared-handoff evidence is reused.

The retained decoder checks cover zeros, subnormal inputs, cancellation, ties, word-crossing shifts and overflow. The [current public checks](rounded_product_sum.md#interface-and-actual-checks) also cover the prepared handoff.

## Prepared Wide Handoff

On refusal, `w1=1` identifies an addend whose original aligned magnitude exceeds 127 bits, and `w1=2` identifies such a product. Other refusals return `w1=0`. Read a tag only when `w0=1`. The public interface permits changes to `w1` as scratch, while successful private `w1` remains its required exception mask. Both tagged routes retain the complete exact product, addend, signs, exponents and bit length for their [prepared wide entry](wide_product_sum.md#prepared-entries). They preserve floating inputs and hardware status. After its original domain checks, the direct wrapper sends tag zero to the general body because only compact-class tiny results can remain, including zero-addend cases. The full wide entry would refuse those cases without an observable status change. Public compact-success arithmetic and the deferred-status object remain unchanged. The focused public handoff checks and current forecast limit are recorded in the [direct wrapper contract](rounded_product_sum.md#interface-and-actual-checks).

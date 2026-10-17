# Compact Exact Product And Sum

Revision 5. This is a compact path for the [accepted atomic product and sum](rounded_product_sum.md). An atomic operation has one declared rounding point. It computes the exact real value $`ab+c`$, then rounds once to FP64, the eight-byte floating-point format, using round-to-nearest with ties to even. The weather solver retains its declared intermediate rounding points.

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

The combined [autonomous forecast](../input/standalone_weather_forecast.md) matches all 27,486,113 compared state bytes and all 618,140 saved-file bytes. Three matched ordinary pairs also retain all ten files and 59 observed final fields exactly, with checks outside timing. The [README](../../../../../README.md) reports their complete-process performance. The known process-boundary and physical-validation limits remain unchanged.

## Private POWER Mask Return

The same source also builds the private status-return child with `MD2ASM_PRODUCT_SUM_DEFERRED_STATUS`. A successful private call returns its required exception mask in `w1` and leaves FPSR unchanged. Exact returns explicitly supply mask zero. All numerical instructions, admission rules and other interface obligations remain those of this contract. The ordinary public build is byte-identical to its accepted object. The [POWER parent contract](power_original_rounding.md#private-status-collection) defines mask collection, every observation boundary, fallback storage and the changed-path checks.

## Private Normal-Input Decoder

For the private POWER child, a finite stored exponent from 1 through 2046 identifies a normal nonzero input. When all three exponents are in that range, setting significand bit 52 gives the same three integers as the full decoder. The child can then skip the two impossible zero-factor checks and the three zero-exponent corrections, reaching the unchanged exact multiplication with eight fewer integer instructions.

If any exponent is zero, the complete original decoder handles zeros and subnormal values. An earlier hidden-bit OR can safely run again because setting an already-set bit leaves the integer unchanged. Both routes reach the same exponent calculations, signs, exact product and prepared-wide state. Public entry instructions, rounding, status masks, classifications, counters and preserved registers remain unchanged.

The focused revision-5 checks pass 7,860 finite triples and 1,280 incoming-status cases, giving 9,140 complete atomic comparisons and ABI calls. They also pass 18,280 private-child comparisons, all 6,525 tagged handoffs and 139 prepared tiny-result refusals, plus 46 domain refusals. The complete POWER comparison passes 10,976 result/status/counter pairs and 468 seeded ABI calls. Every compared bit and immediate status value agrees. The changed complete forecast matches all 685 numerical owners, 560 descriptor relations and 27,486,113 raw bytes, ten saved files over 618,140 bytes and 59 final views. Native ABI mask is zero, with natural FPCR/FPSR/errno 0/25/0. Three matched ordinary pairs retain all files and final views outside timing. Their wall medians are 24.00 and 23.89 seconds, with overlapping ranges; all three use less user CPU time. The [README](../../../../../README.md) reports the complete-process comparison. The focused simple POWER workload has a small timing regression, retained in the local records. Known physical and process-boundary limits remain unchanged.

## Private Wide Handoff

On private refusal, `w1=1` identifies an addend whose original aligned magnitude exceeds 127 bits, and `w1=2` identifies such a product. Other private refusals return `w1=0`. These tags apply only when `w0=1`. Successful `w1` remains the required exception mask. The tags retain the complete exact product, addend, signs, exponents and bit length for the [prepared wide entry](wide_product_sum.md#private-prepared-entry). They preserve floating inputs and hardware status. The ordinary public object and its refusal interface remain unchanged.

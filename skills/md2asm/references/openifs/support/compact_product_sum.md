# Compact Exact Product And Sum

Revision 2. This is a compact path for the [accepted atomic product and sum](rounded_product_sum.md). An atomic operation has one declared rounding point. It computes the exact real value $`ab+c`$, then rounds once to FP64, the eight-byte floating-point format, using round-to-nearest with ties to even. The weather solver retains its declared intermediate rounding points.

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

The helper calls no function, creates no frame and reads no caller buffer. Both paths use authored integer assembly. Wrappers preserve their existing domain checks and remove their 16-byte return-address frame before the general arithmetic. Their bounded zero stores clear exactly 1,608 bytes in the [direct wrapper](rounded_product_sum.md) or 1,072 bytes in the [power child](power_original_rounding.md), using caller-saved `v3`; their general frames remain 1,712 and 1,728 bytes. The compact leaf does not use `v3`. The power child's compact success increments its original fast counter once; other calls retain their original classification.

## Accepted Component Checks

Each mathematical-helper route passes 6,846 retained cases and 102 new boundary cases against independent exact-rational arithmetic and the retained original atomic control. Result bits, numerical status, FPCR and errno match. Register preservation, inherited flags, signed zeros, alignment limits, word-crossing shifts, cancellation, rounding ties and overflow pass. The 222 register checks, 1,110 inherited-status checks and 20 domain refusals pass. The changed [autonomous forecast](../input/standalone_weather_forecast.md) also matches all 27,486,113 compared state bytes and all 618,140 saved-file bytes. The [README](../../../../../README.md) reports matched complete-process performance. The known process-boundary and physical-validation limits remain unchanged.

The changed status predicate also passes 111 interface cases with all 128 combinations of the seven defined incoming FPSR bits on both helper routes. All 28,416 result and status comparisons and 222 register checks pass, with zero changes to FPCR or errno. The combined autonomous forecast retains complete-state and saved-file agreement.

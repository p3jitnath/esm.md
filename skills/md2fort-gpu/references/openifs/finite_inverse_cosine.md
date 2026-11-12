# Finite Inverse Cosine on the GPU

Revision 2 defines the direct [PTX function](../../../../src/openifs/support/gpu/finite_inverse_cosine.ptx) that converts a cosine to an angle. Its input is a dimensionless FP64 value, meaning a number stored in 64 bits. Its result is an angle in radians. The supported interval is $`-1 \leq x \leq 1`$, including signed zeros, subnormal values and both endpoints.

The complete ordered calculations and table selection follow the [original inverse-cosine contract](../../../md2fort/references/openifs/support/acos_original_rounding.md). The selected CPU function is `md2asm_acos_original_rounding`. Revision 2 makes the tiny-input cutoff explicit as $`3 \times 2^{-56}`$, whose raw word is `0x3c88000000000000`. This word fixes the branch choice when prose approximations of the threshold would differ.

## Arithmetic and Tables

Each ordinary operation rounds separately to nearest with ties to even. A required product-plus-addend refinement uses the [exact integer product sum](finite_mathematical_functions.md), which rounds the exact combined value once. This retains the scalar mathematical function's declared arithmetic. Weather-model multiplications and additions retain their separate rounding points.

The function uses four numerical regions. Tiny inputs return the frozen high word of half pi. Small inputs use the original polynomial. Intermediate inputs use the original table intervals and coefficient order. Inputs near either endpoint use the frozen inverse-square-root refinement. Positive one returns positive zero, and negative one follows the original rounded endpoint calculation. Keep all branch ties, operand order, signed zeros and gradual underflow.

All coefficient and lookup words are immutable initialised GPU global data. Each lookup index stays inside its declared table row. No host calculation constructs numerical coefficients or supplies an omitted stage.

## Device Interface

`md2asm_gpu_acos_unit_interval` takes one raw 64-bit input word through a PTX parameter. It returns one eight-byte-aligned object with the following layout.

| Byte offset | Type | Meaning |
| --- | --- | --- |
| 0 | 64-bit word | Angle in radians |
| 8 | Unsigned 32-bit integer | Newly raised Arm floating-point flags |
| 12 | Unsigned 32-bit integer | Zero error-write event |
| 16 | Unsigned 64-bit integer | Actual FAST helper calls |
| 24 | Unsigned 64-bit integer | Actual WIDE helper calls |

FAST and WIDE are the two qualified exact-product-sum calculation routes. Their counts record actual calls and follow unsigned wrapping addition. The caller combines new flags with incoming flags using integer OR. A zero error event preserves `errno`, the C library error slot. The function changes no caller buffer, uses private temporary registers and parameter storage, and requires no shared storage or barrier. Its caller must admit the finite input interval before numerical writes.

## Accepted Scope

Complete result, flag, error and helper-count records match the selected CPU corpus. Inherited status, empty work, unsupported-input refusal and ordinary device storage also pass. Independent high-precision inverse-projection, range and monotonicity checks remain separate from exact agreement. The numerical-source review passes. These results qualify this mathematical component; each model caller still needs complete physical and forecast checks. Detailed evidence stays local under `.runtime/`.

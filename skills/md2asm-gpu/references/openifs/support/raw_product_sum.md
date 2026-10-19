# Exact Product and Sum on the GPU

Revision 1 preserves the raw Arm function `md2asm_round_product_sum_direct`. It takes finite 64-bit floating-point (FP64) values $`a`$, $`b`$ and $`c`$ and returns their product and sum with one rounding step. The product and the added value must have compatible physical units. The calculation is

```math
r = \operatorname{RN}(ab+c).
```

Here $`\operatorname{RN}`$ means round once to the nearest FP64 value, with ties to even. The [exact integer device function](../finite_mathematical_functions.md) forms the complete product and sum before rounding. It preserves signed zero, very small values and overflow. This is the original mathematical helper's rounding rule.

## Arm Interface

The [raw wrapper](../../../../../src/openifs/support/gpu/raw_product_sum_direct.S) receives the three values in `d0`, `d1` and `d2`, and returns the result in `d0`. The floating-point control register, FPCR, must be zero. Inputs that represent infinity or an undefined value, and other control modes, retain the original refusal. The wrapper preserves the required general registers, the platform register `x18`, the stack pointer and `errno`, the C library error indicator. Register `x9` and the integer condition flags remain permitted scratch. Each complete live vector register is retained across the inserted call. Its temporary frame is 1024 bytes and remains aligned to 16 bytes.

The [host transport](../../../../../src/openifs/support/gpu/raw_product_sum_cell_calls.S) passes the operand words to the [device entry](../../../../../src/openifs/support/gpu/raw_product_sum_cell.ptx) with mode 17. Assembly owns these records and calls the declared CUDA services. The numerical calculation runs on the GPU, with no CPU numerical fallback. The existing [CUDA runtime](../cuda_runtime.md) defines serial call and storage lifetimes.

## Device Records

All seven complete buffers are aligned to eight bytes and are disjoint. The first three input words contain the operands. The remaining words are initialised before use. The [call context](../gpu_call_context.md) defines the shared record fields.

| Buffer | Bytes | Purpose |
| --- | ---: | --- |
| Input | 72 | Nine operand and control words |
| Output | 32 | Result, condition, error event and two counts |
| Argument vector | 16 | Record and context addresses |
| Context | 64 | Status and record bounds |
| Call record | 64 | Input and output descriptions |
| Fast counter | 8 | Original public counter owner |
| Wide counter | 8 | Original public counter owner |

The output contains an eight-byte result, a four-byte zero condition, a four-byte zero error event and two eight-byte zero counts. The entry checks all three operands before writing outputs or status. It joins new numerical flags with incoming flags using integer OR, so an earlier flag remains set. It preserves `errno` and the original zero changes to the public counters. Counted private power services use their separate interfaces.

## Component Evidence

The raw GPU route matches the actual selected CPU provider for 7861 finite triples, with independent exact rational checks, plus 100 seeded-status calls and 50 register checks. Refusal, complete-buffer, ordinary-launch and graph checks pass. Two independent source reviews and final machine-instruction checks pass. These results qualify this mathematical component. Complete forecast agreement and performance require the combined forecast gate. Detailed inputs and records remain local.

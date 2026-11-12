# Radiation Log Domain Batch

The [radiation formulation](../../../../../formulations/openifs/radiation/radiation_grid_preparation.md) uses the natural logarithm of pressure divided by one pascal. This value has no units. The existing setup accepts values from 9.2 to 11.7, including both limits. The [PTX entry](../../../../../src/openifs/radiation/gpu/radiation_log_domain_batch.ptx) checks these same bounds for a complete input interval in one launch. It leaves every later radiation calculation unchanged.

## Interface

`md2asm_gpu_radcfg_log_domain_batch(saved_state, status_context)` takes two 64-bit device addresses. The caller owns an aligned 832-byte saved Arm register image, a separate 64-byte status buffer and a read-only array of binary64 input values. The register image requires 16-byte alignment. The other buffers require eight-byte alignment. All buffers must remain mapped and live until the launch completes, and the two writable buffers must be separate from the complete input array.

Launch one block of 256 threads with no dynamic shared memory. The input capacity is `P`, from 1 through 2048. The interval starts at the zero-based index `first` and stops before `end`, with `0 <= first < end <= P`. The original parent checks these dimensions before dispatch. The Arm floating-point control register, FPCR, must be zero.

| Register-Image Offset | Input or Output |
| --- | --- |
| 72 | Input array address, from `x9` |
| 80 | First index, from `x10`, then the original loop's final index |
| 184 | Complete input capacity, from `x23` |
| 208 | Exclusive end index, from `x26` |
| 256 and 264 | Low and high halves of vector register `q0` |
| 272 and 288 | Original binary64 lower and upper bounds |
| 768 and 776 | FPCR and floating-point status register FPSR |
| 784 | Integer condition flags, called NZCV |

The status buffer starts with a zero error word and revision one in its next four bytes. Unsupported dimensions, bounds, alignment or buffer relationships set the error word to one without changing the saved register image. A value outside the physical bounds follows the original rejection path through the returned condition flags and keeps the runtime error word zero.

## Ordered Result

Threads inspect separate values through their integer bit patterns. For positive finite binary64 values, unsigned bit order matches numerical order. A shared minimum selects the earliest rejected index. A NaN is a floating-point value that does not represent a number. The kernel identifies NaNs before applying the positive-value ordering.

On success, `x10` becomes `end`, the low half of `q0` receives the last checked value, its high half becomes zero, and NZCV becomes `0x60000000`. A rejected lower or upper value returns its original index and bits with NZCV `0x80000000` or `0x20000000`. A rejected NaN returns NZCV `0x30000000`.

FPSR keeps its incoming bits. It gains the invalid-operation bit only when the first rejected value is a signalling NaN. Later values contribute no status bits. Every other register-image byte stays unchanged. The checked assembly host bridge preserves all integer and vector registers, stack state, floating-point state and the thread-local error value, then applies the original rejection branches. The assembly CUDA service receives the saved-state pointer in `x1` and the status pointer in `x2`.

## Accepted Checks

The critical bank compares all 832 saved bytes against the original Arm comparison loop in 255 cases. It covers exact limits and neighbouring values, signed zeros, subnormal values, infinities, quiet and signalling NaNs, incoming flags, partial intervals and the maximum capacity. A second 255-case check passes through the production host bridge and compares every architectural register, the error value and buffer guards.

The complete radiation parent matches all 4,520,432 owner bytes and 93,792 canonical output bytes at the same addresses. Floating-point status, the error value, preserved registers and seven actual counters also match. The retained independent physics checks apply because the mathematical calculations are unchanged. Repeated quiet complete-parent measurements select this component. These checks establish component acceptance, and a complete combined GPU forecast remains pending.

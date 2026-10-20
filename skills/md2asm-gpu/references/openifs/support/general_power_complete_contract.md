# General Power on the GPU

This pure device function computes $`x^y`$ with the [original ordered power calculation](../../../../md2asm/references/openifs/support/power_original_rounding.md). FP64 is the 64-bit floating-point format. The caller supplies the base $`x`$, exponent $`y`$ and their physical meaning. The function supports every pair of FP64 bit patterns, including negative bases, signed zeros, infinities and NaNs. A NaN is a floating-point value that represents an undefined numerical result.

The [PTX source](../../../../../src/openifs/support/gpu/general_power_values.ptx) defines `md2asm_gpu_power_general_complete`. Both arguments are raw 64-bit words. The application binary interface, or ABI, returns one 32-byte record aligned to eight bytes.

| Byte offset | Size in bytes | Meaning |
| --- | --- | --- |
| 0 | 8 | Result bits |
| 8 | 4 | Newly raised Arm floating-point flags |
| 12 | 4 | Error-write event |
| 16 | 8 | FAST counter increment |
| 24 | 8 | WIDE counter increment |

The FAST and WIDE increments count the original short and general paths for rounding an exact product plus addend. The function owns no model buffers, global counters or thread-local error storage. Its parent adds the returned integer counts to the actual counter owners with unsigned 64-bit wrap. The parent combines flags and error events in original source order.

A zero error event preserves `errno`, the C library error indicator. Event 33 writes the original domain error, and event 34 writes the original range error. A negative finite base requires an integer exponent for a real result. The original operand classification, NaN priority, integer parity and signed-zero rules remain unchanged. Each rounded scaling and small-result correction retains the result sign at its original position.

The function requires the original zero Arm floating-point control register, or FPCR. It preserves nearest-even rounding, gradual underflow, separate rounding points and the declared exact product-and-sum boundaries. The [shared mathematical contract](../mathematical_support.md) defines the reused arithmetic helpers. The source retains its GNU LGPL-2.1-or-later copyright and licence notice.

Component checks passed exact values, flags, error events, actual counter increments, register obligations and independent real-power relations across retained inputs and new negative-base and special-value cases. These checks qualify this device function. The existing published host dispatch remains governed by its [positive-normal power contract](positive_normal_power_complete_contract.md). Complete-forecast agreement and a GPU forecast runtime remain pending.

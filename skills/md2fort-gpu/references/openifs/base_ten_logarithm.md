# Base-Ten Logarithm GPU Contract

Revision 1 preserves the original private base-ten logarithm for a finite, dimensionless input from two to the power −40 through 32, including both endpoints. The base-ten logarithm gives the power of ten that represents an input. The selected CPU reference is `md2asm_log10_original_rounding` in the accepted original logarithm library.

## Ordered Calculation

Use the equations and threshold ties in the [original logarithm contract](../../../md2fort/references/openifs/support/log10_original_rounding.md). The [direct PTX source](../../../../src/openifs/support/gpu/base_ten_logarithm.ptx) retains all 277 literal words and the complete ordered calculation. FP64 stores each number in 64 bits. Each ordinary operation rounds to the nearest FP64 number, with ties to even.

Split the input into an exact power of two and a value near one. The original exponent rule gives an integer from −39 through 5 and a normalized value that is at least one half and strictly less than two. Evaluate its natural logarithm through the original near-one polynomial or 128-row table. An exact normalized value of one returns positive zero. Retain the table index, lower and upper endpoint choices, and every ordered correction from the original contract.

The outer calculation converts that natural logarithm to base ten and adds the exponent contribution through the original high and low constants. Its private exact product sums round the product plus the addend once. Use the qualified integer [product-sum helper](finite_mathematical_functions.md) at those existing sites and retain its actual FAST or WIDE classification. These names identify its two arithmetic paths. Preserve separate model operations, signed zeros, gradual underflow and all rounded intermediate values.

## Function Interface

`md2asm_gpu_log10_soil` takes one raw 64-bit input word and returns an eight-byte-aligned object of 32 bytes. Each call owns its PTX argument and return storage, with no assumed native register assignment. The caller validates the input interval before numerical work. The function reads immutable constants and tables and does not write a caller buffer.

| Byte offset | Returned value |
| --- | --- |
| 0 | Result word, eight bytes |
| 8 | Newly raised arithmetic flags, four bytes |
| 12 | Error-write event, four bytes, always zero |
| 16 | Actual FAST calls, eight bytes |
| 24 | Actual WIDE calls, eight bytes |

The caller joins new flags with incoming flags by integer OR and adds the two call counts with unsigned wrapping. A zero error-write event preserves `errno`, the C error slot. The [common mathematical interface](mathematical_support.md) defines status flags and the frozen processor mode.

## Accepted Checks And Limits

Complete result, status and counter records match the selected CPU for the retained input corpus. The independent high-precision logarithm checks and focused source review pass. The checks also cover inherited flags, direct call contexts, empty work, invalid inputs before output writes, guarded buffers and ordinary device storage. The corpus wrapper uses the same block of 128 threads, complete domain scan and barrier as the bounded projection functions. New model callers need focused independent checks for their new arguments and complete physical and interface checks. This component result establishes neither a complete GPU forecast nor its runtime. Detailed records remain local under `.runtime/`.

# Small-Angle Sine And Cosine GPU Contract

Revision 1 preserves the selected CPU calculations for finite angles strictly between −2 and 2 radians. Sine and cosine give the two components of a direction vector. The CPU reference functions are `md2asm_sin_original_rounding` and `md2asm_cos_original_rounding`. This interval covers the current leaf-temperature and photosynthesis callers.

## Ordered Calculation

Use the equations, coefficient words, table entries and threshold ties in the [original sine and cosine contract](../../../md2asm/references/openifs/support/sin_cos_original_rounding.md). The [direct PTX source](../../../../src/openifs/support/gpu/small_angle_projections.ptx) keeps that complete calculation. FP64 stores each number in 64 bits. Each ordinary operation rounds once to the nearest FP64 number, with ties to even.

For very small angles, sine returns the input word and cosine returns positive one. Sine still evaluates the original squared input when needed to retain underflow and inexact status. Other inputs use the original polynomial or the nearest entry in the immutable table of 110 rows. Angles nearer a right angle use the original high and low parts of half pi, then the complementary projection. Preserve every sign choice, threshold endpoint and ordered correction.

The private library calculation uses an exact product sum that rounds a product plus an addend once. Use the qualified integer [product-sum helper](finite_mathematical_functions.md) at those existing sites and retain its actual FAST or WIDE classification. These names identify its two arithmetic paths. Keep model expressions separate. Preserve signed zeros, gradual underflow and the original rounded intermediate values.

## Function Interface

Each function takes one raw 64-bit input word and returns an eight-byte-aligned object of 32 bytes. Each call owns its PTX argument and return storage, with no assumed native register assignment. The caller validates the input interval before numerical work.

| Function | Input interval in radians |
| --- | --- |
| `md2asm_gpu_sin_small_finite` | Finite angle strictly between −2 and 2 |
| `md2asm_gpu_cos_small_finite` | Finite angle strictly between −2 and 2 |
| `md2asm_gpu_cos_small_nonnegative` | Zero through rounded pi divided by three, word `3ff0c152382d7365` |

| Byte offset | Returned value |
| --- | --- |
| 0 | Result word, eight bytes |
| 8 | Newly raised arithmetic flags, four bytes |
| 12 | Error-write event, four bytes, always zero |
| 16 | Actual FAST calls, eight bytes |
| 24 | Actual WIDE calls, eight bytes |

The caller joins new flags with incoming flags by integer OR and adds the two call counts with unsigned wrapping. A zero error-write event preserves `errno`, the C error slot. The functions read immutable coefficients and tables and do not write a caller buffer. The [common mathematical interface](mathematical_support.md) defines status flags and the frozen processor mode.

## Accepted Checks And Limits

Complete result, status and counter records match the selected CPU for the retained input corpus. The independent high-precision projection checks and focused source review pass. The checks also cover inherited flags, direct call contexts, empty work, invalid inputs before output writes, guarded buffers and ordinary device storage. The corpus wrapper uses one block of 128 threads, a complete domain scan, a barrier, and independent outputs. Each model caller still needs its own physical and interface checks. This component result establishes neither a complete GPU forecast nor its runtime. Detailed records remain local under `.runtime/`.

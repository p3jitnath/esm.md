# Complete positive normal power GPU phase

The public function `md2asm_pow_original_rounding_candidate` returns the source-rounded power of the base in `d0` and exponent in `d1`, with its result in `d0`. FP64 means the 64-bit floating-point format. This one-call route accepts a positive normal base and a finite exponent whose magnitude is at least two raised to minus 65 and less than two raised to 63. A normal positive base ranges from two raised to minus 1022 through the largest finite FP64 value. The caller supplies the physical units and valid real-power inputs.

Integer bit tests select exactly the original direct-logarithm route. Every other input branches to the complete original GPU implementation before a new service or status check. The original direct returns of one remain unchanged, including a zero exponent with a finite base and base one with a tiny or huge finite exponent. Base one with an admitted exponent remains in the counted direct-logarithm route.

The [host source](../../../../../src/openifs/support/gpu/power_original_rounding.S) keeps the entire original route through one reversible private symbol rename and adds its dispatch and private phase in the same object. The [device entry](../../../../../src/openifs/support/gpu/positive_normal_power_entry.ptx) calls the unchanged [nonnegative-base power child](nonnegative_base_power.md) once. Its 791 constant words, ordered arithmetic, separate rounding points and exact product-and-sum boundaries retain the [original numerical contract](../../../../md2fort/references/openifs/support/power_original_rounding.md). There is no new mathematical body or approximation.

The application binary interface, or ABI, keeps the declared Arm registers and incoming status. The private host phase uses a 1,024-byte frame aligned to 16 bytes, saves complete vector registers and `x18`, and returns only the declared result in `d0`. It requires the original zero floating-point control register, or FPCR, and preserves the inherited refusal inside an active OpenMP parallel region. The floating-point status register, or FPSR, keeps all incoming bits and gains the actual new source flags.

| Private owner | Frame byte offset | Complete bytes |
| --- | --- | --- |
| Base bits, exponent bits and result address | 832 | 24 |
| Complete child result | 864 | 32 |
| Common context | 896 | 64 |
| Capacity record | 960 | 32 |

Each owner is aligned to eight bytes and is disjoint from the others. The host zeros the entire private span from byte 832 through byte 1023. The device admits one block, one thread, no dynamic shared memory, context revision one and zero control bits. Before output writes it checks complete capacities, safe pointer ends, all six owner pairs, reserved words and the same live operand domain. Refusals change only a valid context error word. Codes 28600, 28601 and 28602 identify shape or context, owner bounds, and reserved fields or input domain.

The pure child returns 32 bytes: result bits at byte zero, new flags at eight, an actual errno-write event at 12, and unsigned 64-bit FAST and WIDE totals at 16 and 24. These totals count the original exact product-and-sum classes. The entry writes the whole result, joins context flags and records a nonzero error event at source position one. A zero event preserves the incoming context event.

The host adds the returned FAST and WIDE totals once to the actual existing counter owners, with unsigned 64-bit wrap. A zero event preserves errno, the C library error indicator. The admitted range-error event writes 34 even when the incoming value is already 34. The host restores FPCR and its saved integer condition flags, joins FPSR, and preserves required registers. No duplicate pure provider, exact-product-sum provider or counter owner is added.

Component acceptance used 53 retained inputs in 161 seeded transport calls and 10 source refusal or original no-service controls. Values, immediate ABI and x18, FPCR, FPSR, errno, actual counters and wrap all matched. Forty-three device controls compared each entire 8,192-byte owner image, including all six overlap pairs and source-order context events. Independent source review passed, and focused native inspection found one pure-power call and no new floating-point arithmetic outside the unchanged child. Existing independent mathematical checks and retained arithmetic records were reused without a CPU oracle or unchanged pure-body replay. These component checks do not establish complete-forecast agreement or a forecast speedup.

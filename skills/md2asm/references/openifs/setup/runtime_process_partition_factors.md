# Runtime Process Partition Factors

A process is one running copy of the model. MPI lets these copies exchange data, while OpenMP lets threads share work within each copy. This child chooses how the processes divide grid points and spectral coefficients, which describe fields as waves. It implements the scalar-system, zero-explicit-factor route in SUMPINI sections 4.1 and 4.4. The process and thread counts are live inputs, so a different allocation uses the same assembled child.

`int md2asm_derive_runtime_process_partitions(world,threads,spectral_minimum,out32,capacity)` uses w0, w1, w2, x3 and x4. The first three arguments are signed 32-bit integers with no physical units. World is zero through 65,536, threads is one through 65,536, and spectral minimum is zero through 1,000,000. Source world zero becomes one. Source minimum zero becomes the effective world count. The mapped output needs 32 bytes, eight-byte alignment, a nonzero base, a nonwrapping address range and capacity of at least 32 bytes. The caller provides the mapped storage.

The eight output int32 words are NPROC, NPRGPNS, NPRGPEW, NPRTRW, NPRTRV, NPRTRNS, NPRTRN and effective NSPECRESMIN. The first word is the effective world count. The next two divide the grid into north-south and east-west process groups. The following two divide the spectral transform into wave and vertical groups. NPRTRNS equals NPRTRW, while NPRTRN equals NPRTRV. Each factor pair has product NPROC.

Grid selection takes the original FP64 square root, converts it to an integer and finds the first exact divisor at or above that value. Transform selection scans vertical factors from four in the original order. It uses integer division, divisibility, the spectral minimum and the thread-dependent threshold before the source square-root fallback. Keep these separate factor pairs. Replacing this rule with a fixed layout or another square-root calculation can change the selected map or floating-point flags.

| World | Threads | Spectral minimum | Grid groups | Transform groups |
| --- | --- | --- | --- | --- |
| 768 | 1 | 1280 | 32 × 24 | 192 × 4 |
| 768 | 6 | 1280 | 32 × 24 | 96 × 8 |
| 768 | 12 | 1280 | 32 × 24 | 48 × 16 |
| 768 | 6 | 0, defaulting to 768 | 32 × 24 | 64 × 12 |

These examples are consequences of the source rule, rather than dispatch constants. The supported input route has no explicit grid or transform factor overrides. A fallback wave factor above the effective minimum returns two before output mutation, representing an unsupported source configuration. The original routine terminates for this condition, while the checked child reports it to its caller.

Return zero commits all eight words after successful selection. Return two preserves the complete output for an invalid domain, span, capacity or unsupported source factor. The floating-point control register FPCR must be zero and is checked before arithmetic. Source-reached square roots retain their natural status flags. Domain and span refusals before arithmetic preserve those flags. The entry preserves FPCR, errno, x18, all Arm saved registers, the return address, stack and sixteen-byte stack alignment. The application binary interface (ABI) is this register and memory agreement. The 380-byte child has no private frame, call, allocation or external numerical provider.

One small gate passed 13 selected-source/native pairs and seven native critical refusals, for 33 calls. Twelve source-domain cases succeeded, and one unsupported minimum preserved the output in both checked interfaces. Cases cover source defaults, worlds below four, prime and composite counts, the maximum bounds and three thread-sensitive 768-process layouts. A local verification-only Fortran helper copied the selected source statements with explicit int32 and FP64 values. It did not compile or call the original OpenIFS program or routine. The original main executable stayed unchanged.

Complete output bytes, immediate ABI and arithmetic status, surrounding metadata, refusal preservation and file-descriptor counts passed. All 99 raw records total 10,032 bytes. Independent integer checks verified both factor products, the first grid divisor, aliases and the stated thread-sensitive layouts. The protected mapping was released and the bounded child process exited normally. This qualifies process metadata only. The namelist parser, public MPI and transform setup, runtime region payloads, complete distributed parent and forecast remain separate requirements. No physical-model or performance result follows from this component check.

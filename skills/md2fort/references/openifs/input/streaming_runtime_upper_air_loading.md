# Streaming Runtime Upper-air Initial Loading

This direct assembly loader reads the seven existing upper-air field families in their original order. It decodes one global record into a reusable buffer and copies this process's points into private local storage. It publishes the local result only after every record, grid label and end-of-file check succeeds. The existing [runtime reader](runtime_initial_upper_air_field_reader.md) and [placement contract](runtime_partitioned_upper_air_placement.md) define the unchanged field units, identities and ordering.

## Interface And Bounds

The public entry is `md2asm_load_streaming_runtime_upper_air_state(path, shape, output, output_capacity, headers, header_capacity)`. Arguments use registers x0 through x5. Register w0 returns the result code. The path is a readable operating-system filename that ends with a zero byte. The shape uses the existing 64-byte runtime record.

| Byte offset | Stored value |
| --- | --- |
| 0 | Local point count Q |
| 8 | Address of the int32 point map |
| 16 | Map size in bytes |
| 24 | Local block count B |
| 32 | Block width P |
| 40 | Atmospheric layer count L |
| 48 | Global point count N |
| 56 | Field count, which must be nine |

The map gives the global cell number for each local point. Its indices start at one. Require positive Q and N, with Q no greater than N and both no greater than the largest signed 32-bit integer. Require P from one through 1,024 and L from one through 256. The block count is $`B=\lceil Q/P\rceil`$ and the map occupies $`4Q`$ bytes. Every map entry must lie from one through N. These counts and indices have no units. The producer establishes the local point selection and distributed coverage.

The shape, headers and output have eight-byte alignment. The map has four-byte alignment. All consumed memory ranges must exist and must not wrap around the address space. Output must be separate from the shape, map and consumed header bytes. The accepted header must have the same L and N as the shape and must obey the runtime reader's complete row-list bounds. The path may overlap output because file opening consumes the path before public output changes.

## Storage And Update

Output has shape $`P\times L\times9\times B`$, with the first dimension stored consecutively. It needs $`72PLB`$ bytes because each 64-bit floating-point value occupies eight bytes. The input parameters 133, 203, 75, 76, 246, 247 and 248 map to output field slots 0, 6, 4, 3, 1, 2 and 5. Field slots start at zero. The two diagnostic slots 7 and 8 become positive zero over every row, including padding in the last block. In the other seven slots, placement changes physical points only and retains every incoming padding bit.

The parent checks the shape, complete map, capacities and overlap before allocation or file access. It allocates one temporary buffer of $`8N+72PLB+280L+80`$ bytes. This contains one global record, a copy of the complete local output, all record labels, a private shape and a completed-record count. Each accepted decoded record updates this private local copy. After successful end-of-file validation, the parent zeros the two diagnostic slots and copies the complete local result to public output. Every failure leaves the whole public output unchanged. The temporary is released once.

The private reader retains the accepted identity schema, public ecCodes calls, date and time checks, complete Gaussian row checks, handle cleanup and file cleanup. It reuses the same global value row and copies an accepted record before advancing its completed count. The existing whole-file reader remains unchanged. Placement uses integer loads and stores to preserve each raw 64-bit value, including its source units. No floating-point calculation is added.

Return code 0 means success. Code 1 rejects arguments or floating-point mode. Code 2 reports allocation failure. Input failure returns 16 plus the existing reader code, preserving its first-error order. These codes cover open failure, codec failure, identity or end-of-file mismatch, and close failure as defined in the reader contract.

The parent uses a 256-byte stack frame. The existing reader uses nested frames of 57,648, 256 and 20,624 bytes, so their total with the parent is 78,784 bytes. Public codec workspace is additional. The application binary interface, or ABI, defines argument registers, saved registers and stack alignment. Preserve x18, all required saved registers and 16-byte stack alignment. FPCR controls floating-point modes and must be zero at entry. FPSR records numerical exceptions. Preserve FPCR, FPSR and the incoming C library error indicator errno. Only libc and the accepted public ecCodes interface provide services. No original OpenIFS routine, global constructor or captured numerical state supplies a production stage.

## Checked Scope

Twelve complete loader calls pass the focused check. A genuine reduced Gaussian file has 24 points and two layers, with seven selected points in width-five blocks and two active points in the last block. A genuine regular Gaussian file has 64 points and three layers, with 25 selected points in width-24 blocks and one final active point. Both complete outputs match the existing accepted whole-file decoder and placement control across 11,808 bytes, with both guards unchanged. The control uses independently retained decoded values and labels from the accepted codec traversal. Existing codec and physical checks remain applicable because this change adds no physical calculation.

The native ABI violation mask is zero for every call. Incoming FPCR, FPSR and errno are preserved, including refusal with a different rounding mode. Complete-map and capacity refusals access no file or allocation. Allocation failure preserves output. A truncated file and a wrong complete row list preserve the complete incoming output while closing each held file and codec handle and freeing the one temporary. The requested allocation equals the formula above.

The process had a 2 GiB address-space limit and a 30-second timeout. The operating system reported zero for peak resident memory, so this check makes no measured peak-memory claim. It is a correctness check and supplies no benchmark result.

The production shared library needs only public ecCodes and libc. Verification links the same two direct assembly objects with forward-only resource counters and the existing native ABI probe. Its accepted placement control stays separate from production. Publishing the sources changes only their contract comments. Both assembled objects and the complete shared library remain byte-for-byte identical to the checked versions.

The larger operational input, 768-process layout, six-thread forecast, complete model startup and saved forecast outputs remain separate acceptance work. These small input checks do not establish that wider result. Exact sources, commands, controls and results remain in the local runtime folder.

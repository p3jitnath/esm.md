# Owned Operational Grid-Point Field Context

This utility owns the outer `TGFL` record and its four operational numerical arrays. `TGFL` stores transported model quantities at grid points. The caller supplies a complete field namespace, which describes the fields. This utility borrows that namespace and does not construct it. The accepted [raw storage layer](operational_grid_point_field_storage.md) supplies allocation and release. No zero stage, file loading, padding preparation or forecast runs here.

## Interface and storage

The application binary interface (ABI) defines arguments, saved registers and stack use. The constructor is `int md2asm_create_operational_gridpoint_field_context(cfg7, namespace, output)`. Registers x0, x1 and x2 carry its arguments, and w0 returns status. The controls contain seven signed 32-bit words: 17, 137, 388217, 9, 3, 0 and 0. They give positions per block, atmospheric layers, blocks, main fields, physics fields, tendency fields and companion fields.

The controls occupy 28 read-only bytes. The opaque namespace occupies 1,359,136 read-only bytes, and the output-pointer slot occupies eight writable bytes. The caller must provide complete mapped, nonwrapping and mutually disjoint spans. Controls need four-byte alignment; the namespace and output need eight-byte alignment. These span conditions are caller obligations. The namespace must remain live until the context is released. The constructor only stores its borrowed address, without reading its contents.

The context contains the complete 1,096-byte source-compatible record and eight private bytes. It owns the following allocations, whose first dimension changes fastest. Each value occupies eight bytes.

| Owner | Shape | Logical bytes |
| --- | --- | --- |
| `GFL` | 17 × 137 × 9 × 388,217 | 65,099,332,296 |
| `GFLSLP` | 17 × 137 × 3 × 388,217 | 21,699,777,432 |
| `GFLPT` | 17 × 137 × 0 × 388,217 | 0 |
| `GFLPC` | 17 × 137 × 0 × 388,217 | 0 |

Each empty owner has the accepted nonnull one-byte reservation. With the outer context, the five allocations occupy 86,799,110,834 bytes before allocator overhead. Production preserves every incoming numerical allocation byte. Array descriptions retain the source bounds, strides, address origins and type words. Unused descriptions remain zero.

## Construction, release and errors

Allocate the outer context and clear exactly its first 1,096 bytes. Call the accepted operational raw allocator with the explicit controls and borrowed namespace. The raw child stores the namespace address at byte 1088. After complete success, write the private ownership marker `0x5447464c43545831` at byte 1096 and publish the context pointer. No failed path changes the caller's output-pointer slot.

Call `int md2asm_release_operational_gridpoint_field_context(context)` with the returned pointer in x0. It validates the ownership marker, releases the four numerical owners, clears the marker and frees the outer context. It does not free the borrowed namespace. The caller must discard the released context pointer.

Return zero means success. Return one means an allocation failed after all acquired storage was released. Return two rejects an unsupported tuple, null or misaligned argument, invalid ownership marker, or unsupported creation mode. Creation requires the floating-point control register, FPCR, to be zero. Both entries preserve FPCR, the floating-point status register FPSR, the C error indicator errno, x18 and all required saved integer and vector registers. Creation uses a 96-byte stack frame and release uses 80 bytes; both retain 16-byte stack alignment.

## Completed checks and limits

Two complete profiles preserve all 173,598,219,460 numerical-owner bytes from the allocation patterns already qualified against the original source. They compare 4,416 complete context bytes across construction and release, 2,718,272 borrowed namespace bytes and 104 independent descriptor relations. Expected context bytes come from the declared outer-record zeroing and the accepted original descriptor writes. Only the four numerical addresses and borrowed namespace address use explicit pointer correspondences; no other returned byte is masked or supplied by the candidate.

Seven native ABI and status calls pass: two constructors, two releases, the first outer allocation failure, the first raw-child allocation failure and a wrong-level refusal. All ABI masks are zero. Output sentinels and 352 heap-guard bytes remain intact, and every acquired allocation is released once. FPCR remains zero, FPSR preserves its incoming zero or 24, and errno remains 777. The complete native process has no original OpenIFS or Fortran library mapped.

The earlier complete original raw-storage comparisons and independent layout checks are reused. No original process or old test bank is repeated. The actual source namespace is an opaque frozen verification input; this check does not qualify a newly executed namespace producer. The old coarse context source is unchanged, with a complete inverse for the separate operational entry. Complete model ownership, loading and operational forecast acceptance remain outside this utility.

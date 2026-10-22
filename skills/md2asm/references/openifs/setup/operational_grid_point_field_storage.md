# Operational Grid-Point Field Storage

A grid-point field stores values at horizontal positions in the model. This raw assembly layer allocates the selected field arrays for 137 atmospheric layers. It implements the four `TGFL` allocations from `SUSC2C`, the separate `ZERO_YOMGFL` zero stage and the corresponding `DEALXMO` releases. It does not construct their sibling storage layers or the complete model.

The new entry `md2asm_initialize_operational_gridpoint_field` receives a fresh, zero-filled 1,096-byte record in x0, seven read-only 32-bit integers in x1 and a borrowed 1,359,136-byte grid-field configuration in x2. Records have eight-byte alignment and the integer array has four-byte alignment. Complete spans must be mapped, must not wrap and must be disjoint. The borrowed configuration must outlive this record. The allocator stores its address without reading its field contents.

| Control | Required value | Meaning |
| --- | --- | --- |
| `NPROMA` | 17 | Positions in one storage block |
| Layers | 137 | Atmospheric layers |
| Blocks | 388,217 | Complete storage blocks |
| `NDIM` | 9 | Main field count |
| `NDIMSLP` | 3 | Selected physics field count |
| `NDIMPT` | 0 | Empty tendency field count |
| `NDIMPC` | 0 | Empty companion field count |

This tuple gives 6,599,689 stored horizontal positions for 6,599,680 physical grid points. The final block includes nine padding positions. This raw storage qualification does not qualify the upstream `SUMP` block producer. Field counts follow the accepted operational nine-field registration.

| Allocation order | Array | Shape | Logical bytes |
| --- | --- | --- | --- |
| 1 | `GFL` | 17 × 137 × 9 × 388,217 | 65,099,332,296 |
| 2 | `GFLSLP` | 17 × 137 × 3 × 388,217 | 21,699,777,432 |
| 3 | `GFLPT` | 17 × 137 × 0 × 388,217 | 0 |
| 4 | `GFLPC` | 17 × 137 × 0 × 388,217 | 0 |

Each value occupies eight bytes. The first dimension changes fastest. Each empty array retains a nonnull reservation of at least one byte. The allocator preserves every incoming allocation byte. Array descriptions retain the original GNU layout, including all bounds, strides, type information and the address offset. Size and stride products use 64-bit integer arithmetic. Other array descriptions retain their fresh zero bytes.

Call the unchanged `md2asm_zero_gridpoint_field` as a separate stage. It writes positive zero to every logical value in the allocated main, next-time, physics and selected tendency arrays. Here the next-time array remains unallocated, and the two empty reservations retain their incoming byte. Padding positions within the complete main and physics shapes are included. Trajectory arrays remain unchanged. These are storage preparation stages, rather than the loading of physical initial conditions.

Call the unchanged `md2asm_release_gridpoint_field` to free the four selected owners in source order. It clears only their base-address words. The caller retains the record, dimension inputs and borrowed configuration. Release also cleans up any owners acquired before a failed allocation.

The application binary interface (ABI) defines arguments, registers and stack use. The initializer uses a 160-byte frame, release uses 96 bytes and zero is a leaf with no frame. Stack alignment is 16 bytes. All entries preserve x18, required saved registers, the floating-point control and status registers, and the library error indicator. Set the floating-point control register to zero before allocation. Return 0 means success, 1 means allocation failure after cleanup, and 2 rejects an unsupported input before mutation. Production uses only direct assembly and the C library's allocation, release and error-address services.

The existing coarse-case initializer, zero stage and release source remain unchanged. The outer context creator and complete model startup retain their earlier contracts. Detailed source, complete-buffer and lifecycle checks remain local under `.runtime/`.

Two complete operational source and assembly cases compare 347,196,438,920 payload bytes before and after the separate zero stage, 6,576 complete record bytes and 2,718,272 unchanged borrowed-configuration bytes. The four independent allocation addresses are matched explicitly, with every other record byte compared unchanged. Original records and address associations are retained. Independent checks cover complete incoming byte patterns, positive-zero values and 114 dimension, stride and origin relations. All ten native ABI and status checks pass, along with 608 allocation-guard bytes, first and fourth allocation failures, and two wrong-shape refusals.

The reference uses the accepted original allocation and release statements with only the admission tuple changed, plus the genuine original `ZERO_YOMGFL`. No new high-level numerical calculation is introduced. The full-buffer verification took about 262 seconds after an initial 120-second cutoff. The candidate did not change. This is a component verification duration, rather than a forecast measurement. Reuse unchanged source-stage and physical evidence for storage preparation.

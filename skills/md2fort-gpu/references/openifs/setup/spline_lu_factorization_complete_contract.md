# Complete spline LU factorisation on the GPU

LU factorisation stores a square matrix as row swaps and lower and upper triangular factors. This GPU revision preserves the [accepted spline method and physical checks](../../../../md2fort/references/openifs/setup/spline_lu_factorization_contract.md), including every rounding point. Dimension, row indices, pivots and diagnostic counts are dimensionless. The matrix retains the caller's spline units and scaling. The complete numerical body now runs in one GPU call.

The public [Arm parent](../../../../../src/openifs/setup/gpu/spline_lu_factorization_host.S) exports md2asm_spline_lu_factor. Its four addresses in x0 through x3 are dimension, matrix, pivots and info, and w0 returns the source code. Dimension is one through twenty-four. Matrix has n squared sixty-four-bit floating-point values in contiguous column order, with eight-byte alignment. Dimension, n pivot words and info contain signed thirty-two-bit integers with four-byte alignment. These mapped complete owners are disjoint. All initial cells and executed intermediate results are finite. Return two rejects the original null, alignment, size or initial nonfinite input without output changes. Return zero completes factorisation; pivots are one-based and info stores the first zero-pivot position, or zero when nonsingular.

The [values child](../../../../../src/openifs/setup/gpu/spline_lu_factorization_values.ptx) exports md2asm_gpu_spline_lu_factor_values. Its arguments are n:u32, matrix:u64, pivots:u64 and info:u64. Here u32 and u64 mean unsigned thirty-two- and sixty-four-bit integers; i32 means a signed thirty-two-bit integer. Addresses occupy u64 arguments. The caller admits the complete owners first. The child performs the source matrix, pivot and info writes, then returns an eight-byte-aligned thirty-two-byte record.

| Offset in bytes | Return field |
| --- | --- |
| 0 | source return code, u32 |
| 4 | source info, i32 |
| 8 | newly raised floating-point status, u32 |
| 12 | zero, u32 |
| 16 | FAST count, u64 |
| 24 | WIDE count, u64 |

Visit columns in increasing order and choose the first row with strictly largest absolute pivot. Swap complete rows and store its one-based index. For a nonzero pivot at or above the smallest normal floating-point magnitude, separately round one divided by the pivot, then multiply each lower cell by that reciprocal in increasing row order. For a smaller pivot, divide each lower cell separately. A zero pivot sets only the first info index, leaves the column unscaled and continues the source updates.

For each later column with a nonzero pivot-row value, separately round negative one times that value. For every increasing lower row, evaluate product plus old cell with the qualified exact integer product-sum helper and one final round to nearest, ties to even. Preserve operand order. Do not split that update into separately rounded multiply and add or replace it with a native fused instruction. Retain signed-zero skips, gradual underflow, finite comparisons and all source intermediate rounding points.

Each call starts local status and counts at zero. The unchanged multiply/divide helpers return a separately rounded value and required new status. The compact exact product-sum helper returns the same value/status/class interface as its qualified original: class zero contributes one actual public FAST event and class one one WIDE event, including the tiny/general route. Consume each returned value, flag word and class before another call. The values child makes no global counter write and performs no incoming-status shortcut.

The [private Arm phase](../../../../../src/openifs/setup/gpu/spline_lu_factorization_phase_calls.S) retains all thirty-one general registers, all thirty-two full vector registers, floating-point control and status registers, integer condition flags and errno in an aligned 2048-byte frame. The original parent retains its 176-byte frame and integer input checks. The phase restores x18 after runtime services and keeps every private buffer alive until completion. Incoming floating-point control must be zero: nearest, ties to even, with gradual underflow. The serial host restores that control and errno and joins newly raised status into the saved incoming status. Only storage, constants and state moves remain on the host.

The [device phase](../../../../../src/openifs/setup/gpu/spline_lu_factorization_phase.ptx) exports md2asm_gpu_spline_lu_factor. It receives vector:u64 and context:u64 and launches one block with one thread and zero dynamic shared memory. The sixteen-byte vector points to an eight-byte-aligned 128-byte header and thirty-two-byte completion. Completion has the values-child return layout. The header is as follows.

| Offset in bytes | Header field |
| --- | --- |
| 0, 8, 16, 24 | dimension, matrix, pivots and info addresses, u64 |
| 32, 40 | actual public FAST and WIDE owner addresses, u64 |
| 48, 56 | matrix and pivot capacities, u64 |
| 64 | dimension n, u32 |
| 68 through 127 | zero |

The caller supplies a mapped, eight-byte-aligned sixty-four-byte standard context with error:u32 at byte zero, revision one:u32 at four, new status:u32 at eight, zero serial control:u32 at twelve and event:u64 at sixteen. Progress, scratch address and capacity are zero at twenty-four, thirty-two and forty. Record address and capacity occupy forty-eight and fifty-six. The sixteen-byte record stores exact header/completion capacities 128 and 32. The ordinary runtime initialises context error, new status and event fields before launch; the host retains incoming CPU status separately.

The eleven pairwise disjoint owners are the header (128 bytes), completion (32), vector (16), context (64), record (16), dimension (4), full matrix and pivot capacity spans, info (4) and both eight-byte public counters. Dimension, pivots and info need four-byte alignment; all other owners need eight-byte alignment. Matrix and pivot capacities cover at least eight times n squared and four times n bytes. The host supplies those exact extents. Admission checks capacities, address-end overflow, header controls, dimension agreement, every owner pair and every initial finite matrix word before child writes. Malformed shape/context controls set error 29200, malformed range/overlap sets 29201 and malformed numerical/reserved controls set 29202. Private refusal changes only context error.

The host obtains the original md2asm_product_sum_fast_calls and md2asm_product_sum_wide_calls owners through their global address bindings. The entry publishes each returned total once by sixty-four-bit atomic addition, with wrap modulo two to the power sixty-four, and joins returned flags into context. A complete caller can instead compose the values child and combine its private totals before one publication. Keep the actual counter owner object, compact exact product-sum provider, IEEE status provider and scalar helper once in a combined image. No original OpenIFS numerical routine or CPU fallback supplies this stage.

The component passes thirteen retained complete cases over 30,420 matrix, pivot and info bytes, immediate status, errno, strict register obligations and real FAST/WIDE totals with wrap. Verification drivers read the original counter addresses instead of separate copies. Thirty-eight new interface controls cover three valid cases, thirty-four device refusals and one host revision refusal, with 4,984 bytes checked per image. Reuse the retained 5,661 independent exact-rational factor relations and original host refusals. Independent source and native peers cover the complete new body and boundary; native helper return/status/class handling is explicit. Fixed half-precision fused instructions consume only zero registers and literals to make constants, never model values.

Every numerical process had an external 14.13-second limit on an owned exclusive node. No new CPU or Fortran oracle or unchanged mathematical-helper check ran. These records qualify the complete LU component. A combined forecast and comparative performance remain separate decisions.

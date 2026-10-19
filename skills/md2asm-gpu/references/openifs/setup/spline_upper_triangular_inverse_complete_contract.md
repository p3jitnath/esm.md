# Complete upper triangular spline inverse on the GPU

This revision moves the complete accepted upper triangular inverse into one GPU call. The upper triangle contains the cells on and above a square matrix's main diagonal. Its inverse replaces those cells, while every byte below the diagonal stays unchanged. Dimension n, indices, return codes and operation counts are dimensionless. Matrix values retain the caller's declared spline units and scaling. The [accepted mathematical contract](../../../../md2asm/references/openifs/setup/upper_triangular_inverse_contract.md) supplies the method and retained physical evidence. No physical equation or rounding rule changes.

The public Arm entry [spline_upper_triangular_inverse_host.S](../../../../../src/openifs/setup/gpu/spline_upper_triangular_inverse_host.S) exports md2asm_spline_upper_inverse. It receives dimension:i32* in x0, matrix:f64* in x1 and info:i32* in x2, returning its source code in w0. Dimension is one through twenty-four. Dimension and info need four-byte alignment; the contiguous column-major matrix needs eight-byte alignment and n squared FP64 cells. FP64 means a sixty-four-bit floating-point value. The caller supplies mapped, disjoint complete owners. All initial cells and executed intermediate results are finite.

Return zero means source processing completed. Info zero means that the inverse was formed. A zero diagonal returns zero with its first one-based position in info and preserves the complete matrix. Return two rejects null, alignment, dimension or nonfinite initial input without matrix or info changes. Invalid mapped extents and aliases are outside the public buffer contract and are refused at the private admission boundary before numerical writes.

The [values child](../../../../../src/openifs/setup/gpu/spline_upper_triangular_inverse_values.ptx) exports md2asm_gpu_spline_upper_inverse_values. It takes n:u32 then matrix:u64 and returns an eight-byte-aligned thirty-two-byte record. The caller first admits the complete matrix. Private status and counts start at zero, and the child does not write public counters.

| Byte offset | Return field |
| --- | --- |
| 0 | source return code, u32 |
| 4 | source info, i32 |
| 8 | newly raised floating-point status, u32 |
| 12 | zero, u32 |
| 16 | FAST count, u64 |
| 24 | WIDE count, u64 |

Check n, matrix alignment and every initial cell's finite exponent before any numerical comparison or matrix write. Scan diagonal entries in increasing order for the first positive or negative zero. For each nonsingular increasing column, separately divide one by its diagonal through the qualified division helper. Store the reciprocal and change only its sign bit to obtain the negative scale.

For each increasing prefix column k with nonzero current vector value t, visit earlier rows i in increasing order. Let a be the already inverted upper block and u the current vector. RN means round to nearest with ties to even. The source update has one final rounding.

```math
u_i \leftarrow \operatorname{RN}(a_{ik}t+u_i).
```

Use the qualified exact integer product-sum child for that update. It must not become a separately rounded multiply then add, a reassociated expression or a native fused instruction. Then separately multiply t by the block diagonal through the multiplication helper. After the prefix loop, separately multiply every prefix cell by the negative reciprocal, including zero cells. Preserve source operand order, rounding points, signed zeros and gradual underflow.

The exact product-sum interface takes three raw sixty-four-bit operands and returns an eight-byte-aligned twenty-four-byte record: value at zero, new status:u32 at eight, zero at twelve, class:u32 at sixteen and zero at twenty. Class zero contributes one actual public FAST event; class one contributes one WIDE event. These classes describe the qualified integer rounding route. Every finite source call contributes one class, including the tiny/general route. The already qualified compact provider keeps this interface and is selected once. Multiply and divide retain their unchanged sixteen-byte value/status helpers. Consume each value, new status word and class before another call.

The [device entry](../../../../../src/openifs/setup/gpu/spline_upper_triangular_inverse_entry.ptx) exports md2asm_gpu_spline_upper_inverse. It takes vector:u64 then context:u64. Launch one block with one thread and zero dynamic shared bytes. The sixteen-byte vector has input and output addresses at zero and eight. Input and output need eight-byte alignment and thirty-two bytes each. Input stores dimension, matrix and info addresses at zero, eight and sixteen, then zero at twenty-four. Output uses the values child's return layout. Commit original info only when source return is zero.

The caller first admits a mapped, eight-byte-aligned sixty-four-byte context. It has error:u32 at zero, revision one:u32 at four, incoming sticky status:u32 at eight and zero serial control:u32 at twelve. Event:u64 at sixteen, progress at twenty-four, scratch address at thirty-two and scratch capacity at forty are unused and preserved. Record address and capacity are at forty-eight and fifty-six. The eight-byte-aligned sixty-four-byte record stores u64 capacities for input, output, matrix, dimension and info at zero, eight, sixteen, twenty-four and thirty-two. Its final three words are zero.

The vector, context, record, input, output, dimension, info and matrix consumed ranges are pairwise disjoint. Before the numerical call, check the seven non-context ranges for null, alignment, capacity, positive-address limits and address-end overflow. The complete mapped context remains a caller precondition. Admission checks all twenty-eight owner pairs. Shape or context controls set error34900; range or overlap sets34901; numerical controls or reserved words set34902. Refusal changes only the context error word. A pre-existing error returns unchanged. A null or misaligned context returns without a status write.

The Arm adapter retains all 31 general registers, all 32 full vector registers, the floating-point control register (FPCR), floating-point status register (FPSR), integer condition flags and errno in an aligned 2048-byte private frame. It restores x18 after runtime services. FPCR must be zero, and the caller is serial. Private records remain disjoint and live until the ordinary CUDA launch completes. Host numerical arithmetic supplies no result. The adapter restores control state and errno, joins new status into incoming FPSR, and adds each returned count once modulo two to the power 64 to the original md2asm_product_sum_fast_calls and md2asm_product_sum_wide_calls owners. Each owner occurs once in the executable.

The module selects the complete values and admission objects, the already qualified compact exact product-sum provider, the IEEE multiply/divide status provider and its scalar helper. A complete inverse parent can call the same values child without a host launch. Keep that child and every provider once in a combined module. Original OpenIFS routines, constructors, descriptors and CPU numerical fallbacks do not supply this stage.

Acceptance compared all thirteen retained matrices and info fields, totalling 29,588 bytes, with zero differences. A one-time accepted GPU capture supplied missing immediate status and actual count records after matching every archived output byte. The complete host matched those records, errno, register obligations and counter wrap. Twenty-four new raw controls compared complete 8,192-byte images, and nine public rejection cases preserved every buffer, status and count. Independent peers covered the complete child and eight-owner host/entry boundary. Native inspection found four expected helper calls and two finite comparisons in the changed values body, with no other numerical arithmetic.

Reuse the retained 5,623 independent exact-rational inverse and lower-preservation relations, 2,310 exact product-sum tuples and 151 source stages. No new CPU or Fortran oracle ran. Each numerical process had an external 14.13-second limit on an owned exclusive node. These checks accept this component; a complete forecast and matched performance remain separate obligations. No full-forecast speed claim follows from this component.

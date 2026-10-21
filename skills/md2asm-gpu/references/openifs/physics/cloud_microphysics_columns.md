# Distributed Cloud Microphysics Columns

Revision 3 preserves the [cloud water and rain formulation](../../../../../formulations/openifs/physics/cloud_water_and_rain.md), the ordered calculations in the [complete cloud contract](../../../../md2asm/references/openifs/cloud_microphysics_contract.md), all eight numerical child interfaces and every original output bit. Revision 1 distributes independent columns across GPU blocks. Revision 2 carries accumulated status through private arithmetic helpers to reduce repeated work. Revision 3 performs checked common multiplications directly in each caller. Each worker completes a column from its first cloud level to its last level before moving to another column.

The supported configuration and physical limits are unchanged. The allocated column count is P from 1 through 4096, the level count is N from 2 through 256, and the active interval starts at column 1 and ends at an integer from 0 through P. P and N count cells and levels and have no physical units. Unsupported controls, bounds, alignment and forbidden overlaps fail the original admission checks before output writes.

## Interfaces and Storage

The application binary interface (ABI) defines arguments, registers and stack storage. The [host boundary](../../../../../src/openifs/physics/gpu/cloud_microphysics_boundary.S) keeps the original 76 pointer arguments, with eight in x0 through x7 and 68 on the incoming stack. It uses a 1280-byte frame with 16-byte stack alignment and preserves x18, x19 through x29, the low 64 bits of d8 through d15 and the caller's declared floating-point state. Its constant symbols refer to the forecast's assembly-owned storage. The host performs storage and CUDA services, with no cloud calculation or original OpenIFS numerical call.

Each [GPU entry](../../../../../src/openifs/physics/gpu/cloud_microphysics_column_stages.ptx) takes two eight-byte aligned unsigned 64-bit device addresses, pointing to the 608-byte argument vector and the 64-byte revision-1 context. The context supplies a 256-byte constant/counter record and the complete private scratch owner, which holds temporary column values. One column uses 512 times (N + 2) + 4160 scratch bytes, and the supplied capacity covers all P columns. The original admission routine checks complete argument owners, descriptors, constant views, alignment, integer overflow and overlap before calculation. No new storage is required.

## Ordered Launches

The [launch helper](../../../../../src/openifs/physics/gpu/cloud_microphysics_launch.S) preserves its Arm register obligations in a 96-byte frame and keeps FPCR, FPSR and errno across nonnumerical services. These registers control floating-point rounding and record numerical events. All stages use one ordered stream and zero dynamic shared memory. Workers and join consume only a successfully prepared context.

| Stage | Blocks × Threads per Block | Complete Work |
| --- | --- | --- |
| Prepare | 1 × 1 | Run the original admission and clear the complete rain-freezing output once |
| Workers | 32 × 1 | Give block b columns b, b + 32 and later columns below the active count, using zero-based storage indices |
| Join | 1 × 1 | Combine flags, ordered error events and actual mathematical-helper totals with the original rules |

Separate launches order the complete grid. Each column keeps disjoint scratch and output cells, all original intermediate rounding and every original numerical child call. The join runs only after every worker completes. An empty call retains the original one-block, 128-thread entry and its original setup effects.

## Repeated Numerical Status

The [accumulated binary helpers](../support/accumulated_binary_status.md) retain the original rounded results while reducing repeated reconstruction of numerical status. The eight children have 993 arithmetic sites. At 408 multiplication sites, the caller checks its existing flag word and both operands, then performs the same rounded multiplication directly when the proved bounds hold. The remaining sites use the private helpers. A proved operand bound permits the short route only when the operation can add no flag that the caller does not already hold. Other inputs use the unchanged complete arithmetic helper. Each returned flag word is used only to update the same accumulated state. No child argument, counter, model owner or launch changes.

## Evidence and Limits

The arithmetic helpers pass 4,320 operand and status cases. The directly placed multiplier also matches 1,080 retained edge records, including signed zeros, exceptional values and guard boundaries. The changed complete parent passes 192 retained cases with zero differing owner or readonly bytes and exact numerical status, real counters and ABI state. The unchanged high-precision column water and phase-enthalpy checks remain applicable through the exact canonical outputs. Checked cases include empty work, partial work, seeded status and counters, and protected buffer boundaries. Repeated matched measurements select this launch sequence for the retained 24-column, 19-level component. Detailed inputs, tools and timing records remain local. This component result does not establish complete GPU forecast acceptance or runtime.

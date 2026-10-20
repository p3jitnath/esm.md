# Parallel Lagrangian Grid Update

This component advances the same air-parcel calculation as the [serial GPU contract](lagrangian_grid_update.md). One block of 32 GPU threads processes independent horizontal columns. Each column keeps the original vertical calculation and rounding order. The original serial providers remain available for their other callers.

## Interface And Storage

The [Arm host](../../../../../src/openifs/dynamics/gpu/lagrangian_grid_parallel/lagrangian_grid_parallel_host.S) retains the original 36 address arguments and application binary interface, or ABI. It preserves the caller's saved registers, floating-point controls and error indicator. The [parallel parent](../../../../../src/openifs/dynamics/gpu/lagrangian_grid_parallel/lagrangian_grid_parallel_parent.ptx) uses a 64-byte common context, a 32,768-byte input record and a complete 1,144,736-byte scratch buffer. The context carries status and buffer addresses. Required real arrays have eight-byte alignment and retain their original column-first order.

Each thread has private temporary records, context and counters. Shared work arrays are divided by column, with the original full-array spacing. Six admission routines check supported inputs before output writes. Scratch checks include the complete consumed buffers reached through indirect addresses. All threads join required child barriers, including threads with no active column. Each nested call uses private argument and return storage.

## Exact Agreement

Sixteen retained calls match 155,206,208 output bytes and 136,219,520 readonly bytes. One ordinary device-memory case matches 9,700,388 output bytes. Thirteen early-refusal cases preserve 222,272,388 complete buffer bytes apart from the declared status word. All comparisons have zero differing bytes. Immediate status, actual counter wrap and 16 private-scratch guard observations pass. The existing 7,296 independent physical relations remain applicable.

These are component checks for the declared forecast shape. The published sources rebuild to the accepted objects exactly. Complete GPU forecast agreement and comparative performance remain separate checks. Detailed inputs, tools and records remain local.

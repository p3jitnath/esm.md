# Parallel Radiation Climatology

Climatology gives typical atmospheric and surface values over long periods. Phase three of RADINTG prepares these prescribed data for radiation. This supplement describes how independent groups of columns run together. The physical formulas, constants and ordered 64-bit floating-point calculations remain unchanged. The [parent contract](radiation_grid_parent.md) gives the original 59-address interface and the other radiation phases.

The application binary interface (ABI) passes two 64-bit address words to each kernel: original_vector and common_context. They point to the original 472-byte argument vector and 64-byte context. Both addresses and the private-storage base must be aligned to eight bytes. The context retains a pointer to the original 160-byte record. The Arm boundary retains the register, floating-point control and error-indicator obligations in the parent contract.

Private storage needs 482,282,048 bytes for the selected parallel route. The first 449,838,528 bytes retain the accepted phase-four layout. Extra storage holds an 18,673,296-byte snapshot, 127 separate worker areas, 256 result rows and control words. Bounds, alignment, address wrap and separation from every consumed external owner are checked before these extra areas are written. The fast route also requires the admitted 64-by-91 greenhouse table. Other valid layouts use the complete original serial phase.

The following offsets count bytes from the private-storage base. Each area remains inside the declared complete capacity.

| Area | Byte offset | Size in bytes |
| --- | ---: | ---: |
| Original-state snapshot | 449,838,528 | 18,673,296 |
| Private worker areas | 468,511,872 | 127 × 108,160 |
| Result rows | 482,248,192 | 256 × 128 |
| Control words | 482,280,960 | 1,088 |

A GPU block is a group of threads that run together. Preparation uses one block of one thread. The snapshot uses 128 blocks of 256 threads. Then 128 blocks of one thread each process two original eight-column groups, in their original local order. Worker 127 finishes original group 255 in the original workspace. The join uses one block of 256 threads. The context records temporary progress 259 after preparation and progress four after a complete join. The phase-four sequence remains separate.

The join checks every completion marker and error before it publishes numerical effects. It keeps incoming status flags, selects the last nonzero error event in original group order and adds the nine counter effects with their original 64-bit wrap rule. A 64-bit unsigned counter wraps from its largest value back to zero. If a worker is incomplete or refuses an input, the join restores the snapshot and runs the complete original serial phase. It does not publish the discarded worker effects. All threads reach the required barriers. The original serial provider and shared numerical helpers remain linked once.

One genuine retained graph passes both the normal route and a controlled missing-marker rollback. Each check compares all 25,471,520 original workspace bytes, 21,519,888 external owner and guard bytes, the full context and 47 actual counter words, with zero differences. The normal route requires all 256 markers and no fallback. The control removes one private marker and requires a complete restore and serial resume. Both preserve the old phase-four private areas, incoming sticky flag 128 and nine near-wrap counter seeds. Accepted GPU phases zero, one and two produce the true phase-three input. Retained table loaders prepare verification inputs and supply no production stage. Existing independent child physics checks remain applicable. No new CPU RADINTG or Fortran physics reference is called. Full-forecast acceptance and matched timing remain separate unfinished work.

The assembly sources are the [parallel phase](../../../../../src/openifs/radiation/gpu/radiation_climatology_parallel_blocks.ptx), the [ordered entry](../../../../../src/openifs/radiation/gpu/radiation_grid_entry.ptx) and the [Arm launch boundary](../../../../../src/openifs/radiation/gpu/radiation_grid_calls.S). They retain every accepted instruction and symbol. Local records keep exact toolchain commands, raw bytes, failures and independent reviews.

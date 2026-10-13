# Grid-Point Block Driver Contract

Revision 2 freezes CPG_DRV from OpenIFS 48.1.1, original source `arpifs/adiab/cpg_drv.F90`, for the selected coarse forecast. Its [formulation](../../../../../formulations/openifs/dynamics/grid_point_block_driver.md) groups the unchanged column physics. Original and corrected source versions, typed layouts, block strides and detailed evidence remain local.

## Method And Schedule

Visit all 86 blocks in ascending order, applying the complete direct [CPG update](complete_grid_point_update.md) to each block. The grid has 2,048 cells, 24 allocated columns per block and 19 levels; the final block has eight active columns. Keep configuration A or B, split and lagged physics and the interpolation buffer. Predictor correction, mixed time stepping, extra transport statistics and optional mean, gust, visibility and precipitation resets are inactive.

Derive the first-step flag from NSTEP, forward stored TDT and BETADT and set the ordinary update factor to one. The original reset caller indexed a one-element allocation with NSTEP although its bounds used NSTEP divided by NFRRAZ. Corrected source revision 2 uses that integer quotient for both the slice and the dummy lower bound. Retain NFRRAZ equal to 20. The direct MONIO_T child selects the event; reset only at the initial step or exact multiples of twenty. Preserve the old source and its formerly undefined bytes locally and compare against the separate corrected reference.

The driver clears each column of its 19-by-86 integer transport-counter array before CPG. PPGTERM has one 968-byte record per block. Use the original complete column-first field strides and the actual SAVTEND and saved-departure descriptors. Equation CPGDRV-P01 describes these block views. Inactive trajectory views have no selected consumer, so forward absent private views while retaining ordinary trajectory objects and their bytes. Keep all original parent and SC2PRG profiling events and GSTATS calls.

## Assembly Interface

The application binary interface, or ABI, defines call arguments and preserved registers. `md2asm_cpg_drv_7358525`, also exported as `cpg_drv_`, retains 72 ordinary addresses plus one GNU hidden character length. The first eight addresses use x0 through x7, the other 64 addresses occupy consecutive eight-byte incoming stack slots and the character length follows them. CDCONF addresses one character and its hidden length must be one. Geometry, Model, Fields and the transport configuration are typed records; logical and integer values use four bytes. Required real arrays use eight-byte-aligned, little-endian FP64 storage.

The frame has 2,048 bytes and 16-byte alignment. Preserve x18 through x29, the return address and the required low halves of v8 through v15. Numerical children retain FPCR zero, round-to-nearest with ties to even, gradual underflow and signed zeros, with contraction, reassociation, fused and approximate arithmetic forbidden. Compare immediate FPSR and errno with the source return.

Every consumed block view must lie inside its complete owner. Preserve readonly owners, metadata and aliases. Inactive DDH views have zero consumed extent, while their actual small complete allocations remain in the comparison. Reject changed selected controls before mutation. All native numerical work uses direct assembly; source profiling and runtime allocation remain declared services. The enclosing Fortran forecast and source-only verification controls remain required, so this driver is not an autonomous forecast.

## Checks And Build

The focused corrected reset check passes steps zero, one and twenty, including buffer guards, source bounds and the independent event rule. R25 records 25 source CPG_DRV calls and three complete source-first/native pairs at the initial step, a positive ordinary step and step twenty. They compare 775,302,519 owner bytes with zero differences and require exact raw status and saved registers. Reused owner, alias and child physical proofs retain their frozen scope. Other steps use the source in this verification run. All ten saved files match corrected reference R4 over 618,140 bytes.

Assemble the self-contained source with `gcc -c -fPIC -march=armv8.2-a+simd src/openifs/dynamics/grid_point_block_driver.S -o grid_point_block_driver.o`, then link the retained CPG and MONIO_T direct bodies and declared runtime services. Publication preserves the accepted machine text, constant bytes and relocation meanings. CPG_DRV is a main-phase support body and adds no weather-routine credit. No performance or whole-forecast physical result is claimed.

# Complete Grid-Point Update Contract

Revision 1 freezes CPG from OpenIFS 48.1.1, original source `arpifs/adiab/cpg.F90`, for the selected coarse forecast. Its [formulation](../../../../../formulations/openifs/dynamics/complete_grid_point_update.md) groups existing physical equations. Source versions, typed layouts, argument maps and detailed evidence remain local.

## Method And Storage

Keep one process, one thread, 19 levels and blocks with 24 allocated columns. Split and lagged physics and transport storage are enabled. Predictor correction, pressure-gradient reuse, extra dynamics diagnostics, DDH diagnostics, the convective cellular automaton and curved right-hand-side rotation are inactive. Reject unsupported controls and mapped destination bounds before mutation.

Call CPG_GP, EC_PHYS_LSLPHY, CPG_DIA, CPG_DYN and CPG_END in that order through private direct assembly entries. Their frozen numerical methods, constants and rounding points remain unchanged. The parent owns its complete consumed work arrays. Clear ZGPAR to positive zero, clear active transport cells, let the children fill them, then copy 463 fields to PB1 in ascending field and active-column order using YDSL.NSLCORE. This integer copy implements equation CPG-P01 and retains every bit.

The parent uses 235,472 scratch bytes and allocates the five pressure-term targets RT0L, RT0M, PHI0FL, PHI0FM and PHI0H. Each full-level target holds 24 by 19 FP64 values; the half-level target holds 24 by 20 values with level lower bound zero. After the final child, free all five and clear their data addresses while preserving the source-defined descriptor metadata. Unconsumed private land, soil and diagnostic scratch has no physical output and keeps valid aligned child addresses.

## Assembly Interface

The application binary interface, or ABI, defines call arguments and register duties. `md2asm_cpg_7358525`, also exported as `cpg_`, retains 85 ordinary addresses: the first eight use x0 through x7 and the remaining 77 use consecutive eight-byte incoming stack slots. Geometry, Model and Fields are typed records; the six following logical controls use four-byte values. KGPCOMP, KSTGLO and KIBL are four-byte integers. PDT, PDTPHY, PTE and PBETADT are FP64 values, followed by the transport record and the original field-address sequence. KSETTLOFF holds 19 integer outputs. Trajectory, diagnostic and saved-position arguments retain their original types and order.

Required real buffers are eight-byte aligned, little-endian FP64 arrays with columns first. Every used view lies inside its complete allocated owner, where an owner means the whole buffer or object. KIBL selects the actual block record, KSTGLO selects the global first column and KGPCOMP bounds active columns. Preserve caller aliases, unused bytes and optional trajectory presence. Inactive DDH views consume zero elements; their real small backing allocations, descriptors and aliases remain read-only in the comparison.

The frame has 4,096 bytes and 16-byte alignment. Preserve x18 through x29, the return address and the required low halves of v8 through v15. Use FPCR zero, round-to-nearest with ties to even, gradual underflow and preserved signed zeros. No contraction, reassociation, fused operation, approximate arithmetic or reduced precision is permitted. Capture FPSR and errno immediately at return for the raw-status comparison.

The source reference retains the accepted original-only CPG_GP route with corrected GPCTY and strict vertical integration. Direct numerical children supply every native stage. The original DR_HOOK profiler and malloc/free remain runtime services. The surrounding Fortran forecast and source-only verification controls are still required for this checkpoint; autonomous execution is not established.

## Checks And Build

R17 records 2,150 source CPG calls and two source-first/native pairs covering the first full and partial logical-control tuples. The paired complete owners compare 467,086,472 bytes with zero differences. The gate requires exact raw status and saved registers. Complete typed owner and alias qualification and independent child physical proofs are reused. Other repeated tuples use the source in this verification run. All ten saved files match corrected reference R4 over 618,140 bytes.

Assemble the self-contained source with `gcc -c -fPIC -march=armv8.2-a+simd src/openifs/dynamics/complete_grid_point_update.S -o complete_grid_point_update.o`, then link the retained direct child graph and declared runtime services. Publication compares machine text, constant bytes and relocation meanings with the retained numerical object. No forecast timing, whole-forecast physical proof or autonomous forecast is claimed.

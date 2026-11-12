# Complete Forecast Grid Driver Contract

Raw-array binding revision 8 retains GP_MODEL from OpenIFS 48.1.1, original source `arpifs/control/gp_model.F90`. Its [formulation](../../../../../formulations/openifs/dynamics/complete_forecast_grid_driver.md) groups unchanged child physics. The primary entry is `md2asm_gp_model_physics_cape_r7_7358525`. The retained parent evidence and passing joint forecast gate admit this selected route.

## Method And Storage

Keep one process and thread, 2,048 cells, 19 levels and 86 blocks of 24 allocated columns. The last block has eight active columns. Split and lagged physics, tracer correction, implicit radiation and the heap-backed transport route are enabled. Predictor correction, regional and two-dimensional models, grid stress and the declared extra diagnostics are inactive. Preserve the source-selected guards and child contracts.

Allocate and initialise the new wind and tracer storage as the source requires. The new wind, surface and tracer owners have 941,184, 16,512 and 1,882,368 bytes. The driver's private workspace has 8,617,712 bytes with the original nonoverlapping regions. When the padding control is positive, fill the declared 463-field departure buffer with the largest finite positive FP64 value. Clear the complete second departure buffer to positive zero.

Call CPG_DRV, CALL_SL_HEAP2 and the corrected-address TRMFIXERS in that order. Before RADDRV, save the active old tracer planes and copy the new tracer fields into their old-state positions. Restore the saved planes after radiation, preserving each bit. Run the CAPE-aware EC_PHYS_DRV and then CPGLAG on all 86 blocks. The selected numerical bodies use direct assembly and frozen arithmetic, with the retained C power helper declared as a mathematical dependency. The radiation call uses the qualified grid-driver binding. Keep the two-plane transported-physics capacity, actual partial-block bounds and all caller aliases.

The separate [runtime complete physics driver](../physics/runtime_complete_physics_driver.md) records the live-grid argument and nested-record interface. Its owner-address check is accepted, while its complete parent numerical and forecast acceptance remain pending.

## Interface And Temporary Services

The application binary interface, or ABI, defines arguments and preserved registers. GP_MODEL receives eleven ordinary addresses plus a GNU hidden character length of nine. The first eight addresses use x0 through x7; the other three addresses and final length occupy consecutive eight-byte incoming stack slots. Geometry, Fields and Model are the first three records. All following records, arrays and optional trajectory objects retain their original types and order. The frame has 4,096 bytes with 16-byte alignment. Required real arrays are eight-byte-aligned, little-endian FP64 with columns first. Every descriptor, view and field index must lie inside its complete allocated owner.

CPGLAG receives 21 ordinary argument addresses, including optional arrays. Its explicit-shape array arguments use raw first-cell addresses. Arguments 9–15 and 19 load the data addresses from the already constructed local descriptors; arguments 16 and 17 already use raw storage. The descriptors have lower bounds 1, row stride 1, level stride 24 and a bias that places the first cell at the data address. Keep every extent, block bound, scalar address and stress argument unchanged. No descriptor record is passed where the child expects numerical storage.

Preserve x18 through x29, the return address and required low halves of v8 through v15. Require FPCR zero, round-to-nearest with ties to even, gradual underflow, signed zeros and the original rounding points. Contraction, fused operations, reassociation and approximate arithmetic are forbidden. The verifier captures raw FPSR and errno immediately at return.

The first-registration branch retains the six original FIELD_REGISTRY registration methods in source order. First-use verification records each process's complete created owners and compares their defined values and canonical alias relations, while later paired calls reuse the existing created graph. Original DR_HOOK and GSTATS services, C++ ATLAS trace services and allocation remain dependencies. The surrounding Fortran forecast still constructs inputs and owns file encoding; this does not establish autonomous first creation.

## Acceptance And Build

Reuse the accepted child physics, typed owner, alias and registry-fixture proofs. The retained numerical-stage comparisons and joint coarse gate pass the declared full and partial owner checks, radiation save/copy/restore, status, ABI and direct-stage completion. The complete final state and all ten saved files agree within the frozen comparison rules.

Assemble the self-contained source with `gcc -c -fPIC -march=armv8.2-a+simd src/openifs/dynamics/complete_forecast_grid_driver.S -o complete_forecast_grid_driver.o`, then link the frozen direct child graph and declared runtime services. Publication preserves machine text, constants and relocation meanings. Autonomy and performance remain unverified.

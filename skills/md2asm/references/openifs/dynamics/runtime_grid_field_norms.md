# Runtime Grid-Field Norms

The [assembly](../../../../../src/openifs/dynamics/runtime_grid_field_norms.S) implements GPNORM_GFL from `arpifs/utility/gpnorm_gfl.F90`. A norm summarizes a field. For each selected constituent, this entry returns the area-weighted vertical sum, that sum divided by the layer count, and the minimum and maximum over all physical cells and layers. Each result retains the field's units. Layers are added in their source order.

## Interface

`md2asm_runtime_grid_field_norms` takes Geometry (20,400 bytes), TGFL (1,096 bytes) and context (48 bytes) in x0 through x2. The context's six words are the grid-norm dependency (32 bytes) pointer, controls (16 bytes) pointer, result pointer, result capacity, workspace byte limit and reserved zero. The dependency holds partition (4,096 bytes), configuration (67,616 bytes), an unused HYD pointer and reserved zero. Controls are NSPPR zero, LELAM false, actual MPI world size and optional-selector-present zero. All records are mapped, eight-byte aligned and live through return. Private storage and mutable results are disjoint from inputs.

TGFL describes the contiguous FP64 array P by L by C by B, with lower bounds one. P is cells per block, L is layers, C is constituents and B is blocks. Physical local count Q is positive and B equals ceil(Q/P). The genuine YGFL pointer is TGFL byte 1088. Its constituent records start at byte 3848, have stride 368 and select fields through LGP at byte 52. Bounds are P from 1 through 4096, L from 1 through 512, C from 1 through 2048 and F from 1 through 16 selected fields. All processes agree on L and the selected indices. The partition is at phase seven and associates this Geometry and actual MPI world.

Each selected field has four FP64 result words. The source root alone publishes them, followed by the int32 selected count and four preserved padding bytes. Result capacity is at least$`32F+8`$ bytes. The public GPNORM_TRANS call uses LDAVE_ONLY true, retaining the separately computed extrema. Final-block padding is not read. Other output processes retain every result byte.

One allocation of$`8(P+2)FB`$ bytes must fit the positive caller limit, at most 64 GiB. The 4096-byte aligned frame preserves x18 and all Arm callee-saved registers. FPCR is zero. Natural floating status and library errno remain visible. Storage is freed and collective status agrees before publication. Return zero means success, one allocation refusal, two rejected inputs and three MPI failure. Controlled refusal preserves results.

## Evidence

The joint mass and norm comparison passes 56 observations on four processes with a genuine T21 transform and 137 layers. Two block widths cover three and sixteen selected fields, incomplete final blocks, empty local spectral views and two common refusals. Complete records and arrays match across222,415,936 nonaddress bytes, with 608 typed pointer relations and 704 independent mean, extrema and mass checks. Guards, ABI, input preservation and release pass. This is component evidence, with whole-weather and forecast integration still pending.

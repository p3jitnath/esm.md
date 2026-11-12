# Loaded Grid-Point Tile Storage

A tile is a small group of horizontal grid points processed together. This component owns the temporary fields and controls used by the initial grid-point calculation. It extends the accepted [loaded-grid connection](loaded_grid_point_prefix.md). The numerical method, ordered FP64 arithmetic and existing CPG children stay unchanged.

## Entry Points

[`loaded_grid_point_tile_storage.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/runtime/loaded_grid_point_tile_storage.S) supplies three Arm application binary interfaces (ABIs). An ABI fixes argument locations and saved registers. Each address is a live mapped buffer, and each byte range must fit without address wrap. Eight-byte values use little-endian storage.

| Entry | Registers and result |
| --- | --- |
| `md2asm_create_loaded_grid_point_tile` | `x0` is the borrowed 64-byte initialized-model owner, `x1` names a four-byte block index, `x2` names eleven eight-byte complete field capacities, and `x3` names an empty eight-byte output slot. Return zero on success, one on allocation failure or two on a checked unsupported input. |
| `md2asm_run_loaded_grid_point_tile` | `x0` is the live tile owner. Return zero after the complete numerical call, or two for a checked invalid owner. |
| `md2asm_release_loaded_grid_point_tile` | `x0` names the eight-byte tile-owner slot. Release its allocation and clear the slot. An already empty slot succeeds. Return two for a checked invalid slot or owner. |

The owner, capacity table and output slot align to eight bytes. The block index aligns to four. The created allocation aligns to at least sixteen bytes. The output slot is separate from every input and borrowed record, including the 800-byte outer model container. The caller keeps the complete actual Geometry, MODEL, FIELDS, configuration and all borrowed field allocations live until the tile is released. Geometry describes the grid, MODEL holds model settings and state, and FIELDS describes field storage. Raw address validity, these lifetimes and complete declared ranges remain caller obligations.

## Live Sizes And Selected Bounds

Let $`P`$ be the column capacity of a tile and $`L`$ the atmospheric level count. One FP64 value occupies eight bytes. Full-level fields use $`8PL`$ bytes per stored component, and half-level fields use $`8P(L+1)`$ bytes. A half level lies at a layer boundary. Surface fields use $`8P`$ bytes per component. The selected source field counts supply each component multiplier.

The emitted size table retains the original CPG declarations, including the distinct work widths $`8L+1`$ for transport and $`7L+1`$ for ozone work. The nonhydrostatic reserve has a live consumed extent of zero or one column. One column of backing storage remains present in both cases, and inactive bytes are preserved. A zero extent does not require a missing address.

The linked geometry and numerical providers currently qualify $`P=17`$ and $`L=137`$ for this entry. The constructor reads both values before calculating sizes and rejects other values. It reads the live block count and local point count, computes the block's first global index and finds its active final-column limit. Field extents and complete capacities still come from the actual live descriptors and owner receipts. Another resolution needs its limited providers extended and checked before support is claimed. The same assembler object and main Fortran reference executable are used throughout this checkpoint.

## Ownership And Call Order

One 1,529,880-byte allocation contains a 3,072-byte metadata header, local carriers and five pressure-gradient matrices. It also contains the accepted 744-byte dynamics map, an 80-byte dependency table and sixteen bytes for inactive controls. Each local carrier and gradient matrix has sixteen trailing padding bytes for bounds observations. The original 75 argument positions and the additional explicit dependency address are retained. Fifteen positions borrow existing records, global field sections or the live time coefficient.

The constructor prepares the selected initial-step controls in assembly. The timestep address borrows the live MODEL coefficient at byte 4,150,016, and the time interpolation factor is exactly FP64 one. Inactive carrier bytes retain the accepted incoming `0x57` pattern. This pattern defines source-unwritten storage for exact comparison and supplies no physical quantity. The pressure-term record starts with zero bytes and receives five complete dense GNU array descriptors. A descriptor records an array's address, element size, dimensions and strides.

Next, the accepted binder selects the eleven actual global field sections. No tile pointer is published before all binding checks succeed. Allocation failure leaves the output slot empty. A later binding refusal releases the private allocation and also leaves the slot empty. The borrowed model is unchanged. Release the tile before releasing its model.

The run entry places the first eight arguments in `x0` through `x7` and the remaining 68 addresses in 544 outgoing stack bytes. It calls the accepted complete `md2asm_operational_forecast_grid` entry. Its 592-byte frame includes separate saved-register storage. The constructor uses 192 stack bytes and release uses 64, in addition to their declared accepted children. All three preserve `x18`, the required saved integer registers, the low halves of `d8` through `d15`, the link register and sixteen-byte stack alignment. No floating-point instruction is added.

Allocation and release use public C library `malloc`, `free`, `memset` and `__errno_location` services. These storage operations preserve incoming FPSR flags and `errno`. FPCR must be zero before creation and numerical execution. The run entry preserves the numerical child's actual flags and error state. The child has a void return, so its incidental `x0` word is diagnostic. The original reference changes `x18`, giving ABI mask 2. All native observations have mask zero. The new wrapper's declared integer success result is separate from the child's complete numerical outputs and defined status.

## Acceptance Scope

The new metadata check covers both block extents, complete scalar and descriptor construction, destination preservation, supported bounds, rollback and release. It has 27 zero-ABI observations, including 21 atomic constructor refusals and one invalid-run refusal. The live check additionally exercises one forced allocation failure and one refusal after allocation on each process. It compares every returned field and gradient byte, defined FPCR/FPSR/errno bytes, all borrowed metadata, inactive cells, per-carrier padding and protected global boundaries. The existing independent 90-digit physical relations and complete source field checks remain unchanged.

The actual loaded initial state and one accepted inverse on each of four processes supply the first and last CPG tiles, with 17 and 2 active columns. Eight original calls and eight native calls agree on all 17,254,944 output and defined-status bytes per route. Independent 90-digit checks pass 500,688 physical relations across both routes. Each process releases all 291,607 observed allocations, including the numerical children and comparison storage. The native route uses the new assembly-owned carriers and forwarding entry. No selected-physics stage, full grid scan, transport update, complete forecast or performance result is claimed by this component.

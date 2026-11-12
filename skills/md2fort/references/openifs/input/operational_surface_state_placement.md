# Operational Surface State Placement

This integer assembly stage puts the selected 9 km initial surface fields into the model arrays. It changes their storage order and preserves every value bit. Physical conversion and initial defaults are separate stages. The [coarse-case entry](initial_surface_state_placement.md) remains unchanged.

## Interface and Storage

The application binary interface (ABI) is `int md2asm_place_operational_initial_surface_fields(field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes, owners, owner_table_bytes)`. Registers `x0` through `x7` carry these arguments. Return 0 means success, 1 means an invalid buffer or overlap, and 2 means an incorrect fixed identifier. Rejected calls preserve all output bytes.

The immutable field arrays have Fortran shapes `(6599680,50)` and `(6599680,5,5)`. They require 2,639,872,000 and 1,319,936,000 bytes. Each value occupies eight bytes. The [operational selector](operational_surface_field_selection.md) defines their order. The identifier array holds 50 ordinary and five snow parameter codes as 55 signed 32-bit integers, requiring 220 bytes.

The immutable owner table contains six pairs of unsigned 64-bit words. Each pair gives the base address and byte capacity of one complete model array. The table requires 96 bytes. A plane contains one field at one level within a block.

| Table Index | Model Array | Planes per Block | Required Bytes |
| ---: | --- | ---: | ---: |
| 0 | `SP_SB`, soil | 24 | 1,267,140,288 |
| 1 | `SP_SL`, lake | 14 | 739,165,168 |
| 2 | `SP_SG`, snow | 50 | 2,639,875,600 |
| 3 | `SP_RR`, skin reservoir | 4 | 211,190,048 |
| 4 | `SD_VF`, fixed surface properties | 38 | 2,006,305,456 |
| 5 | `SD_WS`, wave state | 3 | 158,392,536 |

Every block has 17 positions. There are 388,216 complete blocks, followed by eight active positions and nine padding positions. Fields, complete arrays and the owner table require eight-byte alignment. Identifiers require four-byte alignment. The caller provides mapped storage. Every required span must fit its capacity without address wrap. Output arrays must be disjoint from each other and all four immutable spans. Immutable spans may overlap. Capacity beyond a required span remains unchanged. All spans and identifiers are checked before the first write.

## Source Mapping

The actual original `SU0PHY` and `SU_SURF_FLDS` metadata supplies the field order and complete array shapes. The first 43 ordinary assignments match the [coarse mapping](initial_surface_state_placement.md). The six albedo parameters 210186 through 210191 fill zero-based fixed-surface planes 30 through 35. Parameter 148 fills wave plane 0. The 25 snow layer inputs fill snow planes 0 through 24. Both default-only wave Stokes planes retain their incoming bytes.

For zero-based point $`p`$, define its block $`b=\lfloor p/17\rfloor`$ and row $`j=p-17b`$. For selected plane $`r`$ in an array with $`P`$ planes per block, the destination word is

```math
j+17(r+Pb).
```

The source points are consecutive within each input plane. The stage copies 3,959,808,000 bytes. Across all 7,022,069,096 model bytes, it preserves the other 3,062,261,096 bytes, including 5,400 selected padding bytes and all unselected planes. It makes no prior-zero assumption.

## Register and Status Rules

The routine uses integer instructions only. It has no stack frame and calls no external function. Registers `x0` through `x17` and integer condition flags are scratch. Preserve `x18` through `x30`, every vector register, `errno`, the floating-point control register (FPCR) and floating-point status register (FPSR). Any incoming FPCR is supported because no floating-point operation is performed.

## Accepted Checks and Limits

One actual-file decode and accepted selection supplied raw input bits only. An independent control used the original-source mapping and traversed physical points, while assembly traversed blocks. All 7,022,069,096 complete output bytes agreed from arbitrary incoming storage. All selected padding and unselected wave fields remained unchanged. Four native interface and status checks passed. Three protected-output refusals covered the final identifier, final owner capacity and owner overlap with the table. Input protection, guards, extra capacity and mapping release passed.

The unchanged coarse route retains exactly its 584 machine-code bytes, 644 constant bytes and all code relocations. Its earlier numerical checks remain valid. Independent source and interface review passed on an owned exclusive node. This result accepts storage placement only. It does not supply physical conversion, defaults or a complete operational forecast.

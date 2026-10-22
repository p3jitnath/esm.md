# Initial Surface State Placement

This integer assembly stage copies the converted initial surface fields into the original model's blocked storage. A block holds up to 24 grid points. The selected coarse case has 2,048 points in 86 blocks, with eight active points in the final block. This stage changes storage order without changing a physical value or setting any other state to zero.

The separate [operational entry](operational_surface_state_placement.md) supports the actual 9 km field list, six complete arrays and 17-position blocks.

## Interface and Complete Storage

The application binary interface (ABI) is `int md2asm_place_initial_surface_fields(field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes, owners, owner_table_bytes)`. Registers `x0` through `x7` carry the eight arguments. Return 0 means success, 1 means an invalid span, alignment or overlap, and 2 means the wrong fixed parameter sequence. Every rejected call leaves all complete output buffers unchanged.

The two input field arrays have Fortran shapes `(2048,47)` and `(2048,5,5)`, requiring 770,048 and 409,600 bytes. They contain FP64 values, meaning 64-bit floating-point values, after the separate physical surface conversion. The immutable parameter buffer contains the exact 47 then five signed 32-bit identifiers used by the [field selector](initial_surface_field_selection.md), in 208 bytes. The source checks every identifier before writing output.

The immutable owner table has five pairs of 64-bit unsigned words, each containing a pointer and a byte capacity, in the following order. An owner is the complete allocated array whose unselected words must also be retained.

| Owner table index | Original owner | Fortran shape | Required bytes |
| ---: | --- | --- | ---: |
| 0 | `SP_SB`, soil | `(24,4,6,86)` | 396288 |
| 1 | `SP_SL`, lake | `(24,14,86)` | 231168 |
| 2 | `SP_SG`, snow | `(24,5,10,86)` | 825600 |
| 3 | `SP_RR`, skin reservoir | `(24,4,86)` | 66048 |
| 4 | `SD_VF`, surface properties | `(24,38,86)` | 627456 |

The owner table requires 80 bytes. Fields, owner buffers and the table require eight-byte alignment, while identifiers require four-byte alignment. Each fixed span must fit its capacity without address wrap. Every output owner must be disjoint from the other owners and all four immutable input spans. Immutable input spans may overlap. Capacity beyond each fixed span remains unchanged, and the caller provides mapped storage.

## Original Field Mapping

The exact source field order is frozen by the selector. These assignments use one-based model field and level numbers, matching the original source log.

| Owner | Original selected assignment |
| --- | --- |
| Soil | Parameters 139,170,183,236 fill levels 1–4 of field 1, parameters 39–42 fill levels 1–4 of field 2, and parameters 35–38 fill levels 1–4 of field 3 |
| Lake | Parameters 228008–228014 fill fields 1–7 |
| Snow | Parameters 228141,32,33,238,228038 fill fields 1–5, with all five levels in each field |
| Skin reservoir | Parameters 235 and 198 fill fields 1 and 2 |
| Surface properties | Parameters use the following selected slots |

| Surface parameter sequence | One-based destination slots |
| --- | --- |
| 173,174 | 1,2 |
| 160,172,161,162,163,234,27,129172,28,200199 | 4–13 |
| 29,30,66,67,43,26,228007,31,34 | 15–23 |
| 74,15,16,17,18 | 26–30 |

For zero-based global point $`p`$, let $`b=\lfloor p/24\rfloor`$ be its block and $`j=p-24b`$ its row. A plane holds one field at one level within a block. If an owner has $`P`$ planes per block and the selected plane is $`r`$, the destination word index is

```math
j+24(r+Pb).
```

For a layered owner with $`L`$ levels, zero-based field $`v`$ and level $`l`$, the plane is $`r=l+Lv`$. For an owner without levels, the plane is its field index. Source words are $`p+2048f`$ for a 2D field $`f`$, and $`p+2048(l+5f)`$ for a snow field.

Copy all 1,179,648 selected bytes. Retain the complete incoming contents of the five owners everywhere else. Across 2,146,560 owner bytes, 966,912 bytes remain unchanged, including 16,640 bytes in the 16 inactive final-block rows. There is no prior-zero assumption and no zero operation in this stage. Earlier surface defaults remain a separate initialisation requirement.

## Source and Status Boundary

The source is `arpifs/setup/sugridg.F90`, lines 308–678. Its selected field copies are reported in the actual complete startup log, while the independent typed startup metadata supplies all five complete shapes. Every one of the 47 surface planes and 25 snow layer planes is accounted for. The actual configuration has `LIFSTRAJ` false and `NCONF` 1, which disables the diagnostic-surface copy. Other source groups have no selected copy in this case. This helper implements only the five listed owners and makes no claim for other configurations or a full `SUGRIDG` replacement.

Use only integer loads, stores and address calculations. Preserve all copied bits, including signed zeros and diagnostic values. Any incoming floating-point control register (FPCR) is supported. FPCR, the floating-point status register (FPSR), `errno`, `x18` through `x30` and every vector register remain unchanged. The leaf uses no stack and calls no child or library. Integer flags and registers `x0` through `x17` are scratch.

## Acceptance

This stage passes twelve focused cases against an independently written Fortran whole-slice control derived from the original field logs and typed shapes. All 2,146,560 owner bytes agree for actual converted fields and diagnostic raw bit patterns. Protected arbitrary preimages, final-block padding, metadata, capacities and output overlap cases pass. Three seeded ABI paths also pass, with every required status value retained. The independent source/interface review also passes. There is no new physical calculation to validate. The earlier conversion checks retain their separate physical scope, and this placement stage does not establish a complete autonomous forecast.

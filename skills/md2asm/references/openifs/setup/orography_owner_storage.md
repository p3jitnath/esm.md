# Owned Orography Storage

Orography describes the shape of the land surface. This child owns the selected hydrostatic allocation tail of SUGEOMETRY, before surface orography input is loaded. It receives the stable 17,096-byte owned Geometry address in x0 and returns status in w0. Geometry is eight-byte aligned and mapped. Its YROROG descriptor at byte offset 14024 is fresh, its owned LNONHYD_GEOM flag is canonical false, and its positive NPROMA, NGPTOT and NGPBLKS obey the source block-count relation. The selected actual values are 24, 2048 and 86. The checked bounded shape accepts NPROMA from one through 24, up to 2048 active points and no more than 86 blocks. All new records and payloads are complete, mapped and disjoint from the input records.

Allocate NGPBLKS records of 384 bytes and initialize their six allocatable data pointers to null. In increasing source block order, allocate OROG, OROGL and OROGM FP64 owners with IEND equal to the smaller of NPROMA and the remaining active points. The actual first 85 owners in each field have 24 values and the final owner has eight. The other three derivative owners remain unallocated. Do not write any numerical payload byte: actual input setup supplies these values later. All GNU descriptors use the true element sizes, spans, ranks, strides and one-based bounds.

The raw entries are `int md2asm_allocate_orography_owners(void *geometry)` and `int md2asm_release_orography_owners(void *geometry)`. Return zero is complete, two rejects the checked shape/freshness scope before mutation and one reports allocation failure. Failure releases every acquired payload and outer record and clears the outer data pointer; partial bounds can remain. Release frees only these acquired owners and clears the outer data pointer, retaining other Geometry bytes. Initializer and release frames are 160 and 96 bytes with 16-byte alignment. Preserve x18, all ABI saved registers, FPCR, FPSR and errno. Only malloc, free and errno access are production external services.

The separate control retains the genuine source allocation loop and original TOROG type. Four genuine source cases pass 99,648 complete source-unwritten payload bytes, 203,968 complete outer-record/Geometry and release bytes, 12 immediate ABI/status calls and 525 independent true-extent relations. The actual final eight-point block, a single partial block, an exact full-block edge, two incoming allocation byte patterns and fresh/preseeded FPSR are covered. After payload comparison, each new data-address word uses explicit owner correspondence; every other metadata byte is exact. All four freshness rejections are atomic. The control and preimage mechanism remain outside production. This child does not claim the complete SUGEOMETRY body or numerical orography input initialization.

## Operational Grid

The separate entries `md2asm_allocate_operational_orography_owners(geometry)` and `md2asm_release_operational_orography_owners(geometry)` support the actual 9 km grid. Their one-pointer ABI uses `x0` for the complete 17,096-byte Geometry record and `w0` for status. The record must be mapped, eight-byte aligned and nonwrapping. Its borrowed nonhydrostatic flag must be canonical false and remain live. The caller owns the record and all its other fields.

The new initializer requires exactly 17 positions per block, 6,599,680 active points and 388,217 blocks. Its outer array address must be null. It checks these conditions before mutation. The old coarse initializer and release remain unchanged.

Each block has one 384-byte record containing six array descriptions. The source allocates only `OROG`, `OROGL` and `OROGM`. Each has 17 eight-byte values in every complete block and eight values in the final block. The three second-derivative arrays remain unassociated. No inactive row is allocated in this final terrain block.

| Storage | Complete Extent | Bytes |
| --- | --- | ---: |
| Block records | 388,217 records of 384 bytes | 149,075,328 |
| Three terrain arrays | 3 × 6,599,680 eight-byte values | 158,392,320 |
| Total owned storage | Records and numerical arrays | 307,467,648 |

Allocate the outer records first, clear their six data-address words, then allocate the three arrays in source block and field order. This makes 1,164,652 allocation calls. Every array description retains the checked original type, bounds and strides. Leave every numerical payload byte unwritten until its later input producer runs. These entries add no physical calculation or default value.

Return 0 on success, 1 for allocation failure and 2 for an unsupported or already associated input. A partial failure calls the new paired release, which frees every acquired array and the outer records, then clears the outer data address. Partial descriptor bounds can remain. Normal release follows the same source order. The caller must not use freed storage and must release only a valid live or partially acquired operational record.

The new entries retain the original 160-byte initializer and 96-byte release frames, with 16-byte stack alignment. Preserve `x18`, all saved integer registers, the required saved vector halves, FPCR, FPSR and `errno`. Allocation, free and the `errno` address are the only external services. All pointer and allocation-size calculations use 64-bit registers.

The unchanged genuine allocation-tail control passes two actual-grid profiles with different incoming allocation bytes and FPSR values. Complete source and assembly arrays agree across 614,935,296 bytes, including every record and source-unwritten payload. All 68,384 created and released Geometry bytes also agree under explicit address correspondence. Independent checks cover 2,329,302 payload extents and all unallocated derivative arrays. Seven native interface/status calls pass. First and final allocation failures release the whole acquired prefix, one freshness refusal is atomic, and all allocation guards pass. The complete old source remains literal, and independent source/interface review passes. No full geometry, terrain loading, forecast or performance result is claimed.

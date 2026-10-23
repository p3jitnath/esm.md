# Partitioned Operational Upper-Air Loading

This assembly loads the 959 upper-air records for the 9 km, 137-layer case into one process's model buffer. Each process uses its live partition map to select its points from the decoded global fields. The [accepted reader](operational_gridpoint_field_readers.md) and [field mapping](operational_upper_air_initial_state_placement.md) retain their physics, units and exact stored bits. This stage adds integer addressing and ownership of temporary storage.

## Partition And Buffer

The caller supplies a read-only, eight-byte-aligned 32-byte record. The map comes from the live SUMP `NGLOBALINDEX` owner at Geometry byte offset 6648. The local point count comes from `NGPTOT` at offset 7376. A map entry is a one-based index into the packed GRIB values. It is distinct from a rectangular grid index. Retain this map until loading ends.

| Byte Offset | Unsigned 64-Bit Word | Requirement |
| ---: | --- | --- |
| 0 | Local point count $`N`$ | 1 through 6,599,680 |
| 8 | Map address | Four-byte aligned, signed 32-bit entries in 1 through 6,599,680 |
| 16 | Map capacity in bytes | At least $`4N`$ |
| 24 | Block count $`B`$ | $`B=\lceil N/17\rceil`$ |

The output stores 17 columns, 137 layers and nine fields in each block, with columns varying fastest. Its required size is $`167688B`$ bytes. The destination and all consumed input spans are mapped and nonwrapping. The destination aligns to eight bytes and is disjoint from the partition record, map, decoded values and metadata. Unused capacity beyond the required span remains unchanged. The partition producer establishes unique local points and complete distributed coverage. Placement accepts any valid local order.

Slots 0 through 6 copy the active points only. Their padding retains its incoming bytes. Slots 7 and 8 are diagnostic fields and receive positive zero throughout, including padding. A fresh owning caller defines copied-field padding before loading. This routine does not change padding to conceal a mismatch.

## Assembly Interfaces

The application binary interface, or ABI, defines registers, argument order and saved state. `md2asm_place_partitioned_operational_upper_air_fields(values, value_capacity, metadata, metadata_capacity, GFL, GFL_capacity, partition)` uses x0 through x6. Values occupy 50,632,744,960 bytes. Metadata occupies 38,360 bytes, with five signed 64-bit words for each of 959 records. Complete record identities, levels, counts and map indices are checked before any destination store. Return 0 succeeds, 1 refuses a buffer or shape, 2 refuses metadata and 3 refuses a map index. The frame has 96 bytes.

`md2asm_load_partitioned_operational_upper_air_state(path, partition, GFL, capacity)` uses x0 through x3. The readable, zero-terminated path names `ICMGGacflINIUA`. Require FPCR zero, validate the destination, allocate one 50,632,783,320-byte temporary buffer, decode all records, place local values and release the buffer. Return 1 means invalid input or mode, 2 means allocation failure, a reader code plus 16 means decoding failure and a placement code plus 32 means placement refusal. Failed calls preserve the complete output. The frame has 128 bytes.

The private destination validator receives partition, output and output capacity in x0 through x2. On success, x3 through x7 return the block count, local point count, map address, consumed map bytes and required output bytes. It uses no frame or external call.

All three entries preserve x18, required saved integer and vector registers, the floating-point control register FPCR, the floating-point status register FPSR and the C error indicator `errno`. Frames retain 16-byte alignment. Transfers use integer instructions and preserve every copied 64-bit value, including signed zeros. Production calls use direct assembly and public ecCodes and C services. No original OpenIFS routine or saved verification state supplies production input.

## Acceptance

The changed placement checks cover counts 1, 17, 18, 34 and 37, reordered maps, global endpoints, arbitrary incoming bytes and raw exceptional bit patterns. All 3,018,384 complete output bytes agree. Eighteen placement ABI calls and three loader failure calls pass, including protected-output refusals, allocation failure, unsupported floating-point mode and a real wrong-row-list file. Guards, input storage, numerical status and cleanup pass. The independent source and interface review also passes.

The complete four-process file check also passes. Each process decodes all 959 actual records and matches its independent streaming control. All 65,099,835,360 local output bytes agree across the four buffers. Four complete loader ABI calls preserve status, map and partition inputs, guards and cleanup. Each final block has two active columns and fifteen padding columns. These component checks do not establish a complete forecast or performance result. Exact sources, tools, input records and results remain locally under `.runtime/`.

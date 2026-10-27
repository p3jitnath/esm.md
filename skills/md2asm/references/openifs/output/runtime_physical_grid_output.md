# Runtime Physical Grid Output

Fullpos prepares model fields for saved output. These three assembly entries retain the selected HPOS, SCAN2M_HPOS and GRIDFPOS calculations on the model grid. With five snow layers, the request producer expands 103 requests into 121 fields. The supported route uses ECMWF physics with no ocean coupling, horizontal interpolation, climatology replacement or flux fields. User-grid buffer reshaping and FA packing are inactive. Other routes require separate qualification.

## Interface And Storage

The application binary interface, or ABI, follows AArch64 Linux. The entries preserve x18, the required saved registers, a 16-byte aligned stack and the floating-point control register. The table gives incoming stack offsets in bytes, before each entry reserves its own frame.

| Entry | Original address arguments | Hidden character length | Appended context |
| --- | ---: | ---: | ---: |
| `md2asm_runtime_physical_grid_output` | 27 | 152 | 160 |
| `md2asm_runtime_scan2m_hpos` | 19 | None | 88 |
| `md2asm_runtime_hpos` | 29 | None | 168 |

The shared Fullpos context occupies 128 bytes. It supplies physical constants at offset 24, the standard-atmosphere record at 32, the phase-7 partition at 40, the false profiling flag at 80 and the private byte budget at 96. The partition must refer to the same Geometry record as the call.

The block width ranges from 1 to 1,024 points. The positive local point count determines the number of blocks, including the final partial block. The interface supports 1 to 1,639 output fields, 1 to 6 snow layers and 1 to 256 soil layers. Each requested soil layer must exist. Array descriptors, which store addresses, dimensions and strides, must describe the complete consumed buffers. Inputs remain live and separate from output through return.

`PBUF` is a 112-byte GNU rank-three FP64 pointer descriptor whose data pointer is null on entry. FP64 means 64-bit floating point. An optional `P2DFIELDS` or `P3DFIELDS` array remains caller-owned, and the latter retains the original level-times-field count. Otherwise, the parent allocates 8 times the block width times the field count times the block count bytes. The caller releases this allocation after its last reader.

## Calculations And Bounds

Most fields copy the corresponding surface values without changing their units. The live TAFN table maps request codes to fields, while the source `MP` or `MP0` index selects each stored component. Total precipitation adds the large-scale and convective parts in source order. Snow mass and depth sums follow layer order and include positive layer mass. Their ratio gives mean density, with the original first-layer fallback. Repeated density and temperature requests retain their aggregate and layer order. Layer snow mass and liquid water use the original nonnegative maximum. Padding in the final block becomes positive zero. Sea ice and currents use the uncoupled `VF` surface fields on this route.

The HPOS frame occupies 512 bytes plus the next multiple of 16 bytes that contains 32 times the field count plus 24 times the block width. Its maximum is 77,536 bytes. The caller frames occupy 2,304 and 768 bytes. These frames and the complete output must fit the positive private budget, which is at most 64 GiB. One GiB is 1,073,741,824 bytes. HPOS validates its consumed fields before numerical output begins, and the parent publishes the returned descriptor after successful block work.

Success returns 0. Invalid metadata returns 2, output-allocation refusal returns 1, and a child failure after parent progress returns 3 for forecast abort and teardown. Original public GSTATS profiling calls remain in order. Formatted progress text is outside canonical saved-field output. Leaf calls preserve the error indicator `errno`, while enclosing allocation and public-service calls retain their natural effects. No original OpenIFS routine or verification helper supplies a production calculation.

## Accepted Checks

One finite component check passed 41 original and assembly calls across block widths 1, 17, 24 and 1,024, partial blocks, and one, five and six snow layers. It compared 5,447,424 output and nonaddress descriptor bytes exactly, including the full 121-field case. Descriptor addresses were checked through their declared ownership relations. The 26,251,760 input bytes remained unchanged after each call. Independent saved-data checks passed 62,915 snow and precipitation relations using exact rational arithmetic. Six metadata refusals and one allocation refusal preserved public output. Saved registers, floating-point status, guards, allocation release and final process cleanup passed.

The detailed check records and raw files remain local. This evidence accepts the selected component. The complete operational forecast and other Fullpos routes still require their own joined comparisons.

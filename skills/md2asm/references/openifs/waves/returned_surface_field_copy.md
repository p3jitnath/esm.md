# Returned Wave Surface Fields

The original WVRG2XF stage copies values returned by the wave model into atmospheric surface storage. It performs no numerical arithmetic. Preserve every input bit, including signed zero and NaN payloads. The [wave formulation](../../../../../formulations/openifs/waves/ocean_waves.md) defines the physical quantities and their units.

`md2asm_store_operational_wave_surface_fields(surface,surface_bytes,fields,fields_bytes,field_count,point_count,block_width)` uses x0 through x6. Surface is an 18,224-byte TSURF record with its live SD_WS and YSD_WS descriptors. A descriptor records an array's address, shape and strides. Input values form a contiguous column-major array with point_count rows and field_count columns. The caller keeps the complete descriptors and their backing owners mapped and live until return. Ranges are eight-byte aligned, nonwrapping and disjoint.

The accepted destination descriptor has lower bounds 1 and dense dimensions block_width, surface field count and block count. Its field descriptions contain 64-byte records, each with an MP destination-column index. Each consumed index must lie within the destination field count. Support 1 through 9 returned fields, block widths 1 through 1,024 and 0 through 6,599,680 local points, within the destination capacity. Copy only physical points and selected fields. Preserve unused columns, final-block padding, input values and metadata.

Return 0 after copying or 2 before mutation on invalid capacities, maps, shape or overlap. The leaf has a 96-byte aligned frame, no allocation and no imports. It preserves x18, saved registers, FPCR, arithmetic flags and the system error value. FPCR must be zero. Integer loads and stores preserve the complete value words.

Four original/native comparisons pass for the actual 1,649,920-point three-field shape, a remapped final block, an empty array and block width 1. Every copied word is checked independently, and all 39,599,568 complete target-owner bytes agree. Status, guards and atomic refusal checks pass. Full wave coupling and complete forecast acceptance remain separate.

The [canonical assembly source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/waves/returned_surface_field_copy.S) is shared by the [runtime wave-return wrapper](runtime_wave_surface_return.md). Its original profiling boundaries and selected disabled-hook checks are qualified separately, while this complete bit-copy object stays unchanged.

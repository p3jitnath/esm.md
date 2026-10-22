/* Complete post-SUALMP2 SUMP maps; x0 Geometry[17096], x1 int32 settings[7].
 * Caller owns all descriptors and payloads. This child owns one IGLOBAL heap.
 * Contract: skills/md2asm/references/openifs/setup/operational_serial_grid_maps.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_serial_grid_maps
.type md2asm_initialize_operational_serial_grid_maps,%function
md2asm_initialize_operational_serial_grid_maps:
 cbz x0,.Lgm_bad
 cbz x1,.Lgm_bad
 tst x0,#7
 b.ne .Lgm_bad
 tst x1,#3
 b.ne .Lgm_bad
 mov x9,#0
.Lgm_settings:
 ldr w10,[x1,x9,lsl#2]
 cmp w10,#1
 b.ne .Lgm_bad
 add x9,x9,#1
 cmp x9,#7
 b.lo .Lgm_settings
 adr x9,.Lgm_fields
 mov x10,#0
.Lgm_fields_loop:
 add x11,x9,x10,lsl#3
 ldp w12,w13,[x11]
 ldr w14,[x0,x12]
 cmp w14,w13
 b.ne .Lgm_bad
 add x10,x10,#1
 cmp x10,#18
 b.lo .Lgm_fields_loop
 /* Canonical complete output and consumed input descriptors. */
 adr x9,.Lgm_descriptors
 mov x10,#0
.Lgm_descriptors_loop:
 add x11,x9,x10,lsl#4
 ldp w12,w13,[x11]
 ldp w14,w15,[x11,#8]
 add x12,x0,x12
 ldr x16,[x12]
 cbz x16,.Lgm_bad
 tst x16,#3
 b.ne .Lgm_bad
 ldr x16,[x12,#16]
 cmp x16,#4
 b.ne .Lgm_bad
 ldr x16,[x12,#32]
 cmp x16,#4
 b.ne .Lgm_bad
 ldrsw x17,[x11,#4]
 ldr x16,[x12,#48]
 cmp x16,x17
 b.ne .Lgm_bad
 ldrsw x17,[x11,#8]
 ldr x16,[x12,#56]
 cmp x16,x17
 b.ne .Lgm_bad
 mov x17,#0x100
 add x17,x17,x15
 lsl x17,x17,#32
 ldr x16,[x12,#24]
 cmp x16,x17
 b.ne .Lgm_bad
 cmp w15,#2
 b.ne .Lgm_next_descriptor
 /* Rank two: source either17x388217 or(-1:2562)x1. */
 cmp w13,#1
 b.ne .Lgm_halo_descriptor
 mov x17,#17
 ldr x16,[x12,#64]
 cmp x16,x17
 b.ne .Lgm_bad
 mov x17,#0xec79
 movk x17,#5,lsl#16
 ldr x16,[x12,#80]
 cmp x16,x17
 b.ne .Lgm_bad
 b .Lgm_rank2_lower
.Lgm_halo_descriptor:
 mov x17,#2564
 ldr x16,[x12,#64]
 cmp x16,x17
 b.ne .Lgm_bad
 ldr x16,[x12,#80]
 cmp x16,#1
 b.ne .Lgm_bad
.Lgm_rank2_lower:
 ldr x16,[x12,#72]
 cmp x16,#1
 b.ne .Lgm_bad
.Lgm_next_descriptor:
 add x10,x10,#1
 cmp x10,#14
 b.lo .Lgm_descriptors_loop
 /* Source query scalars and active row agreement, before allocation/writes. */
 ldr x9,[x0,#6456]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgm_bad
 ldr x9,[x0,#6520]
 ldr w9,[x9]
 cmp w9,#2560
 b.ne .Lgm_bad
 ldr x9,[x0,#6264]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgm_bad
 ldr x9,[x0,#5896]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgm_bad
 ldr x9,[x0,#7640]
 add x9,x9,#8
 ldr x10,[x0,#6088]
 add x10,x10,#8
 ldr x11,[x0,#6176]
 add x11,x11,#8
 mov x12,#0
 mov x13,#0
 mov w17,#5136
.Lgm_rows_guard:
 ldr w14,[x9,x12,lsl#2]
 cmp w14,#1
 b.lt .Lgm_bad
 cmp w14,w17
 b.gt .Lgm_bad
 ldr w15,[x10,x12,lsl#2]
 cmp w15,#1
 b.ne .Lgm_bad
 ldr w15,[x11,x12,lsl#2]
 cmp w15,w14
 b.ne .Lgm_bad
 add x13,x13,x14
 add x12,x12,#1
 cmp x12,#2560
 b.lo .Lgm_rows_guard
 mov x14,#0xb400
 movk x14,#0x64,lsl#16
 cmp x13,x14
 b.ne .Lgm_bad
 sub sp,sp,#256
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#104]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 bl __errno_location
 mov x27,x0
 ldr w28,[x27]
 mov x0,#0x8000
 movk x0,#0x322,lsl#16
 bl malloc
 cbz x0,.Lgm_allocation_failure
 mov x21,x0
 ldr x22,[x19,#7640]
 add x22,x22,#8
 /* Original MYLEVS then MYLATS. */
 ldr x25,[x19,#5960]
 ldr x9,[x19,#5896]
 ldr w10,[x9]
 mov x11,#0
.Lgm_levels:
 add w12,w10,w11
 str w12,[x25,x11,lsl#2]
 add x11,x11,#1
 cmp x11,#137
 b.lo .Lgm_levels
 ldr x25,[x19,#7144]
 ldr x9,[x19,#6456]
 ldr w10,[x9]
 mov x11,#0
.Lgm_latitudes:
 add w12,w10,w11
 str w12,[x25,x11,lsl#2]
 add x11,x11,#1
 cmp x11,#2560
 b.lo .Lgm_latitudes
 /* Every rectangular workspace cell is source-defined zero. */
 mov x9,#0
 mov x10,#0x8000
 movk x10,#0x322,lsl#16
.Lgm_zero_rectangle:
 add x11,x21,x9
 stp xzr,xzr,[x11]
 add x9,x9,#16
 cmp x9,x10
 b.lo .Lgm_zero_rectangle
 mov x23,#0
 mov w24,#1
.Lgm_fill_global_row:
 mov x9,#5136
 mul x10,x23,x9
 add x10,x21,x10,lsl#2
 ldr w11,[x22,x23,lsl#2]
 mov x12,#0
.Lgm_fill_global_column:
 str w24,[x10,x12,lsl#2]
 add w24,w24,#1
 add x12,x12,#1
 cmp x12,x11
 b.lo .Lgm_fill_global_column
 add x23,x23,#1
 cmp x23,#2560
 b.lo .Lgm_fill_global_row
 /* Forward local/global map loop, keeping ragged source row order. */
 ldr x25,[x19,#6648]
 ldr x26,[x19,#6712]
 mov x23,#0
 mov x24,#0
.Lgm_forward_row:
 mov x9,#5136
 mul x10,x23,x9
 add x10,x21,x10,lsl#2
 ldr w11,[x22,x23,lsl#2]
 mov x12,#0
 add w14,w23,#1
.Lgm_forward_column:
 ldr w13,[x10,x12,lsl#2]
 str w13,[x25,x24,lsl#2]
 str w14,[x26,x24,lsl#2]
 add x24,x24,#1
 add x12,x12,#1
 cmp x12,x11
 b.lo .Lgm_forward_column
 add x23,x23,#1
 cmp x23,#2560
 b.lo .Lgm_forward_row
 /* Source initializes all processor words before its inverse-map pass. */
 ldr x25,[x19,#6776]
 ldr x26,[x19,#6840]
 mov x9,#0
 mov x10,#0xb400
 movk x10,#0x64,lsl#16
.Lgm_zero_processors:
 str wzr,[x25,x9,lsl#2]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lgm_zero_processors
 mov x23,#0
 mov w24,#0
.Lgm_inverse_row:
 mov x9,#5136
 mul x10,x23,x9
 add x10,x21,x10,lsl#2
 ldr w11,[x22,x23,lsl#2]
 mov x12,#0
 mov w14,#1
.Lgm_inverse_column:
 ldr w13,[x10,x12,lsl#2]
 sub w13,w13,#1
 str w14,[x25,w13,uxtw#2]
 add w24,w24,#1
 str w24,[x26,w13,uxtw#2]
 add x12,x12,#1
 cmp x12,x11
 b.lo .Lgm_inverse_column
 add x23,x23,#1
 cmp x23,#2560
 b.lo .Lgm_inverse_row
 /* Both complete blocked owners include nine sentinel padding words. */
 ldr x25,[x19,#6904]
 ldr x26,[x19,#6992]
 mov x9,#0
 mov x10,#0xb409
 movk x10,#0x64,lsl#16
 mov w11,#0x7961
 movk w11,#0xfffe,lsl#16
.Lgm_block_sentinels:
 str w11,[x25,x9,lsl#2]
 str w11,[x26,x9,lsl#2]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lgm_block_sentinels
 mov x23,#0
 mov x24,#0
 ldr x15,[x19,#7144]
.Lgm_block_row:
 ldr w10,[x15,x23,lsl#2]
 ldr w11,[x22,x23,lsl#2]
 mov w12,#1
.Lgm_block_column:
 str w10,[x25,x24,lsl#2]
 str w12,[x26,x24,lsl#2]
 add x24,x24,#1
 add w12,w12,#1
 cmp w12,w11
 b.ls .Lgm_block_column
 add x23,x23,#1
 cmp x23,#2560
 b.lo .Lgm_block_row
 sub x9,x24,#1
 mov x10,#17
 udiv x9,x9,x10
 add x9,x9,#1
 ldr w10,[x19,#5160]
 cmp x9,x10
 b.ne .Lgm_source_invariant
 mov x0,x21
 bl free
 mov w0,#0
 b .Lgm_restore
.Lgm_allocation_failure:
 mov w0,#1
.Lgm_restore:
 str w28,[x27]
 ldp x9,x10,[sp,#104]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.Lgm_source_invariant:
 brk #1
.Lgm_bad:
 mov w0,#2
 ret
.size md2asm_initialize_operational_serial_grid_maps,.-md2asm_initialize_operational_serial_grid_maps
.section .rodata
.p2align 3
.Lgm_fields:
 .word 4872,2560,4892,1,4908,2560,4936,5136
 .word 5144,17,5160,388217,5172,1279,5224,137
 .word 5228,137,5208,1279,7232,0,7244,0
 .word 7376,6599680,7380,6599680,7384,6599680,7388,6599680
 .word 7228,1,4876,2560
.Lgm_descriptors:
 .word 5960,1,137,1
 .word 7144,1,2560,1
 .word 6648,1,6599680,1
 .word 6712,1,6599680,1
 .word 6776,1,6599680,1
 .word 6840,1,6599680,1
 .word 6904,1,17,2
 .word 6992,1,17,2
 .word 6088,-1,2562,2
 .word 6176,-1,2562,2
 .word 7640,-1,2562,1
 .word 5896,1,2,1
 .word 6456,1,1,1
 .word 6520,1,1,1
.section .note.GNU-stack,"",%progbits

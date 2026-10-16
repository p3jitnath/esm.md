/* Contract: skills/md2asm/references/openifs/setup/serial_partition_map_contract.md.
 * x0 owned Geometry[17096], x1 owned stream[872], x2 serial int32 settings[7].
 * Own all34 SUMP arrays and selected stream copies. Frame9216B aligned16.
 */
.arch armv8.2-a
.text
.macro SLOT n, off
 mov x9,#\off
 add x9,x19,x9
 str x9,[sp,#128+8*\n]
.endm
.macro DATA n, off
 ldr x9,[x19,#\off]
 str x9,[sp,#128+8*\n]
.endm
.p2align 4
.global md2asm_initialize_serial_partition_maps
.type md2asm_initialize_serial_partition_maps,%function
md2asm_initialize_serial_partition_maps:
 cbz x0,.Lmap_bad
 cbz x1,.Lmap_bad
 cbz x2,.Lmap_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lmap_bad
 tst x2,#3
 b.ne .Lmap_bad
 mov x9,#0
.Lmap_check_serial:
 ldr w10,[x2,x9,lsl#2]
 cmp w10,#1
 b.ne .Lmap_bad
 add x9,x9,#1
 cmp x9,#7
 b.lo .Lmap_check_serial
 ldr x9,[x0]
 cbz x9,.Lmap_bad
 ldr w9,[x9]
 cbnz w9,.Lmap_bad
 ldr w9,[x0,#5172]
 cmp w9,#21
 b.ne .Lmap_bad
 ldr w9,[x0,#5208]
 cmp w9,#21
 b.ne .Lmap_bad
 ldr w9,[x0,#5176]
 cbnz w9,.Lmap_bad
 ldr w9,[x0,#4872]
 cmp w9,#32
 b.ne .Lmap_bad
 ldr w9,[x0,#4936]
 cmp w9,#64
 b.ne .Lmap_bad
 ldr w9,[x0,#5144]
 cmp w9,#24
 b.ne .Lmap_bad
 ldr w9,[x0,#5164]
 cbnz w9,.Lmap_bad
 ldr w9,[x0,#5224]
 cmp w9,#19
 b.ne .Lmap_bad
 ldr w9,[x0,#5168]
 cmp w9,#1
 b.lt .Lmap_bad
 ldr x9,[x0,#7640]
 cbz x9,.Lmap_bad
 ldr x10,[x0,#7688]
 mov x11,#1
 sub x10,x11,x10
 add x9,x9,x10,lsl#2
 mov x10,#0
.Lmap_global_counts:
 ldr w11,[x9,x10,lsl#2]
 cmp w11,#64
 b.ne .Lmap_bad
 add x10,x10,#1
 cmp x10,#32
 b.lo .Lmap_global_counts
 ldr x9,[x1,#64]
 ldr x10,[x1,#144]
 orr x9,x9,x10
 cbnz x9,.Lmap_bad
 adr x9,.Lmap_owned_offsets
 mov x10,#0
.Lmap_fresh_owners:
 ldr w11,[x9,x10,lsl#2]
 ldr x11,[x0,x11]
 cbnz x11,.Lmap_bad
 add x10,x10,#1
 cmp x10,#34
 b.lo .Lmap_fresh_owners
 mov x9,#9216
 sub sp,sp,x9
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x1,x21
 mov x2,#0
 bl md2asm_allocate_serial_partition_arrays
 cbnz w0,.Lmap_fail
 /* Source vertical partition, selected one-processor domain. */
 ldr w9,[x19,#5224]
 ldr x10,[x19,#5832]
 stp w9,wzr,[x10]
 str w9,[x19,#5228]
 str w9,[x19,#5232]
 str w9,[x19,#5236]
 mov w9,#1
 ldr x10,[x19,#6024]
 str w9,[x10]
 str w9,[x19,#7208]
 bl .Lmap_zero_arguments
 SLOT 0,5168
 SLOT 1,5196
 SLOT 2,5200
 SLOT 4,5204
 SLOT 5,5212
 SLOT 12,5256
 SLOT 13,7248
 SLOT 14,5384
 SLOT 15,5448
 SLOT 16,7312
 add x0,sp,#128
 bl md2asm_call_public_transform_inquiry
 bl .Lmap_zero_arguments
 SLOT 0,5208
 SLOT 1,5208
 str x21,[sp,#144]
 str x21,[sp,#152]
 DATA 6,5320
 add x9,sp,#792
 str x9,[sp,#184]
 add x9,sp,#704
 str x9,[sp,#224]
 add x0,sp,#128
 bl md2asm_call_public_spectral_distribution
 ldr w9,[sp,#792]
 str w9,[x19,#5216]
 bl .Lmap_zero_arguments
 SLOT 0,5168
 SLOT 6,7376
 SLOT 7,7388
 SLOT 8,7384
 SLOT 9,7392
 SLOT 17,6456
 SLOT 18,6520
 SLOT 19,7232
 SLOT 20,6392
 SLOT 21,6264
 SLOT 22,6328
 SLOT 23,7244
 SLOT 34,7080
 mov x9,#6088
 add x1,x19,x9
 add x0,sp,#504
 bl .Lmap_section
 add x9,sp,#504
 str x9,[sp,#320]
 mov x9,#6176
 add x1,x19,x9
 add x0,sp,#592
 bl .Lmap_section
 add x9,sp,#592
 str x9,[sp,#328]
 add x0,sp,#128
 bl md2asm_call_public_transform_inquiry
 bl .Lmap_zero_arguments
 SLOT 0,5168
 /* KULTPP is an assumed-shape public argument, so pass a rank-one descriptor. */
 add x9,sp,#796
 str x9,[sp,#816]
 mov x9,#-1
 str x9,[sp,#824]
 mov x9,#4
 str x9,[sp,#832]
 str x9,[sp,#848]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[sp,#840]
 mov x9,#1
 str x9,[sp,#856]
 str x9,[sp,#864]
 str x9,[sp,#872]
 add x9,sp,#816
 str x9,[sp,#336]
 SLOT 27,5512
 add x0,sp,#128
 bl md2asm_call_public_transform_inquiry
 /* Local latitude dimensions and active limits. */
 ldr w9,[sp,#796]
 str w9,[x19,#4876]
 mov w10,#1
 str w10,[x19,#4892]
 str w10,[x19,#4928]
 ldr x10,[x19,#6520]
 ldr w11,[x10]
 ldr w12,[x19,#7232]
 sub w12,w11,w12
 str w12,[x19,#4908]
 ldr x10,[x19,#6456]
 ldr w13,[x10]
 ldr w14,[x19,#4924]
 add w15,w13,w9
 sub w16,w14,w13
 add w16,w16,#1
 cmp w15,w14
 csel w9,w9,w16,le
 str w9,[x19,#4932]
 str w13,[x19,#7236]
 str w11,[x19,#7240]
 /* Selected actual query covers every longitude on all32 latitudes. */
 ldr x10,[x19,#5576]
 mov w9,#1
 ldr w11,[x19,#5200]
 add w12,w11,#1
 stp w9,w12,[x10]
 /* Source whole-column partition. Retain its reverse accumulation order. */
 ldr x10,[x19,#5704]
 mov w9,#1
 ldr w12,[x19,#5212]
 add w13,w12,#1
 stp w9,w13,[x10]
 mov w14,#0
 sub w12,w12,#1
 add x10,sp,#704
.Lmap_column_sum:
 ldr w13,[x10,w12,uxtw#2]
 mov w15,#22
 sub w15,w15,w13
 add w14,w14,w15,lsl#1
 subs w12,w12,#1
 b.pl .Lmap_column_sum
 ldr x10,[x19,#5640]
 add w14,w14,#1
 stp w9,w14,[x10]
 ldr x10,[x19,#5768]
 mov w9,#-999
 mov x11,#0
.Lmap_start_sentinel:
 str w9,[x10,x11,lsl#2]
 add x11,x11,#1
 cmp x11,#22
 b.lo .Lmap_start_sentinel
 add x11,sp,#704
 ldr w12,[x19,#5212]
 mov w9,#1
 mov x13,#0
.Lmap_spectral_starts:
 ldr w14,[x11,x13,lsl#2]
 str w9,[x10,w14,uxtw#2]
 mov w15,#22
 sub w15,w15,w14
 add w9,w9,w15,lsl#1
 add x13,x13,#1
 cmp x13,x12
 b.lo .Lmap_spectral_starts
 ldr x10,[x19,#5896]
 mov w9,#1
 ldr w11,[x19,#5224]
 add w12,w11,#1
 stp w9,w12,[x10]
 str w9,[x19,#7228]
 ldr x10,[x19,#6584]
 mov x12,#0
.Lmap_level_sets:
 str w9,[x10,x12,lsl#2]
 add x12,x12,#1
 cmp x12,x11
 b.lo .Lmap_level_sets
 /* Preserve the source's selected stream metadata stage here. */
 mov x0,x20
 mov x1,x19
 add x2,x21,#20
 bl md2asm_initialize_stream_geometry_metadata
 cbnz w0,.Lmap_fail
 ldr x10,[x19,#5576]
 ldp w9,w11,[x10]
 sub w11,w11,w9
 str w11,[x19,#7212]
 ldr x10,[x19,#5640]
 ldp w9,w12,[x10]
 sub w12,w12,w9
 str w12,[x19,#7216]
 str wzr,[x19,#7224]
 /* Selected global SUOPTPROMA: optimization was disabled by NPROMA=-24. */
 ldr w9,[x19,#5144]
 str w9,[x19,#5148]
 mov w10,#1
 str w10,[x19,#5156]
 ldr w10,[x19,#7376]
 sub w11,w10,#1
 sdiv w11,w11,w9
 add w11,w11,#1
 str w11,[x19,#5160]
 mov x0,x19
 mov x1,x21
 mov x2,#1
 bl md2asm_allocate_serial_partition_arrays
 cbnz w0,.Lmap_fail
 ldr w9,[x19,#7376]
 str w9,[x19,#7380]
 mov x0,x19
 mov x1,x21
 mov x2,#2
 bl md2asm_allocate_serial_partition_arrays
 cbnz w0,.Lmap_fail
 /* MYLEVS and MYLATS. */
 ldr x9,[x19,#5960]
 ldr w10,[x19,#5228]
 mov x11,#0
.Lmap_levels:
 add w12,w11,#1
 str w12,[x9,x11,lsl#2]
 add x11,x11,#1
 cmp x11,x10
 b.lo .Lmap_levels
 ldr x9,[x19,#7144]
 ldr w10,[x19,#4908]
 mov x11,#0
.Lmap_latitudes:
 add w12,w11,#1
 str w12,[x9,x11,lsl#2]
 add x11,x11,#1
 cmp x11,x10
 b.lo .Lmap_latitudes
 /* Source IGLOBAL is temporary, zeroed then filled in global row order. */
 add x22,sp,#1024
 mov x9,#0
.Lmap_zero_global:
 str wzr,[x22,x9,lsl#2]
 add x9,x9,#1
 cmp x9,#2048
 b.lo .Lmap_zero_global
 mov x9,#0
 mov w10,#1
.Lmap_global:
 str w10,[x22,x9,lsl#2]
 add w10,w10,#1
 add x9,x9,#1
 cmp x9,#2048
 b.lo .Lmap_global
 /* Assemble all local/global maps from active source bounds. */
 ldr x23,[x19,#6648]
 ldr x24,[x19,#6712]
 ldr x25,[x19,#6776]
 ldr x26,[x19,#6840]
 mov x9,#0
.Lmap_zero_processors:
 str wzr,[x25,x9,lsl#2]
 add x9,x9,#1
 cmp x9,#2048
 b.lo .Lmap_zero_processors
 mov x9,#0
 mov w10,#1
.Lmap_points:
 ldr w11,[x22,x9,lsl#2]
 str w11,[x23,x9,lsl#2]
 lsr w12,w9,#6
 add w12,w12,#1
 str w12,[x24,x9,lsl#2]
 sub w11,w11,#1
 str w10,[x25,w11,uxtw#2]
 add w12,w9,#1
 str w12,[x26,w11,uxtw#2]
 add x9,x9,#1
 cmp x9,#2048
 b.lo .Lmap_points
 /* Fill complete blocked owners first, then all active latitude/longitude rows. */
 ldr x23,[x19,#6904]
 ldr x24,[x19,#6992]
 ldr w10,[x19,#5160]
 ldr w11,[x19,#5144]
 mul w10,w10,w11
 mov w12,#0x7961
 movk w12,#0xfffe,lsl#16
 mov x9,#0
.Lmap_block_sentinels:
 str w12,[x23,x9,lsl#2]
 str w12,[x24,x9,lsl#2]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lmap_block_sentinels
 mov x9,#0
.Lmap_block_points:
 lsr w10,w9,#6
 add w10,w10,#1
 and w11,w9,#63
 add w11,w11,#1
 str w10,[x23,x9,lsl#2]
 str w11,[x24,x9,lsl#2]
 add x9,x9,#1
 cmp x9,#2048
 b.lo .Lmap_block_points
 mov w0,#0
 b .Lmap_return
.Lmap_fail:
 mov w23,w0
 mov x0,x20
 bl md2asm_release_stream_geometry_metadata
 mov x0,x19
 mov x1,#2
 bl md2asm_release_serial_partition_arrays
 mov x0,x19
 mov x1,#1
 bl md2asm_release_serial_partition_arrays
 mov x0,x19
 mov x1,#0
 bl md2asm_release_serial_partition_arrays
 mov w0,w23
.Lmap_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 mov x9,#9216
 add sp,sp,x9
 ret
.Lmap_bad:
 mov w0,#2
 ret
.size md2asm_initialize_serial_partition_maps,.-md2asm_initialize_serial_partition_maps
/* Local fixed argument preparation; no callback or original method table. */
.Lmap_zero_arguments:
 mov x9,#0
 add x10,sp,#128
.Lmap_zero_loop:
 str xzr,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#47
 b.lo .Lmap_zero_loop
 ret
/* Copy a true contiguous rank-two descriptor as its source section (1:,:). */
.Lmap_section:
 ldp x9,x10,[x1]
 ldp x11,x12,[x1,#16]
 stp x9,x10,[x0]
 stp x11,x12,[x0,#16]
 ldp x9,x10,[x1,#32]
 ldp x11,x12,[x1,#48]
 stp x9,x10,[x0,#32]
 stp x11,x12,[x0,#48]
 ldp x9,x10,[x1,#64]
 ldr x11,[x1,#80]
 stp x9,x10,[x0,#64]
 str x11,[x0,#80]
 ldr x9,[x1]
 ldr x10,[x1,#48]
 mov x11,#1
 sub x10,x11,x10
 add x9,x9,x10,lsl#2
 str x9,[x0]
 ldr x9,[x1,#64]
 neg x9,x9
 sub x9,x9,#1
 str x9,[x0,#8]
 str x11,[x0,#48]
 ret
.p2align 4
.global md2asm_release_serial_partition_maps
.type md2asm_release_serial_partition_maps,%function
md2asm_release_serial_partition_maps:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x0,x20
 bl md2asm_release_stream_geometry_metadata
 mov x21,x0
 mov x0,x19
 mov x1,#2
 bl md2asm_release_serial_partition_arrays
 orr x21,x21,x0
 mov x0,x19
 mov x1,#1
 bl md2asm_release_serial_partition_arrays
 orr x21,x21,x0
 mov x0,x19
 mov x1,#0
 bl md2asm_release_serial_partition_arrays
 orr x0,x21,x0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_serial_partition_maps,.-md2asm_release_serial_partition_maps
.section .rodata
.p2align 2
.Lmap_owned_offsets:
 .word 5832,6024,5256,5320,5384,7248,5448,7312,5512,5576,5640,5704,5768,5896,6088,6176,6264,6328,6392,7080,6456,6520,6584,4968,5056,7392,6992,6904,5960,7144,6648,6712,6776,6840
.section .note.GNU-stack,"",%progbits

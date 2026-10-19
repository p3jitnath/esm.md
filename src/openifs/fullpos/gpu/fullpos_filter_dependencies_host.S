#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_filter_controls
.type md2asm_initialize_selected_fullpos_filter_controls,%function
md2asm_initialize_selected_fullpos_filter_controls:
 cbz x0,.Lfilter_control_early_bad
 cbz x1,.Lfilter_control_early_bad
 cmp x1,#64,lsl#12
 b.hi .Lfilter_control_early_bad
 cbz x2,.Lfilter_control_early_bad
 tst x2,#7
 b.ne .Lfilter_control_early_bad
 mov x9,#8424
 cmp x3,x9
 b.lo .Lfilter_control_early_bad
 adds x10,x0,x1
 b.cs .Lfilter_control_early_bad
 adds x11,x2,x9
 b.cs .Lfilter_control_early_bad
 cmp x0,x11
 b.hs .Lfilter_control_distinct
 cmp x2,x10
 b.lo .Lfilter_control_early_bad
.Lfilter_control_distinct:
 stp x29,x30,[sp,#-32]!
 stp x19,x18,[sp,#16]
 mov x29,sp
 mov x19,x2
 adr x2,.Lfilter_group
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lfilter_control_return
 mov w9,#1
 str w9,[x19]
 str wzr,[x19,#4]
 str wzr,[x19,#8]
 str w9,[x19,#12]
 mov w9,#12
 str w9,[x19,#16]
 str wzr,[x19,#20]
 add x9,x19,#24
 mov x10,#15
.Lfilter_zero_cutoff:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lfilter_zero_cutoff
 adr x9,.Lfilter_constants
 ldp x10,x11,[x9]
 stp x10,x11,[x19,#88]
 ldr x10,[x9,#16]
 str x10,[x19,#104]
 add x9,x19,#112
 mov x10,#15
 mov x11,#0x3ff0000000000000
.Lfilter_selectivity:
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lfilter_selectivity
 add x9,x19,#232
 mov x10,#8192
 mov w11,#32
.Lfilter_blank_names:
 strb w11,[x9],#1
 subs x10,x10,#1
 b.ne .Lfilter_blank_names
 adr x9,.Lfilter_names
 add x10,x19,#232
 add x11,x19,#488
 mov x12,#0
.Lfilter_fixed_names:
 ldrb w13,[x9,x12]
 strb w13,[x10,x12]
 add x14,x9,#7
 ldrb w13,[x14,x12]
 strb w13,[x11,x12]
 add x12,x12,#1
 cmp x12,#7
 b.lo .Lfilter_fixed_names
 mov w0,#0
.Lfilter_control_return:
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Lfilter_control_early_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_fullpos_filter_controls,.-md2asm_initialize_selected_fullpos_filter_controls
.global md2asm_initialize_selected_fullpos_fields
.type md2asm_initialize_selected_fullpos_fields,%function
md2asm_initialize_selected_fullpos_fields:
 mov x9,#62384
 cmp x1,x9
 b.lo .Lfields_early_bad
 cmp x4,#1424
 b.lo .Lfields_early_bad
 cbz x0,.Lfields_early_bad
 cbz x2,.Lfields_early_bad
 cbz x3,.Lfields_early_bad
 orr x10,x0,x2
 orr x10,x10,x3
 tst x10,#7
 b.ne .Lfields_early_bad
 adds x11,x0,x9
 b.cs .Lfields_early_bad
 adds x12,x2,#32
 b.cs .Lfields_early_bad
 adds x13,x3,#1424
 b.cs .Lfields_early_bad
 sub sp,sp,#1648
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#1632]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x3
 add x22,sp,#96
 add x9,sp,#1520
 stp x0,x11,[x9]
 stp x2,x12,[x9,#16]
 stp x3,x13,[x9,#32]
 mov x28,#3
 str wzr,[sp,#1608]
 ldp w9,w10,[x20]
 sub w11,w9,#1
 cmp w11,#199
 b.hi .Lfields_bad
 cmp w10,#200
 b.hi .Lfields_bad
 ldp w9,w10,[x20,#8]
 orr w9,w9,w10
 cbnz w9,.Lfields_bad
 ldp x9,x10,[x20,#16]
 cbnz x9,.Lfields_optional_vab
 cbnz x10,.Lfields_bad
 b .Lfields_ranges
.Lfields_optional_vab:
 tst x9,#7
 b.ne .Lfields_bad
 cmp x10,#512
 b.lo .Lfields_bad
 adds x10,x9,#512
 b.cs .Lfields_bad
 add x11,sp,#1568
 stp x9,x10,[x11]
 mov x28,#4
 add x9,x9,#64
 ldp x10,x11,[x9]
 cbz x10,.Lfields_bad
 cbnz x11,.Lfields_bad
 ldp x10,x11,[x9,#16]
 cmp x10,#8
 b.ne .Lfields_bad
 mov x12,#0x301
 lsl x12,x12,#32
 cmp x11,x12
 b.ne .Lfields_bad
 ldp x10,x11,[x9,#32]
 cmp x10,#8
 b.ne .Lfields_bad
 cmp x11,#1
 b.ne .Lfields_bad
 ldp x10,x11,[x9,#48]
 cbnz x10,.Lfields_bad
 sub x10,x11,#1
 cmp x10,#199
 b.hi .Lfields_bad
 str w11,[sp,#1608]
.Lfields_ranges:
 mov x9,#0
.Lfields_range_outer:
 add x10,sp,#1520
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,x9,#1
.Lfields_range_inner:
 cmp x13,x28
 b.hs .Lfields_range_next
 add x10,sp,#1520
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Lfields_range_distinct
 cmp x14,x12
 b.lo .Lfields_bad
.Lfields_range_distinct:
 add x13,x13,#1
 b .Lfields_range_inner
.Lfields_range_next:
 add x9,x9,#1
 add x10,x9,#1
 cmp x10,x28
 b.lo .Lfields_range_outer
 mov x9,#0
.Lfields_fresh:
 add x10,x21,x9,lsl#6
 ldr x10,[x10]
 cbnz x10,.Lfields_bad
 add x9,x9,#1
 cmp x9,#21
 b.lo .Lfields_fresh
 mov x9,#56636
 ldr w10,[x19,x9]
 cbnz w10,.Lfields_bad
 mov x9,#0
.Lfields_copy_record_in:
 add x10,x21,x9
 ldp x11,x12,[x10]
 add x10,x22,x9
 stp x11,x12,[x10]
 add x9,x9,#16
 cmp x9,#1424
 b.lo .Lfields_copy_record_in
 add x9,x22,#1344
 mov x10,#19
.Lfields_zero_counts:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lfields_zero_counts
 mov x9,#50048
 add x9,x19,x9
 add x10,x22,#1372
 mov x11,#7
.Lfields_request_counts:
 ldr w12,[x9],#4
 cmp w12,#454
 b.hi .Lfields_bad
 str w12,[x10],#4
 subs x11,x11,#1
 b.ne .Lfields_request_counts
 ldr w12,[x9]
 cmp w12,#212
 b.hi .Lfields_bad
 str w12,[x22,#1404]
 adr x24,.Lfield_scan_rows
 mov x23,#0
.Lfields_scan_row:
 ldp w9,w26,[x24]
 ldp w27,w10,[x24,#8]
 ldr w2,[x24,#16]
 ldr w28,[x22,x10]
 add x25,x19,x9
 cmp w2,#3
 b.eq .Lfields_scan_integer_levels
 mov x0,x25
 mov x1,x26
 bl .Lfield_scan_real
 cbnz w1,.Lfields_bad
 b .Lfields_level_count
.Lfields_scan_integer_levels:
 ldr w9,[x25]
 cmn w9,#99
 b.ne .Lfields_scan_integer_loop_start
 cbz w28,.Lfields_bad
 ldr w0,[x20]
 b .Lfields_level_count
.Lfields_scan_integer_loop_start:
 mov x0,#0
.Lfields_scan_integer_loop:
 cmp x0,x26
 b.hs .Lfields_level_count
 ldr w9,[x25,x0,lsl#2]
 tbnz w9,#31,.Lfields_level_count
 add x0,x0,#1
 b .Lfields_scan_integer_loop
.Lfields_level_count:
 cmp w28,#0
 csel w0,wzr,w0,eq
 str w0,[x22,x27]
 add x24,x24,#20
 add x23,x23,#1
 cmp x23,#7
 b.lo .Lfields_scan_row
 ldr w28,[sp,#1608]
 cbz w28,.Lfields_allocations
 ldr w10,[x22,#1364]
 cmp w10,w28
 b.hi .Lfields_bad
 mov x9,#49248
 add x9,x19,x9
 ldr w11,[x9]
 cmn w11,#99
 b.eq .Lfields_allocations
 mov x11,#0
.Lfields_vab_level_check:
 cmp x11,x10
 b.hs .Lfields_allocations
 ldr w12,[x9,x11,lsl#2]
 sub w12,w12,#1
 cmp w12,w28
 b.hs .Lfields_bad
 add x11,x11,#1
 b .Lfields_vab_level_check
.Lfields_allocations:
 mov x23,#0
 adr x24,.Lfield_owner_rows
.Lfields_allocate_owner:
 ldp w9,w10,[x24]
 ldr w26,[x22,x10]
 ldr w11,[x24,#8]
 mul x0,x26,x11
 cmp x0,#1
 mov x12,#1
 csel x0,x0,x12,hs
 bl malloc
 ldr x18,[sp,#1632]
 cbz x0,.Lfields_allocation_failed
 mov x25,x0
 ldr w9,[x24]
 add x0,x22,x9
 mov x1,x25
 ldp w2,w3,[x24,#8]
 mov x4,x26
 bl .Lfield_descriptor
 cbz x26,.Lfields_owner_filled
 ldr w9,[x24,#12]
 mov x10,x25
 cmp w9,#6
 b.eq .Lfields_fill_character
 cmp w9,#1
 b.eq .Lfields_fill_integer
 mov x11,#0x7fefffffffffffff
 mov x12,x26
.Lfields_fill_real:
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne .Lfields_fill_real
 b .Lfields_owner_filled
.Lfields_fill_integer:
 mov w11,#0x7fffffff
 mov x12,x26
.Lfields_fill_integer_loop:
 str w11,[x10],#4
 subs x12,x12,#1
 b.ne .Lfields_fill_integer_loop
 b .Lfields_owner_filled
.Lfields_fill_character:
 ldr w11,[x24,#8]
 mul x12,x26,x11
 mov w11,#32
.Lfields_fill_character_loop:
 strb w11,[x10],#1
 subs x12,x12,#1
 b.ne .Lfields_fill_character_loop
.Lfields_owner_filled:
 add x23,x23,#1
 add x24,x24,#24
 cmp x23,#21
 b.lo .Lfields_allocate_owner
 adr x24,.Lfield_copy_rows
 mov x23,#0
.Lfields_copy_owner:
 ldp w9,w10,[x24]
 ldr x11,[x22,x9]
 ldr w12,[x22,x10]
 cbz w12,.Lfields_copy_owner_next
 ldr w13,[x24,#8]
 ldr w14,[x24,#16]
 add x15,x19,x14
 cmp w9,#1280
 b.ne .Lfields_copy_owner_bytes
 ldr w14,[x15]
 cmn w14,#99
 b.ne .Lfields_copy_owner_bytes
 mov w14,#1
.Lfields_generate_levels:
 str w14,[x11],#4
 add w14,w14,#1
 subs w12,w12,#1
 b.ne .Lfields_generate_levels
 b .Lfields_copy_owner_next
.Lfields_copy_owner_bytes:
 mul x12,x12,x13
.Lfields_copy_byte:
 ldrb w14,[x15],#1
 strb w14,[x11],#1
 subs x12,x12,#1
 b.ne .Lfields_copy_byte
.Lfields_copy_owner_next:
 add x24,x24,#24
 add x23,x23,#1
 cmp x23,#16
 b.lo .Lfields_copy_owner
 mov x9,#0
.Lfields_commit:
 add x10,x22,x9
 ldp x11,x12,[x10]
 add x10,x21,x9
 stp x11,x12,[x10]
 add x9,x9,#16
 cmp x9,#1424
 b.lo .Lfields_commit
 mov w0,#0
 b .Lfields_return
.Lfields_allocation_failed:
 mov x24,#0
.Lfields_rollback:
 cmp x24,x23
 b.hs .Lfields_failed
 add x0,x22,x24,lsl#6
 ldr x0,[x0]
 bl free
 ldr x18,[sp,#1632]
 add x24,x24,#1
 b .Lfields_rollback
.Lfields_failed:
 mov w0,#1
 b .Lfields_return
.Lfields_bad:
 mov w0,#2
.Lfields_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#1648
 ret
.Lfields_early_bad:
 mov w0,#2
 ret
.Lfield_scan_real:
 adr x9,.Llevel_thresholds
 ldr d0,[x9,x2,lsl#3]
 mov x9,#0
.Lfield_scan_real_next:
 cmp x9,x1
 b.hs .Lfield_scan_real_done
 ldr x10,[x0,x9,lsl#3]
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lfield_scan_real_bad
 fmov d1,x10
 cmp w2,#1
 b.eq .Lfield_scan_real_high
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d1,d0,comparison // fcmp d1,d0
 b.lt .Lfield_scan_real_done
 b .Lfield_scan_real_advance
.Lfield_scan_real_high:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d1,d0,comparison // fcmp d1,d0
 b.ge .Lfield_scan_real_done
.Lfield_scan_real_advance:
 add x9,x9,#1
 b .Lfield_scan_real_next
.Lfield_scan_real_done:
 mov x0,x9
 mov w1,#0
 ret
.Lfield_scan_real_bad:
 mov w1,#2
 ret
.Lfield_descriptor:
 mov x9,#-1
 stp x1,x9,[x0]
 lsl x9,x3,#40
 orr x9,x9,#0x100000000
 stp x2,x9,[x0,#16]
 mov x9,#1
 stp x2,x9,[x0,#32]
 stp x9,x4,[x0,#48]
 ret
.size md2asm_initialize_selected_fullpos_fields,.-md2asm_initialize_selected_fullpos_fields
.global md2asm_release_selected_fullpos_fields
.type md2asm_release_selected_fullpos_fields,%function
md2asm_release_selected_fullpos_fields:
 cbz x0,.Lfield_release_bad
 tst x0,#7
 b.ne .Lfield_release_bad
 cmp x1,#1424
 b.lo .Lfield_release_bad
 adds x9,x0,#1424
 b.cs .Lfield_release_bad
 sub sp,sp,#48
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,#0
.Lfield_release_next:
 add x0,x19,x20,lsl#6
 ldr x0,[x0]
 bl free
 ldr x18,[sp,#32]
 add x9,x19,x20,lsl#6
 str xzr,[x9]
 add x20,x20,#1
 cmp x20,#21
 b.lo .Lfield_release_next
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#48
 ret
.Lfield_release_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_fullpos_fields,.-md2asm_release_selected_fullpos_fields
.section .rodata
.Lfilter_group: .ascii "NAMFPF"
.Lfilter_names: .ascii "MATDILAMATCONT"
.section .rodata
.p2align 3
.Lfield_owner_rows:
.word 0,1400,12,6,0,0
.word 64,1404,16,6,58992,0
.word 128,1408,16,6,5448,0
.word 192,1412,16,6,56640,0
.word 256,1416,16,6,57952,0
.word 320,1372,4,1,31672,0
.word 384,1376,4,1,33488,0
.word 448,1380,4,1,35304,0
.word 512,1384,4,1,37120,0
.word 576,1388,4,1,38936,0
.word 640,1392,4,1,40752,0
.word 704,1396,4,1,42568,0
.word 768,1404,4,1,44384,0
.word 832,1408,4,1,50080,0
.word 896,1344,8,3,45232,0
.word 960,1348,8,3,45832,0
.word 1024,1352,8,3,46848,0
.word 1088,1356,8,3,47448,0
.word 1152,1360,8,3,48048,0
.word 1216,1368,8,3,48648,0
.word 1280,1364,4,1,49248,0
.Lfield_scan_rows:
.word 45232,75,1344,1376,0
.word 45832,127,1348,1380,0
.word 46848,75,1352,1384,0
.word 47448,75,1356,1388,1
.word 48048,75,1360,1392,2
.word 49248,200,1364,1372,3
.word 48648,75,1368,1396,0
.Lfield_copy_rows:
.word 896,1344,8,3,45232,0
.word 960,1348,8,3,45832,0
.word 1024,1352,8,3,46848,0
.word 1088,1356,8,3,47448,0
.word 1152,1360,8,3,48048,0
.word 1216,1368,8,3,48648,0
.word 1280,1364,4,1,49248,0
.word 320,1372,4,1,31672,0
.word 384,1376,4,1,33488,0
.word 448,1380,4,1,35304,0
.word 512,1384,4,1,37120,0
.word 576,1388,4,1,38936,0
.word 640,1392,4,1,40752,0
.word 704,1396,4,1,42568,0
.word 768,1404,4,1,44384,0
.word 832,1408,4,1,50080,0
.Lfilter_constants:
.quad 0x3ddb7cdfd9d7bdbb,0x4010000000000000,0x4008ac0b56d32fe7
.Llevel_thresholds:
.quad 0x0000000000000000,0x40f86a0000000000,0xc08f380000000000
.section .note.GNU-stack,"",%progbits

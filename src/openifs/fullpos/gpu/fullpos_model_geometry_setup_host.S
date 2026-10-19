#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_model_geometry
.type md2asm_initialize_selected_fullpos_model_geometry,%function
md2asm_initialize_selected_fullpos_model_geometry:
 cmp x4,#472
 b.lo .Lmg_bad
 cbz x0,.Lmg_bad
 cbz x1,.Lmg_bad
 cbz x2,.Lmg_bad
 cbz x3,.Lmg_bad
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lmg_bad
 mov x9,#17096
 adds x9,x0,x9
 b.cs .Lmg_bad
 adds x9,x2,#24
 b.cs .Lmg_bad
 mrs x9,fpcr
 cbnz x9,.Lmg_bad
 sub sp,sp,#640
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x9,#17096
 stp x0,x9,[sp,#112]
 mov x9,#32
 stp x1,x9,[sp,#128]
 mov x9,#24
 stp x2,x9,[sp,#144]
 mov x9,#472
 stp x3,x9,[sp,#160]
 ldr x23,[x19,#7640]
 ldr x24,[x19,#7768]
 mov x9,#144
 stp x23,x9,[sp,#176]
 stp x24,x9,[sp,#192]
 add x0,sp,#112
 bl .Lmg_views
 cbnz w0,.Lmg_return
 ldp x9,x10,[x21]
 orr x9,x9,x10
 cbnz x9,.Lmg_invalid
 ldr x9,[x21,#16]
 tbnz x9,#63,.Lmg_invalid
 cbz x9,.Lmg_invalid
 ubfx x9,x9,#52,#11
 cmp x9,#2047
 b.eq .Lmg_invalid
 ldr x9,[x22,#80]
 cbnz x9,.Lmg_invalid
 ldr x9,[x22,#144]
 cbnz x9,.Lmg_invalid
 ldr x9,[x22,#208]
 cbnz x9,.Lmg_invalid
 adrp x25,.Lmg_selected_i32
 add x25,x25,:lo12:.Lmg_selected_i32
 mov x26,#0
.Lmg_selected_loop:
 add x9,x25,x26
 ldp w9,w10,[x9]
 ldr w11,[x19,x9]
 cmp w11,w10
 b.ne .Lmg_invalid
 add x26,x26,#8
 cmp x26,#64
 b.lo .Lmg_selected_loop
 mov x9,#0x3ff0000000000000
 ldr x10,[x19,#7496]
 cmp x10,x9
 b.ne .Lmg_invalid
 ldr x10,[x19,#7512]
 cmp x10,x9
 b.ne .Lmg_invalid
 ldr x10,[x19,#7504]
 lsl x10,x10,#1
 cbnz x10,.Lmg_invalid
 ldr w9,[x19,#5168]
 cbz w9,.Lmg_invalid
 mov w10,#32767
 cmp w9,w10
 b.hi .Lmg_invalid
 ldr w9,[x19,#5192]
 cmp w9,#65536
 b.hi .Lmg_invalid
 ldr w9,[x19,#5200]
 cmp w9,#65536
 b.hi .Lmg_invalid
 add x9,x19,#3,lsl #12
 add x9,x9,#3256
 mov x10,#0
.Lmg_finite_angles:
 ldr x11,[x9,x10]
 ubfx x11,x11,#52,#11
 cmp x11,#2047
 b.eq .Lmg_invalid
 add x10,x10,#8
 cmp x10,#32
 b.lo .Lmg_finite_angles
 mov x9,#7640
 add x0,x19,x9
 bl .Lmg_integer_descriptor
 cbnz w0,.Lmg_return
 mov x9,#7768
 add x0,x19,x9
 bl .Lmg_integer_descriptor
 cbnz w0,.Lmg_return
 add x23,x23,#8
 add x24,x24,#8
 mov x9,#0
.Lmg_grid_inputs:
 ldr w10,[x23,x9,lsl #2]
 cmp w10,#64
 b.ne .Lmg_invalid
 ldr w10,[x24,x9,lsl #2]
 cmp w10,#21
 b.hi .Lmg_invalid
 add x9,x9,#1
 cmp x9,#32
 b.lo .Lmg_grid_inputs
 mov x0,x22
 mov x1,#472
 bl md2asm_initialize_fullpos_user_geometry_defaults
 cbnz w0,.Lmg_return
 adrp x9,.Lmodel_constants
 add x9,x9,:lo12:.Lmodel_constants
 ldr d0,[x9]
 ldr d1,[x21,#16]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d2,d0,d1 // fdiv d2,d0,d1
 ldp x9,x10,[x20]
 stp x9,x10,[x22]
 ldp x9,x10,[x20,#16]
 stp x9,x10,[x22,#16]
 adrp x9,.Lmg_initial_i32
 add x9,x9,:lo12:.Lmg_initial_i32
 mov x10,#10
 bl .Lmg_copy_i32
 adrp x9,.Lmg_angle_pairs
 add x9,x9,:lo12:.Lmg_angle_pairs
 mov x10,#4
.Lmg_angle_products:
 ldp w11,w12,[x9],#8
 ldr d0,[x19,x11]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d2 // fmul d0,d0,d2
 str d0,[x22,x12]
 subs x10,x10,#1
 b.ne .Lmg_angle_products
 ldr w9,[x19,#15652]
 str w9,[x22,#352]
 ldr w9,[x19,#15648]
 str w9,[x22,#356]
 movz w9,#0x4147
 movk w9,#0x5355,lsl #16
 str w9,[x22,#32]
 mov w9,#83
 strb w9,[x22,#36]
 adrp x9,.Lmg_after_angles_i32
 add x9,x9,:lo12:.Lmg_after_angles_i32
 mov x10,#2
 bl .Lmg_copy_i32
 mov w11,#1
 str w11,[x22,#384]
 mov x10,#2
 bl .Lmg_copy_i32
 ldr d0,[x19,#7496]
 str d0,[x22,#56]
 ldr d0,[x19,#7504]
 str d0,[x22,#64]
 ldr d0,[x19,#7512]
 str d0,[x22,#72]
 add x0,x22,#80
 mov w1,#4
 mov w2,#1
 bl .Lmg_allocate
 cbnz w0,.Lmg_allocation_failure
 add x0,x22,#144
 mov w1,#4
 mov w2,#1
 bl .Lmg_allocate
 cbnz w0,.Lmg_allocation_failure
 add x0,x22,#208
 mov w1,#8
 mov w2,#3
 bl .Lmg_allocate
 cbnz w0,.Lmg_allocation_failure
 ldr x9,[x22,#80]
 ldr x10,[x22,#144]
 ldr x11,[x22,#208]
 mov w12,#0x7fffffff
 mov x13,#-1
 movk x13,#0x7fef,lsl #48
 mov x14,#0
.Lmg_huge_fill:
 str w12,[x9,x14,lsl #2]
 add x14,x14,#1
 cmp x14,#32
 b.lo .Lmg_huge_fill
 mov x14,#0
.Lmg_huge_wave_fill:
 str w12,[x10,x14,lsl #2]
 add x14,x14,#1
 cmp x14,#32
 b.lo .Lmg_huge_wave_fill
 mov x14,#0
.Lmg_huge_real_fill:
 str x13,[x11,x14,lsl #3]
 add x14,x14,#1
 cmp x14,#32
 b.lo .Lmg_huge_real_fill
 mov x10,#0
.Lmg_copy_grid:
 ldr w11,[x23,x10,lsl #2]
 str w11,[x9,x10,lsl #2]
 add x10,x10,#1
 cmp x10,#32
 b.lo .Lmg_copy_grid
 fmov d0,#1.0
 str d0,[x22,#56]
 str xzr,[x22,#64]
 str xzr,[x22,#304]
 stp xzr,xzr,[x22,#336]
 str wzr,[x22,#352]
 mov w9,#1
 str w9,[x22,#356]
 str xzr,[x22,#312]
 ldr d0,[x22,#64]
 str d0,[x22,#328]
 ldr d0,[x22,#56]
 str d0,[x22,#320]
 ldr w9,[x22,#52]
 mov w10,#1
 cmp w9,#1
 csel w9,w9,w10,ge
 mov w10,#2
 cmp w9,#2
 csel w9,w9,w10,le
 str w9,[x22,#52]
 ldr w9,[x22,#48]
 cmp w9,#0
 csel w9,w9,wzr,ge
 cmp w9,#2
 csel w9,w9,w10,le
 str w9,[x22,#48]
 ldr x9,[x22,#80]
 ldr w10,[x22,#44]
 mov x11,#0
.Lmg_regular_grid:
 str w10,[x9,x11,lsl #2]
 add x11,x11,#1
 cmp x11,#32
 b.lo .Lmg_regular_grid
 ldr w9,[x22,#388]
 ldr w10,[x22,#392]
 cmp w9,#0
 csel w9,w9,wzr,ge
 cmp w10,#0
 csel w10,w10,wzr,ge
 str w9,[x22,#388]
 str w10,[x22,#392]
 ldr d0,[x22,#72]
 fmov d1,#1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0,d0,d1
 adrp x9,.Lmodel_constants
 add x9,x9,:lo12:.Lmodel_constants
 ldr d1,[x9,#8]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d1,d1 // fneg d1,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 b.lt .Lmg_source_failure
 ldr w9,[x22,#388]
 ldr w10,[x19,#5172]
 cmp w9,w10
 cset w9,eq
 str w9,[x22,#404]
 ldr w9,[x22,#44]
 ldr w10,[x19,#4936]
 cmp w9,w10
 cset w25,eq
 ldr w9,[x22,#40]
 ldr w10,[x19,#4872]
 cmp w9,w10
 cset w9,eq
 and w25,w25,w9
 ldr x9,[x22,#80]
 mov x10,#0
.Lmg_grid_equality:
 ldr w11,[x9,x10,lsl #2]
 ldr w12,[x23,x10,lsl #2]
 cmp w11,w12
 cset w11,eq
 and w25,w25,w11
 add x10,x10,#1
 cmp x10,#32
 b.lo .Lmg_grid_equality
 str w25,[x22,#408]
 str w25,[x22,#412]
 eor w26,w25,#1
 adrp x9,.Lmodel_constants
 add x9,x9,:lo12:.Lmodel_constants
 ldr d2,[x9,#16]
 ldr d0,[x22,#72]
 ldr d1,[x19,#7512]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d2,comparison // fcmp d0,d2
 cset w9,gt
 orr w26,w26,w9
 ldr w9,[x22,#52]
 ldr w10,[x19,#7520]
 cmp w9,w10
 cset w9,ne
 orr w26,w26,w9
 ldr d0,[x22,#56]
 ldr d1,[x19,#7496]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d2,comparison // fcmp d0,d2
 cset w9,gt
 orr w26,w26,w9
 ldr d0,[x22,#64]
 ldr d1,[x19,#7504]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d2,comparison // fcmp d0,d2
 cset w9,gt
 orr w26,w26,w9
 str w26,[x22,#416]
 str wzr,[x22,#420]
 str wzr,[x22,#424]
 str wzr,[x22,#428]
 str w26,[x22,#432]
 ldr x9,[x22,#80]
 mov x10,#0
 mov w11,#0
.Lmg_sum_grid:
 ldr w12,[x9,x10,lsl #2]
 add w11,w11,w12
 add x10,x10,#1
 cmp x10,#32
 b.lo .Lmg_sum_grid
 str w11,[x22,#460]
 str w11,[x22,#464]
 cmp w26,#0
 mov w9,#2
 csel w9,w9,wzr,ne
 str w9,[x22,#436]
 adrp x9,.Lmg_final_i32
 add x9,x9,:lo12:.Lmg_final_i32
 mov x10,#4
 bl .Lmg_copy_i32
 ldr x9,[x22,#144]
 mov x10,#0
.Lmg_copy_waves:
 ldr w11,[x24,x10,lsl #2]
 str w11,[x9,x10,lsl #2]
 add x10,x10,#1
 cmp x10,#32
 b.lo .Lmg_copy_waves
 add x9,sp,#224
 mov x10,#47
.Lmg_clear_inquiry:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lmg_clear_inquiry
 add x9,x19,#1,lsl #12
 add x9,x9,#1072
 str x9,[sp,#224]
 add x9,x22,#208
 str x9,[sp,#544]
 add x0,sp,#224
 bl md2asm_call_public_transform_inquiry
 ldr x18,[sp,#96]
 cbnz w0,.Lmg_source_failure
 mov w0,#0
 b .Lmg_return
.Lmg_source_failure:
 mov w27,#3
 b .Lmg_cleanup
.Lmg_allocation_failure:
 mov w27,#1
.Lmg_cleanup:
 mov x0,x22
 mov x1,#472
 bl md2asm_release_selected_fullpos_model_geometry
 mov w0,w27
 b .Lmg_return
.Lmg_invalid:
 mov w0,#2
.Lmg_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#640
 ret
.Lmg_copy_i32:
 ldp w11,w12,[x9],#8
 ldr w13,[x19,x11]
 str w13,[x22,x12]
 subs x10,x10,#1
 b.ne .Lmg_copy_i32
 ret
.Lmg_integer_descriptor:
 ldr x9,[x0,#8]
 cmp x9,#1
 b.ne .Lmg_bad
 ldr x9,[x0,#16]
 cmp x9,#4
 b.ne .Lmg_bad
 ldr x9,[x0,#24]
 mov x10,#0x10100000000
 cmp x9,x10
 b.ne .Lmg_bad
 ldr x9,[x0,#32]
 cmp x9,#4
 b.ne .Lmg_bad
 ldp x9,x10,[x0,#40]
 cmp x9,#1
 b.ne .Lmg_bad
 cmn x10,#1
 b.ne .Lmg_bad
 ldr x9,[x0,#56]
 cmp x9,#34
 b.ne .Lmg_bad
 mov w0,#0
 ret
.Lmg_views:
 mov x9,#0
.Lmg_outer_view:
 add x10,x0,x9,lsl #4
 ldp x11,x12,[x10]
 cbz x11,.Lmg_bad
 tst x11,#7
 b.ne .Lmg_bad
 adds x12,x11,x12
 b.cs .Lmg_bad
 add x13,x9,#1
.Lmg_inner_view:
 cmp x13,#6
 b.hs .Lmg_next_view
 add x14,x0,x13,lsl #4
 ldp x15,x16,[x14]
 adds x16,x15,x16
 b.cs .Lmg_bad
 cmp x11,x16
 b.hs .Lmg_next_peer
 cmp x15,x12
 b.lo .Lmg_bad
.Lmg_next_peer:
 add x13,x13,#1
 b .Lmg_inner_view
.Lmg_next_view:
 add x9,x9,#1
 cmp x9,#6
 b.lo .Lmg_outer_view
 mov w0,#0
 ret
.Lmg_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_fullpos_model_geometry,.-md2asm_initialize_selected_fullpos_model_geometry
.p2align 4
.global md2asm_initialize_fullpos_user_geometry_defaults
.type md2asm_initialize_fullpos_user_geometry_defaults,%function
md2asm_initialize_fullpos_user_geometry_defaults:
 cmp x1,#472
 b.lo .Lmg_bad
 cbz x0,.Lmg_bad
 tst x0,#7
 b.ne .Lmg_bad
 adds x9,x0,#472
 b.cs .Lmg_bad
 ldr x9,[x0,#80]
 cbnz x9,.Lmg_bad
 ldr x9,[x0,#144]
 cbnz x9,.Lmg_bad
 ldr x9,[x0,#208]
 cbnz x9,.Lmg_bad
 adrp x9,.Lmodel_spaces
 ldr x10,[x9,:lo12:.Lmodel_spaces]
 stp x10,x10,[x0]
 stp x10,x10,[x0,#16]
 adrp x9,.Lmodel_default_rows
 add x9,x9,:lo12:.Lmodel_default_rows
 adrp x10,.Lmodel_default_rows_end
 add x10,x10,:lo12:.Lmodel_default_rows_end
.Lmg_default_loop:
 ldp w11,w12,[x9]
 ldr x13,[x9,#8]
 cmp w12,#4
 b.ne .Lmg_default_wide
 str w13,[x0,x11]
 b .Lmg_default_next
.Lmg_default_wide:
 str x13,[x0,x11]
.Lmg_default_next:
 add x9,x9,#16
 cmp x9,x10
 b.lo .Lmg_default_loop
 mov w0,#0
 ret
.size md2asm_initialize_fullpos_user_geometry_defaults,.-md2asm_initialize_fullpos_user_geometry_defaults
.Lmg_allocate:
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov w20,w1
 mov w21,w2
 lsl x0,x20,#5
 bl malloc
 ldr x18,[sp,#40]
 cbz x0,.Lmg_allocate_failed
 str x0,[x19]
 mov x9,#-1
 str x9,[x19,#8]
 str x20,[x19,#16]
 mov x9,#1
 orr w10,w9,w21,lsl #8
 lsl x10,x10,#32
 str x10,[x19,#24]
 str x20,[x19,#32]
 stp x9,x9,[x19,#40]
 mov x9,#32
 str x9,[x19,#56]
 mov w0,#0
 b .Lmg_allocate_return
.Lmg_allocate_failed:
 mov w0,#1
.Lmg_allocate_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.p2align 4
.global md2asm_release_selected_fullpos_model_geometry
.type md2asm_release_selected_fullpos_model_geometry,%function
md2asm_release_selected_fullpos_model_geometry:
 cmp x1,#472
 b.lo .Lmg_bad
 cbz x0,.Lmg_bad
 tst x0,#7
 b.ne .Lmg_bad
 adds x9,x0,#472
 b.cs .Lmg_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov x20,#80
.Lmg_release_loop:
 ldr x0,[x19,x20]
 cbz x0,.Lmg_release_next
 bl free
 ldr x18,[sp,#40]
 str xzr,[x19,x20]
.Lmg_release_next:
 add x20,x20,#64
 cmp x20,#272
 b.lo .Lmg_release_loop
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_selected_fullpos_model_geometry,.-md2asm_release_selected_fullpos_model_geometry
.section .rodata
.p2align 3
.Lmg_selected_i32:
 .word 4872,32,4936,64,5172,21,5176,21,5144,24,7524,0,7520,1,7376,2048
.Lmg_initial_i32:
 .word 4872,40,4936,44,5172,388,5176,392,4924,304,4960,308
 .word 15492,312,15496,316,15352,396,15348,400
.Lmg_angle_pairs:
 .word 15568,320,15560,328,15544,336,15552,344
.Lmg_after_angles_i32:
 .word 15344,376,15340,380,7524,48,7520,52
.Lmg_final_i32:
 .word 5168,440,5192,448,5200,444,7376,452
.section .rodata
.p2align 3
.Lmodel_default_rows:
 .word 40,4
 .quad 0
 .word 44,4
 .quad 0
 .word 48,4
 .quad 0
 .word 52,4
 .quad 1
 .word 56,8
 .quad 0
 .word 64,8
 .quad 0
 .word 72,8
 .quad 0
 .word 80,8
 .quad 0
 .word 144,8
 .quad 0
 .word 208,8
 .quad 0
 .word 272,8
 .quad 0
 .word 280,8
 .quad 0
 .word 288,4
 .quad 0
 .word 292,4
 .quad 0
 .word 296,4
 .quad 0
 .word 300,4
 .quad 0
 .word 304,4
 .quad 0
 .word 308,4
 .quad 0
 .word 312,4
 .quad 0
 .word 316,4
 .quad 0
 .word 320,8
 .quad 0
 .word 328,8
 .quad 0
 .word 336,8
 .quad 0
 .word 344,8
 .quad 0
 .word 352,4
 .quad 0
 .word 356,4
 .quad 0
 .word 360,8
 .quad 0
 .word 368,8
 .quad 0
 .word 376,4
 .quad 0
 .word 380,4
 .quad 0
 .word 384,4
 .quad 1
 .word 388,4
 .quad 0
 .word 392,4
 .quad 0
 .word 396,4
 .quad 0
 .word 400,4
 .quad 0
 .word 436,4
 .quad 0
 .word 440,4
 .quad 0
 .word 444,4
 .quad 0
 .word 448,4
 .quad 0
 .word 452,4
 .quad 0
 .word 456,4
 .quad 0
 .word 460,4
 .quad 0
 .word 464,4
 .quad 0
.Lmodel_default_rows_end:
.p2align 3
.Lmodel_spaces:.quad 0x2020202020202020
.Lmodel_constants:
 .quad 0x4066800000000000
 .quad 0x3d19000000000000
 .quad 0x3d83880000000000
.section .note.GNU-stack,"",%progbits

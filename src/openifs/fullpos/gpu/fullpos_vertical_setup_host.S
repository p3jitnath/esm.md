#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_vertical
.type md2asm_initialize_selected_fullpos_vertical,%function
md2asm_initialize_selected_fullpos_vertical:
 cmp x4,#3224
 b.lo .Lfp_reject
 cmp x6,#512
 b.lo .Lfp_reject
 cbz x1,.Lfp_reject
 cmp x1,#64,lsl #12
 b.hi .Lfp_reject
 cbz x2,.Lfp_reject
 tst x2,#7
 b.ne .Lfp_reject
 adds x9,x2,#32
 b.cs .Lfp_reject
 sub sp,sp,#224
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x5
 stp x0,x1,[sp,#80]
 mov x9,#32
 stp x2,x9,[sp,#96]
 mov x9,#3224
 stp x3,x9,[sp,#112]
 mov x9,#512
 stp x5,x9,[sp,#128]
 ldp x10,x11,[x2]
 mov x9,#160
 stp x10,x9,[sp,#144]
 stp x11,x9,[sp,#160]
 add x0,sp,#80
 mov w1,#6
 bl .Lfp_views
 cbnz w0,.Lfp_parent_return
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x22
 mov x4,#3224
 bl md2asm_initialize_selected_fullpos_vertical_namelist
 cbnz w0,.Lfp_parent_return
 add x9,x22,#8
 add x10,x22,#1616
 stp x9,x10,[sp,#176]
 ldp x9,x10,[x21,#16]
 stp x9,x10,[sp,#192]
 mov x0,x23
 mov x1,#512
 add x2,sp,#176
 bl md2asm_initialize_selected_fullpos_vertical_coordinate
.Lfp_parent_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#224
 ret
.size md2asm_initialize_selected_fullpos_vertical,.-md2asm_initialize_selected_fullpos_vertical
.p2align 4
.global md2asm_initialize_selected_fullpos_vertical_namelist
.type md2asm_initialize_selected_fullpos_vertical_namelist,%function
md2asm_initialize_selected_fullpos_vertical_namelist:
 cmp x4,#3224
 b.lo .Lfp_reject
 cbz x1,.Lfp_reject
 cmp x1,#64,lsl #12
 b.hi .Lfp_reject
 cbz x2,.Lfp_reject
 tst x2,#7
 b.ne .Lfp_reject
 adds x9,x2,#32
 b.cs .Lfp_reject
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 stp x0,x1,[sp,#64]
 mov x9,#32
 stp x2,x9,[sp,#80]
 mov x9,#3224
 stp x3,x9,[sp,#96]
 ldp x10,x11,[x2]
 mov x9,#160
 stp x10,x9,[sp,#112]
 stp x11,x9,[sp,#128]
 add x0,sp,#64
 mov w1,#5
 bl .Lfp_views
 cbnz w0,.Lfp_nam_return
 mov x0,x21
 bl .Lfp_upstream
 cbnz w0,.Lfp_nam_return
 mov x0,x19
 mov x1,x20
 adrp x2,.Lfp_group
 add x2,x2,:lo12:.Lfp_group
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lfp_nam_return
 mov w9,#19
 str w9,[x22]
 ldp x10,x11,[x21]
 add x12,x22,#8
 add x13,x22,#1616
 mov x9,#0
.Lfp_copy:
 ldr x14,[x10,x9]
 ldr x15,[x11,x9]
 str x14,[x12,x9]
 str x15,[x13,x9]
 add x9,x9,#8
 cmp x9,#160
 b.lo .Lfp_copy
 mov w0,#0
.Lfp_nam_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.size md2asm_initialize_selected_fullpos_vertical_namelist,.-md2asm_initialize_selected_fullpos_vertical_namelist
.p2align 4
.global md2asm_initialize_selected_fullpos_vertical_coordinate
.type md2asm_initialize_selected_fullpos_vertical_coordinate,%function
md2asm_initialize_selected_fullpos_vertical_coordinate:
 cmp x1,#512
 b.lo .Lfp_reject
 cbz x2,.Lfp_reject
 tst x2,#7
 b.ne .Lfp_reject
 adds x9,x2,#32
 b.cs .Lfp_reject
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov x20,x2
 mov x9,#32
 stp x2,x9,[sp,#48]
 mov x9,#512
 stp x0,x9,[sp,#64]
 ldp x10,x11,[x2]
 mov x9,#160
 stp x10,x9,[sp,#80]
 stp x11,x9,[sp,#96]
 add x0,sp,#48
 mov w1,#4
 bl .Lfp_views
 cbnz w0,.Lfp_coord_return
 mov x0,x20
 bl .Lfp_upstream
 cbnz w0,.Lfp_coord_return
 mov x0,x19
 mov w1,#19
 ldp x2,x3,[x20]
 ldr d0,[x20,#16]
 bl md2asm_initialize_hybrid_coordinate_owners
 cbnz w0,.Lfp_coord_return
 mov w21,#0
 adrp x9,.Lfp_epsilon
 ldr d1,[x9,:lo12:.Lfp_epsilon]
 ldr w9,[x20,#28]
 cbz w9,.Lfp_bottom_A
 ldr x9,[x19,#64]
 ldr d0,[x9]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 cinc w21,w21,gt
.Lfp_bottom_A:
 ldr x9,[x19,#128]
 ldr d0,[x9,#152]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 cinc w21,w21,gt
 ldr x9,[x19,#64]
 ldr d0,[x9,#152]
 fmov d2,#1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d2 // fsub d0,d0,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 cinc w21,w21,gt
 cbnz w21,.Lfp_endpoint_failure
 mov w0,#0
 b .Lfp_coord_return
.Lfp_endpoint_failure:
 mov x0,x19
 bl md2asm_release_hybrid_coordinate_owners
 mov w0,#3
.Lfp_coord_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.size md2asm_initialize_selected_fullpos_vertical_coordinate,.-md2asm_initialize_selected_fullpos_vertical_coordinate
.p2align 4
.global md2asm_release_selected_fullpos_vertical
.type md2asm_release_selected_fullpos_vertical,%function
md2asm_release_selected_fullpos_vertical:
 cmp x1,#512
 b.lo .Lfp_reject
 cbz x0,.Lfp_reject
 tst x0,#7
 b.ne .Lfp_reject
 adds x9,x0,#512
 b.cs .Lfp_reject
 stp x29,x30,[sp,#-32]!
 mov x29,sp
 str x18,[sp,#16]
 bl md2asm_release_hybrid_coordinate_owners
 mov w0,#0
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.size md2asm_release_selected_fullpos_vertical,.-md2asm_release_selected_fullpos_vertical
.Lfp_views:
 mrs x9,fpcr
 cbnz x9,.Lfp_reject
 mov w8,w1
 mov w9,#0
.Lfp_view_outer:
 add x10,x0,x9,lsl #4
 ldp x11,x12,[x10]
 cbz x11,.Lfp_reject
 tst x11,#7
 b.ne .Lfp_reject
 adds x12,x11,x12
 b.cs .Lfp_reject
 add w13,w9,#1
.Lfp_view_inner:
 cmp w13,w8
 b.hs .Lfp_view_next
 add x14,x0,x13,lsl #4
 ldp x15,x16,[x14]
 adds x16,x15,x16
 b.cs .Lfp_reject
 cmp x11,x16
 b.hs .Lfp_view_inner_next
 cmp x15,x12
 b.hs .Lfp_view_inner_next
 sub w17,w8,#2
 cmp w9,w17
 b.ne .Lfp_reject
 add w17,w17,#1
 cmp w13,w17
 b.ne .Lfp_reject
 cmp x11,x15
 b.ne .Lfp_reject
.Lfp_view_inner_next:
 add w13,w13,#1
 b .Lfp_view_inner
.Lfp_view_next:
 add w9,w9,#1
 cmp w9,w8
 b.lo .Lfp_view_outer
 mov w0,#0
 ret
.Lfp_upstream:
 ldr w9,[x0,#24]
 cmp w9,#19
 b.ne .Lfp_reject
 ldr w9,[x0,#28]
 cmp w9,#1
 b.hi .Lfp_reject
 ldr x9,[x0,#16]
 tbnz x9,#63,.Lfp_reject
 cbz x9,.Lfp_reject
 ubfx x9,x9,#52,#11
 cmp x9,#2047
 b.eq .Lfp_reject
 ldp x10,x11,[x0]
 mov x9,#0
.Lfp_finite:
 ldr x12,[x10,x9]
 ubfx x12,x12,#52,#11
 cmp x12,#2047
 b.eq .Lfp_reject
 ldr x12,[x11,x9]
 ubfx x12,x12,#52,#11
 cmp x12,#2047
 b.eq .Lfp_reject
 add x9,x9,#8
 cmp x9,#160
 b.lo .Lfp_finite
 mov w0,#0
 ret
.Lfp_reject:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lfp_epsilon:
 .quad 0x3d83880000000000
.Lfp_group:
 .ascii "NAMFPG"
.section .note.GNU-stack,"",%progbits

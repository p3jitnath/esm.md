#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_sampling_transform
.type md2asm_spline_sampling_transform,%function
md2asm_spline_sampling_transform:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    orr x9,x0,x2
    tst x9,#7
    b.ne .Lreject
    tst x1,#3
    b.ne .Lreject
    ldr w9,[x1]
    cmp w9,#4
    b.ne .Lreject
    ldp x9,x10,[x0]
    cbnz x9,.Lreject
    mov x11,#0x3ff0000000000000
    cmp x10,x11
    b.ne .Lreject
    stp x29,x30,[sp,#-256]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp d8,d9,[sp,#64]
    mov x19,x0
    mov x20,x2
    mov x21,#0
    mov w22,#4
    str w22,[sp,#80]
    mov w9,#1
    str w9,[sp,#88]
    add x24,sp,#112
.Lrow:
    add w9,w21,#1
    str w9,[sp,#84]
    add x0,sp,#80
    add x1,sp,#84
    mov x2,x19
    bl md2asm_spline_sample_position
    str d0,[sp,#96]
    mov x0,x19
    add x1,x19,#8
    add x2,sp,#96
    bl md2asm_spline_coordinate_from_local
    fmov d8,d0
    fmov d9,#1.0
    str d9,[x24,x21,lsl #3]
    mov x23,#1
.Lpower:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d9,d8,d9 // fmul d9,d8,d9
    add x9,x21,x23,lsl #2
    str d9,[x24,x9,lsl #3]
    add x23,x23,#1
    cmp x23,x22
    b.lt .Lpower
    add x21,x21,#1
    cmp x21,x22
    b.lt .Lrow
    add x0,sp,#88
    add x1,sp,#80
    mov x2,x24
    mov x3,x20
    bl md2asm_selected_spline_inverse
    cbz w0,.Lfinish
    mov w0,#3
.Lfinish:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp d8,d9,[sp,#64]
    ldp x29,x30,[sp],#256
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_sampling_transform,.-md2asm_spline_sampling_transform
.section .note.GNU-stack,"",%progbits

#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_evaluation_matrix
.type md2asm_spline_evaluation_matrix,%function
md2asm_spline_evaluation_matrix:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    cbz x6,.Lreject
    orr x9,x0,x3
    tst x9,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x4
    orr x9,x9,x5
    orr x9,x9,x6
    tst x9,#7
    b.ne .Lreject
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr w7,[x0]
    sub w9,w7,#19
    cmp w9,#2
    b.hi .Lreject
    ldr w8,[x0,#4]
    sub w9,w8,#21
    cmp w9,#3
    b.hi .Lreject
    ldr w10,[x0,#8]
    cmp w10,w9
    b.hi .Lreject
    ldr w9,[x0,#12]
    cbnz w9,.Lreject
    ldr x9,[x1]
    cbnz x9,.Lreject
    mov x9,#0
.Lpoint_guard:
    ldr w10,[x3,x9,lsl #2]
    cmp w10,#1
    b.hi .Lreject
    ldr x10,[x2,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    fmov d0,x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,zero,comparison // fcmp d0,#0.0
    b.lt .Lreject
    fmov d1,#1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
    b.gt .Lreject
    add x9,x9,#1
    cmp w9,w7
    b.lt .Lpoint_guard
    mov x9,#0
    add w12,w8,#4
    fmov d1,xzr
.Lknot_guard:
    ldr x10,[x4,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    fmov d0,x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
    b.lt .Lreject
    fmov d2,#1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d2,comparison // fcmp d0,d2
    b.gt .Lreject
    cmp w9,#4
    b.ge .Llast_knots
    cbnz x10,.Lreject
.Llast_knots:
    cmp w9,w8
    b.lt .Lnext_knot
    mov x11,#0x3ff0000000000000
    cmp x10,x11
    b.ne .Lreject
.Lnext_knot:
    fmov d1,d0
    add x9,x9,#1
    cmp w9,w12
    b.lt .Lknot_guard
    stp x29,x30,[sp,#-256]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    mov x19,x0
    mov x20,x2
    mov x21,x3
    mov x22,x4
    mov x23,x5
    mov x24,x6
    mov w25,w7
    mov w26,w8
    ldr w9,[x19,#8]
    str w9,[sp,#152]
    mov w9,#4
    str w9,[sp,#128]
    mov w9,#3
    str w9,[sp,#132]
    mov w9,#21
    mul w10,w25,w9
    mov x9,#0
.Lclear:
    str xzr,[x24,x9,lsl #3]
    add x9,x9,#1
    cmp w9,w10
    b.lt .Lclear
    mov x27,#0
.Lrow:
    ldr w9,[x21,x27,lsl #2]
    str w9,[sp,#136]
    ldr d2,[x20,x27,lsl #3]
    mov x9,#0
    mov w10,#-1
    add w11,w26,#3
.Lfind_interval:
    add x12,x22,x9,lsl #3
    ldp d0,d1,[x12]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d3,d1,d0 // fsub d3,d1,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d3,d3 // fabs d3,d3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,zero,comparison // fcmp d3,#0.0
    b.le .Lfind_next
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d0,comparison // fcmp d2,d0
    b.lt .Lfind_next
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d1,comparison // fcmp d2,d1
    b.gt .Lfind_next
    add w10,w9,#1
.Lfind_next:
    add x9,x9,#1
    cmp w9,w11
    b.lt .Lfind_interval
    str w10,[sp,#140]
    ldr w12,[sp,#152]
    add w13,w12,#1
    sub w14,w10,#3
    cmp w13,w14
    csel w28,w13,w14,ge
    add w13,w12,#21
    cmp w13,w10
    csel w13,w13,w10,le
    str w13,[sp,#148]
    sub w9,w10,#1
    add x9,x22,x9,lsl #3
    ldp d0,d1,[x9]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d3,d1,d0 // fsub d3,d1,d0
    fmov d8,#1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d8,d8,d3 // fdiv d8,d8,d3
    ldr d2,[x20,x27,lsl #3]
    bl md2asm_vertical_interval_coordinate
    str d0,[sp,#160]
.Lbasis:
    ldr w9,[sp,#148]
    cmp w28,w9
    b.gt .Lnext_row
    ldr w9,[sp,#140]
    sub w9,w9,w28
    mul w9,w9,w26
    sub w10,w28,#1
    add w9,w9,w10
    add x9,x23,x9,lsl #3
    lsl x10,x26,#5
    add x11,sp,#176
    mov w12,#0
.Lcopy_coeff:
    ldr d0,[x9]
    str d0,[x11,x12,lsl #3]
    add x9,x9,x10
    add w12,w12,#1
    cmp w12,#4
    b.lt .Lcopy_coeff
    ldr w9,[sp,#136]
    cbnz w9,.Lderivative
    add x0,sp,#128
    add x1,sp,#176
    add x2,sp,#160
    bl md2asm_spline_polynomial_evaluate
    b .Lstore
.Lderivative:
    stp xzr,xzr,[sp,#208]
    str xzr,[sp,#224]
    add x0,sp,#128
    add x1,sp,#176
    add x2,sp,#132
    add x3,sp,#208
    bl md2asm_spline_polynomial_derivative
    add x0,sp,#132
    add x1,sp,#208
    add x2,sp,#160
    bl md2asm_spline_polynomial_evaluate
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d8 // fmul d0,d0,d8
.Lstore:
    ldr w9,[sp,#152]
    sub w9,w28,w9
    sub w9,w9,#1
    mul w9,w9,w25
    add w9,w9,w27
    str d0,[x24,x9,lsl #3]
    add w28,w28,#1
    b .Lbasis
.Lnext_row:
    add x27,x27,#1
    cmp w27,w25
    b.lt .Lrow
    mov w0,#0
    ldp d8,d9,[sp,#96]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#256
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_evaluation_matrix,.-md2asm_spline_evaluation_matrix
.section .note.GNU-stack,"",%progbits

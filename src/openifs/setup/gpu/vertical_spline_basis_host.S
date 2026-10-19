#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_vertical_spline_basis
.type md2asm_vertical_spline_basis,%function
md2asm_vertical_spline_basis:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    orr x9,x0,x2
    tst x9,#3
    b.ne .Lreject
    orr x9,x1,x3
    orr x9,x9,x4
    tst x9,#7
    b.ne .Lreject
    ldr w5,[x0]
    ldr w6,[x2]
    sub w9,w5,#2
    cmp w9,#2
    b.hi .Lreject
    cmp w6,w5
    b.lt .Lreject
    cmp w6,#24
    b.gt .Lreject
    add w7,w5,w6
    ldr x9,[x1]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fmov d0,x9
    fmov d1,xzr
    fmov d2,#1.0
    mov x8,#0
    mov w12,#0
.Lguard_knots:
    ldr x9,[x3,x8,lsl #3]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fmov d3,x9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d1,comparison // fcmp d3,d1
    b.lt .Lreject
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d2,comparison // fcmp d3,d2
    b.gt .Lreject
    cmp w8,w5
    b.ge .Lguard_upper
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d1,comparison // fcmp d3,d1
    b.ne .Lreject
.Lguard_upper:
    cmp w8,w6
    b.lt .Lguard_order
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d2,comparison // fcmp d3,d2
    b.ne .Lreject
.Lguard_order:
    cbz x8,.Lnew_run
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d4,comparison // fcmp d3,d4
    b.lt .Lreject
    b.ne .Lnew_run
    add w12,w12,#1
    cmp w12,w5
    b.gt .Lreject
    b .Lnext_guard
.Lnew_run:
    mov w12,#1
.Lnext_guard:
    fmov d4,d3
    add x8,x8,#1
    cmp w8,w7
    b.lt .Lguard_knots
    sub sp,sp,#224
    mov x9,sp
    sub w8,w7,#1
    mov x10,#0
.Lfirst_order:
    ldr d3,[x3,x10,lsl #3]
    add x11,x10,#1
    ldr d4,[x3,x11,lsl #3]
    fmov d5,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d3,comparison // fcmp d0,d3
    b.lt .Lstore_first
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d4,comparison // fcmp d0,d4
    b.ge .Lstore_first
    fmov d5,d2
.Lstore_first:
    str d5,[x9,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w8
    b.lt .Lfirst_order
    mov w11,#2
.Lorder:
    sub w8,w7,w11
    mov x10,#0
.Lbasis:
    ldr d3,[x9,x10,lsl #3]
    fmov d4,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d1,comparison // fcmp d3,d1
    b.eq .Lright
    ldr d6,[x3,x10,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d7,d0,d6 // fsub d7,d0,d6
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d7,d7,d3 // fmul d7,d7,d3
    add x12,x10,x11
    sub x12,x12,#1
    ldr d5,[x3,x12,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d5,d5,d6 // fsub d5,d5,d6
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d4,d7,d5 // fdiv d4,d7,d5
.Lright:
    add x12,x10,#1
    ldr d3,[x9,x12,lsl #3]
    fmov d5,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d1,comparison // fcmp d3,d1
    b.eq .Lcombine
    ldr d6,[x3,x12,lsl #3]
    add x12,x10,x11
    ldr d7,[x3,x12,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d5,d7,d0 // fsub d5,d7,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d5,d5,d3 // fmul d5,d5,d3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d7,d7,d6 // fsub d7,d7,d6
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d5,d5,d7 // fdiv d5,d5,d7
.Lcombine:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d4,d4,d5 // fadd d4,d4,d5
    str d4,[x9,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w8
    b.lt .Lbasis
    add w11,w11,#1
    cmp w11,w5
    b.le .Lorder
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d3,d0,d2 // fsub d3,d0,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d3,d3 // fabs d3,d3
    mov x12,#0x0010000000000000
    fmov d4,x12
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d3,d4,comparison // fcmp d3,d4
    b.ge .Lcopy
    mov x10,#0
    sub w8,w6,#1
.Lendpoint_zero:
    str d1,[x4,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w8
    b.lt .Lendpoint_zero
    str d2,[x4,x10,lsl #3]
    b .Lsuccess
.Lcopy:
    mov x10,#0
.Lcopy_next:
    ldr d3,[x9,x10,lsl #3]
    str d3,[x4,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w6
    b.lt .Lcopy_next
.Lsuccess:
    add sp,sp,#224
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_vertical_spline_basis,.-md2asm_vertical_spline_basis
.section .note.GNU-stack,"",%progbits

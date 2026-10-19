#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_vertical_spline_knots
.type md2asm_vertical_spline_knots,%function
md2asm_vertical_spline_knots:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    orr x9,x0,x1
    orr x9,x9,x2
    tst x9,#3
    b.ne .Lreject
    orr x9,x3,x4
    tst x9,#7
    b.ne .Lreject
    ldr w5,[x0]
    ldr w6,[x1]
    ldr w7,[x2]
    sub w9,w5,#2
    cmp w9,#2
    b.hi .Lreject
    cmp w6,w5
    b.lt .Lreject
    cmp w7,w5
    b.lt .Lreject
    cmp w6,#24
    b.gt .Lreject
    cmp w7,#24
    b.gt .Lreject
    sub w8,w6,w5
    cmp w8,w7
    b.gt .Lreject
    fmov d0,xzr
    fmov d1,#1.0
    mov x9,#0
.Lguard_eta:
    ldr x10,[x3,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    fmov d2,x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d0,comparison // fcmp d2,d0
    b.lt .Lreject
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d1,comparison // fcmp d2,d1
    b.gt .Lreject
    cbnz x9,.Lguard_increasing
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d0,comparison // fcmp d2,d0
    b.ne .Lreject
    b .Lguard_next
.Lguard_increasing:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d3,comparison // fcmp d2,d3
    b.le .Lreject
.Lguard_next:
    fmov d3,d2
    add x9,x9,#1
    cmp w9,w7
    b.lt .Lguard_eta
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d2,d1,comparison // fcmp d2,d1
    b.ne .Lreject
    add w11,w6,w5
    mov x9,#0
.Lboundaries:
    str d0,[x4,x9,lsl #3]
    sub w10,w11,w9
    sub w10,w10,#1
    str d1,[x4,x10,lsl #3]
    add x9,x9,#1
    cmp w9,w5
    b.lt .Lboundaries
    cbz w8,.Lsuccess
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d4,w7 // scvtf d4,w7
    fmov d2,#2.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d4,d4,d2 // fsub d4,d4,d2
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d3,w8 // scvtf d3,w8
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d4,d4,d3 // fsub d4,d4,d3
    fmov d3,#0.5
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d4,d3,d4 // fmul d4,d3,d4
    add w9,w8,#1
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d5,w9 // scvtf d5,w9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d3,d2,d4 // fmul d3,d2,d4
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d5,d5,d3 // fadd d5,d5,d3
    sub w9,w7,#1
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d6,w9 // scvtf d6,w9
    mov w9,#1
.Linterior:
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d7,w9 // scvtf d7,w9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d7,d7,d4 // fadd d7,d7,d4
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d7,d7,d5 // fdiv d7,d7,d5
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d7,d7,d6 // fmul d7,d7,d6
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d7,d7,d1 // fadd d7,d7,d1
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w11,d7 // fcvtzs w11,d7
    sub w10,w11,#1
    ldr d16,[x3,x10,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d16,d0,comparison // fcmp d16,d0
    b.eq .Lcopy_next
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d16,d1,comparison // fcmp d16,d1
    b.eq .Lcopy_previous
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d18,w11 // scvtf d18,w11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d18,d7,d18 // fsub d18,d7,d18
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d19,d1,d18 // fsub d19,d1,d18
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d16,d19,d16 // fmul d16,d19,d16
    add w10,w10,#1
    ldr d17,[x3,x10,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d17,d18,d17 // fmul d17,d18,d17
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16,d16,d17
    b .Lstore_knot
.Lcopy_next:
    add w10,w10,#1
    ldr d16,[x3,x10,lsl #3]
    b .Lstore_knot
.Lcopy_previous:
    sub w10,w10,#1
    ldr d16,[x3,x10,lsl #3]
.Lstore_knot:
    add w10,w5,w9
    sub w10,w10,#1
    str d16,[x4,x10,lsl #3]
    add w9,w9,#1
    cmp w9,w8
    b.le .Linterior
.Lsuccess:
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_vertical_spline_knots,.-md2asm_vertical_spline_knots
.section .note.GNU-stack,"",%progbits

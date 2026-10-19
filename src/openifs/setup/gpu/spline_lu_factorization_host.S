#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_lu_factor
.type md2asm_spline_lu_factor,%function
md2asm_spline_lu_factor:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    orr x9,x0,x2
    orr x9,x9,x3
    tst x9,#3
    b.ne .Lreject
    tst x1,#7
    b.ne .Lreject
    ldr w4,[x0]
    sub w9,w4,#1
    cmp w9,#23
    b.hi .Lreject
    mul w5,w4,w4
    mov x6,#0
.Lfinite_input:
    ldr x7,[x1,x6,lsl #3]
    ubfx x8,x7,#52,#11
    cmp x8,#2047
    b.eq .Lreject
    add x6,x6,#1
    cmp w6,w5
    b.lt .Lfinite_input
    stp x29,x30,[sp,#-176]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,x1
    mov x20,x2
    mov x21,x3
    mov w22,w4
    mov x23,#0
    str wzr,[x21]
    fmov d12,#-1.0
    mov x9,#0x0010000000000000
    fmov d13,x9
    fmov d14,xzr
    fmov d15,#1.0
.Lcolumn:
    mul x9,x23,x22
    add x24,x19,x9,lsl #3
    mov x26,x23
    ldr d8,[x24,x23,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d9,d8 // fabs d9,d8
    add x25,x23,#1
    cmp x25,x22
    b.ge .Lpivot_ready
.Lpivot_scan:
    ldr d10,[x24,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d11,d10 // fabs d11,d10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d11,d9,comparison // fcmp d11,d9
    b.le .Lpivot_next
    mov x26,x25
    fmov d8,d10
    fmov d9,d11
.Lpivot_next:
    add x25,x25,#1
    cmp x25,x22
    b.lt .Lpivot_scan
.Lpivot_ready:
    add w9,w26,#1
    str w9,[x20,x23,lsl #2]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d8,d14,comparison // fcmp d8,d14
    b.eq .Lzero_pivot
    cmp x26,x23
    b.eq .Lscale
    mov x25,#0
.Lswap:
    mul x9,x25,x22
    add x9,x19,x9,lsl #3
    ldr d10,[x9,x23,lsl #3]
    ldr d11,[x9,x26,lsl #3]
    str d11,[x9,x23,lsl #3]
    str d10,[x9,x26,lsl #3]
    add x25,x25,#1
    cmp x25,x22
    b.lt .Lswap
.Lscale:
    add x25,x23,#1
    cmp x25,x22
    b.ge .Lupdate
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d9,d13,comparison // fcmp d9,d13
    b.lt .Ldivide_lower
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d9,d15,d8 // fdiv d9,d15,d8
.Lmultiply_lower:
    ldr d10,[x24,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d10,d9,d10 // fmul d10,d9,d10
    str d10,[x24,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x22
    b.lt .Lmultiply_lower
    b .Lupdate
.Ldivide_lower:
    ldr d10,[x24,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d10,d10,d8 // fdiv d10,d10,d8
    str d10,[x24,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x22
    b.lt .Ldivide_lower
    b .Lupdate
.Lzero_pivot:
    ldr w9,[x21]
    cbnz w9,.Lupdate
    add w9,w23,#1
    str w9,[x21]
.Lupdate:
    add x27,x23,#1
    cmp x27,x22
    b.ge .Lnext_column
.Lupdate_column:
    mul x9,x27,x22
    add x25,x19,x9,lsl #3
    ldr d10,[x25,x23,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d10,d14,comparison // fcmp d10,d14
    b.eq .Lnext_update_column
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d10,d12,d10 // fmul d10,d12,d10
    add x28,x23,#1
.Lupdate_row:
    ldr d0,[x24,x28,lsl #3]
    fmov d1,d10
    ldr d2,[x25,x28,lsl #3]
    bl md2asm_round_product_sum_candidate
    str d0,[x25,x28,lsl #3]
    add x28,x28,#1
    cmp x28,x22
    b.lt .Lupdate_row
.Lnext_update_column:
    add x27,x27,#1
    cmp x27,x22
    b.lt .Lupdate_column
.Lnext_column:
    add x23,x23,#1
    cmp x23,x22
    b.lt .Lcolumn
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp],#176
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_lu_factor,.-md2asm_spline_lu_factor
.section .note.GNU-stack,"",%progbits

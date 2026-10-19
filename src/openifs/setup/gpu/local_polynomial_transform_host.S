#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_local_polynomial
.type md2asm_spline_local_polynomial,%function
md2asm_spline_local_polynomial:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    cbz x6,.Lreject
    tst x0,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    orr x9,x9,x6
    tst x9,#7
    b.ne .Lreject
    ldr w9,[x0]
    cmp w9,#4
    b.ne .Lreject
    ldp x9,x10,[x6]
    cbnz x9,.Lreject
    mov x11,#0x3ff0000000000000
    cmp x10,x11
    b.ne .Lreject
    ldr x9,[x2]
    ldr x10,[x3]
    ubfx x11,x9,#52,#11
    ubfx x12,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    cmp x12,#2047
    b.eq .Lreject
    fmov d0,x9
    fmov d1,x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d1,d0,comparison // fcmp d1,d0
    b.le .Lreject
    stp x29,x30,[sp,#-160]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    mov x26,#0
    add x27,sp,#120
.Lsamples:
    add w9,w26,#1
    str w9,[sp,#96]
    mov x0,x19
    add x1,sp,#96
    mov x2,x25
    bl md2asm_spline_sample_position
    str d0,[sp,#104]
    mov x0,x21
    mov x1,x22
    add x2,sp,#104
    bl md2asm_spline_coordinate_from_local
    str d0,[sp,#112]
    mov x0,x19
    mov x1,x23
    add x2,sp,#112
    bl md2asm_spline_polynomial_evaluate
    str d0,[x27,x26,lsl #3]
    add x26,x26,#1
    cmp x26,#4
    b.lt .Lsamples
    mov x26,#0
.Lrow:
    fmov d0,xzr
    mov x28,#0
.Ldot:
    add x9,x26,x28,lsl #2
    ldr d1,[x20,x9,lsl #3]
    ldr d2,[x27,x28,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1,d1,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
    add x28,x28,#1
    cmp x28,#4
    b.lt .Ldot
    str d0,[x24,x26,lsl #3]
    add x26,x26,#1
    cmp x26,#4
    b.lt .Lrow
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#160
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_local_polynomial,.-md2asm_spline_local_polynomial
.section .note.GNU-stack,"",%progbits

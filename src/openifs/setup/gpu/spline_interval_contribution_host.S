#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_interval_contribution
.type md2asm_spline_interval_contribution,%function
md2asm_spline_interval_contribution:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    tst x0,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    tst x9,#7
    b.ne .Lreject
    ldr w6,[x0]
    add w9,w6,#1
    cmp w9,#2
    b.hi .Lreject
    ldp x9,x10,[x4]
    cbnz x9,.Lreject
    mov x11,#0x3ff0000000000000
    cmp x10,x11
    b.ne .Lreject
    ldr x9,[x3]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fmov d0,x9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,zero,comparison // fcmp d0,#0.0
    b.le .Lreject
    mov x9,#0
.Lfinite_coefficients:
    ldr x10,[x1,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    ldr x10,[x2,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    add x9,x9,#1
    cmp x9,#4
    b.lt .Lfinite_coefficients
    stp x29,x30,[sp,#-352]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    mov w19,w6
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov w9,#4
    str w9,[sp,#128]
    str w9,[sp,#148]
    str xzr,[sp,#136]
    cbz w19,.Lmass
    cmp w19,#1
    b.eq .Lderivative
    mov w25,#5
    str w25,[sp,#144]
    ldr d8,[x22]
    add x0,sp,#128
    mov x1,x20
    add x2,sp,#136
    add x3,sp,#144
    add x4,sp,#160
    bl md2asm_spline_polynomial_integral
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d8,d8,d8 // fmul d8,d8,d8
    b .Lproduct
.Lmass:
    mov w25,#4
    str w25,[sp,#144]
    ldp d0,d1,[x20]
    ldp d2,d3,[x20,#16]
    stp d0,d1,[sp,#160]
    stp d2,d3,[sp,#176]
    ldr d8,[x22]
    b .Lproduct
.Lderivative:
    mov w25,#3
    str w25,[sp,#144]
    fmov d8,#1.0
    add x0,sp,#128
    mov x1,x20
    add x2,sp,#144
    add x3,sp,#160
    bl md2asm_spline_polynomial_derivative
.Lproduct:
    add w26,w25,#3
    str w26,[sp,#152]
    add w9,w26,#1
    str w9,[sp,#156]
    add x0,sp,#144
    add x1,sp,#160
    add x2,sp,#148
    mov x3,x21
    add x4,sp,#152
    add x5,sp,#208
    bl md2asm_spline_polynomial_product
    add x0,sp,#152
    add x1,sp,#208
    add x2,sp,#136
    add x3,sp,#156
    add x4,sp,#272
    bl md2asm_spline_polynomial_integral
    add x0,sp,#156
    add x1,sp,#272
    mov x2,x23
    bl md2asm_spline_polynomial_evaluate
    fmov d9,d0
    add x0,sp,#156
    add x1,sp,#272
    add x2,x23,#8
    bl md2asm_spline_polynomial_evaluate
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d9 // fsub d0,d0,d9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d8,d0 // fmul d0,d8,d0
    str d0,[x24]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp x29,x30,[sp],#352
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_interval_contribution,.-md2asm_spline_interval_contribution
.section .note.GNU-stack,"",%progbits

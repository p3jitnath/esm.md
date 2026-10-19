#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_adjust_vertical_hybrid_coordinates
.type md2asm_adjust_vertical_hybrid_coordinates,%function
md2asm_adjust_vertical_hybrid_coordinates:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    orr x9,x0,x1
    orr x9,x9,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    tst x9,#7
    b.ne .Lreject
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr x9,[x4]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fmov d0,x9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,zero,comparison // fcmp d0,#0.0
    b.le .Lreject
    mov x9,#0
.Loutput_guard:
    ldr x10,[x5,x9,lsl #3]
    cbz x10,.Lreject
    tst x10,#7
    b.ne .Lreject
    add x9,x9,#1
    cmp x9,#5
    b.lt .Loutput_guard
    sub sp,sp,#576
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str d8,[sp,#96]
    str x18,[sp,#104]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    ldr d8,[x23]
    add x26,sp,#112
    add x27,sp,#264
    add x28,sp,#424
    mov x25,#0
.Ldifferences:
    add x9,x20,x25,lsl #3
    ldp d0,d1,[x9]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d1,d0 // fsub d0,d1,d0
    ldr x10,[x24]
    str d0,[x10,x25,lsl #3]
    ldr d1,[x21,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
    str d0,[x26,x25,lsl #3]
    add x9,x19,x25,lsl #3
    ldp d0,d1,[x9]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d1,d0 // fsub d0,d1,d0
    ldr x10,[x24,#8]
    str d0,[x10,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Ldifferences
    mov x1,x26
    bl .Lintegrate
    cbnz w0,.Lfailure
    ldr d0,[x27,#152]
    mov x25,#0
.Lnormalise_b:
    ldr x9,[x24]
    ldr d1,[x9,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d1,d1,d0 // fdiv d1,d1,d0
    str d1,[x9,x25,lsl #3]
    ldr d2,[x21,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1,d1,d2
    str d1,[x26,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lnormalise_b
    mov x1,x26
    bl .Lintegrate
    cbnz w0,.Lfailure
    ldr x9,[x24,#16]
    mov x25,#0
.Lcopy_b:
    ldr d0,[x27,x25,lsl #3]
    str d0,[x9,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lcopy_b
    mov x25,#0
.Lzone_input:
    ldr x9,[x24]
    ldr d0,[x9,x25,lsl #3]
    ldr d1,[x21,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
    str d0,[x26,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lzone_input
    mov x1,x26
    bl .Lintegrate
    cbnz w0,.Lfailure
    ldr d0,[x27,#152]
    mov x25,#0
.Lzone:
    ldr d1,[x26,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d1,d1,d0 // fdiv d1,d1,d0
    str d1,[x28,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lzone
    mov x1,x28
    bl .Lintegrate
    cbnz w0,.Lfailure
    mov x25,#0
.Lcombined_a:
    ldr x9,[x24,#8]
    ldr d0,[x9,x25,lsl #3]
    ldr d1,[x21,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d8 // fdiv d0,d0,d8
    ldr d1,[x28,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
    str d0,[x26,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lcombined_a
    mov x1,x26
    bl .Lintegrate
    cbnz w0,.Lfailure
    ldr d0,[x27,#152]
    mov x25,#0
.Lnormalise_a:
    ldr d1,[x26,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d1,d1,d0 // fdiv d1,d1,d0
    ldr d2,[x28,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1,d1,d2
    str d1,[x26,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lnormalise_a
    mov x1,x26
    bl .Lintegrate
    cbnz w0,.Lfailure
    mov x25,#0
.Lreconstruct_a:
    ldr d0,[x26,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d8 // fmul d0,d0,d8
    ldr d1,[x21,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0,d0,d1
    ldr x9,[x24,#8]
    str d0,[x9,x25,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
    str d0,[x26,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lreconstruct_a
    mov x1,x26
    bl .Lintegrate
    cbnz w0,.Lfailure
    ldr x9,[x24,#24]
    mov x25,#0
.Lcopy_a:
    ldr d0,[x27,x25,lsl #3]
    str d0,[x9,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lcopy_a
    mov x25,#0
.Lcross_product:
    add x9,x19,x25,lsl #3
    ldp d0,d1,[x9]
    add x9,x20,x25,lsl #3
    ldp d2,d3,[x9]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1,d1,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d3 // fmul d0,d0,d3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d1,d0 // fsub d0,d1,d0
    ldr x9,[x24,#32]
    str d0,[x9,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#19
    b.lt .Lcross_product
    mov w0,#0
    b .Lreturn
.Lfailure:
    mov w0,#3
.Lreturn:
    ldr d8,[sp,#96]
    ldr x18,[sp,#104]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#576
    ret
.Lintegrate:
    mov x0,x22
    mov x2,x27
    b md2asm_integrate_spline_profile
.Lreject:
    mov w0,#2
    ret
.size md2asm_adjust_vertical_hybrid_coordinates,.-md2asm_adjust_vertical_hybrid_coordinates
.section .note.GNU-stack,"",%progbits

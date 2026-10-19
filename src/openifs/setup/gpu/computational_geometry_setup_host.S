#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_initialize_computational_geometry
.type md2asm_initialize_computational_geometry,%function
md2asm_initialize_computational_geometry:
    mrs x9, fpcr
    cbnz x9, .Lcomputational_invalid
    cbz x0, .Lcomputational_invalid
    cbz x1, .Lcomputational_invalid
    cbz x2, .Lcomputational_invalid
    cbz x3, .Lcomputational_invalid
    orr x9, x0, x1
    orr x9, x9, x2
    orr x9, x9, x3
    tst x9, #7
    b.ne .Lcomputational_invalid
    adds x10, x0, #384
    b.cs .Lcomputational_invalid
    adds x9, x1, #48
    b.cs .Lcomputational_invalid
    cmp x0, x9
    b.hs .Lcomputational_physical_disjoint
    cmp x1, x10
    b.lo .Lcomputational_invalid
.Lcomputational_physical_disjoint:
    adds x9, x2, #256
    b.cs .Lcomputational_invalid
    cmp x0, x9
    b.hs .Lcomputational_sines_disjoint
    cmp x2, x10
    b.lo .Lcomputational_invalid
.Lcomputational_sines_disjoint:
    adds x9, x3, #256
    b.cs .Lcomputational_invalid
    cmp x0, x9
    b.hs .Lcomputational_weights_disjoint
    cmp x3, x10
    b.lo .Lcomputational_invalid
.Lcomputational_weights_disjoint:
    ldr x9, [x1]
    movz x10, #0x3ff0, lsl #48
    cmp x9, x10
    b.ne .Lcomputational_invalid
    ldr x9, [x1, #8]
    movz x10, #0x4000, lsl #48
    cmp x9, x10
    b.ne .Lcomputational_invalid
    ldr x9, [x1, #16]
    cbnz x9, .Lcomputational_invalid
    ldr x9, [x1, #24]
    adrp x10, .Lcomputational_radius
    ldr x10, [x10, :lo12:.Lcomputational_radius]
    cmp x9, x10
    b.ne .Lcomputational_invalid
    ldr x9, [x1, #32]
    adrp x10, .Lcomputational_pi
    ldr x10, [x10, :lo12:.Lcomputational_pi]
    cmp x9, x10
    b.ne .Lcomputational_invalid
    mov x9, x0
    mov w10, #6
.Lcomputational_association:
    ldr x11, [x9], #64
    cbnz x11, .Lcomputational_invalid
    subs w10, w10, #1
    b.ne .Lcomputational_association
    stp x29, x30, [sp, #-176]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    stp d8, d9, [sp, #112]
    stp d10, d11, [sp, #128]
    stp d12, d13, [sp, #144]
    stp d14, d15, [sp, #160]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x9, x0
    add x10, x0, #384
.Lcomputational_clear:
    str xzr, [x9], #8
    cmp x9, x10
    b.lo .Lcomputational_clear
    mov x26, #0
.Lcomputational_allocate:
    mov x0, #16384
    bl malloc
    cbz x0, .Lcomputational_failed
    add x27, x19, x26, lsl #6
    str x0, [x27]
    mov x9, #-1
    str x9, [x27, #8]
    mov x9, #8
    mov w10, #3
    str x9, [x27, #16]
    str x9, [x27, #32]
    mov w11, #1
    strb w11, [x27, #28]
    strb w10, [x27, #29]
    mov x9, #1
    stp x9, x9, [x27, #40]
    mov x9, #2048
    str x9, [x27, #56]
    add x26, x26, #1
    cmp x26, #6
    b.lo .Lcomputational_allocate
    mov x23, #0
    mov x25, #0
.Lcomputational_latitude:
    ldr d8, [x21, x23, lsl #3]
    ldr d9, [x22, x23, lsl #3]
    mov x24, #0
.Lcomputational_longitude:
    lsl x28, x25, #3
    lsl w9, w24, #1
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d0,w9 // scvtf d0, w9
    ldr d1, [x20, #32]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d1,d0 // fmul d0, d1, d0
    mov w9, #64
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d1,w9 // scvtf d1, w9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    fmov d1, xzr
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d15,d1,d0 // fadd d15, d1, d0
    fmov d0, d15
    bl md2asm_cos_original_rounding
    ldr x9, [x19, #(64*0)]
    str d0, [x9, x28]
    fmov d0, d15
    bl md2asm_sin_original_rounding
    ldr x9, [x19, #(64*1)]
    str d0, [x9, x28]
    add w9, w24, #1
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d0,w9 // scvtf d0, w9
    ldr x9, [x19, #(64*2)]
    str d0, [x9, x28]
    add w9, w23, #1
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d0,w9 // scvtf d0, w9
    ldr x9, [x19, #(64*3)]
    str d0, [x9, x28]
    ldr d1, [x20, #8]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d8,d1 // fmul d0, d8, d1
    ldr d1, [x20, #16]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d1,d0 // fadd d0, d1, d0
    ldr d1, [x20]
    ldr d2, [x20, #24]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d9 // fmul d1, d1, d9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    ldr x9, [x19, #(64*4)]
    str d0, [x9, x28]
    fmov d0, xzr
    ldr x9, [x19, #(64*5)]
    str d0, [x9, x28]
    add x25, x25, #1
    add x24, x24, #1
    cmp x24, #64
    b.lo .Lcomputational_longitude
    add x23, x23, #1
    cmp x23, #32
    b.lo .Lcomputational_latitude
    mov w0, #0
    b .Lcomputational_return
.Lcomputational_failed:
    mov x26, #0
.Lcomputational_free:
    add x27, x19, x26, lsl #6
    ldr x0, [x27]
    str xzr, [x27]
    cbz x0, .Lcomputational_next_free
    bl free
.Lcomputational_next_free:
    add x26, x26, #1
    cmp x26, #6
    b.lo .Lcomputational_free
    mov w0, #1
.Lcomputational_return:
    ldp d14, d15, [sp, #160]
    ldp d12, d13, [sp, #144]
    ldp d10, d11, [sp, #128]
    ldp d8, d9, [sp, #112]
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #176
    ret
.Lcomputational_invalid:
    mov w0, #2
    ret
.size md2asm_initialize_computational_geometry,.-md2asm_initialize_computational_geometry
.global md2asm_spherical_resolution_scale
.type md2asm_spherical_resolution_scale,%function
md2asm_spherical_resolution_scale:
    mrs x9, fpcr
    cbnz x9, .Lresolution_invalid
    cbz x0, .Lresolution_invalid
    cbz x1, .Lresolution_invalid
    cbz x2, .Lresolution_invalid
    ldr w9, [x2]
    cmp w9, #1
    b.lt .Lresolution_invalid
    cmp w9, #21
    b.gt .Lresolution_invalid
    add w10, w9, #1
    mul w9, w9, w10
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d2,w9 // scvtf d2, w9
    ldr x9, [x1, #24]
    adrp x10, .Lcomputational_radius
    ldr x10, [x10, :lo12:.Lcomputational_radius]
    cmp x9, x10
    b.ne .Lresolution_invalid
    fmov d0, x9
    ldr x9, [x1, #32]
    adrp x10, .Lcomputational_pi
    ldr x10, [x10, :lo12:.Lcomputational_pi]
    cmp x9, x10
    b.ne .Lresolution_invalid
    fmov d3, x9
    fmov d1, #8.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d0 // fmul d1, d1, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d0 // fmul d1, d1, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d1,d1,d2 // fdiv d1, d1, d2
 md2asm_gpu_full_scalar md2asm_gpu_lake_energy_cell_host,17,d1,d1 // fsqrt d1, d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d3,d1 // fmul d0, d3, d1
    str d0, [x0]
    ret
.Lresolution_invalid:
    b abort
.size md2asm_spherical_resolution_scale,.-md2asm_spherical_resolution_scale
.section .rodata
.balign 8
.Lcomputational_radius:
    .double 6371229.0
.Lcomputational_pi:
    .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits

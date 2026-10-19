#include "../../support/gpu/preserved_weather_calls.inc.S"
.include "src/openifs/setup/gaussian_tangent_literals.S"
.text
.p2align 4
.global md2asm_gaussian_tangent
.type md2asm_gaussian_tangent,%function
md2asm_gaussian_tangent:
    mrs x9, fpcr
    cbnz x9, .Ltan_unsupported
    movz x10, #0x3fb0, lsl #48
    fmov d1, x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0, d1
    b.lo .Ltan_unsupported
    fmov d1, #1.5625
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0, d1
    b.hi .Ltan_unsupported
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x18, [sp, #32]
    stp d8, d9, [sp, #48]
    stp d10, d11, [sp, #64]
    stp d12, d13, [sp, #80]
    stp d14, d15, [sp, #96]
    adrp x19, .Ltan_table
    add x19, x19, :lo12:.Ltan_table
    adrp x20, .Ltan_constants
    add x20, x20, :lo12:.Ltan_constants
    fmov d8, d0
    fmov d9, d0
    ldr d1, [x20, #TAN_g3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d9,d1,comparison // fcmp d9, d1
    b.hi .Ltan_reduce
    mov w21, #0
    fmov d10, xzr
    b .Ltan_table_value
.Ltan_reduce:
    ldr d1, [x20, #TAN_hpinv]
    ldr d2, [x20, #TAN_toint]
    fmov d0, d8
    bl md2asm_round_product_sum_direct
    ldr d1, [x20, #TAN_toint]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d9,d0,d1 // fsub d9, d0, d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d0,d9 // fneg d0, d9
    ldr d1, [x20, #TAN_mp1]
    fmov d2, d8
    bl md2asm_round_product_sum_direct
    fmov d11, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d0,d9 // fneg d0, d9
    ldr d1, [x20, #TAN_mp2]
    fmov d2, d11
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    ldr d1, [x20, #TAN_mp3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d10,d9,d1 // fmul d10, d9, d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d9,d11,d10 // fsub d9, d11, d10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d11,d11,d9 // fsub d11, d11, d9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d10,d11,d10 // fsub d10, d11, d10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d11,d9 // fabs d11, d9
    ldr d1, [x20, #TAN_g2]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d11,d1,comparison // fcmp d11, d1
    b.ls .Ltan_small_reduced
    fmov d9, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d10,d10 // fneg d10, d10
    mov w21, #1
.Ltan_table_value:
    movz x9, #0x4070, lsl #48
    fmov d0, x9
    fmov d1, d9
    ldr d2, [x20, #TAN_mfftnhf]
    bl md2asm_round_product_sum_direct
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d0 // fcvtzs w9, d0
    cmp w9, #185
    b.hi .Ltan_unsupported
    add x9, x19, x9, lsl #5
    ldr d0, [x9]
    ldp d13, d14, [x9, #8]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d11,d9,d0 // fsub d11, d9, d0
    cbz w21, .Ltan_table_difference
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d11,d11,d10 // fadd d11, d11, d10
.Ltan_table_difference:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d12,d11,d11 // fmul d12, d11, d11
    fmov d0, d12
    ldr d1, [x20, #TAN_e1]
    ldr d2, [x20, #TAN_e0]
    bl md2asm_round_product_sum_direct
    fmov d15, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d11,d12 // fmul d0, d11, d12
    fmov d1, d15
    fmov d2, d11
    bl md2asm_round_product_sum_direct
    fmov d11, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d15,d13,d14 // fadd d15, d13, d14
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d15,d11,d15 // fmul d15, d11, d15
    cbnz w21, .Ltan_table_cotangent
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d14,d11 // fsub d0, d14, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d15,d15,d0 // fdiv d15, d15, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d13,d15 // fadd d0, d13, d15
    b .Ltan_return
.Ltan_table_cotangent:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d13,d11 // fadd d0, d13, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d15,d15,d0 // fdiv d15, d15, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d14,d15 // fsub d0, d14, d15
    b .Ltan_return
.Ltan_small_reduced:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d12,d9,d9 // fmul d12, d9, d9
    fmov d0, d12
    ldr d1, [x20, #TAN_d11]
    ldr d2, [x20, #TAN_d9]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmov d0, d12
    fmov d1, d11
    ldr d2, [x20, #TAN_d7]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmov d0, d12
    fmov d1, d11
    ldr d2, [x20, #TAN_d5]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmov d0, d12
    fmov d1, d11
    ldr d2, [x20, #TAN_d3]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d9,d12 // fmul d0, d9, d12
    fmov d1, d11
    fmov d2, d10
    bl md2asm_round_product_sum_direct
    fmov d10, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d11,d9,d10 // fadd d11, d9, d10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d12,d9,d11 // fsub d12, d9, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d12,d12,d10 // fadd d12, d12, d10
    fmov d0, #1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d13,d0,d11 // fdiv d13, d0, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d14,d13,d11 // fmul d14, d13, d11
    fmov d0, d13
    fmov d1, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d2,d14 // fneg d2, d14
    bl md2asm_round_product_sum_direct
    fmov d15, d0
    fmov d0, #1.0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d8,d0,d14 // fsub d8, d0, d14
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d8,d8,d15 // fsub d8, d8, d15
    fmov d0, xzr
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d8,d8,d0 // fadd d8, d8, d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d0,d13 // fneg d0, d13
    fmov d1, d12
    fmov d2, d8
    bl md2asm_round_product_sum_direct
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d8,d0,d11 // fdiv d8, d0, d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d14,d13,d8 // fadd d14, d13, d8
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d15,d13,d14 // fsub d15, d13, d14
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d15,d15,d8 // fadd d15, d15, d8
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d14,d15 // fadd d0, d14, d15
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
.Ltan_return:
    ldp d8, d9, [sp, #48]
    ldp d10, d11, [sp, #64]
    ldp d12, d13, [sp, #80]
    ldp d14, d15, [sp, #96]
    ldp x21, x18, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.Ltan_unsupported:
    b abort
.size md2asm_gaussian_tangent,.-md2asm_gaussian_tangent
.section .note.GNU-stack,"",%progbits

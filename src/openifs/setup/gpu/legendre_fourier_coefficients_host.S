#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_legendre_fourier_coefficients
.type md2asm_legendre_fourier_coefficients,%function
md2asm_legendre_fourier_coefficients:
    ldr w2, [x1]
    cmp w2, #32
    b.ne .Lcoefficient_unsupported
    fmov d0, #2.0
    fmov d1, #0.25
    fmov d2, #1.0
    mov w2, #1
.Lhighest_coefficient:
    mul w3, w2, w2
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d3,w3 // scvtf d3, w3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d3,d1,d3 // fdiv d3, d1, d3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d3,d2,d3 // fsub d3, d2, d3
 md2asm_gpu_full_scalar md2asm_gpu_lake_energy_cell_host,17,d3,d3 // fsqrt d3, d3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d3 // fmul d0, d0, d3
    add w2, w2, #1
    cmp w2, #32
    b.le .Lhighest_coefficient
    str d0, [x0, #128]
    mov w2, #2
    mov x3, #15
.Llower_coefficient:
    sub w4, w2, #1
    mov w5, #66
    sub w5, w5, w2
    mul w4, w4, w5
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d1,w4 // scvtf d1, w4
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    mov w5, #65
    sub w5, w5, w2
    mul w4, w2, w5
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d1,w4 // scvtf d1, w4
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x0, x3, lsl #3]
    sub x3, x3, #1
    add w2, w2, #2
    cmp w2, #32
    b.le .Llower_coefficient
    ret
.Lcoefficient_unsupported:
    b abort
.size md2asm_legendre_fourier_coefficients,.-md2asm_legendre_fourier_coefficients
.section .note.GNU-stack,"",%progbits

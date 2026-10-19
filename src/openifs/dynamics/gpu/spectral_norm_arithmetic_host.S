#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_spectral_norm_matrix_7358525
.type md2asm_spectral_norm_matrix_7358525,%function
md2asm_spectral_norm_matrix_7358525:
 sub sp,sp,#256
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,#0
 adr x9,.Lfloor
 ldr d7,[x9]
.Lmatrix_wave:
 cmp x24,#22
 b.ge .Lmatrix_done
 add x14,x24,#1
 mov x9,#3912
 add x9,x19,x9
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 madd x10,x14,x11,x10
 ldr x9,[x9]
 ldr w13,[x9,x10,lsl #2]
 cmp w13,w24
 b.ne .Lmatrix_bad
 mov x25,#0
.Lmatrix_level:
 cmp x25,x22
 b.ge .Lmatrix_nextwave
 fmov d0,xzr
 mov x26,x24
 mov x9,#3720
 add x9,x19,x9
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 madd x10,x24,x11,x10
 ldr x9,[x9]
 ldr w15,[x9,x10,lsl #2]
 sxtw x27,w15
.Lmatrix_degree:
 cmp x26,#21
 b.gt .Lmatrix_store
 ldr x9,[x20,#8]
 ldr x10,[x20,#40]
 add x11,x25,#1
 madd x9,x11,x10,x9
 ldr x10,[x20,#64]
 madd x9,x27,x10,x9
 ldr x10,[x20]
 ldr d1,[x10,x9,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d1 // fmul d1,d1,d1
 cbz x24,.Lmatrix_real
 add x28,x27,#1
 ldr x9,[x20,#8]
 ldr x10,[x20,#40]
 add x11,x25,#1
 madd x9,x11,x10,x9
 ldr x10,[x20,#64]
 madd x9,x28,x10,x9
 ldr x10,[x20]
 ldr d2,[x10,x9,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d2 // fmul d2,d2,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1,d1,d2
.Lmatrix_real:
 fmov d3,#1.0
 cbz x21,.Lmatrix_metric_ready
 mov x9,#4168
 add x9,x19,x9
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 madd x10,x26,x11,x10
 ldr x9,[x9]
 ldr d3,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d3,d3 // fneg d3,d3
.Lmatrix_metric_ready:
 cbz x24,.Lmatrix_single_weight
 fmov d4,#2.0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d4,d3 // fmul d3,d4,d3
.Lmatrix_single_weight:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d3,d1 // fmul d1,d3,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 add x27,x27,#2
 add x26,x26,#1
 b .Lmatrix_degree
.Lmatrix_store:
 md2asm_gpu_upper_operation md2asm_gpu_output_numeric_cell_host,17,d0,d7,d0 // fmaxnm d0,d7,d0
 madd x9,x24,x22,x25
 str d0,[x23,x9,lsl #3]
 add x25,x25,#1
 b .Lmatrix_level
.Lmatrix_nextwave:
 add x24,x24,#1
 b .Lmatrix_wave
.Lmatrix_done:
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#256
 ret
.Lmatrix_bad:
 str x18,[sp,#240]
 bl abort
 ldr x18,[sp,#240]
.size md2asm_spectral_norm_matrix_7358525,.-md2asm_spectral_norm_matrix_7358525
.global md2asm_spectral_norm_average_7358525
.type md2asm_spectral_norm_average_7358525,%function
md2asm_spectral_norm_average_7358525:
 fmov d0,xzr
 mov x4,#0
.Laverage_level:
 fmov d1,xzr
 mov x5,#0
.Laverage_wave:
 madd x6,x5,x1,x4
 ldr d2,[x0,x6,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1,d1,d2
 add x5,x5,#1
 cmp x5,#22
 b.lt .Laverage_wave
 cbnz x2,.Laverage_no_root
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,17,d1,d1 // fsqrt d1,d1
.Laverage_no_root:
 str d1,[x3,x4,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 add x4,x4,#1
 cmp x4,x1
 b.lt .Laverage_level
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d2,x1 // scvtf d2,x1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d2 // fdiv d0,d0,d2
 ret
.size md2asm_spectral_norm_average_7358525,.-md2asm_spectral_norm_average_7358525
.section .rodata
.p2align 3
.Lfloor: .quad 0x0079000000000000
.section .note.GNU-stack,"",%progbits

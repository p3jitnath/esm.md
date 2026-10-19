#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_output_spectral_norm_matrix_7358525
.type md2asm_output_spectral_norm_matrix_7358525,%function
md2asm_output_spectral_norm_matrix_7358525:
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
.Loutputmatrix_wave:
 cmp x24,#22
 b.ge .Loutputmatrix_done
 add x14,x24,#1
 mov x9,#48
 add x9,x19,x9
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 madd x10,x14,x11,x10
 ldr x9,[x9]
 ldr w13,[x9,x10,lsl #2]
 cmp w13,w24
 b.ne .Loutputmatrix_bad
 mov x25,#0
.Loutputmatrix_level:
 cmp x25,x22
 b.ge .Loutputmatrix_nextwave
 fmov d0,xzr
 mov x26,x24
 mov x9,#368
 add x9,x19,x9
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 madd x10,x24,x11,x10
 ldr x9,[x9]
 ldr w15,[x9,x10,lsl #2]
 sxtw x27,w15
.Loutputmatrix_degree:
 cmp x26,#21
 b.gt .Loutputmatrix_store
 ldr x9,[x20,#8]
 ldr x10,[x20,#40]
 add x11,x25,#1
 madd x9,x11,x10,x9
 ldr x10,[x20,#64]
 madd x9,x27,x10,x9
 ldr x10,[x20]
 ldr d1,[x10,x9,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d1 // fmul d1,d1,d1
 cbz x24,.Loutputmatrix_real
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
.Loutputmatrix_real:
 fmov d3,#1.0
.Loutputmatrix_metric_ready:
 cbz x24,.Loutputmatrix_single_weight
 fmov d4,#2.0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d4,d3 // fmul d3,d4,d3
.Loutputmatrix_single_weight:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d3,d1 // fmul d1,d3,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 add x27,x27,#2
 add x26,x26,#1
 b .Loutputmatrix_degree
.Loutputmatrix_store:
 madd x9,x24,x22,x25
 str d0,[x23,x9,lsl #3]
 add x25,x25,#1
 b .Loutputmatrix_level
.Loutputmatrix_nextwave:
 add x24,x24,#1
 b .Loutputmatrix_wave
.Loutputmatrix_done:
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#256
 ret
.Loutputmatrix_bad:
 str x18,[sp,#240]
 bl abort
 ldr x18,[sp,#240]
.size md2asm_output_spectral_norm_matrix_7358525,.-md2asm_output_spectral_norm_matrix_7358525
.section .note.GNU-stack,"",%progbits

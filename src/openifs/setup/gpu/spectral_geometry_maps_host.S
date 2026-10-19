#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_spectral_geometry_maps
.type md2asm_initialize_spectral_geometry_maps,%function
md2asm_initialize_spectral_geometry_maps:
 cbz x0,.Lmaps_reject
 cbz x1,.Lmaps_reject
 cbz x2,.Lmaps_reject
 cbz x3,.Lmaps_reject
 cbz x4,.Lmaps_reject
 orr x9,x0,x4
 tst x9,#7
 b.ne .Lmaps_reject
 orr x9,x1,x2
 orr x9,x9,x3
 tst x9,#3
 b.ne .Lmaps_reject
 mrs x9,fpcr
 cbnz x9,.Lmaps_reject
 ldr x9,[x0]
 ldr x10,[x0,#88]
 orr x9,x9,x10
 cbnz x9,.Lmaps_reject
 ldp w9,w10,[x1]
 sub w11,w9,#1
 cmp w11,#20
 b.hi .Lmaps_reject
 add w11,w9,#1
 cmp w10,w11
 b.ne .Lmaps_reject
 add w12,w9,#2
 mul w12,w11,w12
 lsr w12,w12,#1
 ldp w13,w14,[x1,#8]
 cmp w13,w12
 b.ne .Lmaps_reject
 cbnz w14,.Lmaps_reject
 mov x14,#0x3fe0
 lsl x14,x14,#48
 ldr x15,[x4]
 cmp x15,x14
 b.lo .Lmaps_reject
 mov x14,#0x4000
 lsl x14,x14,#48
 cmp x15,x14
 b.hi .Lmaps_reject
 mov w11,#0
 mov w12,#0
.Lmaps_check_layout:
 ldr w13,[x2,x11,lsl#2]
 cmp w13,w11
 b.ne .Lmaps_reject
 ldr w13,[x3,x11,lsl#2]
 cmp w13,w12
 b.ne .Lmaps_reject
 add w12,w12,w10
 sub w12,w12,w11
 add w11,w11,#1
 cmp w11,w10
 b.lo .Lmaps_check_layout
 sub sp,sp,#320
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 str x15,[sp,#112]
 ldp w23,w24,[x20]
 ldr w25,[x20,#8]
 bl __errno_location
 mov x27,x0
 ldr w9,[x27]
 str w9,[sp,#120]
 lsl x0,x25,#4
 bl malloc
 cbz x0,.Lmaps_alloc_failed
 mov x26,x0
 mov x9,#24
 mul x0,x25,x9
 bl malloc
 cbz x0,.Lmaps_second_failed
 mov x28,x0
 mov x8,x19
 mov x0,x26
 mov x1,#2
 bl .Lmaps_descriptor
 add x8,x19,#88
 mov x0,x28
 mov x1,#3
 bl .Lmaps_descriptor
 ldr d25,[sp,#112]
 fmov d20,#1.0
 fmov d21,#0.5
 fmov d22,#2.0
 fmov d23,#4.0
 fmov d24,xzr
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d20,d25 // fdiv d0,d20,d25
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d25,d0 // fadd d0,d25,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d26,d21,d0 // fmul d26,d21,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d20,d25 // fdiv d0,d20,d25
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d25,d0 // fsub d0,d25,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d27,d21,d0 // fmul d27,d21,d0
 mov w10,#0
.Lmaps_first_column:
 ldr w8,[x21,x10,lsl#2]
 ldr w11,[x22,x10,lsl#2]
 bl .Lmaps_recurrence
 mov w9,w8
.Lmaps_GMR_diagonal:
 sub w12,w9,w8
 add w12,w12,w11
 str d26,[x26,x12,lsl#3]
 add w9,w9,#1
 cmp w9,w23
 b.ls .Lmaps_GMR_diagonal
 add x14,x26,x25,lsl#3
 mov w9,w8
.Lmaps_GMR_offdiagonal:
 cmp w9,w23
 b.hs .Lmaps_GMR_last
 add w12,w9,#1
 ldr d0,[x13,x12,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d27,d0 // fmul d0,d27,d0
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x14,x12,lsl#3]
 add w9,w9,#1
 b .Lmaps_GMR_offdiagonal
.Lmaps_GMR_last:
 sub w12,w23,w8
 add w12,w12,w11
 str xzr,[x14,x12,lsl#3]
 add w10,w10,#1
 cmp w10,w24
 b.lo .Lmaps_first_column
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d20,d25 // fdiv d0,d20,d25
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d25,d0 // fadd d0,d25,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d26,d21,d0 // fmul d26,d21,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d20,d25 // fdiv d0,d20,d25
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d25,d0 // fsub d0,d25,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d27,d21,d0 // fmul d27,d21,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d28,d26,d26 // fmul d28,d26,d26
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d29,d27,d27 // fmul d29,d27,d27
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d22,d26 // fmul d0,d22,d26
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d30,d0,d27 // fmul d30,d0,d27
 mov w10,#0
.Lmaps_second_column:
 ldr w8,[x21,x10,lsl#2]
 ldr w11,[x22,x10,lsl#2]
 bl .Lmaps_recurrence
 mov w9,w8
.Lmaps_squared_diagonal:
 ldr d0,[x13,x9,lsl#3]
 add w12,w9,#1
 ldr d1,[x13,x12,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d0 // fmul d0,d0,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d1 // fmul d1,d1,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d29,d0 // fmul d0,d29,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d28,d0 // fadd d0,d28,d0
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x28,x12,lsl#3]
 add w9,w9,#1
 cmp w9,w23
 b.ls .Lmaps_squared_diagonal
 add x14,x28,x25,lsl#3
 mov w9,w8
.Lmaps_squared_first:
 cmp w9,w23
 b.hs .Lmaps_squared_first_last
 add w12,w9,#1
 ldr d0,[x13,x12,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d30,d0 // fmul d0,d30,d0
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x14,x12,lsl#3]
 add w9,w9,#1
 b .Lmaps_squared_first
.Lmaps_squared_first_last:
 sub w12,w23,w8
 add w12,w12,w11
 str xzr,[x14,x12,lsl#3]
 add x14,x14,x25,lsl#3
 mov w9,w8
 sub w15,w23,#1
.Lmaps_squared_second:
 cmp w9,w15
 b.hs .Lmaps_squared_second_last
 add w12,w9,#1
 ldr d0,[x13,x12,lsl#3]
 add w12,w9,#2
 ldr d1,[x13,x12,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d29,d0 // fmul d0,d29,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
 sub w12,w9,w8
 add w12,w12,w11
 str d0,[x14,x12,lsl#3]
 add w9,w9,#1
 b .Lmaps_squared_second
.Lmaps_squared_second_last:
 sub w12,w15,w8
 add w12,w12,w11
 str xzr,[x14,x12,lsl#3]
 add w12,w12,#1
 str xzr,[x14,x12,lsl#3]
 add w10,w10,#1
 cmp w10,w24
 b.lo .Lmaps_second_column
 mov w0,#0
 b .Lmaps_return
.Lmaps_second_failed:
 mov x0,x26
 bl free
.Lmaps_alloc_failed:
 mov w0,#1
.Lmaps_return:
 ldr w9,[sp,#120]
 str w9,[x27]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#320
 ret
.Lmaps_reject:
 mov w0,#2
 ret
.Lmaps_descriptor:
 str x0,[x8]
 neg x9,x25
 sub x9,x9,#1
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 str x9,[x8,#32]
 mov x9,#0x302
 lsl x9,x9,#32
 str x9,[x8,#24]
 mov x9,#1
 stp x9,x9,[x8,#40]
 stp x25,x25,[x8,#56]
 stp x9,x1,[x8,#72]
 ret
.Lmaps_recurrence:
 add x13,sp,#128
 mul w12,w8,w8
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d3,w12 // scvtf d3,w12
 mov w9,w8
 add w15,w23,#2
.Lmaps_recurrence_loop:
 mul w12,w9,w9
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d1,w12 // scvtf d1,w12
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d1,d3 // fsub d0,d1,d3
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d2,d23,d1 // fmul d2,d23,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d2,d2,d20 // fsub d2,d2,d20
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d2 // fdiv d0,d0,d2
 md2asm_gpu_full_scalar md2asm_gpu_output_numeric_cell_host,17,d0,d24,d0 // fmaxnm d0,d24,d0
 md2asm_gpu_full_scalar md2asm_gpu_lake_energy_cell_host,17,d0,d0 // fsqrt d0,d0
 str d0,[x13,x9,lsl#3]
 add w9,w9,#1
 cmp w9,w15
 b.ls .Lmaps_recurrence_loop
 ret
.size md2asm_initialize_spectral_geometry_maps,.-md2asm_initialize_spectral_geometry_maps
.p2align 4
.global md2asm_release_spectral_geometry_maps
.type md2asm_release_spectral_geometry_maps,%function
md2asm_release_spectral_geometry_maps:
 cbz x0,.Lmaps_release_reject
 tst x0,#7
 b.ne .Lmaps_release_reject
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#48]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 ldr x0,[x19]
 cbz x0,.Lmaps_release_second
 bl free
 str xzr,[x19]
.Lmaps_release_second:
 ldr x0,[x19,#88]
 cbz x0,.Lmaps_release_done
 bl free
 str xzr,[x19,#88]
.Lmaps_release_done:
 str w21,[x20]
 ldp x9,x10,[sp,#48]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#64
 mov w0,#0
 ret
.Lmaps_release_reject:
 mov w0,#2
 ret
.size md2asm_release_spectral_geometry_maps,.-md2asm_release_spectral_geometry_maps
.section .note.GNU-stack,"",%progbits

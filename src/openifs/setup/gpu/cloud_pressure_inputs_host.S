#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_cloud_pressure_inputs
.type md2asm_initialize_cloud_pressure_inputs,%function
md2asm_initialize_cloud_pressure_inputs:
 cbz x0,.Lcloud_pressure_bad
 cbz x1,.Lcloud_pressure_bad
 cbz x2,.Lcloud_pressure_bad
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lcloud_pressure_bad
 mrs x9,fpcr
 cbnz x9,.Lcloud_pressure_bad
 ldr w9,[x0,#5224]
 cmp w9,#19
 b.ne .Lcloud_pressure_bad
 ldr x9,[x0,#3240]
 add x10,x0,#16
 cmp x9,x10
 b.ne .Lcloud_pressure_bad
 ldr x9,[x0,#3264]
 add x10,x0,#3024
 cmp x9,x10
 b.ne .Lcloud_pressure_bad
 sub sp,sp,#224
 stp x29,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 bl __errno_location
 mov x22,x0
 ldr w23,[x22]
 mov x9,#20328
 ldr x9,[x19,x9]
 str x9,[sp,#112]
 ldr x9,[x20,#184]
 str x9,[sp,#120]
 ldr x9,[x20,#216]
 str x9,[sp,#128]
 adr x9,.Lcloud_pressure_fields
 ldp q0,q1,[x9]
 add x10,sp,#136
 stp q0,q1,[x10]
 mov w9,#1
 str w9,[sp,#176]
 mov w9,#19
 str w9,[sp,#180]
 mov x10,#20320
 ldr x9,[x19,x10]
 str x9,[x21,#152]
 add x9,x21,#160
 str x9,[sp]
 add x9,sp,#112
 str x9,[sp,#8]
 add x0,sp,#176
 add x1,sp,#180
 mov x2,x0
 mov x3,x0
 ldr x4,[x19,#3240]
 ldr x5,[x19,#3264]
 mov x6,x21
 mov x7,#0
 bl md2asm_standard_atmosphere_pressure
 ldr d1,[x21,#152]
 mov x9,#0
 add x10,x21,#312
.Lcloud_pressure_half_eta:
 ldr d0,[x21,x9,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0,d0,d1
 str d0,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#20
 b.lo .Lcloud_pressure_half_eta
 mov x9,#0
 add x10,x21,#160
 add x11,x21,#472
.Lcloud_pressure_full_eta:
 ldr d0,[x10,x9,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0,d0,d1
 str d0,[x11,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#19
 b.lo .Lcloud_pressure_full_eta
 str w23,[x22]
 mov w0,#0
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x18,[sp,#64]
 ldp x29,x30,[sp,#16]
 add sp,sp,#224
 ret
.Lcloud_pressure_bad:
 mov w0,#2
 ret
.size md2asm_initialize_cloud_pressure_inputs,.-md2asm_initialize_cloud_pressure_inputs
.p2align 3
.Lcloud_pressure_fields:
 .word 1,2,3,4,5,6,7,7
.section .note.GNU-stack,"",%progbits

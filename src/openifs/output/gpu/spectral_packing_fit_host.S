#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_fitspectrum_original_rounding
.global __fitspectrum_mod_MOD_fitspectrum
.hidden md2asm_log_positive_normal
.type md2asm_fitspectrum_original_rounding,%function
.type __fitspectrum_mod_MOD_fitspectrum,%function
md2asm_fitspectrum_original_rounding:
__fitspectrum_mod_MOD_fitspectrum:
 mrs x9,fpcr
 cbnz x9,.Lreject
 cbz x0,.Lreject
 cbz x1,.Lreject
 cbz x2,.Lreject
 cbz x3,.Lreject
 cbz x4,.Lreject
 cbz x5,.Lreject
 orr x9,x0,x1
 orr x9,x9,x3
 tst x9,#3
 b.ne .Lreject
 orr x9,x2,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lreject
 ldr w9,[x0]
 cmp w9,#21
 b.ne .Lreject
 ldr w9,[x1]
 cmp w9,#506
 b.ne .Lreject
 ldr w9,[x3]
 cmp w9,#10
 b.ne .Lreject
 adds x10,x2,#4048
 b.cs .Lreject
 adds x9,x4,#8
 b.cs .Lreject
 adds x9,x5,#8
 b.cs .Lreject
 cmp x4,x5
 b.eq .Lreject
 cmp x4,x2
 b.lo .Lcheck_second_output
 cmp x4,x10
 b.lo .Lreject
.Lcheck_second_output:
 cmp x5,x2
 b.lo .Lfinite_scan
 cmp x5,x10
 b.lo .Lreject
.Lfinite_scan:
 mov x9,x2
 mov x10,#506
 movz x13,#0x7ff0,lsl#48
.Lfinite:
 ldr x11,[x9],#8
 and x12,x11,#0x7ff0000000000000
 cmp x12,x13
 b.eq .Lreject
 subs x10,x10,#1
 b.ne .Lfinite
 sub sp,sp,#576
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 stp x4,x5,[sp,#144]
 stp d8,d9,[sp,#160]
 stp d10,d11,[sp,#176]
 stp d12,d13,[sp,#192]
 stp d14,d15,[sp,#208]
 adrp x9,md2asm_fitspectrum_direct_calls
 add x9,x9,:lo12:md2asm_fitspectrum_direct_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 mov x19,x2
 add x23,sp,#224
 add x24,sp,#400
 mov x22,#11
.Lweights:
 fmov d1,#11.0
 sub x10,x22,#10
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d0,x10 // scvtf d0,x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d1,d0 // fdiv d0,d1,d0
 str d0,[x23,x22,lsl#3]
 str xzr,[x24,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#22
 b.ne .Lweights
 mov x20,#0
.Lm:
 mov x9,#45
 sub x9,x9,x20
 mul x25,x20,x9
 mov x21,#0
 mov x9,#11
 cmp x20,x9
 csel x26,x20,x9,ge
.Lcomponent:
 mov x22,x26
.Lnorm:
 sub x9,x22,x20
 add x9,x25,x9,lsl#1
 add x9,x9,x21
 ldr d0,[x19,x9,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,16,d0,d0 // fabs d0,d0
 ldr d1,[x24,x22,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,5,d1,d1,d0 // fmax d1,d1,d0
 str d1,[x24,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#22
 b.ne .Lnorm
 cbz x20,.Lnext_m
 add x21,x21,#1
 cmp x21,#2
 b.ne .Lcomponent
.Lnext_m:
 add x20,x20,#1
 cmp x20,#22
 b.ne .Lm
 movz x9,#0x3cb0,lsl#48
 fmov d1,x9
 movz x10,#0x3d19,lsl#48
 mov x22,#11
.Lfloor:
 ldr d0,[x24,x22,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,5,d0,d0,d1 // fmax d0,d0,d1
 str d0,[x24,x22,lsl#3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 b.ne .Lnext_floor
 str x10,[x23,x22,lsl#3]
.Lnext_floor:
 add x22,x22,#1
 cmp x22,#22
 b.ne .Lfloor
 fmov d8,xzr
 fmov d9,xzr
 fmov d10,xzr
 mov x22,#11
.Lmeans:
 ldr d11,[x23,x22,lsl#3]
 add x9,x22,#1
 mul x9,x22,x9
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d0,x9 // scvtf d0,x9
 bl md2asm_log_positive_normal
 fmov d12,d0
 ldr d0,[x24,x22,lsl#3]
 bl md2asm_log_positive_normal
 fmov d13,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d12,d11 // fmul d0,d12,d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d8,d8,d0 // fadd d8,d8,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d13,d11 // fmul d0,d13,d11
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d9,d9,d0 // fadd d9,d9,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d10,d10,d11 // fadd d10,d10,d11
 add x22,x22,#1
 cmp x22,#22
 b.ne .Lmeans
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d14,d8,d10 // fdiv d14,d8,d10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d15,d9,d10 // fdiv d15,d9,d10
 fmov d8,xzr
 fmov d9,xzr
 mov x22,#11
.Lfit:
 ldr d11,[x23,x22,lsl#3]
 add x9,x22,#1
 mul x9,x22,x9
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d0,x9 // scvtf d0,x9
 bl md2asm_log_positive_normal
 fmov d12,d0
 ldr d0,[x24,x22,lsl#3]
 bl md2asm_log_positive_normal
 fmov d13,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d13,d13,d15 // fsub d13,d13,d15
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d12,d12,d14 // fsub d12,d12,d14
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d11,d13 // fmul d0,d11,d13
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d12 // fmul d0,d0,d12
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d8,d8,d0 // fadd d8,d8,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d12,d12 // fmul d0,d12,d12
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d11,d0 // fmul d0,d11,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d9,d9,d0 // fadd d9,d9,d0
 add x22,x22,#1
 cmp x22,#22
 b.ne .Lfit
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d1,d8,d9 // fdiv d1,d8,d9
 ldr x9,[sp,#152]
 str d1,[x9]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d1,d14 // fmul d0,d1,d14
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d15,d0 // fsub d0,d15,d0
 ldr x9,[sp,#144]
 str d0,[x9]
 ldp d8,d9,[sp,#160]
 ldp d10,d11,[sp,#176]
 ldp d12,d13,[sp,#192]
 ldp d14,d15,[sp,#208]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#576
 ret
.Lreject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size md2asm_fitspectrum_original_rounding,.-md2asm_fitspectrum_original_rounding
.size __fitspectrum_mod_MOD_fitspectrum,.-__fitspectrum_mod_MOD_fitspectrum
.data
.p2align 3
.hidden md2asm_fitspectrum_direct_calls
.global md2asm_fitspectrum_direct_calls
.type md2asm_fitspectrum_direct_calls,%object
md2asm_fitspectrum_direct_calls:
 .quad 0
.size md2asm_fitspectrum_direct_calls,8
.section .note.GNU-stack,"",%progbits

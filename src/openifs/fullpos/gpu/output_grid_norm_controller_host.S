#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_fpgpnorm_7358525
.type md2asm_fpgpnorm_7358525,%function
md2asm_fpgpnorm_7358525:
 mov x16,sp
 sub sp,sp,#1024
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 ldr x9,[x16,#0]
 str x9,[sp,#192]
 ldr x9,[x16,#8]
 str x9,[sp,#200]
 ldr x9,[x16,#16]
 str x9,[sp,#208]
 ldr x9,[x16,#24]
 str x9,[sp,#216]
 ldr x9,[x16,#32]
 str x9,[sp,#224]
 ldr x9,[x16,#40]
 str x9,[sp,#232]
 ldr x9,[x16,#48]
 str x9,[sp,#240]
 ldr x9,[x16,#56]
 str x9,[sp,#248]
 ldr x9,[x16,#64]
 str x9,[sp,#256]
 ldr x9,[x16,#72]
 str x9,[sp,#264]
 ldr x9,[x16,#80]
 str x9,[sp,#272]
 stp x19,x20,[sp,#384]
 stp x21,x22,[sp,#400]
 stp x23,x24,[sp,#416]
 stp x25,x26,[sp,#432]
 stp x27,x28,[sp,#448]
 stp x29,x30,[sp,#464]
 mov x19,x1
 mov x20,x6
 mrs x9,fpcr
 cbnz x9,.Lo_bad
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lo_bad
 ldr x9,[sp,#128]
 ldr w9,[x9]
 cmp w9,#0
 b.gt .Lo_bad
 ldr x9,[sp,#144]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lo_bad
 ldr w21,[x19]
 cmp w21,#2048
 b.ne .Lo_bad
 ldr w9,[x19,#4]
 cmp w9,#2048
 b.ne .Lo_bad
 ldr w9,[x19,#12]
 cmp w9,#24
 b.ne .Lo_bad
 ldr w9,[x19,#16]
 cmp w9,#86
 b.ne .Lo_bad
 ldr x9,[sp,#168]
 ldr w9,[x9]
 cmp w9,#2048
 b.ne .Lo_bad
 ldr x22,[x20,#80]
 ldr x9,[x20,#72]
 sub x22,x22,x9
 add x22,x22,#1
 cmp x22,#1
 b.lt .Lo_bad
 cmp x22,#39
 b.gt .Lo_bad
 ldr x9,[sp,#240]
 cbz x9,.Lo_bad
 ldrb w9,[x9]
 cmp w9,#80
 b.eq .Lo_cfg
 cmp w9,#83
 b.ne .Lo_bad
.Lo_cfg:
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#520]
 cbz w9,.Lo_start
 adr x0,.Lo_name
 add x1,sp,#524
 str wzr,[x1]
 add x2,sp,#528
 mov x3,#8
 str x18,[sp,#512]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#512]
.Lo_start:
 mul x0,x21,x22
 lsl x0,x0,#3
 str x18,[sp,#512]
 bl malloc
 ldr x18,[sp,#512]
 cbz x0,.Lo_bad
 mov x23,x0
 mov x24,#0
.Lo_field:
 cmp x24,x22
 b.ge .Lo_norms
 ldr x11,[sp,#208]
 ldr x9,[x11,#8]
 ldr x10,[x11,#40]
 ldr x12,[x11,#48]
 add x12,x12,x24
 madd x9,x12,x10,x9
 ldr x10,[x11]
 ldr w9,[x10,x9,lsl #2]
 cmp w9,#1
 b.ne .Lo_bad
 ldr x11,[sp,#216]
 ldr x9,[x11,#8]
 ldr x10,[x11,#40]
 ldr x12,[x11,#48]
 madd x9,x12,x10,x9
 ldr x10,[x11,#64]
 ldr x12,[x11,#72]
 add x12,x12,x24
 madd x9,x12,x10,x9
 ldr x10,[x11]
 ldr w9,[x10,x9,lsl #2]
 cmp w9,#1
 b.ne .Lo_bad
 mov x25,#0
.Lo_block:
 cmp x25,#86
 b.ge .Lo_nextfield
 add x9,x19,#24
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 ldr x12,[x9,#48]
 add x12,x12,x25
 madd x10,x12,x11,x10
 ldr x9,[x9]
 ldr w27,[x9,x10,lsl #2]
 cmp w27,#24
 b.hi .Lo_bad
 cbz w27,.Lo_bad
 mov x26,#0
.Lo_cell:
 mov x13,#24
 madd x13,x25,x13,x26
 add x9,x19,#152
 ldr x10,[x9,#8]
 ldr x11,[x9,#48]
 add x11,x11,x13
 ldr x12,[x9,#40]
 madd x10,x11,x12,x10
 ldr x11,[x9,#72]
 ldr x12,[x9,#64]
 madd x10,x11,x12,x10
 ldr x9,[x9]
 ldrsw x28,[x9,x10,lsl #2]
 cmp x28,#1
 b.lt .Lo_bad
 cmp x28,x21
 b.gt .Lo_bad
 sub x28,x28,#1
 ldr x9,[x20,#8]
 ldr x10,[x20,#48]
 add x10,x10,x26
 ldr x11,[x20,#40]
 madd x9,x10,x11,x9
 ldr x10,[x20,#72]
 add x10,x10,x24
 ldr x11,[x20,#64]
 madd x9,x10,x11,x9
 ldr x10,[x20,#96]
 add x10,x10,x25
 ldr x11,[x20,#88]
 madd x9,x10,x11,x9
 ldr x10,[x20]
 ldr x11,[x10,x9,lsl #3]
 madd x9,x24,x21,x28
 str x11,[x23,x9,lsl #3]
 add x26,x26,#1
 cmp x26,x27
 b.lt .Lo_cell
 add x25,x25,#1
 b .Lo_block
.Lo_nextfield:
 add x24,x24,#1
 b .Lo_field
.Lo_norms:
 adrp x28,:got:md2asm_output_grid_norm_results_7358525
 ldr x28,[x28,:got_lo12:md2asm_output_grid_norm_results_7358525]
 mov x24,#0
 adr x9,.Lo_missing
 ldr d7,[x9]
 adr x9,.Lo_epsilon
 ldr d6,[x9]
.Lo_norm_field:
 fmov d0,xzr
 fmov d2,d7
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d3,d7 // fneg d3,d7
 mov x25,#0
 mov x26,#0
.Lo_norm_cell:
 madd x9,x24,x21,x25
 ldr d1,[x23,x9,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d1,d7,real,late,comparison // fcmp d1,d7
 b.eq .Lo_skip
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_output_numeric_cell_host,18,d2,d2,d1 // fminnm d2,d2,d1
 md2asm_gpu_upper_operation md2asm_gpu_output_numeric_cell_host,17,d3,d3,d1 // fmaxnm d3,d3,d1
 add x26,x26,#1
.Lo_skip:
 add x25,x25,#1
 cmp x25,x21
 b.lt .Lo_norm_cell
 cbz x26,.Lo_bad
 fmov d4,#1.0
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d5,x26 // scvtf d5,x26
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d4,d4,d5 // fdiv d4,d4,d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d4 // fmul d0,d0,d4
 mov x9,#24
 madd x10,x24,x9,x28
 str d0,[x10]
 stp d2,d3,[x10,#8]
 add x10,x10,#936
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,16,d4,d0 // fabs d4,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d4,d6,real,late,comparison // fcmp d4,d6
 b.ge .Lo_display0
 fmov d0,xzr
.Lo_display0:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,16,d4,d2 // fabs d4,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d4,d6,real,late,comparison // fcmp d4,d6
 b.ge .Lo_display2
 fmov d2,xzr
.Lo_display2:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,16,d4,d3 // fabs d4,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d4,d6,real,late,comparison // fcmp d4,d6
 b.ge .Lo_display3
 fmov d3,xzr
.Lo_display3:
 str d0,[x10]
 stp d2,d3,[x10,#8]
 add x24,x24,#1
 cmp x24,x22
 b.lt .Lo_norm_field
 adrp x9,:got:md2asm_output_grid_norm_count_7358525
 ldr x9,[x9,:got_lo12:md2asm_output_grid_norm_count_7358525]
 str w22,[x9]
 mov x0,x23
 str x18,[sp,#512]
 bl free
 ldr x18,[sp,#512]
 ldr w9,[sp,#520]
 cbz w9,.Lo_return
 adr x0,.Lo_name
 add x1,sp,#524
 mov w9,#1
 str w9,[x1]
 add x2,sp,#528
 mov x3,#8
 str x18,[sp,#512]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#512]
.Lo_return:
 ldp x19,x20,[sp,#384]
 ldp x21,x22,[sp,#400]
 ldp x23,x24,[sp,#416]
 ldp x25,x26,[sp,#432]
 ldp x27,x28,[sp,#448]
 ldp x29,x30,[sp,#464]
 add sp,sp,#1024
 ret
.Lo_bad:
 str x18,[sp,#512]
 bl abort
 ldr x18,[sp,#512]
.size md2asm_fpgpnorm_7358525,.-md2asm_fpgpnorm_7358525
.section .rodata
.Lo_name: .ascii "FPGPNORM"
.p2align 3
.Lo_missing: .quad 0x7fefffffffffffff
.Lo_epsilon: .quad 0x3cb0000000000000
.bss
.p2align 3
.global md2asm_output_grid_norm_results_7358525
md2asm_output_grid_norm_results_7358525: .zero 1872
.global md2asm_output_grid_norm_count_7358525
md2asm_output_grid_norm_count_7358525: .zero 4
.section .note.GNU-stack,"",%progbits

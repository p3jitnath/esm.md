#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_ltdir_ledir_child_7358525
.type md2asm_ltdir_ledir_child_7358525,%function
.macro COUNT index
 adrp x9,.Lledir_counts
 add x9,x9,:lo12:.Lledir_counts
 ldr x10,[x9,#8*\index]
 add x10,x10,#1
 str x10,[x9,#8*\index]
.endm
md2asm_ltdir_ledir_child_7358525:
 mov x17,sp
 sub sp,sp,#512
 str x18,[sp,#24]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 stp d8,d9,[sp,#128]
 stp d10,d11,[sp,#144]
 stp d12,d13,[sp,#160]
 stp d14,d15,[sp,#176]
 stp x0,x1,[sp,#192]
 stp x2,x3,[sp,#208]
 stp x4,x5,[sp,#224]
 stp x6,x7,[sp,#240]
 ldp x9,x10,[x17]
 stp x9,x10,[sp,#256]
 ldr x9,[x17,#16]
 str x9,[sp,#272]
 mrs x9,fpcr
 cbnz x9,.Lledir_bad
 ldrsw x19,[x0]
 cmp x19,#21
 b.hi .Lledir_bad
 ldr w9,[x1]
 add w10,w19,#1
 cmp w9,w10
 b.ne .Lledir_bad
 str w9,[sp,#368]
 ldrsw x20,[x2]
 cmp x20,#10
 b.eq .Lledir_width_ok
 cmp x20,#38
 b.eq .Lledir_width_ok
 cmp x20,#40
 b.eq .Lledir_width_ok
 cmp x20,#76
 b.eq .Lledir_width_ok
 cmp x20,#116
 b.ne .Lledir_bad
.Lledir_width_ok:
 ldrsw x21,[x3]
 cmp x21,#0
 b.lt .Lledir_bad
 ldr w9,[x5]
 cmp w9,#0
 b.lt .Lledir_bad
 cbz x21,.Lledir_empty
 cbz w9,.Lledir_empty
 cmp w9,#16
 b.ne .Lledir_bad
 ldr w9,[x4]
 cmp w9,#1
 b.ne .Lledir_bad
 ldr w9,[x6]
 cmp w9,w20
 b.ne .Lledir_bad
 mov x22,#1
 cbnz x19,.Lledir_step_ok
 mov x22,#2
.Lledir_step_ok:
 udiv x9,x20,x22
 cmp x9,x21
 b.ne .Lledir_bad
 mov w9,#23
 sub w9,w9,w19
 lsr w10,w9,#1
 str w10,[sp,#360]
 and w10,w9,#1
 add w10,w10,#1
 str w10,[sp,#352]
 add w9,w9,#1
 lsr w10,w9,#1
 str w10,[sp,#364]
 and w10,w9,#1
 add w10,w10,#1
 str w10,[sp,#356]
 adrp x9,:got:__tpm_dim_MOD_r
 ldr x9,[x9,:got_lo12:__tpm_dim_MOD_r]
 ldr x9,[x9]
 cbz x9,.Lledir_bad
 str x9,[sp,#408]
 ldr w10,[x9,#4]
 cmp w10,#21
 b.ne .Lledir_bad
 adrp x9,:got:__tpm_flt_MOD_s
 ldr x9,[x9,:got_lo12:__tpm_flt_MOD_s]
 ldr x9,[x9]
 cbz x9,.Lledir_bad
 str x9,[sp,#416]
 ldr w10,[x9,#72]
 cbnz w10,.Lledir_bad
 ldr x10,[x9,#16]
 cmp x10,#744
 b.ne .Lledir_bad
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lledir_bad
 ldr x10,[x9,#32]
 cmp x10,#744
 b.ne .Lledir_bad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lledir_bad
 ldrsw x10,[sp,#368]
 ldr x11,[x9,#48]
 cmp x10,x11
 b.lt .Lledir_bad
 ldr x12,[x9,#56]
 cmp x10,x12
 b.gt .Lledir_bad
 sub x12,x12,x11
 add x12,x12,#1
 mov x13,#744
 mul x12,x12,x13
 str x12,[sp,#400]
 ldr x14,[x9,#8]
 add x15,x14,x11
 ldr x16,[x9]
 madd x15,x15,x13,x16
 str x15,[sp,#392]
 add x10,x14,x10
 madd x10,x10,x13,x16
 str x10,[sp,#384]
 ldr x0,[sp,#248]
 mov w1,w20
 mov w2,#16
 bl .Lledir_rank2
 mov x23,x0
 str x1,[sp,#280]
 str x2,[sp,#336]
 ldr x0,[sp,#256]
 mov w1,w20
 mov w2,#16
 bl .Lledir_rank2
 mov x24,x0
 str x1,[sp,#288]
 str x2,[sp,#344]
 ldr x0,[sp,#264]
 mov w1,#23
 sub w1,w1,w19
 mov w2,w20
 bl .Lledir_rank2
 mov x25,x0
 str x1,[sp,#296]
 str x2,[sp,#304]
 ldr x0,[sp,#384]
 add x0,x0,#104
 mov w1,#16
 ldr w2,[sp,#360]
 bl .Lledir_rank2
 cmp x1,#16
 b.ne .Lledir_bad
 mov x27,x0
 str x2,[sp,#320]
 ldr x0,[sp,#384]
 add x0,x0,#16
 mov w1,#16
 ldr w2,[sp,#364]
 bl .Lledir_rank2
 cmp x1,#16
 b.ne .Lledir_bad
 mov x28,x0
 str x2,[sp,#328]
 ldr x26,[sp,#272]
 cbz x26,.Lledir_bad
 mov x0,x23
 ldr x1,[sp,#336]
 bl .Lledir_readonly_range
 mov x0,x24
 ldr x1,[sp,#344]
 bl .Lledir_readonly_range
 mov x0,x26
 mov x1,#128
 bl .Lledir_readonly_range
 mov x0,x27
 ldr x1,[sp,#320]
 bl .Lledir_readonly_range
 mov x0,x28
 ldr x1,[sp,#328]
 bl .Lledir_readonly_range
 ldr x0,[sp,#408]
 mov x1,#56
 bl .Lledir_readonly_range
 ldr x0,[sp,#416]
 mov x1,#120
 bl .Lledir_readonly_range
 ldr x0,[sp,#392]
 ldr x1,[sp,#400]
 bl .Lledir_readonly_range
 mov x29,#0
.Lledir_argument_ranges:
 add x9,sp,#192
 ldr x0,[x9,x29,lsl #3]
 mov x1,#4
 cmp x29,#7
 b.lt .Lledir_argument_range
 mov x1,#88
.Lledir_argument_range:
 bl .Lledir_readonly_range
 add x29,x29,#1
 cmp x29,#10
 b.lt .Lledir_argument_ranges
 lsl x0,x21,#8
 bl malloc
 cbz x0,.Lledir_bad
 str x0,[sp,#312]
 add x1,x0,x21,lsl #7
 str x1,[sp,#432]
 mov x9,#0
 mov x10,x23
 mov x11,x24
 lsl x12,x22,#3
 mov x13,x12
.Lledir_weight_column:
 mov x14,#0
.Lledir_weight_latitude:
 ldr d0,[x26,x14,lsl #3]
 ldr x15,[sp,#280]
 mul x15,x15,x14
 ldr d1,[x10,x15,lsl #3]
 ldr x15,[sp,#288]
 mul x15,x15,x14
 ldr d2,[x11,x15,lsl #3]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d0 // fmul d1,d1,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d2,d2,d0 // fmul d2,d2,d0
 str d1,[x0],#8
 str d2,[x1],#8
 add x14,x14,#1
 cmp x14,#16
 b.lt .Lledir_weight_latitude
 add x10,x10,x12
 add x11,x11,x13
 add x9,x9,#1
 cmp x9,x21
 b.lt .Lledir_weight_column
 COUNT 0
 COUNT 2
 mov x0,x27
 ldr x1,[sp,#312]
 ldr w2,[sp,#360]
 ldr w3,[sp,#352]
 bl .Lledir_project
 COUNT 1
 mov x0,x28
 ldr x1,[sp,#432]
 ldr w2,[sp,#364]
 ldr w3,[sp,#356]
 bl .Lledir_project
 COUNT 3
 ldr x0,[sp,#312]
 bl free
 COUNT 4
 b .Lledir_return
.Lledir_empty:
 COUNT 5
.Lledir_return:
 ldp d8,d9,[sp,#128]
 ldp d10,d11,[sp,#144]
 ldp d12,d13,[sp,#160]
 ldp d14,d15,[sp,#176]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 ldr x18,[sp,#24]
 add sp,sp,#512
 ret
.size md2asm_ltdir_ledir_child_7358525,.-md2asm_ltdir_ledir_child_7358525
.Lledir_project:
 mov x9,#0
.Lledir_project_column:
 mov x10,#0
.Lledir_project_degree:
 add x11,x0,x10,lsl #7
 mov x12,x1
 mov x13,#16
 fmov d0,xzr
.Lledir_project_latitude:
 ldr d1,[x11],#8
 ldr d2,[x12],#8
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1,d1,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 subs x13,x13,#1
 b.ne .Lledir_project_latitude
 ldr x14,[sp,#296]
 mul x15,x9,x22
 mul x15,x15,x14
 add x15,x15,w3,uxtw
 sub x15,x15,#1
 add x15,x15,x10,lsl #1
 str d0,[x25,x15,lsl #3]
 add x10,x10,#1
 cmp x10,x2
 b.lt .Lledir_project_degree
 add x1,x1,#128
 add x9,x9,#1
 cmp x9,x21
 b.lt .Lledir_project_column
 ret
.Lledir_rank2:
 cbz x0,.Lledir_bad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lledir_bad
 ldrb w9,[x0,#28]
 cmp w9,#2
 b.ne .Lledir_bad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lledir_bad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lledir_bad
 ldr x11,[x0,#48]
 ldr x9,[x0,#56]
 sub x9,x9,x11
 add x9,x9,#1
 cmp x9,x1
 b.lt .Lledir_bad
 ldr x12,[x0,#72]
 ldr x10,[x0,#80]
 sub x10,x10,x12
 add x10,x10,#1
 cmp x10,x2
 b.lt .Lledir_bad
 ldr x13,[x0,#64]
 cmp x13,x9
 b.ne .Lledir_bad
 mul x2,x9,x10
 cmp x2,#0
 b.le .Lledir_bad
 mov x13,#0x8000000
 cmp x2,x13
 b.hi .Lledir_bad
 lsl x2,x2,#3
 ldr x13,[x0,#8]
 madd x12,x12,x9,x13
 add x12,x12,x11
 ldr x0,[x0]
 cbz x0,.Lledir_bad
 add x0,x0,x12,lsl #3
 mov x1,x9
 ret
.Lledir_readonly_range:
 cbz x0,.Lledir_bad
 adds x10,x0,x1
 b.cs .Lledir_bad
 ldr x9,[sp,#304]
 adds x9,x25,x9
 b.cs .Lledir_bad
 cmp x25,x10
 b.hs .Lledir_range_disjoint
 cmp x0,x9
 b.lo .Lledir_bad
.Lledir_range_disjoint:
 ret
.Lledir_bad:
 bl abort
 brk #0
.global md2asm_ltdir_ledir_child_count_7358525
.type md2asm_ltdir_ledir_child_count_7358525,%function
md2asm_ltdir_ledir_child_count_7358525:
 cmp w0,#6
 b.hs .Lledir_count_empty
 adrp x9,.Lledir_counts
 add x9,x9,:lo12:.Lledir_counts
 ldr x0,[x9,w0,uxtw #3]
 ret
.Lledir_count_empty:
 mov x0,#0
 ret
.size md2asm_ltdir_ledir_child_count_7358525,.-md2asm_ltdir_ledir_child_count_7358525
.bss
.p2align 3
.Lledir_counts:
 .skip 48
.section .note.GNU-stack,"",%progbits

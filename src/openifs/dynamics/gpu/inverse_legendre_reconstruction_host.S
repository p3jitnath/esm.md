/* GPU contract: skills/md2asm-gpu/references/openifs/dynamics/inverse_legendre_reconstruction.md */
.text
.p2align 4
.macro COUNT index
 adrp x9,.Lleinv_counts
 add x9,x9,:lo12:.Lleinv_counts
 ldr x10,[x9,#8*\index]
 add x10,x10,#1
 str x10,[x9,#8*\index]
.endm
.global md2asm_ltinv_leinv
.type md2asm_ltinv_leinv,%function
md2asm_ltinv_leinv:
 mov x17,sp
 sub sp,sp,#448
 str x18,[sp,#24]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 stp x0,x1,[sp,#192]
 stp x2,x3,[sp,#208]
 stp x4,x5,[sp,#224]
 stp x6,x7,[sp,#240]
 ldp x9,x10,[x17]
 stp x9,x10,[sp,#256]
 mrs x9,fpcr
 cbnz x9,.Lleinv_bad
 ldrsw x19,[x0]
 cmp x19,#21
 b.hi .Lleinv_bad
 ldr w9,[x1]
 add w10,w19,#1
 cmp w9,w10
 b.ne .Lleinv_bad
 str w9,[sp,#368]
 ldrsw x20,[x2]
 cmp x20,#0
 b.lt .Lleinv_bad
 ldrsw x21,[x3]
 cmp x21,#0
 b.lt .Lleinv_bad
 ldr w9,[x6]
 cmp w9,#0
 b.lt .Lleinv_bad
 cbz w9,.Lleinv_empty
 cbnz x20,.Lleinv_width_check
 cbnz x21,.Lleinv_bad
 ldr w9,[x4]
 cbnz w9,.Lleinv_bad
 b .Lleinv_empty
.Lleinv_width_check:
 cmp x20,#2
 b.eq .Lleinv_width_ok
 cmp x20,#4
 b.eq .Lleinv_width_ok
 cmp x20,#38
 b.eq .Lleinv_width_ok
 cmp x20,#76
 b.eq .Lleinv_width_ok
 cmp x20,#194
 b.eq .Lleinv_width_ok
 cmp x20,#232
 b.ne .Lleinv_bad
.Lleinv_width_ok:
 ldr w9,[x6]
 cmp w9,#16
 b.ne .Lleinv_bad
 ldr w9,[x5]
 cmp w9,#1
 b.ne .Lleinv_bad
 ldr w9,[x4]
 lsr w10,w20,#1
 cmp w9,w10
 b.ne .Lleinv_bad
 mov x22,#1
 cbnz x19,.Lleinv_step_ok
 mov x22,#2
.Lleinv_step_ok:
 udiv x9,x20,x22
 cmp x9,x21
 b.ne .Lleinv_bad
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
 cbz x9,.Lleinv_bad
 str x9,[sp,#408]
 ldr w10,[x9]
 cmp w10,#21
 b.ne .Lleinv_bad
 adrp x9,:got:__tpm_flt_MOD_s
 ldr x9,[x9,:got_lo12:__tpm_flt_MOD_s]
 ldr x9,[x9]
 cbz x9,.Lleinv_bad
 str x9,[sp,#416]
 ldr w10,[x9,#72]
 cbnz w10,.Lleinv_bad
 ldr x10,[x9,#16]
 cmp x10,#744
 b.ne .Lleinv_bad
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lleinv_bad
 ldr x10,[x9,#32]
 cmp x10,#744
 b.ne .Lleinv_bad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lleinv_bad
 ldrsw x10,[sp,#368]
 ldr x11,[x9,#48]
 cmp x10,x11
 b.lt .Lleinv_bad
 ldr x12,[x9,#56]
 cmp x10,x12
 b.gt .Lleinv_bad
 sub x12,x12,x11
 add x12,x12,#1
 cmp x12,#1000
 b.hi .Lleinv_bad
 mov x13,#744
 mul x12,x12,x13
 str x12,[sp,#400]
 ldr x14,[x9,#8]
 add x15,x14,x11
 ldr x16,[x9]
 cbz x16,.Lleinv_bad
 madd x15,x15,x13,x16
 str x15,[sp,#392]
 add x10,x14,x10
 madd x10,x10,x13,x16
 str x10,[sp,#384]
 ldr x0,[sp,#248]
 mov w1,#24
 sub w1,w1,w19
 mov w2,w20
 bl .Lleinv_rank2
 mov x23,x0
 str x1,[sp,#280]
 str x2,[sp,#304]
 ldr x0,[sp,#256]
 mov w1,w20
 mov w2,#16
 bl .Lleinv_rank2
 mov x24,x0
 str x1,[sp,#288]
 str x2,[sp,#312]
 ldr x0,[sp,#264]
 mov w1,w20
 mov w2,#16
 bl .Lleinv_rank2
 mov x25,x0
 str x1,[sp,#296]
 str x2,[sp,#320]
 ldr x0,[sp,#384]
 add x0,x0,#104
 mov w1,#16
 ldr w2,[sp,#360]
 bl .Lleinv_rank2
 cmp x1,#16
 b.ne .Lleinv_bad
 mov x27,x0
 str x2,[sp,#328]
 ldr x0,[sp,#384]
 add x0,x0,#16
 mov w1,#16
 ldr w2,[sp,#364]
 bl .Lleinv_rank2
 cmp x1,#16
 b.ne .Lleinv_bad
 mov x28,x0
 str x2,[sp,#336]
 ldr x9,[sp,#312]
 add x10,x24,x9
 ldr x9,[sp,#320]
 add x11,x25,x9
 cmp x24,x11
 b.hs .Lleinv_outputs_disjoint
 cmp x25,x10
 b.lo .Lleinv_bad
.Lleinv_outputs_disjoint:
 mov x0,x23
 ldr x1,[sp,#304]
 bl .Lleinv_readonly_range
 mov x0,x27
 ldr x1,[sp,#328]
 bl .Lleinv_readonly_range
 mov x0,x28
 ldr x1,[sp,#336]
 bl .Lleinv_readonly_range
 ldr x0,[sp,#408]
 mov x1,#56
 bl .Lleinv_readonly_range
 ldr x0,[sp,#416]
 mov x1,#120
 bl .Lleinv_readonly_range
 ldr x0,[sp,#392]
 ldr x1,[sp,#400]
 bl .Lleinv_readonly_range
 mov x29,#0
.Lleinv_argument_ranges:
 add x9,sp,#192
 ldr x0,[x9,x29,lsl #3]
 mov x1,#4
 cmp x29,#7
 b.lt .Lleinv_argument_range
 mov x1,#88
.Lleinv_argument_range:
 bl .Lleinv_readonly_range
 add x29,x29,#1
 cmp x29,#10
 b.lt .Lleinv_argument_ranges
 COUNT 0
 cbnz x19,.Lleinv_antisymmetric
 mov x9,#1
 ldr x12,[sp,#288]
 lsl x12,x12,#3
 ldr x13,[sp,#296]
 lsl x13,x13,#3
.Lleinv_mean_field:
 add x10,x24,x9,lsl #3
 add x11,x25,x9,lsl #3
 mov x14,#16
.Lleinv_mean_latitude:
 str xzr,[x10]
 str xzr,[x11]
 add x10,x10,x12
 add x11,x11,x13
 subs x14,x14,#1
 b.ne .Lleinv_mean_latitude
 add x9,x9,#2
 cmp x9,x20
 b.lo .Lleinv_mean_field
 COUNT 1
.Lleinv_antisymmetric:
 COUNT 2
 mov x0,x27
 mov x1,x24
 ldr x2,[sp,#288]
 lsl x2,x2,#3
 ldr w3,[sp,#352]
 ldr w4,[sp,#360]
 ldr x5,[sp,#280]
 lsl x5,x5,#3
 bl .Lleinv_half
 COUNT 3
 COUNT 4
 mov x0,x28
 mov x1,x25
 ldr x2,[sp,#296]
 lsl x2,x2,#3
 ldr w3,[sp,#356]
 ldr w4,[sp,#364]
 ldr x5,[sp,#280]
 lsl x5,x5,#3
 bl .Lleinv_half
 COUNT 5
 b .Lleinv_return
.Lleinv_empty:
 COUNT 0
.Lleinv_return:
 ldr x18,[sp,#24]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#448
 ret
.size md2asm_ltinv_leinv,.-md2asm_ltinv_leinv
.Lleinv_half:
 b md2asm_inverse_legendre_half_gpu_phase
/* Original metadata decoding follows unchanged. */
.Lleinv_rank2:
 cbz x0,.Lleinv_bad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lleinv_bad
 ldrb w9,[x0,#28]
 cmp w9,#2
 b.ne .Lleinv_bad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lleinv_bad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lleinv_bad
 ldp x10,x11,[x0,#48]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,x1
 b.lt .Lleinv_bad
 cmp x11,#1000
 b.hi .Lleinv_bad
 ldp x12,x13,[x0,#72]
 sub x13,x13,x12
 add x13,x13,#1
 cmp x13,x2
 b.lt .Lleinv_bad
 cmp x13,#1000
 b.hi .Lleinv_bad
 ldr x14,[x0,#64]
 cmp x14,x11
 b.ne .Lleinv_bad
 ldr x15,[x0,#8]
 madd x15,x12,x14,x15
 add x15,x15,x10
 ldr x16,[x0]
 cbz x16,.Lleinv_bad
 add x0,x16,x15,lsl #3
 mov x1,x11
 mul x2,x11,x13
 lsl x2,x2,#3
 adds x9,x0,x2
 b.cs .Lleinv_bad
 ret
.Lleinv_readonly_range:
 cbz x1,.Lleinv_range_disjoint
 cbz x0,.Lleinv_bad
 adds x10,x0,x1
 b.cs .Lleinv_bad
 ldr x9,[sp,#312]
 adds x9,x24,x9
 b.cs .Lleinv_bad
 cmp x24,x10
 b.hs .Lleinv_check_symmetric
 cmp x0,x9
 b.lo .Lleinv_bad
.Lleinv_check_symmetric:
 ldr x9,[sp,#320]
 adds x9,x25,x9
 b.cs .Lleinv_bad
 cmp x25,x10
 b.hs .Lleinv_range_disjoint
 cmp x0,x9
 b.lo .Lleinv_bad
.Lleinv_range_disjoint:
 ret
.Lleinv_bad:
 bl abort
 brk #0
.global md2asm_ltinv_leinv_count_get
.type md2asm_ltinv_leinv_count_get,%function
md2asm_ltinv_leinv_count_get:
 cmp w0,#6
 b.hs .Lleinv_count_empty
 adrp x9,.Lleinv_counts
 add x9,x9,:lo12:.Lleinv_counts
 ldr x0,[x9,w0,uxtw #3]
 ret
.Lleinv_count_empty:
 mov x0,#0
 ret
.size md2asm_ltinv_leinv_count_get,.-md2asm_ltinv_leinv_count_get
.bss
.p2align 3
.Lleinv_counts:
 .skip 48
.section .note.GNU-stack,"",%progbits

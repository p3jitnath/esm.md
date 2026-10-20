/* Complete positive normal logarithm: original guards and one GPU launch.
 * Contract: skills/md2asm-gpu/references/openifs/support/positive_normal_logarithm_complete_contract.md
 * Original source: src/openifs/support/positive_natural_logarithm.S
 */
// Copyright (c) 2018-2025, Arm Limited.
// SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
// Original contract: skills/md2asm/references/openifs/support/positive_natural_logarithm.md
// Complete numerical work is supplied by the accepted pure GPU child.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_log_positive_normal
.type md2asm_log_positive_normal,%function
md2asm_log_positive_normal:
 mrs x9,fpcr
 cbnz x9,.Lreject
 fmov x1,d0
 movz x2,#0x3cb0,lsl#48
 cmp x1,x2
 b.lo .Lreject
 movz x2,#0x7ff0,lsl#48
 cmp x1,x2
 b.hs .Lreject
 adrp x9,md2asm_log_positive_normal_calls
 add x9,x9,:lo12:md2asm_log_positive_normal_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 movz x2,#0x3ff0,lsl#48
 cmp x1,x2
 b.ne md2asm_log_positive_normal_gpu_phase
 fmov d0,xzr
 ret
.Lreject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size md2asm_log_positive_normal,.-md2asm_log_positive_normal

// Private phase. The four private owners lie inside this 1024-byte frame.
.p2align 4
.hidden md2asm_log_positive_normal_gpu_phase
.type md2asm_log_positive_normal_gpu_phase,%function
md2asm_log_positive_normal_gpu_phase:
 sub sp,sp,#1024
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 stp x16,x17,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 stp x28,x29,[sp,#224]
 str x30,[sp,#240]
 stp q0,q1,[sp,#256]
 stp q2,q3,[sp,#288]
 stp q4,q5,[sp,#320]
 stp q6,q7,[sp,#352]
 stp q8,q9,[sp,#384]
 stp q10,q11,[sp,#416]
 stp q12,q13,[sp,#448]
 stp q14,q15,[sp,#480]
 stp q16,q17,[sp,#512]
 stp q18,q19,[sp,#544]
 stp q20,q21,[sp,#576]
 stp q22,q23,[sp,#608]
 stp q24,q25,[sp,#640]
 stp q26,q27,[sp,#672]
 stp q28,q29,[sp,#704]
 stp q30,q31,[sp,#736]
 mrs x9,fpcr
 mrs x10,fpsr
 mrs x11,nzcv
 str x9,[sp,#768]
 str x10,[sp,#776]
 str x11,[sp,#784]
 bl __errno_location
 ldr x18,[sp,#144]
 str x0,[sp,#792]
 ldr w9,[x0]
 str w9,[sp,#800]
 bl omp_in_parallel
 ldr x18,[sp,#144]
 cbnz w0,.Llog_phase_fatal
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#144]
 cbnz w0,.Llog_phase_fatal
 add x19,sp,#832
 mov x9,#0
.Llog_zero_private:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#16
 b.lo .Llog_zero_private
 add x21,sp,#848
 add x20,sp,#864
 ldr x9,[sp,#256]
 stp x9,x21,[x19]
 mov w9,#1
 str w9,[x20,#4]
 add x16,sp,#928
 str x16,[x20,#48]
 mov x9,#32
 str x9,[x20,#56]
 mov x9,#16
 stp x9,x9,[x16]
 ldr x9,[sp,#768]
 ldr x10,[sp,#776]
 msr fpcr,x9
 msr fpsr,x10
 ldr x9,[sp,#792]
 ldr w10,[sp,#800]
 str w10,[x9]
 adrp x0,.Llog_complete_entry_name
 add x0,x0,:lo12:.Llog_complete_entry_name
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#144]
 cbnz w0,.Llog_phase_fatal
 ldr w9,[x20]
 cbnz w9,.Llog_phase_fatal
 ldr w9,[x21,#12]
 cbnz w9,.Llog_phase_fatal
 ldr x9,[x21]
 str x9,[sp,#256]
 ldr x9,[sp,#768]
 msr fpcr,x9
 ldr x9,[sp,#776]
 ldr w10,[x20,#8]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x9,[sp,#792]
 ldr w10,[sp,#800]
 str w10,[x9]
 ldr x9,[sp,#784]
 msr nzcv,x9
 ldp q0,q1,[sp,#256]
 ldp q2,q3,[sp,#288]
 ldp q4,q5,[sp,#320]
 ldp q6,q7,[sp,#352]
 ldp q8,q9,[sp,#384]
 ldp q10,q11,[sp,#416]
 ldp q12,q13,[sp,#448]
 ldp q14,q15,[sp,#480]
 ldp q16,q17,[sp,#512]
 ldp q18,q19,[sp,#544]
 ldp q20,q21,[sp,#576]
 ldp q22,q23,[sp,#608]
 ldp q24,q25,[sp,#640]
 ldp q26,q27,[sp,#672]
 ldp q28,q29,[sp,#704]
 ldp q30,q31,[sp,#736]
 ldp x0,x1,[sp,#0]
 ldp x2,x3,[sp,#16]
 ldp x4,x5,[sp,#32]
 ldp x6,x7,[sp,#48]
 ldp x8,x9,[sp,#64]
 ldp x10,x11,[sp,#80]
 ldp x12,x13,[sp,#96]
 ldp x14,x15,[sp,#112]
 ldp x16,x17,[sp,#128]
 ldp x18,x19,[sp,#144]
 ldp x20,x21,[sp,#160]
 ldp x22,x23,[sp,#176]
 ldp x24,x25,[sp,#192]
 ldp x26,x27,[sp,#208]
 ldp x28,x29,[sp,#224]
 ldr x30,[sp,#240]
 add sp,sp,#1024
 ret
.Llog_phase_fatal:
 bl abort
 brk #0
.size md2asm_log_positive_normal_gpu_phase,.-md2asm_log_positive_normal_gpu_phase
.section .rodata
.Llog_complete_entry_name:.asciz "md2asm_gpu_log_positive_normal"
.data
.p2align 3
.hidden md2asm_log_positive_normal_calls
.global md2asm_log_positive_normal_calls
.type md2asm_log_positive_normal_calls,%object
md2asm_log_positive_normal_calls:
 .quad 0
.size md2asm_log_positive_normal_calls,8
.section .note.GNU-stack,"",%progbits

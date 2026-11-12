// Original argument storage and CUDA call control. No numerical operation.
// Contract: skills/md2fort-gpu/references/openifs/physics_forecast_calls.md.
// Revision 1. Serial and nonrecursive calls.
.text
.p2align 2
.macro BEGIN original,count
.global \original
.type \original,%function
\original:
 sub sp,sp,#1152
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 str x21,[sp,#32]
 str x18,[sp,#40]
 mov x29,sp
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 .if \count > 8
 add x9,sp,#1152
 add x10,sp,#192
 mov w11,#(\count-8)
.Lcopy\@:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Lcopy\@
 .endif
 add x19,sp,#128
 add x20,sp,#912
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
 add x21,sp,#976
.endm
.macro CONSTANT offset,name
 adrp x9,:got:\name
 ldr x9,[x9,:got_lo12:\name]
 str x9,[x21,#\offset]
.endm
.macro RECORD bytes
 str x21,[x20,#48]
 mov x9,#\bytes
 str x9,[x20,#56]
.endm
.macro FINISH original,entry,counter
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#40]
 cbnz w0,.Lfailure\@
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#128
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#40]
 cbnz w0,.Lfailure\@
 adrp x9,:got:\counter
 ldr x9,[x9,:got_lo12:\counter]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#40]
 ldr x21,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1152
 ret
.Lfailure\@:
 bl abort
 brk #0
.size \original,.-\original
.section .rodata
.Lentry\@: .asciz "\entry"
.bss
.balign 8
.global \counter
.hidden \counter
\counter: .zero 8
.text
.endm
BEGIN md2asm_callpar_state_update_7358525,5
FINISH md2asm_callpar_state_update_7358525,md2asm_gpu_state_update,state_update_gpu_calls
BEGIN md2asm_callpar_state_increment_7358525,13
FINISH md2asm_callpar_state_increment_7358525,md2asm_gpu_state_increment,state_increment_gpu_calls
BEGIN md2asm_callpar_update_fields_7358525,97
FINISH md2asm_callpar_update_fields_7358525,md2asm_gpu_update_fields,update_fields_gpu_calls
BEGIN md2asm_callpar_qnegat_7358525,11
CONSTANT 0,__yomcst_MOD_rg
RECORD 8
FINISH md2asm_callpar_qnegat_7358525,md2asm_gpu_qnegat,qnegat_gpu_calls
BEGIN md2asm_callpar_satur_7358525,10
CONSTANT 0,__yoethf_MOD_rtice
CONSTANT 8,__yoethf_MOD_rticecu
CONSTANT 16,__yoethf_MOD_rtwat_rtice_r
CONSTANT 24,__yoethf_MOD_rtwat_rticecu_r
CONSTANT 32,__yoethf_MOD_rtwat
CONSTANT 40,__yomcst_MOD_retv
CONSTANT 48,__yomcst_MOD_rtt
CONSTANT 56,__yoethf_MOD_r2es
CONSTANT 64,__yoethf_MOD_r3les
CONSTANT 72,__yoethf_MOD_r4les
CONSTANT 80,__yoethf_MOD_r3ies
CONSTANT 88,__yoethf_MOD_r4ies
RECORD 96
FINISH md2asm_callpar_satur_7358525,md2asm_gpu_satur,satur_gpu_calls
.global satur_
.set satur_,md2asm_callpar_satur_7358525
BEGIN md2asm_drv_physics_close_7358525,18
CONSTANT 0,__yoethf_MOD_ralvdcp
CONSTANT 8,__yoethf_MOD_ralsdcp
RECORD 16
FINISH md2asm_drv_physics_close_7358525,md2asm_gpu_cpqtuv,cpqtuv_gpu_calls
.section .note.GNU-stack,"",%progbits

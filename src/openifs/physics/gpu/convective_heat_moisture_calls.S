// Contract: skills/md2fort-gpu/references/openifs/physics/convective_heat_moisture.md.
// Original ABI storage/launch draft from original_host_contract.md revision1.
.text
.p2align 2
.macro CONST reg,value
 movz \reg,#((\value)&65535)
 .if ((\value)>>16)
 movk \reg,#(((\value)>>16)&65535),lsl #16
 .endif
.endm
.macro BEGIN name,count
.global \name
.type \name,%function
\name:
 sub sp,sp,#4096
 stp x29,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 add x29,sp,#128
 stp x0,x1,[sp,#256]
 stp x2,x3,[sp,#272]
 stp x4,x5,[sp,#288]
 stp x6,x7,[sp,#304]
 .if \count>8
 add x9,sp,#4096
 add x10,sp,#320
 mov w11,#(\count-8)
.Lstack_copy\@:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Lstack_copy\@
 .endif
 add x19,sp,#256
 add x20,sp,#640
 add x21,sp,#768
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
 mov x9,x21
 mov w10,#64
.Lzero_record\@:
 stp xzr,xzr,[x9],#16
 subs w10,w10,#1
 b.ne .Lzero_record\@
.endm
.macro RECORD bytes
 str x21,[x20,#48]
 mov x9,#\bytes
 str x9,[x20,#56]
.endm
.macro SERVICE target
 str x0,[sp,#1960]
 mrs x9,fpcr
 str x9,[sp,#1920]
 mrs x9,fpsr
 str x9,[sp,#1928]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#1936]
 ldr w9,[x0]
 str w9,[sp,#1944]
 ldr x0,[sp,#1960]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#1968]
 ldr x9,[sp,#1936]
 ldr w10,[sp,#1944]
 str w10,[x9]
 ldr x9,[sp,#1920]
 msr fpcr,x9
 ldr x9,[sp,#1928]
 msr fpsr,x9
 ldr x0,[sp,#1968]
.endm
.macro SERIAL_CALLER
 SERVICE __oml_mod_MOD_oml_in_parallel
 cbnz w0,.Ldraft_failure
.endm
.macro BYTES destination,left,right
 umulh x17,\left,\right
 cbnz x17,.Ldraft_failure
 mul \destination,\left,\right
 lsr x17,\destination,#60
 cbnz x17,.Ldraft_failure
 lsl \destination,\destination,#3
.endm
.macro ALLOC bytes
 str \bytes,[x20,#40]
 cbz \bytes,.Lallocated\@
 mov x0,\bytes
 SERVICE malloc
 cbz x0,.Ldraft_failure
 str x0,[x20,#32]
.Lallocated\@:
.endm
.macro FINISH name,entry,counter,release=0
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 .if \release
 ldr x0,[x20,#32]
 cbz x0,.Lreleased\@
 SERVICE free
.Lreleased\@:
 .endif
 adrp x9,:got:\counter
 ldr x9,[x9,:got_lo12:\counter]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#224]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldp x29,x30,[sp,#128]
 add sp,sp,#4096
 ret
.size \name,.-\name
.section .rodata
.Lentry\@: .asciz "\entry"
.bss
.balign 8
.global \counter
.hidden \counter
\counter: .zero 8
.text
.endm
.macro ALIAS name,target
.global \name
.set \name,\target
.endm
BEGIN md2asm_gpu_host_cudtdqn,44
 RECORD 80
 SERIAL_CALLER
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 str x9,[x21,#0]
 adrp x9,:got:__yomcst_MOD_rcpd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
 str x9,[x21,#8]
 adrp x9,:got:__yomcst_MOD_rlvtt
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rlvtt]
 str x9,[x21,#16]
 adrp x9,:got:__yomcst_MOD_rlstt
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rlstt]
 str x9,[x21,#24]
 adrp x9,:got:__yomcst_MOD_rlmlt
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rlmlt]
 str x9,[x21,#32]
 adrp x9,:got:__yoethf_MOD_rticecu
 ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
 str x9,[x21,#40]
 adrp x9,:got:__yoethf_MOD_rtwat
 ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
 str x9,[x21,#48]
 adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
 ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
 str x9,[x21,#56]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 str x9,[x21,#64]
 mov x9,#4
 str x9,[x21,#72]
 ldr x9,[x19,#48]
 cbz x9,.Ldraft_failure
 tst x9,#3
 b.ne .Ldraft_failure
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Ldraft_failure
 CONST x11,2048
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#56]
 cbz x9,.Ldraft_failure
 tst x9,#3
 b.ne .Ldraft_failure
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Ldraft_failure
 CONST x11,512
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#32]
 cbz x9,.Ldraft_failure
 tst x9,#3
 b.ne .Ldraft_failure
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Ldraft_failure
 CONST x11,2049
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#40]
 cbz x9,.Ldraft_failure
 tst x9,#3
 b.ne .Ldraft_failure
 ldrsw x10,[x9]
 cmp x10,#0
 b.lt .Ldraft_failure
 CONST x11,2048
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#64]
 cbz x9,.Ldraft_failure
 tst x9,#3
 b.ne .Ldraft_failure
 ldrsw x10,[x9]
 cmp x10,#2
 b.lt .Ldraft_failure
 CONST x11,513
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#48]
 ldrsw x22,[x9]
 ldr x9,[x19,#56]
 ldrsw x23,[x9]
 ldr x9,[x19,#64]
 ldrsw x10,[x9]
 add x11,x23,#1
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#32]
 ldrsw x10,[x9]
 add x11,x22,#1
 cmp x10,x11
 b.gt .Ldraft_failure
 ldr x9,[x19,#40]
 ldrsw x11,[x9]
 cmp x11,x22
 b.gt .Ldraft_failure
 cmp x10,x11
 b.gt .Lscratch_ready
 mul x25,x22,x23
 mov x9,#60
 mul x10,x25,x9
 add x10,x10,x22,lsl #3
 add x10,x10,#31
 and x10,x10,#-16
 CONST x11,1048576
 cmp x10,x11
 b.hi .Ldraft_failure
 mov x9,#120
 mul x24,x25,x9
 add x24,x24,x22,lsl #3
 lsl x10,x25,#2
 add x10,x10,#7
 and x10,x10,#-8
 add x24,x24,x10
 lsl x10,x22,#2
 add x10,x10,#7
 and x10,x10,#-8
 add x24,x24,x10
 add x24,x24,#4096
 ALLOC x24
.Lscratch_ready:
 FINISH md2asm_gpu_host_cudtdqn,md2asm_gpu_cudtdqn,md2asm_gpu_cudtdqn_launches,1
 ALIAS md2asm_cudtdqn,md2asm_gpu_host_cudtdqn
.Ldraft_failure:
 bl abort
 brk #0
.global md2asm_gpu_cudtdqn_launch_count_get
.type md2asm_gpu_cudtdqn_launch_count_get,%function
md2asm_gpu_cudtdqn_launch_count_get:
 adrp x9,:got:md2asm_gpu_cudtdqn_launches
 ldr x9,[x9,:got_lo12:md2asm_gpu_cudtdqn_launches]
 ldr x0,[x9]
 ret
.size md2asm_gpu_cudtdqn_launch_count_get,.-md2asm_gpu_cudtdqn_launch_count_get
.section .note.GNU-stack,"",%progbits

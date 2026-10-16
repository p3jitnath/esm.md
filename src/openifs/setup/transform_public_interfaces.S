/* Contract:skills/md2asm/references/openifs/setup/transform_interface_contract.md. Fixed public external targets only.
 * x0 complete aligned pointer-word array; at least max(8,N) words mapped.
 * w0=0 after call,2 null/alignment reject. Preservex18/ABI, natural external status.
 */
.arch armv8.2-a
.text
.macro PUBLIC_CALL name,target,nargs,stack,frame
.p2align 4
.global \name
.type \name,%function
\name:
 cbz x0,.Lpublic_reject_\@
 tst x0,#7
 b.ne .Lpublic_reject_\@
 sub sp,sp,#\frame
 stp x29,x30,[sp,#\stack]
 stp x19,x18,[sp,#(\stack+16)]
 add x29,sp,#\stack
 mov x19,x0
.if \nargs > 8
 mov x9,#8
.Lpublic_pack_\@:
 ldr x10,[x19,x9,lsl#3]
 sub x11,x9,#8
 str x10,[sp,x11,lsl#3]
 add x9,x9,#1
 cmp x9,#\nargs
 b.lo .Lpublic_pack_\@
.endif
 ldp x0,x1,[x19]
 ldp x2,x3,[x19,#16]
 ldp x4,x5,[x19,#32]
 ldp x6,x7,[x19,#48]
 bl \target
 ldp x29,x30,[sp,#\stack]
 ldp x19,x18,[sp,#(\stack+16)]
 add sp,sp,#\frame
 mov w0,#0
 ret
.Lpublic_reject_\@:
 mov w0,#2
 ret
.size \name,.-\name
.endm
PUBLIC_CALL md2asm_call_public_message_init,__mpl_init_mod_MOD_mpl_init,6,0,32
PUBLIC_CALL md2asm_call_public_transform_setup0,setup_trans0_,18,80,112
PUBLIC_CALL md2asm_call_public_transform_setup,setup_trans_,24,128,160
PUBLIC_CALL md2asm_call_public_transform_inquiry,trans_inq_,47,320,352
PUBLIC_CALL md2asm_call_public_spectral_distribution,ini_spec_dist_,15,64,96
.section .note.GNU-stack,"",%progbits

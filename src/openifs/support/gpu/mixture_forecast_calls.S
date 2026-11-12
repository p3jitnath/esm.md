// Original mixture interfaces and CUDA control. All numerical work stays in PTX.
// Contract: skills/md2fort-gpu/references/openifs/dynamics/thermodynamic_properties.md.
// Revision 1. Serial, nonrecursive original host calls.
.text
.p2align 2
.macro BEGIN name,count
.global \name
.type \name,%function
\name:
 sub sp,sp,#768
 stp x29,x30,[sp,#64]
 stp x19,x20,[sp,#80]
 stp x21,x22,[sp,#96]
 stp x23,x24,[sp,#112]
 stp x25,x26,[sp,#128]
 stp x27,x28,[sp,#144]
 str x18,[sp,#160]
 add x29,sp,#64
 stp x0,x1,[sp,#192]
 stp x2,x3,[sp,#208]
 stp x4,x5,[sp,#224]
 stp x6,x7,[sp,#240]
 .if \count > 8
 add x9,sp,#768
 add x10,sp,#256
 mov w11,#(\count-8)
.Lcopy\@:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Lcopy\@
 .endif
 add x19,sp,#192
 add x20,sp,#320
 add x21,sp,#384
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
.endm
.macro RESTORE
 ldr x18,[sp,#160]
 ldp x19,x20,[sp,#80]
 ldp x21,x22,[sp,#96]
 ldp x23,x24,[sp,#112]
 ldp x25,x26,[sp,#128]
 ldp x27,x28,[sp,#144]
 ldp x29,x30,[sp,#64]
 add sp,sp,#768
 ret
.endm
.macro CONSTANT offset,name
 adrp x9,:got:\name
 ldr x9,[x9,:got_lo12:\name]
 str x9,[x21,#\offset]
.endm
.macro BUILD_RECORD is_ctvtot
 adrp x9,:got:__yom_ygfl_MOD_ygfl
 ldr x9,[x9,:got_lo12:__yom_ygfl_MOD_ygfl]
 ldr x23,[x9]
 str x23,[x21]
 CONSTANT 8,__yomcst_MOD_rd
 CONSTANT 16,__yomcst_MOD_rv
 CONSTANT 24,__yomcst_MOD_rcpd
 CONSTANT 32,__yomcst_MOD_rcpv
 CONSTANT 40,__yomcst_MOD_rcw
 CONSTANT 48,__yomcst_MOD_rcs
 str xzr,[x21,#56]
 .if \is_ctvtot
 ldr x9,[x19,#40]
 .else
 ldr x9,[x19,#104]
 .endif
 cbz x9,.Lrecord_ready\@
 cbz x23,.Lmixture_failure
 mov w10,#0
 .if !\is_ctvtot
 ldr x9,[x19,#112]
 cbz x9,.Lmode_ready\@
 ldr w10,[x9]
 .endif
.Lmode_ready\@:
 cbz w10,.Lfull_capacity\@
 cmp w10,#9
 b.eq .Lfull_capacity\@
 cmp w10,#1
 b.ne .Lmixture_failure
 ldrsw x10,[x23,#64]
 b .Lcapacity_ready\@
.Lfull_capacity\@:
 ldrsw x10,[x23,#48]
.Lcapacity_ready\@:
 str x10,[x21,#56]
.Lrecord_ready\@:
 str x21,[x20,#48]
 mov x9,#64
 str x9,[x20,#56]
.endm
.macro GRID
 mul x22,x24,x25
 add x22,x22,#127
 lsr x22,x22,#7
 mov w9,#0x7fffffff
 cmp x22,x9
 b.hi .Lmixture_failure
.endm
.macro LAUNCH entry
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov x1,x19
 mov x2,x20
 mov w3,w22
 mov w4,#128
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#160]
 cbnz w0,.Lmixture_failure
.section .rodata
.Lentry\@: .asciz "\entry"
.text
.endm
.macro COUNT name
 adrp x9,:got:\name
 ldr x9,[x9,:got_lo12:\name]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
.endm
.macro SERVICE target
 str x0,[sp,#544]
 mrs x9,fpcr
 str x9,[sp,#512]
 mrs x9,fpsr
 str x9,[sp,#520]
 bl __errno_location
 ldr x18,[sp,#160]
 str x0,[sp,#528]
 ldr w9,[x0]
 str w9,[sp,#536]
 ldr x0,[sp,#544]
 bl \target
 ldr x18,[sp,#160]
 str x0,[sp,#552]
 ldr x9,[sp,#528]
 ldr w10,[sp,#536]
 str w10,[x9]
 ldr x9,[sp,#512]
 msr fpcr,x9
 ldr x9,[sp,#520]
 msr fpsr,x9
 ldr x0,[sp,#552]
.endm
BEGIN md2asm_scan_gprcp_body_7358525,16
 ldp x9,x10,[x19,#80]
 ldr x11,[x19,#96]
 orr x9,x9,x10
 orr x9,x9,x11
 cbz x9,.Lgprcp_return
 ldr x9,[x19]
 ldrsw x24,[x9]
 ldr x9,[x19,#24]
 ldrsw x25,[x9]
 cbz x25,.Lgprcp_return
 cmp x24,#1
 b.lt .Lmixture_failure
 cmp x25,#0
 b.lt .Lmixture_failure
 ldp x9,x10,[x19,#8]
 ldr w9,[x9]
 ldr w10,[x10]
 cmp w9,w10
 b.gt .Lgprcp_return
 BUILD_RECORD 0
 GRID
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#160]
 cbnz w0,.Lmixture_failure
 LAUNCH md2asm_gpu_gprcp
 COUNT gprcp_gpu_calls
.Lgprcp_return:
 RESTORE
.size md2asm_scan_gprcp_body_7358525,.-md2asm_scan_gprcp_body_7358525
.global md2asm_lassie_gprcp,md2asm_hydrostatic_private_gprcp,md2asm_lagged_grid_gprcp,md2asm_ec_mixture_7358525
.set md2asm_lassie_gprcp,md2asm_scan_gprcp_body_7358525
.set md2asm_hydrostatic_private_gprcp,md2asm_scan_gprcp_body_7358525
.set md2asm_lagged_grid_gprcp,md2asm_scan_gprcp_body_7358525
.set md2asm_ec_mixture_7358525,md2asm_scan_gprcp_body_7358525
BEGIN md2asm_scan_ctvtot_body_7358525,6
 ldr x9,[x19]
 ldrsw x24,[x9,#5144]
 ldrsw x25,[x9,#5224]
 cbz x25,.Lctvtot_return
 cmp x24,#1
 b.lt .Lmixture_failure
 cmp x25,#0
 b.lt .Lmixture_failure
 ldp x9,x10,[x19,#16]
 ldr w9,[x9]
 ldr w10,[x10]
 cmp w9,w10
 b.gt .Lctvtot_return
 GRID
 mul x27,x24,x25
 lsl x27,x27,#3
 mov x0,x27
 SERVICE malloc
 cbz x0,.Lmixture_failure
 mov x26,x0
 stp xzr,xzr,[sp]
 stp xzr,x26,[sp,#16]
 ldr x9,[x19,#40]
 stp xzr,x9,[sp,#32]
 stp xzr,xzr,[sp,#48]
 ldr x9,[x19]
 mov x10,#5144
 add x0,x9,x10
 ldp x1,x2,[x19,#16]
 mov x10,#5224
 add x3,x9,x10
 mov x4,xzr
 mov x5,xzr
 mov x6,xzr
 mov x7,xzr
 bl md2asm_scan_gprcp_body_7358525
 ldr x18,[sp,#160]
 BUILD_RECORD 1
 str x26,[x20,#32]
 str x27,[x20,#40]
 LAUNCH md2asm_gpu_ctvtot
 COUNT ctvtot_gpu_calls
 mov x0,x26
 SERVICE free
.Lctvtot_return:
 RESTORE
.size md2asm_scan_ctvtot_body_7358525,.-md2asm_scan_ctvtot_body_7358525
.Lmixture_failure:
 bl abort
 brk #0
.bss
.balign 8
.global gprcp_gpu_calls,ctvtot_gpu_calls
.hidden gprcp_gpu_calls,ctvtot_gpu_calls
gprcp_gpu_calls: .zero 8
ctvtot_gpu_calls: .zero 8
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/support/global_perturbation_storage_owner.md.
 * Own the 1,584-byte global metadata record. The original type has no INIT.
 * x0: caller-owned eight-byte output slot; x1: capacity. Return 0, 1 or 2.
 * Release requires PTEMP at byte 1,272 to be clear after block FINAL.
 * Keep inactive cellular descriptions opaque; never follow their targets. */
.arch armv8.2-a
.text
.macro GP_ENTER
 sub sp,sp,#80
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#48]
 mov x19,x0
 bl __errno_location
 str x0,[sp,#64]
 ldr w9,[x0]
 str w9,[sp,#72]
.endm
.macro GP_LEAVE
 ldr x9,[sp,#64]
 ldr w10,[sp,#72]
 str w10,[x9]
 ldp x9,x10,[sp,#48]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,w21
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.endm
.macro GP_SLOT
 cbz x0,.Lgpo_bad
 tst x0,#7
 b.ne .Lgpo_bad
 cmp x1,#8
 b.lo .Lgpo_bad
 adds x8,x0,#8
 b.cs .Lgpo_bad
.endm
.p2align 4
.global md2asm_create_global_perturbation_owner
.type md2asm_create_global_perturbation_owner,%function
md2asm_create_global_perturbation_owner:
 GP_SLOT
 ldr x9,[x0]
 cbnz x9,.Lgpo_bad
 GP_ENTER
 mov x0,#1
 mov x1,#1584
 bl calloc
 mov x20,x0
 cbz x20,.Lgpo_allocate_failed
 str x20,[x19]
 mov w21,#0
 b .Lgpo_create_return
.Lgpo_allocate_failed:
 mov w21,#1
.Lgpo_create_return:
 GP_LEAVE
.size md2asm_create_global_perturbation_owner,.-md2asm_create_global_perturbation_owner
.p2align 4
.global md2asm_release_global_perturbation_owner
.type md2asm_release_global_perturbation_owner,%function
md2asm_release_global_perturbation_owner:
 GP_SLOT
 ldr x9,[x0]
 cbz x9,.Lgpo_success
 tst x9,#7
 b.ne .Lgpo_bad
 adds x10,x9,#1584
 b.cs .Lgpo_bad
 cmp x0,x10
 b.hs .Lgpo_slot_separate
 cmp x9,x8
 b.lo .Lgpo_bad
.Lgpo_slot_separate:
 ldr x10,[x9,#1272]
 cbnz x10,.Lgpo_bad
 GP_ENTER
 ldr x20,[x19]
 mov x0,x20
 bl free
 str xzr,[x19]
 mov w21,#0
 GP_LEAVE
.size md2asm_release_global_perturbation_owner,.-md2asm_release_global_perturbation_owner
.Lgpo_success:
 mov w0,#0
 ret
.Lgpo_bad:
 mov w0,#2
 ret
.section .note.GNU-stack,"",%progbits

/* Direct EIGSOL interface for an independently sourced EISPACK service.
 * Contract skills/md2asm/references/openifs/dynamics/semi_implicit_eigenvalues.md.
 * Ten ordinary addresses retain the original Fortran argument order.
 * x0..x7 are NM,N,A,WR,WI,MATZ,Z,IV1. Incoming SP0/SP8 hold FV1/IERR.
 * Caller owns complete column-major arrays. The service overwrites A.
 * Preserve x18 and every used saved register across external calls. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_semi_implicit_eigenvalues
.type md2asm_semi_implicit_eigenvalues,%function
md2asm_semi_implicit_eigenvalues:
 mov x9,sp
 sub sp,sp,#160
 stp x18,x19,[sp,#112]
 stp x20,x21,[sp,#128]
 stp x29,x30,[sp,#144]
 mov x29,sp
 stp x0,x1,[sp,#16]
 stp x2,x3,[sp,#32]
 stp x4,x5,[sp,#48]
 stp x6,x7,[sp,#64]
 ldp x10,x11,[x9]
 stp x10,x11,[sp,#80]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,.Leigen_run
 adrp x0,.Leigen_name
 add x0,x0,:lo12:.Leigen_name
 str wzr,[sp,#100]
 add x1,sp,#100
 add x2,sp,#104
 mov x3,#6
 bl __yomhook_MOD_dr_hook_default8
.Leigen_run:
 ldp x0,x1,[sp,#16]
 ldp x2,x3,[sp,#32]
 ldp x4,x5,[sp,#48]
 ldp x6,x7,[sp,#64]
 ldp x10,x11,[sp,#80]
 stp x10,x11,[sp]
 bl md2asm_netlib_rg_
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,.Leigen_return
 adrp x0,.Leigen_name
 add x0,x0,:lo12:.Leigen_name
 mov w9,#1
 str w9,[sp,#100]
 add x1,sp,#100
 add x2,sp,#104
 mov x3,#6
 bl __yomhook_MOD_dr_hook_default8
.Leigen_return:
 ldp x18,x19,[sp,#112]
 ldp x20,x21,[sp,#128]
 ldp x29,x30,[sp,#144]
 add sp,sp,#160
 ret
.size md2asm_semi_implicit_eigenvalues,.-md2asm_semi_implicit_eigenvalues
.section .rodata
.Leigen_name: .ascii "EIGSOL"
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/global_lateral_boundary_controls.md.
 * Global profile of SUELBC_INIT. No regional-model branch is admitted.
 * x0 target record, x1 available bytes, x2 LELAM, x3 control bytes.
 * Return w0=0 on success or2 before any write. Preserve X18, SP, all
 * callee-saved registers and floating-point state. Target and control
 * must not overlap. No calls are made.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_global_lateral_boundary_controls
.type md2asm_initialize_global_lateral_boundary_controls,%function
md2asm_initialize_global_lateral_boundary_controls:
 cbz x0,.Llateral_bad
 cbz x2,.Llateral_bad
 tst x0,#7
 b.ne .Llateral_bad
 tst x2,#3
 b.ne .Llateral_bad
 cmp x1,#2504
 b.lo .Llateral_bad
 cmp x3,#4
 b.lo .Llateral_bad
 adds x9,x0,#2504
 b.cs .Llateral_bad
 adds x10,x2,#4
 b.cs .Llateral_bad
 cmp x0,x10
 b.hs .Llateral_disjoint
 cmp x2,x9
 b.lo .Llateral_bad
.Llateral_disjoint:
 ldr w11,[x2]
 cbnz w11,.Llateral_bad
 /* These42 words are exactly the source-assigned prefix. */
 mov x9,x0
 mov x10,#21
.Llateral_zero:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Llateral_zero
 mov w11,#1
 str w11,[x0,#8]    /* LRFIRST */
 str w11,[x0,#36]   /* NECRIPL */
 str w11,[x0,#68]   /* NFRLSG */
 mov w0,#0
 ret
.Llateral_bad:
 mov w0,#2
 ret
.size md2asm_initialize_global_lateral_boundary_controls,.-md2asm_initialize_global_lateral_boundary_controls
.section .note.GNU-stack,"",%progbits

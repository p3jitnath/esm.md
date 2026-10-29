/* Apply the SUSPNG defaults for the inactive sponge profile.
 * x0: writable Model, aligned to 8 bytes.
 * x1: Model capacity in bytes, at least 4275088.
 * x2: read-only fort.4 bytes; x3: length from 1 to 262144 bytes.
 * Require a present empty NAMSPNG and an unallocated RSPONGF.
 * Write only the 4-byte LNSPONGE = false at Model byte 1570400.
 * Return w0 = 0, or w0 = 2 with Model unchanged.
 * Preserve x18, saved registers, FPCR, FPSR and errno.
 * Contract: skills/md2asm/references/openifs/setup/inactive_sponge_controls.md
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_inactive_sponge_controls
.type md2asm_initialize_inactive_sponge_controls,%function
md2asm_initialize_inactive_sponge_controls:
 cbz x0,.Lsponge_bad
 tst x0,#7
 b.ne .Lsponge_bad
 movz x9,#15248
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lsponge_bad
 adds x10,x0,x9
 b.cs .Lsponge_bad
 cbz x2,.Lsponge_bad
 cbz x3,.Lsponge_bad
 cmp x3,#64,lsl#12
 b.hi .Lsponge_bad
 adds x11,x2,x3
 b.cs .Lsponge_bad
 cmp x10,x2
 b.ls .Lsponge_separate
 cmp x11,x0
 b.hi .Lsponge_bad
.Lsponge_separate:
 movz x9,#63080
 movk x9,#23,lsl#16
 ldr x10,[x0,x9]
 cbnz x10,.Lsponge_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x19,x0
 mov x0,x2
 mov x1,x3
 adr x2,.Lsponge_group
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lsponge_done
 movz x9,#63072
 movk x9,#23,lsl#16
 str wzr,[x19,x9]
.Lsponge_done:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lsponge_bad:
 mov w0,#2
 ret
.size md2asm_initialize_inactive_sponge_controls,.-md2asm_initialize_inactive_sponge_controls
.section .rodata
.Lsponge_group: .ascii "NAMSPNG"
.section .note.GNU-stack,"",%progbits

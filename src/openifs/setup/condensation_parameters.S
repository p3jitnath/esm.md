/* Complete source SUCOND record, revision 1.
 * x0 TECND16, x1 capacity; return zero or two. Integer-only leaf.
 * Contract: skills/md2asm/references/openifs/setup/condensation_parameters.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_condensation_parameters
.type md2asm_initialize_condensation_parameters,%function
md2asm_initialize_condensation_parameters:
 cbz x0,.Lcp_bad
 tst x0,#7
 b.ne .Lcp_bad
 cmp x1,#16
 b.lo .Lcp_bad
 adds x2,x0,#16
 b.cs .Lcp_bad
 adrp x2,.Lcp_values
 add x2,x2,:lo12:.Lcp_values
 ldp x3,x4,[x2]
 stp x3,x4,[x0]
 mov w0,#0
 ret
.Lcp_bad:
 mov w0,#2
 ret
.size md2asm_initialize_condensation_parameters,.-md2asm_initialize_condensation_parameters
.section .rodata
.p2align 3
.Lcp_values:
 .quad 0x3af357c299a88ea7
 .quad 0x3e45798ee2308c3a
.section .note.GNU-stack,"",%progbits

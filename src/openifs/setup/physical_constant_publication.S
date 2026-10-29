/* Copy completed physical constants into their selected shared owner.
 * Contract: skills/md2asm/references/openifs/setup/physical_constant_publication.md.
 * x0 is the read-only source, x1 its capacity in bytes.
 * x2 is the writable destination, x3 its capacity in bytes.
 * Each owner has at least 520 bytes and eight-byte alignment.
 * Copy defined bytes 0 through 515. Preserve reserved bytes 516 through 519.
 * Return integer status 0 on success or 2 before any write on refusal.
 * Integer registers x0 through x7 may change. Preserve SP, x18, saved
 * registers, floating-point registers and status, and errno.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_publish_owned_physical_constant_namespace
.type md2asm_publish_owned_physical_constant_namespace,%function
md2asm_publish_owned_physical_constant_namespace:
 cbz x0,.Lpublish_bad
 cbz x2,.Lpublish_bad
 cmp x1,#520
 b.lo .Lpublish_bad
 cmp x3,#520
 b.lo .Lpublish_bad
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lpublish_bad
 adds x6,x0,#520
 b.cs .Lpublish_bad
 adds x7,x2,#520
 b.cs .Lpublish_bad
 cmp x0,x7
 b.hs .Lpublish_disjoint
 cmp x2,x6
 b.lo .Lpublish_bad
.Lpublish_disjoint:
 mov x4,#0
.Lpublish_words:
 ldr x5,[x0,x4]
 str x5,[x2,x4]
 add x4,x4,#8
 cmp x4,#512
 b.lo .Lpublish_words
 ldr w5,[x0,#512]
 str w5,[x2,#512]
 mov w0,#0
 ret
.Lpublish_bad:
 mov w0,#2
 ret
.size md2asm_publish_owned_physical_constant_namespace,.-md2asm_publish_owned_physical_constant_namespace
.section .note.GNU-stack,"",%progbits

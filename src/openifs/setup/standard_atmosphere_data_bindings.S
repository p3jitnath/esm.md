// Contract: skills/md2asm/references/openifs/setup/atmosphere_dynamics_data_bindings.md.
.arch armv8.2-a
// Copy the complete live SUSTA tables; no floating-point instruction.
.text
.p2align 4
.global md2asm_bind_standard_atmosphere_data
.type md2asm_bind_standard_atmosphere_data,%function
md2asm_bind_standard_atmosphere_data:
 cbz x0,.Latm_bad
 tst x0,#7
 b.ne .Latm_bad
 cmp x1,#576
 b.lo .Latm_bad
 adds x9,x0,#576
 b.cs .Latm_bad
 adrp x10,md2asm_owned_standard_atmosphere_data
 add x10,x10,:lo12:md2asm_owned_standard_atmosphere_data
 add x11,x10,#576
 cmp x0,x11
 b.hs .Latm_copy
 cmp x10,x9
 b.lo .Latm_bad
.Latm_copy:
 mov x11,#0
.Latm_words:
 ldr x12,[x0,x11]
 str x12,[x10,x11]
 add x11,x11,#8
 cmp x11,#576
 b.lo .Latm_words
 mov w0,#0
 ret
.Latm_bad:
 mov w0,#2
 ret
.size md2asm_bind_standard_atmosphere_data,.-md2asm_bind_standard_atmosphere_data
.section .note.GNU-stack,"",%progbits

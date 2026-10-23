/* Contract: skills/md2asm/references/openifs/dynamics/operational_time_coefficients.md.
 * Accepted component source. Complete operational forecast acceptance remains separate. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_update_operational_time_coefficients
.type md2asm_update_operational_time_coefficients,%function
md2asm_update_operational_time_coefficients:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x3,.Lbad
 orr x9,x0,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lbad
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 adds x11,x2,#8
 b.cs .Lbad
 adds x12,x3,#520
 b.cs .Lbad
 cmp x0,x12
 b.hs .Lapart
 cmp x3,x10
 b.lo .Lbad
.Lapart:
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldr x9,[x2]
 tbnz x9,#63,.Lbad
 cbz x9,.Lbad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lbad
 adr x11,.Llimits
 ldr x12,[x11]
 cmp x9,x12
 b.hi .Lbad
 ldr x9,[x3,#104]
 tbnz x9,#63,.Lbad
 ldp x10,x12,[x11,#8]
 cmp x9,x10
 b.lo .Lbad
 cmp x9,x12
 b.hi .Lbad
 ldr d0,[x2]
 ldr d1,[x3,#104]
 fmov d2,#0.5
 fmul d2,d2,d0
 fdiv d2,d2,d1
 fmul d3,d2,d2
 fmov d4,#6.0
 fdiv d4,d3,d4
 fmov d5,#2.0
 fdiv d5,d3,d5
 movz x9,#(1359544 & 65535)
 movk x9,#(1359544 >> 16),lsl#16
 add x9,x0,x9
 stp d2,d3,[x9]
 stp d4,d5,[x9,#16]
 str d0,[x9,#32]
 fmov d1,#1.0
 fmax d0,d0,d1
 movz x9,#(4150016 & 65535)
 movk x9,#(4150016 >> 16),lsl#16
 str d0,[x0,x9]
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_update_operational_time_coefficients,.-md2asm_update_operational_time_coefficients
.section .rodata
.p2align 3
.Llimits: .double 86400.0,1000000.0,10000000.0
.section .note.GNU-stack,"",%progbits

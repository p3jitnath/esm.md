/* Contract: skills/md2asm/references/openifs/dynamics/operational_model_transform_callers.md.
 * Qualified component. Complete autonomous forecast acceptance remains separate. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_rayleigh_controls
.type md2asm_initialize_operational_rayleigh_controls,%function
md2asm_initialize_operational_rayleigh_controls:
 cbz x0,.Lrc_bad_leaf
 cbz x1,.Lrc_bad_leaf
 cbz x2,.Lrc_bad_leaf
 cbz x3,.Lrc_bad_leaf
 cbz x4,.Lrc_bad_leaf
 mov x9,#262144
 cmp x1,x9
 b.hi .Lrc_bad_leaf
 adds x9,x0,x1
 b.cs .Lrc_bad_leaf
 orr x10,x2,x3
 orr x10,x10,x4
 tst x10,#7
 b.ne .Lrc_bad_leaf
 ldr w10,[x2,#5224]
 cmp w10,#137
 b.ne .Lrc_bad_leaf
 mov x10,#40104
 ldr w10,[x4,x10]
 cmp w10,#1
 b.ne .Lrc_bad_leaf
 sub sp,sp,#80
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 mov x19,x3
 stp wzr,wzr,[sp,#32]
 mov w9,#3
 str w9,[sp,#36]
 stp wzr,wzr,[sp,#40]
 add x1,x0,x1
 adr x2,.Lrc_group
 mov x3,#6
 adr x4,.Lrc_keys
 add x5,sp,#32
 bl md2asm_parse_bounded_scalar_group
 cbnz w0,.Lrc_bad
 ldp w9,w10,[sp,#40]
 orr w9,w9,w10
 cbnz w9,.Lrc_bad
 movz x9,#(1566724&65535)
 movk x9,#(1566724>>16),lsl#16
 add x9,x19,x9
 stp wzr,wzr,[x9]
 mov w0,#0
 b .Lrc_return
.Lrc_bad:
 mov w0,#2
.Lrc_return:
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#80
 ret
.Lrc_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_rayleigh_controls,.-md2asm_initialize_operational_rayleigh_controls
.section .rodata
.Lrc_group: .ascii "NAMDYN"
.p2align 3
.Lrc_keys:
 .word 7,2,0,0,1,0
 .ascii "LMASCOR"
 .zero 9
 .word 5,1,4,0,20,0
 .ascii "NITMP"
 .zero 11
 .word 6,2,8,0,1,0
 .ascii "LRFRIC"
 .zero 10
 .word 11,2,12,0,1,0
 .ascii "LRFRICISOTR"
 .zero 5
 .zero 40
.section .note.GNU-stack,"",%progbits

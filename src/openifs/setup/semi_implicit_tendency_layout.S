/* Consumed SUNDDH semi-implicit field cursor and its named zero defaults.
 * Contract: skills/md2asm/references/openifs/dynamics/semi_implicit_tendency_layout.md.
 * x0 complete owned MODEL, x1 byte capacity. Return w0 0 or 2.
 * NFTHER and LNHDYN are borrowed live producer outputs. No external call. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_semi_implicit_tendency_layout
.type md2asm_initialize_semi_implicit_tendency_layout,%function
md2asm_initialize_semi_implicit_tendency_layout:
 cbz x0,.Lrefuse
 tst x0,#7
 b.ne .Lrefuse
 mov x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x1,x9
 b.lo .Lrefuse
 adds x9,x0,x9
 b.cs .Lrefuse
 ldr w9,[x0,#16]
 tbnz w9,#31,.Lrefuse
 mov x10,#(1564144&65535)
 movk x10,#(1564144>>16),lsl#16
 ldr w10,[x0,x10]
 cmp w10,#1
 b.hi .Lrefuse
 mov x11,#(4267708&65535)
 movk x11,#(4267708>>16),lsl#16
 add x11,x0,x11
 stp wzr,wzr,[x11]
 stp wzr,wzr,[x11,#8]
 stp wzr,wzr,[x11,#16]
 stp wzr,wzr,[x11,#24]
 stp wzr,wzr,[x11,#32]
 stp wzr,wzr,[x11,#40]
 stp wzr,wzr,[x11,#48]
 stp wzr,wzr,[x11,#56]
 mov w13,#1
 add x12,x11,#4
 mov w14,#3
.Lsource_group:
 str w13,[x12]
 add w13,w13,#1
 str w13,[x12,#4]
 add w13,w13,#1
 cbz w9,.Lnext_group
 str w13,[x12,#8]
 add w13,w13,#1
 cbz w10,.Lnext_group
 str w13,[x12,#12]
 add w13,w13,#1
 str w13,[x12,#16]
 add w13,w13,#1
.Lnext_group:
 add x12,x12,#20
 subs w14,w14,#1
 b.ne .Lsource_group
 sub w13,w13,#1
 str w13,[x11]
 mov w0,#0
 ret
.Lrefuse:
 mov w0,#2
 ret
.size md2asm_initialize_semi_implicit_tendency_layout,.-md2asm_initialize_semi_implicit_tendency_layout
.section .note.GNU-stack,"",%progbits

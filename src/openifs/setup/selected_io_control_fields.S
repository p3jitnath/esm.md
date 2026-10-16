// Contract: skills/md2asm/references/openifs/setup/fresh_forecast_continuation.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_io_controls
.type md2asm_initialize_selected_io_controls,%function
md2asm_initialize_selected_io_controls:
 cbz x0,.Lio_bad
 cbz x1,.Lio_bad
 cbz x3,.Lio_bad
 tst x3,#7
 b.ne .Lio_bad
 cmp w2,#1
 b.ne .Lio_bad
 cmp x1,#64,lsl#12
 b.hi .Lio_bad
 cmp x4,#248
 b.lo .Lio_bad
 adds x5,x0,x1
 b.cs .Lio_bad
 adds x6,x3,#248
 b.cs .Lio_bad
 cmp x0,x6
 b.hs .Lio_disjoint
 cmp x3,x5
 b.lo .Lio_bad
.Lio_disjoint:
 stp x29,x30,[sp,#-32]!
 stp x19,x18,[sp,#16]
 mov x29,sp
 mov x19,x3
 adrp x2,.Lnamios
 add x2,x2,:lo12:.Lnamios
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lio_return
 mov x9,#0
 mov x10,#0x2020202020202020
.Lio_spaces:
 str x10,[x19,x9]
 add x9,x9,#8
 cmp x9,#240
 b.lo .Lio_spaces
 mov w9,#114
 strb w9,[x19]
 mov w9,#99
 strb w9,[x19,#1]
 mov w9,#102
 strb w9,[x19,#2]
 mov w9,#115
 strb w9,[x19,#120]
 mov w9,#114
 strb w9,[x19,#121]
 mov w9,#102
 strb w9,[x19,#122]
 str wzr,[x19,#240]
 mov w0,#0
.Lio_return:
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Lio_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_io_controls,.-md2asm_initialize_selected_io_controls
.section .rodata
.Lnamios:.ascii "NAMIOS"
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/support/runtime_physics_work_shape_counts.md.
 * x0 output32, x1 Geometry20400, x2 MODEL4275088, x3 TSURF18224,
 * x4 dimensions192, x5 configuration67616. Complete mapped spans are aligned8,
 * nonwrapping and pairwise disjoint. Accepted producers own every input.
 * Copy seven live int32 counts and the original NPAERODIAG=8 parameter.
 * Return0 completes; return2 refuses before any output write.
 * Integer leaf: no frame, allocation, external call or floating-point instruction.
 * Preserve x18..x30, vectors, FPCR/FPSR, errno and stack alignment.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_bind_runtime_physics_work_shape_counts
.type md2asm_bind_runtime_physics_work_shape_counts,%function
md2asm_bind_runtime_physics_work_shape_counts:
 cbz x0,.Lwork_shape_refuse
 cbz x1,.Lwork_shape_refuse
 cbz x2,.Lwork_shape_refuse
 cbz x3,.Lwork_shape_refuse
 cbz x4,.Lwork_shape_refuse
 cbz x5,.Lwork_shape_refuse
 orr x12,x0,x1
 orr x12,x12,x2
 orr x12,x12,x3
 orr x12,x12,x4
 orr x12,x12,x5
 tst x12,#7
 b.ne .Lwork_shape_refuse
 adds x6,x0,#32
 b.cs .Lwork_shape_refuse
 mov x12,#20400
 adds x7,x1,x12
 b.cs .Lwork_shape_refuse
 movz x12,#(4275088 & 65535)
 movk x12,#(4275088 >> 16),lsl#16
 adds x8,x2,x12
 b.cs .Lwork_shape_refuse
 mov x12,#18224
 adds x9,x3,x12
 b.cs .Lwork_shape_refuse
 adds x10,x4,#192
 b.cs .Lwork_shape_refuse
 movz x12,#(67616 & 65535)
 movk x12,#(67616 >> 16),lsl#16
 adds x11,x5,x12
 b.cs .Lwork_shape_refuse
 /* Check each of the fifteen complete span pairs before reading input words. */
 cmp x0,x7
 b.hs .Lwork_shape_span01
 cmp x1,x6
 b.lo .Lwork_shape_refuse
.Lwork_shape_span01:
 cmp x0,x8
 b.hs .Lwork_shape_span02
 cmp x2,x6
 b.lo .Lwork_shape_refuse
.Lwork_shape_span02:
 cmp x0,x9
 b.hs .Lwork_shape_span03
 cmp x3,x6
 b.lo .Lwork_shape_refuse
.Lwork_shape_span03:
 cmp x0,x10
 b.hs .Lwork_shape_span04
 cmp x4,x6
 b.lo .Lwork_shape_refuse
.Lwork_shape_span04:
 cmp x0,x11
 b.hs .Lwork_shape_span05
 cmp x5,x6
 b.lo .Lwork_shape_refuse
.Lwork_shape_span05:
 cmp x1,x8
 b.hs .Lwork_shape_span12
 cmp x2,x7
 b.lo .Lwork_shape_refuse
.Lwork_shape_span12:
 cmp x1,x9
 b.hs .Lwork_shape_span13
 cmp x3,x7
 b.lo .Lwork_shape_refuse
.Lwork_shape_span13:
 cmp x1,x10
 b.hs .Lwork_shape_span14
 cmp x4,x7
 b.lo .Lwork_shape_refuse
.Lwork_shape_span14:
 cmp x1,x11
 b.hs .Lwork_shape_span15
 cmp x5,x7
 b.lo .Lwork_shape_refuse
.Lwork_shape_span15:
 cmp x2,x9
 b.hs .Lwork_shape_span23
 cmp x3,x8
 b.lo .Lwork_shape_refuse
.Lwork_shape_span23:
 cmp x2,x10
 b.hs .Lwork_shape_span24
 cmp x4,x8
 b.lo .Lwork_shape_refuse
.Lwork_shape_span24:
 cmp x2,x11
 b.hs .Lwork_shape_span25
 cmp x5,x8
 b.lo .Lwork_shape_refuse
.Lwork_shape_span25:
 cmp x3,x10
 b.hs .Lwork_shape_span34
 cmp x4,x9
 b.lo .Lwork_shape_refuse
.Lwork_shape_span34:
 cmp x3,x11
 b.hs .Lwork_shape_span35
 cmp x5,x9
 b.lo .Lwork_shape_refuse
.Lwork_shape_span35:
 cmp x4,x11
 b.hs .Lwork_shape_spans_separate
 cmp x5,x10
 b.lo .Lwork_shape_refuse
.Lwork_shape_spans_separate:
 /* Configuration and MODEL name the same actual producer records. */
 ldr x12,[x5]
 cmp x12,x2
 b.ne .Lwork_shape_refuse
 ldr x12,[x5,#16]
 cmp x12,x1
 b.ne .Lwork_shape_refuse
 ldr x12,[x2,#8]
 cmp x12,x1
 b.ne .Lwork_shape_refuse
 ldr x12,[x5,#8]
 cbz x12,.Lwork_shape_refuse
 tst x12,#7
 b.ne .Lwork_shape_refuse
 mov x13,#4512
 adds x13,x12,x13
 b.cs .Lwork_shape_refuse
 cmp x13,x3
 b.ne .Lwork_shape_refuse
 ldr x12,[x5,#24]
 movz w13,#0x4346
 movk w13,#0x4731,lsl#16
 cmp x12,x13
 b.ne .Lwork_shape_refuse
 mov x12,#40104
 ldr w12,[x5,x12]
 cmp w12,#1
 b.ne .Lwork_shape_refuse
 /* Load the seven complete source words before any output mutation. */
 ldr w6,[x1,#5224]
 ldr w7,[x3,#5888]
 ldr w8,[x2,#304]
 movz x14,#(1577392 & 65535)
 movk x14,#(1577392 >> 16),lsl#16
 add x14,x2,x14
 ldp w9,w10,[x14]
 movz x14,#(1608800 & 65535)
 movk x14,#(1608800 >> 16),lsl#16
 add x14,x2,x14
 ldr w12,[x14]
 ldr w11,[x14,#8]
 orr w14,w6,w7
 orr w14,w14,w8
 orr w14,w14,w9
 orr w14,w14,w10
 orr w14,w14,w11
 orr w14,w14,w12
 tbnz w14,#31,.Lwork_shape_refuse
 /* DIMENSION INIT has already copied these same four actual source counts. */
 ldr w14,[x4,#48]
 cmp w14,w6
 b.ne .Lwork_shape_refuse
 ldr w14,[x4,#20]
 cmp w14,w7
 b.ne .Lwork_shape_refuse
 ldr w14,[x4,#64]
 cmp w14,w9
 b.ne .Lwork_shape_refuse
 ldr w14,[x4,#24]
 cmp w14,w10
 b.ne .Lwork_shape_refuse
 mov w15,#8
 stp w6,w7,[x0]
 stp w8,w15,[x0,#8]
 stp w9,w10,[x0,#16]
 stp w11,w12,[x0,#24]
 mov w0,#0
 ret
.Lwork_shape_refuse:
 mov w0,#2
 ret
.size md2asm_bind_runtime_physics_work_shape_counts,.-md2asm_bind_runtime_physics_work_shape_counts
.section .note.GNU-stack,"",%progbits

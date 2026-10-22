/* Surface field unit scaling, revision 2.
 * Contract: skills/md2asm/references/openifs/input/surface_field_unit_scaling.md.
 * The original entry selects 2,048 points and 47 ordinary fields. The explicit
 * operational entry selects 6,599,680 points and 50 ordinary fields. Both use
 * five layered fields with five layers. All byte products are 64-bit.
 * x0..x7: writable ordinary fields, their capacity, writable layered fields,
 * their capacity, read-only IDs, ID capacity, constants and constant capacity.
 * Operational spans are 2,639,872,000/1,319,936,000/220/16 bytes.
 * Preserve the literal FP64 FMUL for each value, including factors of one.
 * Inputs and outputs are mapped, aligned and disjoint as the contract states.
 * Return 0 success, 1 invalid buffers or 2 nonzero FPCR before any write.
 * Preserve FPCR, errno, x18..x30 and saved vector registers. FPSR accumulates
 * the genuine arithmetic flags. x0..x17 and d0,d1 are scratch. No stack/call.
 */
.arch armv8.2-a
.text
.p2align 4
.macro DISJOINT first, first_end, second, second_end
    cmp \first, \second_end
    b.hs .Ldisjoint_\@
    cmp \second, \first_end
    b.lo .Lbad
.Ldisjoint_\@:
.endm
.global md2asm_scale_initial_surface_fields
.type md2asm_scale_initial_surface_fields,%function
md2asm_scale_initial_surface_fields:
 movz x13,#2048
 mov x14,#47
 mov x15,#208
 movz x16,#49152
 movk x16,#11,lsl#16
 movz x17,#16384
 movk x17,#6,lsl#16
 b .Lscale_selected
.global md2asm_scale_operational_initial_surface_fields
.type md2asm_scale_operational_initial_surface_fields,%function
md2asm_scale_operational_initial_surface_fields:
 movz x13,#46080
 movk x13,#100,lsl#16
 mov x14,#50
 mov x15,#220
 movz x16,#16384
 movk x16,#40281,lsl#16
 movz x17,#40960
 movk x17,#20140,lsl#16
.Lscale_selected:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 cbz x6,.Lbad
 orr x8,x0,x2
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 mov x8,x16
 cmp x1,x8
 b.lo .Lbad
 adds x9,x0,x8
 b.cs .Lbad
 mov x8,x17
 cmp x3,x8
 b.lo .Lbad
 adds x10,x2,x8
 b.cs .Lbad
 cmp x5,x15
 b.lo .Lbad
 adds x11,x4,x15
 b.cs .Lbad
 cmp x7,#16
 b.lo .Lbad
 adds x12,x6,#16
 b.cs .Lbad
 DISJOINT x0,x9,x2,x10
 DISJOINT x0,x9,x4,x11
 DISJOINT x0,x9,x6,x12
 DISJOINT x2,x10,x4,x11
 DISJOINT x2,x10,x6,x12
 mrs x8,fpcr
 cbnz x8,.Lbad_mode
 mov x7,#0
.Lfield2:
 ldr w8,[x4,x7,lsl#2]
 fmov d1,#1.0
 cmp w8,#173
 b.eq .Lgravity2
 cmp w8,#244
 b.eq .Lgravity2
 cmp w8,#160
 b.eq .Lgravity2
 cmp w8,#198
 b.eq .Lwater2
 b .Lfactor2_ready
.Lgravity2:
 ldr d1,[x6]
 b .Lfactor2_ready
.Lwater2:
 ldr d1,[x6,#8]
.Lfactor2_ready:
 mov x8,x13
.Lpoint2:
 ldr d0,[x0]
 fmul d0,d1,d0
 str d0,[x0],#8
 subs x8,x8,#1
 b.ne .Lpoint2
 add x7,x7,#1
 cmp x7,x14
 b.ne .Lfield2
 add x4,x4,x14,lsl#2
 mov x7,#0
.Lfield3:
 ldr w8,[x4,x7,lsl#2]
 fmov d1,#1.0
 cmp w8,#173
 b.eq .Lgravity3
 cmp w8,#244
 b.eq .Lgravity3
 cmp w8,#160
 b.eq .Lgravity3
 cmp w8,#141
 b.eq .Lwater3
 cmp w8,#198
 b.eq .Lwater3
 b .Lfactor3_ready
.Lgravity3:
 ldr d1,[x6]
 b .Lfactor3_ready
.Lwater3:
 ldr d1,[x6,#8]
.Lfactor3_ready:
 add x8,x13,x13,lsl#2
.Lpoint3:
 ldr d0,[x2]
 fmul d0,d1,d0
 str d0,[x2],#8
 subs x8,x8,#1
 b.ne .Lpoint3
 add x7,x7,#1
 cmp x7,#5
 b.ne .Lfield3
 mov w0,#0
 ret
.Lbad:
 mov w0,#1
 ret
.Lbad_mode:
 mov w0,#2
 ret
.size md2asm_scale_initial_surface_fields,.-md2asm_scale_initial_surface_fields
.size md2asm_scale_operational_initial_surface_fields,.-md2asm_scale_operational_initial_surface_fields
.section .note.GNU-stack,"",%progbits

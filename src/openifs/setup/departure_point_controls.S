/* Source SUDYN Cartesian departure controls after empty NAMDYN/NAMDYNA admission.
 * Contract skills/md2asm/references/openifs/dynamics/departure_point_controls.md.
 * x0 MODEL, x1 byte capacity, x2 platform16 NCONF/LECMWF/LR2D/LR3D. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_initialize_departure_point_controls
.type md2asm_initialize_departure_point_controls,%function
md2asm_initialize_departure_point_controls:
 cbz x0,.Lbad
 cbz x2,.Lbad
 tst x0,#7
 b.ne .Lbad
 tst x2,#3
 b.ne .Lbad
 MADDR x9,xzr,4275088
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 adds x11,x2,#16
 b.cs .Lbad
 cmp x10,x2
 b.ls .Ldisjoint
 cmp x11,x0
 b.hi .Lbad
.Ldisjoint:
 ldp w9,w10,[x2]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x2,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 mrs x9,fpcr
 cbnz x9,.Lbad
 MADDR x9,x0,1564420
 ldp w10,w11,[x9]
 cmp w10,#1
 b.hi .Lbad
 cmp w11,#1
 b.hi .Lbad
 /* SUDYN648-650, selected ECMWF three-dimensional/NCONF1 route. */
 orr w10,w10,w11
 mov w11,#2
 cmp w10,#0
 cinc w11,w11,ne
 MADDR x9,x0,1568808
 str w11,[x9]
 /* SUDYN763,864-865,889,963-967 after admitted empty source groups. */
 MADDR x9,x0,1568896
 str wzr,[x9]
 fmov d0,#1.0
 MADDR x9,x0,1568816
 stp d0,d0,[x9]
 MADDR x9,x0,1569160
 str wzr,[x9]
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_initialize_departure_point_controls,.-md2asm_initialize_departure_point_controls
.section .note.GNU-stack,"",%progbits

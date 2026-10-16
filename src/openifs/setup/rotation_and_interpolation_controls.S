/* Named source SUDYN selectors for rotation and vertical interpolation.
 * Contract skills/md2asm/references/openifs/dynamics/rotation_and_interpolation_controls.md.
 * MODEL and the live platform record remain owned by the caller. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
/* Shared leaf check preserves x0,x1,x2,x16 and returns status in w9. */
.Lmodel:
 mov w9,#2
 cbz x0,.Lmodel_done
 tst x0,#7
 b.ne .Lmodel_done
 MADDR x10,xzr,4275088
 cmp x1,x10
 b.lo .Lmodel_done
 adds x11,x0,x10
 b.cs .Lmodel_done
 mrs x10,fpcr
 cbnz x10,.Lmodel_done
 mov w9,#0
.Lmodel_done:
 ret
.p2align 4
.global md2asm_initialize_coriolis_controls
.type md2asm_initialize_coriolis_controls,%function
md2asm_initialize_coriolis_controls:
 mov x16,x30
 bl .Lmodel
 mov x30,x16
 cbnz w9,.Lbad
 cbz x2,.Lbad
 tst x2,#3
 b.ne .Lbad
 adds x12,x2,#16
 b.cs .Lbad
 cmp x11,x2
 b.ls .Lplatform_disjoint
 cmp x12,x0
 b.hi .Lbad
.Lplatform_disjoint:
 ldr w9,[x2,#4]
 cmp w9,#1
 b.hi .Lbad
 ldr w10,[x2,#8]
 cmp w10,#1
 b.hi .Lbad
 MADDR x12,x0,1564156
 ldp w13,w14,[x12]
 cmp w13,#1
 b.hi .Lbad
 cmp w14,#1
 b.hi .Lbad
 and w13,w13,w14
 cbz w9,.Lnon_ecmwf
 cbnz w10,.Ltwo_dimensional
 mov w14,#1
 eor w14,w13,w14
 b .Lwrite_coriolis
.Ltwo_dimensional:
 mov w13,#1
 mov w14,#0
 b .Lwrite_coriolis
.Lnon_ecmwf:
 mov w14,w13
 mov w13,#0
.Lwrite_coriolis:
 MADDR x9,x0,1569032
 stp w14,w13,[x9]
 mov w0,#0
 ret
.size md2asm_initialize_coriolis_controls,.-md2asm_initialize_coriolis_controls
.p2align 4
.global md2asm_initialize_vertical_smoothness_controls
.type md2asm_initialize_vertical_smoothness_controls,%function
md2asm_initialize_vertical_smoothness_controls:
 mov x16,x30
 bl .Lmodel
 mov x30,x16
 cbnz w9,.Lbad
 MADDR x9,x0,1565696
 ldr x10,[x9]
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lbad
 fmov d0,x10
 fcmp d0,#0.0
 b.lt .Lbad
 adr x9,.Lmaximum_sponge
 ldr d1,[x9]
 fcmp d0,d1
 b.gt .Lbad
 /* NINT uses nearest integer with half ties away from zero. */
 fcvtas w13,d0
 MADDR x9,x0,1568856
 fmov d0,#2.0
 stp d0,d0,[x9]
 str w13,[x9,#16]
 mov w13,#5
 str w13,[x9,#20]
 stp wzr,wzr,[x9,#24]
 mov w0,#0
 ret
.size md2asm_initialize_vertical_smoothness_controls,.-md2asm_initialize_vertical_smoothness_controls
.Lbad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lmaximum_sponge:
 .xword 0x406fe00000000000
.section .note.GNU-stack,"",%progbits

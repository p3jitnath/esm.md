/* Source SUSC2B section 2.2.2 and CVER assignment before SLCSET.
 * Contract: skills/md2asm/references/openifs/dynamics/spherical_interpolation_halo.md.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity, x4 RA address,
 * x5 RPI address, x6 controls8 [LELAM,LSLONDEM], x7 controls capacity.
 * Return 0 or 2. No allocation or external call. Preserve x18 and saved registers. */
.arch armv8.2-a
.text
.p2align 4
.macro ADDRESS reg,base,offset
 mov x17,#(\offset & 65535)
 movk x17,#((\offset >> 16)&65535),lsl#16
 add \reg,\base,x17
.endm
.macro POSITIVE_FINITE reg
 cbz \reg,.Lhalo_bad
 tbnz \reg,#63,.Lhalo_bad
 ubfx x10,\reg,#52,#11
 cmp x10,#2047
 b.eq .Lhalo_bad
.endm
/* SUMP0 source default after accepted NAMPAR1 admission.
 * x0 writable controls8, x1 capacity, x2 live owned LELAM int32 address.
 * The admitted first NAMPAR1 has no supported LSLONDEM override. */
.global md2asm_initialize_selected_spherical_halo_controls
.type md2asm_initialize_selected_spherical_halo_controls,%function
md2asm_initialize_selected_spherical_halo_controls:
 cbz x0,.Lcontrol_bad
 cbz x2,.Lcontrol_bad
 orr x9,x0,x2
 tst x9,#3
 b.ne .Lcontrol_bad
 cmp x1,#8
 b.lo .Lcontrol_bad
 adds x9,x0,#8
 b.cs .Lcontrol_bad
 adds x9,x2,#4
 b.cs .Lcontrol_bad
 ldr w9,[x2]
 cbnz w9,.Lcontrol_bad
 mov w10,#1
 stp w9,w10,[x0]
 mov w0,#0
 ret
.Lcontrol_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_spherical_halo_controls,.-md2asm_initialize_selected_spherical_halo_controls
.p2align 4
.global md2asm_initialize_spherical_interpolation_halo
.type md2asm_initialize_spherical_interpolation_halo,%function
md2asm_initialize_spherical_interpolation_halo:
 cbz x0,.Lhalo_bad
 cbz x2,.Lhalo_bad
 cbz x4,.Lhalo_bad
 cbz x5,.Lhalo_bad
 cbz x6,.Lhalo_bad
 orr x9,x0,x2
 orr x9,x9,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lhalo_bad
 tst x6,#3
 b.ne .Lhalo_bad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lhalo_bad
 adds x9,x0,x9
 b.cs .Lhalo_bad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x3,x9
 b.lo .Lhalo_bad
 adds x9,x2,x9
 b.cs .Lhalo_bad
 adds x9,x4,#8
 b.cs .Lhalo_bad
 adds x9,x5,#8
 b.cs .Lhalo_bad
 cmp x7,#8
 b.lo .Lhalo_bad
 adds x9,x6,#8
 b.cs .Lhalo_bad
 ldp w9,w14,[x6]
 cbnz w9,.Lhalo_bad
 cmp w14,#1
 b.hi .Lhalo_bad
 mrs x9,fpcr
 cbnz x9,.Lhalo_bad
 ADDRESS x9,x2,1564160
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lhalo_bad
 ADDRESS x9,x2,1564156
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lhalo_bad
 mov x9,#4872
 ldr w12,[x0,x9]
 sub w9,w12,#2
 mov w10,#65534
 cmp w9,w10
 b.hi .Lhalo_bad
 mov x9,#4884
 ldr w13,[x0,x9]
 sub w9,w13,#1
 cmp w9,#1023
 b.hi .Lhalo_bad
 ldr x9,[x4]
 POSITIVE_FINITE x9
 fmov d0,x9
 ldr x9,[x5]
 POSITIVE_FINITE x9
 fmov d1,x9
 mov x9,#7512
 ldr x9,[x0,x9]
 POSITIVE_FINITE x9
 fmov d2,x9
 ADDRESS x9,x2,1359528
 ldr x9,[x9]
 and x10,x9,#0x7fffffffffffffff
 cbz x10,.Lhalo_step_valid
 tbnz x9,#63,.Lhalo_bad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lhalo_bad
.Lhalo_step_valid:
 fmov d3,x9
 ADDRESS x9,x2,1566928
 ldr x9,[x9]
 POSITIVE_FINITE x9
 fmov d4,x9
 ADDRESS x9,x2,1566936
 ldr x9,[x9]
 POSITIVE_FINITE x9
 fmov d5,x9
 /* ZDL = ZLTRAJ * VMAX2 * TSTEP * RSTRET / RA, with ZLTRAJ one. */
 fmov d23,#1.0
 fmul d6,d23,d5
 fmul d6,d6,d3
 fmul d6,d6,d2
 fdiv d6,d6,d0
 fmov d7,#0.5
 fmul d7,d7,d1
 fcmp d6,d7
 b.hi .Lhalo_bad
 /* ZISLWM2 = ZDL * (REAL(NDGLG) + 0.5) / RPI. */
 scvtf d16,w12
 fmov d17,#0.5
 fadd d16,d16,d17
 fmul d17,d6,d16
 fdiv d17,d17,d1
 fcvtps w15,d17
 /* Ordered revised speed calculation, retaining the source zero-step branch. */
 fdiv d18,d4,d5
 scvtf d19,w15
 fmul d19,d19,d1
 fdiv d19,d19,d16
 fcmp d3,#0.0
 b.eq .Lhalo_commit
 fmul d20,d19,d0
 fmul d21,d23,d3
 fmul d21,d21,d2
 fdiv d20,d20,d21
 fmul d21,d18,d20
 movz x9,#0x4000,lsl#32
 movk x9,#0x406f,lsl#48
 fmov d22,x9
 fmin d21,d21,d22
 ADDRESS x9,x2,1566936
 str d20,[x9]
 ADDRESS x9,x2,1566928
 str d21,[x9]
.Lhalo_commit:
 add w15,w15,w13
 sub w15,w15,#1
 ADDRESS x9,x2,1575132
 str w15,[x9]
 ADDRESS x9,x2,1574800
 str w14,[x9]
 ADDRESS x9,x2,1573768
 mov w10,#0x4c53
 strh w10,[x9]
 mov w0,#0
 ret
.Lhalo_bad:
 mov w0,#2
 ret
.size md2asm_initialize_spherical_interpolation_halo,.-md2asm_initialize_spherical_interpolation_halo
.section .note.GNU-stack,"",%progbits

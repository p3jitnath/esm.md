/* Default disabled SURAND1 controls.
 * Contract: skills/md2asm/references/openifs/setup/disabled_stochastic_physics_setup.md
 * Arguments x0..x7 are STOPH, capacity, Geometry, TDYN, TRIP, radius, text, text bytes.
 * Complete mapped record sizes are 2,904 / 17,096 / 4,720 / 175,976 / 8 bytes.
 * STOPH is separate from all inputs. Empty NAMSTOPH selects the disabled branch.
 * Update 416 bytes and preserve the other 2,488 bytes, including array descriptions.
 * The 80-byte frame is aligned to 16 bytes. Save x19..x26 and preserve x18/d8..d15.
 * Require FPCR zero and preserve errno. Source arithmetic adds its natural FPSR flags.
 * Return zero on success and two before output mutation for unsupported inputs.
 */
.arch armv8.2-a
.text
.macro ST_CONST reg,value
 movz \reg,#((\value)&65535)
 movk \reg,#(((\value)>>16)&65535),lsl#16
.endm
.macro ST_APART ptr,endptr
 cmp x0,\endptr
 b.hs .Lst_separate\@
 cmp \ptr,x9
 b.lo .Lst_bad
.Lst_separate\@:
.endm
.p2align 4
.global md2asm_initialize_disabled_stochastic_physics
.type md2asm_initialize_disabled_stochastic_physics,%function
md2asm_initialize_disabled_stochastic_physics:
 mrs x8,fpcr
 cbnz x8,.Lst_bad
 cbz x0,.Lst_bad
 cbz x2,.Lst_bad
 cbz x3,.Lst_bad
 cbz x4,.Lst_bad
 cbz x5,.Lst_bad
 cbz x6,.Lst_bad
 orr x8,x0,x2
 orr x8,x8,x3
 orr x8,x8,x4
 orr x8,x8,x5
 tst x8,#7
 b.ne .Lst_bad
 cmp x1,#2904
 b.lo .Lst_bad
 adds x9,x0,#2904
 b.cs .Lst_bad
 ST_CONST x8,17096
 adds x10,x2,x8
 b.cs .Lst_bad
 ST_CONST x8,4720
 adds x11,x3,x8
 b.cs .Lst_bad
 ST_CONST x8,175976
 adds x12,x4,x8
 b.cs .Lst_bad
 adds x13,x5,#8
 b.cs .Lst_bad
 cbz x7,.Lst_bad
 cmp x7,#64,lsl#12
 b.hi .Lst_bad
 adds x14,x6,x7
 b.cs .Lst_bad
 ST_APART x2,x10
 ST_APART x3,x11
 ST_APART x4,x12
 ST_APART x5,x13
 ST_APART x6,x14
 ldr w15,[x2,#5172]
 cbz w15,.Lst_bad
 cmp w15,#1,lsl#12
 b.hi .Lst_bad
 ldr w15,[x2,#4872]
 cbz w15,.Lst_bad
 cmp w15,#2,lsl#12
 b.hi .Lst_bad
 ldr w15,[x3,#4532]
 cmp w15,#1
 b.hi .Lst_bad
 /* Integer bit tests refuse nonfinite or unbounded values without FP events. */
 adrp x17,.Lst_limits
 add x17,x17,:lo12:.Lst_limits
 ldp x15,x16,[x17]
 ldr x8,[x5]
 cmp x8,x15
 b.lo .Lst_bad
 cmp x8,x16
 b.hi .Lst_bad
 ldr x15,[x4,#208]
 and x15,x15,#0x7fffffffffffffff
 ldr x16,[x17,#16]
 cmp x15,x16
 b.hi .Lst_bad
 ldr x15,[x3,#40]
 lsr x15,x15,#52
 and w15,w15,#2047
 cmp w15,#2047
 b.eq .Lst_bad
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 mov x22,x4
 mov x23,x5
 mov x0,x6
 mov x1,x7
 adrp x2,.Lst_group
 add x2,x2,:lo12:.Lst_group
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lst_return
 /* Source constants are stored by their exact frozen integer bit patterns. */
 adrp x24,.Lst_words
 add x24,x24,:lo12:.Lst_words
 adrp x25,.Lst_words_end
 add x25,x25,:lo12:.Lst_words_end
.Lst_word_loop:
 ldp w9,w10,[x24],#8
 str w10,[x19,x9]
 cmp x24,x25
 b.lo .Lst_word_loop
 adrp x24,.Lst_doubles
 add x24,x24,:lo12:.Lst_doubles
 adrp x25,.Lst_doubles_end
 add x25,x25,:lo12:.Lst_doubles_end
.Lst_double_loop:
 ldp x9,x10,[x24],#16
 str x10,[x19,x9]
 cmp x24,x25
 b.lo .Lst_double_loop
 ldr w9,[x20,#5172]
 mov w10,#159
 cmp w9,w10
 csel w11,w9,w10,le
 str w11,[x19,#1864]
 /* Angular setting90*n/159, NINT, then180/j. */
 adrp x24,.Lst_math
 add x24,x24,:lo12:.Lst_math
 scvtf d0,w9
 ldr d1,[x24,#0]
 fmul d0,d0,d1
 ldr d1,[x24,#8]
 fdiv d0,d0,d1
 fcvtas w10,d0
 scvtf d1,w10
 ldr d0,[x24,#16]
 fdiv d0,d0,d1
 str d0,[x19,#1632]
 str d0,[x19,#1640]
 ldr d1,[x24,#24]
 fdiv d1,d1,d0
 fcvtas w10,d1
 ldr d1,[x24,#16]
 fdiv d1,d1,d0
 fcvtas w11,d1
 /* Live branch selectsZX, then source3*ZX precedes the radius-square chain. */
 ldr w9,[x21,#4532]
 cbnz w9,.Lst_spectral_viscosity
 ldr d0,[x22,#208]
 ldr d1,[x21,#40]
 ldr d2,[x24,#32]
 fmax d1,d1,d2
 fdiv d0,d0,d1
 b .Lst_z_ready
.Lst_spectral_viscosity:
 fmov d0,xzr
 str wzr,[x19,#1716]
.Lst_z_ready:
 ldr d1,[x24,#40]
 fmul d0,d0,d1
 ldr d1,[x23]
 fmul d1,d1,d1
 ldr w9,[x20,#5172]
 ldr w10,[x20,#4872]
 add w11,w9,#1
 cmp w10,w11
 sub w10,w10,#1
 csel w9,w10,w9,gt
 add w10,w9,#1
 mul w9,w9,w10
 scvtf d2,w9
 fdiv d1,d1,d2
 fmul d1,d1,d1
 fmul d0,d0,d1
 str d0,[x19,#1592]
 mov w0,#0
.Lst_return:
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Lst_bad:
 mov w0,#2
 ret
.size md2asm_initialize_disabled_stochastic_physics,.-md2asm_initialize_disabled_stochastic_physics
.section .rodata
.p2align 3
.Lst_group: .ascii "NAMSTOPH"
.Lst_limits:
 .quad 0x3ff0000000000000
 .quad 0x41cdcd6500000000
 .quad 0x412e848000000000
.Lst_math:
 .quad 0x4056800000000000
 .quad 0x4063e00000000000
 .quad 0x4066800000000000
 .quad 0x4076800000000000
 .quad 0x3eb0c6f7a0b5ed8d
 .quad 0x4008000000000000
.Lst_words:
 .word 1508,0x00000000 /* NFORCESTART */
 .word 1512,0x000000f0 /* NFORCEEND */
 .word 1496,0x00000004 /* NFRSTOPH_SPBS */
 .word 1500,0x00000004 /* NFRSTOPH_SPBS_PAT */
 .word 1516,0x00000002 /* NSTOCHOPT */
 .word 1504,0x00000002 /* NFRSTOPH_VC */
 .word 1700,0x00000000 /* LFORCENL */
 .word 1656,0x00000000 /* LEXTRAFIELDS */
 .word 1648,0x00000000 /* LSTOPH_SPBS */
 .word 1660,0x00000000 /* LSTOPH_JBCOR */
 .word 1664,0x00000000 /* LSTOPH_UNCORR */
 .word 1668,0x00000000 /* LSTOPH_UNIFORM */
 .word 1676,0x00000001 /* LSTOPH_RVP */
 .word 1680,0x00000000 /* LSTOPH_RVPOLD */
 .word 1684,0x00000001 /* LSTOPH_TAPER */
 .word 1688,0x00000001 /* LSTOPH_INI */
 .word 1704,0x00000000 /* LSTOPH_VARALPHA */
 .word 1652,0x00000001 /* LSTOPH_SPBS_FAST */
 .word 1672,0x00000000 /* LSTOPH_SPBS_VORT */
 .word 1708,0x00000001 /* LSTOPH_GAUSS */
 .word 1716,0x00000001 /* LSPBS_DISSNUM */
 .word 1724,0x00000000 /* LSPBS_DISSNUM_CT */
 .word 1720,0x00000001 /* LSPBS_DISSCU */
 .word 1712,0x00000000 /* LSPBS_DISSGW */
 .word 1728,0x00000001 /* LSPBSNORM */
 .word 1732,0x00000001 /* LSPBSDISS */
 .word 2192,0x00000000 /* LSTOPH_SPBS_T */
 .word 1692,0x00000000 /* LSTOPH_CASBS */
 .word 1696,0x00000000 /* LVORTCON */
.Lst_words_end:
.p2align 3
.Lst_doubles:
 .quad 1568,0xbff451eb851eb852 /* REXPONENT */
 .quad 1544,0x3fb851eb851eb852 /* RATIO_BACKSCAT */
 .quad 1560,0x3ff0000000000000 /* RATIO_BACKSCAT_CON2NUM */
 .quad 1584,0x3f747ae147ae147b /* RFLUX_DET_CLIP */
 .quad 1552,0x40d86a0000000000 /* RSPBS_TAU */
 .quad 2208,0x3fc99999a0000000 /* RATIO_APE2KE */
 .quad 1872,0x0000000000000000 /* RVP_MULMIN */
 .quad 1880,0x3ff0000000000000 /* RVP_MULMAX */
 .quad 1888,0x3fb999999999999a /* RVP_MULEXP */
 .quad 1896,0x406fe00000000000 /* RVP_MULNSMAX */
 .quad 1968,0x3ffaf905a55b6ebc /* RVP_MUL_A */
 .quad 1976,0xbf0f746bb80c01e0 /* RVP_MUL_B */
 .quad 1984,0x3e1304f160000000 /* RVP_MUL_C */
 .quad 1992,0xbcfd4edf40000000 /* RVP_MUL_D */
 .quad 2000,0x403204ea4a8c154d /* RVP_MUL_1 */
 .quad 2008,0xbfcba29c779a6b51 /* RVP_MUL_2 */
 .quad 2696,0x0000000000000000 /* RVP_MULMIN_T */
 .quad 2704,0x3ff0000000000000 /* RVP_MULMAX_T */
 .quad 2712,0x3fb999999999999a /* RVP_MULEXP_T */
 .quad 2720,0x406fe00000000000 /* RVP_MULNSMAX_T */
 .quad 2792,0x3ffaf905a55b6ebc /* RVP_MUL_A_T */
 .quad 2800,0xbf0f746bb80c01e0 /* RVP_MUL_B_T */
 .quad 2808,0x3e1304f160000000 /* RVP_MUL_C_T */
 .quad 2816,0xbcfd4edf40000000 /* RVP_MUL_D_T */
 .quad 2824,0x40251f212d773190 /* RVP_MUL_1_T */
 .quad 2832,0xbfd2f0068db8bac7 /* RVP_MUL_2_T */
 .quad 1624,0x4000000000000000 /* AMAGSTOPH_CASBS */
 .quad 1536,0x4008000000000000 /* SLDISSFAC */
 .quad 1600,0x41155cc000000000 /* RSMOOTHSCALE */
 .quad 1576,0x3fd3333333333333 /* VC_CON */
 .quad 2200,0xbff451eb851eb852 /* REXPONENT_T */
 .quad 1608,0x3fc5555555555555 /* RSIGMA2_EPS */
 .quad 1520,0x4000000000000000 /* ALPHA_DEEP_CONV */
 .quad 1528,0x4000000000000000 /* ALPHA_SHAL_CONV */
.Lst_doubles_end:
.section .note.GNU-stack,"",%progbits

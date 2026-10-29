/* Apply the SUGFL1 scalar assignments for the inactive chemistry profile.
 * x0: writable TCOMPO, 280 bytes, aligned to 8 bytes.
 * x1: writable TCHEM, 11936 bytes, aligned to 8 bytes.
 * x2: read-only uint64 capacities[2], 16 bytes, aligned to 8 bytes.
 * x3: read-only int32 counts[4], 16 bytes, aligned to 4 bytes:
 *     NCHEM, NGHG, NAERO, NACTAERO; all must be zero.
 * Return w0 = 0, or w0 = 2 before any write.
 * Preserve x18, saved registers, FPCR, FPSR and errno.
 * No stack frame, calls, allocation or floating-point arithmetic.
 * Contract: skills/md2asm/references/openifs/setup/inactive_chemistry_scalar_initialization.md
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_inactive_chemistry_scalar_defaults
.type md2asm_initialize_inactive_chemistry_scalar_defaults,%function
md2asm_initialize_inactive_chemistry_scalar_defaults:
 cbz x0,.Lchem_scalar_bad
 cbz x1,.Lchem_scalar_bad
 cbz x2,.Lchem_scalar_bad
 cbz x3,.Lchem_scalar_bad
 orr x8,x0,x1
 orr x8,x8,x2
 tst x8,#7
 b.ne .Lchem_scalar_bad
 tst x3,#3
 b.ne .Lchem_scalar_bad
 mrs x8,fpcr
 cbnz x8,.Lchem_scalar_bad
 adds x4,x0,#280
 b.cs .Lchem_scalar_bad
 mov x8,#11936
 adds x5,x1,x8
 b.cs .Lchem_scalar_bad
 adds x6,x2,#16
 b.cs .Lchem_scalar_bad
 adds x7,x3,#16
 b.cs .Lchem_scalar_bad
 ldp x8,x9,[x2]
 cmp x8,#280
 b.lo .Lchem_scalar_bad
 mov x10,#11936
 cmp x9,x10
 b.lo .Lchem_scalar_bad
 cmp x4,x1
 b.ls .Lchem_scalar_disjoint_0_1
 cmp x5,x0
 b.hi .Lchem_scalar_bad
.Lchem_scalar_disjoint_0_1:
 cmp x4,x2
 b.ls .Lchem_scalar_disjoint_0_2
 cmp x6,x0
 b.hi .Lchem_scalar_bad
.Lchem_scalar_disjoint_0_2:
 cmp x4,x3
 b.ls .Lchem_scalar_disjoint_0_3
 cmp x7,x0
 b.hi .Lchem_scalar_bad
.Lchem_scalar_disjoint_0_3:
 cmp x5,x2
 b.ls .Lchem_scalar_disjoint_1_2
 cmp x6,x1
 b.hi .Lchem_scalar_bad
.Lchem_scalar_disjoint_1_2:
 cmp x5,x3
 b.ls .Lchem_scalar_disjoint_1_3
 cmp x7,x1
 b.hi .Lchem_scalar_bad
.Lchem_scalar_disjoint_1_3:
 cmp x6,x3
 b.ls .Lchem_scalar_disjoint_2_3
 cmp x7,x2
 b.hi .Lchem_scalar_bad
.Lchem_scalar_disjoint_2_3:
 ldp w8,w9,[x3]
 ldp w10,w11,[x3,#8]
 orr w8,w8,w9
 orr w8,w8,w10
 orr w8,w8,w11
 cbnz w8,.Lchem_scalar_bad
 /* LCHEM_DIA */
 str wzr,[x0,#0]
 /* RCHEM_DIA_PERIOD */
 movz x9,#16408,lsl#48
 str x9,[x0,#8]
 /* LCHEM_DDFLX */
 str wzr,[x0,#16]
 /* LCOMPO_DDFLX_DIR */
 str wzr,[x0,#20]
 /* LCHEM_TROPO */
 str wzr,[x0,#24]
 /* LCOMPO_DCDD */
 movz w9,#1,lsl#0
 str w9,[x0,#36]
 /* LAERNITRATE */
 str wzr,[x0,#40]
 /* LAEREQSAM4CLIM */
 str wzr,[x0,#28]
 /* LAERRESUSPENSION */
 str wzr,[x0,#44]
 /* LAERSOA */
 str wzr,[x0,#48]
 /* LAERSOA_COUPLED */
 str wzr,[x0,#52]
 /* LAERNUCL */
 movz w9,#1,lsl#0
 str w9,[x0,#60]
 /* KGHG_CHEMTEND_CH4 */
 str wzr,[x0,#56]
 /* KCHEM_DRYDEP */
 str wzr,[x1,#68]
 /* LCHEM_LIGHT */
 str wzr,[x1,#44]
 /* RCHEM_LINOX_SCALING */
 str xzr,[x1,#48]
 /* LCHEM_DIAC */
 str wzr,[x1,#20]
 /* LCHEM_JOUT */
 str wzr,[x1,#40]
 /* LCHEM_BASCOE_JON */
 str wzr,[x1,#24]
 /* LCHEM_BASCOE_HETCHEM */
 movz w9,#1,lsl#0
 str w9,[x1,#28]
 /* LMOZART_RSF_DUMMY */
 str wzr,[x1,#36]
 /* LCHEM_EXTENDJNO2 */
 str wzr,[x1,#32]
 /* KCHEM_NOXADV */
 str wzr,[x1,#60]
 /* KCHEM_WETDEP */
 movz w9,#1,lsl#0
 str w9,[x1,#64]
 /* LCHEM_STMA */
 str wzr,[x1,#76]
 /* LCHEM_ANAO3 */
 str wzr,[x1,#80]
 /* LCHEM_ANACH4 */
 str wzr,[x1,#9692]
 /* LCHEM_WEAK_CH4_RELAXATION */
 str wzr,[x1,#9696]
 /* LCHEM_0NOX */
 str wzr,[x1,#9688]
 /* LCHEM_HTAP */
 str wzr,[x1,#9712]
 /* LCHEM_CONVSCAV */
 str wzr,[x1,#9700]
 /* LCHEM_CSHAPE */
 str wzr,[x1,#9704]
 /* LCHEM_WDFR */
 str wzr,[x1,#9708]
 /* LCHEM_O3RAD */
 str wzr,[x1,#9732]
 /* LCHEM_AEROI */
 str wzr,[x1,#9740]
 /* LCHEM_TL */
 str wzr,[x1,#9736]
 /* KCHEM_SOLVE */
 str wzr,[x1,#9728]
 /* LCHEM_REVCHEM */
 str wzr,[x1,#72]
 /* KCHEM_YEARPI */
 movz w9,#2000,lsl#0
 str w9,[x1,#9716]
 /* RCH4CONST */
 movz x9,#13107,lsl#0
 movk x9,#13107,lsl#16
 movk x9,#34803,lsl#32
 movk x9,#49347,lsl#48
 str x9,[x1,#9720]
 /* LCHEM_ARPCLIM */
 str wzr,[x1,#11928]
 mov w0,#0
 ret
.Lchem_scalar_bad:
 mov w0,#2
 ret
.size md2asm_initialize_inactive_chemistry_scalar_defaults,.-md2asm_initialize_inactive_chemistry_scalar_defaults
.section .note.GNU-stack,"",%progbits

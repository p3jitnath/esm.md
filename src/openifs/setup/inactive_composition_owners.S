/* Initialise inactive composition metadata and one owned aerosol descriptor.
 * x0: composition[280], x1: chemistry[11936], x2: GRIB codes[32].
 * x3: aerosol descriptor[64], x4: four read-only u64 capacities.
 * x5: read-only int32 counts NCHEM, NGHG, NAERO, NACTAERO, all zero.
 * Byte ranges and null owner bases are checked before allocation or mutation.
 * Only declared defaults change; the 152-byte allocation is never filled.
 * Return 0 success, 1 allocation failure, 2 checked no-write refusal.
 * Contract: skills/md2asm/references/openifs/setup/inactive_composition_owners.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_inactive_composition_owners
.type md2asm_initialize_inactive_composition_owners,%function
md2asm_initialize_inactive_composition_owners:
 cbz x0,.Linactive_owner_reject
 cbz x1,.Linactive_owner_reject
 cbz x2,.Linactive_owner_reject
 cbz x3,.Linactive_owner_reject
 cbz x4,.Linactive_owner_reject
 cbz x5,.Linactive_owner_reject
 orr x12,x0,x1
 orr x12,x12,x2
 orr x12,x12,x3
 orr x12,x12,x4
 orr x12,x12,x5
 tst x12,#7
 b.ne .Linactive_owner_reject
 mrs x12,fpcr
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x4,#0]
 mov x13,#280
 cmp x12,x13
 b.lo .Linactive_owner_reject
 ldr x12,[x4,#8]
 mov x13,#11936
 cmp x12,x13
 b.lo .Linactive_owner_reject
 ldr x12,[x4,#16]
 mov x13,#32
 cmp x12,x13
 b.lo .Linactive_owner_reject
 ldr x12,[x4,#24]
 mov x13,#64
 cmp x12,x13
 b.lo .Linactive_owner_reject
 mov x12,#280
 adds x6,x0,x12
 b.cs .Linactive_owner_reject
 mov x12,#11936
 adds x7,x1,x12
 b.cs .Linactive_owner_reject
 mov x12,#32
 adds x8,x2,x12
 b.cs .Linactive_owner_reject
 mov x12,#64
 adds x9,x3,x12
 b.cs .Linactive_owner_reject
 mov x12,#32
 adds x10,x4,x12
 b.cs .Linactive_owner_reject
 mov x12,#16
 adds x11,x5,x12
 b.cs .Linactive_owner_reject
 cmp x6,x1
 b.ls .Linactive_owner_separate_0
 cmp x7,x0
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_0:
 cmp x6,x2
 b.ls .Linactive_owner_separate_1
 cmp x8,x0
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_1:
 cmp x6,x3
 b.ls .Linactive_owner_separate_2
 cmp x9,x0
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_2:
 cmp x6,x4
 b.ls .Linactive_owner_separate_3
 cmp x10,x0
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_3:
 cmp x6,x5
 b.ls .Linactive_owner_separate_4
 cmp x11,x0
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_4:
 cmp x7,x2
 b.ls .Linactive_owner_separate_5
 cmp x8,x1
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_5:
 cmp x7,x3
 b.ls .Linactive_owner_separate_6
 cmp x9,x1
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_6:
 cmp x7,x4
 b.ls .Linactive_owner_separate_7
 cmp x10,x1
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_7:
 cmp x7,x5
 b.ls .Linactive_owner_separate_8
 cmp x11,x1
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_8:
 cmp x8,x3
 b.ls .Linactive_owner_separate_9
 cmp x9,x2
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_9:
 cmp x8,x4
 b.ls .Linactive_owner_separate_10
 cmp x10,x2
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_10:
 cmp x8,x5
 b.ls .Linactive_owner_separate_11
 cmp x11,x2
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_11:
 cmp x9,x4
 b.ls .Linactive_owner_separate_12
 cmp x10,x3
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_12:
 cmp x9,x5
 b.ls .Linactive_owner_separate_13
 cmp x11,x3
 b.hi .Linactive_owner_reject
.Linactive_owner_separate_13:
 ldp x12,x13,[x5]
 orr x12,x12,x13
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x0,#80]
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x0,#152]
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x0,#216]
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x1,#11776]
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x1,#11864]
 cbnz x12,.Linactive_owner_reject
 ldr x12,[x3,#0]
 cbnz x12,.Linactive_owner_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x0,#152
 bl malloc
 cbz x0,.Linactive_owner_allocation_failed
 /* LCHEM_DIA */
 str wzr,[x19,#0]
 /* RCHEM_DIA_PERIOD */
 movz x9,#16408,lsl#48
 str x9,[x19,#8]
 /* LCHEM_DDFLX */
 str wzr,[x19,#16]
 /* LCOMPO_DDFLX_DIR */
 str wzr,[x19,#20]
 /* LCHEM_TROPO */
 str wzr,[x19,#24]
 /* LCOMPO_DCDD */
 movz w9,#1,lsl#0
 str w9,[x19,#36]
 /* LAERNITRATE */
 str wzr,[x19,#40]
 /* LAEREQSAM4CLIM */
 str wzr,[x19,#28]
 /* LAERRESUSPENSION */
 str wzr,[x19,#44]
 /* LAERSOA */
 str wzr,[x19,#48]
 /* LAERSOA_COUPLED */
 str wzr,[x19,#52]
 /* LAERNUCL */
 movz w9,#1,lsl#0
 str w9,[x19,#60]
 /* KGHG_CHEMTEND_CH4 */
 str wzr,[x19,#56]
 mov w9,#-999
 stp w9,w9,[x21]
 stp w9,w9,[x21,#8]
 stp w9,w9,[x21,#16]
 stp w9,w9,[x21,#24]
 /* KCHEM_DRYDEP */
 str wzr,[x20,#68]
 /* LCHEM_LIGHT */
 str wzr,[x20,#44]
 /* RCHEM_LINOX_SCALING */
 str xzr,[x20,#48]
 /* LCHEM_DIAC */
 str wzr,[x20,#20]
 /* LCHEM_JOUT */
 str wzr,[x20,#40]
 /* LCHEM_BASCOE_JON */
 str wzr,[x20,#24]
 /* LCHEM_BASCOE_HETCHEM */
 movz w9,#1,lsl#0
 str w9,[x20,#28]
 /* LMOZART_RSF_DUMMY */
 str wzr,[x20,#36]
 /* LCHEM_EXTENDJNO2 */
 str wzr,[x20,#32]
 /* KCHEM_NOXADV */
 str wzr,[x20,#60]
 /* KCHEM_WETDEP */
 movz w9,#1,lsl#0
 str w9,[x20,#64]
 /* LCHEM_STMA */
 str wzr,[x20,#76]
 /* LCHEM_ANAO3 */
 str wzr,[x20,#80]
 /* LCHEM_ANACH4 */
 str wzr,[x20,#9692]
 /* LCHEM_WEAK_CH4_RELAXATION */
 str wzr,[x20,#9696]
 /* LCHEM_0NOX */
 str wzr,[x20,#9688]
 /* LCHEM_HTAP */
 str wzr,[x20,#9712]
 /* LCHEM_CONVSCAV */
 str wzr,[x20,#9700]
 /* LCHEM_CSHAPE */
 str wzr,[x20,#9704]
 /* LCHEM_WDFR */
 str wzr,[x20,#9708]
 /* LCHEM_O3RAD */
 str wzr,[x20,#9732]
 /* LCHEM_AEROI */
 str wzr,[x20,#9740]
 /* LCHEM_TL */
 str wzr,[x20,#9736]
 /* KCHEM_SOLVE */
 str wzr,[x20,#9728]
 /* LCHEM_REVCHEM */
 str wzr,[x20,#72]
 /* KCHEM_YEARPI */
 movz w9,#2000,lsl#0
 str w9,[x20,#9716]
 /* RCH4CONST */
 movz x9,#13107,lsl#0
 movk x9,#13107,lsl#16
 movk x9,#34803,lsl#32
 movk x9,#49347,lsl#48
 str x9,[x20,#9720]
 /* LCHEM_ARPCLIM */
 str wzr,[x20,#11928]
 /* These descriptor fields come from the original typed allocation ABI. */
 mov x9,#-1
 stp x0,x9,[x22]
 mov x9,#152
 movz x10,#0x501,lsl#32
 stp x9,x10,[x22,#16]
 mov x10,#1
 stp x9,x10,[x22,#32]
 stp x10,x10,[x22,#48]
 mov w0,#0
 b .Linactive_owner_restore
.Linactive_owner_allocation_failed:
 mov w0,#1
.Linactive_owner_restore:
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Linactive_owner_reject:
 mov w0,#2
 ret
.size md2asm_initialize_inactive_composition_owners,.-md2asm_initialize_inactive_composition_owners

/* Release only the owned aerosol payload; preserve all other descriptor bytes. */
.p2align 4
.global md2asm_release_inactive_composition_owner
.type md2asm_release_inactive_composition_owner,%function
md2asm_release_inactive_composition_owner:
 cbz x0,.Linactive_release_reject
 tst x0,#7
 b.ne .Linactive_release_reject
 adds x9,x0,#64
 b.cs .Linactive_release_reject
 mrs x9,fpcr
 cbnz x9,.Linactive_release_reject
 ldr x9,[x0]
 cbz x9,.Linactive_release_empty
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x18,[sp,#16]
 mov x19,x0
 mov x0,x9
 bl free
 str xzr,[x19]
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
.Linactive_release_empty:
 mov w0,#0
 ret
.Linactive_release_reject:
 mov w0,#2
 ret
.size md2asm_release_inactive_composition_owner,.-md2asm_release_inactive_composition_owner
.section .note.GNU-stack,"",%progbits

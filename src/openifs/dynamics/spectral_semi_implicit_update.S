/* Direct spectral semi-implicit parent from arithmetic revision 2.
 * Physics: formulations/openifs/dynamics/spectral_semi_implicit_update.md revision 1.
 * Contract: skills/md2asm/references/openifs/dynamics/spectral_semi_implicit_update.md.
 * Complete selected source route, with private accepted assembly children.
 * No compiler numerical assembly or intermediate representation is used.
 */
.text
.p2align 4
.global md2asm_spcsi
.type md2asm_spcsi,%function
.macro COUNT index
 adrp x9,.Lspcsi_counts
 add x9,x9,:lo12:.Lspcsi_counts
 ldr x10,[x9,#8*\index]
 add x10,x10,#1
 str x10,[x9,#8*\index]
.endm
.macro OBSERVE index,slot,second=0
#ifdef SPCSI_NATIVE_STAGE_OBSERVER
 mov w0,#\index
 ldr x1,[sp,#\slot]
 .if \second
 ldr x2,[sp,#\second]
 .else
 mov x2,xzr
 .endif
 bl md2asm_spcsi_observe_stage
#endif
.endm
md2asm_spcsi:
 mov x17,sp
 sub sp,sp,#576
 str x18,[sp,#568]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp x29,x30,[sp,#96]
 stp d8,d9,[sp,#112]
 stp d10,d11,[sp,#128]
 stp d12,d13,[sp,#144]
 stp d14,d15,[sp,#160]
 stp x0,x1,[sp,#176]
 stp x2,x3,[sp,#192]
 stp x4,x5,[sp,#208]
 stp x6,x7,[sp,#224]
 ldp x9,x10,[x17]
 stp x9,x10,[sp,#240]
 ldp x9,x10,[x17,#16]
 stp x9,x10,[sp,#256]
 ldp x9,x10,[x17,#32]
 stp x9,x10,[sp,#272]
 ldp x9,x10,[x17,#48]
 stp x9,x10,[sp,#288]
 ldp x9,x10,[x17,#64]
 stp x9,x10,[sp,#304]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mrs x9,fpcr
 cbnz x9,.Lspcsi_bad
 ldr w9,[x19,#5224]
 cmp w9,#19
 b.ne .Lspcsi_bad
 ldr w9,[x19,#5228]
 cmp w9,#19
 b.ne .Lspcsi_bad
 ldr w9,[x19,#5236]
 cmp w9,#19
 b.ne .Lspcsi_bad
 ldr w9,[x19,#5172]
 cmp w9,#21
 b.ne .Lspcsi_bad
 ldr w9,[x19,#5212]
 cmp w9,#22
 b.ne .Lspcsi_bad
 ldr w9,[x19,#5200]
 cmp w9,#506
 b.ne .Lspcsi_bad
 ldr w9,[x19,#7212]
 cmp w9,#506
 b.ne .Lspcsi_bad
 ldr w9,[x19,#7216]
 cmp w9,#506
 b.ne .Lspcsi_bad
 ldr x9,[sp,#232]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lspcsi_bad
 ldr x9,[sp,#240]
 ldr w9,[x9]
 cmp w9,#506
 b.ne .Lspcsi_bad
 ldr x9,[sp,#248]
 ldr w9,[x9]
 cbnz w9,.Lspcsi_bad
 ldr w9,[x20,#108]
 cbnz w9,.Lspcsi_bad
 ldr w9,[x22,#2476]
 cbnz w9,.Lspcsi_bad
 ldr w9,[x22,#4444]
 cmp w9,#1
 b.ne .Lspcsi_bad
 ldr w9,[x23,#8]
 cbnz w9,.Lspcsi_bad
 ldr w9,[x23,#40]
 cbnz w9,.Lspcsi_bad
 ldr x9,[x19,#7512]
 movz x10,#0x3ff0,lsl #48
 cmp x9,x10
 b.ne .Lspcsi_bad
 ldr x9,[x19,#3264]
 cbz x9,.Lspcsi_bad
 ldr w10,[x9,#52]
 cmp w10,#1
 b.ne .Lspcsi_bad
 ldr w10,[x9,#36]
 cmp w10,#3
 b.ne .Lspcsi_bad
 ldr w9,[x19,#5144]
 cmp w9,#1
 b.lt .Lspcsi_bad
 adrp x9,:got:__yommp0_MOD_nprtrn
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nprtrn]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lspcsi_bad
 adrp x9,:got:__yommp0_MOD_nprtrv
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nprtrv]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lspcsi_bad

 /* Validate every consumed caller field and both dense matrix layouts. */
 ldr x0,[sp,#264]
 mov w1,#506
 bl .Lspcsi_rank2
 mov x24,x0
 ldr x0,[sp,#272]
 mov w1,#506
 bl .Lspcsi_rank2
 mov x25,x0
 ldr x0,[sp,#280]
 bl .Lspcsi_rank1
 mov x26,x0
 ldr x0,[sp,#312]
 cbz x0,.Lspcsi_bad
 mov w1,#506
 bl .Lspcsi_rank2
 mov x27,x0
 add x0,x22,#3224
 mov w1,#19
 bl .Lspcsi_rank2
 str x0,[sp,#8]
 add x0,x22,#3136
 mov w1,#19
 bl .Lspcsi_rank2

 /* One owned scratch allocation for every source temporary. */
 movz x0,#0xee00
 movk x0,#5,lsl #16
 bl malloc
 cbz x0,.Lspcsi_bad
 mov x28,x0
 str x0,[sp,#320]
 movz x9,#0x2c70
 movk x9,#1,lsl #16
 add x0,x0,x9
 str x0,[sp,#328]
 add x0,x0,x9
 str x0,[sp,#336]
 add x0,x0,x9
 str x0,[sp,#344]
 add x0,x0,x9
 str x0,[sp,#352]
 add x0,x0,x9
 str x0,[sp,#360]
 mov w9,#1
 str w9,[sp,#376]
 mov w9,#19
 str w9,[sp,#380]
 mov w9,#506
 str w9,[sp,#384]
 str wzr,[sp,#388]
 ldr d0,[x22,#2496]
 ldr d1,[x21,#208]
 fmul d8,d0,d1
 str d8,[sp,#368]

 /* Complete hydrostatic gamma from temperature and surface pressure. */
 mov x0,x19
 mov x1,x22
 add x2,sp,#376
 add x3,sp,#380
 ldr x4,[sp,#320]
 mov x5,x25
 mov x6,x26
 add x7,sp,#384
 add x9,sp,#380
 str x9,[sp]
 bl md2asm_spcsi_sigam
 COUNT 0
 OBSERVE 0,320

 /* Original RHS. Select each degree through NVALUE and NPTRSV. */
 add x9,x19,#4096
 add x9,x9,#1480
 ldp x10,x11,[x9]
 adrp x12,:got:__yommp0_MOD_mysetv
 ldr x12,[x12,:got_lo12:__yommp0_MOD_mysetv]
 ldrsw x12,[x12]
 add x11,x11,x12
 ldrsw x11,[x10,x11,lsl #2]
 sub x11,x11,#1
 ldr x9,[x19,#3848]
 ldr x10,[x19,#3856]
 add x10,x10,x11
 add x10,x10,#1
 add x9,x9,x10,lsl #2
 ldr x10,[x19,#4104]
 ldr x11,[x19,#4112]
 add x10,x10,x11,lsl #3
 ldr x12,[sp,#320]
 ldr x13,[sp,#320]
 mov x14,x24
 mov x15,x27
 mov x16,#506
.Lspcsi_rhs_column:
 ldrsw x11,[x9],#4
 ldr d0,[x10,x11,lsl #3]
 fmul d1,d8,d0
 mov x17,#19
.Lspcsi_rhs_level:
 ldr d2,[x12],#8
 fmul d2,d1,d2
 ldr d3,[x14],#8
 fsub d3,d3,d2
 ldr d4,[x15],#8
 fadd d3,d3,d4
 str d3,[x13],#8
 subs x17,x17,#1
 b.ne .Lspcsi_rhs_level
 subs x16,x16,#1
 b.ne .Lspcsi_rhs_column
 OBSERVE 1,320

 /* Level coefficients to vertical modes with the unfused matrix order. */
 ldr x0,[x22,#3224]
 ldr x1,[sp,#320]
 ldr x2,[sp,#328]
 bl md2asm_spcsi_matrix_product
 COUNT 1
 OBSERVE 2,328

 /* Two complete private descriptors for the full implicit solve. */
 add x0,sp,#392
 ldr x1,[sp,#328]
 bl .Lspcsi_make_descriptor
 add x0,sp,#480
 ldr x1,[sp,#336]
 bl .Lspcsi_make_descriptor
 mov x0,x19
 mov x1,x21
 mov x2,x22
 add x3,x23,#8
 add x4,x23,#40
 ldr x5,[sp,#248]
 add x6,sp,#392
 add x7,sp,#480
 bl md2asm_spcsi_pressure_solve
 COUNT 2
 OBSERVE 3,336

 /* Modes back to levels, writing only the declared divergence output. */
 ldr x0,[x22,#3136]
 ldr x1,[sp,#336]
 mov x2,x24
 bl md2asm_spcsi_matrix_product
 COUNT 3
#ifdef SPCSI_NATIVE_STAGE_OBSERVER
 mov w0,#4
 mov x1,x24
 mov x2,xzr
 bl md2asm_spcsi_observe_stage
#endif

 /* The original two stretching-factor products remain explicit. */
 ldr x9,[sp,#344]
 mov x10,x24
 mov x11,#9614
 ldr d0,[x19,#7512]
.Lspcsi_prepare_velocity:
 ldr d1,[x10],#8
 fmul d1,d1,d0
 fmul d1,d1,d0
 str d1,[x9],#8
 subs x11,x11,#1
 b.ne .Lspcsi_prepare_velocity
 OBSERVE 5,344

 /* Complete temperature and log-pressure operators. */
 mov x0,x19
 mov x1,x22
 add x2,sp,#376
 add x3,sp,#380
 ldr x4,[sp,#344]
 ldr x5,[sp,#352]
 ldr x6,[sp,#360]
 add x7,sp,#384
 bl md2asm_spcsi_temperature_pressure
 COUNT 4
 OBSERVE 6,352,360

 /* Every updated temperature and pressure bit remains source ordered. */
 ldr d8,[sp,#368]
 ldr x9,[sp,#352]
 ldr x10,[sp,#360]
 mov x11,x25
 mov x12,x26
 mov x13,#506
.Lspcsi_update_column:
 mov x14,#19
.Lspcsi_update_level:
 ldr d0,[x9],#8
 fmul d0,d8,d0
 ldr d1,[x11]
 fsub d1,d1,d0
 str d1,[x11],#8
 subs x14,x14,#1
 b.ne .Lspcsi_update_level
 ldr d0,[x10],#8
 fmul d0,d8,d0
 ldr d1,[x12]
 fsub d1,d1,d0
 str d1,[x12],#8
 subs x13,x13,#1
 b.ne .Lspcsi_update_column
 mov x0,x28
 bl free
 ldp d8,d9,[sp,#112]
 ldp d10,d11,[sp,#128]
 ldp d12,d13,[sp,#144]
 ldp d14,d15,[sp,#160]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp,#96]
 ldr x18,[sp,#568]
 add sp,sp,#576
 ret
.size md2asm_spcsi,.-md2asm_spcsi

/* Fixed dense descriptor validation returns the first physical cell. */
.Lspcsi_rank2:
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lspcsi_bad
 ldr x9,[x0,#24]
 movz x10,#0x0302,lsl #32
 cmp x9,x10
 b.ne .Lspcsi_bad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lspcsi_bad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lspcsi_bad
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Lspcsi_bad
 ldr x9,[x0,#56]
 cmp x9,#19
 b.ne .Lspcsi_bad
 ldr x9,[x0,#64]
 cmp x9,#19
 b.ne .Lspcsi_bad
 ldr x9,[x0,#72]
 cmp x9,#1
 b.ne .Lspcsi_bad
 ldr x9,[x0,#80]
 cmp x9,x1
 b.ne .Lspcsi_bad
 ldr x9,[x0,#8]
 cmn x9,#20
 b.ne .Lspcsi_bad
 ldr x0,[x0]
 cbz x0,.Lspcsi_bad
 tst x0,#7
 b.ne .Lspcsi_bad
 ret
.Lspcsi_rank1:
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lspcsi_bad
 ldr x9,[x0,#24]
 movz x10,#0x0301,lsl #32
 cmp x9,x10
 b.ne .Lspcsi_bad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lspcsi_bad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lspcsi_bad
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Lspcsi_bad
 ldr x9,[x0,#56]
 cmp x9,#506
 b.ne .Lspcsi_bad
 ldr x9,[x0,#8]
 cmn x9,#1
 b.ne .Lspcsi_bad
 ldr x0,[x0]
 cbz x0,.Lspcsi_bad
 tst x0,#7
 b.ne .Lspcsi_bad
 ret
.Lspcsi_make_descriptor:
 str x1,[x0]
 mov x9,#-20
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 movz x9,#0x0302,lsl #32
 str x9,[x0,#24]
 mov x9,#8
 str x9,[x0,#32]
 mov x9,#1
 str x9,[x0,#40]
 str x9,[x0,#48]
 mov x9,#19
 str x9,[x0,#56]
 str x9,[x0,#64]
 mov x9,#1
 str x9,[x0,#72]
 mov x9,#506
 str x9,[x0,#80]
 ret

/* Each independent output retains all nineteen product/add rounding points. */
.global md2asm_spcsi_matrix_product
.hidden md2asm_spcsi_matrix_product
.type md2asm_spcsi_matrix_product,%function
md2asm_spcsi_matrix_product:
 mov x3,#506
.Lspcsi_matrix_column:
 mov x4,#19
 mov x5,x0
.Lspcsi_matrix_row:
 mov x6,x5
 mov x7,x1
 mov x8,#19
 fmov d0,xzr
.Lspcsi_matrix_contraction:
 ldr d1,[x6]
 add x6,x6,#152
 ldr d2,[x7],#8
 fmul d1,d1,d2
 fadd d0,d0,d1
 subs x8,x8,#1
 b.ne .Lspcsi_matrix_contraction
 str d0,[x2],#8
 add x5,x5,#8
 subs x4,x4,#1
 b.ne .Lspcsi_matrix_row
 add x1,x1,#152
 subs x3,x3,#1
 b.ne .Lspcsi_matrix_column
 ret
.size md2asm_spcsi_matrix_product,.-md2asm_spcsi_matrix_product

.Lspcsi_bad:
 bl abort
 brk #0

.global md2asm_spcsi_child_count_get
.type md2asm_spcsi_child_count_get,%function
md2asm_spcsi_child_count_get:
 cmp w0,#4
 b.hi .Lspcsi_count_zero
 adrp x1,.Lspcsi_counts
 add x1,x1,:lo12:.Lspcsi_counts
 ldr x0,[x1,w0,uxtw #3]
 ret
.Lspcsi_count_zero:
 mov x0,xzr
 ret
.size md2asm_spcsi_child_count_get,.-md2asm_spcsi_child_count_get
.bss
.p2align 3
.Lspcsi_counts:
 .zero 40
.section .note.GNU-stack,"",%progbits

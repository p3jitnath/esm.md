/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_lagrangian_controls.md. */
/* Direct selected SUDYN trajectory controls. See skills/md2asm/references/openifs/setup/operational_lagrangian_controls.md.
 * x0 text,x1 textbytes,x2 Geometry20400,x3 MODEL4275088,x4 config67616.
 * Consume the actual first NAMDYN group before any public MODEL store. */
.arch armv8.2-a
.text
.macro AT out,base,off
 movz \out,#((\off)&65535)
 movk \out,#((\off)>>16),lsl#16
 add \out,\base,\out
.endm
.p2align 4
.global md2asm_initialize_operational_lagrangian_controls
.type md2asm_initialize_operational_lagrangian_controls,%function
md2asm_initialize_operational_lagrangian_controls:
 sub sp,sp,#320
 stp x29,x30,[sp]
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 cbz x19,.Lbad
 cbz x20,.Lbad
 cmp x20,#64,lsl#12
 b.hi .Lbad
 cbz x21,.Lbad
 cbz x22,.Lbad
 cbz x23,.Lbad
 orr x9,x21,x22
 orr x9,x9,x23
 tst x9,#7
 b.ne .Lbad
 mrs x9,fpcr
 cbnz x9,.Lbad
 /* Four complete incoming ranges must be nonwrapping and disjoint. */
 stp x19,x20,[sp,#160]
 mov x9,#20400
 stp x21,x9,[sp,#176]
 movz x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 stp x22,x9,[sp,#192]
 movz x9,#(67616&65535)
 movk x9,#(67616>>16),lsl#16
 stp x23,x9,[sp,#208]
 mov x10,#0
.Lrange:
 add x9,sp,#160
 add x9,x9,x10,lsl#4
 ldp x11,x12,[x9]
 adds x13,x11,x12
 b.cs .Lbad
 mov x14,#0
.Lprior:
 cmp x14,x10
 b.hs .Lrange_next
 add x9,sp,#160
 add x9,x9,x14,lsl#4
 ldp x15,x16,[x9]
 add x16,x15,x16
 cmp x11,x16
 b.hs .Lprior_next
 cmp x15,x13
 b.lo .Lbad
.Lprior_next:
 add x14,x14,#1
 b .Lprior
.Lrange_next:
 add x10,x10,#1
 cmp x10,#4
 b.lo .Lrange
 ldr x9,[x23]
 cmp x9,x22
 b.ne .Lbad
 ldr x9,[x23,#16]
 cmp x9,x21
 b.ne .Lbad
 ldr x9,[x22,#8]
 cmp x9,x21
 b.ne .Lbad
 ldr x9,[x23,#24]
 mov x10,#0x4346
 movk x10,#0x4731,lsl#16
 cmp x9,x10
 b.ne .Lbad
 adr x9,.Lplatform_offsets
 add x10,sp,#128
 mov x11,#0
.Lplatform:
 ldr w12,[x9,x11,lsl#2]
 ldr w12,[x23,x12]
 str w12,[x10,x11,lsl#2]
 add x11,x11,#1
 cmp x11,#5
 b.lo .Lplatform
 ldp w9,w10,[sp,#128]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[sp,#136]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 ldr w9,[sp,#144]
 cbnz w9,.Lbad
 AT x9,x22,1564136
 ldr w10,[x9,#8]
 cbnz w10,.Lbad
 ldp w10,w11,[x9,#20]
 cmp w10,#1
 b.ne .Lbad
 cmp w11,#1
 b.ne .Lbad
 AT x9,x22,1359332
 ldr w9,[x9]
 cmp w9,#1
 b.lt .Lbad
 AT x9,x22,1568800
 ldr w9,[x9]
 cbnz w9,.Lbad
 mov x9,#5224
 ldr w24,[x21,x9]
 sub w10,w24,#1
 cmp w10,#254
 b.hi .Lbad
 /* A complete, ordinary STPREH(0:levels) owner comes from live SUSTA. */
 add x9,x21,#3272
 ldr x25,[x9]
 cbz x25,.Lbad
 tst x25,#7
 b.ne .Lbad
 ldr x10,[x9,#8]
 cbnz x10,.Lbad
 ldr x10,[x9,#16]
 cmp x10,#8
 b.ne .Lbad
 ldr w10,[x9,#28]
 cmp w10,#0x301
 b.ne .Lbad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lbad
 ldr x10,[x9,#48]
 cbnz x10,.Lbad
 ldr x10,[x9,#56]
 cmp x10,x24
 b.ne .Lbad
 add x10,x24,#1
 lsl x10,x10,#3
 adds x26,x25,x10
 b.cs .Lbad
 mov x10,#0
.Lpressure_ranges:
 add x9,sp,#160
 add x9,x9,x10,lsl#4
 ldp x11,x12,[x9]
 add x12,x11,x12
 cmp x25,x12
 b.hs .Lpressure_range_next
 cmp x11,x26
 b.lo .Lbad
.Lpressure_range_next:
 add x10,x10,#1
 cmp x10,#4
 b.lo .Lpressure_ranges
 mov x9,#0
.Lpressure_finite:
 ldr x10,[x25,x9,lsl#3]
 tbnz x10,#63,.Lbad
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lbad
 add x9,x9,#1
 cmp x9,x24
 b.ls .Lpressure_finite
 /* Private NAMDYN defaults precede the source first-group read. */
 str wzr,[sp,#112]
 AT x9,x22,1564420
 ldp w10,w11,[x9]
 cmp w10,#1
 b.hi .Lbad
 cmp w11,#1
 b.hi .Lbad
 orr w10,w10,w11
 mov w9,#2
 cmp w10,#0
 cinc w9,w9,ne
 str w9,[sp,#116]
 mov x0,x19
 add x1,x19,x20
 adr x2,.Lgroup
 mov x3,#6
 adr x4,.Lkeys
 add x5,sp,#112
 bl md2asm_parse_bounded_scalar_group
 cbnz w0,.Lbad
 /* Count the source-selected standard-atmosphere layers before publication. */
 adr x9,.Lthreshold
 ldr d1,[x9]
 mov x9,#1
 mov w27,#0
.Lfilter_count:
 ldr d0,[x25,x9,lsl#3]
 fcmp d0,d1
 cinc w27,w27,le
 add x9,x9,#1
 cmp x9,x24
 b.ls .Lfilter_count
 cmp w27,w24
 csel w27,w27,w24,le
 mov x0,x21
 mov x1,#20400
 mov x2,x22
 movz x3,#(4275088&65535)
 movk x3,#(4275088>>16),lsl#16
 add x4,sp,#128
 add x5,x23,#64
 add x5,x5,#184
 add x6,sp,#144
 bl md2asm_initialize_reference_atmosphere_controls
 cbnz w0,.Lbad
 /* Integer stores preserve all unrelated MODEL bytes and the GFL side effect. */
 adr x9,.Lint_defaults
.Lint_next:
 ldp w10,w11,[x9],#8
 cbz w10,.Lreal_start
 str w11,[x22,x10]
 b .Lint_next
.Lreal_start:
 adr x9,.Lreal_defaults
.Lreal_next:
 ldp x10,x11,[x9],#16
 cbz x10,.Lspecial_values
 str x11,[x22,x10]
 b .Lreal_next
.Lspecial_values:
 AT x9,x22,1569080
 str w27,[x9]
 ldp w10,w11,[sp,#112]
 AT x9,x22,1569164
 str w10,[x9]
 AT x9,x22,1568808
 str w11,[x9]
 /* The admitted top-pressure branch selects the same source XIDT override. */
 AT x9,x22,1567112
 ldr d0,[x9]
 adr x10,.Ltemperature350
 ldr d1,[x10]
 fcmp d0,d1
 adr x10,.Lxidt_default
 ldr d1,[x10]
 fmov d2,xzr
 fcsel d1,d2,d1,eq
 AT x9,x22,1568920
 str d1,[x9]
 mov w0,#0
 b .Lexit
.Lbad:
 mov w0,#2
.Lexit:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#320
 ret
.size md2asm_initialize_operational_lagrangian_controls,.-md2asm_initialize_operational_lagrangian_controls
.section .rodata
.p2align 3
.Lplatform_offsets: .word 35688,40104,40088,40084,35872
.Lgroup: .ascii "NAMDYN"
.p2align 3
.Lkeys:
 .word 7,2,0,0,1,0
 .ascii "LMASCOR"
 .zero 9
 .word 5,1,4,0,20,0
 .ascii "NITMP"
 .zero 11
 .zero 40
.p2align 3
.Lthreshold: .double 6000.0
.Ltemperature350: .double 350.0
.Lxidt_default: .double 0.05
.p2align 3
.Lint_defaults:
 .word 1569040,0 /* L2TLFF. */
 .word 1569032,0 /* LADVF. */
 .word 1569036,1 /* LIMPF. */
 .word 1568896,0 /* LRHS_CURV. */
 .word 1568836,0 /* LSETFSTAT. */
 .word 1568832,1 /* LSETTLSVF. */
 .word 1568840,0 /* LSETTLSVF_DIFF. */
 .word 1568892,1 /* LSLDP_CURV. */
 .word 1568888,0 /* LSLDP_RK. */
 .word 1568904,1 /* LSLDP_SAVE. */
 .word 1568900,1 /* LSLDP_XYZ. */
 .word 1569060,0 /* LSVTSM. */
 .word 1567172,0 /* NCURRENT_ITER. */
 .word 1568788,3 /* NSPDLAG. */
 .word 1568796,0 /* NSPLTHOI. */
 .word 1568792,3 /* NSVDLAG. */
 .word 1568784,3 /* NTLAG. */
 .word 1568776,3 /* NVLAG. */
 .word 1568780,3 /* NWLAG. */
 .word 0,0
.p2align 3
.Lreal_defaults:
 .quad 1567072,0x3ff0000000000000 /* BETADT. */
 .quad 1569048,0x3ff0000000000000 /* RCMSLP0. */
 .quad 1569104,0x3ff0000000000000 /* RINTOPT. */
 .quad 1569112,0x3ff0000000000000 /* RRINTOPT. */
 .quad 1569088,0x42d6bcc41e900000 /* RSCALE. */
 .quad 1569096,0x3d06849b86a12b9b /* RSCALEOFF. */
 .quad 1569072,0x40b7700000000000 /* RPRES_SETTLSVF. */
 .quad 1568912,0x0000000000000000 /* VESL. */
 .quad 1568848,0x0000000000000000 /* RW2TLFF. */
 .quad 0,0
.section .note.GNU-stack,"",%progbits

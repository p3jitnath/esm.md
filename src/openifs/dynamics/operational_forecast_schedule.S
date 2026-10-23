/* Contract: skills/md2asm/references/openifs/dynamics/operational_forecast_schedule.md.
 * Accepted component source. Complete operational forecast acceptance remains separate. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_output_switches
.type md2asm_initialize_operational_output_switches,%function
md2asm_initialize_operational_output_switches:
 cbz x0,.Los_bad_leaf
 cbz x1,.Los_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Los_bad_leaf
 cbz x2,.Los_bad_leaf
 cbz x3,.Los_bad_leaf
 orr x9,x2,x3
 tst x9,#7
 b.ne .Los_bad_leaf
 adds x9,x0,x1
 b.cs .Los_bad_leaf
 adds x10,x3,#64
 b.cs .Los_bad_leaf
 cmp x10,x0
 b.ls .Los_range_cfg
 cmp x3,x9
 b.lo .Los_bad_leaf
.Los_range_cfg:
 mov x11,#67616&65535
 movk x11,#67616>>16,lsl#16
 adds x11,x2,x11
 b.cs .Los_bad_leaf
 cmp x10,x2
 b.ls .Los_fp
 cmp x3,x11
 b.lo .Los_bad_leaf
.Los_fp:
 mrs x10,fpcr
 cbnz x10,.Los_bad_leaf
 mov x10,#35688
 ldr w11,[x2,x10]
 cmp w11,#1
 b.ne .Los_bad_leaf
 mov x10,#35768
 ldr w11,[x2,x10]
 cmp w11,#1
 b.hi .Los_bad_leaf
 stp x29,x30,[sp,#-176]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x29,sp
 mov x19,x3
 mov x20,x2
 mov x1,x9
 adr x2,.Los_group
 mov x3,#6
 adr x4,.Los_keys
 add x5,sp,#80
 adr x9,.Los_defaults
 ldp x10,x11,[x9]
 stp x10,x11,[x5]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[x5,#16]
 ldp x10,x11,[x9,#32]
 stp x10,x11,[x5,#32]
 ldp x10,x11,[x9,#48]
 stp x10,x11,[x5,#48]
 bl md2asm_parse_operational_forecast_group
 cbnz w0,.Los_bad_frame
 /* SUCT1 combines the parsed LRFILAF with LARPEGEF after reading. */
 mov x9,#35768
 ldr w10,[x20,x9]
 ldr w11,[sp,#132]
 and w11,w11,w10
 str w11,[sp,#132]
 ldp x9,x10,[sp,#80]
 stp x9,x10,[x19]
 ldp x9,x10,[sp,#96]
 stp x9,x10,[x19,#16]
 ldp x9,x10,[sp,#112]
 stp x9,x10,[x19,#32]
 ldp x9,x10,[sp,#128]
 stp x9,x10,[x19,#48]
 mov w0,#0
 b .Los_return
.Los_bad_frame:
 mov w0,#2
.Los_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp],#176
 ret
.Los_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_output_switches,.-md2asm_initialize_operational_output_switches

/* x0 cfg67616, x1 MODEL4275088, x2 switches64, w3 step,
 * w4 complete source fullpos eligibility, x5 output96.
 * Full mapped buffers and disjoint input records are caller obligations. */
.macro OP_MWORD dst,off
 movz x17,#(\off&65535)
 movk x17,#(\off>>16),lsl#16
 ldr \dst,[x1,x17]
.endm
.macro OP_OUT_DISJOINT base,bytes
 movz x17,#(\bytes&65535)
 movk x17,#(\bytes>>16),lsl#16
 adds x17,\base,x17
 b.cs .Lop_bad
 cmp x16,\base
 b.ls 91f
 cmp x5,x17
 b.lo .Lop_bad
91:
.endm
.p2align 4
.global md2asm_select_operational_forecast_stage
.type md2asm_select_operational_forecast_stage,%function
md2asm_select_operational_forecast_stage:
 cbz x0,.Lop_bad
 cbz x1,.Lop_bad
 cbz x2,.Lop_bad
 cbz x5,.Lop_bad
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lop_bad
 adds x16,x5,#96
 b.cs .Lop_bad
 OP_OUT_DISJOINT x0,67616
 OP_OUT_DISJOINT x1,4275088
 OP_OUT_DISJOINT x2,64
 mrs x9,fpcr
 cbnz x9,.Lop_bad
 cmp w4,#1
 b.hi .Lop_bad
 mov x9,#35688
 ldr w9,[x0,x9]
 cmp w9,#1
 b.ne .Lop_bad
 OP_MWORD w9,1359328
 cbnz w9,.Lop_bad
 OP_MWORD w9,1359332
 cmp w9,#8
 b.ne .Lop_bad
 cmp w3,w9
 b.hi .Lop_bad
 OP_MWORD w9,1564156
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4218356
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4232912
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4232956
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4232960
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4232964
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4232968
 cmp w9,#1
 b.hi .Lop_bad
 OP_MWORD w9,4271608
 cmp w9,#1
 b.hi .Lop_bad
 movz x17,#(1359528&65535)
 movk x17,#(1359528>>16),lsl#16
 ldr x9,[x1,x17]
 adr x10,.Lop_450
 ldr x10,[x10]
 cmp x9,x10
 b.ne .Lop_bad
 /* Refuse unsupported explicit lists before changing output bytes. */
 adr x6,.Lop_rows
 mov w7,#10
.Lop_preflight:
 ldp w9,w10,[x6]
 ldr w11,[x6,#8]
 ldr w13,[x0,x9]
 sub w13,w13,#1
 movz w14,#(999998&65535)
 movk w14,#(999998>>16),lsl#16
 cmp w13,w14
 b.hi .Lop_bad
 ldr w14,[x0,x10]
 cbnz w14,.Lop_bad
 tbnz w11,#31,.Lop_preflight_literal
 ldr w15,[x2,x11]
 cmp w15,#1
 b.hi .Lop_bad
.Lop_preflight_literal:
 add x6,x6,#20
 subs w7,w7,#1
 b.ne .Lop_preflight
 stp xzr,xzr,[x5]
 stp xzr,xzr,[x5,#16]
 stp xzr,xzr,[x5,#32]
 stp xzr,xzr,[x5,#48]
 stp xzr,xzr,[x5,#64]
 stp xzr,xzr,[x5,#80]
 str w3,[x5]
 mov w9,#8
 str w9,[x5,#4]
 adr x6,.Lop_rows
 mov w7,#10
.Lop_flags:
 ldr w9,[x6]
 ldp w11,w12,[x6,#8]
 ldr w13,[x0,x9]
 tbnz w11,#31,.Lop_source_literal
 ldr w15,[x2,x11]
 b .Lop_source_enable
.Lop_source_literal:
 mov w15,#1
 OP_MWORD w16,4232912
 and w15,w15,w16
.Lop_source_enable:
 ldr w16,[x6,#16]
 cbz w16,.Lop_source_enabled
 ldr w16,[x1,x16]
 and w15,w15,w16
.Lop_source_enabled:
 udiv w14,w3,w13
 msub w14,w14,w13,w3
 cmp w14,#0
 csel w15,w15,wzr,eq
 /* Source MONIO_T mass-correction LDCOND is NFRMASSCON<=NSTOP. */
 cmp w7,#1
 b.ne .Lop_store_flag
 cmp w13,#8
 csel w15,w15,wzr,ls
.Lop_store_flag:
 str w15,[x5,x12]
 add x6,x6,#20
 subs w7,w7,#1
 b.ne .Lop_flags
 adr x9,.Lop_450
 ldr d1,[x9]
 fmov d0,d1
 cbz w3,.Lop_dt_ready
 OP_MWORD w9,1564156
 cbnz w9,.Lop_dt_ready
 fmov d2,#2.0
 fmul d0,d2,d0
.Lop_dt_ready:
 str d0,[x5,#48]
 scvtf d0,w3
 fmul d0,d0,d1
 fmov d2,#0.5
 fadd d0,d0,d2
 str d0,[x5,#56]
 ldr w9,[x5,#8]
 and w4,w4,w9
 str w4,[x5,#80]
 OP_MWORD w9,4232912
 OP_MWORD w10,4271608
 orr w9,w9,w10
 str w9,[x5,#84]
 movz x10,#0x3030
 movk x10,#0x3030,lsl#16
 movk x10,#0x3030,lsl#32
 movk x10,#0x3030,lsl#48
 str x10,[x5,#64]
 mov w10,#48
 strb w10,[x5,#72]
 /* History and surface-history selection is shared by the two CNT4 branches. */
 ldr w10,[x5,#12]
 ldr w11,[x5,#16]
 cbz w10,.Lop_not_history
 mov w10,#65
 cbz w11,.Lop_first_ready
 mov w10,#81
 b .Lop_first_ready
.Lop_not_history:
 mov w10,#48
 cbz w11,.Lop_first_ready
 mov w10,#83
.Lop_first_ready:
 strb w10,[x5,#64]
 cmp w3,#8
 b.lo .Lop_complete_update
 orr w9,w9,w4
 cbz w9,.Lop_done
 mov w10,#65
 strb w10,[x5,#65]
 strb w10,[x5,#66]
 strb w10,[x5,#67]
 b .Lop_done
.Lop_complete_update:
 mov w10,#65
 strb w10,[x5,#65]
 strb w10,[x5,#66]
 strb w10,[x5,#67]
 strb w10,[x5,#70]
 strb w10,[x5,#71]
 strb w10,[x5,#72]
.Lop_done:
 mov w0,#0
 ret
.Lop_bad:
 mov w0,#2
 ret
.size md2asm_select_operational_forecast_stage,.-md2asm_select_operational_forecast_stage
.section .rodata
.p2align 3
.Los_defaults:
 .word 1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0
.Los_group: .ascii "NAMCT1"
.p2align 3
.Los_keys:
 .word 5,1,0,0,1,0
 .ascii "N1POS"
 .zero 11
 .word 5,1,4,0,1,0
 .ascii "N1HIS"
 .zero 11
 .word 5,1,8,0,1,0
 .ascii "N1SDI"
 .zero 11
 .word 5,1,12,0,1,0
 .ascii "N1RES"
 .zero 11
 .word 8,1,16,0,1,0
 .ascii "N1SFXHIS"
 .zero 8
 .word 5,1,20,0,1,0
 .ascii "N1GDI"
 .zero 11
 .word 5,1,24,0,1,0
 .ascii "N1DHP"
 .zero 11
 .word 6,1,28,0,1,0
 .ascii "N1DHFG"
 .zero 10
 .word 6,1,32,0,1,0
 .ascii "N1DHFZ"
 .zero 10
 .word 6,1,36,0,1,0
 .ascii "N1DHFD"
 .zero 10
 .word 5,1,40,0,1,0
 .ascii "N1CFU"
 .zero 11
 .word 5,1,44,0,1,0
 .ascii "N1XFU"
 .zero 11
 .word 9,1,48,0,1,0
 .ascii "N1MASSCON"
 .zero 7
 .word 7,2,52,0,1,0
 .ascii "LRFILAF"
 .zero 9
 .word 7,2,56,0,1,0
 .ascii "LWRSPEC"
 .zero 9
 .zero 40
.p2align 3
.Lop_450: .double 450.0
.Lop_rows:
 .word 35708,584,0,8,0
 .word 35712,4428,4,12,0
 .word 40060,36216,16,16,4218356
 .word 35720,8272,20,20,0
 .word 35724,12116,8,24,0
 .word 35732,15960,-1,28,4232960
 .word 35736,19804,-1,32,4232964
 .word 35740,23648,-1,36,4232968
 .word 35744,27492,-1,40,4232956
 .word 35752,31336,48,44,0
.section .note.GNU-stack,"",%progbits

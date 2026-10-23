/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Direct operational SUTRAJP, SUNUD and SUMCC controls.
 * Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md.
 * Preserve the original default, namelist, frequency and reset boundaries. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_inactive_startup_controls
.type md2asm_initialize_operational_inactive_startup_controls,%function
md2asm_initialize_operational_inactive_startup_controls:
 cbz x0,.Linactive_bad_leaf
 cbz x1,.Linactive_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Linactive_bad_leaf
 adds x9,x0,x1
 b.cs .Linactive_bad_leaf
 cbz x2,.Linactive_bad_leaf
 tst x2,#7
 b.ne .Linactive_bad_leaf
 adds x10,x2,#128
 b.cs .Linactive_bad_leaf
 mrs x11,fpcr
 cbnz x11,.Linactive_bad_leaf
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 /* Complete range and pair validation precedes every source store. */
 adr x12,.Linactive_record_sizes
 mov x6,#0
.Linactive_range:
 lsl x9,x6,#4
 add x13,x21,x9
 ldp x7,x8,[x13]
 cbz x7,.Linactive_bad
 ldr x10,[x12,x6,lsl#3]
 cmp x10,#4
 b.eq .Linactive_scalar_align
 tst x7,#7
 b.ne .Linactive_bad
 b .Linactive_aligned
.Linactive_scalar_align:
 tst x7,#3
 b.ne .Linactive_bad
.Linactive_aligned:
 cmp x8,x10
 b.lo .Linactive_bad
 adds x11,x7,x10
 b.cs .Linactive_bad
 cmp x6,#3
 b.hs .Linactive_prior_start
 add x8,x19,x20
 cmp x7,x8
 b.hs .Linactive_text_clear
 cmp x19,x11
 b.lo .Linactive_bad
.Linactive_text_clear:
 add x8,x21,#128
 cmp x7,x8
 b.hs .Linactive_prior_start
 cmp x21,x11
 b.lo .Linactive_bad
.Linactive_prior_start:
 mov x9,#0
.Linactive_prior:
 cmp x9,x6
 b.hs .Linactive_next_range
 lsl x10,x9,#4
 ldr x8,[x21,x10]
 ldr x10,[x12,x9,lsl#3]
 add x10,x8,x10
 cmp x7,x10
 b.hs .Linactive_prior_clear
 cmp x8,x11
 b.lo .Linactive_bad
.Linactive_prior_clear:
 add x9,x9,#1
 b .Linactive_prior
.Linactive_next_range:
 add x6,x6,#1
 cmp x6,#8
 b.lo .Linactive_range
 ldr x9,[x21,#64]
 ldr w10,[x9,#4]
 cmp w10,#1
 b.hi .Linactive_bad
 ldr x9,[x21,#80]
 ldr w10,[x9,#48]
 cmp w10,#1
 b.hi .Linactive_bad
 ldr x9,[x21,#112]
 ldr w10,[x9]
 cbnz w10,.Linactive_bad
 mov x0,x19
 mov x1,x20
 adr x2,.Linactive_nud_group
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Linactive_bad
 str wzr,[sp,#104]
 mov w9,#1
 str w9,[sp,#108]
 mov x0,x19
 add x1,x19,x20
 adr x2,.Linactive_mcc_group
 mov x3,#6
 adr x4,.Loperational_mcc_keys
 add x5,sp,#104
 bl md2asm_parse_operational_forecast_group
 cbnz w0,.Linactive_bad
 /* The object declaration precedes all three genuine source bodies. */
 ldr x0,[x21,#16]
 ldr x1,[x21,#24]
 bl md2asm_initialize_climate_declaration_defaults
 cbnz w0,.Linactive_bad
 /* SUTRAJP is first in the selected SU0YOMA call order. */
 ldr x9,[x21,#32]
 mov w10,#9
 str w10,[x9]
 /* SUNUD writes every named state member except the alignment gap. */
 ldr x22,[x21]
 mov x9,#0
.Linactive_nud_zero:
 str wzr,[x22,x9]
 add x9,x9,#4
 cmp x9,#100
 b.lo .Linactive_nud_zero
 mov w9,#999
 str w9,[x22,#4]
 mov w9,#1
 str w9,[x22,#8]
 mov w9,#998
 str w9,[x22,#20]
 mov w9,#999
 str w9,[x22,#24]
 add x10,x22,#104
 mov x9,#0x3ff0000000000000
 mov x11,#200
.Linactive_profile:
 str x9,[x10],#8
 subs x11,x11,#1
 b.ne .Linactive_profile
 add x10,x22,#1704
 mov x11,#15
.Linactive_coefficients:
 str xzr,[x10],#8
 subs x11,x11,#1
 b.ne .Linactive_coefficients
 /* SUMCC source defaults, then inactive-coupling guards in source order. */
 ldr x22,[x21,#16]
 adr x23,.Linactive_mcc_rows
.Linactive_mcc_store:
 adr x9,.Loperational_mcc_read_boundary
 cmp x23,x9
 b.ne .Loperational_mcc_check_frequency
 ldp w10,w11,[sp,#104]
 str w10,[x22,#6776]
 str w11,[x22,#6780]
.Loperational_mcc_check_frequency:
 adr x9,.Loperational_mcc_frequency_boundary
 cmp x23,x9
 b.ne .Loperational_mcc_next_store
 ldr w10,[sp,#104]
 cbz w10,.Loperational_mcc_next_store
 ldr x9,[x21,#96]
 ldr w10,[x9]
 str w10,[x22,#6844]
.Loperational_mcc_next_store:
 ldp w9,w10,[x23],#8
 cmp w9,#-1
 b.eq .Linactive_success
 str w10,[x22,x9]
 b .Linactive_mcc_store
.Linactive_success:
 mov w0,#0
 b .Linactive_return
.Linactive_bad:
 mov w0,#2
.Linactive_return:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.Linactive_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_inactive_startup_controls,.-md2asm_initialize_operational_inactive_startup_controls
.p2align 4
.global md2asm_initialize_climate_declaration_defaults
.type md2asm_initialize_climate_declaration_defaults,%function
md2asm_initialize_climate_declaration_defaults:
 cbz x0,.Linactive_bad_leaf
 tst x0,#7
 b.ne .Linactive_bad_leaf
 mov x2,#7584
 cmp x1,x2
 b.lo .Linactive_bad_leaf
 adds x2,x0,x2
 b.cs .Linactive_bad_leaf
 adr x3,.Lclimate_owner_offsets
 mov x4,#11
.Lclimate_check_owner:
 ldr w5,[x3],#4
 ldr x6,[x0,x5]
 cbnz x6,.Linactive_bad_leaf
 subs x4,x4,#1
 b.ne .Lclimate_check_owner
 adr x3,.Lclimate_owner_offsets
 mov x4,#11
.Lclimate_null_owner:
 ldr w5,[x3],#4
 str xzr,[x0,x5]
 subs x4,x4,#1
 b.ne .Lclimate_null_owner
 adr x3,.Lclimate_default_rows
.Lclimate_default:
 ldp x4,x5,[x3]
 ldr x6,[x3,#16]
 add x3,x3,#24
 cmp x4,#-1
 b.eq .Lclimate_default_text
 cmp x5,#4
 b.ne .Lclimate_default_fpword
 str w6,[x0,x4]
 b .Lclimate_default
.Lclimate_default_fpword:
 str x6,[x0,x4]
 b .Lclimate_default
.Lclimate_default_text:
 mov x4,#7232
 add x4,x0,x4
 adr x5,.Ldefault_CDNPARTMASKFILE
 mov x6,#128
.Ldefault_copy_CDNPARTMASKFILE:
 ldrb w7,[x5],#1
 strb w7,[x4],#1
 subs x6,x6,#1
 b.ne .Ldefault_copy_CDNPARTMASKFILE
 mov w0,#0
 ret
.size md2asm_initialize_climate_declaration_defaults,.-md2asm_initialize_climate_declaration_defaults
.section .rodata
.p2align 3
.Linactive_record_sizes: .quad 1824,7584,4,4,88,448,4,4
.Linactive_nud_group: .ascii "NAMNUD"
.Linactive_mcc_group: .ascii "NAMMCC"
.p2align 3
.Lclimate_owner_offsets:
 .word 6088,6200,6312,6424,6536,6624,6904,6968,7104,7168,7360
.p2align 3
.Lclimate_default_rows:
 .quad 6736,4,0x0000000000000001 /* LFIRSTUPD declaration */
 .quad 6848,4,0x0000000000000001 /* LNEMOLIMGET declaration */
 .quad 6852,4,0x0000000000000001 /* LNEMOLIMPUT declaration */
 .quad 6856,4,0x0000000000000000 /* LNEMOLIMALB declaration */
 .quad 6860,4,0x0000000000000000 /* LNEMOLIMTEMP declaration */
 .quad 6864,4,0x0000000000000000 /* LNEMOLIMTLVL declaration */
 .quad 6868,4,0x0000000000000000 /* LNEMOLIMTHK declaration */
 .quad 6872,4,0x0000000000000000 /* LNEMOSICOUP declaration */
 .quad 6876,4,0x0000000000000001 /* LNEMOATMFLDS declaration */
 .quad 6880,4,0x0000000000000000 /* LNEMOOCEICEMIX declaration */
 .quad 6884,4,0x0000000000000000 /* LNEMOQNSICEFILT declaration */
 .quad 6888,4,0x0000000000000001 /* LNEMOACCUMFLUX declaration */
 .quad 7056,4,0x0000000000000000 /* LNEMOPARTCOUP declaration */
 .quad 7060,4,0x0000000000000000 /* LNEMOPARTMASK declaration */
 .quad 7064,4,0x0000000000000000 /* LNEMOPARTMASKFILE declaration */
 .quad 7072,8,0x4014000000000000 /* RNPARTRAMPSTART declaration */
 .quad 7080,8,0x4010000000000000 /* RNPARTRAMPLEN declaration */
 .quad 7088,8,0x4034000000000000 /* RNPARTLAT declaration */
 .quad 7096,8,0x4014000000000000 /* RNPARTLATSPREAD declaration */
 .quad 7424,4,0x0000000000000000 /* CPLNG_ACTIVE declaration */
 .quad 7428,4,0x0000000000000000 /* CPLNG_NUM_FIELDS declaration */
 .quad 7432,4,0xffffffffffffffff /* IP_A_SST declaration */
 .quad 7436,4,0xffffffffffffffff /* IP_A_ICE_FRAC declaration */
 .quad 7440,4,0xffffffffffffffff /* IP_A_CURR_U declaration */
 .quad 7444,4,0xffffffffffffffff /* IP_A_CURR_V declaration */
 .quad 7448,4,0xffffffffffffffff /* IP_A_TAUX_OCE declaration */
 .quad 7452,4,0xffffffffffffffff /* IP_A_TAUY_OCE declaration */
 .quad 7456,4,0xffffffffffffffff /* IP_A_TAUX_ICE declaration */
 .quad 7460,4,0xffffffffffffffff /* IP_A_TAUY_ICE declaration */
 .quad 7464,4,0xffffffffffffffff /* IP_A_QS_MIX declaration */
 .quad 7468,4,0xffffffffffffffff /* IP_A_QNS_MIX declaration */
 .quad 7472,4,0xffffffffffffffff /* IP_A_QS_OCE declaration */
 .quad 7476,4,0xffffffffffffffff /* IP_A_QNS_OCE declaration */
 .quad 7480,4,0xffffffffffffffff /* IP_A_QS_ICE declaration */
 .quad 7484,4,0xffffffffffffffff /* IP_A_QNS_ICE declaration */
 .quad 7488,4,0xffffffffffffffff /* IP_A_PRECIP_LIQUID declaration */
 .quad 7492,4,0xffffffffffffffff /* IP_A_PRECIP_SOLID declaration */
 .quad 7496,4,0xffffffffffffffff /* IP_A_EVAP_TOTAL declaration */
 .quad 7500,4,0xffffffffffffffff /* IP_A_EVAP_ICE declaration */
 .quad 7504,4,0xffffffffffffffff /* IP_A_DQNS_DT declaration */
 .quad 7508,4,0xffffffffffffffff /* IP_A_RUNOFF declaration */
 .quad 7512,4,0xffffffffffffffff /* IP_A_TOTAL_CC declaration */
 .quad 7516,4,0xffffffffffffffff /* IP_A_LOW_CC declaration */
 .quad 7520,4,0xffffffffffffffff /* IP_A_ICE_TEMP declaration */
 .quad 7524,4,0xffffffffffffffff /* IP_A_ICE_ALBEDO declaration */
 .quad 7528,4,0xffffffffffffffff /* IP_A_ICE_THICKNESS declaration */
 .quad 7532,4,0xffffffffffffffff /* IP_A_SNOW_THICKNESS declaration */
 .quad 7536,4,0xffffffffffffffff /* IP_A_ICE_TEMP_LVLS declaration */
 .quad 7540,4,0xffffffffffffffff /* IP_A_TAUX declaration */
 .quad 7544,4,0xffffffffffffffff /* IP_A_TAUY declaration */
 .quad 7548,4,0xffffffffffffffff /* IP_A_QS declaration */
 .quad 7552,4,0xffffffffffffffff /* IP_A_QNS declaration */
 .quad 7556,4,0xffffffffffffffff /* IP_A_WATER declaration */
 .quad 7560,4,0xffffffffffffffff /* IP_A_SST_ATM declaration */
 .quad 7564,4,0xffffffffffffffff /* IP_A_TSK_ATM declaration */
 .quad 7568,4,0xffffffffffffffff /* IP_A_IST_ATM declaration */
 .quad 7572,4,0xffffffffffffffff /* IP_A_2DECV_SKT declaration */
 .quad 7576,4,0x0000000000000000 /* LCOUPSIM declaration */
 .quad -1,0,0
.Ldefault_CDNPARTMASKFILE: .ascii "partialmask.grib                                                                                                                "
.p2align 3
.Linactive_mcc_rows:
 .word 6752,0 /* LMCC01 */
 .word 6756,0 /* LMCC02 */
 .word 6760,0 /* LMCC03 */
 .word 6764,0 /* LMCC04 */
 .word 6768,0 /* LMCC05 */
 .word 6776,0 /* LMCCEC */
 .word 6780,1 /* LMCCIEC */
 .word 6788,0 /* LMCCICEIC */
 .word 0,0 /* N923 */
 .word 6080,2 /* NOACOMM */
 .word 6844,999999 /* NFRCPL */
 .word 6740,0 /* LCURR */
 .word 6744,0 /* LGELATO */
 .word 6748,0 /* LMCC01_MSE */
 .word 6796,0 /* LNEMOCOUP */
 .word 6820,0 /* LNEMOSSTFREEZ */
 .word 6812,0 /* LNEMO1WAY */
 .word 6800,0 /* LNEMOFLUXNC */
 .word 6804,0 /* LNEMOOUTGRB */
 .word 6808,0 /* LCOUPINFOUT */
 .word 6816,0 /* LNEMOIFSLOG */
 .word 6792,0 /* LMCCDYNSEAICE */
 .word 6824,0 /* LNEMOGRIBFLDS */
 .word 6836,0 /* LMULTIYR */
 .word 6784,0 /* LMCCIEC_COMPO */
 .word 6840,0 /* LMCC_COMPO */
 .word 6084,9 /* NSSTICEOP */
 .word 6892,0 /* LNEMOGRIB3D */
 .word 6896,20 /* NNEMO3DLEVS */
 .word 6828,0 /* LNEMOGRIBMASK */
 .word 6832,0 /* L2DECV2NEMO */
.Loperational_mcc_read_boundary:
 .word 0,0 /* N923 */
.Loperational_mcc_frequency_boundary:
 .word 6812,0 /* LNEMO1WAY */
 .word 6800,0 /* LNEMOFLUXNC */
 .word 6804,0 /* LNEMOOUTGRB */
 .word 6824,0 /* LNEMOGRIBFLDS */
 .word 6892,0 /* LNEMOGRIB3D */
 .word 6828,0 /* LNEMOGRIBMASK */
 .word 6792,0 /* LMCCDYNSEAICE */
 .word 6848,0 /* LNEMOLIMGET */
 .word 6852,0 /* LNEMOLIMPUT */
 .word 6856,0 /* LNEMOLIMALB */
 .word 6860,0 /* LNEMOLIMTEMP */
 .word 6864,0 /* LNEMOLIMTLVL */
 .word 6868,0 /* LNEMOLIMTHK */
 .word -1,0
.p2align 3
.Loperational_mcc_keys:
 .word 6,2,0,0,1,0
 .ascii "LMCCEC"
 .zero 10
 .word 7,2,4,0,1,0
 .ascii "LMCCIEC"
 .zero 9
 .zero 40
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/field_dimension_setup.md. Direct selected SUDIMF1/SUDIMF2.
 * Six {address,capacity} records are TDIMF176,TDPHY88,TDYNA456,TEPHY448,
 * TPHY1096,TARPHY88. Upstream controls are the source-selected40 bytes.
 * Metadata only, no FP arithmetic or heap allocation. Preserve source tails. */
.arch armv8.2-a
.text
.equ dimf_NFTHER,0
.equ dimf_NF3D,4
.equ dimf_NFD2D,8
.equ dimf_NFC2D,12
.equ dimf_NS3D,16
.equ dimf_NS2D,20
.equ dimf_NS1D,24
.equ dimf_LVOR,160
.equ dimf_LADER,164
.equ dimf_LUVDER,168
.equ dimf_LSPT,172
.equ dphy_NCSS,0
.equ dphy_NVXP,4
.equ dphy_NVXP2,8
.equ dphy_NCXP,12
.equ dphy_NCSI,16
.equ dphy_NCOM,20
.equ dphy_NCSNEC,24
.equ dphy_NTILES,28
.equ dphy_NVEXTR,32
.equ dphy_NVEXTRDI,36
.equ dphy_NVEXTRRAD,40
.equ dphy_NVEXTRDYN,44
.equ dphy_NVXTR2,48
.equ dphy_NVECOUT,52
.equ dphy_NCEXTR,56
.equ dphy_NVCLIS,60
.equ dphy_NTOZ1D,64
.equ dphy_NTOZ2D,68
.equ dphy_NTOZ3D,72
.equ dphy_NTSSG,76
.equ dphy_LTPROF,80
.equ dphy_LDIRCLSMOD,84
.equ dyna_LSLAG,24
.equ dyna_LNHDYN,8
.equ dyna_LSLHD,76
.equ dyna_LSLHD_STATIC,104
.equ dyna_L3DTURB,212
.equ dyna_LCOMAD,236
.equ dyna_LNHX,40
.equ dyna_LRUBC,332
.equ ephy_LEFLAKE,196
.equ ephy_LEURBAN,344
.equ ephy_LEO3CH,72
.equ ephy_LEOCML,200
.equ ephy_LO3CH_BMS,84
.equ ephy_LO3CH_HLO,88
.equ ephy_LOCMLTKE,236
.equ ephy_LDIAGTURB_EC,252
.equ ephy_LDIAGTURBGRAD_EC,256
.equ phy_LOZONE,824
.equ arphy_LMSE,4
.p2align 4
.global md2asm_initialize_physics_field_dimensions
.type md2asm_initialize_physics_field_dimensions,%function
md2asm_initialize_physics_field_dimensions:
 cbz x0,.Lfd_bad_leaf
 cbz x1,.Lfd_bad_leaf
 mov x9,#262144
 cmp x1,x9
 b.hi .Lfd_bad_leaf
 adds x9,x0,x1
 b.cs .Lfd_bad_leaf
 cbz x2,.Lfd_bad_leaf
 cbz x3,.Lfd_bad_leaf
 orr x10,x2,x3
 tst x10,#7
 b.ne .Lfd_bad_leaf
 mrs x10,fpcr
 cbnz x10,.Lfd_bad_leaf
 sub sp,sp,#416
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x9
 mov x21,x2
 mov x22,x3
 mov x0,x21
 mov x1,x22
 mov x2,x19
 mov x3,x20
 bl .Lfd_preflight
 cbnz w0,.Lfd_bad
 ldr x23,[x21]
 ldr x24,[x21,#16]
 ldr x25,[x21,#32]
 ldr x26,[x21,#48]
 ldr x27,[x21,#64]
 ldr x28,[x21,#80]
 /* All consumed logical words use the canonical source0/1 representation. */
 adr x9,.Lfd_boolean_fields
 mov x10,#19
.Lfd_check_boolean:
 ldp w11,w12,[x9],#8
 ldr x13,[x21,x11]
 ldr w13,[x13,x12]
 cmp w13,#1
 b.hi .Lfd_bad
 subs x10,x10,#1
 b.ne .Lfd_check_boolean
 /* Parse only into private scratch before any public output mutation. */
 str xzr,[sp,#384]
 mov w9,#1
 str w9,[sp,#392]
 mov x0,x19
 mov x1,x20
 adr x2,.Lfd_group
 mov x3,#7
 adr x4,.Lfd_keys
 add x5,sp,#384
 bl md2asm_parse_bounded_scalar_group
 cbnz w0,.Lfd_bad
 /* The source ozone consistency guard applies to these selected defaults. */
 ldr w9,[x27,#phy_LOZONE]
 cbz w9,.Lfd_ozone_valid
 ldr w9,[x26,#ephy_LEO3CH]
 cbz w9,.Lfd_bad
.Lfd_ozone_valid:
 mov x9,#0
.Lfd_copy_dim:
 ldr x10,[x23,x9]
 add x11,sp,#112
 str x10,[x11,x9]
 add x9,x9,#8
 cmp x9,#176
 b.lo .Lfd_copy_dim
 mov x9,#0
.Lfd_copy_dphy:
 ldr x10,[x24,x9]
 add x11,sp,#288
 str x10,[x11,x9]
 add x9,x9,#8
 cmp x9,#88
 b.lo .Lfd_copy_dphy
 add x19,sp,#112
 add x20,sp,#288
 /* Ordered SUDIMF1 source defaults. NVEXTRDI is not assigned. */
 str wzr,[x20,#dphy_NVXP]
 str wzr,[x20,#dphy_NCXP]
 str wzr,[x20,#dphy_NVXP2]
 mov w9,#1
 str w9,[x20,#dphy_NVECOUT]
 str wzr,[x20,#dphy_NVEXTR]
 str wzr,[x20,#dphy_NVEXTRRAD]
 str wzr,[x20,#dphy_NVEXTRDYN]
 str wzr,[x20,#dphy_NVXTR2]
 str wzr,[x20,#dphy_NCEXTR]
 str wzr,[x20,#dphy_NTSSG]
 str wzr,[x20,#dphy_LTPROF]
 str wzr,[x20,#dphy_LDIRCLSMOD]
 mov w9,#4
 str w9,[x20,#dphy_NCSS]
 str wzr,[x20,#dphy_NTOZ3D]
 str wzr,[x20,#dphy_NTOZ2D]
 str wzr,[x20,#dphy_NTOZ1D]
 str wzr,[x20,#dphy_NVCLIS]
 ldr w9,[x26,#ephy_LEO3CH]
 cbz w9,.Lfd_ozone_done
 mov w9,#1
 str w9,[x20,#dphy_NTOZ2D]
 ldr w10,[x26,#ephy_LO3CH_BMS]
 ldr w11,[x26,#ephy_LO3CH_HLO]
 orr w10,w10,w11
 mov w9,#8
 sub w9,w9,w10
 str w9,[x20,#dphy_NVCLIS]
.Lfd_ozone_done:
 ldr w9,[sp,#392]
 str w9,[x20,#dphy_NCSNEC]
 str wzr,[x20,#dphy_NCSI]
 str wzr,[x20,#dphy_NTILES]
 str wzr,[x20,#dphy_NCOM]
 mov w9,#4
 str w9,[x20,#dphy_NCSI]
 mov w9,#8
 ldr w10,[x26,#ephy_LEFLAKE]
 add w9,w9,w10
 ldr w10,[x26,#ephy_LEURBAN]
 mov w11,#10
 cmp w10,#0
 csel w9,w11,w9,ne
 str w9,[x20,#dphy_NTILES]
 ldr w9,[x26,#ephy_LEOCML]
 cbz w9,.Lfd_ocean_tke
 mov w9,#35
 str w9,[x20,#dphy_NCOM]
.Lfd_ocean_tke:
 ldr w9,[x26,#ephy_LOCMLTKE]
 cbz w9,.Lfd_ocean_done
 mov w9,#9
 str w9,[x20,#dphy_NCOM]
.Lfd_ocean_done:
 mov w9,#1
 str w9,[x19,#dimf_NFC2D]
 str w9,[x19,#dimf_LSPT]
 str w9,[x19,#dimf_LADER]
 ldr w10,[x25,#dyna_LSLAG]
 cbz w10,.Lfd_derivative_ready
 ldr w9,[x25,#dyna_LSLHD]
 ldr w11,[x25,#dyna_LSLHD_STATIC]
 bic w9,w9,w11
 ldr w11,[x25,#dyna_LNHDYN]
 orr w9,w9,w11
 ldr w11,[x25,#dyna_L3DTURB]
 orr w9,w9,w11
 ldr w11,[x25,#dyna_LCOMAD]
 orr w9,w9,w11
 ldr w11,[x26,#ephy_LDIAGTURB_EC]
 ldr w12,[x26,#ephy_LDIAGTURBGRAD_EC]
 and w11,w11,w12
 orr w9,w9,w11
.Lfd_derivative_ready:
 str w9,[x19,#dimf_LUVDER]
 ldr w9,[x25,#dyna_LNHDYN]
 cbnz w9,.Lfd_vorticity_ready
 ldr w9,[x25,#dyna_LSLHD]
 and w9,w9,w10
 eor w10,w10,#1
 orr w9,w9,w10
.Lfd_vorticity_ready:
 str w9,[x19,#dimf_LVOR]
 mov x9,#0
.Lfd_commit_dim:
 ldr x10,[x19,x9]
 str x10,[x23,x9]
 add x9,x9,#8
 cmp x9,#176
 b.lo .Lfd_commit_dim
 mov x9,#0
.Lfd_commit_dphy:
 ldr x10,[x20,x9]
 str x10,[x24,x9]
 add x9,x9,#8
 cmp x9,#88
 b.lo .Lfd_commit_dphy
 mov w0,#0
 b .Lfd_return
.Lfd_bad:
 mov w0,#2
.Lfd_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#416
 ret
.Lfd_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_physics_field_dimensions,.-md2asm_initialize_physics_field_dimensions
/* Trusted table schema, complete mapped buffers and all ranges before parsing. */
.Lfd_preflight:
 adds x4,x0,#96
 b.cs .Lfd_bad_leaf
 adds x5,x1,#40
 b.cs .Lfd_bad_leaf
 adr x6,.Lfd_controls
 mov x7,#0
.Lfd_control:
 ldr w8,[x1,x7]
 ldr w9,[x6,x7]
 cmp w8,w9
 b.ne .Lfd_bad_leaf
 add x7,x7,#4
 cmp x7,#40
 b.lo .Lfd_control
 adr x6,.Lfd_sizes
 mov x7,#0
.Lfd_range:
 ldr x8,[x0,x7]
 cbz x8,.Lfd_bad_leaf
 tst x8,#7
 b.ne .Lfd_bad_leaf
 ldr x9,[x6,x7]
 add x17,x0,x7
 ldr x10,[x17,#8]
 cmp x10,x9
 b.lo .Lfd_bad_leaf
 adds x9,x8,x9
 b.cs .Lfd_bad_leaf
 cmp x7,#32
 b.hs .Lfd_pairs
 cmp x8,x3
 b.hs .Lfd_output_text_clear
 cmp x2,x9
 b.lo .Lfd_bad_leaf
.Lfd_output_text_clear:
 cmp x8,x4
 b.hs .Lfd_output_table_clear
 cmp x0,x9
 b.lo .Lfd_bad_leaf
.Lfd_output_table_clear:
 cmp x8,x5
 b.hs .Lfd_pairs
 cmp x1,x9
 b.lo .Lfd_bad_leaf
.Lfd_pairs:
 mov x10,#0
.Lfd_pair_loop:
 cmp x10,x7
 b.hs .Lfd_range_next
 ldr x11,[x0,x10]
 ldr x12,[x6,x10]
 add x12,x11,x12
 cmp x8,x12
 b.hs .Lfd_pair_next
 cmp x11,x9
 b.lo .Lfd_bad_leaf
.Lfd_pair_next:
 add x10,x10,#16
 b .Lfd_pair_loop
.Lfd_range_next:
 add x7,x7,#16
 cmp x7,#96
 b.lo .Lfd_range
 mov w0,#0
 ret
/* x0 TDIMF176,x1 TDYNA456,x2 int32 NUMSPFLDS,x3 selected controls40. */
.p2align 4
.global md2asm_initialize_spectral_field_dimensions
.type md2asm_initialize_spectral_field_dimensions,%function
md2asm_initialize_spectral_field_dimensions:
 cbz x0,.Lfd_bad_leaf
 cbz x1,.Lfd_bad_leaf
 cbz x2,.Lfd_bad_leaf
 cbz x3,.Lfd_bad_leaf
 orr x4,x0,x1
 orr x4,x4,x3
 tst x4,#7
 b.ne .Lfd_bad_leaf
 tst x2,#3
 b.ne .Lfd_bad_leaf
 adds x4,x0,#176
 b.cs .Lfd_bad_leaf
 adds x5,x1,#456
 b.cs .Lfd_bad_leaf
 adds x6,x2,#4
 b.cs .Lfd_bad_leaf
 adds x7,x3,#40
 b.cs .Lfd_bad_leaf
 cmp x0,x5
 b.hs .Lfd2_dyna_disjoint
 cmp x1,x4
 b.lo .Lfd_bad_leaf
.Lfd2_dyna_disjoint:
 cmp x0,x6
 b.hs .Lfd2_num_disjoint
 cmp x2,x4
 b.lo .Lfd_bad_leaf
.Lfd2_num_disjoint:
 cmp x0,x7
 b.hs .Lfd2_control_disjoint
 cmp x3,x4
 b.lo .Lfd_bad_leaf
.Lfd2_control_disjoint:
 adr x4,.Lfd_controls
 mov x5,#0
.Lfd2_controls:
 ldr w6,[x3,x5]
 ldr w7,[x4,x5]
 cmp w6,w7
 b.ne .Lfd_bad_leaf
 add x5,x5,#4
 cmp x5,#40
 b.lo .Lfd2_controls
 mrs x4,fpcr
 cbnz x4,.Lfd_bad_leaf
 ldr w4,[x2]
 cmp w4,#255
 b.hi .Lfd_bad_leaf
 ldr w5,[x1,#dyna_LNHDYN]
 cmp w5,#1
 b.hi .Lfd_bad_leaf
 ldr w6,[x1,#dyna_LNHX]
 cmp w6,#1
 b.hi .Lfd_bad_leaf
 ldr w7,[x1,#dyna_LRUBC]
 cmp w7,#1
 b.hi .Lfd_bad_leaf
 ldr w8,[x0,#dimf_LSPT]
 cmp w8,#1
 b.hi .Lfd_bad_leaf
 ldr w9,[x0,#dimf_LADER]
 cmp w9,#1
 b.hi .Lfd_bad_leaf
 ldr w10,[x0,#dimf_NFC2D]
 cmp w10,#1
 b.ne .Lfd_bad_leaf
 /* All validation is complete. Retain the ordered source count updates. */
 add w7,w7,#1
 str w7,[x0,#dimf_NFD2D]
 mov w11,#0
 cbz w8,.Lfd2_no_temperature
 add w11,w11,#1
.Lfd2_no_temperature:
 cbz w5,.Lfd2_hydrostatic
 add w11,w11,#2
 cbz w6,.Lfd2_hydrostatic
 add w11,w11,#1
.Lfd2_hydrostatic:
 str w11,[x0,#dimf_NFTHER]
 add w12,w11,#2
 add w12,w12,w4
 str w12,[x0,#dimf_NF3D]
 cbnz w9,.Lfd2_derivative_kept
 str wzr,[x0,#dimf_LUVDER]
.Lfd2_derivative_kept:
 str w12,[x0,#dimf_NS3D]
 add w7,w7,w10
 str w7,[x0,#dimf_NS2D]
 mov w7,#2
 str w7,[x0,#dimf_NS1D]
 mov w0,#0
 ret
.size md2asm_initialize_spectral_field_dimensions,.-md2asm_initialize_spectral_field_dimensions
.section .rodata
.p2align 3
.Lfd_sizes: .quad 176,0,88,0,456,0,448,0,1096,0,88,0
.Lfd_controls: .word 1,1,1,0,0,0,0,0,20,50
.Lfd_boolean_fields:
 .word 32,dyna_LSLAG,32,dyna_LNHDYN,32,dyna_LSLHD,32,dyna_LSLHD_STATIC
 .word 32,dyna_L3DTURB,32,dyna_LCOMAD,32,dyna_LNHX,32,dyna_LRUBC
 .word 48,ephy_LEFLAKE,48,ephy_LEURBAN,48,ephy_LEO3CH,48,ephy_LEOCML
 .word 48,ephy_LO3CH_BMS,48,ephy_LO3CH_HLO,48,ephy_LOCMLTKE
 .word 48,ephy_LDIAGTURB_EC,48,ephy_LDIAGTURBGRAD_EC
 .word 64,phy_LOZONE,80,arphy_LMSE
.Lfd_group: .ascii "NAMDPHY"
.p2align 3
.Lfd_keys:
 .word 6,1,0,0,0,0
 .ascii "NVEXTR"
 .zero 10
 .word 6,1,4,0,0,0
 .ascii "NCEXTR"
 .zero 10
 .word 6,1,8,1,16,0
 .ascii "NCSNEC"
 .zero 10
 .zero 40
.section .note.GNU-stack,"",%progbits

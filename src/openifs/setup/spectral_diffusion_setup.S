/* Complete selected SUDYN/SUHDIR/SUALDYNB/SUHDF_EC setup.
 * Contract: skills/md2asm/references/openifs/setup/spectral_diffusion_setup.md.
 * Inputs are live owned records. No original OpenIFS callable or state. */
.arch armv8.2-a
.text
.macro address out,base,offset
 movz \out,#(\offset & 65535)
 movk \out,#((\offset >> 16) & 65535),lsl#16
 add \out,\base,\out
.endm
.equ M_HDIRVOR,1564632
.equ M_HDIRDIV,1564640
.equ M_HDIRT,1564648
.equ M_HDIRQ,1564656
.equ M_HDIRO3,1564664
.equ M_HDIRPD,1564672
.equ M_HDIRVD,1564680
.equ M_HDIRSP,1564688
.equ M_HRDIRVOR,1564696
.equ M_HRDIRDIV,1564704
.equ M_HRDIRT,1564712
.equ M_HRDIRQ,1564720
.equ M_HRDIRO3,1564728
.equ M_HRDIRPD,1564736
.equ M_HRDIRVD,1564744
.equ M_HRDIRSP,1564752
.equ M_RRDXTAU,1564760
.equ M_RDAMPVOR,1564768
.equ M_RDAMPDIV,1564776
.equ M_RDAMPT,1564784
.equ M_RDAMPQ,1564792
.equ M_RDAMPO3,1564800
.equ M_RDAMPPD,1564808
.equ M_RDAMPVD,1564816
.equ M_RDAMPSP,1564824
.equ M_LNEWHD,1564832
.equ M_REXPDH,1564840
.equ M_FRANDH,1564848
.equ M_SLEVDH,1564856
.equ M_SLEVDH1,1564864
.equ M_SLEVDH2,1564872
.equ M_SLEVDH3,1564880
.equ M_NSREFDH,1564888
.equ M_RATIO_HDI_TOP,1564896
.equ M_NPROFILEHD,1564904
.equ M_RPROFHDBT,1564912
.equ M_RPROFHDTP,1564920
.equ M_RPROFHDMX,1564928
.equ M_RPROFHDEX,1564936
.equ M_LRDISPE_EC,1564944
.equ M_RDIVOR,1564952
.equ M_RDIDIV,1565040
.equ M_RDITG,1565128
.equ M_RDIGFL,1565216
.equ M_RDISP,1565504
.equ M_KLSPONGE,1565696
.equ M_LM0DAMP,1565704
.equ M_RBEGSPONGE,1565712
.equ M_LTOP_VOR,1565720
.equ M_NTOP_VOR_TRUNC,1565724
.equ M_NTOP_VOR_BOT,1565728
.equ M_SLHDA0,1565936
.equ M_SLHDA0T,1565944
.equ M_SLHDB,1565952
.equ M_SLHDBT,1565960
.equ M_SLHDD00,1566032
.equ M_SLHDD00T,1566040
.equ M_SLHDDIV,1566048
.equ M_SLHDRATDDIV,1566056
.equ M_SLHDHOR,1566064
.equ M_SLHD_P_LOW,1566072
.equ M_SLHD_P_HIGH,1566080
.equ M_LSLHDHEAT,1566088
.equ M_LSLHDSPONGE,1566092
.equ M_HDSRVOR,1566096
.equ M_HDSRDIV,1566104
.equ M_HDSRVD,1566112
.equ M_HRDSRVOR,1566120
.equ M_HRDSRDIV,1566128
.equ M_HRDSRVD,1566136
.equ M_RDAMPVORS,1566144
.equ M_RDAMPDIVS,1566152
.equ M_RDAMPVDS,1566160
.equ M_RDAMPHDS,1566168
.equ M_REXPDHS,1566176
.equ M_SLEVDHS,1566184
.equ M_SLEVDHS1,1566192
.equ M_SLEVDHS2,1566200
.equ M_SDRED,1566208
.equ M_LHDIFFM,1569120
.equ M_LSPECVIS,1569124
.equ M_NDIFFACT,1569128
.equ M_LGPSTRESS,1569132
.equ M_RCLSTRESS,1569136
.equ M_RCLPOLE,1569144
.equ M_LNHDYN,1564144
.equ M_LSLAG,1564160
.equ M_LSLHD,1564212
.equ M_LSLHD_W,1564216
.equ M_LSLHD_T,1564220
.equ M_LSLHD_SPD,1564224
.equ M_LSLHD_SVD,1564228
.equ M_LSLHD_STATIC,1564240
.equ G_NFLEVG,5224
.equ G_NFLEVL,5228
.equ G_NSMAX,5172
.equ G_NDGLG,4872
.equ G_NDLON,4936
.equ G_YRVERT_GEOM,8
.equ G_NUMSPFLDS,200
.equ G_GFL_LSP,56
.equ G_YQ_NL_LSLHD,801672
.equ G_YO3_NL_LSLHD,806536
.equ G_YQ_NL,801536
.equ G_YO3_NL,806400
.equ G_TSTEP,1359528
.equ G_YQ_pointer,800032
.equ G_YO3_pointer,800184
.equ G_YRVAB_pointer,3240
.equ G_MYLEVS,5960
/* Validate all common input records before mutation or allocation. */
.p2align 4
.Lsd_validate:
 cbz x0,.Lsd_invalid
 cbz x2,.Lsd_invalid
 tst x0,#7
 b.ne .Lsd_invalid
 tst x2,#7
 b.ne .Lsd_invalid
 mov x8,#17096
 cmp x1,x8
 b.lo .Lsd_invalid
 movz x8,#15248
 movk x8,#65,lsl#16
 cmp x3,x8
 b.lo .Lsd_invalid
 adds x9,x0,#4,lsl#12
 b.cs .Lsd_invalid
 adds x9,x9,#712
 b.cs .Lsd_invalid
 adds x10,x2,x8
 b.cs .Lsd_invalid
 cmp x0,x10
 b.hs .Lsd_records_disjoint
 cmp x2,x9
 b.lo .Lsd_invalid
.Lsd_records_disjoint:
 mrs x8,fpcr
 cbnz x8,.Lsd_invalid
 ldr w8,[x0,#G_NFLEVG]
 cmp w8,#2
 b.lo .Lsd_invalid
 cmp w8,#59
 b.hi .Lsd_invalid
 ldr w9,[x0,#G_NFLEVL]
 cmp w9,w8
 b.ne .Lsd_invalid
 ldr w9,[x0,#G_NSMAX]
 cmp w9,#21
 b.lo .Lsd_invalid
 cmp w9,#255
 b.hi .Lsd_invalid
 ldr w10,[x0,#G_NDGLG]
 add w11,w9,#1
 cmp w10,w11
 b.le .Lsd_invalid
 cmp w10,#1024
 b.hi .Lsd_invalid
 ldr w10,[x0,#G_NDLON]
 cmp w10,#1
 b.lt .Lsd_invalid
 ldr w10,[x2,#200]
 cbnz w10,.Lsd_invalid
 address x10,x2,1564144
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564212
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564216
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564220
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564228
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564224
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564240
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,1564160
 ldr w11,[x10]
 cmp w11,#1
 b.ne .Lsd_invalid
 address x10,x2,801672
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,806536
 ldr w11,[x10]
 cbnz w11,.Lsd_invalid
 address x10,x2,800032
 ldr x10,[x10]
 cmp x10,x2
 b.lo .Lsd_invalid
 adds x11,x10,#60
 b.cs .Lsd_invalid
 cmp x11,x10
 b.lo .Lsd_invalid
 movz x12,#15248
 movk x12,#65,lsl#16
 add x12,x2,x12
 cmp x11,x12
 b.hi .Lsd_invalid
 ldr w11,[x10,#56]
 cbnz w11,.Lsd_invalid
 address x10,x2,800184
 ldr x10,[x10]
 cmp x10,x2
 b.lo .Lsd_invalid
 adds x11,x10,#60
 b.cs .Lsd_invalid
 cmp x11,x10
 b.lo .Lsd_invalid
 movz x12,#15248
 movk x12,#65,lsl#16
 add x12,x2,x12
 cmp x11,x12
 b.hi .Lsd_invalid
 ldr w11,[x10,#56]
 cbnz w11,.Lsd_invalid
 /* Live full-level mapping, with a contiguous int32 descriptor. */
 address x10,x0,G_MYLEVS
 ldr x11,[x10]
 cbz x11,.Lsd_invalid
 tst x11,#3
 b.ne .Lsd_invalid
 ldr x12,[x10,#16]
 cmp x12,#4
 b.ne .Lsd_invalid
 ldr x12,[x10,#40]
 cmp x12,#1
 b.ne .Lsd_invalid
 ldr x12,[x10,#48]
 cmp x12,#1
 b.ne .Lsd_invalid
 ldr x12,[x10,#56]
 cmp w12,w8
 b.ne .Lsd_invalid
 mov x12,#0
.Lsd_map_check:
 ldr w13,[x11,x12,lsl#2]
 cmp w13,#1
 b.lt .Lsd_invalid
 cmp w13,w8
 b.gt .Lsd_invalid
 add x12,x12,#1
 cmp w12,w8
 b.lo .Lsd_map_check
 /* The nonmesosphere branch has VAH(1)>21 Pa. */
 ldr x10,[x0,#G_YRVAB_pointer]
 cbz x10,.Lsd_invalid
 tst x10,#7
 b.ne .Lsd_invalid
 ldr x11,[x10,#128]
 cbz x11,.Lsd_invalid
 tst x11,#7
 b.ne .Lsd_invalid
 ldr x12,[x10,#144]
 cmp x12,#8
 b.ne .Lsd_invalid
 ldr x12,[x10,#168]
 cmp x12,#1
 b.ne .Lsd_invalid
 ldr x12,[x10,#176]
 cbnz x12,.Lsd_invalid
 ldr x12,[x10,#184]
 cmp w12,w8
 b.ne .Lsd_invalid
 ldr x12,[x11,#8]
 ubfx x13,x12,#52,#11
 cmp x13,#2047
 b.eq .Lsd_invalid
 fmov d0,x12
 fmov d1,#21.0
 fcmp d0,d1
 b.le .Lsd_invalid
 mov w0,#0
 ret
.Lsd_invalid:
 mov w0,#2
 ret
/* The constants are RHOUR, VP00 and RPLRADI, in that order. */
.Lsd_constants:
 cbz x4,.Lsd_invalid
 tst x4,#7
 b.ne .Lsd_invalid
 cmp x5,#24
 b.lo .Lsd_invalid
 adds x8,x4,#24
 b.cs .Lsd_invalid
 mov x9,#17096
 add x9,x19,x9
 cmp x4,x9
 b.hs .Lsd_constants_after_geometry
 cmp x19,x8
 b.lo .Lsd_invalid
.Lsd_constants_after_geometry:
 movz x9,#15248
 movk x9,#65,lsl#16
 add x9,x20,x9
 cmp x4,x9
 b.hs .Lsd_constants_after_model
 cmp x20,x8
 b.lo .Lsd_invalid
.Lsd_constants_after_model:
 mov x9,#0
.Lsd_constant_loop:
 ldr x10,[x4,x9]
 tbnz x10,#63,.Lsd_invalid
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lsd_invalid
 cbz x10,.Lsd_invalid
 add x9,x9,#8
 cmp x9,#24
 b.lo .Lsd_constant_loop
 mov w0,#0
 ret

.p2align 4
.global md2asm_initialize_spectral_diffusion_controls
.type md2asm_initialize_spectral_diffusion_controls,%function
md2asm_initialize_spectral_diffusion_controls:
 stp x29,x30,[sp,#-80]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x5
 bl .Lsd_validate
 cbnz w0,.Lsd_controls_return
 mov x4,x21
 mov x5,x22
 bl .Lsd_constants
 cbnz w0,.Lsd_controls_return
 address x8,x20,1564832
 adrp x9,.Lsd_cv_0
 ldr w10,[x9,:lo12:.Lsd_cv_0]
 str w10,[x8]
 address x8,x20,1564840
 adrp x9,.Lsd_cv_1
 ldr x10,[x9,:lo12:.Lsd_cv_1]
 str x10,[x8]
 address x8,x20,1564848
 adrp x9,.Lsd_cv_2
 ldr x10,[x9,:lo12:.Lsd_cv_2]
 str x10,[x8]
 address x8,x20,1564760
 adrp x9,.Lsd_cv_3
 ldr x10,[x9,:lo12:.Lsd_cv_3]
 str x10,[x8]
 address x8,x20,1564776
 adrp x9,.Lsd_cv_4
 ldr x10,[x9,:lo12:.Lsd_cv_4]
 str x10,[x8]
 address x8,x20,1564768
 adrp x9,.Lsd_cv_5
 ldr x10,[x9,:lo12:.Lsd_cv_5]
 str x10,[x8]
 address x8,x20,1564784
 adrp x9,.Lsd_cv_6
 ldr x10,[x9,:lo12:.Lsd_cv_6]
 str x10,[x8]
 address x8,x20,1564792
 adrp x9,.Lsd_cv_7
 ldr x10,[x9,:lo12:.Lsd_cv_7]
 str x10,[x8]
 address x8,x20,1564824
 adrp x9,.Lsd_cv_8
 ldr x10,[x9,:lo12:.Lsd_cv_8]
 str x10,[x8]
 address x8,x20,1564800
 adrp x9,.Lsd_cv_9
 ldr x10,[x9,:lo12:.Lsd_cv_9]
 str x10,[x8]
 address x8,x20,1564816
 adrp x9,.Lsd_cv_10
 ldr x10,[x9,:lo12:.Lsd_cv_10]
 str x10,[x8]
 address x8,x20,1564808
 adrp x9,.Lsd_cv_11
 ldr x10,[x9,:lo12:.Lsd_cv_11]
 str x10,[x8]
 address x8,x20,1564904
 adrp x9,.Lsd_cv_12
 ldr w10,[x9,:lo12:.Lsd_cv_12]
 str w10,[x8]
 address x8,x20,1564944
 adrp x9,.Lsd_cv_13
 ldr w10,[x9,:lo12:.Lsd_cv_13]
 str w10,[x8]
 address x8,x20,1564632
 adrp x9,.Lsd_cv_14
 ldr x10,[x9,:lo12:.Lsd_cv_14]
 str x10,[x8]
 address x8,x20,1564640
 adrp x9,.Lsd_cv_15
 ldr x10,[x9,:lo12:.Lsd_cv_15]
 str x10,[x8]
 address x8,x20,1564648
 adrp x9,.Lsd_cv_16
 ldr x10,[x9,:lo12:.Lsd_cv_16]
 str x10,[x8]
 address x8,x20,1564656
 adrp x9,.Lsd_cv_17
 ldr x10,[x9,:lo12:.Lsd_cv_17]
 str x10,[x8]
 address x8,x20,1564664
 adrp x9,.Lsd_cv_18
 ldr x10,[x9,:lo12:.Lsd_cv_18]
 str x10,[x8]
 address x8,x20,1564688
 adrp x9,.Lsd_cv_19
 ldr x10,[x9,:lo12:.Lsd_cv_19]
 str x10,[x8]
 address x8,x20,1564672
 adrp x9,.Lsd_cv_20
 ldr x10,[x9,:lo12:.Lsd_cv_20]
 str x10,[x8]
 address x8,x20,1564680
 adrp x9,.Lsd_cv_21
 ldr x10,[x9,:lo12:.Lsd_cv_21]
 str x10,[x8]
 address x8,x20,1564856
 adrp x9,.Lsd_cv_22
 ldr x10,[x9,:lo12:.Lsd_cv_22]
 str x10,[x8]
 address x8,x20,1564864
 adrp x9,.Lsd_cv_23
 ldr x10,[x9,:lo12:.Lsd_cv_23]
 str x10,[x8]
 address x8,x20,1564872
 adrp x9,.Lsd_cv_24
 ldr x10,[x9,:lo12:.Lsd_cv_24]
 str x10,[x8]
 address x8,x20,1564896
 adrp x9,.Lsd_cv_25
 ldr x10,[x9,:lo12:.Lsd_cv_25]
 str x10,[x8]
 address x8,x20,1564912
 adrp x9,.Lsd_cv_26
 ldr x10,[x9,:lo12:.Lsd_cv_26]
 str x10,[x8]
 address x8,x20,1564920
 adrp x9,.Lsd_cv_27
 ldr x10,[x9,:lo12:.Lsd_cv_27]
 str x10,[x8]
 address x8,x20,1564928
 adrp x9,.Lsd_cv_28
 ldr x10,[x9,:lo12:.Lsd_cv_28]
 str x10,[x8]
 address x8,x20,1564936
 adrp x9,.Lsd_cv_29
 ldr x10,[x9,:lo12:.Lsd_cv_29]
 str x10,[x8]
 address x8,x20,1566152
 adrp x9,.Lsd_cv_30
 ldr x10,[x9,:lo12:.Lsd_cv_30]
 str x10,[x8]
 address x8,x20,1566144
 adrp x9,.Lsd_cv_31
 ldr x10,[x9,:lo12:.Lsd_cv_31]
 str x10,[x8]
 address x8,x20,1566160
 adrp x9,.Lsd_cv_32
 ldr x10,[x9,:lo12:.Lsd_cv_32]
 str x10,[x8]
 address x8,x20,1566168
 adrp x9,.Lsd_cv_33
 ldr x10,[x9,:lo12:.Lsd_cv_33]
 str x10,[x8]
 address x8,x20,1565936
 adrp x9,.Lsd_cv_34
 ldr x10,[x9,:lo12:.Lsd_cv_34]
 str x10,[x8]
 address x8,x20,1565944
 adrp x9,.Lsd_cv_35
 ldr x10,[x9,:lo12:.Lsd_cv_35]
 str x10,[x8]
 address x8,x20,1565952
 adrp x9,.Lsd_cv_36
 ldr x10,[x9,:lo12:.Lsd_cv_36]
 str x10,[x8]
 address x8,x20,1565960
 adrp x9,.Lsd_cv_37
 ldr x10,[x9,:lo12:.Lsd_cv_37]
 str x10,[x8]
 address x8,x20,1566032
 adrp x9,.Lsd_cv_38
 ldr x10,[x9,:lo12:.Lsd_cv_38]
 str x10,[x8]
 address x8,x20,1566040
 adrp x9,.Lsd_cv_39
 ldr x10,[x9,:lo12:.Lsd_cv_39]
 str x10,[x8]
 address x8,x20,1566048
 adrp x9,.Lsd_cv_40
 ldr x10,[x9,:lo12:.Lsd_cv_40]
 str x10,[x8]
 address x8,x20,1566056
 adrp x9,.Lsd_cv_41
 ldr x10,[x9,:lo12:.Lsd_cv_41]
 str x10,[x8]
 address x8,x20,1566064
 adrp x9,.Lsd_cv_42
 ldr x10,[x9,:lo12:.Lsd_cv_42]
 str x10,[x8]
 address x8,x20,1566072
 adrp x9,.Lsd_cv_43
 ldr x10,[x9,:lo12:.Lsd_cv_43]
 str x10,[x8]
 address x8,x20,1566080
 adrp x9,.Lsd_cv_44
 ldr x10,[x9,:lo12:.Lsd_cv_44]
 str x10,[x8]
 address x8,x20,1566176
 adrp x9,.Lsd_cv_45
 ldr x10,[x9,:lo12:.Lsd_cv_45]
 str x10,[x8]
 address x8,x20,1566184
 adrp x9,.Lsd_cv_46
 ldr x10,[x9,:lo12:.Lsd_cv_46]
 str x10,[x8]
 address x8,x20,1566192
 adrp x9,.Lsd_cv_47
 ldr x10,[x9,:lo12:.Lsd_cv_47]
 str x10,[x8]
 address x8,x20,1566200
 adrp x9,.Lsd_cv_48
 ldr x10,[x9,:lo12:.Lsd_cv_48]
 str x10,[x8]
 address x8,x20,1566208
 adrp x9,.Lsd_cv_49
 ldr x10,[x9,:lo12:.Lsd_cv_49]
 str x10,[x8]
 address x8,x20,1566088
 adrp x9,.Lsd_cv_50
 ldr w10,[x9,:lo12:.Lsd_cv_50]
 str w10,[x8]
 address x8,x20,1566092
 adrp x9,.Lsd_cv_51
 ldr w10,[x9,:lo12:.Lsd_cv_51]
 str w10,[x8]
 address x8,x20,1566096
 adrp x9,.Lsd_cv_52
 ldr x10,[x9,:lo12:.Lsd_cv_52]
 str x10,[x8]
 address x8,x20,1566104
 adrp x9,.Lsd_cv_53
 ldr x10,[x9,:lo12:.Lsd_cv_53]
 str x10,[x8]
 address x8,x20,1566112
 adrp x9,.Lsd_cv_54
 ldr x10,[x9,:lo12:.Lsd_cv_54]
 str x10,[x8]
 address x8,x20,1566120
 adrp x9,.Lsd_cv_55
 ldr x10,[x9,:lo12:.Lsd_cv_55]
 str x10,[x8]
 address x8,x20,1566128
 adrp x9,.Lsd_cv_56
 ldr x10,[x9,:lo12:.Lsd_cv_56]
 str x10,[x8]
 address x8,x20,1566136
 adrp x9,.Lsd_cv_57
 ldr x10,[x9,:lo12:.Lsd_cv_57]
 str x10,[x8]
 address x8,x20,1569120
 adrp x9,.Lsd_cv_58
 ldr w10,[x9,:lo12:.Lsd_cv_58]
 str w10,[x8]
 address x8,x20,1569124
 adrp x9,.Lsd_cv_59
 ldr w10,[x9,:lo12:.Lsd_cv_59]
 str w10,[x8]
 address x8,x20,1569128
 adrp x9,.Lsd_cv_60
 ldr w10,[x9,:lo12:.Lsd_cv_60]
 str w10,[x8]
 address x8,x20,1569132
 adrp x9,.Lsd_cv_61
 ldr w10,[x9,:lo12:.Lsd_cv_61]
 str w10,[x8]
 address x8,x20,1569136
 adrp x9,.Lsd_cv_62
 ldr x10,[x9,:lo12:.Lsd_cv_62]
 str x10,[x8]
 address x8,x20,1569144
 adrp x9,.Lsd_cv_63
 ldr x10,[x9,:lo12:.Lsd_cv_63]
 str x10,[x8]
 address x8,x20,1565724
 adrp x9,.Lsd_cv_64
 ldr w10,[x9,:lo12:.Lsd_cv_64]
 str w10,[x8]
 address x8,x20,1565728
 adrp x9,.Lsd_cv_65
 ldr w10,[x9,:lo12:.Lsd_cv_65]
 str w10,[x8]
 address x8,x20,1565704
 adrp x9,.Lsd_cv_66
 ldr w10,[x9,:lo12:.Lsd_cv_66]
 str w10,[x8]
 address x8,x20,1565712
 adrp x9,.Lsd_cv_67
 ldr x10,[x9,:lo12:.Lsd_cv_67]
 str x10,[x8]
 address x8,x20,1565720
 adrp x9,.Lsd_cv_68
 ldr w10,[x9,:lo12:.Lsd_cv_68]
 str w10,[x8]
 address x8,x20,1565696
 adrp x9,.Lsd_cv_69
 ldr x10,[x9,:lo12:.Lsd_cv_69]
 str x10,[x8]
 ldr w8,[x19,#G_NSMAX]
 address x9,x20,1564888
 str w8,[x9]
 mov x8,#100
 scvtf d0,x8
 ldr d1,[x21,#8]
 fdiv d0,d0,d1
 address x9,x20,1564880
 str d0,[x9]
 /* Source SUHDIR old-style resolution thresholds. */
 ldr w8,[x19,#G_NSMAX]
 adrp x9,.Lsd_resolution_table
 add x9,x9,:lo12:.Lsd_resolution_table
 mov w10,#0
.Lsd_resolution_loop:
 add x11,x9,x10,lsl#4
 ldr w11,[x11]
 cmp w8,w11
 b.ge .Lsd_resolution_found
 add w10,w10,#1
 b .Lsd_resolution_loop
.Lsd_resolution_found:
 add x9,x9,x10,lsl#4
 ldr d0,[x9,#8]
 /* Source division by RDAMPVOR, NINT and conversion remain ordered. */
 fmov d1,#1.0
 fdiv d1,d0,d1
 fcvtas x8,d0
 scvtf d0,x8
 fcvtas x8,d1
 scvtf d1,x8
 ldr d2,[x21,#16]
 fmul d1,d1,d2
 fmul d0,d0,d2
 address x8,x20,1564640
 str d1,[x8]
 address x8,x20,1564632
 str d0,[x8]
 address x8,x20,1564648
 str d0,[x8]
 address x8,x20,1564656
 str d0,[x8]
 address x8,x20,1564688
 str xzr,[x8]
 address x8,x20,1564664
 str xzr,[x8]
 address x8,x20,1564672
 str xzr,[x8]
 address x8,x20,1564680
 str xzr,[x8]
 address x8,x20,1564864
 fmov d0,#1.0
 str d0,[x8]
 address x8,x20,1564872
 fmov d0,#1.0
 str d0,[x8]
 address x8,x20,1566192
 fmov d0,#0.25
 str d0,[x8]
 address x8,x20,1566200
 fmov d0,#0.25
 str d0,[x8]
 address x8,x20,1564632
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_VOR
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_VOR
.Lsd_recip_zero_VOR:
 fmov d0,xzr
.Lsd_recip_store_VOR:
 address x8,x20,1564696
 str d0,[x8]
 address x8,x20,1564640
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_DIV
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_DIV
.Lsd_recip_zero_DIV:
 fmov d0,xzr
.Lsd_recip_store_DIV:
 address x8,x20,1564704
 str d0,[x8]
 address x8,x20,1564648
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_T
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_T
.Lsd_recip_zero_T:
 fmov d0,xzr
.Lsd_recip_store_T:
 address x8,x20,1564712
 str d0,[x8]
 address x8,x20,1564656
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_Q
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_Q
.Lsd_recip_zero_Q:
 fmov d0,xzr
.Lsd_recip_store_Q:
 address x8,x20,1564720
 str d0,[x8]
 address x8,x20,1564664
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_O3
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_O3
.Lsd_recip_zero_O3:
 fmov d0,xzr
.Lsd_recip_store_O3:
 address x8,x20,1564728
 str d0,[x8]
 address x8,x20,1564688
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_SP
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_SP
.Lsd_recip_zero_SP:
 fmov d0,xzr
.Lsd_recip_store_SP:
 address x8,x20,1564752
 str d0,[x8]
 address x8,x20,1564680
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_VD
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_VD
.Lsd_recip_zero_VD:
 fmov d0,xzr
.Lsd_recip_store_VD:
 address x8,x20,1564744
 str d0,[x8]
 address x8,x20,1564672
 ldr d0,[x8]
 fcmp d0,#0.0
 b.eq .Lsd_recip_zero_PD
 fmov d1,#1.0
 fdiv d0,d1,d0
 b .Lsd_recip_store_PD
.Lsd_recip_zero_PD:
 fmov d0,xzr
.Lsd_recip_store_PD:
 address x8,x20,1564736
 str d0,[x8]
 mov w0,#0
.Lsd_controls_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp],#80
 ret
.size md2asm_initialize_spectral_diffusion_controls,.-md2asm_initialize_spectral_diffusion_controls

.p2align 4
.global md2asm_allocate_spectral_diffusion_storage
.type md2asm_allocate_spectral_diffusion_storage,%function
md2asm_allocate_spectral_diffusion_storage:
 stp x29,x30,[sp,#-192]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 bl .Lsd_validate
 cbnz w0,.Lsd_alloc_return
 address x8,x20,1564952
 ldr x9,[x8]
 cbnz x9,.Lsd_alloc_bad
 address x8,x20,1565040
 ldr x9,[x8]
 cbnz x9,.Lsd_alloc_bad
 address x8,x20,1565128
 ldr x9,[x8]
 cbnz x9,.Lsd_alloc_bad
 address x8,x20,1565216
 ldr x9,[x8]
 cbnz x9,.Lsd_alloc_bad
 address x8,x20,1565504
 ldr x9,[x8]
 cbnz x9,.Lsd_alloc_bad
 ldr w21,[x19,#G_NFLEVG]
 ldr w22,[x19,#G_NSMAX]
 add x22,x22,#1
 mul x23,x21,x22
 lsl x23,x23,#3
 stp xzr,xzr,[sp,#96]
 stp xzr,xzr,[sp,#112]
 str xzr,[sp,#128]
 mov w24,#0
.Lsd_allocate_loop:
 cmp w24,#3
 b.eq .Lsd_alloc_empty
 cmp w24,#4
 b.eq .Lsd_alloc_surface
 mov x0,x23
 b .Lsd_alloc_call
.Lsd_alloc_empty:
 mov x0,#1
 b .Lsd_alloc_call
.Lsd_alloc_surface:
 lsl x0,x22,#3
.Lsd_alloc_call:
 bl malloc
 cbz x0,.Lsd_alloc_failed
 add x8,sp,#96
 str x0,[x8,x24,lsl#3]
 add w24,w24,#1
 cmp w24,#5
 b.lo .Lsd_allocate_loop
 /* Complete Fortran descriptors, including the zero-extent third dimension. */
 address x8,x20,1564952
 ldr x9,[sp,#96]
 str x9,[x8]
 mov x9,#-1
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 movz x9,#0
 movk x9,#0,lsl#16
 movk x9,#770,lsl#32
 str x9,[x8,#24]
 mov x9,#8
 str x9,[x8,#32]
 mov x9,#1
 str x9,[x8,#40]
 mov x9,#1
 str x9,[x8,#48]
 str x21,[x8,#56]
 str x21,[x8,#64]
 str xzr,[x8,#72]
 sub x9,x22,#1
 str x9,[x8,#80]
 address x8,x20,1565040
 ldr x9,[sp,#104]
 str x9,[x8]
 mov x9,#-1
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 movz x9,#0
 movk x9,#0,lsl#16
 movk x9,#770,lsl#32
 str x9,[x8,#24]
 mov x9,#8
 str x9,[x8,#32]
 mov x9,#1
 str x9,[x8,#40]
 mov x9,#1
 str x9,[x8,#48]
 str x21,[x8,#56]
 str x21,[x8,#64]
 str xzr,[x8,#72]
 sub x9,x22,#1
 str x9,[x8,#80]
 address x8,x20,1565128
 ldr x9,[sp,#112]
 str x9,[x8]
 mov x9,#-1
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 movz x9,#0
 movk x9,#0,lsl#16
 movk x9,#770,lsl#32
 str x9,[x8,#24]
 mov x9,#8
 str x9,[x8,#32]
 mov x9,#1
 str x9,[x8,#40]
 mov x9,#1
 str x9,[x8,#48]
 str x21,[x8,#56]
 str x21,[x8,#64]
 str xzr,[x8,#72]
 sub x9,x22,#1
 str x9,[x8,#80]
 address x8,x20,1565216
 ldr x9,[sp,#120]
 str x9,[x8]
 mul x9,x21,x22
 neg x9,x9
 sub x9,x9,#1
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 movz x9,#0
 movk x9,#0,lsl#16
 movk x9,#771,lsl#32
 str x9,[x8,#24]
 mov x9,#8
 str x9,[x8,#32]
 mov x9,#1
 str x9,[x8,#40]
 mov x9,#1
 str x9,[x8,#48]
 str x21,[x8,#56]
 str x21,[x8,#64]
 str xzr,[x8,#72]
 sub x9,x22,#1
 str x9,[x8,#80]
 mul x9,x21,x22
 str x9,[x8,#88]
 mov x9,#1
 str x9,[x8,#96]
 str xzr,[x8,#104]
 address x8,x20,1565504
 ldr x9,[sp,#128]
 str x9,[x8]
 mov x9,#0
 str x9,[x8,#8]
 mov x9,#8
 str x9,[x8,#16]
 movz x9,#0
 movk x9,#0,lsl#16
 movk x9,#769,lsl#32
 str x9,[x8,#24]
 mov x9,#8
 str x9,[x8,#32]
 mov x9,#1
 str x9,[x8,#40]
 str xzr,[x8,#48]
 sub x9,x22,#1
 str x9,[x8,#56]
 mov w0,#0
 b .Lsd_alloc_return
.Lsd_alloc_failed:
 cbz w24,.Lsd_alloc_bad
 sub w24,w24,#1
 add x8,sp,#96
 ldr x0,[x8,x24,lsl#3]
 bl free
 b .Lsd_alloc_failed
.Lsd_alloc_bad:
 mov w0,#2
.Lsd_alloc_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x29,x30,[sp],#192
 ret
.size md2asm_allocate_spectral_diffusion_storage,.-md2asm_allocate_spectral_diffusion_storage
.p2align 4
.global md2asm_release_spectral_diffusion_storage
.type md2asm_release_spectral_diffusion_storage,%function
md2asm_release_spectral_diffusion_storage:
 cbz x0,.Lsd_release_bad
 tst x0,#7
 b.ne .Lsd_release_bad
 movz x8,#15248
 movk x8,#65,lsl#16
 cmp x1,x8
 b.lo .Lsd_release_bad
 stp x29,x30,[sp,#-64]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x19,x0
 address x20,x19,1565504
 ldr x0,[x20]
 cbz x0,.Lsd_release_next_0
 bl free
 str xzr,[x20]
.Lsd_release_next_0:
 address x20,x19,1565216
 ldr x0,[x20]
 cbz x0,.Lsd_release_next_1
 bl free
 str xzr,[x20]
.Lsd_release_next_1:
 address x20,x19,1565128
 ldr x0,[x20]
 cbz x0,.Lsd_release_next_2
 bl free
 str xzr,[x20]
.Lsd_release_next_2:
 address x20,x19,1565040
 ldr x0,[x20]
 cbz x0,.Lsd_release_next_3
 bl free
 str xzr,[x20]
.Lsd_release_next_3:
 address x20,x19,1564952
 ldr x0,[x20]
 cbz x0,.Lsd_release_next_4
 bl free
 str xzr,[x20]
.Lsd_release_next_4:
 mov w0,#0
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.Lsd_release_bad:
 mov w0,#2
 ret
.size md2asm_release_spectral_diffusion_storage,.-md2asm_release_spectral_diffusion_storage

.text
.p2align 4
.global md2asm_calculate_spectral_diffusion_coefficients
.type md2asm_calculate_spectral_diffusion_coefficients,%function
md2asm_calculate_spectral_diffusion_coefficients:
 stp x29,x30,[sp,#-288]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 stp x28,xzr,[sp,#96]
 stp d8,d9,[sp,#112]
 stp d10,d11,[sp,#128]
 stp d12,d13,[sp,#144]
 stp d14,d15,[sp,#160]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x5
 bl .Lsd_validate
 cbnz w0,.Lsd_calculate_return
 mov x4,x21
 mov x5,x22
 bl .Lsd_constants
 cbnz w0,.Lsd_calculate_return
 ldr w22,[x19,#G_NFLEVG]
 ldr w23,[x19,#G_NSMAX]
 ldr w24,[x19,#G_NDGLG]
 sub w24,w24,#1
 address x8,x20,1564952
 ldr x9,[x8]
 cbz x9,.Lsd_calculate_bad
 tst x9,#7
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#16]
 cmp x9,#8
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#40]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#48]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#56]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#64]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#72]
 cbnz x9,.Lsd_calculate_bad
 ldr x9,[x8,#80]
 cmp w9,w23
 b.ne .Lsd_calculate_bad
 address x8,x20,1565040
 ldr x9,[x8]
 cbz x9,.Lsd_calculate_bad
 tst x9,#7
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#16]
 cmp x9,#8
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#40]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#48]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#56]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#64]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#72]
 cbnz x9,.Lsd_calculate_bad
 ldr x9,[x8,#80]
 cmp w9,w23
 b.ne .Lsd_calculate_bad
 address x8,x20,1565128
 ldr x9,[x8]
 cbz x9,.Lsd_calculate_bad
 tst x9,#7
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#16]
 cmp x9,#8
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#40]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#48]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#56]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#64]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#72]
 cbnz x9,.Lsd_calculate_bad
 ldr x9,[x8,#80]
 cmp w9,w23
 b.ne .Lsd_calculate_bad
 address x8,x20,1565216
 ldr x9,[x8]
 cbz x9,.Lsd_calculate_bad
 tst x9,#7
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#16]
 cmp x9,#8
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#40]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#48]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#56]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#64]
 cmp w9,w22
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#72]
 cbnz x9,.Lsd_calculate_bad
 ldr x9,[x8,#80]
 cmp w9,w23
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#104]
 cbnz x9,.Lsd_calculate_bad
 address x8,x20,1565504
 ldr x9,[x8]
 cbz x9,.Lsd_calculate_bad
 tst x9,#7
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#16]
 cmp x9,#8
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#40]
 cmp x9,#1
 b.ne .Lsd_calculate_bad
 ldr x9,[x8,#48]
 cbnz x9,.Lsd_calculate_bad
 ldr x9,[x8,#56]
 cmp w9,w23
 b.ne .Lsd_calculate_bad
 address x8,x20,1564840
 ldr d0,[x8]
 fmov d1,#4.0
 fcmp d0,d1
 b.ne .Lsd_calculate_bad
 address x8,x20,1564632
 ldr d0,[x8]
 fmov d1,#1.0
 fcmp d0,d1
 b.le .Lsd_calculate_bad
 address x8,x20,1564640
 ldr d0,[x8]
 fmov d1,#1.0
 fcmp d0,d1
 b.le .Lsd_calculate_bad
 address x8,x20,1564648
 ldr d0,[x8]
 fmov d1,#1.0
 fcmp d0,d1
 b.le .Lsd_calculate_bad
 address x8,x20,1359528
 ldr x9,[x8]
 tbnz x9,#63,.Lsd_calculate_bad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lsd_calculate_bad
 cbz x9,.Lsd_calculate_bad
 fmov d15,x9
 lsl x0,x22,#3
 bl malloc
 cbz x0,.Lsd_calculate_bad
 mov x25,x0
 /* Source integer power uses its ordered square-and-multiply route. */
 mov w26,#1
.Lsd_profile_loop:
 cmp w22,#19
 b.ne .Lsd_profile_other
 fmov d0,#2.0
 mov w8,#6
 b .Lsd_profile_power
.Lsd_profile_other:
 adrp x8,.Lsd_1p3
 ldr d0,[x8,:lo12:.Lsd_1p3]
 mov w8,#9
 cmp w22,w8
 csel w8,w22,w8,lt
.Lsd_profile_power:
 subs w8,w8,w26
 csel w8,w8,wzr,gt
 fmov d1,#1.0
 cbz w8,.Lsd_profile_power_done
.Lsd_integer_power:
 tbz w8,#0,.Lsd_integer_even
 fmul d1,d1,d0
.Lsd_integer_even:
 lsr w8,w8,#1
 cbz w8,.Lsd_profile_power_done
 fmul d0,d0,d0
 b .Lsd_integer_power
.Lsd_profile_power_done:
 fmov d0,#16.0
 fmin d1,d0,d1
 sub w8,w26,#1
 str d1,[x25,x8,lsl#3]
 add w26,w26,#1
 cmp w26,w22
 b.le .Lsd_profile_loop
 /* Nonmesosphere source explicitly resets the sponge threshold. */
 address x8,x20,1565712
 fmov d0,#1.0
 str d0,[x8]
 /* Source ZZDIR is evaluated even when its later branch is inactive. */
 address x8,x20,M_NDIFFACT
 ldr w8,[x8]
 scvtf d0,w8
 fmul d0,d0,d15
 mov w26,#0
.Lsd_wave_loop:
 mov w27,#0
.Lsd_wind_level_loop:
 add x8,x19,#1,lsl#12
 add x8,x8,#1864
 ldr x8,[x8]
 ldr w9,[x8,x27,lsl#2]
 sub w9,w9,#1
 ldr d8,[x25,x9,lsl#3]
 fmov d0,#1.0
 fcmp d8,d0
 b.le .Lsd_zero_wind
 fsub d8,d8,d0
 mov w0,w26
 mov w1,w24
 fmov d0,d8
 fmov d1,#4.0
 bl .Lsd_shape
 address x8,x20,1564632
 ldr d1,[x8]
 fdiv d9,d0,d1
 mov w0,w26
 mov w1,w24
 fmov d0,d8
 fmov d1,#4.0
 bl .Lsd_shape
 address x8,x20,1564640
 ldr d1,[x8]
 fdiv d10,d0,d1
 b .Lsd_store_wind
.Lsd_zero_wind:
 fmov d9,xzr
 fmov d10,xzr
.Lsd_store_wind:
 madd w9,w26,w22,w27
 address x8,x20,1564952
 ldr x8,[x8]
 str d9,[x8,x9,lsl#3]
 address x8,x20,1565040
 ldr x8,[x8]
 str d10,[x8,x9,lsl#3]
 add w27,w27,#1
 cmp w27,w22
 b.lo .Lsd_wind_level_loop
 mov w27,#0
.Lsd_temperature_loop:
 ldr d8,[x25,x27,lsl#3]
 fmov d0,#1.0
 fcmp d8,d0
 b.le .Lsd_zero_temperature
 fsub d8,d8,d0
 mov w0,w26
 mov w1,w24
 fmov d0,d8
 fmov d1,#4.0
 bl .Lsd_shape
 address x8,x20,1564648
 ldr d1,[x8]
 fdiv d0,d0,d1
 b .Lsd_store_temperature
.Lsd_zero_temperature:
 fmov d0,xzr
.Lsd_store_temperature:
 madd w9,w26,w22,w27
 address x8,x20,1565128
 ldr x8,[x8]
 str d0,[x8,x9,lsl#3]
 add w27,w27,#1
 cmp w27,w22
 b.lo .Lsd_temperature_loop
 address x8,x20,1565504
 ldr x8,[x8]
 str xzr,[x8,x26,lsl#3]
 add w26,w26,#1
 cmp w26,w23
 b.le .Lsd_wave_loop
 /* Cubic-grid spectral viscosity is added after all sponge values. */
 lsl w8,w23,#1
 scvtf d0,w8
 fmov d1,#1.0
 fdiv d11,d1,d0
 fdiv d11,d11,d15
 lsr w24,w23,#1
 mov w26,#0
.Lsd_viscosity_loop:
 cmp w26,w24
 b.le .Lsd_zero_viscosity
 sub w8,w26,w23
 scvtf d0,w8
 fmul d0,d0,d0
 fmov d1,#-0.5
 fmul d0,d1,d0
 sub w8,w26,w24
 scvtf d1,w8
 fmul d1,d1,d1
 fdiv d0,d0,d1
 bl md2asm_exp_original_rounding
 fmov d8,d0
 add w8,w26,#1
 mul w8,w26,w8
 scvtf d0,w8
 add w8,w23,#1
 mul w8,w23,w8
 scvtf d1,w8
 fdiv d0,d0,d1
 fmul d0,d0,d0
 fmul d0,d11,d0
 fmul d1,d8,d8
 fmul d12,d0,d1
 b .Lsd_add_viscosity
.Lsd_zero_viscosity:
 fmov d12,xzr
.Lsd_add_viscosity:
 mov w27,#0
.Lsd_add_viscosity_wind:
 madd w9,w26,w22,w27
 address x8,x20,1564952
 ldr x8,[x8]
 ldr d0,[x8,x9,lsl#3]
 fadd d0,d0,d12
 str d0,[x8,x9,lsl#3]
 address x8,x20,1565040
 ldr x8,[x8]
 ldr d0,[x8,x9,lsl#3]
 fadd d0,d0,d12
 str d0,[x8,x9,lsl#3]
 add w27,w27,#1
 cmp w27,w22
 b.lo .Lsd_add_viscosity_wind
 mov w27,#0
.Lsd_add_viscosity_temperature:
 madd w9,w26,w22,w27
 address x8,x20,1565128
 ldr x8,[x8]
 ldr d0,[x8,x9,lsl#3]
 fadd d0,d0,d12
 str d0,[x8,x9,lsl#3]
 add w27,w27,#1
 cmp w27,w22
 b.lo .Lsd_add_viscosity_temperature
 address x8,x20,1565504
 ldr x8,[x8]
 str xzr,[x8,x26,lsl#3]
 add w26,w26,#1
 cmp w26,w23
 b.le .Lsd_viscosity_loop
 /* Retain the source diagnostic divisions and their arithmetic status. */
 sub w27,w22,#1
.Lsd_diagnostic_level:
 madd w9,w23,w22,w27
 address x8,x20,1564952
 ldr x8,[x8]
 ldr d0,[x8,x9,lsl#3]
 adrp x8,.Lsd_small_threshold
 ldr d1,[x8,:lo12:.Lsd_small_threshold]
 fcmp d0,d1
 b.le .Lsd_diagnostic_skip_rdivor
 fmov d1,#1.0
 fdiv d0,d1,d0
 ldr d1,[x21]
 fdiv d0,d0,d1
.Lsd_diagnostic_skip_rdivor:
 address x8,x20,1565128
 ldr x8,[x8]
 ldr d0,[x8,x9,lsl#3]
 adrp x8,.Lsd_small_threshold
 ldr d1,[x8,:lo12:.Lsd_small_threshold]
 fcmp d0,d1
 b.le .Lsd_diagnostic_skip_rditg
 fmov d1,#1.0
 fdiv d0,d1,d0
 ldr d1,[x21]
 fdiv d0,d0,d1
.Lsd_diagnostic_skip_rditg:
 address x8,x20,1565040
 ldr x8,[x8]
 ldr d0,[x8,x9,lsl#3]
 adrp x8,.Lsd_small_threshold
 ldr d1,[x8,:lo12:.Lsd_small_threshold]
 fcmp d0,d1
 b.le .Lsd_diagnostic_skip_rdidiv
 fmov d1,#1.0
 fdiv d0,d1,d0
 ldr d1,[x21]
 fdiv d0,d0,d1
.Lsd_diagnostic_skip_rdidiv:
 subs w27,w27,#1
 b.ge .Lsd_diagnostic_level
 mov x0,x25
 bl free
 mov w0,#0
 b .Lsd_calculate_return
.Lsd_calculate_bad:
 mov w0,#2
.Lsd_calculate_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp d8,d9,[sp,#112]
 ldp d10,d11,[sp,#128]
 ldp d12,d13,[sp,#144]
 ldp d14,d15,[sp,#160]
 ldp x29,x30,[sp],#288
 ret
.size md2asm_calculate_spectral_diffusion_coefficients,.-md2asm_calculate_spectral_diffusion_coefficients
/* Ordered original PDISPEL, including its zero-weighted second term. */
.p2align 4
.Lsd_shape:
 stp x29,x30,[sp,#-96]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp d8,d9,[sp,#48]
 stp d10,d11,[sp,#64]
 mov w19,w0
 mov w20,w1
 fmov d8,d0
 fmov d10,d1
 add w8,w0,#1
 mul w8,w0,w8
 scvtf d0,w8
 add w8,w1,#1
 mul w8,w1,w8
 scvtf d1,w8
 fdiv d0,d0,d1
 fsqrt d0,d0
 fmov d2,xzr
 fmax d0,d0,d2
 fmov d1,d10
 bl md2asm_pow_original_rounding_candidate
 fmov d1,#1.0
 fmul d0,d1,d0
 fmul d9,d0,d8
 add w8,w19,#1
 mul w8,w19,w8
 scvtf d0,w8
 add w8,w20,#1
 mul w8,w20,w8
 scvtf d1,w8
 fdiv d0,d0,d1
 fsqrt d0,d0
 fmov d2,xzr
 fmax d0,d0,d2
 fmov d1,#3.0
 fmul d1,d10,d1
 fmov d2,#2.0
 fdiv d1,d1,d2
 bl md2asm_pow_original_rounding_candidate
 fmov d1,xzr
 fmul d0,d1,d0
 fmul d0,d0,d8
 fadd d11,d9,d0
 /* The original third term retains diffusion inside the whole profile. */
 add w8,w19,#1
 mul w8,w19,w8
 scvtf d0,w8
 add w8,w20,#1
 mul w8,w20,w8
 scvtf d1,w8
 fdiv d0,d0,d1
 fsqrt d0,d0
 fmov d2,xzr
 fmax d0,d0,d2
 fmov d1,d10
 bl md2asm_pow_original_rounding_candidate
 fmov d1,#1.0
 fmul d0,d1,d0
 fadd d0,d11,d0
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp d8,d9,[sp,#48]
 ldp d10,d11,[sp,#64]
 ldp x29,x30,[sp],#96
 ret

.section .rodata
.p2align 3
.Lsd_1p3: .double 1.3
.Lsd_small_threshold: .double 1e-7

.section .rodata
.p2align 3
.Lsd_cv_0: .word 0
.p2align 3
.Lsd_cv_1: .quad 0x4010000000000000
.p2align 3
.Lsd_cv_2: .quad 0x0
.p2align 3
.Lsd_cv_3: .quad 0x404ca8f5c28f5c29
.p2align 3
.Lsd_cv_4: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_5: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_6: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_7: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_8: .quad 0x0
.p2align 3
.Lsd_cv_9: .quad 0x0
.p2align 3
.Lsd_cv_10: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_11: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_12: .word 1
.p2align 3
.Lsd_cv_13: .word 1
.p2align 3
.Lsd_cv_14: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_15: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_16: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_17: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_18: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_19: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_20: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_21: .quad 0xc0c3878000000000
.p2align 3
.Lsd_cv_22: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_23: .quad 0x3fa999999999999a
.p2align 3
.Lsd_cv_24: .quad 0x3f747ae147ae147b
.p2align 3
.Lsd_cv_25: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_26: .quad 0x40c3880000000000
.p2align 3
.Lsd_cv_27: .quad 0x4059000000000000
.p2align 3
.Lsd_cv_28: .quad 0x40c3880000000000
.p2align 3
.Lsd_cv_29: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_30: .quad 0x0
.p2align 3
.Lsd_cv_31: .quad 0x0
.p2align 3
.Lsd_cv_32: .quad 0x0
.p2align 3
.Lsd_cv_33: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_34: .quad 0x3fd0000000000000
.p2align 3
.Lsd_cv_35: .quad 0x3fa47ae147ae147b
.p2align 3
.Lsd_cv_36: .quad 0x4010000000000000
.p2align 3
.Lsd_cv_37: .quad 0x4010000000000000
.p2align 3
.Lsd_cv_38: .quad 0x3f110a137f38c543
.p2align 3
.Lsd_cv_39: .quad 0x3f153bd1676640a7
.p2align 3
.Lsd_cv_40: .quad 0x0
.p2align 3
.Lsd_cv_41: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_42: .quad 0x0
.p2align 3
.Lsd_cv_43: .quad 0x409f400000000000
.p2align 3
.Lsd_cv_44: .quad 0x408f400000000000
.p2align 3
.Lsd_cv_45: .quad 0x4018000000000000
.p2align 3
.Lsd_cv_46: .quad 0x3fd0000000000000
.p2align 3
.Lsd_cv_47: .quad 0x3fa999999999999a
.p2align 3
.Lsd_cv_48: .quad 0x3f747ae147ae147b
.p2align 3
.Lsd_cv_49: .quad 0x0
.p2align 3
.Lsd_cv_50: .word 1
.p2align 3
.Lsd_cv_51: .word 1
.p2align 3
.Lsd_cv_52: .quad 0x0
.p2align 3
.Lsd_cv_53: .quad 0x0
.p2align 3
.Lsd_cv_54: .quad 0x0
.p2align 3
.Lsd_cv_55: .quad 0x0
.p2align 3
.Lsd_cv_56: .quad 0x0
.p2align 3
.Lsd_cv_57: .quad 0x0
.p2align 3
.Lsd_cv_58: .word 0
.p2align 3
.Lsd_cv_59: .word 1
.p2align 3
.Lsd_cv_60: .word 6
.p2align 3
.Lsd_cv_61: .word 0
.p2align 3
.Lsd_cv_62: .quad 0x3ff0000000000000
.p2align 3
.Lsd_cv_63: .quad 0x3fefae147ae147ae
.p2align 3
.Lsd_cv_64: .word 255
.p2align 3
.Lsd_cv_65: .word 3
.p2align 3
.Lsd_cv_66: .word 0
.p2align 3
.Lsd_cv_67: .quad 0x4022000000000000
.p2align 3
.Lsd_cv_68: .word 0
.p2align 3
.Lsd_cv_69: .quad 0x4030000000000000
.p2align 3
.Lsd_resolution_table:
.word 255,0
.double 2500.0
.word 213,0
.double 2700.0
.word 159,0
.double 5400.0
.word 106,0
.double 12570.0
.word 95,0
.double 15000.0
.word 63,0
.double 27000.0
.word 42,0
.double 54000.0
.word 21,0
.double 108000.0

.section .note.GNU-stack,"",%progbits

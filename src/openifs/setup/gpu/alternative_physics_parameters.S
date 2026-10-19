/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/alternative_physics_parameters.S
 */
// Original contract: skills/md2asm/references/openifs/setup/alternative_physics_parameters.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.equ ALT_CMICRO,0
.equ ALT_CSEDIM,4
.equ ALT_NSPLITR,8
.equ ALT_NSPLITG,12
.equ ALT_NRR,16
.equ ALT_NRRL,20
.equ ALT_NRRI,24
.equ ALT_NSV,28
.equ ALT_NSWB_MNH,32
.equ ALT_NGPAR,36
.equ ALT_MINPRR,40
.equ ALT_MACPRR,44
.equ ALT_MINPRS,48
.equ ALT_MACPRS,52
.equ ALT_MINPRG,56
.equ ALT_MACPRG,60
.equ ALT_MALBDIR,64
.equ ALT_MALBSCA,68
.equ ALT_MRAIN,72
.equ ALT_MSNOW,76
.equ ALT_MGZ0,80
.equ ALT_MGZ0H,84
.equ ALT_MVQS,88
.equ ALT_MVTS,92
.equ ALT_MVEMIS,96
.equ ALT_MSWDIR,100
.equ ALT_MSWDIF,104
.equ ALT_MFRTHDS,108
.equ ALT_MLSM,112
.equ ALT_MCD,116
.equ ALT_XSW_BANDS,120
.equ ALT_LOSUBG_COND,184
.equ ALT_LOSEDIC,188
.equ ALT_LOWARM,192
.equ ALT_LOSIGMAS,196
.equ ALT_LOLSMC,200
.equ ALT_LOTOWNC,204
.equ ALT_LOCND2,208
.equ ALT_LGRSN,212
.equ ALT_RADGR,216
.equ ALT_RADSN,224
.equ ALT_VSIGQSAT,232
.equ ALT_CMF_UPDRAFT,240
.equ ALT_CMF_CLOUD,244
.equ ALT_LMIXUV,248
.equ ALT_LLCRIT,252
.equ ALT_LTOTPREC,256
.equ ALT_XALP_PERT,264
.equ ALT_XABUO,272
.equ ALT_XBENTR,280
.equ ALT_XBDETR,288
.equ ALT_XCMF,296
.equ ALT_XENTR_MF,304
.equ ALT_XCRAD_MF,312
.equ ALT_XENTR_DRY,320
.equ ALT_XDETR_DRY,328
.equ ALT_XDETR_LUP,336
.equ ALT_XKCF_MF,344
.equ ALT_XKRC_MF,352
.equ ALT_XTAUSIGMF,360
.equ ALT_XPRES_UV,368
.equ ALT_XFRAC_UP_MAX,376
.equ ALT_XALPHA_MF,384
.equ ALT_XSIGMA_MF,392
.equ ALT_XA1,400
.equ ALT_XB,408
.equ ALT_XC,416
.equ ALT_XBETA1,424
.equ ALT_XR,432
.equ ALT_XLAMBDA,440
.equ ALT_LTHETAS,448
.equ ALT_LSQUALL,452
.equ ALT_NREFROI1,456
.equ ALT_NREFROI2,460
.equ ALT_VSQUALL,464
.equ ALT_NPTP,472
.equ ALT_NPRINTFR,476
.equ ALT_LDIAGWMAX,480
.equ ALT_NDIAGWMAX,484
.equ ALT_NDTCHEM,488
.equ ALT_LAROBU_ENABLE,492
.equ ALT_XLINI,496
.equ ALT_LHARATU,504
.equ ALT_CSUBG_AUCV_RC,508
.equ ALT_CSUBG_RC_RR_ACCR,512
.equ ALT_CSUBG_RR_EVAP,592
.equ ALT_CSUBG_PR_PDF,672
.equ ALT_RCRIAUTI,752
.equ ALT_RCRIAUTC,760
.equ ALT_RT0CRIAUTI,768
.equ ALT_LCRIAUTI,776
.equ ALT_XTSTEP_TS,784
.equ ALT_XMRSTEP,792
.equ ALT_NMAXITER_MICRO,800
.equ ALT_CSNOWRIMING,804
.equ ALT_XFRACM90,808
.equ ALT_LNULLWETG,816
.equ ALT_LWETGPOST,820
.equ ALT_LNULLWETH,824
.equ ALT_LWETHPOST,828
.equ ALT_LFEEDBACKT,832
.equ ALT_LEVLIMIT,836
.equ ALT_LCONVHG,840
.equ ALT_LCRFLIMIT,844
.equ ALT_CFRAC_ICE_ADJUST,848
.equ ALT_CFRAC_ICE_SHALLOW_MF,849
.equ ALT_LSEDIM_AFTER,852
.equ ALT_XSPLIT_MAXCFL,856
.equ ALT_LFPREC3D,864
.equ ALT_XCQVR,872
.equ ALT_GQVPLIM,880
.equ ALT_GQVTOP,888
.equ ALT_LQVTOP,896
.text
.p2align 4
.global md2asm_initialize_alternative_physics_parameters
.type md2asm_initialize_alternative_physics_parameters,%function
md2asm_initialize_alternative_physics_parameters:
 cbz x0,.Lalt_bad_leaf
 cbz x1,.Lalt_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lalt_bad_leaf
 cbz x2,.Lalt_bad_leaf
 cbz x4,.Lalt_bad_leaf
 cmp x3,#904
 b.lo .Lalt_bad_leaf
 orr x5,x2,x4
 tst x5,#7
 b.ne .Lalt_bad_leaf
 adds x5,x0,x1
 b.cs .Lalt_bad_leaf
 adds x6,x2,#904
 b.cs .Lalt_bad_leaf
 adds x7,x4,#32
 b.cs .Lalt_bad_leaf
 cmp x2,x5
 b.hs .Lalt_text_clear
 cmp x0,x6
 b.lo .Lalt_bad_leaf
.Lalt_text_clear:
 cmp x2,x7
 b.hs .Lalt_input_clear
 cmp x4,x6
 b.lo .Lalt_bad_leaf
.Lalt_input_clear:
 ldp w5,w6,[x4]
 orr w5,w5,w6
 cbnz w5,.Lalt_bad_leaf
 ldp w5,w6,[x4,#8]
 cmp w5,#1
 b.hi .Lalt_bad_leaf
 cmp w6,#1
 b.hi .Lalt_bad_leaf
 ldr w5,[x4,#16]
 cmp w5,#1
 b.hi .Lalt_bad_leaf
 mrs x5,fpcr
 cbnz x5,.Lalt_bad_leaf
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x2
 mov x20,x4
 adr x2,.Lalt_group
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lalt_bad_frame
 mov x0,x19
 bl md2asm_set_alternative_parameter_literals_raw
 mov x0,x19
 mov x1,x20
 bl md2asm_set_alternative_parameter_arithmetic_raw
 mov w0,#0
 b .Lalt_return
.Lalt_bad_frame:
 mov w0,#2
.Lalt_return:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lalt_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_alternative_physics_parameters,.-md2asm_initialize_alternative_physics_parameters
.p2align 4
.global md2asm_set_alternative_parameter_literals_raw
.type md2asm_set_alternative_parameter_literals_raw,%function
md2asm_set_alternative_parameter_literals_raw:
 adr x9,.Lalt_literal_0
 ldr w10,[x9,#0]
 str w10,[x0,#4]
 adr x9,.Lalt_literal_1
 ldr x10,[x9,#0]
 str x10,[x0,#752]
 adr x9,.Lalt_literal_2
 ldr x10,[x9,#0]
 str x10,[x0,#760]
 adr x9,.Lalt_literal_3
 ldr w10,[x9,#0]
 str w10,[x0,#776]
 adr x9,.Lalt_literal_4
 ldr x10,[x9,#0]
 str x10,[x0,#784]
 adr x9,.Lalt_literal_5
 ldr x10,[x9,#0]
 str x10,[x0,#792]
 adr x9,.Lalt_literal_6
 ldr w10,[x9,#0]
 str w10,[x0,#800]
 adr x9,.Lalt_literal_7
 ldr w10,[x9,#0]
 str w10,[x0,#864]
 adr x9,.Lalt_literal_8
 ldr w10,[x9,#0]
 str w10,[x0,#0]
 adr x9,.Lalt_literal_9
 ldr w10,[x9,#0]
 str w10,[x0,#16]
 adr x9,.Lalt_literal_10
 ldr w10,[x9,#0]
 str w10,[x0,#20]
 adr x9,.Lalt_literal_11
 ldr w10,[x9,#0]
 str w10,[x0,#24]
 adr x9,.Lalt_literal_12
 ldr w10,[x9,#0]
 str w10,[x0,#0]
 adr x9,.Lalt_literal_13
 ldr w10,[x9,#0]
 str w10,[x0,#16]
 adr x9,.Lalt_literal_14
 ldr w10,[x9,#0]
 str w10,[x0,#20]
 adr x9,.Lalt_literal_15
 ldr w10,[x9,#0]
 str w10,[x0,#24]
 adr x9,.Lalt_literal_16
 ldr w10,[x9,#0]
 str w10,[x0,#184]
 adr x9,.Lalt_literal_17
 ldr x10,[x9,#0]
 str x10,[x0,#232]
 adr x9,.Lalt_literal_18
 ldr w10,[x9,#0]
 str w10,[x0,#196]
 adr x9,.Lalt_literal_19
 ldr w10,[x9,#0]
 str w10,[x0,#188]
 adr x9,.Lalt_literal_20
 ldr w10,[x9,#0]
 str w10,[x0,#32]
 adr x9,.Lalt_literal_21
 ldr w10,[x9,#0]
 str w10,[x0,#452]
 adr x9,.Lalt_literal_22
 ldr w10,[x9,#0]
 str w10,[x0,#456]
 adr x9,.Lalt_literal_23
 ldr w10,[x9,#0]
 str w10,[x0,#460]
 adr x9,.Lalt_literal_24
 ldr x10,[x9,#0]
 str x10,[x0,#464]
 adr x9,.Lalt_literal_25
 ldr w10,[x9,#0]
 str w10,[x0,#472]
 adr x9,.Lalt_literal_26
 ldr w10,[x9,#0]
 str w10,[x0,#480]
 adr x9,.Lalt_literal_27
 ldr w10,[x9,#0]
 str w10,[x0,#484]
 adr x9,.Lalt_literal_28
 ldr w10,[x9,#0]
 str w10,[x0,#192]
 adr x9,.Lalt_literal_29
 ldr w10,[x9,#0]
 str w10,[x0,#200]
 adr x9,.Lalt_literal_30
 ldr w10,[x9,#0]
 str w10,[x0,#204]
 adr x9,.Lalt_literal_31
 ldr w10,[x9,#0]
 str w10,[x0,#208]
 adr x9,.Lalt_literal_32
 ldr w10,[x9,#0]
 str w10,[x0,#212]
 adr x9,.Lalt_literal_33
 ldr x10,[x9,#0]
 str x10,[x0,#216]
 adr x9,.Lalt_literal_34
 ldr x10,[x9,#0]
 str x10,[x0,#224]
 adr x9,.Lalt_literal_35
 ldr w10,[x9,#0]
 str w10,[x0,#240]
 adr x9,.Lalt_literal_36
 ldr w10,[x9,#0]
 str w10,[x0,#244]
 adr x9,.Lalt_literal_37
 ldr w10,[x9,#0]
 str w10,[x0,#248]
 adr x9,.Lalt_literal_38
 ldr w10,[x9,#0]
 str w10,[x0,#252]
 adr x9,.Lalt_literal_39
 ldr w10,[x9,#0]
 str w10,[x0,#256]
 adr x9,.Lalt_literal_40
 ldr x10,[x9,#0]
 str x10,[x0,#264]
 adr x9,.Lalt_literal_41
 ldr x10,[x9,#0]
 str x10,[x0,#272]
 adr x9,.Lalt_literal_42
 ldr x10,[x9,#0]
 str x10,[x0,#280]
 adr x9,.Lalt_literal_43
 ldr x10,[x9,#0]
 str x10,[x0,#288]
 adr x9,.Lalt_literal_44
 ldr x10,[x9,#0]
 str x10,[x0,#296]
 adr x9,.Lalt_literal_45
 ldr x10,[x9,#0]
 str x10,[x0,#304]
 adr x9,.Lalt_literal_46
 ldr x10,[x9,#0]
 str x10,[x0,#312]
 adr x9,.Lalt_literal_47
 ldr x10,[x9,#0]
 str x10,[x0,#320]
 adr x9,.Lalt_literal_48
 ldr x10,[x9,#0]
 str x10,[x0,#328]
 adr x9,.Lalt_literal_49
 ldr x10,[x9,#0]
 str x10,[x0,#336]
 adr x9,.Lalt_literal_50
 ldr x10,[x9,#0]
 str x10,[x0,#344]
 adr x9,.Lalt_literal_51
 ldr x10,[x9,#0]
 str x10,[x0,#352]
 adr x9,.Lalt_literal_52
 ldr x10,[x9,#0]
 str x10,[x0,#360]
 adr x9,.Lalt_literal_53
 ldr x10,[x9,#0]
 str x10,[x0,#368]
 adr x9,.Lalt_literal_54
 ldr x10,[x9,#0]
 str x10,[x0,#376]
 adr x9,.Lalt_literal_55
 ldr x10,[x9,#0]
 str x10,[x0,#384]
 adr x9,.Lalt_literal_56
 ldr x10,[x9,#0]
 str x10,[x0,#392]
 adr x9,.Lalt_literal_57
 ldr x10,[x9,#0]
 str x10,[x0,#408]
 adr x9,.Lalt_literal_58
 ldr x10,[x9,#0]
 str x10,[x0,#416]
 adr x9,.Lalt_literal_59
 ldr x10,[x9,#0]
 str x10,[x0,#424]
 adr x9,.Lalt_literal_60
 ldr x10,[x9,#0]
 str x10,[x0,#432]
 adr x9,.Lalt_literal_61
 ldr x10,[x9,#0]
 str x10,[x0,#440]
 adr x9,.Lalt_literal_62
 ldr w10,[x9,#0]
 str w10,[x0,#448]
 adr x9,.Lalt_literal_63
 ldr w10,[x9,#0]
 str w10,[x0,#488]
 adr x9,.Lalt_literal_64
 ldr w10,[x9,#0]
 str w10,[x0,#492]
 adr x9,.Lalt_literal_65
 ldr w10,[x9,#0]
 str w10,[x0,#508]
 adr x9,.Lalt_literal_66
 ldr x10,[x9,#0]
 str x10,[x0,#512]
 ldr x10,[x9,#8]
 str x10,[x0,#520]
 ldr x10,[x9,#16]
 str x10,[x0,#528]
 ldr x10,[x9,#24]
 str x10,[x0,#536]
 ldr x10,[x9,#32]
 str x10,[x0,#544]
 ldr x10,[x9,#40]
 str x10,[x0,#552]
 ldr x10,[x9,#48]
 str x10,[x0,#560]
 ldr x10,[x9,#56]
 str x10,[x0,#568]
 ldr x10,[x9,#64]
 str x10,[x0,#576]
 ldr x10,[x9,#72]
 str x10,[x0,#584]
 adr x9,.Lalt_literal_67
 ldr x10,[x9,#0]
 str x10,[x0,#592]
 ldr x10,[x9,#8]
 str x10,[x0,#600]
 ldr x10,[x9,#16]
 str x10,[x0,#608]
 ldr x10,[x9,#24]
 str x10,[x0,#616]
 ldr x10,[x9,#32]
 str x10,[x0,#624]
 ldr x10,[x9,#40]
 str x10,[x0,#632]
 ldr x10,[x9,#48]
 str x10,[x0,#640]
 ldr x10,[x9,#56]
 str x10,[x0,#648]
 ldr x10,[x9,#64]
 str x10,[x0,#656]
 ldr x10,[x9,#72]
 str x10,[x0,#664]
 adr x9,.Lalt_literal_68
 ldr x10,[x9,#0]
 str x10,[x0,#672]
 ldr x10,[x9,#8]
 str x10,[x0,#680]
 ldr x10,[x9,#16]
 str x10,[x0,#688]
 ldr x10,[x9,#24]
 str x10,[x0,#696]
 ldr x10,[x9,#32]
 str x10,[x0,#704]
 ldr x10,[x9,#40]
 str x10,[x0,#712]
 ldr x10,[x9,#48]
 str x10,[x0,#720]
 ldr x10,[x9,#56]
 str x10,[x0,#728]
 ldr x10,[x9,#64]
 str x10,[x0,#736]
 ldr x10,[x9,#72]
 str x10,[x0,#744]
 adr x9,.Lalt_literal_69
 ldr w10,[x9,#0]
 str w10,[x0,#804]
 adr x9,.Lalt_literal_70
 ldr x10,[x9,#0]
 str x10,[x0,#808]
 adr x9,.Lalt_literal_71
 ldr w10,[x9,#0]
 str w10,[x0,#832]
 adr x9,.Lalt_literal_72
 ldr w10,[x9,#0]
 str w10,[x0,#836]
 adr x9,.Lalt_literal_73
 ldr w10,[x9,#0]
 str w10,[x0,#816]
 adr x9,.Lalt_literal_74
 ldr w10,[x9,#0]
 str w10,[x0,#820]
 adr x9,.Lalt_literal_75
 ldr w10,[x9,#0]
 str w10,[x0,#824]
 adr x9,.Lalt_literal_76
 ldr w10,[x9,#0]
 str w10,[x0,#828]
 adr x9,.Lalt_literal_77
 ldr w10,[x9,#0]
 str w10,[x0,#840]
 adr x9,.Lalt_literal_78
 ldr w10,[x9,#0]
 str w10,[x0,#844]
 adr x9,.Lalt_literal_79
 ldrb w10,[x9,#0]
 strb w10,[x0,#848]
 adr x9,.Lalt_literal_80
 ldrb w10,[x9,#0]
 strb w10,[x0,#849]
 adr x9,.Lalt_literal_81
 ldr w10,[x9,#0]
 str w10,[x0,#852]
 adr x9,.Lalt_literal_82
 ldr x10,[x9,#0]
 str x10,[x0,#856]
 adr x9,.Lalt_literal_83
 ldr x10,[x9,#0]
 str x10,[x0,#496]
 adr x9,.Lalt_literal_84
 ldr w10,[x9,#0]
 str w10,[x0,#504]
 adr x9,.Lalt_literal_85
 ldr x10,[x9,#0]
 str x10,[x0,#872]
 adr x9,.Lalt_literal_86
 ldr x10,[x9,#0]
 str x10,[x0,#880]
 adr x9,.Lalt_literal_87
 ldr x10,[x9,#0]
 str x10,[x0,#888]
 adr x9,.Lalt_literal_88
 ldr w10,[x9,#0]
 str w10,[x0,#896]
 adr x9,.Lalt_literal_89
 ldr w10,[x9,#0]
 str w10,[x0,#476]
 ret
.section .rodata
.p2align 3
.Lalt_literal_0:
 .byte 83,84,65,84
.Lalt_literal_1:
 .byte 0,0,0,128,181,248,244,62
.Lalt_literal_2:
 .byte 0,0,0,224,77,98,64,63
.Lalt_literal_3:
 .byte 0,0,0,0
.Lalt_literal_4:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_5:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_6:
 .byte 5,0,0,0
.Lalt_literal_7:
 .byte 0,0,0,0
.Lalt_literal_8:
 .byte 79,76,68,51
.Lalt_literal_9:
 .byte 7,0,0,0
.Lalt_literal_10:
 .byte 2,0,0,0
.Lalt_literal_11:
 .byte 4,0,0,0
.Lalt_literal_12:
 .byte 79,76,68,52
.Lalt_literal_13:
 .byte 6,0,0,0
.Lalt_literal_14:
 .byte 2,0,0,0
.Lalt_literal_15:
 .byte 3,0,0,0
.Lalt_literal_16:
 .byte 0,0,0,0
.Lalt_literal_17:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_18:
 .byte 0,0,0,0
.Lalt_literal_19:
 .byte 0,0,0,0
.Lalt_literal_20:
 .byte 6,0,0,0
.Lalt_literal_21:
 .byte 0,0,0,0
.Lalt_literal_22:
 .byte 1,0,0,0
.Lalt_literal_23:
 .byte 1,0,0,0
.Lalt_literal_24:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_25:
 .byte 1,0,0,0
.Lalt_literal_26:
 .byte 0,0,0,0
.Lalt_literal_27:
 .byte 1,0,0,0
.Lalt_literal_28:
 .byte 1,0,0,0
.Lalt_literal_29:
 .byte 0,0,0,0
.Lalt_literal_30:
 .byte 0,0,0,0
.Lalt_literal_31:
 .byte 0,0,0,0
.Lalt_literal_32:
 .byte 0,0,0,0
.Lalt_literal_33:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_34:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_35:
 .byte 69,68,75,70
.Lalt_literal_36:
 .byte 68,73,82,69
.Lalt_literal_37:
 .byte 1,0,0,0
.Lalt_literal_38:
 .byte 0,0,0,0
.Lalt_literal_39:
 .byte 0,0,0,0
.Lalt_literal_40:
 .byte 51,51,51,51,51,51,211,63
.Lalt_literal_41:
 .byte 0,0,0,0,0,0,240,63
.Lalt_literal_42:
 .byte 0,0,0,0,0,0,240,63
.Lalt_literal_43:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_44:
 .byte 164,112,61,10,215,163,176,63
.Lalt_literal_45:
 .byte 236,81,184,30,133,235,161,63
.Lalt_literal_46:
 .byte 0,0,0,0,0,0,73,64
.Lalt_literal_47:
 .byte 154,153,153,153,153,153,225,63
.Lalt_literal_48:
 .byte 0,0,0,0,0,0,36,64
.Lalt_literal_49:
 .byte 0,0,0,0,0,0,240,63
.Lalt_literal_50:
 .byte 0,0,0,0,0,0,6,64
.Lalt_literal_51:
 .byte 0,0,0,0,0,0,240,63
.Lalt_literal_52:
 .byte 0,0,0,0,0,192,130,64
.Lalt_literal_53:
 .byte 0,0,0,0,0,0,224,63
.Lalt_literal_54:
 .byte 31,133,235,81,184,30,213,63
.Lalt_literal_55:
 .byte 0,0,0,0,0,0,0,64
.Lalt_literal_56:
 .byte 0,0,0,0,0,0,52,64
.Lalt_literal_57:
 .byte 252,169,241,210,77,98,96,63
.Lalt_literal_58:
 .byte 250,126,106,188,116,147,136,63
.Lalt_literal_59:
 .byte 205,204,204,204,204,204,236,63
.Lalt_literal_60:
 .byte 0,0,0,0,0,0,0,64
.Lalt_literal_61:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_62:
 .byte 0,0,0,0
.Lalt_literal_63:
 .byte 1,0,0,0
.Lalt_literal_64:
 .byte 0,0,0,0
.Lalt_literal_65:
 .byte 80,68,70,32
.Lalt_literal_66:
 .byte 78,79,78,69,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.Lalt_literal_67:
 .byte 78,79,78,69,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.Lalt_literal_68:
 .byte 83,73,71,77,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.Lalt_literal_69:
 .byte 77,57,48,32
.Lalt_literal_70:
 .byte 0,0,0,160,153,153,185,63
.Lalt_literal_71:
 .byte 1,0,0,0
.Lalt_literal_72:
 .byte 1,0,0,0
.Lalt_literal_73:
 .byte 1,0,0,0
.Lalt_literal_74:
 .byte 1,0,0,0
.Lalt_literal_75:
 .byte 1,0,0,0
.Lalt_literal_76:
 .byte 1,0,0,0
.Lalt_literal_77:
 .byte 1,0,0,0
.Lalt_literal_78:
 .byte 1,0,0,0
.Lalt_literal_79:
 .byte 84
.Lalt_literal_80:
 .byte 84
.Lalt_literal_81:
 .byte 0,0,0,0
.Lalt_literal_82:
 .byte 0,0,0,160,153,153,233,63
.Lalt_literal_83:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_84:
 .byte 0,0,0,0
.Lalt_literal_85:
 .byte 0,0,0,0,0,0,0,0
.Lalt_literal_86:
 .byte 0,0,0,0,0,136,195,64
.Lalt_literal_87:
 .byte 105,29,85,77,16,117,207,62
.Lalt_literal_88:
 .byte 0,0,0,0
.Lalt_literal_89:
 .byte 64,250,1,0
.text
.size md2asm_set_alternative_parameter_literals_raw,.-md2asm_set_alternative_parameter_literals_raw
.p2align 4
.global md2asm_set_alternative_parameter_arithmetic_raw
.type md2asm_set_alternative_parameter_arithmetic_raw,%function
md2asm_set_alternative_parameter_arithmetic_raw:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 ldr d0,[x19,#ALT_RCRIAUTI]
 bl log10
 ldr x18,[sp,#32]
 fmov d1,#3.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 adr x9,.Lalt_six_percent
 ldr d1,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#ALT_RT0CRIAUTI]
 fmov d0,#2.0
 fmov d1,#3.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#ALT_XA1]
 ldr w9,[x20,#16]
 cbnz w9,.Lalt_hail
 mov w9,#6
 str w9,[x19,#ALT_NRR]
 mov w9,#3
 str w9,[x19,#ALT_NRRI]
 adr x10,.Lalt_old3
 ldr w9,[x10]
 b .Lalt_micro_ready
.Lalt_hail:
 mov w9,#7
 str w9,[x19,#ALT_NRR]
 mov w9,#4
 str w9,[x19,#ALT_NRRI]
 adr x10,.Lalt_old4
 ldr w9,[x10]
.Lalt_micro_ready:
 str w9,[x19,#ALT_CMICRO]
 ldp w9,w10,[x20,#8]
 orr w9,w9,w10
 mov w10,#1
 mov w11,#6
 cmp w9,#0
 csel w9,w11,w10,ne
 str w9,[x19,#ALT_NSWB_MNH]
 str wzr,[x19,#ALT_NGPAR]
 ldr w9,[x20,#20]
 str w9,[x19,#ALT_MINPRR]
 str w9,[x19,#ALT_MACPRR]
 str w9,[x19,#ALT_MINPRS]
 str w9,[x19,#ALT_MACPRS]
 str w9,[x19,#ALT_MINPRG]
 str w9,[x19,#ALT_MACPRG]
 str w9,[x19,#ALT_MALBDIR]
 str w9,[x19,#ALT_MALBSCA]
 str w9,[x19,#ALT_MVTS]
 str w9,[x19,#ALT_MVEMIS]
 str w9,[x19,#ALT_MSWDIR]
 str w9,[x19,#ALT_MSWDIF]
 str w9,[x19,#ALT_MRAIN]
 str w9,[x19,#ALT_MSNOW]
 str w9,[x19,#ALT_MVQS]
 str w9,[x19,#ALT_MLSM]
 str w9,[x19,#ALT_MGZ0]
 str w9,[x19,#ALT_MGZ0H]
 str w9,[x19,#ALT_MCD]
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_set_alternative_parameter_arithmetic_raw,.-md2asm_set_alternative_parameter_arithmetic_raw
.section .rodata
.p2align 3
.Lalt_group:
 .ascii "NAMPARAR"
.Lalt_old3:
 .ascii "OLD3"
.Lalt_old4:
 .ascii "OLD4"
.p2align 3
.Lalt_six_percent:
 .quad 0x3faeb851e0000000
.section .note.GNU-stack,"",%progbits

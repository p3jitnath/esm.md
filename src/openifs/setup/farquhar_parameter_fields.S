/* Contract: skills/md2asm/references/openifs/setup/photosynthesis_parameter_setup.md. */
/* Complete SUFARQUHAR field stage. x0 TAGF1472 with10ownedarrays,x1 optimizationnamespace1368. */
#include "photosynthesis_parameter_layout.inc.S"
.text
.p2align 4
.global md2asm_farquhar_parameter_fields
.type md2asm_farquhar_parameter_fields,%function
md2asm_farquhar_parameter_fields:
 ldr x3,[x0,#AGF_RVCMAX25]
 ldr x4,[x1,#88]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RHUMREL]
 ldr x4,[x1,#176]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RA1]
 ldr x4,[x1,#264]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RB1]
 ldr x4,[x1,#352]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RG0]
 ldr x4,[x1,#440]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RGM25]
 ldr x4,[x1,#528]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RE_VCMAX]
 ldr x4,[x1,#616]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RE_JMAX]
 ldr x4,[x1,#704]
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RDOWNREGULATION_CO2_COEF]
 adr x4,.Lfarquhar_RDOWNREGULATION_CO2_COEF
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 ldr x3,[x0,#AGF_RSTRUCT_CONST]
 adr x4,.Lfarquhar_RSTRUCT_CONST
 mov x5,#40
1: ldr x6,[x4],#8
 str x6,[x3],#8
 subs x5,x5,#1
 b.ne 1b
 adr x3,.Lfarquhar_NLAI
 ldr w4,[x3,#0]
 str w4,[x0,#0]
 adr x3,.Lfarquhar_NLAI1
 ldr w4,[x3,#0]
 str w4,[x0,#4]
 adr x3,.Lfarquhar_NPATH
 ldr w4,[x3,#0]
 str w4,[x0,#8]
 adr x3,.Lfarquhar_RDOWNREGULATION_CO2_BASELEVEL
 ldr x4,[x3,#0]
 str x4,[x0,#16]
 adr x3,.Lfarquhar_RDOWNREGULATION_CO2_MINIMUM
 ldr x4,[x3,#0]
 str x4,[x0,#24]
 adr x3,.Lfarquhar_RUNDEF_SECHIBA
 ldr x4,[x3,#0]
 str x4,[x0,#32]
 adr x3,.Lfarquhar_RUNDEF
 ldr x4,[x3,#0]
 str x4,[x0,#40]
 adr x3,.Lfarquhar_RONE_MONTH
 ldr x4,[x3,#0]
 str x4,[x0,#48]
 adr x3,.Lfarquhar_RARJV
 ldr x4,[x3,#0]
 str x4,[x0,#56]
 ldr x4,[x3,#8]
 str x4,[x0,#64]
 adr x3,.Lfarquhar_RBRJV
 ldr x4,[x3,#0]
 str x4,[x0,#72]
 ldr x4,[x3,#8]
 str x4,[x0,#80]
 adr x3,.Lfarquhar_RASJ
 ldr x4,[x3,#0]
 str x4,[x0,#88]
 ldr x4,[x3,#8]
 str x4,[x0,#96]
 adr x3,.Lfarquhar_RBSJ
 ldr x4,[x3,#0]
 str x4,[x0,#104]
 ldr x4,[x3,#8]
 str x4,[x0,#112]
 adr x3,.Lfarquhar_RASV
 ldr x4,[x3,#0]
 str x4,[x0,#120]
 ldr x4,[x3,#8]
 str x4,[x0,#128]
 adr x3,.Lfarquhar_RBSV
 ldr x4,[x3,#0]
 str x4,[x0,#136]
 ldr x4,[x3,#8]
 str x4,[x0,#144]
 adr x3,.Lfarquhar_RD_VCMAX
 ldr x4,[x3,#0]
 str x4,[x0,#152]
 ldr x4,[x3,#8]
 str x4,[x0,#160]
 adr x3,.Lfarquhar_RD_JMAX
 ldr x4,[x3,#0]
 str x4,[x0,#168]
 ldr x4,[x3,#8]
 str x4,[x0,#176]
 adr x3,.Lfarquhar_RE_GAMMA_STAR
 ldr x4,[x3,#0]
 str x4,[x0,#184]
 adr x3,.Lfarquhar_RE_GM
 ldr x4,[x3,#0]
 str x4,[x0,#192]
 ldr x4,[x3,#8]
 str x4,[x0,#200]
 adr x3,.Lfarquhar_RS_GM
 ldr x4,[x3,#0]
 str x4,[x0,#208]
 ldr x4,[x3,#8]
 str x4,[x0,#216]
 adr x3,.Lfarquhar_RS_JMAX
 ldr x4,[x3,#0]
 str x4,[x0,#224]
 ldr x4,[x3,#8]
 str x4,[x0,#232]
 adr x3,.Lfarquhar_RD_GM
 ldr x4,[x3,#0]
 str x4,[x0,#240]
 ldr x4,[x3,#8]
 str x4,[x0,#248]
 adr x3,.Lfarquhar_RE_KMC
 ldr x4,[x3,#0]
 str x4,[x0,#256]
 adr x3,.Lfarquhar_RE_KMO
 ldr x4,[x3,#0]
 str x4,[x0,#264]
 adr x3,.Lfarquhar_RE_RD
 ldr x4,[x3,#0]
 str x4,[x0,#272]
 adr x3,.Lfarquhar_RE_SCO
 ldr x4,[x3,#0]
 str x4,[x0,#280]
 adr x3,.Lfarquhar_RGAMMA_STAR25
 ldr x4,[x3,#0]
 str x4,[x0,#288]
 adr x3,.Lfarquhar_RKMC25
 ldr x4,[x3,#0]
 str x4,[x0,#296]
 ldr x4,[x3,#8]
 str x4,[x0,#304]
 adr x3,.Lfarquhar_RKMO25
 ldr x4,[x3,#0]
 str x4,[x0,#312]
 ldr x4,[x3,#8]
 str x4,[x0,#320]
 adr x3,.Lfarquhar_RSCO25
 ldr x4,[x3,#0]
 str x4,[x0,#328]
 ldr x4,[x3,#8]
 str x4,[x0,#336]
 adr x3,.Lfarquhar_RSTRESS_GM
 ldr x4,[x3,#0]
 str x4,[x0,#344]
 adr x3,.Lfarquhar_RSTRESS_GS
 ldr x4,[x3,#0]
 str x4,[x0,#352]
 adr x3,.Lfarquhar_RSTRESS_VCMAX
 ldr x4,[x3,#0]
 str x4,[x0,#360]
 adr x3,.Lfarquhar_RTPHOTO_MAX
 ldr x4,[x3,#0]
 str x4,[x0,#368]
 adr x3,.Lfarquhar_RTPHOTO_MIN
 ldr x4,[x3,#0]
 str x4,[x0,#376]
 adr x3,.Lfarquhar_RLAI_LEVEL_DEPTH
 ldr x4,[x3,#0]
 str x4,[x0,#1264]
 adr x3,.Lfarquhar_RLAIMAX
 ldr x4,[x3,#0]
 str x4,[x0,#1272]
 adr x3,.Lfarquhar_REXT_COEFF
 ldr x4,[x3,#0]
 str x4,[x0,#1280]
 adr x3,.Lfarquhar_RGB_REF
 ldr x4,[x3,#0]
 str x4,[x0,#1288]
 adr x3,.Lfarquhar_RTP_00
 ldr x4,[x3,#0]
 str x4,[x0,#1296]
 adr x3,.Lfarquhar_RPB_STD
 ldr x4,[x3,#0]
 str x4,[x0,#1304]
 adr x3,.Lfarquhar_RRG_TO_PAR
 ldr x4,[x3,#0]
 str x4,[x0,#1312]
 adr x3,.Lfarquhar_RW_TO_MOL
 ldr x4,[x3,#0]
 str x4,[x0,#1320]
 adr x3,.Lfarquhar_RALPHA_LL
 ldr x4,[x3,#0]
 str x4,[x0,#1328]
 adr x3,.Lfarquhar_RTHETA
 ldr x4,[x3,#0]
 str x4,[x0,#1336]
 adr x3,.Lfarquhar_RFPSIR
 ldr x4,[x3,#0]
 str x4,[x0,#1344]
 adr x3,.Lfarquhar_RFQ
 ldr x4,[x3,#0]
 str x4,[x0,#1352]
 adr x3,.Lfarquhar_RFPSEUDO
 ldr x4,[x3,#0]
 str x4,[x0,#1360]
 adr x3,.Lfarquhar_RH_PROTONS
 ldr x4,[x3,#0]
 str x4,[x0,#1368]
 adr x3,.Lfarquhar_RGBS
 ldr x4,[x3,#0]
 str x4,[x0,#1376]
 adr x3,.Lfarquhar_ROI
 ldr x4,[x3,#0]
 str x4,[x0,#1384]
 adr x3,.Lfarquhar_RALPHA
 ldr x4,[x3,#0]
 str x4,[x0,#1392]
 adr x3,.Lfarquhar_RKP
 ldr x4,[x3,#0]
 str x4,[x0,#1400]
 adr x3,.Lfarquhar_RTETENS_1
 ldr x4,[x3,#0]
 str x4,[x0,#1408]
 adr x3,.Lfarquhar_RTETENS_2
 ldr x4,[x3,#0]
 str x4,[x0,#1416]
 adr x3,.Lfarquhar_RREF_TEMP
 ldr x4,[x3,#0]
 str x4,[x0,#1424]
 adr x3,.Lfarquhar_RMOL_TO_M_1
 ldr x4,[x3,#0]
 str x4,[x0,#1432]
 adr x3,.Lfarquhar_RRATIO_H2O_TO_CO2
 ldr x4,[x3,#0]
 str x4,[x0,#1440]
 adr x3,.Lfarquhar_RN_VERT_ATT
 ldr x4,[x3,#0]
 str x4,[x0,#1448]
 adr x3,.Lfarquhar_RRVEG_PFT
 ldr x4,[x3,#0]
 str x4,[x0,#1456]
 adr x3,.Lfarquhar_RTAU_TEMP_AIR_MONTH
 ldr x4,[x3,#0]
 str x4,[x0,#1464]
 ret
.size md2asm_farquhar_parameter_fields,.-md2asm_farquhar_parameter_fields
.section .rodata
.p2align 3
.Lfarquhar_NLAI:
.word 20
.p2align 3
.Lfarquhar_NLAI1:
.word 21
.p2align 3
.Lfarquhar_NPATH:
.word 2
.p2align 3
.Lfarquhar_RDOWNREGULATION_CO2_BASELEVEL:
.quad 0x4077c00000000000
.p2align 3
.Lfarquhar_RDOWNREGULATION_CO2_MINIMUM:
.quad 0x4071800000000000
.p2align 3
.Lfarquhar_RUNDEF_SECHIBA:
.quad 0x4415af1d78b58c40
.p2align 3
.Lfarquhar_RUNDEF:
.quad 0xc0c3878000000000
.p2align 3
.Lfarquhar_RONE_MONTH:
.quad 0x4143c68000000000
.p2align 3
.Lfarquhar_RARJV:
.quad 0x4004b851eb851eb8
.quad 0x3ffb70a3d70a3d71
.p2align 3
.Lfarquhar_RBRJV:
.quad 0xbfa1eb851eb851ec
.quad 0x0000000000000000
.p2align 3
.Lfarquhar_RASJ:
.quad 0x40849d999999999a
.quad 0x4083b00000000000
.p2align 3
.Lfarquhar_RBSJ:
.quad 0xbfe8000000000000
.quad 0x0000000000000000
.p2align 3
.Lfarquhar_RASV:
.quad 0x4084e31eb851eb85
.quad 0x40840d1eb851eb85
.p2align 3
.Lfarquhar_RBSV:
.quad 0xbff11eb851eb851f
.quad 0x0000000000000000
.p2align 3
.Lfarquhar_RD_VCMAX:
.quad 0x41086a0000000000
.quad 0x4107700000000000
.p2align 3
.Lfarquhar_RD_JMAX:
.quad 0x41086a0000000000
.quad 0x4107700000000000
.p2align 3
.Lfarquhar_RE_GAMMA_STAR:
.quad 0x40e278c000000000
.p2align 3
.Lfarquhar_RE_GM:
.quad 0x40e8380000000000
.quad 0xc0c3878000000000
.p2align 3
.Lfarquhar_RS_GM:
.quad 0x4095e00000000000
.quad 0xc0c3878000000000
.p2align 3
.Lfarquhar_RS_JMAX:
.quad 0x4084500000000000
.quad 0x4083b00000000000
.p2align 3
.Lfarquhar_RD_GM:
.quad 0x411ab26000000000
.quad 0xc0c3878000000000
.p2align 3
.Lfarquhar_RE_KMC:
.quad 0x40f3646000000000
.p2align 3
.Lfarquhar_RE_KMO:
.quad 0x40e1c38000000000
.p2align 3
.Lfarquhar_RE_RD:
.quad 0x40e6a6c000000000
.p2align 3
.Lfarquhar_RE_SCO:
.quad 0xc0d7e30000000000
.p2align 3
.Lfarquhar_RGAMMA_STAR25:
.quad 0x4045600000000000
.p2align 3
.Lfarquhar_RKMC25:
.quad 0x40794e6666666666
.quad 0x4084500000000000
.p2align 3
.Lfarquhar_RKMO25:
.quad 0x4110fe0000000000
.quad 0x411b774000000000
.p2align 3
.Lfarquhar_RSCO25:
.quad 0x40a5e00000000000
.quad 0x40a43c0000000000
.p2align 3
.Lfarquhar_RSTRESS_GM:
.quad 0x3ff0000000000000
.p2align 3
.Lfarquhar_RSTRESS_GS:
.quad 0x3ff0000000000000
.p2align 3
.Lfarquhar_RSTRESS_VCMAX:
.quad 0x3ff0000000000000
.p2align 3
.Lfarquhar_RTPHOTO_MAX:
.quad 0x404b800000000000
.p2align 3
.Lfarquhar_RTPHOTO_MIN:
.quad 0xc010000000000000
.p2align 3
.Lfarquhar_RLAI_LEVEL_DEPTH:
.quad 0x3fc3333333333333
.p2align 3
.Lfarquhar_RLAIMAX:
.quad 0x4028000000000000
.p2align 3
.Lfarquhar_REXT_COEFF:
.quad 0x3fe0000000000000
.p2align 3
.Lfarquhar_RGB_REF:
.quad 0x3fa47ae147ae147b
.p2align 3
.Lfarquhar_RTP_00:
.quad 0x4071126666666666
.p2align 3
.Lfarquhar_RPB_STD:
.quad 0x408fa80000000000
.p2align 3
.Lfarquhar_RRG_TO_PAR:
.quad 0x3fe0000000000000
.p2align 3
.Lfarquhar_RW_TO_MOL:
.quad 0x4012666666666666
.p2align 3
.Lfarquhar_RALPHA_LL:
.quad 0x3fd3333333333333
.p2align 3
.Lfarquhar_RTHETA:
.quad 0x3fe6666666666666
.p2align 3
.Lfarquhar_RFPSIR:
.quad 0x3fd999999999999a
.p2align 3
.Lfarquhar_RFQ:
.quad 0x3ff0000000000000
.p2align 3
.Lfarquhar_RFPSEUDO:
.quad 0x3fb999999999999a
.p2align 3
.Lfarquhar_RH_PROTONS:
.quad 0x4010000000000000
.p2align 3
.Lfarquhar_RGBS:
.quad 0x3f689374bc6a7efa
.p2align 3
.Lfarquhar_ROI:
.quad 0x4109a28000000000
.p2align 3
.Lfarquhar_RALPHA:
.quad 0x3fb999999999999a
.p2align 3
.Lfarquhar_RKP:
.quad 0x3fe6666666666666
.p2align 3
.Lfarquhar_RTETENS_1:
.quad 0x3fe3e76c8b439581
.p2align 3
.Lfarquhar_RTETENS_2:
.quad 0x3fd83126e978d4fe
.p2align 3
.Lfarquhar_RREF_TEMP:
.quad 0x4072a00000000000
.p2align 3
.Lfarquhar_RMOL_TO_M_1:
.quad 0x3f98fc5040000000
.p2align 3
.Lfarquhar_RRATIO_H2O_TO_CO2:
.quad 0x3ff99999a0000000
.p2align 3
.Lfarquhar_RN_VERT_ATT:
.quad 0x3fe6666666666666
.p2align 3
.Lfarquhar_RRVEG_PFT:
.quad 0x3ff0000000000000
.p2align 3
.Lfarquhar_RTAU_TEMP_AIR_MONTH:
.quad 0x413a5e0000000000
.p2align 3
.Lfarquhar_RDOWNREGULATION_CO2_COEF:
.quad 0x3fceb851eb851eb8
.quad 0x3fceb851eb851eb8
.quad 0x3fc999999999999a
.quad 0x3fc999999999999a
.quad 0x3fd0a3d70a3d70a4
.quad 0x3fd0a3d70a3d70a4
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0x3fceb851eb851eb8
.quad 0x3fceb851eb851eb8
.quad 0x3f9eb851eb851eb8
.quad 0xc0c3878000000000
.quad 0x3fceb851eb851eb8
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0x3f9eb851eb851eb8
.quad 0x3fceb851eb851eb8
.quad 0x3fd0a3d70a3d70a4
.quad 0x3fd0a3d70a3d70a4
.quad 0xc0c3878000000000
.quad 0x3f9eb851eb851eb8
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0x3f9eb851eb851eb8
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.Lfarquhar_RSTRUCT_CONST:
.quad 0x4000000000000000
.quad 0x4004000000000000
.quad 0x4039000000000000
.quad 0x4039000000000000
.quad 0x4039000000000000
.quad 0x4039000000000000
.quad 0xc0c3878000000000
.quad 0x0000000000000000
.quad 0x4004000000000000
.quad 0x4000000000000000
.quad 0x4000000000000000
.quad 0xc0c3878000000000
.quad 0x4004000000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0x4000000000000000
.quad 0x4004000000000000
.quad 0x4039000000000000
.quad 0x4039000000000000
.quad 0xc0c3878000000000
.quad 0x4000000000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0x4000000000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.quad 0xc0c3878000000000
.section .note.GNU-stack,"",%progbits

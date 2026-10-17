// The default entry keeps the complete original serial ABI and frame.
// MD2ASM_CLOUD_PRIVATE_RANGE selects a controller-only range: x0 points to
// 76 original argument words, x1/x2 are global half-open column bounds,
// x3 is 320*(N+1) bytes of private scratch, and x4 is the worker errno address.
// Incoming x28 points to a separate 64-byte private counter prefix.
// Saved x29 holds the parameter record; this private entry has no frame chain.
// The controller validates the public contract and owns setup, clear and join.
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
#define CLOUD_PARAMETERS x29
#define CLOUD_POWER md2asm_cloud_private_pow
#define CLOUD_EXP md2asm_cloud_private_exp
#define CLOUD_SUPERSAT md2asm_cloud_private_supersatcheck
#define CLOUD_ENTRY md2asm_cloudsc_private_counter_range
#else
#define CLOUD_PARAMETERS x28
#define CLOUD_POWER md2asm_pow_original_rounding_candidate
#define CLOUD_EXP exp
#define CLOUD_SUPERSAT md2asm_cloud_supersatcheck
#define CLOUD_ENTRY md2asm_cloudsc_complete
#endif
/* Direct AArch64 CLOUDSC from the frozen source-ordered contract.
 * Physics formulations/openifs/physics/cloud_water_and_rain.md.
 * Contract skills/md2asm/references/openifs/cloud_microphysics_contract.md.
 * Preserve exponent types, source operation routes and every FP64 rounding point. */
.text
.arch armv8-a
.equ ZERO, 0
.equ ONE, 8
.equ HALF, 16
.equ EPS, 24
.equ SMALL, 32
.equ DT, 40
.equ INVDT, 48
.equ RG, 56
.equ RD, 64
.equ CP, 72
.equ RV, 80
.equ RETV, 88
.equ RTT, 96
.equ LV, 104
.equ LS, 112
.equ ALV, 120
.equ ALS, 128
.equ ALF, 136
.equ R2ES, 144
.equ R3L, 152
.equ R3I, 160
.equ R4L, 168
.equ R4I, 176
.equ R5L, 184
.equ R5I, 192
.equ RTWAT, 200
.equ RTICE, 208
.equ RTINV, 216
.equ KOOP1, 224
.equ KOOP2, 232
.equ GDCP, 240
.equ RDCP, 248
.equ RGR, 256
.equ RLDCP, 264
.equ ADVW, 272
.equ ADVWD, 280
.equ TRPAUS, 288
.equ PSURFINV, 296
.equ COVPTOT, 304
.equ COVPCLR, 312
.equ COVPMAX, 320
.equ CLDTOPDIST, 328
.equ ANEWM1, 336
.equ DA, 344
.equ LLRAIN, 352
.equ TMP0, 360
.equ TMP1, 368
.equ TMP2, 376
.equ TMP3, 384
.equ TMP4, 392
.equ TMP5, 400
.equ TMP6, 408
.equ TMP7, 416
.equ T, 424
.equ A, 432
.equ AOR, 440
.equ QL, 448
.equ QI, 456
.equ QR, 464
.equ QS, 472
.equ QV, 480
.equ QL0, 488
.equ QI0, 496
.equ QR0, 504
.equ QS0, 512
.equ QV0, 520
.equ ALFA, 528
.equ QSM, 536
.equ QSL, 544
.equ QSI, 552
.equ FOM, 560
.equ FOI, 568
.equ FOL, 576
.equ LI, 584
.equ LIF, 592
.equ IIF, 600
.equ P, 608
.equ PH, 616
.equ PHNEXT, 624
.equ PHM1, 632
.equ PM1, 640
.equ TM1, 648
.equ AM1, 656
.equ DTGDP, 664
.equ RDTGDP, 672
.equ DTGDPF, 680
.equ DP, 688
.equ GDP, 696
.equ RHO, 704
.equ FACW, 712
.equ FACI, 720
.equ COR, 728
.equ DQSL, 736
.equ DQSI, 744
.equ DQSM, 752
.equ CORQSL, 760
.equ CORQSI, 768
.equ CORQSM, 776
.equ EVAPM, 784
.equ EVAPL, 792
.equ EVAPI, 800
.equ LIQCLD, 808
.equ ICECLD, 816
.equ LICLD, 824
.equ SOLAB, 832
.equ SOLAC, 840
.equ MF, 848
.equ ACUST, 856
.equ LCUSTL, 864
.equ LCUSTI, 872
.equ LFINAL, 880
.equ LFINALSUM, 888
.equ DTDP, 896
.equ WTOT, 904
.equ DTFORC, 912
.equ DQS, 920
.equ EVAP, 928
.equ MFDN, 936
.equ LDIFDT, 944
.equ QE, 952
.equ E, 960
.equ LEROS, 968
.equ AEROS, 976
.equ FALLCORR, 984
.equ TEMP, 992
.equ RLAMBDA, 1000
.equ PRETOT, 1008
.equ RAINCLD, 1016
.equ RAINCLDM1, 1024
.equ SNOWCLD, 1032
.equ SNOWCLDM1, 1040
.equ RAINAUT, 1048
.equ RAINACC, 1056
.equ LCRIT, 1064
.equ FACTOR, 1072
.equ IND, 1080
.equ RH0, 1088
.equ QCLR, 1096
.equ CORR, 1104
.equ RAINEVAP, 1112
.equ BETA, 1120
.equ LAMBDA, 1128
.equ DENOM, 1136
.equ VPD, 1144
.equ VTEMP, 1152
.equ ICEINIT, 1160
.equ CVDS, 1168
.equ ICEDEP, 1176
.equ IGET, 1184
.equ ICE0, 1192
.equ ICEAFTER, 1200
.equ DEPRATE, 1208
.equ ICETOT, 1216
.equ GROW, 1224
.equ RATE, 1232
.equ REMAINDER, 1240
.equ TC, 1248
.equ FAC, 1256
.equ FREEZE, 1264
.equ MELT, 1272
.equ MAXMELT, 1280
.equ WETBULB, 1288
.equ RR, 1296
.equ RACI, 1304
.equ RACR, 1312
.equ RICS, 1320
.equ PRACI, 1328
.equ PSACR, 1336
.equ RIMELIQ, 1344
.equ RIMESNOW, 1352
.equ RIME, 1360
.equ QPRE, 1368
.equ QPRENEW, 1376
.equ RHLIMIT, 1384
.equ RHNEW, 1392
.equ RAINFLUX, 1400
.equ QNEW, 1408
.equ SUMRHS, 1416
.equ SINKSUM, 1424
.equ RATIO, 1432
.equ RAT, 1440
.equ MAXVAL, 1448
.equ ZZRATIO, 1456
.equ DA0, 1464
.equ TUP, 1472
.equ QUP, 1480
.equ AUP, 1488
.equ TADJ, 1496
.equ QADJ, 1504
.equ AADJ, 1512
.equ LADJ, 1520
.equ IADJ, 1528
.equ FLUXQ, 1536
.equ AQNEW, 1544
.equ GDPHR, 1552
.equ DT_TEMP, 1560
.equ WATERLOSS, 1568
.equ HLOSS, 1576
.equ SIGNTMP, 1584
.equ QLNEG, 1592
.equ QINEG, 1600
.equ QRNEG, 1608
.equ QSNEG, 1616
.equ QLXN, 1624
.equ QIXN, 1632
.equ QRXN, 1640
.equ QSXN, 1648
.equ PVAL, 1656
.equ PVAL2, 1664
.equ PVAL3, 1672
.equ FG1, 1680
.equ FG2, 1688
.equ FG3, 1696
.equ FG4, 1704
.equ FG5, 1712
.equ PREV1, 1720
.equ PREV2, 1728
.equ PREV3, 1736
.equ PREV4, 1744
.equ PREV5, 1752
.equ FALLSPD1, 1760
.equ FALLSPD2, 1768
.equ FALLSPD3, 1776
.equ FALLSPD4, 1784
.equ FALLSPD5, 1792
.equ FALLSRC1, 1800
.equ FALLSRC2, 1808
.equ FALLSRC3, 1816
.equ FALLSRC4, 1824
.equ FALLSRC5, 1832
.equ FALLSINK1, 1840
.equ FALLSINK2, 1848
.equ FALLSINK3, 1856
.equ FALLSINK4, 1864
.equ FALLSINK5, 1872
.equ CONVSRC1, 1880
.equ CONVSRC2, 1888
.equ CONVSRC3, 1896
.equ CONVSRC4, 1904
.equ CONVSRC5, 1912
.equ CONVSINK1, 1920
.equ CONVSINK2, 1928
.equ CONVSINK3, 1936
.equ CONVSINK4, 1944
.equ CONVSINK5, 1952
.equ XN1, 1960
.equ XN2, 1968
.equ XN3, 1976
.equ XN4, 1984
.equ XN5, 1992
.equ RHS1, 2000
.equ RHS2, 2008
.equ RHS3, 2016
.equ RHS4, 2024
.equ RHS5, 2032
.equ RATIOS1, 2040
.equ RATIOS2, 2048
.equ RATIOS3, 2056
.equ RATIOS4, 2064
.equ RATIOS5, 2072
.equ QA11, 2080
.equ QA21, 2088
.equ QA31, 2096
.equ QA41, 2104
.equ QA51, 2112
.equ QA12, 2120
.equ QA22, 2128
.equ QA32, 2136
.equ QA42, 2144
.equ QA52, 2152
.equ QA13, 2160
.equ QA23, 2168
.equ QA33, 2176
.equ QA43, 2184
.equ QA53, 2192
.equ QA14, 2200
.equ QA24, 2208
.equ QA34, 2216
.equ QA44, 2224
.equ QA54, 2232
.equ QA15, 2240
.equ QA25, 2248
.equ QA35, 2256
.equ QA45, 2264
.equ QA55, 2272
.equ QB11, 2280
.equ QB21, 2288
.equ QB31, 2296
.equ QB41, 2304
.equ QB51, 2312
.equ QB12, 2320
.equ QB22, 2328
.equ QB32, 2336
.equ QB42, 2344
.equ QB52, 2352
.equ QB13, 2360
.equ QB23, 2368
.equ QB33, 2376
.equ QB43, 2384
.equ QB53, 2392
.equ QB14, 2400
.equ QB24, 2408
.equ QB34, 2416
.equ QB44, 2424
.equ QB54, 2432
.equ QB15, 2440
.equ QB25, 2448
.equ QB35, 2456
.equ QB45, 2464
.equ QB55, 2472
.equ LHS11, 2480
.equ LHS21, 2488
.equ LHS31, 2496
.equ LHS41, 2504
.equ LHS51, 2512
.equ LHS12, 2520
.equ LHS22, 2528
.equ LHS32, 2536
.equ LHS42, 2544
.equ LHS52, 2552
.equ LHS13, 2560
.equ LHS23, 2568
.equ LHS33, 2576
.equ LHS43, 2584
.equ LHS53, 2592
.equ LHS14, 2600
.equ LHS24, 2608
.equ LHS34, 2616
.equ LHS44, 2624
.equ LHS54, 2632
.equ LHS15, 2640
.equ LHS25, 2648
.equ LHS35, 2656
.equ LHS45, 2664
.equ LHS55, 2672
.equ LAMR, 2680
.equ LAMS, 2688
.equ LAMI, 2696
.equ N0R, 2704
.equ N0S, 2712
.equ N0I, 2720
.equ FALLDIFF, 2728
.equ PI, 2736
.equ PSURF, 2744
.equ P_LAERICEAUTO, 1128
.equ P_LAERICESED, 1124
.equ P_LAERLIQAUTOLSP, 1108
.equ P_LAERLIQCOLL, 1120
.equ P_LCLDBUDC, 1048
.equ P_LCLDBUDGET, 1044
.equ P_LCLDBUDI, 1056
.equ P_LCLDBUDL, 1052
.equ P_LCLDBUDT, 1060
.equ P_LCLDBUD_TIMEINT, 1064
.equ P_LCLDBUD_VERTINT, 1068
.equ P_LCLOUD_INHOMOG, 400
.equ P_NCLDTOP, 1076
.equ P_NSSOPT, 1072
.equ P_RAMID, 0
.equ P_RAMIN, 112
.equ P_RCCN, 240
.equ P_RCLCRIT_LAND, 40
.equ P_RCLCRIT_SEA, 32
.equ P_RCLDIFF, 8
.equ P_RCLDIFF_CONVI, 16
.equ P_RCLDTOPCF, 280
.equ P_RCL_APB1, 544
.equ P_RCL_APB2, 552
.equ P_RCL_APB3, 560
.equ P_RCL_CDENOM1, 816
.equ P_RCL_CDENOM2, 824
.equ P_RCL_CDENOM3, 832
.equ P_RCL_CONST10R, 976
.equ P_RCL_CONST1I, 472
.equ P_RCL_CONST1R, 856
.equ P_RCL_CONST1S, 632
.equ P_RCL_CONST2I, 480
.equ P_RCL_CONST2R, 864
.equ P_RCL_CONST2S, 640
.equ P_RCL_CONST3I, 488
.equ P_RCL_CONST3R, 872
.equ P_RCL_CONST3S, 648
.equ P_RCL_CONST4I, 496
.equ P_RCL_CONST4R, 880
.equ P_RCL_CONST4S, 656
.equ P_RCL_CONST5I, 504
.equ P_RCL_CONST5R, 936
.equ P_RCL_CONST5S, 664
.equ P_RCL_CONST6I, 512
.equ P_RCL_CONST6R, 944
.equ P_RCL_CONST6S, 672
.equ P_RCL_CONST7I, 520
.equ P_RCL_CONST7R, 888
.equ P_RCL_CONST7S, 680
.equ P_RCL_CONST8R, 896
.equ P_RCL_CONST8S, 688
.equ P_RCL_CONST9R, 968
.equ P_RCL_DI, 432
.equ P_RCL_DR, 752
.equ P_RCL_EFFRIME, 312
.equ P_RCL_EFF_RACW, 984
.equ P_RCL_FZRAB, 952
.equ P_RCL_INHOMOGACC, 392
.equ P_RCL_INHOMOGAUT, 384
.equ P_RCL_KA273, 808
.equ P_RCL_KKAAC, 328
.equ P_RCL_KKAAU, 344
.equ P_RCL_KKBAC, 336
.equ P_RCL_KKBAUN, 360
.equ P_RCL_KKBAUQ, 352
.equ P_RCL_KK_CLOUD_NUM_LAND, 376
.equ P_RCL_KK_CLOUD_NUM_SEA, 368
.equ P_RCL_LAM1R, 904
.equ P_RCL_LAM1R_MP, 920
.equ P_RCL_LAM1S, 696
.equ P_RCL_LAM2R, 912
.equ P_RCL_LAM2R_MP, 928
.equ P_RCL_LAM2S, 704
.equ P_RCL_LAMBDA1I, 528
.equ P_RCL_LAMBDA2I, 536
.equ P_RCL_OVERLAPLIQICE, 304
.equ P_RCL_X1R, 760
.equ P_RCL_X1R_MP, 784
.equ P_RCL_X1S, 600
.equ P_RCL_X2R, 768
.equ P_RCL_X2R_MP, 792
.equ P_RCL_X2S, 608
.equ P_RCL_X3I, 456
.equ P_RCOVPMIN, 232
.equ P_RDENSREF, 720
.equ P_RDENSWAT, 712
.equ P_RDEPLIQREFDEPTH, 296
.equ P_RDEPLIQREFRATE, 288
.equ P_RICEHI1, 176
.equ P_RICEHI2, 184
.equ P_RICEINIT, 192
.equ P_RKCONV, 48
.equ P_RKOOPTAU, 128
.equ P_RLCRITSNOW, 152
.equ P_RLMIN, 120
.equ P_RNICE, 248
.equ P_RPECONS, 80
.equ P_RPRC1, 56
.equ P_RPRECRHMAX, 96
.equ P_RSNOWLIN1, 160
.equ P_RSNOWLIN2, 168
.equ P_RTAUMEL, 104
.equ P_RTHOMO, 224
.equ P_RVICE, 200
.equ P_RVRAIN, 208
.equ P_RVRFACTOR, 88
.equ P_RVSNOW, 216

.macro LD reg, name
 ldr \reg, [x20, #\name]
.endm
.macro ST reg, name
 str \reg, [x20, #\name]
.endm
.macro COPY dst, src
 LD d0, \src
 ST d0, \dst
.endm
.macro ZER dst
 str xzr, [x20, #\dst]
.endm
.macro F_ADD dst, left, right
 LD d0, \left
 LD d1, \right
 fadd d0, d0, d1
 ST d0, \dst
.endm
.macro F_SUB dst, left, right
 LD d0, \left
 LD d1, \right
 fsub d0, d0, d1
 ST d0, \dst
.endm
.macro F_MUL dst, left, right
 LD d0, \left
 LD d1, \right
 fmul d0, d0, d1
 ST d0, \dst
.endm
.macro F_DIV dst, left, right
 LD d0, \left
 LD d1, \right
 fdiv d0, d0, d1
 ST d0, \dst
.endm
.macro F_MIN dst, left, right
 LD d0, \left
 LD d1, \right
 fminnm d0, d0, d1
 ST d0, \dst
.endm
.macro F_MAX dst, left, right
 LD d0, \left
 LD d1, \right
 fmaxnm d0, d0, d1
 ST d0, \dst
.endm
.macro F_NEG dst, src
 LD d0, \src
 fneg d0, d0
 ST d0, \dst
.endm
.macro F_ABS dst, src
 LD d0, \src
 fabs d0, d0
 ST d0, \dst
.endm
.macro F_SQRT dst, src
 LD d0, \src
 fsqrt d0, d0
 ST d0, \dst
.endm
.macro EXP dst, src
 LD d0, \src
 bl CLOUD_EXP
 ST d0, \dst
.endm
.macro POW dst, base, exponent
 LD d0, \base
 LD d1, \exponent
 bl CLOUD_POWER
 ST d0, \dst
.endm
.macro F_CMP left, right
 LD d0, \left
 LD d1, \right
 fcmp d0, d1
.endm
.macro GLOB dst, symbol
 adrp x9, :got:\symbol
 ldr x9, [x9, :got_lo12:\symbol]
 ldr d0, [x9]
 ST d0, \dst
.endm
.macro LIT dst, label
 adrp x9, \label
 add x9, x9, :lo12:\label
 ldr d0, [x9]
 ST d0, \dst
.endm
.macro PAR dst, field
 ldr d0, [CLOUD_PARAMETERS, #P_\field]
 ST d0, \dst
.endm
.macro CUM dst, offset
 ldr x9, [x19, #8]
 ldr d0, [x9, #\offset]
 ST d0, \dst
.endm
.macro OWN dst, arg, plane=0, next=0
 ldr x9, [x19, #(8*\arg)]
 add x9, x9, x26
 .if \plane
 mov x10, #\plane
 madd x9, x27, x10, x9
 .endif
 .if \next == 1
 add x9, x9, x23, lsl #3
 .elseif \next == -1
 sub x9, x9, x23, lsl #3
 .endif
 ldr d0, [x9]
 ST d0, \dst
.endm
.macro PUT arg, src, plane=0, next=0
 ldr x9, [x19, #(8*\arg)]
 add x9, x9, x26
 .if \plane
 mov x10, #\plane
 madd x9, x27, x10, x9
 .endif
 .if \next == 1
 add x9, x9, x23, lsl #3
 .elseif \next == -1
 sub x9, x9, x23, lsl #3
 .endif
 LD d0, \src
 str d0, [x9]
.endm
.macro COL dst, arg
 ldr x9, [x19, #(8*\arg)]
 ldr d0, [x9, x24, lsl #3]
 ST d0, \dst
.endm
.macro COLI reg, arg
 ldr x9, [x19, #(8*\arg)]
 ldr \reg, [x9, x24, lsl #2]
.endm
.macro ROW dst, offset, previous=0
 .if \previous
 sub x9, x21, #320
 ldr d0, [x9, #\offset]
 .else
 ldr d0, [x21, #\offset]
 .endif
 ST d0, \dst
.endm
.macro SAVE src, offset
 LD d0, \src
 str d0, [x21, #\offset]
.endm
.macro CELL_INDEX
 madd x26, x25, x23, x24
 lsl x26, x26, #3
.endm

.global CLOUD_ENTRY
.type CLOUD_ENTRY, %function
CLOUD_ENTRY:
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
 cmp x1,x2
 b.eq .Lcloud_range_empty
#endif
 sub sp, sp, #2, lsl #12
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
 str x1,[sp,#968]
 str x2,[sp,#976]
 str x3,[sp,#984]
 str x4,[sp,#992]
#endif
 stp x29, x30, [sp]
#ifndef MD2ASM_CLOUD_PRIVATE_RANGE
 mov x29, sp
#endif
 stp x19, x20, [sp, #16]
 stp x21, x22, [sp, #32]
 stp x23, x24, [sp, #48]
 stp x25, x26, [sp, #64]
 stp x27, x28, [sp, #80]
 str x18, [sp, #96]
 stp d8, d9, [sp, #112]
 stp d10, d11, [sp, #128]
 stp d12, d13, [sp, #144]
 stp d14, d15, [sp, #160]
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
 add x19,sp,#256
 mov x9,x0
 mov x10,x19
 mov x11,#76
.Lcopy_range_arguments:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcopy_range_arguments
#else
 add x19, sp, #256
 stp x0, x1, [x19]
 stp x2, x3, [x19, #16]
 stp x4, x5, [x19, #32]
 stp x6, x7, [x19, #48]
 add x9, sp, #2, lsl #12
 add x10, x19, #64
 mov x11, #68
.Lcopy_arguments:
 ldr x12, [x9], #8
 str x12, [x10], #8
 subs x11, x11, #1
 b.ne .Lcopy_arguments
#endif
 add x20, sp, #1280
 ldr CLOUD_PARAMETERS, [x19]
 mrs x9, fpcr
 cbnz x9, .Lreject
 ldr x9, [x19, #72]
 ldr w23, [x9]
 cmp w23, #1
 b.lt .Lreject
 cmp w23, #4096
 b.gt .Lreject
 ldr x9, [x19, #80]
 ldr w22, [x9]
 cmp w22, #2
 b.lt .Lreject
 cmp w22, #256
 b.gt .Lreject
 ldr x9, [x19, #56]
 ldr w10, [x9]
 cmp w10, #1
 b.ne .Lreject
 cmp w10, w23
 b.gt .Lreject
 str w10, [sp, #912]
 ldr x9, [x19, #64]
 ldr w11, [x9]
 cmp w11, #0
 b.lt .Lreject
 cmp w11, w23
 b.gt .Lreject
 str w11, [sp, #916]
 ldr w9, [CLOUD_PARAMETERS, #P_NCLDTOP]
 cmp w9, #2
 b.lt .Lreject
 cmp w9, w22
 b.gt .Lreject
 str w9, [sp, #920]
 ldr w9, [CLOUD_PARAMETERS, #P_NSSOPT]
 cmp w9, #1
 b.ne .Lreject
 // Qualify the immutable actual route before any returned storage changes.
 ldr w9, [CLOUD_PARAMETERS, #P_LAERICEAUTO]
 ldr w10, [CLOUD_PARAMETERS, #P_LAERICESED]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LAERLIQAUTOLSP]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LAERLIQCOLL]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLOUD_INHOMOG]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLDBUDGET]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLDBUDC]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLDBUDL]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLDBUDI]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLDBUDT]
 orr w9, w9, w10
 ldr w10, [CLOUD_PARAMETERS, #P_LCLDBUD_VERTINT]
 orr w9, w9, w10
 cbnz w9, .Lreject
 ldr x9, [x19, #32]
 ldr w10, [x9, #104]
 ldr w11, [x9, #436]
 orr w10, w10, w11
 cbnz w10, .Lreject
 ldr x9, [x19, #48]
 ldr w10, [x9]
 cbnz w10, .Lreject
 ldr w10, [x9, #216]
 cbnz w10, .Lreject
 ldr x9, [x19, #600]
 ldr w10, [x9]
 cbnz w10, .Lreject
 adrp x9, :got:__yommp0_MOD_lscmec
 ldr x9, [x9, :got_lo12:__yommp0_MOD_lscmec]
 ldr w10, [x9]
 cbnz w10, .Lreject
 ldr x9, [x19, #88]
 ldr d0, [x9]
 fcmp d0, #0.0
 b.le .Lreject
 ST d0, DT
 mul x27, x23, x22
 lsl x27, x27, #3
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
 // The controller prepared both addresses before the startup barrier.
 ldr x0,[sp,#992]
 str x0,[sp,#936]
 ldr w9,[x0]
 str w9,[sp,#944]
 ldr x0,[sp,#984]
 str x0,[sp,#960]
#else
 bl __errno_location
 str x0, [sp, #936]
 ldr w9, [x0]
 str w9, [sp, #944]
 add x0, x22, #1
 mov x1, #320
 bl calloc
 cbz x0, .Lreject
 str x0, [sp, #960]
#endif
 // Constants are read from the original frozen shared initialisation.
 ZER ZERO
 LIT ONE, .LCone
 LIT HALF, .LChalf
 LIT EPS, .LCeps
 LIT SMALL, .LCsmall
 GLOB RG, __yomcst_MOD_rg
 GLOB RD, __yomcst_MOD_rd
 GLOB RV, __yomcst_MOD_rv
 GLOB CP, __yomcst_MOD_rcpd
 GLOB RETV, __yomcst_MOD_retv
 GLOB RTT, __yomcst_MOD_rtt
 GLOB LV, __yomcst_MOD_rlvtt
 GLOB LS, __yomcst_MOD_rlstt
 GLOB R2ES, __yoethf_MOD_r2es
 GLOB R3L, __yoethf_MOD_r3les
 GLOB R3I, __yoethf_MOD_r3ies
 GLOB R4L, __yoethf_MOD_r4les
 GLOB R4I, __yoethf_MOD_r4ies
 GLOB R5L, __yoethf_MOD_r5les
 GLOB R5I, __yoethf_MOD_r5ies
 GLOB ALV, __yoethf_MOD_ralvdcp
 GLOB ALS, __yoethf_MOD_ralsdcp
 GLOB ALF, __yoethf_MOD_ralfdcp
 GLOB RTWAT, __yoethf_MOD_rtwat
 GLOB RTICE, __yoethf_MOD_rtice
 GLOB RTINV, __yoethf_MOD_rtwat_rtice_r
 GLOB KOOP1, __yoethf_MOD_rkoop1
 GLOB KOOP2, __yoethf_MOD_rkoop2
 F_DIV INVDT, ONE, DT
 F_DIV GDCP, RG, CP
 F_DIV RDCP, RD, CP
 F_DIV RGR, ONE, RG
 F_SUB TMP0, ALS, ALV
 F_DIV RLDCP, ONE, TMP0
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
 // The controller cleared the complete rain-fraction owner once.
 ldr x24,[sp,#968]
 ldr w9,[sp,#976]
 str w9,[sp,#916]
#else
 // The original initialises the entire rain-fraction owner, including inactive columns.
 ldr x9, [x19, #472]
 mov x10, #0
.Lrain_fraction_zero:
 str xzr, [x9, x10, lsl #3]
 add x10, x10, #1
 cmp x10, x23
 b.lt .Lrain_fraction_zero
 ldr w24, [sp, #912]
 sub x24, x24, #1
#endif
.Lcolumn:
 ldr w9, [sp, #916]
 cmp x24, x9
 b.ge .Ldone
 ldr x0, [sp, #960]
 mov x1, #0
 add x2, x22, #1
 mov x9, #320
 mul x2, x2, x9
 bl memset
 COPY ADVW, ONE
 COPY ADVWD, ONE
 COLI w9, 39
 cmp w9, #1
 b.ne .Ladvection_ready
 CUM TMP0, 104
 F_CMP TMP0, ZERO
 b.le .Ladvection_ready
 F_SUB ADVW, ONE, TMP0
 CUM TMP1, 112
 F_MUL TMP0, TMP0, TMP1
 F_SUB ADVWD, ONE, TMP0
.Ladvection_ready:
 ZER ANEWM1
 ZER COVPTOT
 ZER COVPCLR
 ZER COVPMAX
 ZER CLDTOPDIST
 COPY LLRAIN, ONE
 ZER PREV1
 ZER PREV2
 ZER PREV3
 ZER PREV4
 ZER PREV5
 mov x25, #0
 ldr x21, [sp, #960]
.Linitial_level:
 CELL_INDEX
 ZER TMP0
 PUT 18, TMP0
 PUT 19, TMP0
 PUT 20, TMP0
 PUT 21, TMP0, 0
 PUT 21, TMP0, 1
 PUT 21, TMP0, 2
 PUT 21, TMP0, 3
 OWN T, 12
 OWN TMP0, 14
 F_MUL TMP0, DT, TMP0
 F_ADD T, T, TMP0
 SAVE T, 0
 OWN QV, 13
 OWN TMP0, 15
 F_MUL TMP0, DT, TMP0
 F_ADD QV, QV, TMP0
 SAVE QV, 56
 SAVE QV, 96
 OWN A, 50
 OWN TMP0, 16
 F_MUL TMP0, DT, TMP0
 F_ADD A, A, TMP0
 SAVE A, 8
 SAVE A, 16
 OWN QL, 51, 0
 OWN TMP0, 17, 0
 F_MUL TMP0, DT, TMP0
 F_ADD QL, QL, TMP0
 SAVE QL, 24
 SAVE QL, 64
 OWN QI, 51, 1
 OWN TMP0, 17, 1
 F_MUL TMP0, DT, TMP0
 F_ADD QI, QI, TMP0
 SAVE QI, 32
 SAVE QI, 72
 OWN QR, 51, 2
 OWN TMP0, 17, 2
 F_MUL TMP0, DT, TMP0
 F_ADD QR, QR, TMP0
 SAVE QR, 40
 SAVE QR, 80
 OWN QS, 51, 3
 OWN TMP0, 17, 3
 F_MUL TMP0, DT, TMP0
 F_ADD QS, QS, TMP0
 SAVE QS, 48
 SAVE QS, 88
 add x25, x25, #1
 add x21, x21, #320
 cmp x25, x22
 b.lt .Linitial_level
 // Surface pressure and tropopause diagnostic keep the source pressure ordering.
 ldr x9, [x19, #272]
 madd x10, x22, x23, x24
 ldr d0, [x9, x10, lsl #3]
 ST d0, PH
 F_DIV PSURFINV, ONE, PH
 LIT TRPAUS, .LC01
 mov x25, #0
 ldr x21, [sp, #960]
.Ltropopause:
 CELL_INDEX
 ROW T, 0
 ldr d0, [x21, #320]
 ST d0, TMP0
 OWN P, 33
 F_MUL TMP1, P, PSURFINV
 LIT TMP2, .LC01
 F_CMP TMP1, TMP2
 b.le .Ltropopause_next
 LIT TMP2, .LC04
 F_CMP TMP1, TMP2
 b.ge .Ltropopause_next
 F_CMP T, TMP0
 b.le .Ltropopause_next
 COPY TRPAUS, TMP1
.Ltropopause_next:
 add x25, x25, #1
 add x21, x21, #320
 sub x9, x22, #1
 cmp x25, x9
 b.lt .Ltropopause
 mov x25, #0
 ldr x21, [sp, #960]
.Lsaturation:
 CELL_INDEX
 ROW T, 0
 OWN P, 33
 F_MIN TMP0, RTWAT, T
 F_MAX TMP0, RTICE, TMP0
 F_SUB TMP0, TMP0, RTICE
 F_MUL TMP0, TMP0, RTINV
 F_MUL TMP0, TMP0, TMP0
 F_MIN ALFA, ONE, TMP0
 SAVE ALFA, 104
 F_SUB TMP0, T, RTT
 F_MUL TMP0, R3L, TMP0
 F_SUB TMP1, T, R4L
 F_DIV TMP0, TMP0, TMP1
 EXP TMP4, TMP0
 F_SUB TMP0, T, RTT
 F_MUL TMP0, R3I, TMP0
 F_SUB TMP1, T, R4I
 F_DIV TMP0, TMP0, TMP1
 EXP TMP5, TMP0
 F_MUL TMP0, ALFA, TMP4
 F_SUB TMP1, ONE, ALFA
 F_MUL TMP1, TMP1, TMP5
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, R2ES, TMP0
 F_DIV TMP0, TMP0, P
 F_MIN FOM, TMP0, HALF
 SAVE FOM, 248
 F_MUL TMP0, RETV, FOM
 F_SUB TMP0, ONE, TMP0
 F_DIV QSM, FOM, TMP0
 SAVE QSM, 112
 // FOEDELTA selects liquid at and above the triple-point temperature.
 F_CMP T, RTT
 b.ge .Ldelta_water
 COPY TMP2, ZERO
 b .Ldelta_ready
.Ldelta_water:
 COPY TMP2, ONE
.Ldelta_ready:
 F_MUL TMP4, R2ES, TMP4
 F_MUL TMP5, R2ES, TMP5
 F_MUL TMP0, TMP2, TMP4
 F_SUB TMP1, ONE, TMP2
 F_MUL TMP1, TMP1, TMP5
 F_ADD TMP0, TMP0, TMP1
 F_DIV TMP0, TMP0, P
 F_MIN FOI, TMP0, HALF
 F_MIN FOI, HALF, FOI
 SAVE FOI, 256
 F_MUL TMP0, RETV, FOI
 F_SUB TMP0, ONE, TMP0
 F_DIV QSI, FOI, TMP0
 SAVE QSI, 128
 F_DIV TMP0, TMP4, P
 F_MIN FOL, TMP0, HALF
 SAVE FOL, 264
 F_MUL TMP0, RETV, FOL
 F_SUB TMP0, ONE, TMP0
 F_DIV QSL, FOL, TMP0
 SAVE QSL, 120
 add x25, x25, #1
 add x21, x21, #320
 cmp x25, x22
 b.lt .Lsaturation
 mov x25, #0
 ldr x21, [sp, #960]
.Ltidy:
 CELL_INDEX
 ROW QL, 24
 ROW QI, 32
 ROW QR, 40
 ROW QS, 48
 ROW QV, 56
 ROW A, 8
 F_ADD LI, QL, QI
 PAR TMP0, RLMIN
 F_CMP LI, TMP0
 b.lt .Ltidy_small_cloud
 PAR TMP0, RAMIN
 F_CMP A, TMP0
 b.ge .Ltidy_each_species
.Ltidy_small_cloud:
 // Evaporate liquid before ice, preserving both temperature increments.
 ROW TMP0, 136
 F_ADD TMP0, TMP0, QL
 SAVE TMP0, 136
 F_MUL QADJ, QL, INVDT
 OWN TMP0, 19
 F_ADD TMP0, TMP0, QADJ
 PUT 19, TMP0
 F_MUL TMP0, ALV, QADJ
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_ADD QV, QV, QL
 ZER QL
 ROW TMP0, 144
 F_ADD TMP0, TMP0, QI
 SAVE TMP0, 144
 F_MUL QADJ, QI, INVDT
 OWN TMP0, 19
 F_ADD TMP0, TMP0, QADJ
 PUT 19, TMP0
 F_MUL TMP0, ALS, QADJ
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_ADD QV, QV, QI
 ZER QI
 ZER A
.Ltidy_each_species:
 // The following four distinct phase transfers match the species order.
 PAR TMP0, RLMIN
 F_CMP QL, TMP0
 b.ge .Ltidy_QL_ready
 ROW TMP0, 136
 F_ADD TMP0, TMP0, QL
 SAVE TMP0, 136
 F_MUL QADJ, QL, INVDT
 OWN TMP0, 19
 F_ADD TMP0, TMP0, QADJ
 PUT 19, TMP0
 F_MUL TMP0, ALV, QADJ
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_ADD QV, QV, QL
 ZER QL
.Ltidy_QL_ready:
 SAVE QL, 24
 PAR TMP0, RLMIN
 F_CMP QI, TMP0
 b.ge .Ltidy_QI_ready
 ROW TMP0, 144
 F_ADD TMP0, TMP0, QI
 SAVE TMP0, 144
 F_MUL QADJ, QI, INVDT
 OWN TMP0, 19
 F_ADD TMP0, TMP0, QADJ
 PUT 19, TMP0
 F_MUL TMP0, ALS, QADJ
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_ADD QV, QV, QI
 ZER QI
.Ltidy_QI_ready:
 SAVE QI, 32
 PAR TMP0, RLMIN
 F_CMP QR, TMP0
 b.ge .Ltidy_QR_ready
 ROW TMP0, 152
 F_ADD TMP0, TMP0, QR
 SAVE TMP0, 152
 F_MUL QADJ, QR, INVDT
 OWN TMP0, 19
 F_ADD TMP0, TMP0, QADJ
 PUT 19, TMP0
 F_MUL TMP0, ALV, QADJ
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_ADD QV, QV, QR
 ZER QR
.Ltidy_QR_ready:
 SAVE QR, 40
 PAR TMP0, RLMIN
 F_CMP QS, TMP0
 b.ge .Ltidy_QS_ready
 ROW TMP0, 160
 F_ADD TMP0, TMP0, QS
 SAVE TMP0, 160
 F_MUL QADJ, QS, INVDT
 OWN TMP0, 19
 F_ADD TMP0, TMP0, QADJ
 PUT 19, TMP0
 F_MUL TMP0, ALS, QADJ
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_ADD QV, QV, QS
 ZER QS
.Ltidy_QS_ready:
 SAVE QS, 48
 SAVE QV, 56
 F_MIN A, ONE, A
 F_MAX A, ZERO, A
 SAVE A, 8
 F_ADD LI, QL, QI
 SAVE LI, 272
 PAR TMP0, RLMIN
 F_CMP LI, TMP0
 b.le .Ltidy_no_fraction
 F_DIV LIF, QL, LI
 F_SUB IIF, ONE, LIF
 b .Ltidy_fraction_ready
.Ltidy_no_fraction:
 ZER LIF
 ZER IIF
.Ltidy_fraction_ready:
 SAVE LIF, 280
 SAVE IIF, 288
 add x25, x25, #1
 add x21, x21, #320
 cmp x25, x22
 b.lt .Ltidy
 ldr w25, [sp, #920]
 sub x25, x25, #1
 mov x9, #320
 ldr x21, [sp, #960]
 madd x21, x25, x9, x21
.Lphysical_level:
 CELL_INDEX
 // Each column has the same ordered local calculation as the source row.
 ROW T, 0
 ROW A, 8
 ROW AOR, 16
 ROW QL, 24
 ROW QI, 32
 ROW QR, 40
 ROW QS, 48
 ROW QV, 56
 ROW QL0, 64
 ROW QI0, 72
 ROW QR0, 80
 ROW QS0, 88
 ROW QV0, 96
 ROW ALFA, 104
 ROW QSM, 112
 ROW QSL, 120
 ROW QSI, 128
 ROW FOM, 248
 ROW FOI, 256
 ROW FOL, 264
 ROW LI, 272
 ROW LIF, 280
 ROW IIF, 288
 COPY FG1, QL
 COPY FG2, QI
 COPY FG3, QR
 COPY FG4, QS
 COPY FG5, QV
 ZER PRETOT
 ZER LFINALSUM
 ZER SOLAB
 ZER SOLAC
 ZER RAINAUT
 ZER RAINACC
 ZER ICETOT
 ZER FALLSPD1
 ZER FALLSPD2
 ZER FALLSPD3
 ZER FALLSPD4
 ZER FALLSPD5
 ZER FALLSRC1
 ZER FALLSRC2
 ZER FALLSRC3
 ZER FALLSRC4
 ZER FALLSRC5
 ZER FALLSINK1
 ZER FALLSINK2
 ZER FALLSINK3
 ZER FALLSINK4
 ZER FALLSINK5
 ZER CONVSRC1
 ZER CONVSRC2
 ZER CONVSRC3
 ZER CONVSRC4
 ZER CONVSRC5
 ZER CONVSINK1
 ZER CONVSINK2
 ZER CONVSINK3
 ZER CONVSINK4
 ZER CONVSINK5
 add x9, x20, #QA11
 mov x10, #50
.Lmatrix_zero:
 str xzr, [x9], #8
 subs x10, x10, #1
 b.ne .Lmatrix_zero
 OWN P, 33
 OWN PH, 34
 OWN PHNEXT, 34, 0, 1
 OWN PM1, 33, 0, -1
 ROW TM1, 0, 1
 ROW AM1, 8, 1
 F_SUB DP, PHNEXT, PH
 F_DIV GDP, RG, DP
 F_MUL TMP0, RD, T
 F_DIV RHO, P, TMP0
 F_MUL DTGDP, DT, GDP
 F_MUL TMP0, DT, RG
 F_DIV TMP0, ONE, TMP0
 F_MUL RDTGDP, DP, TMP0
 F_MUL TMP0, DT, RG
 F_SUB TMP1, P, PM1
 F_DIV DTGDPF, TMP0, TMP1
 F_SUB TMP0, T, R4L
 F_MUL TMP0, TMP0, TMP0
 F_DIV FACW, R5L, TMP0
 F_MUL TMP0, RETV, FOL
 F_SUB TMP0, ONE, TMP0
 F_DIV COR, ONE, TMP0
 F_MUL DQSL, FACW, COR
 F_MUL DQSL, DQSL, QSL
 F_MUL TMP0, ALV, DQSL
 F_ADD CORQSL, ONE, TMP0
 F_SUB TMP0, T, R4I
 F_MUL TMP0, TMP0, TMP0
 F_DIV FACI, R5I, TMP0
 F_MUL TMP0, RETV, FOI
 F_SUB TMP0, ONE, TMP0
 F_DIV COR, ONE, TMP0
 F_MUL DQSI, FACI, COR
 F_MUL DQSI, DQSI, QSI
 F_MUL TMP0, ALS, DQSI
 F_ADD CORQSI, ONE, TMP0
 F_MUL TMP0, ALFA, FACW
 F_SUB TMP1, ONE, ALFA
 F_MUL TMP1, TMP1, FACI
 F_ADD TMP2, TMP0, TMP1
 F_MUL TMP0, RETV, FOM
 F_SUB TMP0, ONE, TMP0
 F_DIV COR, ONE, TMP0
 F_MUL DQSM, TMP2, COR
 F_MUL DQSM, DQSM, QSM
 F_MUL TMP0, ALFA, ALV
 F_SUB TMP1, ONE, ALFA
 F_MUL TMP1, TMP1, ALS
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, TMP0, DQSM
 F_ADD CORQSM, ONE, TMP0
 F_SUB TMP0, QSM, QV
 F_DIV TMP0, TMP0, CORQSM
 F_MAX EVAPM, TMP0, ZERO
 F_SUB TMP0, QSL, QV
 F_DIV TMP0, TMP0, CORQSL
 F_MAX EVAPL, TMP0, ZERO
 F_SUB TMP0, QSI, QV
 F_DIV TMP0, TMP0, CORQSI
 F_MAX EVAPI, TMP0, ZERO
 LIT TMP0, .LC001
 F_MAX TMP0, A, TMP0
 F_DIV TMP0, ONE, TMP0
 F_MUL LIQCLD, QL, TMP0
 F_MUL ICECLD, QI, TMP0
 F_ADD LICLD, LIQCLD, ICECLD
 PAR TMP0, RLMIN
 F_CMP QL, TMP0
 b.ge .Lsmall_liquid_ready
 COPY QA51, QL
 F_NEG QA15, QL
.Lsmall_liquid_ready:
 F_CMP QI, TMP0
 b.ge .Lsmall_ice_ready
 COPY QA52, QI
 F_NEG QA25, QI
.Lsmall_ice_ready:
 // Source 3.2. Convective detrainment is admitted before downward transport.
 add x9, x25, #1
 cmp x9, x22
 b.ge .Ldetrainment_ready
 OWN TMP0, 43
 F_MUL TMP0, TMP0, DTGDP
 PUT 43, TMP0
 COLI w9, 37
 cbz w9, .Lno_detrainment
 F_CMP TMP0, SMALL
 b.le .Lno_detrainment
 OWN TMP1, 42, 0, 1
 F_CMP TMP1, SMALL
 b.le .Lno_detrainment
 F_DIV TMP0, TMP0, TMP1
 F_ADD SOLAC, SOLAC, TMP0
 OWN TMP0, 44, 0
 F_MUL CONVSRC1, TMP0, DTGDP
 OWN TMP0, 44, 1
 F_MUL CONVSRC2, TMP0, DTGDP
 F_ADD QA11, QA11, CONVSRC1
 F_ADD QA22, QA22, CONVSRC2
 b .Lconvective_snow
.Lno_detrainment:
 ZER TMP0
 PUT 43, TMP0
.Lconvective_snow:
 ldr x9, [x19, #8]
 ldr w9, [x9, #268]
 cbz w9, .Ldetrainment_ready
 OWN TMP0, 45, 0
 F_MUL CONVSRC3, TMP0, DTGDP
 OWN TMP0, 45, 1
 F_MUL CONVSRC4, TMP0, DTGDP
 F_ADD QA33, QA33, CONVSRC3
 F_ADD QA44, QA44, CONVSRC4
.Ldetrainment_ready:
 // Source 3.3. Downward cloud imports use the previously solved upper layer.
 ldr w9, [sp, #920]
 add x10, x25, #1
 cmp x10, x9
 b.le .Lsubsidence_source_ready
 OWN TMP0, 46
 F_MUL TMP0, TMP0, ADVW
 OWN TMP1, 47
 F_MUL TMP1, TMP1, ADVWD
 F_ADD MF, TMP0, TMP1
 F_MUL MF, MF, DTGDP
 F_MAX MF, ZERO, MF
 F_MUL ACUST, MF, ANEWM1
 F_MUL LCUSTL, MF, PREV1
 F_MUL LCUSTI, MF, PREV2
 F_ADD CONVSRC1, CONVSRC1, LCUSTL
 F_ADD CONVSRC2, CONVSRC2, LCUSTI
 F_MUL DTDP, RDCP, HALF
 F_ADD TMP0, TM1, T
 F_MUL DTDP, DTDP, TMP0
 F_DIV DTDP, DTDP, PH
 OWN TMP0, 46
 F_MUL TMP0, TMP0, ADVW
 OWN TMP1, 47
 F_MUL TMP1, TMP1, ADVWD
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, RG, TMP0
 F_SUB TMP1, P, PM1
 F_DIV TMP1, TMP1, DT
 F_MIN WTOT, TMP0, TMP1
 F_MUL DTFORC, DTDP, DT
 F_MUL DTFORC, DTFORC, WTOT
 F_MUL DQS, ANEWM1, DTFORC
 F_MUL DQS, DQS, DQSM
 F_SUB LFINAL, LCUSTL, DQS
 F_MAX LFINAL, ZERO, LFINAL
 F_SUB EVAP, LCUSTL, LFINAL
 F_MIN EVAP, EVAP, EVAPM
 F_SUB LFINAL, LCUSTL, EVAP
 F_ADD LFINALSUM, LFINALSUM, LFINAL
 F_ADD QA11, QA11, LCUSTL
 F_ADD QA51, QA51, EVAP
 F_SUB QA15, QA15, EVAP
 F_SUB LFINAL, LCUSTI, DQS
 F_MAX LFINAL, ZERO, LFINAL
 F_SUB EVAP, LCUSTI, LFINAL
 F_MIN EVAP, EVAP, EVAPM
 F_SUB LFINAL, LCUSTI, EVAP
 F_ADD LFINALSUM, LFINALSUM, LFINAL
 F_ADD QA22, QA22, LCUSTI
 F_ADD QA52, QA52, EVAP
 F_SUB QA25, QA25, EVAP
 F_ADD SOLAC, SOLAC, ACUST
 F_CMP LFINALSUM, SMALL
 b.ge .Lsubsidence_source_ready
 F_SUB SOLAC, SOLAC, ACUST
.Lsubsidence_source_ready:
 add x9, x25, #1
 cmp x9, x22
 b.ge .Lsubsidence_sink_ready
 OWN TMP0, 46, 0, 1
 F_MUL TMP0, TMP0, ADVW
 OWN TMP1, 47, 0, 1
 F_MUL TMP1, TMP1, ADVWD
 F_ADD MFDN, TMP0, TMP1
 F_MUL MFDN, MFDN, DTGDP
 F_MAX MFDN, ZERO, MFDN
 F_ADD SOLAB, SOLAB, MFDN
 F_ADD QB11, QB11, MFDN
 F_ADD QB22, QB22, MFDN
 COPY CONVSINK1, MFDN
 COPY CONVSINK2, MFDN
.Lsubsidence_sink_ready:
 // Source 3.4. Mixed-phase cloud-edge erosion.
 PAR LDIFDT, RCLDIFF
 F_MUL LDIFDT, LDIFDT, DT
 COLI w11, 39
 OWN TMP0, 43
 F_CMP TMP0, SMALL
 b.le .Lerosion_rate_ready
 cmp w11, #2
 b.lt .Lerosion_deep
 COL TMP1, 41
 LIT TMP2, .LCten
 F_CMP TMP1, TMP2
 b.ge .Lerosion_rate_ready
 LIT TMP0, .LCtwenty
 PAR TMP1, RCLDIFF_CONVI
 F_MUL TMP0, TMP0, TMP1
 F_MUL LDIFDT, TMP0, LDIFDT
 b .Lerosion_rate_ready
.Lerosion_deep:
 cmp w11, #1
 b.ne .Lerosion_rate_ready
 LIT TMP0, .LCtwo
 PAR TMP1, RCLDIFF_CONVI
 F_MUL TMP0, TMP0, TMP1
 F_MUL LDIFDT, TMP0, LDIFDT
.Lerosion_rate_ready:
 F_CMP LI, SMALL
 b.le .Lerosion_ready
 F_MUL TMP0, A, QSM
 F_SUB TMP0, QV, TMP0
 F_SUB TMP1, ONE, A
 F_MAX TMP1, SMALL, TMP1
 F_DIV QE, TMP0, TMP1
 F_SUB E, QSM, QE
 F_MAX E, E, ZERO
 LIT TMP0, .LC0333
 F_MUL LEROS, TMP0, A
 F_SUB TMP0, ONE, A
 F_MUL LEROS, LEROS, TMP0
 F_MUL LEROS, LEROS, LDIFDT
 F_MUL LEROS, LEROS, E
 F_MIN LEROS, LEROS, EVAPM
 F_MIN LEROS, LEROS, LI
 F_MUL AEROS, HALF, LEROS
 F_DIV AEROS, AEROS, LICLD
 F_SUB SOLAC, SOLAC, AEROS
 F_MUL TMP0, LIF, LEROS
 F_ADD QA51, QA51, TMP0
 F_SUB QA15, QA15, TMP0
 F_MUL TMP0, IIF, LEROS
 F_ADD QA52, QA52, TMP0
 F_SUB QA25, QA25, TMP0
.Lerosion_ready:
 // Source 4.1. Falling particles use the frozen variable-speed rain route.
 ZER FALLSPD1
 PAR FALLSPD2, RVICE
 PAR FALLSPD4, RVSNOW
 PAR TMP0, RDENSREF
 F_DIV TMP0, TMP0, RHO
 LIT TMP1, .LC04
 POW FALLCORR, TMP0, TMP1
 F_ADD TEMP, QR, PREV3
 F_MUL TEMP, HALF, TEMP
 F_MUL TMP0, RHO, TEMP
 PAR TMP1, RCL_LAM1R
 F_DIV TMP0, TMP0, TMP1
 PAR TMP1, RCL_LAM2R
 POW RLAMBDA, TMP0, TMP1
 PAR TMP0, RCL_CONST7R
 F_MUL FALLSPD3, FALLCORR, TMP0
 PAR TMP1, RCL_DR
 POW TMP0, RLAMBDA, TMP1
 F_MUL FALLSPD3, FALLSPD3, TMP0
 PAR TMP0, RVICE
 F_CMP TMP0, ZERO
 b.le .Lfall_2_ready
 ldr w9, [sp, #920]
 add x10, x25, #1
 cmp x10, x9
 b.le .Lfall_2_sink
 ROW TMP0, 216
 F_MUL FALLSRC2, TMP0, DTGDP
 F_ADD QA22, QA22, FALLSRC2
 F_ADD FG2, FG2, FALLSRC2
 F_ADD PRETOT, PRETOT, FG2
.Lfall_2_sink:
 F_MUL FALLSINK2, DTGDP, RHO
 F_MUL FALLSINK2, FALLSINK2, FALLSPD2
.Lfall_2_ready:
 PAR TMP0, RVRAIN
 F_CMP TMP0, ZERO
 b.le .Lfall_3_ready
 ldr w9, [sp, #920]
 add x10, x25, #1
 cmp x10, x9
 b.le .Lfall_3_sink
 ROW TMP0, 224
 F_MUL FALLSRC3, TMP0, DTGDP
 F_ADD QA33, QA33, FALLSRC3
 F_ADD FG3, FG3, FALLSRC3
 F_ADD PRETOT, PRETOT, FG3
.Lfall_3_sink:
 F_MUL FALLSINK3, DTGDP, RHO
 F_MUL FALLSINK3, FALLSINK3, FALLSPD3
.Lfall_3_ready:
 PAR TMP0, RVSNOW
 F_CMP TMP0, ZERO
 b.le .Lfall_4_ready
 ldr w9, [sp, #920]
 add x10, x25, #1
 cmp x10, x9
 b.le .Lfall_4_sink
 ROW TMP0, 232
 F_MUL FALLSRC4, TMP0, DTGDP
 F_ADD QA44, QA44, FALLSRC4
 F_ADD FG4, FG4, FALLSRC4
 F_ADD PRETOT, PRETOT, FG4
.Lfall_4_sink:
 F_MUL FALLSINK4, DTGDP, RHO
 F_MUL FALLSINK4, FALLSINK4, FALLSPD4
.Lfall_4_ready:
 // Source 4.2. Precipitation coverage retains vertical maximum-random overlap.
 F_CMP PRETOT, SMALL
 b.le .Lno_precipitation_coverage
 F_SUB TMP0, ONE, COVPTOT
 F_MAX TMP1, A, AM1
 F_SUB TMP1, ONE, TMP1
 F_MUL TMP0, TMP0, TMP1
 LIT TMP1, .LCone_less_micro
 F_MIN TMP1, AM1, TMP1
 F_SUB TMP1, ONE, TMP1
 F_DIV TMP0, TMP0, TMP1
 F_SUB COVPTOT, ONE, TMP0
 PAR TMP0, RCOVPMIN
 F_MAX COVPTOT, COVPTOT, TMP0
 F_SUB TMP0, COVPTOT, A
 F_MAX COVPCLR, ZERO, TMP0
 ROW TMP0, 40, 1
 F_ADD RAINCLD, QR, TMP0
 F_MUL RAINCLD, HALF, RAINCLD
 F_DIV RAINCLD, RAINCLD, COVPTOT
 F_ADD RAINCLDM1, QR, PREV3
 F_MUL RAINCLDM1, HALF, RAINCLDM1
 F_DIV RAINCLDM1, RAINCLDM1, COVPTOT
 ROW TMP0, 48, 1
 F_ADD SNOWCLD, QS, TMP0
 F_MUL SNOWCLD, HALF, SNOWCLD
 F_DIV SNOWCLD, SNOWCLD, COVPTOT
 F_ADD SNOWCLDM1, QS, PREV4
 F_MUL SNOWCLDM1, HALF, SNOWCLDM1
 F_DIV SNOWCLDM1, SNOWCLDM1, COVPTOT
 F_MAX COVPMAX, COVPTOT, COVPMAX
 b .Lprecipitation_coverage_ready
.Lno_precipitation_coverage:
 ZER RAINCLD
 ZER RAINCLDM1
 ZER SNOWCLD
 ZER SNOWCLDM1
 ZER COVPTOT
 ZER COVPCLR
 ZER COVPMAX
.Lprecipitation_coverage_ready:
 // Source 4.3. Implicit warm rain, with unchanged constant cloud variability factors.
 F_CMP LIQCLD, SMALL
 b.le .Lwarm_rain_ready
 COL TMP0, 35
 F_CMP TMP0, HALF
 b.le .Lwarm_ocean
 PAR TEMP, RCL_KK_CLOUD_NUM_LAND
 PAR LCRIT, RCLCRIT_LAND
 b .Lwarm_environment_ready
.Lwarm_ocean:
 PAR TEMP, RCL_KK_CLOUD_NUM_SEA
 PAR LCRIT, RCLCRIT_SEA
.Lwarm_environment_ready:
 PAR FACTOR, RCL_INHOMOGAUT
 F_MUL RAINAUT, FACTOR, DT
 PAR TMP0, RCL_KKAAU
 F_MUL RAINAUT, RAINAUT, TMP0
 PAR TMP1, RCL_KKBAUQ
 F_SUB TMP1, TMP1, ONE
 POW TMP0, LIQCLD, TMP1
 F_MUL RAINAUT, RAINAUT, TMP0
 PAR TMP1, RCL_KKBAUN
 POW TMP0, TEMP, TMP1
 F_MUL RAINAUT, RAINAUT, TMP0
 F_ADD QB31, QB31, RAINAUT
 F_CMP RAINCLD, SMALL
 b.le .Lwarm_accretion_ready
 PAR FACTOR, RCL_INHOMOGACC
 F_MUL RAINACC, FACTOR, DT
 PAR TMP0, RCL_KKAAC
 F_MUL RAINACC, RAINACC, TMP0
 PAR TMP1, RCL_KKBAC
 F_SUB TMP1, TMP1, ONE
 POW TMP0, LIQCLD, TMP1
 F_MUL RAINACC, RAINACC, TMP0
 PAR TMP1, RCL_KKBAC
 POW TMP0, RAINCLD, TMP1
 F_MUL RAINACC, RAINACC, TMP0
.Lwarm_accretion_ready:
 F_ADD QB31, QB31, RAINACC
.Lwarm_rain_ready:
 // Source 4.4. Rain evaporates only in the qualifying clear part of a cell.
 PAR RHLIMIT, RPRECRHMAX
 F_SUB TMP0, ONE, RHLIMIT
 F_MUL TMP0, TMP0, COVPMAX
 F_SUB TMP1, ONE, A
 F_MAX TMP1, SMALL, TMP1
 F_DIV TMP0, TMP0, TMP1
 F_ADD RHLIMIT, RHLIMIT, TMP0
 PAR TMP0, RPRECRHMAX
 F_MAX RHLIMIT, RHLIMIT, TMP0
 F_MIN RHLIMIT, RHLIMIT, ONE
 PAR RH0, RAMID
 ldr x9, [x19, #272]
 madd x10, x22, x23, x24
 ldr d0, [x9, x10, lsl #3]
 ST d0, TMP0
 F_DIV TMP0, P, TMP0
 LIT TMP1, .LC08
 F_CMP TMP0, TMP1
 b.le .Lrain_critical_humidity
 F_SUB TMP0, TMP0, TMP1
 LIT TMP1, .LC02
 F_DIV TMP0, TMP0, TMP1
 F_MUL TMP0, TMP0, TMP0
 F_SUB TMP1, ONE, RH0
 F_MUL TMP0, TMP1, TMP0
 F_ADD RH0, RH0, TMP0
.Lrain_critical_humidity:
 F_MIN RHLIMIT, RH0, RHLIMIT
 LIT TMP0, .LC09
 F_MIN RHLIMIT, TMP0, RHLIMIT
 F_MIN QE, QV, QSL
 F_MAX QE, ZERO, QE
 F_CMP COVPCLR, SMALL
 b.le .Lrain_evaporation_ready
 F_CMP RAINCLDM1, SMALL
 b.le .Lrain_evaporation_ready
 F_MUL TMP0, RHLIMIT, QSL
 F_CMP QE, TMP0
 b.ge .Lrain_evaporation_ready
 // A bare 0.4 source literal rounds in single precision before widening.
 PAR TMP0, RDENSREF
 F_DIV TMP0, TMP0, RHO
 LIT TMP1, .LC04single
 POW FALLCORR, TMP0, TMP1
 F_SUB TMP0, T, RTT
 F_MUL TMP0, R3L, TMP0
 F_SUB TMP1, T, R4L
 F_DIV TMP0, TMP0, TMP1
 EXP TMP0, TMP0
 F_MUL TMP0, R2ES, TMP0
 F_DIV VPD, RV, RD
 F_MUL VPD, VPD, TMP0
 F_MUL TMP0, RHO, RAINCLDM1
 PAR TMP1, RCL_LAM1R
 F_DIV TMP0, TMP1, TMP0
 PAR TMP1, RCL_LAM2R
 POW LAMBDA, TMP0, TMP1
 PAR TMP0, RCL_CDENOM1
 F_MUL DENOM, TMP0, VPD
 PAR TMP0, RCL_CDENOM2
 F_MUL TMP0, TMP0, T
 F_MUL TMP0, TMP0, VPD
 F_SUB DENOM, DENOM, TMP0
 PAR TMP0, RCL_CDENOM3
 LIT TMP1, .LCthree
 POW TMP1, T, TMP1
 F_MUL TMP0, TMP0, TMP1
 F_MUL TMP0, TMP0, P
 F_ADD DENOM, DENOM, TMP0
 LIT TMP0, .LC273
 F_DIV TMP0, T, TMP0
 LIT TMP1, .LC15
 POW CORR, TMP0, TMP1
 LIT TMP0, .LC393
 F_MUL CORR, CORR, TMP0
 LIT TMP0, .LC120
 F_ADD TMP0, T, TMP0
 F_DIV CORR, CORR, TMP0
 // The source's conductivity local is retained even though this route uses CORR directly.
 PAR TMP0, RCL_KA273
 F_MUL TMP0, TMP0, CORR
 F_MUL TMP0, RHLIMIT, QSL
 F_SUB TMP0, TMP0, QE
 F_MAX WATERLOSS, TMP0, ZERO
 LIT TMP0, .LC015
 F_DIV BETA, TMP0, QSL
 F_MUL TMP0, T, T
 F_MUL BETA, BETA, TMP0
 F_MUL BETA, BETA, VPD
 PAR TMP0, RCL_CONST1R
 F_MUL BETA, BETA, TMP0
 F_DIV TMP0, CORR, DENOM
 F_MUL BETA, BETA, TMP0
 PAR TMP1, RCL_CONST4R
 POW TMP0, LAMBDA, TMP1
 LIT TMP1, .LC078
 F_DIV TMP4, TMP1, TMP0
 F_MUL TMP0, RHO, FALLCORR
 LIT TMP1, .LChalf
 POW TMP0, TMP0, TMP1
 PAR TMP1, RCL_CONST2R
 F_MUL TMP5, TMP1, TMP0
 LIT TMP1, .LChalf
 POW TMP6, CORR, TMP1
 PAR TMP1, RCL_CONST3R
 POW TMP0, LAMBDA, TMP1
 F_MUL TMP6, TMP6, TMP0
 F_DIV TMP5, TMP5, TMP6
 F_ADD TMP4, TMP4, TMP5
 F_MUL BETA, BETA, TMP4
 F_MUL TMP0, BETA, DT
 F_MUL TMP0, TMP0, CORQSL
 F_ADD DENOM, ONE, TMP0
 F_MUL RAINEVAP, COVPCLR, BETA
 F_MUL RAINEVAP, RAINEVAP, DT
 F_MUL RAINEVAP, RAINEVAP, WATERLOSS
 F_DIV RAINEVAP, RAINEVAP, DENOM
 F_MIN EVAP, RAINEVAP, FG3
 F_ADD QA53, QA53, EVAP
 F_SUB QA35, QA35, EVAP
 F_SUB FG3, FG3, EVAP
.Lrain_evaporation_ready:
 // Source 4.5. Liquid supplies the Rotstayn depositional ice growth.
 PAR TMP0, RCLDTOPCF
 F_CMP AM1, TMP0
 b.ge .Lcloud_top_distance_grows
 F_CMP A, TMP0
 b.lt .Lcloud_top_distance_grows
 ZER CLDTOPDIST
 b .Lcloud_top_distance_ready
.Lcloud_top_distance_grows:
 F_MUL TMP0, RHO, RG
 F_DIV TMP0, DP, TMP0
 F_ADD CLDTOPDIST, CLDTOPDIST, TMP0
.Lcloud_top_distance_ready:
 F_SUB FACTOR, QSL, QSI
 F_DIV FACTOR, FACTOR, QSI
 LIT TMP0, .LCfive
 F_SUB TMP0, RTT, TMP0
 F_CMP T, TMP0
 b.ge .Lice_deposition_ready
 PAR TMP0, RLMIN
 F_CMP FG1, TMP0
 b.le .Lice_deposition_ready
 F_SUB TMP0, T, RTT
 F_MUL TMP0, R3I, TMP0
 F_SUB TMP1, T, R4I
 F_DIV TMP0, TMP0, TMP1
 EXP VPD, TMP0
 F_MUL VPD, R2ES, VPD
 F_MUL VPD, VPD, RV
 F_DIV VPD, VPD, RD
 LIT TMP0, .LC1296
 F_MUL TMP0, TMP0, FACTOR
 LIT TMP1, .LC0639
 F_SUB TMP0, TMP0, TMP1
 EXP ICEINIT, TMP0
 LIT TMP0, .LCthousand
 F_MUL ICEINIT, TMP0, ICEINIT
 F_MUL TMP0, RV, T
 F_DIV TMP0, LS, TMP0
 F_SUB TMP0, TMP0, ONE
 F_MUL TMP4, LS, TMP0
 LIT TMP0, .LC0024
 F_MUL TMP0, TMP0, T
 F_DIV TMP4, TMP4, TMP0
 F_MUL TMP5, RV, T
 F_MUL TMP5, TMP5, P
 LIT TMP0, .LC221
 F_MUL TMP0, TMP0, VPD
 F_DIV TMP5, TMP5, TMP0
 F_DIV TMP0, ICEINIT, RHO
 LIT TMP1, .LC0666
 POW CVDS, TMP0, TMP1
 LIT TMP0, .LC78
 F_MUL CVDS, TMP0, CVDS
 F_MUL CVDS, CVDS, FACTOR
 F_ADD TMP0, TMP4, TMP5
 LIT TMP1, .LC887
 F_MUL TMP0, TMP1, TMP0
 F_DIV CVDS, CVDS, TMP0
 PAR TMP0, RICEINIT
 F_MUL TMP0, ICEINIT, TMP0
 F_DIV TMP0, TMP0, RHO
 F_MAX ICE0, ICECLD, TMP0
 LIT TMP0, .LC0666
 F_MUL ICEAFTER, TMP0, CVDS
 F_MUL ICEAFTER, ICEAFTER, DT
 POW TMP0, ICE0, TMP0
 F_ADD ICEAFTER, ICEAFTER, TMP0
 LIT TMP1, .LC15
 POW ICEAFTER, ICEAFTER, TMP1
 PAR ICEDEP, RCL_OVERLAPLIQICE
 F_MUL ICEDEP, ICEDEP, A
 F_SUB TMP0, ICEAFTER, ICE0
 F_MUL ICEDEP, ICEDEP, TMP0
 F_MAX ICEDEP, ICEDEP, ZERO
 F_MIN ICEDEP, ICEDEP, FG1
 LIT TMP0, .LC15000
 F_DIV FACTOR, ICEINIT, TMP0
 F_MIN FACTOR, FACTOR, ONE
 PAR TMP0, RDEPLIQREFDEPTH
 F_DIV TMP0, CLDTOPDIST, TMP0
 PAR TMP1, RDEPLIQREFRATE
 F_ADD TMP0, TMP1, TMP0
 F_SUB TMP1, ONE, FACTOR
 F_MUL TMP0, TMP1, TMP0
 F_ADD TMP0, FACTOR, TMP0
 F_MIN TMP0, TMP0, ONE
 F_MUL ICEDEP, ICEDEP, TMP0
 F_ADD QA21, QA21, ICEDEP
 F_SUB QA12, QA12, ICEDEP
 F_ADD FG2, FG2, ICEDEP
 F_SUB FG1, FG1, ICEDEP
.Lice_deposition_ready:
 // Source 4.7. Snow gains water from the excess over mixed-phase saturation.
 F_SUB FACTOR, QV, QSM
 F_DIV FACTOR, FACTOR, QSM
 F_MAX FACTOR, FACTOR, ZERO
 F_CMP T, RTT
 b.ge .Lsnow_deposition_ready
 F_CMP SNOWCLD, SMALL
 b.le .Lsnow_deposition_ready
 F_CMP FACTOR, ZERO
 b.le .Lsnow_deposition_ready
 F_SUB TMP0, T, RTT
 F_MUL TMP0, R3I, TMP0
 F_SUB TMP1, T, R4I
 F_DIV TMP0, TMP0, TMP1
 EXP VPD, TMP0
 F_MUL VPD, R2ES, VPD
 F_MUL VPD, VPD, RV
 F_DIV VPD, VPD, RD
 PAR TMP0, RCL_APB1
 F_MUL DENOM, TMP0, VPD
 PAR TMP0, RCL_APB2
 F_MUL TMP0, TMP0, VPD
 F_MUL TMP0, TMP0, T
 F_SUB DENOM, DENOM, TMP0
 PAR TMP0, RCL_APB3
 F_MUL TMP0, P, TMP0
 F_MUL TMP1, T, T
 F_MUL TMP1, TMP1, T
 F_MUL TMP0, TMP0, TMP1
 F_ADD DENOM, DENOM, TMP0
 F_DIV TMP0, ONE, RHO
 LIT TMP1, .LChalf
 POW FALLCORR, TMP0, TMP1
 LIT TMP0, .LC273
 F_DIV TMP0, T, TMP0
 LIT TMP1, .LC15
 POW CORR, TMP0, TMP1
 LIT TMP0, .LC120
 F_ADD TMP0, T, TMP0
 LIT TMP1, .LC393
 F_DIV TMP0, TMP1, TMP0
 F_MUL CORR, CORR, TMP0
 F_MUL TEMP, RHO, SNOWCLD
 PAR TMP0, RCL_CONST1S
 F_MUL TEMP, TEMP, TMP0
 // ZTCG and ZFACX1S are both exactly one in this selected source route.
 F_MUL TMP0, ONE, ONE
 F_DIV TEMP, TEMP, TMP0
 F_MUL DEPRATE, T, T
 F_MUL DEPRATE, FACTOR, DEPRATE
 F_MUL DEPRATE, DEPRATE, VPD
 F_MUL DEPRATE, DEPRATE, CORR
 F_MUL DEPRATE, DEPRATE, ONE
 PAR TMP0, RCL_CONST2S
 F_MUL DEPRATE, DEPRATE, TMP0
 F_MUL DEPRATE, DEPRATE, ONE
 F_MUL TMP0, RHO, DENOM
 F_DIV DEPRATE, DEPRATE, TMP0
 LIT TMP0, .LC065
 PAR TMP1, RCL_CONST6S
 F_MUL GROW, TMP0, TMP1
 PAR TMP1, RCL_CONST4S
 POW TMP0, TEMP, TMP1
 F_MUL GROW, GROW, TMP0
 PAR TMP0, RCL_CONST3S
 LIT TMP1, .LChalf
 POW TMP1, FALLCORR, TMP1
 F_MUL RATE, TMP0, TMP1
 LIT TMP1, .LChalf
 POW TMP0, RHO, TMP1
 F_MUL RATE, RATE, TMP0
 PAR TMP1, RCL_CONST5S
 POW TMP0, TEMP, TMP1
 F_MUL RATE, RATE, TMP0
 LIT TMP1, .LChalf
 POW TMP0, CORR, TMP1
 F_DIV RATE, RATE, TMP0
 F_ADD GROW, GROW, RATE
 F_MUL DEPRATE, COVPTOT, DEPRATE
 F_MUL DEPRATE, DEPRATE, GROW
 F_MUL DEPRATE, DEPRATE, DT
 F_MAX DEPRATE, DEPRATE, ZERO
 F_SUB TMP0, QV, QSM
 F_MIN DEPRATE, DEPRATE, TMP0
 F_DIV DEPRATE, DEPRATE, CORQSM
 F_ADD QA45, QA45, DEPRATE
 F_SUB QA54, QA54, DEPRATE
.Lsnow_deposition_ready:
 // The revised in-cloud amounts use the process first guess, not the initial state.
 LIT TMP0, .LC001
 F_MAX TMP0, A, TMP0
 F_DIV TMP0, ONE, TMP0
 F_MUL LIQCLD, FG1, TMP0
 F_MUL ICECLD, FG2, TMP0
 // Source 4.8. Cloud ice converts implicitly to snow.
 F_CMP T, RTT
 b.gt .Lice_to_snow_ready
 F_CMP ICECLD, SMALL
 b.le .Lice_to_snow_ready
 PAR TMP0, RSNOWLIN1
 F_MUL FACTOR, DT, TMP0
 F_SUB TMP0, T, RTT
 PAR TMP1, RSNOWLIN2
 F_MUL TMP0, TMP1, TMP0
 EXP TMP0, TMP0
 F_MUL FACTOR, FACTOR, TMP0
 PAR TMP0, RLCRITSNOW
 F_DIV TEMP, ICECLD, TMP0
 F_MUL TEMP, TEMP, TEMP
 F_NEG TEMP, TEMP
 LIT TMP0, .LCfifty
 F_CMP TEMP, TMP0
 b.ge .Lice_autoconversion_without_exp
 EXP TMP0, TEMP
 F_SUB TMP0, ONE, TMP0
 F_MUL TEMP, FACTOR, TMP0
 b .Lice_autoconversion_add
.Lice_autoconversion_without_exp:
 COPY TEMP, FACTOR
.Lice_autoconversion_add:
 F_ADD QB42, QB42, TEMP
.Lice_to_snow_ready:
 // Source 4.12. Melt ice and snow into rain at the wet-bulb melting limit.
 F_ADD ICETOT, FG2, FG4
 ZER MAXMELT
 F_CMP ICETOT, SMALL
 b.le .Lmelting_rate_ready
 F_CMP T, RTT
 b.le .Lmelting_rate_ready
 F_SUB WATERLOSS, QSI, QV
 F_MAX WATERLOSS, WATERLOSS, ZERO
 LIT TMP0, .LCtw3
 F_SUB TMP0, P, TMP0
 LIT TMP1, .LCtw2
 F_MUL TMP0, TMP1, TMP0
 LIT TMP1, .LCtw1
 F_ADD TMP0, TMP1, TMP0
 LIT TMP1, .LCtw5
 F_SUB TMP1, T, TMP1
 LIT TMP2, .LCtw4
 F_MUL TMP1, TMP2, TMP1
 F_SUB TMP0, TMP0, TMP1
 F_MUL TMP0, WATERLOSS, TMP0
 F_SUB WETBULB, T, RTT
 F_SUB WETBULB, WETBULB, TMP0
 F_MUL FACTOR, HALF, WETBULB
 F_ADD FACTOR, ONE, FACTOR
 F_MUL FACTOR, DT, FACTOR
 PAR TMP0, RTAUMEL
 F_DIV FACTOR, FACTOR, TMP0
 F_ABS FACTOR, FACTOR
 F_MUL MAXMELT, WETBULB, FACTOR
 F_MUL MAXMELT, MAXMELT, RLDCP
 F_MAX MAXMELT, MAXMELT, ZERO
.Lmelting_rate_ready:
 F_CMP MAXMELT, SMALL
 b.le .Lmelting_ready
 F_CMP ICETOT, SMALL
 b.le .Lmelting_ready
 F_DIV FACTOR, FG2, ICETOT
 F_MUL MELT, FACTOR, MAXMELT
 F_MIN MELT, FG2, MELT
 F_SUB FG2, FG2, MELT
 F_ADD FG3, FG3, MELT
 F_ADD QA32, QA32, MELT
 F_SUB QA23, QA23, MELT
 F_DIV FACTOR, FG4, ICETOT
 F_MUL MELT, FACTOR, MAXMELT
 F_MIN MELT, FG4, MELT
 F_SUB FG4, FG4, MELT
 F_ADD FG3, FG3, MELT
 F_ADD QA34, QA34, MELT
 F_SUB QA43, QA43, MELT
.Lmelting_ready:
 // Source 4.13. Diagnose rain fraction and retain the source single-precision threshold.
 F_CMP QR, SMALL
 b.le .Lrain_freezing_ready
 F_CMP T, RTT
 b.gt .Lrain_freezing_type_ready
 F_CMP TM1, RTT
 b.le .Lrain_freezing_type_ready
 F_ADD PRETOT, QS, QR
 F_MAX PRETOT, PRETOT, SMALL
 F_DIV TMP0, QR, PRETOT
 ldr x9, [x19, #472]
 LD d0, TMP0
 str d0, [x9, x24, lsl #3]
 LIT TMP1, .LC08single
 F_CMP TMP0, TMP1
 b.le .Lrain_partly_melted
 COPY LLRAIN, ONE
 b .Lrain_freezing_type_ready
.Lrain_partly_melted:
 ZER LLRAIN
.Lrain_freezing_type_ready:
 F_CMP T, RTT
 b.ge .Lrain_freezing_ready
 F_CMP LLRAIN, ZERO
 b.eq .Lrapid_rain_freezing
 F_MUL TMP0, RHO, QR
 PAR TMP1, RCL_LAM1R
 F_DIV TMP0, TMP1, TMP0
 PAR TMP1, RCL_LAM2R
 POW LAMBDA, TMP0, TMP1
 F_SUB TMP0, T, RTT
 PAR TMP1, RCL_FZRAB
 F_MUL TEMP, TMP1, TMP0
 LIT TMP0, .LCfifty
 F_MIN TEMP, TEMP, TMP0
 PAR TMP0, RCL_CONST5R
 F_DIV TMP0, TMP0, RHO
 F_MUL FREEZE, DT, TMP0
 EXP TMP0, TEMP
 F_SUB TMP0, TMP0, ONE
 F_MUL FREEZE, FREEZE, TMP0
 PAR TMP1, RCL_CONST6R
 POW TMP0, LAMBDA, TMP1
 F_MUL FREEZE, FREEZE, TMP0
 F_MAX FREEZE, FREEZE, ZERO
 b .Lrain_freezing_rate_ready
.Lrapid_rain_freezing:
 F_SUB TMP0, RTT, T
 F_MUL FACTOR, HALF, TMP0
 F_ADD FACTOR, ONE, FACTOR
 F_MUL FACTOR, DT, FACTOR
 PAR TMP1, RTAUMEL
 F_DIV FACTOR, FACTOR, TMP1
 F_ABS FACTOR, FACTOR
 F_MUL FREEZE, TMP0, FACTOR
 F_MUL FREEZE, FREEZE, RLDCP
 F_MAX FREEZE, FREEZE, ZERO
.Lrain_freezing_rate_ready:
 F_CMP FREEZE, SMALL
 b.le .Lrain_freezing_ready
 F_MIN FREEZE, QR, FREEZE
 F_ADD QA43, QA43, FREEZE
 F_SUB QA34, QA34, FREEZE
.Lrain_freezing_ready:
 // Source 4.14. Liquid freezes below the homogeneous freezing temperature.
 PAR TMP0, RTHOMO
 F_SUB TMP0, TMP0, T
 F_MUL FREEZE, TMP0, RLDCP
 F_MAX FREEZE, FREEZE, ZERO
 F_CMP FREEZE, SMALL
 b.le .Lcloud_freezing_ready
 F_CMP FG1, SMALL
 b.le .Lcloud_freezing_ready
 F_MIN FREEZE, FG1, FREEZE
 F_ADD QA21, QA21, FREEZE
 F_SUB QA12, QA12, FREEZE
.Lcloud_freezing_ready:
 // Source 4.9. Snow collects supercooled liquid, implicitly in its liquid amount.
 F_CMP T, RTT
 b.gt .Lsnow_riming_ready
 F_CMP LIQCLD, SMALL
 b.le .Lsnow_riming_ready
 PAR TMP0, RDENSREF
 F_DIV TMP0, TMP0, RHO
 LIT TMP1, .LC04single
 POW FALLCORR, TMP0, TMP1
 F_CMP SNOWCLD, SMALL
 b.le .Lsnow_riming_ready
 LIT TMP0, .LC001
 F_CMP COVPTOT, TMP0
 b.le .Lsnow_riming_ready
 PAR RIMELIQ, RCL_EFFRIME
 F_MUL RIMELIQ, RIMELIQ, COVPTOT
 F_MUL RIMELIQ, RIMELIQ, DT
 PAR TMP0, RCL_CONST7S
 F_MUL RIMELIQ, RIMELIQ, TMP0
 F_MUL RIMELIQ, RIMELIQ, FALLCORR
 F_MUL TMP0, RHO, SNOWCLD
 PAR TMP1, RCL_CONST1S
 F_MUL TMP0, TMP0, TMP1
 PAR TMP1, RCL_CONST8S
 POW TMP0, TMP0, TMP1
 F_MUL RIMELIQ, RIMELIQ, TMP0
 F_MIN RIMELIQ, RIMELIQ, ONE
 F_ADD QB41, QB41, RIMELIQ
.Lsnow_riming_ready:
 F_CMP RAINCLD, SMALL
 b.le .Lzero_distribution_R
 F_MUL TMP0, RHO, RAINCLD
 PAR TMP1, RCL_LAM1R
 F_DIV TMP0, TMP1, TMP0
 PAR TMP1, RCL_LAM2R
 POW LAMR, TMP0, TMP1
 PAR N0R, RCL_X1R
 PAR TMP1, RCL_X2R
 POW TMP0, LAMR, TMP1
 F_MUL N0R, N0R, TMP0
 b .Ldistribution_R_ready
.Lzero_distribution_R:
 ZER LAMR
 ZER N0R
.Ldistribution_R_ready:
 F_CMP SNOWCLD, SMALL
 b.le .Lzero_distribution_S
 F_MUL TMP0, RHO, SNOWCLD
 PAR TMP1, RCL_LAM1S
 F_DIV TMP0, TMP1, TMP0
 PAR TMP1, RCL_LAM2S
 POW LAMS, TMP0, TMP1
 PAR N0S, RCL_X1S
 b .Ldistribution_S_ready
.Lzero_distribution_S:
 ZER LAMS
 ZER N0S
.Ldistribution_S_ready:
 F_CMP ICECLD, SMALL
 b.le .Lzero_distribution_I
 F_MUL TMP0, RHO, ICECLD
 PAR TMP1, RCL_LAM1S
 F_DIV TMP0, TMP1, TMP0
 PAR TMP1, RCL_LAM2S
 POW LAMI, TMP0, TMP1
 PAR N0I, RCL_X1S
 b .Ldistribution_I_ready
.Lzero_distribution_I:
 ZER LAMI
 ZER N0I
.Ldistribution_I_ready:
 // Source collection of rain by snow.
 F_CMP T, RTT
 b.gt .Lcollection_S_ready
 COL TMP0, 59
 F_CMP TMP0, SMALL
 b.ge .Lcollection_S_ready
 F_CMP RAINCLD, SMALL
 b.le .Lcollection_S_ready
 F_CMP SNOWCLD, SMALL
 b.le .Lcollection_S_ready
 F_SUB TMP0, FALLSPD3, FALLSPD4
 F_ABS TMP0, TMP0
 F_ADD TMP1, FALLSPD3, FALLSPD4
 LIT TMP2, .LCeight
 F_DIV TMP1, TMP1, TMP2
 F_MAX FALLDIFF, TMP0, TMP1
 GLOB PI, __yomcst_MOD_rpi
 F_MUL FACTOR, PI, PI
 PAR TMP0, RDENSWAT
 F_MUL FACTOR, FACTOR, TMP0
 F_MUL FACTOR, FACTOR, ONE
 F_MUL FACTOR, FACTOR, RHO
 F_MUL FACTOR, FACTOR, N0R
 F_MUL FACTOR, FACTOR, N0S
 F_MUL TMP0, LAMR, LAMR
 F_MUL TMP0, TMP0, LAMR
 F_MUL TMP0, LAMS, TMP0
 F_DIV FACTOR, FACTOR, TMP0
 F_DIV RAT, LAMR, LAMS
 F_MUL RACI, COVPTOT, DT
 F_MUL RACI, RACI, FACTOR
 F_MUL RACI, RACI, FALLDIFF
 F_MUL TMP0, HALF, RAT
 LIT TMP1, .LCtwo
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, TMP0, RAT
 LIT TMP1, .LCfive
 F_ADD TMP0, TMP0, TMP1
 F_MUL RACI, RACI, TMP0
 F_MUL TMP0, LAMR, LAMR
 F_MUL TMP0, TMP0, LAMR
 F_DIV RACI, RACI, TMP0
 F_ADD QA43, QA43, RACI
 F_SUB QA34, QA34, RACI
.Lcollection_S_ready:
 // Source collection of rain by ice.
 F_CMP T, RTT
 b.gt .Lcollection_I_ready
 COL TMP0, 59
 F_CMP TMP0, SMALL
 b.ge .Lcollection_I_ready
 F_CMP RAINCLD, SMALL
 b.le .Lcollection_I_ready
 F_CMP ICECLD, SMALL
 b.le .Lcollection_I_ready
 F_SUB TMP0, FALLSPD3, FALLSPD2
 F_ABS TMP0, TMP0
 F_ADD TMP1, FALLSPD3, FALLSPD2
 LIT TMP2, .LCeight
 F_DIV TMP1, TMP1, TMP2
 F_MAX FALLDIFF, TMP0, TMP1
 GLOB PI, __yomcst_MOD_rpi
 F_MUL FACTOR, PI, PI
 PAR TMP0, RDENSWAT
 F_MUL FACTOR, FACTOR, TMP0
 LIT TMP0, .LC01
 F_MUL FACTOR, FACTOR, TMP0
 F_MUL FACTOR, FACTOR, RHO
 F_MUL FACTOR, FACTOR, N0R
 F_MUL FACTOR, FACTOR, N0I
 F_MUL TMP0, LAMR, LAMR
 F_MUL TMP0, TMP0, LAMR
 F_MUL TMP0, LAMI, TMP0
 F_DIV FACTOR, FACTOR, TMP0
 F_DIV RAT, LAMR, LAMI
 F_MUL RACI, COVPTOT, DT
 F_MUL RACI, RACI, FACTOR
 F_MUL RACI, RACI, FALLDIFF
 F_MUL TMP0, HALF, RAT
 LIT TMP1, .LCtwo
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, TMP0, RAT
 LIT TMP1, .LCfive
 F_ADD TMP0, TMP0, TMP1
 F_MUL RACI, RACI, TMP0
 F_MUL TMP0, LAMR, LAMR
 F_MUL TMP0, TMP0, LAMR
 F_DIV RACI, RACI, TMP0
 F_ADD QA23, QA23, RACI
 F_SUB QA32, QA32, RACI
.Lcollection_I_ready:
 // Source 4.15. Snow sublimation uses the source signed denominator and coverage reduction.
 PAR RHLIMIT, RPRECRHMAX
 F_SUB TMP0, ONE, RHLIMIT
 F_MUL TMP0, TMP0, COVPMAX
 F_SUB TMP1, ONE, A
 F_MAX TMP1, SMALL, TMP1
 F_DIV TMP0, TMP0, TMP1
 F_ADD RHLIMIT, RHLIMIT, TMP0
 PAR TMP0, RPRECRHMAX
 F_MAX RHLIMIT, RHLIMIT, TMP0
 F_MIN RHLIMIT, RHLIMIT, ONE
 F_MUL TMP0, A, QSI
 F_SUB TMP0, QV, TMP0
 F_SUB TMP1, ONE, A
 F_MAX TMP1, SMALL, TMP1
 F_DIV QE, TMP0, TMP1
 F_MIN QE, QE, QSI
 F_MAX QE, ZERO, QE
 F_CMP COVPCLR, SMALL
 b.le .Lsnow_sublimation_ready
 F_CMP FG4, SMALL
 b.le .Lsnow_sublimation_ready
 F_MUL TMP0, RHLIMIT, QSI
 F_CMP QE, TMP0
 b.ge .Lsnow_sublimation_ready
 F_MUL SIGNTMP, COVPTOT, DTGDP
 F_ABS TMP0, SIGNTMP
 F_MAX TMP0, TMP0, EPS
 LD d0, TMP0
 LD d1, SIGNTMP
 fmov x9, d0
 fmov x10, d1
 ubfx x10, x10, #63, #1
 bfi x9, x10, #63, #1
 fmov d0, x9
 ST d0, TMP0
 F_MUL QPRE, FG4, COVPCLR
 F_DIV QPRE, QPRE, TMP0
 ldr x9, [x19, #272]
 madd x10, x22, x23, x24
 ldr d0, [x9, x10, lsl #3]
 ST d0, TMP0
 F_DIV TMP0, P, TMP0
 F_SQRT BETA, TMP0
 PAR TMP0, RVRFACTOR
 F_DIV BETA, BETA, TMP0
 F_MUL BETA, BETA, QPRE
 F_MAX TMP0, COVPCLR, SMALL
 F_DIV BETA, BETA, TMP0
 LIT TMP1, .LC05777
 POW BETA, BETA, TMP1
 PAR TMP0, RPECONS
 F_MUL TMP0, RG, TMP0
 F_MUL BETA, TMP0, BETA
 F_MUL DENOM, BETA, DT
 F_MUL DENOM, DENOM, CORQSI
 F_ADD DENOM, ONE, DENOM
 F_MUL EVAP, COVPCLR, BETA
 F_SUB TMP0, QSI, QE
 F_MUL EVAP, EVAP, TMP0
 F_DIV EVAP, EVAP, DENOM
 F_MUL EVAP, EVAP, DP
 F_MUL EVAP, EVAP, RGR
 F_MUL EVAP, EVAP, DTGDP
 F_MIN EVAP, EVAP, FG4
 F_ADD QA54, QA54, EVAP
 F_SUB QA45, QA45, EVAP
 F_SUB TMP0, COVPTOT, A
 F_MUL TMP0, TMP0, EVAP
 F_DIV TMP0, TMP0, FG4
 F_MAX TMP0, ZERO, TMP0
 F_SUB TMP0, COVPTOT, TMP0
 PAR TMP1, RCOVPMIN
 F_MAX COVPTOT, TMP1, TMP0
 F_SUB FG4, FG4, EVAP
.Lsnow_sublimation_ready:
 PAR TMP0, RVICE
 F_CMP TMP0, ZERO
 b.le .Lsmall_precip_2_ready
 PAR TMP0, RLMIN
 F_CMP FG2, TMP0
 b.ge .Lsmall_precip_2_ready
 F_ADD QA52, QA52, FG2
 F_SUB QA25, QA25, FG2
.Lsmall_precip_2_ready:
 PAR TMP0, RVRAIN
 F_CMP TMP0, ZERO
 b.le .Lsmall_precip_3_ready
 PAR TMP0, RLMIN
 F_CMP FG3, TMP0
 b.ge .Lsmall_precip_3_ready
 F_ADD QA53, QA53, FG3
 F_SUB QA35, QA35, FG3
.Lsmall_precip_3_ready:
 PAR TMP0, RVSNOW
 F_CMP TMP0, ZERO
 b.le .Lsmall_precip_4_ready
 PAR TMP0, RLMIN
 F_CMP FG4, TMP0
 b.ge .Lsmall_precip_4_ready
 F_ADD QA54, QA54, FG4
 F_SUB QA45, QA45, FG4
.Lsmall_precip_4_ready:
 // Source 5.1. Cloud fraction retains the implicit downward transport sink.
 F_ADD ANEWM1, A, SOLAC
 F_ADD TMP0, ONE, SOLAB
 F_DIV ANEWM1, ANEWM1, TMP0
 F_MIN ANEWM1, ANEWM1, ONE
 PAR TMP0, RAMIN
 F_CMP ANEWM1, TMP0
 b.ge .Lcloud_fraction_ready
 ZER ANEWM1
.Lcloud_fraction_ready:
 F_SUB DA, ANEWM1, AOR
 // Source 5.2.1. Calculate explicit sink limits in the original species order.
 ZER SINKSUM
 F_SUB SINKSUM, SINKSUM, QA11
 F_SUB SINKSUM, SINKSUM, QA12
 F_SUB SINKSUM, SINKSUM, QA13
 F_SUB SINKSUM, SINKSUM, QA14
 F_SUB SINKSUM, SINKSUM, QA15
 F_MAX MAXVAL, QL, SMALL
 F_MAX RAT, SINKSUM, MAXVAL
 F_DIV RATIOS1, MAXVAL, RAT
 ZER SINKSUM
 F_SUB SINKSUM, SINKSUM, QA21
 F_SUB SINKSUM, SINKSUM, QA22
 F_SUB SINKSUM, SINKSUM, QA23
 F_SUB SINKSUM, SINKSUM, QA24
 F_SUB SINKSUM, SINKSUM, QA25
 F_MAX MAXVAL, QI, SMALL
 F_MAX RAT, SINKSUM, MAXVAL
 F_DIV RATIOS2, MAXVAL, RAT
 ZER SINKSUM
 F_SUB SINKSUM, SINKSUM, QA31
 F_SUB SINKSUM, SINKSUM, QA32
 F_SUB SINKSUM, SINKSUM, QA33
 F_SUB SINKSUM, SINKSUM, QA34
 F_SUB SINKSUM, SINKSUM, QA35
 F_MAX MAXVAL, QR, SMALL
 F_MAX RAT, SINKSUM, MAXVAL
 F_DIV RATIOS3, MAXVAL, RAT
 ZER SINKSUM
 F_SUB SINKSUM, SINKSUM, QA41
 F_SUB SINKSUM, SINKSUM, QA42
 F_SUB SINKSUM, SINKSUM, QA43
 F_SUB SINKSUM, SINKSUM, QA44
 F_SUB SINKSUM, SINKSUM, QA45
 F_MAX MAXVAL, QS, SMALL
 F_MAX RAT, SINKSUM, MAXVAL
 F_DIV RATIOS4, MAXVAL, RAT
 ZER SINKSUM
 F_SUB SINKSUM, SINKSUM, QA51
 F_SUB SINKSUM, SINKSUM, QA52
 F_SUB SINKSUM, SINKSUM, QA53
 F_SUB SINKSUM, SINKSUM, QA54
 F_SUB SINKSUM, SINKSUM, QA55
 F_MAX MAXVAL, QV, SMALL
 F_MAX RAT, SINKSUM, MAXVAL
 F_DIV RATIOS5, MAXVAL, RAT
 // Stable insertion sort. An equal ratio retains its original species position.
 add x11, x20, #RATIOS1
 add x12, sp, #1024
 str wzr, [x12]
 mov x9, #1
.Lorder_insert:
 sub x10, x9, #1
 ldr d1, [x11, x9, lsl #3]
.Lorder_shift:
 ldr w13, [x12, x10, lsl #2]
 ldr d0, [x11, x13, lsl #3]
 fcmp d0, d1
 b.le .Lorder_place
 add x14, x10, #1
 str w13, [x12, x14, lsl #2]
 subs x10, x10, #1
 b.ge .Lorder_shift
.Lorder_place:
 add x14, x10, #1
 str w9, [x12, x14, lsl #2]
 add x9, x9, #1
 cmp x9, #5
 b.lt .Lorder_insert
 // Recalculate a row after earlier species scaling. Save its signs before any pair changes.
 add x11, x20, #QA11
 add x12, sp, #1024
 add x13, sp, #1048
 mov x14, #0
.Lscale_ordered_species:
 ldr w15, [x12, x14, lsl #2]
 mov x9, #0
 fmov d2, xzr
.Lscale_sink_sum:
 mov x10, #40
 mul x10, x9, x10
 add x10, x10, x15, lsl #3
 ldr d0, [x11, x10]
 fsub d2, d2, d0
 fcmp d0, #0.0
 cset w10, lt
 str w10, [x13, x9, lsl #2]
 add x9, x9, #1
 cmp x9, #5
 b.lt .Lscale_sink_sum
 add x9, x20, #QL
 ldr d0, [x9, x15, lsl #3]
 LD d1, SMALL
 fmaxnm d0, d0, d1
 fmaxnm d2, d2, d0
 fdiv d2, d0, d2
 mov x9, #0
.Lscale_sink_pairs:
 ldr w10, [x13, x9, lsl #2]
 cbz w10, .Lscale_sink_next
 mov x10, #40
 mul x10, x9, x10
 add x10, x10, x15, lsl #3
 ldr d0, [x11, x10]
 fmul d0, d0, d2
 str d0, [x11, x10]
 mov x10, #40
 mul x10, x15, x10
 add x10, x10, x9, lsl #3
 ldr d0, [x11, x10]
 fmul d0, d0, d2
 str d0, [x11, x10]
.Lscale_sink_next:
 add x9, x9, #1
 cmp x9, #5
 b.lt .Lscale_sink_pairs
 add x14, x14, #1
 cmp x14, #5
 b.lt .Lscale_ordered_species
 // Source 5.2.2. Form each matrix column and each right-hand side in source order.
 F_ADD LHS11, ONE, FALLSINK1
 F_ADD LHS11, LHS11, QB11
 F_ADD LHS11, LHS11, QB21
 F_ADD LHS11, LHS11, QB31
 F_ADD LHS11, LHS11, QB41
 F_ADD LHS11, LHS11, QB51
 F_NEG LHS21, QB21
 F_NEG LHS31, QB31
 F_NEG LHS41, QB41
 F_NEG LHS51, QB51
 F_NEG LHS12, QB12
 F_ADD LHS22, ONE, FALLSINK2
 F_ADD LHS22, LHS22, QB12
 F_ADD LHS22, LHS22, QB22
 F_ADD LHS22, LHS22, QB32
 F_ADD LHS22, LHS22, QB42
 F_ADD LHS22, LHS22, QB52
 F_NEG LHS32, QB32
 F_NEG LHS42, QB42
 F_NEG LHS52, QB52
 F_NEG LHS13, QB13
 F_NEG LHS23, QB23
 F_ADD LHS33, ONE, FALLSINK3
 F_ADD LHS33, LHS33, QB13
 F_ADD LHS33, LHS33, QB23
 F_ADD LHS33, LHS33, QB33
 F_ADD LHS33, LHS33, QB43
 F_ADD LHS33, LHS33, QB53
 F_NEG LHS43, QB43
 F_NEG LHS53, QB53
 F_NEG LHS14, QB14
 F_NEG LHS24, QB24
 F_NEG LHS34, QB34
 F_ADD LHS44, ONE, FALLSINK4
 F_ADD LHS44, LHS44, QB14
 F_ADD LHS44, LHS44, QB24
 F_ADD LHS44, LHS44, QB34
 F_ADD LHS44, LHS44, QB44
 F_ADD LHS44, LHS44, QB54
 F_NEG LHS54, QB54
 F_NEG LHS15, QB15
 F_NEG LHS25, QB25
 F_NEG LHS35, QB35
 F_NEG LHS45, QB45
 F_ADD LHS55, ONE, FALLSINK5
 F_ADD LHS55, LHS55, QB15
 F_ADD LHS55, LHS55, QB25
 F_ADD LHS55, LHS55, QB35
 F_ADD LHS55, LHS55, QB45
 F_ADD LHS55, LHS55, QB55
 ZER SUMRHS
 F_ADD SUMRHS, SUMRHS, QA11
 F_ADD SUMRHS, SUMRHS, QA12
 F_ADD SUMRHS, SUMRHS, QA13
 F_ADD SUMRHS, SUMRHS, QA14
 F_ADD SUMRHS, SUMRHS, QA15
 F_ADD XN1, QL, SUMRHS
 ZER SUMRHS
 F_ADD SUMRHS, SUMRHS, QA21
 F_ADD SUMRHS, SUMRHS, QA22
 F_ADD SUMRHS, SUMRHS, QA23
 F_ADD SUMRHS, SUMRHS, QA24
 F_ADD SUMRHS, SUMRHS, QA25
 F_ADD XN2, QI, SUMRHS
 ZER SUMRHS
 F_ADD SUMRHS, SUMRHS, QA31
 F_ADD SUMRHS, SUMRHS, QA32
 F_ADD SUMRHS, SUMRHS, QA33
 F_ADD SUMRHS, SUMRHS, QA34
 F_ADD SUMRHS, SUMRHS, QA35
 F_ADD XN3, QR, SUMRHS
 ZER SUMRHS
 F_ADD SUMRHS, SUMRHS, QA41
 F_ADD SUMRHS, SUMRHS, QA42
 F_ADD SUMRHS, SUMRHS, QA43
 F_ADD SUMRHS, SUMRHS, QA44
 F_ADD SUMRHS, SUMRHS, QA45
 F_ADD XN4, QS, SUMRHS
 ZER SUMRHS
 F_ADD SUMRHS, SUMRHS, QA51
 F_ADD SUMRHS, SUMRHS, QA52
 F_ADD SUMRHS, SUMRHS, QA53
 F_ADD SUMRHS, SUMRHS, QA54
 F_ADD SUMRHS, SUMRHS, QA55
 F_ADD XN5, QV, SUMRHS
 // No-pivot LU factorisation. Every product rounds before its subtraction.
 // Keep the fixed five-species solve in registers, with the same FP64 order.
 // d0..d24 hold LHS, d25..d29 hold XN, and d30 holds rounded TMP0.
 LD d0, LHS11
 LD d1, LHS21
 LD d2, LHS31
 LD d3, LHS41
 LD d4, LHS51
 LD d5, LHS12
 LD d6, LHS22
 LD d7, LHS32
 LD d8, LHS42
 LD d9, LHS52
 LD d10, LHS13
 LD d11, LHS23
 LD d12, LHS33
 LD d13, LHS43
 LD d14, LHS53
 LD d15, LHS14
 LD d16, LHS24
 LD d17, LHS34
 LD d18, LHS44
 LD d19, LHS54
 LD d20, LHS15
 LD d21, LHS25
 LD d22, LHS35
 LD d23, LHS45
 LD d24, LHS55
 LD d25, XN1
 LD d26, XN2
 LD d27, XN3
 LD d28, XN4
 LD d29, XN5
 fdiv d1, d1, d0
 fmul d30, d1, d5
 fsub d6, d6, d30
 fmul d30, d1, d10
 fsub d11, d11, d30
 fmul d30, d1, d15
 fsub d16, d16, d30
 fmul d30, d1, d20
 fsub d21, d21, d30
 fdiv d2, d2, d0
 fmul d30, d2, d5
 fsub d7, d7, d30
 fmul d30, d2, d10
 fsub d12, d12, d30
 fmul d30, d2, d15
 fsub d17, d17, d30
 fmul d30, d2, d20
 fsub d22, d22, d30
 fdiv d3, d3, d0
 fmul d30, d3, d5
 fsub d8, d8, d30
 fmul d30, d3, d10
 fsub d13, d13, d30
 fmul d30, d3, d15
 fsub d18, d18, d30
 fmul d30, d3, d20
 fsub d23, d23, d30
 fdiv d4, d4, d0
 fmul d30, d4, d5
 fsub d9, d9, d30
 fmul d30, d4, d10
 fsub d14, d14, d30
 fmul d30, d4, d15
 fsub d19, d19, d30
 fmul d30, d4, d20
 fsub d24, d24, d30
 fdiv d7, d7, d6
 fmul d30, d7, d11
 fsub d12, d12, d30
 fmul d30, d7, d16
 fsub d17, d17, d30
 fmul d30, d7, d21
 fsub d22, d22, d30
 fdiv d8, d8, d6
 fmul d30, d8, d11
 fsub d13, d13, d30
 fmul d30, d8, d16
 fsub d18, d18, d30
 fmul d30, d8, d21
 fsub d23, d23, d30
 fdiv d9, d9, d6
 fmul d30, d9, d11
 fsub d14, d14, d30
 fmul d30, d9, d16
 fsub d19, d19, d30
 fmul d30, d9, d21
 fsub d24, d24, d30
 fdiv d13, d13, d12
 fmul d30, d13, d17
 fsub d18, d18, d30
 fmul d30, d13, d22
 fsub d23, d23, d30
 fdiv d14, d14, d12
 fmul d30, d14, d17
 fsub d19, d19, d30
 fmul d30, d14, d22
 fsub d24, d24, d30
 fdiv d19, d19, d18
 fmul d30, d19, d23
 fsub d24, d24, d30
 // Forward substitution, then reverse back substitution.
 fmul d30, d1, d25
 fsub d26, d26, d30
 fmul d30, d2, d25
 fsub d27, d27, d30
 fmul d30, d7, d26
 fsub d27, d27, d30
 fmul d30, d3, d25
 fsub d28, d28, d30
 fmul d30, d8, d26
 fsub d28, d28, d30
 fmul d30, d13, d27
 fsub d28, d28, d30
 fmul d30, d4, d25
 fsub d29, d29, d30
 fmul d30, d9, d26
 fsub d29, d29, d30
 fmul d30, d14, d27
 fsub d29, d29, d30
 fmul d30, d19, d28
 fsub d29, d29, d30
 fdiv d29, d29, d24
 fmul d30, d23, d29
 fsub d28, d28, d30
 fdiv d28, d28, d18
 fmul d30, d17, d28
 fsub d27, d27, d30
 fmul d30, d22, d29
 fsub d27, d27, d30
 fdiv d27, d27, d12
 fmul d30, d11, d27
 fsub d26, d26, d30
 fmul d30, d16, d28
 fsub d26, d26, d30
 fmul d30, d21, d29
 fsub d26, d26, d30
 fdiv d26, d26, d6
 fmul d30, d5, d26
 fsub d25, d25, d30
 fmul d30, d10, d27
 fsub d25, d25, d30
 fmul d30, d15, d28
 fsub d25, d25, d30
 fmul d30, d20, d29
 fsub d25, d25, d30
 fdiv d25, d25, d0
 // Retain every final matrix, solution and temporary word before cleaning.
 ST d0, LHS11
 ST d1, LHS21
 ST d2, LHS31
 ST d3, LHS41
 ST d4, LHS51
 ST d5, LHS12
 ST d6, LHS22
 ST d7, LHS32
 ST d8, LHS42
 ST d9, LHS52
 ST d10, LHS13
 ST d11, LHS23
 ST d12, LHS33
 ST d13, LHS43
 ST d14, LHS53
 ST d15, LHS14
 ST d16, LHS24
 ST d17, LHS34
 ST d18, LHS44
 ST d19, LHS54
 ST d20, LHS15
 ST d21, LHS25
 ST d22, LHS35
 ST d23, LHS45
 ST d24, LHS55
 ST d25, XN1
 ST d26, XN2
 ST d27, XN3
 ST d28, XN4
 ST d29, XN5
 ST d30, TMP0
 F_CMP XN1, SMALL
 b.ge .Lsolved_species_1_ready
 F_ADD XN5, XN5, XN1
 ZER XN1
.Lsolved_species_1_ready:
 F_CMP XN2, SMALL
 b.ge .Lsolved_species_2_ready
 F_ADD XN5, XN5, XN2
 ZER XN2
.Lsolved_species_2_ready:
 F_CMP XN3, SMALL
 b.ge .Lsolved_species_3_ready
 F_ADD XN5, XN5, XN3
 ZER XN3
.Lsolved_species_3_ready:
 F_CMP XN4, SMALL
 b.ge .Lsolved_species_4_ready
 F_ADD XN5, XN5, XN4
 ZER XN4
.Lsolved_species_4_ready:
 COPY PREV1, XN1
 SAVE XN1, 168
 F_MUL TMP0, FALLSINK1, XN1
 F_MUL TMP0, TMP0, RDTGDP
 LD d0, TMP0
 str d0, [x21, #528]
 COPY PREV2, XN2
 SAVE XN2, 176
 F_MUL TMP0, FALLSINK2, XN2
 F_MUL TMP0, TMP0, RDTGDP
 LD d0, TMP0
 str d0, [x21, #536]
 COPY PREV3, XN3
 SAVE XN3, 184
 F_MUL TMP0, FALLSINK3, XN3
 F_MUL TMP0, TMP0, RDTGDP
 LD d0, TMP0
 str d0, [x21, #544]
 COPY PREV4, XN4
 SAVE XN4, 192
 F_MUL TMP0, FALLSINK4, XN4
 F_MUL TMP0, TMP0, RDTGDP
 LD d0, TMP0
 str d0, [x21, #552]
 COPY PREV5, XN5
 F_MUL TMP0, FALLSINK5, XN5
 F_MUL TMP0, TMP0, RDTGDP
 LD d0, TMP0
 str d0, [x21, #560]
 ldr d0, [x21, #552]
 ldr d1, [x21, #544]
 fadd d0, d0, d1
 ST d0, PRETOT
 F_CMP PRETOT, SMALL
 b.ge .Lfinal_precipitation_cover
 ZER COVPTOT
.Lfinal_precipitation_cover:
 // Source 6.1. Account for transport before each phase latent-heat increment.
 F_ADD FLUXQ, CONVSRC1, FALLSRC1
 F_ADD TMP0, FALLSINK1, CONVSINK1
 F_MUL TMP0, TMP0, XN1
 F_SUB FLUXQ, FLUXQ, TMP0
 F_SUB TMP0, XN1, QL
 F_SUB TMP0, TMP0, FLUXQ
 F_MUL TMP0, ALV, TMP0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 18
 F_ADD TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_SUB TMP0, XN1, QL0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 21, 0
 F_ADD TMP1, TMP1, TMP0
 PUT 21, TMP1, 0
 F_ADD FLUXQ, CONVSRC2, FALLSRC2
 F_ADD TMP0, FALLSINK2, CONVSINK2
 F_MUL TMP0, TMP0, XN2
 F_SUB FLUXQ, FLUXQ, TMP0
 F_SUB TMP0, XN2, QI
 F_SUB TMP0, TMP0, FLUXQ
 F_MUL TMP0, ALS, TMP0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 18
 F_ADD TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_SUB TMP0, XN2, QI0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 21, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 21, TMP1, 1
 F_ADD FLUXQ, CONVSRC3, FALLSRC3
 F_ADD TMP0, FALLSINK3, CONVSINK3
 F_MUL TMP0, TMP0, XN3
 F_SUB FLUXQ, FLUXQ, TMP0
 F_SUB TMP0, XN3, QR
 F_SUB TMP0, TMP0, FLUXQ
 F_MUL TMP0, ALV, TMP0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 18
 F_ADD TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_SUB TMP0, XN3, QR0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 21, 2
 F_ADD TMP1, TMP1, TMP0
 PUT 21, TMP1, 2
 F_ADD FLUXQ, CONVSRC4, FALLSRC4
 F_ADD TMP0, FALLSINK4, CONVSINK4
 F_MUL TMP0, TMP0, XN4
 F_SUB FLUXQ, FLUXQ, TMP0
 F_SUB TMP0, XN4, QS
 F_SUB TMP0, TMP0, FLUXQ
 F_MUL TMP0, ALS, TMP0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 18
 F_ADD TMP1, TMP1, TMP0
 PUT 18, TMP1
 F_SUB TMP0, XN4, QS0
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 21, 3
 F_ADD TMP1, TMP1, TMP0
 PUT 21, TMP1, 3
 // Source 6.2 through 6.4. Construct the actual updated state for the accepted child.
 F_SUB TMP0, XN5, QV
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 19
 F_ADD TMP1, TMP1, TMP0
 PUT 19, TMP1
 F_MUL TMP0, DA, INVDT
 OWN TMP1, 20
 F_ADD TMP1, TMP1, TMP0
 PUT 20, TMP1
 OWN TMP0, 19
 OWN TMP1, 15
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, DT, TMP0
 OWN TMP1, 13
 F_ADD QUP, TMP1, TMP0
 OWN TMP0, 18
 OWN TMP1, 14
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, DT, TMP0
 OWN TMP1, 12
 F_ADD TUP, TMP1, TMP0
 OWN TMP0, 20
 OWN TMP1, 16
 F_ADD TMP0, TMP0, TMP1
 F_MUL TMP0, DT, TMP0
 OWN TMP1, 50
 F_ADD AUP, TMP1, TMP0
 ldr x9, [x19, #272]
 madd x10, x22, x23, x24
 ldr d0, [x9, x10, lsl #3]
 ST d0, PSURF
 mov w9, #1
 str w9, [sp, #1072]
 mov x0, CLOUD_PARAMETERS
 add x1, sp, #1072
 mov x2, x1
 mov x3, x1
 ldr x4, [x19, #80]
 mov x5, x1
 add x6, x20, #TUP
 add x7, x20, #QUP
 sub sp, sp, #128
 add x9, x20, #AUP
 str x9, [sp]
 add x9, x20, #P
 str x9, [sp, #8]
 add x9, x20, #PSURF
 str x9, [sp, #16]
 add x9, x20, #TADJ
 str x9, [sp, #24]
 add x9, x20, #QADJ
 str x9, [sp, #32]
 add x9, x20, #AADJ
 str x9, [sp, #40]
 add x9, x20, #LADJ
 str x9, [sp, #48]
 add x9, x20, #IADJ
 str x9, [sp, #56]
 bl CLOUD_SUPERSAT
 add sp, sp, #128
 F_MUL TMP0, QADJ, INVDT
 OWN TMP1, 19, 0
 F_ADD TMP1, TMP1, TMP0
 PUT 19, TMP1, 0
 F_MUL TMP0, TADJ, INVDT
 OWN TMP1, 18, 0
 F_ADD TMP1, TMP1, TMP0
 PUT 18, TMP1, 0
 F_MUL TMP0, AADJ, INVDT
 OWN TMP1, 20, 0
 F_ADD TMP1, TMP1, TMP0
 PUT 20, TMP1, 0
 F_MUL TMP0, LADJ, INVDT
 OWN TMP1, 21, 0
 F_ADD TMP1, TMP1, TMP0
 PUT 21, TMP1, 0
 F_MUL TMP0, IADJ, INVDT
 OWN TMP1, 21, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 21, TMP1, 1
 OWN TMP0, 21, 0
 F_MUL TMP0, TMP0, DT
 F_ADD LADJ, QL0, TMP0
 F_CMP LADJ, ZERO
 b.ge .Lnegative_LADJ_ready
 F_MUL TMP0, LADJ, INVDT
 OWN TMP1, 21, 0
 F_SUB TMP1, TMP1, TMP0
 PUT 21, TMP1, 0
 OWN TMP1, 19
 F_ADD TMP1, TMP1, TMP0
 PUT 19, TMP1
 F_MUL TMP0, ALV, LADJ
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
.Lnegative_LADJ_ready:
 OWN TMP0, 21, 1
 F_MUL TMP0, TMP0, DT
 F_ADD IADJ, QI0, TMP0
 F_CMP IADJ, ZERO
 b.ge .Lnegative_IADJ_ready
 F_MUL TMP0, IADJ, INVDT
 OWN TMP1, 21, 1
 F_SUB TMP1, TMP1, TMP0
 PUT 21, TMP1, 1
 OWN TMP1, 19
 F_ADD TMP1, TMP1, TMP0
 PUT 19, TMP1
 F_MUL TMP0, ALS, IADJ
 F_MUL TMP0, TMP0, INVDT
 OWN TMP1, 18
 F_SUB TMP1, TMP1, TMP0
 PUT 18, TMP1
.Lnegative_IADJ_ready:
 PUT 57, COVPTOT
 OWN TMP0, 50
 F_ADD TMP0, TMP0, DA
 LIT TMP1, .LC0001
 F_CMP TMP0, TMP1
 b.le .Lcloud_precip_fraction_ready
 F_MAX TMP0, TMP0, COVPTOT
 LIT TMP1, .LC01
 F_MAX TMP0, TMP0, TMP1
 SAVE TMP0, 296
.Lcloud_precip_fraction_ready:
 add x25, x25, #1
 add x21, x21, #320
 cmp x25, x22
 b.lt .Lphysical_level
 // Source 8. The declared optional diagnostics and inhomogeneity route are inactive.
 // Retain every prognostic precipitation and negative-water diagnostic flux.
 mov x25, #0
 ldr x21, [sp, #960]
.Ltotal_precipitation_flux:
 CELL_INDEX
 ROW TMP0, 224
 ROW TMP1, 208
 F_ADD TMP0, TMP0, TMP1
 PUT 70, TMP0
 ROW TMP0, 232
 ROW TMP1, 216
 F_ADD TMP0, TMP0, TMP1
 PUT 71, TMP0
 add x25, x25, #1
 add x21, x21, #320
 cmp x25, x22
 b.le .Ltotal_precipitation_flux
 mov x25, #0
 CELL_INDEX
 ZER TMP0
 PUT 60, TMP0
 PUT 61, TMP0
 PUT 62, TMP0
 PUT 63, TMP0
 PUT 64, TMP0
 PUT 65, TMP0
 PUT 66, TMP0
 PUT 67, TMP0
 PUT 68, TMP0
 PUT 69, TMP0
 ldr x21, [sp, #960]
.Ldiagnostic_level:
 CELL_INDEX
 OWN PH, 34
 OWN PHNEXT, 34, 0, 1
 F_SUB DP, PHNEXT, PH
 F_NEG GDPHR, RGR
 F_MUL GDPHR, GDPHR, DP
 F_MUL GDPHR, GDPHR, INVDT
 OWN TMP0, 60
 PUT 60, TMP0, 0, 1
 OWN TMP0, 61
 PUT 61, TMP0, 0, 1
 OWN TMP0, 60
 PUT 64, TMP0, 0, 1
 OWN TMP0, 61
 PUT 65, TMP0, 0, 1
 OWN TMP0, 63
 PUT 63, TMP0, 0, 1
 OWN TMP0, 62
 PUT 62, TMP0, 0, 1
 OWN TMP0, 63
 PUT 66, TMP0, 0, 1
 OWN TMP0, 62
 PUT 67, TMP0, 0, 1
 OWN TMP0, 68
 PUT 68, TMP0, 0, 1
 OWN TMP0, 69
 PUT 69, TMP0, 0, 1
 ROW TMP0, 104
 COPY ALFA, TMP0
 ROW QLXN, 168
 ROW QL0, 64
 OWN TMP0, 23
 F_MUL TMP0, TMP0, DT
 F_SUB TMP1, QLXN, QL0
 F_ADD TMP1, TMP1, TMP0
 F_MUL TMP1, TMP1, GDPHR
 OWN TMP2, 60, 0, 1
 F_ADD TMP2, TMP2, TMP1
 OWN TMP1, 44, 0
 F_ADD TMP2, TMP2, TMP1
 PUT 60, TMP2, 0, 1
 ROW QLNEG, 136
 F_MUL TMP0, QLNEG, GDPHR
 OWN TMP1, 63, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 63, TMP1, 0, 1
 OWN TMP0, 23
 F_MUL TMP0, TMP0, DT
 F_MUL TMP0, TMP0, GDPHR
 OWN TMP1, 68, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 68, TMP1, 0, 1
 ROW QRXN, 184
 ROW QR0, 80
 F_SUB TMP0, QRXN, QR0
 F_MUL TMP0, TMP0, GDPHR
 OWN TMP1, 64, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 64, TMP1, 0, 1
 ROW QRNEG, 152
 F_MUL TMP0, QRNEG, GDPHR
 OWN TMP1, 66, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 66, TMP1, 0, 1
 ROW QIXN, 176
 ROW QI0, 72
 OWN TMP0, 24
 F_MUL TMP0, TMP0, DT
 F_SUB TMP1, QIXN, QI0
 F_ADD TMP1, TMP1, TMP0
 F_MUL TMP1, TMP1, GDPHR
 OWN TMP2, 61, 0, 1
 F_ADD TMP2, TMP2, TMP1
 OWN TMP1, 44, 1
 F_ADD TMP2, TMP2, TMP1
 PUT 61, TMP2, 0, 1
 ROW QINEG, 144
 F_MUL TMP0, QINEG, GDPHR
 OWN TMP1, 62, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 62, TMP1, 0, 1
 OWN TMP0, 24
 F_MUL TMP0, TMP0, DT
 F_MUL TMP0, TMP0, GDPHR
 OWN TMP1, 69, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 69, TMP1, 0, 1
 ROW QSXN, 192
 ROW QS0, 88
 F_SUB TMP0, QSXN, QS0
 F_MUL TMP0, TMP0, GDPHR
 OWN TMP1, 65, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 65, TMP1, 0, 1
 ROW QSNEG, 160
 F_MUL TMP0, QSNEG, GDPHR
 OWN TMP1, 67, 0, 1
 F_ADD TMP1, TMP1, TMP0
 PUT 67, TMP1, 0, 1
 add x25, x25, #1
 add x21, x21, #320
 cmp x25, x22
 b.lt .Ldiagnostic_level
 mov x25, #0
.Lprecipitation_energy:
 CELL_INDEX
 F_NEG TMP0, LV
 OWN TMP1, 70
 F_MUL TMP0, TMP0, TMP1
 PUT 72, TMP0
 F_NEG TMP0, LS
 OWN TMP1, 71
 F_MUL TMP0, TMP0, TMP1
 PUT 73, TMP0
 add x25, x25, #1
 cmp x25, x22
 b.le .Lprecipitation_energy
 add x24, x24, #1
 b .Lcolumn
.Ldone:
#ifndef MD2ASM_CLOUD_PRIVATE_RANGE
 ldr x0, [sp, #960]
 bl free
#endif
 ldr x9, [sp, #936]
 ldr w10, [sp, #944]
 str w10, [x9]
 ldp d8, d9, [sp, #112]
 ldp d10, d11, [sp, #128]
 ldp d12, d13, [sp, #144]
 ldp d14, d15, [sp, #160]
 ldr x18, [sp, #96]
 ldp x19, x20, [sp, #16]
 ldp x21, x22, [sp, #32]
 ldp x23, x24, [sp, #48]
 ldp x25, x26, [sp, #64]
 ldp x27, x28, [sp, #80]
 ldp x29, x30, [sp]
 add sp, sp, #2, lsl #12
 ret
.Lreject:
 bl abort
 brk #0
#ifdef MD2ASM_CLOUD_PRIVATE_RANGE
.Lcloud_range_empty:
 ret
#endif
.size CLOUD_ENTRY, .-CLOUD_ENTRY
.section .rodata
.align 3
.LCone: .quad 0x3ff0000000000000
.LChalf: .quad 0x3fe0000000000000
.LCeps: .quad 0x3d19000000000000
.LCsmall: .quad 0x3d06849b86a12b9b
.LC01: .quad 0x3fb999999999999a
.LC04: .quad 0x3fd999999999999a
.LC001: .quad 0x3f847ae147ae147b
.LC0001: .quad 0x3f50624dd2f1a9fc
.LCten: .quad 0x4024000000000000
.LCtwenty: .quad 0x4034000000000000
.LCtwo: .quad 0x4000000000000000
.LCfive: .quad 0x4014000000000000
.LC0333: .quad 0x3fd54fdf3b645a1d
.LCone_less_micro: .quad 0x3feffffde7210be9
.LC08: .quad 0x3fe999999999999a
.LC02: .quad 0x3fc999999999999a
.LC09: .quad 0x3feccccccccccccd
.LC04single: .quad 0x3fd99999a0000000
.LC08single: .quad 0x3fe99999a0000000
.LC273: .quad 0x4071100000000000
.LC15: .quad 0x3ff8000000000000
 .balign 8
.LCthree: .quad 0x4008000000000000
.LC393: .quad 0x4078900000000000
.LC120: .quad 0x405e000000000000
.LC015: .quad 0x3fc3333333333333
.LC078: .quad 0x3fe8f5c28f5c28f6
.LC1296: .quad 0x4029eb851eb851ec
.LC0639: .quad 0x3fe472b020c49ba6
.LCthousand: .quad 0x408f400000000000
.LC0024: .quad 0x3f989374bc6a7efa
.LC221: .quad 0x4001ae147ae147ae
.LC0666: .quad 0x3fe54fdf3b645a1d
.LC78: .quad 0x401f333333333333
.LC887: .quad 0x4021bd70a3d70a3d
.LC15000: .quad 0x40cd4c0000000000
.LC065: .quad 0x3fe4cccccccccccd
.LCfifty: .quad 0x4049000000000000
.LCtw1: .quad 0x4094c53d70a3d70a
.LCtw2: .quad 0x3f7e8ff327aa68f5
.LCtw3: .quad 0x40f4c08000000000
.LCtw4: .quad 0x40445189374bc6a8
.LCtw5: .quad 0x4071300000000000
.LCeight: .quad 0x4020000000000000
.LC05777: .quad 0x3fe27c84b5dcc63f
.section .note.GNU-stack,"",%progbits

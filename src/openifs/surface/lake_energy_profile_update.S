// Original OpenIFS lake energy and ice update with bounded signed-depth support.
// Formulation: formulations/openifs/surface/lake_temperature_profile.md
// Contract: skills/md2asm/references/openifs/surface/lake_temperature_profile.md
.equ S_Q_STAR,1632
.equ S_DEPTH,768
.equ S_CORIOLIS,776
.equ S_SFC_P,784
.equ S_ICE_P,792
.equ S_WML_P,800
.equ S_MEAN_P,808
.equ S_BOT_P,816
.equ S_HICE_P,824
.equ S_HML_P,832
.equ S_SHAPE_P,840
.equ S_QW,848
.equ S_QICE,856
.equ S_USTAR,864
.equ S_IICE,872
.equ S_IBOT,880
.equ S_IW,888
.equ S_IH,896
.equ S_I0H,904
.equ S_IHD,912
.equ S_ICE_N,920
.equ S_WML_N,928
.equ S_MEAN_N,936
.equ S_BOT_N,944
.equ S_HICE_N,952
.equ S_HML_N,960
.equ S_SHAPE_N,968
.equ S_SFC_N,976
.equ S_RC_CBL_1,984
.equ S_RC_CBL_2,992
.equ S_RC_I_LIN,1000
.equ S_RC_I_MR,1008
.equ S_RC_RELAX_C,1016
.equ S_RC_RELAX_H,1024
.equ S_RC_SBL_ZM_I,1032
.equ S_RC_SBL_ZM_N,1040
.equ S_RC_SBL_ZM_S,1048
.equ S_RC_SMALL_FLK,1056
.equ S_RC_TT_1,1064
.equ S_RC_TT_2,1072
.equ S_RC_T_MAX,1080
.equ S_RC_T_MIN,1088
.equ S_RH_ICE_MAX,1096
.equ S_RH_ICE_MIN_FLK,1104
.equ S_RH_ML_MAX_FLK,1112
.equ S_RH_ML_MIN_FLK,1120
.equ S_RPHI_I_AST_MR,1128
.equ S_RPHI_I_PR0_LIN,1136
.equ S_RPHI_I_PR1_LIN,1144
.equ S_RPHI_T_PR0_1,1152
.equ S_RPHI_T_PR0_2,1160
.equ S_RTPL_A_T,1168
.equ S_RTPL_C_I,1176
.equ S_RTPL_C_W,1184
.equ S_RTPL_GRAV,1192
.equ S_RTPL_KAPPA_I,1200
.equ S_RTPL_KAPPA_W,1208
.equ S_RTPL_L_F,1216
.equ S_RTPL_RHO_I,1224
.equ S_RTPL_RHO_W_R,1232
.equ S_RTPL_T_F,1240
.equ S_RTPL_T_R,1248
.equ S_RU_STAR_MIN_FLK,1256
.equ S_DT,1264
.equ S_EXT,1272
.equ S_DEPTH_USED,1280
.equ S_SHAPE_MEAN,1288
.equ S_SHAPE_RATE_MAX,1296
.equ S_DMEAN,1304
.equ S_DICE,1312
.equ S_DBOT,1320
.equ S_DHICE,1328
.equ S_DHML,1336
.equ S_DSHAPE,1344
.equ S_N_MEAN,1352
.equ S_WIND_SCALE,1360
.equ S_CONV_SCALE,1368
.equ S_ICE_THRESHOLD,1376
.equ S_STR1,1384
.equ S_STR2,1392
.equ S_R_H,1400
.equ S_R_RHO,1408
.equ S_R_TI,1416
.equ S_R_STAR,1424
.equ S_C_TT,1432
.equ S_C_Q,1440
.equ S_C_ICE,1448
.equ S_PHI_T0,1456
.equ S_PHI_I0,1464
.equ S_PHI_I1,1472
.equ S_WSTAR,1480
.equ S_T0,1488
.equ S_T1,1496
.equ S_T2,1504
.equ S_T3,1512
.equ S_T4,1520
.equ S_T5,1528
.equ S_ZERO,1536
.equ S_ONE,1544
.equ S_TWO,1552
.equ S_HALF,1560
.equ S_SIX,1568
.equ S_NINE_TENTHS,1576
.equ S_CUBE_ROOT,1584
.equ S_SECONDS_MONTH,1592
.equ S_DEPTH_MIN,1600
.equ S_DEPTH_MAX,1608
.equ S_ICE_TEMPERATURE_MIN,1616
.equ S_EPS,1624

.text
.p2align 4
.macro GET reg, name
    ldr \reg,[sp,#S_\name]
.endm
.macro PUT reg, name
    str \reg,[sp,#S_\name]
.endm
.macro COPY destination, source
    GET d0,\source
    PUT d0,\destination
.endm
.macro CALC instruction, destination, left, right
    GET d0,\left
    GET d1,\right
    \instruction d0,d0,d1
    PUT d0,\destination
.endm
.macro NEG destination, source
    GET d0,\source
    fneg d0,d0
    PUT d0,\destination
.endm
.macro ABS destination, source
    GET d0,\source
    fabs d0,d0
    PUT d0,\destination
.endm
.macro SQRT destination, source
    GET d0,\source
    fsqrt d0,d0
    PUT d0,\destination
.endm
.macro SIGN destination, magnitude, sign
    GET d0,\magnitude
    GET d1,\sign
    fmov x9,d0
    fmov x10,d1
    and x9,x9,#0x7fffffffffffffff
    and x10,x10,#0x8000000000000000
    orr x9,x9,x10
    fmov d0,x9
    PUT d0,\destination
.endm
.macro COMPARE left, right
    GET d0,\left
    GET d1,\right
    fcmp d0,d1
.endm
.macro MATH name
    str x18,[sp,#3000]
    bl \name
    ldr x18,[sp,#3000]
.endm
.macro EXP destination, source
    GET d0,\source
    MATH exp
    PUT d0,\destination
.endm
.macro BUOY destination, temperature
    CALC fmul,T4,RTPL_GRAV,RTPL_A_T
    CALC fsub,T5,\temperature,RTPL_T_R
    CALC fmul,\destination,T4,T5
.endm
.macro ARG reg, argument
    ldr \reg,[x19,#(\argument*8)]
.endm
.macro READ destination, argument
    ARG x9,\argument
    ldr x9,[x9]
    ldr d0,[x9,x20,lsl #3]
    PUT d0,\destination
.endm
.macro WRITE source, argument
    ARG x9,\argument
    ldr x9,[x9]
    GET d0,\source
    str d0,[x9,x20,lsl #3]
.endm
.macro CHECK_DESCRIPTOR argument, bytes, kind
    ARG x9,\argument
    ldr x10,[x9]
    cbz x10,.Lreject
    tst x10,#(\bytes-1)
    b.ne .Lreject
    ldr x10,[x9,#16]
    cmp x10,#\bytes
    b.ne .Lreject
    ldr x10,[x9,#32]
    cmp x10,#\bytes
    b.ne .Lreject
    ldrb w10,[x9,#28]
    cmp w10,#1
    b.ne .Lreject
    ldrb w10,[x9,#29]
    cmp w10,#\kind
    b.ne .Lreject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lreject
    ldp x10,x11,[x9,#48]
    sub x11,x11,x10
    add x11,x11,#1
    cmp x11,x21
    b.ne .Lreject
    ldr x11,[x9,#8]
    add x11,x11,x10
    cbnz x11,.Lreject
.endm
.global md2asm_flakeene_profile_r3
.global md2asm_flakeene_stock_signed_depth_r1_7388001
.type md2asm_flakeene_profile_r3,%function
.global md2asm_flakeene_stock_warm_no_ice_r3_7435711
.type md2asm_flakeene_stock_warm_no_ice_r3_7435711,%function
.set md2asm_flakeene_stock_warm_no_ice_r3_7435711,md2asm_flakeene_profile_r3
.global md2asm_flakeene_stock_signed_ice_residual_r2_7388001
.type md2asm_flakeene_stock_signed_ice_residual_r2_7388001,%function
.set md2asm_flakeene_stock_signed_ice_residual_r2_7388001,md2asm_flakeene_profile_r3
.type md2asm_flakeene_stock_signed_depth_r1_7388001,%function
md2asm_flakeene_profile_r3:
md2asm_flakeene_stock_signed_depth_r1_7388001:
    sub sp,sp,#1,lsl #12
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    str x18,[sp,#96]
    add x19,sp,#320
    stp x0,x1,[x19]
    stp x2,x3,[x19,#16]
    stp x4,x5,[x19,#32]
    stp x6,x7,[x19,#48]
    add x11,sp,#1,lsl #12
    mov x10,#8
.Larguments:
    ldr x9,[x11],#8
    str x9,[x19,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#34
    b.lt .Larguments
    mrs x9,fpcr
    cbnz x9,.Lreject
    mov x10,#0
.Lpointers:
    ldr x9,[x19,x10,lsl #3]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    add x10,x10,#1
    cmp x10,#34
    b.lt .Lpointers
    ARG x9,2
    ldr w21,[x9]
    cmp w21,#1
    b.lt .Lreject
    cmp w21,#4096
    b.gt .Lreject
    ARG x9,0
    ldr w23,[x9]
    sub w23,w23,#1
    cmp w23,#0
    b.lt .Lreject
    cmp w23,w21
    b.gt .Lreject
    ARG x9,1
    ldr w24,[x9]
    cmp w24,#0
    b.lt .Lreject
    cmp w24,w21
    b.gt .Lreject
    cmp w24,w23
    b.lt .Lreject

    CHECK_DESCRIPTOR 3,8,3
    CHECK_DESCRIPTOR 4,8,3
    CHECK_DESCRIPTOR 5,4,2
    CHECK_DESCRIPTOR 9,8,3
    CHECK_DESCRIPTOR 10,8,3
    CHECK_DESCRIPTOR 11,8,3
    CHECK_DESCRIPTOR 12,8,3
    CHECK_DESCRIPTOR 13,8,3
    CHECK_DESCRIPTOR 14,8,3
    CHECK_DESCRIPTOR 15,8,3
    CHECK_DESCRIPTOR 16,8,3
    CHECK_DESCRIPTOR 17,8,3
    CHECK_DESCRIPTOR 18,8,3
    CHECK_DESCRIPTOR 19,8,3
    CHECK_DESCRIPTOR 20,8,3
    CHECK_DESCRIPTOR 21,8,3
    CHECK_DESCRIPTOR 22,8,3
    CHECK_DESCRIPTOR 23,8,3
    CHECK_DESCRIPTOR 24,8,3
    CHECK_DESCRIPTOR 25,8,3
    CHECK_DESCRIPTOR 26,8,3
    CHECK_DESCRIPTOR 27,8,3
    CHECK_DESCRIPTOR 28,8,3
    CHECK_DESCRIPTOR 29,8,3
    CHECK_DESCRIPTOR 30,8,3
    CHECK_DESCRIPTOR 31,8,3
    CHECK_DESCRIPTOR 32,8,3
    CHECK_DESCRIPTOR 33,8,3
    ARG x22,7
    ldr d0,[x22,#0]
    PUT d0,RC_CBL_1
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#8]
    PUT d0,RC_CBL_2
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#136]
    PUT d0,RC_I_LIN
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#168]
    PUT d0,RC_I_MR
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#48]
    PUT d0,RC_RELAX_C
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#40]
    PUT d0,RC_RELAX_H
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#32]
    PUT d0,RC_SBL_ZM_I
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#16]
    PUT d0,RC_SBL_ZM_N
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#24]
    PUT d0,RC_SBL_ZM_S
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#224]
    PUT d0,RC_SMALL_FLK
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#88]
    PUT d0,RC_TT_1
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#96]
    PUT d0,RC_TT_2
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#64]
    PUT d0,RC_T_MAX
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#56]
    PUT d0,RC_T_MIN
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#176]
    PUT d0,RH_ICE_MAX
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#192]
    PUT d0,RH_ICE_MIN_FLK
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#208]
    PUT d0,RH_ML_MAX_FLK
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#200]
    PUT d0,RH_ML_MIN_FLK
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#160]
    PUT d0,RPHI_I_AST_MR
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#144]
    PUT d0,RPHI_I_PR0_LIN
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#152]
    PUT d0,RPHI_I_PR1_LIN
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#72]
    PUT d0,RPHI_T_PR0_1
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#80]
    PUT d0,RPHI_T_PR0_2
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#256]
    PUT d0,RTPL_A_T
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#296]
    PUT d0,RTPL_C_I
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#288]
    PUT d0,RTPL_C_W
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#232]
    PUT d0,RTPL_GRAV
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#312]
    PUT d0,RTPL_KAPPA_I
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#304]
    PUT d0,RTPL_KAPPA_W
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#280]
    PUT d0,RTPL_L_F
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#272]
    PUT d0,RTPL_RHO_I
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#264]
    PUT d0,RTPL_RHO_W_R
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#248]
    PUT d0,RTPL_T_F
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#240]
    PUT d0,RTPL_T_R
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ldr d0,[x22,#216]
    PUT d0,RU_STAR_MIN_FLK
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_ZERO
    ldr d0,[x9,:lo12:.LC_ZERO]
    PUT d0,ZERO
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_ONE
    ldr d0,[x9,:lo12:.LC_ONE]
    PUT d0,ONE
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_TWO
    ldr d0,[x9,:lo12:.LC_TWO]
    PUT d0,TWO
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_HALF
    ldr d0,[x9,:lo12:.LC_HALF]
    PUT d0,HALF
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_SIX
    ldr d0,[x9,:lo12:.LC_SIX]
    PUT d0,SIX
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_NINE_TENTHS
    ldr d0,[x9,:lo12:.LC_NINE_TENTHS]
    PUT d0,NINE_TENTHS
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_CUBE_ROOT
    ldr d0,[x9,:lo12:.LC_CUBE_ROOT]
    PUT d0,CUBE_ROOT
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_SECONDS_MONTH
    ldr d0,[x9,:lo12:.LC_SECONDS_MONTH]
    PUT d0,SECONDS_MONTH
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_DEPTH_MIN
    ldr d0,[x9,:lo12:.LC_DEPTH_MIN]
    PUT d0,DEPTH_MIN
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_DEPTH_MAX
    ldr d0,[x9,:lo12:.LC_DEPTH_MAX]
    PUT d0,DEPTH_MAX
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_ICE_TEMPERATURE_MIN
    ldr d0,[x9,:lo12:.LC_ICE_TEMPERATURE_MIN]
    PUT d0,ICE_TEMPERATURE_MIN
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    adrp x9,.LC_EPS
    ldr d0,[x9,:lo12:.LC_EPS]
    PUT d0,EPS
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    ARG x9,8
    ldr d0,[x9]
    PUT d0,DT
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fcmp d0,#0.0
    b.le .Lreject
    b.vs .Lreject
    ARG x9,6
    ldr d0,[x9]
    PUT d0,EXT
    fmov x10,d0
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fcmp d0,#0.0
    b.le .Lreject
    b.vs .Lreject
    CALC fadd,SHAPE_MEAN,RC_T_MAX,RC_T_MIN
    CALC fdiv,SHAPE_MEAN,SHAPE_MEAN,TWO
    CALC fsub,SHAPE_RATE_MAX,RC_T_MAX,RC_T_MIN
    CALC fdiv,SHAPE_RATE_MAX,SHAPE_RATE_MAX,SECONDS_MONTH
    // Validate supported physical input fields before complete setup writes.
    mov x20,x23
    cmp x20,x24
    b.ge .Lcopy_begin
.Ldomain:
    ARG x9,5
    ldr x9,[x9]
    ldr w9,[x9,x20,lsl #2]
    cmp w9,#1
    b.hi .Lreject
    cbz w9,.Ldomain_next
    mov x12,#3
.Ldomain_finite:
    cmp x12,#5
    b.lt .Ldomain_finite_read
    mov x12,#10
.Ldomain_finite_read:
    ldr x9,[x19,x12,lsl #3]
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ubfx x10,x10,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    add x12,x12,#1
    cmp x12,#5
    b.eq .Ldomain_finite
    cmp x12,#26
    b.lt .Ldomain_finite_read
    READ HICE_P,14
    READ HML_P,15
    READ SHAPE_P,16
    COMPARE HICE_P,ZERO
    b.lt .Lsigned_ice_negative_r2
.Lsigned_ice_supported_r2:
    COMPARE HML_P,ZERO
    // This branch accepts only an encoded zero-depth residual under existing ice.
    // Integer checks preserve every FP64 instruction, FP status and raw input word.
    b.ge .Lsigned_depth_supported_r1
    ldr x10,[sp,#S_HML_P]
    and x10,x10,#0x7fffffffffffffff
    ldr x11,[sp,#S_HICE_P]
    ldr x12,[sp,#S_RH_ICE_MIN_FLK]
    cmp x11,x12
    b.lo .Lreject
    ARG x9,11
    ldr x9,[x9]
    ldr x11,[x9,x20,lsl #3]
    ldr x12,[sp,#S_RTPL_T_F]
    cmp x11,x12
    b.ne .Lreject
    ARG x9,3
    ldr x9,[x9]
    ldr x11,[x9,x20,lsl #3]
    ldr x12,[sp,#S_DEPTH_MIN]
    tbnz x11,#63,.Lsigned_depth_clamp_min_r1
    cmp x11,x12
    b.hs .Lsigned_depth_clamp_max_r1
.Lsigned_depth_clamp_min_r1:
    mov x11,x12
.Lsigned_depth_clamp_max_r1:
    ldr x12,[sp,#S_DEPTH_MAX]
    cmp x11,x12
    csel x11,x11,x12,ls
    ubfx x12,x11,#52,#11
    sub x12,x12,#52
    lsl x12,x12,#52
    // 2^(floor(log2(clamped_depth))-52) is below gamma3*clamped_depth.
    cmp x10,x12
    b.hi .Lreject
.Lsigned_depth_supported_r1:
    COMPARE SHAPE_P,RC_T_MIN
    b.lt .Lreject
    COMPARE SHAPE_P,RC_T_MAX
    b.gt .Lreject
.Ldomain_next:
    add x20,x20,#1
    cmp x20,x24
    b.lt .Ldomain
.Lcopy_begin:
    mov x20,#0
.Lcopy_row:

    ARG x9,10
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,26
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    ARG x9,11
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,27
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    ARG x9,12
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,28
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    ARG x9,13
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,29
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    ARG x9,14
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,30
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    ARG x9,15
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,31
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    ARG x9,16
    ldr x9,[x9]
    ldr x10,[x9,x20,lsl #3]
    ARG x9,32
    ldr x9,[x9]
    str x10,[x9,x20,lsl #3]
    add x20,x20,#1
    cmp x20,x21
    b.lt .Lcopy_row
    mov x20,x23
    cmp x20,x24
    b.ge .Lreturn
.Lrow:
    ARG x9,5
    ldr x9,[x9]
    ldr w9,[x9,x20,lsl #2]
    cbz w9,.Lnext

    READ DEPTH,3
    READ CORIOLIS,4
    READ SFC_P,9
    READ ICE_P,10
    READ WML_P,11
    READ MEAN_P,12
    READ BOT_P,13
    READ HICE_P,14
    READ HML_P,15
    READ SHAPE_P,16
    READ QW,17
    READ QICE,18
    READ USTAR,19
    READ IICE,20
    READ IBOT,21
    READ IW,22
    READ IH,23
    READ I0H,24
    READ IHD,25
    READ ICE_N,26
    READ WML_N,27
    READ MEAN_N,28
    READ BOT_N,29
    READ HICE_N,30
    READ HML_N,31
    READ SHAPE_N,32
    READ SFC_N,33
    CALC fmax,DEPTH_USED,DEPTH_MIN,DEPTH
    CALC fmin,DEPTH_USED,DEPTH_MAX,DEPTH_USED
    CALC fmin,HML_N,HML_N,DEPTH_USED
    CALC fmin,HICE_N,HICE_N,DEPTH_USED
    CALC fmax,WML_N,WML_N,RTPL_T_F
    CALC fmax,MEAN_N,MEAN_N,RTPL_T_F
    CALC fmax,BOT_N,BOT_N,RTPL_T_F
    CALC fmin,ICE_N,ICE_N,RTPL_T_F
    COPY DMEAN,ZERO
    COPY DICE,ZERO
    COPY DBOT,ZERO
    COPY DHICE,ZERO
    COPY DHML,ZERO
    COPY DSHAPE,ZERO
    mov w25,#0
    mov w26,#0
    // Recompute under-ice water heat flux from the previous profile.
    COMPARE HICE_P,RH_ICE_MIN_FLK
    b.lt .Lwater_flux_done
    COMPARE HML_P,RH_ML_MIN_FLK
    b.gt .Lzero_water_flux
    CALC fsub,T0,BOT_P,WML_P
    NEG T1,RTPL_KAPPA_W
    CALC fmul,T0,T1,T0
    CALC fdiv,QW,T0,DEPTH_USED
    CALC fmul,T0,RPHI_T_PR0_1,SHAPE_P
    CALC fsub,PHI_T0,T0,RPHI_T_PR0_2
    CALC fmax,T0,PHI_T0,ONE
    CALC fmul,QW,QW,T0
    b .Lwater_flux_done
.Lzero_water_flux:
    COPY QW,ZERO
.Lwater_flux_done:
    CALC fadd,T0,QW,IW
    CALC fadd,T0,T0,IH
    CALC fmul,T1,TWO,I0H
    CALC fsub,STR1,T0,T1
    COPY Q_STAR,STR1
    // Ice creation and the complete existing-ice alternatives.
    COMPARE HICE_P,RH_ICE_MIN_FLK
    b.ge .Lexisting_ice
    CALC fadd,T0,RTPL_T_F,RC_SMALL_FLK
    COMPARE WML_P,T0
    b.gt .Lice_limits
    COMPARE QW,ZERO
    b.ge .Lice_limits
    mov w25,#1
    NEG T0,QW
    CALC fdiv,T0,T0,RTPL_RHO_I
    CALC fdiv,DHICE,T0,RTPL_L_F
    CALC fmul,T0,DHICE,DT
    CALC fadd,HICE_N,HICE_P,T0
    CALC fmul,T0,HICE_N,QW
    CALC fdiv,T0,T0,RTPL_KAPPA_I
    CALC fdiv,T0,T0,RPHI_I_PR0_LIN
    CALC fadd,ICE_N,RTPL_T_F,T0
    CALC fdiv,T0,HICE_N,RH_ICE_MAX
    CALC fmin,T0,ONE,T0
    CALC fmul,T0,RPHI_I_AST_MR,T0
    CALC fadd,PHI_I1,RPHI_I_PR1_LIN,T0
    b .Lice_limits
.Lexisting_ice:
    CALC fsub,T0,RTPL_T_F,RC_SMALL_FLK
    COMPARE ICE_P,T0
    b.lt .Lcold_ice
    CALC fadd,T0,QICE,IICE
    CALC fsub,T0,T0,IW
    CALC fsub,T0,T0,QW
    COMPARE T0,ZERO
    b.lt .Lcold_ice
    mov w26,#1
    NEG T0,T0
    CALC fdiv,T0,T0,RTPL_L_F
    CALC fdiv,DHICE,T0,RTPL_RHO_I
    CALC fmul,T0,DHICE,DT
    CALC fadd,HICE_N,HICE_P,T0
    COPY ICE_N,RTPL_T_F
    b .Lice_limits
.Lcold_ice:
    CALC fdiv,PHI_I0,HICE_P,RH_ICE_MAX
    CALC fadd,T0,ONE,RPHI_I_AST_MR
    CALC fmul,T0,RC_I_MR,T0
    CALC fmul,T0,T0,PHI_I0
    CALC fsub,C_ICE,RC_I_LIN,T0
    CALC fmul,T0,RPHI_I_AST_MR,PHI_I0
    CALC fadd,PHI_I1,RPHI_I_PR1_LIN,T0
    CALC fsub,PHI_I0,RPHI_I_PR0_LIN,PHI_I0
    CALC fmul,T0,TWO,C_ICE
    CALC fmul,T0,T0,RTPL_C_I
    CALC fsub,T1,RTPL_T_F,ICE_P
    CALC fmul,T0,T0,T1
    CALC fdiv,T0,T0,RTPL_L_F
    CALC fmax,ICE_THRESHOLD,ONE,T0
    CALC fdiv,T0,PHI_I0,C_ICE
    CALC fmul,T0,T0,RTPL_KAPPA_I
    CALC fdiv,T0,T0,RTPL_RHO_I
    CALC fdiv,T0,T0,RTPL_C_I
    CALC fmul,ICE_THRESHOLD,T0,ICE_THRESHOLD
    CALC fmul,T0,ICE_THRESHOLD,DT
    CALC fmax,T0,ZERO,T0
    SQRT ICE_THRESHOLD,T0
    CALC fmul,T0,NINE_TENTHS,RH_ICE_MAX
    CALC fmax,T1,ICE_THRESHOLD,RH_ICE_MIN_FLK
    CALC fmin,ICE_THRESHOLD,T0,T1
    COMPARE HICE_P,ICE_THRESHOLD
    b.ge .Lfull_cold_ice
    CALC fadd,T0,QICE,IICE
    CALC fsub,STR2,T0,IW
    CALC fsub,T0,STR2,QW
    NEG T0,T0
    CALC fdiv,T0,T0,RTPL_L_F
    CALC fdiv,DHICE,T0,RTPL_RHO_I
    CALC fmul,T0,DHICE,DT
    CALC fadd,HICE_N,HICE_P,T0
    CALC fmul,T0,HICE_N,STR2
    CALC fdiv,T0,T0,RTPL_KAPPA_I
    CALC fdiv,T0,T0,PHI_I0
    CALC fadd,ICE_N,RTPL_T_F,T0
    b .Lcold_ice_end
.Lfull_cold_ice:
    CALC fsub,T0,RTPL_T_F,ICE_P
    CALC fmul,T0,RTPL_KAPPA_I,T0
    CALC fdiv,T0,T0,HICE_P
    CALC fmul,DHICE,T0,PHI_I0
    CALC fadd,T0,QW,DHICE
    CALC fdiv,T0,T0,RTPL_L_F
    CALC fdiv,DHICE,T0,RTPL_RHO_I
    CALC fmul,T0,DHICE,DT
    CALC fadd,HICE_N,HICE_P,T0
    CALC fsub,T0,RTPL_T_F,ICE_P
    CALC fmul,T0,RTPL_C_I,T0
    CALC fdiv,R_TI,T0,RTPL_L_F
    CALC fsub,R_STAR,ONE,C_ICE
    CALC fmul,R_STAR,R_STAR,R_TI
    CALC fadd,T0,QICE,IICE
    CALC fsub,STR2,T0,IW
    CALC fmul,T3,C_ICE,HICE_P
    COPY DICE,ZERO
    CALC fsub,T0,RTPL_T_F,ICE_P
    CALC fmul,T0,RTPL_KAPPA_I,T0
    CALC fdiv,T0,T0,HICE_P
    CALC fmul,T0,T0,PHI_I0
    CALC fsub,T1,ONE,R_STAR
    CALC fmul,T0,T0,T1
    CALC fadd,DICE,DICE,T0
    CALC fmul,T0,R_STAR,QW
    CALC fsub,DICE,DICE,T0
    CALC fadd,DICE,DICE,STR2
    CALC fdiv,DICE,DICE,RTPL_RHO_I
    CALC fdiv,DICE,DICE,RTPL_C_I
    CALC fdiv,DICE,DICE,T3
    CALC fmul,T0,DICE,DT
    CALC fadd,ICE_N,ICE_P,T0
.Lcold_ice_end:
    CALC fdiv,T0,HICE_N,RH_ICE_MAX
    CALC fmin,T0,ONE,T0
    CALC fmul,T0,RPHI_I_AST_MR,T0
    CALC fadd,PHI_I1,RPHI_I_PR1_LIN,T0
.Lice_limits:
    CALC fmin,HICE_N,HICE_N,RH_ICE_MAX
    CALC fmin,ICE_N,ICE_N,RTPL_T_F
    CALC fmax,ICE_N,ICE_N,ICE_TEMPERATURE_MIN
    COMPARE HICE_N,RH_ICE_MIN_FLK
    b.ge .Lmean
    COPY HICE_N,ZERO
    COPY ICE_N,RTPL_T_F
    mov w25,#0
.Lmean:
    cbz w25,.Lmean_flux
    COPY QW,ZERO
.Lmean_flux:
    // The unused bottom-sediment flux remains exact positive zero.
    CALC fsub,T0,QW,ZERO
    CALC fadd,T0,T0,IW
    CALC fsub,T0,T0,IBOT
    CALC fdiv,T0,T0,RTPL_RHO_W_R
    CALC fdiv,T0,T0,RTPL_C_W
    CALC fdiv,DMEAN,T0,DEPTH_USED
    CALC fmul,T0,DMEAN,DT
    CALC fadd,MEAN_N,MEAN_P,T0
    CALC fmax,MEAN_N,MEAN_N,RTPL_T_F
    COMPARE HICE_N,RH_ICE_MIN_FLK
    b.lt .Lopen_water
    CALC fmin,MEAN_N,MEAN_N,RTPL_T_R
    COPY WML_N,RTPL_T_F
    cbz w25,.Lold_ice_profile
    CALC fsub,T0,DEPTH_USED,RH_ML_MIN_FLK
    COMPARE HML_P,T0
    b.lt .Lnew_ice_partial
    COPY HML_N,ZERO
    COPY SHAPE_N,SHAPE_MEAN
    b .Lice_reconstruct_bottom
.Lnew_ice_partial:
    COPY HML_N,HML_P
    COPY SHAPE_N,SHAPE_P
    b .Lice_reconstruct_bottom
.Lold_ice_profile:
    COMPARE BOT_P,RTPL_T_R
    b.ge .Lice_bottom_convection
    COPY HML_N,HML_P
    COPY SHAPE_N,SHAPE_P
.Lice_reconstruct_bottom:
    CALC fsub,T0,HML_N,DEPTH_USED
    ABS T0,T0
    COMPARE T0,EPS
    b.le .Lice_bottom_limit
    CALC fsub,T0,WML_N,MEAN_N
    CALC fdiv,T0,T0,SHAPE_N
    CALC fdiv,T1,HML_N,DEPTH_USED
    CALC fsub,T1,ONE,T1
    CALC fdiv,T0,T0,T1
    CALC fsub,BOT_N,WML_N,T0
    b .Lice_bottom_limit
.Lice_bottom_convection:
    COPY BOT_N,RTPL_T_R
    COMPARE HML_P,RC_SMALL_FLK
    b.lt .Lice_no_mixed_layer
    CALC fsub,T0,WML_N,MEAN_N
    CALC fsub,T1,WML_N,BOT_N
    CALC fdiv,T0,T0,T1
    CALC fdiv,T0,T0,SHAPE_P
    CALC fsub,T0,ONE,T0
    CALC fmul,HML_N,DEPTH_USED,T0
    CALC fmax,HML_N,HML_N,ZERO
    COPY SHAPE_N,SHAPE_P
    CALC fsub,T0,DEPTH_USED,RH_ML_MIN_FLK
    COMPARE HML_N,T0
    b.lt .Lice_shape_rate
    COPY HML_N,ZERO
    CALC fsub,T0,WML_N,MEAN_N
    CALC fdiv,T0,T0,SHAPE_N
    CALC fsub,BOT_N,WML_N,T0
    b .Lice_shape_rate
.Lice_no_mixed_layer:
    COPY HML_N,HML_P
    CALC fsub,T0,WML_N,MEAN_N
    CALC fsub,T1,WML_N,BOT_N
    CALC fdiv,SHAPE_N,T0,T1
    CALC fmax,T0,SHAPE_N,RC_T_MIN
    CALC fmin,SHAPE_N,RC_T_MAX,T0
.Lice_shape_rate:
    CALC fsub,T0,SHAPE_N,SHAPE_P
    CALC fdiv,DSHAPE,T0,DT
    ABS T0,DSHAPE
    COMPARE T0,SHAPE_RATE_MAX
    b.le .Lice_bottom_limit
    SIGN T0,SHAPE_RATE_MAX,DSHAPE
    CALC fmul,T0,T0,DT
    CALC fadd,SHAPE_N,SHAPE_P,T0
.Lice_bottom_limit:
    CALC fmin,BOT_N,BOT_N,RTPL_T_R
    b .Lstratification
.Lopen_water:
    BUOY T0,WML_P
    CALC fmul,T0,T0,STR1
    CALC fdiv,T0,T0,RTPL_RHO_W_R
    CALC fdiv,STR1,T0,RTPL_C_W
    COMPARE STR1,ZERO
    b.ge .Lzero_convection
    COMPARE HML_P,ZERO
    b.le .Lzero_convection
    NEG T0,STR1
    CALC fmul,T0,T0,HML_P
    GET d0,T0
    GET d1,CUBE_ROOT
    MATH md2asm_pow_original_rounding_candidate
    PUT d0,WSTAR
    b .Lconvective_equilibrium
.Lzero_convection:
    COPY WSTAR,ZERO
.Lconvective_equilibrium:
    NEG T0,QW
    CALC fmax,T1,IW,RC_SMALL_FLK
    CALC fdiv,CONV_SCALE,T0,T1
    COMPARE CONV_SCALE,ZERO
    b.le .Lzero_equilibrium
    COMPARE CONV_SCALE,ONE
    b.ge .Lzero_equilibrium
    COMPARE WML_P,RTPL_T_R
    b.le .Lzero_equilibrium
    CALC fmul,T0,SIX,CONV_SCALE
    SQRT T0,T0
    CALC fmul,T1,TWO,CONV_SCALE
    CALC fsub,T2,ONE,CONV_SCALE
    CALC fdiv,T1,T1,T2
    CALC fadd,CONV_SCALE,T0,T1
    CALC fdiv,T0,CONV_SCALE,EXT
    CALC fmin,CONV_SCALE,DEPTH_USED,T0
    b .Lbuoyancy_frequency
.Lzero_equilibrium:
    COPY CONV_SCALE,ZERO
.Lbuoyancy_frequency:
    CALC fadd,T0,WML_P,BOT_P
    CALC fmul,T0,HALF,T0
    BUOY T0,T0
    CALC fsub,T1,WML_P,BOT_P
    CALC fmul,N_MEAN,T0,T1
    CALC fsub,T0,DEPTH_USED,RH_ML_MIN_FLK
    COMPARE HML_P,T0
    b.gt .Lzero_frequency
    CALC fsub,T0,DEPTH_USED,HML_P
    CALC fdiv,T0,N_MEAN,T0
    CALC fmax,T0,T0,ZERO
    SQRT N_MEAN,T0
    b .Lshape_relaxation
.Lzero_frequency:
    COPY N_MEAN,ZERO
.Lshape_relaxation:
    CALC fmax,T0,WSTAR,USTAR
    CALC fmax,T0,T0,RU_STAR_MIN_FLK
    CALC fmul,DSHAPE,T0,T0
    CALC fsub,T0,DEPTH_USED,HML_P
    CALC fmul,T0,T0,T0
    CALC fmul,T0,N_MEAN,T0
    CALC fdiv,T0,T0,RC_RELAX_C
    CALC fdiv,DSHAPE,T0,DSHAPE
    CALC fsub,T0,RC_T_MAX,RC_T_MIN
    CALC fmax,T1,DSHAPE,RC_SMALL_FLK
    CALC fdiv,DSHAPE,T0,T1
    CALC fmul,T0,RC_TT_1,SHAPE_P
    CALC fsub,C_TT,T0,RC_TT_2
    CALC fmul,T0,TWO,C_TT
    CALC fdiv,C_Q,T0,SHAPE_P
    COMPARE STR1,ZERO
    b.ge .Lwind_mixing
    ABS T0,DSHAPE
    COMPARE T0,SHAPE_RATE_MAX
    b.le .Lconvective_shape
    SIGN DSHAPE,SHAPE_RATE_MAX,DSHAPE
.Lconvective_shape:
    CALC fmul,T0,DSHAPE,DT
    CALC fadd,SHAPE_N,SHAPE_P,T0
    CALC fmax,T0,SHAPE_N,RC_T_MIN
    CALC fmin,SHAPE_N,RC_T_MAX,T0
    CALC fsub,T0,SHAPE_N,SHAPE_P
    CALC fdiv,DSHAPE,T0,DT
    CALC fsub,T0,DEPTH_USED,RH_ML_MIN_FLK
    COMPARE HML_P,T0
    b.gt .Lconvective_full_depth
    COMPARE HML_P,RH_ML_MIN_FLK
    b.gt .Lcomplete_entrainment
    CALC fdiv,T0,RC_CBL_1,RC_CBL_2
    CALC fmax,T1,WSTAR,RC_SMALL_FLK
    CALC fmul,DHML,T0,T1
    b .Lconvective_depth_update
.Lcomplete_entrainment:
    CALC fdiv,R_H,DEPTH_USED,HML_P
    CALC fsub,R_RHO,R_H,ONE
    CALC fdiv,R_TI,SHAPE_P,C_TT
    CALC fdiv,T0,R_TI,TWO
    CALC fsub,T0,T0,ONE
    CALC fmul,T0,T0,R_RHO
    CALC fadd,R_STAR,T0,ONE
    CALC fadd,T0,ONE,RC_CBL_1
    CALC fmul,T0,R_STAR,T0
    CALC fsub,T0,T0,ONE
    // Heat and buoyancy retain their distinct original meanings.
    NEG T1,Q_STAR
    CALC fmul,T0,T1,T0
    CALC fsub,T0,T0,ZERO
    CALC fdiv,T0,T0,RTPL_RHO_W_R
    CALC fdiv,DHML,T0,RTPL_C_W
    CALC fsub,T0,DEPTH_USED,HML_P
    CALC fsub,T1,WML_P,BOT_P
    CALC fmul,T0,T0,T1
    CALC fmul,T0,T0,RC_TT_2
    CALC fdiv,T0,T0,C_TT
    CALC fmul,STR2,T0,DSHAPE
    CALC fadd,DHML,DHML,STR2
    CALC fsub,T0,R_TI,ONE
    CALC fmul,T0,T0,IH
    CALC fadd,T0,IBOT,T0
    CALC fmul,T1,R_TI,IHD
    CALC fsub,STR2,T0,T1
    CALC fsub,T0,R_TI,TWO
    CALC fmul,T0,T0,R_RHO
    CALC fsub,T1,IH,I0H
    CALC fmul,T0,T0,T1
    CALC fadd,STR2,STR2,T0
    CALC fdiv,STR2,STR2,RTPL_RHO_W_R
    CALC fdiv,STR2,STR2,RTPL_C_W
    CALC fadd,DHML,DHML,STR2
    NEG T0,RC_CBL_2
    CALC fmul,T0,T0,R_STAR
    CALC fmul,T0,T0,Q_STAR
    CALC fdiv,T0,T0,RTPL_RHO_W_R
    CALC fdiv,T0,T0,RTPL_C_W
    CALC fmax,T1,WSTAR,RC_SMALL_FLK
    CALC fdiv,STR2,T0,T1
    CALC fsub,T0,WML_P,BOT_P
    CALC fmul,T0,SHAPE_P,T0
    CALC fadd,STR2,STR2,T0
    ABS T0,STR2
    CALC fmax,T0,T0,RC_SMALL_FLK
    SIGN T0,T0,STR2
    CALC fdiv,DHML,DHML,T0
.Lconvective_depth_update:
    CALC fmax,DHML,DHML,RC_SMALL_FLK
    CALC fmul,T0,DHML,DT
    CALC fadd,HML_N,HML_P,T0
    CALC fmin,T0,HML_N,DEPTH_USED
    CALC fmax,HML_N,RH_ML_MIN_FLK,T0
    b .Lwater_profile
.Lconvective_full_depth:
    COPY HML_N,DEPTH_USED
    b .Lwater_profile
.Lwind_mixing:
    CALC fmax,DHML,USTAR,RU_STAR_MIN_FLK
    ABS T0,CORIOLIS
    CALC fdiv,T0,T0,RC_SBL_ZM_N
    CALC fdiv,T1,N_MEAN,RC_SBL_ZM_I
    CALC fadd,T0,T0,T1
    CALC fmul,T1,DHML,DHML
    CALC fmul,WIND_SCALE,T0,T1
    CALC fdiv,T0,STR1,RC_SBL_ZM_S
    CALC fadd,WIND_SCALE,WIND_SCALE,T0
    CALC fmax,WIND_SCALE,WIND_SCALE,RC_SMALL_FLK
    CALC fmul,T0,DHML,DHML
    CALC fmul,T0,T0,DHML
    CALC fdiv,WIND_SCALE,T0,WIND_SCALE
    CALC fmin,T0,WIND_SCALE,RH_ML_MAX_FLK
    CALC fmax,WIND_SCALE,RH_ML_MIN_FLK,T0
    CALC fmax,WIND_SCALE,WIND_SCALE,CONV_SCALE
    CALC fmul,T0,RC_RELAX_H,DHML
    CALC fdiv,T0,T0,WIND_SCALE
    CALC fmul,DHML,T0,DT
    NEG T0,DHML
    EXP T0,T0
    CALC fsub,T1,WIND_SCALE,HML_P
    CALC fmul,T0,T1,T0
    CALC fsub,HML_N,WIND_SCALE,T0
    CALC fmin,T0,HML_N,DEPTH_USED
    CALC fmax,HML_N,RH_ML_MIN_FLK,T0
    CALC fsub,T0,HML_N,HML_P
    CALC fdiv,DHML,T0,DT
    COMPARE HML_N,HML_P
    b.gt .Lwind_shape_limit
    NEG DSHAPE,DSHAPE
.Lwind_shape_limit:
    ABS T0,DSHAPE
    COMPARE T0,SHAPE_RATE_MAX
    b.le .Lwind_shape
    SIGN DSHAPE,SHAPE_RATE_MAX,DSHAPE
.Lwind_shape:
    CALC fmul,T0,DSHAPE,DT
    CALC fadd,SHAPE_N,SHAPE_P,T0
    CALC fmax,T0,SHAPE_N,RC_T_MIN
    CALC fmin,SHAPE_N,RC_T_MAX,T0
    CALC fsub,T0,SHAPE_N,SHAPE_P
    CALC fdiv,DSHAPE,T0,DT
.Lwater_profile:
    CALC fsub,T0,DEPTH_USED,RH_ML_MIN_FLK
    COMPARE HML_N,T0
    b.gt .Lwhole_water_mixed
    COMPARE HML_N,HML_P
    b.le .Lstationary_bottom
    CALC fdiv,R_H,HML_P,DEPTH_USED
    CALC fsub,R_RHO,ONE,R_H
    CALC fmul,T0,HALF,SHAPE_P
    CALC fmul,T0,T0,R_RHO
    CALC fmul,T1,TWO,R_H
    CALC fsub,T1,T1,ONE
    CALC fmul,T1,C_TT,T1
    CALC fadd,R_TI,T0,T1
    CALC fadd,T0,HALF,C_TT
    CALC fsub,T0,T0,C_Q
    CALC fdiv,R_STAR,T0,R_TI
    CALC fmul,T0,SHAPE_P,R_RHO
    CALC fsub,T0,ONE,T0
    CALC fdiv,R_TI,T0,R_TI
    CALC fsub,T0,QW,ZERO
    CALC fadd,T0,T0,IW
    CALC fsub,T0,T0,IBOT
    CALC fdiv,T0,T0,RTPL_RHO_W_R
    CALC fdiv,DBOT,T0,RTPL_C_W
    CALC fsub,T0,WML_P,BOT_P
    CALC fmul,T0,SHAPE_P,T0
    CALC fmul,T0,T0,DHML
    CALC fsub,DBOT,DBOT,T0
    CALC fmul,DBOT,DBOT,R_STAR
    CALC fdiv,DBOT,DBOT,DEPTH_USED
    CALC fsub,T0,ONE,C_Q
    CALC fmul,T0,T0,IH
    CALC fsub,STR2,IHD,T0
    CALC fmul,T0,C_Q,IBOT
    CALC fsub,STR2,STR2,T0
    CALC fmul,STR2,STR2,R_TI
    CALC fsub,T0,DEPTH_USED,HML_P
    CALC fdiv,STR2,STR2,T0
    CALC fdiv,STR2,STR2,RTPL_RHO_W_R
    CALC fdiv,STR2,STR2,RTPL_C_W
    CALC fadd,DBOT,DBOT,STR2
    CALC fmul,T0,RC_TT_2,R_TI
    CALC fsub,T0,ONE,T0
    CALC fdiv,STR2,T0,SHAPE_P
    CALC fsub,T0,WML_P,BOT_P
    CALC fmul,STR2,STR2,T0
    CALC fmul,STR2,STR2,DSHAPE
    CALC fadd,DBOT,DBOT,STR2
    b .Lbottom_temperature
.Lstationary_bottom:
    COPY DBOT,ZERO
.Lbottom_temperature:
    CALC fmul,T0,DBOT,DT
    CALC fadd,BOT_N,BOT_P,T0
    CALC fmax,BOT_N,BOT_N,RTPL_T_F
    CALC fsub,T0,BOT_N,RTPL_T_R
    BUOY T1,MEAN_N
    CALC fmul,STR2,T0,T1
    COMPARE STR2,ZERO
    b.ge .Lmixed_temperature
    COPY BOT_N,RTPL_T_R
.Lmixed_temperature:
    CALC fdiv,T0,HML_N,DEPTH_USED
    CALC fsub,T0,ONE,T0
    CALC fmul,WML_N,SHAPE_N,T0
    CALC fmul,T0,BOT_N,WML_N
    CALC fsub,T0,MEAN_N,T0
    CALC fsub,T1,ONE,WML_N
    CALC fdiv,WML_N,T0,T1
    CALC fmax,WML_N,WML_N,RTPL_T_F
    b .Lstratification
.Lwhole_water_mixed:
    COPY HML_N,DEPTH_USED
    COPY WML_N,MEAN_N
    COPY BOT_N,MEAN_N
    COPY SHAPE_N,SHAPE_MEAN
.Lstratification:
    CALC fsub,T0,WML_N,BOT_N
    BUOY T1,MEAN_N
    CALC fmul,STR2,T0,T1
    COMPARE STR2,ZERO
    b.ge .Lsurface
    COPY HML_N,DEPTH_USED
    COPY WML_N,MEAN_N
    COPY BOT_N,MEAN_N
    COPY SHAPE_N,SHAPE_MEAN
.Lsurface:
    COMPARE HICE_N,RH_ICE_MIN_FLK
    b.lt .Lwater_surface
    COPY SFC_N,ICE_N
    b .Lwrite
.Lwater_surface:
    COPY SFC_N,WML_N
.Lwrite:

    WRITE QW,17
    WRITE ICE_N,26
    WRITE WML_N,27
    WRITE MEAN_N,28
    WRITE BOT_N,29
    WRITE HICE_N,30
    WRITE HML_N,31
    WRITE SHAPE_N,32
    WRITE SFC_N,33

.Lnext:
    add x20,x20,#1
    cmp x20,x24
    b.lt .Lrow
.Lreturn:
    adrp x9,.Lnative_calls
    ldr x10,[x9,:lo12:.Lnative_calls]
    add x10,x10,#1
    str x10,[x9,:lo12:.Lnative_calls]
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldr x18,[sp,#96]
    add sp,sp,#1,lsl #12
    ret
.Lreject:
    bl abort
    brk #0
.size md2asm_flakeene_profile_r3,.-md2asm_flakeene_profile_r3
.size md2asm_flakeene_stock_signed_depth_r1_7388001,.-md2asm_flakeene_stock_signed_depth_r1_7388001
.global md2asm_flakeene_calls_get
.type md2asm_flakeene_calls_get,%function
md2asm_flakeene_calls_get:
    adrp x9,.Lnative_calls
    ldr x0,[x9,:lo12:.Lnative_calls]
    ret
.size md2asm_flakeene_calls_get,.-md2asm_flakeene_calls_get
.section .rodata
.p2align 3

.LC_ZERO: .quad 0x0000000000000000
.LC_ONE: .quad 0x3ff0000000000000
.LC_TWO: .quad 0x4000000000000000
.LC_HALF: .quad 0x3fe0000000000000
.LC_SIX: .quad 0x4018000000000000
.LC_NINE_TENTHS: .quad 0x3feccccccccccccd
.LC_CUBE_ROOT: .quad 0x3fd5555555555555
.LC_SECONDS_MONTH: .quad 0x4143c68000000000
.LC_DEPTH_MIN: .quad 0x4000000000000000
.LC_DEPTH_MAX: .quad 0x4049000000000000
.LC_ICE_TEMPERATURE_MIN: .quad 0x405249999999999a
.LC_EPS: .quad 0x3ce4000000000000
.bss
.p2align 3
.Lnative_calls: .zero 8
.section .note.GNU-stack,"",%progbits

.text
// Admit only a bounded negative zero-ice residual in the source no-create branch.
// Keep the original word and all FP64 arithmetic. The depth bound is one ULP.
.Lsigned_ice_negative_r2:
    ldr x10,[sp,#S_HICE_P]
    and x10,x10,#0x7fffffffffffffff
    ARG x9,10
    ldr x9,[x9]
    ldr x11,[x9,x20,lsl #3]
    ldr x12,[sp,#S_RTPL_T_F]
    cmp x11,x12
    b.ne .Lreject
    ARG x9,17
    ldr x9,[x9]
    ldr x11,[x9,x20,lsl #3]
    tbz x11,#63,.Lsigned_ice_no_create_r2
    and x11,x11,#0x7fffffffffffffff
    cbz x11,.Lsigned_ice_no_create_r2
    // Warm mixed-layer water also selects the original no-create branch.
    // Preserve incoming numerical flags while checking its rounded threshold.
    mrs x13,fpsr
    GET d0,RTPL_T_F
    GET d1,RC_SMALL_FLK
    fadd d0,d0,d1
    ARG x9,11
    ldr x9,[x9]
    ldr d1,[x9,x20,lsl #3]
    fcmp d1,d0
    msr fpsr,x13
    b.le .Lreject
.Lsigned_ice_no_create_r2:
    ARG x9,3
    ldr x9,[x9]
    ldr x11,[x9,x20,lsl #3]
    ldr x12,[sp,#S_DEPTH_MIN]
    tbnz x11,#63,.Lsigned_ice_clamp_min_r2
    cmp x11,x12
    b.hs .Lsigned_ice_clamp_max_r2
.Lsigned_ice_clamp_min_r2:
    mov x11,x12
.Lsigned_ice_clamp_max_r2:
    ldr x12,[sp,#S_DEPTH_MAX]
    cmp x11,x12
    csel x11,x11,x12,ls
    ubfx x12,x11,#52,#11
    sub x12,x12,#52
    lsl x12,x12,#52
    cmp x10,x12
    b.hi .Lreject
    b .Lsigned_ice_supported_r2

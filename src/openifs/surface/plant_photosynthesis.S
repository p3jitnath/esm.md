// Physics formulations/openifs/surface/carbon_uptake_by_plant_leaves.md.
// Contract skills/md2asm/references/openifs/surface/plant_photosynthesis.md.
// Complete fixed-control C3/C4 FARQUHAR, formulation/contract revision 2.
// The original whole-path reset, all leaf stages and ordered canopy sums are retained.
// All main arrays use original GNU rank-one descriptors. FP64 arithmetic is explicit.
#include "plant_photosynthesis_slots.inc.S"
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
.macro CONST name, value
    adrp x9,.LC_\name
    ldr d0,[x9,:lo12:.LC_\name]
    PUT d0,\name
.endm
.macro PARAM destination, offset
    ldr d0,[x20,#\offset]
    PUT d0,\destination
.endm
.macro TABLE destination, offset
    ldr x9,[x20,#\offset]
    mov x10,#20
    madd x10,x26,x10,x27
    ldr d0,[x9,x10,lsl #3]
    PUT d0,\destination
.endm
.macro INPUT destination, argument
    ldr x9,[x19,#(\argument*8)]
    ldr x9,[x9]
    ldr d0,[x9,x23,lsl #3]
    PUT d0,\destination
.endm
.macro OUTPUT source, argument
    ldr x9,[x19,#(\argument*8)]
    ldr x9,[x9]
    GET d0,\source
    str d0,[x9,x23,lsl #3]
.endm
.macro EXPONENTIAL destination, source
    GET d0,\source
    LEAF_CALL exp
    PUT d0,\destination
.endm
.macro ARRHENIUS destination, activation_offset
    add x0,sp,#S_LEAF_TEMPERATURE
    add x1,x20,#1424
    add x2,x20,#\activation_offset
    mov x3,x20
    mov x4,x22
    LEAF_CALL md2asm_photosynthesis_temperature_response
    PUT d0,\destination
.endm
.macro ARRHENIUS_MODIFIED destination, activation, deactivation, entropy
    add x0,sp,#S_LEAF_TEMPERATURE
    add x1,x20,#1424
    add x2,sp,#S_\activation
    add x3,sp,#S_\deactivation
    add x4,sp,#S_\entropy
    mov x5,x20
    mov x6,x22
    LEAF_CALL md2asm_photosynthesis_temperature_response_with_deactivation
    PUT d0,\destination
.endm
.macro CHECK_DESCRIPTOR argument, bytes, type
    ldr x9,[x19,#(\argument*8)]
    cbz x9,.Lphotosynthesis_reject
    ldr x10,[x9]
    cbz x10,.Lphotosynthesis_reject
    tst x10,#(\bytes-1)
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#16]
    cmp x10,#\bytes
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#32]
    cmp x10,#\bytes
    b.ne .Lphotosynthesis_reject
    ldrb w10,[x9,#28]
    cmp w10,#1
    b.ne .Lphotosynthesis_reject
    ldrb w10,[x9,#29]
    cmp w10,#\type
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lphotosynthesis_reject
    ldp x10,x11,[x9,#48]
    sub x11,x11,x10
    add x11,x11,#1
    cmp x11,x24
    b.lt .Lphotosynthesis_reject
    ldr x11,[x9,#8]
    add x11,x11,x10
    cbnz x11,.Lphotosynthesis_reject
.endm
.macro CHECK_TABLE offset
    add x9,x20,#\offset
    ldr x10,[x9]
    cbz x10,.Lphotosynthesis_reject
    tst x10,#7
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#16]
    cmp x10,#8
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#32]
    cmp x10,#8
    b.ne .Lphotosynthesis_reject
    ldrb w10,[x9,#28]
    cmp w10,#2
    b.ne .Lphotosynthesis_reject
    ldrb w10,[x9,#29]
    cmp w10,#3
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#8]
    cmn x10,#21
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#48]
    cmp x10,#1
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#56]
    cmp x10,#20
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#64]
    cmp x10,#20
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#72]
    cmp x10,#1
    b.ne .Lphotosynthesis_reject
    ldr x10,[x9,#80]
    cmp x10,#2
    b.ne .Lphotosynthesis_reject
.endm
.macro C4_ADDRESS reg, name
    add \reg,sp,#1,lsl #12
    add \reg,\reg,#(S_\name-4096)
.endm
.macro LEAF_CALL name
    bl \name
    ldr x18,[sp,#160]
.endm
.global md2asm_farquhar
.type md2asm_farquhar,%function
md2asm_farquhar:
    sub sp,sp,#2,lsl #12
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    str x18,[sp,#160]
    mov x29,sp
    add x19,sp,#256
    stp x0,x1,[x19]
    stp x2,x3,[x19,#16]
    stp x4,x5,[x19,#32]
    stp x6,x7,[x19,#48]
    add x11,sp,#2,lsl #12
    mov x10,#8
.Lphotosynthesis_arguments:
    ldr x9,[x11],#8
    str x9,[x19,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#24
    b.lt .Lphotosynthesis_arguments
    mrs x9,fpcr
    cbnz x9,.Lphotosynthesis_reject
    mov x10,#0
.Lphotosynthesis_pointers:
    ldr x9,[x19,x10,lsl #3]
    cbz x9,.Lphotosynthesis_reject
    tst x9,#3
    b.ne .Lphotosynthesis_reject
    add x10,x10,#1
    cmp x10,#24
    b.lt .Lphotosynthesis_pointers
    ldr x9,[x19,#16]
    ldr w24,[x9]
    cmp w24,#1
    b.lt .Lphotosynthesis_reject
    cmp w24,#4096
    b.gt .Lphotosynthesis_reject
    ldr x9,[x19]
    ldr w23,[x9]
    sub w23,w23,#1
    cmp w23,#0
    b.lt .Lphotosynthesis_reject
    cmp w23,w24
    b.gt .Lphotosynthesis_reject
    str w23,[sp,#448]
    ldr x9,[x19,#8]
    ldr w25,[x9]
    cmp w25,#0
    b.lt .Lphotosynthesis_reject
    cmp w25,w24
    b.gt .Lphotosynthesis_reject
    cmp w25,w23
    b.lt .Lphotosynthesis_reject
    ldr x20,[x19,#56]
    ldr x21,[x19,#48]
    ldr x22,[x19,#64]
    ldr w9,[x20]
    cmp w9,#20
    b.ne .Lphotosynthesis_reject
    ldr w9,[x20,#4]
    cmp w9,#21
    b.ne .Lphotosynthesis_reject
    ldr w9,[x20,#8]
    cmp w9,#2
    b.ne .Lphotosynthesis_reject
    CHECK_DESCRIPTOR 3,4,2
    CHECK_DESCRIPTOR 4,4,1
    CHECK_DESCRIPTOR 5,4,1
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
    CHECK_TABLE 384
    CHECK_TABLE 472
    CHECK_TABLE 560
    CHECK_TABLE 648
    CHECK_TABLE 736
    CHECK_TABLE 824
    CHECK_TABLE 912
    CHECK_TABLE 1000

    // Constants retain their declared types before widening to FP64.
    // The qualified profiler remains controlled by the model's readonly LHOOK.
    adrp x9,:got:__yomhook_MOD_lhook
    ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
    ldr w9,[x9]
    cmp w9,#1
    b.hi .Lphotosynthesis_reject
    str w9,[sp,#480]
    cbz w9,.Lphotosynthesis_hook_entry_done
    adr x0,.Lphotosynthesis_hook_name
    add x1,sp,#484
    str wzr,[x1]
    add x2,sp,#488
    mov x3,#21
    LEAF_CALL __yomhook_MOD_dr_hook_default8
.Lphotosynthesis_hook_entry_done:
    CONST ZERO,0.0
    CONST ONE,1.0
    CONST TWO,2.0
    CONST THREE,3.0
    CONST FOUR,4.0
    CONST NINE,9.0
    CONST TEN,10.0
    CONST ELEVEN,11.0
    CONST TWENTY,20.0
    CONST TWENTY_SEVEN,27.0
    CONST THIRTY_FIVE,35.0
    CONST FORTY_FOUR_SIX,44.6
    CONST FIFTY_FOUR,54.0
    CONST HUNDRED,100.0
    CONST MILLION,1000000.0
    CONST MICRO,1e-06
    CONST EPSILON,1.1920928955078125e-07
    CONST ONE_MINUS_EPSILON,0.9999998807907104
    CONST HUNDREDTH,0.01
    CONST SENTINEL,9999.0
    CONST THREE_HALVES,1.5
    CONST TINY,1e-30
    CONST C4_HALF,0.5
    CONST C4_SEVEN,7.0
    CONST C4_DIFF,0.047

    cmp w23,w25
    b.ge .Lphotosynthesis_lai_begin
.Lphotosynthesis_domain_begin:
    ldr w23,[sp,#448]
.Lphotosynthesis_domain_column:
    ldr x9,[x19,#32]
    ldr x9,[x9]
    ldr w9,[x9,x23,lsl #2]
    cmp w9,#0
    b.lt .Lphotosynthesis_reject
    cmp w9,#20
    b.gt .Lphotosynthesis_reject
    add x23,x23,#1
    cmp x23,x25
    b.lt .Lphotosynthesis_domain_column
.Lphotosynthesis_lai_begin:
    mov x28,#0
.Lphotosynthesis_lai:
    scvtf d0,w28
    ldr d1,[x20,#1264]
    fmul d0,d1,d0
    LEAF_CALL exp
    GET d1,ONE
    fsub d0,d0,d1
    ldr d1,[x20,#1272]
    fmul d0,d1,d0
    PUT d0,T0
    GET d0,TWENTY
    ldr d1,[x20,#1264]
    fmul d0,d1,d0
    LEAF_CALL exp
    GET d1,ONE
    fsub d0,d0,d1
    GET d1,T0
    fdiv d0,d1,d0
    add x9,sp,#2048
    str d0,[x9,x28,lsl #3]
    add x28,x28,#1
    cmp x28,#21
    b.lt .Lphotosynthesis_lai
    mov x28,#0
.Lphotosynthesis_light:
    add x9,sp,#2048
    ldr d0,[x9,x28,lsl #3]
    ldr d1,[x20,#1280]
    fneg d1,d1
    fmul d0,d1,d0
    LEAF_CALL exp
    add x9,sp,#2224
    str d0,[x9,x28,lsl #3]
    add x28,x28,#1
    cmp x28,#20
    b.lt .Lphotosynthesis_light
    ldr w23,[sp,#448]
    cmp x23,x25
    b.ge .Lphotosynthesis_return
.Lphotosynthesis_column:
    COPY ASSIM_TOTAL,ZERO
    COPY RD_TOTAL,ZERO
    COPY GS_TOTAL,ZERO
    COPY GS_TOP,ZERO
    COPY LAST_LAI,ZERO
    OUTPUT ZERO,20
    OUTPUT ZERO,21
    OUTPUT ZERO,22
    OUTPUT ZERO,23
    INPUT PB,10
    CALC fdiv,PB,PB,HUNDRED
    INPUT CO2,18
    CALC fmul,CO2,CO2,MILLION
    ldr d0,[x21,#8]
    PUT d0,T0
    CALC fmul,CO2,CO2,T0
    ldr d0,[x21,#24]
    PUT d0,T0
    CALC fdiv,CO2,CO2,T0
    INPUT LEAF_TEMPERATURE,14
    INPUT GROWTH,16
    PARAM T0,1296
    CALC fsub,GROWTH,GROWTH,T0
    mov x26,#0
    sub x9,x25,#1
    cmp x23,x9
    b.ne .Lphotosynthesis_path_ready
    ldr x9,[x19,#40]
    ldr x9,[x9]
    ldr w9,[x9,x23,lsl #2]
    cmp w9,#4
    cset x26,eq
.Lphotosynthesis_path_ready:
    ldr x9,[x19,#32]
    ldr x9,[x9]
    ldr w27,[x9,x23,lsl #2]
    cmp w27,#0
    mov w10,#1
    csel w27,w27,w10,gt
    sub w27,w27,#1
    COPY VCMAX25,ZERO
    ldr x9,[x19,#24]
    ldr x9,[x9]
    ldr w9,[x9,x23,lsl #2]
    cbz w9,.Lphotosynthesis_vcmax_ready
    TABLE VCMAX25,384
.Lphotosynthesis_vcmax_ready:
    INPUT T0,11
    INPUT T1,13
    PARAM T2,1408
    PARAM T3,1416
    CALC fmul,T4,T0,PB
    CALC fmul,T5,T0,T3
    CALC fadd,T5,T2,T5
    CALC fdiv,T4,T4,T5
    CALC fmul,T5,T1,PB
    CALC fmul,T6,T1,T3
    CALC fadd,T6,T2,T6
    CALC fdiv,T5,T5,T6
    CALC fsub,VPD,T4,T5
    CALC fdiv,VPD,VPD,TEN
    // Initialise the complete leaf arrays, including below-canopy levels.
    add x9,sp,#2400
    add x10,sp,#2576
    add x11,sp,#2752
    mov x12,#0
.Lphotosynthesis_clear_leaves:
    str xzr,[x9,x12,lsl #3]
    str xzr,[x10,x12,lsl #3]
    str xzr,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,#21
    b.lt .Lphotosynthesis_clear_leaves
    mov w9,#0
    str w9,[sp,#452]
    ldr x9,[x19,#24]
    ldr x9,[x9]
    ldr w9,[x9,x23,lsl #2]
    cbz w9,.Lphotosynthesis_integrate_begin
    ldr x9,[x19,#32]
    ldr x9,[x9]
    ldr w9,[x9,x23,lsl #2]
    cmp w9,#0
    b.le .Lphotosynthesis_integrate_begin
    INPUT LAI_VALUE,19
    GET d0,LAI_VALUE
    GET d1,HUNDREDTH
    fcmp d0,d1
    b.le .Lphotosynthesis_integrate_begin
    TABLE T0,472
    INPUT T1,17
    CALC fmul,T0,T1,T0
    CALC fmin,WATER,ONE,T0
    PARAM T0,360
    CALC fsub,T0,ONE,T0
    CALC fmax,STRESS_VC,T0,WATER
    PARAM T0,344
    CALC fsub,T0,ONE,T0
    CALC fmax,STRESS_GM,T0,WATER
    PARAM T0,352
    CALC fsub,T0,ONE,T0
    CALC fmax,STRESS_GS,T0,WATER
    ARRHENIUS TRD,272
    mov x28,#0
.Lphotosynthesis_respiration:
    add x9,sp,#2224
    ldr d0,[x9,x28,lsl #3]
    PUT d0,LIGHT_VALUE
    PARAM T0,1448
    CALC fsub,T1,ONE,LIGHT_VALUE
    CALC fmul,T1,T0,T1
    CALC fsub,NITRO,ONE,T1
    CALC fmul,T0,VCMAX25,NITRO
    CALC fmul,T0,T0,HUNDREDTH
    CALC fmul,T0,T0,TRD
    CALC fmul,T0,T0,STRESS_VC
    GET d0,T0
    add x9,sp,#2400
    str d0,[x9,x28,lsl #3]
    add x28,x28,#1
    cmp x28,#20
    b.lt .Lphotosynthesis_respiration
    INPUT T0,9
    GET d0,T0
    GET d1,EPSILON
    fcmp d0,d1
    b.le .Lphotosynthesis_integrate_begin
    INPUT T0,17
    GET d0,T0
    fcmp d0,d1
    b.le .Lphotosynthesis_integrate_begin
    GET d0,GROWTH
    ldr d1,[x20,#376]
    fcmp d0,d1
    b.le .Lphotosynthesis_integrate_begin
    ldr d1,[x20,#368]
    fcmp d0,d1
    b.ge .Lphotosynthesis_integrate_begin
    mov w9,#1
    str w9,[sp,#452]
    // The original reset leaves all but the final active column C3.
    ARRHENIUS TKMC,256
    ARRHENIUS TKMO,264
    ARRHENIUS TSCO,280
    ARRHENIUS TGAMMA,184
    cbnz x26,.Lphotosynthesis_C4_temperature
    CALC fmin,T0,GROWTH,THIRTY_FIVE
    CALC fmax,T0,ELEVEN,T0
    PARAM T1,104
    CALC fmul,T1,T1,T0
    PARAM T2,88
    CALC fadd,SJ,T2,T1
    TABLE PARAM0,1000
    PARAM PARAM1,168
    ARRHENIUS_MODIFIED TJ,PARAM0,PARAM1,SJ
    CALC fmin,T0,GROWTH,THIRTY_FIVE
    CALC fmax,T0,ELEVEN,T0
    PARAM T1,136
    CALC fmul,T1,T1,T0
    PARAM T2,120
    CALC fadd,SV,T2,T1
    TABLE PARAM0,912
    PARAM PARAM1,152
    ARRHENIUS_MODIFIED TV,PARAM0,PARAM1,SV
    CALC fmin,T0,GROWTH,THIRTY_FIVE
    CALC fmax,T0,ELEVEN,T0
    PARAM T1,72
    CALC fmul,T1,T1,T0
    PARAM T2,56
    CALC fadd,T1,T2,T1
    CALC fmul,JMAX25,T1,VCMAX25
    CALC fmul,VJ,JMAX25,TJ
    CALC fmul,VC,VCMAX25,TV
    PARAM PARAM0,192
    PARAM PARAM1,240
    PARAM PARAM2,208
    ARRHENIUS_MODIFIED TGM,PARAM0,PARAM1,PARAM2
    TABLE T0,824
    CALC fmul,T0,T0,TGM
    CALC fmul,GM,T0,STRESS_GM
    TABLE T0,736
    CALC fmul,G0,T0,STRESS_GS
    PARAM T0,296
    CALC fmul,KMC,T0,TKMC
    PARAM T0,312
    CALC fmul,KMO,T0,TKMO
    PARAM T0,328
    CALC fmul,SCO,T0,TSCO
    TABLE T0,648
    CALC fmul,T0,T0,VPD
    TABLE T1,560
    CALC fsub,T0,T1,T0
    CALC fmax,T0,EPSILON,T0
    CALC fmin,T0,ONE_MINUS_EPSILON,T0
    CALC fdiv,T0,ONE,T0
    CALC fsub,T0,T0,ONE
    CALC fdiv,T0,ONE,T0
    CALC fmul,FVPD,T0,STRESS_GS
    b .Lphotosynthesis_temperature_common
.Lphotosynthesis_C4_temperature:
    CALC fmin,T0,GROWTH,THIRTY_FIVE
    CALC fmax,T0,ELEVEN,T0
    PARAM T1,112
    CALC fmul,T1,T1,T0
    PARAM T2,96
    CALC fadd,SJ,T2,T1
    TABLE PARAM0,1000
    PARAM PARAM1,176
    ARRHENIUS_MODIFIED TJ,PARAM0,PARAM1,SJ
    CALC fmin,T0,GROWTH,THIRTY_FIVE
    CALC fmax,T0,ELEVEN,T0
    PARAM T1,144
    CALC fmul,T1,T1,T0
    PARAM T2,128
    CALC fadd,SV,T2,T1
    TABLE PARAM0,912
    PARAM PARAM1,160
    ARRHENIUS_MODIFIED TV,PARAM0,PARAM1,SV
    CALC fmin,T0,GROWTH,THIRTY_FIVE
    CALC fmax,T0,ELEVEN,T0
    PARAM T1,80
    CALC fmul,T1,T1,T0
    PARAM T2,64
    CALC fadd,T1,T2,T1
    CALC fmul,JMAX25,T1,VCMAX25
    CALC fmul,VJ,JMAX25,TJ
    CALC fmul,VC,VCMAX25,TV
    COPY GM,ZERO
    TABLE T0,736
    CALC fmul,G0,T0,STRESS_GS
    PARAM T0,304
    CALC fmul,KMC,T0,TKMC
    PARAM T0,320
    CALC fmul,KMO,T0,TKMO
    PARAM T0,336
    CALC fmul,SCO,T0,TSCO
    TABLE T0,648
    CALC fmul,T0,T0,VPD
    TABLE T1,560
    CALC fsub,T0,T1,T0
    CALC fmax,T0,EPSILON,T0
    CALC fmin,T0,ONE_MINUS_EPSILON,T0
    CALC fdiv,T0,ONE,T0
    CALC fsub,T0,T0,ONE
    CALC fdiv,T0,ONE,T0
    CALC fmul,FVPD,T0,STRESS_GS
.Lphotosynthesis_temperature_common:
    PARAM T0,288
    CALC fmul,GAMMA,T0,TGAMMA
    GET d0,ONE
    fmov d1,#0.5
    PUT d1,T0
    CALC fdiv,LOW_GAMMA,T0,SCO
    PARAM T0,1288
    CALC fmul,T0,T0,FORTY_FOUR_SIX
    PARAM T1,1296
    INPUT T2,14
    CALC fdiv,T1,T1,T2
    CALC fmul,T0,T0,T1
    PARAM T1,1304
    CALC fdiv,T1,PB,T1
    CALC fmul,GB_H2O,T0,T1
    PARAM T0,1440
    CALC fdiv,GB,GB_H2O,T0
    mov x28,#0
.Lphotosynthesis_capacity:
    add x9,sp,#2224
    ldr d0,[x9,x28,lsl #3]
    PUT d0,LIGHT_VALUE
    PARAM T0,1448
    CALC fsub,T1,ONE,LIGHT_VALUE
    CALC fmul,T1,T0,T1
    CALC fsub,NITRO,ONE,T1
    CALC fmul,T0,VC,NITRO
    CALC fmul,T0,T0,STRESS_VC
    GET d0,T0
    add x9,sp,#2576
    str d0,[x9,x28,lsl #3]
    CALC fmul,T0,VJ,NITRO
    CALC fmul,JMAX,T0,STRESS_VC
    INPUT IABS,9
    PARAM T0,1320
    CALC fmul,IABS,IABS,T0
    PARAM T0,1312
    CALC fmul,IABS,IABS,T0
    PARAM T0,1280
    CALC fmul,IABS,IABS,T0
    CALC fmul,IABS,IABS,LIGHT_VALUE
    PARAM T0,1328
    CALC fmul,PRODUCT,T0,IABS
    CALC fadd,SUM,PRODUCT,JMAX
    CALC fmul,SQUARE,SUM,SUM
    PARAM T0,1336
    CALC fmul,T1,FOUR,T0
    CALC fmul,T1,T1,JMAX
    PARAM T2,1328
    CALC fmul,T1,T1,T2
    CALC fmul,T1,T1,IABS
    CALC fsub,RADICAND,SQUARE,T1
    GET d0,RADICAND
    fsqrt d0,d0
    PUT d0,T1
    CALC fsub,T1,SUM,T1
    CALC fmul,T0,TWO,T0
    CALC fdiv,T1,T1,T0
    GET d0,T1
    add x9,sp,#2752
    str d0,[x9,x28,lsl #3]
    add x28,x28,#1
    cmp x28,#20
    b.lt .Lphotosynthesis_capacity
.Lphotosynthesis_integrate_begin:
    mov x28,#0
.Lphotosynthesis_integrate_level:
    add x9,sp,#2400
    ldr d0,[x9,x28,lsl #3]
    PUT d0,RD_LEAF
    add x9,sp,#2048
    ldr d0,[x9,x28,lsl #3]
    PUT d0,LAI_VALUE
    add x10,x28,#1
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d1,d0
    PUT d0,LAI_WIDTH
    ldr w9,[sp,#452]
    cbz w9,.Lphotosynthesis_integrate_respiration
    INPUT T0,19
    GET d0,LAI_VALUE
    GET d1,T0
    fcmp d0,d1
    b.gt .Lphotosynthesis_integrate_respiration
    add x9,sp,#2576
    ldr d0,[x9,x28,lsl #3]
    PUT d0,VC_LEAF
    add x9,sp,#2752
    ldr d0,[x9,x28,lsl #3]
    PUT d0,JJ_LEAF
    cbnz x26,.Lphotosynthesis_C4_leaf
    COPY SELECTED,SENTINEL
    mov w9,#1
    str w9,[sp,#456]
    b .Lphotosynthesis_cubic_limit
#include "plant_photosynthesis_c4.inc.S"
.Lphotosynthesis_cubic_limit:
    ldr w9,[sp,#456]
    cmp w9,#1
    b.ne .Lphotosynthesis_j_limit
    COPY X1,VC_LEAF
    CALC fmul,T0,TWO,GAMMA
    CALC fmul,T0,T0,SCO
    CALC fdiv,T0,T0,KMO
    CALC fadd,T0,ONE,T0
    CALC fmul,X2,KMC,T0
    b .Lphotosynthesis_cubic
.Lphotosynthesis_j_limit:
    CALC fdiv,X1,JJ_LEAF,FOUR
    CALC fmul,X2,TWO,GAMMA
.Lphotosynthesis_cubic:
    CALC fadd,T0,X2,GAMMA
    CALC fmul,T0,G0,T0
    CALC fdiv,T1,G0,GM
    CALC fadd,T1,T1,FVPD
    CALC fsub,T2,X1,RD_LEAF
    CALC fmul,T1,T1,T2
    CALC fadd,A,T0,T1
    CALC fsub,T0,X1,RD_LEAF
    CALC fmul,T0,CO2,T0
    CALC fmul,T1,GAMMA,X1
    CALC fsub,T0,T0,T1
    CALC fmul,T1,RD_LEAF,X2
    CALC fsub,B,T0,T1
    CALC fadd,T0,CO2,X2
    CALC fdiv,T1,ONE,GM
    CALC fdiv,T2,ONE,GB
    CALC fadd,T1,T1,T2
    CALC fsub,T2,X1,RD_LEAF
    CALC fmul,T1,T1,T2
    CALC fadd,C,T0,T1
    CALC fadd,T0,X2,GAMMA
    CALC fsub,T1,X1,RD_LEAF
    CALC fdiv,T1,T1,GM
    CALC fadd,D,T0,T1
    CALC fdiv,T0,ONE,GM
    CALC fdiv,T1,G0,GM
    CALC fadd,T1,T1,FVPD
    CALC fdiv,T2,ONE,GM
    CALC fdiv,T3,ONE,GB
    CALC fadd,T2,T2,T3
    CALC fmul,T1,T1,T2
    CALC fadd,M,T0,T1
    CALC fsub,T0,X1,RD_LEAF
    CALC fdiv,T0,T0,GM
    CALC fadd,T0,D,T0
    CALC fdiv,T1,ONE,GM
    CALC fdiv,T2,ONE,GB
    CALC fadd,T1,T1,T2
    CALC fmul,T1,A,T1
    CALC fadd,T0,T0,T1
    CALC fdiv,T1,G0,GM
    CALC fadd,T1,T1,FVPD
    CALC fmul,T1,T1,C
    CALC fadd,T0,T0,T1
    NEG T0,T0
    CALC fdiv,P,T0,M
    CALC fsub,T0,X1,RD_LEAF
    CALC fmul,T0,D,T0
    CALC fmul,T1,A,C
    CALC fadd,T0,T0,T1
    CALC fdiv,T1,G0,GM
    CALC fadd,T1,T1,FVPD
    CALC fmul,T1,T1,B
    CALC fadd,T0,T0,T1
    CALC fdiv,Q,T0,M
    NEG T0,A
    CALC fmul,T0,T0,B
    CALC fdiv,RR,T0,M
    CALC fmul,T0,P,P
    CALC fmul,T1,THREE,Q
    CALC fsub,T0,T0,T1
    CALC fdiv,QQ,T0,NINE
    // Real cubic exponent uses the qualified positive POWER route and restores the sign.
    GET d0,P
    fabs d0,d0
    GET d1,THREE
    LEAF_CALL md2asm_pow_original_rounding_candidate
    GET d1,P
    fcmp d1,#0.0
    b.ge .Lphotosynthesis_cubic_positive
    fneg d0,d0
.Lphotosynthesis_cubic_positive:
    PUT d0,CUBE
    CALC fmul,T0,TWO,CUBE
    CALC fmul,T1,NINE,P
    CALC fmul,T1,T1,Q
    CALC fsub,T0,T0,T1
    CALC fmul,T1,TWENTY_SEVEN,RR
    CALC fadd,T0,T0,T1
    CALC fdiv,UU,T0,FIFTY_FOUR
    GET d0,QQ
    fcmp d0,#0.0
    b.lt .Lphotosynthesis_next_limit
    b.eq .Lphotosynthesis_zero_qq
    GET d1,THREE_HALVES
    LEAF_CALL md2asm_pow_original_rounding_candidate
    b .Lphotosynthesis_qq_ready
.Lphotosynthesis_zero_qq:
    fmov d0,xzr
.Lphotosynthesis_qq_ready:
    PUT d0,QQ_POWER
    CALC fdiv,RATIO,UU,QQ_POWER
    GET d0,RATIO
    fabs d1,d0
    GET d2,ONE
    fcmp d1,d2
    b.gt .Lphotosynthesis_next_limit
    b.vs .Lphotosynthesis_next_limit
    LEAF_CALL md2asm_acos_original_rounding
    PUT d0,PSI
    GET d0,QQ
    fsqrt d0,d0
    GET d1,TWO
    fneg d1,d1
    fmul d0,d1,d0
    PUT d0,T0
    CALC fdiv,T1,PSI,THREE
    GET d0,T1
    LEAF_CALL md2asm_cos_original_rounding
    PUT d0,T1
    CALC fmul,T0,T0,T1
    CALC fdiv,T1,P,THREE
    CALC fsub,ROOT,T0,T1
    GET d0,ROOT
    GET d1,SELECTED
    fcmp d0,d1
    b.ge .Lphotosynthesis_restore_vc
    PUT d0,SELECTED
    b .Lphotosynthesis_next_limit
.Lphotosynthesis_restore_vc:
    COPY X1,VC_LEAF
    CALC fmul,T0,TWO,GAMMA
    CALC fmul,T0,T0,SCO
    CALC fdiv,T0,T0,KMO
    CALC fadd,T0,ONE,T0
    CALC fmul,X2,KMC,T0
.Lphotosynthesis_next_limit:
    ldr w9,[sp,#456]
    add w9,w9,#1
    str w9,[sp,#456]
    cmp w9,#2
    b.le .Lphotosynthesis_cubic_limit
    GET d0,SELECTED
    GET d1,SENTINEL
    fcmp d0,d1
    b.eq .Lphotosynthesis_respiration_floor
    GET d1,RD_LEAF
    fneg d1,d1
    fcmp d0,d1
    b.ge .Lphotosynthesis_assimilation_ready
.Lphotosynthesis_respiration_floor:
    GET d0,RD_LEAF
    fneg d0,d0
.Lphotosynthesis_assimilation_ready:
    PUT d0,ASSIM_LEAF
    CALC fadd,GROSS,ASSIM_LEAF,RD_LEAF
    GET d0,GROSS
    fabs d0,d0
    GET d1,EPSILON
    fcmp d0,d1
    b.lt .Lphotosynthesis_minimum_conductance
    CALC fmul,T0,GAMMA,X1
    CALC fmul,T1,GROSS,X2
    CALC fadd,T0,T0,T1
    CALC fsub,T1,X1,GROSS
    CALC fmax,T1,EPSILON,T1
    CALC fdiv,CC,T0,T1
    CALC fdiv,T0,ASSIM_LEAF,GM
    CALC fadd,CI,CC,T0
    CALC fdiv,T0,RD_LEAF,GM
    CALC fsub,CI_STAR,GAMMA,T0
    CALC fsub,T0,CI,CI_STAR
    CALC fdiv,T0,GROSS,T0
    CALC fmul,T0,T0,FVPD
    CALC fadd,GS_LEAF,G0,T0
    b .Lphotosynthesis_leaf_ready
.Lphotosynthesis_minimum_conductance:
    COPY GS_LEAF,G0
.Lphotosynthesis_leaf_ready:
#ifdef PHOTOSYNTHESIS_C4_PROBE
    cbz x26,.Lphotosynthesis_C4_state_done
    GET d0,ASSIM_LEAF
    str d0,[sp,#4672]
    GET d0,RD_LEAF
    str d0,[sp,#4680]
    GET d0,GS_LEAF
    str d0,[sp,#4688]
    GET d0,X1
    str d0,[sp,#4696]
    GET d0,X2
    str d0,[sp,#4704]
    GET d0,C4_X3
    str d0,[sp,#4712]
    GET d0,C4_PA
    str d0,[sp,#4720]
    GET d0,C4_PB
    str d0,[sp,#4728]
    GET d0,C4_RM
    str d0,[sp,#4736]
    GET d0,SCO
    str d0,[sp,#4744]
    GET d0,GAMMA
    str d0,[sp,#4752]
    GET d0,GB
    str d0,[sp,#4760]
    GET d0,CO2
    str d0,[sp,#4768]
    GET d0,FVPD
    str d0,[sp,#4776]
    GET d0,G0
    str d0,[sp,#4784]
    GET d0,C4_STAR
    str d0,[sp,#4792]
    GET d0,CI
    str d0,[sp,#4800]
    GET d0,CC
    str d0,[sp,#4808]
    GET d0,GROSS
    str d0,[sp,#4816]
    add w9,w23,#1
    str w9,[sp,#460]
    add w9,w28,#1
    str w9,[sp,#464]
    mov w9,#2
    str w9,[sp,#468]
    add x0,sp,#460
    add x1,sp,#464
    add x2,sp,#468
    C4_ADDRESS x3,C4_STATE
    LEAF_CALL md2asm_c4_state_record_
.Lphotosynthesis_C4_state_done:
#endif
#ifdef PHOTOSYNTHESIS_LEAF_PROBE
    add w9,w23,#1
    str w9,[sp,#460]
    add w9,w28,#1
    str w9,[sp,#464]
    add w9,w26,#1
    str w9,[sp,#468]
    add x0,sp,#460
    add x1,sp,#464
    add x2,sp,#468
    add x3,sp,#S_ASSIM_LEAF
    add x4,sp,#S_RD_LEAF
    add x5,sp,#S_GS_LEAF
    add x6,sp,#S_X1
    add x7,sp,#S_X2
    add x9,sp,#S_GAMMA
    str x9,[sp,#3000]
    add x9,sp,#S_GM
    str x9,[sp,#3008]
    add x9,sp,#S_GB
    str x9,[sp,#3016]
    add x9,sp,#S_CO2
    str x9,[sp,#3024]
    add x9,sp,#S_FVPD
    str x9,[sp,#3032]
    add x9,sp,#S_G0
    str x9,[sp,#3040]
    add x9,sp,#S_VC_LEAF
    str x9,[sp,#3048]
    add x9,sp,#S_JJ_LEAF
    str x9,[sp,#3056]
    add x9,sp,#S_KMC
    str x9,[sp,#3064]
    add x9,sp,#S_KMO
    str x9,[sp,#3072]
    add x9,sp,#S_SCO
    str x9,[sp,#3080]
    // Outgoing stack is separate from all saved registers and scalar slots.
    sub sp,sp,#128
    add x10,sp,#128
    add x10,x10,#3000
    mov x11,#0
.Lphotosynthesis_probe_stack:
    ldr x9,[x10,x11,lsl #3]
    str x9,[sp,x11,lsl #3]
    add x11,x11,#1
    cmp x11,#11
    b.lt .Lphotosynthesis_probe_stack
    bl md2asm_photosynthesis_leaf_record_
    add sp,sp,#128
    ldr x18,[sp,#160]
#endif
    cbnz x28,.Lphotosynthesis_top_ready
    COPY GS_TOP,GS_LEAF
.Lphotosynthesis_top_ready:
    cbnz x26,.Lphotosynthesis_C4_canopy_gross
    CALC fadd,T0,ASSIM_LEAF,RD_LEAF
    b .Lphotosynthesis_canopy_gross_ready
.Lphotosynthesis_C4_canopy_gross:
    COPY T0,GROSS
.Lphotosynthesis_canopy_gross_ready:
    CALC fmul,T0,T0,LAI_WIDTH
    CALC fadd,ASSIM_TOTAL,ASSIM_TOTAL,T0
    CALC fmul,T0,GS_LEAF,LAI_WIDTH
    CALC fadd,GS_TOTAL,GS_TOTAL,T0
    add x9,sp,#2048
    add x10,x28,#1
    ldr d0,[x9,x10,lsl #3]
    PUT d0,LAST_LAI
.Lphotosynthesis_integrate_respiration:
    CALC fmul,T0,RD_LEAF,LAI_WIDTH
    CALC fadd,RD_TOTAL,RD_TOTAL,T0
    add x28,x28,#1
    cmp x28,#20
    b.lt .Lphotosynthesis_integrate_level
    ldr w9,[sp,#452]
    cbz w9,.Lphotosynthesis_final_carbon
    CALC fmul,T0,ASSIM_TOTAL,MICRO
    ldr d0,[x21,#24]
    PUT d0,T1
    CALC fmul,T0,T0,T1
    OUTPUT T0,21
    PARAM T0,1432
    INPUT T1,14
    PARAM T2,1296
    CALC fdiv,T1,T1,T2
    CALC fmul,T0,T0,T1
    PARAM T1,1304
    CALC fdiv,T1,T1,PB
    CALC fmul,T0,T0,T1
    CALC fmul,T0,T0,GS_TOTAL
    PARAM T1,1440
    CALC fmul,T0,T0,T1
    OUTPUT T0,20
    PARAM T0,1432
    INPUT T1,14
    PARAM T2,1296
    CALC fdiv,T1,T1,T2
    CALC fmul,T0,T0,T1
    PARAM T1,1304
    CALC fdiv,T1,T1,PB
    CALC fmul,T0,T0,T1
    CALC fmul,T0,T0,GS_TOP
    PARAM T1,1440
    CALC fmul,T0,T0,T1
    CALC fmul,GSTOP,T0,LAST_LAI
    GET d0,GSTOP
    GET d1,EPSILON
    fcmp d0,d1
    b.lt .Lphotosynthesis_undefined_resistance
    CALC fdiv,RVEGET,ONE,GSTOP
    b .Lphotosynthesis_final_carbon
.Lphotosynthesis_undefined_resistance:
    PARAM RVEGET,32
.Lphotosynthesis_final_carbon:
    CALC fsub,T0,ASSIM_TOTAL,RD_TOTAL
    CALC fmul,T0,T0,MICRO
    ldr d0,[x21,#24]
    PUT d0,T1
    CALC fmul,T0,T0,T1
    OUTPUT T0,23
    CALC fmul,T0,RD_TOTAL,MICRO
    CALC fmul,T0,T0,T1
    OUTPUT T0,22
    add x23,x23,#1
    cmp x23,x25
    b.lt .Lphotosynthesis_column
.Lphotosynthesis_return:
    adrp x9,:got:__yomhook_MOD_lhook
    ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
    ldr w9,[x9]
    cbz w9,.Lphotosynthesis_hook_exit_done
    adr x0,.Lphotosynthesis_hook_name
    add x1,sp,#484
    mov w9,#1
    str w9,[x1]
    add x2,sp,#488
    mov x3,#21
    LEAF_CALL __yomhook_MOD_dr_hook_default8
.Lphotosynthesis_hook_exit_done:
    ldr x18,[sp,#160]
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#2,lsl #12
    ret
.Lphotosynthesis_reject:
    bl abort
    brk #0
.size md2asm_farquhar,.-md2asm_farquhar
.section .rodata
.p2align 3
.LC_ZERO: .double 0.0
.LC_ONE: .double 1.0
.LC_TWO: .double 2.0
.LC_THREE: .double 3.0
.LC_FOUR: .double 4.0
.LC_NINE: .double 9.0
.LC_TEN: .double 10.0
.LC_ELEVEN: .double 11.0
.LC_TWENTY: .double 20.0
.LC_TWENTY_SEVEN: .double 27.0
.LC_THIRTY_FIVE: .double 35.0
.LC_FORTY_FOUR_SIX: .double 44.6
.LC_FIFTY_FOUR: .double 54.0
.LC_HUNDRED: .double 100.0
.LC_MILLION: .double 1000000.0
.LC_MICRO: .double 1e-06
.LC_EPSILON: .double 1.1920928955078125e-07
.LC_ONE_MINUS_EPSILON: .double 0.9999998807907104
.LC_HUNDREDTH: .double 0.01
.LC_SENTINEL: .double 9999.0
.LC_THREE_HALVES: .double 1.5
.LC_TINY: .double 1e-30
.LC_C4_HALF: .double 0.5
.LC_C4_SEVEN: .double 7.0
.LC_C4_DIFF: .double 0.047
.Lphotosynthesis_hook_name: .ascii "FARQUHAR_MOD:FARQUHAR"
.section .note.GNU-stack,"",%progbits

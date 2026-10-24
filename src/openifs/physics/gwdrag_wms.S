// Physics formulations/openifs/physics/nonorographic_gravity_wave_drag.md.
// Contract skills/md2asm/references/openifs/physics/gwdrag_wms.md.
// Complete four-azimuth, twenty-phase coarse-grid calculation. No fused FP.
#ifndef GWDRAG_SYMBOL
#define GWDRAG_SYMBOL gwdrag_wms_
#endif
.text
.p2align 4
.equ FRAME,1024
.equ A0,128
.equ A1,136
.equ A2,144
.equ A3,152
.equ A4,160
.equ A5,168
.equ A6,176
.equ A7,184
.equ A8,192
.equ A9,200
.equ A10,208
.equ A11,216
.equ A12,224
.equ A13,232
.equ A14,240
.equ A15,248
.equ A16,256
.equ A17,264
.equ A18,272
.equ A19,280
.equ A20,288
.equ A21,296
.equ P_THM,320
.equ P_UHM,328
.equ P_VHM,336
.equ P_BVF,344
.equ P_RHO,352
.equ P_FCT,360
.equ P_UI,368
.equ P_PU,376
.equ P_DFL,384
.equ P_CRT,392
.equ P_UL,400
.equ P_CIMIN,408
.equ P_FLUX,416
.equ P_ACT,424
.equ P_ACC,432
.equ P_BVFL,440
.equ P_FNORM,448
.equ P_LAUN,456
.equ P_CNGL,464
.equ P_CI,472
.equ P_DCI,480
.equ P_COS,488
.equ P_SIN,496
.equ MM,520
.equ AZ,528
.equ S_PI,544
.equ S_RA,552
.equ S_RG,560
.equ S_RD,568
.equ S_CP,576
.equ S_RDI,584
.equ S_CONS2,592
.equ S_GSSEC,600
.equ S_MS,608
.equ S_FGLOB,616
.equ S_GB,624
.equ S_GAM,632
.equ S_SPAN,640
.equ S_DX,648
.equ S_XMIN,656
.equ S_X1,664
.equ S_X2,672
.equ S_INVGS,680
.equ S_STD,688
.equ S_TMP,696
.macro C r,name
    ldr d\r,.LC_\name
.endm
.macro LD2 r,ptr,delta=0
    ldr x9,[sp,#\ptr]
    madd x10,x28,x20,x27
.if \delta > 0
    add x10,x10,x20
.elseif \delta < 0
    sub x10,x10,x20
.endif
    ldr d\r,[x9,x10,lsl #3]
.endm
.macro ST2 r,ptr,delta=0
    ldr x9,[sp,#\ptr]
    madd x10,x28,x20,x27
.if \delta > 0
    add x10,x10,x20
.elseif \delta < 0
    sub x10,x10,x20
.endif
    str d\r,[x9,x10,lsl #3]
.endm
.macro LD3 r,ptr,delta=0
    ldr x9,[sp,#\ptr]
    madd x10,x28,x20,x27
.if \delta > 0
    add x10,x10,x20
.elseif \delta < 0
    sub x10,x10,x20
.endif
    ldr w11,[sp,#AZ]
    ldr x12,[sp,#MM]
    madd x10,x11,x12,x10
    ldr d\r,[x9,x10,lsl #3]
.endm
.macro ST3 r,ptr,delta=0
    ldr x9,[sp,#\ptr]
    madd x10,x28,x20,x27
.if \delta > 0
    add x10,x10,x20
.elseif \delta < 0
    sub x10,x10,x20
.endif
    ldr w11,[sp,#AZ]
    ldr x12,[sp,#MM]
    madd x10,x11,x12,x10
    str d\r,[x9,x10,lsl #3]
.endm
.macro LDV r,ptr
    ldr x9,[sp,#\ptr]
    ldr d\r,[x9,x27,lsl #3]
.endm
.macro STV r,ptr
    ldr x9,[sp,#\ptr]
    str d\r,[x9,x27,lsl #3]
.endm
.macro LDA r,ptr
    ldr x9,[sp,#\ptr]
    ldr w11,[sp,#AZ]
    madd x10,x11,x20,x27
    ldr d\r,[x9,x10,lsl #3]
.endm
.macro STA r,ptr
    ldr x9,[sp,#\ptr]
    ldr w11,[sp,#AZ]
    madd x10,x11,x20,x27
    str d\r,[x9,x10,lsl #3]
.endm
.macro LDS r,ptr,first=0
    ldr x9,[sp,#\ptr]
.if \first
    mov x10,x26
.else
    ldr w11,[sp,#AZ]
    mov x12,#20
    madd x10,x11,x12,x26
.endif
    madd x10,x10,x20,x27
    ldr d\r,[x9,x10,lsl #3]
.endm
.macro STS r,ptr,first=0
    ldr x9,[sp,#\ptr]
.if \first
    mov x10,x26
.else
    ldr w11,[sp,#AZ]
    mov x12,#20
    madd x10,x11,x12,x26
.endif
    madd x10,x10,x20,x27
    str d\r,[x9,x10,lsl #3]
.endm
.macro LDCI r,ptr=P_CI
    ldr x9,[sp,#\ptr]
    ldr d\r,[x9,x26,lsl #3]
.endm
.macro TRIG co,si
    ldr w11,[sp,#AZ]
    ldr x9,[sp,#P_COS]
    ldr d\co,[x9,x11,lsl #3]
    ldr x9,[sp,#P_SIN]
    ldr d\si,[x9,x11,lsl #3]
.endm
.macro PTR slot,count
    str x9,[sp,#\slot]
    add x9,x9,\count,lsl #3
.endm
.macro CONST symbol,slot
    adrp x9,:got:__yomcst_MOD_\symbol
    ldr x9,[x9,:got_lo12:__yomcst_MOD_\symbol]
    ldr d0,[x9]
    str d0,[sp,#\slot]
.endm
.macro TRACE stage
#ifdef GW_NATIVE_TRACE
    mov w0,#\stage
    mov w1,w20
    mov w2,w21
    add w3,w24,#1
    add w4,w22,#1
    add w5,w23,#1
    mov x6,sp
#ifdef GW_RUNTIME_GRID_SPACING
    str x18,[sp,#704]
#endif
    bl native_gw_trace
#ifdef GW_RUNTIME_GRID_SPACING
    ldr x18,[sp,#704]
#endif
#endif
.endm
.global GWDRAG_SYMBOL
.type GWDRAG_SYMBOL,%function
GWDRAG_SYMBOL:
    sub sp,sp,#FRAME
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x0,x1,[sp,#A0]
    stp x2,x3,[sp,#A2]
    stp x4,x5,[sp,#A4]
    stp x6,x7,[sp,#A6]
    add x9,sp,#FRAME
    add x10,sp,#A8
    mov x11,#14
.Largs:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Largs
    mrs x9,fpcr
    cbnz x9,.Ldomain
    ldr x25,[sp,#A2]
    ldr w20,[x5]
    ldr w21,[x6]
    cmp w20,#1
    b.lt .Ldomain
    cmp w20,#2048
    b.gt .Ldomain
    cmp w21,#2
    b.lt .Ldomain
    cmp w21,#512
    b.gt .Ldomain
    ldr w22,[x3]
    ldr w23,[x4]
    cmp w22,#1
    b.lt .Ldomain
    cmp w23,w20
    b.gt .Ldomain
    sub w22,w22,#1
    sub w23,w23,#1
    ldr w9,[x7]
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,#3
    b.gt .Ldomain
    sub w9,w9,#1
    add x10,x25,#16
    ldr w24,[x10,x9,lsl #2]
    cmp w24,#2
    b.lt .Ldomain
    cmp w24,w21
    b.gt .Ldomain
    sub w24,w24,#1
    add x10,x25,#48
    ldr d0,[x10,x9,lsl #3]
    str d0,[sp,#S_FGLOB]
    add x10,x25,#136
    ldr d0,[x10,x9,lsl #3]
    str d0,[sp,#S_GB]
    add x10,x25,#80
    ldr d0,[x10,x9,lsl #3]
    str d0,[sp,#S_TMP]
#ifdef GW_RUNTIME_GRID_SPACING
    // The runtime route uses the selected default configuration.
    ldr w9,[x25]
    cmp w9,#1
    b.ne .Ldomain
    ldp w9,w10,[x25,#4]
    orr w9,w9,w10
    ldr w10,[x25,#12]
    orr w9,w9,w10
    cbnz w9,.Ldomain
    ldr w9,[x25,#36]
    cmp w9,#1
    b.ne .Ldomain
    ldr w9,[x25,#40]
    cmp w9,#2
    b.ne .Ldomain
    ldr d0,[x25,#112]
    fmov d1,#2.0
    fcmp d0,d1
    b.ne .Ldomain
#endif
    ldr w9,[x25,#36]
    cmp w9,#-1
    b.lt .Ldomain
    cmp w9,#2
    b.gt .Ldomain
    ldr d0,[x25,#112]
    C 1,two
    fcmp d0,d1
    b.eq .Lpower_ok
    C 1,three
    fcmp d0,d1
    b.ne .Ldomain
.Lpower_ok:
    CONST rpi,S_PI
    fmov x9,d0
    ldr x10,.LC_pi
    cmp x9,x10
    b.ne .Ldomain
    CONST ra,S_RA
    CONST rg,S_RG
    CONST rd,S_RD
    CONST rcpd,S_CP
    ldr x9,[sp,#A1]
    ldr d0,[x9,#48]
    str d0,[sp,#S_GSSEC]
    ldr d1,[sp,#S_RD]
    C 0,one
    fdiv d0,d0,d1
    str d0,[sp,#S_RDI]
    ldr d0,[sp,#S_RG]
    fmul d0,d0,d0
    ldr d1,[sp,#S_CP]
    fdiv d0,d0,d1
    str d0,[sp,#S_CONS2]
    ldr d0,[sp,#S_PI]
    C 1,two
    fmul d0,d1,d0
    ldr d1,[sp,#S_TMP]
    fdiv d0,d0,d1
    str d0,[sp,#S_MS]
    // Check every selected source grid metric before any output mutation.
    mov x27,x22
    cmp x27,x23
    b.gt .Lgrid_done
.Lgrid:
    LDV 0,A16
    fcmp d0,#0.0
    b.le .Ldomain
    b.vs .Ldomain
    ldr d1,[sp,#S_PI]
    fmul d0,d1,d0
    fsqrt d0,d0
    ldr d1,[sp,#S_RA]
    C 2,two
    fmul d1,d2,d1
    fmul d0,d1,d0
    C 1,hundred
    fmaxnm d0,d0,d1
#ifndef GW_RUNTIME_GRID_SPACING
    C 1,grid
    fcmp d0,d1
    b.lt .Ldomain
    b.vs .Ldomain
#endif
    add x27,x27,#1
    cmp x27,x23
    b.le .Lgrid
.Lgrid_done:
    mul x9,x20,x21
    str x9,[sp,#MM]
    mov x10,#22
    mul x0,x9,x10
    mov x10,#252
    madd x0,x20,x10,x0
    add x0,x0,#48
    mov x1,#8
    bl calloc
    cbz x0,.Ldomain
    mov x19,x0
    mov x9,x0
    ldr x10,[sp,#MM]
    PTR P_THM,x10
    PTR P_UHM,x10
    PTR P_VHM,x10
    PTR P_BVF,x10
    PTR P_RHO,x10
    PTR P_FCT,x10
    lsl x11,x10,#2
    PTR P_UI,x11
    PTR P_PU,x11
    PTR P_DFL,x11
    PTR P_CRT,x11
    lsl x11,x20,#2
    PTR P_UL,x11
    PTR P_CIMIN,x11
    mov x11,#80
    mul x11,x20,x11
    PTR P_FLUX,x11
    PTR P_ACT,x11
    PTR P_ACC,x11
    PTR P_BVFL,x20
    PTR P_FNORM,x20
    PTR P_LAUN,x20
    PTR P_CNGL,x20
    mov x11,#20
    PTR P_CI,x11
    PTR P_DCI,x11
    mov x11,#4
    PTR P_COS,x11
    PTR P_SIN,x11
    adrp x9,.LC_cos
    add x9,x9,:lo12:.LC_cos
    ldr x10,[sp,#P_COS]
    ldp q0,q1,[x9]
    stp q0,q1,[x10]
    ldr x10,[sp,#P_SIN]
    ldp q0,q1,[x9,#32]
    stp q0,q1,[x10]
    // All tendency cells are cleared, including inactive columns.
    ldr x9,[sp,#A18]
    ldr x10,[sp,#A19]
    ldr x11,[sp,#MM]
    fmov d0,xzr
.Lzero_tendency:
    str d0,[x9],#8
    str d0,[x10],#8
    subs x11,x11,#1
    b.ne .Lzero_tendency
    // Selected flux cells only are cleared.
    mov x28,#0
.Lzero_flux_level:
    mov x27,x22
    cmp x27,x23
    b.gt .Lzero_flux_next
.Lzero_flux_col:
    ST2 0,A20
    ST2 0,A21
    add x27,x27,#1
    cmp x27,x23
    b.le .Lzero_flux_col
.Lzero_flux_next:
    add x28,x28,#1
    cmp x28,x21
    b.le .Lzero_flux_level
    cmp x22,x23
    b.gt .Lfinish
    mov w9,#0
    str w9,[sp,#AZ]
.Lcimin_azi:
    mov x27,x22
    C 0,half
.Lcimin_col:
    STA 0,P_CIMIN
    add x27,x27,#1
    cmp x27,x23
    b.le .Lcimin_col
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Lcimin_azi
    // Half-level temperature and wind retain the original adjacent-cell average.
    mov x28,#0
.Lhalf_level:
    mov x27,x22
.Lhalf_col:
    LD2 0,A9
    LD2 1,A10
    LD2 2,A11
    cbz x28,.Lhalf_store
    LD2 3,A9,-1
    LD2 4,A10,-1
    LD2 5,A11,-1
    fadd d0,d3,d0
    fadd d1,d4,d1
    fadd d2,d5,d2
    C 3,half
    fmul d0,d3,d0
    fmul d1,d3,d1
    fmul d2,d3,d2
.Lhalf_store:
    ST2 0,P_THM
    ST2 1,P_UHM
    ST2 2,P_VHM
    add x27,x27,#1
    cmp x27,x23
    b.le .Lhalf_col
    add x28,x28,#1
    cmp x28,x21
    b.lt .Lhalf_level
    sub x28,x21,#1
.Lstability_level:
    mov x27,x22
.Lstability_col:
    LD2 0,A14
    LD2 1,A14,-1
    fsub d5,d0,d1
    LD2 0,P_THM
    LD2 1,A13
    ldr d2,[sp,#S_RDI]
    fmul d1,d1,d2
    fdiv d1,d1,d0
    ST2 1,P_RHO
    ldr d1,[sp,#S_CONS2]
    fdiv d6,d1,d0
    LD2 1,A9
    LD2 2,A9,-1
    fsub d1,d1,d2
    ldr d2,[sp,#S_CP]
    fmul d1,d2,d1
    fdiv d1,d1,d5
    C 2,one
    fadd d1,d2,d1
    fmul d1,d6,d1
    ldr d2,[sp,#S_GSSEC]
    fmaxnm d1,d1,d2
    fsqrt d1,d1
    ST2 1,P_BVF
    add x27,x27,#1
    cmp x27,x23
    b.le .Lstability_col
    sub x28,x28,#1
    cbnz x28,.Lstability_level
    // Coordinate transform. Qualified scalar EXP and LOG are arithmetic primitives.
    C 0,one
    C 1,half
    fdiv d0,d0,d1
    C 1,one
    C 2,hundred
    fdiv d1,d1,d2
    str d1,[sp,#S_XMIN]
    fsub d2,d0,d1
    str d2,[sp,#S_SPAN]
    C 3,nineteen
    fdiv d3,d2,d3
    str d3,[sp,#S_DX]
    C 3,quarter
    str d3,[sp,#S_GAM]
    ldr w9,[x25,#4]
    cbz w9,.Lgamma_done
    fdiv d0,d0,d1
    bl log
    ldr d1,[sp,#S_SPAN]
    fdiv d0,d1,d0
    str d0,[sp,#S_GAM]
.Lgamma_done:
    ldr d0,[sp,#S_SPAN]
    ldr d1,[sp,#S_GAM]
    fdiv d0,d0,d1
    bl exp
    C 1,one
    fsub d0,d0,d1
    ldr d1,[sp,#S_SPAN]
    fdiv d0,d1,d0
    str d0,[sp,#S_X1]
    ldr d1,[sp,#S_XMIN]
    fsub d1,d1,d0
    str d1,[sp,#S_X2]
    mov x26,#0
.Lcoordinate:
    ucvtf d0,x26
    ldr d1,[sp,#S_DX]
    fmul d0,d0,d1
    ldr d1,[sp,#S_XMIN]
    fadd d0,d0,d1
    fsub d0,d0,d1
    ldr d1,[sp,#S_GAM]
    fdiv d0,d0,d1
    bl exp
    ldr d1,[sp,#S_X1]
    fmul d2,d1,d0
    ldr d3,[sp,#S_X2]
    fadd d2,d2,d3
    C 3,one
    fdiv d2,d3,d2
    ldr x9,[sp,#P_CI]
    str d2,[x9,x26,lsl #3]
    fmul d2,d2,d2
    ldr d3,[sp,#S_GAM]
    fdiv d1,d1,d3
    fmul d2,d2,d1
    fmul d2,d2,d0
    ldr d1,[sp,#S_DX]
    fmul d2,d2,d1
    ldr x9,[sp,#P_DCI]
    str d2,[x9,x26,lsl #3]
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lcoordinate
    // Launch wind and intrinsic directional wind.
    mov w9,#0
    str w9,[sp,#AZ]
.Lintrinsic_azi:
    mov x28,x24
    mov x27,x22
.Llaunch_col:
    TRIG 2,3
    LD2 0,P_UHM
    LD2 1,P_VHM
    fmul d0,d2,d0
    fmul d1,d3,d1
    fadd d0,d0,d1
    STA 0,P_UL
    LD2 0,P_BVF
    STV 0,P_BVFL
    add x27,x27,#1
    cmp x27,x23
    b.le .Llaunch_col
    mov x28,#1
.Lintrinsic_level:
    mov x27,x22
.Lintrinsic_col:
    TRIG 2,3
    LD2 0,P_UHM
    LD2 1,P_VHM
    fmul d0,d2,d0
    fmul d1,d3,d1
    fadd d0,d0,d1
    LDA 1,P_UL
    fsub d0,d0,d1
    ST3 0,P_UI
    add x27,x27,#1
    cmp x27,x23
    b.le .Lintrinsic_col
    add x28,x28,#1
    cmp x28,x24
    b.le .Lintrinsic_level
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Lintrinsic_azi
    mov x28,#1
.Lfactor_level:
    mov x27,x22
.Lfactor_col:
    LD2 0,P_RHO
    LD2 1,P_BVF
    fdiv d0,d0,d1
    ST2 0,P_FCT
    add x27,x27,#1
    cmp x27,x23
    b.le .Lfactor_col
    add x28,x28,#1
    cmp x28,x24
    b.le .Lfactor_level
    ldr w9,[x25,#12]
    cbz w9,.Lstd_done
    // GNU rank-one standard profiles use data + (offset + index*stride)*8.
    ldr x13,[sp,#A0]
    add x14,x24,#1
    ldr x9,[x13,#128]
    ldr x10,[x13,#136]
    ldr x11,[x13,#168]
    madd x12,x14,x11,x10
    ldr d0,[x9,x12,lsl #3]
    sub x12,x12,x11
    ldr d1,[x9,x12,lsl #3]
    fsub d5,d0,d1
    ldr x9,[x13,#192]
    ldr x10,[x13,#200]
    ldr x11,[x13,#232]
    madd x12,x14,x11,x10
    ldr d0,[x9,x12,lsl #3]
    sub x12,x12,x11
    ldr d1,[x9,x12,lsl #3]
    fsub d6,d0,d1
    fadd d0,d1,d0
    C 1,half
    fmul d4,d1,d0
    ldr x9,[x13]
    ldr x10,[x13,#8]
    ldr x11,[x13,#40]
    madd x12,x24,x11,x10
    ldr d0,[x9,x12,lsl #3]
    ldr d1,[sp,#S_RDI]
    fmul d0,d0,d1
    fdiv d7,d0,d4
    ldr d0,[sp,#S_CONS2]
    fdiv d0,d0,d4
    ldr d1,[sp,#S_CP]
    fmul d1,d1,d6
    fdiv d1,d1,d5
    C 2,one
    fadd d1,d2,d1
    fmul d0,d0,d1
    ldr d1,[sp,#S_GSSEC]
    fmaxnm d0,d0,d1
    fsqrt d0,d0
    fdiv d0,d7,d0
    mov x28,x24
    mov x27,x22
.Lstd_col:
    ST2 0,P_FCT
    add x27,x27,#1
    cmp x27,x23
    b.le .Lstd_col
.Lstd_done:
    // The four supported spectral slopes keep the source integer-power products.
    str wzr,[sp,#AZ]
    mov x28,x24
    mov x26,#0
.Lspectrum_inc:
    mov x27,x22
.Lspectrum_col:
    LDCI 0
    ldr d1,[sp,#S_MS]
    fmul d2,d1,d0
    LDV 3,P_BVFL
    LD2 4,P_FCT
    ldr w9,[x25,#36]
    cmp w9,#-1
    b.eq .Lslope_minus
    cbz w9,.Lslope_zero
    fmul d2,d2,d2
    fmul d2,d2,d2
    fmul d5,d3,d3
    fmul d5,d5,d5
    fmul d4,d4,d5
    cmp w9,#2
    b.eq .Lslope_two
    ldr w9,[x25,#8]
    cbz w9,.Lslope_one_unsat
    fdiv d1,d0,d2
    fdiv d3,d0,d5
    fminnm d1,d1,d3
    fmul d0,d4,d1
    b .Lspectrum_store
.Lslope_one_unsat:
    fmul d0,d4,d0
    fadd d1,d5,d2
    fdiv d0,d0,d1
    b .Lspectrum_store
.Lslope_two:
    fdiv d3,d3,d1
    ldr w9,[x25,#8]
    cbz w9,.Lslope_two_unsat
    fdiv d1,d3,d2
    fdiv d0,d0,d5
    fminnm d1,d1,d0
    fmul d0,d4,d1
    b .Lspectrum_store
.Lslope_two_unsat:
    fmul d4,d4,d0
    fmul d4,d4,d3
    fmul d5,d5,d3
    fmul d2,d2,d0
    fadd d5,d5,d2
    fdiv d0,d4,d5
    b .Lspectrum_store
.Lslope_minus:
    fmul d2,d2,d2
    fmul d3,d3,d3
    fmul d4,d4,d3
    fmul d0,d4,d0
    fadd d1,d3,d2
    fdiv d0,d0,d1
    b .Lspectrum_store
.Lslope_zero:
    fmul d5,d2,d2
    fmul d2,d5,d2
    fmul d5,d3,d3
    fmul d3,d5,d3
    fmul d4,d4,d3
    fmul d0,d4,d0
    fadd d1,d3,d2
    fdiv d0,d0,d1
.Lspectrum_store:
    STS 0,P_FLUX
    C 0,one
    STS 0,P_ACT
    STS 0,P_ACC
    add x27,x27,#1
    cmp x27,x23
    b.le .Lspectrum_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lspectrum_inc
    // Ordered twenty-point quadrature.
    mov x26,#0
.Lintegrate_launch_inc:
    mov x27,x22
.Lintegrate_launch_col:
    LDS 0,P_FLUX
    LDCI 1,P_DCI
    fmul d0,d0,d1
    LD3 1,P_PU
    fadd d0,d1,d0
    ST3 0,P_PU
    add x27,x27,#1
    cmp x27,x23
    b.le .Lintegrate_launch_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lintegrate_launch_inc
    mov x27,x22
.Lnormalise_col:
#ifdef GW_RUNTIME_GRID_SPACING
    LDV 0,A16
    ldr d1,[sp,#S_PI]
    ldr d2,[sp,#S_RA]
    bl md2asm_wave_launch_grid_factor
    ldr d1,[sp,#S_FGLOB]
    fmul d0,d1,d0
#else
    // Source grid factor is exactly one throughout the checked >=29km domain.
    ldr d0,[sp,#S_FGLOB]
    C 1,one
    fmul d0,d0,d1
#endif
    STV 0,P_LAUN
    LD3 1,P_PU
    fdiv d0,d0,d1
    STV 0,P_FNORM
    ldr w9,[x25]
    cbz w9,.Lnormalise_next
    ldr w9,[x25,#40]
    cmp w9,#1
    b.eq .Lprecip
    cmp w9,#2
    b.eq .Lgauss
    cmp w9,#4
    b.ne .Lnormalise_next
.Lgauss:
    LDV 0,A15
    C 1,radtodeg
    fmul d0,d0,d1
    ldr w9,[x25,#40]
    cmp w9,#4
    b.ne .Lgauss_lat
    C 1,minfifty
    fsub d0,d0,d1
.Lgauss_lat:
    fneg d1,d0
    fmul d0,d1,d0
    ldr d1,[x25,#128]
    C 2,two
    fmul d2,d2,d1
    fmul d1,d2,d1
    fdiv d0,d0,d1
    bl exp
    ldr d1,[sp,#S_GB]
    fmul d0,d1,d0
    C 1,one
    fadd d0,d1,d0
    LDV 1,P_LAUN
    fmul d0,d0,d1
    b .Llaunch_renorm
.Lprecip:
    LDV 0,A17
    ldr d1,[x25,#160]
    fmul d0,d1,d0
    C 1,half
    fminnm d0,d1,d0
    C 1,one
    fadd d0,d1,d0
    LDV 1,P_LAUN
    fmul d0,d1,d0
.Llaunch_renorm:
    STV 0,P_LAUN
    LD3 1,P_PU
    fdiv d0,d0,d1
    STV 0,P_FNORM
.Lnormalise_next:
    add x27,x27,#1
    cmp x27,x23
    b.le .Lnormalise_col
    str wzr,[sp,#AZ]
.Llaunch_set_azi:
    mov x27,x22
.Llaunch_set_col:
    LDV 0,P_LAUN
    ST3 0,P_PU
    add x27,x27,#1
    cmp x27,x23
    b.le .Llaunch_set_col
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Llaunch_set_azi
    mov x28,#1
.Lfactor_norm_level:
    mov x27,x22
.Lfactor_norm_col:
    LDV 0,P_FNORM
    LD2 1,P_FCT
    fmul d0,d0,d1
    ST2 0,P_FCT
    add x27,x27,#1
    cmp x27,x23
    b.le .Lfactor_norm_col
    add x28,x28,#1
    cmp x28,x24
    b.le .Lfactor_norm_level
    mov x26,#0
.Lflux_norm_inc:
    mov x27,x22
.Lflux_norm_col:
    LDV 0,P_FNORM
    LDS 1,P_FLUX,1
    fmul d0,d0,d1
    STS 0,P_FLUX,1
    add x27,x27,#1
    cmp x27,x23
    b.le .Lflux_norm_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lflux_norm_inc
    mov w9,#1
    str w9,[sp,#AZ]
.Lcopy_azi:
    mov x26,#0
.Lcopy_inc:
    mov x27,x22
.Lcopy_col:
    LDS 0,P_FLUX,1
    STS 0,P_FLUX
    C 0,one
    STS 0,P_ACT
    STS 0,P_ACC
    add x27,x27,#1
    cmp x27,x23
    b.le .Lcopy_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lcopy_inc
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Lcopy_azi
    TRACE 0
    str wzr,[sp,#AZ]
.Lprop_azi:
    sub x28,x24,#1
    cbz x28,.Lprop_next_azi
.Lprop_level:
    mov x27,x22
.Lmin_col:
    LDA 0,P_CIMIN
    LD3 1,P_UI
    fmaxnm d0,d0,d1
    STA 0,P_CIMIN
    add x27,x27,#1
    cmp x27,x23
    b.le .Lmin_col
    mov x26,#0
.Lcritical_inc:
    mov x27,x22
.Lcritical_col:
    LDCI 0
    LDA 1,P_CIMIN
    fsub d0,d0,d1
    fmov x9,d0
    lsr x9,x9,#63
    mov x10,#1
    sub x9,x10,x9
    ucvtf d0,x9
    LDS 1,P_ACT
    fsub d1,d1,d0
    STS 1,P_ACC
    STS 0,P_ACT
    add x27,x27,#1
    cmp x27,x23
    b.le .Lcritical_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lcritical_inc
    mov x26,#0
.Ldeposit_inc:
    mov x27,x22
.Ldeposit_col:
    LDS 0,P_ACC
    LDS 1,P_FLUX
    fmul d0,d0,d1
    LDCI 1,P_DCI
    fmul d0,d0,d1
    LD3 1,P_DFL
    fadd d0,d1,d0
    ST3 0,P_DFL
    add x27,x27,#1
    cmp x27,x23
    b.le .Ldeposit_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Ldeposit_inc
    mov x27,x22
.Lphase_col:
    LD3 7,P_DFL
    fcmp d7,#0.0
    b.le .Lphase_copy
    LD3 6,P_CRT
    mov x26,#0
.Lphase_inc:
    LDCI 0
    LDS 1,P_ACC
    fmul d0,d0,d1
    LDS 1,P_FLUX
    fmul d0,d0,d1
    LDCI 1,P_DCI
    fmul d0,d0,d1
    fadd d6,d6,d0
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lphase_inc
    fdiv d0,d6,d7
    b .Lphase_store
.Lphase_copy:
    LD3 0,P_CRT,1
.Lphase_store:
    ST3 0,P_CRT
    add x27,x27,#1
    cmp x27,x23
    b.le .Lphase_col
    mov x26,#0
.Lsaturation_inc:
    mov x27,x22
.Lsaturation_col:
    LDCI 0
    C 1,one
    fdiv d6,d1,d0
    LD3 1,P_UI
    fsub d2,d0,d1
    ldr d3,[x25,#104]
    LD2 4,P_FCT
    fmul d3,d3,d4
    ldr d0,[x25,#112]
    C 1,three
    fcmp d0,d1
    b.eq .Lcubic_cap
    fmul d2,d2,d2
    fmul d3,d3,d2
    fmul d3,d3,d6
    LDS 0,P_FLUX
    fsub d1,d0,d3
    LDS 2,P_ACT
    fmul d1,d2,d1
    fcmp d1,#0.0
    b.le .Lsaturation_next
    STS 3,P_FLUX
    b .Lsaturation_next
.Lcubic_cap:
    fmul d3,d3,d2
    fmul d3,d3,d3
    fmul d3,d3,d2
    fmul d3,d3,d6
    LDS 0,P_FLUX
    fmul d0,d0,d0
    fsub d1,d0,d3
    LDS 2,P_ACT
    fmul d1,d2,d1
    fcmp d1,#0.0
    b.le .Lsaturation_next
    fsqrt d3,d3
    STS 3,P_FLUX
.Lsaturation_next:
    add x27,x27,#1
    cmp x27,x23
    b.le .Lsaturation_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lsaturation_inc
    mov x26,#0
.Lprop_integral_inc:
    mov x27,x22
.Lprop_integral_col:
    LDS 0,P_ACT
    LDS 1,P_FLUX
    fmul d0,d0,d1
    LDCI 1,P_DCI
    fmul d0,d0,d1
    LD3 1,P_PU
    fadd d0,d1,d0
    ST3 0,P_PU
    add x27,x27,#1
    cmp x27,x23
    b.le .Lprop_integral_col
    add x26,x26,#1
    cmp x26,#20
    b.lt .Lprop_integral_inc
    sub x28,x28,#1
    cbnz x28,.Lprop_level
.Lprop_next_azi:
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Lprop_azi
    TRACE 1
    ldr d0,[sp,#S_RG]
    ldr x9,[sp,#A8]
    ldr d1,[x9]
    fmul d0,d0,d1
    C 1,one
    fdiv d0,d1,d0
    str d0,[sp,#S_INVGS]
    str wzr,[sp,#AZ]
.Lcorrection_azi:
    mov x27,x22
    fmov d0,xzr
.Lcarry_zero:
    STV 0,P_CNGL
    add x27,x27,#1
    cmp x27,x23
    b.le .Lcarry_zero
    mov x28,#1
.Lcorrection_level:
    mov x27,x22
.Lcorrection_col:
    TRIG 2,3
    LD2 0,A10
    LD2 1,A11
    fmul d0,d2,d0
    fmul d1,d3,d1
    fadd d0,d0,d1
    LDA 1,P_UL
    fsub d6,d0,d1
    LD3 0,P_DFL,-1
    LDV 1,P_CNGL
    fadd d7,d0,d1
    ST3 7,P_DFL,-1
    LD2 0,A12,-1
    LD2 1,A12
    fsub d0,d0,d1
    C 1,two
    fmul d0,d1,d0
    LD3 1,P_CRT,-1
    fsub d1,d1,d6
    fmul d0,d0,d1
    ldr d1,[sp,#S_INVGS]
    fmul d0,d0,d1
    fminnm d0,d7,d0
    fmov d1,xzr
    fmaxnm d0,d0,d1
    fsub d0,d7,d0
    STV 0,P_CNGL
    LD3 1,P_PU
    fsub d1,d1,d0
    ST3 1,P_PU
    add x27,x27,#1
    cmp x27,x23
    b.le .Lcorrection_col
    add x28,x28,#1
    cmp x28,x24
    b.le .Lcorrection_level
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Lcorrection_azi
    TRACE 2
    str wzr,[sp,#AZ]
.Lsum_azi:
    mov x28,x24
.Lsum_level:
    mov x27,x22
.Lsum_col:
    LD3 0,P_PU
    C 1,one
    fmul d0,d0,d1
    TRIG 2,3
    fmul d2,d0,d2
    fmul d3,d0,d3
    // The source flux arrays have the ordinary one-based lower bound.
    LD2 0,A20
    LD2 1,A21
    fadd d0,d0,d2
    fadd d1,d1,d3
    ST2 0,A20
    ST2 1,A21
    add x27,x27,#1
    cmp x27,x23
    b.le .Lsum_col
    sub x28,x28,#1
    cbnz x28,.Lsum_level
    ldr w9,[sp,#AZ]
    add w9,w9,#1
    str w9,[sp,#AZ]
    cmp w9,#4
    b.lt .Lsum_azi
    mov x28,#0
.Ltendency_level:
    mov x27,x22
.Ltendency_col:
    LD2 0,A13,1
    LD2 1,A13
    fsub d0,d0,d1
    ldr d1,[sp,#S_RG]
    fdiv d6,d1,d0
    LD2 0,A20,1
    LD2 1,A20
    fsub d0,d0,d1
    fmul d0,d0,d6
    ST2 0,A18
    LD2 0,A21,1
    LD2 1,A21
    fsub d0,d0,d1
    fmul d0,d0,d6
    ST2 0,A19
    add x27,x27,#1
    cmp x27,x23
    b.le .Ltendency_col
    add x28,x28,#1
    cmp x28,x24
    b.le .Ltendency_level
.Lfinish:
    mov x0,x19
    bl free
    ldp x29,x30,[sp]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    add sp,sp,#FRAME
    ret
.Ldomain:
    bl abort
    brk #0
.size GWDRAG_SYMBOL,.-GWDRAG_SYMBOL
.section .rodata
.p2align 3
.LC_one: .double 1.0
.LC_half: .double 0.5
.LC_two: .double 2.0
.LC_three: .double 3.0
.LC_quarter: .double 0.25
.LC_hundred: .double 100.0
.LC_nineteen: .double 19.0
.LC_grid: .double 29000.0
.LC_minfifty: .double -50.0
.LC_radtodeg: .double 57.29577951
.LC_pi: .quad 0x400921fb54442d18
.LC_cos:
.quad 0x3ff0000000000000,0x3c91a62633145c07,0xbff0000000000000,0xbcaa79394c9e8a0a
.quad 0x0000000000000000,0x3ff0000000000000,0x3ca1a62633145c07,0xbff0000000000000
.section .note.GNU-stack,"",%progbits

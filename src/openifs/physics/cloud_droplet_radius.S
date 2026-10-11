/* Cloud-drop radius from formulations/openifs/physics/cloud_droplet_radius.md.
 * Eighteen address arguments use x0..x7 and incoming stack bytes 0..72.
 * Atmospheric arrays use contiguous column-major FP64 storage.
 * Only selected output columns change. Inputs and metadata stay read-only.
 * The 384-byte frame saves x19..x30 and the ABI-required low halves of v8..v15.
 * Source POWER has a private qualified symbol. Strict EXP and LOG are external.
 * The solver preserves every separate arithmetic rounding point. */
#ifndef LIQUID_RADIUS_SYMBOL
#define LIQUID_RADIUS_SYMBOL liquid_effective_radius_
#endif
.text
.p2align 2
.global LIQUID_RADIUS_SYMBOL
.type LIQUID_RADIUS_SYMBOL,%function
.macro radius_constant target, label
    adrp x9,\label
    ldr \target,[x9,:lo12:\label]
.endm
LIQUID_RADIUS_SYMBOL:
    stp x29,x30,[sp,#-384]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    ldrsw x19,[x4]
    sub x19,x19,#1
    ldrsw x20,[x5]
    ldrsw x21,[x6]
    ldrsw x22,[x7]
    ldp x9,x10,[sp,#384]
    stp x9,x10,[sp,#192]
    ldp x9,x10,[sp,#400]
    stp x9,x10,[sp,#208]
    ldp x9,x10,[sp,#416]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[sp,#432]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[sp,#448]
    stp x9,x10,[sp,#256]
/* Preserve the original aerosol-dependent mode selection. */
    ldr w9,[x3,#112]
    cbnz w9,.Lradius_aerosols
    ldr w10,[x0,#180]
    cmp w10,#1
    b.ne .Lradius_aerosols
    ldr w9,[x0,#196]
.Lradius_aerosols:
    cmp w9,#12
    b.lt .Lradius_mode
    ldr w10,[x1,#1104]
    cmp w10,#0
    b.gt .Lradius_unsupported
.Lradius_mode:
    ldr w9,[x0,#120]
    cmp w9,#2
    b.hi .Lradius_unsupported
    str w9,[sp,#272]
    str wzr,[sp,#276]
/* The optional pattern is consumed only by an enabled positive entry. */
    ldr w9,[x2]
    cbz w9,.Lradius_pattern_ready
    ldrsw x10,[x2,#564]
    cmp x10,#0
    b.le .Lradius_pattern_ready
    ldr x11,[x2,#352]
    ldr x12,[x2,#360]
    add x10,x10,x12
    mov x12,#184
    madd x11,x10,x12,x11
    str x11,[sp,#280]
    mov w9,#1
    str w9,[sp,#276]
.Lradius_pattern_ready:
    cmp x19,x20
    b.ge .Lradius_return
    cmp x22,#0
    b.le .Lradius_return
    mov x23,x19
.Lradius_column:
    ldr w9,[sp,#272]
    cbz w9,.Lradius_legacy_column
    cmp w9,#1
    b.eq .Lradius_fixed_column
/* Activate sea or land drop concentration before the vertical loop. */
    ldr x10,[sp,#232]
    ldr d0,[x10,x23,lsl #3]
    fmov d1,#0.5
    fcmp d0,d1
    b.lt .Lradius_sea
    ldr x10,[sp,#160]
    ldr w9,[x10,#520]
    cbz w9,.Lradius_land_fixed
    ldr x10,[sp,#240]
    ldr d0,[x10,x23,lsl #3]
    b .Lradius_land_number
.Lradius_land_fixed:
    ldr d0,[x10,#552]
.Lradius_land_number:
    radius_constant d1,.Lradius_land_quadratic
    fmul d1,d0,d1
    fmul d1,d1,d0
    radius_constant d2,.Lradius_land_linear
    fmul d2,d0,d2
    fsub d2,d2,d1
    radius_constant d3,.Lradius_land_offset
    fsub d9,d2,d3
    radius_constant d8,.Lradius_land_dispersion
    radius_constant d10,.Lradius_land_ratio
    b .Lradius_number_ready
.Lradius_sea:
    ldr x10,[sp,#160]
    ldr w9,[x10,#524]
    cbz w9,.Lradius_sea_fixed
    ldr x10,[sp,#248]
    ldr d0,[x10,x23,lsl #3]
    b .Lradius_sea_number
.Lradius_sea_fixed:
    ldr d0,[x10,#560]
.Lradius_sea_number:
    radius_constant d1,.Lradius_sea_quadratic
    fmul d1,d0,d1
    fmul d1,d1,d0
    radius_constant d2,.Lradius_sea_linear
    fmul d2,d0,d2
    fsub d2,d2,d1
    radius_constant d3,.Lradius_sea_offset
    fadd d9,d2,d3
    radius_constant d8,.Lradius_sea_dispersion
    radius_constant d10,.Lradius_sea_ratio
.Lradius_number_ready:
    ldr w9,[sp,#276]
    cbz w9,.Lradius_denominator
    ldr x10,[sp,#280]
    ldr d0,[x10,#56]
    ldr d1,[x10,#24]
    ldrsw x11,[x10,#140]
    sub x11,x11,#1
    madd x11,x11,x21,x23
    ldr x10,[sp,#264]
    ldr d2,[x10,x11,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    bl exp
    fmul d9,d9,d0
.Lradius_denominator:
    adrp x9,:got:__yomcst_MOD_rpi
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
    ldr d0,[x9]
    fmov d1,#4.0
    fmul d14,d1,d0
    fmul d14,d14,d9
    fmul d14,d14,d8
    mov x24,#0
.Lradius_modern_level:
    madd x25,x24,x21,x23
    lsl x25,x25,#3
    ldr x10,[sp,#208]
    ldr d3,[x10,x25]
    radius_constant d0,.Lradius_cloud_threshold
    fcmp d3,d0
    b.lt .Lradius_dry
    ldr x10,[sp,#216]
    ldr d0,[x10,x25]
    ldr x10,[sp,#224]
    ldr d1,[x10,x25]
    fadd d2,d0,d1
    fcmp d2,#0.0
    b.le .Lradius_dry
/* Convert each water mass fraction separately to in-cloud density. */
    ldr x10,[sp,#192]
    ldr d2,[x10,x25]
    radius_constant d4,.Lradius_thousand
    fmul d2,d4,d2
    ldr x10,[sp,#200]
    ldr d4,[x10,x25]
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d5,[x9]
    fmul d4,d5,d4
    fdiv d2,d2,d4
    fmul d0,d2,d0
    fmul d1,d2,d1
    fdiv d11,d0,d3
    fdiv d12,d1,d3
    fmov d13,#1.0
    adrp x9,:got:__yoerdu_MOD_repscw
    ldr x9,[x9,:got_lo12:__yoerdu_MOD_repscw]
    ldr d0,[x9]
    fcmp d11,d0
    b.le .Lradius_volume
    fdiv d15,d12,d11
    fmov d0,#1.0
    fadd d0,d0,d15
    radius_constant d1,.Lradius_two_thirds
    bl md2asm_pow_original_rounding_candidate
    radius_constant d1,.Lradius_fifth
    fmul d1,d1,d10
    fmul d1,d1,d15
    fmov d2,#1.0
    fadd d1,d2,d1
    fdiv d13,d0,d1
.Lradius_volume:
    fadd d0,d11,d12
    fmov d1,#3.0
    fmul d0,d1,d0
    fdiv d0,d0,d14
    adrp x9,:got:__yoerdu_MOD_replog
    ldr x9,[x9,:got_lo12:__yoerdu_MOD_replog]
    ldr d1,[x9]
    fcmp d0,d1
    b.le .Lradius_dry
    bl log
    radius_constant d1,.Lradius_third
    fmul d0,d1,d0
    bl exp
    radius_constant d1,.Lradius_hundred
    fmul d1,d13,d1
    fmul d0,d1,d0
    fmov d1,#30.0
    fminnm d0,d0,d1
    fmov d1,#4.0
    fmaxnm d0,d0,d1
    b .Lradius_store_modern
.Lradius_dry:
    fmov d0,#4.0
.Lradius_store_modern:
    ldr x10,[sp,#256]
    str d0,[x10,x25]
    add x24,x24,#1
    cmp x24,x22
    b.lt .Lradius_modern_level
    b .Lradius_next_column
.Lradius_fixed_column:
    ldr x10,[sp,#232]
    ldr d0,[x10,x23,lsl #3]
    fmov d1,#0.5
    fcmp d0,d1
    b.lt .Lradius_fixed_sea
    fmov d15,#10.0
    b .Lradius_fixed_levels
.Lradius_fixed_sea:
    fmov d15,#13.0
.Lradius_fixed_levels:
    mov x24,#0
.Lradius_fixed_level:
    madd x25,x24,x21,x23
    lsl x25,x25,#3
    ldr x10,[sp,#256]
    str d15,[x10,x25]
    add x24,x24,#1
    cmp x24,x22
    b.lt .Lradius_fixed_level
    b .Lradius_next_column
.Lradius_legacy_column:
    mov x24,#0
.Lradius_legacy_level:
    madd x25,x24,x21,x23
    lsl x25,x25,#3
    ldr x10,[sp,#192]
    ldr d0,[x10,x25]
    radius_constant d1,.Lradius_reference_pressure
    fsub d0,d1,d0
    fmov d1,#3.5
    fmul d0,d0,d1
    fmov d1,#10.0
    fadd d0,d1,d0
    ldr x10,[sp,#256]
    str d0,[x10,x25]
    add x24,x24,#1
    cmp x24,x22
    b.lt .Lradius_legacy_level
.Lradius_next_column:
    add x23,x23,#1
    cmp x23,x20
    b.lt .Lradius_column
.Lradius_return:
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#384
    ret
.Lradius_unsupported:
    bl abort
.size LIQUID_RADIUS_SYMBOL,.-LIQUID_RADIUS_SYMBOL
.section .rodata
.p2align 3
.Lradius_sea_ratio: .quad 0x3fe5261293de469b
.Lradius_land_ratio: .quad 0x3fe5ef8102bb5092
.Lradius_sea_dispersion: .double 0.77
.Lradius_land_dispersion: .double 0.69
.Lradius_sea_quadratic: .double 0.00115
.Lradius_land_quadratic: .double 0.000210
.Lradius_sea_linear: .double 0.963
.Lradius_land_linear: .double 0.568
.Lradius_sea_offset: .double 5.30
.Lradius_land_offset: .double 27.9
.Lradius_cloud_threshold: .double 0.001
.Lradius_thousand: .double 1000.0
.Lradius_hundred: .double 100.0
.Lradius_reference_pressure: .double 100000.0
.Lradius_third: .double 0.333
.Lradius_two_thirds: .double 0.666
.Lradius_fifth: .double 0.2
.section .note.GNU-stack,"",%progbits

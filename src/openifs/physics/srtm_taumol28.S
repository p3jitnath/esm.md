// Complete shortwave band-28 ozone and oxygen optical depth.
// The frozen Markdown contract defines all twenty pointer arguments.
// Columns have approximately 1e20 molecules/cm2 units. Depth is dimensionless.
// Solar flux has W/m2 units. All operations use separate binary64 rounding.
// The 304-byte frame saves x19 through x30 and all argument pointers.
// Only active daylight cells in the first six of sixteen points are written.
// Complete lower pass precedes upper pass with one shared solar selector.
.text
.p2align 4
.global srtm_taumol28_assembly_
.type srtm_taumol28_assembly_, %function
srtm_taumol28_assembly_:
    sub sp, sp, #304
    stp x19, x20, [sp, #0]
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    stp x29, x30, [sp, #80]
    stp x0, x1, [sp, #96]
    stp x2, x3, [sp, #112]
    stp x4, x5, [sp, #128]
    stp x6, x7, [sp, #144]
    ldp x8, x9, [sp, #304]
    stp x8, x9, [sp, #160]
    ldp x8, x9, [sp, #320]
    stp x8, x9, [sp, #176]
    ldp x8, x9, [sp, #336]
    stp x8, x9, [sp, #192]
    ldp x8, x9, [sp, #352]
    stp x8, x9, [sp, #208]
    ldp x8, x9, [sp, #368]
    stp x8, x9, [sp, #224]
    ldp x8, x9, [sp, #384]
    stp x8, x9, [sp, #240]
    ldr w8, [x1]
    ldr w9, [x2]
    sub w19, w9, w8
    add w19, w19, #1
    cbz w19, .L28_return
    ldr w20, [x0]
    ldr w21, [x3]
    cbz w21, .L28_return
    mul w28, w19, w20
    adrp x9, :got:__yoesrta28_MOD_strrat
    ldr x9, [x9, :got_lo12:__yoesrta28_MOD_strrat]
    ldr d26, [x9]
    adrp x9, :got:__yoesrta28_MOD_rayl
    ldr x9, [x9, :got_lo12:__yoesrta28_MOD_rayl]
    ldr d27, [x9]
    adrp x9, :got:__yoesrta28_MOD_layreffr
    ldr x9, [x9, :got_lo12:__yoesrta28_MOD_layreffr]
    ldr w8, [x9]
    str w8, [sp, #264]
    fmov d24, #1.0
    fmov d25, #8.0
    mov w26, #0
    mov w29, #9
    mov w8, #4680
    str w8, [sp, #260]
    adrp x27, :got:yoesrta28.eq.1_
    ldr x27, [x27, :got_lo12:yoesrta28.eq.1_]
    mov w22, #0
.L28_layer:
    mov w23, #0
    umull x25, w22, w19
.L28_column:
    ldr x9, [sp, #248]
    ldr d0, [x9, x23, lsl #3]
    fcmp d0, #0.0
    b.le .L28_next_column
    ldr x9, [sp, #216]
    ldr w10, [x9, x23, lsl #2]
    cmp w22, w10
    cbnz w26, .L28_upper_select
    b.ge .L28_next_column
    b .L28_mixture
.L28_upper_select:
    b.lt .L28_next_column
    // This selector is shared. Each column can change later columns' writes.
    ldr x9, [sp, #160]
    sub x10, x25, x19
    ldr w11, [x9, x10, lsl #2]
    ldr w12, [x9, x25, lsl #2]
    ldr w13, [sp, #264]
    cmp w11, w13
    b.ge .L28_mixture
    cmp w12, w13
    b.lt .L28_mixture
    add w8, w22, #1
    str w8, [sp, #268]
.L28_mixture:
    ldr x9, [sp, #208]
    ldr d0, [x9, x25, lsl #3]
    ldr x9, [sp, #200]
    ldr d1, [x9, x25, lsl #3]
    fmul d1, d26, d1
    fadd d20, d0, d1
    fdiv d2, d0, d20
    ldr x9, [sp, #184]
    ldr d3, [x9, x23, lsl #3]
    fcmp d2, d3
    b.lt .L28_cap_done
    fmov d2, d3
.L28_cap_done:
    fmul d2, d25, d2
    fcvtzs w8, d2
    scvtf d3, w8
    fsub d21, d2, d3
    fsub d22, d24, d21
    str w8, [sp, #272]
    ldr x9, [sp, #128]
    ldr d16, [x9, x25, lsl #3]
    ldr x9, [sp, #144]
    ldr d17, [x9, x25, lsl #3]
    ldr x9, [sp, #136]
    ldr d18, [x9, x25, lsl #3]
    ldr x9, [sp, #152]
    ldr d19, [x9, x25, lsl #3]
    ldr x9, [sp, #160]
    ldr w7, [x9, x25, lsl #2]
    ldr x9, [sp, #168]
    ldr w11, [x9, x25, lsl #2]
    ldr x9, [sp, #176]
    ldr w12, [x9, x25, lsl #2]
    sub w11, w11, #1
    sub w12, w12, #1
    mov w13, #1
    mov w14, #0
    cbz w26, .L28_pressure_base
    mov w13, #13
    mov w14, #12
.L28_pressure_base:
    sub w10, w7, w13
    add w10, w10, w10, lsl #2
    add w10, w10, w11
    mul w10, w10, w29
    add w10, w10, w8
    str w10, [sp, #276]
    sub w15, w7, w14
    add w15, w15, w15, lsl #2
    add w15, w15, w12
    mul w15, w15, w29
    add w15, w15, w8
    str w15, [sp, #280]
    ldr x9, [sp, #192]
    ldr d0, [x9, x25, lsl #3]
    fmul d23, d0, d27
    mov w24, #0
.L28_point:
    ldr w8, [sp, #260]
    mul w8, w24, w8
    add x9, x27, w8, uxtw
    ldr w10, [sp, #276]
    ldr w11, [sp, #280]
    add x10, x9, w10, uxtw #3
    add x11, x9, w11, uxtw #3
    add x12, x10, w29, uxtw #3
    add x13, x11, w29, uxtw #3
    // Adjacent mixture nodes form two complete ordered four-product sums.
    ldp d0, d1, [x10]
    ldp d2, d3, [x12]
    ldp d4, d5, [x11]
    ldp d6, d7, [x13]
    fmul d0, d0, d16
    fmul d1, d1, d16
    fmul d2, d2, d17
    fmul d3, d3, d17
    fadd d0, d0, d2
    fadd d1, d1, d3
    fmul d4, d4, d18
    fmul d5, d5, d18
    fadd d0, d0, d4
    fadd d1, d1, d5
    fmul d6, d6, d19
    fmul d7, d7, d19
    fadd d0, d0, d6
    fadd d1, d1, d7
    fmul d0, d22, d0
    fmul d1, d21, d1
    fadd d0, d0, d1
    fmul d0, d20, d0
    umaddl x9, w24, w28, x25
    ldr x10, [sp, #232]
    str d0, [x10, x9, lsl #3]
    cbz w26, .L28_store_ray
    add w8, w22, #1
    ldr w10, [sp, #268]
    cmp w8, w10
    b.ne .L28_store_ray
    // Interpolate the two selected five-node solar entries in source order.
    ldr w8, [sp, #272]
    add w11, w24, w8, lsl #4
    adrp x10, :got:__yoesrta28_MOD_sfluxrefc
    ldr x10, [x10, :got_lo12:__yoesrta28_MOD_sfluxrefc]
    add x10, x10, w11, uxtw #3
    ldr d0, [x10]
    ldr d1, [x10, #128]
    fsub d1, d1, d0
    fmul d1, d21, d1
    fadd d0, d0, d1
    umaddl x11, w24, w19, x23
    ldr x10, [sp, #224]
    str d0, [x10, x11, lsl #3]
.L28_store_ray:
    ldr x10, [sp, #240]
    str d23, [x10, x9, lsl #3]
    add w24, w24, #1
    cmp w24, #6
    b.lt .L28_point
.L28_next_column:
    add w23, w23, #1
    add x25, x25, #1
    cmp w23, w19
    b.lt .L28_column
    add w22, w22, #1
    cmp w22, w21
    b.lt .L28_layer
    cbnz w26, .L28_return
    // The upper pass starts only after every lower layer and column.
    mov w26, #1
    mov w29, #5
    mov w8, #9400
    str w8, [sp, #260]
    str w21, [sp, #268]
    fmov d25, #4.0
    adrp x27, :got:yoesrta28.eq.0_
    ldr x27, [x27, :got_lo12:yoesrta28.eq.0_]
    mov w22, #0
    b .L28_layer
.L28_return:
    ldp x19, x20, [sp, #0]
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x25, x26, [sp, #48]
    ldp x27, x28, [sp, #64]
    ldp x29, x30, [sp, #80]
    add sp, sp, #304
    ret
.size srtm_taumol28_assembly_, .-srtm_taumol28_assembly_
.section .note.GNU-stack,"",%progbits

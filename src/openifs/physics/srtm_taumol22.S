// Complete direct water/oxygen absorption, solar interpolation and scattering.
// Physics: formulations/openifs/physics/shortwave_water_oxygen.md.
// Contract: skills/md2asm/references/openifs/physics/srtm_taumol22.md.
// The GNU interface has26 reference arguments and complete sixteen-point owners.
// One INTEGER4 solar selector per active column is private stack storage.
// Preserve x19-x29, link register, stack alignment, x18 and d8-d15.
// Reuse accepted ordered interpolation instructions with Band22's own equations.
.arch armv8-a
.text
.p2align 4
.global md2asm_srtm_taumol22
.type md2asm_srtm_taumol22,%function
.macro FIELD reg,idx
    ldr \reg,[x29,#(96+8*\idx)]
.endm
.macro GOT reg,sym
    adrp \reg,:got:\sym
    ldr \reg,[\reg,:got_lo12:\sym]
.endm
md2asm_srtm_taumol22:
    sub sp, sp, #352
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
    ldp x9, x10, [sp, #352]
    stp x9, x10, [sp, #160]
    ldp x9, x10, [sp, #368]
    stp x9, x10, [sp, #176]
    ldp x9, x10, [sp, #384]
    stp x9, x10, [sp, #192]
    ldp x9, x10, [sp, #400]
    stp x9, x10, [sp, #208]
    ldp x9, x10, [sp, #416]
    stp x9, x10, [sp, #224]
    ldp x9, x10, [sp, #432]
    stp x9, x10, [sp, #240]
    ldp x9, x10, [sp, #448]
    stp x9, x10, [sp, #256]
    ldp x9, x10, [sp, #464]
    stp x9, x10, [sp, #272]
    ldp x9, x10, [sp, #480]
    stp x9, x10, [sp, #288]
    ldr w19, [x2]
    ldr w9, [x1]
    sub w19, w19, w9
    add w19, w19, #1
    ldr w20, [x3]
    ldr w21, [x0]
    cbz w19, .L22_fixed_return
    cbz w20, .L22_fixed_return
    mov x29,sp
    add x9,x19,#3
    lsr x9,x9,#2
    lsl x9,x9,#4
    sub sp,sp,x9
    str x9,[x29,#328]
    mov x10,sp
    str x10,[x29,#320]
    FIELD x11,15
    mov x12,#0
.L22_init_selector:
    ldr w13,[x11,x12,lsl #2]
    str w13,[x10,x12,lsl #2]
    add x12,x12,#1
    cmp x12,x19
    b.lt .L22_init_selector
    mul x22, x19, x21
    lsl x22, x22, #3
    GOT x9, __yoesrta22_MOD_rayl
    ldr d29, [x9]
    GOT x9, __yoesrta22_MOD_strrat
    ldr d30, [x9]
    fmov d31, #1.0

/* Complete the lower pass in increasing layer and column order. */
    mov x23, #0
.L22_lower_layer:
    mov x24, #0
.L22_lower_column:
    FIELD x9, 25
    ldr d23, [x9, x24, lsl #3]
    fcmp d23, #0.0
    b.le .L22_lower_next_column
    FIELD x9, 15
    ldr w10, [x9, x24, lsl #2]
    cmp w23, w10
    b.ge .L22_lower_next_column
    madd x25, x23, x19, x24
    FIELD x9,8
    ldr w11,[x9,x25,lsl #2]
    GOT x12,__yoesrta22_MOD_layreffr
    ldr w12,[x12]
    cmp w11,w12
    b.ge .L22_lower_no_crossing
    add x11,x25,x19
    ldr w11,[x9,x11,lsl #2]
    cmp w11,w12
    b.lt .L22_lower_no_crossing
    add w11,w23,#2
    cmp w11,w10
    csel w11,w11,w10,le
    ldr x9,[x29,#320]
    str w11,[x9,x24,lsl #2]
.L22_lower_no_crossing:
    ldr x9,[x29,#320]
    ldr w11,[x9,x24,lsl #2]
    add w12,w23,#1
    cmp w11,w12
    cset w11,eq
    str w11,[x29,#308]
    FIELD x9, 4
    ldr d0, [x9, x25, lsl #3]
    FIELD x9, 6
    ldr d1, [x9, x25, lsl #3]
    FIELD x9, 5
    ldr d2, [x9, x25, lsl #3]
    FIELD x9, 7
    ldr d3, [x9, x25, lsl #3]
    FIELD x9, 12
    ldr d4, [x9, x25, lsl #3]
    FIELD x9, 14
    ldr d24, [x9, x25, lsl #3]
    adrp x9,.L22_oxygen_constant
    ldr d23,[x9,:lo12:.L22_oxygen_constant]
    fmul d28,d23,d24
    adrp x9,.L22_denominator
    ldr d23,[x9,:lo12:.L22_denominator]
    fdiv d28,d28,d23
    adrp x9,.L22_adjustment
    ldr d23,[x9,:lo12:.L22_adjustment]
    fmul d23,d23,d30
    fmul d23,d23,d24
    fadd d5,d4,d23
    fdiv d6, d4, d5
    FIELD x9, 11
    ldr d23, [x9, x24, lsl #3]
    fcmp d6, d23
    fcsel d6, d23, d6, ge
    fmov d23, #8.0
    fmul d6, d23, d6
    fcvtzs w16, d6
    scvtf d23, w16
    fsub d6, d6, d23
    fsub d7, d31, d6

/* Zero-based rows keep all eight lower table gathers within 585 rows. */
    FIELD x9, 8
    ldr w10, [x9, x25, lsl #2]
    FIELD x9, 9
    ldr w11, [x9, x25, lsl #2]
    FIELD x9, 10
    ldr w12, [x9, x25, lsl #2]
    sub w11, w11, #1
    sub w12, w12, #1
    mov w13, #5
    madd w12, w10, w13, w12
    sub w10, w10, #1
    madd w11, w10, w13, w11
    mov w13, #9
    madd w11, w11, w13, w16
    madd w12, w12, w13, w16
    GOT x9, yoesrta22.eq.1_
    add x28, x9, x11, lsl #3
    add x17, x9, x12, lsl #3
    FIELD x9, 18
    ldr w10, [x9, x25, lsl #2]
    sub w10, w10, #1
    GOT x9, __yoesrta22_MOD_selfrefc
    add x14, x9, x10, lsl #3
    FIELD x9, 21
    ldr w10, [x9, x25, lsl #2]
    sub w10, w10, #1
    GOT x9, __yoesrta22_MOD_forrefc
    add x15, x9, x10, lsl #3
    FIELD x9, 16
    ldr d17, [x9, x25, lsl #3]
    FIELD x9, 17
    ldr d18, [x9, x25, lsl #3]
    FIELD x9, 19
    ldr d19, [x9, x25, lsl #3]
    FIELD x9, 20
    ldr d20, [x9, x25, lsl #3]
    FIELD x9, 13
    ldr d16, [x9, x25, lsl #3]
    fmul d16, d16, d29
    FIELD x9, 23
    add x26, x9, x25, lsl #3
    FIELD x9, 24
    add x27, x9, x25, lsl #3
    FIELD x9,22
    add x12,x9,x24,lsl #3
    GOT x13,__yoesrta22_MOD_sfluxrefc
    add x13,x13,x16,lsl #7
    mov x30, #0
.L22_lower_point:
/* Each bracket retains four coefficient-first products and rounded sums. */
    ldr d21, [x28, #0]
    fmul d21, d21, d0
    ldr d23, [x28, #72]
    fmul d23, d23, d1
    fadd d21, d21, d23
    ldr d23, [x17, #0]
    fmul d23, d23, d2
    fadd d21, d21, d23
    ldr d23, [x17, #72]
    fmul d23, d23, d3
    fadd d21, d21, d23
    ldr d22, [x28, #8]
    fmul d22, d22, d0
    ldr d23, [x28, #80]
    fmul d23, d23, d1
    fadd d22, d22, d23
    ldr d23, [x17, #8]
    fmul d23, d23, d2
    fadd d22, d22, d23
    ldr d23, [x17, #80]
    fmul d23, d23, d3
    fadd d22, d22, d23
    fmul d21, d7, d21
    fmul d22, d6, d22
    fadd d21, d21, d22
    fmul d21, d5, d21
/* Lower self and foreign interpolation retain their separate differences. */
    ldp d26, d27, [x14]
    fsub d27, d27, d26
    fmul d27, d18, d27
    fadd d26, d26, d27
    fmul d24, d17, d26
    ldp d26, d27, [x15]
    fsub d27, d27, d26
    fmul d27, d20, d27
    fadd d26, d26, d27
    fmul d25, d19, d26
    fadd d24, d24, d25
    fmul d24, d4, d24
    fadd d21, d21, d24
    fadd d21,d21,d28
    ldr w9,[x29,#308]
    cbz w9,.L22_lower_no_solar
    ldr d23,[x13]
    ldr d24,[x13,#128]
    fsub d24,d24,d23
    fmul d24,d6,d24
    fadd d23,d23,d24
    str d23,[x12]
.L22_lower_no_solar:
    str d21, [x26]
    str d16, [x27]
    add x30, x30, #1
    cmp x30, #2
    b.eq .L22_lower_next_column
    mov x9, #4680
    add x28, x28, x9
    add x17, x17, x9
    add x14, x14, #80
    add x15, x15, #24
    add x12,x12,x19,lsl #3
    add x13,x13,#8
    add x26, x26, x22
    add x27, x27, x22
    b .L22_lower_point
.L22_lower_next_column:
    add x24, x24, #1
    cmp x24, x19
    b.lt .L22_lower_column
    add x23, x23, #1
    cmp x23, x20
    b.lt .L22_lower_layer

// The upper branch uses oxygen alone and no solar or water continuum fields.
    mov x23,#0
.L22_upper_layer:
    mov x24,#0
.L22_upper_column:
    FIELD x9,25
    ldr d23,[x9,x24,lsl #3]
    fcmp d23,#0.0
    b.le .L22_upper_next_column
    FIELD x9,15
    ldr w10,[x9,x24,lsl #2]
    cmp w23,w10
    b.lt .L22_upper_next_column
    madd x25,x23,x19,x24
    FIELD x9,4
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,6
    ldr d1,[x9,x25,lsl #3]
    FIELD x9,5
    ldr d2,[x9,x25,lsl #3]
    FIELD x9,7
    ldr d3,[x9,x25,lsl #3]
    FIELD x9,14
    ldr d4,[x9,x25,lsl #3]
    adrp x9,.L22_adjustment
    ldr d23,[x9,:lo12:.L22_adjustment]
    fmul d5,d4,d23
    adrp x9,.L22_oxygen_constant
    ldr d23,[x9,:lo12:.L22_oxygen_constant]
    fmul d28,d23,d4
    adrp x9,.L22_denominator
    ldr d23,[x9,:lo12:.L22_denominator]
    fdiv d28,d28,d23
    FIELD x9,8
    ldr w10,[x9,x25,lsl #2]
    FIELD x9,9
    ldr w11,[x9,x25,lsl #2]
    FIELD x9,10
    ldr w12,[x9,x25,lsl #2]
    sub w11,w11,#1
    sub w12,w12,#1
    sub w13,w10,#12
    sub w10,w10,#13
    mov w9,#5
    madd w11,w10,w9,w11
    madd w12,w13,w9,w12
    GOT x9,yoesrta22.eq.0_
    add x28,x9,x11,lsl #3
    add x17,x9,x12,lsl #3
    FIELD x9,13
    ldr d16,[x9,x25,lsl #3]
    fmul d16,d16,d29
    FIELD x9,23
    add x26,x9,x25,lsl #3
    FIELD x9,24
    add x27,x9,x25,lsl #3
    mov x30,#0
.L22_upper_point:
    ldr d21,[x28]
    fmul d21,d0,d21
    ldr d23,[x28,#8]
    fmul d23,d1,d23
    fadd d21,d21,d23
    ldr d23,[x17]
    fmul d23,d2,d23
    fadd d21,d21,d23
    ldr d23,[x17,#8]
    fmul d23,d3,d23
    fadd d21,d21,d23
    fmul d21,d5,d21
    fadd d21,d21,d28
    str d21,[x26]
    str d16,[x27]
    add x30,x30,#1
    cmp x30,#2
    b.eq .L22_upper_next_column
    mov x9,#1880
    add x28,x28,x9
    add x17,x17,x9
    add x26,x26,x22
    add x27,x27,x22
    b .L22_upper_point
.L22_upper_next_column:
    add x24,x24,#1
    cmp x24,x19
    b.lt .L22_upper_column
    add x23,x23,#1
    cmp x23,x20
    b.lt .L22_upper_layer
    mov sp,x29
.L22_fixed_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#352
    ret
.size md2asm_srtm_taumol22,.-md2asm_srtm_taumol22
.section .rodata
.p2align 3
.L22_adjustment:
    .double 1.6
.L22_denominator:
    .double 700.0
.L22_oxygen_constant:
    .quad 0x3f3c8216c0000000
.section .note.GNU-stack,"",%progbits

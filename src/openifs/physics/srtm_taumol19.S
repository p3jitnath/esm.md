/* Complete shortwave band 19 from the frozen original physical contract.
 * FP64 products and sums keep every source rounding point.
 * Scaled columns count approximately 10^20 molecules/cm^2.
 * Optical depth has no unit and solar flux uses W/m^2.
 * Twenty-six ordinary pointers use x0-x7 and eighteen stack slots.
 * Fixed frame352 plus aligned four-byte-per-column solar state preserves x19-x30. x18 and d8-d15 are untouched.
 * Column-fast fields keep complete sixteen-point output capacity.
 * The two layer-major passes retain independent lower solar selection.
 */
.arch armv8-a
.text
.p2align 2
.global srtm_taumol19_assembly_
.type srtm_taumol19_assembly_, %function
.macro FIELD reg, idx
    ldr \reg, [x17, #(96+8*\idx)]
.endm
.macro GOT reg, sym
    adrp \reg, :got:\sym
    ldr \reg, [\reg, :got_lo12:\sym]
.endm
srtm_taumol19_assembly_:
    sub sp, sp, #352
    mov x17, sp
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
    cbz w19, .L19_return
    cbz w20, .L19_return
    mul x22, x19, x21
    lsl x22, x22, #3
    GOT x9, __yoesrta19_MOD_rayl
    ldr d29, [x9]
    GOT x9, __yoesrta19_MOD_strrat
    ldr d30, [x9]
    fmov d31, #1.0

/* Each column owns one four-byte solar index for the complete call. */
    lsl x9, x19, #2
    add x9, x9, #15
    and x9, x9, #-16
    sub sp, sp, x9
    mov x9, sp
    str x9, [x17, #304]
    mov x9, #0
    FIELD x10, 15
.L19_state_init:
    ldr w11, [x10, x9, lsl #2]
    str w11, [sp, x9, lsl #2]
    add x9, x9, #1
    cmp x9, x19
    b.lt .L19_state_init

/* Lower pass keeps increasing layers and then increasing columns. */
    mov x23, #0
.L19_lower_layer:
    mov x24, #0
.L19_lower_column:
    FIELD x9, 25
    ldr d23, [x9, x24, lsl #3]
    fcmp d23, #0.0
    b.le .L19_lower_next_column
    FIELD x9, 15
    ldr w10, [x9, x24, lsl #2]
    cmp w23, w10
    b.ge .L19_lower_next_column
    madd x25, x23, x19, x24
/* Preserve the next-pressure capacity and the column-local lower crossing. */
    FIELD x9, 8
    ldr w11, [x9, x25, lsl #2]
    add x12, x25, x19
    ldr w12, [x9, x12, lsl #2]
    GOT x9, __yoesrta19_MOD_layreffr
    ldr w13, [x9]
    cmp w11, w13
    b.ge .L19_lower_no_crossing
    cmp w12, w13
    b.lt .L19_lower_no_crossing
    add w11, w23, #2
    cmp w11, w10
    csel w11, w11, w10, le
    ldr x9, [x17, #304]
    str w11, [x9, x24, lsl #2]
.L19_lower_no_crossing:
    ldr x9, [x17, #304]
    ldr w11, [x9, x24, lsl #2]
    add w12, w23, #1
    cmp w11, w12
    cset w11, eq
    str w11, [x17, #312]
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
    FIELD x9, 13
    ldr d23, [x9, x25, lsl #3]
    fmul d23, d30, d23
    fadd d5, d4, d23
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

/* Nine mixture rows per temperature and 585 rows per spectral point. */
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
    GOT x9, yoesrta19.eq.1_
    add x28, x9, x11, lsl #3
    add x29, x9, x12, lsl #3
    FIELD x9, 18
    ldr w10, [x9, x25, lsl #2]
    sub w10, w10, #1
    GOT x9, __yoesrta19_MOD_selfrefc
    add x14, x9, x10, lsl #3
    FIELD x9, 21
    ldr w10, [x9, x25, lsl #2]
    sub w10, w10, #1
    GOT x9, __yoesrta19_MOD_forrefc
    add x15, x9, x10, lsl #3
    FIELD x9, 16
    ldr d17, [x9, x25, lsl #3]
    FIELD x9, 17
    ldr d18, [x9, x25, lsl #3]
    FIELD x9, 19
    ldr d19, [x9, x25, lsl #3]
    FIELD x9, 20
    ldr d20, [x9, x25, lsl #3]
    FIELD x9, 14
    ldr d16, [x9, x25, lsl #3]
    fmul d16, d16, d29
    FIELD x9, 23
    add x26, x9, x25, lsl #3
    FIELD x9, 24
    add x27, x9, x25, lsl #3
    GOT x12, __yoesrta19_MOD_sfluxrefc
    add x12, x12, x16, lsl #7
    FIELD x9, 22
    add x13, x9, x24, lsl #3
    mov x30, #0
.L19_lower_point:
/* First four rounded products are summed from left to right. */
    ldr d21, [x28, #0]
    fmul d21, d21, d0
    ldr d23, [x28, #72]
    fmul d23, d23, d1
    fadd d21, d21, d23
    ldr d23, [x29, #0]
    fmul d23, d23, d2
    fadd d21, d21, d23
    ldr d23, [x29, #72]
    fmul d23, d23, d3
    fadd d21, d21, d23
/* The next mixture bracket has its own four-product rounded sum. */
    ldr d22, [x28, #8]
    fmul d22, d22, d0
    ldr d23, [x28, #80]
    fmul d23, d23, d1
    fadd d22, d22, d23
    ldr d23, [x29, #8]
    fmul d23, d23, d2
    fadd d22, d22, d23
    ldr d23, [x29, #80]
    fmul d23, d23, d3
    fadd d22, d22, d23
    fmul d21, d7, d21
    fmul d22, d6, d22
    fadd d21, d21, d22
    fmul d21, d5, d21
/* Self and foreign continua retain adjacent-row subtraction. */
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
    str d21, [x26]
    ldr w9, [x17, #312]
    cbz w9, .L19_lower_no_solar
/* Adjacent solar mixture columns are sixteen reals apart. */
    ldr d26, [x12]
    ldr d27, [x12, #128]
    fsub d27, d27, d26
    fmul d27, d6, d27
    fadd d26, d26, d27
    str d26, [x13]
.L19_lower_no_solar:
    str d16, [x27]
    add x30, x30, #1
    cmp x30, #8
    b.eq .L19_lower_next_column
    mov x9, #4680
    add x28, x28, x9
    add x29, x29, x9
    add x14, x14, #80
    add x15, x15, #24
    add x12, x12, #8
    add x13, x13, x19, lsl #3
    add x26, x26, x22
    add x27, x27, x22
    b .L19_lower_point
.L19_lower_next_column:
    add x24, x24, #1
    cmp x24, x19
    b.lt .L19_lower_column
    add x23, x23, #1
    cmp x23, x20
    b.lt .L19_lower_layer

/* The upper pass changes no solar selection or solar output. */
    mov x23, #0
.L19_upper_layer:
    mov x24, #0
.L19_upper_column:
    FIELD x9, 25
    ldr d23, [x9, x24, lsl #3]
    fcmp d23, #0.0
    b.le .L19_upper_next_column
    FIELD x9, 15
    ldr w10, [x9, x24, lsl #2]
    cmp w23, w10
    b.lt .L19_upper_next_column
    madd x25, x23, x19, x24
    FIELD x9, 8
    ldr w10, [x9, x25, lsl #2]
/* Upper temperature rows have no mixture axis and no water continuum. */
    FIELD x9, 9
    ldr w11, [x9, x25, lsl #2]
    FIELD x9, 10
    ldr w12, [x9, x25, lsl #2]
    sub w11, w11, #1
    sub w12, w12, #1
    sub w13, w10, #12
    sub w10, w10, #13
    mov w9, #5
    madd w11, w10, w9, w11
    madd w12, w13, w9, w12
    GOT x9, yoesrta19.eq.0_
    add x28, x9, x11, lsl #3
    add x29, x9, x12, lsl #3
    FIELD x9, 4
    ldr d0, [x9, x25, lsl #3]
    FIELD x9, 6
    ldr d1, [x9, x25, lsl #3]
    FIELD x9, 5
    ldr d2, [x9, x25, lsl #3]
    FIELD x9, 7
    ldr d3, [x9, x25, lsl #3]
    FIELD x9, 13
    ldr d4, [x9, x25, lsl #3]
    FIELD x9, 14
    ldr d16, [x9, x25, lsl #3]
    fmul d16, d16, d29
    FIELD x9, 23
    add x26, x9, x25, lsl #3
    FIELD x9, 24
    add x27, x9, x25, lsl #3
    mov x30, #0
.L19_upper_point:
    ldr d21, [x28, #0]
    fmul d21, d0, d21
    ldr d23, [x28, #8]
    fmul d23, d1, d23
    fadd d21, d21, d23
    ldr d23, [x29, #0]
    fmul d23, d2, d23
    fadd d21, d21, d23
    ldr d23, [x29, #8]
    fmul d23, d3, d23
    fadd d21, d21, d23
    fmul d21, d4, d21
    str d21, [x26]
    str d16, [x27]
    add x30, x30, #1
    cmp x30, #8
    b.eq .L19_upper_next_column
    add x28, x28, #1880
    add x29, x29, #1880
    add x26, x26, x22
    add x27, x27, x22
    b .L19_upper_point
.L19_upper_next_column:
    add x24, x24, #1
    cmp x24, x19
    b.lt .L19_upper_column
    add x23, x23, #1
    cmp x23, x20
    b.lt .L19_upper_layer
.L19_return:
    mov sp, x17
    ldp x19, x20, [sp, #0]
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x25, x26, [sp, #48]
    ldp x27, x28, [sp, #64]
    ldp x29, x30, [sp, #80]
    add sp, sp, #352
    ret
.size srtm_taumol19_assembly_, .-srtm_taumol19_assembly_
.section .note.GNU-stack,"",%progbits

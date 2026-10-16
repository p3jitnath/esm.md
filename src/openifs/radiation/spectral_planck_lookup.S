// Selected two-band Planck CALC from yoe_spectral_planck.F90:241-298.
// Contract: skills/md2asm/references/openifs/radiation/spectral_planck_lookup.md.
// x0 record240, x1 temperatures, x2 count, x3 output, x4 capacity,
// x5 constants520, w6 first, w7 last. Return 0 or atomic rejection 2.
// All spans are mapped and aligned to eight bytes. FPCR must be zero.
.text
.p2align 4
.global md2asm_calculate_selected_spectral_planck
.type md2asm_calculate_selected_spectral_planck,%function
md2asm_calculate_selected_spectral_planck:
    mrs x8, fpcr
    cbnz x8, .Lreject
    cbz x0, .Lreject
    cbz x1, .Lreject
    cbz x3, .Lreject
    cbz x5, .Lreject
    orr x8, x0, x1
    orr x8, x8, x3
    orr x8, x8, x5
    tst x8, #7
    b.ne .Lreject
    sub x8, x2, #1
    cmp x8, #4095
    b.hi .Lreject
    cmp w6, #1
    b.lt .Lreject
    cmp w7, w6
    b.lt .Lreject
    cmp w7, w2
    b.hi .Lreject
    lsl x17, x2, #4
    cmp x4, x17
    b.lo .Lreject
    adds x8, x3, x17
    b.cs .Lreject
// Reject each complete input range if it overlaps the output.
.macro EXCLUDE base, bytes
    adds x9, \base, \bytes
    b.cs .Lreject
    cmp x3, x9
    b.hs .Lapart\@
    cmp \base, x8
    b.lo .Lreject
.Lapart\@:
.endm
    EXCLUDE x0, #240
    EXCLUDE x5, #520
    lsl x17, x2, #3
    EXCLUDE x1, x17
    ldr x10, [x0, #24]
    cbz x10, .Lreject
    tst x10, #7
    b.ne .Lreject
    EXCLUDE x10, #3216
// The live table descriptor comes from the owned two-band INIT.
    ldr x8, [x0]
    mov x9, #2
    movk x9, #201, lsl #32
    cmp x8, x9
    b.ne .Lreject
    ldr x8, [x0, #8]
    mov x9, #0xc000
    movk x9, #0x4062, lsl #16
    lsl x9, x9, #32
    cmp x8, x9
    b.ne .Lreject
    ldr x8, [x0, #16]
    mov x9, #0x3ff0
    lsl x9, x9, #48
    cmp x8, x9
    b.ne .Lreject
    ldr x8, [x0, #32]
    cmn x8, #3
    b.ne .Lreject
    ldr x8, [x0, #40]
    cmp x8, #8
    b.ne .Lreject
    ldr x8, [x0, #48]
    mov x9, #0x302
    lsl x9, x9, #32
    cmp x8, x9
    b.ne .Lreject
    ldr x8, [x0, #56]
    cmp x8, #8
    b.ne .Lreject
    ldp x8, x9, [x0, #64]
    cmp x8, #1
    b.ne .Lreject
    cmp x9, #1
    b.ne .Lreject
    ldp x8, x9, [x0, #80]
    cmp x8, #2
    b.ne .Lreject
    cmp x9, #2
    b.ne .Lreject
    ldp x8, x9, [x0, #96]
    cmp x8, #1
    b.ne .Lreject
    cmp x9, #201
    b.ne .Lreject
// Check every consumed temperature by its positive FP64 bit order.
    ldr x8, [x5, #136]
    cbz x8, .Lreject
    tbnz x8, #63, .Lreject
    lsr x9, x8, #52
    cmp x9, #2047
    b.eq .Lreject
    // 1000 K = 0x408f400000000000.
    mov x12, #0x4000
    movk x12, #0x408f, lsl #16
    lsl x12, x12, #32
    mov x13, #0xd800
    movk x13, #0x4075, lsl #16
    lsl x13, x13, #32
    mov x14, #0xe000
    movk x14, #0x4075, lsl #16
    lsl x14, x14, #32
    sub w15, w6, #1
.Lcheck_temperature:
    ldr x9, [x1, x15, lsl #3]
    cbz x9, .Lreject
    cmp x9, x12
    b.hi .Lreject
    cmp x9, x13
    b.lo .Ltemperature_ok
    cmp x9, x14
    b.lo .Lreject
.Ltemperature_ok:
    add x15, x15, #1
    cmp w15, w7
    b.lo .Lcheck_temperature
// Source order: upper table temperature, interpolation, sum, then scaling.
    ldr d2, [x0, #8]
    ldr d3, [x0, #16]
    mov w8, #200
    scvtf d4, w8
    fmul d4, d3, d4
    fadd d4, d2, d4
    fmov d5, #1.0
    ldr d6, [x5, #136]
    fmov d7, xzr
    add x14, x3, x2, lsl #3
    sub w12, w6, #1
.Lcolumn:
    ldr d0, [x1, x12, lsl #3]
    fcmp d0, d2
    b.le .Llow
    fsub d1, d0, d2
    fdiv d1, d1, d3
    fadd d1, d5, d1
    fcmp d0, d4
    b.ge .Lhigh
    frinta d24, d1
    fcvtzs x11, d24
    fsub d1, d1, d24
    b .Linterpolate
.Lhigh:
    mov x11, #200
    scvtf d24, x11
    fsub d1, d1, d24
    b .Linterpolate
.Llow:
    mov x11, #1
    fmov d1, d7
.Linterpolate:
    sub x11, x11, #1
    add x11, x10, x11, lsl #4
    ldp d16, d17, [x11]
    ldp d18, d19, [x11, #16]
    fsub d18, d18, d16
    fsub d19, d19, d17
    fmul d18, d1, d18
    fmul d19, d1, d19
    fadd d16, d16, d18
    fadd d17, d17, d19
    fadd d20, d7, d16
    fadd d20, d20, d17
    fmul d21, d0, d0
    fmul d22, d21, d21
    fmul d16, d16, d6
    fmul d16, d16, d22
    fdiv d16, d16, d20
    fmul d17, d17, d6
    fmul d17, d17, d22
    fdiv d17, d17, d20
    str d16, [x3, x12, lsl #3]
    str d17, [x14, x12, lsl #3]
    add x12, x12, #1
    cmp w12, w7
    b.lo .Lcolumn
    mov w0, #0
    ret
.Lreject:
    mov w0, #2
    ret
.size md2asm_calculate_selected_spectral_planck,.-md2asm_calculate_selected_spectral_planck
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2asm/references/openifs/setup/gaussian_latitude_setup.md.
// Construct all32 Gaussian latitude sine values and weights from source arithmetic.
// Contract: skills/md2asm/references/openifs/setup/gaussian_latitude_setup.md. x0 and x1 own disjoint256-byte
// FP64 output arrays, aligned8. Return w0:0 ready,1 invalid buffers or FPCR.
// No input packet, heap allocation, Fortran target or precomputed grid is used.
// Frame416, alignment16; preserve x18 and required AAPCS64 saved registers.
.text
.p2align 4
.global md2asm_initialize_gaussian_latitudes
.type md2asm_initialize_gaussian_latitudes,%function
md2asm_initialize_gaussian_latitudes:
    mrs x9, fpcr
    cbnz x9, .Lgaussian_invalid
    cbz x0, .Lgaussian_invalid
    cbz x1, .Lgaussian_invalid
    orr x9, x0, x1
    tst x9, #7
    b.ne .Lgaussian_invalid
    adds x9, x0, #256
    b.cs .Lgaussian_invalid
    adds x10, x1, #256
    b.cs .Lgaussian_invalid
    cmp x0, x1
    b.hs .Lgaussian_second_first
    cmp x9, x1
    b.hi .Lgaussian_invalid
    b .Lgaussian_begin
.Lgaussian_second_first:
    cmp x10, x0
    b.hi .Lgaussian_invalid
.Lgaussian_begin:
    stp x29, x30, [sp, #-416]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x18, [sp, #48]
    stp d8, d9, [sp, #64]
    mov x19, x0
    mov x20, x1
    mov w9, #32
    str w9, [sp, #80]
    movz x9, #0x3cb0, lsl #48
    str x9, [sp, #88]
    add x0, sp, #128
    add x1, sp, #80
    bl md2asm_legendre_fourier_coefficients
    adrp x9, .Lgaussian_pi
    ldr d9, [x9, :lo12:.Lgaussian_pi]
    mov w21, #1
.Lgaussian_initial:
    lsl w9, w21, #2
    sub w9, w9, #1
    scvtf d0, w9
    fmul d8, d0, d9
    mov w9, #130
    scvtf d1, w9
    fdiv d8, d8, d1
    fmov d0, d8
    bl md2asm_gaussian_tangent
    movz x9, #0x40c0, lsl #48
    fmov d1, x9
    fmul d0, d0, d1
    fmov d1, #1.0
    fdiv d0, d1, d0
    fadd d0, d8, d0
    sub w9, w21, #1
    add x23, sp, #272
    str d0, [x23, x9, lsl #3]
    // Preserve the source's cosine scratch calculations; diagnostics are false.
    fmov d0, d8
    bl md2asm_cos_original_rounding
    sub w9, w21, #1
    ldr d0, [x23, x9, lsl #3]
    bl md2asm_cos_original_rounding
    add w21, w21, #1
    cmp w21, #16
    b.le .Lgaussian_initial
    mov w21, #16
.Lgaussian_refine:
    sub w22, w21, #1
    add x0, sp, #128
    add x1, sp, #272
    add x1, x1, x22, lsl #3
    add x2, x20, x22, lsl #3
    add x3, sp, #88
    add x4, sp, #80
    add x5, sp, #96
    add x6, sp, #104
    bl md2asm_refine_gaussian_latitude
    subs w21, w21, #1
    b.ne .Lgaussian_refine
    mov w21, #0
    add x23, sp, #272
.Lgaussian_sines:
    ldr d0, [x23, x21, lsl #3]
    bl md2asm_cos_original_rounding
    str d0, [x19, x21, lsl #3]
    add w21, w21, #1
    cmp w21, #16
    b.lo .Lgaussian_sines
    mov x9, #0
    mov x10, #31
.Lgaussian_mirror:
    ldr d0, [x19, x9, lsl #3]
    fneg d0, d0
    str d0, [x19, x10, lsl #3]
    ldr x11, [x20, x9, lsl #3]
    str x11, [x20, x10, lsl #3]
    add x9, x9, #1
    sub x10, x10, #1
    cmp x9, #16
    b.lo .Lgaussian_mirror
    mov w0, #0
    ldp d8, d9, [sp, #64]
    ldp x23, x18, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #416
    ret
.Lgaussian_invalid:
    mov w0, #1
    ret
.size md2asm_initialize_gaussian_latitudes,.-md2asm_initialize_gaussian_latitudes
.section .rodata
.balign 8
.Lgaussian_pi:
    .xword 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits

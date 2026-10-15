// Contract: skills/md2asm/references/openifs/setup/gaussian_grid_children.md.
// Calculate selected SULEG Fourier coefficients. Contract: skills/md2asm/references/openifs/setup/gaussian_grid_children.md.
// x0: caller-owned17 FP64 outputs; x1: address of int32 degree32.
.text
.p2align 4
.global md2asm_legendre_fourier_coefficients
.type md2asm_legendre_fourier_coefficients,%function
md2asm_legendre_fourier_coefficients:
    ldr w2, [x1]
    cmp w2, #32
    b.ne .Lcoefficient_unsupported
    fmov d0, #2.0
    fmov d1, #0.25
    fmov d2, #1.0
    mov w2, #1
.Lhighest_coefficient:
    mul w3, w2, w2
    scvtf d3, w3
    fdiv d3, d1, d3
    fsub d3, d2, d3
    fsqrt d3, d3
    fmul d0, d0, d3
    add w2, w2, #1
    cmp w2, #32
    b.le .Lhighest_coefficient
    str d0, [x0, #128]
    mov w2, #2
    mov x3, #15
.Llower_coefficient:
    sub w4, w2, #1
    mov w5, #66
    sub w5, w5, w2
    mul w4, w4, w5
    scvtf d1, w4
    fmul d0, d0, d1
    mov w5, #65
    sub w5, w5, w2
    mul w4, w2, w5
    scvtf d1, w4
    fdiv d0, d0, d1
    str d0, [x0, x3, lsl #3]
    sub x3, x3, #1
    add w2, w2, #2
    cmp w2, #32
    b.le .Llower_coefficient
    ret
.Lcoefficient_unsupported:
    b abort
.size md2asm_legendre_fourier_coefficients,.-md2asm_legendre_fourier_coefficients
.section .note.GNU-stack,"",%progbits

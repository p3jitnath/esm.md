// Contract: skills/md2asm/references/openifs/setup/legendre_newton_step.md.
// Direct selected CPLEDN step. Contract: skills/md2asm/references/openifs/setup/legendre_newton_step.md.
// Original eight-pointer ABI: degree, parity, coefficients, theta, flag,
// weight, new_theta, correction. Degree32, even parity, flag0/1 only.
.text
.p2align 4
.global md2asm_legendre_newton_step
.type md2asm_legendre_newton_step,%function
md2asm_legendre_newton_step:
    ldr w8, [x0]
    cmp w8, #32
    b.ne .Lnewton_unsupported
    ldr w8, [x1]
    cbnz w8, .Lnewton_unsupported
    ldr w8, [x4]
    cmp w8, #1
    b.hi .Lnewton_unsupported
    stp x29, x30, [sp, #-160]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp d8, d9, [sp, #96]
    stp d10, d11, [sp, #112]
    stp d12, d13, [sp, #128]
    str x18, [sp, #144]
    mov x21, x2
    mov w23, w8
    mov x24, x5
    mov x25, x6
    mov x26, x7
    ldr d10, [x3]
    ldr d8, [x21]
    fmov d0, #0.5
    fmul d8, d0, d8
    fmov d9, xzr
    mov w27, #2
    mov x28, #1
.Lnewton_fourier_term:
    ldr d11, [x21, x28, lsl #3]
    scvtf d13, w27
    fmul d12, d13, d10
    cbnz w23, .Lnewton_derivative
    fmov d0, d12
    bl md2asm_cos_original_rounding
    fmul d0, d11, d0
    fadd d8, d8, d0
.Lnewton_derivative:
    fmov d0, d12
    bl md2asm_sin_original_rounding
    fmul d1, d11, d13
    fmul d1, d1, d0
    fsub d9, d9, d1
    add w27, w27, #2
    add x28, x28, #1
    cmp w27, #32
    b.le .Lnewton_fourier_term
    cbnz w23, .Lnewton_weight
    fneg d0, d8
    fdiv d0, d0, d9
    fadd d1, d10, d0
    str d1, [x25]
    str d0, [x26]
    b .Lnewton_return
.Lnewton_weight:
    fmul d0, d9, d9
    mov w8, #65
    scvtf d1, w8
    fdiv d0, d1, d0
    str d0, [x24]
.Lnewton_return:
    ldr x18, [sp, #144]
    ldp d8, d9, [sp, #96]
    ldp d10, d11, [sp, #112]
    ldp d12, d13, [sp, #128]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #160
    ret
.Lnewton_unsupported:
    b abort
.size md2asm_legendre_newton_step,.-md2asm_legendre_newton_step
.section .note.GNU-stack,"",%progbits

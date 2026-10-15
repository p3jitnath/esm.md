// Contract: skills/md2asm/references/openifs/setup/gaussian_tangent.md.
/* Direct bounded GNU TAN math primitive for Gaussian initial angles.
 * Contract: skills/md2asm/references/openifs/setup/gaussian_tangent.md. Input/result d0, FPCR0.
 * Derived from GNU libc2.38 IBM Accurate Math Library.
 * Copyright (C) 2001-2023 Free Software Foundation, Inc.
 * LGPL-2.1-or-later; without warranty. Original source stays in tangent_source/.
 */
.include "src/openifs/setup/gaussian_tangent_literals.S"
.text
.p2align 4
.global md2asm_gaussian_tangent
.type md2asm_gaussian_tangent,%function
md2asm_gaussian_tangent:
    mrs x9, fpcr
    cbnz x9, .Ltan_unsupported
    movz x10, #0x3fb0, lsl #48
    fmov d1, x10
    fcmp d0, d1
    b.lo .Ltan_unsupported
    fmov d1, #1.5625
    fcmp d0, d1
    b.hi .Ltan_unsupported
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x18, [sp, #32]
    stp d8, d9, [sp, #48]
    stp d10, d11, [sp, #64]
    stp d12, d13, [sp, #80]
    stp d14, d15, [sp, #96]
    adrp x19, .Ltan_table
    add x19, x19, :lo12:.Ltan_table
    adrp x20, .Ltan_constants
    add x20, x20, :lo12:.Ltan_constants
    fmov d8, d0
    fmov d9, d0
    ldr d1, [x20, #TAN_g3]
    fcmp d9, d1
    b.hi .Ltan_reduce
    mov w21, #0
    fmov d10, xzr
    b .Ltan_table_value
.Ltan_reduce:
    // Rounded count of pi/2 turns is one over this supported interval.
    ldr d1, [x20, #TAN_hpinv]
    ldr d2, [x20, #TAN_toint]
    fmov d0, d8
    bl md2asm_round_product_sum_direct
    ldr d1, [x20, #TAN_toint]
    fsub d9, d0, d1
    fneg d0, d9
    ldr d1, [x20, #TAN_mp1]
    fmov d2, d8
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fneg d0, d9
    ldr d1, [x20, #TAN_mp2]
    fmov d2, d11
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    ldr d1, [x20, #TAN_mp3]
    fmul d10, d9, d1
    fsub d9, d11, d10
    fsub d11, d11, d9
    fsub d10, d11, d10
    fabs d11, d9
    ldr d1, [x20, #TAN_g2]
    fcmp d11, d1
    b.ls .Ltan_small_reduced
    fmov d9, d11
    fneg d10, d10
    mov w21, #1
.Ltan_table_value:
    movz x9, #0x4070, lsl #48
    fmov d0, x9
    fmov d1, d9
    ldr d2, [x20, #TAN_mfftnhf]
    bl md2asm_round_product_sum_direct
    fcvtzs w9, d0
    cmp w9, #185
    b.hi .Ltan_unsupported
    add x9, x19, x9, lsl #5
    ldr d0, [x9]
    ldp d13, d14, [x9, #8]
    fsub d11, d9, d0
    cbz w21, .Ltan_table_difference
    fadd d11, d11, d10
.Ltan_table_difference:
    fmul d12, d11, d11
    fmov d0, d12
    ldr d1, [x20, #TAN_e1]
    ldr d2, [x20, #TAN_e0]
    bl md2asm_round_product_sum_direct
    fmov d15, d0
    fmul d0, d11, d12
    fmov d1, d15
    fmov d2, d11
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fadd d15, d13, d14
    fmul d15, d11, d15
    cbnz w21, .Ltan_table_cotangent
    fsub d0, d14, d11
    fdiv d15, d15, d0
    fadd d0, d13, d15
    b .Ltan_return
.Ltan_table_cotangent:
    fadd d0, d13, d11
    fdiv d15, d15, d0
    fsub d0, d14, d15
    b .Ltan_return
.Ltan_small_reduced:
    // a=d9 and da=d10 retain the original signs of the reduced pair.
    fmul d12, d9, d9
    fmov d0, d12
    ldr d1, [x20, #TAN_d11]
    ldr d2, [x20, #TAN_d9]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmov d0, d12
    fmov d1, d11
    ldr d2, [x20, #TAN_d7]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmov d0, d12
    fmov d1, d11
    ldr d2, [x20, #TAN_d5]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmov d0, d12
    fmov d1, d11
    ldr d2, [x20, #TAN_d3]
    bl md2asm_round_product_sum_direct
    fmov d11, d0
    fmul d0, d9, d12
    fmov d1, d11
    fmov d2, d10
    bl md2asm_round_product_sum_direct
    fmov d10, d0
    // Exact addition: abs(a) exceeds abs(the polynomial correction).
    fadd d11, d9, d10
    fsub d12, d9, d11
    fadd d12, d12, d10
    // Double-length reciprocal of (b,db), using the accepted product remainder.
    fmov d0, #1.0
    fdiv d13, d0, d11
    fmul d14, d13, d11
    fmov d0, d13
    fmov d1, d11
    fneg d2, d14
    bl md2asm_round_product_sum_direct
    fmov d15, d0
    fmov d0, #1.0
    fsub d8, d0, d14
    fsub d8, d8, d15
    fmov d0, xzr
    fadd d8, d8, d0
    fneg d0, d13
    fmov d1, d12
    fmov d2, d8
    bl md2asm_round_product_sum_direct
    fdiv d8, d0, d11
    fadd d14, d13, d8
    fsub d15, d13, d14
    fadd d15, d15, d8
    fadd d0, d14, d15
    fneg d0, d0
.Ltan_return:
    ldp d8, d9, [sp, #48]
    ldp d10, d11, [sp, #64]
    ldp d12, d13, [sp, #80]
    ldp d14, d15, [sp, #96]
    ldp x21, x18, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.Ltan_unsupported:
    b abort
.size md2asm_gaussian_tangent,.-md2asm_gaussian_tangent
.section .note.GNU-stack,"",%progbits

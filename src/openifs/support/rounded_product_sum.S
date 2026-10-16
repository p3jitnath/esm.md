/* Exact one-rounding product and sum inside an atomic original math helper.
 * Input formulations/openifs/support/rounded_product_sum.md.
 * Contract skills/md2asm/references/openifs/support/rounded_product_sum.md.
 * Mathematical result is RN(a*b+c), including original Arm exception status.
 * This has fused-result semantics. It must not replace the weather solver's
 * separately rounded multiplication and addition.
 * Direct AArch64 integer arithmetic uses the compact child or general body.
 * Inputs use d0,d1,d2, result uses d0. All finite operands require FPCR zero.
 * Preserve x18, x19..x29, d8..d15, SP, FPCR and errno.
 * Generic frame is 1712 bytes; the compact call uses a separate 16-byte frame.
 */
.text
.p2align 4
.global md2asm_round_product_sum_direct
.type md2asm_round_product_sum_direct,%function
md2asm_round_product_sum_direct:
    mrs x9, fpcr
    cbnz x9, .Lproduct_sum_bad
    fmov x0, d0
    fmov x1, d1
    fmov x2, d2
    ubfx x3, x0, #52, #11
    ubfx x4, x1, #52, #11
    ubfx x5, x2, #52, #11
    cmp x3, #2047
    b.eq .Lproduct_sum_bad
    cmp x4, #2047
    b.eq .Lproduct_sum_bad
    cmp x5, #2047
    b.eq .Lproduct_sum_bad
    // Keep the original domain refusal ahead of the compact leaf.
    stp x29, x30, [sp, #-16]!
    bl md2asm_try_compact_product_sum
    ldp x29, x30, [sp], #16
    cbnz w0, .Lproduct_compact_fallback
    ret
.Lproduct_compact_fallback:
    // The leaf preserved operands and status, but its integer scratch is free.
    fmov x0, d0
    fmov x1, d1
    fmov x2, d2
    ubfx x3, x0, #52, #11
    ubfx x4, x1, #52, #11
    ubfx x5, x2, #52, #11
    sub sp, sp, #1712
    stp x19, x20, [sp]
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    stp x29, x30, [sp, #80]
    eor x22, x0, x1
    lsr x22, x22, #63
    lsr x23, x2, #63
    and x6, x0, #0xfffffffffffff
    and x7, x1, #0xfffffffffffff
    and x26, x2, #0xfffffffffffff
    cbz x3, .Lproduct_a_exponent
    orr x6, x6, #0x10000000000000
.Lproduct_a_exponent:
    cbz x4, .Lproduct_b_exponent
    orr x7, x7, #0x10000000000000
.Lproduct_b_exponent:
    cbz x5, .Lproduct_c_exponent
    orr x26, x26, #0x10000000000000
.Lproduct_c_exponent:
    cbz x6, .Lproduct_zero
    cbz x7, .Lproduct_zero
    mov x8, #1075
    sub x9, x3, x8
    sub x10, x4, x8
    sub x25, x5, x8
    mov x11, #-1074
    cmp x3, #0
    csel x9, x11, x9, eq
    cmp x4, #0
    csel x10, x11, x10, eq
    cmp x5, #0
    csel x25, x11, x25, eq
    add x24, x9, x10
    mul x27, x6, x7
    umulh x28, x6, x7
    add x19, sp, #96
    add x20, x19, #536
    add x21, x20, #536
    mov x0, x19
    mov x1, #201
.Lproduct_clear_arrays:
    str xzr, [x0], #8
    sub x1, x1, #1
    cbnz x1, .Lproduct_clear_arrays
    mov x0, x19
    mov x1, x27
    add x2, x24, #2148
    bl .Lproduct_insert_word
    mov x0, x19
    mov x1, x28
    add x2, x24, #2212
    bl .Lproduct_insert_word
    mov x0, x20
    mov x1, x26
    add x2, x25, #2148
    bl .Lproduct_insert_word
    cmp x22, x23
    b.ne .Lproduct_opposite_signs
    mov x27, x22
    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x5, #67
    adds xzr, xzr, xzr
.Lproduct_add_words:
    ldr x3, [x0], #8
    ldr x4, [x1], #8
    adcs x6, x3, x4
    str x6, [x2], #8
    sub x5, x5, #1
    cbnz x5, .Lproduct_add_words
    b.cs .Lproduct_sum_failed_frame
    b .Lproduct_find_top
.Lproduct_opposite_signs:
    mov x0, #66
.Lproduct_compare_words:
    ldr x1, [x19, x0, lsl #3]
    ldr x2, [x20, x0, lsl #3]
    cmp x1, x2
    b.hi .Lproduct_magnitude_larger
    b.lo .Lproduct_addend_larger
    sub x0, x0, #1
    tbz x0, #63, .Lproduct_compare_words
    mov x0, #0
    b .Lproduct_return_word
.Lproduct_magnitude_larger:
    mov x0, x19
    mov x1, x20
    mov x27, x22
    b .Lproduct_subtract_setup
.Lproduct_addend_larger:
    mov x0, x20
    mov x1, x19
    mov x27, x23
.Lproduct_subtract_setup:
    mov x2, x21
    mov x5, #67
    cmp xzr, xzr
.Lproduct_subtract_words:
    ldr x3, [x0], #8
    ldr x4, [x1], #8
    sbcs x6, x3, x4
    str x6, [x2], #8
    sub x5, x5, #1
    cbnz x5, .Lproduct_subtract_words
    b.cc .Lproduct_sum_failed_frame
.Lproduct_find_top:
    mov x0, #66
.Lproduct_top_word:
    ldr x1, [x21, x0, lsl #3]
    cbnz x1, .Lproduct_top_found
    sub x0, x0, #1
    tbz x0, #63, .Lproduct_top_word
    lsl x0, x27, #63
    b .Lproduct_return_word
.Lproduct_top_found:
    clz x2, x1
    mov x3, #63
    sub x3, x3, x2
    add x3, x3, x0, lsl #6
    sub x24, x3, #2148
    mov x4, #-1022
    cmp x24, x4
    cset x25, lt
    sub x28, x3, #52
    mov x4, #1074
    cmp x25, #0
    csel x28, x4, x28, ne
    lsr x0, x28, #6
    and x1, x28, #63
    ldr x2, [x21, x0, lsl #3]
    lsr x26, x2, x1
    cbz x1, .Lproduct_significand_ready
    add x0, x0, #1
    ldr x2, [x21, x0, lsl #3]
    mov x3, #64
    sub x3, x3, x1
    lsl x2, x2, x3
    orr x26, x26, x2
.Lproduct_significand_ready:
    mov x0, x21
    mov x1, x28
    bl .Lproduct_any_below
    mov x23, x0
    sub x0, x28, #1
    lsr x1, x0, #6
    and x0, x0, #63
    ldr x2, [x21, x1, lsl #3]
    lsr x2, x2, x0
    tbz x2, #0, .Lproduct_finish
    mov x0, x21
    sub x1, x28, #1
    bl .Lproduct_any_below
    cbnz x0, .Lproduct_round_up
    tbz x26, #0, .Lproduct_finish
.Lproduct_round_up:
    add x26, x26, #1
.Lproduct_finish:
    cbnz x25, .Lproduct_finish_subnormal
    mov x0, #0x20000000000000
    cmp x26, x0
    b.ne .Lproduct_normal_exponent
    lsr x26, x26, #1
    add x24, x24, #1
.Lproduct_normal_exponent:
    cmp x24, #1023
    b.gt .Lproduct_overflow
    add x0, x24, #1023
    lsl x0, x0, #52
    and x1, x26, #0xfffffffffffff
    orr x0, x0, x1
    orr x0, x0, x27, lsl #63
    lsl x1, x23, #4
    b .Lproduct_status_and_return
.Lproduct_finish_subnormal:
    orr x0, x26, x27, lsl #63
    mov x1, #24
    cmp x23, #0
    csel x1, x1, xzr, ne
    b .Lproduct_status_and_return
.Lproduct_overflow:
    mov x0, #0x7ff0000000000000
    orr x0, x0, x27, lsl #63
    mov x1, #20
.Lproduct_status_and_return:
    cbz x1, .Lproduct_return_word
    mrs x2, fpsr
    orr x2, x2, x1
    msr fpsr, x2
.Lproduct_return_word:
    fmov d0, x0
    ldp x29, x30, [sp, #80]
    ldp x27, x28, [sp, #64]
    ldp x25, x26, [sp, #48]
    ldp x23, x24, [sp, #32]
    ldp x21, x22, [sp, #16]
    ldp x19, x20, [sp]
    add sp, sp, #1712
    ret
.Lproduct_zero:
    cbz x26, .Lproduct_both_zero
    fmov x0, d2
    b .Lproduct_return_word
.Lproduct_both_zero:
    and x0, x22, x23
    lsl x0, x0, #63
    b .Lproduct_return_word
.Lproduct_sum_failed_frame:
    ldp x29, x30, [sp, #80]
    add sp, sp, #1712
    b abort
.Lproduct_insert_word:
    lsr x3, x2, #6
    and x4, x2, #63
    add x3, x0, x3, lsl #3
    lsl x5, x1, x4
    ldr x6, [x3]
    orr x6, x6, x5
    str x6, [x3]
    cbz x4, .Lproduct_insert_return
    mov x5, #64
    sub x5, x5, x4
    lsr x5, x1, x5
    ldr x6, [x3, #8]
    orr x6, x6, x5
    str x6, [x3, #8]
.Lproduct_insert_return:
    ret
.Lproduct_any_below:
    lsr x2, x1, #6
    and x3, x1, #63
    mov x4, #0
    mov x5, #0
    cbz x2, .Lproduct_any_partial
.Lproduct_any_words:
    ldr x6, [x0, x5, lsl #3]
    orr x4, x4, x6
    add x5, x5, #1
    cmp x5, x2
    b.lo .Lproduct_any_words
.Lproduct_any_partial:
    cbz x3, .Lproduct_any_result
    ldr x6, [x0, x2, lsl #3]
    mov x7, #1
    lsl x7, x7, x3
    sub x7, x7, #1
    and x6, x6, x7
    orr x4, x4, x6
.Lproduct_any_result:
    cmp x4, #0
    cset x0, ne
    ret
.Lproduct_sum_bad:
    b abort
.size md2asm_round_product_sum_direct,.-md2asm_round_product_sum_direct
.section .note.GNU-stack,"",%progbits

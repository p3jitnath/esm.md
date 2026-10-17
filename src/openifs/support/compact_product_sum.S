/* Define MD2ASM_PRODUCT_SUM_DEFERRED_STATUS only for POWER's private child.
 * Its success also returns w1=required flags 0, 16 or 20 without accessing FPSR.
 * The parent commits these flags before each observable boundary.
 * The ordinary public build retains immediate cumulative status.
 * On refusal, both builds return w1=0, 1 or 2 as described below. */
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
#define md2asm_try_compact_product_sum md2asm_private_compact_deferred
#define md2asm_try_compact_product_sum_preclassified md2asm_private_compact_deferred_preclassified
#endif
/* Exact product plus addend, rounded once to nearest-even FP64.
 * d0,d1,d2 are a,b,c. w0=0 returns the exact result in d0.
 * w0=1 leaves d0,d1,d2 and FPSR unchanged for the owned wide or general path.
 * For w0=1, w1=1 tags a wide addend, w1=2 a wide product and w1=0
 * every other refusal. The tagged state is read only by the hidden wide entry.
 * Only x0..x17, NZCV and, on success, d0 are changed. No stack or calls.
 * Preserve x18..x30, full v8..v15, SP, FPCR and errno.
 * Contract: skills/md2asm/references/openifs/support/compact_product_sum.md.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_try_compact_product_sum
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
.hidden md2asm_try_compact_product_sum
#endif
.type md2asm_try_compact_product_sum,%function
md2asm_try_compact_product_sum:
    mrs x17, fpcr
    cbnz x17, .Lcompact_fallback
    fmov x0, d0
    fmov x1, d1
    fmov x2, d2
    ubfx x3, x0, #52, #11
    ubfx x4, x1, #52, #11
    ubfx x5, x2, #52, #11
    cmp w3, #2047
    b.eq .Lcompact_fallback
    cmp w4, #2047
    b.eq .Lcompact_fallback
    cmp w5, #2047
    b.eq .Lcompact_fallback
.global md2asm_try_compact_product_sum_preclassified
.hidden md2asm_try_compact_product_sum_preclassified
.type md2asm_try_compact_product_sum_preclassified,%function
/* Private ABI: caller has checked finite operands and FPCR=0.
 * d0..d2 are unchanged, x0..x2 are their raw words, x3..x5 their stored exponents.
 * Share the public entry's numerical body, return rules and preserved registers.
 */
md2asm_try_compact_product_sum_preclassified:
    eor x9, x0, x1
    lsr x9, x9, #63
    lsr x10, x2, #63
    and x6, x0, #0xfffffffffffff
    and x7, x1, #0xfffffffffffff
    and x8, x2, #0xfffffffffffff
    // A nonzero finite stored exponent identifies a normal nonzero operand.
    cbz w3, .Lcompact_slow_decode
    orr x6, x6, #0x10000000000000
    cbz w4, .Lcompact_slow_decode
    orr x7, x7, #0x10000000000000
    cbz w5, .Lcompact_slow_decode
    orr x8, x8, #0x10000000000000
.Lcompact_exponents_ready:
    sub w13, w3, #1075
    sub w14, w4, #1075
    add w13, w13, w14
    sub w14, w5, #1075
    mul x11, x6, x7
    umulh x12, x6, x7
    cbz x8, .Lcompact_sum_ready
    // Align on the OLD unreduced common exponent, preserving its fast class.
    subs w15, w13, w14
    b.gt .Lcompact_shift_product
    neg w15, w15
    clz x16, x8
    mov w17, #64
    sub w16, w17, w16
    add w16, w16, w15
    cmp w16, #127
    b.gt .Lcompact_prepared_addend
    mov x7, #0
    cbz w15, .Lcompact_aligned
    tbnz w15, #6, .Lcompact_c_high
    neg w0, w15
    lsr x7, x8, x0
    lsl x8, x8, x15
    b .Lcompact_aligned
.Lcompact_c_high:
    lsl x7, x8, x15
    mov x8, #0
    b .Lcompact_aligned
.Lcompact_shift_product:
    cbz x12, .Lcompact_product_low_length
    clz x16, x12
    mov w17, #128
    sub w16, w17, w16
    b .Lcompact_product_length_ready
.Lcompact_product_low_length:
    clz x16, x11
    mov w17, #64
    sub w16, w17, w16
.Lcompact_product_length_ready:
    add w16, w16, w15
    cmp w16, #127
    b.gt .Lcompact_prepared_product
    mov w13, w14
    mov x7, #0
    tbnz w15, #6, .Lcompact_product_high
    neg w0, w15
    lsr x1, x11, x0
    lsl x12, x12, x15
    orr x12, x12, x1
    lsl x11, x11, x15
    b .Lcompact_aligned
.Lcompact_product_high:
    lsl x12, x11, x15
    mov x11, #0
.Lcompact_aligned:
    cmp w9, w10
    b.ne .Lcompact_opposite_signs
    adds x11, x11, x8
    adc x12, x12, x7
    b .Lcompact_sum_ready
.Lcompact_opposite_signs:
    cmp x12, x7
    b.hi .Lcompact_product_larger
    b.lo .Lcompact_addend_larger
    cmp x11, x8
    b.hi .Lcompact_product_larger
    b.lo .Lcompact_addend_larger
    mov x0, #0
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
    mov w6, #0
#endif
    b .Lcompact_success_bits
.Lcompact_product_larger:
    subs x11, x11, x8
    sbc x12, x12, x7
    b .Lcompact_sum_ready
.Lcompact_addend_larger:
    subs x11, x8, x11
    sbc x12, x7, x12
    mov w9, w10
.Lcompact_sum_ready:
    cbz x12, .Lcompact_sum_low
    clz x15, x12
    mov w16, #127
    sub w15, w16, w15
    b .Lcompact_highest_ready
.Lcompact_sum_low:
    clz x15, x11
    mov w16, #63
    sub w15, w16, w15
.Lcompact_highest_ready:
    add w13, w13, w15
    mov w16, #-1022
    cmp w13, w16
    b.lt .Lcompact_fallback
    cmp w13, #1023
    b.gt .Lcompact_overflow
    mov w6, #0
    subs w15, w15, #52
    b.gt .Lcompact_discard_bits
    neg w15, w15
    lsl x8, x11, x15
    b .Lcompact_encode
.Lcompact_discard_bits:
    cmp w15, #64
    b.hs .Lcompact_from_high_word
    lsr x8, x11, x15
    neg w0, w15
    lsl x1, x12, x0
    orr x8, x8, x1
    sub w0, w15, #1
    lsr x7, x11, x0
    and x7, x7, #1
    mov x1, #1
    lsl x1, x1, x0
    sub x1, x1, #1
    and x10, x11, x1
    b .Lcompact_round
.Lcompact_from_high_word:
    lsr x8, x12, x15
    b.eq .Lcompact_shift_64
    sub w0, w15, #65
    lsr x7, x12, x0
    and x7, x7, #1
    mov x1, #1
    lsl x1, x1, x0
    sub x1, x1, #1
    and x10, x12, x1
    orr x10, x10, x11
    b .Lcompact_round
.Lcompact_shift_64:
    lsr x7, x11, #63
    and x10, x11, #0x7fffffffffffffff
.Lcompact_round:
    orr x0, x7, x10
    cmp x0, #0
    cset w6, ne
    lsl w6, w6, #4
    cbz x7, .Lcompact_encode
    cbnz x10, .Lcompact_increment
    tbz x8, #0, .Lcompact_encode
.Lcompact_increment:
    add x8, x8, #1
    tbnz x8, #53, .Lcompact_round_carry
    b .Lcompact_encode
.Lcompact_round_carry:
    lsr x8, x8, #1
    add w13, w13, #1
    cmp w13, #1023
    b.gt .Lcompact_overflow
.Lcompact_encode:
    add w0, w13, #1023
    lsl x0, x0, #52
    and x8, x8, #0xfffffffffffff
    orr x0, x0, x8
    orr x0, x0, x9, lsl #63
    cbz w6, .Lcompact_success_bits
    b .Lcompact_add_status
.Lcompact_overflow:
    mov x0, #0x7ff0000000000000
    orr x0, x0, x9, lsl #63
    mov w6, #20
.Lcompact_add_status:
#ifndef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
    mrs x1, fpsr
    bic x2, x6, x1
    cbz x2, .Lcompact_success_bits
    orr x1, x1, x6
    msr fpsr, x1
#endif
.Lcompact_success_bits:
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
    mov w1, w6
#endif
    fmov d0, x0
    mov w0, #0
    ret
.Lcompact_zero_product:
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
    mov w6, #0
#endif
    cbz x8, .Lcompact_both_zero
    mov x0, x2
    b .Lcompact_success_bits
.Lcompact_both_zero:
    and x0, x9, x10
    lsl x0, x0, #63
    b .Lcompact_success_bits
.Lcompact_fallback:
    mov w1, #0
    mov w0, #1
    ret
/* Refusal tags retain raw product/exponents only at a proven wide class. */
.Lcompact_prepared_addend:
    mov w1, #1
    mov w0, #1
    ret
.Lcompact_prepared_product:
    mov w1, #2
    mov w0, #1
    ret
// Repeating a hidden-bit OR leaves a partially decoded normal input unchanged.
.Lcompact_slow_decode:
    cbz w3, .Lcompact_a_fraction
    orr x6, x6, #0x10000000000000
.Lcompact_a_fraction:
    cbz w4, .Lcompact_b_fraction
    orr x7, x7, #0x10000000000000
.Lcompact_b_fraction:
    cbz w5, .Lcompact_c_fraction
    orr x8, x8, #0x10000000000000
.Lcompact_c_fraction:
    cbz x6, .Lcompact_zero_product
    cbz x7, .Lcompact_zero_product
    cmp w3, #0
    cinc w3, w3, eq
    cmp w4, #0
    cinc w4, w4, eq
    cmp w5, #0
    cinc w5, w5, eq
    b .Lcompact_exponents_ready
.size md2asm_try_compact_product_sum,.-md2asm_try_compact_product_sum
.size md2asm_try_compact_product_sum_preclassified,.-md2asm_try_compact_product_sum_preclassified
.section .note.GNU-stack,"",%progbits

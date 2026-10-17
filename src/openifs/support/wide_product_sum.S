/* Define MD2ASM_PRODUCT_SUM_DEFERRED_STATUS only for POWER's private child.
 * Its success also returns w1=required flags 0, 16 or 20 without accessing FPSR.
 * The ordinary public build retains immediate cumulative status. */
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
#define md2asm_try_wide_product_sum md2asm_private_wide_deferred
#endif
/* Exact one-rounding product plus addend for the original wide operand class.
 * Input: formulations/openifs/support/rounded_product_sum.md.
 * Contract: skills/md2asm/references/openifs/support/wide_product_sum.md.
 * d0,d1,d2 are a,b,c. w0=0 returns the result in d0.
 * w0=1 keeps d0,d1,d2 and FPSR unchanged for general direct assembly.
 * Only x0..x17, NZCV and, on success, d0 are changed.
 * Preserve x18..x30, v8..v15, SP, FPCR and errno. No stack or calls.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_try_wide_product_sum
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
.hidden md2asm_try_wide_product_sum
#endif
.type md2asm_try_wide_product_sum,%function
md2asm_try_wide_product_sum:
    mrs x17, fpcr
    cbnz x17, .Lwide_fallback
    fmov x0, d0
    fmov x1, d1
    fmov x2, d2
    ubfx x3, x0, #52, #11
    ubfx x4, x1, #52, #11
    ubfx x5, x2, #52, #11
    cmp w3, #2047
    b.eq .Lwide_fallback
    cmp w4, #2047
    b.eq .Lwide_fallback
    cmp w5, #2047
    b.eq .Lwide_fallback
    eor x9, x0, x1
    lsr x9, x9, #63          // Product sign.
    lsr x10, x2, #63
    eor w10, w9, w10        // One when the two exact terms have opposite signs.
    and x6, x0, #0xfffffffffffff
    and x7, x1, #0xfffffffffffff
    and x8, x2, #0xfffffffffffff
    cbz w3, .Lwide_a_fraction
    orr x6, x6, #0x10000000000000
.Lwide_a_fraction:
    cbz w4, .Lwide_b_fraction
    orr x7, x7, #0x10000000000000
.Lwide_b_fraction:
    cbz w5, .Lwide_c_fraction
    orr x8, x8, #0x10000000000000
.Lwide_c_fraction:
    cbz x6, .Lwide_fallback
    cbz x7, .Lwide_fallback
    cbz x8, .Lwide_fallback
    cmp w3, #0
    cinc w3, w3, eq
    cmp w4, #0
    cinc w4, w4, eq
    cmp w5, #0
    cinc w5, w5, eq
    sub w13, w3, #1075
    sub w14, w4, #1075
    add w13, w13, w14        // Exact product exponent Ep.
    sub w14, w5, #1075       // Exact addend exponent Ec.
    mul x11, x6, x7
    umulh x12, x6, x7
    subs w15, w13, w14
    b.gt .Lwide_product_class
    // The addend alone can exceed 127 bits on the original common scale.
    clz x16, x8
    mov w17, #64
    sub w16, w17, w16
    neg w15, w15
    add w0, w16, w15
    cmp w0, #127
    b.le .Lwide_fallback
    // Make x12:x11 dominant, x7:x8 smaller, with their exact exponents.
    mov x0, x11
    mov x1, x12
    mov x11, x8
    mov x12, xzr
    mov x8, x0
    mov x7, x1
    mov w0, w13
    mov w13, w14
    mov w14, w0
    eor w9, w9, w10          // Dominant addend sign.
    b .Lwide_normalize_dominant
.Lwide_product_class:
    cbz x12, .Lwide_product_low_length
    clz x16, x12
    mov w17, #128
    sub w16, w17, w16
    b .Lwide_product_length_ready
.Lwide_product_low_length:
    clz x16, x11
    mov w17, #64
    sub w16, w17, w16
.Lwide_product_length_ready:
    add w0, w16, w15
    cmp w0, #127
    b.le .Lwide_fallback
    mov x7, xzr             // Smaller addend has one raw integer word.
.Lwide_normalize_dominant:
    // Left shift 21..126 places the dominant leading bit at 126 exactly.
    mov w15, #127
    sub w15, w15, w16
    sub w13, w13, w15       // Common unit exponent S.
    tbnz w15, #6, .Lwide_dominant_high_shift
    neg w0, w15
    lsr x1, x11, x0
    lsl x12, x12, x15
    orr x12, x12, x1
    lsl x11, x11, x15
    b .Lwide_align_smaller
.Lwide_dominant_high_shift:
    // Shift 64..126 implies the original dominant high word was zero.
    lsl x12, x11, x15       // Modulo-64 count is exactly shift minus 64.
    mov x11, xzr
.Lwide_align_smaller:
    mov w6, #0              // Nonzero fractional-tail flag j.
    // Original-WIDE admission proves S minus smaller exponent is positive.
    sub w14, w13, w14       // Right shift k equals wide aligned length minus 127.
    cmp w14, #128
    b.ge .Lwide_smaller_all_fraction
    cmp w14, #64
    b.eq .Lwide_smaller_right_64
    b.gt .Lwide_smaller_right_high
    // Right shift 1..63. Only removed low-word bits contribute to j.
    neg w0, w14
    lsl x1, x8, x0
    cmp x1, #0
    cset w6, ne
    lsr x1, x8, x14
    lsl x2, x7, x0
    orr x8, x1, x2
    lsr x7, x7, x14
    b .Lwide_combine
.Lwide_smaller_right_64:
    cmp x8, #0
    cset w6, ne
    mov x8, x7
    mov x7, xzr
    b .Lwide_combine
.Lwide_smaller_right_high:
    // Right shift 65..127. Remove the low word and part of the high word.
    neg w0, w14
    lsl x1, x7, x0
    orr x1, x1, x8
    cmp x1, #0
    cset w6, ne
    lsr x8, x7, x14
    mov x7, xzr
    b .Lwide_combine
.Lwide_smaller_all_fraction:
    // Both exact terms were admitted nonzero, so all removed is inexact.
    mov x8, xzr
    mov x7, xzr
    mov w6, #1
.Lwide_combine:
    cbnz w10, .Lwide_subtract
    adds x11, x11, x8
    adc x12, x12, x7
    b .Lwide_highest_ready
.Lwide_subtract:
    subs x11, x11, x8
    sbc x12, x12, x7
    // For j=1 the exact smaller term is q+f, so floor(A-q-f)=A-q-1.
    subs x11, x11, x6
    sbc x12, x12, xzr
.Lwide_highest_ready:
    clz x15, x12
    mov w16, #127
    sub w15, w16, w15       // Highest bit h is 125, 126 or 127.
    add w13, w13, w15       // Exact leading-bit exponent e=S+h.
    mov w16, #-1022
    cmp w13, w16
    b.lt .Lwide_fallback
    cmp w13, #1023
    b.gt .Lwide_overflow
    // Rounding removes 73..75 bits, or 9..11 bits from the high word.
    sub w15, w15, #116      // h-52-64.
    lsr x8, x12, x15        // Retained 53-bit integer.
    sub w0, w15, #1
    lsr x1, x12, x0
    and x1, x1, #1          // Guard bit.
    neg w0, w0
    lsl x2, x12, x0
    orr x2, x2, x11
    orr x2, x2, x6          // Every lower integer bit and the fractional tail.
    orr x3, x1, x2
    cmp x3, #0
    cset w6, ne
    lsl w6, w6, #4          // Inexact flag, if required.
    cbz x1, .Lwide_encode
    cbnz x2, .Lwide_round_up
    tbz x8, #0, .Lwide_encode
.Lwide_round_up:
    add x8, x8, #1
    tbz x8, #53, .Lwide_encode
    lsr x8, x8, #1
    add w13, w13, #1
    cmp w13, #1023
    b.gt .Lwide_overflow
.Lwide_encode:
    and x8, x8, #0xfffffffffffff
    add w13, w13, #1023
    orr x0, x8, x13, lsl #52
    orr x0, x0, x9, lsl #63
    cbz w6, .Lwide_success
    b .Lwide_add_status
.Lwide_overflow:
    mov x0, #0x7ff0000000000000
    orr x0, x0, x9, lsl #63
    mov w6, #20             // Overflow and inexact.
.Lwide_add_status:
#ifndef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
    mrs x1, fpsr
    bic x2, x6, x1
    cbz x2, .Lwide_success
    orr x1, x1, x6
    msr fpsr, x1
#endif
.Lwide_success:
#ifdef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
    mov w1, w6
#endif
    fmov d0, x0
    mov w0, #0
    ret
.Lwide_fallback:
    mov w0, #1
    ret
.size md2asm_try_wide_product_sum,.-md2asm_try_wide_product_sum
.section .note.GNU-stack,"",%progbits

/* Longwave coupling coefficients from physics P01.
 * Physics is formulations/openifs/physics/two_stream_gammas_lw.md.
 * Contract is skills/md2asm/references/openifs/physics/calc_two_stream_gammas_lw.md.
 * x0 points to INTEGER4 count, x1..x4 to four rank-one descriptors.
 * Descriptor byte 0 is the first cell, byte 40 the signed element stride.
 * Each reached cell is aligned FP64. Disjoint outputs. Separate rounding.
 * This leaf preserves descriptors and all callee-saved registers. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_two_stream_gammas_lw
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w8,[x0]
    cmp w8,#0
    b.le .Llw_gamma_done
    ldr x9,[x1,#40]
    ldr x10,[x2,#40]
    ldr x11,[x3,#40]
    ldr x12,[x4,#40]
    mov x13,#1
    cmp x9,#0
    csel x9,x9,x13,ne
    cmp x10,#0
    csel x10,x10,x13,ne
    cmp x11,#0
    csel x11,x11,x13,ne
    cmp x12,#0
    csel x12,x12,x13,ne
    lsl x9,x9,#3
    lsl x10,x10,#3
    lsl x11,x11,#3
    lsl x12,x12,#3
    ldr x1,[x1]
    ldr x2,[x2]
    ldr x3,[x3]
    ldr x4,[x4]
    ldr d4,.Llw_gamma_half
    ldr d5,.Llw_gamma_factor
    fmov d6,#1.0
.Llw_gamma_point:
    ldr d0,[x1]
    ldr d1,[x2]
    fmul d0,d4,d0
    fadd d2,d6,d1
    fmul d2,d0,d2
    fsub d2,d5,d2
    fsub d1,d6,d1
    fmul d1,d0,d1
    str d2,[x3]
    str d1,[x4]
    add x1,x1,x9
    add x2,x2,x10
    add x3,x3,x11
    add x4,x4,x12
    subs w8,w8,#1
    b.ne .Llw_gamma_point
.Llw_gamma_done:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Llw_gamma_half:
    .double 0.83
.Llw_gamma_factor:
    .double 1.66
.section .note.GNU-stack,"",%progbits

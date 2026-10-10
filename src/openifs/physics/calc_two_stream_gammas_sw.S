/* Shortwave coupling coefficients from physics P01.
 * Physics input is formulations/openifs/physics/two_stream_gammas_sw.md.
 * Contract is skills/md2asm/references/openifs/physics/calc_two_stream_gammas_sw.md.
 * x0 points to INTEGER4 count, x1 to FP64 mu, x2..x6 to array descriptors.
 * Descriptor byte 0 is the first cell and byte 40 the signed element stride.
 * All cells are aligned FP64. Outputs are disjoint. Each operation rounds.
 * This leaf uses caller-saved registers only and preserves descriptor bytes. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_two_stream_gammas_sw
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w8,[x0]
    cmp w8,#0
    b.le .Lsw_gamma_done
    ldr d7,[x1]
    ldr x9,[x2,#40]
    ldr x10,[x3,#40]
    ldr x11,[x4,#40]
    ldr x12,[x5,#40]
    ldr x13,[x6,#40]
    mov x14,#1
    cmp x9,#0
    csel x9,x9,x14,ne
    cmp x10,#0
    csel x10,x10,x14,ne
    cmp x11,#0
    csel x11,x11,x14,ne
    cmp x12,#0
    csel x12,x12,x14,ne
    cmp x13,#0
    csel x13,x13,x14,ne
    lsl x9,x9,#3
    lsl x10,x10,#3
    lsl x11,x11,#3
    lsl x12,x12,#3
    lsl x13,x13,#3
    ldr x2,[x2]
    ldr x3,[x3]
    ldr x4,[x4]
    ldr x5,[x5]
    ldr x6,[x6]
    fmov d4,#0.75
    fmov d5,#1.25
    fmov d6,#2.0
    fmov d16,#0.5
.Lsw_gamma_point:
    ldr d0,[x3]
    ldr d1,[x2]
    fmul d0,d0,d4
    fadd d2,d5,d0
    fmul d2,d1,d2
    fsub d2,d6,d2
    fsub d3,d4,d0
    fmul d3,d1,d3
    fmul d0,d7,d0
    fsub d0,d16,d0
    str d2,[x4]
    str d3,[x5]
    str d0,[x6]
    add x2,x2,x9
    add x3,x3,x10
    add x4,x4,x11
    add x5,x5,x12
    add x6,x6,x13
    subs w8,w8,#1
    b.ne .Lsw_gamma_point
.Lsw_gamma_done:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

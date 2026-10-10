/* Complete longwave layer transmission and emission without scattering.
 * Physics is formulations/openifs/physics/no_scattering_longwave.md.
 * Contract is skills/md2asm/references/openifs/physics/calc_no_scattering_transmittance_lw.md.
 * x0 count, x1 depth, x2 top source, x3 bottom source, x4 transmission,
 * x5 upward emission, x6 downward emission. Disjoint aligned FP64 arrays.
 * The default-real source threshold keeps its promoted FP32 bits.
 * Each operation rounds separately, with the accepted shared EXP route. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_no_scattering_transmittance_lw
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w9,[x0]
    cmp w9,#0
    b.le .Llw_clear_empty
    sub sp,sp,#128
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x29,x30,[sp,#64]
    stp d8,d9,[sp,#80]
    stp d10,d11,[sp,#96]
    mov x19,#0
    lsl x20,x9,#3
    mov x21,x1
    mov x22,x2
    mov x23,x3
    mov x24,x4
    mov x25,x5
    mov x26,x6
    ldr d11,.Llw_clear_diffusivity
.Llw_clear_point:
    ldr d8,[x21,x19]
    ldr d9,[x22,x19]
    ldr d10,[x23,x19]
    ldr d0,.Llw_clear_threshold
    fcmp d8,d0
    fmul d8,d11,d8
    b.gt .Llw_clear_thick
    fmov d0,#1.0
    fsub d0,d0,d8
    fmov d1,#0.5
    fmul d1,d8,d1
    fadd d2,d9,d10
    fmul d1,d1,d2
    str d0,[x24,x19]
    str d1,[x25,x19]
    str d1,[x26,x19]
    b .Llw_clear_next
.Llw_clear_thick:
    fneg d0,d8
    bl exp
    fsub d1,d10,d9
    fdiv d1,d1,d8
    fadd d2,d1,d9
    fadd d3,d1,d10
    fmul d3,d0,d3
    fsub d2,d2,d3
    fsub d3,d9,d1
    fsub d4,d10,d1
    fmul d3,d0,d3
    fsub d3,d4,d3
    str d0,[x24,x19]
    str d2,[x25,x19]
    str d3,[x26,x19]
.Llw_clear_next:
    add x19,x19,#8
    cmp x19,x20
    b.ne .Llw_clear_point
    ldp d8,d9,[sp,#80]
    ldp d10,d11,[sp,#96]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x29,x30,[sp,#64]
    add sp,sp,#128
.Llw_clear_empty:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Llw_clear_threshold:
    .quad 0x3f50624de0000000
.Llw_clear_diffusivity:
    .double 1.66
.section .note.GNU-stack,"",%progbits

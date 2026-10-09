/* Complete Fu shortwave ice optics, from the frozen source equations.
 * Seven address arguments: nb, GNU rank-two coefficients, ice water path,
 * radius, total depth, scattering depth and asymmetry. No stack arguments.
 * The three complete stages preserve each ordered FP64 rounding point. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_ice_optics_fu_MOD_calc_ice_optics_fu_sw
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w8,[x0]
    ldr d4,[x3]
    adrp x11,.Lice_sw_constants
    add x11,x11,:lo12:.Lice_sw_constants
    ldr d0,[x11]
    fmul d0,d4,d0                 // Diameter in micrometres.
    fmov d3,#1.0
    fdiv d1,d3,d0                 // Exact rounded inverse diameter.
    ldr d4,[x2]
    ldr d2,[x11,#8]
    fmul d2,d4,d2                 // Ice water path in g per square metre.
    cmp w8,#0
    b.le .Lice_sw_done
    ldr x7,[x1]
    ldr x9,[x1,#40]
    ldr x10,[x1,#64]
    lsl x9,x9,#3
    lsl x10,x10,#3
    mov x11,x7
    mov x15,x4
    mov w12,w8
.Lice_sw_total:
    add x13,x11,x10
    ldr d4,[x13]
    ldr d5,[x11]
    fmul d4,d4,d1
    fadd d4,d5,d4
    fmul d4,d2,d4
    str d4,[x15],#8
    add x11,x11,x9
    subs w12,w12,#1
    b.ne .Lice_sw_total
    mov x11,x7
    mov x15,x4
    mov x16,x5
    mov w12,w8
.Lice_sw_scattering:
    add x13,x11,x10,lsl #2
    add x13,x13,x10              // Coefficient six.
    ldr d4,[x13]
    sub x13,x13,x10
    ldr d5,[x13]
    fmul d4,d0,d4
    fadd d4,d5,d4
    sub x13,x13,x10
    ldr d5,[x13]
    fmul d4,d0,d4
    fadd d4,d5,d4
    sub x13,x13,x10
    ldr d5,[x13]
    fmul d4,d0,d4
    fadd d4,d5,d4
    fsub d4,d3,d4
    ldr d5,[x15],#8
    fmul d4,d5,d4
    str d4,[x16],#8
    add x11,x11,x9
    subs w12,w12,#1
    b.ne .Lice_sw_scattering
    mov x11,x7
    mov x15,x6
    mov w12,w8
.Lice_sw_asymmetry:
    add x13,x11,x10,lsl #3
    add x13,x13,x10              // Coefficient ten.
    ldr d4,[x13]
    sub x13,x13,x10
    ldr d5,[x13]
    fmul d4,d0,d4
    fadd d4,d5,d4
    sub x13,x13,x10
    ldr d5,[x13]
    fmul d4,d0,d4
    fadd d4,d5,d4
    sub x13,x13,x10
    ldr d5,[x13]
    fmul d4,d0,d4
    fadd d4,d5,d4
    fcmp d4,d3
    fcsel d4,d4,d3,le
    str d4,[x15],#8
    add x11,x11,x9
    subs w12,w12,#1
    b.ne .Lice_sw_asymmetry
.Lice_sw_done:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lice_sw_constants:
    .quad 0x41377e0e79041148
    .quad 0x408f400000000000
.section .note.GNU-stack,"",%progbits

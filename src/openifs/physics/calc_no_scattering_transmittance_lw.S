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
    sub x9,x20,x19
    cmp x9,#32
    b.lo .Llw_clear_scalar_point
    add x9,x21,x19
    ldp x10,x11,[x9]
    ldp x12,x13,[x9,#16]
    ldr x14,.Llw_clear_threshold
    mov x15,#0x4070000000000000
.macro CLEAR_FOUR_DEPTH raw
    cmp \raw,x14
    b.ls .Llw_clear_scalar_point
    cmp \raw,x15
    b.hs .Llw_clear_scalar_point
.endm
    CLEAR_FOUR_DEPTH x10
    CLEAR_FOUR_DEPTH x11
    CLEAR_FOUR_DEPTH x12
    CLEAR_FOUR_DEPTH x13
    ldp q8,q24,[x9]
    add x9,x22,x19
    ldp q9,q25,[x9]
    add x9,x23,x19
    ldp q10,q26,[x9]
    dup v2.2d,v11.d[0]
    fmul v8.2d,v2.2d,v8.2d
    fmul v24.2d,v2.2d,v24.2d
    fneg v0.2d,v8.2d
    fneg v1.2d,v24.2d
    bl md2asm_try_exp_four_counted
    cbnz w0,.Llw_clear_scalar_point
    fsub v2.2d,v10.2d,v9.2d
    fsub v27.2d,v26.2d,v25.2d
    fdiv v2.2d,v2.2d,v8.2d
    fdiv v27.2d,v27.2d,v24.2d
    fadd v3.2d,v2.2d,v9.2d
    fadd v28.2d,v27.2d,v25.2d
    fadd v4.2d,v2.2d,v10.2d
    fadd v29.2d,v27.2d,v26.2d
    fmul v4.2d,v0.2d,v4.2d
    fmul v29.2d,v1.2d,v29.2d
    fsub v3.2d,v3.2d,v4.2d
    fsub v28.2d,v28.2d,v29.2d
    fsub v4.2d,v9.2d,v2.2d
    fsub v29.2d,v25.2d,v27.2d
    fsub v5.2d,v10.2d,v2.2d
    fsub v30.2d,v26.2d,v27.2d
    fmul v4.2d,v0.2d,v4.2d
    fmul v29.2d,v1.2d,v29.2d
    fsub v4.2d,v5.2d,v4.2d
    fsub v29.2d,v30.2d,v29.2d
    str q0,[x24,x19]
    str q3,[x25,x19]
    str q4,[x26,x19]
    add x9,x19,#16
    str q1,[x24,x9]
    str q28,[x25,x9]
    str q29,[x26,x9]
    add x19,x19,#32
    cmp x19,x20
    b.ne .Llw_clear_point
    b .Llw_clear_restore
.Llw_clear_scalar_point:
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
 .Llw_clear_restore:
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

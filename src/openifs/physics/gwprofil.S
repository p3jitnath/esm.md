/* Gravity-wave stress from formulations/openifs/physics/gravity_wave_stress_profile.md.
 * The ordered update and 21-address ABI are in
 * skills/md2asm/references/openifs/physics/gwprofil.md.
 * Each column keeps the original descending recurrence and rounded operations. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL gwprofil_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
.macro ARG reg,number
    ldr \reg,[sp,#(96+8*\number)]
.endm
.macro GET reg,number,index
    ARG x9,\number
    ldr \reg,[x9,\index]
.endm
.macro PUT reg,number,index
    ARG x9,\number
    str \reg,[x9,\index]
.endm
ORIGINAL_SYMBOL:
    mov x17,sp
    sub sp,sp,#272
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x10,sp,#160
    mov x11,#13
.Lgwprofil_copy_arguments:
    ldr x12,[x17],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Lgwprofil_copy_arguments

    ARG x9,0
    ldr w0,[x9,#4]
    ARG x10,1
    ldr d7,[x10,#24]
    ldr d16,[x10,#48]
    ldr d17,[x10,#56]
    cbz w0,.Lgwprofil_nonlinear_drag
    ldr d6,[x9,#96]
    b .Lgwprofil_constants
.Lgwprofil_nonlinear_drag:
    ldr d6,[x10,#32]
.Lgwprofil_constants:
    fmov d18,#1.0
    fmov d19,#2.0
    fmov d20,#4.0
    ARG x9,2
    ldrsw x19,[x9]
    sub x19,x19,#1
    ARG x9,3
    ldrsw x20,[x9]
    ARG x9,4
    ldrsw x21,[x9]
    lsl x21,x21,#3
    ARG x9,5
    ldrsw x22,[x9]
    lsl x28,x19,#3
    cmp x19,x20
    b.ge .Lgwprofil_return
.Lgwprofil_column:
    lsr x10,x28,#1
    GET w0,6,x10
    cbz w0,.Lgwprofil_next_column
    GET w27,7,x10
    GET w25,8,x10
    GET w26,9,x10
    GET w24,11,x10

    GET d0,19,x28
    GET d1,18,x28
    fmul d5,d0,d1
    fdiv d5,d5,d20
    GET d0,20,x28
    fmax d0,d0,d18
    fdiv d5,d5,d0
    mul x12,x22,x21
    add x12,x12,x28
    GET d4,17,x12

    mov x23,x22
.Lgwprofil_level:
    sub x12,x23,#1
    mul x12,x12,x21
    add x12,x12,x28
    add x13,x12,x21
    cmp x23,x24
    b.ge .Lgwprofil_blocked
    GET d0,13,x12
    fmul d21,d6,d0
    GET d24,14,x12
    fsqrt d0,d24
    fmul d21,d21,d0
    GET d25,15,x12
    fmul d21,d21,d25
    fmul d21,d21,d5
    GET d28,17,x13
    fmax d0,d21,d16
    fdiv d22,d28,d0
    fcmp d28,d17
    b.lt .Lgwprofil_critical
    cmp x23,x25
    b.le .Lgwprofil_critical

    /* Evaluate the wave Richardson number with separate rounding points. */
    GET d26,16,x12
    fsqrt d23,d26
    fmul d0,d24,d22
    fsqrt d0,d0
    fdiv d0,d0,d25
    fmul d1,d0,d23
    fadd d1,d18,d1
    fmul d1,d1,d1
    fsub d0,d18,d0
    fmul d0,d26,d0
    fdiv d0,d0,d1
    fcmp d0,d7
    b.ge .Lgwprofil_stable

    /* The critical displacement solves the wave-breaking quadratic. */
    fdiv d30,d20,d23
    fdiv d30,d30,d7
    fmul d0,d7,d7
    fdiv d0,d18,d0
    fadd d30,d30,d0
    fdiv d0,d20,d7
    fadd d30,d30,d0
    fdiv d31,d18,d7
    fdiv d0,d19,d23
    fadd d31,d31,d0
    fneg d31,d31
    fsqrt d0,d30
    fadd d29,d31,d0
    fmov d3,#0.5
    fmul d29,d3,d29
    fmul d0,d25,d29
    fmul d0,d0,d0
    fdiv d0,d0,d24
    fmul d27,d21,d0
    b .Lgwprofil_limit
.Lgwprofil_stable:
    fmul d27,d21,d22
.Lgwprofil_limit:
    fmin d27,d27,d28
    PUT d27,17,x12
    b .Lgwprofil_next_level
.Lgwprofil_critical:
    fmov d0,xzr
    PUT d0,17,x12
    b .Lgwprofil_next_level
.Lgwprofil_blocked:
    PUT d4,17,x12
.Lgwprofil_next_level:
    sub x23,x23,#1
    cmp x23,#2
    b.ge .Lgwprofil_level

    /* Save both endpoints before pressure interpolation changes interior cells. */
    add x23,x27,#1
    cmp x23,x26
    b.ge .Lgwprofil_next_column
    sub x12,x26,#1
    mul x12,x12,x21
    add x12,x12,x28
    GET d27,17,x12
    GET d29,12,x12
    sub x13,x27,#1
    mul x13,x13,x21
    add x13,x13,x28
    GET d28,17,x13
    GET d30,12,x13
    fsub d30,d30,d29
    fsub d31,d28,d27
.Lgwprofil_interpolate:
    sub x12,x23,#1
    mul x12,x12,x21
    add x12,x12,x28
    GET d0,12,x12
    fsub d0,d0,d29
    fmul d0,d31,d0
    fdiv d0,d0,d30
    fadd d0,d27,d0
    PUT d0,17,x12
    add x23,x23,#1
    cmp x23,x26
    b.lt .Lgwprofil_interpolate
.Lgwprofil_next_column:
    add x19,x19,#1
    add x28,x28,#8
    cmp x19,x20
    b.lt .Lgwprofil_column
.Lgwprofil_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#272
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

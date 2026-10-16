/* Local scalar schedule candidate for the unchanged layer equations P01 and P02.
 * Physics is formulations/openifs/physics/two_stream_shortwave_transport.md.
 * Contract is skills/md2asm/references/openifs/physics/calc_reflectance_transmittance_sw.md.
 * x0 count, x1 mu, x2..x6 input arrays, x7 diffuse reflection.
 * Four remaining output pointers are at entry sp+0, +8, +16 and +24.
 * Arrays are disjoint aligned FP64, with count cells. Separate rounding.
 * The shared EXP route has an explicitly recorded accuracy and FP contract. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_reflectance_transmittance_sw
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w9,[x0]
    cmp w9,#0
    b.le .Lsw_rt_empty
    sub sp,sp,#256
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,#0
    lsl x20,x9,#3
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    mov x26,x7
    ldr x27,[sp,#256]
    ldr x28,[sp,#264]
    ldr x9,[sp,#272]
    str x9,[sp,#160]
    ldr x9,[sp,#280]
    str x9,[sp,#168]
    ldr d0,[x1]
    str d0,[sp,#176]
.Lsw_rt_point:
    ldr d8,[sp,#176]
    ldr d9,[x23,x19]
    ldr d10,[x24,x19]
    ldr d11,[x25,x19]
    ldr d13,[x21,x19]
    fmov d0,#1.0
    fsub d1,d0,d11
    str d1,[sp,#184]
    // Start the independent square root before both coupling sums.
    fsub d2,d9,d10
    fadd d3,d9,d10
    fmul d2,d2,d3
    ldr d3,.Lsw_rt_floor
    fmaxnm d2,d2,d3
    fsqrt d12,d2
    fmul d2,d9,d1
    fmul d3,d10,d11
    fadd d14,d2,d3
    fmul d2,d9,d11
    fmul d3,d10,d1
    fadd d15,d2,d3
    fmul d2,d12,d8
    fsub d2,d0,d2
    fabs d2,d2
    ldr d3,.Lsw_rt_threshold
    fcmp d2,d3
    b.ge .Lsw_rt_angle_ready
    ldr d3,.Lsw_rt_adjustment
    fmul d8,d8,d3
.Lsw_rt_angle_ready:
    // Independent products cover part of the division wait.
    fdiv d0,d13,d8
    fmul d2,d12,d8
    str d2,[sp,#192]
    fmul d2,d12,d11
    str d2,[sp,#200]
    ldr d1,[sp,#184]
    fmul d2,d12,d1
    str d2,[sp,#208]
    fmov d1,xzr
    fmaxnm d0,d0,d1
    fneg d0,d0
    bl exp
    str d0,[sp,#216]
    ldr x9,[sp,#168]
    str d0,[x9,x19]
    fmul d0,d12,d13
    fneg d0,d0
    bl exp
    // EXP is finished for this cell, so caller registers keep rounded values.
    fmul d16,d0,d0
    fmov d17,#2.0
    fmul d17,d17,d12
    fmul d17,d17,d0
    ldp d18,d19,[sp,#192]
    ldr d20,[sp,#208]
    ldr d21,[sp,#184]
    ldr d22,[sp,#216]
    fadd d3,d12,d9
    fsub d4,d12,d9
    fmul d4,d4,d16
    fadd d3,d3,d4
    fmov d5,#1.0
    fdiv d3,d5,d3
    // Prepare independent factors while the reciprocal is in progress.
    fmul d7,d18,d18
    fsub d7,d5,d7
    ldr d0,[x22,x19]
    fmul d0,d8,d0
    fsub d1,d5,d18
    fadd d2,d5,d18
    fsub d6,d5,d16
    fmul d6,d10,d6
    fmul d4,d6,d3
    str d4,[x26,x19]
    fmul d4,d17,d3
    str d4,[x27,x19]
    fmul d0,d0,d3
    fdiv d0,d0,d7
    fadd d4,d15,d19
    fmul d4,d1,d4
    fsub d3,d15,d19
    fmul d3,d2,d3
    fmul d3,d3,d16
    fsub d4,d4,d3
    fmul d3,d15,d8
    fsub d3,d11,d3
    fmul d3,d17,d3
    fmul d3,d3,d22
    fsub d4,d4,d3
    fmul d4,d0,d4
    fmov d3,xzr
    fminnm d4,d4,d5
    fmaxnm d4,d4,d3
    str d4,[x28,x19]
    fmul d3,d14,d8
    fadd d3,d21,d3
    fmul d3,d17,d3
    fadd d7,d14,d20
    fmul d7,d2,d7
    fsub d6,d14,d20
    fmul d6,d1,d6
    fmul d6,d6,d16
    fsub d7,d7,d6
    fmul d7,d22,d7
    fsub d3,d3,d7
    fmul d3,d0,d3
    fsub d5,d5,d4
    fminnm d3,d3,d5
    fmov d1,xzr
    fmaxnm d3,d3,d1
    ldr x9,[sp,#160]
    str d3,[x9,x19]
    add x19,x19,#8
    cmp x19,x20
    b.ne .Lsw_rt_point
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#256
.Lsw_rt_empty:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Lsw_rt_floor:
    .double 1.0e-12
.Lsw_rt_threshold:
    .double 2.220446049250313080847263336181640625e-13
.Lsw_rt_adjustment:
    .double 0.9999999999997779553950749686919152736663818359375
.section .note.GNU-stack,"",%progbits

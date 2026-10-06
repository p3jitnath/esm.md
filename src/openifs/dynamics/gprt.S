/* GPRT computes the thermal pressure term and both horizontal derivatives.
 * FP64 inputs and outputs use Fortran order and the GNU 12.3 Arm interface.
 * See skills/md2asm/references/openifs/dynamics/gprt.md for units and bounds.
 * Each product and sum has a separate rounding point. No fused arithmetic.
 * Independent columns use NEON pairs, followed by an in-bounds scalar tail.
 * All required arrays are read-only except the three separate outputs. */
.text
.p2align 4
.global gprt_
.type gprt_,%function
gprt_:
    ldr w4,[x4]
    cbz w4,.Lreturn
    ldr w1,[x1]
    ldr w2,[x2]
    ldr w3,[x3]
    sub w3,w3,w2
    adds w3,w3,#1
    ble .Lreturn
    ldr w0,[x0]
    stp x19,x20,[sp,#-80]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    ldp x19,x20,[sp,#80]
    ldp x21,x22,[sp,#96]
    ldp x23,x24,[sp,#112]
    ldp x25,x26,[sp,#128]
    ldp x27,x28,[sp,#144]
    sub w2,w2,#1
    sxtw x8,w2
    lsl x8,x8,#3
    sxtw x1,w1
    lsl x1,x1,#3
    sxtw x3,w3
    ldr d16,[x5]
    dup v16.2d,v16.d[0]
    cbnz w0,.Lselect_virtual
    cbnz x27,.Lselect_explicit
    ldr d17,[x6]
    fsub d17,d17,d16
    dup v17.2d,v17.d[0]
    adr x12,.Lmoist_level
    b .Lnext_level
.Lselect_virtual:
    adr x12,.Lvirtual_level
    b .Lnext_level
.Lselect_explicit:
    adr x12,.Lexplicit_level
.Lnext_level:
    mov x9,x8
    mov x10,x3
    br x12
.Lvirtual_level:
    cmp x10,#2
    b.lt .Lvirtual_tail
.Lvirtual_pair:
    ldr q0,[x7,x9]
    ldr q1,[x19,x9]
    ldr q2,[x20,x9]
    ldr q3,[x21,x9]
    fmul v4.2d,v0.2d,v1.2d
    fmul v5.2d,v16.2d,v2.2d
    fmul v6.2d,v16.2d,v3.2d
    str q4,[x24,x9]
    str q5,[x25,x9]
    str q6,[x26,x9]
    add x9,x9,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lvirtual_pair
.Lvirtual_tail:
    cbz x10,.Lend_level
    ldr d0,[x7,x9]
    ldr d1,[x19,x9]
    ldr d2,[x20,x9]
    ldr d3,[x21,x9]
    fmul d4,d0,d1
    fmul d5,d16,d2
    fmul d6,d16,d3
    str d4,[x24,x9]
    str d5,[x25,x9]
    str d6,[x26,x9]
    b .Lend_level
.Lexplicit_level:
    cmp x10,#2
    b.lt .Lexplicit_tail
.Lexplicit_pair:
    ldr q0,[x7,x9]
    ldr q1,[x19,x9]
    ldr q2,[x20,x9]
    ldr q3,[x21,x9]
    fmul v4.2d,v0.2d,v1.2d
    ldr q5,[x27,x9]
    ldr q6,[x28,x9]
    fmul v5.2d,v5.2d,v1.2d
    fmul v6.2d,v6.2d,v1.2d
    fmul v2.2d,v0.2d,v2.2d
    fmul v3.2d,v0.2d,v3.2d
    fadd v5.2d,v5.2d,v2.2d
    fadd v6.2d,v6.2d,v3.2d
    str q4,[x24,x9]
    str q5,[x25,x9]
    str q6,[x26,x9]
    add x9,x9,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lexplicit_pair
.Lexplicit_tail:
    cbz x10,.Lend_level
    ldr d0,[x7,x9]
    ldr d1,[x19,x9]
    ldr d2,[x20,x9]
    ldr d3,[x21,x9]
    fmul d4,d0,d1
    ldr d5,[x27,x9]
    ldr d6,[x28,x9]
    fmul d5,d5,d1
    fmul d6,d6,d1
    fmul d2,d0,d2
    fmul d3,d0,d3
    fadd d5,d5,d2
    fadd d6,d6,d3
    str d4,[x24,x9]
    str d5,[x25,x9]
    str d6,[x26,x9]
    b .Lend_level
.Lmoist_level:
    cmp x10,#2
    b.lt .Lmoist_tail
.Lmoist_pair:
    ldr q0,[x7,x9]
    ldr q1,[x19,x9]
    ldr q2,[x20,x9]
    ldr q3,[x21,x9]
    fmul v4.2d,v0.2d,v1.2d
    ldr q5,[x22,x9]
    ldr q6,[x23,x9]
    fmul v7.2d,v17.2d,v1.2d
    fmul v5.2d,v7.2d,v5.2d
    fmul v6.2d,v7.2d,v6.2d
    fmul v2.2d,v0.2d,v2.2d
    fmul v3.2d,v0.2d,v3.2d
    fadd v5.2d,v5.2d,v2.2d
    fadd v6.2d,v6.2d,v3.2d
    str q4,[x24,x9]
    str q5,[x25,x9]
    str q6,[x26,x9]
    add x9,x9,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lmoist_pair
.Lmoist_tail:
    cbz x10,.Lend_level
    ldr d0,[x7,x9]
    ldr d1,[x19,x9]
    ldr d2,[x20,x9]
    ldr d3,[x21,x9]
    fmul d4,d0,d1
    ldr d5,[x22,x9]
    ldr d6,[x23,x9]
    fmul d7,d17,d1
    fmul d5,d7,d5
    fmul d6,d7,d6
    fmul d2,d0,d2
    fmul d3,d0,d3
    fadd d5,d5,d2
    fadd d6,d6,d3
    str d4,[x24,x9]
    str d5,[x25,x9]
    str d6,[x26,x9]
    b .Lend_level
.Lend_level:
    add x8,x8,x1
    subs w4,w4,#1
    b.ne .Lnext_level
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x19,x20,[sp],#80
.Lreturn:
    ret
.size gprt_,.-gprt_
.section .note.GNU-stack,"",%progbits

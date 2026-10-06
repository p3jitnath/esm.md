/* Complete GPADDSLPHY physics increments from its frozen md2asm contract.
 * Multiplication and addition round separately in FP64.
 * Output levels include unchanged leading and trailing boundary storage.
 * Descriptor order preserves repeated additions to one tracer field. */
.text
.p2align 4
.global gpaddslphy_
.type gpaddslphy_,%function
gpaddslphy_:
    ldr w8,[x3]
    cbnz w8,.Lfirst_step
    stp x19,x20,[sp,#-80]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    ldp x19,x20,[sp,#80]
    ldp x21,x22,[sp,#96]
    ldr x23,[sp,#112]
    mov x24,x1
    mov x25,x2
    ldrsw x1,[x0,#5144]
    ldrsw x28,[x0,#5224]
    cbz x28,.Lreturn
    ldrsw x26,[x4]
    ldrsw x27,[x5]
    sub x27,x27,x26
    adds x27,x27,#1
    ble .Lreturn
    sub x26,x26,#1
    lsl x26,x26,#3
    ldrsw x3,[x0,#5244]
    ldrsw x4,[x0,#5248]
    sub x4,x4,x3
    add x4,x4,#1
    lsl x1,x1,#3
    mul x11,x1,x28
    mul x4,x4,x1
    neg x3,x3
    add x3,x3,#1
    madd x3,x3,x1,x26
    ldr d16,[x6]
    dup v16.2d,v16.d[0]
    ldrsw x0,[x24,#344]
    sub x0,x0,#1
    madd x13,x0,x11,x7
    ldrsw x0,[x24,#348]
    sub x0,x0,#1
    madd x14,x0,x11,x7
    ldrsw x0,[x24,#352]
    sub x0,x0,#1
    madd x15,x0,x11,x7
    mov x2,x28
    mov x8,x26
    mov x9,x3
.Lwind_level:
    mov x10,x8
    mov x12,x9
    mov x0,x27
    cmp x0,#2
    b.lt .Lwind_tail
.Lwind_pair:
    ldr q0,[x13,x10]
    ldr q1,[x20,x12]
    ldr q2,[x14,x10]
    ldr q3,[x21,x12]
    ldr q4,[x15,x10]
    ldr q5,[x22,x12]
    fmul v0.2d,v0.2d,v16.2d
    fmul v2.2d,v2.2d,v16.2d
    fmul v4.2d,v4.2d,v16.2d
    fadd v1.2d,v1.2d,v0.2d
    fadd v3.2d,v3.2d,v2.2d
    fadd v5.2d,v5.2d,v4.2d
    str q1,[x20,x12]
    str q3,[x21,x12]
    str q5,[x22,x12]
    add x10,x10,#16
    add x12,x12,#16
    sub x0,x0,#2
    cmp x0,#2
    b.ge .Lwind_pair
.Lwind_tail:
    cbz x0,.Lwind_end
    ldr d0,[x13,x10]
    ldr d1,[x20,x12]
    ldr d2,[x14,x10]
    ldr d3,[x21,x12]
    ldr d4,[x15,x10]
    ldr d5,[x22,x12]
    fmul d0,d0,d16
    fmul d2,d2,d16
    fmul d4,d4,d16
    fadd d1,d1,d0
    fadd d3,d3,d2
    fadd d5,d5,d4
    str d1,[x20,x12]
    str d3,[x21,x12]
    str d5,[x22,x12]
.Lwind_end:
    add x8,x8,x1
    add x9,x9,x1
    subs x2,x2,#1
    b.ne .Lwind_level
    ldrsw x6,[x25]
    cbz x6,.Lreturn
    add x25,x25,#3848
.Ldescriptor:
    ldr w0,[x25,#100]
    cbz w0,.Ldescriptor_end
    ldrsw x0,[x25,#204]
    sub x0,x0,#1
    madd x13,x0,x11,x19
    madd x14,x0,x4,x23
    mov x2,x28
    mov x8,x26
    mov x9,x3
.Ltracer_level:
    mov x10,x8
    mov x12,x9
    mov x0,x27
    cmp x0,#2
    b.lt .Ltracer_tail
.Ltracer_pair:
    ldr q0,[x13,x10]
    ldr q1,[x14,x12]
    fmul v0.2d,v0.2d,v16.2d
    fadd v1.2d,v1.2d,v0.2d
    str q1,[x14,x12]
    add x10,x10,#16
    add x12,x12,#16
    sub x0,x0,#2
    cmp x0,#2
    b.ge .Ltracer_pair
.Ltracer_tail:
    cbz x0,.Ltracer_end
    ldr d0,[x13,x10]
    ldr d1,[x14,x12]
    fmul d0,d0,d16
    fadd d1,d1,d0
    str d1,[x14,x12]
.Ltracer_end:
    add x8,x8,x1
    add x9,x9,x1
    subs x2,x2,#1
    b.ne .Ltracer_level
.Ldescriptor_end:
    add x25,x25,#368
    subs x6,x6,#1
    b.ne .Ldescriptor
.Lreturn:
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x19,x20,[sp],#80
.Lfirst_step:
    ret
.size gpaddslphy_,.-gpaddslphy_
.section .note.GNU-stack,"",%progbits

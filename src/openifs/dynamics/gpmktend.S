/* Complete GPMKTEND state-change rates from the frozen md2asm contract.
 * Wind, temperature and tracer outputs keep their own physical units per s.
 * The reciprocal, subtraction and multiplication round separately in FP64.
 * Descriptor traversal and repeated output mappings retain the source order.
 * GNU 12.3 object offsets were measured by independent storage-only probes. */
.text
.p2align 4
.global gpmktend_
.type gpmktend_,%function
gpmktend_:
    stp x19,x20,[sp,#-80]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    ldp x19,x20,[sp,#80]
    ldp x21,x22,[sp,#96]
    ldp x23,x24,[sp,#112]
    mov x25,x1
    ldrsw x1,[x0,#5144]
    ldrsw x28,[x0,#5224]
    cbz x28,.Lreturn
    ldr w2,[x2]
    ldr w3,[x3]
    sub w3,w3,w2
    adds w3,w3,#1
    ble .Lreturn
    sxtw x27,w3
    sub w2,w2,#1
    sxtw x26,w2
    lsl x26,x26,#3
    lsl x1,x1,#3
    mul x11,x1,x28
    fmov d16,#1.0
    ldr d17,[x4]
    fdiv d16,d16,d17
    dup v16.2d,v16.d[0]
    mov x2,x28
    mov x8,x26
.Lwind_level:
    mov x9,x8
    mov x10,x27
    cmp x10,#2
    b.lt .Lwind_tail
.Lwind_pair:
    ldr q0,[x5,x9]
    ldr q1,[x20,x9]
    ldr q2,[x6,x9]
    ldr q3,[x21,x9]
    ldr q4,[x7,x9]
    ldr q5,[x22,x9]
    fsub v0.2d,v0.2d,v1.2d
    fsub v2.2d,v2.2d,v3.2d
    fsub v4.2d,v4.2d,v5.2d
    fmul v0.2d,v0.2d,v16.2d
    fmul v2.2d,v2.2d,v16.2d
    fmul v4.2d,v4.2d,v16.2d
    str q0,[x5,x9]
    str q2,[x6,x9]
    str q4,[x7,x9]
    add x9,x9,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lwind_pair
.Lwind_tail:
    cbz x10,.Lwind_end
    ldr d0,[x5,x9]
    ldr d1,[x20,x9]
    ldr d2,[x6,x9]
    ldr d3,[x21,x9]
    ldr d4,[x7,x9]
    ldr d5,[x22,x9]
    fsub d0,d0,d1
    fsub d2,d2,d3
    fsub d4,d4,d5
    fmul d0,d0,d16
    fmul d2,d2,d16
    fmul d4,d4,d16
    str d0,[x5,x9]
    str d2,[x6,x9]
    str d4,[x7,x9]
.Lwind_end:
    add x8,x8,x1
    subs x2,x2,#1
    b.ne .Lwind_level
    ldrsw x4,[x25]
    cbz x4,.Lreturn
    add x25,x25,#3848
.Ldescriptor:
    ldr w0,[x25,#92]
    cbz w0,.Ldescriptor_end
    ldr w0,[x25,#188]
    sub w0,w0,#1
    sxtw x0,w0
    madd x13,x0,x11,x19
    madd x15,x0,x11,x24
    ldr w0,[x25,#184]
    sub w0,w0,#1
    sxtw x0,w0
    madd x14,x0,x11,x23
    mov x2,x28
    mov x8,x26
.Ltracer_level:
    mov x9,x8
    mov x10,x27
    cmp x10,#2
    b.lt .Ltracer_tail
.Ltracer_pair:
    ldr q0,[x13,x9]
    ldr q1,[x14,x9]
    fsub v0.2d,v0.2d,v1.2d
    fmul v0.2d,v0.2d,v16.2d
    str q0,[x13,x9]
    str q0,[x15,x9]
    add x9,x9,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Ltracer_pair
.Ltracer_tail:
    cbz x10,.Ltracer_end
    ldr d0,[x13,x9]
    ldr d1,[x14,x9]
    fsub d0,d0,d1
    fmul d0,d0,d16
    str d0,[x13,x9]
    str d0,[x15,x9]
.Ltracer_end:
    add x8,x8,x1
    subs x2,x2,#1
    b.ne .Ltracer_level
.Ldescriptor_end:
    add x25,x25,#368
    subs x4,x4,#1
    b.ne .Ldescriptor
.Lreturn:
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x19,x20,[sp],#80
    ret
.size gpmktend_,.-gpmktend_
.section .note.GNU-stack,"",%progbits

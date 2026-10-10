/* Find the complete local field range around each selected departure point.
 * Inputs use the original eleven-pointer ABI. All integer values are 32 bit.
 * Field values and bounds are FP64 and have the same physical units.
 * x0 holds the source plane pitch in bytes. x11 holds one index-plane pitch.
 * The eight loads follow the original operand order. No numerical helper
 * supplies a selection. Every inactive destination byte remains unchanged. */
.text
.p2align 4
.global laminmaxint_md2asm
.type laminmaxint_md2asm,%function
laminmaxint_md2asm:
    ldr w0,[x0]
    ldr w1,[x1]
    ldr w2,[x2]
    ldr w3,[x3]
    ldr w4,[x4]
    cmp w3,w2
    b.lt .Ldone
    cbz w4,.Ldone
    sub w2,w2,#1
    sub w13,w3,w2
    mul x11,x1,x4
    lsl x11,x11,#2
    add x7,x7,x11
    add x7,x7,x2,lsl #2
    ldp x8,x9,[sp]
    ldr x10,[sp,#16]
    lsl x0,x0,#3
    add x8,x8,x0
    add x9,x9,x2,lsl #3
    cbz x10,.Lmin_start
    add x10,x10,x2,lsl #3
.Lmin_start:
    sub x16,x1,x13
    lsl x17,x16,#3
    lsl x16,x16,#2
.Llevel:
    mov x12,x13
.Lcell:
    ldrsw x14,[x7]
    ldrsw x15,[x7,x11]
    add x7,x7,#4
    add x14,x8,x14,lsl #3
    add x15,x8,x15,lsl #3
    ldp d0,d1,[x14]
    ldp d2,d3,[x15]
    add x14,x14,x0
    add x15,x15,x0
    ldp d4,d5,[x14]
    ldp d6,d7,[x15]
    fmin d16,d0,d1
    fmin d16,d16,d2
    fmin d16,d16,d3
    fmin d16,d16,d4
    fmin d16,d16,d5
    fmin d16,d16,d6
    fmin d16,d16,d7
    str d16,[x9],#8
    cbz x10,.Lmin_only
    fmax d17,d0,d1
    fmax d17,d17,d2
    fmax d17,d17,d3
    fmax d17,d17,d4
    fmax d17,d17,d5
    fmax d17,d17,d6
    fmax d17,d17,d7
    str d17,[x10],#8
.Lmin_only:
    subs x12,x12,#1
    b.ne .Lcell
    add x7,x7,x16
    add x9,x9,x17
    cbz x10,.Lnext_level
    add x10,x10,x17
.Lnext_level:
    subs w4,w4,#1
    b.ne .Llevel
.Ldone:
    ret
.size laminmaxint_md2asm,.-laminmaxint_md2asm
.section .note.GNU-stack,"",%progbits

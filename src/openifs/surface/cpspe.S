/*
 * CPSPE surface advancement, contract revision 1.0.
 * Arguments are the 56 upstream by-address arguments. The first eight
 * pointers arrive in x0-x7, and the remaining pointers start at entry sp.
 * Integers are 32-bit, states and tendencies are FP64 in column order.
 * Buffers are disjoint, 8-byte aligned and sized as the contract requires.
 * Only active columns change. Zero trailing extents are never accessed.
 * This leaf uses caller-saved registers, leaves sp and x18 unchanged,
 * preserves x19-x29 and v8-v15, and needs no scratch storage.
 * Equation P01 uses a separately rounded multiply followed by an add.
 * Directly emitted from the Markdown contract, without compiler assembly.
 */
.text
.p2align 4
.global cpspe_
.type cpspe_, %function
cpspe_:
    ldr w0, [x0]
    ldr w1, [x1]
    ldr w2, [x2]
    ldr w3, [x3]
    ldr w4, [x4]
    ldr w5, [x5]
    ldr w6, [x6]
    ldr w7, [x7]
    ldr x8, [sp]
    ldr w8, [x8]
    ldr x9, [sp, #8]
    ldr d0, [x9]
    dup v0.2d, v0.d[0]
    sub w1, w1, #1
    sub w2, w2, w1
    cmp w2, #0
    b.le .Lreturn
    lsl x0, x0, #3
    lsl x1, x1, #3
    mov x10, #0
    adrp x17, .Lshapes
    add x17, x17, :lo12:.Lshapes
.Lfield:
    ldrb w13, [x17, x10]
    cmp w13, #1
    b.eq .Lsoil
    cmp w13, #2
    b.eq .Lsnow
    cmp w13, #3
    b.eq .Lextra
    cmp w13, #4
    b.eq .Lextra2
    cmp w13, #5
    b.eq .Locean
    mov x13, #1
    b .Lshape
.Lsoil:
    mov x13, x3
    b .Lshape
.Lsnow:
    mov x13, x6
    b .Lshape
.Lextra:
    mul x13, x4, x7
    b .Lshape
.Lextra2:
    mov x13, x8
    b .Lshape
.Locean:
    mov x13, x5
.Lshape:
    cbz x13, .Lnext
    add x11, sp, #16
    ldr x11, [x11, x10, lsl #3]
    add x12, sp, #200
    ldr x12, [x12, x10, lsl #3]
.Lplane:
    mov x14, x1
    mov x15, x2
.Lpair:
    cmp x15, #2
    b.lt .Ltail
    ldr q1, [x11, x14]
    ldr q2, [x12, x14]
    fmul v1.2d, v0.2d, v1.2d
    fadd v2.2d, v2.2d, v1.2d
    str q2, [x12, x14]
    add x14, x14, #16
    sub x15, x15, #2
    b .Lpair
.Ltail:
    cbz x15, .Lplane_done
    ldr d1, [x11, x14]
    ldr d2, [x12, x14]
    fmul d1, d0, d1
    fadd d2, d2, d1
    str d2, [x12, x14]
.Lplane_done:
    add x11, x11, x0
    add x12, x12, x0
    subs x13, x13, #1
    b.ne .Lplane
.Lnext:
    add x10, x10, #1
    cmp x10, #23
    b.lt .Lfield
.Lreturn:
    ret
.size cpspe_, .-cpspe_
.section .rodata
.Lshapes:
    .byte 1,0,1,1,0,2,2,2,2,2,0,0,0,0,0,0,0,3,4,5,5,5,5
.section .note.GNU-stack,"",%progbits

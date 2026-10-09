/* Direct AArch64 from strict_matrix.md revision 1.
 * A(i,c) * B(r,c), then the rounded sum in increasing c.
 * GNU DGEMM argument ABI; private, scoped N,T,+1,+0 operation.
 */
.text
.p2align 4
.global verdisint_strict_nt_fp64_
.hidden verdisint_strict_nt_fp64_
.type verdisint_strict_nt_fp64_, %function
verdisint_strict_nt_fp64_:
    mrs x17, fpcr
    cbnz x17, .Lmatrix_bad
    ldrb w16, [x0]
    cmp w16, #'N'
    b.ne .Lmatrix_bad
    ldrb w16, [x1]
    cmp w16, #'T'
    b.ne .Lmatrix_bad
    ldr x16, [sp, #40]
    cmp x16, #1
    b.ne .Lmatrix_bad
    ldr x16, [sp, #48]
    cmp x16, #1
    b.ne .Lmatrix_bad
    ldr x16, [x5]
    mov x17, #0x3ff0000000000000
    cmp x16, x17
    b.ne .Lmatrix_bad
    ldr x16, [sp, #16]
    ldr x16, [x16]
    cbnz x16, .Lmatrix_bad
    ldr w2, [x2]
    ldr w3, [x3]
    ldr w4, [x4]
    tbnz w2, #31, .Lmatrix_bad
    tbnz w3, #31, .Lmatrix_bad
    tbnz w4, #31, .Lmatrix_bad
    ldr w7, [x7]
    ldr x8, [sp]
    ldr x9, [sp, #8]
    ldr w9, [x9]
    ldr x11, [sp, #24]
    ldr x12, [sp, #32]
    ldr w12, [x12]
    mov w16, #1
    cmp w2, #1
    csel w17, w2, w16, ge
    cmp w7, w17
    b.lt .Lmatrix_bad
    cmp w12, w17
    b.lt .Lmatrix_bad
    cmp w3, #1
    csel w17, w3, w16, ge
    cmp w9, w17
    b.lt .Lmatrix_bad
    cbz w2, .Lmatrix_done
    cbz w3, .Lmatrix_done
    tst x11, #7
    b.ne .Lmatrix_bad
    cbz w4, .Lmatrix_addresses
    tst x6, #7
    b.ne .Lmatrix_bad
    tst x8, #7
    b.ne .Lmatrix_bad
.Lmatrix_addresses:
    lsl x7, x7, #3
    lsl x9, x9, #3
    lsl x12, x12, #3
    mov x0, x11
    mov x1, x8
    mov w14, w3
    /* Independent points share one coefficient without changing their sums. */
    cmp w2, #8
    b.lt .Lmatrix_row
.Lmatrix_vector_row:
    mov x5, x6
    mov x10, x0
    mov w13, w2
.Lmatrix_vector_block:
    cmp w13, #8
    b.lt .Lmatrix_vector_tail
    movi v0.16b, #0
    movi v1.16b, #0
    movi v2.16b, #0
    movi v3.16b, #0
    mov x15, x5
    mov x16, x1
    mov w17, w4
    cbz w17, .Lmatrix_vector_store
.Lmatrix_vector_column:
    ld1r {v16.2d}, [x16]
    ldp q4, q5, [x15, #0]
    ldp q6, q7, [x15, #32]
    fmul v4.2d, v4.2d, v16.2d
    fmul v5.2d, v5.2d, v16.2d
    fmul v6.2d, v6.2d, v16.2d
    fmul v7.2d, v7.2d, v16.2d
    fadd v0.2d, v0.2d, v4.2d
    fadd v1.2d, v1.2d, v5.2d
    fadd v2.2d, v2.2d, v6.2d
    fadd v3.2d, v3.2d, v7.2d
    add x15, x15, x7
    add x16, x16, x9
    subs w17, w17, #1
    b.ne .Lmatrix_vector_column
.Lmatrix_vector_store:
    stp q0, q1, [x10, #0]
    stp q2, q3, [x10, #32]
    add x5, x5, #64
    add x10, x10, #64
    sub w13, w13, #8
    b .Lmatrix_vector_block
.Lmatrix_vector_tail:
    cmp w13, #2
    b.lt .Lmatrix_vector_scalar
    movi v0.16b, #0
    mov x15, x5
    mov x16, x1
    mov w17, w4
    cbz w17, .Lmatrix_pair_store
.Lmatrix_pair_column:
    ldr q4, [x15]
    ld1r {v16.2d}, [x16]
    fmul v4.2d, v4.2d, v16.2d
    fadd v0.2d, v0.2d, v4.2d
    add x15, x15, x7
    add x16, x16, x9
    subs w17, w17, #1
    b.ne .Lmatrix_pair_column
.Lmatrix_pair_store:
    str q0, [x10]
    add x5, x5, #16
    add x10, x10, #16
    sub w13, w13, #2
    b .Lmatrix_vector_tail
.Lmatrix_vector_scalar:
    cbz w13, .Lmatrix_vector_next_row
    fmov d0, xzr
    mov x15, x5
    mov x16, x1
    mov w17, w4
    cbz w17, .Lmatrix_scalar_store
.Lmatrix_scalar_column:
    ldr d1, [x15]
    ldr d2, [x16]
    fmul d1, d1, d2
    fadd d0, d0, d1
    add x15, x15, x7
    add x16, x16, x9
    subs w17, w17, #1
    b.ne .Lmatrix_scalar_column
.Lmatrix_scalar_store:
    str d0, [x10]
.Lmatrix_vector_next_row:
    add x1, x1, #8
    add x0, x0, x12
    subs w14, w14, #1
    b.ne .Lmatrix_vector_row
    ret
.Lmatrix_row:
    mov x5, x6
    mov x10, x0
    mov w13, w2
.Lmatrix_point:
    fmov d0, xzr
    mov x15, x5
    mov x16, x1
    mov w17, w4
    cbz w17, .Lmatrix_store
.Lmatrix_column:
    ldr d1, [x15]
    ldr d2, [x16]
    fmul d1, d1, d2
    fadd d0, d0, d1
    add x15, x15, x7
    add x16, x16, x9
    subs w17, w17, #1
    b.ne .Lmatrix_column
.Lmatrix_store:
    str d0, [x10]
    add x5, x5, #8
    add x10, x10, #8
    subs w13, w13, #1
    b.ne .Lmatrix_point
    add x1, x1, #8
    add x0, x0, x12
    subs w14, w14, #1
    b.ne .Lmatrix_row
.Lmatrix_done:
    ret
.Lmatrix_bad:
    stp x29, x30, [sp, #-16]!
    adrp x0, .Lmatrix_message
    add x0, x0, :lo12:.Lmatrix_message
    mov x1, .Lmatrix_message_end-.Lmatrix_message
    bl abor1_
    brk #0
.size verdisint_strict_nt_fp64_, .-verdisint_strict_nt_fp64_
.section .rodata
.Lmatrix_message:
    .ascii "STRICT VERTICAL MATRIX: UNSUPPORTED CONTRACT"
.Lmatrix_message_end:
.section .note.GNU-stack,"",%progbits

.text
.p2align 4
.global matrix_compute_probe
.type matrix_compute_probe,%function
matrix_compute_probe:
    movi v0.16b, #0
    movi v1.16b, #0
    movi v2.16b, #0
    movi v3.16b, #0
    movi v4.16b, #0
    movi v5.16b, #0
    movi v6.16b, #0
    movi v7.16b, #0
    fmov d24, #0.5
    dup v24.2d, v24.d[0]
    cbz x0, .Lcompute_store
.Lcompute_loop:
    fmul v16.2d, v24.2d, v24.2d
    fmul v17.2d, v24.2d, v24.2d
    fmul v18.2d, v24.2d, v24.2d
    fmul v19.2d, v24.2d, v24.2d
    fmul v20.2d, v24.2d, v24.2d
    fmul v21.2d, v24.2d, v24.2d
    fmul v22.2d, v24.2d, v24.2d
    fmul v23.2d, v24.2d, v24.2d
    fadd v0.2d, v0.2d, v16.2d
    fadd v1.2d, v1.2d, v17.2d
    fadd v2.2d, v2.2d, v18.2d
    fadd v3.2d, v3.2d, v19.2d
    fadd v4.2d, v4.2d, v20.2d
    fadd v5.2d, v5.2d, v21.2d
    fadd v6.2d, v6.2d, v22.2d
    fadd v7.2d, v7.2d, v23.2d
    subs x0, x0, #1
    b.ne .Lcompute_loop
.Lcompute_store:
    stp q0, q1, [x1, #0]
    stp q2, q3, [x1, #32]
    stp q4, q5, [x1, #64]
    stp q6, q7, [x1, #96]
    ret
.size matrix_compute_probe,.-matrix_compute_probe
.p2align 4
.global matrix_copy_probe
.type matrix_copy_probe,%function
matrix_copy_probe:
    cbz x0, .Lcopy_done
    mov x4, x1
    mov x5, x2
.Lcopy_pass:
    mov x1, x4
    mov x2, x5
    mov x6, x3
.Lcopy_block:
    ldp q0, q1, [x1, #0]
    ldp q2, q3, [x1, #32]
    ldp q4, q5, [x1, #64]
    ldp q6, q7, [x1, #96]
    stp q0, q1, [x2, #0]
    stp q2, q3, [x2, #32]
    stp q4, q5, [x2, #64]
    stp q6, q7, [x2, #96]
    add x1, x1, #128
    add x2, x2, #128
    subs x6, x6, #128
    b.ne .Lcopy_block
    subs x0, x0, #1
    b.ne .Lcopy_pass
.Lcopy_done:
    ret
.size matrix_copy_probe,.-matrix_copy_probe
.section .note.GNU-stack,"",%progbits

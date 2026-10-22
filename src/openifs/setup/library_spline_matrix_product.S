/* Complete public-runtime product for the qualified large spline pairs.
 * Contract: skills/md2asm/references/openifs/setup/library_spline_matrix_product.md.
 * x0=&int32 rows 137, 138 or 139; x1=left[rows,139], x2=right[139,139], x3=output.
 * Matrices are column-major FP64 with eight-byte alignment; the row word is four-byte aligned.
 * Return 0 means complete; return 2 refuses the interface before mutation.
 * Stack: 416 bytes. Arithmetic stays in the original public GNU MATMUL service.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_library_spline_matrix_product
.type md2asm_library_spline_matrix_product,%function
md2asm_library_spline_matrix_product:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    tst x0,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x3
    tst x9,#7
    b.ne .Lreject
    adds x4,x0,#4
    b.cs .Lreject
    ldr w5,[x0]
    sub w9,w5,#137
    cmp w9,#2
    b.hi .Lreject
    mov x6,#1112
    mul x6,x5,x6
    mov x7,#0x5bc8
    movk x7,#2,lsl #16
    adds x8,x1,x6
    b.cs .Lreject
    adds x9,x2,x7
    b.cs .Lreject
    adds x10,x3,x6
    b.cs .Lreject
    /* Output cannot overlap either input or the read-only row word. */
    cmp x10,x1
    b.ls 1f
    cmp x8,x3
    b.hi .Lreject
1:
    cmp x10,x2
    b.ls 1f
    cmp x9,x3
    b.hi .Lreject
1:
    cmp x10,x0
    b.ls 1f
    cmp x4,x3
    b.hi .Lreject
1:
    mrs x11,fpcr
    cbnz x11,.Lreject
    mov x11,#0
.Lfinite_left:
    ldr x12,[x1,x11]
    ubfx x13,x12,#52,#11
    cmp x13,#2047
    b.eq .Lreject
    add x11,x11,#8
    cmp x11,x6
    b.lo .Lfinite_left
    mov x11,#0
.Lfinite_right:
    ldr x12,[x2,x11]
    ubfx x13,x12,#52,#11
    cmp x13,#2047
    b.eq .Lreject
    add x11,x11,#8
    cmp x11,x7
    b.lo .Lfinite_right
    sub sp,sp,#416
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x19,x1
    mov x20,x2
    mov x21,x3
    mov w22,w5
    mov x23,x6
    mov x24,x7
    add x25,sp,#128
    add x26,sp,#224
    add x27,sp,#320
    str w22,[sp,#120]
    bl __errno_location
    str x0,[sp,#104]
    ldr w9,[x0]
    str w9,[sp,#112]
    /* GNU rank-two descriptor: base, offset, dtype, span, then two dimensions. */
    add x9,x22,#1
    neg x9,x9
    stp x19,x9,[x25]
    mov x10,#8
    movz x11,#0x0302,lsl #32
    stp x10,x11,[x25,#16]
    mov x12,#1
    stp x10,x12,[x25,#32]
    stp x12,x22,[x25,#48]
    stp x22,x12,[x25,#64]
    mov x13,#139
    str x13,[x25,#80]
    /* Only the unused right span differs from the two nested-source descriptors. */
    mov x9,#140
    neg x9,x9
    stp x20,x9,[x26]
    stp x10,x11,[x26,#16]
    stp x10,x12,[x26,#32]
    stp x12,x13,[x26,#48]
    stp x13,x12,[x26,#64]
    str x13,[x26,#80]
    /* The two square products use the source's null-base allocation interface. */
    stp xzr,xzr,[x27]
    stp x10,x11,[x27,#16]
    stp xzr,xzr,[x27,#32]
    stp xzr,xzr,[x27,#48]
    stp xzr,xzr,[x27,#64]
    str xzr,[x27,#80]
    cmp w22,#139
    b.eq .Lcall_product
    /* The final rectangular product writes the same preallocated caller span. */
    add x9,x22,#1
    neg x9,x9
    stp x21,x9,[x27]
    stp x10,x12,[x27,#32]
    stp x12,x22,[x27,#48]
    stp x22,x12,[x27,#64]
    str x13,[x27,#80]
.Lcall_product:
    mov x0,x27
    mov x1,x25
    mov x2,x26
    mov w3,wzr
    mov w4,wzr
    mov x5,xzr
    bl _gfortran_matmul_r8
    cmp w22,#139
    b.ne .Lfinish
    /* The owned runtime result is copied in full before exactly one release. */
    ldr x9,[x27]
    mov x10,#0
.Lcopy_owned_result:
    ldr x11,[x9,x10]
    str x11,[x21,x10]
    add x10,x10,#8
    cmp x10,x23
    b.lo .Lcopy_owned_result
    mov x0,x9
    bl free
.Lfinish:
    ldr x9,[sp,#104]
    ldr w10,[sp,#112]
    str w10,[x9]
    ldr x18,[sp,#96]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#416
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_library_spline_matrix_product,.-md2asm_library_spline_matrix_product
.section .note.GNU-stack,"",%progbits

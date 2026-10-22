/* Complete bounded MINV_CALLER service for the two qualified N139 matrices.
 * Contract: skills/md2asm/references/openifs/setup/library_spline_matrix_inverse.md.
 * x0=&int32 scale1, x1=&int32 N139, x2=readonly input, x3=output.
 * Matrices are disjoint154568B column-major FP64 spans, aligned8B.
 * Return0 commits all output;2 refuses interface;3 refuses numerical service.
 * Private314976B frame; public DGETRF/DGECON/DGETRI, original LWORK556.
 * Output is untouched until all three services and condition checks pass.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_library_spline_matrix_inverse
.type md2asm_library_spline_matrix_inverse,%function
md2asm_library_spline_matrix_inverse:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    orr x9,x0,x1
    tst x9,#3
    b.ne .Lreject
    orr x9,x2,x3
    tst x9,#7
    b.ne .Lreject
    adds x4,x0,#4
    b.cs .Lreject
    adds x5,x1,#4
    b.cs .Lreject
    mov x8,#0x5bc8
    movk x8,#2,lsl #16
    adds x6,x2,x8
    b.cs .Lreject
    adds x7,x3,x8
    b.cs .Lreject
    /* All four complete caller spans must be disjoint. */
    cmp x4,x1
    b.ls 1f
    cmp x5,x0
    b.hi .Lreject
1:
    cmp x4,x2
    b.ls 1f
    cmp x6,x0
    b.hi .Lreject
1:
    cmp x4,x3
    b.ls 1f
    cmp x7,x0
    b.hi .Lreject
1:
    cmp x5,x2
    b.ls 1f
    cmp x6,x1
    b.hi .Lreject
1:
    cmp x5,x3
    b.ls 1f
    cmp x7,x1
    b.hi .Lreject
1:
    cmp x6,x3
    b.ls 1f
    cmp x7,x2
    b.hi .Lreject
1:
    ldr w4,[x1]
    cmp w4,#139
    b.ne .Lreject
    ldr w5,[x0]
    cmp w5,#1
    b.ne .Lreject
    mrs x9,fpcr
    cbnz x9,.Lreject
    mov x9,#0
    mov x12,#19321
.Lfinite_input:
    ldr x10,[x2,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    add x9,x9,#1
    cmp x9,x12
    b.lo .Lfinite_input
    /* Slots0/8 are exclusively the two outgoing DGECON stack arguments. */
    sub sp,sp,#76,lsl #12
    sub sp,sp,#3680
    stp x29,x30,[sp,#16]
    add x29,sp,#16
    stp x19,x20,[sp,#32]
    stp x21,x22,[sp,#48]
    stp x23,x24,[sp,#64]
    stp x25,x26,[sp,#80]
    stp x27,x28,[sp,#96]
    stp x18,xzr,[sp,#112]
    stp d8,d9,[sp,#128]
    mov x19,x2
    mov x20,x3
    add x21,sp,#256
    mov x22,#0x5cd0
    movk x22,#2,lsl #16
    add x22,sp,x22
    mov x23,#0xb8a0
    movk x23,#4,lsl #16
    add x23,sp,x23
    mov x24,#0xbad0
    movk x24,#4,lsl #16
    add x24,sp,x24
    mov x25,#0xbd00
    movk x25,#4,lsl #16
    add x25,sp,x25
    mov x26,#139
    mov x27,#19321
    str w26,[sp,#160]
    mov w9,#1
    str w9,[sp,#164]
    mov w9,#556
    str w9,[sp,#168]
    mov w9,#49
    strb w9,[sp,#176]
    bl __errno_location
    str x0,[sp,#144]
    ldr w9,[x0]
    str w9,[sp,#152]
    /* Source MINV_CALLER: increasing diagonal sum, then one division. */
    fmov d8,xzr
    mov x9,#0
    mov x10,x19
.Ldiagonal_sum:
    ldr d0,[x10]
    fabs d0,d0
    fadd d8,d8,d0
    add x10,x10,#1120
    add x9,x9,#1
    cmp x9,x26
    b.lo .Ldiagonal_sum
    scvtf d0,w26
    fdiv d8,d8,d0
    str d8,[sp,#200]
    fcmp d8,#0.0
    cset w28,gt
    /* Source row outer, column inner, with separately rounded divisions. */
    mov x9,#0
.Lscale_row:
    add x12,x19,x9,lsl #3
    add x13,x21,x9,lsl #3
    mov x10,#0
.Lscale_column:
    ldr d0,[x12]
    cbz w28,.Lscale_store
    fdiv d0,d0,d8
.Lscale_store:
    str d0,[x13]
    add x12,x12,#1112
    add x13,x13,#1112
    add x10,x10,#1
    cmp x10,x26
    b.lo .Lscale_column
    add x9,x9,#1
    cmp x9,x26
    b.lo .Lscale_row
    /* MINV_8's separate complete extraction into ZMAT is retained. */
    mov x9,#0
.Lextract_row:
    add x12,x21,x9,lsl #3
    add x13,x22,x9,lsl #3
    mov x10,#0
.Lextract_column:
    ldr x11,[x12]
    str x11,[x13]
    add x12,x12,#1112
    add x13,x13,#1112
    add x10,x10,#1
    cmp x10,x26
    b.lo .Lextract_column
    add x9,x9,#1
    cmp x9,x26
    b.lo .Lextract_row
    /* Actual original native norm uses scalar FADD and FMAXNM. */
    fmov d9,xzr
    mov x9,#0
    mov x12,x22
.Lnorm_column:
    fmov d0,xzr
    mov x10,#0
.Lnorm_row:
    ldr d1,[x12],#8
    fabs d1,d1
    fadd d0,d0,d1
    add x10,x10,#1
    cmp x10,x26
    b.lo .Lnorm_row
    fmaxnm d9,d9,d0
    add x9,x9,#1
    cmp x9,x26
    b.lo .Lnorm_column
    str d9,[sp,#184]
    /* Public factorisation: INFO>0 still reaches the original condition test. */
    add x0,sp,#160
    mov x1,x0
    mov x2,x22
    mov x3,x0
    mov x4,x23
    add x5,sp,#172
    bl dgetrf_
    ldr w9,[sp,#172]
    tbnz w9,#31,.Lnumeric_failure
    /* GNU Fortran DGECON: nine explicit arguments, then character length1. */
    add x0,sp,#176
    add x1,sp,#160
    mov x2,x22
    mov x3,x1
    add x4,sp,#184
    add x5,sp,#192
    mov x6,x25
    mov x7,x24
    add x9,sp,#172
    str x9,[sp]
    mov x9,#1
    str x9,[sp,#8]
    bl dgecon_
    ldr w9,[sp,#172]
    cbnz w9,.Lnumeric_failure
    ldr d0,[sp,#192]
    adrp x9,.Lcondition_threshold
    add x9,x9,:lo12:.Lcondition_threshold
    ldr d1,[x9]
    fcmp d0,d1
    b.ls .Lnumeric_failure
    /* Keep the same WORK pointer and original LWORK556, without a query. */
    add x0,sp,#160
    mov x1,x22
    mov x2,x0
    mov x3,x23
    mov x4,x25
    add x5,sp,#168
    add x6,sp,#172
    bl dgetri_
    ldr w9,[sp,#172]
    cbnz w9,.Lnumeric_failure
    fmov d0,#1.0
    str d0,[sp,#208]
    /* Original KMODE1 copy precedes MINV_CALLER's final rescaling. */
    mov x9,#0
.Linverse_copy_row:
    add x12,x22,x9,lsl #3
    add x13,x21,x9,lsl #3
    mov x10,#0
.Linverse_copy_column:
    ldr x11,[x12]
    str x11,[x13]
    add x12,x12,#1112
    add x13,x13,#1112
    add x10,x10,#1
    cmp x10,x26
    b.lo .Linverse_copy_column
    add x9,x9,#1
    cmp x9,x26
    b.lo .Linverse_copy_row
    /* The caller output is first touched here, after every service succeeds. */
    mov x9,#0
.Loutput_row:
    add x12,x21,x9,lsl #3
    add x13,x20,x9,lsl #3
    mov x10,#0
.Loutput_column:
    ldr d0,[x12]
    cbz w28,.Loutput_store
    fdiv d0,d0,d8
.Loutput_store:
    str d0,[x13]
    add x12,x12,#1112
    add x13,x13,#1112
    add x10,x10,#1
    cmp x10,x26
    b.lo .Loutput_column
    add x9,x9,#1
    cmp x9,x26
    b.lo .Loutput_row
    mov w0,#0
    b .Lfinish
.Lnumeric_failure:
    mov w0,#3
.Lfinish:
    str w0,[sp,#156]
    ldr x9,[sp,#144]
    ldr w10,[sp,#152]
    str w10,[x9]
    ldp d8,d9,[sp,#128]
    ldr x18,[sp,#112]
    ldp x19,x20,[sp,#32]
    ldp x21,x22,[sp,#48]
    ldp x23,x24,[sp,#64]
    ldp x25,x26,[sp,#80]
    ldp x27,x28,[sp,#96]
    ldp x29,x30,[sp,#16]
    ldr w0,[sp,#156]
    add sp,sp,#3680
    add sp,sp,#76,lsl #12
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_library_spline_matrix_inverse,.-md2asm_library_spline_matrix_inverse
.section .rodata
.p2align 3
.Lcondition_threshold:
    .quad 0x0079000000000000
.section .note.GNU-stack,"",%progbits

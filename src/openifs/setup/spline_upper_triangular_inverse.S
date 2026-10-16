/* Direct selected DTRTRI upper/nonunit body through source DTRTI2.
 * Contract: skills/md2asm/references/openifs/setup/upper_triangular_inverse_contract.md. x0=&dimension,
 * x1=matrix[n*n],x2=&info. Caller-owned column-major matrix, aligned8.
 * Return0 complete (info may mark singular),2 reject before mutation.
 * Own frame176B; accepted integer rounding child1728B; no FMA instruction.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_upper_inverse
.type md2asm_spline_upper_inverse,%function
md2asm_spline_upper_inverse:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    orr x9,x0,x2
    tst x9,#3
    b.ne .Lreject
    tst x1,#7
    b.ne .Lreject
    ldr w3,[x0]
    sub w9,w3,#1
    cmp w9,#23
    b.hi .Lreject
    mul w4,w3,w3
    mov x5,#0
.Lfinite_input:
    ldr x6,[x1,x5,lsl #3]
    ubfx x7,x6,#52,#11
    cmp x7,#2047
    b.eq .Lreject
    add x5,x5,#1
    cmp w5,w4
    b.lt .Lfinite_input
    fmov d0,xzr
    mov x5,#0
.Lsingular_scan:
    madd x6,x5,x3,x5
    ldr d1,[x1,x6,lsl #3]
    fcmp d1,d0
    b.eq .Lsingular
    add x5,x5,#1
    cmp w5,w3
    b.lt .Lsingular_scan
    str wzr,[x2]
    stp x29,x30,[sp,#-176]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,x1
    mov x20,x2
    mov w21,w3
    mov x22,#0
    fmov d14,xzr
    fmov d15,#1.0
.Lcolumn:
    mul x9,x22,x21
    add x23,x19,x9,lsl #3
    ldr d10,[x23,x22,lsl #3]
    fdiv d8,d15,d10
    str d8,[x23,x22,lsl #3]
    fneg d8,d8
    cbz x22,.Lnext_column
    mov x24,#0
.Ltriangular_product:
    ldr d9,[x23,x24,lsl #3]
    fcmp d9,d14
    b.eq .Lnext_product
    mul x9,x24,x21
    add x26,x19,x9,lsl #3
    cbz x24,.Lproduct_diagonal
    mov x25,#0
.Lproduct_row:
    ldr d0,[x26,x25,lsl #3]
    fmov d1,d9
    ldr d2,[x23,x25,lsl #3]
    bl md2asm_round_product_sum_candidate
    str d0,[x23,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x24
    b.lt .Lproduct_row
.Lproduct_diagonal:
    ldr d10,[x26,x24,lsl #3]
    fmul d10,d9,d10
    str d10,[x23,x24,lsl #3]
.Lnext_product:
    add x24,x24,#1
    cmp x24,x22
    b.lt .Ltriangular_product
    mov x25,#0
.Lscale_column:
    ldr d10,[x23,x25,lsl #3]
    fmul d10,d8,d10
    str d10,[x23,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x22
    b.lt .Lscale_column
.Lnext_column:
    add x22,x22,#1
    cmp x22,x21
    b.lt .Lcolumn
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp],#176
    mov w0,#0
    ret
.Lsingular:
    add w5,w5,#1
    str w5,[x2]
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_upper_inverse,.-md2asm_spline_upper_inverse
.section .note.GNU-stack,"",%progbits

/* Source-ordered small vertical matrix product, all buffers caller-owned.
 * Contract: skills/md2asm/references/openifs/setup/spline_matrix_product_contract.md. x0=&rows19..21,x1=left[rows,21],
 * x2=right[21,21],x3=output[rows,21], first index fastest. Return0 or reject2.
 * Separate FP64 product/add, increasing inner index, positive-zero initial sum.
 * No frame, allocation, external callable, original metadata or numerical table.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_matrix_product
.type md2asm_spline_matrix_product,%function
md2asm_spline_matrix_product:
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
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr w4,[x0]
    sub w9,w4,#19
    cmp w9,#2
    b.hi .Lreject
    lsl x12,x4,#3
    mov x5,#0
.Lcolumn:
    mov x6,#0
.Lrow:
    add x8,x1,x6,lsl #3
    mov x9,#168
    madd x9,x5,x9,x2
    fmov d0,xzr
    mov w7,#21
.Linner:
    ldr d1,[x8]
    ldr d2,[x9],#8
    fmul d1,d1,d2
    fadd d0,d0,d1
    add x8,x8,x12
    subs w7,w7,#1
    b.ne .Linner
    madd x10,x5,x4,x6
    str d0,[x3,x10,lsl #3]
    add x6,x6,#1
    cmp x6,x4
    b.lt .Lrow
    add x5,x5,#1
    cmp x5,#21
    b.lt .Lcolumn
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_matrix_product,.-md2asm_spline_matrix_product
.section .note.GNU-stack,"",%progbits

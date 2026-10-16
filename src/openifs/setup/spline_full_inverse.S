/* Direct selected unblocked DGETRI. Contract: skills/md2asm/references/openifs/setup/spline_full_inverse_contract.md.
 * x0=&dimension,x1=column-major LU matrix[n*n],x2=readonly pivots[n],
 * x3=&info. Return0 complete/singular,2 rejected before mutation.
 * Own368B frame with192B scratch; only direct upper and integer-round children.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_inverse_from_lu
.type md2asm_spline_inverse_from_lu,%function
md2asm_spline_inverse_from_lu:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    orr x9,x0,x2
    orr x9,x9,x3
    tst x9,#3
    b.ne .Lreject
    tst x1,#7
    b.ne .Lreject
    ldr w4,[x0]
    sub w9,w4,#1
    cmp w9,#23
    b.hi .Lreject
    mov x5,#0
.Lpivots:
    ldr w6,[x2,x5,lsl #2]
    add w7,w5,#1
    cmp w6,w7
    b.lt .Lreject
    cmp w6,w4
    b.gt .Lreject
    add x5,x5,#1
    cmp w5,w4
    b.lt .Lpivots
    stp x29,x30,[sp,#-368]!
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
    mov x21,x3
    mov w22,w4
    add x25,sp,#176
    mov x2,x21
    bl md2asm_spline_upper_inverse
    cbnz w0,.Lfinish
    ldr w9,[x21]
    cbnz w9,.Lsuccess
    fmov d14,xzr
    fmov d15,#-1.0
    sub x23,x22,#1
.Lcolumn:
    mul x9,x23,x22
    add x24,x19,x9,lsl #3
    add x27,x23,#1
    cmp x27,x22
    b.ge .Lnext_column
.Lcopy_lower:
    ldr d9,[x24,x27,lsl #3]
    str d9,[x25,x27,lsl #3]
    str d14,[x24,x27,lsl #3]
    add x27,x27,#1
    cmp x27,x22
    b.lt .Lcopy_lower
    add x26,x23,#1
.Lupdate_column:
    mul x9,x26,x22
    add x28,x19,x9,lsl #3
    ldr d8,[x25,x26,lsl #3]
    fmul d8,d15,d8
    mov x27,#0
.Lupdate_row:
    ldr d0,[x28,x27,lsl #3]
    fmov d1,d8
    ldr d2,[x24,x27,lsl #3]
    bl md2asm_round_product_sum_candidate
    str d0,[x24,x27,lsl #3]
    add x27,x27,#1
    cmp x27,x22
    b.lt .Lupdate_row
    add x26,x26,#1
    cmp x26,x22
    b.lt .Lupdate_column
.Lnext_column:
    subs x23,x23,#1
    b.pl .Lcolumn
    sub x23,x22,#2
    cmp x23,#0
    b.lt .Lsuccess
.Lpivot_column:
    ldr w9,[x20,x23,lsl #2]
    sub w9,w9,#1
    cmp w9,w23
    b.eq .Lnext_pivot
    mul x10,x23,x22
    add x24,x19,x10,lsl #3
    mul x10,x9,x22
    add x28,x19,x10,lsl #3
    mov x27,#0
.Lswap_column:
    ldr d8,[x24,x27,lsl #3]
    ldr d9,[x28,x27,lsl #3]
    str d9,[x24,x27,lsl #3]
    str d8,[x28,x27,lsl #3]
    add x27,x27,#1
    cmp x27,x22
    b.lt .Lswap_column
.Lnext_pivot:
    subs x23,x23,#1
    b.pl .Lpivot_column
.Lsuccess:
    mov w0,#0
.Lfinish:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp],#368
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_inverse_from_lu,.-md2asm_spline_inverse_from_lu
.section .note.GNU-stack,"",%progbits

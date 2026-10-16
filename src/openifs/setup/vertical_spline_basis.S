/* Complete SUVFE_BASIS numerical body, emitted directly as AArch64 assembly.
 * Contract: skills/md2asm/references/openifs/setup/spline_basis_contract.md.
 * ABI: x0=&int32 order, x1=&FP64 value, x2=&int32 basis_count,
 * x3=contiguous knots[basis_count+order], x4=weights[basis_count].
 * Return w0=0 complete or 2 rejected before mutation. No external calls.
 * Stack 224 bytes, aligned 16. Caller-owned disjoint mapped buffers.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_vertical_spline_basis
.type md2asm_vertical_spline_basis,%function
md2asm_vertical_spline_basis:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    orr x9,x0,x2
    tst x9,#3
    b.ne .Lreject
    orr x9,x1,x3
    orr x9,x9,x4
    tst x9,#7
    b.ne .Lreject
    ldr w5,[x0]
    ldr w6,[x2]
    sub w9,w5,#2
    cmp w9,#2
    b.hi .Lreject
    cmp w6,w5
    b.lt .Lreject
    cmp w6,#24
    b.gt .Lreject
    add w7,w5,w6
    ldr x9,[x1]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fmov d0,x9
    fmov d1,xzr
    fmov d2,#1.0
    mov x8,#0
    mov w12,#0
.Lguard_knots:
    ldr x9,[x3,x8,lsl #3]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lreject
    fmov d3,x9
    fcmp d3,d1
    b.lt .Lreject
    fcmp d3,d2
    b.gt .Lreject
    cmp w8,w5
    b.ge .Lguard_upper
    fcmp d3,d1
    b.ne .Lreject
.Lguard_upper:
    cmp w8,w6
    b.lt .Lguard_order
    fcmp d3,d2
    b.ne .Lreject
.Lguard_order:
    cbz x8,.Lnew_run
    fcmp d3,d4
    b.lt .Lreject
    b.ne .Lnew_run
    add w12,w12,#1
    cmp w12,w5
    b.gt .Lreject
    b .Lnext_guard
.Lnew_run:
    mov w12,#1
.Lnext_guard:
    fmov d4,d3
    add x8,x8,#1
    cmp w8,w7
    b.lt .Lguard_knots

    sub sp,sp,#224
    mov x9,sp
    sub w8,w7,#1
    mov x10,#0
.Lfirst_order:
    ldr d3,[x3,x10,lsl #3]
    add x11,x10,#1
    ldr d4,[x3,x11,lsl #3]
    fmov d5,d1
    fcmp d0,d3
    b.lt .Lstore_first
    fcmp d0,d4
    b.ge .Lstore_first
    fmov d5,d2
.Lstore_first:
    str d5,[x9,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w8
    b.lt .Lfirst_order

    mov w11,#2
.Lorder:
    sub w8,w7,w11
    mov x10,#0
.Lbasis:
    ldr d3,[x9,x10,lsl #3]
    fmov d4,d1
    fcmp d3,d1
    b.eq .Lright
    ldr d6,[x3,x10,lsl #3]
    fsub d7,d0,d6
    fmul d7,d7,d3
    add x12,x10,x11
    sub x12,x12,#1
    ldr d5,[x3,x12,lsl #3]
    fsub d5,d5,d6
    fdiv d4,d7,d5
.Lright:
    add x12,x10,#1
    ldr d3,[x9,x12,lsl #3]
    fmov d5,d1
    fcmp d3,d1
    b.eq .Lcombine
    ldr d6,[x3,x12,lsl #3]
    add x12,x10,x11
    ldr d7,[x3,x12,lsl #3]
    fsub d5,d7,d0
    fmul d5,d5,d3
    fsub d7,d7,d6
    fdiv d5,d5,d7
.Lcombine:
    fadd d4,d4,d5
    str d4,[x9,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w8
    b.lt .Lbasis
    add w11,w11,#1
    cmp w11,w5
    b.le .Lorder

    fsub d3,d0,d2
    fabs d3,d3
    mov x12,#0x0010000000000000
    fmov d4,x12
    fcmp d3,d4
    b.ge .Lcopy
    mov x10,#0
    sub w8,w6,#1
.Lendpoint_zero:
    str d1,[x4,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w8
    b.lt .Lendpoint_zero
    str d2,[x4,x10,lsl #3]
    b .Lsuccess
.Lcopy:
    mov x10,#0
.Lcopy_next:
    ldr d3,[x9,x10,lsl #3]
    str d3,[x4,x10,lsl #3]
    add x10,x10,#1
    cmp w10,w6
    b.lt .Lcopy_next
.Lsuccess:
    add sp,sp,#224
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_vertical_spline_basis,.-md2asm_vertical_spline_basis
.section .note.GNU-stack,"",%progbits

/* Direct selected SUVFE_IMPLICITBC value boundaries.
 * Contract: skills/md2asm/references/openifs/setup/spline_value_boundary_contract.md. x0=top[2],x1=bottom[2],
 * x2=&order (4), x3=&basis (21 through 24, or 139 or 140),
 * x4=pieces[basis,4,4].
 * Return0 complete,2 rejected before mutation. No stack or external call.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_value_boundaries
.type md2asm_spline_value_boundaries,%function
md2asm_spline_value_boundaries:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    orr x9,x0,x1
    orr x9,x9,x2
    orr x9,x9,x3
    tst x9,#3
    b.ne .Lreject
    tst x4,#7
    b.ne .Lreject
    ldr w9,[x2]
    cmp w9,#4
    b.ne .Lreject
    ldr w5,[x3]
    sub w9,w5,#21
    cmp w9,#3
    b.hi .Llarge_domain
.Lboundary_flags:
    ldp w6,w9,[x0]
    cbnz w9,.Lreject
    cmp w6,#1
    b.hi .Lreject
    ldp w7,w9,[x1]
    cbnz w9,.Lreject
    cmp w7,#1
    b.hi .Lreject
    mov x10,#0
    sub x8,x5,#1
.Lplane:
    mul x9,x10,x5
    add x9,x4,x9,lsl #3
    cbz w6,.Lbottom
    str xzr,[x9]
.Lbottom:
    cbz w7,.Lnext
    str xzr,[x9,x8,lsl #3]
.Lnext:
    add x10,x10,#1
    cmp x10,#16
    b.lt .Lplane
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.Llarge_domain:
    sub w9,w5,#139
    cmp w9,#1
    b.hi .Lreject
    b .Lboundary_flags
.size md2asm_spline_value_boundaries,.-md2asm_spline_value_boundaries
.section .note.GNU-stack,"",%progbits

/* Direct selected SUVFE_CPSPLINES. Contract: skills/md2asm/references/openifs/setup/spline_piece_coefficient_contract.md.
 * x0=control[order,basis,maximas,verbose],x1=&minimum_interval,x2=bounds[2],
 * x3=transform[16],x4=knots[basis+4],x5=pieces[basis,4,4],x6=centres[basis].
 * Return 0 means complete, 2 means interface rejection, and 3 means child failure.
 * Own 1,216 bytes for old shapes or 5,856 bytes for basis 139 or 140.
 * Each entered frame has an exact matching release.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_piece_coefficients
.type md2asm_spline_piece_coefficients,%function
md2asm_spline_piece_coefficients:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    cbz x6,.Lreject
    tst x0,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    orr x9,x9,x6
    tst x9,#7
    b.ne .Lreject
    ldp w9,w10,[x0]
    cmp w9,#4
    b.ne .Lreject
    sub w11,w10,#21
    cmp w11,#3
    b.hi .Llarge_domain
    ldp w11,w12,[x0,#8]
    orr w11,w11,w12
    cbnz w11,.Lreject
    ldp x11,x12,[x2]
    cbnz x11,.Lreject
    mov x13,#0x3ff0000000000000
    cmp x12,x13
    b.ne .Lreject
    ldr x11,[x1]
    ubfx x12,x11,#52,#11
    cmp x12,#2047
    b.eq .Lreject
    fmov d0,x11
    fcmp d0,#0.0
    b.lt .Lreject
    sub sp,sp,#1216
    stp x29,x30,[sp]
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
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    mov w26,w10
    str w9,[sp,#176]
    str w10,[sp,#180]
    fmov d8,d0
    lsl x10,x26,#4
    mov x9,#0
    fmov d0,xzr
.Lzero_pieces:
    str d0,[x24,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x10
    b.lt .Lzero_pieces
    mov x28,#0
.Lsample_positions:
    add w9,w28,#1
    str w9,[sp,#184]
    add x0,sp,#176
    add x1,sp,#184
    mov x2,x21
    bl md2asm_spline_sample_position
    add x9,sp,#224
    str d0,[x9,x28,lsl #3]
    add x28,x28,#1
    cmp x28,#4
    b.lt .Lsample_positions
    mov x27,#0
.Linterval:
    add x9,x23,x27,lsl #3
    ldp d0,d1,[x9]
    fsub d9,d1,d0
    fabs d0,d9
    fcmp d0,d8
    b.le .Lnext_interval
    mov x28,#0
.Lsample_basis:
    add x0,x23,x27,lsl #3
    add x1,x0,#8
    add x2,sp,#224
    add x2,x2,x28,lsl #3
    bl md2asm_spline_coordinate_from_local
    str d0,[sp,#192]
    add x0,sp,#176
    add x1,sp,#192
    add x2,sp,#180
    mov x3,x23
    add x4,sp,#256
    bl md2asm_vertical_spline_basis
    cbnz w0,.Lchild_failure
    mov x9,#0
    add x10,sp,#256
    add x11,sp,#448
.Lcopy_sample:
    ldr d0,[x10,x9,lsl #3]
    add x12,x28,x9,lsl #2
    str d0,[x11,x12,lsl #3]
    add x9,x9,#1
    cmp x9,x26
    b.lt .Lcopy_sample
    add x28,x28,#1
    cmp x28,#4
    b.lt .Lsample_basis
    sub x28,x27,#3
    cmp x28,#0
    csel x28,x28,xzr,ge
    sub x9,x26,#1
    cmp x27,x9
    csel x9,x27,x9,lt
    str w9,[sp,#212]
.Lbasis_piece:
    sub x10,x27,x28
    mul x10,x10,x26
    add x10,x10,x28
    add x13,x24,x10,lsl #3
    add x10,sp,#448
    add x14,x10,x28,lsl #5
    mov x9,#0
.Lcoefficient:
    fmov d0,xzr
    mov x10,#0
.Ldot:
    add x11,x9,x10,lsl #2
    ldr d1,[x22,x11,lsl #3]
    ldr d2,[x14,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    add x10,x10,#1
    cmp x10,#4
    b.lt .Ldot
    mul x11,x9,x26
    lsl x11,x11,#2
    str d0,[x13,x11,lsl #3]
    add x9,x9,#1
    cmp x9,#4
    b.lt .Lcoefficient
    add x28,x28,#1
    ldr w9,[sp,#212]
    cmp x28,x9
    b.le .Lbasis_piece
.Lnext_interval:
    add x27,x27,#1
    add x9,x26,#3
    cmp x27,x9
    b.lt .Linterval
    mov x9,#0
    fmov d2,#3.0
.Lcentre:
    fmov d0,xzr
    mov x10,#1
.Lcentre_sum:
    add x11,x9,x10
    ldr d1,[x23,x11,lsl #3]
    fadd d0,d0,d1
    add x10,x10,#1
    cmp x10,#3
    b.le .Lcentre_sum
    fdiv d0,d0,d2
    str d0,[x25,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x26
    b.lt .Lcentre
    mov w0,#0
    b .Lfinish
.Lchild_failure:
    mov w0,#3
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
    ldp x29,x30,[sp]
    add sp,sp,#1216
    ret
.Lreject:
    mov w0,#2
    ret
.Llarge_domain:
    sub w11,w10,#139
    cmp w11,#1
    b.hi .Lreject
    ldp w11,w12,[x0,#8]
    orr w11,w11,w12
    cbnz w11,.Lreject
    ldp x11,x12,[x2]
    cbnz x11,.Lreject
    mov x13,#0x3ff0000000000000
    cmp x12,x13
    b.ne .Lreject
    ldr x11,[x1]
    ubfx x12,x11,#52,#11
    cmp x12,#2047
    b.eq .Lreject
    fmov d0,x11
    fcmp d0,#0.0
    b.lt .Lreject
    sub sp,sp,#1,lsl #12
    sub sp,sp,#1760
    stp x29,x30,[sp]
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
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    mov w26,w10
    str w9,[sp,#176]
    str w10,[sp,#180]
    fmov d8,d0
    lsl x10,x26,#4
    mov x9,#0
    fmov d0,xzr
.Llarge_zero_pieces:
    str d0,[x24,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x10
    b.lt .Llarge_zero_pieces
    mov x28,#0
.Llarge_sample_positions:
    add w9,w28,#1
    str w9,[sp,#184]
    add x0,sp,#176
    add x1,sp,#184
    mov x2,x21
    bl md2asm_spline_sample_position
    add x9,sp,#224
    str d0,[x9,x28,lsl #3]
    add x28,x28,#1
    cmp x28,#4
    b.lt .Llarge_sample_positions
    mov x27,#0
.Llarge_interval:
    add x9,x23,x27,lsl #3
    ldp d0,d1,[x9]
    fsub d9,d1,d0
    fabs d0,d9
    fcmp d0,d8
    b.le .Llarge_next_interval
    mov x28,#0
.Llarge_sample_basis:
    add x0,x23,x27,lsl #3
    add x1,x0,#8
    add x2,sp,#224
    add x2,x2,x28,lsl #3
    bl md2asm_spline_coordinate_from_local
    str d0,[sp,#192]
    add x0,sp,#176
    add x1,sp,#192
    add x2,sp,#180
    mov x3,x23
    add x4,sp,#256
    bl md2asm_vertical_spline_basis
    cbnz w0,.Llarge_child_failure
    mov x9,#0
    add x10,sp,#256
    add x11,sp,#1376
.Llarge_copy_sample:
    ldr d0,[x10,x9,lsl #3]
    add x12,x28,x9,lsl #2
    str d0,[x11,x12,lsl #3]
    add x9,x9,#1
    cmp x9,x26
    b.lt .Llarge_copy_sample
    add x28,x28,#1
    cmp x28,#4
    b.lt .Llarge_sample_basis
    sub x28,x27,#3
    cmp x28,#0
    csel x28,x28,xzr,ge
    sub x9,x26,#1
    cmp x27,x9
    csel x9,x27,x9,lt
    str w9,[sp,#212]
.Llarge_basis_piece:
    sub x10,x27,x28
    mul x10,x10,x26
    add x10,x10,x28
    add x13,x24,x10,lsl #3
    add x10,sp,#1376
    add x14,x10,x28,lsl #5
    mov x9,#0
.Llarge_coefficient:
    fmov d0,xzr
    mov x10,#0
.Llarge_dot:
    add x11,x9,x10,lsl #2
    ldr d1,[x22,x11,lsl #3]
    ldr d2,[x14,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    add x10,x10,#1
    cmp x10,#4
    b.lt .Llarge_dot
    mul x11,x9,x26
    lsl x11,x11,#2
    str d0,[x13,x11,lsl #3]
    add x9,x9,#1
    cmp x9,#4
    b.lt .Llarge_coefficient
    add x28,x28,#1
    ldr w9,[sp,#212]
    cmp x28,x9
    b.le .Llarge_basis_piece
.Llarge_next_interval:
    add x27,x27,#1
    add x9,x26,#3
    cmp x27,x9
    b.lt .Llarge_interval
    mov x9,#0
    fmov d2,#3.0
.Llarge_centre:
    fmov d0,xzr
    mov x10,#1
.Llarge_centre_sum:
    add x11,x9,x10
    ldr d1,[x23,x11,lsl #3]
    fadd d0,d0,d1
    add x10,x10,#1
    cmp x10,#3
    b.le .Llarge_centre_sum
    fdiv d0,d0,d2
    str d0,[x25,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x26
    b.lt .Llarge_centre
    mov w0,#0
    b .Llarge_finish
.Llarge_child_failure:
    mov w0,#3
.Llarge_finish:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp]
    add sp,sp,#1760
    add sp,sp,#1,lsl #12
    ret
.size md2asm_spline_piece_coefficients,.-md2asm_spline_piece_coefficients
.section .note.GNU-stack,"",%progbits

/* Selected consumed MINV_CALLER computation, direct assembly.
 * Contract: skills/md2asm/references/openifs/setup/selected_spline_inverse_contract.md. x0=&scale,x1=&n,
 * x2=readonly input[n*n],x3=output[n*n], column-major FP64, n4 or21.
 * Return0 complete,2 bad interface,3 numerical-child rejection/singularity.
 * Own3808B frame; only direct LU/full-inverse arithmetic children.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_selected_spline_inverse
.type md2asm_selected_spline_inverse,%function
md2asm_selected_spline_inverse:
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
    ldr w4,[x1]
    cmp w4,#4
    b.eq .Ldimension_ok
    cmp w4,#21
    b.ne .Lreject
.Ldimension_ok:
    ldr w6,[x0]
    cmp w6,#1
    b.hi .Lreject
    mul w5,w4,w4
    mov x9,#0
.Lfinite_input:
    ldr x10,[x2,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    add x9,x9,#1
    cmp w9,w5
    b.lt .Lfinite_input
    sub sp,sp,#3808
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
    mov x19,x2
    mov x20,x3
    mov w22,w4
    mov w23,w5
    mov w24,w6
    add x25,sp,#272
    add x26,sp,#176
    str w4,[sp,#160]
    fmov d8,xzr
    cbz w24,.Lcopy_setup
    mov x9,#0
    add x10,x22,#1
.Ldiagonal_sum:
    mul x11,x9,x10
    ldr d0,[x19,x11,lsl #3]
    fabs d0,d0
    fadd d8,d8,d0
    add x9,x9,#1
    cmp x9,x22
    b.lt .Ldiagonal_sum
    scvtf d0,w22
    fdiv d8,d8,d0
    fcmp d8,#0.0
    cset w24,gt
.Lcopy_setup:
    mov x9,#0
.Lcopy_input:
    ldr d0,[x19,x9,lsl #3]
    cbz w24,.Lcopy_unscaled
    fdiv d0,d0,d8
.Lcopy_unscaled:
    str d0,[x25,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x23
    b.lt .Lcopy_input
    add x0,sp,#160
    mov x1,x25
    mov x2,x26
    add x3,sp,#164
    bl md2asm_spline_lu_factor
    cbnz w0,.Lnumeric_failure
    ldr w9,[sp,#164]
    cbnz w9,.Lnumeric_failure
    add x0,sp,#160
    mov x1,x25
    mov x2,x26
    add x3,sp,#164
    bl md2asm_spline_inverse_from_lu
    cbnz w0,.Lnumeric_failure
    ldr w9,[sp,#164]
    cbnz w9,.Lnumeric_failure
    mov x9,#0
.Lcopy_output:
    ldr d0,[x25,x9,lsl #3]
    cbz w24,.Loutput_unscaled
    fdiv d0,d0,d8
.Loutput_unscaled:
    str d0,[x20,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x23
    b.lt .Lcopy_output
    mov w0,#0
    b .Lfinish
.Lnumeric_failure:
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
    add sp,sp,#3808
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_selected_spline_inverse,.-md2asm_selected_spline_inverse
.section .note.GNU-stack,"",%progbits

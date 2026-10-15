// Contract: skills/md2asm/references/openifs/setup/gaussian_grid_children.md.
// Direct selected GAWL loop. Contract: skills/md2asm/references/openifs/setup/gaussian_grid_children.md.
// Original seven-pointer ABI: coefficients,angle,weight,epsilon,degree,iterations,correction.
.text
.p2align 4
.global md2asm_refine_gaussian_latitude
.type md2asm_refine_gaussian_latitude,%function
md2asm_refine_gaussian_latitude:
    ldr w7, [x4]
    cmp w7, #32
    b.ne .Lrefine_unsupported
    stp x29, x30, [sp, #-160]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    str x18, [sp, #80]
    str d8, [sp, #88]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6
    str w7, [sp, #96]
    str wzr, [sp, #100]
    str wzr, [sp, #104]
    ldr d0, [x20]
    str d0, [sp, #112]
    ldr d8, [x22]
    mov w7, #1000
    scvtf d0, w7
    fmul d8, d8, d0
    mov w26, #1
.Lrefine_iteration:
    str w26, [x24]
    add x0, sp, #96
    add x1, sp, #100
    mov x2, x19
    add x3, sp, #112
    add x4, sp, #104
    add x5, sp, #120
    add x6, sp, #128
    mov x7, x25
    bl md2asm_legendre_newton_step
    ldr d0, [sp, #128]
    str d0, [sp, #112]
    ldr w7, [sp, #104]
    cbnz w7, .Lrefine_complete
    ldr d0, [x25]
    fabs d0, d0
    fcmp d0, d8
    b.hi .Lrefine_next
    mov w7, #1
    str w7, [sp, #104]
.Lrefine_next:
    add w26, w26, #1
    cmp w26, #21
    b.le .Lrefine_iteration
.Lrefine_complete:
    ldr d0, [sp, #128]
    str d0, [x20]
    ldr d0, [sp, #120]
    str d0, [x21]
    ldr d8, [sp, #88]
    ldr x18, [sp, #80]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x29, x30, [sp], #160
    ret
.Lrefine_unsupported:
    b abort
.size md2asm_refine_gaussian_latitude,.-md2asm_refine_gaussian_latitude
.section .note.GNU-stack,"",%progbits

/* Complete pressure-weighted column integral from the md2asm GPPWC contract, revision 1.1.
 * GNU Fortran AArch64 ABI, seven address arguments in x0 to x6.
 * Arrays are FP64 in Fortran order, with pressure and water boundaries 0..KFLEV.
 * Independent columns use two-lane NEON, with a bounded scalar remainder.
 * All vertical dependencies and the four layer rounding points are preserved.
 * This leaf uses caller-saved registers only and leaves the stack unchanged. */
.text
.p2align 4
.global gppwc_
.type gppwc_, %function
gppwc_:
    ldrsw x8, [x0]
    ldrsw x9, [x1]
    ldrsw x10, [x2]
    ldrsw x11, [x3]
    cmp x9, x10
    b.gt .Ldone
    lsl x8, x8, #3
    sub x9, x9, #1
    lsl x9, x9, #3
    lsl x10, x10, #3
    adrp x7, :got:__yomcst_MOD_rg
    ldr x7, [x7, :got_lo12:__yomcst_MOD_rg]
    ldr d0, [x7]
    fmov d1, #1.0
    fdiv d0, d1, d0
    dup v0.2d, v0.d[0]

    eor v1.16b, v1.16b, v1.16b
    mov x15, x9
.Ltop:
    sub x16, x10, x15
    cmp x16, #16
    b.lt .Ltop_tail
    str q1, [x4, x15]
    add x15, x15, #16
    b .Ltop
.Ltop_tail:
    cbz x16, .Ltop_done
    str d1, [x4, x15]
.Ltop_done:
    cbz x11, .Ldone
.Llayer:
    add x13, x4, x8         /* Next water boundary. */
    add x14, x6, x8         /* Next pressure boundary. */
    mov x15, x9
.Lcolumns:
    sub x16, x10, x15
    cmp x16, #16
    b.lt .Ltail
    ldr q1, [x5, x15]
    ldr q2, [x6, x15]
    ldr q3, [x14, x15]
    ldr q4, [x4, x15]
    fsub v3.2d, v3.2d, v2.2d
    fmul v1.2d, v1.2d, v3.2d
    fmul v1.2d, v1.2d, v0.2d
    fadd v1.2d, v4.2d, v1.2d
    str q1, [x13, x15]
    add x15, x15, #16
    b .Lcolumns
.Ltail:
    cbz x16, .Lnext_layer
    ldr d1, [x5, x15]
    ldr d2, [x6, x15]
    ldr d3, [x14, x15]
    ldr d4, [x4, x15]
    fsub d3, d3, d2
    fmul d1, d1, d3
    fmul d1, d1, d0
    fadd d1, d4, d1
    str d1, [x13, x15]
.Lnext_layer:
    mov x4, x13
    mov x6, x14
    add x5, x5, x8
    subs x11, x11, #1
    b.ne .Llayer
.Ldone:
    ret
.size gppwc_, .-gppwc_
.section .note.GNU-stack,"",%progbits

/* Integrate ozone mass through pressure layers, producing kg/m².
 * Each layer multiplies its mass fraction and pressure depth before gravity.
 * The contract defines the ordered sum, buffer bounds and GNU Fortran ABI. */
.text
.p2align 4
.global gptco3_
.type gptco3_, %function
gptco3_:
    ldrsw x7, [x0]
    ldrsw x8, [x1]
    ldrsw x9, [x2]
    ldrsw x11, [x3]
    sub x9, x9, x8
    adds x9, x9, #1
    b.le .Lreturn
    lsl x7, x7, #3
    sub x8, x8, #1
    lsl x8, x8, #3
    adrp x0, :got:__yomcst_MOD_rg
    ldr x0, [x0, :got_lo12:__yomcst_MOD_rg]
    ldr d30, [x0]
    fmov d29, #1.0
    fdiv d30, d29, d30
    dup v30.2d, v30.d[0]
    movi v0.2d, #0
    mov x13, x8
    mov x14, x9
.Lzero_pair:
    cmp x14, #2
    b.lt .Lzero_tail
    str q0, [x6, x13]
    add x13, x13, #16
    sub x14, x14, #2
    b .Lzero_pair
.Lzero_tail:
    cbz x14, .Lzero_done
    str d0, [x6, x13]
.Lzero_done:
    cbz x11, .Lreturn
    mov x12, x8
.Llevel:
    mov x15, x12
    mov x13, x8
    mov x14, x9
.Lpair:
    cmp x14, #2
    b.lt .Ltail
    ldr q1, [x5, x15]
    ldr q2, [x4, x15]
    fmul v1.2d, v1.2d, v2.2d
    fmul v1.2d, v1.2d, v30.2d
    ldr q0, [x6, x13]
    fadd v0.2d, v0.2d, v1.2d
    str q0, [x6, x13]
    add x15, x15, #16
    add x13, x13, #16
    sub x14, x14, #2
    b .Lpair
.Ltail:
    cbz x14, .Lnext_level
    ldr d1, [x5, x15]
    ldr d2, [x4, x15]
    fmul d1, d1, d2
    fmul d1, d1, d30
    ldr d0, [x6, x13]
    fadd d0, d0, d1
    str d0, [x6, x13]
.Lnext_level:
    add x12, x12, x7
    subs x11, x11, #1
    b.ne .Llevel
.Lreturn:
    ret
.size gptco3_, .-gptco3_
.section .note.GNU-stack,"",%progbits

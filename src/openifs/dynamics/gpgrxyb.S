/* Pressure-gradient weights from the frozen GPGRXYB contract.
 * Inputs use pascals and inverse pascals. Each FP64 operation rounds once.
 * The ABI and buffer bounds are defined in the model contract. */
.text
.p2align 4
.global gpgrxyb_
.type gpgrxyb_, %function
gpgrxyb_:
    sub sp, sp, #160
    stp x19, x20, [sp, #80]
    stp x21, x22, [sp, #96]
    stp x23, x24, [sp, #112]
    stp x25, x26, [sp, #128]
    stp x27, x28, [sp, #144]
    ldrsw x26, [x0]
    ldrsw x20, [x1]
    ldrsw x19, [x2]
    ldrsw x28, [x3]
    cbz x28, .Lreturn
    sub x19, x19, x20
    adds x19, x19, #1
    b.le .Lreturn
    sub x20, x20, #1
    lsl x20, x20, #3
    lsl x26, x26, #3
    mul x9, x26, x28
    mov x22, x7
    ldr x23, [sp, #160]
    ldr x7, [sp, #168]
    ldr x21, [sp, #176]
    ldr w17, [x4]
    ldr w14, [x6, #52]
    cbnz w14, .Lfinite_setup
    ldr w14, [x6, #4]
    mov w16, #1
    cbz w14, .Lconventional_setup
    mov w16, #2
    b .Lconventional_setup
.Lfinite_setup:
    mov w16, #0
    add x4, x5, #448
    b .Lcoefficient_setup
.Lconventional_setup:
    add x4, x5, #192
.Lcoefficient_setup:
    ldr x24, [x4]
    ldr x8, [x4, #48]
    mov x0, #1
    sub x8, x0, x8
    add x24, x24, x8, lsl #3
    cmp w16, #1
    b.ne .Lfield_setup
    ldr x25, [x5, #64]
    ldr x8, [x5, #112]
    sub x8, x0, x8
    add x25, x25, x8, lsl #3
.Lfield_setup:
    adrp x14, :got:__intdyn_mod_MOD_yytxyb
    ldr x14, [x14, :got_lo12:__intdyn_mod_MOD_yytxyb]
    adrp x15, :got:__intdyn_mod_MOD_yytxybder
    ldr x15, [x15, :got_lo12:__intdyn_mod_MOD_yytxybder]
    ldrsw x8, [x14, #16]
    sub x8, x8, #1
    mul x8, x8, x9
    add x11, x7, x8
    cbnz w16, .Lconventional_fields
    ldrsw x8, [x14, #4]
    sub x8, x8, #1
    mul x8, x8, x9
    add x10, x7, x8
    ldrsw x8, [x14, #8]
    sub x8, x8, #1
    mul x8, x8, x9
    add x12, x7, x8
    b .Loutput_setup
.Lconventional_fields:
    ldrsw x8, [x14, #24]
    sub x8, x8, #1
    mul x8, x8, x9
    add x10, x7, x8
    cmp w16, #1
    b.ne .Lapproximate_fields
    ldrsw x8, [x14, #20]
    sub x8, x8, #1
    mul x8, x8, x9
    add x12, x7, x8
    b .Loutput_setup
.Lapproximate_fields:
    ldrsw x8, [x14, #8]
    sub x8, x8, #1
    mul x8, x8, x9
    add x12, x7, x8
    ldrsw x8, [x14, #12]
    sub x8, x8, #1
    mul x8, x8, x9
    add x13, x7, x8
.Loutput_setup:
    ldrsw x8, [x15, #0]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #0]
    ldrsw x8, [x15, #4]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #8]
    cbz w16, .Loptional_setup
    ldrsw x8, [x15, #8]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #16]
    ldrsw x8, [x15, #12]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #24]
    ldrsw x8, [x15, #16]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #32]
    ldrsw x8, [x15, #20]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #40]
.Loptional_setup:
    cbz w17, .Llevels
    ldrsw x8, [x15, #24]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #48]
    cbz w16, .Llevels
    ldrsw x8, [x15, #28]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #56]
    ldrsw x8, [x15, #32]
    sub x8, x8, #1
    mul x8, x8, x9
    add x8, x21, x8
    str x8, [sp, #64]
.Llevels:
    mov x27, x20
.Llevel:
    ldr d30, [x24], #8
    cbz w16, .Lcoefficient_ready
    fneg d30, d30
.Lcoefficient_ready:
    dup v30.2d, v30.d[0]
    cmp w16, #1
    b.ne .Lrow
    ldr d31, [x25], #8
    dup v31.2d, v31.d[0]
.Lrow:
    mov x0, x27
    mov x1, x20
    mov x2, x19
.Lpair:
    cmp x2, #2
    b.lt .Ltail
    ldr q1, [x10, x0]
    ldr q2, [x11, x0]
    ldr q5, [x22, x1]
    ldr q6, [x23, x1]
    fmul v16.2d, v30.2d, v1.2d
    cbnz w16, .Lpair_depth_ready
    ldr q3, [x12, x0]
    fsub v16.2d, v16.2d, v2.2d
    fmul v16.2d, v16.2d, v3.2d
.Lpair_depth_ready:
    fmul v18.2d, v16.2d, v5.2d
    fmul v19.2d, v16.2d, v6.2d
    ldr x14, [sp, #0]
    str q18, [x14, x0]
    ldr x14, [sp, #8]
    str q19, [x14, x0]
    cbz w17, .Lpair_alpha
    ldr x14, [sp, #48]
    str q16, [x14, x0]
.Lpair_alpha:
    cbz w16, .Lpair_done
    ldr q3, [x12, x0]
    cmp w16, #1
    b.ne .Lpair_approximate
    fmul v21.2d, v31.2d, v3.2d
    fsub v20.2d, v21.2d, v2.2d
    b .Lpair_alpha_ready
.Lpair_approximate:
    ldr q4, [x13, x0]
    fmul v20.2d, v16.2d, v4.2d
    fdiv v20.2d, v20.2d, v3.2d
    fadd v21.2d, v20.2d, v2.2d
.Lpair_alpha_ready:
    fmul v22.2d, v21.2d, v5.2d
    fmul v23.2d, v21.2d, v6.2d
    fmul v24.2d, v20.2d, v5.2d
    fmul v25.2d, v20.2d, v6.2d
    ldr x14, [sp, #32]
    str q22, [x14, x0]
    ldr x14, [sp, #40]
    str q23, [x14, x0]
    ldr x14, [sp, #16]
    str q24, [x14, x0]
    ldr x14, [sp, #24]
    str q25, [x14, x0]
    cbz w17, .Lpair_done
    ldr x14, [sp, #56]
    str q20, [x14, x0]
    ldr x14, [sp, #64]
    str q21, [x14, x0]
.Lpair_done:
    add x0, x0, #16
    add x1, x1, #16
    sub x2, x2, #2
    b .Lpair
.Ltail:
    cbz x2, .Lnext_level
    ldr d1, [x10, x0]
    ldr d2, [x11, x0]
    ldr d5, [x22, x1]
    ldr d6, [x23, x1]
    fmul d16, d30, d1
    cbnz w16, .Lscalar_depth_ready
    ldr d3, [x12, x0]
    fsub d16, d16, d2
    fmul d16, d16, d3
.Lscalar_depth_ready:
    fmul d18, d16, d5
    fmul d19, d16, d6
    ldr x14, [sp, #0]
    str d18, [x14, x0]
    ldr x14, [sp, #8]
    str d19, [x14, x0]
    cbz w17, .Lscalar_alpha
    ldr x14, [sp, #48]
    str d16, [x14, x0]
.Lscalar_alpha:
    cbz w16, .Lscalar_done
    ldr d3, [x12, x0]
    cmp w16, #1
    b.ne .Lscalar_approximate
    fmul d21, d31, d3
    fsub d20, d21, d2
    b .Lscalar_alpha_ready
.Lscalar_approximate:
    ldr d4, [x13, x0]
    fmul d20, d16, d4
    fdiv d20, d20, d3
    fadd d21, d20, d2
.Lscalar_alpha_ready:
    fmul d22, d21, d5
    fmul d23, d21, d6
    fmul d24, d20, d5
    fmul d25, d20, d6
    ldr x14, [sp, #32]
    str d22, [x14, x0]
    ldr x14, [sp, #40]
    str d23, [x14, x0]
    ldr x14, [sp, #16]
    str d24, [x14, x0]
    ldr x14, [sp, #24]
    str d25, [x14, x0]
    cbz w17, .Lscalar_done
    ldr x14, [sp, #56]
    str d20, [x14, x0]
    ldr x14, [sp, #64]
    str d21, [x14, x0]
.Lscalar_done:
.Lnext_level:
    add x27, x27, x26
    subs x28, x28, #1
    b.ne .Llevel
.Lreturn:
    ldp x19, x20, [sp, #80]
    ldp x21, x22, [sp, #96]
    ldp x23, x24, [sp, #112]
    ldp x25, x26, [sp, #128]
    ldp x27, x28, [sp, #144]
    add sp, sp, #160
    ret
.size gpgrxyb_, .-gpgrxyb_
.section .note.GNU-stack,"",%progbits

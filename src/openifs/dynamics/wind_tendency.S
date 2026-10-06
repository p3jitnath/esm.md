/* Complete horizontal-wind tendency body from its frozen md2asm contract.
 * Pressure, Coriolis and every Rayleigh branch retain separate FP64 rounding.
 * Coefficients honour the measured Fortran allocation's lower bound.
 * Local damping values stay in registers, with all four final outputs stored. */
.text
.p2align 4
.global gp_tndlagadiab_uv_
.type gp_tndlagadiab_uv_,%function
gp_tndlagadiab_uv_:
    stp x19,x20,[sp,#-80]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    ldp x19,x20,[sp,#80]
    ldp x21,x22,[sp,#96]
    ldp x23,x24,[sp,#112]
    ldp x25,x26,[sp,#128]
    mov x12,x2
    ldrsw x27,[x0,#5144]
    lsl x27,x27,#3
    ldrsw x2,[x0,#5224]
    cbz x2,.Lreturn
    ldrsw x10,[x4]
    ldrsw x9,[x5]
    sub x28,x9,x10
    adds x28,x28,#1
    ble .Lreturn
    sub x10,x10,#1
    lsl x10,x10,#3
    mul x9,x27,x2
    mov x11,x22
    ldrsw x8,[x1,#1012]
    sub x8,x8,#1
    madd x22,x8,x9,x11
    ldrsw x8,[x1,#1016]
    sub x8,x8,#1
    madd x5,x8,x9,x11
    mov w17,#0
    ldr w8,[x3,#2132]
    cbz w8,.Lno_friction
    ldr w8,[x12,#24]
    cbnz w8,.Lno_friction
    ldr w8,[x3,#2136]
    cbnz w8,.Lisotropic
    adrp x8,:got:__yomct0_MOD_lrplane
    ldr x8,[x8,:got_lo12:__yomct0_MOD_lrplane]
    ldr w8,[x8]
    cbnz w8,.Ltilted
    ldr w8,[x0,#7520]
    cmp w8,#1
    b.ne .Ltilted
    mov w17,#2
    b .Lcoefficient
.Lisotropic:
    mov w17,#1
    b .Lcoefficient
.Ltilted:
    mov w17,#3
.Lcoefficient:
    ldr x8,[x3,#2416]
    ldr x3,[x3,#2368]
    mov x9,#1
    sub x8,x9,x8
    add x3,x3,x8,lsl #3
    b .Lmode_ready
.Lno_friction:
    mov x3,xzr
.Lmode_ready:
    mov x1,x10
    movi v30.2d,#0
.Llevel:
    cbz w17,.Llevel_ready
    ldr d31,[x3],#8
    dup v31.2d,v31.d[0]
.Llevel_ready:
    mov x4,x1
    mov x9,x10
    mov x8,x28
    cmp x8,#2
    b.lt .Ltail
.Lpair:
    ldr q0,[x22,x4]
    ldr q1,[x5,x4]
    ldr q2,[x20,x4]
    ldr q3,[x21,x4]
    ldr q4,[x6,x9]
    movi v16.2d,#0
    movi v17.2d,#0
    cbz w17,.Lpair_total
    cmp w17,#3
    b.eq .Lpair_tilted
    fneg v18.2d,v31.2d
    fmul v16.2d,v18.2d,v0.2d
    cmp w17,#1
    b.ne .Lpair_total
    fmul v17.2d,v18.2d,v1.2d
    b .Lpair_total
.Lpair_tilted:
    ldr q5,[x7,x9]
    ldr q6,[x19,x9]
    fmul v18.2d,v31.2d,v6.2d
    fmul v18.2d,v18.2d,v6.2d
    fmul v19.2d,v30.2d,v5.2d
    fmul v19.2d,v19.2d,v5.2d
    fadd v18.2d,v18.2d,v19.2d
    fneg v18.2d,v18.2d
    fmul v16.2d,v18.2d,v0.2d
    fsub v20.2d,v31.2d,v30.2d
    fmul v20.2d,v20.2d,v6.2d
    fmul v20.2d,v20.2d,v5.2d
    fmul v21.2d,v20.2d,v1.2d
    fadd v16.2d,v16.2d,v21.2d
    fmul v18.2d,v31.2d,v5.2d
    fmul v18.2d,v18.2d,v5.2d
    fmul v19.2d,v30.2d,v6.2d
    fmul v19.2d,v19.2d,v6.2d
    fadd v18.2d,v18.2d,v19.2d
    fmul v18.2d,v18.2d,v1.2d
    fmul v17.2d,v20.2d,v0.2d
    fsub v17.2d,v17.2d,v18.2d
.Lpair_total:
    fneg v18.2d,v2.2d
    fadd v18.2d,v18.2d,v16.2d
    fmul v19.2d,v4.2d,v1.2d
    fadd v19.2d,v18.2d,v19.2d
    fneg v20.2d,v3.2d
    fadd v20.2d,v20.2d,v17.2d
    fmul v21.2d,v4.2d,v0.2d
    fsub v21.2d,v20.2d,v21.2d
    str q19,[x23,x4]
    str q21,[x24,x4]
    str q18,[x25,x4]
    str q20,[x26,x4]
    add x4,x4,#16
    add x9,x9,#16
    sub x8,x8,#2
    cmp x8,#2
    b.ge .Lpair
.Ltail:
    cbz x8,.Llevel_end
    ldr d0,[x22,x4]
    ldr d1,[x5,x4]
    ldr d2,[x20,x4]
    ldr d3,[x21,x4]
    ldr d4,[x6,x9]
    fmov d16,xzr
    fmov d17,xzr
    cbz w17,.Lscalar_total
    cmp w17,#3
    b.eq .Lscalar_tilted
    fneg d18,d31
    fmul d16,d18,d0
    cmp w17,#1
    b.ne .Lscalar_total
    fmul d17,d18,d1
    b .Lscalar_total
.Lscalar_tilted:
    ldr d5,[x7,x9]
    ldr d6,[x19,x9]
    fmul d18,d31,d6
    fmul d18,d18,d6
    fmul d19,d30,d5
    fmul d19,d19,d5
    fadd d18,d18,d19
    fneg d18,d18
    fmul d16,d18,d0
    fsub d20,d31,d30
    fmul d20,d20,d6
    fmul d20,d20,d5
    fmul d21,d20,d1
    fadd d16,d16,d21
    fmul d18,d31,d5
    fmul d18,d18,d5
    fmul d19,d30,d6
    fmul d19,d19,d6
    fadd d18,d18,d19
    fmul d18,d18,d1
    fmul d17,d20,d0
    fsub d17,d17,d18
.Lscalar_total:
    fneg d18,d2
    fadd d18,d18,d16
    fmul d19,d4,d1
    fadd d19,d18,d19
    fneg d20,d3
    fadd d20,d20,d17
    fmul d21,d4,d0
    fsub d21,d20,d21
    str d19,[x23,x4]
    str d21,[x24,x4]
    str d18,[x25,x4]
    str d20,[x26,x4]
.Llevel_end:
    add x1,x1,x27
    subs x2,x2,#1
    b.ne .Llevel
.Lreturn:
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x19,x20,[sp],#80
    ret
.size gp_tndlagadiab_uv_,.-gp_tndlagadiab_uv_
.section .note.GNU-stack,"",%progbits

// Complete GPHPRE from contract 1.0, emitted directly as AArch64 source.
// Pressure uses Pa. Every FP64 arithmetic instruction retains its rounding point.
// The 416-byte frame preserves x19-x29 and the low 64 bits of v8-v15.
// Private scratch holds every coefficient field. Library log/exp are frozen.
// Standard calloc, memcpy and free manage bytes and supply no numerical stage.
.text
.p2align 4
.global gphpre_
.type gphpre_, %function
.macro coefficient descriptor, slot
    ldr x9, [x19, #\descriptor]
    ldr x10, [x19, #(\descriptor+48)]
    sub x9, x9, x10, lsl #3
    str x9, [sp, #\slot]
.endm
.macro store_field value, slot
    ldr x9, [sp, #\slot]
    str \value, [x9, x24]
.endm
.macro load_field value, slot
    ldr x9, [sp, #\slot]
    ldr \value, [x9, x24]
.endm
gphpre_:
    ldr w9, [x1]
    cbz w9, .Lhp_return
    ldr w10, [x2]
    ldr w11, [x3]
    cmp w11, w10
    b.lt .Lhp_return
    ldr x8, [sp]
    sub sp, sp, #416
    stp x19, x20, [sp, #256]
    stp x21, x22, [sp, #272]
    stp x23, x24, [sp, #288]
    stp x25, x26, [sp, #304]
    stp x27, x28, [sp, #320]
    stp x29, x30, [sp, #336]
    stp d8, d9, [sp, #352]
    stp d10, d11, [sp, #368]
    stp d12, d13, [sp, #384]
    stp d14, d15, [sp, #400]
    str x7, [sp, #0]
    str x8, [sp, #8]
    uxtw x9, w9
    str x9, [sp, #16]
    sub w10, w10, #1
    uxtw x10, w10
    lsl x10, x10, #3
    str x10, [sp, #24]
    uxtw x11, w11
    lsl x11, x11, #3
    str x11, [sp, #32]
    mov x19, x4
    mov x20, x5
    mov x21, x6
    ldr w9, [x0]
    uxtw x23, w9
    lsl x23, x23, #3
    coefficient 128, 144
    coefficient 64, 152
    orr x9, x7, x8
    cbz x9, .Lhp_half_start
    ldr w9, [x20, #4]
    sxtw x9, w9
    str x9, [sp, #48]
    ldr w9, [x20, #52]
    str x9, [sp, #56]
    ldr d0, [x20, #8]
    str d0, [sp, #232]
    adrp x9, :got:__yomvert_MOD_toppres
    ldr x9, [x9, :got_lo12:__yomvert_MOD_toppres]
    ldr d3, [x9]
    str d3, [sp, #208]
    mov x9, #1
    str x9, [sp, #40]
    ldr x9, [sp, #16]
    madd x28, x9, x23, x21
    ldr x26, [sp, #24]
    ldr x27, [sp, #32]
    ldr x9, [sp, #144]
    ldr d1, [x9]
    ldr x9, [sp, #152]
    ldr d2, [x9]
.Lhp_top_selection:
    ldr d0, [x28, x26]
    fmul d0, d2, d0
    fadd d0, d1, d0
    fcmp d0, d3
    b.gt .Lhp_top_next
    mov x9, #2
    str x9, [sp, #40]
.Lhp_top_next:
    add x26, x26, #8
    cmp x26, x27
    b.lt .Lhp_top_selection
.Lhp_half_start:
    mov x25, #0
    ldr x9, [sp, #16]
    madd x28, x9, x23, x21
.Lhp_half_level:
    ldr x9, [sp, #144]
    ldr d1, [x9, x25, lsl #3]
    ldr x9, [sp, #152]
    ldr d2, [x9, x25, lsl #3]
    madd x12, x25, x23, x21
    ldr x26, [sp, #24]
    ldr x27, [sp, #32]
.Lhp_half_column:
    ldr d0, [x28, x26]
    fmul d0, d2, d0
    fadd d0, d1, d0
    str d0, [x12, x26]
    add x26, x26, #8
    cmp x26, x27
    b.lt .Lhp_half_column
    add x25, x25, #1
    ldr x9, [sp, #16]
    cmp x25, x9
    b.lt .Lhp_half_level
    ldr x9, [sp, #0]
    ldr x10, [sp, #8]
    orr x9, x9, x10
    cbz x9, .Lhp_restore
    ldr x9, [sp, #16]
    mul x9, x9, x23
    str x9, [sp, #64]
    adrp x10, :got:__intdyn_mod_MOD_yytxyb
    ldr x10, [x10, :got_lo12:__intdyn_mod_MOD_yytxyb]
    ldr w11, [x10, #28]
    uxtw x11, w11
    mul x1, x9, x11
    str x1, [sp, #72]
    mov x0, #1
    bl calloc
    cbz x0, .Lhp_allocation_failed
    mov x22, x0
    adrp x10, :got:__intdyn_mod_MOD_yytxyb
    ldr x10, [x10, :got_lo12:__intdyn_mod_MOD_yytxyb]
    ldr x11, [sp, #64]
    mov x12, #0
    add x13, sp, #80
.Lhp_field_pointer:
    ldrsw x9, [x10, x12, lsl #2]
    sub x9, x9, #1
    madd x9, x9, x11, x22
    str x9, [x13, x12, lsl #3]
    add x12, x12, #1
    cmp x12, #7
    b.lt .Lhp_field_pointer
    coefficient 448, 184
    ldr x9, [sp, #56]
    cbz x9, .Lhp_conventional_start
    coefficient 256, 160
    coefficient 320, 168
    coefficient 384, 176
    ldr x26, [sp, #24]
    ldr x27, [sp, #32]
.Lhp_fe_column:
    ldr x9, [sp, #16]
    madd x9, x9, x23, x21
    ldr d15, [x9, x26]
    mov x25, #1
    mov x24, x26
    add x28, x21, x23
    add x28, x28, x26
.Lhp_fe_level:
    ldr x9, [sp, #184]
    ldr d0, [x9, x25, lsl #3]
    fmul d0, d0, d15
    ldr x9, [sp, #176]
    ldr d1, [x9, x25, lsl #3]
    fadd d10, d1, d0
    fmov d0, #1.0
    fdiv d11, d0, d10
    ldr x9, [sp, #168]
    ldr d2, [x9, x25, lsl #3]
    fmul d0, d2, d15
    ldr x9, [sp, #160]
    ldr d1, [x9, x25, lsl #3]
    fadd d9, d1, d0
    fmov d0, #1.0
    fdiv d13, d0, d9
    fmul d12, d10, d13
    fmul d14, d2, d13
    ldr d8, [x28]
    fsub d0, d8, d9
    fmul d0, d0, d13
    store_field d10, 80
    store_field d11, 88
    store_field d12, 96
    store_field d14, 112
    store_field d0, 104
    add x25, x25, #1
    add x24, x24, x23
    add x28, x28, x23
    ldr x9, [sp, #16]
    cmp x25, x9
    b.le .Lhp_fe_level
    add x26, x26, #8
    cmp x26, x27
    b.lt .Lhp_fe_column
    b .Lhp_coefficients_done
.Lhp_conventional_start:
    // VC is used only when a normal layer exists.
    ldr x9, [sp, #40]
    ldr x10, [sp, #16]
    cmp x9, x10
    b.gt .Lhp_conventional_columns
    coefficient 192, 192
.Lhp_conventional_columns:
    ldr x26, [sp, #24]
    ldr x27, [sp, #32]
.Lhp_conventional_column:
    ldr x25, [sp, #40]
    madd x28, x25, x23, x21
    add x28, x28, x26
    sub x9, x25, #1
    madd x24, x9, x23, x26
    ldr x9, [sp, #48]
    cbnz x9, .Lhp_normal_test
    sub x9, x28, x23
    ldr d9, [x9]
    fmov d0, #1.0
    fdiv d14, d0, d9
.Lhp_normal_test:
    ldr x9, [sp, #16]
    cmp x25, x9
    b.gt .Lhp_top_test
.Lhp_normal_level:
    ldr d8, [x28]
    sub x9, x28, x23
    ldr d9, [x9]
    fsub d10, d8, d9
    fmov d0, #1.0
    fdiv d11, d0, d10
    fdiv d13, d0, d8
    ldr x9, [sp, #48]
    cbnz x9, .Lhp_normal_approximate
    fmul d0, d8, d14
    bl log
    fmov d12, d0
    fmul d1, d13, d14
    fmov d14, d13
    b .Lhp_normal_weights
.Lhp_normal_approximate:
    fmul d1, d8, d9
    fdiv d1, d0, d1
    fsqrt d2, d1
    fmul d12, d10, d2
.Lhp_normal_weights:
    store_field d1, 128
    fmul d0, d9, d11
    fmul d0, d0, d12
    fmov d1, #1.0
    fsub d15, d1, d0
    ldr x9, [sp, #192]
    ldr d0, [x9, x25, lsl #3]
    fmul d0, d0, d12
    fmul d0, d0, d11
    ldr x9, [sp, #184]
    ldr d1, [x9, x25, lsl #3]
    fadd d0, d1, d0
    fmul d0, d11, d0
    store_field d10, 80
    store_field d11, 88
    store_field d12, 96
    store_field d13, 120
    store_field d15, 104
    store_field d0, 112
    add x25, x25, #1
    add x24, x24, x23
    add x28, x28, x23
    ldr x9, [sp, #16]
    cmp x25, x9
    b.le .Lhp_normal_level
.Lhp_top_test:
    ldr x9, [sp, #40]
    cmp x9, #2
    b.ne .Lhp_next_conventional_column
    mov x25, #1
    mov x24, x26
    add x28, x21, x23
    add x28, x28, x26
    ldr d8, [x28]
    ldr x9, [sp, #48]
    cbnz x9, .Lhp_top_approximate
    sub x9, x28, x23
    ldr d9, [x9]
    fsub d10, d8, d9
    fmov d0, #1.0
    fdiv d11, d0, d10
    ldr d2, [sp, #208]
    fdiv d0, d8, d2
    bl log
    fmov d12, d0
    ldr d15, [sp, #232]
    fmov d0, #1.0
    fdiv d13, d0, d8
    ldr d2, [sp, #208]
    fmul d1, d8, d2
    fdiv d1, d0, d1
    b .Lhp_top_weights
.Lhp_top_approximate:
    fmov d10, d8
    cmp x9, #1
    b.ne .Lhp_top_mode_two
    adrp x9, :got:__yomcst_MOD_rd
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rd]
    ldr d0, [x9]
    adrp x9, :got:__yomcst_MOD_rcvd
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rcvd]
    ldr d1, [x9]
    fdiv d0, d1, d0
    fmov d1, #2.0
    fadd d12, d1, d0
    b .Lhp_top_approximate_weights
.Lhp_top_mode_two:
    add x10, x24, x23
    ldr x9, [sp, #80]
    ldr d0, [x9, x10]
    fdiv d0, d10, d0
    ldr x9, [sp, #96]
    ldr d1, [x9, x10]
    fmul d0, d1, d0
    ldr d1, [x28, x23]
    fdiv d1, d1, d8
    fsqrt d1, d1
    fmul d0, d0, d1
    fmov d1, #1.0
    fadd d12, d1, d0
.Lhp_top_approximate_weights:
    fmov d15, #1.0
    fdiv d11, d15, d10
    fdiv d13, d15, d8
    fmul d1, d12, d11
    fmul d1, d1, d1
.Lhp_top_weights:
    store_field d1, 128
    ldr x9, [sp, #184]
    ldr d0, [x9, #8]
    fmul d0, d11, d0
    store_field d10, 80
    store_field d11, 88
    store_field d12, 96
    store_field d13, 120
    store_field d15, 104
    store_field d0, 112
.Lhp_next_conventional_column:
    add x26, x26, #8
    cmp x26, x27
    b.lt .Lhp_conventional_column
.Lhp_coefficients_done:
    ldr x0, [sp, #0]
    cbz x0, .Lhp_full_test
    mov x1, x22
    ldr x2, [sp, #72]
    bl memcpy
.Lhp_full_test:
    ldr x9, [sp, #8]
    cbz x9, .Lhp_free
    ldr x26, [sp, #24]
    ldr x27, [sp, #32]
.Lhp_full_column:
    mov x25, #1
    mov x24, x26
    add x28, x21, x23
    add x28, x28, x26
.Lhp_full_level:
    ldr x9, [sp, #56]
    cbz x9, .Lhp_full_conventional
    ldr x9, [sp, #16]
    madd x9, x9, x23, x21
    ldr d15, [x9, x26]
    ldr x9, [sp, #168]
    ldr d0, [x9, x25, lsl #3]
    fmul d0, d0, d15
    ldr x9, [sp, #160]
    ldr d1, [x9, x25, lsl #3]
    fadd d0, d1, d0
    b .Lhp_full_store
.Lhp_full_conventional:
    ldr d8, [x28]
    ldr x9, [sp, #48]
    cbnz x9, .Lhp_full_approximate
    ldr w9, [x20]
    cbz w9, .Lhp_full_identric
    sub x9, x28, x23
    ldr d0, [x9]
    fadd d0, d0, d8
    fmov d1, #0.5
    fmul d0, d0, d1
    b .Lhp_full_store
.Lhp_full_identric:
    load_field d0, 104
    fneg d0, d0
    bl exp
    fmul d0, d0, d8
    b .Lhp_full_store
.Lhp_full_approximate:
    ldr x9, [sp, #40]
    cmp x25, x9
    b.lt .Lhp_full_closed_top
    load_field d0, 104
    fmov d1, #1.0
    fsub d0, d1, d0
    fmul d0, d0, d8
    b .Lhp_full_store
.Lhp_full_closed_top:
    load_field d1, 96
    fdiv d0, d8, d1
.Lhp_full_store:
    ldr x9, [sp, #8]
    str d0, [x9, x24]
    add x25, x25, #1
    add x24, x24, x23
    add x28, x28, x23
    ldr x9, [sp, #16]
    cmp x25, x9
    b.le .Lhp_full_level
    add x26, x26, #8
    cmp x26, x27
    b.lt .Lhp_full_column
.Lhp_free:
    mov x0, x22
    bl free
.Lhp_restore:
    ldp d8, d9, [sp, #352]
    ldp d10, d11, [sp, #368]
    ldp d12, d13, [sp, #384]
    ldp d14, d15, [sp, #400]
    ldp x19, x20, [sp, #256]
    ldp x21, x22, [sp, #272]
    ldp x23, x24, [sp, #288]
    ldp x25, x26, [sp, #304]
    ldp x27, x28, [sp, #320]
    ldp x29, x30, [sp, #336]
    add sp, sp, #416
.Lhp_return:
    ret
.Lhp_allocation_failed:
    bl abort
.size gphpre_, .-gphpre_
.section .note.GNU-stack,"",%progbits

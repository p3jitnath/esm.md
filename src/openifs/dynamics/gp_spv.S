// Complete GP_SPV surface-pressure conversion from contract revision 1.0.
// GNU 12.3 AArch64 ABI uses eight address registers and eleven stack addresses.
// exp is the shared frozen scalar library. No driver provides a numerical stage.
// Six disjoint FP64 outputs preserve inactive rows and columns.
// The 160-byte frame keeps previous pointers, range and x19-x29 obligations.
.text
.p2align 4
.global gp_spv_
.type gp_spv_, %function
gp_spv_:
    ldr w9, [x5]
    ldr w10, [x6]
    cmp w10, w9
    b.lt .Lspv_return
    sub sp, sp, #160
    stp x19, x20, [sp, #64]
    stp x21, x22, [sp, #80]
    stp x23, x24, [sp, #96]
    stp x25, x26, [sp, #112]
    stp x27, x28, [sp, #128]
    stp x29, x30, [sp, #144]
    sub w10, w10, w9
    add w10, w10, #1
    uxtw x26, w10
    str x26, [sp, #56]
    sub w9, w9, #1
    lsl x12, x9, #3
    str x12, [sp, #48]
    ldr w9, [x0, #5144]
    ldr w10, [x0, #5224]
    umull x11, w9, w10
    lsl x11, x11, #3
    add x19, x7, x12
    ldr x20, [sp, #160]
    ldr x21, [sp, #168]
    add x20, x20, x12
    add x21, x21, x12
    ldr x22, [sp, #200]
    ldr x23, [sp, #208]
    ldr x24, [sp, #216]
    add x22, x22, x11
    add x22, x22, x12
    add x23, x23, x12
    add x24, x24, x12
    // Previous-time-level rule uses every upstream control.
    ldr w9, [x4]
    eor w9, w9, #1
    ldr w10, [x3]
    orr w9, w9, w10
    ldr w10, [x2, #8]
    orr w9, w9, w10
    ldr w10, [x2, #20]
    eor w10, w10, #1
    ldr w13, [x2, #336]
    ldr w14, [x1, #2580]
    cmp w14, #0
    cset w14, gt
    and w13, w13, w14
    orr w10, w10, w13
    and w28, w9, w10
    cbz w28, .Lspv_column
    ldr x8, [sp, #176]
    add x8, x8, x12
    str x8, [sp, #0]
    ldr x8, [sp, #184]
    add x8, x8, x12
    str x8, [sp, #8]
    ldr x8, [sp, #192]
    add x8, x8, x12
    str x8, [sp, #16]
    ldr x8, [sp, #224]
    add x8, x8, x11
    add x8, x8, x12
    str x8, [sp, #24]
    ldr x8, [sp, #232]
    add x8, x8, x12
    str x8, [sp, #32]
    ldr x8, [sp, #240]
    add x8, x8, x12
    str x8, [sp, #40]
.Lspv_column:
    ldr d0, [x19], #8
    bl exp
    str d0, [x22], #8
    ldr d1, [x20], #8
    fmul d1, d1, d0
    str d1, [x23], #8
    ldr d1, [x21], #8
    fmul d1, d1, d0
    str d1, [x24], #8
    subs x26, x26, #1
    b.ne .Lspv_column
    cbz w28, .Lspv_restore
    mov w28, #0
    ldp x19, x20, [sp, #0]
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldr x26, [sp, #56]
    b .Lspv_column
.Lspv_restore:
    ldp x19, x20, [sp, #64]
    ldp x21, x22, [sp, #80]
    ldp x23, x24, [sp, #96]
    ldp x25, x26, [sp, #112]
    ldp x27, x28, [sp, #128]
    ldp x29, x30, [sp, #144]
    add sp, sp, #160
.Lspv_return:
    ret
.size gp_spv_, .-gp_spv_
.section .note.GNU-stack,"",%progbits

// Complete STATE_TYPE_UPDATE_VIEW: select live views and copy four cloud planes.
// Contract: skills/md2asm/references/openifs/support/physics_state_complete_update.md.
// x0 is STATE1240, w1 is the live block; w0 returns zero or pre-write refusal one.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_update_physics_state
.type md2asm_update_physics_state,%function
md2asm_update_physics_state:
    cbz x0, .Lupdate_reject_early
    tst x0, #7
    b.ne .Lupdate_reject_early
    cmp w1, #1
    b.lt .Lupdate_reject_early
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x19, x0
    mov w20, w1
    adrp x21, .Lupdate_rules
    add x21, x21, :lo12:.Lupdate_rules
    mov w22, #12
// Check each selected last-dimension bound before changing any state view.
.Lupdate_validate:
    ldr w9, [x21]
    ldr x1, [x19, w9, uxtw]
    cbz x1, .Lupdate_validate_next
    tst x1, #7
    b.ne .Lupdate_reject
    ldr w3, [x21, #8]
    mov x4, #72
    madd x4, x3, x4, x1
    add x4, x4, #100
    ldr w5, [x4]
    cbz w5, .Lupdate_validate_next
    sxtw x6, w20
    ldr w5, [x4, #4]
    cbz w5, .Lupdate_validate_storage
    mov x6, #1
.Lupdate_validate_storage:
    ldr w5, [x4, #8]
    cbnz w5, .Lupdate_validate_owned
    mov x4, #24
    madd x4, x3, x4, x1
    add x4, x4, #16
    b .Lupdate_validate_bounds
.Lupdate_validate_owned:
    mov x4, #48
    madd x4, x3, x4, x1
    add x4, x4, #56
.Lupdate_validate_bounds:
    sub x5, x3, #1
    mov x7, #24
    madd x7, x5, x7, x4
    ldp x8, x9, [x7, #48]
    cmp x6, x8
    b.lt .Lupdate_reject
    cmp x6, x9
    b.gt .Lupdate_reject
.Lupdate_validate_next:
    add x21, x21, #24
    subs w22, w22, #1
    b.ne .Lupdate_validate
    sub x21, x21, #288
    mov w22, #12
.Lupdate_next:
    ldp w9, w24, [x21]
    ldp w23, w25, [x21, #8]
    ldr w26, [x21, #16]
    ldr x1, [x19, w9, uxtw]
    cbz x1, .Lupdate_skip
    add x0, x19, w24, uxtw
    mov w2, w20
    cmp w23, #4
    b.eq .Lupdate_cloud_view
    bl md2asm_physics_field_view_3d
    b .Lupdate_after_view
.Lupdate_cloud_view:
    bl md2asm_physics_field_view_4d
.Lupdate_after_view:
    tbnz w25, #31, .Lupdate_skip
    ldr w9, [x19, w25, uxtw]
    cbz w9, .Lupdate_skip
// A view base addresses its first cell. The strides are in FP64 elements.
    add x12, x19, w24, uxtw
    ldr x0, [x12]
    ldr x1, [x19, #1000]
    ldr x13, [x19, #1088]
    uxtw x14, w26
    mul x13, x13, x14
    add x1, x1, x13, lsl #3
    ldr x2, [x12, #40]
    ldr x3, [x12, #64]
    ldr x4, [x19, #1040]
    ldr x5, [x19, #1064]
    lsl x2, x2, #3
    lsl x3, x3, #3
    lsl x4, x4, #3
    lsl x5, x5, #3
    ldp x6, x7, [x12, #48]
    sub x6, x7, x6
    add x6, x6, #1
    ldp x7, x8, [x12, #72]
    sub x7, x8, x7
    add x7, x7, #1
    cmp x6, #0
    b.le .Lupdate_skip
    cmp x7, #0
    b.le .Lupdate_skip
.Lupdate_copy_column:
    mov x8, x0
    mov x9, x1
    mov x10, x6
.Lupdate_copy_row:
    ldr x11, [x8]
    str x11, [x9]
    add x8, x8, x2
    add x9, x9, x4
    subs x10, x10, #1
    b.ne .Lupdate_copy_row
    add x0, x0, x3
    add x1, x1, x5
    subs x7, x7, #1
    b.ne .Lupdate_copy_column
.Lupdate_skip:
    add x21, x21, #24
    subs w22, w22, #1
    b.ne .Lupdate_next
    mov w0, #0
    b .Lupdate_return
.Lupdate_reject:
    mov w0, #1
.Lupdate_return:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.Lupdate_reject_early:
    mov w0, #1
    ret
.size md2asm_update_physics_state, .-md2asm_update_physics_state
.section .rodata
.p2align 3
.Lupdate_rules:
    .word 1112,32,3,-1,-1,0
    .word 1120,120,3,-1,-1,0
    .word 1128,208,3,-1,-1,0
    .word 1136,296,3,-1,-1,0
    .word 1144,384,3,-1,-1,0
    .word 1152,472,3,-1,-1,0
    .word 1192,560,3,-1,-1,0
    .word 1200,1000,4,-1,-1,0
    .word 1160,648,3,12,0,0
    .word 1168,736,3,16,1,0
    .word 1176,824,3,20,2,0
    .word 1184,912,3,24,3,0
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2asm/references/openifs/support/auxiliary_physics_work_records.md.
// Shared FIELD rules: skills/md2asm/references/openifs/support/physics_field_block_views.md.
// Select a source-equivalent FP64 field block without changing numerical data.
.text
.p2align 4

.global md2asm_physics_field_view_2d
.type md2asm_physics_field_view_2d,%function
md2asm_physics_field_view_2d:
    mov w3, #2
.Lfield_block_view:
    mov x4, #72
    mul x4, x3, x4
    add x4, x4, #100
    add x4, x1, x4
    ldr w5, [x4]
    cbz w5, .Lfield_existing_view
    sxtw x6, w2
    ldr w5, [x4, #4]
    mov x7, #1
    cmp w5, #0
    csel x6, x6, x7, eq
    ldr w5, [x4, #8]
    cbnz w5, .Lfield_owned_view
    mov x4, #24
    madd x4, x3, x4, x1
    add x4, x4, #16
    b .Lfield_selected_storage
.Lfield_owned_view:
    mov x4, #48
    madd x4, x3, x4, x1
    add x4, x4, #56
.Lfield_selected_storage:
    sub x5, x3, #1
    mov x7, #24
    madd x7, x5, x7, x4
    add x7, x7, #40
    ldp x8, x9, [x7]
    sub x6, x6, x9
    mul x6, x6, x8
    ldr x10, [x4]
    add x10, x10, x6, lsl #3
    str x10, [x0]
    mov x10, #8
    str x10, [x0, #16]
    str xzr, [x0, #24]
    strb w5, [x0, #28]
    mov w11, #3
    strb w11, [x0, #29]
    str x10, [x0, #32]
    mov x11, x5
    mov x12, #0
    add x13, x4, #40
    add x14, x0, #40
    mov x17, #1
.Lfield_view_dimensions:
    ldp x15, x16, [x13]
    ldr x10, [x13, #16]
    sub x16, x10, x16
    add x16, x16, #1
    stp x15, x17, [x14]
    str x16, [x14, #16]
    sub x12, x12, x15
    add x13, x13, #24
    add x14, x14, #24
    subs x11, x11, #1
    b.ne .Lfield_view_dimensions
    str x12, [x0, #8]
    ret
.Lfield_existing_view:
    mov x4, #24
    mul x4, x3, x4
    add x4, x4, #16
.Lfield_copy_existing:
    ldr x5, [x1], #8
    str x5, [x0], #8
    subs x4, x4, #8
    b.ne .Lfield_copy_existing
    ret
.size md2asm_physics_field_view_2d,.-md2asm_physics_field_view_2d
.section .note.GNU-stack,"",%progbits

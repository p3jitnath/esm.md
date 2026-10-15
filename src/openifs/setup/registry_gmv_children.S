// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Build one section descriptor by removing the field dimension before blocks.
// x0 output; x1 input; w2 signed field index; w3 result rank (2 or 3).
.text
.p2align 4
.global md2asm_registry_slice_field_descriptor
.type md2asm_registry_slice_field_descriptor,%function
md2asm_registry_slice_field_descriptor:
    ldp x4, x5, [x1]
    ldp x6, x7, [x1, #16]
    stp x4, x5, [x0]
    stp x6, x7, [x0, #16]
    ldr x8, [x1, #32]
    str x8, [x0, #32]
    strb w3, [x0, #28]
    mov x5, #24
    sub x6, x3, #1
    madd x5, x5, x6, x1
    ldr x5, [x5, #40]
    sxtw x2, w2
    sub x2, x2, #1
    mul x2, x2, x5
    add x4, x4, x2, lsl #3
    str x4, [x0]
    add x4, x1, #40
    add x5, x0, #40
    mov x7, #0
    mov x12, #1
.Lslice_leading_dimensions:
    ldp x8, x9, [x4]
    ldr x10, [x4, #16]
    sub x10, x10, x9
    add x10, x10, #1
    sub x7, x7, x8
    stp x8, x12, [x5]
    str x10, [x5, #16]
    add x4, x4, #24
    add x5, x5, #24
    subs x6, x6, #1
    b.ne .Lslice_leading_dimensions
    // Skip the removed field dimension and retain the block dimension.
    add x4, x4, #24
    ldp x8, x9, [x4]
    ldr x10, [x4, #16]
    sub x10, x10, x9
    add x10, x10, #1
    sub x7, x7, x8
    stp x8, x12, [x5]
    str x10, [x5, #16]
    str x7, [x0, #8]
    ret
.size md2asm_registry_slice_field_descriptor,.-md2asm_registry_slice_field_descriptor

.global md2asm_registry_create_gmv_variable
.type md2asm_registry_create_gmv_variable,%function
md2asm_registry_create_gmv_variable:
    stp x29, x30, [sp, #-256]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    add x0, sp, #112
    mov x1, x21
    ldr w2, [x23]
    mov x3, x24
    bl md2asm_registry_slice_field_descriptor
    mov x0, x19
    mov x1, x20
    add x2, sp, #112
    cmp w24, #2
    b.eq .Lgmv_base_2d
    bl md2asm_registry_wrap_variable_3d
    b .Lgmv_base_ready
.Lgmv_base_2d:
    bl md2asm_registry_wrap_variable_2d
.Lgmv_base_ready:
    cbnz w0, .Lgmv_return
    mov w4, #1
    str w4, [x19, #60]
    mov x4, #168
    mul x28, x24, x4
    add x28, x28, #176
    mov x25, #1
.Lgmv_optional_fields:
    ldr w26, [x23, x25, lsl #2]
    tbnz w26, #31, .Lgmv_optional_next
    mov w4, #1
    add x5, x19, x25, lsl #2
    str w4, [x5, #36]
    add x0, sp, #112
    cmp x25, #1
    csel x1, x22, x21, eq
    mov w2, w26
    mov x3, x24
    bl md2asm_registry_slice_field_descriptor
    mov x0, #72
    mul x0, x24, x0
    add x0, x0, #112
    bl malloc
    cbz x0, .Lgmv_failed
    mov x27, x0
    add x1, sp, #112
    cmp w24, #2
    b.eq .Lgmv_optional_2d
    bl md2asm_field_wrap_3d_
    b .Lgmv_optional_ready
.Lgmv_optional_2d:
    bl md2asm_field_wrap_2d_
.Lgmv_optional_ready:
    add x4, x19, x28
    str x27, [x4, x25, lsl #3]
.Lgmv_optional_next:
    add x25, x25, #1
    cmp x25, #6
    b.lo .Lgmv_optional_fields
    mov w0, #0
    b .Lgmv_return
.Lgmv_failed:
    mov w0, #1
.Lgmv_return:
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #256
    ret
.size md2asm_registry_create_gmv_variable,.-md2asm_registry_create_gmv_variable
.section .note.GNU-stack,"",%progbits

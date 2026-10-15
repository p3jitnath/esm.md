// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Construct GFL component variables and arrays. Metadata only.
.text
.p2align 4
.global md2asm_registry_create_gfl_variable
.type md2asm_registry_create_gfl_variable,%function
md2asm_registry_create_gfl_variable:
    stp x29, x30, [sp, #-224]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    str x18, [sp, #80]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov w2, #3
    bl md2asm_registry_initialize_variable
    ldp x4, x5, [x21]
    stp x4, x5, [x19, #16]
    ldr w4, [x21, #16]
    str w4, [x19, #32]
    ldr w26, [x21, #64]
    str w26, [x19, #36]
    ldr w4, [x21, #92]
    str w4, [x19, #40]
    ldr w4, [x21, #88]
    str w4, [x19, #44]
    ldr w4, [x21, #100]
    str w4, [x19, #48]
    ldr w4, [x21, #20]
    str w4, [x19, #60]
    cbz w26, .Lgfl_variable_complete
    mov x23, #0
.Lgfl_fields:
    adrp x4, .Lgfl_index_offsets
    add x4, x4, :lo12:.Lgfl_index_offsets
    ldr w4, [x4, x23, lsl #2]
    ldr w25, [x21, w4, uxtw]
    cmp w25, #0
    b.le .Lgfl_next_field
    add x0, sp, #96
    add x4, x22, #136
    cmp x23, #1
    csel x1, x4, x22, eq
    mov w2, w25
    mov w3, #3
    bl md2asm_registry_slice_field_descriptor
    mov w0, #328
    bl malloc
    cbz x0, .Lgfl_variable_failed
    mov x24, x0
    add x1, sp, #96
    bl md2asm_field_wrap_3d_
    add x4, x19, #680
    str x24, [x4, x23, lsl #3]
.Lgfl_next_field:
    add x23, x23, #1
    cmp x23, #6
    b.lo .Lgfl_fields
.Lgfl_variable_complete:
    mov w0, #0
    b .Lgfl_variable_return
.Lgfl_variable_failed:
    mov w0, #1
.Lgfl_variable_return:
    ldr x18, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #224
    ret
.size md2asm_registry_create_gfl_variable,.-md2asm_registry_create_gfl_variable

.global md2asm_registry_create_gfl_array
.type md2asm_registry_create_gfl_array,%function
md2asm_registry_create_gfl_array:
    stp x29, x30, [sp, #-144]!
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
    mov x27, x4
    ldr x25, [x21]
    mov x23, #0
    cbz x25, .Lgfl_array_allocate
    ldp x4, x5, [x21, #48]
    cmp x4, #1
    b.ne .Lgfl_array_domain_failed
    sub x23, x5, x4
    add x23, x23, #1
    cmp x23, #255
    b.hi .Lgfl_array_domain_failed
    ldr x28, [x21, #40]
    mov x4, #368
    mul x28, x28, x4
.Lgfl_array_allocate:
    mov x4, #728
    mul x0, x23, x4
    cmp x0, #0
    csinc x0, x0, xzr, ne
    bl malloc
    cbz x0, .Lgfl_array_failed
    mov x26, x0
    str x0, [x19]
    mov x4, #-1
    str x4, [x19, #8]
    mov x4, #728
    str x4, [x19, #16]
    movz x5, #0x501, lsl #32
    str x5, [x19, #24]
    str x4, [x19, #32]
    mov x4, #1
    stp x4, x4, [x19, #40]
    str x23, [x19, #56]
    mov x24, #1
    cbz x23, .Lgfl_array_complete
.Lgfl_array_element:
    ldp x4, x5, [x20]
    stp x4, x5, [sp, #112]
    add x4, sp, #112
    mov w5, #'_'
    strb w5, [x4, x27]
    add x5, x27, #1
    strb w24, [x4, x5]
    mov x0, x26
    add x1, sp, #112
    mov x2, x25
    mov x3, x22
    bl md2asm_registry_create_gfl_variable
    cbnz w0, .Lgfl_array_failed
    add x26, x26, #728
    add x25, x25, x28
    add x24, x24, #1
    cmp x24, x23
    b.ls .Lgfl_array_element
.Lgfl_array_complete:
    mov w0, #0
    b .Lgfl_array_return
.Lgfl_array_domain_failed:
    mov w0, #2
    b .Lgfl_array_return
.Lgfl_array_failed:
    mov w0, #1
.Lgfl_array_return:
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #144
    ret
.size md2asm_registry_create_gfl_array,.-md2asm_registry_create_gfl_array
.section .rodata
.p2align 2
.Lgfl_index_offsets:
    .word 168,188,180,184,172,176
.section .note.GNU-stack,"",%progbits

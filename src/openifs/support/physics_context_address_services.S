// Solver contract skills/md2asm/references/openifs/support/physics_context_address_services.md.
// Original physics context address services, with direct verified children.
// Contract skills/md2asm/references/openifs/support/physics_context_address_services.md. No numerical stage.
.arch armv8.2-a
.text
.p2align 4
.macro address_service_count index
    adrp x9, .Lcontext_address_counts
    add x9, x9, :lo12:.Lcontext_address_counts
    ldr x10, [x9, #(8*\index)]
    add x10, x10, #1
    str x10, [x9, #(8*\index)]
.endm
.global md2asm_physics_driver_shape
.type md2asm_physics_driver_shape,%function
md2asm_physics_driver_shape:
    address_service_count 0
    ldr x2, [x0]
    ldr x3, [x0, #40]
    ldr w9, [x2, #5144]
    str w9, [x1, #0]
    ldr w9, [x2, #5224]
    str w9, [x1, #4]
    ldr w9, [x2, #5160]
    str w9, [x1, #8]
    ldr w9, [x2, #7376]
    str w9, [x1, #12]
    ldr w9, [x3, #256]
    str w9, [x1, #16]
    ldr w9, [x3, #264]
    str w9, [x1, #20]
    movz x10, #4656
    movk x10, #24, lsl #16
    ldr w9, [x3, x10]
    str w9, [x1, #24]
    movz x10, #35876
    movk x10, #24, lsl #16
    ldr w9, [x3, x10]
    str w9, [x1, #28]
    ret
.size md2asm_physics_driver_shape,.-md2asm_physics_driver_shape
.global md2asm_physics_storage_zero_view
.type md2asm_physics_storage_zero_view,%function
md2asm_physics_storage_zero_view:
    address_service_count 1
    movz x9, #51136
    movk x9, #1, lsl #16
    ldr x0, [x0, x9]
    ret
.size md2asm_physics_storage_zero_view,.-md2asm_physics_storage_zero_view
.global md2asm_physics_storage_begin_block
.type md2asm_physics_storage_begin_block,%function
md2asm_physics_storage_begin_block:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x18, [sp, #32]
    add x19, x0, #16
    mov w20, w1
    address_service_count 2
    mov x0, x19
    bl md2asm_clone_field_variable_arrays
    mov x0, x19
    mov w1, w20
    bl md2asm_update_field_variable_views
    ldr x18, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size md2asm_physics_storage_begin_block,.-md2asm_physics_storage_begin_block
.global md2asm_physics_context_address_call_count_get
.type md2asm_physics_context_address_call_count_get,%function
md2asm_physics_context_address_call_count_get:
    cmp x0, #3
    b.hs .Lcontext_address_zero
    adrp x9, .Lcontext_address_counts
    add x9, x9, :lo12:.Lcontext_address_counts
    ldr x0, [x9, x0, lsl #3]
    ret
.Lcontext_address_zero:
    mov x0, #0
    ret
.size md2asm_physics_context_address_call_count_get,.-md2asm_physics_context_address_call_count_get
.bss
.p2align 3
.Lcontext_address_counts: .zero 24
.section .note.GNU-stack,"",%progbits

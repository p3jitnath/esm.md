// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Construct all seven field-registry metadata methods in source order.
// Contract: skills/md2asm/references/openifs/setup/field_registry.md. x0 geometry, x1 fields, x2 model,
// x3 int32 result. Result0 ready,1 wrong model before mutation,2 allocation
// failure after partial creation. Caller owns all created metadata and buffers.
.text
.p2align 4
.global md2asm_prepare_field_registry
.type md2asm_prepare_field_registry,%function
md2asm_prepare_field_registry:
    movz x4, #4984
    movk x4, #8, lsl #16
    ldr x5, [x1, x4]
    cbnz x5, .Lprepare_already_ready
    ldr x5, [x1, #1840]
    cmp x5, x2
    b.ne .Lprepare_wrong_model
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x18, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    mov x1, x19
    bl md2asm_registry_initialize
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    add x1, x0, #16
    mov x2, x19
    bl md2asm_registry_register_geometry
    cbnz w0, .Lprepare_allocation_failed
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    add x1, x0, #16
    add x2, x20, #1856
    bl md2asm_registry_register_gmv
    cbnz w0, .Lprepare_allocation_failed
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    add x1, x0, #16
    mov x4, #3416
    add x2, x20, x4
    add x3, x21, #192
    bl md2asm_registry_register_gfl
    cbnz w0, .Lprepare_allocation_failed
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    add x1, x0, #24
    mov x4, #4512
    add x2, x20, x4
    bl md2asm_registry_register_surface
    cbnz w0, .Lprepare_allocation_failed
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    ldr x1, [x0, #16]
    mov x4, #25728
    add x2, x20, x4
    bl md2asm_registry_register_ec_physics
    cbnz w0, .Lprepare_allocation_failed
    movz x4, #4968
    movk x4, #8, lsl #16
    add x0, x20, x4
    ldr x1, [x0, #16]
    movz x4, #33624
    movk x4, #24, lsl #16
    add x2, x21, x4
    bl md2asm_registry_register_radiation
    cbnz w0, .Lprepare_allocation_failed
    str wzr, [x22]
    b .Lprepare_return
.Lprepare_allocation_failed:
    mov w0, #2
    str w0, [x22]
.Lprepare_return:
    ldr x18, [sp, #48]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #64
    ret
.Lprepare_already_ready:
    str wzr, [x3]
    ret
.Lprepare_wrong_model:
    mov w0, #1
    str w0, [x3]
    ret
.size md2asm_prepare_field_registry,.-md2asm_prepare_field_registry
.section .note.GNU-stack,"",%progbits

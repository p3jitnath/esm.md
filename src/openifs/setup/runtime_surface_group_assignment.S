// Contract: skills/md2asm/references/openifs/setup/runtime_field_registry.md.
// x0 FIELD328/400; x1 int32 shape[rank]; x2 rank3/4; x3 thread flag1.
// Success returns w0=0; allocation failure returns1 with earlier owners live.
// PTR keeps its first owner. DATA receives bytes from an independent source.
.text
.p2align 4
.global md2asm_registry_allocate_runtime_surface_group
.type md2asm_registry_allocate_runtime_surface_group,%function
md2asm_registry_allocate_runtime_surface_group:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x18, [sp, #64]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    bl md2asm_registry_allocate_field
    cbnz w0, .Lruntime_group_return
    mov x23, #8
    mov x4, #0
.Lruntime_group_count:
    ldr w5, [x20, x4, lsl #2]
    mul x23, x23, x5
    add x4, x4, #1
    cmp x4, x21
    b.lo .Lruntime_group_count
    cmp x23, #0
    csinc x0, x23, xzr, ne
    bl malloc
    cbz x0, .Lruntime_group_failed
    mov x24, x0
    mov x4, #48
    madd x4, x21, x4, x19
    str x24, [x4, #56]
    cmp x23, #0
    csinc x0, x23, xzr, ne
    bl malloc
    cbz x0, .Lruntime_group_failed
    mov x25, x0
    mov x0, x24
    mov x1, x25
    mov x2, x23
    bl memcpy
    mov x0, x25
    bl free
    mov w0, #0
    b .Lruntime_group_return
.Lruntime_group_failed:
    mov w0, #1
.Lruntime_group_return:
    ldp x25, x18, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size md2asm_registry_allocate_runtime_surface_group,.-md2asm_registry_allocate_runtime_surface_group
.section .note.GNU-stack,"",%progbits

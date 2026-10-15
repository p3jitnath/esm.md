// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Allocate contiguous owned field storage. Numerical values remain undefined.
.text
.p2align 4
.global md2asm_registry_allocate_field
.type md2asm_registry_allocate_field,%function
md2asm_registry_allocate_field:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x18, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, #8
    mov x4, #0
.Lowned_count:
    ldr w5, [x20, x4, lsl #2]
    mul x23, x23, x5
    add x4, x4, #1
    cmp x4, x21
    b.lo .Lowned_count
    cmp x23, #0
    csinc x0, x23, xzr, ne
    bl malloc
    cbz x0, .Lowned_failed
    mov x1, x0
    mov x4, #72
    mul x4, x21, x4
    add x4, x4, #112
    mov x5, x19
    add x6, x19, x4
.Lowned_clear:
    str xzr, [x5], #8
    cmp x5, x6
    b.lo .Lowned_clear
    mov x4, #48
    madd x0, x21, x4, x19
    add x0, x0, #56
    mov x2, x20
    mov x3, x21
    bl .Lowned_descriptor
    mov x4, #48
    madd x4, x21, x4, x19
    add x4, x4, #56
    mov x5, #24
    madd x5, x21, x5, x19
    add x5, x5, #16
    mov x6, #24
    mul x6, x21, x6
    add x6, x6, #40
.Lowned_copy_ptr:
    ldr x7, [x4], #8
    str x7, [x5], #8
    subs x6, x6, #8
    b.ne .Lowned_copy_ptr
    mov x4, #72
    madd x4, x21, x4, x19
    add x4, x4, #96
    sub x5, x21, #1
    ldr w6, [x20, x5, lsl #2]
    mov w7, #1
    stp w6, w7, [x4]
    stp w22, w7, [x4, #8]
    mov w0, #0
    b .Lowned_return
.Lowned_failed:
    mov w0, #1
.Lowned_return:
    ldp x23, x18, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size md2asm_registry_allocate_field,.-md2asm_registry_allocate_field

// x0 descriptor; x1 base; x2 shape; x3 rank. FP64, contiguous, one-based.
.Lowned_descriptor:
    str x1, [x0]
    mov x4, #8
    str x4, [x0, #16]
    str xzr, [x0, #24]
    strb w3, [x0, #28]
    mov w5, #3
    strb w5, [x0, #29]
    str x4, [x0, #32]
    add x4, x0, #40
    mov x5, #0
    mov x6, #1
    mov x7, #0
    mov x10, #1
.Lowned_dimensions:
    ldr w8, [x2, x5, lsl #2]
    sub x7, x7, x6
    stp x6, x10, [x4]
    str x8, [x4, #16]
    mul x6, x6, x8
    add x4, x4, #24
    add x5, x5, #1
    cmp x5, x3
    b.lo .Lowned_dimensions
    str x7, [x0, #8]
    ret

.global md2asm_registry_create_surface_variable
.type md2asm_registry_create_surface_variable,%function
md2asm_registry_create_surface_variable:
    stp x29, x30, [sp, #-256]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    mov x19, x0
    mov x20, x2
    mov x21, x3
    mov x22, x4
    mov x23, x5
    mov x24, x6
    mov x2, x6
    bl md2asm_registry_initialize_variable
    mov x4, #168
    mul x28, x24, x4
    add x28, x28, #176
    mov x25, #0
.Lsurface_time_levels:
    mov w26, #0
    cbz x21, .Lsurface_index_ready
    adrp x4, .Lsurface_index_offsets
    add x4, x4, :lo12:.Lsurface_index_offsets
    ldr w4, [x4, x25, lsl #2]
    ldr w26, [x21, w4, uxtw]
.Lsurface_index_ready:
    cmp w26, #0
    cset w4, gt
    add x5, x19, x25, lsl #2
    str w4, [x5, #36]
    mov x0, #72
    mul x0, x24, x0
    add x0, x0, #112
    bl malloc
    cbz x0, .Lsurface_variable_failed
    mov x27, x0
    cmp w26, #0
    b.le .Lsurface_temporary
    add x0, sp, #112
    mov x1, x20
    mov w2, w26
    mov x3, x24
    bl md2asm_registry_slice_field_descriptor
    mov x0, x27
    add x1, sp, #112
    cmp w24, #2
    b.eq .Lsurface_wrap_2d
    bl md2asm_field_wrap_3d_
    b .Lsurface_time_level_ready
.Lsurface_wrap_2d:
    bl md2asm_field_wrap_2d_
    b .Lsurface_time_level_ready
.Lsurface_temporary:
    ldr w4, [x23, #8]
    str w4, [sp, #224]
    mov w5, #1
    cmp w24, #2
    b.eq .Lsurface_temporary_shape2
    ldr w4, [x22, #8]
    stp w4, w5, [sp, #228]
    b .Lsurface_temporary_shape_ready
.Lsurface_temporary_shape2:
    str w5, [sp, #228]
.Lsurface_temporary_shape_ready:
    mov x0, x27
    add x1, sp, #224
    mov x2, x24
    mov w3, #1
    bl md2asm_registry_allocate_field
    cbnz w0, .Lsurface_variable_failed
.Lsurface_time_level_ready:
    add x4, x19, x28
    str x27, [x4, x25, lsl #3]
    add x25, x25, #1
    cmp x25, #3
    b.lo .Lsurface_time_levels
    mov w0, #0
    b .Lsurface_variable_return
.Lsurface_variable_failed:
    mov w0, #1
.Lsurface_variable_return:
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #256
    ret
.size md2asm_registry_create_surface_variable,.-md2asm_registry_create_surface_variable
.section .rodata
.p2align 2
.Lsurface_index_offsets:
    .word 0,12,8
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Construct rank-one or rank-two arrays of surface VARIABLE records.
.text
.p2align 4
.global md2asm_registry_create_surface_array
.type md2asm_registry_create_surface_array,%function
md2asm_registry_create_surface_array:
    stp x29, x30, [sp, #-224]!
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
    mov x25, x6
    mov x26, x7
    ldp x4, x5, [x21, #48]
    sub x4, x5, x4
    add x4, x4, #1
    cmp x4, #255
    b.hi .Lsurface_array_domain_failed
    mov x5, #1
    ldr w6, [x26]
    cmp w6, #2
    b.ne .Lsurface_array_dimensions_ready
    ldp x5, x6, [x21, #72]
    sub x5, x6, x5
    add x5, x5, #1
    cmp x5, #255
    b.hi .Lsurface_array_domain_failed
.Lsurface_array_dimensions_ready:
    stp x4, x5, [sp, #128]
    mov x6, #168
    mul x6, x25, x6
    add x6, x6, #224
    str x6, [sp, #160]
    mul x0, x4, x5
    mul x0, x0, x6
    cmp x0, #0
    csinc x0, x0, xzr, ne
    bl malloc
    cbz x0, .Lsurface_array_failed
    mov x27, x0
    str x0, [x19]
    ldr x4, [sp, #160]
    str x4, [x19, #16]
    str xzr, [x19, #24]
    ldr w5, [x26]
    strb w5, [x19, #28]
    mov w6, #5
    strb w6, [x19, #29]
    str x4, [x19, #32]
    mov x4, #1
    stp x4, x4, [x19, #40]
    ldp x6, x7, [sp, #128]
    str x6, [x19, #56]
    mov x8, #-1
    cmp w5, #2
    b.ne .Lsurface_array_descriptor_ready
    stp x6, x4, [x19, #64]
    str x7, [x19, #80]
    sub x8, x8, x6
.Lsurface_array_descriptor_ready:
    str x8, [x19, #8]
    mul x6, x6, x7
    cbz x6, .Lsurface_array_complete
    mov x28, #0
.Lsurface_array_element:
    ldp x4, x5, [x20]
    stp x4, x5, [sp, #112]
    ldr x4, [sp, #128]
    udiv x5, x28, x4
    msub x6, x5, x4, x28
    stp x6, x5, [sp, #144]
    add x6, x6, #1
    add x5, x5, #1
    ldr w7, [x26, #4]
    add x8, sp, #112
    mov w9, #'_'
    cmp x7, #16
    b.hs .Lsurface_array_name_first_done
    strb w9, [x8, x7]
    add x7, x7, #1
    cmp x7, #16
    b.hs .Lsurface_array_name_first_done
    strb w6, [x8, x7]
.Lsurface_array_name_first_done:
    ldr w7, [x26, #4]
    add x7, x7, #2
    ldr w10, [x26]
    cmp w10, #2
    b.ne .Lsurface_array_name_ready
    cmp x7, #16
    b.hs .Lsurface_array_name_ready
    strb w9, [x8, x7]
    add x7, x7, #1
    cmp x7, #16
    b.hs .Lsurface_array_name_ready
    strb w5, [x8, x7]
.Lsurface_array_name_ready:
    ldp x5, x6, [sp, #144]
    ldr x7, [x21, #40]
    mul x5, x5, x7
    ldr w8, [x26]
    cmp w8, #2
    b.ne .Lsurface_array_meta_offset_ready
    ldr x7, [x21, #64]
    madd x5, x6, x7, x5
.Lsurface_array_meta_offset_ready:
    mov x7, #64
    mov x8, #288
    cmp w25, #2
    csel x7, x7, x8, eq
    ldr x3, [x21]
    madd x3, x5, x7, x3
    mov x0, x27
    add x1, sp, #112
    mov x2, x22
    mov x4, x23
    mov x5, x24
    mov x6, x25
    bl md2asm_registry_create_surface_variable
    cbnz w0, .Lsurface_array_return
    ldr x4, [sp, #160]
    add x27, x27, x4
    add x28, x28, #1
    ldp x4, x5, [sp, #128]
    mul x4, x4, x5
    cmp x28, x4
    b.lo .Lsurface_array_element
.Lsurface_array_complete:
    mov w0, #0
    b .Lsurface_array_return
.Lsurface_array_domain_failed:
    mov w0, #2
    b .Lsurface_array_return
.Lsurface_array_failed:
    mov w0, #1
.Lsurface_array_return:
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #224
    ret
.size md2asm_registry_create_surface_array,.-md2asm_registry_create_surface_array
.section .note.GNU-stack,"",%progbits

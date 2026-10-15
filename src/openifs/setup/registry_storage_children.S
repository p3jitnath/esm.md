// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Construct address and dimension records. No numerical array value is written.
.text
.p2align 4
.global md2asm_field_registry_init
.type md2asm_field_registry_init,%function
md2asm_field_registry_init:
    ldr x0, [x0]
    b md2asm_registry_initialize
.size md2asm_field_registry_init,.-md2asm_field_registry_init

.global md2asm_registry_initialize
.type md2asm_registry_initialize,%function
md2asm_registry_initialize:
    ldr w2, [x1, #5144]
    ldr w3, [x1, #5160]
    str x1, [x0]
    stp w2, w3, [x0, #8]
    ret
.size md2asm_registry_initialize,.-md2asm_registry_initialize

.global md2asm_field_wrap_2d_
.type md2asm_field_wrap_2d_,%function
md2asm_field_wrap_2d_:
    mov w2, #2
    b .Lfield_wrap
.size md2asm_field_wrap_2d_,.-md2asm_field_wrap_2d_
.global md2asm_field_wrap_3d_
.type md2asm_field_wrap_3d_,%function
md2asm_field_wrap_3d_:
    mov w2, #3
    b .Lfield_wrap
.size md2asm_field_wrap_3d_,.-md2asm_field_wrap_3d_
.global md2asm_field_wrap_4d_
.type md2asm_field_wrap_4d_,%function
md2asm_field_wrap_4d_:
    mov w2, #4
.Lfield_wrap:
    // FIELD size is 112 + 72 * rank, measured through typed source records.
    mov x3, #72
    madd x3, x2, x3, xzr
    add x3, x3, #112
    mov x4, x0
    add x5, x0, x3
.Lclear_field:
    str xzr, [x4], #8
    cmp x4, x5
    b.lo .Lclear_field
    // PTR follows the rank-minus-one VIEW descriptor: 16 + 24 * rank.
    mov x4, #24
    madd x4, x2, x4, x0
    add x4, x4, #16
    ldr x5, [x1]
    str x5, [x4]
    // The original typed dummy rebuilds its FP64 descriptor header.
    mov x5, #8
    str x5, [x4, #16]
    str xzr, [x4, #24]
    strb w2, [x4, #28]
    mov w6, #3
    strb w6, [x4, #29]
    str x5, [x4, #32]
    add x5, x1, #40
    add x6, x4, #40
    mov x7, x2
    mov x8, #0
    mov x12, #1
.Lwrap_dimensions:
    ldp x9, x10, [x5]
    cmp x7, x2
    b.ne .Lwrap_stride_ready
    cmp x9, #0
    csinc x9, x9, xzr, ne
.Lwrap_stride_ready:
    ldr x11, [x5, #16]
    sub x11, x11, x10
    add x11, x11, #1
    sub x8, x8, x9
    stp x9, x12, [x6]
    str x11, [x6, #16]
    add x5, x5, #24
    add x6, x6, #24
    subs x7, x7, #1
    b.ne .Lwrap_dimensions
    str x8, [x4, #8]
    sub x3, x3, #16
    add x3, x0, x3
    str w11, [x3]
    str w12, [x3, #4]
    ret
.size md2asm_field_wrap_4d_,.-md2asm_field_wrap_4d_
// Wrap one named array in a VARIABLE record and its allocated FIELD record.
// x0: result; x1: sixteen-byte padded name; x2: array descriptor.
// Return zero on success, or one without changing result if malloc fails.
.global md2asm_registry_wrap_variable_2d
.type md2asm_registry_wrap_variable_2d,%function
md2asm_registry_wrap_variable_2d:
    mov w3, #2
    b .Lwrap_variable
.size md2asm_registry_wrap_variable_2d,.-md2asm_registry_wrap_variable_2d
.global md2asm_registry_wrap_variable_3d
.type md2asm_registry_wrap_variable_3d,%function
md2asm_registry_wrap_variable_3d:
    mov w3, #3
    b .Lwrap_variable
.size md2asm_registry_wrap_variable_3d,.-md2asm_registry_wrap_variable_3d
.global md2asm_registry_wrap_variable_4d
.type md2asm_registry_wrap_variable_4d,%function
md2asm_registry_wrap_variable_4d:
    mov w3, #4
.Lwrap_variable:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x18, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x0, #72
    mul x0, x22, x0
    add x0, x0, #112
    bl malloc
    cbz x0, .Lvariable_alloc_failed
    mov x23, x0
    mov x1, x21
    mov x2, x22
    bl .Lfield_wrap
    // VARIABLE size is 224 + 168 * array rank.
    mov x3, #168
    mul x3, x22, x3
    add x3, x3, #224
    mov x4, x19
    add x5, x19, x3
.Lclear_variable:
    str xzr, [x4], #8
    cmp x4, x5
    b.lo .Lclear_variable
    ldp x4, x5, [x20]
    stp x4, x5, [x19]
    stp x4, x5, [x19, #16]
    mov w4, #-999
    str w4, [x19, #32]
    mov w4, #1
    str w4, [x19, #36]
    sub x3, x3, #48
    str x23, [x19, x3]
    mov w0, #0
    b .Lvariable_done
.Lvariable_alloc_failed:
    mov w0, #1
.Lvariable_done:
    ldp x23, x18, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size md2asm_registry_wrap_variable_4d,.-md2asm_registry_wrap_variable_4d
// Default VARIABLE record. x0 result; x1 sixteen-byte name; w2 rank.
.global md2asm_registry_initialize_variable
.type md2asm_registry_initialize_variable,%function
md2asm_registry_initialize_variable:
    mov x3, #168
    mul x3, x2, x3
    add x3, x3, #224
    mov x4, x0
    add x5, x0, x3
.Linitialize_variable_clear:
    str xzr, [x4], #8
    cmp x4, x5
    b.lo .Linitialize_variable_clear
    ldp x4, x5, [x1]
    stp x4, x5, [x0]
    stp x4, x5, [x0, #16]
    mov w4, #-999
    str w4, [x0, #32]
    ret
.size md2asm_registry_initialize_variable,.-md2asm_registry_initialize_variable
.section .note.GNU-stack,"",%progbits

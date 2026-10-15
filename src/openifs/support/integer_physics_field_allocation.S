// Contract: skills/md2asm/references/openifs/support/surface_physics_work_records.md.
// Allocate a contiguous rank-two int32 work field. Values remain undefined.
.text
.p2align 4
.global md2asm_allocate_integer_work_field
.type md2asm_allocate_integer_work_field,%function
md2asm_allocate_integer_work_field:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x18, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, #4
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
.size md2asm_allocate_integer_work_field,.-md2asm_allocate_integer_work_field

// x0 descriptor; x1 base; x2 shape; x3 rank2. Int32, contiguous, one-based.
.Lowned_descriptor:
    str x1, [x0]
    mov x4, #4
    str x4, [x0, #16]
    str xzr, [x0, #24]
    strb w3, [x0, #28]
    mov w5, #1
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


.section .note.GNU-stack,"",%progbits

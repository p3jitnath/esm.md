// Selected SUNDDH soil variable and flux class counts, in original source order.
// Contract: skills/md2asm/references/openifs/setup/ecmwf_soil_diagnostic_class_counts.md.
// x0 MODEL4275088, x1 capacity, x2 configuration67616, x3 capacity; w0 zero/two.
// Mapped records are disjoint and aligned8. Only fourteen int32 MODEL words change.
// Integer leaf: no frame, allocation, FP instruction or external call; preserve ABI/status.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_ecmwf_soil_diagnostic_class_counts
.type md2asm_initialize_ecmwf_soil_diagnostic_class_counts,%function
md2asm_initialize_ecmwf_soil_diagnostic_class_counts:
    cbz x0, .Lsoil_counts_refuse
    cbz x2, .Lsoil_counts_refuse
    orr x8, x0, x2
    tst x8, #7
    b.ne .Lsoil_counts_refuse
    mov x8, #(4275088 & 65535)
    movk x8, #(4275088 >> 16), lsl #16
    cmp x1, x8
    b.lo .Lsoil_counts_refuse
    adds x9, x0, x8
    b.cs .Lsoil_counts_refuse
    mov x8, #(67616 & 65535)
    movk x8, #(67616 >> 16), lsl #16
    cmp x3, x8
    b.lo .Lsoil_counts_refuse
    adds x10, x2, x8
    b.cs .Lsoil_counts_refuse
    cmp x0, x10
    b.hs .Lsoil_counts_separate
    cmp x2, x9
    b.lo .Lsoil_counts_refuse
.Lsoil_counts_separate:
    ldr x8, [x2]
    cmp x8, x0
    b.ne .Lsoil_counts_refuse
    ldr x8, [x2, #24]
    mov w9, #0x4346
    movk w9, #0x4731, lsl #16
    cmp x8, x9
    b.ne .Lsoil_counts_refuse
    ldr x8, [x0, #8]
    cbz x8, .Lsoil_counts_refuse
    tst x8, #7
    b.ne .Lsoil_counts_refuse
    ldr x9, [x2, #16]
    cmp x8, x9
    b.ne .Lsoil_counts_refuse
    mov x9, #40104
    ldr w8, [x2, x9]
    cmp w8, #1
    b.ne .Lsoil_counts_refuse
    adrp x11, .Lsoil_counts
    add x11, x11, :lo12:.Lsoil_counts
    mov w12, #14
.Lsoil_counts_store:
    ldp w9, w10, [x11], #8
    str w10, [x0, w9, uxtw]
    subs w12, w12, #1
    b.ne .Lsoil_counts_store
    mov w0, #0
    ret
.Lsoil_counts_refuse:
    mov w0, #2
    ret
.size md2asm_initialize_ecmwf_soil_diagnostic_class_counts, .-md2asm_initialize_ecmwf_soil_diagnostic_class_counts
.section .rodata
.p2align 2
.Lsoil_counts:
    // SUNDDH variables, lines555 through561.
    .word 4233140,3
    .word 4233148,6
    .word 4233156,4
    .word 4233164,4
    .word 4233172,1
    .word 4233180,1
    .word 4233188,2
    // SUNDDH fluxes, lines591 through597.
    .word 4233144,9
    .word 4233152,9
    .word 4233160,11
    .word 4233168,9
    .word 4233176,4
    .word 4233184,3
    .word 4233192,8
.section .note.GNU-stack,"",%progbits

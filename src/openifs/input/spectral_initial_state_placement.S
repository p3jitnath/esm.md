/*
 * Initial spectral state placement, revision 1.
 * Contract: skills/md2asm/references/openifs/input/spectral_initial_state_placement.md
 *
 * Direct AArch64 assembly written from the frozen storage map.
 * Arguments x0..x7 are values, values_bytes, metadata, metadata_bytes,
 * pspec3, pspec3_bytes, pspec2 and pspec2_bytes.
 * Required extents are 315744, 1872, 230736 and 8096 bytes.
 * The four pointers are aligned to eight bytes. Outputs are disjoint
 * from both inputs and each other. Inputs remain unchanged.
 * All checks precede output writes. Return 0 for success, 1 for an
 * invalid buffer contract, and 2 for unexpected record metadata.
 * Integer copies preserve every input bit. No floating-point operation,
 * child call or stack storage is used. x18..x30, all vector registers,
 * FPCR is the floating-point control register. FPSR records floating-point
 * status. Both registers and errno remain unchanged. x0..x17 and flags
 * are scratch.
 */
.arch armv8.2-a
.text
.p2align 4
.macro DISJOINT first, first_end, second, second_end
    cmp \first, \second_end
    b.hs .Ldisjoint_\@
    cmp \second, \first_end
    b.lo .Linvalid
.Ldisjoint_\@:
.endm
.global md2asm_place_initial_spectral_fields
.type md2asm_place_initial_spectral_fields, %function
md2asm_place_initial_spectral_fields:
    cbz x0, .Linvalid
    cbz x2, .Linvalid
    cbz x4, .Linvalid
    cbz x6, .Linvalid
    orr x12, x0, x2
    orr x12, x12, x4
    orr x12, x12, x6
    tst x12, #7
    b.ne .Linvalid
    movz x12, #0xd160
    movk x12, #4, lsl #16
    cmp x1, x12
    b.lo .Linvalid
    adds x8, x0, x12
    b.cs .Linvalid
    mov x12, #1872
    cmp x3, x12
    b.lo .Linvalid
    adds x9, x2, x12
    b.cs .Linvalid
    movz x12, #0x8550
    movk x12, #3, lsl #16
    cmp x5, x12
    b.lo .Linvalid
    adds x10, x4, x12
    b.cs .Linvalid
    mov x12, #8096
    cmp x7, x12
    b.lo .Linvalid
    adds x11, x6, x12
    b.cs .Linvalid
    DISJOINT x4, x10, x0, x8
    DISJOINT x4, x10, x2, x9
    DISJOINT x6, x11, x0, x8
    DISJOINT x6, x11, x2, x9
    DISJOINT x4, x10, x6, x11

    adrp x8, .Lfield_pairs
    add x8, x8, :lo12:.Lfield_pairs
    mov x9, x2
    mov x10, #78
.Lmetadata:
    ldp x11, x12, [x9], #16
    ldr x13, [x9], #8
    ldp x14, x15, [x8], #16
    cmp x11, x14
    b.ne .Lmetadata_invalid
    cmp x12, x15
    b.ne .Lmetadata_invalid
    cmp x13, #506
    b.ne .Lmetadata_invalid
    subs x10, x10, #1
    b.ne .Lmetadata

    mov x8, #0
.Lupper_field:
    mov x9, #0
.Lupper_level:
    add x10, x9, x9, lsl #1
    add x10, x10, x8
    add x10, x10, #1
    mov x11, #4048
    madd x12, x10, x11, x0
    movz x14, #0x2c70
    movk x14, #1, lsl #16
    madd x13, x8, x14, x4
    add x13, x13, x9, lsl #3
    mov x15, #506
.Lupper_coefficient:
    ldr x14, [x12], #8
    str x14, [x13]
    add x13, x13, #152
    subs x15, x15, #1
    b.ne .Lupper_coefficient
    add x9, x9, #1
    cmp x9, #19
    b.ne .Lupper_level
    add x8, x8, #1
    cmp x8, #3
    b.ne .Lupper_field

    mov x12, x0
    mov x13, x6
    mov x15, #506
.Lsurface_pressure:
    ldr x14, [x12], #8
    str x14, [x13], #8
    subs x15, x15, #1
    b.ne .Lsurface_pressure
    movz x9, #0x9520
    movk x9, #3, lsl #16
    add x12, x0, x9
    add x13, x6, #4048
    mov x15, #506
.Lorography:
    ldr x14, [x12], #8
    str x14, [x13], #8
    subs x15, x15, #1
    b.ne .Lorography
    mov w0, #0
    ret
.Linvalid:
    mov w0, #1
    ret
.Lmetadata_invalid:
    mov w0, #2
    ret
.size md2asm_place_initial_spectral_fields, .-md2asm_place_initial_spectral_fields
.section .rodata
.p2align 3
.Lfield_pairs:
    .xword 152, 1
    .set .Llevel, 1
    .rept 19
    .xword 138, .Llevel
    .xword 155, .Llevel
    .xword 130, .Llevel
    .set .Llevel, .Llevel+1
    .endr
    .xword 129, 0
    .set .Llevel, 1
    .rept 19
    .xword 133, .Llevel
    .set .Llevel, .Llevel+1
    .endr
.section .note.GNU-stack,"",%progbits

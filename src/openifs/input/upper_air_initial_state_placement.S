/*
 * Upper-air initial state placement, revision 1.
 * Contract: skills/md2asm/references/openifs/input/upper_air_initial_state_placement.md
 *
 * Direct AArch64 assembly from the original SUGRIDUG storage assignment.
 * x0..x5: values, values_bytes, metadata, metadata_bytes, gfl, gfl_bytes.
 * Required spans: 1245184, 1824 and 2509824 bytes, aligned to eight.
 * GFL is in/out and disjoint from both immutable input spans.
 * Validate all metadata before writes. Return 0 success, 1 invalid
 * buffers or alias, 2 unexpected metadata. Rejections preserve GFL.
 *
 * Copy physical rows into slots 1,2,3,6. Clear complete slots 4,5,7,8.
 * Preserve the 9728 padding bytes in copied fields.
 * No floating-point arithmetic, stack storage or external call.
 * x18..x30 and all vector registers remain unchanged.
 * FPCR controls floating-point execution. FPSR records its status.
 * Both registers and errno remain unchanged. x0..x17 and flags scratch.
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
.global md2asm_place_initial_upper_air_fields
.type md2asm_place_initial_upper_air_fields, %function
md2asm_place_initial_upper_air_fields:
    cbz x0, .Linvalid
    cbz x2, .Linvalid
    cbz x4, .Linvalid
    orr x6, x0, x2
    orr x6, x6, x4
    tst x6, #7
    b.ne .Linvalid
    movz x6, #0
    movk x6, #19, lsl #16
    cmp x1, x6
    b.lo .Linvalid
    adds x7, x0, x6
    b.cs .Linvalid
    mov x6, #1824
    cmp x3, x6
    b.lo .Linvalid
    adds x8, x2, x6
    b.cs .Linvalid
    movz x6, #0x4c00
    movk x6, #38, lsl #16
    cmp x5, x6
    b.lo .Linvalid
    adds x9, x4, x6
    b.cs .Linvalid
    DISJOINT x4, x9, x0, x7
    DISJOINT x4, x9, x2, x8

    adrp x6, .Lfield_pairs
    add x6, x6, :lo12:.Lfield_pairs
    mov x7, x2
    mov x8, #76
.Lmetadata:
    ldp x9, x10, [x7], #16
    ldr x11, [x7], #8
    ldp x12, x13, [x6], #16
    cmp x9, x12
    b.ne .Lmetadata_invalid
    cmp x10, x13
    b.ne .Lmetadata_invalid
    cmp x11, #2048
    b.ne .Lmetadata_invalid
    subs x8, x8, #1
    b.ne .Lmetadata

    // A block has 8 fields, each with 19 levels of 24 stored rows.
    mov x6, #29184
    mov x7, #3648
    mov x8, #0
.Lzero_block:
    madd x9, x8, x6, x4
    mov x10, #0
    mov x11, #0xd8
.Lzero_slot:
    lsrv x12, x11, x10
    tbz x12, #0, .Lzero_next_slot
    madd x13, x10, x7, x9
    mov x14, #228
.Lzero_words:
    stp xzr, xzr, [x13], #16
    subs x14, x14, #1
    b.ne .Lzero_words
.Lzero_next_slot:
    add x10, x10, #1
    cmp x10, #8
    b.ne .Lzero_slot
    add x8, x8, #1
    cmp x8, #86
    b.ne .Lzero_block

    mov x7, #0
.Lcopy_field:
    mov x16, x7
    cmp x7, #3
    mov x17, #5
    csel x16, x17, x16, eq
    mov x9, #0
.Lcopy_level:
    cbz x7, .Lhumidity_record
    add x8, x9, x9, lsl #1
    add x8, x8, x7
    add x8, x8, #18
    b .Lrecord_ready
.Lhumidity_record:
    mov x8, x9
.Lrecord_ready:
    add x10, x0, x8, lsl #14
    mov x17, #3648
    madd x11, x16, x17, x4
    mov x17, #192
    madd x11, x9, x17, x11
    mov x12, #0
.Lcopy_block:
    madd x13, x12, x6, x11
    mov x14, #24
    cmp x12, #85
    mov x17, #8
    csel x14, x17, x14, eq
.Lcopy_rows:
    ldr x15, [x10], #8
    str x15, [x13], #8
    subs x14, x14, #1
    b.ne .Lcopy_rows
    add x12, x12, #1
    cmp x12, #86
    b.ne .Lcopy_block
    add x9, x9, #1
    cmp x9, #19
    b.ne .Lcopy_level
    add x7, x7, #1
    cmp x7, #4
    b.ne .Lcopy_field
    mov w0, #0
    ret
.Linvalid:
    mov w0, #1
    ret
.Lmetadata_invalid:
    mov w0, #2
    ret
.size md2asm_place_initial_upper_air_fields, .-md2asm_place_initial_upper_air_fields
.section .rodata
.p2align 3
.Lfield_pairs:
    .set .Llevel, 1
    .rept 19
    .xword 133, .Llevel
    .set .Llevel, .Llevel+1
    .endr
    .set .Llevel, 1
    .rept 19
    .xword 246, .Llevel
    .xword 247, .Llevel
    .xword 248, .Llevel
    .set .Llevel, .Llevel+1
    .endr
.section .note.GNU-stack,"",%progbits

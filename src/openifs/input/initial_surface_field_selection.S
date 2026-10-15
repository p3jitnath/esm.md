/*
 * Initial surface field selection from the original decoded input records.
 * Contract: skills/md2asm/references/openifs/input/initial_surface_field_selection.md
 * ABI x0..x7: values, values_bytes, metadata, metadata_bytes,
 * fields_2d, fields_2d_bytes, fields_3d, fields_3d_bytes.
 * Fixed spans are 2293760, 5600, 770048 and 409600 bytes.
 * Every pointer is eight-byte aligned. Outputs are disjoint from both
 * inputs and each other. The read-only inputs may overlap.
 * Metadata rows contain five signed 64-bit words. Only parameter, level
 * and count affect the original selection. Date and time remain decoded.
 * Return 0 on success, 1 for a buffer error, 2 for a wrong record count,
 * or 3 for a missing requested field. Rejection changes no output.
 * All validation and selection finish before zeroing or copying.
 * Integer instructions preserve every value bit, FPCR, FPSR and errno.
 * Preserve x18..x30 and all vector registers. The 256-byte frame contains
 * 96 saved-register bytes and 144 bytes of selected record indices.
 * No child, floating-point operation or omitted conversion is supplied.
 */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_select_initial_surface_fields
.type md2asm_select_initial_surface_fields,%function
md2asm_select_initial_surface_fields:
    stp x29, x30, [sp, #-256]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x19, x0
    mov x20, x2
    mov x21, x4
    mov x22, x6
    mov w0, #1
    cbz x19, .Lsurface_return
    cbz x20, .Lsurface_return
    cbz x21, .Lsurface_return
    cbz x22, .Lsurface_return
    orr x8, x19, x20
    orr x8, x8, x21
    orr x8, x8, x22
    tst x8, #7
    b.ne .Lsurface_return
    mov x8, #140
    lsl x8, x8, #14
    mov x9, #5600
    mov x10, #47
    lsl x10, x10, #14
    mov x11, #25
    lsl x11, x11, #14
    cmp x1, x8
    b.lo .Lsurface_return
    cmp x3, x9
    b.lo .Lsurface_return
    cmp x5, x10
    b.lo .Lsurface_return
    cmp x7, x11
    b.lo .Lsurface_return
    adds x23, x19, x8
    b.cs .Lsurface_return
    adds x24, x20, x9
    b.cs .Lsurface_return
    adds x25, x21, x10
    b.cs .Lsurface_return
    adds x26, x22, x11
    b.cs .Lsurface_return
    cmp x21, x23
    b.hs .Lsurface_two_metadata
    cmp x19, x25
    b.lo .Lsurface_return
.Lsurface_two_metadata:
    cmp x21, x24
    b.hs .Lsurface_three_values
    cmp x20, x25
    b.lo .Lsurface_return
.Lsurface_three_values:
    cmp x22, x23
    b.hs .Lsurface_three_metadata
    cmp x19, x26
    b.lo .Lsurface_return
.Lsurface_three_metadata:
    cmp x22, x24
    b.hs .Lsurface_outputs
    cmp x20, x26
    b.lo .Lsurface_return
.Lsurface_outputs:
    cmp x21, x26
    b.hs .Lsurface_counts
    cmp x22, x25
    b.lo .Lsurface_return
.Lsurface_counts:
    mov w0, #2
    add x8, x20, #16
    mov w9, #140
.Lsurface_count_loop:
    ldr x10, [x8], #40
    cmp x10, #2048
    b.ne .Lsurface_return
    subs w9, w9, #1
    b.ne .Lsurface_count_loop
    // A selected index is 0..139. The all-one halfword means missing.
    add x27, sp, #96
    mov x8, x27
    mov x9, #-1
    mov w10, #9
.Lsurface_clear_indices:
    stp x9, x9, [x8], #16
    subs w10, w10, #1
    b.ne .Lsurface_clear_indices
    adrp x23, .Lsurface_requests_two
    add x23, x23, :lo12:.Lsurface_requests_two
    adrp x24, .Lsurface_requests_three
    add x24, x24, :lo12:.Lsurface_requests_three
    mov w25, #0
    mov w26, #72
.Lsurface_record:
    cbz w26, .Lsurface_zero_outputs
    mov x8, #40
    madd x8, x25, x8, x20
    ldp x9, x10, [x8]
    mov w11, #0
.Lsurface_find_two:
    ldr w12, [x23, w11, uxtw #2]
    cmp x9, x12
    b.eq .Lsurface_two_match
    add w11, w11, #1
    cmp w11, #47
    b.lo .Lsurface_find_two
    b .Lsurface_check_three
.Lsurface_two_match:
    ldrh w12, [x27, w11, uxtw #1]
    tbz w12, #15, .Lsurface_check_three
    strh w25, [x27, w11, uxtw #1]
    sub w26, w26, #1
    b .Lsurface_next_record
.Lsurface_check_three:
    cmp x10, #1
    b.lo .Lsurface_next_record
    cmp x10, #5
    b.hi .Lsurface_next_record
    mov w11, #0
.Lsurface_find_three:
    ldr w12, [x24, w11, uxtw #2]
    cmp x9, x12
    b.eq .Lsurface_three_match
    add w11, w11, #1
    cmp w11, #5
    b.lo .Lsurface_find_three
    b .Lsurface_next_record
.Lsurface_three_match:
    mov w12, #5
    madd w12, w11, w12, w10
    add w12, w12, #46
    ldrh w13, [x27, w12, uxtw #1]
    tbz w13, #15, .Lsurface_next_record
    strh w25, [x27, w12, uxtw #1]
    sub w26, w26, #1
.Lsurface_next_record:
    add w25, w25, #1
    cmp w25, #140
    b.lo .Lsurface_record
    mov w0, #3
    cbnz w26, .Lsurface_return
.Lsurface_zero_outputs:
    // Original SUGRIDG defines both complete arrays before record copies.
    mov x8, x21
    mov w9, #48128
.Lsurface_zero_two:
    stp xzr, xzr, [x8], #16
    subs w9, w9, #1
    b.ne .Lsurface_zero_two
    mov x8, x22
    mov w9, #25600
.Lsurface_zero_three:
    stp xzr, xzr, [x8], #16
    subs w9, w9, #1
    b.ne .Lsurface_zero_three
    mov w8, #0
.Lsurface_copy_record:
    ldrh w9, [x27, w8, uxtw #1]
    add x10, x19, x9, lsl #14
    cmp w8, #47
    b.hs .Lsurface_copy_three_address
    add x11, x21, x8, lsl #14
    b .Lsurface_copy_cells
.Lsurface_copy_three_address:
    sub w11, w8, #47
    add x11, x22, x11, lsl #14
.Lsurface_copy_cells:
    mov w12, #1024
.Lsurface_copy_pair:
    ldp x13, x14, [x10], #16
    stp x13, x14, [x11], #16
    subs w12, w12, #1
    b.ne .Lsurface_copy_pair
    add w8, w8, #1
    cmp w8, #72
    b.lo .Lsurface_copy_record
    mov w0, #0
.Lsurface_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #256
    ret
.size md2asm_select_initial_surface_fields,.-md2asm_select_initial_surface_fields
.section .rodata
.p2align 2
.Lsurface_requests_two:
    .word 139, 170, 183, 236
    .word 39, 40, 41, 42
    .word 35, 36, 37, 38
    .word 228008, 228009, 228010, 228011
    .word 228012, 228013, 228014, 235
    .word 198, 173, 174, 160
    .word 172, 161, 162, 163
    .word 234, 27, 129172, 28
    .word 200199, 29, 30, 66
    .word 67, 43, 26, 228007
    .word 31, 34, 74, 15
    .word 16, 17, 18
.Lsurface_requests_three:
    .word 228141, 32, 33, 238, 228038
.section .note.GNU-stack,"",%progbits

/*
 * Initial surface field selection from the original decoded input records.
 * Contract: skills/md2asm/references/openifs/input/initial_surface_field_selection.md
 * ABI x0..x7: values, values_bytes, metadata, metadata_bytes,
 * fields_2d, fields_2d_bytes, fields_3d, fields_3d_bytes.
 * Legacy spans are 2293760, 5600, 770048 and 409600 bytes.
 * Operational spans are 4276592640, 3240, 2639872000 and 1319936000 bytes.
 * The operational entry selects 50 ordinary and 25 snow planes from 81 records.
 * Operational contract: skills/md2asm/references/openifs/input/operational_surface_field_selection.md
 * Every pointer is eight-byte aligned. Outputs are disjoint from both
 * inputs and each other. The read-only inputs may overlap.
 * Metadata rows contain five signed 64-bit words. Only parameter, level
 * and count affect the original selection. Date and time remain decoded.
 * Return 0 on success, 1 for a buffer error, 2 for a wrong record count,
 * or 3 for a missing requested field. Rejection changes no output.
 * All validation and selection finish before zeroing or copying.
 * Integer instructions preserve every value bit, FPCR, FPSR and errno.
 * Preserve x18..x30 and all vector registers. The 288-byte frame contains
 * 96 saved-register bytes, 160 index-region bytes and 24 shape bytes.
 * No child, floating-point operation or omitted conversion is supplied.
 */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_select_initial_surface_fields
.type md2asm_select_initial_surface_fields,%function
md2asm_select_initial_surface_fields:
    mov w8, #2048
    mov w9, #140
    mov w10, #47
    b .Lsurface_select_common
.global md2asm_select_operational_initial_surface_fields
.type md2asm_select_operational_initial_surface_fields,%function
md2asm_select_operational_initial_surface_fields:
    movz w8, #0xb400
    movk w8, #0x64, lsl #16
    mov w9, #81
    mov w10, #50
.Lsurface_select_common:
    stp x29, x30, [sp, #-288]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp x8, x9, [sp, #256]
    str x10, [sp, #272]
    lsl x28, x8, #3
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
    ldr x8, [sp, #264]
    mul x8, x8, x28
    ldr x12, [sp, #264]
    mov x9, #40
    mul x9, x12, x9
    ldr x10, [sp, #272]
    mul x10, x10, x28
    mov x11, #25
    mul x11, x11, x28
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
    ldr w9, [sp, #264]
    ldr x11, [sp, #256]
.Lsurface_count_loop:
    ldr x10, [x8], #40
    cmp x10, x11
    b.ne .Lsurface_return
    subs w9, w9, #1
    b.ne .Lsurface_count_loop
    // Each selected index fits a halfword. All-one means missing.
    add x27, sp, #96
    mov x8, x27
    mov x9, #-1
    mov w10, #10
.Lsurface_clear_indices:
    stp x9, x9, [x8], #16
    subs w10, w10, #1
    b.ne .Lsurface_clear_indices
    adrp x23, .Lsurface_requests_two
    add x23, x23, :lo12:.Lsurface_requests_two
    adrp x24, .Lsurface_requests_three
    add x24, x24, :lo12:.Lsurface_requests_three
    mov w25, #0
    ldr w26, [sp, #272]
    add w26, w26, #25
.Lsurface_record:
    cbz w26, .Lsurface_zero_outputs
    mov x8, #40
    madd x8, x25, x8, x20
    ldp x9, x10, [x8]
    mov w11, #0
.Lsurface_find_two:
    cmp w11, #43
    b.lo .Lsurface_common_request
    ldr w13, [sp, #272]
    cmp w13, #47
    b.eq .Lsurface_common_request
    sub w12, w11, #43
    adr x13, .Lsurface_operational_tail
    ldr w12, [x13, w12, uxtw #2]
    b .Lsurface_compare_request
.Lsurface_common_request:
    ldr w12, [x23, w11, uxtw #2]
.Lsurface_compare_request:
    cmp x9, x12
    b.eq .Lsurface_two_match
    add w11, w11, #1
    ldr w13, [sp, #272]
    cmp w11, w13
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
    ldr w13, [sp, #272]
    sub w13, w13, #1
    add w12, w12, w13
    ldrh w13, [x27, w12, uxtw #1]
    tbz w13, #15, .Lsurface_next_record
    strh w25, [x27, w12, uxtw #1]
    sub w26, w26, #1
.Lsurface_next_record:
    add w25, w25, #1
    ldr w9, [sp, #264]
    cmp w25, w9
    b.lo .Lsurface_record
    mov w0, #3
    cbnz w26, .Lsurface_return
.Lsurface_zero_outputs:
    // Original SUGRIDG defines both complete arrays before record copies.
    mov x8, x21
    ldr x9, [sp, #272]
    mul x9, x9, x28
    lsr x9, x9, #4
.Lsurface_zero_two:
    stp xzr, xzr, [x8], #16
    subs x9, x9, #1
    b.ne .Lsurface_zero_two
    mov x8, x22
    mov x9, #25
    mul x9, x9, x28
    lsr x9, x9, #4
.Lsurface_zero_three:
    stp xzr, xzr, [x8], #16
    subs x9, x9, #1
    b.ne .Lsurface_zero_three
    mov w8, #0
.Lsurface_copy_record:
    ldrh w9, [x27, w8, uxtw #1]
    madd x10, x9, x28, x19
    ldr w9, [sp, #272]
    cmp w8, w9
    b.hs .Lsurface_copy_three_address
    madd x11, x8, x28, x21
    b .Lsurface_copy_cells
.Lsurface_copy_three_address:
    sub w11, w8, w9
    madd x11, x11, x28, x22
.Lsurface_copy_cells:
    lsr x12, x28, #4
.Lsurface_copy_pair:
    ldp x13, x14, [x10], #16
    stp x13, x14, [x11], #16
    subs x12, x12, #1
    b.ne .Lsurface_copy_pair
    add w8, w8, #1
    ldr w9, [sp, #272]
    add w9, w9, #25
    cmp w8, w9
    b.lo .Lsurface_copy_record
    mov w0, #0
.Lsurface_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #288
    ret
.size md2asm_select_initial_surface_fields,.-md2asm_select_initial_surface_fields
.size md2asm_select_operational_initial_surface_fields,.-md2asm_select_operational_initial_surface_fields
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
.Lsurface_operational_tail:
    .word 210186, 210187, 210188, 210189, 210190, 210191, 148
.section .note.GNU-stack,"",%progbits

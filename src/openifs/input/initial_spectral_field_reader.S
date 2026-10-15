/*
 * Initial spectral field reader, revision 1.
 *
 * This direct AArch64 source was written from the frozen file contract.
 * No compiler-generated assembly or intermediate representation was used.
 * It decodes file records; it performs no forecast equation or state update.
 * Contract: [initial spectral field reader](../../../skills/md2asm/references/openifs/input/initial_spectral_field_reader.md).
 * The application binary interface, or ABI, defines arguments and saved registers.
 * FP64 means a 64-bit floating-point value.
 *
 * int md2asm_read_initial_spectral_fields(
 *   const char *path, double *values, uint64_t values_bytes,
 *   int64_t *metadata, uint64_t metadata_bytes, uint64_t *messages_read);
 *
 * x0: readable path ending in a zero byte.
 * x1: writable values, at least 315744 B.
 * x2: value capacity in bytes. x3: writable metadata, at least 1872 B.
 * x4: metadata capacity in bytes. x5: writable eight-byte message count.
 * Outputs are eight-byte aligned and their fixed written extents are disjoint.
 * Metadata has 78 consecutive {paramId, level, count} int64 rows.
 * Values have 78 consecutive records of 506 little-endian FP64 values.
 *
 * FPCR is the floating-point control register; it sets the rounding mode.
 * FPSR is the floating-point status register; it records arithmetic flags.
 * Return w0: 0 success; 1 invalid pointer, alignment, capacity, range overlap,
 * or FPCR; 2 open failure; 3 codec/read/delete failure; 4 wrong field order,
 * value count, message count, or extra message; 5 close failure.
 * Code 1 changes no public output. Other errors leave partial outputs.
 * After valid argument checks, messages_read starts at zero. It counts only
 * records whose decode and handle deletion both succeeded. The current value
 * record can be partly written on a decode failure. Metadata rows after the
 * committed prefix are untouched. A later EOF/close failure can leave all
 * 78 records committed. A cleanup error preserves any earlier error code.
 *
 * The 192-byte frame is 16-byte aligned. Preserve x18 through x29, x30,
 * FPCR, FPSR and errno. No SIMD register is used. All child calls obey the
 * ordinary Arm ABI. Only ecCodes file decoding and libc services are called.
 * The caller supplies readable/writable storage; capacities cannot prove
 * that an address is mapped. Invalid FPCR includes every nonzero bit.
 */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_read_initial_spectral_fields
.type md2asm_read_initial_spectral_fields, %function
md2asm_read_initial_spectral_fields:
    stp x29, x30, [sp, #-192]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    mrs x9, fpsr
    str x9, [sp, #144]
    mrs x9, fpcr
    str x9, [sp, #152]
    mov x19, x0
    mov x20, x1
    mov x21, x3
    mov x22, x5
    mov x23, xzr
    mov x24, xzr
    mov x25, xzr
    mov w26, #1
    mov x28, xzr
    cbz x0, .Lreturn
    cbz x1, .Lreturn
    cbz x3, .Lreturn
    cbz x5, .Lreturn
    cbnz x9, .Lreturn
    orr x9, x1, x3
    orr x9, x9, x5
    tst x9, #7
    b.ne .Lreturn
    movz x9, #0xd160
    movk x9, #4, lsl #16
    cmp x2, x9
    b.lo .Lreturn
    cmp x4, #1872
    b.lo .Lreturn
    adds x9, x1, x9
    b.cs .Lreturn
    adds x10, x3, #1872
    b.cs .Lreturn
    adds x11, x5, #8
    b.cs .Lreturn
    cmp x1, x10
    b.hs .Lvalues_metadata_disjoint
    cmp x3, x9
    b.lo .Lreturn
.Lvalues_metadata_disjoint:
    cmp x1, x11
    b.hs .Lvalues_count_disjoint
    cmp x5, x9
    b.lo .Lreturn
.Lvalues_count_disjoint:
    cmp x3, x11
    b.hs .Lall_outputs_disjoint
    cmp x5, x10
    b.lo .Lreturn
.Lall_outputs_disjoint:
    bl __errno_location
    mov x28, x0
    ldr w9, [x28]
    str w9, [sp, #168]
    mov x0, x19
    adrp x1, .Lbinary_mode
    add x1, x1, :lo12:.Lbinary_mode
    bl fopen
    mov x23, x0
    str xzr, [x22]
    cbz x23, .Lopen_failure
    adrp x27, .Lexpected_fields
    add x27, x27, :lo12:.Lexpected_fields
.Lnext_message:
    str wzr, [sp, #112]
    mov x0, xzr
    mov x1, x23
    add x2, sp, #112
    bl codes_grib_handle_new_from_file
    mov x24, x0
    ldr w9, [sp, #112]
    cbnz w9, .Lcodec_failure
    cbz x24, .Lend_of_file
    cmp x25, #78
    b.hs .Lscope_failure
    mov x0, x24
    adrp x1, .Lparameter_key
    add x1, x1, :lo12:.Lparameter_key
    add x2, sp, #128
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    mov x0, x24
    adrp x1, .Llevel_key
    add x1, x1, :lo12:.Llevel_key
    add x2, sp, #136
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    mov x0, x24
    adrp x1, .Lvalues_key
    add x1, x1, :lo12:.Lvalues_key
    add x2, sp, #120
    bl codes_get_size
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #120]
    cmp x9, #506
    b.ne .Lscope_failure
    add x9, x27, x25, lsl #4
    ldp x10, x11, [x9]
    ldp x12, x13, [sp, #128]
    cmp x10, x12
    b.ne .Lscope_failure
    cmp x11, x13
    b.ne .Lscope_failure
    mov x0, x24
    adrp x1, .Lvalues_key
    add x1, x1, :lo12:.Lvalues_key
    mov x2, x20
    add x3, sp, #120
    bl codes_get_double_array
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #120]
    cmp x9, #506
    b.ne .Lscope_failure
    mov x0, x24
    bl codes_handle_delete
    mov x24, xzr
    cbnz w0, .Lcodec_failure
    ldp x9, x10, [sp, #128]
    stp x9, x10, [x21]
    mov x9, #506
    str x9, [x21, #16]
    add x25, x25, #1
    str x25, [x22]
    add x20, x20, #4048
    add x21, x21, #24
    b .Lnext_message
.Lend_of_file:
    mov x0, x23
    bl ferror
    cbnz w0, .Lcodec_failure
    mov x0, x23
    bl feof
    cbz w0, .Lcodec_failure
    cmp x25, #78
    b.ne .Lscope_failure
    mov w26, wzr
    b .Lcleanup
.Lopen_failure:
    mov w26, #2
    b .Lcleanup
.Lcodec_failure:
    mov w26, #3
    b .Lcleanup
.Lscope_failure:
    mov w26, #4
.Lcleanup:
    cbz x24, .Lclose_file
    mov x0, x24
    bl codes_handle_delete
    mov x24, xzr
.Lclose_file:
    cbz x23, .Lreturn
    mov x0, x23
    bl fclose
    mov x23, xzr
    cbz w0, .Lreturn
    cbnz w26, .Lreturn
    mov w26, #5
.Lreturn:
    cbz x28, .Lrestore_status
    ldr w9, [sp, #168]
    str w9, [x28]
.Lrestore_status:
    ldr x9, [sp, #152]
    msr fpcr, x9
    ldr x9, [sp, #144]
    msr fpsr, x9
    mov w0, w26
    ldr x18, [sp, #96]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #192
    ret
.size md2asm_read_initial_spectral_fields, .-md2asm_read_initial_spectral_fields

.section .rodata
.p2align 3
.Lbinary_mode:
    .asciz "rb"
.Lparameter_key:
    .asciz "paramId"
.Llevel_key:
    .asciz "level"
.Lvalues_key:
    .asciz "values"
.p2align 3
.Lexpected_fields:
    .xword 152, 1
    .xword 138, 1
    .xword 155, 1
    .xword 130, 1
    .xword 138, 2
    .xword 155, 2
    .xword 130, 2
    .xword 138, 3
    .xword 155, 3
    .xword 130, 3
    .xword 138, 4
    .xword 155, 4
    .xword 130, 4
    .xword 138, 5
    .xword 155, 5
    .xword 130, 5
    .xword 138, 6
    .xword 155, 6
    .xword 130, 6
    .xword 138, 7
    .xword 155, 7
    .xword 130, 7
    .xword 138, 8
    .xword 155, 8
    .xword 130, 8
    .xword 138, 9
    .xword 155, 9
    .xword 130, 9
    .xword 138, 10
    .xword 155, 10
    .xword 130, 10
    .xword 138, 11
    .xword 155, 11
    .xword 130, 11
    .xword 138, 12
    .xword 155, 12
    .xword 130, 12
    .xword 138, 13
    .xword 155, 13
    .xword 130, 13
    .xword 138, 14
    .xword 155, 14
    .xword 130, 14
    .xword 138, 15
    .xword 155, 15
    .xword 130, 15
    .xword 138, 16
    .xword 155, 16
    .xword 130, 16
    .xword 138, 17
    .xword 155, 17
    .xword 130, 17
    .xword 138, 18
    .xword 155, 18
    .xword 130, 18
    .xword 138, 19
    .xword 155, 19
    .xword 130, 19
    .xword 129, 0
    .xword 133, 1
    .xword 133, 2
    .xword 133, 3
    .xword 133, 4
    .xword 133, 5
    .xword 133, 6
    .xword 133, 7
    .xword 133, 8
    .xword 133, 9
    .xword 133, 10
    .xword 133, 11
    .xword 133, 12
    .xword 133, 13
    .xword 133, 14
    .xword 133, 15
    .xword 133, 16
    .xword 133, 17
    .xword 133, 18
    .xword 133, 19
.section .note.GNU-stack,"",%progbits

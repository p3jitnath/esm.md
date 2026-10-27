/* Contract skills/md2asm/references/openifs/input/streaming_runtime_spectral_loading.md.
 * Private one-row selection of the accepted ecCodes spectral reader.
 * x0 path, x1 row, x2 row capacity, x3 metadata, x4 metadata capacity,
 * x5 count8, x6 validated schema, x7 private context128.
 * Frame224, alignment16. Preserve saved registers and incoming FP state/errno.
 * The original codec/status/EOF route is retained in order.
 */
.arch armv8.2-a
.text
.global md2asm_read_streaming_runtime_spectral_records
.hidden md2asm_read_streaming_runtime_spectral_records
.type md2asm_read_streaming_runtime_spectral_records, %function
md2asm_read_streaming_runtime_spectral_records:
    stp x29, x30, [sp, #-224]!
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
    mov x27, x6
    str x7, [sp, #208]
    cbz x0, .Lreturn
    cbz x1, .Lreturn
    cbz x3, .Lreturn
    cbz x5, .Lreturn
    cbnz x9, .Lreturn
    orr x9, x1, x3
    orr x9, x9, x5
    tst x9, #7
    b.ne .Lreturn
    ldr x9, [x27, #16]
    cmp x2, x9
    b.lo .Lreturn
    ldr x10, [x27, #24]
    cmp x4, x10
    b.lo .Lreturn
    adds x9, x1, x9
    b.cs .Lreturn
    adds x10, x3, x10
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
    ldr x9, [x27]
    cmp x25, x9
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
    ldr x10, [x27, #8]
    cmp x9, x10
    b.ne .Lscope_failure
    add x9, x27, #48
    add x9, x9, x25, lsl #5
    ldp x10, x11, [x9]
    ldp x12, x13, [sp, #128]
    cmp x10, x12
    b.ne .Lscope_failure
    cmp x11, x13
    b.ne .Lscope_failure
    ldr x9, [x27, #32]
    cmp x9, #5
    b.ne .Lidentity_ready
    mov x0, x24
    adrp x1, .Ldate_key
    add x1, x1, :lo12:.Ldate_key
    add x2, sp, #176
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    mov x0, x24
    adrp x1, .Ltime_key
    add x1, x1, :lo12:.Ltime_key
    add x2, sp, #184
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    add x9, x27, #48
    add x9, x9, x25, lsl #5
    ldp x10, x11, [x9, #16]
    ldp x12, x13, [sp, #176]
    cmp x10, x12
    b.ne .Lscope_failure
    cmp x11, x13
    b.ne .Lscope_failure
    mov x0, x24
    adrp x1, .LNi_key
    add x1, x1, :lo12:.LNi_key
    add x2, sp, #192
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #192]
    cmp x9, #64
    b.ne .Lscope_failure
    mov x0, x24
    adrp x1, .LNj_key
    add x1, x1, :lo12:.LNj_key
    add x2, sp, #192
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #192]
    cmp x9, #32
    b.ne .Lscope_failure
    mov x0, x24
    adrp x1, .LN_key
    add x1, x1, :lo12:.LN_key
    add x2, sp, #192
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #192]
    cmp x9, #16
    b.ne .Lscope_failure
    mov x0, x24
    adrp x1, .Lscan_key
    add x1, x1, :lo12:.Lscan_key
    add x2, sp, #192
    bl codes_get_long
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #192]
    cmp x9, #0
    b.ne .Lscope_failure
    mov x0, x24
    adrp x1, .Lmissing_key
    add x1, x1, :lo12:.Lmissing_key
    mov x2, #-9999
    bl codes_set_long
    cbnz w0, .Lcodec_failure
.Lidentity_ready:
    mov x0, x24
    adrp x1, .Lvalues_key
    add x1, x1, :lo12:.Lvalues_key
    mov x2, x20
    add x3, sp, #120
    bl codes_get_double_array
    cbnz w0, .Lcodec_failure
    ldr x9, [sp, #120]
    ldr x10, [x27, #8]
    cmp x9, x10
    b.ne .Lscope_failure
    mov x0, x24
    bl codes_handle_delete
    mov x24, xzr
    cbnz w0, .Lcodec_failure
    ldp x9, x10, [sp, #128]
    stp x9, x10, [x21]
    ldr x9, [x27, #8]
    str x9, [x21, #16]
    ldr x10, [x27, #32]
    cmp x10, #5
    b.ne .Lmetadata_stored
    ldp x10, x11, [sp, #176]
    stp x10, x11, [x21, #24]
.Lmetadata_stored:
    ldr x0, [sp, #208]
    mov x1, x20
    mov x2, x25
    bl md2asm_scatter_streaming_runtime_spectral_record
    add x25, x25, #1
    str x25, [x22]
    ldr x10, [x27, #32]
    add x21, x21, x10, lsl #3
    b .Lnext_message
.Lend_of_file:
    mov x0, x23
    bl ferror
    cbnz w0, .Lcodec_failure
    mov x0, x23
    bl feof
    cbz w0, .Lcodec_failure
    ldr x9, [x27]
    cmp x25, x9
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
    ldp x29, x30, [sp], #224
    ret
.size md2asm_read_streaming_runtime_spectral_records, .-md2asm_read_streaming_runtime_spectral_records
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
.Ldate_key:
    .asciz "dataDate"
.Ltime_key:
    .asciz "dataTime"
.LNi_key:
    .asciz "Ni"
.LNj_key:
    .asciz "Nj"
.LN_key:
    .asciz "N"
.Lscan_key:
    .asciz "scanningMode"
.Lmissing_key:
    .asciz "missingValue"
.p2align 3
.section .note.GNU-stack,"",%progbits

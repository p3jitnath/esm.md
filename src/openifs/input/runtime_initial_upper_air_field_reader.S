/* Contract: skills/md2asm/references/openifs/input/runtime_initial_upper_air_field_reader.md.
 * The verified source contract defines
 * arguments x0..x7, source field order, complete spans and status behavior.
 * Header counts select the shape without changing this assembled solver.
 * The 57,648-byte public frame contains a bounded private identity schema.
 */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_read_runtime_initial_upper_air_fields
.type md2asm_read_runtime_initial_upper_air_fields, %function
md2asm_read_runtime_initial_upper_air_fields:
    mrs x9, fpcr
    cbnz x9, .Lruntime_public_bad_early
    sub sp, sp, #14, lsl #12
    sub sp, sp, #304
    stp x29, x30, [sp]
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    stp x0, x1, [sp, #128]
    stp x2, x3, [sp, #144]
    stp x4, x5, [sp, #160]
    stp x6, x7, [sp, #176]
    cbz x0, .Lruntime_public_bad
    cbz x1, .Lruntime_public_bad
    cbz x3, .Lruntime_public_bad
    cbz x5, .Lruntime_public_bad
    cbz x6, .Lruntime_public_bad
    orr x9, x1, x3
    orr x9, x9, x5
    orr x9, x9, x6
    tst x9, #7
    b.ne .Lruntime_public_bad
    mov x19, x6
    mov x9, #5232
    cmp x7, x9
    b.lo .Lruntime_public_bad
    adds x10, x6, x9
    b.cs .Lruntime_public_bad
    ldr w20, [x19, #16]
    sub w9, w20, #1
    cmp w9, #255
    b.hi .Lruntime_public_bad
    ldr w21, [x19, #56]
    sub w9, w21, #1
    cmp w9, #1279
    b.hi .Lruntime_public_bad
    ldr w9, [x19, #8]
    lsl w10, w21, #1
    cmp w9, w10
    b.ne .Lruntime_public_bad
    lsl x23, x21, #2
    mov x9, #4215
    add x23, x23, x9
    and x23, x23, #-8
    mov x9, #5232
    cmp x23, x9
    csel x23, x23, x9, hs
    cmp x7, x23
    b.lo .Lruntime_public_bad
    adds x9, x19, x23
    b.cs .Lruntime_public_bad
    mov x22, #0
    mov w10, #0
    mov x11, #0
    mov x12, #4208
    add x12, x19, x12
.Lruntime_header_rows:
    ldr w13, [x12, x11, lsl #2]
    cmp w13, #0
    b.le .Lruntime_public_bad
    add x22, x22, x13
    cmp w13, w10
    csel w10, w13, w10, hi
    add x11, x11, #1
    cmp x11, x21
    b.lo .Lruntime_header_rows
    ldr w9, [x19, #12]
    cmp w9, w10
    b.ne .Lruntime_public_bad
    lsl x22, x22, #1
    mov w9, #0x7fffffff
    cmp x22, x9
    b.hi .Lruntime_public_bad
    ldr w24, [x19, #44]
    cmp w24, #0
    b.le .Lruntime_public_bad
    movz w9, #48831
    movk w9, #1525, lsl #16
    cmp w24, w9
    b.hi .Lruntime_public_bad
    ldr w25, [x19, #48]
    movz w9, #20804
    movk w9, #1, lsl #16
    cmp w25, w9
    b.hi .Lruntime_public_bad
    mov w9, #60
    udiv w10, w25, w9
    msub w11, w10, w9, w25
    cbnz w11, .Lruntime_public_bad
    udiv w11, w10, w9
    msub w12, w11, w9, w10
    mov w9, #100
    madd w25, w11, w9, w12
    mov x9, #7
    mul x13, x20, x9
    mul x14, x13, x22
    lsl x14, x14, #3
    mov x9, #40
    mul x15, x13, x9
    stp x14, x15, [sp, #192]
    str x13, [sp, #208]
    ldr x9, [sp, #144]
    cmp x9, x14
    b.lo .Lruntime_public_bad
    ldr x9, [sp, #160]
    cmp x9, x15
    b.lo .Lruntime_public_bad
    adds x9, x1, x14
    b.cs .Lruntime_public_bad
    adds x10, x3, x15
    b.cs .Lruntime_public_bad
    adds x11, x5, #8
    b.cs .Lruntime_public_bad
    add x12, x19, x23
.macro RUNTIME_DISJOINT a, ae, b, be
    cmp \a, \be
    b.hs 991f
    cmp \b, \ae
    b.lo .Lruntime_public_bad
991:
.endm
    RUNTIME_DISJOINT x1, x9, x3, x10
    RUNTIME_DISJOINT x1, x9, x5, x11
    RUNTIME_DISJOINT x3, x10, x5, x11
    RUNTIME_DISJOINT x1, x9, x19, x12
    RUNTIME_DISJOINT x3, x10, x19, x12
    RUNTIME_DISJOINT x5, x11, x19, x12
.purgem RUNTIME_DISJOINT
    add x26, sp, #256
    str x13, [x26]
    str x22, [x26, #8]
    stp x14, x15, [x26, #16]
    mov x9, #5
    stp x9, x21, [x26, #32]
    add x27, x26, #48
    mov x9, #1
    mov x10, #133
    mov x11, #203
.Lruntime_schema_q_ozone:
    stp x10, x9, [x27]
    stp x24, x25, [x27, #16]
    stp x11, x9, [x27, #32]
    stp x24, x25, [x27, #48]
    add x27, x27, #64
    add x9, x9, #1
    cmp x9, x20
    b.ls .Lruntime_schema_q_ozone
    adrp x28, .Lruntime_cloud_parameters
    add x28, x28, :lo12:.Lruntime_cloud_parameters
    mov x9, #1
.Lruntime_schema_cloud_level:
    mov x10, #0
.Lruntime_schema_cloud_family:
    ldr w11, [x28, x10, lsl #2]
    stp x11, x9, [x27]
    stp x24, x25, [x27, #16]
    add x27, x27, #32
    add x10, x10, #1
    cmp x10, #5
    b.lo .Lruntime_schema_cloud_family
    add x9, x9, #1
    cmp x9, x20
    b.ls .Lruntime_schema_cloud_level
    ldp x0, x1, [sp, #128]
    ldp x2, x3, [sp, #144]
    ldp x4, x5, [sp, #160]
    mov x6, x26
    mov x7, x19
    bl .Lread_initial_records
    b .Lruntime_public_return
.Lruntime_public_bad:
    mov w0, #1
.Lruntime_public_return:
    ldr x18, [sp, #96]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp]
    add sp, sp, #304
    add sp, sp, #14, lsl #12
    ret
.Lruntime_public_bad_early:
    mov w0, #1
    ret
.size md2asm_read_runtime_initial_upper_air_fields, .-md2asm_read_runtime_initial_upper_air_fields
.type .Lread_initial_records, %function
.Lread_initial_records:
    stp x29, x30, [sp, #-256]!
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
    str x7, [sp, #224]
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
    ldr x1, [sp, #224]
    ldr x2, [x27, #8]
    bl .Lvalidate_runtime_initial_grid
    cmp w0, #3
    b.eq .Lcodec_failure
    cbnz w0, .Lscope_failure
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
    add x25, x25, #1
    str x25, [x22]
    add x20, x20, x9, lsl #3
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
    ldp x29, x30, [sp], #256
    ret
.size .Lread_initial_records, .-.Lread_initial_records

/* x0 is a held codec handle, x1 the accepted header and x2 global N.
 * Return zero, codec status 3 or grid mismatch 4. The frame holds every
 * supported int64 row length. No numerical value is changed here.
 */
.p2align 2
.type .Lvalidate_runtime_initial_grid, %function
.Lvalidate_runtime_initial_grid:
    sub sp, sp, #5, lsl #12
    sub sp, sp, #144
    stp x29, x30, [sp]
    stp x19, x20, [sp, #16]
    stp x21, x18, [sp, #32]
    stp x22, x23, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    ldr w22, [x20, #56]
    lsl x23, x22, #1
.macro RUNTIME_GRID_LONG key, expected
    mov x0, x19
    adrp x1, \key
    add x1, x1, :lo12:\key
    add x2, sp, #80
    bl codes_get_long
    cbnz w0, .Lruntime_grid_codec
    ldr x9, [sp, #80]
    cmp x9, \expected
    b.ne .Lruntime_grid_bad
.endm
    RUNTIME_GRID_LONG .Ltemplate_key, #40
    RUNTIME_GRID_LONG .LN_key, x22
    RUNTIME_GRID_LONG .LNj_key, x23
    RUNTIME_GRID_LONG .Lscan_key, #0
    RUNTIME_GRID_LONG .Lpoint_count_key, x21
.purgem RUNTIME_GRID_LONG
    str wzr, [sp, #72]
    mov x0, x19
    adrp x1, .LNi_key
    add x1, x1, :lo12:.LNi_key
    add x2, sp, #72
    bl codes_is_missing
    ldr w9, [sp, #72]
    cbnz w9, .Lruntime_grid_codec
    cmp w0, #1
    b.eq .Lruntime_grid_reduced
    cbnz w0, .Lruntime_grid_bad
    cmp x22, #256
    b.hi .Lruntime_grid_bad
    mov x0, x19
    adrp x1, .LNi_key
    add x1, x1, :lo12:.LNi_key
    add x2, sp, #80
    bl codes_get_long
    cbnz w0, .Lruntime_grid_codec
    ldr x9, [sp, #80]
    ldr w10, [x20, #12]
    cmp x9, x10
    b.ne .Lruntime_grid_bad
    mul x11, x9, x23
    cmp x11, x21
    b.ne .Lruntime_grid_bad
    mov x10, #0
    mov x11, #4208
    add x11, x20, x11
.Lruntime_grid_regular_rows:
    ldr w12, [x11, x10, lsl #2]
    cmp x12, x9
    b.ne .Lruntime_grid_bad
    add x10, x10, #1
    cmp x10, x22
    b.lo .Lruntime_grid_regular_rows
    b .Lruntime_grid_missing_value
.Lruntime_grid_reduced:
    mov x0, x19
    adrp x1, .LPL_key
    add x1, x1, :lo12:.LPL_key
    add x2, sp, #64
    bl codes_get_size
    cbnz w0, .Lruntime_grid_codec
    ldr x9, [sp, #64]
    cmp x9, x23
    b.ne .Lruntime_grid_bad
    mov x0, x19
    adrp x1, .LPL_key
    add x1, x1, :lo12:.LPL_key
    add x2, sp, #144
    add x3, sp, #64
    bl codes_get_long_array
    cbnz w0, .Lruntime_grid_codec
    ldr x9, [sp, #64]
    cmp x9, x23
    b.ne .Lruntime_grid_bad
    mov x10, #0
    add x11, sp, #144
    mov x12, #4208
    add x12, x20, x12
.Lruntime_grid_reduced_rows:
    sub x13, x23, #1
    sub x13, x13, x10
    cmp x10, x13
    csel x13, x10, x13, lo
    ldr w14, [x12, x13, lsl #2]
    ldr x9, [x11, x10, lsl #3]
    cmp x9, x14
    b.ne .Lruntime_grid_bad
    add x10, x10, #1
    cmp x10, x23
    b.lo .Lruntime_grid_reduced_rows
.Lruntime_grid_missing_value:
    mov x0, x19
    adrp x1, .Lmissing_key
    add x1, x1, :lo12:.Lmissing_key
    mov x2, #-9999
    bl codes_set_long
    cbnz w0, .Lruntime_grid_codec
    mov w0, #0
    b .Lruntime_grid_return
.Lruntime_grid_codec:
    mov w0, #3
    b .Lruntime_grid_return
.Lruntime_grid_bad:
    mov w0, #4
.Lruntime_grid_return:
    ldp x22, x23, [sp, #48]
    ldp x21, x18, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp]
    add sp, sp, #144
    add sp, sp, #5, lsl #12
    ret
.size .Lvalidate_runtime_initial_grid, .-.Lvalidate_runtime_initial_grid

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
.LPL_key:
    .asciz "pl"
.Ltemplate_key:
    .asciz "gridDefinitionTemplateNumber"
.Lpoint_count_key:
    .asciz "numberOfDataPoints"

.p2align 2
.Lruntime_cloud_parameters:
    .word 75, 76, 246, 247, 248
.section .note.GNU-stack,"",%progbits

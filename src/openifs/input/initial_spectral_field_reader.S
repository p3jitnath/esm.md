/* Qualified live-provider contract: skills/md2asm/references/openifs/input/initial_spectral_field_reader.md. */
/*
 * Initial spectral, upper-air and surface field readers, revision 4.
 *
 * Six six-argument entries share one private direct assembly decoder.
 * Contracts: skills/md2asm/references/openifs/input/initial_spectral_field_reader.md
 * skills/md2asm/references/openifs/input/initial_upper_air_field_reader.md and
 * skills/md2asm/references/openifs/input/initial_surface_field_reader.md and
 * skills/md2asm/references/openifs/input/operational_gridpoint_field_readers.md.
 *
 * int entry(path, values, values_bytes, metadata, metadata_bytes, messages_read)
 * Arguments x0..x5 have the same order as the original spectral reader.
 * Trusted read-only schema headers define record count, uniform value count,
 * values extent and metadata extent. Each following row holds paramId/level.
 * Public entries select a fixed schema before entering the shared body.
 * Surface and operational grid-point rows also freeze dataDate/dataTime.
 * The coarse surface grid is 64 by 32; operational grids have 2,560 reduced rows.
 * FP64 means 64-bit floating-point values. Coarse spectral/upper-air and
 * operational spectral metadata have three signed 64-bit words per record.
 * Surface and operational grid-point metadata have five signed 64-bit words.
 * The completed-record counter is unsigned 64-bit.
 * Output pointers are eight-byte aligned and their fixed extents are disjoint.
 * The caller supplies a readable zero-byte-terminated path and mapped buffers.
 * Spectral extents are 315744/1872/8 bytes for 78 records of 506 values.
 * Operational spectral extents are 5417502720/9912/8 bytes for 413 records of 1639680 values.
 * Upper-air extents are 1245184/1824/8 bytes for 76 records of 2048 values.
 * Surface extents are 2293760/5600/8 bytes for 140 records of 2048 values.
 * Operational surface extents are 4276592640/3240/8 bytes for 81 records.
 * Operational upper-air extents are 50632744960/38360/8 bytes for 959 records.
 * Both operational grid-point files have 6,599,680 FP64 values per record.
 * Five-word metadata adds date/time after parameter, level and value count.
 * The surface codec retains the original missingValue setting of -9999.
 *
 * Return 0 for success, 1 for an invalid argument or a nonzero floating-point control register, 2 for open
 * failure, 3 for codec/read/delete failure, 4 for schema/count mismatch,
 * and 5 for close failure. Code 1 changes no output. Later failures retain
 * only the documented decoded prefix and possible current value record.
 * The count is initialised after fopen consumes the path. Cleanup preserves
 * an earlier error. Each held handle and opened file is released once.
 *
 * The 224-byte frame is 16-byte aligned. Preserve x18..x30 and all required
 * vector low halves through ordinary C child calls. FPCR is the floating-point
 * control register and FPSR records floating-point status. Both and errno
 * are restored on return. The private operational grid checker has a 20,624-byte
 * frame for all row counts, giving 20,848 nested assembly bytes.
 * No forecast arithmetic or Fortran call is used.
 */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_read_initial_spectral_fields
.type md2asm_read_initial_spectral_fields, %function
md2asm_read_initial_spectral_fields:
    adrp x6, .Lspectral_schema
    add x6, x6, :lo12:.Lspectral_schema
    b .Lread_initial_records
.size md2asm_read_initial_spectral_fields, .-md2asm_read_initial_spectral_fields
.global md2asm_read_initial_upper_air_fields
.type md2asm_read_initial_upper_air_fields, %function
md2asm_read_initial_upper_air_fields:
    adrp x6, .Lupper_air_schema
    add x6, x6, :lo12:.Lupper_air_schema
    b .Lread_initial_records
.size md2asm_read_initial_upper_air_fields, .-md2asm_read_initial_upper_air_fields
.global md2asm_read_initial_surface_fields
.type md2asm_read_initial_surface_fields, %function
md2asm_read_initial_surface_fields:
    adrp x6, .Lsurface_schema
    add x6, x6, :lo12:.Lsurface_schema
    b .Lread_initial_records
.size md2asm_read_initial_surface_fields, .-md2asm_read_initial_surface_fields
.global md2asm_grid_decoder_unused_operational_spectral_fields
.type md2asm_grid_decoder_unused_operational_spectral_fields, %function
md2asm_grid_decoder_unused_operational_spectral_fields:
    adrp x6, .Loperational_spectral_schema
    add x6, x6, :lo12:.Loperational_spectral_schema
    b .Lread_initial_records
.size md2asm_grid_decoder_unused_operational_spectral_fields, .-md2asm_grid_decoder_unused_operational_spectral_fields
.global md2asm_read_operational_initial_surface_fields
.type md2asm_read_operational_initial_surface_fields, %function
md2asm_read_operational_initial_surface_fields:
    adrp x6, .Loperational_surface_schema
    add x6, x6, :lo12:.Loperational_surface_schema
    b .Lread_initial_records
.size md2asm_read_operational_initial_surface_fields, .-md2asm_read_operational_initial_surface_fields
.global md2asm_read_operational_initial_upper_air_fields
.type md2asm_read_operational_initial_upper_air_fields, %function
md2asm_read_operational_initial_upper_air_fields:
    adrp x6, .Loperational_upper_air_schema
    add x6, x6, :lo12:.Loperational_upper_air_schema
    b .Lread_initial_records
.size md2asm_read_operational_initial_upper_air_fields, .-md2asm_read_operational_initial_upper_air_fields
.type .Lread_initial_records, %function
.Lread_initial_records:
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
    ldr x9, [x27, #40]
    cmp x9, #1280
    b.ne .Lregular_grid_identity
    mov x0, x24
    bl .Lvalidate_operational_initial_grid
    cmp w0, #3
    b.eq .Lcodec_failure
    cbnz w0, .Lscope_failure
    b .Lidentity_ready
.Lregular_grid_identity:
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
    ldp x29, x30, [sp], #224
    ret
.size .Lread_initial_records, .-.Lread_initial_records
/* Check the complete reduced-grid row list through the public codec.
 * x0 is a live codec handle. Return 0, codec error 3 or wrong-grid status 4.
 * The 20,624-byte frame holds all 2,560 int64 row counts and saved registers.
 * This private child preserves x18 and the required integer registers.
 */
.p2align 2
.type .Lvalidate_operational_initial_grid, %function
.Lvalidate_operational_initial_grid:
    sub sp, sp, #5, lsl #12
    sub sp, sp, #144
    stp x29, x30, [sp]
    stp x19, x20, [sp, #16]
    stp x21, x18, [sp, #32]
    mov x29, sp
    mov x19, x0
.macro OPERATIONAL_GRID_LONG key, expected
    mov x0, x19
    adrp x1, \key
    add x1, x1, :lo12:\key
    add x2, sp, #80
    bl codes_get_long
    cbnz w0, .Loperational_grid_codec
    ldr x9, [sp, #80]
    cmp x9, #\expected
    b.ne .Loperational_grid_bad
.endm
    OPERATIONAL_GRID_LONG .LN_key, 1280
    OPERATIONAL_GRID_LONG .LNj_key, 2560
    OPERATIONAL_GRID_LONG .Lscan_key, 0
.purgem OPERATIONAL_GRID_LONG
    str wzr, [sp, #72]
    mov x0, x19
    adrp x1, .LNi_key
    add x1, x1, :lo12:.LNi_key
    add x2, sp, #72
    bl codes_is_missing
    ldr w9, [sp, #72]
    cbnz w9, .Loperational_grid_codec
    cmp w0, #1
    b.ne .Loperational_grid_bad
    mov x0, x19
    adrp x1, .Loperational_PL_key
    add x1, x1, :lo12:.Loperational_PL_key
    add x2, sp, #64
    bl codes_get_size
    cbnz w0, .Loperational_grid_codec
    ldr x9, [sp, #64]
    cmp x9, #2560
    b.ne .Loperational_grid_bad
    mov x0, x19
    adrp x1, .Loperational_PL_key
    add x1, x1, :lo12:.Loperational_PL_key
    add x2, sp, #144
    add x3, sp, #64
    bl codes_get_long_array
    cbnz w0, .Loperational_grid_codec
    ldr x9, [sp, #64]
    cmp x9, #2560
    b.ne .Loperational_grid_bad
    add x21, sp, #144
    mov x20, #0
.Loperational_grid_rows:
    mov x11, #2559
    sub x11, x11, x20
    cmp x20, x11
    csel x11, x20, x11, lo
    lsl x11, x11, #2
    add x11, x11, #20
    ldr x9, [x21, x20, lsl #3]
    cmp x9, x11
    b.ne .Loperational_grid_bad
    add x20, x20, #1
    cmp x20, #2560
    b.lo .Loperational_grid_rows
    mov x0, x19
    adrp x1, .Lmissing_key
    add x1, x1, :lo12:.Lmissing_key
    mov x2, #-9999
    bl codes_set_long
    cbnz w0, .Loperational_grid_codec
    mov w0, #0
    b .Loperational_grid_return
.Loperational_grid_codec:
    mov w0, #3
    b .Loperational_grid_return
.Loperational_grid_bad:
    mov w0, #4
.Loperational_grid_return:
    ldp x21, x18, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp]
    add sp, sp, #144
    add sp, sp, #5, lsl #12
    ret
.size .Lvalidate_operational_initial_grid, .-.Lvalidate_operational_initial_grid
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
.Lspectral_schema:
    .xword 78, 506, 315744, 1872, 3, 0
    .xword 152, 1, 0, 0
    .set .Llevel, 1
    .rept 19
    .xword 138, .Llevel, 0, 0
    .xword 155, .Llevel, 0, 0
    .xword 130, .Llevel, 0, 0
    .set .Llevel, .Llevel+1
    .endr
    .xword 129, 0, 0, 0
    .set .Llevel, 1
    .rept 19
    .xword 133, .Llevel, 0, 0
    .set .Llevel, .Llevel+1
    .endr
.p2align 3
.Lupper_air_schema:
    .xword 76, 2048, 1245184, 1824, 3, 0
    .set .Llevel, 1
    .rept 19
    .xword 133, .Llevel, 0, 0
    .set .Llevel, .Llevel+1
    .endr
    .set .Llevel, 1
    .rept 19
    .xword 246, .Llevel, 0, 0
    .xword 247, .Llevel, 0, 0
    .xword 248, .Llevel, 0, 0
    .set .Llevel, .Llevel+1
    .endr
.p2align 3
.Lsurface_schema:
    .xword 140, 2048, 2293760, 5600, 5, 16
    .set .Llevel, 1
    .rept 5
    .xword 32, .Llevel, 20041015, 1200
    .set .Llevel, .Llevel+1
    .endr
    .set .Llevel, 1
    .rept 5
    .xword 238, .Llevel, 20041015, 0
    .set .Llevel, .Llevel+1
    .endr
    .set .Llevel, 1
    .rept 5
    .xword 33, .Llevel, 20041015, 0
    .set .Llevel, .Llevel+1
    .endr
    .xword 139, 0, 20041015, 1200
    .xword 170, 7, 20041015, 1200
    .xword 183, 28, 20041015, 1200
    .xword 236, 100, 20041015, 1200
    .xword 39, 0, 20041015, 1200
    .xword 40, 7, 20041015, 1200
    .xword 41, 28, 20041015, 1200
    .xword 42, 100, 20041015, 1200
    .xword 198, 0, 20041015, 1200
    .xword 235, 0, 20041015, 1200
    .xword 31, 0, 20041015, 1200
    .xword 34, 0, 20041015, 1200
    .xword 35, 0, 20041015, 1200
    .xword 36, 7, 20041015, 1200
    .xword 37, 28, 20041015, 1200
    .xword 38, 100, 20041015, 1200
    .xword 148, 0, 20041015, 1200
    .xword 172, 0, 20041015, 1200
    .xword 173, 0, 20041015, 1200
    .xword 174, 0, 20041015, 1200
    .xword 160, 0, 20041015, 1200
    .xword 161, 0, 20041015, 1200
    .xword 162, 0, 20041015, 1200
    .xword 163, 0, 20041015, 1200
    .xword 234, 0, 20041015, 1200
    .xword 28, 0, 20041015, 1200
    .xword 27, 0, 20041015, 1200
    .xword 30, 0, 20041015, 1200
    .xword 29, 0, 20041015, 1200
    .xword 74, 0, 19960101, 0
    .set .Lmonth, 1
    .rept 12
    .xword 18, 0, 99990015+100*.Lmonth, 0
    .set .Lmonth, .Lmonth+1
    .endr
    .set .Lmonth, 1
    .rept 12
    .xword 17, 0, 99990015+100*.Lmonth, 0
    .set .Lmonth, .Lmonth+1
    .endr
    .set .Lmonth, 1
    .rept 12
    .xword 16, 0, 99990015+100*.Lmonth, 0
    .set .Lmonth, .Lmonth+1
    .endr
    .set .Lmonth, 1
    .rept 12
    .xword 15, 0, 99990015+100*.Lmonth, 0
    .set .Lmonth, .Lmonth+1
    .endr
    .xword 43, 0, 19950101, 0
    .set .Lmonth, 1
    .rept 12
    .xword 66, 0, 99990015+100*.Lmonth, 0
    .set .Lmonth, .Lmonth+1
    .endr
    .set .Lmonth, 1
    .rept 12
    .xword 67, 0, 99990015+100*.Lmonth, 0
    .set .Lmonth, .Lmonth+1
    .endr
    .xword 228007, 0, 99990115, 0
    .xword 26, 0, 20140331, 0
    .xword 228011, 0, 20041015, 0
    .xword 228012, 0, 20041015, 0
    .xword 228008, 0, 20041015, 0
    .xword 228009, 0, 20041015, 0
    .xword 228013, 0, 20041015, 0
    .xword 228014, 0, 20041015, 0
    .xword 228010, 0, 20041015, 0
    .set .Llevel, 1
    .rept 5
    .xword 228141, .Llevel, 20041015, 0
    .set .Llevel, .Llevel+1
    .endr
    .set .Llevel, 1
    .rept 5
    .xword 228038, .Llevel, 20041015, 0
    .set .Llevel, .Llevel+1
    .endr
    .xword 200199, 0, 99990615, 0
    .xword 129172, 0, 20110131, 0
    .xword 200026, 0, 99990615, 0
.p2align 3
.Loperational_spectral_schema:
    .xword 413, 1639680, 5417502720, 9912, 3, 0
    .xword 152, 1, 0, 0
    .set .Loperational_level, 1
    .rept 137
    .xword 138, .Loperational_level, 0, 0
    .xword 155, .Loperational_level, 0, 0
    .xword 130, .Loperational_level, 0, 0
    .set .Loperational_level, .Loperational_level+1
    .endr
    .xword 129, 0, 0, 0
.Loperational_PL_key:
    .asciz "pl"

.p2align 3
.Loperational_surface_schema:
    .xword 81, 6599680, 4276592640, 3240, 5, 1280
    .xword 172, 0, 20110131, 0
    .xword 32, 1, 20260621, 0
    .xword 32, 2, 20260621, 0
    .xword 32, 3, 20260621, 0
    .xword 32, 4, 20260621, 0
    .xword 32, 5, 20260621, 0
    .xword 139, 0, 20260621, 0
    .xword 170, 7, 20260621, 0
    .xword 183, 28, 20260621, 0
    .xword 236, 100, 20260621, 0
    .xword 39, 0, 20260621, 0
    .xword 40, 7, 20260621, 0
    .xword 41, 28, 20260621, 0
    .xword 42, 100, 20260621, 0
    .xword 198, 0, 20260621, 0
    .xword 235, 0, 20260621, 0
    .xword 31, 0, 20260621, 0
    .xword 228008, 0, 20260621, 0
    .xword 228009, 0, 20260621, 0
    .xword 228010, 0, 20260621, 0
    .xword 228011, 0, 20260621, 0
    .xword 228012, 0, 20260621, 0
    .xword 228013, 0, 20260621, 0
    .xword 228014, 0, 20260621, 0
    .xword 34, 0, 20260621, 0
    .xword 35, 0, 20260621, 0
    .xword 36, 7, 20260621, 0
    .xword 37, 28, 20260621, 0
    .xword 38, 100, 20260621, 0
    .xword 148, 0, 20260621, 0
    .xword 228141, 1, 20260621, 0
    .xword 238, 1, 20260621, 0
    .xword 33, 1, 20260621, 0
    .xword 228038, 1, 20260621, 0
    .xword 228141, 2, 20260621, 0
    .xword 238, 2, 20260621, 0
    .xword 33, 2, 20260621, 0
    .xword 228038, 2, 20260621, 0
    .xword 228141, 3, 20260621, 0
    .xword 238, 3, 20260621, 0
    .xword 33, 3, 20260621, 0
    .xword 228038, 3, 20260621, 0
    .xword 228141, 4, 20260621, 0
    .xword 238, 4, 20260621, 0
    .xword 33, 4, 20260621, 0
    .xword 228038, 4, 20260621, 0
    .xword 228141, 5, 20260621, 0
    .xword 238, 5, 20260621, 0
    .xword 33, 5, 20260621, 0
    .xword 228038, 5, 20260621, 0
    .xword 172, 0, 20260621, 0
    .xword 173, 0, 20260621, 0
    .xword 174, 0, 20260621, 0
    .xword 15, 0, 20260621, 0
    .xword 17, 0, 20260621, 0
    .xword 16, 0, 20260621, 0
    .xword 18, 0, 20260621, 0
    .xword 210186, 0, 20260621, 0
    .xword 210187, 0, 20260621, 0
    .xword 210188, 0, 20260621, 0
    .xword 210189, 0, 20260621, 0
    .xword 210190, 0, 20260621, 0
    .xword 210191, 0, 20260621, 0
    .xword 66, 0, 20260621, 0
    .xword 67, 0, 20260621, 0
    .xword 74, 0, 20260621, 0
    .xword 43, 0, 20260621, 0
    .xword 160, 0, 20260621, 0
    .xword 161, 0, 20260621, 0
    .xword 162, 0, 20260621, 0
    .xword 163, 0, 20260621, 0
    .xword 234, 0, 20260621, 0
    .xword 28, 0, 20260621, 0
    .xword 27, 0, 20260621, 0
    .xword 30, 0, 20260621, 0
    .xword 29, 0, 20260621, 0
    .xword 26, 0, 20260621, 0
    .xword 228007, 0, 20260621, 0
    .xword 200199, 0, 99990615, 0
    .xword 129172, 0, 20110131, 0
    .xword 200026, 0, 20260621, 0

.p2align 3
.Loperational_upper_air_schema:
    .xword 959, 6599680, 50632744960, 38360, 5, 1280
    .set .Loperational_level, 1
    .rept 137
    .xword 133, .Loperational_level, 20260621, 0
    .xword 203, .Loperational_level, 20260621, 0
    .set .Loperational_level, .Loperational_level+1
    .endr
    .set .Loperational_level, 1
    .rept 137
    .xword 75, .Loperational_level, 20260621, 0
    .xword 76, .Loperational_level, 20260621, 0
    .xword 246, .Loperational_level, 20260621, 0
    .xword 247, .Loperational_level, 20260621, 0
    .xword 248, .Loperational_level, 20260621, 0
    .set .Loperational_level, .Loperational_level+1
    .endr

.section .note.GNU-stack,"",%progbits

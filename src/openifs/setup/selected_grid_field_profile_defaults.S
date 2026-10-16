/* Source-defined profile defaults for the frozen selected ECMWF field mode.
 * x0 is an aligned fresh-zero owned array of nine 256-byte source profiles.
 * Return 0 or 2 before mutation. The contract records all selected input controls.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_grid_field_profiles
.type md2asm_initialize_selected_grid_field_profiles,%function
md2asm_initialize_selected_grid_field_profiles:
 cbz x0,.Lprofiles_reject
 tst x0,#7
 b.ne .Lprofiles_reject
 adds x9,x0,#2304
 b.cs .Lprofiles_reject
 mrs x9,fpcr
 cbnz x9,.Lprofiles_reject
 mov x3,x0
 mov w4,#288
.Lprofiles_check_fresh:
 ldr x9,[x3],#8
 cbnz x9,.Lprofiles_reject
 subs w4,w4,#1
 b.ne .Lprofiles_check_fresh
 mov x3,x0
 mov w4,#0
 mov w9,#1
 adr x10,.Lprofiles_useless
 ldr x10,[x10]
 mov x11,#0x3ff0000000000000
.Lprofiles_named:
 str w9,[x3,#20]
 str x10,[x3,#24]
 str w9,[x3,#32]
 str w9,[x3,#36]
 str w9,[x3,#84]
 str w9,[x3,#88]
 str x10,[x3,#160]
 str x11,[x3,#216]
 cmp w4,#6
 b.hs .Lprofiles_named_no_grid
 str w9,[x3,#44]
.Lprofiles_named_no_grid:
 cbz w4,.Lprofiles_named_physics
 cmp w4,#5
 b.lo .Lprofiles_named_no_physics
.Lprofiles_named_physics:
 str w9,[x3,#68]
.Lprofiles_named_no_physics:
 cmp w4,#5
 b.eq .Lprofiles_named_no_tendency
 str w9,[x3,#72]
.Lprofiles_named_no_tendency:
 cbz w4,.Lprofiles_named_qm
 cmp w4,#6
 b.ne .Lprofiles_named_qm3d
.Lprofiles_named_qm:
 str w9,[x3,#108]
 b .Lprofiles_named_after_qm
.Lprofiles_named_qm3d:
 str w9,[x3,#116]
.Lprofiles_named_after_qm:
 cbnz w4,.Lprofiles_named_no_weno
 str w9,[x3,#124]
.Lprofiles_named_no_weno:
 cmp w4,#5
 b.hs .Lprofiles_named_no_mass_fix
 str w9,[x3,#208]
.Lprofiles_named_no_mass_fix:
 add x3,x3,#256
 add w4,w4,#1
 cmp w4,#7
 b.lo .Lprofiles_named
 adr x12,.Lprofiles_nogw_names
 ldp x13,x14,[x12]
 stp x13,x14,[x3]
 ldp x13,x14,[x12,#16]
 stp x13,x14,[x3,#256]
 adr x12,.Lprofiles_nogw_code
 ldr w13,[x12]
 str w13,[x3,#16]
 add w13,w13,#2
 str w13,[x3,#272]
 str w9,[x3,#32]
 str w9,[x3,#44]
 str w9,[x3,#64]
 str x11,[x3,#216]
 str w9,[x3,#288]
 str w9,[x3,#300]
 str w9,[x3,#320]
 str x11,[x3,#472]
 mov w0,#0
 ret
.Lprofiles_reject:
 mov w0,#2
 ret
.size md2asm_initialize_selected_grid_field_profiles,.-md2asm_initialize_selected_grid_field_profiles
.section .rodata
.p2align 3
.Lprofiles_useless: .double -999.0
.Lprofiles_nogw_code: .word 228134
.Lprofiles_nogw_names:
 .ascii "TENUNOGW        "
 .ascii "TENVNOGW        "
.section .note.GNU-stack,"",%progbits

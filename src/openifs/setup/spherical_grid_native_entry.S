// Contract: skills/md2asm/references/openifs/setup/native_grid_setup.md.
// Original SUGEM1B ABI: x0 is the live raw GEOMETRY record.
// Contract: skills/md2asm/references/openifs/setup/spherical_grid_setup.md. Load process indices MYSETW
// and MY_REGION_EW, pi and radius from their initialized scalar input addresses.
// These are explicit compatibility inputs; full autonomy must own these values.
// No original callable, constructor, vtable or type descriptor is used.
// Success transfers NSTAGP ownership to GEOMETRY. Failure stops before continuation.
// Frame64, alignment16; preserve x18 and required AAPCS64 saved registers.
.text
.p2align 4
.global sugem1b_
.type sugem1b_,%function
sugem1b_:
    mrs x9, fpcr
    cbnz x9, .Lspherical_native_failed
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    str x18, [sp, #16]
    adrp x2, :got:__yommp0_MOD_mysetw
    ldr x2, [x2, :got_lo12:__yommp0_MOD_mysetw]
    ldr w3, [x2]
    str w3, [sp, #32]
    adrp x2, :got:__yommp0_MOD_my_region_ew
    ldr x2, [x2, :got_lo12:__yommp0_MOD_my_region_ew]
    ldr w3, [x2]
    str w3, [sp, #36]
    adrp x2, :got:__yomcst_MOD_rpi
    ldr x2, [x2, :got_lo12:__yomcst_MOD_rpi]
    ldr x3, [x2]
    str x3, [sp, #40]
    adrp x2, :got:__yomcst_MOD_ra
    ldr x2, [x2, :got_lo12:__yomcst_MOD_ra]
    ldr x3, [x2]
    str x3, [sp, #48]
    add x1, sp, #32
    bl md2asm_initialize_spherical_grid
    cbnz w0, .Lspherical_native_failed
    adrp x2, .Lspherical_native_calls
    ldr x3, [x2, :lo12:.Lspherical_native_calls]
    add x3, x3, #1
    str x3, [x2, :lo12:.Lspherical_native_calls]
    ldr x18, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.Lspherical_native_failed:
    b abort
.size sugem1b_,.-sugem1b_
.global md2asm_spherical_grid_native_count_get
.type md2asm_spherical_grid_native_count_get,%function
md2asm_spherical_grid_native_count_get:
    adrp x0, .Lspherical_native_calls
    ldr x0, [x0, :lo12:.Lspherical_native_calls]
    ret
.size md2asm_spherical_grid_native_count_get,.-md2asm_spherical_grid_native_count_get
.bss
.balign 8
.Lspherical_native_calls:
    .zero 8
.section .note.GNU-stack,"",%progbits

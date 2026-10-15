// Contract: skills/md2asm/references/openifs/setup/native_grid_setup.md.
// Original selected SUGAW seven-pointer ABI. Contract: skills/md2asm/references/openifs/setup/gaussian_latitude_setup.md.
// x0 count32, x1 order0, x2 degree32, x3 sine output, x4 weight output,
// x5 unused PANM input, x6 coefficient matrix PFN(0:32,0:32).
// Recompute and check the17 consumed coefficients before output construction.
// The original PFN address is a verification compatibility input, not a target.
// No Fortran callable, constructor, vtable or numerical library target is used.
// Frame208, alignment16; preserve x18 and required AAPCS64 saved registers.
.text
.p2align 4
.global __sugaw_mod_MOD_sugaw
.type __sugaw_mod_MOD_sugaw,%function
__sugaw_mod_MOD_sugaw:
    mrs x9, fpcr
    cbnz x9, .Lgaussian_native_failed
    cbz x0, .Lgaussian_native_failed
    cbz x1, .Lgaussian_native_failed
    cbz x2, .Lgaussian_native_failed
    cbz x6, .Lgaussian_native_failed
    ldr w9, [x0]
    cmp w9, #32
    b.ne .Lgaussian_native_failed
    ldr w9, [x1]
    cbnz w9, .Lgaussian_native_failed
    ldr w9, [x2]
    cmp w9, #32
    b.ne .Lgaussian_native_failed
    stp x29, x30, [sp, #-208]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x18, [sp, #32]
    mov x19, x3
    mov x20, x4
    mov x21, x6
    add x0, sp, #64
    mov x1, x2
    bl md2asm_legendre_fourier_coefficients
    add x9, sp, #64
    add x10, x21, #256
    mov w11, #17
.Lgaussian_native_coefficients:
    ldr x12, [x9], #8
    ldr x13, [x10]
    cmp x12, x13
    b.ne .Lgaussian_native_failed
    add x10, x10, #528
    subs w11, w11, #1
    b.ne .Lgaussian_native_coefficients
    mov x0, x19
    mov x1, x20
    bl md2asm_initialize_gaussian_latitudes
    cbnz w0, .Lgaussian_native_failed
    adrp x9, .Lgaussian_native_calls
    ldr x10, [x9, :lo12:.Lgaussian_native_calls]
    add x10, x10, #1
    str x10, [x9, :lo12:.Lgaussian_native_calls]
    ldp x21, x18, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #208
    ret
.Lgaussian_native_failed:
    b abort
.size __sugaw_mod_MOD_sugaw,.-__sugaw_mod_MOD_sugaw
.global md2asm_gaussian_native_count_get
.type md2asm_gaussian_native_count_get,%function
md2asm_gaussian_native_count_get:
    adrp x0, .Lgaussian_native_calls
    ldr x0, [x0, :lo12:.Lgaussian_native_calls]
    ret
.size md2asm_gaussian_native_count_get,.-md2asm_gaussian_native_count_get
.bss
.balign 8
.Lgaussian_native_calls:
    .zero 8
.section .note.GNU-stack,"",%progbits

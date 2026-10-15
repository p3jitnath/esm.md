// Contract: skills/md2asm/references/openifs/setup/native_registry_setup.md.
// Original SULAP ABI adapter for the selected one-process spherical case.
// Contract: skills/md2asm/references/openifs/setup/serial_laplacian_setup.md. x0 is caller-owned TLAP (576 bytes),
// x1 is read-only TDIM; NSMAX is the int32 word at byte300. The radius is the
// initialized physical input YOMCST.RA, in metres. No Fortran target is called.
// This verification binding retains the original scalar input address only.
// Successful owners belong to TLAP. A failed construction frees its owners,
// clears all nine data pointers and aborts; partial descriptor bounds can remain.
// The full autonomous initializer must supply its own radius input instead.
.text
.p2align 4
.global sulap_
.type sulap_,%function
sulap_:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x18, [sp, #16]
    ldr w1, [x1, #300]
    adrp x2, :got:__yomcst_MOD_ra
    ldr x2, [x2, :got_lo12:__yomcst_MOD_ra]
    ldr d0, [x2]
    bl md2asm_initialize_serial_laplacian
    cbnz w0, .Lnative_laplacian_failed
    adrp x2, .Lnative_laplacian_calls
    ldr x3, [x2, :lo12:.Lnative_laplacian_calls]
    add x3, x3, #1
    str x3, [x2, :lo12:.Lnative_laplacian_calls]
    ldr x18, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.Lnative_laplacian_failed:
    bl abort
    brk #0
.size sulap_,.-sulap_
.global md2asm_serial_laplacian_native_count_get
.type md2asm_serial_laplacian_native_count_get,%function
md2asm_serial_laplacian_native_count_get:
    adrp x0, .Lnative_laplacian_calls
    ldr x0, [x0, :lo12:.Lnative_laplacian_calls]
    ret
.size md2asm_serial_laplacian_native_count_get,.-md2asm_serial_laplacian_native_count_get
.bss
.balign 8
.Lnative_laplacian_calls:
    .zero 8
.section .note.GNU-stack,"",%progbits

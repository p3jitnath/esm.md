/* Complete CTVTOT conversion from the frozen Markdown contract, revision 1.0.
 * GNU Fortran AArch64 ABI: geometry, GFL config, start*, end*, PT, PGFL.
 * PT is FP64 (columns,levels), in kelvin. Only active PT cells change.
 * The accepted direct GPRCP dependency computes the whole mixture stage.
 * The 176-byte frame includes its 64-byte outgoing argument area.
 * Each RD*Tv product and division by Rm rounds separately. */
#ifndef GPRCP_ENTRY
#define GPRCP_ENTRY gprcp_assembly_
#endif
.text
.p2align 4
.global ctvtot_
.type ctvtot_, %function
ctvtot_:
    sub sp, sp, #176
    stp x29, x30, [sp, #64]
    mov x29, sp
    stp x19, x20, [sp, #80]
    stp x21, x22, [sp, #96]
    stp x23, x24, [sp, #112]
    stp x25, x26, [sp, #128]
    stp x27, x28, [sp, #144]
    mov x19, x0
    mov x20, x4
    mov x21, x5
    mov x22, x2
    mov x23, x3
    ldrsw x24, [x19, #5144]
    ldrsw x25, [x19, #5224]
    str w24, [sp, #160]
    str w25, [sp, #164]
    cbz x25, .Lctv_return
    ldr w9, [x22]
    ldr w10, [x23]
    cmp w9, w10
    b.gt .Lctv_return
    mul x0, x24, x25
    lsl x0, x0, #3
    bl malloc
    cbz x0, .Lctv_allocation_failure
    mov x26, x0

    /* Complete generic mixture calculation: PR and PGFL alone are present. */
    stp xzr, xzr, [sp]
    stp xzr, x26, [sp, #16]
    stp xzr, x21, [sp, #32]
    stp xzr, xzr, [sp, #48]
    add x0, sp, #160
    mov x1, x22
    mov x2, x23
    add x3, sp, #164
    mov x4, xzr
    mov x5, xzr
    mov x6, xzr
    mov x7, xzr
    bl GPRCP_ENTRY

    adrp x9, :got:__yomcst_MOD_rd
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rd]
    ldr d0, [x9]
    ldrsw x22, [x22]
    ldrsw x23, [x23]
    sub x22, x22, #1
    lsl x22, x22, #3
    lsl x23, x23, #3
    lsl x24, x24, #3
    mov x27, #0
.Lctv_level:
    mov x8, x22
.Lctv_column:
    add x9, x27, x8
    ldr d1, [x20, x9]
    ldr d2, [x26, x9]
    fmul d1, d0, d1
    fdiv d1, d1, d2
    str d1, [x20, x9]
    add x8, x8, #8
    cmp x8, x23
    b.lt .Lctv_column
    add x27, x27, x24
    subs x25, x25, #1
    b.ne .Lctv_level
    mov x0, x26
    bl free
.Lctv_return:
    ldp x19, x20, [sp, #80]
    ldp x21, x22, [sp, #96]
    ldp x23, x24, [sp, #112]
    ldp x25, x26, [sp, #128]
    ldp x27, x28, [sp, #144]
    ldp x29, x30, [sp, #64]
    add sp, sp, #176
    ret
.Lctv_allocation_failure:
    bl abort
    brk #0
.size ctvtot_, .-ctvtot_
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/computational_geometry_setup.md. */
/* Calculate the source spherical resolution scale for truncations one through 1279.
 * x0 output8, x1 physical48, x2 int32 truncation. FPCR must be zero.
 * The caller supplies mapped, aligned, disjoint spans. Invalid input calls abort.
 * This leaf uses caller-saved registers and the original ordered FP64 operations. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_operational_spherical_resolution_scale
.type md2asm_operational_spherical_resolution_scale,%function
md2asm_operational_spherical_resolution_scale:
    mrs x9, fpcr
    cbnz x9, .Loperational_resolution_invalid
    cbz x0, .Loperational_resolution_invalid
    cbz x1, .Loperational_resolution_invalid
    cbz x2, .Loperational_resolution_invalid
    ldr w9, [x2]
    cmp w9, #1
    b.lt .Loperational_resolution_invalid
    cmp w9, #1279
    b.gt .Loperational_resolution_invalid
    add w10, w9, #1
    mul w9, w9, w10
    scvtf d2, w9
    ldr x9, [x1, #24]
    adrp x10, .Loperational_resolution_radius
    ldr x10, [x10, :lo12:.Loperational_resolution_radius]
    cmp x9, x10
    b.ne .Loperational_resolution_invalid
    fmov d0, x9
    ldr x9, [x1, #32]
    adrp x10, .Loperational_resolution_pi
    ldr x10, [x10, :lo12:.Loperational_resolution_pi]
    cmp x9, x10
    b.ne .Loperational_resolution_invalid
    fmov d3, x9
    fmov d1, #8.0
    fmul d1, d1, d0
    fmul d1, d1, d0
    fdiv d1, d1, d2
    fsqrt d1, d1
    fmul d0, d3, d1
    str d0, [x0]
    ret
.Loperational_resolution_invalid:
    b abort
.size md2asm_operational_spherical_resolution_scale,.-md2asm_operational_spherical_resolution_scale
.section .rodata
.p2align 3
.Loperational_resolution_radius: .double 6371229.0
.Loperational_resolution_pi: .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits

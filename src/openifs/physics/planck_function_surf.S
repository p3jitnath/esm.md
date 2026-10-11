/* Physics formulations/openifs/physics/surface_thermal_emission.md, revision 1.
 * Contract skills/md2asm/references/openifs/physics/planck_function_surf.md.
 * Six address arguments are first, last, config, temperature, PFRAC and output.
 * A fixed 384-byte frame holds sixteen band fluxes for one column.
 * Distinct inputs stay read-only. FP64 operations retain separate rounding.
 */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_ifs_rrtm_MOD_planck_function_surf
#endif
.text
.p2align 4
.global md2asm_planck_function_surf
.global ORIGINAL_SYMBOL
.type md2asm_planck_function_surf, %function
.type ORIGINAL_SYMBOL, %function
md2asm_planck_function_surf:
ORIGINAL_SYMBOL:
    stp x29, x30, [sp, #-384]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp d8, d9, [sp, #96]
    stp d10, d11, [sp, #112]
    stp d12, d13, [sp, #128]
    stp d14, d15, [sp, #144]
    ldrsw x19, [x0]
    ldrsw x8, [x1]
    sub x28, x8, x19
    add x28, x28, #1
    cmp x28, #0
    b.le .Lpfs_return
    mov x20, x28
    sub x19, x19, #1
    mov x10, #20000
    add x10, x2, x10
    ldrsw x21, [x10]
    ldrsw x22, [x10, #8]
    ldr x23, [x3]
    ldr x8, [x3, #40]
    lsl x8, x8, #3
    str x8, [sp, #360]
    madd x23, x19, x8, x23
    mov x24, x4
    mov x25, x5
    lsl x8, x21, #3
    str x8, [sp, #352]
    ldr w8, [x2, #624]
    cmp w8, #3
    b.eq .Lpfs_reordered_map
    ldr x26, [x2, #10608]
    ldr x9, [x2, #10616]
    ldr x27, [x2, #10648]
    add x9, x9, x27
    add x26, x26, x9, lsl #2
    lsl x27, x27, #2
    str xzr, [sp, #320]
    str xzr, [sp, #328]
    b .Lpfs_tables
.Lpfs_reordered_map:
    ldr x26, [x2, #10864]
    ldr x9, [x2, #10872]
    ldr x27, [x2, #10904]
    add x9, x9, x27
    add x26, x26, x9, lsl #2
    lsl x27, x27, #2
    ldr x10, [x2, #10736]
    ldr x9, [x2, #10744]
    ldr x8, [x2, #10776]
    add x9, x9, x8
    add x10, x10, x9, lsl #2
    lsl x8, x8, #2
    str x10, [sp, #320]
    str x8, [sp, #328]
.Lpfs_tables:
    adrp x9, :got:__yoerrtwn_MOD_totplnk
    ldr x9, [x9, :got_lo12:__yoerrtwn_MOD_totplnk]
    str x9, [sp, #336]
    adrp x9, :got:__yoerrtwn_MOD_delwave
    ldr x9, [x9, :got_lo12:__yoerrtwn_MOD_delwave]
    str x9, [sp, #344]
    adrp x17, .Lpfs_constants
    add x17, x17, :lo12:.Lpfs_constants
    ldr d9, [x17]
    fmov d0, #2.0
    fmul d9, d0, d9
    ldr d0, [x17, #8]
    fmul d9, d9, d0
.Lpfs_column:
    ldr d0, [x23]
    ldr d1, [x17, #16]
    fcmp d0, d1
    b.ge .Lpfs_high
    ldr d2, [x17, #24]
    fcmp d0, d2
    b.lt .Lpfs_capped
    ldr d3, [x17, #32]
    fsub d2, d0, d3
    fcvtzs x13, d2
    sub x13, x13, #1
    lsl x13, x13, #3
    fcvtzs x8, d0
    scvtf d2, x8
    fsub d8, d0, d2
    b .Lpfs_band_setup
.Lpfs_high:
    mov x13, #1432
    fsub d8, d0, d1
    b .Lpfs_band_setup
.Lpfs_capped:
    mov x13, #0
    fmov d8, xzr
.Lpfs_band_setup:
    mov x8, #0
    ldr x9, [sp, #336]
    ldr x10, [sp, #344]
    add x11, sp, #160
.Lpfs_band:
    ldr d1, [x10], #8
    fmul d0, d9, d1
    ldr d2, [x9, x13]
    add x14, x9, x13
    ldr d3, [x14, #8]
    fsub d3, d3, d2
    fmul d3, d8, d3
    fadd d2, d2, d3
    fmul d2, d0, d2
    str d2, [x11], #8
    add x9, x9, #1448
    add x8, x8, #1
    cmp x8, x22
    b.lt .Lpfs_band
    mov x8, #0
    mov x9, x26
    ldr x10, [sp, #320]
    ldr x14, [sp, #328]
    mov x11, x25
    add x15, sp, #160
.Lpfs_point:
    ldrsw x12, [x9]
    sub x12, x12, #1
    ldr d0, [x15, x12, lsl #3]
    cbz x10, .Lpfs_ordinary_point
    ldrsw x12, [x10]
    sub x12, x12, #1
    add x10, x10, x14
    b .Lpfs_fraction
.Lpfs_ordinary_point:
    mov x12, x8
.Lpfs_fraction:
    mul x12, x12, x28
    ldr d1, [x24, x12, lsl #3]
    fmul d0, d0, d1
    str d0, [x11], #8
    add x9, x9, x27
    add x8, x8, #1
    cmp x8, x21
    b.lt .Lpfs_point
    ldr x8, [sp, #360]
    add x23, x23, x8
    add x24, x24, #8
    ldr x8, [sp, #352]
    add x25, x25, x8
    subs x20, x20, #1
    b.ne .Lpfs_column
.Lpfs_return:
    ldp d8, d9, [sp, #96]
    ldp d10, d11, [sp, #112]
    ldp d12, d13, [sp, #128]
    ldp d14, d15, [sp, #144]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #384
    ret
.size md2asm_planck_function_surf, .-md2asm_planck_function_surf
.size ORIGINAL_SYMBOL, .-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lpfs_constants:
    .quad 0x3ff921fb54442d18
    .double 10000.0
    .double 339.0
    .double 160.0
    .double 159.0
.section .note.GNU-stack,"",%progbits

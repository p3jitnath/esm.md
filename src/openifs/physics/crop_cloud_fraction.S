// Direct cloud filter from formulations/openifs/physics/small_cloud_filter.md.
// Contract: skills/md2asm/references/openifs/physics/crop_cloud_fraction.md.
// x0 class wrapper, x1 first column, x2 last column, x3 area threshold,
// x4 water threshold. Water units are kg kg^-1. Fractions have no unit.
// Only selected fraction cells can change. No callee-saved registers are used.
.text
.p2align 4
.global md2asm_openifs_crop_cloud_fraction
.type md2asm_openifs_crop_cloud_fraction, %function
md2asm_openifs_crop_cloud_fraction:
    ldr x5, [x0]
    ldp x6, x7, [x5, #424]
    sub x6, x7, x6
    add x6, x6, #1
    cmp x6, #0
    b.le .Lcrop_return
    ldrsw x7, [x1]
    ldrsw x8, [x2]
    subs x9, x8, x7
    b.lt .Lcrop_return
    add x9, x9, #1
    ldr d0, [x3]
    ldr d1, [x4]
    ldp x10, x11, [x5]
    ldr x0, [x5, #64]
    add x11, x11, x7
    add x11, x11, x0
    add x10, x10, x11, lsl #3
    ldp x12, x13, [x5, #88]
    ldr x1, [x5, #152]
    add x13, x13, x7
    add x13, x13, x1
    add x12, x12, x13, lsl #3
    ldp x14, x15, [x5, #352]
    ldr x2, [x5, #416]
    add x15, x15, x7
    add x15, x15, x2
    add x14, x14, x15, lsl #3
    lsl x0, x0, #3
    lsl x1, x1, #3
    lsl x2, x2, #3
.Lcrop_layer:
    mov x11, x10
    mov x13, x12
    mov x15, x14
    mov x16, x9
.Lcrop_column:
    ldr d2, [x15]
    fcmp d2, d0
    b.mi .Lcrop_clear
    ldr d3, [x11]
    ldr d4, [x13]
    fadd d3, d3, d4
    fcmp d3, d1
    b.pl .Lcrop_next
.Lcrop_clear:
    str xzr, [x15]
.Lcrop_next:
    add x11, x11, #8
    add x13, x13, #8
    add x15, x15, #8
    subs x16, x16, #1
    b.ne .Lcrop_column
    add x10, x10, x0
    add x12, x12, x1
    add x14, x14, x2
    subs x6, x6, #1
    b.ne .Lcrop_layer
.Lcrop_return:
    ret
.size md2asm_openifs_crop_cloud_fraction, .-md2asm_openifs_crop_cloud_fraction
.section .note.GNU-stack,"",%progbits

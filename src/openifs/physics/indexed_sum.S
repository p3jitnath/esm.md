// Direct radiation band sum from formulations/openifs/physics/spectral_band_sum.md.
// Contract: skills/md2asm/references/openifs/physics/indexed_sum.md, P01.
// x0 source descriptor, x1 INTEGER4 index descriptor, x2 destination descriptor.
// Every addition follows increasing source order. FP64 values are W m^-2.
// Signed strides count elements. Zero stride metadata means one.
// Only caller-saved registers are used. All three buffers must be disjoint.
.text
.p2align 4
.global md2asm_openifs_indexed_sum
.type md2asm_openifs_indexed_sum, %function
md2asm_openifs_indexed_sum:
    mov x14, #1
    ldr x3, [x0]
    ldr x4, [x0, #40]
    cmp x4, #0
    csel x4, x14, x4, eq
    ldp x5, x11, [x0, #48]
    sub x5, x11, x5
    add x5, x5, #1
    ldr x6, [x1]
    ldr x7, [x1, #40]
    cmp x7, #0
    csel x7, x14, x7, eq
    ldr x8, [x2]
    ldr x9, [x2, #40]
    cmp x9, #0
    csel x9, x14, x9, eq
    ldp x10, x11, [x2, #48]
    sub x10, x11, x10
    add x10, x10, #1
    lsl x4, x4, #3
    lsl x7, x7, #2
    lsl x9, x9, #3
    cmp x10, #0
    b.le .Lsum_source_start
    mov x11, x8
.Lsum_clear:
    str xzr, [x11]
    add x11, x11, x9
    subs x10, x10, #1
    b.ne .Lsum_clear
.Lsum_source_start:
    cmp x5, #0
    b.le .Lsum_return
.Lsum_point:
    ldrsw x13, [x6]
    sub x13, x13, #1
    madd x12, x13, x9, x8
    ldr d0, [x12]
    ldr d1, [x3]
    fadd d0, d0, d1
    str d0, [x12]
    add x3, x3, x4
    add x6, x6, x7
    subs x5, x5, #1
    b.ne .Lsum_point
.Lsum_return:
    ret
.size md2asm_openifs_indexed_sum, .-md2asm_openifs_indexed_sum
.section .note.GNU-stack,"",%progbits

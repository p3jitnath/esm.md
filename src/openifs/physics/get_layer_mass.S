// Direct AArch64 assembly for dry atmospheric layer mass.
// Physics: formulations/openifs/physics/dry_layer_mass.md, P01.
// Contract: skills/md2asm/references/openifs/physics/get_layer_mass.md.
// x0 class wrapper, x1 first column, x2 last column, x3 output descriptor.
// Input pressures are Pa. Output masses are kg m^-2.
// Pressure columns are contiguous. Output strides count FP64 elements.
// Only caller-saved registers are used. Inputs and output must be disjoint.
.text
.p2align 4
.global md2asm_openifs_get_layer_mass
.type md2asm_openifs_get_layer_mass, %function
md2asm_openifs_get_layer_mass:
    ldr x4, [x0]
    ldr x13, [x4, #80]
    sub x13, x13, #1
    cmp x13, #0
    b.le .Lmass_return
    ldrsw x5, [x1]
    ldrsw x6, [x2]
    cmp x6, x5
    b.lt .Lmass_return
    ldp x7, x8, [x4]
    ldr x9, [x4, #64]
    ldr x10, [x3]
    ldr x11, [x3, #40]
    cmp x11, #0
    mov x14, #1
    csel x11, x14, x11, eq
    ldr x12, [x3, #64]
    add x8, x8, x5
    add x8, x8, x9
    add x7, x7, x8, lsl #3
    sub x14, x5, #1
    mul x14, x14, x11
    add x10, x10, x14, lsl #3
    sub x6, x6, x5
    add x6, x6, #1
    lsl x9, x9, #3
    lsl x11, x11, #3
    lsl x12, x12, #3
    adr x14, .Lmass_reciprocal
    ldr d2, [x14]
.Lmass_layer:
    mov x14, x7
    mov x15, x10
    mov x16, x6
.Lmass_column:
    ldr d0, [x14]
    ldr d1, [x14, x9]
    fsub d0, d1, d0
    fmul d0, d0, d2
    str d0, [x15]
    add x14, x14, #8
    add x15, x15, x11
    subs x16, x16, #1
    b.ne .Lmass_column
    add x7, x7, x9
    add x10, x10, x12
    subs x13, x13, #1
    b.ne .Lmass_layer
.Lmass_return:
    ret
.size md2asm_openifs_get_layer_mass, .-md2asm_openifs_get_layer_mass
.p2align 3
.Lmass_reciprocal:
    .quad 0x3fba1acfea981812
.section .note.GNU-stack,"",%progbits

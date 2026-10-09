/* Direct GPGEO emission from the frozen gravitational-height contract.
 * PHI and PHIF use m²/s²; PR times PT has the same unit.
 * The GNU 12.3 ABI has eight register arguments and three stack arguments.
 * Every pair stays within active columns, with one scalar column if needed.
 * x19-x29 and the link register are preserved; v8-v15 and x18 are unused.
 * Complete FE acceptance requires the verified direct VERDISINT dependency. */
#ifndef VERDISINT_ENTRY
#define VERDISINT_ENTRY verdisint_assembly_
#endif
.text
.p2align 4
.global gpgeo_
.type gpgeo_, %function
gpgeo_:
    stp x29, x30, [sp, #-176]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp x0, x1, [sp, #112]
    stp x2, x3, [sp, #128]
    str xzr, [sp, #104]
    mov x23, x4
    mov x24, x5
    mov x25, x6
    mov x26, x7
    ldr x27, [x29, #176]
    ldr x28, [x29, #184]
    ldr x9, [x29, #192]
    str x9, [sp, #96]
    ldr w19, [x0]
    lsl x19, x19, #3
    ldr w20, [x1]
    sub w20, w20, #1
    ldr w21, [x2]
    subs w21, w21, w20
    b.le .Lgeo_done
    lsl x20, x20, #3
    ldr w22, [x3]
    cbz w22, .Lgeo_done
    ldr w7, [x9, #3068]
    str w7, [sp, #160]
    cbz w7, .Lgeo_half_levels

    /* Private FE input has N+2 rows, followed by N+1 integration rows. */
    lsl x0, x22, #1
    add x0, x0, #3
    mul x0, x0, x19
    bl malloc
    cbz x0, .Lgeo_allocation_failed
    str x0, [x29, #104]
    add x8, x22, #2
    madd x9, x8, x19, x0
    str x9, [x29, #144]
    ldr x9, [x29, #96]
    add x9, x9, #776
    ldr x13, [x9]
    ldr x14, [x9, #48]
    mov x15, #1
    sub x14, x15, x14
    add x13, x13, x14, lsl #3
    str x13, [x29, #152]

    /* Both active endpoint rows are positive zero. */
    add x10, x0, x20
    add x8, x22, #1
    madd x11, x8, x19, x0
    add x11, x11, x20
    mov x17, x21
    movi v0.2d, #0
.Lgeo_zero_pairs:
    cmp x17, #2
    b.lo .Lgeo_zero_tail
    str q0, [x10], #16
    str q0, [x11], #16
    sub x17, x17, #2
    b .Lgeo_zero_pairs
.Lgeo_zero_tail:
    cbz x17, .Lgeo_prepare_first
    str d0, [x10]
    str d0, [x11]
.Lgeo_prepare_first:
    mov x8, #1
.Lgeo_prepare_level:
    sub x9, x8, #1
    madd x9, x9, x19, x20
    add x10, x25, x9
    add x11, x26, x9
    add x12, x27, x9
    ldr x13, [x29, #104]
    add x13, x13, x9
    add x13, x13, x19
    ldr x14, [x29, #152]
    sub x15, x8, #1
    ldr d7, [x14, x15, lsl #3]
    dup v7.2d, v7.d[0]
    mov x17, x21
.Lgeo_prepare_pairs:
    cmp x17, #2
    b.lo .Lgeo_prepare_tail
    ldr q0, [x11], #16
    ldr q1, [x10], #16
    ldr q2, [x12], #16
    fneg v0.2d, v0.2d
    fmul v0.2d, v0.2d, v1.2d
    fmul v0.2d, v0.2d, v2.2d
    fmul v0.2d, v0.2d, v7.2d
    str q0, [x13], #16
    sub x17, x17, #2
    b .Lgeo_prepare_pairs
.Lgeo_prepare_tail:
    cbz x17, .Lgeo_prepare_next
    ldr d0, [x11]
    ldr d1, [x10]
    ldr d2, [x12]
    fneg d0, d0
    fmul d0, d0, d1
    fmul d0, d0, d2
    fmul d0, d0, d7
    str d0, [x13]
.Lgeo_prepare_next:
    add x8, x8, #1
    cmp x8, x22
    b.ls .Lgeo_prepare_level

    /* GNU optional pointers and hidden character lengths use 48 bytes. */
    ldr x9, [x29, #96]
    add x0, x9, #840
    add x1, x9, #3016
    adrp x2, .Lgeo_operation
    add x2, x2, :lo12:.Lgeo_operation
    adrp x3, .Lgeo_boundary
    add x3, x3, :lo12:.Lgeo_boundary
    ldr x4, [x29, #112]
    ldr x5, [x29, #120]
    ldr x6, [x29, #128]
    ldr x7, [x29, #136]
    sub sp, sp, #48
    ldr x9, [x29, #104]
    ldr x10, [x29, #144]
    stp x9, x10, [sp]
    stp xzr, xzr, [sp, #16]
    mov x9, #4
    mov x10, #2
    stp x9, x10, [sp, #32]
    bl VERDISINT_ENTRY
    add sp, sp, #48

    /* The integration output is offset from the unchanged surface PHI. */
    mov x8, #0
    madd x16, x22, x19, x23
    add x16, x16, x20
.Lgeo_full_level:
    madd x9, x8, x19, x20
    ldr x10, [x29, #144]
    add x10, x10, x9
    add x11, x24, x9
    mov x12, x16
    mov x17, x21
.Lgeo_full_pairs:
    cmp x17, #2
    b.lo .Lgeo_full_tail
    ldr q0, [x10], #16
    ldr q1, [x12], #16
    fadd v0.2d, v0.2d, v1.2d
    str q0, [x11], #16
    sub x17, x17, #2
    b .Lgeo_full_pairs
.Lgeo_full_tail:
    cbz x17, .Lgeo_full_next
    ldr d0, [x10]
    ldr d1, [x12]
    fadd d0, d0, d1
    str d0, [x11]
.Lgeo_full_next:
    add x8, x8, #1
    cmp x8, x22
    b.lo .Lgeo_full_level

.Lgeo_half_levels:
    ldr w7, [x29, #160]
.Lgeo_half_level:
    sub x8, x22, #1
    madd x8, x8, x19, x20
    add x9, x23, x8
    add x10, x9, x19
    add x11, x25, x8
    add x12, x26, x8
    add x13, x27, x8
    add x14, x28, x8
    add x15, x24, x8
    mov x16, x21
.Lgeo_half_pairs:
    cmp x16, #2
    b.lo .Lgeo_half_tail
    ldr q0, [x12], #16
    ldr q1, [x11], #16
    ldr q2, [x13], #16
    ldr q4, [x10], #16
    fmul v5.2d, v0.2d, v1.2d
    fmul v5.2d, v5.2d, v2.2d
    fadd v5.2d, v4.2d, v5.2d
    str q5, [x9], #16
    cbnz w7, .Lgeo_half_pair_next
    ldr q3, [x14], #16
    fmul v6.2d, v3.2d, v0.2d
    fmul v6.2d, v6.2d, v1.2d
    fadd v6.2d, v4.2d, v6.2d
    str q6, [x15], #16
.Lgeo_half_pair_next:
    sub x16, x16, #2
    b .Lgeo_half_pairs
.Lgeo_half_tail:
    cbz x16, .Lgeo_half_next
    ldr d0, [x12]
    ldr d1, [x11]
    ldr d2, [x13]
    ldr d4, [x10]
    fmul d5, d0, d1
    fmul d5, d5, d2
    fadd d5, d4, d5
    str d5, [x9]
    cbnz w7, .Lgeo_half_next
    ldr d3, [x14]
    fmul d6, d3, d0
    fmul d6, d6, d1
    fadd d6, d4, d6
    str d6, [x15]
.Lgeo_half_next:
    subs w22, w22, #1
    b.ne .Lgeo_half_level
    ldr x0, [x29, #104]
    cbz x0, .Lgeo_done
    bl free
.Lgeo_done:
    ldp x19, x20, [x29, #16]
    ldp x21, x22, [x29, #32]
    ldp x23, x24, [x29, #48]
    ldp x25, x26, [x29, #64]
    ldp x27, x28, [x29, #80]
    mov sp, x29
    ldp x29, x30, [sp], #176
    ret
.Lgeo_allocation_failed:
    bl abort
.size gpgeo_, .-gpgeo_
.section .rodata
.Lgeo_operation:
    .ascii "IBOT"
.Lgeo_boundary:
    .ascii "11"
.section .note.GNU-stack,"",%progbits

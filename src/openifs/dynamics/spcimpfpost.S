/* Complete spectral Coriolis correction from the frozen Markdown contract.
 * x0 geometry, x1 integration, x2 dynamics, x3 m, x4 first slot,
 * x5 unused last slot, x6 divergence descriptor, x7 vorticity descriptor.
 * Coefficients are dimensionless; returned vorticity has units s^-1.
 * Signed rank-two strides and every inactive byte follow the contract.
 */
#ifndef SPCIMPFPOST_ENTRY
#define SPCIMPFPOST_ENTRY spcimpfpost_assembly_
#endif
.text
.p2align 4
.global SPCIMPFPOST_ENTRY
.type SPCIMPFPOST_ENTRY,%function

/* Optional observation calls copy stages without supplying arithmetic. */
.macro POST_OBSERVE phase
#ifdef POST_STAGE_OBSERVER
    adrp x0, .Lpost_phase\phase
    add x0, x0, :lo12:.Lpost_phase\phase
    ldr x1, [sp, #184]
    ldr x9, [sp, #176]
    add x2, x1, x9
    add x3, x2, x9
    add x4, x3, x9
    add x5, x4, x9
    bl POST_STAGE_OBSERVER
#endif
.endm

SPCIMPFPOST_ENTRY:
    sub sp, sp, #256
    stp x29, x30, [sp]
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    ldrsw x24, [x0, #5172]
    ldrsw x26, [x0, #5228]
    ldrsw x25, [x3]
    ldrsw x27, [x4]
    stp x24, x25, [sp, #96]
    stp x26, x27, [sp, #112]
    ldr x9, [x6]
    ldr x10, [x7]
    stp x9, x10, [sp, #128]
    ldr x9, [x6, #40]
    ldr x10, [x6, #64]
    lsl x9, x9, #3
    lsl x10, x10, #3
    stp x9, x10, [sp, #144]
    ldr x9, [x7, #40]
    ldr x10, [x7, #64]
    lsl x9, x9, #3
    lsl x10, x10, #3
    stp x9, x10, [sp, #160]

    /* C01: B, F and A retain every named binary64 rounding point. */
    ldr d0, [x2, #2496]
    ldr d1, [x1, #208]
    fmul d0, d0, d1
    fmov d1, #2.0
    fmul d0, d1, d0
    adrp x9, :got:__yomcst_MOD_romega
    ldr x9, [x9, :got_lo12:__yomcst_MOD_romega]
    ldr d2, [x9]
    fmul d0, d0, d2
    scvtf d1, w25
    fmul d1, d0, d1
    stp d0, d1, [sp, #192]

    /* Five private arrays have N+2 slots; unused source entries stay private. */
    add x9, x24, #2
    lsl x9, x9, #3
    str x9, [sp, #176]
    add x0, x9, x9, lsl #2
    bl malloc
    cbz x0, .Lpost_allocation_failure
    str x0, [sp, #184]
    ldr x9, [sp, #176]
    mov x19, x0
    add x20, x19, x9
    add x21, x20, x9
    add x22, x21, x9
    add x23, x22, x9
    mov w28, w25
    cbnz w25, .Lpost_coefficients
    str xzr, [x19]
    str xzr, [x20]
    str xzr, [x21]
    mov w28, #1

.Lpost_coefficients:
    mov w26, w28
.Lpost_coefficient_loop:
    cmp w26, w24
    b.gt .Lpost_coefficient_end
    scvtf d0, w26
    fmov d6, #1.0
    fadd d3, d0, d6
    fmul d4, d0, d3
    ldr d5, [sp, #200]
    fdiv d4, d5, d4
    str d4, [x19, x26, lsl #3]
    fmul d5, d4, d4
    fadd d5, d6, d5
    fdiv d5, d6, d5
    str d5, [x20, x26, lsl #3]
    fmul d1, d0, d0
    scvtf d2, w25
    fmul d2, d2, d2
    fsub d1, d1, d2
    fmov d7, #4.0
    fmul d2, d7, d0
    fmul d2, d2, d0
    fsub d2, d2, d6
    fdiv d1, d1, d2
    fsqrt d1, d1
    str d1, [x21, x26, lsl #3]
    add w26, w26, #1
    b .Lpost_coefficient_loop

.Lpost_coefficient_end:
    add x9, x24, #1
    str xzr, [x19, x9, lsl #3]
    str xzr, [x20, x9, lsl #3]
    cbnz w25, .Lpost_factor_start
    str xzr, [x22]
    str xzr, [x23]
.Lpost_factor_start:
    mov w26, w28
.Lpost_factor_loop:
    cmp w26, w24
    b.ge .Lpost_factor_end
    scvtf d0, w26
    fmov d7, #1.0
    fadd d1, d0, d7
    ldr d2, [sp, #192]
    add x10, x26, #1
    ldr d3, [x21, x10, lsl #3]
    fmul d4, d2, d0
    fmul d4, d4, d3
    fdiv d4, d4, d1
    str d4, [x22, x26, lsl #3]
    ldr d3, [x21, x26, lsl #3]
    fmul d4, d2, d1
    fmul d4, d4, d3
    fdiv d4, d4, d0
    str d4, [x23, x26, lsl #3]
    add w26, w26, #1
    b .Lpost_factor_loop

.Lpost_factor_end:
    str xzr, [x22, x24, lsl #3]
    scvtf d0, w24
    fmov d7, #1.0
    fadd d1, d0, d7
    ldr d2, [sp, #192]
    ldr d3, [x21, x24, lsl #3]
    fmul d4, d2, d1
    fmul d4, d4, d3
    fdiv d4, d4, d0
    str d4, [x23, x24, lsl #3]
    add x9, x24, #1
    str xzr, [x22, x9, lsl #3]
    str xzr, [x23, x9, lsl #3]
    POST_OBSERVE 0

    /* C02/C03: complete the lower pass before the upper pass. */
    mov w0, #0
    bl .Lpost_pass
    POST_OBSERVE 1
    mov w0, #1
    bl .Lpost_pass
    POST_OBSERVE 2
    ldr x0, [sp, #184]
    bl free
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp]
    add sp, sp, #256
    ret

/* One complete neighbour pass. Local calls share the outer saved frame. */
.Lpost_pass:
    ldr x28, [sp, #112]
    cbz w28, .Lpost_pass_return
    ldp x19, x20, [sp, #128]
    ldp x21, x22, [sp, #144]
    ldp x23, x24, [sp, #160]
    ldr x25, [sp, #184]
    ldr x10, [sp, #176]
    add x26, x25, x10
    add x27, x26, x10
    add x27, x27, x10
    ldr w17, [sp, #96]
    ldr w11, [sp, #104]
    mov w9, w11
    lsl x16, x22, #1
    cbnz w0, .Lpost_upper_range
    add x27, x27, x10
    neg x16, x16
    add w9, w9, #1
    cbnz w11, .Lpost_degree_loop
    mov w9, #2
    b .Lpost_degree_loop
.Lpost_upper_range:
    sub w17, w17, #1
    cbnz w11, .Lpost_degree_loop
    mov w9, #1

.Lpost_degree_loop:
    cmp w9, w17
    b.gt .Lpost_pass_return
    ldr d2, [x25, x9, lsl #3]
    ldr d4, [x26, x9, lsl #3]
    ldr d5, [x27, x9, lsl #3]
    fmul d3, d4, d5
    sub w15, w9, w11
    lsl w15, w15, #1
    ldr w10, [sp, #120]
    add w15, w15, w10
    sub w15, w15, #1
    sxtw x15, w15
    mul x10, x15, x24
    add x10, x20, x10
    mul x12, x15, x22
    add x12, x19, x12
    add x12, x12, x16
    mov w14, #0
    cbnz w11, .Lpost_complex_level

.Lpost_real_level:
    ldr d0, [x12]
    fmul d4, d3, d0
    ldr d5, [x10]
    fsub d5, d5, d4
    str d5, [x10]
    add x12, x12, x21
    add x10, x10, x23
    add w14, w14, #1
    cmp w14, w28
    b.lt .Lpost_real_level
    b .Lpost_next_degree

.Lpost_complex_level:
    ldr d0, [x12]
    ldr d1, [x12, x22]
    fmul d4, d2, d1
    fsub d4, d0, d4
    fmul d4, d3, d4
    ldr d5, [x10]
    fsub d5, d5, d4
    str d5, [x10]
    fmul d4, d2, d0
    fadd d4, d1, d4
    fmul d4, d3, d4
    ldr d5, [x10, x24]
    fsub d5, d5, d4
    str d5, [x10, x24]
    add x12, x12, x21
    add x10, x10, x23
    add w14, w14, #1
    cmp w14, w28
    b.lt .Lpost_complex_level

.Lpost_next_degree:
    add w9, w9, #1
    b .Lpost_degree_loop
.Lpost_pass_return:
    ret

.Lpost_allocation_failure:
    bl abort
    brk #0
.size SPCIMPFPOST_ENTRY,.-SPCIMPFPOST_ENTRY
#ifdef POST_STAGE_OBSERVER
.section .rodata
.p2align 2
.Lpost_phase0: .word 0
.Lpost_phase1: .word 1
.Lpost_phase2: .word 2
#endif
.section .note.GNU-stack,"",%progbits

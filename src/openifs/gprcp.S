/* Complete GPRCP mixture calculation from the md2asm contract, revision 1.0.
 * AArch64 GNU Fortran ABI. Arrays are FP64 in Fortran cell order.
 * Inputs are read-only. Only requested active output cells change.
 * The 192-byte frame holds saved registers and six input addresses.
 * Every coefficient, product, sum and division rounds separately. */
.text
.p2align 4
.global gprcp_
.type gprcp_, %function

/* Read an exact upstream constant through the position-independent ABI. */
.macro constant reg, name
    adrp x9, :got:\name
    ldr x9, [x9, :got_lo12:\name]
    ldr \reg, [x9]
.endm

/* Select one default water flag from its measured pointer-slot offset. */
.macro flag slot, bit
    movz x9, #(\slot & 65535)
    movk x9, #(\slot >> 16), lsl #16
    ldr x10, [x26, x9]
    ldr w11, [x10, #68]
    cbz w11, .Lflag_skip\@
    orr w17, w17, #(1 << \bit)
.Lflag_skip\@:
.endm

/* Apply one water constituent, preserving both independent sum orders. */
.macro water slot, bit, rcoef, cpcoef
    tbz w17, #\bit, .Lwater_skip\@
    ldr x9, [sp, #\slot]
    cbz x9, .Lwater_skip\@
    ldr d18, [x9, x8]
    fmul d19, \rcoef, d18
    fmul d20, \cpcoef, d18
    fadd d16, d16, d19
    fadd d17, d17, d20
.Lwater_skip\@:
.endm

gprcp_:
    stp x29, x30, [sp, #-192]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp x4, x6, [sp, #96]    /* Vapour, liquid. */
    stp x5, x7, [sp, #112]   /* Ice, rain. */
    ldp x9, x10, [sp, #192]
    stp x9, x10, [sp, #128]  /* Snow, graupel. */
    ldp x19, x20, [sp, #208] /* PCP, PR. */
    ldp x21, x27, [sp, #224] /* PKAP, PGFL. */
    orr x9, x19, x20
    orr x9, x9, x21
    cbz x9, .Lreturn
    ldrsw x22, [x0]
    ldrsw x24, [x1]
    ldrsw x25, [x2]
    ldrsw x28, [x3]
    cbz x28, .Lreturn
    cmp x24, x25
    b.gt .Lreturn
    mul x23, x22, x28
    lsl x23, x23, #3        /* One complete generic field, bytes. */
    lsl x22, x22, #3        /* One horizontal row, bytes. */
    sub x24, x24, #1
    lsl x24, x24, #3
    lsl x25, x25, #3

    constant d0, __yomcst_MOD_rd
    constant d1, __yomcst_MOD_rcpd
    cbnz x27, .Lgeneric_setup

    constant d2, __yomcst_MOD_rv
    fsub d2, d2, d0
    constant d3, __yomcst_MOD_rcpv
    fsub d3, d3, d1
    constant d4, __yomcst_MOD_rcw
    fsub d4, d4, d1
    constant d5, __yomcst_MOD_rcs
    fsub d5, d5, d1
    fneg d6, d0
    ldr x9, [sp, #248]      /* Optional common thermal flag. */
    cbz x9, .Ldefault_flags
    ldr w9, [x9]
    mov w17, #0
    cbz w9, .Lflags_ready
    mov w17, #63
    b .Lflags_ready
.Ldefault_flags:
    adrp x9, :got:__yom_ygfl_MOD_ygfl
    ldr x9, [x9, :got_lo12:__yom_ygfl_MOD_ygfl]
    ldr x26, [x9]
    mov w17, #0
    flag 799840, 0          /* Vapour. */
    flag 799856, 1          /* Liquid. */
    flag 799848, 2          /* Ice. */
    flag 799920, 3          /* Rain. */
    flag 799912, 4          /* Snow. */
    flag 799928, 5          /* Graupel. */
.Lflags_ready:
    str w17, [sp, #144]
    b .Llevel

.Lgeneric_setup:
    adrp x9, :got:__yom_ygfl_MOD_ygfl
    ldr x9, [x9, :got_lo12:__yom_ygfl_MOD_ygfl]
    ldr x26, [x9]
    ldr w9, [x26]
    str w9, [sp, #156]      /* Number of component descriptors. */
    add x26, x26, #3848
    mov w10, #168           /* Default MP field index. */
    ldr x9, [sp, #240]
    cbz x9, .Lmap_ready
    ldr w9, [x9]
    cbz w9, .Lmap_ready
    cmp w9, #1
    mov w11, #188
    csel w10, w11, w10, eq
    cmp w9, #5
    mov w11, #192
    csel w10, w11, w10, eq
    cmp w9, #9
    mov w11, #184
    csel w10, w11, w10, eq
    cmp w9, #101
    mov w11, #216
    csel w10, w11, w10, eq
.Lmap_ready:
    str w10, [sp, #152]

.Llevel:
    mov x8, x24
.Lcell:
    cbnz x27, .Lgeneric_cell
    fmov d16, d0
    fmov d17, d1
    ldr w17, [sp, #144]
    water 96, 0, d2, d3
    water 104, 1, d6, d4
    water 112, 2, d6, d5
    water 120, 3, d6, d4
    water 128, 4, d6, d5
    water 136, 5, d6, d5
    b .Loutput

.Lgeneric_cell:
    mov x9, x26
    ldr w10, [sp, #156]
    ldr w12, [sp, #152]
    mov w13, #0
    cbz w10, .Lgeneric_dry
.Lcomponent:
    ldr w15, [x9, #68]
    cbz w15, .Lnext_component
    ldrsw x14, [x9, x12]
    sub x14, x14, #1
    madd x14, x14, x23, x8
    ldr d18, [x27, x14]
    ldr d21, [x9, #72]
    ldr d22, [x9, #80]
    fsub d21, d21, d0
    fsub d22, d22, d1
    fmul d19, d21, d18
    fmul d20, d22, d18
    cbnz w13, .Lgeneric_add
    fmov d16, d19           /* First product has no initial addition. */
    fmov d17, d20
    mov w13, #1
    b .Lnext_component
.Lgeneric_add:
    fadd d16, d16, d19
    fadd d17, d17, d20
.Lnext_component:
    add x9, x9, #368
    subs w10, w10, #1
    b.ne .Lcomponent
    cbz w13, .Lgeneric_dry
    fadd d16, d0, d16       /* Add dry constants after all products. */
    fadd d17, d1, d17
    b .Loutput
.Lgeneric_dry:
    fmov d16, d0
    fmov d17, d1
.Loutput:
    cbz x19, .Lskip_cp
    str d17, [x19, x8]
.Lskip_cp:
    cbz x20, .Lskip_r
    str d16, [x20, x8]
.Lskip_r:
    cbz x21, .Lskip_kappa
    fdiv d23, d16, d17
    str d23, [x21, x8]
.Lskip_kappa:
    add x8, x8, #8
    cmp x8, x25
    b.lt .Lcell
    add x24, x24, x22
    add x25, x25, x22
    subs x28, x28, #1
    b.ne .Llevel
.Lreturn:
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #192
    ret
.size gprcp_, .-gprcp_
.section .note.GNU-stack,"",%progbits

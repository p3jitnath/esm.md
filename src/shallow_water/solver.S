// Direct AArch64 SVE realisation of shallow_water.md revision 1.0.
// The public ABI is in bench/README.md; helpers follow explicit internal register contracts.
// Public entries preserve x19-x29, the required d8-d15 halves, and stack alignment.
// Arithmetic follows D03 and D04 without contraction or approximations.

.text
.p2align 4
.type .Lhalo, %function
.Lhalo:
    // x0=state, x1=nx, x2=ny, x3=row bytes, x4=field bytes.
    mov x5, #3
    add x7, x1, #1
    lsl x7, x7, #3
.Lhalo_field:
    add x6, x0, x3
    mov x8, x2
.Lhalo_side:
    ldr x9, [x6, x1, lsl #3]
    str x9, [x6]
    ldr x9, [x6, #8]
    str x9, [x6, x7]
    add x6, x6, x3
    subs x8, x8, #1
    b.ne .Lhalo_side
    madd x10, x2, x3, x0
    add x11, x0, x3
    add x12, x2, #1
    madd x12, x12, x3, x0
    add x13, x1, #2
    mov x8, #0
.Lhalo_row:
    whilelo p0.d, x8, x13
    ld1d {z0.d}, p0/z, [x10, x8, lsl #3]
    ld1d {z1.d}, p0/z, [x11, x8, lsl #3]
    st1d {z0.d}, p0, [x0, x8, lsl #3]
    st1d {z1.d}, p0, [x12, x8, lsl #3]
    incd x8
    cmp x8, x13
    b.lo .Lhalo_row
    add x0, x0, x4
    subs x5, x5, #1
    b.ne .Lhalo_field
    ret
.size .Lhalo, .-.Lhalo

.p2align 4
.type .Lprepare, %function
.Lprepare:
    // x0=state row, x1=work row, x2=field bytes, x3=parameters, x4=count.
    mov x10, x4
    add x4, x0, x2
    add x5, x4, x2
    add x6, x1, x2
    add x7, x6, x2
    add x8, x7, x2
    add x9, x8, x2
    mov x11, #0
    ptrue p7.d
    ld1rd {z22.d}, p7/z, [x3]
.Lprepare_cells:
    whilelo p0.d, x11, x10
    ld1d {z0.d}, p0/z, [x0, x11, lsl #3]
    ld1d {z1.d}, p0/z, [x4, x11, lsl #3]
    ld1d {z2.d}, p0/z, [x5, x11, lsl #3]
    fmul z5.d, z22.d, z0.d
    mov z3.d, z1.d
    mov z4.d, z2.d
    fdiv z3.d, p0/m, z3.d, z0.d
    fdiv z4.d, p0/m, z4.d, z0.d
    fsqrt z6.d, p0/m, z5.d
    fmul z7.d, z5.d, z0.d
    fmul z7.d, z7.d, z31.d
    fmul z16.d, z1.d, z3.d
    fadd z16.d, z16.d, z7.d
    fmul z17.d, z1.d, z4.d
    fmul z18.d, z2.d, z4.d
    fadd z18.d, z18.d, z7.d
    fabs z19.d, p0/m, z3.d
    fabs z20.d, p0/m, z4.d
    fadd z19.d, z19.d, z6.d
    fadd z20.d, z20.d, z6.d
    st1d {z16.d}, p0, [x1, x11, lsl #3]
    st1d {z17.d}, p0, [x6, x11, lsl #3]
    st1d {z18.d}, p0, [x7, x11, lsl #3]
    st1d {z19.d}, p0, [x8, x11, lsl #3]
    st1d {z20.d}, p0, [x9, x11, lsl #3]
    incd x11
    cmp x11, x10
    b.lo .Lprepare_cells
    ret
.size .Lprepare, .-.Lprepare

// Rounded faces use output halos until BC01; live scratch rows retain pitch P.
// Rows use the same field stride S in both the full and live-window paths.
.macro FIELD_POINTER base, field
.if \field == 0
    mov x11, \base
.elseif \field == 1
    add x11, \base, x4
.else
    add x11, \base, x4, lsl #1
.endif
.endm

.macro SEED_WEST component, fxbase, fxfield
    FIELD_POINTER x0, \component
    ldp d0, d1, [x11]
    FIELD_POINTER \fxbase, \fxfield
    ldp d3, d4, [x11]
    fadd d4, d3, d4
    fmul d4, d4, d31
    fsub d16, d1, d0
    fmul d16, d24, d16
    fsub d4, d4, d16
    FIELD_POINTER x1, \component
    str d4, [x11]
.endm

// D03 uses the north state row and writes its five values into the next point slot.
.macro NORTH_POINT
    FIELD_POINTER x0, 0
    ld1d {z2.d}, p7/z, [x11, x16, lsl #3]
    FIELD_POINTER x0, 1
    ld1d {z22.d}, p7/z, [x11, x16, lsl #3]
    FIELD_POINTER x0, 2
    ld1d {z14.d}, p7/z, [x11, x16, lsl #3]
    fmul z16.d, z21.d, z2.d
    // For finite positive h, h*1 preserves its bits and delays the u division.
    fmul z3.d, z2.d, z10.d
    fdiv v5.2d, v14.2d, v2.2d
    fsqrt v6.2d, v16.2d
    fdiv v3.2d, v22.2d, v3.2d
    fmul z17.d, z16.d, z2.d
    fmul z17.d, z17.d, z31.d
    fmul z18.d, z22.d, z3.d
    fadd z18.d, z18.d, z17.d
    fmul z8.d, z22.d, z5.d
    fmul z9.d, z14.d, z5.d
    fadd z9.d, z9.d, z17.d
    fabs z19.d, p7/m, z3.d
    fabs z27.d, p7/m, z5.d
    fadd z19.d, z19.d, z6.d
    fadd z27.d, z27.d, z6.d
    FIELD_POINTER x7, 0
    st1d {z18.d}, p0, [x11, x14, lsl #3]
    FIELD_POINTER x7, 1
    st1d {z8.d}, p0, [x11, x14, lsl #3]
    FIELD_POINTER x7, 2
    st1d {z9.d}, p0, [x11, x14, lsl #3]
    add x11, x7, x4, lsl #1
    add x11, x11, x4
    st1d {z19.d}, p0, [x11, x14, lsl #3]
    add x11, x11, x4
    st1d {z27.d}, p0, [x11, x14, lsl #3]
.endm

.macro FACE_COMPONENT component, first, qc, qe, qn, fxc, fxe, fyc, fyn, qs, fys
.if \component == 0
    FIELD_POINTER x0, 0
    ld1d {z0.d}, p7/z, [x11, x14, lsl #3]
    ld1d {z1.d}, p7/z, [x11, x15, lsl #3]
.elseif \component == 1
    FIELD_POINTER x3, 0
    ld1d {z3.d}, p7/z, [x11, x14, lsl #3]
    ld1d {z4.d}, p7/z, [x11, x15, lsl #3]
.else
    FIELD_POINTER x0, 2
    ld1d {z1.d}, p7/z, [x11, x15, lsl #3]
    FIELD_POINTER x3, 1
    ld1d {z4.d}, p7/z, [x11, x15, lsl #3]
    FIELD_POINTER x3, 2
    ld1d {z5.d}, p7/z, [x11, x14, lsl #3]
.endif
    fadd z4.d, z\fxc\().d, z\fxe\().d
    fmul z4.d, z4.d, z31.d
    fsub z16.d, z\qe\().d, z\qc\().d
    fmul z16.d, z24.d, z16.d
    fsub z4.d, z4.d, z16.d
    fadd z6.d, z\fyc\().d, z\fyn\().d
    fmul z6.d, z6.d, z31.d
    fsub z17.d, z\qn\().d, z\qc\().d
    fmul z17.d, z27.d, z17.d
    fsub z6.d, z6.d, z17.d
.if \first
.if \component != 2
    FIELD_POINTER x0, \component
    ld1d {z7.d}, p7/z, [x11, x17, lsl #3]
.endif
.if \component != 0
.if \component == 1
    FIELD_POINTER x24, 1
.else
    FIELD_POINTER x24, 2
.endif
    ld1d {z19.d}, p7/z, [x11, x14, lsl #3]
.endif
    fadd z19.d, z\fys\().d, z\fyc\().d
    fmul z19.d, z19.d, z31.d
    fsub z16.d, z\qc\().d, z\qs\().d
    fmul z16.d, z26.d, z16.d
    fsub z19.d, z19.d, z16.d
    FIELD_POINTER x2, \component
    st1d {z19.d}, p0, [x11, x14, lsl #3]
.endif
    FIELD_POINTER x9, \component
    st1d {z6.d}, p0, [x11, x14, lsl #3]
    FIELD_POINTER x1, \component
    st1d {z4.d}, p0, [x11, x14, lsl #3]
.endm

.macro FACE_VECTOR first
    add x14, x13, #1
    add x15, x14, #1
    add x16, x14, x10
    sub x17, x14, x10
    NORTH_POINT
    ld1d {z24.d}, p7/z, [x5, x14, lsl #3]
    ld1d {z25.d}, p7/z, [x5, x15, lsl #3]
    ld1d {z23.d}, p7/z, [x6, x14, lsl #3]
    fmax z24.d, p7/m, z24.d, z25.d
    fmax z27.d, p7/m, z27.d, z23.d
    fmul z24.d, z24.d, z31.d
    fmul z27.d, z27.d, z31.d
.if \first
    add x11, x24, x4, lsl #2
    ld1d {z26.d}, p7/z, [x11, x14, lsl #3]
    fmax z26.d, p7/m, z26.d, z23.d
    fmul z26.d, z26.d, z31.d
.endif
    FIELD_POINTER x0, 1
    ld1d {z11.d}, p7/z, [x11, x14, lsl #3]
    ld1d {z12.d}, p7/z, [x11, x15, lsl #3]
    FIELD_POINTER x0, 2
    ld1d {z13.d}, p7/z, [x11, x14, lsl #3]
.if \first
    ld1d {z15.d}, p7/z, [x11, x17, lsl #3]
.endif
    FIELD_POINTER x3, 1
    ld1d {z25.d}, p7/z, [x11, x14, lsl #3]
    FACE_COMPONENT 0, \first, 0, 1, 2, 11, 12, 13, 14, 7, 15
    FACE_COMPONENT 1, \first, 11, 12, 22, 3, 4, 25, 8, 7, 19
    FACE_COMPONENT 2, \first, 13, 1, 14, 25, 4, 5, 9, 15, 19
    incd x13
.endm

.macro PROCESS_FACES first
    ldp d24, d25, [x5]
    fmax d24, d24, d25
    fmul d24, d24, d31
    SEED_WEST 0, x0, 1
    SEED_WEST 1, x3, 0
    SEED_WEST 2, x3, 1
    fmov z10.d, #1.0
    mov x13, #0
    and x18, x8, #0xfffffffffffffffc
    cbz x18, .Lfaces_tail\@
    mov p0.b, p7.b
.Lfaces_unrolled\@:
    FACE_VECTOR \first
    FACE_VECTOR \first
    cmp x13, x18
    b.lo .Lfaces_unrolled\@
.Lfaces_tail\@:
    cmp x13, x8
    b.hs .Lfaces_complete\@
.Lfaces_tail_cells\@:
    whilelo p0.d, x13, x8
    FACE_VECTOR \first
    cmp x13, x8
    b.lo .Lfaces_tail_cells\@
.Lfaces_complete\@:
    // D03 is point-local, so its halo values follow the periodic state copies.
    mov x13, x7
    mov x14, #5
.Lnorth_halo\@:
    ldr x16, [x13, x8, lsl #3]
    str x16, [x13]
    ldr x16, [x13, #8]
    sub x15, x10, #1
    str x16, [x13, x15, lsl #3]
    add x13, x13, x4
    subs x14, x14, #1
    b.ne .Lnorth_halo\@
.endm

.p2align 4
.type .Lfaces, %function
.Lfaces:
    // x0=current q row, x1=out bottom halo, x2=out top halo, x3=current point row.
    // x4=field bytes, x5=sx row, x6=sy row, x7=north point row, x8=nx.
    // x9=destination north-face row, x10=pitch, w17=logical j; x24=work root.
    // Only caller-saved registers change; z21 and z28-z31 hold public constants.
    cmp w17, #1
    b.ne .Lfaces_regular
    PROCESS_FACES 1
    ret
.Lfaces_regular:
    PROCESS_FACES 0
    ret
.size .Lfaces, .-.Lfaces

.macro DEFINE_UPDATE entry, final, scaled
.p2align 4
.type \entry, %function
\entry:
    // x0=q row, x1=base row, x2=out row, x3=FN row, x4=field bytes.
    // x5=nx, x6=FS row, x7=FE row; row pointers already select live scratch.
    mov x12, #3
.Lupdate_field\@:
    mov x9, #0
.Lupdate_cells\@:
    whilelo p0.d, x9, x5
    add x10, x9, #1
    ld1d {z0.d}, p0/z, [x0, x10, lsl #3]
    ld1d {z1.d}, p0/z, [x7, x10, lsl #3]
    ld1d {z2.d}, p0/z, [x7, x9, lsl #3]
    ld1d {z3.d}, p0/z, [x3, x10, lsl #3]
    ld1d {z4.d}, p0/z, [x6, x10, lsl #3]
    fsub z1.d, z1.d, z2.d
    fsub z3.d, z3.d, z4.d
.if \scaled
    fmul z1.d, z1.d, z28.d
    fmul z3.d, z3.d, z29.d
.else
    fdiv z1.d, p0/m, z1.d, z28.d
    fdiv z3.d, p0/m, z3.d, z29.d
.endif
    fadd z1.d, z1.d, z3.d
    fneg z1.d, p0/m, z1.d
    fmul z1.d, z30.d, z1.d
    fadd z1.d, z0.d, z1.d
.if \final
    ld1d {z5.d}, p0/z, [x1, x10, lsl #3]
    fmul z5.d, z5.d, z31.d
    fmul z1.d, z1.d, z31.d
    fadd z1.d, z5.d, z1.d
.endif
    st1d {z1.d}, p0, [x2, x10, lsl #3]
    incd x9
    cmp x9, x5
    b.lo .Lupdate_cells\@
    add x0, x0, x4
    add x1, x1, x4
    add x2, x2, x4
    add x3, x3, x4
    add x6, x6, x4
    add x7, x7, x4
    subs x12, x12, #1
    b.ne .Lupdate_field\@
    ret
.size \entry, .-\entry
.endm

DEFINE_UPDATE .Lcomponent_first, 0, 0
DEFINE_UPDATE .Lcomponent_final, 1, 0
DEFINE_UPDATE .Lcomponent_first_scaled, 0, 1
DEFINE_UPDATE .Lcomponent_final_scaled, 1, 1

.macro CALL_STAGE entry, current, base, output
    mov x0, \current
    mov x1, x24
    mov x2, x27
    mov x3, x25
    lsr x4, x26, #2
    bl .Lprepare
    mov x17, #1
    str x17, [sp, #160]
.Lstage_rows\@:
    ldr x17, [sp, #160]
    madd x0, x17, x26, \current
    add x1, \output, x27
    sub x1, x1, x26
    mov x2, \output
    mov x4, x27
    mov x8, x19
    add x10, x19, #2
    cmp x19, #128
    b.lo .Lfull_faces\@
    cmp x20, #3
    b.lo .Lfull_faces\@
    mov x11, #3
    udiv x12, x17, x11
    msub x12, x12, x11, x17
    madd x3, x12, x26, x24
    add x12, x17, #1
    udiv x13, x12, x11
    msub x12, x13, x11, x12
    madd x7, x12, x26, x24
    and x12, x17, #1
    add x12, x12, #3
    madd x9, x12, x26, x24
    b .Lface_pointers\@
.Lfull_faces\@:
    madd x3, x17, x26, x24
    add x7, x3, x26
    sub x9, x3, x26
.Lface_pointers\@:
    add x5, x3, x27, lsl #1
    add x5, x5, x27
    add x6, x5, x27
    bl .Lfaces
    ldr x11, [sp, #160]
    madd x0, x11, x26, \current
    madd x1, x11, x26, \base
    madd x2, x11, x26, \output
    mov x4, x27
    mov x5, x19
    add x7, \output, x27
    sub x7, x7, x26
    cmp x19, #128
    b.lo .Lfull_update\@
    cmp x20, #3
    b.lo .Lfull_update\@
    and x12, x11, #1
    add x12, x12, #3
    madd x3, x12, x26, x24
    sub x12, x11, #1
    and x12, x12, #1
    add x12, x12, #3
    madd x6, x12, x26, x24
    b .Lupdate_pointers\@
.Lfull_update\@:
    sub x12, x11, #1
    madd x3, x12, x26, x24
    sub x12, x12, #1
    madd x6, x12, x26, x24
.Lupdate_pointers\@:
    cmp x11, #1
    csel x6, \output, x6, eq
    bl \entry
    ldr x17, [sp, #160]
    add x17, x17, #1
    str x17, [sp, #160]
    cmp x17, x20
    b.ls .Lstage_rows\@
.endm

.macro SAVE_PUBLIC
    stp x29, x30, [sp, #-176]!
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
.endm

.macro RESTORE_PUBLIC
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp d8, d9, [sp, #96]
    ldp d10, d11, [sp, #112]
    ldp d12, d13, [sp, #128]
    ldp d14, d15, [sp, #144]
    ldp x29, x30, [sp], #176
    ret
.endm

.p2align 4
.global sw_step
.type sw_step, %function
sw_step:
.Lstep_entry:
    SAVE_PUBLIC
    uxtw x19, w0
    uxtw x20, w1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6
    add x26, x19, #2
    add x27, x20, #2
    mul x27, x26, x27
    lsl x27, x27, #3
    lsl x26, x26, #3
    mov x28, #0
    ldp x0, x1, [x25, #8]
    orr x2, x0, x1
    tst x2, #0x000fffffffffffff
    b.ne .Lscale_selected
    ubfx x2, x0, #52, #11
    cbz x2, .Lscale_selected
    cmp x2, #2047
    b.eq .Lscale_selected
    ubfx x2, x1, #52, #11
    cbz x2, .Lscale_selected
    cmp x2, #2047
    b.eq .Lscale_selected
    mov x28, #1
.Lscale_selected:
    mov x0, x21
    mov x1, x19
    mov x2, x20
    mov x3, x26
    mov x4, x27
    bl .Lhalo
    ptrue p7.d
    ld1rd {z21.d}, p7/z, [x25]
    ld1rd {z28.d}, p7/z, [x25, #8]
    ld1rd {z29.d}, p7/z, [x25, #16]
    ld1rd {z30.d}, p7/z, [x25, #24]
    fmov z31.d, #0.5
    cbz x28, .Lparameters_ready
    fmov z27.d, #1.0
    fdivr z28.d, p7/m, z28.d, z27.d
    fdivr z29.d, p7/m, z29.d, z27.d
.Lparameters_ready:
    cbz x28, .Lfirst_general
    CALL_STAGE .Lcomponent_first_scaled, x21, x21, x22
    b .Lfirst_done
.Lfirst_general:
    CALL_STAGE .Lcomponent_first, x21, x21, x22
.Lfirst_done:
    mov x0, x22
    mov x1, x19
    mov x2, x20
    mov x3, x26
    mov x4, x27
    bl .Lhalo
    cbz x28, .Lfinal_general
    CALL_STAGE .Lcomponent_final_scaled, x22, x21, x23
    b .Lfinal_done
.Lfinal_general:
    CALL_STAGE .Lcomponent_final, x22, x21, x23
.Lfinal_done:
    mov x0, x23
    mov x1, x19
    mov x2, x20
    mov x3, x26
    mov x4, x27
    bl .Lhalo
    RESTORE_PUBLIC
.size sw_step, .-sw_step

.p2align 4
.global sw_run
.type sw_run, %function
sw_run:
    cbz w7, .Lrun_empty
    SAVE_PUBLIC
    uxtw x19, w0
    uxtw x20, w1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6
    uxtw x26, w7
.Lrun_steps:
    mov w0, w19
    mov w1, w20
    mov x2, x21
    mov x3, x22
    mov x4, x23
    mov x5, x24
    mov x6, x25
    bl .Lstep_entry
    mov x27, x21
    mov x21, x23
    mov x23, x27
    subs x26, x26, #1
    b.ne .Lrun_steps
    RESTORE_PUBLIC
.Lrun_empty:
    ret
.size sw_run, .-sw_run

.section .note.GNU-stack,"",%progbits

/* GPGRGEO: direct AArch64 emission from contract revision 1.0.
 * H=R*T; gradients retain the caller's horizontal coordinate units.
 * Each product and addition rounds separately in FP64.
 * The finite-element branch requires verified direct VERDISINT.
 *
 * x0..x7: geometry,np*,start*,end*,levels*,H,G_L,G_M.
 * Fifteen remaining pointer arguments occupy incoming stack 0..112.
 * The 512-byte frame includes a 48-byte outgoing call area.
 * Only v0..v7 are used. x18 is unused; x19..x29 and LR are preserved. */
#ifndef VERDISINT_ENTRY
#define VERDISINT_ENTRY verdisint_assembly_
#endif

.text
.p2align 4

/* Calculate one half- or full-level component at full-cell offset x11.
 * Read the lower boundary at x12. w27 selects pressure correction. */
.macro grgeo_value weight, derivative, gradient, nh, lower, output
    ldr x9, [sp, #\lower]
    ldr d0, [x9, x12]
    ldr x9, [sp, #\weight]
    ldr d1, [x9, x11]
    ldr x9, [sp, #\gradient]
    ldr d3, [x9, x11]
    cbz w27, .Lhyd_value_\@
    ldr x9, [sp, #192]
    ldr d2, [x9, x11]
    ldr x9, [sp, #\nh]
    ldr d4, [x9, x11]
    fadd d3, d3, d4
    fmul d1, d1, d2
    fmul d1, d1, d3
    ldr x9, [sp, #\derivative]
    ldr d3, [x9, x11]
    fmul d3, d3, d2
    ldr x9, [sp, #88]
    ldr d4, [x9, x11]
    fmul d3, d3, d4
    b .Lsum_value_\@
.Lhyd_value_\@:
    fmul d1, d1, d3
    ldr x9, [sp, #\derivative]
    ldr d3, [x9, x11]
    ldr x9, [sp, #88]
    ldr d4, [x9, x11]
    fmul d3, d3, d4
.Lsum_value_\@:
    fadd d0, d0, d1
    fadd d0, d0, d3
    ldr x9, [sp, #\output]
    str d0, [x9, x11]
.endm

/* Prepare a boundary-indexed coordinate derivative.
 * Negate d before multiplication and preserve the explicit subtraction. */
.macro grgeo_fe derivative, gradient, nh, output
    ldr x9, [sp, #112]
    ldr d0, [x9, x11]
    fneg d0, d0
    ldr x9, [sp, #\gradient]
    ldr d2, [x9, x11]
    cbz w27, .Lhyd_fe_\@
    ldr x9, [sp, #192]
    ldr d1, [x9, x11]
    fmul d0, d0, d1
    ldr x9, [sp, #\nh]
    ldr d3, [x9, x11]
    fadd d2, d2, d3
    fmul d0, d0, d2
    ldr x9, [sp, #\derivative]
    ldr d2, [x9, x11]
    fmul d2, d2, d1
    ldr x9, [sp, #88]
    ldr d3, [x9, x11]
    fmul d2, d2, d3
    b .Ldifference_fe_\@
.Lhyd_fe_\@:
    fmul d0, d0, d2
    ldr x9, [sp, #\derivative]
    ldr d2, [x9, x11]
    ldr x9, [sp, #88]
    ldr d3, [x9, x11]
    fmul d2, d2, d3
.Ldifference_fe_\@:
    fsub d0, d0, d2
    ldr x9, [sp, #344]
    ldr d4, [x9, x15]
    fmul d0, d0, d4
    ldr x9, [sp, #\output]
    str d0, [x9, x12]
.endm

/* Use the frozen GNU ABI, including both hidden character lengths. */
.macro grgeo_integrate input, output
    ldr x9, [sp, #\input]
    ldr x10, [sp, #\output]
    stp x9, x10, [sp, #0]
    stp xzr, xzr, [sp, #16]
    mov x9, #4
    mov x10, #2
    stp x9, x10, [sp, #32]
    ldr x0, [sp, #248]
    ldr x1, [sp, #232]
    adrp x2, .Lgrgeo_ibot
    add x2, x2, :lo12:.Lgrgeo_ibot
    adrp x3, .Lgrgeo_bc11
    add x3, x3, :lo12:.Lgrgeo_bc11
    ldp x4, x5, [sp, #56]
    ldp x6, x7, [sp, #72]
    bl VERDISINT_ENTRY
.endm

.global gpgrgeo_
.type gpgrgeo_, %function
gpgrgeo_:
    sub sp, sp, #512
    stp x19, x20, [sp, #416]
    stp x21, x22, [sp, #432]
    stp x23, x24, [sp, #448]
    stp x25, x26, [sp, #464]
    stp x27, x28, [sp, #480]
    stp x29, x30, [sp, #496]
    mov x29, sp
    stp x0, x1, [sp, #48]
    stp x2, x3, [sp, #64]
    stp x4, x5, [sp, #80]
    stp x6, x7, [sp, #96]
    add x9, sp, #512
    ldp x10, x11, [x9, #0]
    stp x10, x11, [sp, #112]
    ldp x10, x11, [x9, #16]
    stp x10, x11, [sp, #128]
    ldp x10, x11, [x9, #32]
    stp x10, x11, [sp, #144]
    ldp x10, x11, [x9, #48]
    stp x10, x11, [sp, #160]
    ldp x10, x11, [x9, #64]
    stp x10, x11, [sp, #176]
    ldp x10, x11, [x9, #80]
    stp x10, x11, [sp, #192]
    ldp x10, x11, [x9, #96]
    stp x10, x11, [sp, #208]
    ldr x10, [x9, #112]
    str x10, [sp, #224]

    ldr w19, [x1]
    ldr w20, [x2]
    ldr w21, [x3]
    ldr w22, [x4]
    cmp w21, w20
    b.lt .Lgrgeo_return
    sub w20, w20, #1
    uxtw x19, w19
    lsl x20, x20, #3
    lsl x21, x21, #3
    lsl x23, x19, #3
    mul x24, x23, x22
    mov w27, wzr
    ldr x9, [sp, #184]
    cbz x9, .Lgrgeo_configuration
    ldr w27, [x9]

.Lgrgeo_configuration:
    cbz w22, .Lgrgeo_surface

    ldr x9, [sp, #48]
    ldr x10, [x9, #3264]
    str x10, [sp, #232]
    ldr w28, [x10, #52]
    cbz w28, .Lgrgeo_allocate
    ldr x10, [x9, #3248]
    ldr x11, [x9, #3256]
    stp x10, x11, [sp, #240]
    ldr x11, [x10, #256]
    ldr x12, [x10, #304]
    mov x13, #1
    sub x12, x13, x12
    add x11, x11, x12, lsl #3
    str x11, [sp, #344]

.Lgrgeo_allocate:
    lsl x0, x24, #1
    cbz w28, .Lgrgeo_malloc
    add x9, x22, #1
    mul x0, x9, x23
    mov x9, #6
    mul x0, x0, x9
.Lgrgeo_malloc:
    bl malloc
    cbz x0, .Lgrgeo_allocation_failure
    str x0, [sp, #288]
    str x0, [sp, #328]
    add x9, x0, x24
    str x9, [sp, #336]
    cbz w28, .Lgrgeo_indices
    add x10, x9, x24
    str x10, [sp, #296]
    add x11, x22, #2
    mul x11, x11, x23
    add x10, x10, x11
    str x10, [sp, #304]
    add x10, x10, x11
    str x10, [sp, #312]
    add x11, x22, #1
    mul x11, x11, x23
    add x10, x10, x11
    str x10, [sp, #320]

.Lgrgeo_indices:
    adrp x9, :got:__intdyn_mod_MOD_yytxybder
    ldr x9, [x9, :got_lo12:__intdyn_mod_MOD_yytxybder]
    ldr x11, [sp, #128]
    ldr w10, [x9, #0]
    sub w10, w10, #1
    sxtw x10, w10
    madd x10, x10, x24, x11
    str x10, [sp, #256]
    ldr w10, [x9, #4]
    sub w10, w10, #1
    sxtw x10, w10
    madd x10, x10, x24, x11
    str x10, [sp, #264]
    cbnz w28, .Lgrgeo_nh_start
    ldr w10, [x9, #8]
    sub w10, w10, #1
    sxtw x10, w10
    madd x10, x10, x24, x11
    str x10, [sp, #272]
    ldr w10, [x9, #12]
    sub w10, w10, #1
    sxtw x10, w10
    madd x10, x10, x24, x11
    str x10, [sp, #280]

.Lgrgeo_nh_start:
    mov x25, xzr
.Lgrgeo_nh_level:
    mov x26, x20
.Lgrgeo_nh_column:
    add x11, x25, x26
    fmov d0, xzr
    fmov d1, xzr
    cbz w27, .Lgrgeo_nh_store
    ldr x9, [sp, #88]
    ldr d2, [x9, x11]
    fneg d2, d2
    ldr x9, [sp, #200]
    ldr d0, [x9, x11]
    fmul d0, d2, d0
    ldr x9, [sp, #208]
    ldr d1, [x9, x11]
    fmul d1, d2, d1
.Lgrgeo_nh_store:
    ldr x9, [sp, #328]
    ldr x10, [sp, #336]
    str d0, [x9, x11]
    str d1, [x10, x11]
    ldr x9, [sp, #216]
    cbz x9, .Lgrgeo_nh_m_optional
    str d0, [x9, x11]
.Lgrgeo_nh_m_optional:
    ldr x9, [sp, #224]
    cbz x9, .Lgrgeo_nh_next
    str d1, [x9, x11]
.Lgrgeo_nh_next:
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_nh_column
    add x25, x25, x23
    cmp x25, x24
    b.lo .Lgrgeo_nh_level

.Lgrgeo_surface:
    mov x26, x20
    ldr x9, [sp, #168]
    ldr x10, [sp, #176]
    add x9, x9, x24
    add x10, x10, x24
    ldr x11, [sp, #136]
    ldr x12, [sp, #144]
.Lgrgeo_surface_column:
    ldr d0, [x11, x26]
    ldr d1, [x12, x26]
    str d0, [x9, x26]
    str d1, [x10, x26]
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_surface_column
    cbz w22, .Lgrgeo_return

    sub x25, x24, x23
.Lgrgeo_half_level:
    mov x26, x20
.Lgrgeo_half_column:
    add x11, x25, x26
    add x12, x11, x23
    grgeo_value 112, 256, 96, 328, 168, 168
    grgeo_value 112, 264, 104, 336, 176, 176
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_half_column
    subs x25, x25, x23
    b.ge .Lgrgeo_half_level
    cbnz w28, .Lgrgeo_fe_start

    mov x25, xzr
.Lgrgeo_full_level:
    mov x26, x20
.Lgrgeo_full_column:
    add x11, x25, x26
    add x12, x11, x23
    grgeo_value 120, 272, 96, 328, 168, 152
    grgeo_value 120, 280, 104, 336, 176, 160
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_full_column
    add x25, x25, x23
    cmp x25, x24
    b.lo .Lgrgeo_full_level
    b .Lgrgeo_free

.Lgrgeo_fe_start:
    mov x25, xzr
    mov x15, xzr
.Lgrgeo_fe_level:
    mov x26, x20
.Lgrgeo_fe_column:
    add x11, x25, x26
    add x12, x11, x23
    grgeo_fe 256, 96, 328, 296
    grgeo_fe 264, 104, 336, 304
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_fe_column
    add x25, x25, x23
    add x15, x15, #8
    cmp x25, x24
    b.lo .Lgrgeo_fe_level

    mov x26, x20
    add x12, x24, x23
    ldr x9, [sp, #296]
    ldr x10, [sp, #304]
    fmov d0, xzr
.Lgrgeo_fe_endpoint:
    add x11, x12, x26
    str d0, [x9, x26]
    str d0, [x10, x26]
    str d0, [x9, x11]
    str d0, [x10, x11]
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_fe_endpoint
    grgeo_integrate 296, 312
    grgeo_integrate 304, 320

    mov x25, xzr
.Lgrgeo_fe_full_level:
    mov x26, x20
.Lgrgeo_fe_full_column:
    add x11, x25, x26
    ldr x9, [sp, #312]
    ldr d0, [x9, x11]
    ldr x9, [sp, #136]
    ldr d1, [x9, x26]
    fadd d0, d0, d1
    ldr x9, [sp, #152]
    str d0, [x9, x11]
    ldr x9, [sp, #320]
    ldr d0, [x9, x11]
    ldr x9, [sp, #144]
    ldr d1, [x9, x26]
    fadd d0, d0, d1
    ldr x9, [sp, #160]
    str d0, [x9, x11]
    add x26, x26, #8
    cmp x26, x21
    b.lo .Lgrgeo_fe_full_column
    add x25, x25, x23
    cmp x25, x24
    b.lo .Lgrgeo_fe_full_level

.Lgrgeo_free:
    ldr x0, [sp, #288]
    bl free
.Lgrgeo_return:
    ldp x19, x20, [sp, #416]
    ldp x21, x22, [sp, #432]
    ldp x23, x24, [sp, #448]
    ldp x25, x26, [sp, #464]
    ldp x27, x28, [sp, #480]
    ldp x29, x30, [sp, #496]
    add sp, sp, #512
    ret
.Lgrgeo_allocation_failure:
    bl abort
    brk #0
.size gpgrgeo_, .-gpgrgeo_

.section .rodata
.Lgrgeo_ibot:
    .ascii "IBOT"
.Lgrgeo_bc11:
    .ascii "11"
.section .note.GNU-stack,"",%progbits

/* Direct AArch64 from the frozen Band21 Markdown equations.
 * Each FP64 operation rounds separately. No numerical helper is called.
 * Arguments use the original 26-pointer Arm ABI. Full bounds are proved
 * by the accepted metadata and protected native driver before entry.
 * Only the ten active points are written in the complete sixteen-point
 * storage. x18 is reserved and is never used.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_srtm_taumol21
.type md2asm_srtm_taumol21, %function
md2asm_srtm_taumol21:
    .cfi_startproc
    sub sp, sp, #640
    .cfi_def_cfa_offset 640
    stp x29, x30, [sp]
    .cfi_offset 29, -640
    .cfi_offset 30, -632
    mov x29, sp
    .cfi_def_cfa_register 29
    stp x19, x20, [x29, #16]
    stp x21, x22, [x29, #32]
    stp x23, x24, [x29, #48]
    stp x25, x26, [x29, #64]
    stp x27, x28, [x29, #80]
    .cfi_offset 19, -624
    .cfi_offset 20, -616
    .cfi_offset 21, -608
    .cfi_offset 22, -600
    .cfi_offset 23, -592
    .cfi_offset 24, -584
    .cfi_offset 25, -576
    .cfi_offset 26, -568
    .cfi_offset 27, -560
    .cfi_offset 28, -552
    stp d8, d9, [x29, #96]
    stp d10, d11, [x29, #112]
    stp d12, d13, [x29, #128]
    stp d14, d15, [x29, #144]
    .cfi_offset 72, -544
    .cfi_offset 73, -536
    .cfi_offset 74, -528
    .cfi_offset 75, -520
    .cfi_offset 76, -512
    .cfi_offset 77, -504
    .cfi_offset 78, -496
    .cfi_offset 79, -488

    /* The pointer plane at frame+192 retains the original argument order. */
    stp x0, x1, [x29, #192]
    stp x2, x3, [x29, #208]
    stp x4, x5, [x29, #224]
    stp x6, x7, [x29, #240]
    add x10, x29, #640
    ldp x9, x11, [x10]
    stp x9, x11, [x29, #256]
    ldp x9, x11, [x10, #16]
    stp x9, x11, [x29, #272]
    ldp x9, x11, [x10, #32]
    stp x9, x11, [x29, #288]
    ldp x9, x11, [x10, #48]
    stp x9, x11, [x29, #304]
    ldp x9, x11, [x10, #64]
    stp x9, x11, [x29, #320]
    ldp x9, x11, [x10, #80]
    stp x9, x11, [x29, #336]
    ldp x9, x11, [x10, #96]
    stp x9, x11, [x29, #352]
    ldp x9, x11, [x10, #112]
    stp x9, x11, [x29, #368]
    ldp x9, x11, [x10, #128]
    stp x9, x11, [x29, #384]

    /* Retain the original hook, including its post-entry return decision. */
    adrp x9, :got:__yomhook_MOD_lhook
    ldr x9, [x9, :got_lo12:__yomhook_MOD_lhook]
    ldr w10, [x9]
    cbz w10, .Lhook_entry_done
    adrp x0, .Lhook_name
    add x0, x0, :lo12:.Lhook_name
    adrp x1, .Lhook_zero
    add x1, x1, :lo12:.Lhook_zero
    add x2, x29, #160
    mov x3, #13
    bl __yomhook_MOD_dr_hook_default8
.Lhook_entry_done:
    adrp x9, :got:__yomhook_MOD_lhook
    ldr x9, [x9, :got_lo12:__yomhook_MOD_lhook]
    ldr w10, [x9]
    str w10, [x29, #168]

    /* B is the full extent, including shifted KIDIA:KFDIA bounds. */
    ldr x9, [x29, #200]
    ldr w10, [x9]
    cmp w10, #1
    b.lt .Lshape_rejected
    ldr x9, [x29, #208]
    ldr w19, [x9]
    sub w19, w19, w10
    add w19, w19, #1
    cmp w19, #4096
    b.hi .Lshape_rejected
    ldr x9, [x29, #216]
    ldr w20, [x9]
    ldr x9, [x29, #192]
    ldr w21, [x9]
    cmp w21, #512
    b.hi .Lshape_rejected
    cmp w20, w21
    b.hi .Lshape_rejected
    cbz w19, .Lreturn
    cbz w20, .Lreturn

    /* One private INTEGER4 solar selector belongs to each full column. */
    lsl x9, x19, #2
    add x9, x9, #15
    and x9, x9, #-16
    sub sp, sp, x9
    mov x28, sp
    ldr x9, [x29, #312]
    mov x23, #0
.Lselector_init:
    ldr w10, [x9, x23, lsl #2]
    str w10, [x28, x23, lsl #2]
    add x23, x23, #1
    cmp x23, x19
    b.lo .Lselector_init

    /* GOT imports retain canonical original COMMON and module owners. */
    adrp x9, :got:yoesrta21.eq.1_
    ldr x9, [x9, :got_lo12:yoesrta21.eq.1_]
    str x9, [x29, #400]
    adrp x9, :got:yoesrta21.eq.0_
    ldr x9, [x9, :got_lo12:yoesrta21.eq.0_]
    str x9, [x29, #408]
    adrp x9, :got:__yoesrta21_MOD_selfrefc
    ldr x9, [x9, :got_lo12:__yoesrta21_MOD_selfrefc]
    str x9, [x29, #416]
    adrp x9, :got:__yoesrta21_MOD_forrefc
    ldr x9, [x9, :got_lo12:__yoesrta21_MOD_forrefc]
    str x9, [x29, #424]
    adrp x9, :got:__yoesrta21_MOD_sfluxrefc
    ldr x9, [x9, :got_lo12:__yoesrta21_MOD_sfluxrefc]
    str x9, [x29, #432]
    adrp x9, :got:__yoesrta21_MOD_strrat
    ldr x9, [x9, :got_lo12:__yoesrta21_MOD_strrat]
    ldr d21, [x9]
    adrp x9, :got:__yoesrta21_MOD_rayl
    ldr x9, [x9, :got_lo12:__yoesrta21_MOD_rayl]
    ldr d22, [x9]
    adrp x9, :got:__yoesrta21_MOD_layreffr
    ldr x9, [x9, :got_lo12:__yoesrta21_MOD_layreffr]
    ldr w10, [x9]
    str w10, [x29, #456]
    fmov d23, #1.0

    /* Preserve the complete lower pass before the complete upper pass. */
    mov x26, #0
.Lpass_start:
    cbnz x26, .Lupper_pass
    ldr x27, [x29, #400]
    mov x9, #4680
    str x9, [x29, #464]
    mov x9, #72
    str x9, [x29, #472]
    fmov d24, #8.0
    b .Lpass_selected
.Lupper_pass:
    ldr x27, [x29, #408]
    mov x9, #9400
    str x9, [x29, #464]
    mov x9, #40
    str x9, [x29, #472]
    fmov d24, #4.0
.Lpass_selected:
    mov x22, #0
.Llayer_start:
    mov x23, #0
.Lcolumn_start:
    /* q=c-KIDIA and k=l-1. The full cell index is q+B*k. */
    madd x24, x19, x22, x23
    ldr x9, [x29, #392]
    ldr d0, [x9, x23, lsl #3]
    fcmp d0, #0.0
    b.le .Lnext_column
    ldr x9, [x29, #312]
    ldr w10, [x9, x23, lsl #2]
    cmp w22, w10
    cbnz x26, .Lupper_cell_selection
    b.ge .Lnext_column

    /* Lower JP(l+1) is a genuine row within the declared V extent. */
    ldr x9, [x29, #256]
    ldr w11, [x9, x24, lsl #2]
    add x12, x24, x19
    ldr w12, [x9, x12, lsl #2]
    ldr w13, [x29, #456]
    cmp w11, w13
    b.ge .Lselector_ready
    cmp w12, w13
    b.lt .Lselector_ready
    add w11, w22, #2
    cmp w11, w10
    csel w11, w11, w10, le
    str w11, [x28, x23, lsl #2]
.Lselector_ready:
    ldr w11, [x28, x23, lsl #2]
    add w12, w22, #1
    cmp w11, w12
    cset w11, eq
    str w11, [x29, #528]
    b .Lcell_selected
.Lupper_cell_selection:
    b.lt .Lnext_column
    str wzr, [x29, #528]
.Lcell_selected:
    /* SW21-C1. Each product, sum and division rounds separately. */
    ldr x9, [x29, #288]
    ldr d9, [x9, x24, lsl #3]
    ldr x9, [x29, #296]
    ldr d0, [x9, x24, lsl #3]
    fmul d0, d21, d0
    fadd d8, d9, d0
    fdiv d0, d9, d8
    ldr x9, [x29, #280]
    ldr d1, [x9, x23, lsl #3]
    fcmp d0, d1
    fcsel d0, d0, d1, lt

    /* SW21-C2. INT is truncation. MOD retains x when INT(x)=0,
     * including -0. Otherwise subtraction is exact for 1<=x<8. */
    fmul d0, d24, d0
    fcvtzs w14, d0
    cbz w14, .Lzero_integer_part
    scvtf d1, w14
    fsub d10, d0, d1
    b .Lfraction_ready
.Lzero_integer_part:
    fmov d10, d0
.Lfraction_ready:
    fsub d11, d23, d10

    /* SW21-C3. Store zero-based row byte offsets once per cell. */
    ldr x9, [x29, #256]
    ldr w10, [x9, x24, lsl #2]
    ldr x9, [x29, #264]
    ldr w11, [x9, x24, lsl #2]
    sub w11, w11, #1
    mov w12, #1
    mov w13, #9
    cbz x26, .Lrow_parameters_ready
    mov w12, #13
    mov w13, #5
.Lrow_parameters_ready:
    sub w10, w10, w12
    mov w15, #5
    madd w11, w10, w15, w11
    madd w11, w11, w13, w14
    lsl x11, x11, #3
    str x11, [x29, #480]
    ldr x9, [x29, #272]
    ldr w11, [x9, x24, lsl #2]
    sub w11, w11, #1
    add w10, w10, #1
    madd w11, w10, w15, w11
    madd w11, w11, w13, w14
    lsl x11, x11, #3
    str x11, [x29, #488]

    /* Corner order is FAC00, FAC10, FAC01, FAC11, arguments5,7,6,8. */
    ldr x9, [x29, #224]
    ldr d13, [x9, x24, lsl #3]
    ldr x9, [x29, #240]
    ldr d14, [x9, x24, lsl #3]
    ldr x9, [x29, #232]
    ldr d15, [x9, x24, lsl #3]
    ldr x9, [x29, #248]
    ldr d16, [x9, x24, lsl #3]
    ldr x9, [x29, #304]
    ldr d0, [x9, x24, lsl #3]
    fmul d12, d0, d22

    /* Foreign fields belong to both branches. */
    ldr x9, [x29, #344]
    ldr d20, [x9, x24, lsl #3]
    ldr x9, [x29, #352]
    ldr d19, [x9, x24, lsl #3]
    ldr x9, [x29, #360]
    ldr w10, [x9, x24, lsl #2]
    sub w10, w10, #1
    ldr x9, [x29, #424]
    add x9, x9, x10, lsl #3
    str x9, [x29, #504]
    cbnz x26, .Lupper_continuum_ready

    /* Lower-only self fields and solar table selection. */
    ldr x9, [x29, #320]
    ldr d18, [x9, x24, lsl #3]
    ldr x9, [x29, #328]
    ldr d17, [x9, x24, lsl #3]
    ldr x9, [x29, #336]
    ldr w10, [x9, x24, lsl #2]
    sub w10, w10, #1
    ldr x9, [x29, #416]
    add x9, x9, x10, lsl #3
    str x9, [x29, #496]
    ldr x9, [x29, #432]
    add x9, x9, x14, lsl #7
    str x9, [x29, #512]
    b .Lspectral_start
.Lupper_continuum_ready:
    /* SW21-C7 upper water-factor product precedes each foreign result. */
    fmul d26, d9, d20
.Lspectral_start:
    mov x25, #0
.Lspectral_point:
    ldr x9, [x29, #464]
    madd x0, x25, x9, x27
    ldr x1, [x29, #480]
    ldr x2, [x29, #488]
    ldr x3, [x29, #472]

    /* SW21-C4. L preserves four coefficient-first products and left sums. */
    ldr d0, [x0, x1]
    fmul d0, d0, d13
    add x8, x1, x3
    ldr d1, [x0, x8]
    fmul d1, d1, d14
    fadd d0, d0, d1
    ldr d1, [x0, x2]
    fmul d1, d1, d15
    fadd d0, d0, d1
    add x8, x2, x3
    ldr d1, [x0, x8]
    fmul d1, d1, d16
    fadd d0, d0, d1

    /* U uses the adjacent mixture row at every corner. */
    add x8, x1, #8
    ldr d2, [x0, x8]
    fmul d2, d2, d13
    add x8, x1, x3
    add x8, x8, #8
    ldr d3, [x0, x8]
    fmul d3, d3, d14
    fadd d2, d2, d3
    add x8, x2, #8
    ldr d3, [x0, x8]
    fmul d3, d3, d15
    fadd d2, d2, d3
    add x8, x2, x3
    add x8, x8, #8
    ldr d3, [x0, x8]
    fmul d3, d3, d16
    fadd d2, d2, d3

    /* SW21-C5. Keep the mixture blend before the combined-column product. */
    fmul d0, d11, d0
    fmul d2, d10, d2
    fadd d0, d0, d2
    fmul d0, d8, d0

    /* SW21-C6. Foreign interpolation keeps its subtraction and product. */
    ldr x8, [x29, #504]
    add x8, x8, x25, lsl #5
    ldr d2, [x8]
    ldr d3, [x8, #8]
    fsub d3, d3, d2
    fmul d3, d19, d3
    fadd d2, d2, d3
    cbnz x26, .Lupper_continuum
    ldr x8, [x29, #496]
    mov x9, #80
    madd x8, x25, x9, x8
    ldr d3, [x8]
    ldr d4, [x8, #8]
    fsub d4, d4, d3
    fmul d4, d17, d4
    fadd d3, d3, d4
    fmul d3, d18, d3
    fmul d2, d20, d2
    fadd d2, d3, d2
    fmul d2, d9, d2
    b .Lcontinuum_ready
.Lupper_continuum:
    fmul d2, d26, d2
.Lcontinuum_ready:
    fadd d0, d0, d2

    /* The full B*V plane pitch preserves tails and all six inactive points. */
    mul x4, x19, x21
    mul x4, x4, x25
    add x4, x4, x24
    ldr x5, [x29, #376]
    ldr x6, [x29, #384]
    str d0, [x5, x4, lsl #3]
    str d12, [x6, x4, lsl #3]

    /* SW21-C8. Only the lower pass's selected layer writes solar bytes. */
    ldr w9, [x29, #528]
    cbz w9, .Lnext_spectral_point
    ldr x8, [x29, #512]
    ldr d1, [x8, x25, lsl #3]
    add x9, x8, #128
    ldr d2, [x9, x25, lsl #3]
    fsub d2, d2, d1
    fmul d2, d10, d2
    fadd d1, d1, d2
    ldr x8, [x29, #368]
    madd x9, x19, x25, x23
    str d1, [x8, x9, lsl #3]
.Lnext_spectral_point:
    add x25, x25, #1
    cmp x25, #10
    b.lo .Lspectral_point
.Lnext_column:
    add x23, x23, #1
    cmp x23, x19
    b.lo .Lcolumn_start
    add x22, x22, #1
    cmp x22, x20
    b.lo .Llayer_start
    cbnz x26, .Lreturn
    mov x26, #1
    b .Lpass_start

.Lreturn:
    mov sp, x29
    ldr w9, [x29, #168]
    cbz w9, .Lhook_return_done
    adrp x0, .Lhook_name
    add x0, x0, :lo12:.Lhook_name
    adrp x1, .Lhook_one
    add x1, x1, :lo12:.Lhook_one
    add x2, x29, #160
    mov x3, #13
    bl __yomhook_MOD_dr_hook_default8
.Lhook_return_done:
    ldp d8, d9, [x29, #96]
    ldp d10, d11, [x29, #112]
    ldp d12, d13, [x29, #128]
    ldp d14, d15, [x29, #144]
    ldp x19, x20, [x29, #16]
    ldp x21, x22, [x29, #32]
    ldp x23, x24, [x29, #48]
    ldp x25, x26, [x29, #64]
    ldp x27, x28, [x29, #80]
    ldp x29, x30, [sp]
    add sp, sp, #640
    .cfi_def_cfa sp, 0
    ret
.Lshape_rejected:
    /* Unsupported geometry is rejected before any numerical cell access. */
    brk #0x21
    .cfi_endproc
.size md2asm_srtm_taumol21, .-md2asm_srtm_taumol21

.section .rodata
.Lhook_name:
    .ascii "SRTM_TAUMOL21"
.p2align 2
.Lhook_zero:
    .word 0
.Lhook_one:
    .word 1
.section .note.GNU-stack,"",%progbits

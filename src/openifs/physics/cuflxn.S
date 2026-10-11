/* Complete normal-physics convective flux update.
 * Physics input formulations/openifs/physics/convective_final_fluxes.md.
 * Numerical contract skills/md2asm/references/openifs/physics/cuflxn.md.
 * GNU Arm ABI uses 43 ordinary by-address arguments. The contract defines
 * every owner extent, selected column, private buffer and output byte.
 */
#ifndef CUFLX_SYMBOL
#define CUFLX_SYMBOL cuflxn_
#endif
#ifndef CUFLX_SNAPSHOT
#define CUFLX_SNAPSHOT cuflx_snapshot_
#endif
#ifndef CUFLX_POWER
#define CUFLX_POWER md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.global CUFLX_SYMBOL
.type CUFLX_SYMBOL, %function
CUFLX_SYMBOL:
    sub sp, sp, #1024
    stp x29, x30, [sp]
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp d8, d9, [sp, #96]
    stp d10, d11, [sp, #112]
    stp d12, d13, [sp, #128]
    stp d14, d15, [sp, #144]
    mov x29, sp
    stp x0, x1, [sp, #176]
    stp x2, x3, [sp, #192]
    stp x4, x5, [sp, #208]
    stp x6, x7, [sp, #224]
    add x9, sp, #1024
    add x10, sp, #240
    mov x11, #35
.Lcuflx_arguments:
    ldr x12, [x9], #8
    str x12, [x10], #8
    subs x11, x11, #1
    b.ne .Lcuflx_arguments
    ldr w9, [x0, #4]
    cbnz w9, .Lcuflx_reject
    ldrsw x19, [x4]
    ldrsw x20, [x5]
    cmp x19, #1
    b.lt .Lcuflx_reject
    cmp x20, #1
    b.lt .Lcuflx_reject
    ldrsw x21, [x2]
    ldrsw x22, [x3]
    sub x21, x21, #1
    sub x22, x22, #1
    cmp x21, #0
    b.lt .Lcuflx_reject
    cmp x22, x19
    b.ge .Lcuflx_reject
    lsl x27, x19, #3
    mul x28, x27, x20
    mov x0, x19
    mov x1, #28
    bl calloc
    mov x24, x0
    cbz x24, .Lcuflx_reject
    mov x23, x21
.Ldomain_col:
    cmp x23, x22
    b.gt .Ldomain_end
    lsl x26, x23, #3
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Ldomain_nextcol
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #1
    b.lt .Lcuflx_reject
    cmp w9, w20
    b.ge .Lcuflx_reject
    ldr x10, [sp, #320]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #1
    b.lt .Lcuflx_reject
    cmp w9, w20
    b.gt .Lcuflx_reject
    ldr x10, [sp, #328]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lcuflx_domain_dt_ready
    cmp w9, #1
    b.lt .Lcuflx_reject
    cmp w9, w20
    b.le .Lcuflx_domain_dt_ready
    add w11, w20, #1
    cmp w9, w11
    b.ne .Lcuflx_reject
    ldr x10, [sp, #352]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbnz w9, .Lcuflx_reject
.Lcuflx_domain_dt_ready:
.Ldomain_nextcol:
    add x23, x23, #1
    b .Ldomain_col
.Ldomain_end:
    adrp x9, :got:__yomcst_MOD_rlmlt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rlmlt]
    ldr d0, [x9]
    adrp x9, :got:__yomcst_MOD_rg
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rg]
    ldr d1, [x9]
    fmul d0, d0, d1
    ldr x9, [sp, #184]
    ldr d2, [x9, #208]
    fmul d0, d0, d2
    adrp x9, :got:__yomcst_MOD_rcpd
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rcpd]
    ldr d1, [x9]
    fdiv d0, d1, d0
    str d0, [sp, #640]
    adrp x9, :got:__yomcst_MOD_rg
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rg]
    ldr d0, [x9]
    ldr x9, [sp, #224]
    ldr d1, [x9]
    fmul d0, d0, d1
    ldr x9, [sp, #184]
    ldr d1, [x9, #56]
    fdiv d0, d1, d0
    str d0, [sp, #648]
    ldr x9, [sp, #184]
    ldr w10, [x9, #272]
    cmp w10, #0
    cset w10, ne
    ucvtf d0, w10
    str d0, [sp, #656]
    ldr w10, [x9, #276]
    cmp w10, #0
    cset w10, eq
    ucvtf d0, w10
    str d0, [sp, #664]
/* Remove the environmental heat and water carried by each mass flux. */
    mov x23, x21
.Lprepare_col:
    cmp x23, x22
    b.gt .Lprepare_end
    lsl x26, x23, #3
    fmov d0, xzr
    ldr x9, [sp, #496]
    mov x10, x26
    str d0, [x9, x10]
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lcuflx_inactive
    ldr x10, [sp, #328]
    lsl x12, x23, #2
    ldr w13, [x10, x12]
    ldr x10, [sp, #320]
    lsl x12, x23, #2
    ldr w14, [x10, x12]
    cmp w13, w14
    b.ge .Lcuflx_flagready
.Lcuflx_inactive:
    mov w13, #0
    ldr x10, [sp, #352]
    lsl x12, x23, #2
    str w13, [x10, x12]
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbnz w9, .Lcuflx_flagready
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    str w13, [x10, x12]
.Lcuflx_flagready:
    mov w13, w20
    add x10, x24, x27
    add x10, x10, x27, lsl #1
    add x10, x10, x23, lsl #2
    str w13, [x10]
    ldr x10, [sp, #296]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lcuflx_sea
    adrp x9, .Lcuflx_k0
    ldr d0, [x9, :lo12:.Lcuflx_k0]
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #1
    b.ne .Lcuflx_rhe_ready
    adrp x9, .Lcuflx_k1
    ldr d0, [x9, :lo12:.Lcuflx_k1]
    b .Lcuflx_rhe_ready
.Lcuflx_sea:
    ldr x9, [sp, #184]
    ldr d0, [x9, #216]
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #1
    b.ne .Lcuflx_rhe_ready
    adrp x9, .Lcuflx_k2
    ldr d0, [x9, :lo12:.Lcuflx_k2]
.Lcuflx_rhe_ready:
    add x10, x24, x23, lsl #3
    str d0, [x10]
.Lprepare_nextcol:
    add x23, x23, #1
    b .Lprepare_col
.Lprepare_end:
    ldr x9, [sp, #336]
    mov w10, #2
    str w10, [x9]
    mov x25, #1
.Lenvironment_level:
    cmp x25, x20
    b.hs .Lenvironment_end
    mov x23, x21
.Lenvironment_col:
    cmp x23, x22
    b.gt .Lenvironment_nextlevel
    lsl x26, x23, #3
    madd x26, x25, x27, x26
    fmov d0, xzr
    ldr x9, [sp, #480]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #488]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #464]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #440]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #440]
    mov x10, x26
    add x10, x10, x28
    str d0, [x9, x10]
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lcuflx_no_cloud
    ldr x10, [sp, #320]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w11, w25, #1
    cmp w11, w9
    b.lt .Lcuflx_no_cloud
    ldr x9, [sp, #256]
    mov x10, x26
    ldr d0, [x9, x10]
    adrp x9, :got:__yomcst_MOD_rcpd
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rcpd]
    ldr d1, [x9]
    fmul d0, d1, d0
    ldr x9, [sp, #288]
    mov x10, x26
    ldr d1, [x9, x10]
    fadd d6, d0, d1
    ldr x9, [sp, #360]
    mov x10, x26
    ldr d0, [x9, x10]
    fmul d1, d0, d6
    ldr x9, [sp, #376]
    mov x10, x26
    ldr d2, [x9, x10]
    fsub d2, d2, d1
    ldr x9, [sp, #376]
    mov x10, x26
    str d2, [x9, x10]
    ldr x9, [sp, #264]
    mov x10, x26
    ldr d7, [x9, x10]
    fmul d1, d0, d7
    ldr x9, [sp, #392]
    mov x10, x26
    ldr d2, [x9, x10]
    fsub d2, d2, d1
    ldr x9, [sp, #392]
    mov x10, x26
    str d2, [x9, x10]
    ldr x9, [sp, #472]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d1, d0, d1
    ldr x9, [sp, #472]
    mov x10, x26
    str d1, [x9, x10]
    ldr x10, [sp, #352]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lcuflx_no_dd
    ldr x10, [sp, #328]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w11, w25, #1
    cmp w11, w9
    b.lt .Lcuflx_no_dd
    ldr x9, [sp, #368]
    mov x10, x26
    ldr d0, [x9, x10]
    fmul d1, d0, d6
    ldr x9, [sp, #384]
    mov x10, x26
    ldr d2, [x9, x10]
    fsub d2, d2, d1
    ldr x9, [sp, #384]
    mov x10, x26
    str d2, [x9, x10]
    fmul d1, d0, d7
    ldr x9, [sp, #400]
    mov x10, x26
    ldr d2, [x9, x10]
    fsub d2, d2, d1
    ldr x9, [sp, #400]
    mov x10, x26
    str d2, [x9, x10]
    fmov d1, xzr
    fcmp d0, d1
    b.ge .Lenvironment_nextcol
    add x16, x26, x27
    sub x9, x20, #1
    cmp x25, x9
    csel x16, x26, x16, eq
    ldr x9, [sp, #368]
    mov x10, x16
    ldr d2, [x9, x10]
    fcmp d2, d1
    b.ne .Lenvironment_nextcol
    add w13, w25, #1
    add x10, x24, x27
    add x10, x10, x27, lsl #1
    add x10, x10, x23, lsl #2
    str w13, [x10]
    b .Lenvironment_nextcol
.Lcuflx_no_dd:
    fmov d0, xzr
    ldr x9, [sp, #368]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #384]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #400]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #456]
    sub x10, x26, x27
    str d0, [x9, x10]
    b .Lenvironment_nextcol
.Lcuflx_no_cloud:
    fmov d0, xzr
    ldr x9, [sp, #360]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #368]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #376]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #384]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #392]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #400]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #408]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #472]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #448]
    sub x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #456]
    sub x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #416]
    sub x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #424]
    sub x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #424]
    sub x10, x26, x27
    add x10, x10, x28
    str d0, [x9, x10]
.Lenvironment_nextcol:
    add x23, x23, #1
    b .Lenvironment_col
.Lenvironment_nextlevel:
    add x25, x25, #1
    b .Lenvironment_level
.Lenvironment_end:
    mov x23, #0
.Lcuflx_boundaries:
    cmp x23, x19
    b.hs .Lcuflx_boundary_done
    lsl x26, x23, #3
    fmov d0, xzr
    ldr x9, [sp, #480]
    mov x10, x26
    str d0, [x9, x10]
    add x16, x26, x28
    ldr x9, [sp, #480]
    mov x10, x16
    str d0, [x9, x10]
    ldr x9, [sp, #488]
    mov x10, x26
    str d0, [x9, x10]
    add x16, x26, x28
    ldr x9, [sp, #488]
    mov x10, x16
    str d0, [x9, x10]
    ldr x9, [sp, #440]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #440]
    mov x10, x26
    add x10, x10, x28
    str d0, [x9, x10]
    add x23, x23, #1
    b .Lcuflx_boundaries
.Lcuflx_boundary_done:
/* Use pressure distance to taper mass below the cloud base. */
    mov x23, x21
.Lbase_col:
    cmp x23, x22
    b.gt .Lbase_end
    lsl x26, x23, #3
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lbase_nextcol
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w13, [x10, x12]
    sub x16, x13, #1
    mul x16, x16, x27
    add x16, x16, x26
    add x17, x16, x27
    str x16, [sp, #696]
    str x17, [sp, #704]
    add x15, x26, x28
    ldr x9, [sp, #272]
    mov x10, x15
    ldr d0, [x9, x10]
    ldr x9, [sp, #272]
    mov x10, x17
    ldr d1, [x9, x10]
    fsub d1, d0, d1
    ldr x9, [sp, #272]
    mov x10, x16
    ldr d2, [x9, x10]
    fsub d2, d0, d2
    fdiv d0, d1, d2
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #3
    b.ne .Lcuflx_base_linear
    fmul d0, d0, d0
.Lcuflx_base_linear:
    str d0, [sp, #672]
    ldr x9, [sp, #360]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #360]
    mov x10, x17
    str d1, [x9, x10]
    ldr x9, [sp, #256]
    mov x10, x16
    ldr d0, [x9, x10]
    bl .Lcuflx_latent
    ldr x16, [sp, #696]
    ldr x17, [sp, #704]
    ldr x9, [sp, #408]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d0, d0, d1
    ldr x9, [sp, #376]
    mov x10, x16
    ldr d2, [x9, x10]
    fsub d2, d2, d0
    ldr d3, [sp, #672]
    fmul d2, d2, d3
    ldr x9, [sp, #376]
    mov x10, x17
    str d2, [x9, x10]
    ldr x9, [sp, #392]
    mov x10, x16
    ldr d2, [x9, x10]
    fadd d2, d2, d1
    fmul d2, d2, d3
    ldr x9, [sp, #392]
    mov x10, x17
    str d2, [x9, x10]
    fmov d0, xzr
    ldr x9, [sp, #408]
    mov x10, x17
    str d0, [x9, x10]
.Lbase_nextcol:
    add x23, x23, #1
    b .Lbase_col
.Lbase_end:
    mov x25, #1
.Ltaper_level:
    cmp x25, x20
    b.hs .Ltaper_end
    mov x23, x21
.Ltaper_col:
    cmp x23, x22
    b.gt .Ltaper_nextlevel
    lsl x26, x23, #3
    madd x26, x25, x27, x26
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lcuflx_dd_taper
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w9, w9, #1
    add w11, w25, #1
    cmp w11, w9
    b.le .Lcuflx_dd_taper
    sub x16, x9, #1
    mul x16, x16, x27
    add x16, x16, x23, lsl #3
    add x15, x28, x23, lsl #3
    ldr x9, [sp, #272]
    mov x10, x15
    ldr d0, [x9, x10]
    ldr x9, [sp, #272]
    mov x10, x26
    ldr d1, [x9, x10]
    fsub d1, d0, d1
    ldr x9, [sp, #272]
    mov x10, x16
    ldr d2, [x9, x10]
    fsub d2, d0, d2
    fdiv d0, d1, d2
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #3
    b.ne .Lcuflx_taper_linear
    fmul d0, d0, d0
.Lcuflx_taper_linear:
    ldr x9, [sp, #360]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #360]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #376]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #376]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #392]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #392]
    mov x10, x26
    str d1, [x9, x10]
    fmov d0, xzr
    ldr x9, [sp, #408]
    mov x10, x26
    str d0, [x9, x10]
.Lcuflx_dd_taper:
    ldr x10, [sp, #352]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Ltaper_nextcol
    add x10, x24, x27
    add x10, x10, x27, lsl #1
    add x10, x10, x23, lsl #2
    ldr w13, [x10]
    add w11, w25, #1
    cmp w11, w13
    b.le .Ltaper_nextcol
    cmp w13, w20
    b.ge .Ltaper_nextcol
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w9, w9, #1
    cmp w13, w9
    b.ne .Lcuflx_dd_single
    sub x16, x13, #1
    mul x16, x16, x27
    add x16, x16, x23, lsl #3
    add x15, x28, x23, lsl #3
    ldr x9, [sp, #272]
    mov x10, x15
    ldr d0, [x9, x10]
    ldr x9, [sp, #272]
    mov x10, x26
    ldr d1, [x9, x10]
    fsub d1, d0, d1
    ldr x9, [sp, #272]
    mov x10, x16
    ldr d2, [x9, x10]
    fsub d2, d0, d2
    fdiv d0, d1, d2
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #3
    b.ne .Lcuflx_dd_linear
    fmul d0, d0, d0
.Lcuflx_dd_linear:
    ldr x9, [sp, #368]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #368]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #384]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #384]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #400]
    mov x10, x16
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #400]
    mov x10, x26
    str d1, [x9, x10]
    b .Lcuflx_dd_rate
.Lcuflx_dd_single:
    add w13, w13, #1
    cmp w11, w13
    b.ne .Ltaper_nextcol
.Lcuflx_dd_rate:
    ldr x9, [sp, #368]
    sub x10, x26, x27
    ldr d0, [x9, x10]
    ldr x9, [sp, #368]
    mov x10, x26
    ldr d1, [x9, x10]
    fsub d0, d0, d1
    fneg d0, d0
    ldr x9, [sp, #512]
    mov x10, x26
    str d0, [x9, x10]
.Ltaper_nextcol:
    add x23, x23, #1
    b .Ltaper_col
.Ltaper_nextlevel:
    add x25, x25, #1
    b .Ltaper_level
.Ltaper_end:
/* Limit downdraft mass while preserving its heat and water ratios. */
    mov x23, #0
.Lcuflx_mfs_init:
    cmp x23, x19
    b.hs .Lcuflx_mfs_ready
    adrp x9, .Lcuflx_k3
    ldr d0, [x9, :lo12:.Lcuflx_k3]
    add x10, x24, x23, lsl #3
    add x10, x10, x27
    str d0, [x10]
    add x23, x23, #1
    b .Lcuflx_mfs_init
.Lcuflx_mfs_ready:
    mov x25, #1
.Llimit_level:
    cmp x25, x20
    b.hs .Llimit_end
    mov x23, x21
.Llimit_col:
    cmp x23, x22
    b.gt .Llimit_nextlevel
    lsl x26, x23, #3
    madd x26, x25, x27, x26
    ldr x10, [sp, #352]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Llimit_nextcol
    ldr x10, [sp, #328]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    sub w9, w9, #1
    add w11, w25, #1
    cmp w11, w9
    b.lt .Llimit_nextcol
    ldr x9, [sp, #360]
    mov x10, x26
    ldr d0, [x9, x10]
    fabs d0, d0
    adrp x9, .Lcuflx_k4
    ldr d1, [x9, :lo12:.Lcuflx_k4]
    fmul d0, d0, d1
    ldr x9, [sp, #368]
    mov x10, x26
    ldr d2, [x9, x10]
    fadd d3, d2, d0
    adrp x9, .Lcuflx_k5
    ldr d1, [x9, :lo12:.Lcuflx_k5]
    fadd d3, d3, d1
    fmov d1, xzr
    fcmp d3, d1
    b.ge .Llimit_nextcol
    fneg d0, d0
    fdiv d0, d0, d2
    add x10, x24, x23, lsl #3
    add x10, x10, x27
    ldr d1, [x10]
    fminnm d0, d1, d0
    add x10, x24, x23, lsl #3
    add x10, x10, x27
    str d0, [x10]
.Llimit_nextcol:
    add x23, x23, #1
    b .Llimit_col
.Llimit_nextlevel:
    add x25, x25, #1
    b .Llimit_level
.Llimit_end:
    mov x25, #1
.Lrescale_level:
    cmp x25, x20
    b.hs .Lrescale_end
    mov x23, x21
.Lrescale_col:
    cmp x23, x22
    b.gt .Lrescale_nextlevel
    lsl x26, x23, #3
    madd x26, x25, x27, x26
    add x10, x24, x23, lsl #3
    add x10, x10, x27
    ldr d0, [x10]
    adrp x9, .Lcuflx_k3
    ldr d1, [x9, :lo12:.Lcuflx_k3]
    fcmp d0, d1
    b.ge .Lrescale_nextcol
    ldr x10, [sp, #328]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    sub w9, w9, #1
    add w11, w25, #1
    cmp w11, w9
    b.lt .Lrescale_nextcol
    ldr x9, [sp, #368]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #368]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #384]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #384]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #400]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #400]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #512]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #512]
    mov x10, x26
    str d1, [x9, x10]
    ldr x9, [sp, #456]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d1, d1, d0
    ldr x9, [sp, #456]
    mov x10, x26
    str d1, [x9, x10]
.Lrescale_nextcol:
    add x23, x23, #1
    b .Lrescale_col
.Lrescale_nextlevel:
    add x25, x25, #1
    b .Lrescale_level
.Lrescale_end:
/* Carry rain and snow downwards, exchanging melting mass equally. */
    mov x25, #1
.Lprecip_level:
    cmp x25, x20
    b.hs .Lprecip_end
    mov x23, x21
.Lprecip_col:
    cmp x23, x22
    b.gt .Lprecip_nextlevel
    lsl x26, x23, #3
    madd x26, x25, x27, x26
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Lprecip_nextcol
    ldr x10, [sp, #320]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w11, w25, #1
    sub w9, w9, #1
    cmp w11, w9
    b.lt .Lprecip_nextcol
    lsl x16, x23, #3
    ldr x9, [sp, #496]
    mov x10, x16
    ldr d0, [x9, x10]
    ldr x9, [sp, #448]
    mov x10, x26
    ldr d1, [x9, x10]
    fadd d0, d0, d1
    ldr x9, [sp, #496]
    mov x10, x16
    str d0, [x9, x10]
    ldr x9, [sp, #232]
    mov x10, x26
    ldr d0, [x9, x10]
    str d0, [sp, #680]
    ldr x9, [sp, #248]
    mov x10, x26
    ldr d1, [x9, x10]
    ldr x9, [sp, #240]
    mov x10, x26
    ldr d2, [x9, x10]
    fsub d1, d1, d2
    fmov d3, xzr
    fmaxnm d1, d3, d1
    ldr x9, [sp, #280]
    mov x10, x26
    ldr d2, [x9, x10]
    adrp x9, .Lcuflx_k6
    ldr d3, [x9, :lo12:.Lcuflx_k6]
    fsub d2, d2, d3
    adrp x9, .Lcuflx_k7
    ldr d3, [x9, :lo12:.Lcuflx_k7]
    fmul d2, d3, d2
    adrp x9, .Lcuflx_k8
    ldr d3, [x9, :lo12:.Lcuflx_k8]
    fadd d2, d3, d2
    adrp x9, .Lcuflx_k9
    ldr d3, [x9, :lo12:.Lcuflx_k9]
    fsub d3, d0, d3
    adrp x9, .Lcuflx_k10
    ldr d4, [x9, :lo12:.Lcuflx_k10]
    fmul d3, d4, d3
    fsub d2, d2, d3
    fmul d1, d1, d2
    fsub d1, d0, d1
    ldr d2, [sp, #656]
    fmul d1, d1, d2
    adrp x9, .Lcuflx_k3
    ldr d3, [x9, :lo12:.Lcuflx_k3]
    fsub d2, d3, d2
    fmul d0, d2, d0
    fadd d0, d1, d0
    str d0, [sp, #680]
    ldr x9, [sp, #488]
    mov x10, x26
    ldr d1, [x9, x10]
    fmov d2, xzr
    fcmp d1, d2
    b.le .Lcuflx_melt_done
    adrp x9, :got:__yomcst_MOD_rtt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rtt]
    ldr d2, [x9]
    fcmp d0, d2
    b.le .Lcuflx_melt_done
    fsub d3, d0, d2
    adrp x9, .Lcuflx_k11
    ldr d4, [x9, :lo12:.Lcuflx_k11]
    fmul d3, d4, d3
    adrp x9, .Lcuflx_k3
    ldr d4, [x9, :lo12:.Lcuflx_k3]
    fadd d3, d4, d3
    ldr d4, [sp, #640]
    fmul d3, d4, d3
    ldr x9, [sp, #272]
    add x10, x26, x27
    ldr d4, [x9, x10]
    ldr x9, [sp, #272]
    mov x10, x26
    ldr d5, [x9, x10]
    fsub d4, d4, d5
    fmul d3, d3, d4
    str d3, [sp, #712]
    fsub d4, d0, d2
    fmul d4, d3, d4
    fminnm d1, d1, d4
    ldr x9, [sp, #464]
    mov x10, x26
    str d1, [x9, x10]
    fdiv d1, d1, d3
    fsub d0, d0, d1
    bl .Lcuflx_saturation
    ldr x9, [sp, #280]
    mov x10, x26
    ldr d1, [x9, x10]
    fdiv d0, d0, d1
    ldr x9, [sp, #248]
    mov x10, x26
    str d0, [x9, x10]
.Lcuflx_melt_done:
    ldr d0, [sp, #680]
    bl .Lcuflx_alpha
    str d0, [sp, #688]
    ldr x9, [sp, #232]
    mov x10, x26
    ldr d1, [x9, x10]
    adrp x9, :got:__yomcst_MOD_rtt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rtt]
    ldr d2, [x9]
    fcmp d1, d2
    b.gt .Lcuflx_frozen_done
    fmov d1, xzr
    fcmp d0, d1
    b.le .Lcuflx_frozen_done
    ldr d1, [sp, #664]
    fmul d1, d1, d0
    ldr x9, [sp, #448]
    mov x10, x26
    ldr d2, [x9, x10]
    fmul d1, d1, d2
    ldr x9, [sp, #472]
    mov x10, x26
    ldr d3, [x9, x10]
    fadd d3, d3, d1
    ldr x9, [sp, #456]
    mov x10, x26
    ldr d2, [x9, x10]
    fmul d2, d0, d2
    fadd d3, d3, d2
    ldr x9, [sp, #472]
    mov x10, x26
    str d3, [x9, x10]
    fmov d0, xzr
    str d0, [sp, #688]
.Lcuflx_frozen_done:
    ldr x9, [sp, #184]
    ldr w9, [x9, #268]
    cbz w9, .Lcuflx_detrain_done
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w11, w25, #1
    cmp w11, w9
    b.gt .Lcuflx_detrain_done
    ldr x9, [sp, #432]
    add x10, x26, x27
    ldr d0, [x9, x10]
    ldr x9, [sp, #504]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d0, d0, d1
    ldr d1, [sp, #688]
    fmul d2, d0, d1
    adrp x9, .Lcuflx_k3
    ldr d3, [x9, :lo12:.Lcuflx_k3]
    fsub d3, d3, d1
    fmul d0, d0, d3
    ldr x9, [sp, #448]
    mov x10, x26
    ldr d4, [x9, x10]
    ldr x9, [sp, #456]
    mov x10, x26
    ldr d5, [x9, x10]
    fadd d4, d4, d5
    fmul d1, d1, d4
    fminnm d2, d2, d1
    fmul d3, d3, d4
    ldr x9, [sp, #464]
    mov x10, x26
    ldr d5, [x9, x10]
    fsub d3, d3, d5
    fminnm d0, d0, d3
    fmov d1, xzr
    fmaxnm d2, d2, d1
    fmaxnm d0, d0, d1
    ldr x9, [sp, #440]
    mov x10, x26
    str d2, [x9, x10]
    ldr x9, [sp, #440]
    mov x10, x26
    add x10, x10, x28
    str d0, [x9, x10]
.Lcuflx_detrain_done:
    ldr d0, [sp, #688]
    ldr x9, [sp, #448]
    mov x10, x26
    ldr d1, [x9, x10]
    ldr x9, [sp, #456]
    mov x10, x26
    ldr d2, [x9, x10]
    fadd d1, d1, d2
    fmul d2, d0, d1
    ldr x9, [sp, #480]
    mov x10, x26
    ldr d3, [x9, x10]
    fadd d3, d3, d2
    ldr x9, [sp, #464]
    mov x10, x26
    ldr d4, [x9, x10]
    fadd d3, d3, d4
    ldr x9, [sp, #440]
    mov x10, x26
    ldr d5, [x9, x10]
    fsub d3, d3, d5
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d3, [x9, x10]
    adrp x9, .Lcuflx_k3
    ldr d2, [x9, :lo12:.Lcuflx_k3]
    fsub d2, d2, d0
    fmul d2, d2, d1
    ldr x9, [sp, #488]
    mov x10, x26
    ldr d3, [x9, x10]
    fadd d3, d3, d2
    fsub d3, d3, d4
    ldr x9, [sp, #440]
    mov x10, x26
    add x10, x10, x28
    ldr d5, [x9, x10]
    fsub d3, d3, d5
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d3, [x9, x10]
    ldr x9, [sp, #480]
    add x10, x26, x27
    ldr d0, [x9, x10]
    ldr x9, [sp, #488]
    add x10, x26, x27
    ldr d1, [x9, x10]
    fadd d2, d0, d1
    fmov d3, xzr
    fcmp d2, d3
    b.ge .Lcuflx_precip_single
    ldr x9, [sp, #480]
    mov x10, x26
    ldr d0, [x9, x10]
    ldr x9, [sp, #488]
    mov x10, x26
    ldr d1, [x9, x10]
    fadd d0, d0, d1
    ldr x9, [sp, #448]
    mov x10, x26
    ldr d1, [x9, x10]
    fadd d0, d0, d1
    fneg d0, d0
    ldr x9, [sp, #456]
    mov x10, x26
    str d0, [x9, x10]
    fmov d0, xzr
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #464]
    mov x10, x26
    str d0, [x9, x10]
    b .Lprecip_nextcol
.Lcuflx_precip_single:
    fcmp d0, d3
    b.ge .Lcuflx_precip_snow
    fadd d1, d1, d0
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d1, [x9, x10]
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d3, [x9, x10]
    b .Lprecip_nextcol
.Lcuflx_precip_snow:
    fcmp d1, d3
    b.ge .Lprecip_nextcol
    fadd d0, d0, d1
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d3, [x9, x10]
.Lprecip_nextcol:
    add x23, x23, #1
    b .Lprecip_col
.Lprecip_nextlevel:
    add x25, x25, #1
    b .Lprecip_level
.Lprecip_end:
#ifdef CUFLX_TRACE
    // Record existing arrays without changing a numerical stage.
    ldr x8, [sp, #248]
    ldr x9, [sp, #472]
    sub sp, sp, #32
    stp x8, x9, [sp]
    ldr x0, [sp, #240]
    ldr x1, [sp, #248]
    ldr x2, [sp, #512]
    ldr x3, [sp, #520]
    ldr x4, [sp, #496]
    ldr x5, [sp, #480]
    ldr x6, [sp, #488]
    ldr x7, [sp, #472]
    bl CUFLX_SNAPSHOT
    add sp, sp, #32
#endif
/* Limit evaporation by incoming precipitation and pressure-weighted humidity. */
    mov x23, x21
.Larea_col:
    cmp x23, x22
    b.gt .Larea_end
    lsl x26, x23, #3
    ldr x10, [sp, #344]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cmp w9, #2
    b.lt .Lcuflx_shallow_area
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w13, [x10, x12]
    ldr x10, [sp, #320]
    lsl x12, x23, #2
    ldr w14, [x10, x12]
    sub x16, x13, #1
    mul x16, x16, x27
    add x16, x16, x26
    sub x17, x14, #1
    mul x17, x17, x27
    add x17, x17, x26
    ldr x9, [sp, #240]
    mov x10, x16
    ldr d0, [x9, x10]
    ldr x9, [sp, #248]
    mov x10, x16
    ldr d1, [x9, x10]
    fdiv d0, d0, d1
    ldr x9, [sp, #240]
    mov x10, x17
    ldr d2, [x9, x10]
    ldr x9, [sp, #248]
    mov x10, x17
    ldr d3, [x9, x10]
    fdiv d2, d2, d3
    fadd d0, d0, d2
    adrp x9, .Lcuflx_k11
    ldr d1, [x9, :lo12:.Lcuflx_k11]
    fmul d0, d1, d0
    adrp x9, .Lcuflx_k12
    ldr d1, [x9, :lo12:.Lcuflx_k12]
    fmaxnm d0, d1, d0
    fsub d0, d0, d1
    adrp x9, .Lcuflx_k13
    ldr d1, [x9, :lo12:.Lcuflx_k13]
    fdiv d0, d0, d1
    adrp x9, .Lcuflx_k3
    ldr d1, [x9, :lo12:.Lcuflx_k3]
    fadd d0, d1, d0
    ldr x9, [sp, #184]
    ldr d1, [x9, #200]
    fmul d0, d1, d0
    b .Lcuflx_area_ready
.Lcuflx_shallow_area:
    ldr x9, [sp, #184]
    ldr d0, [x9, #200]
    adrp x9, .Lcuflx_k14
    ldr d1, [x9, :lo12:.Lcuflx_k14]
    fmul d0, d0, d1
.Lcuflx_area_ready:
    add x10, x24, x23, lsl #3
    add x10, x10, x27, lsl #1
    str d0, [x10]
.Larea_nextcol:
    add x23, x23, #1
    b .Larea_col
.Larea_end:
    mov x25, #1
.Levap_level:
    cmp x25, x20
    b.hs .Levap_end
    mov x23, x21
.Levap_col:
    cmp x23, x22
    b.gt .Levap_nextlevel
    lsl x26, x23, #3
    madd x26, x25, x27, x26
    ldr x10, [sp, #304]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    cbz w9, .Levap_nextcol
    ldr x10, [sp, #312]
    lsl x12, x23, #2
    ldr w9, [x10, x12]
    add w11, w25, #1
    cmp w11, w9
    b.lt .Levap_nextcol
    ldr x9, [sp, #480]
    mov x10, x26
    ldr d0, [x9, x10]
    ldr x9, [sp, #488]
    mov x10, x26
    ldr d1, [x9, x10]
    fadd d0, d0, d1
    str d0, [sp, #720]
    adrp x9, .Lcuflx_k15
    ldr d1, [x9, :lo12:.Lcuflx_k15]
    fcmp d0, d1
    b.le .Lcuflx_no_precip
    add x15, x28, x23, lsl #3
    ldr x9, [sp, #272]
    mov x10, x26
    ldr d0, [x9, x10]
    ldr x9, [sp, #272]
    mov x10, x15
    ldr d1, [x9, x10]
    fdiv d0, d0, d1
    fsqrt d0, d0
    ldr x9, [sp, #184]
    ldr d1, [x9, #192]
    fdiv d0, d0, d1
    ldr d1, [sp, #720]
    fmul d0, d0, d1
    add x10, x24, x23, lsl #3
    add x10, x10, x27, lsl #1
    ldr d1, [x10]
    fdiv d0, d0, d1
    adrp x9, .Lcuflx_k16
    ldr d1, [x9, :lo12:.Lcuflx_k16]
    bl CUFLX_POWER
    str d0, [sp, #728]
    ldr x9, [sp, #248]
    mov x10, x26
    ldr d0, [x9, x10]
    ldr x9, [sp, #240]
    mov x10, x26
    ldr d1, [x9, x10]
    fsub d0, d0, d1
    fmov d2, xzr
    fmaxnm d0, d2, d0
    ldr x9, [sp, #184]
    ldr d1, [x9, #184]
    fmul d0, d1, d0
    add x10, x24, x23, lsl #3
    add x10, x10, x27, lsl #1
    ldr d1, [x10]
    fmul d0, d0, d1
    ldr d2, [sp, #728]
    fmul d0, d0, d2
    ldr x9, [sp, #272]
    add x10, x26, x27
    ldr d2, [x9, x10]
    ldr x9, [sp, #272]
    mov x10, x26
    ldr d3, [x9, x10]
    fsub d2, d2, d3
    fmul d0, d0, d2
    ldr d3, [sp, #720]
    fsub d4, d3, d0
    add x10, x24, x23, lsl #3
    ldr d0, [x10]
    ldr x9, [sp, #248]
    mov x10, x26
    ldr d5, [x9, x10]
    fmul d0, d0, d5
    ldr x9, [sp, #240]
    mov x10, x26
    ldr d5, [x9, x10]
    fsub d0, d0, d5
    fmov d5, xzr
    fmaxnm d0, d5, d0
    fmul d0, d1, d0
    ldr d5, [sp, #648]
    fmul d0, d0, d5
    fmul d0, d0, d2
    fsub d0, d3, d0
    fmaxnm d0, d4, d0
    fmov d1, xzr
    fmaxnm d0, d0, d1
    fsub d0, d0, d3
    fminnm d0, d1, d0
    str d0, [sp, #736]
    ldr x9, [sp, #232]
    mov x10, x26
    ldr d0, [x9, x10]
    str d0, [sp, #744]
    bl .Lcuflx_alpha
    ldr d1, [sp, #744]
    adrp x9, :got:__yomcst_MOD_rtt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rtt]
    ldr d2, [x9]
    fcmp d1, d2
    b.ge .Lcuflx_evap_phase
    fmov d0, xzr
.Lcuflx_evap_phase:
    ldr x9, [sp, #456]
    mov x10, x26
    ldr d1, [x9, x10]
    fmul d2, d0, d1
    adrp x9, .Lcuflx_k3
    ldr d3, [x9, :lo12:.Lcuflx_k3]
    fsub d0, d3, d0
    fmul d3, d0, d1
    ldr x9, [sp, #480]
    mov x10, x26
    ldr d4, [x9, x10]
    ldr x9, [sp, #488]
    mov x10, x26
    ldr d5, [x9, x10]
    fadd d0, d4, d5
    adrp x9, .Lcuflx_k15
    ldr d1, [x9, :lo12:.Lcuflx_k15]
    fmaxnm d0, d1, d0
    adrp x9, .Lcuflx_k3
    ldr d1, [x9, :lo12:.Lcuflx_k3]
    fdiv d0, d1, d0
    ldr d1, [sp, #736]
    ldr x9, [sp, #464]
    mov x10, x26
    ldr d6, [x9, x10]
    fadd d2, d4, d2
    fadd d2, d2, d6
    fmul d4, d1, d4
    fmul d4, d4, d0
    fadd d2, d2, d4
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d2, [x9, x10]
    fadd d3, d5, d3
    fsub d3, d3, d6
    fmul d5, d1, d5
    fmul d5, d5, d0
    fadd d3, d3, d5
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d3, [x9, x10]
    ldr x9, [sp, #448]
    mov x10, x26
    ldr d0, [x9, x10]
    fadd d0, d0, d1
    ldr x9, [sp, #448]
    mov x10, x26
    str d0, [x9, x10]
    fadd d4, d2, d3
    fmov d5, xzr
    fcmp d4, d5
    b.ge .Lcuflx_evap_single
    fsub d0, d0, d4
    ldr x9, [sp, #448]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d5, [x9, x10]
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d5, [x9, x10]
    ldr x9, [sp, #464]
    mov x10, x26
    str d5, [x9, x10]
    b .Levap_nextcol
.Lcuflx_evap_single:
    fcmp d2, d5
    b.ge .Lcuflx_evap_snow
    fadd d3, d3, d2
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d3, [x9, x10]
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d5, [x9, x10]
    b .Levap_nextcol
.Lcuflx_evap_snow:
    fcmp d3, d5
    b.ge .Levap_nextcol
    fadd d2, d2, d3
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d2, [x9, x10]
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d5, [x9, x10]
    b .Levap_nextcol
.Lcuflx_no_precip:
    fmov d0, xzr
    ldr x9, [sp, #480]
    add x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #488]
    add x10, x26, x27
    str d0, [x9, x10]
    ldr x9, [sp, #456]
    mov x10, x26
    str d0, [x9, x10]
    ldr x9, [sp, #464]
    mov x10, x26
    str d0, [x9, x10]
.Levap_nextcol:
    add x23, x23, #1
    b .Levap_col
.Levap_nextlevel:
    add x25, x25, #1
    b .Levap_level
.Levap_end:
    mov x0, x24
    bl free
    ldp d8, d9, [sp, #96]
    ldp d10, d11, [sp, #112]
    ldp d12, d13, [sp, #128]
    ldp d14, d15, [sp, #144]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp]
    add sp, sp, #1024
    ret
.Lcuflx_reject:
    bl abort
    brk #0
.size CUFLX_SYMBOL, .-CUFLX_SYMBOL

/* The accepted convective phase rule uses a bounded squared temperature. */
.Lcuflx_alpha:
    adrp x9, :got:__yoethf_MOD_rticecu
    ldr x9, [x9, :got_lo12:__yoethf_MOD_rticecu]
    ldr d1, [x9]
    adrp x9, :got:__yoethf_MOD_rtwat
    ldr x9, [x9, :got_lo12:__yoethf_MOD_rtwat]
    ldr d2, [x9]
    fminnm d0, d2, d0
    fmaxnm d0, d1, d0
    fsub d0, d0, d1
    adrp x9, :got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9, [x9, :got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d1, [x9]
    fmul d0, d0, d1
    fmul d0, d0, d0
    adrp x9, .Lcuflx_k3
    ldr d1, [x9, :lo12:.Lcuflx_k3]
    fminnm d0, d1, d0
    ret
.Lcuflx_latent:
    stp x29, x30, [sp, #-32]!
    bl .Lcuflx_alpha
    adrp x9, :got:__yomcst_MOD_rlvtt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rlvtt]
    ldr d1, [x9]
    fmul d1, d0, d1
    adrp x9, .Lcuflx_k3
    ldr d2, [x9, :lo12:.Lcuflx_k3]
    fsub d0, d2, d0
    adrp x9, :got:__yomcst_MOD_rlstt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rlstt]
    ldr d2, [x9]
    fmul d0, d0, d2
    fadd d0, d1, d0
    ldp x29, x30, [sp], #32
    ret
.Lcuflx_saturation:
    stp x29, x30, [sp, #-64]!
    str d0, [sp, #16]
    bl .Lcuflx_alpha
    str d0, [sp, #24]
    ldr d0, [sp, #16]
    adrp x9, :got:__yomcst_MOD_rtt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rtt]
    ldr d1, [x9]
    fsub d0, d0, d1
    adrp x9, :got:__yoethf_MOD_r3les
    ldr x9, [x9, :got_lo12:__yoethf_MOD_r3les]
    ldr d1, [x9]
    fmul d0, d1, d0
    ldr d1, [sp, #16]
    adrp x9, :got:__yoethf_MOD_r4les
    ldr x9, [x9, :got_lo12:__yoethf_MOD_r4les]
    ldr d2, [x9]
    fsub d1, d1, d2
    fdiv d0, d0, d1
    bl exp
    str d0, [sp, #32]
    ldr d0, [sp, #16]
    adrp x9, :got:__yomcst_MOD_rtt
    ldr x9, [x9, :got_lo12:__yomcst_MOD_rtt]
    ldr d1, [x9]
    fsub d0, d0, d1
    adrp x9, :got:__yoethf_MOD_r3ies
    ldr x9, [x9, :got_lo12:__yoethf_MOD_r3ies]
    ldr d1, [x9]
    fmul d0, d1, d0
    ldr d1, [sp, #16]
    adrp x9, :got:__yoethf_MOD_r4ies
    ldr x9, [x9, :got_lo12:__yoethf_MOD_r4ies]
    ldr d2, [x9]
    fsub d1, d1, d2
    fdiv d0, d0, d1
    bl exp
    ldr d1, [sp, #24]
    ldr d2, [sp, #32]
    fmul d2, d1, d2
    adrp x9, .Lcuflx_k3
    ldr d3, [x9, :lo12:.Lcuflx_k3]
    fsub d1, d3, d1
    fmul d0, d1, d0
    fadd d0, d2, d0
    adrp x9, :got:__yoethf_MOD_r2es
    ldr x9, [x9, :got_lo12:__yoethf_MOD_r2es]
    ldr d1, [x9]
    fmul d0, d1, d0
    ldp x29, x30, [sp], #64
    ret
.section .rodata
.p2align 3
.Lcuflx_k0:
    .quad 0x3fe8000000000000
.Lcuflx_k1:
    .quad 0x3fe6666666666666
.Lcuflx_k2:
    .quad 0x3feb333333333333
.Lcuflx_k3:
    .quad 0x3ff0000000000000
.Lcuflx_k4:
    .quad 0x3fef5c28f5c28f5c
.Lcuflx_k5:
    .quad 0x3cd203af9ee75616
.Lcuflx_k6:
    .quad 0x40f4c08000000000
.Lcuflx_k7:
    .quad 0x3f7e8ff327aa68f5
.Lcuflx_k8:
    .quad 0x4094c53d70a3d70a
.Lcuflx_k9:
    .quad 0x4071300000000000
.Lcuflx_k10:
    .quad 0x40445189374bc6a8
.Lcuflx_k11:
    .quad 0x3fe0000000000000
.Lcuflx_k12:
    .quad 0x3fe999999999999a
.Lcuflx_k13:
    .quad 0x3f9999999999999a
.Lcuflx_k14:
    .quad 0x3fe3333340000000
.Lcuflx_k15:
    .quad 0x3d719799812dea11
.Lcuflx_k16:
    .quad 0x3fe27c84b5dcc63f
.section .note.GNU-stack,"",%progbits

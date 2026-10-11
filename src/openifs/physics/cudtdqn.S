// Physics input formulations/openifs/physics/convective_heat_moisture.md.
// Numerical contract skills/md2asm/references/openifs/physics/cudtdqn.md.
#ifndef CUDTDQN_SYMBOL
#define CUDTDQN_SYMBOL cudtdqn_
#endif
.text
.p2align 4
.global CUDTDQN_SYMBOL
.type CUDTDQN_SYMBOL,%function
// Forty-four address arguments follow the GNU AArch64 Fortran ABI.
// Frame holds preserved registers, arguments and seven reusable matrices.
CUDTDQN_SYMBOL:
    sub sp,sp,#720
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x0,[sp,#112]
    str x1,[sp,#120]
    str x2,[sp,#128]
    str x3,[sp,#136]
    str x4,[sp,#144]
    str x5,[sp,#152]
    str x6,[sp,#160]
    str x7,[sp,#168]
    ldr x9,[x29,#720]
    str x9,[sp,#176]
    ldr x9,[x29,#728]
    str x9,[sp,#184]
    ldr x9,[x29,#736]
    str x9,[sp,#192]
    ldr x9,[x29,#744]
    str x9,[sp,#200]
    ldr x9,[x29,#752]
    str x9,[sp,#208]
    ldr x9,[x29,#760]
    str x9,[sp,#216]
    ldr x9,[x29,#768]
    str x9,[sp,#224]
    ldr x9,[x29,#776]
    str x9,[sp,#232]
    ldr x9,[x29,#784]
    str x9,[sp,#240]
    ldr x9,[x29,#792]
    str x9,[sp,#248]
    ldr x9,[x29,#800]
    str x9,[sp,#256]
    ldr x9,[x29,#808]
    str x9,[sp,#264]
    ldr x9,[x29,#816]
    str x9,[sp,#272]
    ldr x9,[x29,#824]
    str x9,[sp,#280]
    ldr x9,[x29,#832]
    str x9,[sp,#288]
    ldr x9,[x29,#840]
    str x9,[sp,#296]
    ldr x9,[x29,#848]
    str x9,[sp,#304]
    ldr x9,[x29,#856]
    str x9,[sp,#312]
    ldr x9,[x29,#864]
    str x9,[sp,#320]
    ldr x9,[x29,#872]
    str x9,[sp,#328]
    ldr x9,[x29,#880]
    str x9,[sp,#336]
    ldr x9,[x29,#888]
    str x9,[sp,#344]
    ldr x9,[x29,#896]
    str x9,[sp,#352]
    ldr x9,[x29,#904]
    str x9,[sp,#360]
    ldr x9,[x29,#912]
    str x9,[sp,#368]
    ldr x9,[x29,#920]
    str x9,[sp,#376]
    ldr x9,[x29,#928]
    str x9,[sp,#384]
    ldr x9,[x29,#936]
    str x9,[sp,#392]
    ldr x9,[x29,#944]
    str x9,[sp,#400]
    ldr x9,[x29,#952]
    str x9,[sp,#408]
    ldr x9,[x29,#960]
    str x9,[sp,#416]
    ldr x9,[x29,#968]
    str x9,[sp,#424]
    ldr x9,[x29,#976]
    str x9,[sp,#432]
    ldr x9,[x29,#984]
    str x9,[sp,#440]
    ldr x9,[x29,#992]
    str x9,[sp,#448]
    ldr x9,[x29,#1000]
    str x9,[sp,#456]

    ldr x9,[sp,#112]
    ldr w10,[x9,#4]
    cbnz w10,.Ldomain
    ldr x9,[sp,#144]
    ldr w19,[x9]
    ldr x9,[sp,#152]
    ldr w20,[x9]
    ldr x9,[sp,#160]
    ldr w21,[x9]
    ldr x9,[sp,#168]
    ldr w22,[x9]
    ldr x9,[sp,#176]
    ldr w23,[x9]
    cmp w21,#1
    b.lt .Ldomain
    cmp w22,#1
    b.lt .Ldomain
    cmp w23,#2
    b.lt .Ldomain
    add w9,w22,#1
    cmp w23,w9
    b.gt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w20,w21
    b.gt .Ldomain
    cmp w19,w20
    b.gt .Lreturn
    uxtw x21,w21
    uxtw x22,w22
    mul x27,x21,x22
    mov x9,#60
    mul x10,x27,x9
    add x10,x10,x21,lsl #3
    add x10,x10,#31
    and x10,x10,#-16
    mov x9,#1048576
    cmp x10,x9
    b.hi .Ldomain
    sub sp,sp,x10
    mov x28,sp
    // Use x29 for the fixed frame while the reusable arena is below it.
    add x9,sp,#16
    str x9,[x29,#464]
    add x9,x9,x27,lsl #3
    str x9,[x29,#472]
    add x9,x9,x27,lsl #3
    str x9,[x29,#480]
    add x9,x9,x27,lsl #3
    str x9,[x29,#488]
    add x9,x9,x27,lsl #3
    str x9,[x29,#496]
    add x9,x9,x27,lsl #3
    str x9,[x29,#504]
    add x9,x9,x27,lsl #3
    str x9,[x29,#512]
    add x9,x9,x27,lsl #3
    str x9,[x29,#520]
    add x9,x9,x27,lsl #2
    str x9,[x29,#528]
    ldr x9,[x29,#128]
    ldr d0,[x9,#80]
    str d0,[x29,#560]
    fmov d1,#1.0
    fsub d1,d1,d0
    str d1,[x29,#536]
    ldr d0,[x9,#96]
    str d0,[x29,#568]
    ldr d0,[x9,#104]
    str d0,[x29,#576]
    ldr d0,[x9,#112]
    str d0,[x29,#584]
    ldr x9,[x29,#240]
    ldr d0,[x9]
    str d0,[x29,#592]
    fmov d1,#1.0
    fdiv d1,d1,d0
    str d1,[x29,#544]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    str d0,[x29,#600]
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d0,[x9]
    str d0,[x29,#608]
    adrp x9,:got:__yomcst_MOD_rlvtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d0,[x9]
    str d0,[x29,#616]
    adrp x9,:got:__yomcst_MOD_rlstt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rlstt]
    ldr d0,[x9]
    str d0,[x29,#624]
    adrp x9,:got:__yomcst_MOD_rlmlt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rlmlt]
    ldr d0,[x9]
    str d0,[x29,#632]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d0,[x9]
    str d0,[x29,#640]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d0,[x9]
    str d0,[x29,#648]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d0,[x9]
    str d0,[x29,#656]

    ldr d0,[x29,#608]
    fmov d1,#1.0
    fdiv d1,d1,d0
    str d1,[x29,#552]
    // Clear enthalpy diagnostics and optional detrained cloud water.
    ldr x9,[x29,#136]
    ldr w10,[x9,#68]
    ldr x9,[x29,#120]
    ldr w11,[x9,#52]
    ldr w12,[x9,#48]
    orr w10,w10,w11
    orr w10,w10,w12
    mov w17,w10
    mov x24,#0
.Linit_row:
    sub w25,w19,#1
.Linit_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#456]
    str xzr,[x9,x26,lsl #3]
    cbnz w17,.Linit_next
    ldr x9,[x29,#328]
    str xzr,[x9,x26,lsl #3]
    ldr x9,[x29,#336]
    str xzr,[x9,x26,lsl #3]
    add x10,x26,x27
    str xzr,[x9,x10,lsl #3]
.Linit_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Linit_col
    add x24,x24,#1
    cmp x24,x22
    b.lt .Linit_row
    // Retain complete source fluxes before changing implicit ones.
    mov x24,#0
.Lcopy_row:
    sub w25,w19,#1
.Lcopy_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#216]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Lcopy_next
    ldr x9,[x29,#248]
    ldr d0,[x9,x26,lsl #3]
    add x10,x26,x21
    ldr d1,[x9,x10,lsl #3]
    fsub d1,d1,d0
    ldr d0,[x29,#600]
    fdiv d0,d0,d1
    ldr x9,[x29,#496]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#368]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#464]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#376]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#472]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#384]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#480]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#392]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#488]
    str d0,[x9,x26,lsl #3]

.Lcopy_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Lcopy_col
    add x24,x24,#1
    cmp x24,x22
    b.lt .Lcopy_row
    ldr d0,[x29,#560]
    fcmp d0,#0.0
    b.le .Lintegral_setup
    sub w24,w23,#1
.Lflux_row:
    cmp x24,x22
    b.ge .Lintegral_setup
    sub w25,w19,#1
.Lflux_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#216]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Lflux_next
    ldr x9,[x29,#192]
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#2
    cmp w24,w10
    b.lt .Lflux_next
    sub x16,x26,x21
    ldr x9,[x29,#304]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#296]
    ldr d1,[x9,x16,lsl #3]
    ldr x9,[x29,#312]
    ldr d2,[x9,x26,lsl #3]
    fsub d0,d0,d1
    fdiv d16,d0,d2
    ldr x9,[x29,#280]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x9,x16,lsl #3]
    ldr d2,[x29,#608]
    fmul d3,d2,d0
    ldr x9,[x29,#272]
    ldr d4,[x9,x26,lsl #3]
    ldr d5,[x9,x16,lsl #3]
    fadd d17,d3,d4
    ldr x9,[x29,#288]
    ldr d3,[x9,x26,lsl #3]
    fsub d3,d3,d1
    fmul d3,d2,d3
    ldr x9,[x29,#264]
    ldr d6,[x9,x26,lsl #3]
    fadd d3,d3,d6
    fsub d3,d3,d5
    fdiv d18,d3,d17
    ldr d6,[x29,#536]
    fmul d1,d6,d1
    fmul d0,d18,d0
    fadd d0,d1,d0
    fmul d0,d2,d0
    fadd d0,d0,d5
    fmul d4,d18,d4
    fadd d17,d0,d4
    ldr x9,[x29,#296]
    ldr d0,[x9,x16,lsl #3]
    fmul d0,d6,d0
    ldr x9,[x29,#312]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d16,d1
    fadd d18,d0,d1
    ldr x9,[x29,#352]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#368]
    ldr d1,[x9,x26,lsl #3]
    fmul d2,d0,d17
    fsub d1,d1,d2
    ldr x9,[x29,#464]
    str d1,[x9,x26,lsl #3]
    ldr x9,[x29,#384]
    ldr d1,[x9,x26,lsl #3]
    fmul d2,d0,d18
    fsub d1,d1,d2
    ldr x9,[x29,#480]
    str d1,[x9,x26,lsl #3]
    ldr x9,[x29,#224]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Lflux_next
    ldr x9,[x29,#208]
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#1
    cmp w24,w10
    b.lt .Lflux_next
    ldr x9,[x29,#360]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#376]
    ldr d1,[x9,x26,lsl #3]
    fmul d2,d0,d17
    fsub d1,d1,d2
    ldr x9,[x29,#472]
    str d1,[x9,x26,lsl #3]
    ldr x9,[x29,#392]
    ldr d1,[x9,x26,lsl #3]
    fmul d2,d0,d18
    fsub d1,d1,d2
    ldr x9,[x29,#488]
    str d1,[x9,x26,lsl #3]
.Lflux_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Lflux_col
    add x24,x24,#1
    b .Lflux_row
.Lintegral_setup:
    sub w25,w19,#1
.Lintegral_col:
    fmov d20,xzr
    ldr x9,[x29,#128]
    ldr w10,[x9,#284]
    cbz w10,.Lsave_integral
    sub w24,w23,#1
.Lintegral_row:
    cmp x24,x22
    b.ge .Lnormalise_integral
    madd x26,x24,x21,x25
    ldr x9,[x29,#280]
    ldr d0,[x9,x26,lsl #3]
    bl .Llatent_heat
    fmov d17,d0
    fmov d16,d0
    ldr x9,[x29,#232]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Llat_integral_ready
    ldr d16,[x29,#616]
.Llat_integral_ready:
    ldr x9,[x29,#320]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#416]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#632]
    fmul d0,d1,d0
    fadd d20,d20,d0
    ldr x9,[x29,#400]
    ldr d0,[x9,x26,lsl #3]
    add x10,x24,#1
    cmp x10,x22
    b.eq .Lbottom_integral
    add x10,x26,x21
    ldr d1,[x9,x10,lsl #3]
    fsub d1,d1,d0
    fmul d1,d16,d1
    fsub d20,d20,d1
    b .Lprecip_integral
.Lbottom_integral:
    fmul d0,d16,d0
    fadd d20,d20,d0
.Lprecip_integral:
    ldr x9,[x29,#408]
    ldr d0,[x9,x26,lsl #3]
    fmul d0,d17,d0
    fadd d20,d20,d0
    add x24,x24,#1
    b .Lintegral_row
.Lnormalise_integral:
    madd x10,x22,x21,x25
    ldr x9,[x29,#424]
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x29,#616]
    fmul d0,d1,d0
    fsub d0,d20,d0
    ldr x9,[x29,#432]
    ldr d1,[x9,x10,lsl #3]
    ldr d2,[x29,#624]
    fmul d1,d2,d1
    fsub d0,d0,d1
    fabs d1,d20
    adr x9,.Lthreshold
    ldr d2,[x9]
    fcmp d1,d2
    b.le .Lzero_integral
    ldr d1,[x9,#8]
    fadd d1,d20,d1
    fdiv d20,d0,d1
    fabs d0,d20
    fmov d1,#2.0
    fcmp d0,d1
    b.le .Lsave_integral
.Lzero_integral:
    fmov d20,xzr
.Lsave_integral:
    ldr x9,[x29,#528]
    str d20,[x9,x25,lsl #3]
    add w25,w25,#1
    cmp w25,w20
    b.lt .Lintegral_col
    // Local heat and moisture sources retain the source expression order.
    sub w24,w23,#1
.Ltendency_row:
    cmp x24,x22
    b.ge .Lupdate
    sub w25,w19,#1
.Ltendency_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#216]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Ltendency_next
    ldr x9,[x29,#280]
    ldr d0,[x9,x26,lsl #3]
    bl .Llatent_heat
    fmov d17,d0
    fmov d16,d0
    ldr x9,[x29,#128]
    ldr w10,[x9,#284]
    cbz w10,.Llatent_ready
    ldr x9,[x29,#232]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Llatent_ready
    ldr d16,[x29,#616]
.Llatent_ready:
    ldr x9,[x29,#528]
    ldr d18,[x9,x25,lsl #3]
    fmov d0,#1.0
    fsub d18,d0,d18
    ldr x9,[x29,#496]
    ldr d19,[x9,x26,lsl #3]
    add x10,x24,#1
    cmp x10,x22
    b.eq .Lbottom_tendency
    add x16,x26,x21
    ldr x9,[x29,#320]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#416]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#632]
    fmul d0,d1,d0
    ldr x9,[x29,#400]
    ldr d1,[x9,x16,lsl #3]
    ldr d2,[x9,x26,lsl #3]
    fsub d1,d1,d2
    fmul d1,d16,d1
    fsub d0,d0,d1
    ldr x9,[x29,#408]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d17,d1
    fadd d0,d0,d1
    fmul d20,d0,d18
    ldr x9,[x29,#464]
    ldr d0,[x9,x16,lsl #3]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#472]
    ldr d1,[x9,x16,lsl #3]
    fadd d0,d0,d1
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    fadd d20,d0,d20
    ldr x9,[x29,#336]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#344]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d0,d1
    ldr d1,[x29,#616]
    fmul d0,d1,d0
    fadd d20,d20,d0
    add x10,x26,x27
    ldr x9,[x29,#336]
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#344]
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,[x29,#624]
    fmul d0,d1,d0
    fadd d20,d20,d0
    ldr d0,[x29,#552]
    fmul d0,d19,d0
    fmul d20,d0,d20
    ldr x9,[x29,#480]
    ldr d0,[x9,x16,lsl #3]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#488]
    ldr d1,[x9,x16,lsl #3]
    fadd d0,d0,d1
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#400]
    ldr d1,[x9,x16,lsl #3]
    fadd d0,d0,d1
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#328]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#408]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#344]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    add x10,x26,x27
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    fmul d21,d19,d0
    b .Lsave_tendency
.Lbottom_tendency:
    ldr x9,[x29,#416]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#320]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#632]
    fmul d0,d1,d0
    ldr x9,[x29,#400]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d16,d1
    fsub d0,d0,d1
    ldr x9,[x29,#408]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d17,d1
    fsub d0,d0,d1
    fmul d20,d0,d18
    ldr x9,[x29,#464]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#472]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d0,d1
    fadd d20,d0,d20
    fneg d0,d19
    ldr d1,[x29,#552]
    fmul d0,d0,d1
    fmul d20,d0,d20
    ldr x9,[x29,#480]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#488]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d0,d1
    ldr x9,[x29,#400]
    ldr d1,[x9,x26,lsl #3]
    ldr x9,[x29,#408]
    ldr d2,[x9,x26,lsl #3]
    fadd d1,d1,d2
    fadd d0,d0,d1
    fneg d1,d19
    fmul d21,d1,d0
.Lsave_tendency:
    ldr x9,[x29,#504]
    str d20,[x9,x26,lsl #3]
    ldr x9,[x29,#512]
    str d21,[x9,x26,lsl #3]
.Ltendency_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Ltendency_col
    add x24,x24,#1
    b .Ltendency_row
.Lupdate:
    ldr d0,[x29,#560]
    fcmp d0,#0.0
    b.ne .Limplicit
    sub w24,w23,#1
.Lexplicit_row:
    cmp x24,x22
    b.ge .Ldone
    sub w25,w19,#1
.Lexplicit_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#216]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Lexplicit_next
    ldr x9,[x29,#504]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#440]
    ldr d1,[x9,x26,lsl #3]
    fadd d1,d1,d0
    str d1,[x9,x26,lsl #3]
    ldr d1,[x29,#608]
    fmul d0,d0,d1
    ldr x9,[x29,#456]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#512]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#448]
    ldr d1,[x9,x26,lsl #3]
    fadd d1,d1,d0
    str d1,[x9,x26,lsl #3]
.Lexplicit_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Lexplicit_col
    add x24,x24,#1
    b .Lexplicit_row
.Limplicit:
    mov x26,#0
    fmov d0,#1.0
    ldr x9,[x29,#464]
    ldr x10,[x29,#472]
    ldr x11,[x29,#520]
.Limplicit_fill:
    str xzr,[x9,x26,lsl #3]
    str d0,[x10,x26,lsl #3]
    str wzr,[x11,x26,lsl #2]
    add x26,x26,#1
    cmp x26,x27
    b.lt .Limplicit_fill
    sub w24,w23,#1
.Lmatrix_row:
    cmp x24,x22
    b.ge .Lsolve
    sub w25,w19,#1
.Lmatrix_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#216]
    ldr w10,[x9,x25,lsl #2]
    cbz w10,.Lmatrix_next
    ldr x9,[x29,#192]
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#2
    cmp w24,w10
    b.lt .Lmatrix_next
    ldr x9,[x29,#520]
    mov w10,#1
    str w10,[x9,x26,lsl #2]
    ldr x9,[x29,#496]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x29,#560]
    fmul d0,d1,d0
    ldr d1,[x29,#592]
    fmul d16,d0,d1
    ldr x9,[x29,#352]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#360]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d0,d1
    fneg d1,d16
    fmul d0,d1,d0
    ldr x9,[x29,#464]
    str d0,[x9,x26,lsl #3]
    add x10,x24,#1
    cmp x10,x22
    b.eq .Ladvection
    add x16,x26,x21
    ldr x9,[x29,#352]
    ldr d0,[x9,x16,lsl #3]
    ldr x9,[x29,#360]
    ldr d1,[x9,x16,lsl #3]
    fadd d0,d0,d1
    fmul d0,d16,d0
    fmov d1,#1.0
    fadd d0,d1,d0
    ldr x9,[x29,#472]
    str d0,[x9,x26,lsl #3]
.Ladvection:
    sub x16,x26,x21
    ldr x9,[x29,#360]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x29,#584]
    fmul d0,d1,d0
    ldr x9,[x29,#352]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d1,d0
    ldr d1,[x29,#600]
    fmul d0,d1,d0
    ldr x9,[x29,#256]
    ldr d1,[x9,x26,lsl #3]
    ldr d2,[x9,x16,lsl #3]
    fsub d1,d1,d2
    fdiv d0,d0,d1
    ldr d1,[x29,#592]
    fmul d0,d0,d1
    ldr x9,[x29,#184]
    ldr w10,[x9,x25,lsl #2]
    fmov d1,xzr
    cmp w10,#1
    b.ne .Ladvection_factor
    ldr d1,[x29,#576]
.Ladvection_factor:
    fmul d16,d0,d1
    ldr x9,[x29,#280]
    ldr d0,[x9,x16,lsl #3]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#272]
    ldr d1,[x9,x16,lsl #3]
    ldr d2,[x9,x26,lsl #3]
    fsub d1,d1,d2
    ldr d2,[x29,#552]
    fmul d1,d2,d1
    fadd d0,d0,d1
    fmul d17,d16,d0
    ldr x9,[x29,#296]
    ldr d0,[x9,x16,lsl #3]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    fmul d18,d16,d0
    ldr x9,[x29,#440]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x29,#568]
    fmul d0,d0,d1
    ldr x9,[x29,#504]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d1,d0
    ldr d1,[x29,#592]
    fmul d0,d0,d1
    ldr x10,[x29,#280]
    ldr d1,[x10,x26,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d17
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#448]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x29,#568]
    fmul d0,d0,d1
    ldr x9,[x29,#512]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d1,d0
    ldr d1,[x29,#592]
    fmul d0,d0,d1
    ldr x10,[x29,#296]
    ldr d1,[x10,x26,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d18
    str d0,[x9,x26,lsl #3]
.Lmatrix_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Lmatrix_col
    add x24,x24,#1
    b .Lmatrix_row
.Lsolve:
    ldr x0,[x29,#144]
    ldr x1,[x29,#152]
    ldr x2,[x29,#160]
    ldr x3,[x29,#168]
    ldr x4,[x29,#192]
    ldr x5,[x29,#520]
    ldr x6,[x29,#464]
    ldr x7,[x29,#472]
    ldr x9,[x29,#504]
    str x9,[sp]
    ldr x9,[x29,#480]
    str x9,[sp,#8]
    bl md2asm_cudtdqn_bidiag
    ldr x0,[x29,#144]
    ldr x1,[x29,#152]
    ldr x2,[x29,#160]
    ldr x3,[x29,#168]
    ldr x4,[x29,#192]
    ldr x5,[x29,#520]
    ldr x6,[x29,#464]
    ldr x7,[x29,#472]
    ldr x9,[x29,#512]
    str x9,[sp]
    ldr x9,[x29,#488]
    str x9,[sp,#8]
    bl md2asm_cudtdqn_bidiag

    sub w24,w23,#1
.Lfinal_row:
    cmp x24,x22
    b.ge .Ldone
    sub w25,w19,#1
.Lfinal_col:
    madd x26,x24,x21,x25
    ldr x9,[x29,#520]
    ldr w10,[x9,x26,lsl #2]
    cbz w10,.Lfinal_next
    ldr x9,[x29,#480]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#280]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#544]
    fmul d0,d0,d1
    ldr x9,[x29,#456]
    str d0,[x9,x26,lsl #3]
    fmov d2,#1.0
    ldr d3,[x29,#568]
    fsub d2,d2,d3
    ldr x9,[x29,#440]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d1,d2
    fadd d0,d1,d0
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#488]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#296]
    ldr d1,[x9,x26,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#544]
    fmul d0,d0,d1
    ldr x9,[x29,#448]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d1,d2
    fadd d0,d1,d0
    str d0,[x9,x26,lsl #3]
.Lfinal_next:
    add w25,w25,#1
    cmp w25,w20
    b.lt .Lfinal_col
    add x24,x24,#1
    b .Lfinal_row
.Ldone:
    mov sp,x29
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#720
    ret
.Ldomain:
    brk #0x4c1
// FOELHMCU uses a separately rounded bounded quadratic liquid fraction.
.Llatent_heat:
    ldr d1,[x29,#648]
    fmin d0,d1,d0
    ldr d1,[x29,#640]
    fmax d0,d1,d0
    fsub d0,d0,d1
    ldr d1,[x29,#656]
    fmul d0,d0,d1
    fmul d0,d0,d0
    fmov d1,#1.0
    fmin d0,d1,d0
    fsub d1,d1,d0
    ldr d2,[x29,#616]
    fmul d0,d0,d2
    ldr d2,[x29,#624]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ret
.size CUDTDQN_SYMBOL,.-CUDTDQN_SYMBOL
.p2align 3
.Lthreshold:
    .double 0.1,0.001
.section .note.GNU-stack,"",%progbits

// Physics input formulations/openifs/physics/convective_saturation_adjustment.md.
// Contract skills/md2asm/references/openifs/physics/cuadjtq.md.
// Complete normal physics. Mode 3 reuses its unchanged direct environment child.
#ifndef CUADJTQ_SYMBOL
#define CUADJTQ_SYMBOL cuadjtq_
#endif
.text
.p2align 4
.global CUADJTQ_SYMBOL
.type CUADJTQ_SYMBOL,%function
CUADJTQ_SYMBOL:
    ldr w10,[x0,#4]
    cbnz w10,.Ldomain
    ldr x9,[sp,#16]
    ldr w9,[x9]
    cmp w9,#3
    b.eq md2asm_cuinin_environment
    cmp w9,#0
    b.lt .Lempty_return
    cmp w9,#6
    b.gt .Lempty_return
    ldr x10,[sp,#24]
    ldr x11,[sp,#8]
    cmp w9,#6
    b.ne .Loptional_ready
    cbz x10,.Ldomain
.Loptional_ready:
    sub sp,sp,#384
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str w9,[sp,#328]
    str x10,[sp,#336]
    str x11,[sp,#344]
    ldr w19,[x1]
    ldr w20,[x2]
    ldr w21,[x3]
    ldr w12,[x4]
    ldr w9,[x5]
    cmp w21,#1
    b.lt .Ldomain
    cmp w12,#1
    b.lt .Ldomain
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,w12
    b.gt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w20,w21
    b.gt .Ldomain
    sub w9,w9,#1
    uxtw x21,w21
    uxtw x9,w9
    mul x22,x21,x9
    mov x25,x6
    mov x24,x7
    ldr x23,[sp,#384]
    cmp w19,w20
    b.gt .Lreturn
    adrp x9,:got:__yomcst_MOD_rtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rtt]
    ldr d0,[x9]
    str d0,[sp,#112]
    adrp x9,:got:__yoethf_MOD_r2es
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r2es]
    ldr d0,[x9]
    str d0,[sp,#120]
    adrp x9,:got:__yoethf_MOD_r3les
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r3les]
    ldr d0,[x9]
    str d0,[sp,#128]
    adrp x9,:got:__yoethf_MOD_r3ies
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r3ies]
    ldr d0,[x9]
    str d0,[sp,#136]
    adrp x9,:got:__yoethf_MOD_r4les
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r4les]
    ldr d0,[x9]
    str d0,[sp,#144]
    adrp x9,:got:__yoethf_MOD_r4ies
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r4ies]
    ldr d0,[x9]
    str d0,[sp,#152]
    adrp x9,:got:__yoethf_MOD_r5alvcp
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r5alvcp]
    ldr d0,[x9]
    str d0,[sp,#160]
    adrp x9,:got:__yoethf_MOD_r5alscp
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r5alscp]
    ldr d0,[x9]
    str d0,[sp,#168]
    adrp x9,:got:__yoethf_MOD_ralvdcp
    ldr x9,[x9,:got_lo12:__yoethf_MOD_ralvdcp]
    ldr d0,[x9]
    str d0,[sp,#176]
    adrp x9,:got:__yoethf_MOD_ralsdcp
    ldr x9,[x9,:got_lo12:__yoethf_MOD_ralsdcp]
    ldr d0,[x9]
    str d0,[sp,#184]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d0,[x9]
    str d0,[sp,#192]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d0,[x9]
    str d0,[sp,#200]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d0,[x9]
    str d0,[sp,#208]
    adrp x9,:got:__yomcst_MOD_retv
    ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
    ldr d0,[x9]
    str d0,[sp,#216]
    adrp x9,:got:__yoethf_MOD_rtice
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtice]
    ldr d0,[x9]
    str d0,[sp,#312]
    adrp x9,:got:__yoethf_MOD_rtwat_rtice_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rtice_r]
    ldr d0,[x9]
    str d0,[sp,#320]

    ldr w9,[sp,#328]
    cmp w9,#0
    b.eq .Lstandard_phase
    cmp w9,#4
    b.eq .Lstandard_phase
    cmp w9,#5
    b.eq .Lstandard_phase
    ldr d0,[sp,#200]
    ldr d1,[sp,#208]
    b .Lphase_ready
.Lstandard_phase:
    ldr d0,[sp,#312]
    ldr d1,[sp,#320]
.Lphase_ready:
    str d0,[sp,#352]
    str d1,[sp,#360]
    sub w26,w19,#1
.Lcolumn:
    ldr w9,[sp,#328]
    cmp w9,#0
    b.eq .Lcolumn_enabled
    cmp w9,#5
    b.eq .Lcolumn_enabled
    ldr x10,[sp,#344]
    ldr w10,[x10,x26,lsl #2]
    cbz w10,.Lnext_column
.Lcolumn_enabled:
    str wzr,[sp,#368]
    cmp w9,#6
    b.ne .Lliquid_selection_ready
    ldr x10,[sp,#336]
    ldr w10,[x10,x26,lsl #2]
    str w10,[sp,#368]
.Lliquid_selection_ready:
    add x28,x22,x26
    ldr d0,[x24,x28,lsl #3]
    str d0,[sp,#224]
    ldr d0,[x23,x28,lsl #3]
    str d0,[sp,#232]
    ldr d0,[x25,x26,lsl #3]
    fmov d1,#1.0
    fdiv d0,d1,d0
    str d0,[sp,#248]
    mov w27,#2
.Lpass:
    ldr w9,[sp,#368]
    cbnz w9,.Lpure_fraction
    ldr d0,[sp,#224]
    ldr d1,[sp,#192]
    fmin d0,d1,d0
    ldr d1,[sp,#352]
    fmax d0,d1,d0
    fsub d0,d0,d1
    ldr d1,[sp,#360]
    fmul d0,d0,d1
    fmul d0,d0,d0
    fmov d1,#1.0
    fmin d0,d1,d0
    b .Lfraction_ready
.Lpure_fraction:
    fmov d0,#1.0
.Lfraction_ready:
    str d0,[sp,#240]
    ldr w9,[sp,#328]
    cmp w9,#1
    b.eq .Lreciprocal_exponential
    cmp w9,#6
    b.eq .Lreciprocal_exponential
    // Environment/evaporation retain product then denominator division.
    ldr d0,[sp,#224]
    ldr d1,[sp,#112]
    fsub d1,d0,d1
    ldr d2,[sp,#128]
    fmul d1,d2,d1
    ldr d2,[sp,#144]
    fsub d0,d0,d2
    fdiv d0,d1,d0
    bl exp
    str d0,[sp,#280]
    ldr d0,[sp,#224]
    ldr d1,[sp,#112]
    fsub d1,d0,d1
    ldr d2,[sp,#136]
    fmul d1,d2,d1
    ldr d2,[sp,#152]
    fsub d0,d0,d2
    fdiv d0,d1,d0
    bl exp
    b .Lmixed_exponential
.Lreciprocal_exponential:
    ldr d0,[sp,#224]
    ldr d1,[sp,#144]
    fsub d1,d0,d1
    fmov d2,#1.0
    fdiv d1,d2,d1
    str d1,[sp,#296]
    ldr d3,[sp,#112]
    fsub d0,d0,d3
    ldr d3,[sp,#128]
    fmul d0,d3,d0
    fmul d0,d0,d1
    bl exp
    str d0,[sp,#280]
    ldr w9,[sp,#368]
    cbnz w9,.Lpure_exponential
    ldr d0,[sp,#224]
    ldr d1,[sp,#152]
    fsub d1,d0,d1
    fmov d2,#1.0
    fdiv d1,d2,d1
    str d1,[sp,#304]
    ldr d3,[sp,#112]
    fsub d0,d0,d3
    ldr d3,[sp,#136]
    fmul d0,d3,d0
    fmul d0,d0,d1
    bl exp
.Lmixed_exponential:
    ldr d1,[sp,#240]
    fmov d2,#1.0
    fsub d2,d2,d1
    fmul d0,d2,d0
    ldr d2,[sp,#280]
    fmul d2,d1,d2
    fadd d0,d2,d0
    b .Lsaturation_pressure
.Lpure_exponential:
    ldr d0,[sp,#280]
.Lsaturation_pressure:
    ldr d1,[sp,#120]
    fmul d0,d1,d0
    ldr d1,[sp,#248]
    fmul d0,d0,d1
    ldr w9,[sp,#328]
    cmp w9,#1
    b.eq .Lcondensation_cap
    cmp w9,#6
    b.eq .Lcondensation_cap
    fmov d1,#0.5
    fmin d0,d1,d0
    ldr d1,[sp,#216]
    fmul d1,d1,d0
    fmov d2,#1.0
    fsub d1,d2,d1
    fdiv d1,d2,d1
    str d1,[sp,#264]
    fmul d0,d0,d1
    str d0,[sp,#256]
    // Denominator squares precede exact divisions in FOEDEM/FOEDEMCU.
    ldr d0,[sp,#224]
    ldr d1,[sp,#144]
    fsub d1,d0,d1
    fmul d1,d1,d1
    fmov d2,#1.0
    fdiv d1,d2,d1
    ldr d2,[sp,#240]
    ldr d3,[sp,#160]
    fmul d3,d2,d3
    fmul d3,d3,d1
    ldr d1,[sp,#152]
    fsub d1,d0,d1
    fmul d1,d1,d1
    fmov d0,#1.0
    fdiv d1,d0,d1
    fsub d2,d0,d2
    ldr d4,[sp,#168]
    fmul d2,d2,d4
    fmul d2,d2,d1
    fadd d3,d3,d2
    ldr d0,[sp,#256]
    ldr d1,[sp,#264]
    fmul d1,d0,d1
    fmul d1,d1,d3
    fmov d2,#1.0
    fadd d1,d2,d1
    ldr d2,[sp,#232]
    fsub d0,d2,d0
    fdiv d0,d0,d1
    cmp w9,#2
    b.ne .Lcorrection_ready
    cmp w27,#2
    b.eq .Lfirst_evaporation
    ldr d1,[sp,#288]
    fcmp d1,#0.0
    b.ne .Lcorrection_ready
.Lfirst_evaporation:
    fmov d1,xzr
    fmin d0,d0,d1
    b .Lcorrection_ready
.Lcondensation_cap:
    fmov d1,#0.5
    cmp w27,#2
    b.eq .Lfirst_condensation_cap
    // Preserve MINJ, including its cancellation rounding.
    fsub d1,d1,d0
    fabs d2,d1
    fsub d2,d2,d1
    fmov d1,#0.5
    fmul d2,d1,d2
    fsub d0,d0,d2
    b .Lraw_correction
.Lfirst_condensation_cap:
    fmin d0,d1,d0
.Lraw_correction:
    str d0,[sp,#256]
    ldr d1,[sp,#216]
    fmul d1,d1,d0
    fmov d2,#1.0
    fsub d1,d2,d1
    str d1,[sp,#264]
    // Condensation derivatives use separately rounded reciprocal squares.
    ldr d1,[sp,#296]
    fmul d1,d1,d1
    ldr d3,[sp,#160]
    ldr w10,[sp,#368]
    cbnz w10,.Lpure_derivative
    ldr d2,[sp,#240]
    fmul d3,d2,d3
    fmul d3,d3,d1
    ldr d1,[sp,#304]
    fmul d1,d1,d1
    fmov d0,#1.0
    fsub d2,d0,d2
    ldr d4,[sp,#168]
    fmul d2,d2,d4
    fmul d2,d2,d1
    fadd d3,d3,d2
    b .Lraw_numerator
.Lpure_derivative:
    fmul d3,d3,d1
.Lraw_numerator:
    ldr d0,[sp,#256]
    ldr d1,[sp,#264]
    fmul d2,d1,d1
    ldr d4,[sp,#232]
    fmul d4,d4,d2
    fmul d1,d0,d1
    fsub d4,d4,d1
    fmul d0,d0,d3
    fadd d0,d2,d0
    fdiv d0,d4,d0
    cmp w27,#2
    b.eq .Lfirst_condensation
    ldr d1,[sp,#288]
    fcmp d1,#0.0
    b.ne .Lcorrection_ready
    fmov d0,xzr
    b .Lcorrection_ready
.Lfirst_condensation:
    fmov d1,xzr
    fmaxnm d0,d0,d1
.Lcorrection_ready:
    cmp w27,#2
    b.ne .Lstore_heat_water
    str d0,[sp,#288]
.Lstore_heat_water:
    ldr w9,[sp,#368]
    cbnz w9,.Lpure_latent_heat
    ldr d1,[sp,#240]
    ldr d2,[sp,#176]
    fmul d2,d1,d2
    fmov d3,#1.0
    fsub d1,d3,d1
    ldr d3,[sp,#184]
    fmul d1,d1,d3
    fadd d1,d2,d1
    b .Llatent_heat_ready
.Lpure_latent_heat:
    ldr d1,[sp,#176]
.Llatent_heat_ready:
    fmul d1,d1,d0
    ldr d2,[sp,#224]
    fadd d1,d2,d1
    str d1,[sp,#224]
    ldr d1,[sp,#232]
    fsub d1,d1,d0
    str d1,[sp,#232]
    subs w27,w27,#1
    b.ne .Lpass
    ldr d0,[sp,#224]
    str d0,[x24,x28,lsl #3]
    ldr d0,[sp,#232]
    str d0,[x23,x28,lsl #3]
.Lnext_column:
    add w26,w26,#1
    cmp w26,w20
    b.lt .Lcolumn
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#384
.Lempty_return:
    ret
.Ldomain:
    brk #0x4c4
.size CUADJTQ_SYMBOL,.-CUADJTQ_SYMBOL
.section .note.GNU-stack,"",%progbits

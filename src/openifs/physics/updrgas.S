// Physics input formulations/openifs/physics/radiation_gas_forcing.md.
// Contract skills/md2asm/references/openifs/physics/updrgas.md.
// Five-address GNU parent ABI. The optional fifth address may be null.
#ifndef UPDRGAS_SYMBOL
#define UPDRGAS_SYMBOL updrgas_
#endif
#ifndef UPDRGAS_YEAR_SYMBOL
#define UPDRGAS_YEAR_SYMBOL md2asm_updrgas_get_year
#endif
#ifndef UPDRGAS_GHG
#define UPDRGAS_GHG md2asm_updrgas_ghg
#endif
#ifndef UPDRGAS_SOLAR
#define UPDRGAS_SOLAR md2asm_updrgas_solar
#endif
.text
.p2align 4
.global UPDRGAS_SYMBOL
.type UPDRGAS_SYMBOL,%function
UPDRGAS_SYMBOL:
    sub sp,sp,#256
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    str x23,[sp,#48]
    stp x29,x30,[sp,#64]
    mov x19,x2
    mov x20,x4
    mov x21,x1
    mov x22,x3
    mov x23,x0
    add x9,x22,#8,lsl #12
    ldr w9,[x9,#564]
    cmp w9,#0
    b.le .Lcurrent_year
    scvtf d0,w9
    fmov d1,#0.5
    fadd d0,d0,d1
    b .Lyear_ready
.Lcurrent_year:
    mov x0,x23
    mov x1,x22
    bl UPDRGAS_YEAR_SYMBOL
.Lyear_ready:
    str d0,[sp,#96]
#ifdef UPDRGAS_COUNT_YEAR
    adrp x9,:got:md2asm_updrgas_last_year_bits
    ldr x9,[x9,:got_lo12:md2asm_updrgas_last_year_bits]
    str d0,[x9]
#endif
    adrp x9,:got:__yomcst_MOD_rmd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmd]
    ldr d1,[x9]
    adrp x9,:got:__yomcst_MOD_rmco2
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmco2]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#168]
    adrp x9,:got:__yomcst_MOD_rmch4
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmch4]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#176]
    adrp x9,:got:__yomcst_MOD_rmn2o
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmn2o]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#184]
    adrp x9,:got:__yomcst_MOD_rmno2
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmno2]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#192]
    adrp x9,:got:__yomcst_MOD_rmcfc11
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmcfc11]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#200]
    adrp x9,:got:__yomcst_MOD_rmcfc12
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmcfc12]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#208]
    adrp x9,:got:__yomcst_MOD_rmhcfc22
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmhcfc22]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#216]
    adrp x9,:got:__yomcst_MOD_rmccl4
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmccl4]
    ldr d0,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#224]
    adrp x9,:got:__yomghgtimeseries_MOD_yghgtimeseries
    ldr x9,[x9,:got_lo12:__yomghgtimeseries_MOD_yghgtimeseries]
    ldr x9,[x9]
    cbz x9,.Lforcing_reject
    adrp x10,:got:__yomghgtimeseries_MOD___vtab_yomghgtimeseries_Tghgtimeseries
    ldr x10,[x10,:got_lo12:__yomghgtimeseries_MOD___vtab_yomghgtimeseries_Tghgtimeseries]
    stp x9,x10,[sp,#80]
    add x0,sp,#80
    add x1,sp,#96
    add x2,sp,#104
    add x3,sp,#112
    add x4,sp,#120
    add x5,sp,#128
    add x6,sp,#136
    add x7,sp,#144
    add x9,sp,#152
    str x9,[sp]
    bl UPDRGAS_GHG
    ldr d0,[sp,#104]
    ldr d1,[sp,#168]
    fmul d0,d0,d1
    str d0,[x19,#16]
    ldr d0,[sp,#112]
    ldr d1,[sp,#176]
    fmul d0,d0,d1
    str d0,[x19,#24]
    ldr d0,[sp,#120]
    ldr d1,[sp,#184]
    fmul d0,d0,d1
    str d0,[x19,#32]
    adrp x9,.Lnitrogen_dioxide
    ldr d0,[x9,:lo12:.Lnitrogen_dioxide]
    ldr d1,[sp,#192]
    fmul d0,d0,d1
    str d0,[x19,#40]
    ldr d0,[sp,#128]
    ldr d1,[sp,#200]
    fmul d0,d0,d1
    str d0,[x19,#64]
    ldr d0,[sp,#136]
    ldr d1,[sp,#208]
    fmul d0,d0,d1
    str d0,[x19,#72]
    ldr d0,[sp,#144]
    ldr d1,[sp,#216]
    fmul d0,d0,d1
    str d0,[x19,#80]
    ldr d0,[sp,#152]
    ldr d1,[sp,#224]
    fmul d0,d0,d1
    str d0,[x19,#56]
    cbz x20,.Lsolar_selection
    ldr d0,[x20]
    str d0,[x19,#168]
    b .Lforcing_return
.Lsolar_selection:
    ldr w9,[x21,#148]
    cbnz w9,.Lsolar_timeseries
    adrp x9,:got:__yomcst_MOD_ri0
    ldr x9,[x9,:got_lo12:__yomcst_MOD_ri0]
    ldr d0,[x9]
    str d0,[x19,#168]
    b .Lforcing_return
.Lsolar_timeseries:
    adrp x9,:got:__yomsolarirradiance_MOD_ysolarirradiance
    ldr x9,[x9,:got_lo12:__yomsolarirradiance_MOD_ysolarirradiance]
    ldr x9,[x9]
    cbz x9,.Lforcing_reject
    adrp x10,:got:__yomsolarirradiance_MOD___vtab_yomsolarirradiance_Tsolarirradiance
    ldr x10,[x10,:got_lo12:__yomsolarirradiance_MOD___vtab_yomsolarirradiance_Tsolarirradiance]
    stp x9,x10,[sp,#80]
    add x0,sp,#80
    add x1,sp,#96
    add x2,x19,#168
    bl UPDRGAS_SOLAR
.Lforcing_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldr x23,[sp,#48]
    ldp x29,x30,[sp,#64]
    add sp,sp,#256
    ret
.Lforcing_reject:
    brk #0x533
.size UPDRGAS_SYMBOL,.-UPDRGAS_SYMBOL

// Contained GET_YEAR uses x0 TDYNA and x1 TRIP, returning FP64 in d0.
.p2align 4
.global UPDRGAS_YEAR_SYMBOL
.type UPDRGAS_YEAR_SYMBOL,%function
UPDRGAS_YEAR_SYMBOL:
#ifdef UPDRGAS_COUNT_YEAR
    adrp x9,:got:md2asm_updrgas_year_calls
    ldr x9,[x9,:got_lo12:md2asm_updrgas_year_calls]
    ldr x10,[x9]
    add x10,x10,#1
    str x10,[x9]
#endif
    ldr w2,[x1,#16]
    adrp x9,:got:__yomct0_MOD_lnf
    ldr x9,[x9,:got_lo12:__yomct0_MOD_lnf]
    ldr w3,[x9]
    cbnz w3,.Lelapsed_days_ready
    cbnz w2,.Lelapsed_days_ready
    ldr d1,[x1,#200]
    frinta d2,d1
    fcvtzs w2,d2
    adrp x9,:got:__yomct2_MOD_nstar2
    ldr x9,[x9,:got_lo12:__yomct2_MOD_nstar2]
    ldr w3,[x9]
    ldr w4,[x0,#20]
    cbz w4,.Linteger_restart
    scvtf d2,w3
    fmov d3,#0.5
    fadd d2,d2,d3
    fmul d1,d1,d2
    frinta d1,d1
    fcvtzs w2,d1
    b .Lrestart_seconds_ready
.Linteger_restart:
    mul w2,w2,w3
.Lrestart_seconds_ready:
    adrp x9,:got:__yomcst_MOD_rday
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rday]
    ldr d1,[x9]
    frinta d1,d1
    fcvtzs w3,d1
    sdiv w2,w2,w3
.Lelapsed_days_ready:
    adrp x9,:got:__yomrip0_MOD_nindat
    ldr x9,[x9,:got_lo12:__yomrip0_MOD_nindat]
    ldr w3,[x9]
    mov w4,#100
    sdiv w5,w3,w4
    msub w6,w5,w4,w3
    sdiv w7,w5,w4
    msub w5,w7,w4,w5
    sub w5,w5,#1
    adrp x8,.Lmean_month_days
    add x8,x8,:lo12:.Lmean_month_days
    ldr d1,[x8,w5,uxtw #3]
    scvtf d0,w6
    fmov d2,#1.0
    fsub d0,d0,d2
    fadd d0,d0,d1
    scvtf d1,w2
    fadd d0,d0,d1
    adrp x8,.Lmean_year_days
    ldr d1,[x8,:lo12:.Lmean_year_days]
    fdiv d0,d0,d1
    scvtf d1,w7
    fadd d0,d1,d0
    ret
.size UPDRGAS_YEAR_SYMBOL,.-UPDRGAS_YEAR_SYMBOL

.section .rodata
.p2align 3
.Lnitrogen_dioxide:
    .double 5.0e-11
.Lmean_year_days:
    .double 365.25
.Lmean_month_days:
    .double 0.0,31.0,59.25,90.25,120.25,151.25
    .double 181.25,212.25,243.25,273.25,304.25,334.25
#ifdef UPDRGAS_COUNT_YEAR
.bss
.p2align 3
.global md2asm_updrgas_year_calls
.type md2asm_updrgas_year_calls,%object
md2asm_updrgas_year_calls:
    .zero 8
.size md2asm_updrgas_year_calls,8
.global md2asm_updrgas_last_year_bits
.type md2asm_updrgas_last_year_bits,%object
md2asm_updrgas_last_year_bits:
    .zero 8
.size md2asm_updrgas_last_year_bits,8
#endif
.section .note.GNU-stack,"",%progbits

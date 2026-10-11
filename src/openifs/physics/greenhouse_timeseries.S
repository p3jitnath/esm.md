// Physics input formulations/openifs/physics/greenhouse_timeseries.md.
// Contract skills/md2asm/references/openifs/physics/greenhouse_timeseries.md.
// Complete nine-address GNU Fortran lookup for strictly interior dates.
#ifndef GHG_TIMESERIES_SYMBOL
#define GHG_TIMESERIES_SYMBOL __yomghgtimeseries_MOD_get_ghg_concentrations
#endif
.text
.p2align 4
.global GHG_TIMESERIES_SYMBOL
.type GHG_TIMESERIES_SYMBOL,%function
GHG_TIMESERIES_SYMBOL:
    ldr x9,[x0]
    ldr w0,[x9,#512]
    cmp w0,#2
    b.lt .Lghg_reject
    ldr d0,[x1]
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    add x11,x11,x12
    add x10,x10,x11,lsl #3
    lsl x12,x12,#3
    ldr d1,[x10]
    fcmp d0,d1
    b.vs .Lghg_reject
    b.le .Lghg_reject
    sub w1,w0,#1
    smaddl x13,w1,w12,x10
    ldr d2,[x13]
    fcmp d0,d2
    b.vs .Lghg_reject
    b.ge .Lghg_reject
    mov w1,#1
.Lghg_scan:
    ldr d1,[x10]
    ldr d2,[x10,x12]
    fcmp d0,d1
    b.lt .Lghg_next
    fcmp d0,d2
    b.lt .Lghg_interpolate
.Lghg_next:
    add w1,w1,#1
    cmp w1,w0
    b.ge .Lghg_reject
    add x10,x10,x12
    b .Lghg_scan
.Lghg_interpolate:
    fsub d3,d0,d1
    fsub d2,d2,d1
    fdiv d3,d3,d2
    ldr x14,[x9,#64]
    ldr x15,[x9,#72]
    ldr x16,[x9,#104]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x2]
    ldr x14,[x9,#128]
    ldr x15,[x9,#136]
    ldr x16,[x9,#168]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x3]
    ldr x14,[x9,#192]
    ldr x15,[x9,#200]
    ldr x16,[x9,#232]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x4]
    ldr x14,[x9,#256]
    ldr x15,[x9,#264]
    ldr x16,[x9,#296]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x5]
    ldr x14,[x9,#320]
    ldr x15,[x9,#328]
    ldr x16,[x9,#360]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x6]
    ldr x14,[x9,#384]
    ldr x15,[x9,#392]
    ldr x16,[x9,#424]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x7]
    ldr x0,[sp]
    ldr x14,[x9,#448]
    ldr x15,[x9,#456]
    ldr x16,[x9,#488]
    uxtw x17,w1
    madd x15,x17,x16,x15
    add x14,x14,x15,lsl #3
    lsl x16,x16,#3
    ldr d4,[x14]
    ldr d5,[x14,x16]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x0]
    ret
.Lghg_reject:
    brk #0x532
.size GHG_TIMESERIES_SYMBOL,.-GHG_TIMESERIES_SYMBOL
.section .note.GNU-stack,"",%progbits

/* Complete canopy update from formulations/openifs/surface/canopy_water_interception.md.
 * ABI and frozen operations are in skills/md2asm/references/openifs/surface/canopy_water_interception.md.
 * Independent columns keep their water storage in a register between ordered stages. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfwl_mod_MOD_srfwl
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.global md2asm_canopy_water_interception
.type md2asm_canopy_water_interception,%function
.macro COLUMN offset,target
    ldr x9,[x29,#\offset]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    add \target,x10,x12,lsl #3
.endm
ORIGINAL_SYMBOL:
md2asm_canopy_water_interception:
    mov x16,sp
    sub sp,sp,#448
    stp x0,x1,[sp,#0]
    stp x2,x3,[sp,#16]
    stp x4,x5,[sp,#32]
    stp x6,x7,[sp,#48]
    ldp x9,x10,[x16,#0]
    stp x9,x10,[sp,#64]
    ldp x9,x10,[x16,#16]
    stp x9,x10,[sp,#80]
    ldp x9,x10,[x16,#32]
    stp x9,x10,[sp,#96]
    ldp x9,x10,[x16,#48]
    stp x9,x10,[sp,#112]
    ldp x9,x10,[x16,#64]
    stp x9,x10,[sp,#128]
    ldp x9,x10,[x16,#80]
    stp x9,x10,[sp,#144]
    ldp x9,x10,[x16,#96]
    stp x9,x10,[sp,#160]
    stp x19,x20,[sp,#192]
    stp x21,x22,[sp,#208]
    stp x23,x24,[sp,#224]
    stp x25,x26,[sp,#240]
    stp x27,x28,[sp,#256]
    stp x29,x30,[sp,#272]
    stp d8,d9,[sp,#288]
    stp d10,d11,[sp,#304]
    stp d12,d13,[sp,#320]
    stp d14,d15,[sp,#336]
    mov x29,sp
    ldr w19,[x0]
    sub x19,x19,#1
    ldr w20,[x1]
    ldr w21,[x2]
    ldr d9,[x3]
    fmov d1,#1.0
    fdiv d8,d1,d9
    adrp x9,.Ltiny
    ldr d10,[x9,:lo12:.Ltiny]
    ldr x9,[x29,#152]
    ldr d12,[x9,#200]
    fdiv d11,d1,d12
    ldr w10,[x9,#2392]
    str x10,[x29,#352]
    ldr x9,[x29,#160]
    ldr d13,[x9,#552]
    ldr x9,[x29,#168]
    ldp x10,x11,[x9,#48]
    cmp x11,x10
    b.lt .Lno_diag
    ldp x10,x11,[x9,#72]
    cmp x11,x10
    b.lt .Lno_diag
    mov x10,#1
    b .Ldiag_flag
.Lno_diag:
    mov x10,#0
.Ldiag_flag:
    str x10,[x29,#360]
.Lcolumn:
    cmp x19,x20
    b.hs .Lreturn
    fmov d3,xzr
    COLUMN 136,x23
    ldr x24,[x9,#64]
    lsl x24,x24,#3
    COLUMN 64,x25
    ldr x27,[x9,#64]
    lsl x27,x27,#3
    COLUMN 72,x26
    ldr x28,[x9,#64]
    lsl x28,x28,#3
    mov x22,#0
.Lzero_types:
    mul x14,x22,x24
    str d3,[x23,x14]
    add x22,x22,#1
    cmp x22,x21
    b.lo .Lzero_types
    COLUMN 104,x13
    str x13,[x29,#368]
    COLUMN 112,x13
    str x13,[x29,#376]
    COLUMN 120,x13
    str x13,[x29,#384]
    COLUMN 128,x13
    str x13,[x29,#392]
    COLUMN 32,x13
    ldr d14,[x13]
    ldr x9,[x29,#144]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    ldr w12,[x10,x12,lsl #2]
    cbz w12,.Lsea
    COLUMN 56,x13
    ldr d15,[x13]
    fsub d15,d15,d10
    fmin d0,d15,d14
    fmax d0,d0,d3
    fsub d1,d0,d14
    fmul d1,d1,d8
    fadd d1,d3,d1
    add x13,x23,x24,lsl #1
    str d1,[x13]
    ldr x9,[x29,#352]
    cbnz x9,.Lwet_evaporation
    fmov d0,d14
.Lwet_evaporation:
    add x14,x26,x28,lsl #1
    ldr d2,[x14]
    fcmp d2,d3
    b.ge .Ldew_start
    fmov d1,d0
    add x14,x25,x27,lsl #1
    ldr d4,[x14]
    fmul d4,d9,d4
    fmul d4,d4,d2
    fadd d0,d1,d4
    fmax d0,d0,d3
    fsub d2,d0,d1
    fmul d2,d2,d8
    ldr d4,[x13]
    fadd d4,d4,d2
    str d4,[x13]
.Ldew_start:
    mov x22,#0
.Ldew:
    cmp x22,#2
    b.eq .Ldew_liquid
    cmp x22,#3
    b.eq .Ldew_liquid
    cmp x22,#5
    b.eq .Ldew_liquid
    cmp x22,#6
    b.eq .Ldew_liquid
    cmp x22,#7
    b.eq .Ldew_liquid
    cmp x22,#9
    b.ne .Lnext_dew
.Ldew_liquid:
    mul x14,x22,x28
    ldr d2,[x26,x14]
    cmp x22,#6
    b.ne .Ldew_fraction
    COLUMN 96,x13
    ldr d4,[x13]
    fsub d2,d2,d4
.Ldew_fraction:
    mul x14,x22,x27
    ldr d4,[x25,x14]
    fmul d2,d4,d2
    fcmp d2,d3
    b.le .Lnext_dew
    fmov d1,d0
    fmul d2,d9,d2
    fsub d4,d15,d1
    fmin d2,d4,d2
    fadd d0,d1,d2
    fsub d2,d0,d1
    fmul d2,d2,d8
    mul x14,x22,x24
    ldr d4,[x23,x14]
    fadd d4,d4,d2
    str d4,[x23,x14]
.Lnext_dew:
    add x22,x22,#1
    cmp x22,x21
    b.lo .Ldew
    ldr x13,[x29,#376]
    ldr d1,[x13]
    fsub d2,d0,d14
    fmul d2,d2,d8
    fadd d1,d1,d2
    str d1,[x13]
    COLUMN 88,x13
    ldr d1,[x13]
    fcmp d1,d10
    b.le .Lno_large_rain
    COLUMN 40,x13
    ldr d2,[x13]
    COLUMN 48,x13
    ldr d4,[x13]
    fadd d2,d2,d4
    fmul d2,d1,d2
    fmul d2,d2,d13
    fmul d2,d9,d2
    fsub d4,d15,d0
    fmin d2,d4,d2
    fadd d0,d0,d2
    fmul d2,d2,d8
    fsub d1,d1,d2
    b .Llarge_rain_store
.Lno_large_rain:
    fmov d1,d3
.Llarge_rain_store:
    ldr x13,[x29,#392]
    str d1,[x13]
    COLUMN 80,x13
    ldr d1,[x13]
    fcmp d1,d10
    b.le .Lno_convective_rain
    fmul d2,d1,d12
    COLUMN 40,x13
    ldr d4,[x13]
    COLUMN 48,x13
    ldr d5,[x13]
    fadd d4,d4,d5
    fmul d2,d2,d4
    fmul d2,d2,d13
    fmul d2,d9,d2
    fsub d4,d15,d0
    fmin d2,d4,d2
    fmul d2,d2,d11
    fadd d0,d0,d2
    fmul d2,d2,d8
    fsub d1,d1,d2
    b .Lconvective_rain_store
.Lno_convective_rain:
    fmov d1,d3
.Lconvective_rain_store:
    ldr x13,[x29,#384]
    str d1,[x13]
    ldr x13,[x29,#368]
    str d0,[x13]
    b .Ldiagnostics
.Lsea:
    ldr x13,[x29,#368]
    str d3,[x13]
    ldr x13,[x29,#376]
    str d3,[x13]
    COLUMN 80,x13
    ldr d0,[x13]
    ldr x13,[x29,#384]
    str d0,[x13]
    COLUMN 88,x13
    ldr d0,[x13]
    ldr x13,[x29,#392]
    str d0,[x13]
.Ldiagnostics:
    ldr x9,[x29,#360]
    cbz x9,.Lnext_column
    COLUMN 168,x15
    ldr x16,[x9,#64]
    lsl x16,x16,#3
    str d14,[x15]
    COLUMN 88,x13
    ldr d0,[x13]
    ldr x13,[x29,#392]
    ldr d1,[x13]
    fsub d0,d0,d1
    str d0,[x15,x16]
    COLUMN 80,x13
    ldr d0,[x13]
    ldr x13,[x29,#384]
    ldr d1,[x13]
    fsub d0,d0,d1
    add x14,x15,x16,lsl #1
    str d0,[x14]
    add x13,x23,x24,lsl #1
    ldr d0,[x13]
    add x13,x13,x24
    ldr d1,[x13]
    fadd d0,d0,d1
    add x13,x13,x24,lsl #1
    ldr d1,[x13]
    fadd d0,d0,d1
    add x13,x13,x24
    ldr d1,[x13]
    fadd d0,d0,d1
    add x13,x13,x24
    ldr d1,[x13]
    fadd d0,d0,d1
    add x14,x14,x16
    str d0,[x14]
.Lnext_column:
    add x19,x19,#1
    b .Lcolumn
.Lreturn:
    ldp x19,x20,[sp,#192]
    ldp x21,x22,[sp,#208]
    ldp x23,x24,[sp,#224]
    ldp x25,x26,[sp,#240]
    ldp x27,x28,[sp,#256]
    ldp x29,x30,[sp,#272]
    ldp d8,d9,[sp,#288]
    ldp d10,d11,[sp,#304]
    ldp d12,d13,[sp,#320]
    ldp d14,d15,[sp,#336]
    add sp,sp,#448
    ret
.size md2asm_canopy_water_interception,.-md2asm_canopy_water_interception
.section .rodata
.p2align 3
.Ltiny:
    .quad 0x0044000000000000
.section .note.GNU-stack,"",%progbits

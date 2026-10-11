/* Snow ageing and snowfall P01 and P02.
 * Physics formulations/openifs/surface/snow_albedo.md.
 * Contract skills/md2asm/references/openifs/surface/snow_albedo.md.
 * Twelve addresses and independent signed GNU descriptor strides.
 * x19 column, x20 exclusive end, x21..x25 mask/old/melt/snow/output.
 * x26 soil, x27 constants, x28 time step, x29 fixed frame.
 * Preserve x18, x19..x29, d8..d15, aligned SP and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfsn_asn_mod_MOD_srfsn_asn
#endif
.text
.p2align 4
.macro STRIDE slot,desc,shift
    ldr x11,[x\desc,#40]
    cmp x11,#0
    mov x9,#1
    csel x11,x11,x9,ne
    lsl x11,x11,#\shift
    str x11,[sp,#\slot]
.endm
.macro REAL reg,base,slot
    ldr x9,[sp,#\slot]
    mul x9,x19,x9
    ldr d\reg,[x\base,x9]
.endm
.global md2asm_snow_albedo
.type md2asm_snow_albedo,%function
md2asm_snow_albedo:
    mov x16,sp
    sub sp,sp,#192
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x29,sp
    ldr w19,[x0]
    sub x19,x19,#1
    ldr w20,[x1]
    mov x28,x3
    ldr x21,[x4]
    ldr x22,[x5]
    ldr x23,[x6]
    ldr x26,[x16,#8]
    ldr x27,[x16,#16]
    ldr x10,[x16,#24]
    ldr x25,[x10]
    STRIDE 96,4,2
    STRIDE 104,5,3
    STRIDE 112,6,3
    STRIDE 128,10,3
    ldr x9,[x16,#0]
    ldr x24,[x9]
    STRIDE 120,9,3
    str wzr,[sp,#136]
    cmp x19,x20
    b.ge .Lreturn
.Lcolumn:
    ldr x9,[sp,#96]
    mul x9,x19,x9
    ldr w9,[x21,x9]
    cbz w9,.Lsnow
    ldr d0,[x26,#336]
    b .Lstore
.Lsnow:
    REAL 0,23,112
    fcmp d0,#0.0
    b.le .Lordinary
    REAL 1,22,104
    ldr d2,[x26,#320]
    fsub d1,d1,d2
    str d1,[sp,#160]
    ldr w9,[sp,#136]
    tbnz w9,#0,.Lmelting_cached
    ldr d0,[x26,#368]
    fneg d0,d0
    ldr d1,[x28]
    fmul d0,d0,d1
    ldr d1,[x27,#16]
    fdiv d0,d0,d1
    bl exp
    str d0,[sp,#144]
    ldr w9,[sp,#136]
    orr w9,w9,#1
    str w9,[sp,#136]
    b .Lmelting_update
.Lmelting_cached:
    ldr d0,[sp,#144]
.Lmelting_update:
    ldr d1,[sp,#160]
    fmul d0,d1,d0
    ldr d2,[x26,#320]
    fadd d0,d0,d2
    b .Lfresh_snow
.Lordinary:
    ldr w9,[sp,#136]
    tbnz w9,#1,.Lordinary_cached
    ldr d0,[x26,#376]
    ldr d1,[x28]
    fmul d0,d0,d1
    ldr d1,[x27,#16]
    fdiv d0,d0,d1
    str d0,[sp,#152]
    orr w9,w9,#2
    str w9,[sp,#136]
    b .Lordinary_update
.Lordinary_cached:
    ldr d0,[sp,#152]
.Lordinary_update:
    REAL 1,22,104
    fsub d0,d1,d0
    ldr d2,[x26,#320]
    fmax d0,d2,d0
.Lfresh_snow:
    REAL 1,24,120
    ldr d2,[x28]
    fmul d1,d1,d2
    fmov d2,xzr
    fmax d1,d1,d2
    fmov d2,#10.0
    fdiv d1,d1,d2
    fmov d2,#1.0
    fmin d1,d1,d2
    ldr d2,[x26,#336]
    fsub d3,d2,d0
    fmul d1,d1,d3
    fadd d0,d0,d1
    ldr d3,[x26,#320]
    fmax d0,d0,d3
    fmin d0,d2,d0
.Lstore:
    ldr x9,[sp,#128]
    mul x9,x19,x9
    str d0,[x25,x9]
    add x19,x19,#1
    cmp x19,x20
    b.lt .Lcolumn
.Lreturn:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#192
    ret
.size md2asm_snow_albedo,.-md2asm_snow_albedo
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    b md2asm_snow_albedo
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

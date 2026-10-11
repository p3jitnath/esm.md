/* Complete sea ice update from formulations/openifs/surface/sea_ice_temperature.md.
 * ABI and physics limits are in skills/md2asm/references/openifs/surface/sea_ice_temperature.md.
 * The unchanged accepted diffusion body solves each independent ice column. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfi_mod_MOD_srfi
#endif
#ifndef DIFFUSION_SYMBOL
#define DIFFUSION_SYMBOL md2asm_soil_column_diffusion
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.global md2asm_sea_ice_temperature
.type md2asm_sea_ice_temperature,%function
.macro COLUMN offset,target
    ldr x9,[x29,#\offset]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    add \target,x10,x12,lsl #3
.endm
/* Construct a one-column FP64 view with a complete layer extent. */
.macro LAYER_VIEW offset,base
    add x15,x29,#\offset
    stp xzr,xzr,[x15]
    stp xzr,xzr,[x15,#16]
    stp xzr,xzr,[x15,#32]
    stp xzr,xzr,[x15,#48]
    stp xzr,xzr,[x15,#64]
    str xzr,[x15,#80]
    str \base,[x15]
    mov x9,#8
    str x9,[x15,#16]
    str x9,[x15,#32]
    mov w9,#2
    strb w9,[x15,#28]
    mov w9,#3
    strb w9,[x15,#29]
    mov x9,#1
    str x9,[x15,#40]
    str x9,[x15,#48]
    str x9,[x15,#56]
    str x9,[x15,#64]
    str x9,[x15,#72]
    str x21,[x15,#80]
.endm
ORIGINAL_SYMBOL:
md2asm_sea_ice_temperature:
    mov x16,sp
    sub sp,sp,#1024
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
    stp x19,x20,[sp,#160]
    stp x21,x22,[sp,#176]
    stp x23,x24,[sp,#192]
    stp x25,x26,[sp,#208]
    stp x27,x28,[sp,#224]
    stp x29,x30,[sp,#240]
    stp d8,d9,[sp,#256]
    stp d10,d11,[sp,#272]
    stp d12,d13,[sp,#288]
    stp d14,d15,[sp,#304]
    mov x29,sp
    ldr w19,[x0]
    sub x19,x19,#1
    ldr w20,[x1]
    ldr w21,[x3]
    ldr w9,[x4]
    str x9,[x29,#928]
    ldr d9,[x5]
    fmov d1,#1.0
    fdiv d10,d1,d9
    ldr x9,[x29,#120]
    ldr d8,[x9,#144]
    fmul d11,d9,d8
    fmov d2,#2.0
    fmul d11,d11,d2
    fdiv d12,d1,d8
    fsub d12,d1,d12
    ldr d13,[x9,#424]
    ldr d14,[x9,#272]
    ldr d15,[x9,#240]
    ldr d0,[x9,#248]
    str d0,[x29,#840]
    ldp d0,d1,[x9,#256]
    str d0,[x29,#848]
    str d1,[x29,#856]
    ldr x9,[x29,#112]
    ldr d0,[x9,#56]
    str d0,[x29,#832]
    mov x9,#40
    mul x9,x21,x9
    add x9,x9,#47
    and x9,x9,#-16
    sub sp,sp,x9
    add x24,sp,#32
    add x25,x24,x21,lsl #3
    add x26,x25,x21,lsl #3
    add x27,x26,x21,lsl #3
    add x28,x27,x21,lsl #3
    mov x9,#1
    str w9,[x29,#824]
    LAYER_VIEW 320,xzr
    LAYER_VIEW 408,x25
    LAYER_VIEW 496,x26
    LAYER_VIEW 584,x27
    LAYER_VIEW 672,x28
    add x15,x29,#760
    stp xzr,xzr,[x15]
    stp xzr,xzr,[x15,#16]
    stp xzr,xzr,[x15,#32]
    stp xzr,xzr,[x15,#48]
    add x9,x29,#824
    str x9,[x15]
    mov x9,#4
    str x9,[x15,#16]
    str x9,[x15,#32]
    mov w9,#1
    strb w9,[x15,#28]
    mov w9,#4
    strb w9,[x15,#29]
    mov x9,#1
    str x9,[x15,#40]
    str x9,[x15,#48]
    str x9,[x15,#56]
    ldr x9,[x29,#136]
    ldp x10,x11,[x9,#48]
    cmp x11,x10
    b.lt .Lno_diagnostic
    ldp x10,x11,[x9,#72]
    cmp x11,x10
    b.lt .Lno_diagnostic
    ldp x10,x11,[x9,#96]
    cmp x11,x10
    b.lt .Lno_diagnostic
    mov x10,#1
    b .Ldiagnostic_flag
.Lno_diagnostic:
    mov x10,#0
.Ldiagnostic_flag:
    str x10,[x29,#864]
.Lcolumn:
    cmp x19,x20
    b.hs .Lreturn
    COLUMN 128,x13
    str x13,[x29,#880]
    ldr x9,[x29,#864]
    cbz x9,.Lmask
    COLUMN 136,x13
    str x13,[x29,#888]
    ldr x10,[x9,#64]
    lsl x10,x10,#3
    str x10,[x29,#896]
    ldr x10,[x9,#88]
    lsl x10,x10,#3
    str x10,[x29,#904]
.Lmask:
    ldr x9,[x29,#96]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    ldr w12,[x10,x12,lsl #2]
    cbz w12,.Lnonice
    ldr x9,[x29,#120]
    ldr x10,[x9,#1712]
    ldr x11,[x9,#1720]
    add x11,x11,#1
    add x10,x10,x11,lsl #3
    mov x22,#0
    sub x23,x21,#1
.Lupper_thickness:
    ldr d0,[x10,x22,lsl #3]
    str d0,[x24,x22,lsl #3]
    add x22,x22,#1
    cmp x22,x23
    b.lo .Lupper_thickness
    ldp d0,d1,[x24]
    fadd d0,d0,d1
    ldr d1,[x24,#16]
    fadd d0,d0,d1
    ldr x9,[x29,#104]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    ldr w12,[x10,x12,lsl #2]
    cbz w12,.Lsouthern
    ldr d1,[x29,#848]
    b .Lbottom_thickness
.Lsouthern:
    ldr d1,[x29,#856]
.Lbottom_thickness:
    fsub d0,d1,d0
    str d0,[x24,x23,lsl #3]
    COLUMN 88,x13
    ldr x10,[x9,#64]
    ldr d0,[x13,x10,lsl #3]
    COLUMN 80,x13
    ldr d1,[x13]
    fadd d0,d0,d1
    COLUMN 64,x13
    ldr x10,[x9,#64]
    ldr d1,[x13,x10,lsl #3]
    COLUMN 72,x13
    ldr x10,[x9,#64]
    ldr d2,[x13,x10,lsl #3]
    ldr d3,[x29,#832]
    fmul d2,d3,d2
    fadd d1,d1,d2
    fadd d0,d0,d1
    str d0,[x29,#912]
    mov x22,#0
.Lcoefficients:
    ldr d0,[x24,x22,lsl #3]
    fmul d1,d13,d0
    str d1,[x27,x22,lsl #3]
    fmul d2,d11,d14
    cmp x22,x23
    b.eq .Lbottom_coefficient
    add x9,x22,#1
    ldr d3,[x24,x9,lsl #3]
    fadd d0,d0,d3
    fdiv d2,d2,d0
    str d2,[x25,x22,lsl #3]
    fmov d3,xzr
    cbnz x22,.Lrhs_store
    ldr d3,[x29,#912]
    fmul d3,d9,d3
    fdiv d3,d3,d1
    b .Lrhs_store
.Lbottom_coefficient:
    fmov d3,#2.0
    fmul d0,d3,d0
    fdiv d2,d2,d0
    str d2,[x25,x22,lsl #3]
    fdiv d3,d15,d8
    fmul d3,d3,d2
    fdiv d3,d3,d1
.Lrhs_store:
    str d3,[x26,x22,lsl #3]
    add x22,x22,#1
    cmp x22,x21
    b.lo .Lcoefficients
    COLUMN 48,x13
    str x13,[x29,#320]
    ldr x10,[x9,#64]
    str x10,[x29,#384]
    add x0,x29,#824
    mov x1,x0
    mov x2,x0
    ldr x3,[x29,#24]
    add x4,x29,#320
    add x5,x29,#408
    add x6,x29,#496
    add x7,x29,#584
    ldr x9,[x29,#120]
    str x9,[sp]
    add x9,x29,#672
    str x9,[sp,#8]
    add x9,x29,#760
    str x9,[sp,#16]
    bl DIFFUSION_SYMBOL
    ldr x9,[x29,#864]
    cbz x9,.Lrecover
    mov x22,#0
.Lice_diagnostic:
    ldr x9,[x29,#888]
    ldr x10,[x29,#896]
    mul x11,x22,x10
    add x13,x9,x11
    ldr x14,[x29,#904]
    ldr d0,[x27,x22,lsl #3]
    str d0,[x13]
    ldr x9,[x29,#320]
    ldr x10,[x29,#384]
    mul x11,x22,x10
    ldr d1,[x9,x11,lsl #3]
    add x13,x13,x14
    str d1,[x13]
    fmul d2,d0,d1
    add x13,x13,x14
    str d2,[x13]
    ldr d0,[x24,x22,lsl #3]
    add x13,x13,x14
    str d0,[x13]
    ldr x9,[x29,#888]
    ldr x10,[x29,#896]
    mul x11,x22,x10
    add x15,x9,x11
    mov x9,#8
    madd x15,x9,x14,x15
    fmov d0,xzr
    fmov d1,xzr
    cbnz x22,.Lsurface_diagnostic_store
    COLUMN 56,x13
    ldr x10,[x9,#64]
    ldr d2,[x13,x10,lsl #3]
    COLUMN 64,x13
    ldr x10,[x9,#64]
    ldr d3,[x13,x10,lsl #3]
    fmul d0,d2,d3
    COLUMN 72,x13
    ldr x10,[x9,#64]
    ldr d3,[x13,x10,lsl #3]
    ldr d4,[x29,#832]
    fmul d1,d4,d2
    fmul d1,d1,d3
.Lsurface_diagnostic_store:
    str d0,[x15]
    str d1,[x15,x14]
    add x15,x15,x14,lsl #1
    ldr x9,[x29,#928]
    sub x10,x9,#1
    cmp x22,x10
    b.hs .Lzero_phase_diagnostic
    add x9,x22,#1
    ldr d0,[x28,x22,lsl #3]
    ldr d1,[x28,x9,lsl #3]
    fsub d0,d0,d1
    fmul d0,d8,d0
    ldr d1,[x25,x22,lsl #3]
    fmul d0,d0,d1
    fmul d0,d0,d10
    str d0,[x15]
.Lzero_phase_diagnostic:
    add x15,x15,x14
    fmov d0,xzr
    str d0,[x15]
    str d0,[x15,x14]
    add x22,x22,#1
    ldr x9,[x29,#928]
    cmp x22,x9
    b.lo .Lice_diagnostic
    sub x9,x21,#1
    ldr d0,[x28,x9,lsl #3]
    fsub d0,d0,d15
    fmul d0,d8,d0
    ldr x10,[x29,#928]
    sub x10,x10,#1
    ldr d1,[x25,x10,lsl #3]
    fmul d0,d0,d1
    fmul d0,d0,d10
    ldr x13,[x29,#888]
    ldr x10,[x29,#896]
    mul x11,x9,x10
    add x13,x13,x11
    ldr x14,[x29,#904]
    mov x9,#10
    madd x13,x9,x14,x13
    str d0,[x13]
.Lrecover:
    ldr x9,[x29,#48]
    ldr x23,[x9,#64]
    lsl x23,x23,#3
    ldr x13,[x29,#320]
    ldr x9,[x29,#128]
    ldr x16,[x9,#64]
    lsl x16,x16,#3
    ldr x15,[x29,#880]
    ldr d2,[x29,#840]
    mov x22,#0
.Ltemperature:
    mul x10,x22,x23
    ldr d0,[x13,x10]
    fmul d0,d0,d12
    ldr d1,[x28,x22,lsl #3]
    fadd d0,d0,d1
    fmin d0,d0,d2
    mul x10,x22,x16
    str d0,[x15,x10]
    add x22,x22,#1
    cmp x22,x21
    b.lo .Ltemperature
    b .Lnext_column
.Lnonice:
    ldr x9,[x29,#864]
    cbz x9,.Lnonice_temperature
    mov x22,#0
    fmov d0,xzr
.Lnonice_diagnostic:
    ldr x13,[x29,#888]
    ldr x10,[x29,#896]
    mul x11,x22,x10
    add x13,x13,x11
    ldr x14,[x29,#904]
    str d0,[x13]
    str d0,[x13,x14]
    add x13,x13,x14,lsl #1
    str d0,[x13]
    str d0,[x13,x14]
    mov x9,#6
    madd x13,x9,x14,x13
    str d0,[x13]
    str d0,[x13,x14]
    add x13,x13,x14,lsl #1
    ldr x9,[x29,#928]
    sub x10,x9,#1
    cmp x22,x10
    b.hs .Lnonice_phase
    str d0,[x13]
.Lnonice_phase:
    add x13,x13,x14
    str d0,[x13]
    str d0,[x13,x14]
    add x22,x22,#1
    ldr x9,[x29,#928]
    cmp x22,x9
    b.lo .Lnonice_diagnostic
    ldr x13,[x29,#888]
    ldr x10,[x29,#896]
    sub x9,x21,#1
    mul x11,x9,x10
    add x13,x13,x11
    ldr x14,[x29,#904]
    mov x9,#10
    madd x13,x9,x14,x13
    str d0,[x13]
.Lnonice_temperature:
    ldr d2,[x29,#840]
    fmin d0,d15,d2
    ldr x9,[x29,#128]
    ldr x16,[x9,#64]
    lsl x16,x16,#3
    ldr x15,[x29,#880]
    mov x22,#0
.Lfixed_temperature:
    mul x10,x22,x16
    str d0,[x15,x10]
    add x22,x22,#1
    cmp x22,x21
    b.lo .Lfixed_temperature
.Lnext_column:
    add x19,x19,#1
    b .Lcolumn
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#160]
    ldp x21,x22,[sp,#176]
    ldp x23,x24,[sp,#192]
    ldp x25,x26,[sp,#208]
    ldp x27,x28,[sp,#224]
    ldp x29,x30,[sp,#240]
    ldp d8,d9,[sp,#256]
    ldp d10,d11,[sp,#272]
    ldp d12,d13,[sp,#288]
    ldp d14,d15,[sp,#304]
    add sp,sp,#1024
    ret
.size md2asm_sea_ice_temperature,.-md2asm_sea_ice_temperature
.section .note.GNU-stack,"",%progbits

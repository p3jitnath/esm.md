/* Complete soil water correction from formulations/openifs/surface/soil_water_correction.md.
 * The ordered interface is skills/md2asm/references/openifs/surface/soil_water_correction.md.
 * Thickness reciprocals are formed once and reused across independent columns. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfwng_mod_MOD_srfwng
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.global md2asm_soil_water_correction
.type md2asm_soil_water_correction,%function
/* Find one column in the descriptor saved at a fixed-frame byte offset. */
.macro COLUMN offset,target
    ldr x9,[x29,#\offset]
    ldr x10,[x9,#0]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    add \target,x10,x12,lsl #3
.endm
ORIGINAL_SYMBOL:
md2asm_soil_water_correction:
    mov x16,sp
    sub sp,sp,#384
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
    stp x19,x20,[sp,#128]
    stp x21,x22,[sp,#144]
    stp x23,x24,[sp,#160]
    stp x25,x26,[sp,#176]
    stp x27,x28,[sp,#192]
    stp x29,x30,[sp,#208]
    stp d8,d9,[sp,#224]
    stp d10,d11,[sp,#240]
    stp d12,d13,[sp,#256]
    stp d14,d15,[sp,#272]
    mov x29,sp
    ldr w19,[x0]
    sub x19,x19,#1
    ldr w20,[x1]
    ldr w21,[x2]
    ldr d0,[x3]
    fmov d1,#1.0
    fdiv d10,d1,d0
    adrp x9,:got:__yos_thf_MOD_rhoh2o
    ldr x9,[x9,:got_lo12:__yos_thf_MOD_rhoh2o]
    ldr d8,[x9]
    fdiv d9,d1,d8
    ldr x23,[x29,#64]
    sub sp,sp,x21,lsl #4
    mov x28,sp
    add x27,x28,x21,lsl #3
    ldr x9,[x23,#1648]
    ldr x10,[x23,#1656]
    add x10,x10,#1
    add x9,x9,x10,lsl #3
    mov x22,#0
.Lthickness:
    ldr d0,[x9,x22,lsl #3]
    str d0,[x28,x22,lsl #3]
    fdiv d2,d1,d0
    str d2,[x27,x22,lsl #3]
    add x22,x22,#1
    cmp x22,x21
    b.lo .Lthickness
    ldr x9,[x29,#104]
    ldp x10,x11,[x9,#48]
    cmp x11,x10
    b.lt .Lno_diagnostics
    ldp x10,x11,[x9,#72]
    cmp x11,x10
    b.lt .Lno_diagnostics
    ldp x10,x11,[x9,#96]
    cmp x11,x10
    b.lt .Lno_diagnostics
    mov x9,#1
    b .Ldiagnostic_flag
.Lno_diagnostics:
    mov x9,#0
.Ldiagnostic_flag:
    str x9,[x29,#304]
.Lcolumn:
    cmp x19,x20
    b.hs .Lreturn
    fmov d5,xzr
    COLUMN 80,x13
    str d5,[x13]
    ldr x9,[x29,#96]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    ldr w12,[x10,x12,lsl #2]
    cbnz w12,.Lland
    COLUMN 88,x13
    str d5,[x13]
    b .Lnext_column
.Lland:
    ldr w9,[x23,#440]
    cbz w9,.Lshared_saturation
    ldr x9,[x29,#32]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    cmp x11,#0
    csinc x11,x11,xzr,ne
    mul x12,x19,x11
    ldr w12,[x10,x12,lsl #2]
    ldr x9,[x23,#880]
    ldr x10,[x23,#888]
    add x10,x10,x12
    ldr d11,[x9,x10,lsl #3]
    b .Lsaturation_ready
.Lshared_saturation:
    ldr d11,[x23,#120]
.Lsaturation_ready:
    COLUMN 56,x24
    ldr x26,[x9,#64]
    lsl x26,x26,#3
    ldr x9,[x29,#304]
    cbz x9,.Llayer_start
    COLUMN 104,x25
    ldr x10,[x9,#88]
    mov x11,#5
    mul x10,x10,x11
    add x25,x25,x10,lsl #3
    ldr x10,[x9,#64]
    lsl x10,x10,#3
    str x10,[x29,#312]
.Llayer_start:
    mov x22,#0
.Llayer:
    ldr d12,[x28,x22,lsl #3]
    ldr d13,[x27,x22,lsl #3]
    mul x14,x22,x26
    ldr d0,[x24,x14]
    cbnz x22,.Lnegative
    fmov d14,d0
    COLUMN 40,x13
    ldr d0,[x13]
    COLUMN 48,x15
    ldr d1,[x15]
    fsub d2,d0,d1
    fmax d2,d2,d5
    fsub d0,d0,d2
    str d0,[x13]
    fmul d2,d2,d9
    fmul d2,d2,d13
    fadd d0,d14,d2
    str d0,[x24,x14]
.Lnegative:
    fmin d3,d0,d5
    fsub d0,d0,d3
    str d0,[x24,x14]
    add x15,x22,#1
    cmp x15,x21
    b.hs .Lrunoff
    mul x16,x15,x26
    ldr d1,[x24,x16]
    fmul d2,d3,d12
    ldr d4,[x27,x15,lsl #3]
    fmul d2,d2,d4
    fadd d1,d1,d2
    str d1,[x24,x16]
.Lrunoff:
    fsub d4,d0,d11
    fmax d4,d4,d5
    cbnz x22,.Ldeep_runoff
    COLUMN 72,x13
    ldr d1,[x13]
    fmul d2,d12,d8
    fmul d2,d2,d4
    fadd d1,d1,d2
    str d1,[x13]
    COLUMN 88,x13
    ldr d1,[x13]
    fmul d2,d3,d8
    fmul d2,d2,d12
    fmul d2,d2,d10
    fadd d1,d1,d2
    str d1,[x13]
    b .Lremove_runoff
.Ldeep_runoff:
    COLUMN 80,x13
    ldr d1,[x13]
    fmul d2,d12,d8
    fmul d2,d2,d4
    fadd d1,d1,d2
    str d1,[x13]
.Lremove_runoff:
    fsub d0,d0,d4
    str d0,[x24,x14]
    ldr x9,[x29,#304]
    cbz x9,.Lnext_layer
    ldr x10,[x29,#312]
    mul x11,x22,x10
    add x13,x25,x11
    ldr d0,[x13]
    fmul d1,d8,d10
    fmul d1,d1,d12
    fadd d2,d3,d4
    fmul d2,d1,d2
    fsub d0,d0,d2
    str d0,[x13]
    add x15,x22,#1
    cmp x15,x21
    b.hs .Lnext_layer
    ldr d0,[x13,x10]
    fmul d2,d1,d3
    fadd d0,d0,d2
    str d0,[x13,x10]
.Lnext_layer:
    add x22,x22,#1
    cmp x22,x21
    b.lo .Llayer
.Lnext_column:
    add x19,x19,#1
    b .Lcolumn
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#128]
    ldp x21,x22,[sp,#144]
    ldp x23,x24,[sp,#160]
    ldp x25,x26,[sp,#176]
    ldp x27,x28,[sp,#192]
    ldp x29,x30,[sp,#208]
    ldp d8,d9,[sp,#224]
    ldp d10,d11,[sp,#240]
    ldp d12,d13,[sp,#256]
    ldp d14,d15,[sp,#272]
    add sp,sp,#384
    ret
.size md2asm_soil_water_correction,.-md2asm_soil_water_correction
.section .note.GNU-stack,"",%progbits

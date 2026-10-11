/* Vertical snow heat balance P01.
 * Physics formulations/openifs/surface/snow_heat_column.md.
 * Contract skills/md2asm/references/openifs/surface/snow_trisolver.md.
 * Six addresses, independent signed GNU descriptor strides.
 * x19 active layers, x20..x24 A/B/C/F/X, x25..x28 byte strides.
 * The fixed frame stores X stride and the dynamic stack holds gamma.
 * Preserve x18, x19..x29, d8..d15, aligned SP and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfsn_webal_mod_MOD_trisolver
#endif
.text
.p2align 4
.macro STRIDE reg,desc
    ldr x\reg,[x\desc,#40]
    cmp x\reg,#0
    mov x9,#1
    csel x\reg,x\reg,x9,ne
    lsl x\reg,x\reg,#3
.endm
.global md2asm_snow_trisolver
.type md2asm_snow_trisolver,%function
md2asm_snow_trisolver:
    sub sp,sp,#112
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x29,sp
    ldr w19,[x0]
    ldr x20,[x1]
    ldr x21,[x2]
    ldr x22,[x3]
    ldr x23,[x4]
    ldr x24,[x5]
    STRIDE 25,1
    STRIDE 26,2
    STRIDE 27,3
    STRIDE 28,4
    STRIDE 17,5
    str x17,[sp,#96]
    lsl x9,x19,#3
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x16,sp
    ldr d0,[x21]
    ldr d4,[x23]
    fdiv d4,d4,d0
    str d4,[x24]
    mov x9,#1
    cmp x9,x19
    b.ge .Lbackward
.Lforward:
    add x20,x20,x25
    add x21,x21,x26
    add x23,x23,x28
    add x24,x24,x17
    ldr d1,[x22]
    add x22,x22,x27
    fdiv d1,d1,d0
    str d1,[x16,x9,lsl #3]
    ldr d2,[x20]
    fmul d3,d2,d1
    ldr d0,[x21]
    fsub d0,d0,d3
    fmul d3,d2,d4
    ldr d4,[x23]
    fsub d4,d4,d3
    fdiv d4,d4,d0
    str d4,[x24]
    add x9,x9,#1
    cmp x9,x19
    b.lt .Lforward
.Lbackward:
    sub x9,x19,#1
    cbz x9,.Lreturn
.Lrecover:
    ldr d1,[x16,x9,lsl #3]
    sub x24,x24,x17
    fmul d1,d1,d4
    ldr d4,[x24]
    fsub d4,d4,d1
    str d4,[x24]
    subs x9,x9,#1
    b.ne .Lrecover
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#112
    ret
.size md2asm_snow_trisolver,.-md2asm_snow_trisolver
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    b md2asm_snow_trisolver
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

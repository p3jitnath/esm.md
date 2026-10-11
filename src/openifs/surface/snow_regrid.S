/* Snow mass and heat remapping P01 through P03.
 * Physics formulations/openifs/surface/snow_remap.md.
 * Contract skills/md2asm/references/openifs/surface/snow_regrid.md.
 * Fourteen addresses, signed independent GNU descriptor strides.
 * x19 column, x20 exclusive end, x21 layers, x22..x26 inputs.
 * x27 constants, x28 old-depth scratch, x29 fixed frame.
 * x16 old heat and x17 old cumulative depth, with no helper calls.
 * Preserve x18, x19..x29, d8..d15, aligned SP and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfsn_regrid_mod_MOD_srfsn_regrid
#endif
.text
.p2align 4
.macro CONFIG slot,desc,shift,rank
    ldr x10,[x\desc]
    str x10,[x29,#\slot]
    ldr x10,[x\desc,#40]
    cmp x10,#0
    mov x11,#1
    csel x10,x10,x11,ne
    lsl x10,x10,#\shift
    str x10,[x29,#(\slot+8)]
    .if \rank == 2
    ldr x10,[x\desc,#64]
    lsl x10,x10,#\shift
    str x10,[x29,#(\slot+16)]
    .else
    str xzr,[x29,#(\slot+16)]
    .endif
.endm
.macro COLUMN reg,slot
    ldr x9,[x29,#\slot]
    ldr x10,[x29,#(\slot+8)]
    madd x\reg,x19,x10,x9
.endm
.macro LOAD reg,base,slot,index
    ldr x9,[x29,#\slot]
    mul x9,x\index,x9
    ldr d\reg,[x\base,x9]
.endm
.macro STORE reg,slot,index
    ldr x9,[x29,#\slot]
    ldr x10,[x29,#(\slot+8)]
    madd x9,x19,x10,x9
    ldr x10,[x29,#(\slot+16)]
    madd x9,x\index,x10,x9
    str d\reg,[x9]
.endm
.global md2asm_snow_regrid
.type md2asm_snow_regrid,%function
md2asm_snow_regrid:
    mov x15,sp
    sub sp,sp,#384
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
    ldr w21,[x3]
    cmp x19,x20
    b.ge .Lreturn
    CONFIG 96,4,2,1
    CONFIG 120,5,3,2
    CONFIG 144,6,3,2
    CONFIG 168,7,3,2
    ldr x9,[x15,#0]
    CONFIG 192,9,3,2
    ldr x9,[x15,#8]
    CONFIG 216,9,3,2
    ldr x9,[x15,#16]
    CONFIG 240,9,3,2
    ldr x9,[x15,#24]
    CONFIG 264,9,3,2
    ldr x9,[x15,#32]
    CONFIG 288,9,3,2
    ldr x9,[x15,#40]
    CONFIG 312,9,3,2
    lsl x9,x21,#5
    add x9,x9,#16
    sub sp,sp,x9
    mov x28,sp
    lsl x9,x21,#3
    add x16,x28,x9
    add x17,x16,x9
    add x15,x17,x9
    add x15,x15,#8
    str x15,[x29,#336]
    adrp x27,.Lconstants
    add x27,x27,:lo12:.Lconstants
.Lcolumn:
    COLUMN 22,120
    COLUMN 23,144
    COLUMN 24,168
    COLUMN 25,192
    COLUMN 26,216
    ldr x15,[x29,#336]
    str xzr,[x17]
    str xzr,[x15]
    fmov d16,xzr
    fmov d17,xzr
    fmov d18,xzr
    mov x13,#0
.Lprepare:
    LOAD 0,22,136,13
    LOAD 1,23,160,13
    LOAD 2,24,184,13
    LOAD 3,25,208,13
    LOAD 4,26,232,13
    fdiv d5,d0,d1
    str d5,[x28,x13,lsl #3]
    fadd d16,d16,d5
    fadd d17,d17,d4
    add x14,x13,#1
    str d16,[x17,x14,lsl #3]
    str d17,[x15,x14,lsl #3]
    ldr d6,[x27,#8]
    fmul d6,d6,d0
    ldr d7,[x27,#0]
    fsub d3,d3,d7
    fmul d6,d6,d3
    fsub d7,d0,d2
    fadd d18,d18,d7
    ldr d3,[x27,#16]
    fmul d7,d3,d7
    fsub d6,d6,d7
    str d6,[x16,x13,lsl #3]
    add x13,x13,#1
    cmp x13,x21
    b.lt .Lprepare
    ldr x9,[x29,#96]
    ldr x10,[x29,#104]
    madd x9,x19,x10,x9
    ldr w9,[x9]
    cbnz w9,.Lbypass
    fcmp d18,#0.0
    b.eq .Lbypass
    mov x12,#0
.Lnew_layer:
    ldr d19,[x15,x12,lsl #3]
    add x14,x12,#1
    ldr d20,[x15,x14,lsl #3]
    fmov d21,xzr
    fmov d22,xzr
    mov x13,#0
.Lold_layer:
    ldr d0,[x17,x13,lsl #3]
    add x14,x13,#1
    ldr d1,[x17,x14,lsl #3]
    fmax d0,d19,d0
    fmin d1,d20,d1
    fsub d2,d1,d0
    fmov d3,xzr
    fmax d2,d3,d2
    fcmp d2,#0.0
    b.le .Lcoefficient
    ldr d0,[x28,x13,lsl #3]
    fdiv d2,d2,d0
.Lcoefficient:
    LOAD 0,22,136,13
    fmul d0,d2,d0
    fadd d21,d21,d0
    ldr d0,[x16,x13,lsl #3]
    fmul d0,d2,d0
    fadd d22,d22,d0
    add x13,x13,#1
    cmp x13,x21
    b.lt .Lold_layer
    STORE 21,240,12
    LOAD 0,26,232,12
    fcmp d0,#0.0
    b.le .Lzero_depth
    fdiv d1,d21,d0
    STORE 1,264,12
    ldr d3,[x27,#0]
    ldr d4,[x27,#16]
    ldr d5,[x27,#8]
    fmul d0,d4,d21
    fadd d0,d22,d0
    fmul d1,d5,d21
    fdiv d0,d0,d1
    fadd d0,d3,d0
    fmin d0,d3,d0
    STORE 0,312,12
    fdiv d0,d22,d4
    fadd d0,d21,d0
    fmin d0,d21,d0
    fmov d1,xzr
    fmax d0,d1,d0
    STORE 0,288,12
    b .Lnext_layer
.Lzero_depth:
    fmov d0,xzr
    STORE 0,288,12
    LOAD 0,25,208,12
    STORE 0,312,12
    LOAD 0,23,160,12
    STORE 0,264,12
.Lnext_layer:
    add x12,x12,#1
    cmp x12,x21
    b.lt .Lnew_layer
    b .Lnext_column
.Lbypass:
    mov x12,#0
.Lcopy:
    LOAD 0,22,136,12
    STORE 0,240,12
    LOAD 0,23,160,12
    STORE 0,264,12
    LOAD 0,24,184,12
    STORE 0,288,12
    LOAD 0,25,208,12
    STORE 0,312,12
    add x12,x12,#1
    cmp x12,x21
    b.lt .Lcopy
.Lnext_column:
    add x19,x19,#1
    cmp x19,x20
    b.lt .Lcolumn
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#384
    ret
.size md2asm_snow_regrid,.-md2asm_snow_regrid
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    b md2asm_snow_regrid
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .quad 0x4071128f5c28f5c3
    .quad 0x40a1688590b21643
    .quad 0x41145e1000000000
.section .note.GNU-stack,"",%progbits

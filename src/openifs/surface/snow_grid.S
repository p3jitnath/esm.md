/* Snowpack depth and vertical layers P01 and P02.
 * Physics formulations/openifs/surface/snow_layers.md.
 * Contract skills/md2asm/references/openifs/surface/snow_grid.md.
 * Fifteen addresses with independent signed GNU descriptor strides.
 * x19 column, x20 exclusive end, x21 layers, x22..x27 owners.
 * x28 minimum scratch, x16 maximum scratch, x29 fixed frame.
 * Preserve x18, x19..x29, d8..d15, aligned SP and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfsn_vgrid_mod_MOD_srfsn_vgrid
#endif
.text
.p2align 4
.macro STRIDE slot,desc,dim,shift
    ldr x11,[x\desc,#\dim]
    .if \dim == 40
    cmp x11,#0
    mov x10,#1
    csel x11,x11,x10,ne
    .endif
    lsl x11,x11,#\shift
    str x11,[x29,#\slot]
.endm
.global md2asm_snow_grid
.type md2asm_snow_grid,%function
md2asm_snow_grid:
    mov x15,sp
    sub sp,sp,#304
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
    ldr x22,[x4]
    ldr x23,[x5]
    ldr x24,[x6]
    ldr x25,[x7]
    STRIDE 192,4,40,2
    STRIDE 200,5,40,3
    STRIDE 208,6,40,3
    STRIDE 216,6,64,3
    STRIDE 224,7,40,3
    STRIDE 232,7,64,3
    ldr x9,[x15,#0]
    ldr x10,[x9]
    str x10,[x29,#96]
    STRIDE 104,9,40,3
    ldr x9,[x15,#8]
    ldr x10,[x9]
    str x10,[x29,#112]
    STRIDE 120,9,40,3
    ldr x9,[x15,#16]
    ldr x10,[x9]
    str x10,[x29,#128]
    STRIDE 136,9,40,3
    ldr x9,[x15,#24]
    ldr x10,[x9]
    str x10,[x29,#144]
    STRIDE 152,9,40,3
    ldr x9,[x15,#32]
    ldr x26,[x9]
    STRIDE 240,9,40,3
    STRIDE 248,9,64,3
    ldr x9,[x15,#40]
    ldr x27,[x9]
    STRIDE 256,9,40,2
    ldr x9,[x15,#48]
    cmp x9,#0
    cset w9,ne
    str w9,[x29,#264]
    lsl x9,x21,#4
    sub sp,sp,x9
    mov x28,sp
    lsl x9,x21,#3
    add x16,x28,x9
    adrp x17,.Lconstants
    add x17,x17,:lo12:.Lconstants
.Lcolumn:
    /* Each independent sum keeps its original layer order. */
    ldr x12,[x29,#208]
    madd x9,x19,x12,x24
    ldr x12,[x29,#224]
    madd x10,x19,x12,x25
    ldr x12,[x29,#240]
    madd x11,x19,x12,x26
    ldr x13,[x29,#216]
    ldr x14,[x29,#232]
    ldr x15,[x29,#248]
    mov x12,x21
    fmov d16,xzr
    fmov d17,xzr
.Ldepth:
    ldr d0,[x9]
    ldr d1,[x10]
    fdiv d2,d0,d1
    fadd d16,d16,d2
    fadd d17,d17,d0
    str xzr,[x11]
    add x9,x9,x13
    add x10,x10,x14
    add x11,x11,x15
    subs x12,x12,#1
    b.ne .Ldepth
    /* Optional presence selects the glacier and terrain thresholds. */
    ldr w9,[x29,#264]
    ldr d0,[x17,#56]
    cbz w9,.Lglacier_test
    ldr d0,[x17,#64]
.Lglacier_test:
    fcmp d17,d0
    b.ge .Lglacier_bounds
    ldr d0,[x17,#8]
    fcmp d16,d0
    b.le .Lordinary_bounds
    ldr d1,[x17,#40]
    cbz w9,.Lterrain_test
    ldr d1,[x17,#48]
.Lterrain_test:
    ldr x9,[x29,#200]
    mul x9,x19,x9
    ldr d2,[x23,x9]
    fcmp d2,d1
    b.ge .Lterrain_bounds
.Lordinary_bounds:
    ldr x9,[x29,#96]
    ldr x10,[x29,#112]
    ldr x11,[x29,#104]
    ldr x12,[x29,#120]
    b .Lcopy_bounds
.Lglacier_bounds:
    ldr x9,[x29,#128]
    ldr x10,[x29,#144]
    ldr x11,[x29,#136]
    ldr x12,[x29,#152]
.Lcopy_bounds:
    mov x13,x28
    mov x14,x16
    mov x15,x21
.Lcopy_layer:
    ldr d0,[x9]
    ldr d1,[x10]
    str d0,[x13],#8
    str d1,[x14],#8
    add x9,x9,x11
    add x10,x10,x12
    subs x15,x15,#1
    b.ne .Lcopy_layer
    b .Lscreen_bounds
.Lterrain_bounds:
    ldr d0,[x17,#8]
    fsub d1,d16,d0
    ldr d2,[x17,#16]
    fmul d1,d2,d1
    fadd d2,d2,d1
    fmin d2,d0,d2
    ldr d3,[x17,#24]
    fadd d3,d3,d1
    ldr d4,[x17,#32]
    fmin d3,d4,d3
    mov x9,x28
    mov x10,x16
    mov x11,x21
.Lterrain_layer:
    str d2,[x9],#8
    str d3,[x10],#8
    subs x11,x11,#1
    b.ne .Lterrain_layer
    str d2,[x16]
    sub x9,x21,#1
    fmov d0,#-1.0
    str d0,[x16,x9,lsl #3]
.Lscreen_bounds:
    /* The first minimum selects the layer that receives excess depth. */
    ldr d0,[x16]
    mov x14,#0
    mov x9,#1
    add x10,x16,#8
.Lminimum:
    cmp x9,x21
    b.ge .Lminimum_done
    ldr d1,[x10],#8
    fcmp d1,d0
    b.ge .Lminimum_next
    fmov d0,d1
    mov x14,x9
.Lminimum_next:
    add x9,x9,#1
    b .Lminimum
.Lminimum_done:
    ldr d0,[x17,#72]
    str d0,[x16,x14,lsl #3]
    ldr x9,[x29,#192]
    mul x9,x19,x9
    ldr w9,[x22,x9]
    mov x13,#1
    cbnz w9,.Lactive_done
    ldr d0,[x28]
    add x10,x28,#8
    mov x9,#1
.Lactive:
    cmp x9,x21
    b.ge .Lactive_done
    ldr d1,[x10],#8
    fadd d0,d0,d1
    fcmp d16,d0
    b.lt .Lactive_done
    add x13,x9,#1
    add x9,x9,#1
    b .Lactive
.Lactive_done:
    ldr x9,[x29,#256]
    mul x9,x19,x9
    str w13,[x27,x9]
    ldr x9,[x29,#240]
    madd x11,x19,x9,x26
    cmp x13,#1
    b.ne .Lmultiple
    str d16,[x11]
    b .Lnext_column
.Lmultiple:
    ldr d0,[x16]
    fmin d0,d16,d0
    str d0,[x11]
    fsub d1,d16,d0
    sub x9,x13,#1
    scvtf d2,x9
    fdiv d1,d1,d2
    fmov d18,d0
    ldr x15,[x29,#248]
    add x12,x11,x15
    add x10,x16,#8
    mov x9,#1
.Lsplit:
    ldr d2,[x10],#8
    fmin d3,d1,d2
    str d3,[x12]
    fadd d18,d18,d3
    add x12,x12,x15
    add x9,x9,#1
    cmp x9,x13
    b.lt .Lsplit
    fsub d0,d16,d18
    ldr d1,[x17,#0]
    fcmp d0,d1
    b.le .Lnext_column
    sub x9,x13,#1
    cmp x14,x9
    csel x9,x14,x9,le
    mul x9,x9,x15
    ldr d0,[x11,x9]
    /* Keep the addition rounding before the residual subtraction. */
    fadd d0,d0,d16
    fsub d0,d0,d18
    str d0,[x11,x9]
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
    add sp,sp,#304
    ret
.size md2asm_snow_grid,.-md2asm_snow_grid
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    b md2asm_snow_grid
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .quad 0x3ce4000000000000
    .quad 0x3fd0000000000000
    .quad 0x3fb999999999999a
    .quad 0x3fc3333333333333
    .quad 0x3fd3333333333333
    .quad 0x4049000000000000
    .quad 0x4054000000000000
    .quad 0x40b3880000000000
    .quad 0x409f400000000000
    .quad 0x4202a05f20000000
.section .note.GNU-stack,"",%progbits

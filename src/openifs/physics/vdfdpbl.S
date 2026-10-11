/* VDFDPBL diagnoses a stability crossing and interpolates its height in metres. */
/* Physics formulations/openifs/physics/boundary_layer_height.md revision 1. */
/* ABI and rounding skills/md2asm/references/openifs/physics/vdfdpbl.md. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL vdfdpbl_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#96
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x25,x5
    mov x26,x6
    mov x27,x7
    ldr x28,[sp,#96]
    ldr x29,[sp,#104]
    ldr x6,[sp,#136]
    ldr w19,[x1]
    sub w19,w19,#1
    lsl x19,x19,#3
    ldr w20,[x2]
    lsl x20,x20,#3
    ldr w21,[x3]
    lsl x21,x21,#3
    ldr w22,[x4]
    sub w22,w22,#1
    mul x22,x22,x21
    adrp x0,:got:__yomcst_MOD_rcpd
    ldr x0,[x0,:got_lo12:__yomcst_MOD_rcpd]
    ldr d16,[x0]
    adrp x0,:got:__yomcst_MOD_retv
    ldr x0,[x0,:got_lo12:__yomcst_MOD_retv]
    ldr d17,[x0]
    adrp x0,:got:__yomcst_MOD_rg
    ldr x0,[x0,:got_lo12:__yomcst_MOD_rg]
    ldr d18,[x0]
    adrp x0,.Lconstants
    add x0,x0,:lo12:.Lconstants
    ldp d19,d20,[x0,#0]
    ldp d21,d7,[x0,#16]
    ldr d31,[x0,#32]
    adrp x0,:got:__yomdyncore_MOD_rplrg
    ldr x0,[x0,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d0,[x0]
    fdiv d22,d7,d0
    cmp x19,x20
    b.hs .Lfinish
    mov x23,x19
.Lcolumn:
    fmov d5,d22
    add x14,x22,x23
    ldr d0,[x27,x14]
    ldr d1,[x28,x14]
    ldr d30,[x29,x14]
    fmul d0,d16,d0
    fmul d1,d17,d1
    fadd d1,d31,d1
    fmul d0,d0,d1
    fadd d23,d0,d30
    fadd d24,d23,d19
    fmov d25,xzr
    cbz x22,.Lstore_height
    sub x24,x22,x21
.Lscan:
    add x14,x24,x23
    ldr d0,[x27,x14]
    ldr d1,[x28,x14]
    ldr d29,[x29,x14]
    fmul d0,d16,d0
    fmul d1,d17,d1
    fadd d1,d31,d1
    fmul d0,d0,d1
    fadd d26,d0,d29
    ldr d2,[x25,x14]
    ldr d3,[x26,x14]
    fmul d2,d2,d2
    fmul d3,d3,d3
    fadd d2,d2,d3
    fcmp d2,d21
    fcsel d2,d2,d21,ge
    fsub d0,d26,d24
    fsub d1,d26,d29
    fdiv d0,d0,d1
    fsub d1,d29,d30
    fmul d0,d1,d0
    fdiv d0,d0,d2
    fcmp d0,d20
    b.gt .Lcrossing
    fmov d25,d0
    subs x24,x24,x21
    b.pl .Lscan
    b .Lstore_height
.Lcrossing:
    add x15,x14,x21
    ldr d3,[x29,x15]
    fsub d1,d0,d20
    fsub d2,d20,d25
    fmul d1,d1,d3
    fmul d2,d2,d29
    fadd d1,d1,d2
    fsub d2,d0,d25
    fmul d2,d2,d18
    fdiv d5,d1,d2
.Lstore_height:
    str d5,[x6,x23]
    add x23,x23,#8
    cmp x23,x20
    b.lo .Lcolumn
.Lfinish:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#96
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .double 1.e-10,0.25,0.010000000000000002,1000.0,1.0
.section .note.GNU-stack,"",%progbits

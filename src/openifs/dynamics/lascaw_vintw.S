/* Complete vertical cubic, COMAD, lower-order, SLHD and filter update.
 * Twenty-seven ordinary pointers follow the Arm ABI. Rows vary fastest.
 * Each output view contains B*L*3 dimensionless binary64 weights.
 * The enclosing-family observer supplies no numerical solver stage.
 * Unsupported logical flags return before numerical argument reads.
 * A 320-byte frame preserves x19 through x28, with no numerical helper.
 */
#ifndef LASCAW_VINTW_ENTRY
#define LASCAW_VINTW_ENTRY lascaw_vintw_assembly_
#endif
.text
.p2align 4
.global LASCAW_VINTW_ENTRY
.type LASCAW_VINTW_ENTRY,%function
/* Every product follows the original left-associated expression. */
.macro CUBIC a,b,c
    fmul \a,d0,d2
    fmul \a,\a,d3
    fmul \a,\a,d19
    fmul d7,d0,d1
    fmul \b,d7,d3
    fmul \b,\b,d20
    fmul \c,d7,d2
    fmul \c,\c,d21
.endm
/* Store a complete current three-plane view. */
.macro STORE argument,a,b,c
    ldr x9,[sp,#(8*\argument)]
    add x9,x9,x24
    str \a,[x9]
    str \b,[x9,x23]
    add x10,x9,x23,lsl #1
    str \c,[x10]
.endm
.macro BLEND hi,lo,out
    fsub d1,\lo,\hi
    fmul d1,d0,d1
    fadd \out,\hi,d1
.endm
.macro BLEND_BOTH hi,lo,a,b
    fsub d1,\lo,\hi
    fmul d2,d0,d1
    fadd \a,\hi,d2
    fmul d2,d3,d1
    fadd \b,\hi,d2
.endm
/* Matrix row uses source operand order and two successive rounded sums. */
.macro DOT out,a,b,c,row
    ldr d3,[x9,#(8*\row)]
    fmul \out,d3,\a
    ldr d3,[x9,#(8*(\row+3))]
    fmul d3,d3,\b
    fadd \out,\out,d3
    ldr d3,[x9,#(8*(\row+6))]
    fmul d3,d3,\c
    fadd \out,\out,d3
.endm
.macro DIFF out,smooth,a
    fsub \out,\smooth,\a
    fmul \out,d28,\out
    fadd \out,\a,\out
.endm
LASCAW_VINTW_ENTRY:
    ldr w9,[x5]
    cmp w9,#1
    b.hi .Lreject
    ldr w10,[x6]
    cmp w10,#1
    b.hi .Lreject
    ldr w11,[x6,#4]
    cmp w11,#1
    b.hi .Lreject
    ldr w12,[x6,#8]
    cmp w12,#1
    b.hi .Lreject
    ldr w13,[x7]
    cmp w13,#1
    b.hi .Lreject
    ldr x15,[sp]
    ldr w14,[x15]
    cmp w14,#1
    b.hi .Lreject
    cbz w10,.Lflags_valid
    orr w17,w11,w12
    cbz w17,.Lreject
.Lflags_valid:
    orr w16,w9,w10,lsl #1
    orr w16,w16,w11,lsl #2
    orr w16,w16,w12,lsl #3
    orr w16,w16,w13,lsl #4
    orr w16,w16,w14,lsl #5
    sub sp,sp,#320
    stp x19,x20,[sp,#224]
    stp x21,x22,[sp,#240]
    stp x23,x24,[sp,#256]
    stp x25,x26,[sp,#272]
    stp x27,x28,[sp,#288]
    stp x0,x1,[sp]
    stp x2,x3,[sp,#16]
    stp x4,x5,[sp,#32]
    stp x6,x7,[sp,#48]
    ldr x9,[sp,#320]
    str x9,[sp,#64]
    ldr x9,[sp,#328]
    str x9,[sp,#72]
    ldr x9,[sp,#336]
    str x9,[sp,#80]
    ldr x9,[sp,#344]
    str x9,[sp,#88]
    ldr x9,[sp,#352]
    str x9,[sp,#96]
    ldr x9,[sp,#360]
    str x9,[sp,#104]
    ldr x9,[sp,#368]
    str x9,[sp,#112]
    ldr x9,[sp,#376]
    str x9,[sp,#120]
    ldr x9,[sp,#384]
    str x9,[sp,#128]
    ldr x9,[sp,#392]
    str x9,[sp,#136]
    ldr x9,[sp,#400]
    str x9,[sp,#144]
    ldr x9,[sp,#408]
    str x9,[sp,#152]
    ldr x9,[sp,#416]
    str x9,[sp,#160]
    ldr x9,[sp,#424]
    str x9,[sp,#168]
    ldr x9,[sp,#432]
    str x9,[sp,#176]
    ldr x9,[sp,#440]
    str x9,[sp,#184]
    ldr x9,[sp,#448]
    str x9,[sp,#192]
    ldr x9,[sp,#456]
    str x9,[sp,#200]
    ldr x9,[sp,#464]
    str x9,[sp,#208]
    mov w28,w16
    ldrsw x19,[x1]
    ldrsw x20,[x2]
    ldrsw x21,[x3]
    ldrsw x22,[x4]
    cmp x19,#1024
    b.hi .Lrestore
    cmp x20,#256
    b.hi .Lrestore
    cmp x21,#1
    b.lt .Lrestore
    add x9,x19,#1
    cmp x21,x9
    b.gt .Lrestore
    cmp x22,x19
    b.hi .Lrestore
    sub x21,x21,#1
    cmp x22,x21
    b.le .Lrestore
    cbz x19,.Lrestore
    cbz x20,.Lrestore
    mul x23,x19,x20
    lsl x23,x23,#3
    lsl x24,x21,#3
    mov x25,x20
    fmov d30,#1.0
    fmov d31,#0.5
.Llevel:
    sub x26,x22,x21
.Lcell:
    ldr x9,[sp,#80]
    lsr x10,x24,#1
    ldrsw x27,[x9,x10]
    cmp x27,#1
    b.lt .Lboundary
    sub x10,x20,#3
    cmp x27,x10
    b.gt .Lboundary
    ldr x9,[sp,#136]
    add x9,x9,x27,lsl #3
    ldp d0,d1,[x9]
    ldp d2,d3,[x9,#16]
    fmov d28,d1
    fmov d29,d2
    ldr x9,[sp,#88]
    ldr d7,[x9,x24]
    fsub d0,d7,d0
    fsub d1,d7,d1
    fsub d2,d7,d2
    fsub d3,d7,d3
    ldr x9,[sp,#144]
    add x9,x9,x27,lsl #5
    ldr d19,[x9,#8]
    ldr d20,[x9,#16]
    ldr d21,[x9,#24]
    CUBIC d4,d5,d6
    tbz w28,#0,.Lsame_mad
    fsub d0,d0,d1
    fsub d3,d3,d2
    fsub d7,d29,d28
    fmul d7,d31,d7
    ldr x9,[sp,#112]
    ldr d28,[x9,x24]
    fsub d29,d30,d28
    fmul d7,d7,d29
    fmul d1,d1,d28
    fadd d1,d1,d7
    fmul d2,d2,d28
    fsub d2,d2,d7
    fadd d0,d0,d1
    fadd d3,d3,d2
    CUBIC d16,d17,d18
    b .Lmad_ready
.Lsame_mad:
    fmov d16,d4
    fmov d17,d5
    fmov d18,d6
.Lmad_ready:
    STORE 23,d16,d17,d18
    tbz w28,#2,.Lold_lower
    ldr x9,[sp,#96]
    ldr d7,[x9,x24]
    fsub d28,d30,d7
    fmul d29,d7,d28
    ldr x9,[sp,#152]
    mov x10,#24
    madd x9,x27,x10,x9
    ldp d19,d20,[x9]
    ldr d21,[x9,#16]
    fmul d19,d29,d19
    fadd d19,d19,d28
    fmul d20,d29,d20
    fadd d20,d20,d7
    fmul d21,d29,d21
    b .Llower_ready
.Lold_lower:
    tbz w28,#3,.Llower_ready
    ldr x9,[sp,#96]
    ldr d20,[x9,x24]
    fsub d19,d30,d20
    fmov d21,xzr
.Llower_ready:
    tbz w28,#1,.Lwithout_slhd
    ldr x9,[sp,#120]
    ldr d28,[x9,x24]
    fmov x10,d28
    and x10,x10,#0x8000000000000000
    fmov x11,d31
    orr x10,x10,x11
    fmov d29,x10
    ldr x9,[sp,#72]
    ldr d7,[x9]
    fadd d0,d31,d29
    fmul d0,d0,d7
    fsub d1,d29,d31
    ldr x9,[sp]
    ldr d7,[x9,#128]
    fmul d1,d1,d7
    fsub d0,d0,d1
    ldr d3,[x9,#120]
    BLEND_BOTH d4,d19,d22,d25
    BLEND_BOTH d5,d20,d23,d26
    BLEND_BOTH d6,d21,d24,d27
    STORE 22,d22,d23,d24
    ldr x9,[sp,#160]
    mov x10,#72
    madd x9,x27,x10,x9
    DOT d0,d25,d26,d27,0
    DOT d1,d25,d26,d27,1
    DOT d2,d25,d26,d27,2
    fabs d28,d28
    DIFF d25,d0,d22
    DIFF d26,d1,d23
    DIFF d27,d2,d24
    STORE 24,d25,d26,d27
    tbz w28,#5,.Lvertical_filter
    ldr x9,[sp,#128]
    ldr d28,[x9,x24]
    fabs d28,d28
    DIFF d25,d0,d22
    DIFF d26,d1,d23
    DIFF d27,d2,d24
    STORE 25,d25,d26,d27
    b .Lvertical_filter
.Lwithout_slhd:
    tbz w28,#2,.Lhigh_main
    ldr x9,[sp,#72]
    ldr d0,[x9]
    BLEND d4,d19,d22
    BLEND d5,d20,d23
    BLEND d6,d21,d24
    b .Lmain_ready
.Lhigh_main:
    fmov d22,d4
    fmov d23,d5
    fmov d24,d6
.Lmain_ready:
    STORE 22,d22,d23,d24
    STORE 24,d22,d23,d24
.Lvertical_filter:
    tbz w28,#4,.Lnext
    ldr x9,[sp,#168]
    mov x10,#72
    madd x9,x27,x10,x9
    DOT d25,d22,d23,d24,0
    DOT d26,d22,d23,d24,1
    DOT d27,d22,d23,d24,2
    STORE 26,d25,d26,d27
    b .Lnext
.Lboundary:
    ldr x9,[sp,#96]
    ldr d20,[x9,x24]
    fsub d19,d30,d20
    fmov d21,xzr
    STORE 22,d19,d20,d21
    tbz w28,#1,.Lboundary_filter
    STORE 24,d19,d20,d21
    tbz w28,#5,.Lboundary_filter
    STORE 25,d19,d20,d21
.Lboundary_filter:
    tbz w28,#4,.Lboundary_mad
    STORE 26,d19,d20,d21
.Lboundary_mad:
    ldr x9,[sp,#104]
    ldr d20,[x9,x24]
    fsub d19,d30,d20
    STORE 23,d19,d20,d21
.Lnext:
    add x24,x24,#8
    subs x26,x26,#1
    b.ne .Lcell
    sub x9,x22,x21
    sub x9,x19,x9
    add x24,x24,x9,lsl #3
    subs x25,x25,#1
    b.ne .Llevel
.Lrestore:
    ldp x19,x20,[sp,#224]
    ldp x21,x22,[sp,#240]
    ldp x23,x24,[sp,#256]
    ldp x25,x26,[sp,#272]
    ldp x27,x28,[sp,#288]
    add sp,sp,#320
.Lreject:
    ret
.size LASCAW_VINTW_ENTRY,.-LASCAW_VINTW_ENTRY

#ifdef LASCAW_VINTW_ABI_CHECK
.p2align 4
.global lascaw_vintw_abi_invoke
.type lascaw_vintw_abi_invoke,%function
lascaw_vintw_abi_invoke:
    sub sp,sp,#176
    stp x19,x30,[sp,#160]
    mov x19,x0
    ldr x9,[x19,#64]
    str x9,[sp,#0]
    ldr x9,[x19,#72]
    str x9,[sp,#8]
    ldr x9,[x19,#80]
    str x9,[sp,#16]
    ldr x9,[x19,#88]
    str x9,[sp,#24]
    ldr x9,[x19,#96]
    str x9,[sp,#32]
    ldr x9,[x19,#104]
    str x9,[sp,#40]
    ldr x9,[x19,#112]
    str x9,[sp,#48]
    ldr x9,[x19,#120]
    str x9,[sp,#56]
    ldr x9,[x19,#128]
    str x9,[sp,#64]
    ldr x9,[x19,#136]
    str x9,[sp,#72]
    ldr x9,[x19,#144]
    str x9,[sp,#80]
    ldr x9,[x19,#152]
    str x9,[sp,#88]
    ldr x9,[x19,#160]
    str x9,[sp,#96]
    ldr x9,[x19,#168]
    str x9,[sp,#104]
    ldr x9,[x19,#176]
    str x9,[sp,#112]
    ldr x9,[x19,#184]
    str x9,[sp,#120]
    ldr x9,[x19,#192]
    str x9,[sp,#128]
    ldr x9,[x19,#200]
    str x9,[sp,#136]
    ldr x9,[x19,#208]
    str x9,[sp,#144]
    ldp x0,x1,[x19]
    ldp x2,x3,[x19,#16]
    ldp x4,x5,[x19,#32]
    ldp x6,x7,[x19,#48]
    bl LASCAW_VINTW_ENTRY
    ldp x19,x30,[sp,#160]
    add sp,sp,#176
    ret
.size lascaw_vintw_abi_invoke,.-lascaw_vintw_abi_invoke
#endif
.section .note.GNU-stack,"",%progbits

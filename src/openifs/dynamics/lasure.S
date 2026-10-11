// Direct assembly from formulations/openifs/dynamics/time_map_factors.md.
// Contract skills/md2asm/references/openifs/dynamics/lasure.md, revision 1.
// Seventeen ordinary addresses follow AAPCS64. Inputs and outputs are disjoint.
// Eight register arguments, then nine eight-byte entry-stack slots.
// No stack frame, preserved-register writes or numerical helper.
// Independent adjacent columns use two FP64 lanes, with a scalar remainder.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL lasure_
#endif
.arch armv8.2-a+simd
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr x8,[sp]
    ldr x9,[sp,#8]
    ldr x10,[sp,#16]
    ldr x11,[sp,#24]
    ldr x12,[sp,#32]
    ldr x13,[sp,#40]
    ldr x14,[sp,#48]
    ldr x15,[sp,#56]
    ldr x16,[sp,#64]
    ldr d0,[x7]
    ldr d1,[x8]
    fmov d2,#0.5
    fmul d2,d2,d1
    fmul d3,d2,d0
    str d2,[x10]
    str d3,[x11]
    ldr d0,[x2,#4320]
    fmov d1,#1.0
    fadd d4,d1,d0
    fsub d5,d1,d0
    str d4,[x15]
    str d5,[x16]
    ldr w15,[x2,#4448]
    ldr w16,[x1]
    ldr w17,[x4,#12]
    ldr w10,[x1,#64]
    orr w16,w16,w17
    and w15,w15,w16
    bic w15,w15,w10
    str w15,[x12]
    ldr w8,[x3,#1056]
    ldr w10,[x2,#2476]
    ldr w5,[x5]
    ldr w6,[x6]
    cmp w5,w6
    b.gt .Llasure_done
    sub w17,w5,#1
    add x13,x13,x17,lsl #3
    add x14,x14,x17,lsl #3
    sub w6,w6,w5
    add w6,w6,#1
    cbnz w10,.Llasure_implicit
    // Select the complete geometry block with its declared signed stride.
    ldr d6,[x0,#7512]
    ldrsw x9,[x9]
    ldr x10,[x0,#8472]
    ldr x11,[x0,#8480]
    ldr x12,[x0,#8504]
    ldr x15,[x0,#8512]
    madd x9,x15,x9,x11
    madd x0,x9,x12,x10
    // GM is a contiguous pointer with its supplied lower-bound offset.
    ldr x11,[x0,#704]
    ldr x12,[x0,#712]
    add x12,x12,x5
    add x11,x11,x12,lsl #3
    cbnz w8,.Llasure_extended
    fmul d4,d3,d6
    fmul d4,d4,d6
    fmul d7,d6,d6
    dup v4.2d,v4.d[0]
    dup v7.2d,v7.d[0]
    cmp w6,#2
    b.lt .Llasure_stretch_tail
.Llasure_stretch_pair:
    ld1 {v0.2d},[x11],#16
    fmul v1.2d,v0.2d,v0.2d
    fdiv v2.2d,v4.2d,v1.2d
    fdiv v0.2d,v7.2d,v1.2d
    st1 {v2.2d},[x13],#16
    st1 {v0.2d},[x14],#16
    sub w6,w6,#2
    cmp w6,#2
    b.ge .Llasure_stretch_pair
.Llasure_stretch_tail:
    cbz w6,.Llasure_done
    ldr d0,[x11]
    fmul d1,d0,d0
    fdiv d2,d4,d1
    fdiv d0,d7,d1
    str d2,[x13]
    str d0,[x14]
    ret
.Llasure_extended:
    ldr x15,[x0,#768]
    ldr x16,[x0,#776]
    add x16,x16,x5
    add x15,x15,x16,lsl #3
    dup v3.2d,v3.d[0]
    cmp w6,#2
    b.lt .Llasure_extended_tail
.Llasure_extended_pair:
    ld1 {v0.2d},[x11],#16
    ld1 {v2.2d},[x15],#16
    fmul v1.2d,v0.2d,v0.2d
    fmul v4.2d,v3.2d,v2.2d
    fdiv v4.2d,v4.2d,v1.2d
    fdiv v2.2d,v2.2d,v1.2d
    st1 {v4.2d},[x13],#16
    st1 {v2.2d},[x14],#16
    sub w6,w6,#2
    cmp w6,#2
    b.ge .Llasure_extended_pair
.Llasure_extended_tail:
    cbz w6,.Llasure_done
    ldr d0,[x11]
    ldr d2,[x15]
    fmul d1,d0,d0
    fmul d4,d3,d2
    fdiv d4,d4,d1
    fdiv d2,d2,d1
    str d4,[x13]
    str d2,[x14]
    ret
.Llasure_implicit:
    cmp w6,#2
    b.lt .Llasure_implicit_tail
.Llasure_implicit_pair:
    stp d3,d3,[x13],#16
    stp d1,d1,[x14],#16
    sub w6,w6,#2
    cmp w6,#2
    b.ge .Llasure_implicit_pair
.Llasure_implicit_tail:
    cbz w6,.Llasure_done
    str d3,[x13]
    str d1,[x14]
.Llasure_done:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

/* GPGRP supplies both complete horizontal pressure-gradient terms.
 * See the md2asm contract for coordinate units, byte offsets and bounds.
 * Conventional layers preserve B + (alpha*G + D*RT) with separate rounding.
 * Finite elements preserve B + ((RT*C)*P). Inputs never overlap outputs.
 * GNU 12.3 object offsets were measured by a storage-only Fortran probe. */
.text
.p2align 4
.global gpgrp_
.type gpgrp_,%function
gpgrp_:
    ldr w9,[x1]
    ldr w10,[x2]
    ldr w1,[x0,#5144]
    ldr w2,[x0,#5224]
    cbz w2,.Lreturn
    sub w10,w10,w9
    adds w10,w10,#1
    ble .Lreturn
    ldr x13,[x0,#3264]
    ldr w13,[x13,#52]
    stp x19,x20,[sp,#-80]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    ldp x19,x20,[sp,#80]
    ldp x22,x23,[sp,#96]
    ldp x24,x25,[sp,#112]
    ldp x26,x27,[sp,#128]
    sxtw x28,w10
    sub w9,w9,#1
    sxtw x0,w9
    lsl x0,x0,#3
    mov x8,x0
    sxtw x1,w1
    lsl x1,x1,#3
    sxtw x2,w2
    mul x11,x1,x2
    adrp x14,:got:__intdyn_mod_MOD_yytxyb
    ldr x14,[x14,:got_lo12:__intdyn_mod_MOD_yytxyb]
    cbnz w13,.Lsetup_full
    ldr w15,[x14,#12]
    sub w15,w15,#1
    sxtw x15,w15
    madd x19,x15,x11,x19
    adrp x14,:got:__intdyn_mod_MOD_yytxybder
    ldr x14,[x14,:got_lo12:__intdyn_mod_MOD_yytxybder]
    ldr w15,[x14,#20]
    sub w15,w15,#1
    sxtw x15,w15
    madd x21,x15,x11,x20
    ldr w15,[x14,#16]
    sub w15,w15,#1
    sxtw x15,w15
    madd x20,x15,x11,x20
    add x22,x22,x1
    add x23,x23,x1
    adr x12,.Lconventional_level
    b .Lnext_level
.Lsetup_full:
    ldr w15,[x14,#16]
    sub w15,w15,#1
    sxtw x15,w15
    madd x19,x15,x11,x19
    adr x12,.Lfull_level
.Lnext_level:
    mov x9,x8
    mov x10,x28
    mov x15,x0
    br x12
.Lconventional_level:
    cmp x10,#2
    b.lt .Lconventional_tail
.Lconventional_pair:
    ldr q0,[x3,x9]
    ldr q3,[x19,x9]
    ldr q1,[x4,x9]
    ldr q2,[x5,x9]
    ldr q4,[x20,x9]
    ldr q5,[x21,x9]
    ldr q6,[x22,x9]
    ldr q7,[x23,x9]
    fmul v1.2d,v3.2d,v1.2d
    fmul v2.2d,v3.2d,v2.2d
    fmul v4.2d,v4.2d,v0.2d
    fmul v5.2d,v5.2d,v0.2d
    fadd v1.2d,v1.2d,v4.2d
    fadd v2.2d,v2.2d,v5.2d
    fadd v6.2d,v6.2d,v1.2d
    fadd v7.2d,v7.2d,v2.2d
    str q6,[x26,x9]
    str q7,[x27,x9]
    add x9,x9,#16
    add x15,x15,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lconventional_pair
.Lconventional_tail:
    cbz x10,.Lend_level
    ldr d0,[x3,x9]
    ldr d3,[x19,x9]
    ldr d1,[x4,x9]
    ldr d2,[x5,x9]
    ldr d4,[x20,x9]
    ldr d5,[x21,x9]
    ldr d6,[x22,x9]
    ldr d7,[x23,x9]
    fmul d1,d3,d1
    fmul d2,d3,d2
    fmul d4,d4,d0
    fmul d5,d5,d0
    fadd d1,d1,d4
    fadd d2,d2,d5
    fadd d6,d6,d1
    fadd d7,d7,d2
    str d6,[x26,x9]
    str d7,[x27,x9]
    b .Lend_level
.Lfull_level:
    cmp x10,#2
    b.lt .Lfull_tail
.Lfull_pair:
    ldr q0,[x3,x9]
    ldr q3,[x19,x9]
    ldr q1,[x6,x15]
    ldr q2,[x7,x15]
    ldr q4,[x24,x9]
    ldr q5,[x25,x9]
    fmul v0.2d,v0.2d,v3.2d
    fmul v1.2d,v0.2d,v1.2d
    fmul v2.2d,v0.2d,v2.2d
    fadd v4.2d,v4.2d,v1.2d
    fadd v5.2d,v5.2d,v2.2d
    str q4,[x26,x9]
    str q5,[x27,x9]
    add x9,x9,#16
    add x15,x15,#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lfull_pair
.Lfull_tail:
    cbz x10,.Lend_level
    ldr d0,[x3,x9]
    ldr d3,[x19,x9]
    ldr d1,[x6,x15]
    ldr d2,[x7,x15]
    ldr d4,[x24,x9]
    ldr d5,[x25,x9]
    fmul d0,d0,d3
    fmul d1,d0,d1
    fmul d2,d0,d2
    fadd d4,d4,d1
    fadd d5,d5,d2
    str d4,[x26,x9]
    str d5,[x27,x9]
    b .Lend_level
.Lend_level:
    add x8,x8,x1
    subs x2,x2,#1
    b.ne .Lnext_level
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x19,x20,[sp],#80
.Lreturn:
    ret
.size gpgrp_,.-gpgrp_
.section .note.GNU-stack,"",%progbits

/* Complete shortwave band-26 scattering from the frozen Markdown contract.
 * x0..x7 hold TDIMV, bounds, layers, column, tropopause, solar and absorption.
 * Incoming stack bytes 0 and 8 hold Rayleigh and solar cosine pointers.
 * Columns have units 10^20 molecules/cm^2. Rayleigh depth is dimensionless.
 * The coefficient arrays are read-only globals with 16 slots and 6 active slots.
 * Complete night, extra-layer and unused-slot storage remains unchanged.
 * A checked all-day path traverses contiguous independent cell prefixes.
 * Bounded four-cell, two-cell and scalar tails retain full capacities.
 * The 96-byte frame preserves x19..x30. d8..d15 and x18 remain untouched. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL srtm_taumol26_
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    stp x29,x30,[sp,#-96]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldp x22,x23,[sp,#96]
    ldrsw x19,[x2]
    ldrsw x8,[x1]
    sub x19,x19,x8
    add x19,x19,#1
    ldrsw x20,[x3]
    ldrsw x21,[x0]
    cbz x19,.Lreturn
    cbz x20,.Lreturn
    adrp x24,:got:__yoesrta26_MOD_raylc
    ldr x24,[x24,:got_lo12:__yoesrta26_MOD_raylc]
    adrp x25,:got:__yoesrta26_MOD_sfluxrefc
    ldr x25,[x25,:got_lo12:__yoesrta26_MOD_sfluxrefc]
    cmp x19,#2
    b.lo .Lscalar_start
    mov x26,#0
/* Establish a complete daylight prefix with defined solar values. */
.Lscan_day:
    ldr d3,[x23,x26,lsl #3]
    fcmp d3,#0.0
    b.le .Lscalar_start
    ldr w9,[x5,x26,lsl #2]
    cmp w9,#1
    b.lo .Lscalar_start
    cmp w9,w20
    b.hi .Lscalar_start
    add x26,x26,#1
    cmp x26,x19
    b.lo .Lscan_day
    mul x1,x19,x20
    mul x2,x19,x21
    lsl x2,x2,#3
    lsl x3,x19,#3
    movi v0.2d,#0
    mov x26,#0
/* A spectral plane has a contiguous active cell prefix. */
.Lvector_point:
    ldr d2,[x24,x26,lsl #3]
    dup v2.2d,v2.d[0]
    ldr d3,[x25,x26,lsl #3]
    dup v3.2d,v3.d[0]
    mov x11,x6
    mov x27,x19
.Lsolar_four:
    cmp x27,#4
    b.lo .Lsolar_two
    stp q3,q3,[x11],#32
    sub x27,x27,#4
    b .Lsolar_four
.Lsolar_two:
    cmp x27,#2
    b.lo .Lsolar_one
    str q3,[x11],#16
    sub x27,x27,#2
.Lsolar_one:
    cbz x27,.Lsolar_finished
    str d3,[x11]
.Lsolar_finished:
    mov x28,x4
    mov x8,x7
    mov x9,x22
    mov x27,x1
.Lcells_eight:
    cmp x27,#8
    b.lo .Lcells_four
    ldp q4,q5,[x28],#32
    ldp q6,q7,[x28],#32
    fmul v4.2d,v4.2d,v2.2d
    fmul v5.2d,v5.2d,v2.2d
    fmul v6.2d,v6.2d,v2.2d
    fmul v7.2d,v7.2d,v2.2d
    stp q0,q0,[x8],#32
    stp q0,q0,[x8],#32
    stp q4,q5,[x9],#32
    stp q6,q7,[x9],#32
    sub x27,x27,#8
    b .Lcells_eight
.Lcells_four:
    cmp x27,#4
    b.lo .Lcells_two
    ldp q4,q5,[x28],#32
    fmul v4.2d,v4.2d,v2.2d
    fmul v5.2d,v5.2d,v2.2d
    stp q0,q0,[x8],#32
    stp q4,q5,[x9],#32
    sub x27,x27,#4
    b .Lcells_four
.Lcells_two:
    cmp x27,#2
    b.lo .Lcells_one
    ldr q4,[x28],#16
    fmul v4.2d,v4.2d,v2.2d
    str q0,[x8],#16
    str q4,[x9],#16
    sub x27,x27,#2
.Lcells_one:
    cbz x27,.Lvector_next_point
    ldr d4,[x28]
    fmul d4,d4,d2
    str xzr,[x8]
    str d4,[x9]
.Lvector_next_point:
    add x6,x6,x3
    add x7,x7,x2
    add x22,x22,x2
    add x26,x26,#1
    cmp x26,#6
    b.lo .Lvector_point
    b .Lreturn
.Lscalar_start:
    mov x26,#0
.Lcolumn:
    ldr d3,[x23,x26,lsl #3]
    fcmp d3,#0.0
    b.le .Lnext_column
    ldr w9,[x5,x26,lsl #2]
    mov x27,#0
.Llayer:
    madd x10,x27,x19,x26
    ldr d0,[x4,x10,lsl #3]
    add x8,x27,#1
    mov x28,#0
.Lpoint:
    madd x11,x28,x21,x27
    madd x11,x11,x19,x26
    ldr d1,[x24,x28,lsl #3]
    fmul d2,d0,d1
    str xzr,[x7,x11,lsl #3]
    str d2,[x22,x11,lsl #3]
    cmp w9,w8
    b.ne .Lnext_point
    madd x12,x28,x19,x26
    ldr x13,[x25,x28,lsl #3]
    str x13,[x6,x12,lsl #3]
.Lnext_point:
    add x28,x28,#1
    cmp x28,#6
    b.lo .Lpoint
    add x27,x27,#1
    cmp x27,x20
    b.lo .Llayer
.Lnext_column:
    add x26,x26,#1
    cmp x26,x19
    b.lo .Lcolumn
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#96
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

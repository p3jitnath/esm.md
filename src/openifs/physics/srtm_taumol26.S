/* Complete shortwave band-26 scattering from the frozen Markdown contract.
 * x0..x7 hold TDIMV, bounds, layers, column, tropopause, solar and absorption.
 * Incoming stack bytes 0 and 8 hold Rayleigh and solar cosine pointers.
 * Columns have units 10^20 molecules/cm^2. Rayleigh depth is dimensionless.
 * The coefficient arrays are read-only globals with 16 slots and 6 active slots.
 * Complete night, extra-layer and unused-slot storage remains unchanged.
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

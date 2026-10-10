/* Complete longwave fluxes when no layer scatters radiation.
 * Physics is formulations/openifs/physics/longwave_adding.md.
 * Ordered ABI is skills/md2asm/references/openifs/physics/calc_fluxes_no_scattering_lw.md.
 * x0..x7 hold eight pointers. Caller-stack offset zero holds flux_dn.
 * Each FP64 product rounds before its addition. Fluxes have units W/m^2.
 * The 96-byte frame preserves x19..x30. x18 and d8..d15 stay untouched.
 * Two independent lanes and a scalar remainder need no numerical scratch. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_adding_ica_lw_MOD_calc_fluxes_no_scattering_lw
#endif
.text
.p2align 2
.macro LWLD reg,base,index,width
    add x3,\base,\index
.if \width == 2
    ldr q\reg,[x3]
.else
    ldr d\reg,[x3]
.endif
.endm
.macro LWST reg,base,index,width
    add x3,\base,\index
.if \width == 2
    str q\reg,[x3]
.else
    str d\reg,[x3]
.endif
.endm
.macro LWMUL dst,lhs,rhs,width
.if \width == 2
    fmul v\dst\().2d,v\lhs\().2d,v\rhs\().2d
.else
    fmul d\dst,d\lhs,d\rhs
.endif
.endm
.macro LWADD dst,lhs,rhs,width
.if \width == 2
    fadd v\dst\().2d,v\lhs\().2d,v\rhs\().2d
.else
    fadd d\dst,d\lhs,d\rhs
.endif
.endm
.macro LWGROUP width
    movi v0.2d,#0
    mov x1,x0
    mov x2,#0
    LWST 0,x22,x1,\width
.Ldown\@:
    cmp x2,x20
    b.hs .Lsurface\@
    LWLD 1,x24,x1,\width
    LWLD 2,x26,x1,\width
    LWMUL 0,1,0,\width
    LWADD 0,0,2,\width
    add x1,x1,x21
    LWST 0,x22,x1,\width
    add x2,x2,#1
    b .Ldown\@
.Lsurface\@:
    LWLD 3,x27,x0,\width
    LWLD 4,x28,x0,\width
    LWMUL 5,4,0,\width
    LWADD 5,3,5,\width
    LWST 5,x23,x1,\width
    mov x2,x20
.Lup\@:
    cbz x2,.Lfinished\@
    sub x2,x2,#1
    sub x1,x1,x21
    LWLD 1,x24,x1,\width
    LWLD 2,x25,x1,\width
    LWMUL 5,1,5,\width
    LWADD 5,5,2,\width
    LWST 5,x23,x1,\width
    b .Lup\@
.Lfinished\@:
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    stp x29,x30,[sp,#-96]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldrsw x19,[x0]
    ldrsw x20,[x1]
    mov x24,x2
    mov x25,x3
    mov x26,x4
    mov x27,x5
    mov x28,x6
    mov x23,x7
    ldr x22,[sp,#96]
    lsl x21,x19,#3
    mov x0,#0
    cbz x19,.Lreturn
    cmp x19,#2
    b.lo .Lscalar
.Lpair:
    LWGROUP 2
    add x0,x0,#16
    sub x4,x21,x0
    cmp x4,#16
    b.hs .Lpair
    cbz x4,.Lreturn
.Lscalar:
    LWGROUP 1
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

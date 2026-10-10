/* Complete band-25 water/ozone absorption and molecular scattering.
 * All 19 pointer arguments follow the frozen Markdown contract.
 * The first eight use x0..x7. Eleven more use incoming stack bytes 0..80.
 * All columns use 10^20 molecules/cm^2. Returned optical depths are dimensionless.
 * The 256-byte frame saves x19..x30 and stores the complete argument pointers.
 * d8..d15 and x18 remain untouched. Only declared coefficient globals are read.
 * Solar selection preserves increasing lower-layer order for each column. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL srtm_taumol25_
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    stp x29,x30,[sp,#-256]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldp x9,x10,[sp,#256]
    stp x9,x10,[sp,#160]
    ldp x9,x10,[sp,#272]
    stp x9,x10,[sp,#176]
    ldp x9,x10,[sp,#288]
    stp x9,x10,[sp,#192]
    ldp x9,x10,[sp,#304]
    stp x9,x10,[sp,#208]
    ldp x9,x10,[sp,#320]
    stp x9,x10,[sp,#224]
    ldr x9,[sp,#336]
    str x9,[sp,#240]
    ldrsw x19,[x2]
    ldrsw x11,[x1]
    sub x19,x19,x11
    add x19,x19,#1
    ldrsw x20,[x3]
    ldrsw x21,[x0]
    cbz x19,.Lreturn25
    cbz x20,.Lreturn25
    ldr x22,[sp,#160]
    ldr x23,[sp,#208]
    ldr x24,[sp,#240]
    ldr x25,[sp,#224]
    ldr x26,[sp,#232]
    ldr x27,[sp,#216]
    adrp x28,:got:yoesrta25.eq.0_
    ldr x28,[x28,:got_lo12:yoesrta25.eq.0_]
    adrp x7,:got:__yoesrta25_MOD_raylc
    ldr x7,[x7,:got_lo12:__yoesrta25_MOD_raylc]
    adrp x8,:got:__yoesrta25_MOD_sfluxrefc
    ldr x8,[x8,:got_lo12:__yoesrta25_MOD_sfluxrefc]
    adrp x9,:got:__yoesrta25_MOD_abso3ac
    ldr x9,[x9,:got_lo12:__yoesrta25_MOD_abso3ac]
    adrp x10,:got:__yoesrta25_MOD_abso3bc
    ldr x10,[x10,:got_lo12:__yoesrta25_MOD_abso3bc]
    adrp x11,:got:__yoesrta25_MOD_layreffr
    ldr x11,[x11,:got_lo12:__yoesrta25_MOD_layreffr]
    ldr w6,[x11]
    adrp x11,:got:__yoesrtwn_MOD_nspa
    ldr x11,[x11,:got_lo12:__yoesrtwn_MOD_nspa]
    ldr w11,[x11,#36]
    str w11,[sp,#248]
    mov x0,#0
.Lcolumn25:
    ldr d24,[x24,x0,lsl #3]
    fcmp d24,#0.0
    b.le .Lnext_column25
    ldr w4,[x23,x0,lsl #2]
    mov w5,w4
    mov x1,#0
.Llayer25:
    madd x3,x1,x19,x0
    ldr x11,[sp,#192]
    ldr d5,[x11,x3,lsl #3]
    ldr x11,[sp,#200]
    ldr d6,[x11,x3,lsl #3]
    cmp x1,x4
    b.hs .Lupper25
    ldr w11,[x22,x3,lsl #2]
    cmp w11,w6
    b.ge .Lno_cross25
    add x12,x3,x19
    ldr w12,[x22,x12,lsl #2]
    cmp w12,w6
    b.lt .Lno_cross25
    add w5,w1,#2
    cmp w5,w4
    csel w5,w5,w4,lo
.Lno_cross25:
    ldr x12,[sp,#168]
    ldr w12,[x12,x3,lsl #2]
    sub w15,w11,#1
    mov w13,#5
    mul w15,w15,w13
    sub w12,w12,#1
    add w15,w15,w12
    ldr w14,[sp,#248]
    mul w15,w15,w14
    ldr x12,[sp,#176]
    ldr w12,[x12,x3,lsl #2]
    mul w16,w11,w13
    sub w12,w12,#1
    add w16,w16,w12
    mul w16,w16,w14
    ldr x11,[sp,#128]
    ldr d0,[x11,x3,lsl #3]
    ldr x11,[sp,#144]
    ldr d1,[x11,x3,lsl #3]
    ldr x11,[sp,#136]
    ldr d2,[x11,x3,lsl #3]
    ldr x11,[sp,#152]
    ldr d3,[x11,x3,lsl #3]
    ldr x11,[sp,#184]
    ldr d4,[x11,x3,lsl #3]
    mov x2,#0
.Llower_point25:
    mov x11,#65
    madd x11,x2,x11,x15
    ldr d7,[x28,x11,lsl #3]
    fmul d16,d0,d7
    add x12,x11,#1
    ldr d7,[x28,x12,lsl #3]
    fmul d17,d1,d7
    fadd d20,d16,d17
    mov x11,#65
    madd x11,x2,x11,x16
    ldr d7,[x28,x11,lsl #3]
    fmul d18,d2,d7
    fadd d20,d20,d18
    add x12,x11,#1
    ldr d7,[x28,x12,lsl #3]
    fmul d19,d3,d7
    fadd d20,d20,d19
    fmul d21,d4,d20
    ldr d7,[x9,x2,lsl #3]
    fmul d22,d6,d7
    fadd d21,d21,d22
    ldr d7,[x7,x2,lsl #3]
    fmul d23,d5,d7
    madd x17,x2,x21,x1
    madd x17,x17,x19,x0
    str d21,[x25,x17,lsl #3]
    str d23,[x26,x17,lsl #3]
    add w11,w1,#1
    cmp w11,w5
    b.ne .Lnext_lower_point25
    madd x12,x2,x19,x0
    ldr x13,[x8,x2,lsl #3]
    str x13,[x27,x12,lsl #3]
.Lnext_lower_point25:
    add x2,x2,#1
    cmp x2,#6
    b.lo .Llower_point25
    b .Lnext_layer25
.Lupper25:
    mov x2,#0
.Lupper_point25:
    ldr d7,[x10,x2,lsl #3]
    fmul d21,d6,d7
    ldr d7,[x7,x2,lsl #3]
    fmul d23,d5,d7
    madd x17,x2,x21,x1
    madd x17,x17,x19,x0
    str d21,[x25,x17,lsl #3]
    str d23,[x26,x17,lsl #3]
    add x2,x2,#1
    cmp x2,#6
    b.lo .Lupper_point25
.Lnext_layer25:
    add x1,x1,#1
    cmp x1,x20
    b.lo .Llayer25
.Lnext_column25:
    add x0,x0,#1
    cmp x0,x19
    b.lo .Lcolumn25
.Lreturn25:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#256
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

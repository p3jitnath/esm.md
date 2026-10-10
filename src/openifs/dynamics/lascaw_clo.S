/* Complete longitude cubic, lower-order, SLHD and turbulence weights.
 * Fourteen ordinary pointers follow the Arm ABI. Rows vary fastest.
 * The three full output views have B*L*3 real values without units.
 * Native numerical work uses separate binary64 operations and no helper.
 * Canonical flags are checked before reading other arguments. Masks 1 and 9
 * have undefined original low-order weights and return without execution.
 * The primary uses no stack, x18 or callee-saved general/FP register.
 */
#ifndef LASCAW_CLO_ENTRY
#define LASCAW_CLO_ENTRY lascaw_clo_assembly_
#endif
.text
.p2align 4
.global LASCAW_CLO_ENTRY
.type LASCAW_CLO_ENTRY,%function
/* Source expression products keep each intermediate binary64 rounding.
 * Reuse identical rounded x+1, x-1 and x-2 values within a triple. */
.macro CUBIC
    fadd d0,d7,d31
    fsub d1,d7,d31
    fmov d4,#2.0
    fsub d2,d7,d4
    fmul d16,d30,d0
    fmul d16,d16,d1
    fmul d16,d16,d2
    fmul d17,d29,d0
    fmul d17,d17,d7
    fmul d17,d17,d2
    fmul d18,d26,d0
    fmul d18,d18,d7
    fmul d18,d18,d1
.endm
/* Finish a whole triple before overwriting any source component.
 * The turbulence second row adds its diagonal product first. */
.macro TURB a,b,c
    fmov d0,#2.0
    fmul d4,d0,d7
    fsub d4,d31,d4
    fmul d4,d4,\a
    fmul d19,d7,\b
    fadd d4,d4,d19
    fmul d5,d0,d7
    fsub d5,d31,d5
    fmul d5,d5,\b
    fmul d19,d7,\a
    fadd d5,d5,d19
    fmul d6,d7,\b
    fadd d6,d6,\c
    fmov \a,d4
    fmov \b,d5
    fmov \c,d6
.endm
LASCAW_CLO_ENTRY:
    ldp w8,w9,[x5]
    ldp w10,w11,[x5,#8]
    cmp w8,#1
    b.hi .Lreturn
    cmp w9,#1
    b.hi .Lreturn
    cmp w10,#1
    b.hi .Lreturn
    cmp w11,#1
    b.hi .Lreturn
    orr w14,w8,w9,lsl #1
    orr w14,w14,w10,lsl #2
    orr w14,w14,w11,lsl #3
    and w15,w14,#7
    cmp w15,#1
    b.eq .Lreturn
    fmov d31,#1.0
    fmov d30,#0.5
    fmov d29,#-0.5
    fmov d28,#0.25
    fmov d27,#1.25
    adrp x16,.Lone_sixth
    ldr d26,[x16,:lo12:.Lone_sixth]
    ldr d25,[x0,#136]
    fmov d7,#2.0
    fmul d24,d7,d25
    fsub d24,d31,d24
    tbz w14,#0,.Lno_slhd_parameters
    ldr d23,[x0,#120]
    ldr d22,[x0,#128]
.Lno_slhd_parameters:
    tst w14,#3
    b.eq .Lno_minimum
    ldr d21,[x6]
.Lno_minimum:
    mov w5,w14
    ldr w16,[x1]
    ldr w17,[x2]
    ldr w1,[x3]
    ldr w4,[x4]
    cmp w16,#0
    b.le .Lreturn
    cmp w4,w1
    b.lt .Lreturn
    sub w2,w1,#1
    lsl x6,x2,#3
    sub w1,w4,w1
    add w1,w1,#1
    umull x14,w17,w16
    lsl x14,x14,#3
    sub w3,w17,w1
    lsl x3,x3,#3
    mov w2,w16
    ldp x8,x9,[sp]
    ldp x10,x11,[sp,#16]
    ldp x12,x13,[sp,#32]
    add x7,x7,x6
    add x8,x8,x6
    add x9,x9,x6
    add x10,x10,x6
    add x11,x11,x6
    add x12,x12,x6
    add x13,x13,x6
.Llevel:
    mov w15,w1
.Lpoint:
    ldr d7,[x8]
    CUBIC
    str d16,[x12]
    str d17,[x12,x14]
    add x0,x12,x14
    str d18,[x0,x14]
    ldr d7,[x7]
    CUBIC
    tbz w5,#1,.Lnot_quadratic
    fsub d19,d31,d7
    fmul d4,d28,d7
    fadd d4,d31,d4
    fmul d19,d19,d4
    fmul d20,d28,d7
    fsub d20,d27,d20
    fmul d20,d7,d20
    fmul d0,d28,d7
    fsub d4,d7,d31
    fmul d0,d0,d4
    b .Llow_order_done
.Lnot_quadratic:
    tbz w5,#2,.Llow_order_done
    fmov d20,d7
    fsub d19,d31,d20
    fmov d0,xzr
.Llow_order_done:
    tbz w5,#0,.Lwithout_slhd
    ldr d7,[x9]
    fmov x0,d7
    and x0,x0,#0x8000000000000000
    orr x0,x0,#0x3fe0000000000000
    fmov d4,x0
    fadd d1,d30,d4
    fmul d1,d1,d21
    fsub d2,d4,d30
    fmul d2,d2,d22
    fsub d3,d1,d2
    fsub d19,d19,d16
    fsub d20,d20,d17
    fsub d0,d0,d18
    fmul d4,d23,d19
    fadd d4,d16,d4
    fmul d5,d23,d20
    fadd d5,d17,d5
    fmul d6,d23,d0
    fadd d6,d18,d6
    fmul d1,d3,d19
    fadd d16,d16,d1
    fmul d1,d3,d20
    fadd d17,d17,d1
    fmul d1,d3,d0
    fadd d18,d18,d1
    fmul d1,d24,d4
    fmul d19,d25,d5
    fadd d1,d1,d19
    fmul d2,d25,d4
    fmul d19,d24,d5
    fadd d2,d2,d19
    fmul d3,d25,d5
    fadd d3,d3,d6
    fabs d7,d7
    fsub d1,d1,d16
    fmul d1,d7,d1
    fadd d1,d16,d1
    fsub d2,d2,d17
    fmul d2,d7,d2
    fadd d2,d17,d2
    fsub d3,d3,d18
    fmul d3,d7,d3
    fadd d3,d18,d3
    b .Lfinal_turbulence
.Lwithout_slhd:
    tbz w5,#1,.Lsame_main_sets
    fsub d19,d19,d16
    fmul d19,d21,d19
    fadd d16,d16,d19
    fsub d20,d20,d17
    fmul d20,d21,d20
    fadd d17,d17,d20
    fsub d0,d0,d18
    fmul d0,d21,d0
    fadd d18,d18,d0
.Lsame_main_sets:
    fmov d1,d16
    fmov d2,d17
    fmov d3,d18
.Lfinal_turbulence:
    tbz w5,#3,.Lstore
    ldr d7,[x10]
    TURB d16,d17,d18
    TURB d1,d2,d3
.Lstore:
    str d16,[x11]
    str d17,[x11,x14]
    add x0,x11,x14
    str d18,[x0,x14]
    str d1,[x13]
    str d2,[x13,x14]
    add x0,x13,x14
    str d3,[x0,x14]
    add x7,x7,#8
    add x8,x8,#8
    add x9,x9,#8
    add x10,x10,#8
    add x11,x11,#8
    add x12,x12,#8
    add x13,x13,#8
    subs w15,w15,#1
    b.ne .Lpoint
    add x7,x7,x3
    add x8,x8,x3
    add x9,x9,x3
    add x10,x10,x3
    add x11,x11,x3
    add x12,x12,x3
    add x13,x13,x3
    subs w2,w2,#1
    b.ne .Llevel
.Lreturn:
    ret
.size LASCAW_CLO_ENTRY,.-LASCAW_CLO_ENTRY
.section .rodata
.p2align 3
.Lone_sixth:
    .quad 0x3fc5555555555555
#ifdef LASCAW_CLO_ABI_CHECK
.text
.p2align 4
.global lascaw_clo_abi_invoke
.type lascaw_clo_abi_invoke,%function
lascaw_clo_abi_invoke:
    sub sp,sp,#64
    str x30,[sp,#48]
    mov x9,x0
    ldp x0,x1,[x9]
    ldp x2,x3,[x9,#16]
    ldp x4,x5,[x9,#32]
    ldp x6,x7,[x9,#48]
    ldp x10,x11,[x9,#64]
    stp x10,x11,[sp]
    ldp x10,x11,[x9,#80]
    stp x10,x11,[sp,#16]
    ldp x10,x11,[x9,#96]
    stp x10,x11,[sp,#32]
    bl LASCAW_CLO_ENTRY
    ldr x30,[sp,#48]
    add sp,sp,#64
    ret
.size lascaw_clo_abi_invoke,.-lascaw_clo_abi_invoke
#endif
.section .note.GNU-stack,"",%progbits

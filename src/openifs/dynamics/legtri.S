/* Physics input formulations/openifs/dynamics/associated_legendre_basis.md.
 * Ordered recurrence skills/md2asm/references/openifs/dynamics/legtri.md.
 * Four addresses supply sine(latitude), order count, owner length and output.
 * The leaf preserves all Arm callee registers and leaves SP and FPCR unchanged.
 */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL legtri_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.global md2asm_legtri
.type ORIGINAL_SYMBOL,%function
.type md2asm_legtri,%function
ORIGINAL_SYMBOL:
md2asm_legtri:
    mrs x9,fpcr
    cbnz x9,.Lreturn
    ldr w4,[x1]
    cmp w4,#2
    b.lt .Lreturn
    cmp w4,#256
    b.gt .Lreturn
    ldr w5,[x2]
    add w9,w4,#1
    mul w9,w9,w4
    lsr w9,w9,#1
    cmp w5,w9
    b.lt .Lreturn
    mov w10,#1048576
    cmp w5,w10
    b.gt .Lreturn
    ldr d0,[x0]
    fabs d27,d0
    fmov d7,#1.0
    fcmp d27,d7
    b.vs .Lreturn
    b.gt .Lreturn
    sub w5,w4,#1
    fmul d27,d0,d0
    fsub d1,d7,d27
    fsqrt d1,d1
    str d7,[x3]
    fmov d16,#3.0
    fsqrt d2,d16
    fmul d27,d2,d0
    str d27,[x3,#8]
    mov w6,#1
    mov w7,#0
    fmov d26,#4.0
.Lorder:
    scvtf d5,w7
    fmul d6,d5,d5
    fadd d18,d5,d5
    fadd d3,d18,d16
    fsqrt d3,d3
    fdiv d4,d7,d3
    cbz w7,.Ldegrees
    fmul d20,d2,d1
    fsqrt d19,d18
    fdiv d20,d20,d19
    fmul d2,d20,d3
    add w6,w6,#1
    str d20,[x3,w6,uxtw #3]
    cmp w7,w5
    b.eq .Lnext_order
    add w6,w6,#1
    fmul d27,d2,d0
    str d27,[x3,w6,uxtw #3]
.Ldegrees:
    add w8,w7,#2
    cmp w8,w5
    b.gt .Lnext_order
.Ldegree:
    scvtf d21,w8
    fmul d21,d21,d21
    fmul d22,d26,d21
    fsub d22,d22,d7
    fsub d25,d21,d6
    fdiv d22,d22,d25
    fsqrt d22,d22
    add w6,w6,#1
    sub w9,w6,#1
    ldr d23,[x3,w9,uxtw #3]
    sub w9,w6,#2
    ldr d24,[x3,w9,uxtw #3]
    fmul d23,d0,d23
    fmul d24,d4,d24
    fsub d23,d23,d24
    fmul d23,d22,d23
    str d23,[x3,w6,uxtw #3]
    fdiv d4,d7,d22
    add w8,w8,#1
    cmp w8,w5
    b.le .Ldegree
.Lnext_order:
    add w7,w7,#1
    cmp w7,w4
    b.lt .Lorder
.Lreturn:
    ret
.size md2asm_legtri,.-md2asm_legtri
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

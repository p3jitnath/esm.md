/* Direct spline coordinate and polynomial leaves from SUVFE_HLP.
 * Contract: skills/md2asm/references/openifs/setup/spline_polynomial_contract.md. Scalars are addresses; arrays raw.
 * All storage is caller-owned. No stack, external calls or x18 use.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_coordinate_from_local
.type md2asm_spline_coordinate_from_local,%function
md2asm_spline_coordinate_from_local:
    ldr d0,[x0]
    ldr d1,[x1]
    ldr d2,[x2]
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    ret
.size md2asm_spline_coordinate_from_local,.-md2asm_spline_coordinate_from_local

.p2align 4
.global md2asm_spline_sample_position
.type md2asm_spline_sample_position,%function
md2asm_spline_sample_position:
    ldr w9,[x0]
    ldr w10,[x1]
    sub w9,w9,#1
    sub w10,w10,#1
    scvtf d0,w10
    scvtf d1,w9
    fdiv d0,d0,d1
    ldp d1,d2,[x2]
    fsub d2,d2,d1
    fmul d0,d0,d2
    fadd d0,d1,d0
    ret
.size md2asm_spline_sample_position,.-md2asm_spline_sample_position

.p2align 4
.global md2asm_spline_polynomial_evaluate
.type md2asm_spline_polynomial_evaluate,%function
md2asm_spline_polynomial_evaluate:
    ldr w9,[x0]
    ldr d1,[x2]
    sub w9,w9,#1
    ldr d0,[x1,x9,lsl #3]
.Levaluate:
    sub w9,w9,#1
    ldr d2,[x1,x9,lsl #3]
    fmul d0,d1,d0
    fadd d0,d0,d2
    cbnz w9,.Levaluate
    ret
.size md2asm_spline_polynomial_evaluate,.-md2asm_spline_polynomial_evaluate

.p2align 4
.global md2asm_spline_polynomial_derivative
.type md2asm_spline_polynomial_derivative,%function
md2asm_spline_polynomial_derivative:
    ldr w9,[x0]
    mov x10,#1
.Lderivative:
    ldr d0,[x1,x10,lsl #3]
    scvtf d1,w10
    fmul d0,d0,d1
    sub x11,x10,#1
    str d0,[x3,x11,lsl #3]
    add x10,x10,#1
    cmp w10,w9
    b.lt .Lderivative
    ret
.size md2asm_spline_polynomial_derivative,.-md2asm_spline_polynomial_derivative

.p2align 4
.global md2asm_spline_polynomial_integral
.type md2asm_spline_polynomial_integral,%function
md2asm_spline_polynomial_integral:
    ldr w9,[x0]
    ldr d0,[x2]
    str d0,[x4]
    mov x10,#0
.Lintegral:
    ldr d0,[x1,x10,lsl #3]
    add x11,x10,#1
    scvtf d1,w11
    fdiv d0,d0,d1
    str d0,[x4,x11,lsl #3]
    add x10,x10,#1
    cmp w10,w9
    b.lt .Lintegral
    ret
.size md2asm_spline_polynomial_integral,.-md2asm_spline_polynomial_integral

.p2align 4
.global md2asm_spline_polynomial_product
.type md2asm_spline_polynomial_product,%function
md2asm_spline_polynomial_product:
    ldr w9,[x0]
    ldr w10,[x2]
    ldr w11,[x4]
    sub w9,w9,#1
    sub w10,w10,#1
    mov x12,#0
.Lproduct_coefficient:
    fmov d0,xzr
    mov x13,#0
.Lproduct_term:
    sub x14,x12,x13
    cmp w13,w9
    b.gt .Lproduct_skip
    cmp w14,w10
    b.gt .Lproduct_skip
    ldr d1,[x1,x13,lsl #3]
    ldr d2,[x3,x14,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
.Lproduct_skip:
    add x13,x13,#1
    cmp x13,x12
    b.le .Lproduct_term
    str d0,[x5,x12,lsl #3]
    add x12,x12,#1
    cmp w12,w11
    b.lt .Lproduct_coefficient
    ret
.size md2asm_spline_polynomial_product,.-md2asm_spline_polynomial_product
.section .note.GNU-stack,"",%progbits

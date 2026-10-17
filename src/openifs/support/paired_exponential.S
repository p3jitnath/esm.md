// Contract skills/md2asm/references/openifs/support/scalar_exponential.md.
// FPCR must be zero. The private interface is recorded in that contract.
/* Two independent EXP values with the scalar body's ordered rounding.
 * v0.2d supplies and returns two FP64 values. w0 is zero on success and
 * one on refusal. Refusal preserves v0, FPCR, FPSR, errno and every counter.
 * Admit exact signed zeros or finite 2^-54 <= abs(x) <512 in both lanes.
 * Full q8..q15/q24..q31, x18 and AAPCS64 saved registers remain unchanged.
 * FPCR zero is a precondition; the helper does not change the hardware mode.
 * Uses frozen md2asm_exp_constants and md2asm_exp_scale_table words. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_try_exp_pair
.type md2asm_try_exp_pair,%function
md2asm_try_exp_pair:
    mov w8,#0
    b md2asm_exp_pair_integer_guard
.size md2asm_try_exp_pair,.-md2asm_try_exp_pair

/* Counted entry arrives with w8=1; both routes share this integer-only guard. */
.global md2asm_exp_pair_integer_guard
.hidden md2asm_exp_pair_integer_guard
.type md2asm_exp_pair_integer_guard,%function
md2asm_exp_pair_integer_guard:
    fmov x9,d0
    umov x10,v0.d[1]
    and x9,x9,#0x7fffffffffffffff
    and x10,x10,#0x7fffffffffffffff
    mov x11,#0x3c90000000000000
    mov x12,#0x4080000000000000
    cbz x9,.Lpair_check_second
    cmp x9,x11
    b.lo .Lpair_refuse
    cmp x9,x12
    b.hs .Lpair_refuse
.Lpair_check_second:
    cbz x10,.Lpair_admit
    cmp x10,x11
    b.lo .Lpair_refuse
    cmp x10,x12
    b.hs .Lpair_refuse
.Lpair_admit:
    cbz w8,.Lpair_raw_admit
    b md2asm_exp_pair_counted_admitted
.Lpair_raw_admit:
    b md2asm_exp_pair_normal_body
.Lpair_refuse:
    mov w0,#1
    ret
.size md2asm_exp_pair_integer_guard,.-md2asm_exp_pair_integer_guard

.global md2asm_exp_pair_normal_body
.hidden md2asm_exp_pair_normal_body
.type md2asm_exp_pair_normal_body,%function
md2asm_exp_pair_normal_body:
    adrp x17,md2asm_exp_constants
    add x17,x17,:lo12:md2asm_exp_constants
    ldp d1,d2,[x17]
    dup v1.2d,v1.d[0]
    dup v2.2d,v2.d[0]
    ldr d3,[x17,#24]
    dup v3.2d,v3.d[0]
    fmul v4.2d,v1.2d,v0.2d
    fadd v4.2d,v4.2d,v3.2d
    fmov x10,d4
    umov x11,v4.d[1]
    fsub v3.2d,v4.2d,v3.2d
    fmul v4.2d,v3.2d,v2.2d
    fadd v4.2d,v0.2d,v4.2d
    ldr d2,[x17,#16]
    dup v2.2d,v2.d[0]
    fmul v5.2d,v3.2d,v2.2d
    fadd v4.2d,v4.2d,v5.2d
    and x12,x10,#127
    and x13,x11,#127
    lsl x12,x12,#4
    lsl x13,x13,#4
    lsl x14,x10,#45
    lsl x15,x11,#45
    adrp x9,md2asm_exp_scale_table
    add x9,x9,:lo12:md2asm_exp_scale_table
    add x12,x9,x12
    add x13,x9,x13
    ldp x0,x1,[x12]
    ldp x2,x3,[x13]
    add x1,x1,x14
    add x3,x3,x15
    fmov d6,x0
    ins v6.d[1],x2
    fmov d23,x1
    ins v23.d[1],x3
    fmul v5.2d,v4.2d,v4.2d
    ldp d16,d17,[x17,#32]
    ldp d18,d19,[x17,#48]
    dup v16.2d,v16.d[0]
    dup v17.2d,v17.d[0]
    dup v18.2d,v18.d[0]
    dup v19.2d,v19.d[0]
    fadd v7.2d,v6.2d,v4.2d
    fmul v20.2d,v4.2d,v17.2d
    fadd v20.2d,v16.2d,v20.2d
    fmul v20.2d,v5.2d,v20.2d
    fadd v7.2d,v7.2d,v20.2d
    fmul v21.2d,v4.2d,v19.2d
    fadd v21.2d,v18.2d,v21.2d
    fmul v22.2d,v5.2d,v5.2d
    fmul v21.2d,v22.2d,v21.2d
    fadd v7.2d,v7.2d,v21.2d
    fmul v6.2d,v23.2d,v7.2d
    fadd v0.2d,v23.2d,v6.2d
    mov w0,#0
    ret
.size md2asm_exp_pair_normal_body,.-md2asm_exp_pair_normal_body
.section .note.GNU-stack,"",%progbits

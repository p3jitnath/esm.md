// Private workers share the accepted arithmetic and complete admission.
// x28 addresses an aligned 64-byte prefix with FAST/WIDE/EXP at 0/8/16.
// Only the EXP word changes. The prefix address and public ABI stay preserved.
#ifdef MD2ASM_SW_PRIVATE_COUNTERS
#define md2asm_try_exp_four_counted md2asm_sw_private_try_exp_four_counted
#endif
// Contract skills/md2asm/references/openifs/support/scalar_exponential.md.
/* Four independent ordinary exponentials with the accepted scalar rounding.
 * q0={a0,a1}, q1={b0,b1}; success w0=0 returns the same lane order.
 * Refusal w0=1 preserves both inputs, FPSR, FPCR, errno and the counter.
 * FPCR=0. Each lane is signed zero or finite 2^-54 <= abs(x) <512.
 * Preserve full q8..q15/q24..q31, x18..x30 and SP. No frame or calls.
 * Counted success adds four to the existing scalar alias counter owner.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_try_exp_four_counted
#ifdef MD2ASM_SW_PRIVATE_COUNTERS
.hidden md2asm_try_exp_four_counted
#endif
.type md2asm_try_exp_four_counted,%function
.macro FOUR_EXP_GUARD reg
    cbz x\reg,.Lfour_exp_guard_next\@
    cmp x\reg,x13
    b.lo .Lfour_exp_refuse
    cmp x\reg,x14
    b.hs .Lfour_exp_refuse
.Lfour_exp_guard_next\@:
.endm
md2asm_try_exp_four_counted:
    fmov x9,d0
    umov x10,v0.d[1]
    fmov x11,d1
    umov x12,v1.d[1]
    and x9,x9,#0x7fffffffffffffff
    and x10,x10,#0x7fffffffffffffff
    and x11,x11,#0x7fffffffffffffff
    and x12,x12,#0x7fffffffffffffff
    mov x13,#0x3c90000000000000
    mov x14,#0x4080000000000000
    FOUR_EXP_GUARD 9
    FOUR_EXP_GUARD 10
    FOUR_EXP_GUARD 11
    FOUR_EXP_GUARD 12
    // Every lane is admitted before the first counter or vector change.
#ifdef MD2ASM_SW_PRIVATE_COUNTERS
    ldr x10,[x28,#16]
    add x10,x10,#4
    str x10,[x28,#16]
#else
    adrp x9,md2asm_exponential_native_calls_storage
    add x9,x9,:lo12:md2asm_exponential_native_calls_storage
    ldr x10,[x9]
    add x10,x10,#4
    str x10,[x9]
#endif
    adrp x17,md2asm_exp_constants
    add x17,x17,:lo12:md2asm_exp_constants
    ld2r {v2.2d,v3.2d},[x17]
    ldr d4,[x17,#24]
    dup v4.2d,v4.d[0]
    fmul v5.2d,v2.2d,v0.2d
    fmul v6.2d,v2.2d,v1.2d
    fadd v5.2d,v5.2d,v4.2d
    fadd v6.2d,v6.2d,v4.2d
    fmov x10,d5
    umov x11,v5.d[1]
    fmov x12,d6
    umov x13,v6.d[1]
    fsub v5.2d,v5.2d,v4.2d
    fsub v6.2d,v6.2d,v4.2d
    fmul v2.2d,v5.2d,v3.2d
    fmul v7.2d,v6.2d,v3.2d
    fadd v0.2d,v0.2d,v2.2d
    fadd v1.2d,v1.2d,v7.2d
    ldr d4,[x17,#16]
    dup v4.2d,v4.d[0]
    fmul v2.2d,v5.2d,v4.2d
    fmul v7.2d,v6.2d,v4.2d
    fadd v0.2d,v0.2d,v2.2d
    fadd v1.2d,v1.2d,v7.2d
    adrp x9,md2asm_exp_scale_table
    add x9,x9,:lo12:md2asm_exp_scale_table
    // Each integer address selects exactly one accepted sixteen-byte table pair.
    and x0,x10,#127
    add x0,x9,x0,lsl#4
    ldp x1,x2,[x0]
    add x2,x2,x10,lsl#45
    fmov d2,x1
    fmov d4,x2
    and x0,x11,#127
    add x0,x9,x0,lsl#4
    ldp x1,x2,[x0]
    add x2,x2,x11,lsl#45
    ins v2.d[1],x1
    ins v4.d[1],x2
    and x0,x12,#127
    add x0,x9,x0,lsl#4
    ldp x1,x2,[x0]
    add x2,x2,x12,lsl#45
    fmov d3,x1
    fmov d5,x2
    and x0,x13,#127
    add x0,x9,x0,lsl#4
    ldp x1,x2,[x0]
    add x2,x2,x13,lsl#45
    ins v3.d[1],x1
    ins v5.d[1],x2
    fmul v6.2d,v0.2d,v0.2d
    fmul v7.2d,v1.2d,v1.2d
    add x17,x17,#32
    ld2r {v16.2d,v17.2d},[x17],#16
    ld2r {v18.2d,v19.2d},[x17]
    fadd v20.2d,v2.2d,v0.2d
    fadd v21.2d,v3.2d,v1.2d
    fmul v22.2d,v0.2d,v17.2d
    fmul v23.2d,v1.2d,v17.2d
    fadd v22.2d,v16.2d,v22.2d
    fadd v23.2d,v16.2d,v23.2d
    fmul v22.2d,v6.2d,v22.2d
    fmul v23.2d,v7.2d,v23.2d
    fadd v20.2d,v20.2d,v22.2d
    fadd v21.2d,v21.2d,v23.2d
    fmul v22.2d,v0.2d,v19.2d
    fmul v23.2d,v1.2d,v19.2d
    fadd v22.2d,v18.2d,v22.2d
    fadd v23.2d,v18.2d,v23.2d
    fmul v6.2d,v6.2d,v6.2d
    fmul v7.2d,v7.2d,v7.2d
    fmul v22.2d,v6.2d,v22.2d
    fmul v23.2d,v7.2d,v23.2d
    fadd v20.2d,v20.2d,v22.2d
    fadd v21.2d,v21.2d,v23.2d
    fmul v22.2d,v4.2d,v20.2d
    fmul v23.2d,v5.2d,v21.2d
    fadd v0.2d,v4.2d,v22.2d
    fadd v1.2d,v5.2d,v23.2d
    mov w0,#0
    ret
.Lfour_exp_refuse:
    mov w0,#1
    ret
.size md2asm_try_exp_four_counted,.-md2asm_try_exp_four_counted
.section .note.GNU-stack,"",%progbits

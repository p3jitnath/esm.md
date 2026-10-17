// Private workers share the accepted arithmetic and complete admission.
// x28 addresses an aligned 64-byte prefix with FAST/WIDE/EXP at 0/8/16.
// Only the EXP word changes. The prefix address and public ABI stay preserved.
#ifdef MD2ASM_SW_PRIVATE_COUNTERS
#define md2asm_try_exp_eight_counted md2asm_sw_private_try_exp_eight_counted
#endif
// Contract skills/md2asm/references/openifs/support/scalar_exponential.md.
/* Eight independent ordinary EXP values use the accepted per-lane FP64 tree.
 * q0..q3 hold four input pairs and the same result order; w0 is 0 on success.
 * FPCR zero is required. Every lane is signed zero or finite with
 * 2^-54 <= abs(x) <512. Refusal returns w0=1 without changing the inputs,
 * FPSR, FPCR, errno or the shared count. The complete guard precedes effects.
 * Preserve full q8..q15, x18..x30 and SP. q0..q7/q16..q31, x0..x17
 * and NZCV are private scratch. There is no frame, service or child call. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_try_exp_eight_counted
.hidden md2asm_try_exp_eight_counted
.type md2asm_try_exp_eight_counted,%function
.macro EIGHT_EXP_GUARD reg
 cbz x\reg,.Leight_exp_next\@
 cmp x\reg,x0
 b.lo .Leight_exp_refuse
 cmp x\reg,x1
 b.hs .Leight_exp_refuse
.Leight_exp_next\@:
.endm
md2asm_try_exp_eight_counted:
 fmov x9,d0
 umov x10,v0.d[1]
 fmov x11,d1
 umov x12,v1.d[1]
 fmov x13,d2
 umov x14,v2.d[1]
 fmov x15,d3
 umov x16,v3.d[1]
 and x9,x9,#0x7fffffffffffffff
 and x10,x10,#0x7fffffffffffffff
 and x11,x11,#0x7fffffffffffffff
 and x12,x12,#0x7fffffffffffffff
 and x13,x13,#0x7fffffffffffffff
 and x14,x14,#0x7fffffffffffffff
 and x15,x15,#0x7fffffffffffffff
 and x16,x16,#0x7fffffffffffffff
 mov x0,#0x3c90000000000000
 mov x1,#0x4080000000000000
 EIGHT_EXP_GUARD 9
 EIGHT_EXP_GUARD 10
 EIGHT_EXP_GUARD 11
 EIGHT_EXP_GUARD 12
 EIGHT_EXP_GUARD 13
 EIGHT_EXP_GUARD 14
 EIGHT_EXP_GUARD 15
 EIGHT_EXP_GUARD 16
 // All eight arguments are admitted before the counter or FP tree changes.
#ifdef MD2ASM_SW_PRIVATE_COUNTERS
 ldr x1,[x28,#16]
 add x1,x1,#8
 str x1,[x28,#16]
#else
 adrp x0,md2asm_exponential_native_calls_storage
 add x0,x0,:lo12:md2asm_exponential_native_calls_storage
 ldr x1,[x0]
 add x1,x1,#8
 str x1,[x0]
#endif
 adrp x17,md2asm_exp_constants
 add x17,x17,:lo12:md2asm_exp_constants
 ld2r {v16.2d,v17.2d},[x17]
 ldr d18,[x17,#24]
 dup v18.2d,v18.d[0]
 fmul v20.2d,v16.2d,v0.2d
 fmul v21.2d,v16.2d,v1.2d
 fmul v22.2d,v16.2d,v2.2d
 fmul v23.2d,v16.2d,v3.2d
 fadd v20.2d,v20.2d,v18.2d
 fadd v21.2d,v21.2d,v18.2d
 fadd v22.2d,v22.2d,v18.2d
 fadd v23.2d,v23.2d,v18.2d
 fmov x9,d20
 umov x10,v20.d[1]
 fmov x11,d21
 umov x12,v21.d[1]
 fmov x13,d22
 umov x14,v22.d[1]
 fmov x15,d23
 umov x16,v23.d[1]
 fsub v20.2d,v20.2d,v18.2d
 fsub v21.2d,v21.2d,v18.2d
 fsub v22.2d,v22.2d,v18.2d
 fsub v23.2d,v23.2d,v18.2d
 fmul v4.2d,v20.2d,v17.2d
 fmul v5.2d,v21.2d,v17.2d
 fmul v6.2d,v22.2d,v17.2d
 fmul v7.2d,v23.2d,v17.2d
 fadd v0.2d,v0.2d,v4.2d
 fadd v1.2d,v1.2d,v5.2d
 fadd v2.2d,v2.2d,v6.2d
 fadd v3.2d,v3.2d,v7.2d
 ldr d19,[x17,#16]
 dup v19.2d,v19.d[0]
 fmul v4.2d,v20.2d,v19.2d
 fmul v5.2d,v21.2d,v19.2d
 fmul v6.2d,v22.2d,v19.2d
 fmul v7.2d,v23.2d,v19.2d
 fadd v0.2d,v0.2d,v4.2d
 fadd v1.2d,v1.2d,v5.2d
 fadd v2.2d,v2.2d,v6.2d
 fadd v3.2d,v3.2d,v7.2d
 adrp x8,md2asm_exp_scale_table
 add x8,x8,:lo12:md2asm_exp_scale_table
 // Every LDP selects the same bounded 16-byte table record as scalar EXP.
 and x0,x9,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x9,lsl#45
 fmov d28,x1
 fmov d24,x2
 and x0,x10,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x10,lsl#45
 ins v28.d[1],x1
 ins v24.d[1],x2
 and x0,x11,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x11,lsl#45
 fmov d29,x1
 fmov d25,x2
 and x0,x12,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x12,lsl#45
 ins v29.d[1],x1
 ins v25.d[1],x2
 and x0,x13,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x13,lsl#45
 fmov d30,x1
 fmov d26,x2
 and x0,x14,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x14,lsl#45
 ins v30.d[1],x1
 ins v26.d[1],x2
 and x0,x15,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x15,lsl#45
 fmov d31,x1
 fmov d27,x2
 and x0,x16,#127
 add x0,x8,x0,lsl#4
 ldp x1,x2,[x0]
 add x2,x2,x16,lsl#45
 ins v31.d[1],x1
 ins v27.d[1],x2
 fmul v4.2d,v0.2d,v0.2d
 fmul v5.2d,v1.2d,v1.2d
 fmul v6.2d,v2.2d,v2.2d
 fmul v7.2d,v3.2d,v3.2d
 add x17,x17,#32
 ld2r {v16.2d,v17.2d},[x17],#16
 ld2r {v18.2d,v19.2d},[x17]
 fadd v28.2d,v28.2d,v0.2d
 fadd v29.2d,v29.2d,v1.2d
 fadd v30.2d,v30.2d,v2.2d
 fadd v31.2d,v31.2d,v3.2d
 fmul v20.2d,v0.2d,v17.2d
 fmul v21.2d,v1.2d,v17.2d
 fmul v22.2d,v2.2d,v17.2d
 fmul v23.2d,v3.2d,v17.2d
 fadd v20.2d,v16.2d,v20.2d
 fadd v21.2d,v16.2d,v21.2d
 fadd v22.2d,v16.2d,v22.2d
 fadd v23.2d,v16.2d,v23.2d
 fmul v20.2d,v4.2d,v20.2d
 fmul v21.2d,v5.2d,v21.2d
 fmul v22.2d,v6.2d,v22.2d
 fmul v23.2d,v7.2d,v23.2d
 fadd v28.2d,v28.2d,v20.2d
 fadd v29.2d,v29.2d,v21.2d
 fadd v30.2d,v30.2d,v22.2d
 fadd v31.2d,v31.2d,v23.2d
 fmul v20.2d,v0.2d,v19.2d
 fmul v21.2d,v1.2d,v19.2d
 fmul v22.2d,v2.2d,v19.2d
 fmul v23.2d,v3.2d,v19.2d
 fadd v20.2d,v18.2d,v20.2d
 fadd v21.2d,v18.2d,v21.2d
 fadd v22.2d,v18.2d,v22.2d
 fadd v23.2d,v18.2d,v23.2d
 fmul v4.2d,v4.2d,v4.2d
 fmul v5.2d,v5.2d,v5.2d
 fmul v6.2d,v6.2d,v6.2d
 fmul v7.2d,v7.2d,v7.2d
 fmul v20.2d,v4.2d,v20.2d
 fmul v21.2d,v5.2d,v21.2d
 fmul v22.2d,v6.2d,v22.2d
 fmul v23.2d,v7.2d,v23.2d
 fadd v28.2d,v28.2d,v20.2d
 fadd v29.2d,v29.2d,v21.2d
 fadd v30.2d,v30.2d,v22.2d
 fadd v31.2d,v31.2d,v23.2d
 fmul v20.2d,v24.2d,v28.2d
 fmul v21.2d,v25.2d,v29.2d
 fmul v22.2d,v26.2d,v30.2d
 fmul v23.2d,v27.2d,v31.2d
 fadd v0.2d,v24.2d,v20.2d
 fadd v1.2d,v25.2d,v21.2d
 fadd v2.2d,v26.2d,v22.2d
 fadd v3.2d,v27.2d,v23.2d
 mov w0,#0
 ret
.Leight_exp_refuse:
 mov w0,#1
 ret
.size md2asm_try_exp_eight_counted,.-md2asm_try_exp_eight_counted
.section .note.GNU-stack,"",%progbits

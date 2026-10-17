// Define MD2ASM_CLOUD_PRIVATE_COUNTERS only for the hidden cloud worker graph.
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
#define md2asm_pow_original_rounding_candidate md2asm_cloud_private_pow
#define md2asm_private_power_coefficient_records md2asm_cloud_private_coefficient_records
#define md2asm_private_power_product_sum_deferred md2asm_cloud_private_power_product_sum_deferred
#define md2asm_private_power_coefficient_product_sum md2asm_cloud_private_power_coefficient_product_sum
#define md2asm_private_power_log_seed_triplet md2asm_cloud_private_power_log_seed_triplet
#define md2asm_private_power_square_residual md2asm_cloud_private_power_square_residual
#define md2asm_private_power_product_rounding_residual md2asm_cloud_private_power_product_rounding_residual
#define md2asm_private_power_exponential_seed_pair md2asm_cloud_private_power_exponential_seed_pair
#define md2asm_private_power_log_polynomial_merge md2asm_cloud_private_power_log_polynomial_merge
#endif
// Algorithm and constants derived from GLIBC 2.38.
// Copyright (C) 2018-2023 Free Software Foundation, Inc.
// SPDX-License-Identifier: LGPL-2.1-or-later
// Direct POWER from the frozen original arithmetic and exact table words.
// Proved-exact coefficient products retain each one-rounding boundary.
// Input: formulations/openifs/support/scalar_power.md.
// Contract: skills/md2asm/references/openifs/support/power_original_rounding.md.
// ABI: d0=x, d1=y, d0=result; FPCR=0; 256-byte frame; sp aligned to 16 bytes.
.arch armv8-a
.text
.p2align 4
.global md2asm_pow_original_rounding_candidate
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
.hidden md2asm_pow_original_rounding_candidate
#endif
.type md2asm_pow_original_rounding_candidate,%function
md2asm_pow_original_rounding_candidate:
 stp x29,x30,[sp,#-256]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov w27,#0
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 fmov d8,d0
 fmov d9,d1
 fmov x21,d0
 fmov x22,d1
 mov w23,#0
 lsr x24,x21,#52
 lsr x25,x22,#52
 sub w0,w24,#1
 cmp w0,#0x7fe
 b.hs .Lmain_special
 and w0,w25,#0x7ff
 sub w0,w0,#0x3be
 cmp w0,#0x80
 b.hs .Lmain_special
 b .Llog
.Lmain_special:
 lsl x0,x22,#1
 cbz x0,.Ly_zero
 mov x1,#0xffe0000000000000
 cmp x0,x1
 b.hs .Ly_inf_nan
 lsl x0,x21,#1
 cbz x0,.Lx_zero_inf_nan
 cmp x0,x1
 b.hs .Lx_zero_inf_nan
 tbnz x21,#63,.Lx_negative
 b .Lfinite_special_y
.Ly_zero:
 // A signalling NaN still executes the original addition.
 mov x0,#0x8000000000000
 eor x0,x21,x0
 lsl x0,x0,#1
 mov x1,#0xfff0000000000000
 cmp x0,x1
 b.hi .Ladd_original
 b .Lone
.Ly_inf_nan:
 mov x1,#0x3ff0000000000000
 cmp x21,x1
 b.eq .Ly_signal_one
 lsl x0,x21,#1
 mov x1,#0xffe0000000000000
 cmp x0,x1
 b.hi .Ladd_original
 lsl x2,x22,#1
 cmp x2,x1
 b.hi .Ladd_original
 mov x1,#0x7fe0000000000000
 cmp x0,x1
 b.eq .Lone
 cset w2,lo
 lsr x3,x22,#63
 eor w3,w3,#1
 cmp w2,w3
 b.eq .Lpositive_zero
 fmul d0,d9,d9
 b .Ldone
.Ly_signal_one:
 mov x0,#0x8000000000000
 eor x0,x22,x0
 lsl x0,x0,#1
 mov x1,#0xfff0000000000000
 cmp x0,x1
 b.hi .Ladd_original
 b .Lone
.Lx_zero_inf_nan:
 fmul d10,d8,d8
 tbz x21,#63,.Lx_sign_known
 mov x0,x22
 bl .Lcheckint
 cmp w0,#1
 b.ne .Lx_sign_known
 fneg d10,d10
 mov w23,#1
.Lx_sign_known:
 lsl x0,x21,#1
 cbnz x0,.Lx_nonzero_special
 tbz x22,#63,.Lx_nonzero_special
 mov w0,w23
 bl .Ldivzero
 b .Ldone
.Lx_nonzero_special:
 tbz x22,#63,.Lx_special_positive_y
 fmov d0,#1.0
 fdiv d0,d0,d10
 b .Ldone
.Lx_special_positive_y:
 fmov d0,d10
 b .Ldone
.Lx_negative:
 mov x0,x22
 bl .Lcheckint
 cbz w0,.Lnegative_invalid
 cmp w0,#1
 b.ne .Lnegative_even
 mov w23,#0x40000
.Lnegative_even:
 and x21,x21,#0x7fffffffffffffff
 and w24,w24,#0x7ff
.Lfinite_special_y:
 and w0,w25,#0x7ff
 sub w1,w0,#0x3be
 cmp w1,#0x80
 b.lo .Lnormalize
 mov x1,#0x3ff0000000000000
 cmp x21,x1
 b.eq .Lone
 cmp w0,#0x3be
 b.hs .Llarge_y
 cmp x21,x1
 fmov d0,#1.0
 b.hi .Ltiny_y_add
 fsub d0,d0,d9
 b .Ldone
.Ltiny_y_add:
 fadd d0,d0,d9
 b .Ldone
.Llarge_y:
 cmp x21,x1
 cset w0,hi
 cmp w25,#0x800
 cset w1,lo
 cmp w0,w1
 mov w0,#0
 b.ne .Lmain_uflow
 bl .Loflow
 b .Ldone
.Lmain_uflow:
 bl .Luflow
 b .Ldone
.Lnormalize:
 cbnz w24,.Llog
 mov x0,#0x4330000000000000
 fmov d0,x0
 fmul d0,d8,d0
 fmov x21,d0
 and x21,x21,#0x7fffffffffffffff
 mov x0,#0x340000000000000
 sub x21,x21,x0
.Llog:
 adrp x19,:got:md2asm_original_pow_log_data
 ldr x19,[x19,:got_lo12:md2asm_original_pow_log_data]
 adrp x20,:got:md2asm_original_pow_exp_data
 ldr x20,[x20,:got_lo12:md2asm_original_pow_exp_data]
 movz x0,#0x9555,lsl #32
 movk x0,#0x3fe6,lsl #48
 sub x0,x21,x0
 ubfx x1,x0,#45,#7
 asr x2,x0,#52
 scvtf d11,w2
 and x2,x0,#0xfff0000000000000
 sub x2,x21,x2
 fmov d0,x2
 add x26,x19,x1,lsl #5
 add x26,x26,#72
 ldr d1,[x26]
 fmov d2,#-1.0
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d10,d0
 fmov d0,d11
 ldr d1,[x19]
 ldr d2,[x26,#16]
 // Integer k times the 42-bit high coefficient is exact over the full domain.
 fmul d0,d0,d1
 fadd d0,d0,d2
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 mov x6,x28
#else
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 fmov d12,d0
 fadd d13,d12,d10
 fmov d0,d11
 ldr d1,[x19,#8]
 ldr d2,[x26,#24]
 // Four significant integer bits times this 49-bit coefficient fit exactly.
 fmov x0,d11
 tst x0,#0x1ffffffffffff
 b.ne .Lpower_exact_log_low_original
 fmul d0,d0,d1
 fadd d0,d0,d2
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 mov x6,x28
#else
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 b .Lpower_exact_log_low_done
.Lpower_exact_log_low_original:
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
.Lpower_exact_log_low_done:
 str d0,[sp,#160]
 fsub d0,d12,d13
 fadd d0,d0,d10
 str d0,[sp,#168]
 ldr d0,[x19,#16]
 fmul d0,d0,d10
 str d0,[sp,#176]
 fmul d14,d10,d0
 fmul d15,d10,d14
 fadd d12,d13,d14
 str d12,[sp,#184]
 fmov d1,d10
 fneg d2,d14
 bl md2asm_private_power_square_residual
 orr w27,w27,w1
 str d0,[sp,#192]
 fsub d0,d13,d12
 fadd d0,d0,d14
 str d0,[sp,#200]
 // The three seeds share the proved reduction interval and exact rounding.
 adr x16,md2asm_private_power_coefficient_records
 bl md2asm_private_power_log_seed_triplet
 cbnz w0,.Lpower_log_seed_original
 orr w27,w27,w1
 stp d0,d1,[sp,#208]
 str d2,[sp,#224]
 b .Lpower_log_seed_ready
.Lpower_log_seed_original:
 fmov d0,d10
 ldr d1,[x19,#64]
 ldr d2,[x19,#56]
 adr x16,md2asm_private_power_coefficient_records+0
 bl md2asm_private_power_coefficient_product_sum
 orr w27,w27,w1
 str d0,[sp,#208]
 fmov d0,d10
 ldr d1,[x19,#48]
 ldr d2,[x19,#40]
 adr x16,md2asm_private_power_coefficient_records+32
 bl md2asm_private_power_coefficient_product_sum
 orr w27,w27,w1
 str d0,[sp,#216]
 fmov d0,d10
 ldr d1,[x19,#32]
 ldr d2,[x19,#24]
 adr x16,md2asm_private_power_coefficient_records+64
 bl md2asm_private_power_coefficient_product_sum
 orr w27,w27,w1
 str d0,[sp,#224]
.Lpower_log_seed_ready:
 fmov d0,d14
 ldr d1,[sp,#208]
 ldr d2,[sp,#216]
 bl md2asm_private_power_log_polynomial_merge
 orr w27,w27,w1
 fmov d1,d0
 fmov d0,d14
 ldr d2,[sp,#224]
 bl md2asm_private_power_log_polynomial_merge
 orr w27,w27,w1
 fmov d1,d0
 fmov d0,d15
 ldr d2,[sp,#160]
 ldr d3,[sp,#168]
 fadd d2,d2,d3
 ldr d3,[sp,#192]
 fadd d2,d2,d3
 ldr d3,[sp,#200]
 fadd d2,d2,d3
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d10,d0
 fadd d11,d12,d10
 fsub d10,d12,d11
 fadd d10,d10,d0
 fmul d12,d9,d11
 fmov d0,d9
 fmov d1,d11
 fneg d2,d12
 bl md2asm_private_power_product_rounding_residual
 orr w27,w27,w1
 fmov d2,d0
 fmov d0,d9
 fmov d1,d10
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d13,d0
 // Exponential range reduction and the original table polynomial.
 fmov x0,d12
 ubfx x25,x0,#52,#11
 sub w1,w25,#0x3c9
 cmp w1,#63
 b.lo .Lexp_reduce
 tbnz w1,#31,.Ltiny_exp
 cmp w25,#0x409
 b.hs .Lhuge_exp
 mov w25,#0
.Lexp_reduce:
 ldr d0,[x20]
 fmul d0,d0,d12
 frinta d11,d0
 fcvtas x24,d0
 fmov d0,d11
 ldr d1,[x20,#16]
 fmov d2,d12
 // The 36-bit split coefficient times a signed 17-bit integer is exact.
 cmp x24,#0
 cneg x0,x24,lt
 cmp x0,#32,lsl #12
 b.hs .Lpower_exact_exp_original
 fmul d0,d0,d1
 fadd d0,d0,d2
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 mov x6,x28
#else
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 b .Lpower_exact_exp_done
.Lpower_exact_exp_original:
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
.Lpower_exact_exp_done:
 fmov d2,d0
 fmov d0,d11
 ldr d1,[x20,#24]
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fadd d10,d0,d13
 and x0,x24,#127
 add x0,x20,x0,lsl #4
 ldr d11,[x0,#112]
 ldr x26,[x0,#120]
 add x1,x24,x23
 lsl x1,x1,#45
 add x26,x26,x1
 fmul d14,d10,d10
 adr x16,md2asm_private_power_coefficient_records+96
 bl md2asm_private_power_exponential_seed_pair
 cbnz w0,.Lexp_seed_pair_original
 orr w27,w27,w1
 str d0,[sp,#160]
 str d1,[sp,#168]
 b .Lexp_seed_pair_ready
.Lexp_seed_pair_original:
 fmov d0,d10
 ldr d1,[x20,#40]
 ldr d2,[x20,#32]
 adr x16,md2asm_private_power_coefficient_records+96
 bl md2asm_private_power_coefficient_product_sum
 orr w27,w27,w1
 str d0,[sp,#160]
 fmov d0,d10
 ldr d1,[x20,#56]
 ldr d2,[x20,#48]
 adr x16,md2asm_private_power_coefficient_records+128
 bl md2asm_private_power_coefficient_product_sum
 orr w27,w27,w1
 str d0,[sp,#168]
.Lexp_seed_pair_ready:
 fmov d0,d14
 ldr d1,[sp,#160]
 fadd d2,d11,d10
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d2,d0
 fmul d0,d14,d14
 ldr d1,[sp,#168]
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d10,d0
 cbz w25,.Lexp_special
 fmov d0,x26
 fmov d1,d10
 fmov d2,d0
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 b .Ldone
.Ltiny_exp:
 fmov d0,#1.0
 fadd d0,d0,d12
 cbz w23,.Ldone
 fneg d0,d0
 b .Ldone
.Lhuge_exp:
 mov w0,w23
 fmov x1,d12
 tbnz x1,#63,.Lmain_uflow
 bl .Loflow
 b .Ldone
.Lexp_special:
 tbnz x24,#31,.Lexp_subnormal
 mov x0,#0x3f10000000000000
 sub x26,x26,x0
 fmov d0,x26
 fmov d1,d10
 fmov d2,d0
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 mov x0,#0x7f00000000000000
 fmov d1,x0
 fmul d0,d1,d0
 bl .Lcheck_oflow
 b .Ldone
.Lexp_subnormal:
 mov x0,#0x3fe0000000000000
 add x26,x26,x0
 fmov d11,x26
 fmul d0,d11,d10
 fadd d12,d11,d0
 fabs d0,d12
 fmov d1,#1.0
 fcmp d0,d1
 b.ge .Lscale_subnormal
 fmov d13,#1.0
 fcmp d12,#0.0
 b.ge .Lsubnormal_one
 fneg d13,d13
.Lsubnormal_one:
 fsub d14,d11,d12
 fmul d0,d11,d10
 fadd d14,d14,d0
 fadd d15,d13,d12
 fsub d0,d13,d15
 fadd d0,d0,d12
 fadd d14,d0,d14
 fadd d0,d15,d14
 fsub d12,d0,d13
 fcmp d12,#0.0
 b.ne .Lforce_underflow
 and x0,x26,#0x8000000000000000
 fmov d12,x0
.Lforce_underflow:
 mov x0,#0x10000000000000
 fmov d0,x0
 fmul d0,d0,d0
.Lscale_subnormal:
 mov x0,#0x10000000000000
 fmov d0,x0
 fmul d0,d0,d12
 bl .Lcheck_uflow
 b .Ldone
.Lnegative_invalid:
 fmov d0,d8
 bl .Linvalid
 b .Ldone
.Ladd_original:
 fadd d0,d8,d9
 b .Ldone
.Lone:
 fmov d0,#1.0
 b .Ldone
.Lpositive_zero:
 fmov d0,xzr
.Ldone:
 cbz w27,.Ldeferred_flush_done_return
 mrs x16,fpsr
 bic x17,x27,x16
 cbz x17,.Ldeferred_flush_done_return
 orr x16,x16,x27
 msr fpsr,x16
.Ldeferred_flush_done_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp d8,d9,[sp,#96]
 ldp d10,d11,[sp,#112]
 ldp d12,d13,[sp,#128]
 ldp d14,d15,[sp,#144]
 ldp x29,x30,[sp],#256
 ret
.size md2asm_pow_original_rounding_candidate,.-md2asm_pow_original_rounding_candidate
// Integer classification: 0 for noninteger, 1 for odd, 2 for even.
.Lcheckint:
 ubfx x1,x0,#52,#11
 cmp x1,#0x3ff
 b.lo .Lnot_int
 cmp x1,#0x433
 b.hi .Leven_int
 mov x2,#0x433
 sub x1,x2,x1
 mov x2,#1
 lsl x2,x2,x1
 sub x3,x2,#1
 tst x0,x3
 b.ne .Lnot_int
 tst x0,x2
 mov w0,#2
 b.eq .Lcheckint_return
 mov w0,#1
 ret
.Leven_int:
 mov w0,#2
 ret
.Lnot_int:
 mov w0,#0
.Lcheckint_return:
 ret
// These routes retain the original floating-point operations and errno.
.Loflow:
 mov x1,#0x7000000000000000
 b .Lxflow
.Luflow:
 mov x1,#0x1000000000000000
.Lxflow:
 fmov d0,x1
 fmov d1,d0
 cbz w0,.Lxflow_positive
 fneg d0,d0
.Lxflow_positive:
 fmul d0,d0,d1
 mov w0,#34
 b .Lwith_errno
.Ldivzero:
 fmov d0,#1.0
 cbz w0,.Ldivzero_positive
 fneg d0,d0
.Ldivzero_positive:
 fmov d1,xzr
 fdiv d0,d0,d1
 mov w0,#34
 b .Lwith_errno
.Linvalid:
 fmov d2,d0
 fsub d1,d0,d0
 fdiv d0,d1,d1
 fcmp d2,d2
 b.vs .Lerror_return
 mov w0,#33
 b .Lwith_errno
.Lcheck_oflow:
 fmov x0,d0
 and x0,x0,#0x7fffffffffffffff
 mov x1,#0x7ff0000000000000
 cmp x0,x1
 b.ne .Lerror_return
 mov w0,#34
 b .Lwith_errno
.Lcheck_uflow:
 fcmp d0,#0.0
 b.ne .Lerror_return
 mov w0,#34
.Lwith_errno:
 cbz w27,.Ldeferred_flush_done_errno
 mrs x16,fpsr
 bic x17,x27,x16
 cbz x17,.Ldeferred_flush_done_errno
 orr x16,x16,x27
 msr fpsr,x16
.Ldeferred_flush_done_errno:
 mov w27,#0
 stp x18,x30,[sp,#-32]!
 str d0,[sp,#16]
 str w0,[sp,#24]
 bl __errno_location
 ldr w1,[sp,#24]
 str w1,[x0]
 ldr d0,[sp,#16]
 ldp x18,x30,[sp],#32
.Lerror_return:
 ret

// Exact integer metadata for the five immutable polynomial coefficient pairs.
// Each 32-byte record contains significands, stored exponents and signs.
.p2align 4
.global md2asm_private_power_coefficient_records
.hidden md2asm_private_power_coefficient_records
.type md2asm_private_power_coefficient_records,%object
md2asm_private_power_coefficient_records:
 // log_seed1, original b/c table offsets [64, 56].
 .quad 0x10002b8b263fc3,0x12495b9b4845e9
 .word 1023,1023
 .word 0,1
 // log_seed2, original b/c table offsets [48, 40].
 .quad 0x1555555529a47a,0x1999999959554e
 .word 1022,1022
 .word 1,0
 // log_seed3, original b/c table offsets [32, 24].
 .quad 0x10000000000006,0x15555555555560
 .word 1022,1022
 .word 0,1
 // exp_seed1, original b/c table offsets [40, 32].
 .quad 0x1555555555543c,0x1ffffffffffdbd
 .word 1020,1021
 .word 0,0
 // exp_seed2, original b/c table offsets [56, 48].
 .quad 0x11111167a4d017,0x155555cf172b91
 .word 1016,1018
 .word 0,0
.size md2asm_private_power_coefficient_records,160
.section .note.GNU-stack,"",%progbits

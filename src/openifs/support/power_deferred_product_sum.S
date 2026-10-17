// Define MD2ASM_CLOUD_PRIVATE_COUNTERS only for the hidden cloud worker graph.
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
#define md2asm_private_original_general_product_sum md2asm_cloud_private_general_product_sum
#define md2asm_private_power_product_sum_deferred md2asm_cloud_private_power_product_sum_deferred
#define md2asm_private_power_coefficient_product_sum md2asm_cloud_private_power_coefficient_product_sum
#define md2asm_private_power_log_seed_triplet md2asm_cloud_private_power_log_seed_triplet
#define md2asm_private_power_square_residual md2asm_cloud_private_power_square_residual
#define md2asm_private_power_product_rounding_residual md2asm_cloud_private_power_product_rounding_residual
#define md2asm_private_power_exponential_seed_pair md2asm_cloud_private_power_exponential_seed_pair
#define md2asm_private_power_log_polynomial_merge md2asm_cloud_private_power_log_polynomial_merge
#endif
/* Private atomic POWER entry. Borrow x27 as a read-only pending FPSR mask.
 * Preserve all saved registers and original fast/wide counter classification.
 * d0..d2 inputs, d0 result, w1=required mask. General return sets w1=0.
 * Compact successes use the shared body directly, with no frame or child call.
 * Wide and original general calls retain their 16-byte frames. */
.arch armv8-a
.text
.p2align 4
.global md2asm_private_power_product_sum_deferred
.hidden md2asm_private_power_product_sum_deferred
.type md2asm_private_power_product_sum_deferred,%function
md2asm_private_power_product_sum_deferred:
#define MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
#define MD2ASM_COMPACT_IN_ATOMIC
#include "compact_product_sum.S"
#undef MD2ASM_COMPACT_IN_ATOMIC
#undef MD2ASM_PRODUCT_SUM_DEFERRED_STATUS
.text
.Ldeferred_atomic_wide:
 stp x29,x30,[sp,#-16]!
 cbz w1,.Ldeferred_atomic_unprepared_wide
 bl md2asm_private_wide_deferred_prepared
 b .Ldeferred_atomic_wide_return
.Ldeferred_atomic_unprepared_wide:
 bl md2asm_private_wide_deferred
.Ldeferred_atomic_wide_return:
 ldp x29,x30,[sp],#16
 cbnz w0,.Ldeferred_atomic_general
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 add x6,x28,#8
#else
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 ret
.Ldeferred_atomic_general:
 cbz w27,.Ldeferred_flush_done_general
 mrs x16,fpsr
 bic x17,x27,x16
 cbz x17,.Ldeferred_flush_done_general
 orr x16,x16,x27
 msr fpsr,x16
.Ldeferred_flush_done_general:
 stp x29,x30,[sp,#-16]!
 bl md2asm_private_original_general_product_sum
 ldp x29,x30,[sp],#16
 mov w1,#0
 ret
.size md2asm_private_power_product_sum_deferred,.-md2asm_private_power_product_sum_deferred

// Private fixed-pair entry. d0..d2 retain original a,b,c for every replay.
// x16 supplies a matching, read-only 32-byte significand/exponent/sign record.
// Share the included compact body and all original wide/general boundaries.
.p2align 2
.global md2asm_private_power_coefficient_product_sum
.hidden md2asm_private_power_coefficient_product_sum
.type md2asm_private_power_coefficient_product_sum,%function
md2asm_private_power_coefficient_product_sum:
 mrs x17,fpcr
 cbnz x17,md2asm_private_power_product_sum_deferred
 fmov x0,d0
 ubfx x3,x0,#52,#11
 cmp w3,#2047
 b.eq md2asm_private_power_product_sum_deferred
 cbz w3,.Lcoefficient_fused_a_zero_exponent
 and x6,x0,#0xfffffffffffff
 orr x6,x6,#0x10000000000000
 ldp x7,x8,[x16]
 ldp w4,w5,[x16,#16]
 ldp w9,w10,[x16,#24]
 eor x9,x9,x0,lsr #63
 b .Lcompact_exponents_ready
.Lcoefficient_fused_a_zero_exponent:
 lsl x17,x0,#1
 cbnz x17,md2asm_private_power_product_sum_deferred
 fmov x0,d2
 mov w6,#0
 b .Lcompact_success_bits
.size md2asm_private_power_coefficient_product_sum,.-md2asm_private_power_coefficient_product_sum

// Private three-seed leaf. d10 is zero or 2^-60 <= abs(r) < 1/128.
// x16 points to three immutable 32-byte coefficient records. Return d0..d2,
// w1=required flag union and w0=0. Nonzero FPCR refuses with w0=1,w1=0.
// Only x0..x17, d0..d2 and NZCV are scratch. No stack or service calls.
// All results retain the C binade. Round the exact product in C units.
.macro MD2ASM_LOG_SEED offset, base, out
 ldp x5,x6,[x16,#\offset]
 mul x7,x2,x5
 umulh x8,x2,x5
 cmp w1,#64
 b.hs .Llog_seed_high\@
 lsr x9,x7,x1
 neg w12,w1
 lsl x15,x8,x12
 orr x9,x9,x15
 sub w12,w1,#1
 lsr x10,x7,x12
 and x10,x10,#1
 b .Llog_seed_round\@
.Llog_seed_high\@:
 b.eq .Llog_seed_64\@
 sub w12,w1,#64
 lsr x9,x8,x12
 sub w12,w12,#1
 lsr x10,x8,x12
 and x10,x10,#1
 b .Llog_seed_round\@
.Llog_seed_64\@:
 mov x9,x8
 lsr x10,x7,#63
.Llog_seed_round\@:
 // A lower discarded bit is always nonzero, so only the guard rounds up.
 add x9,x9,x10
 sub x7,x6,x9
 add x9,x6,x9
 tst x0,#0x8000000000000000
 csel x9,x7,x9,eq
 and x9,x9,#0xfffffffffffff
 mov x14,#\base
 orr x9,x9,x14
 fmov \out,x9
.endm
.macro MD2ASM_LOG_SEED_C offset, base, out
 ldr x6,[x16,#(\offset+8)]
 and x6,x6,#0xfffffffffffff
 mov x14,#\base
 orr x6,x6,x14
 fmov \out,x6
.endm
.p2align 2
.global md2asm_private_power_log_seed_triplet
.hidden md2asm_private_power_log_seed_triplet
.type md2asm_private_power_log_seed_triplet,%function
md2asm_private_power_log_seed_triplet:
 mrs x17,fpcr
 cbnz x17,.Llog_seed_refuse
 fmov x0,d10
 lsl x5,x0,#1
 cbz x5,.Llog_seed_zero
 ubfx x1,x0,#52,#11
 mov w5,#1075
 sub w1,w5,w1
 mov w4,#16
 cmp w1,#107
 b.hs .Llog_seed_small
 and x2,x0,#0xfffffffffffff
 orr x2,x2,#0x10000000000000
 MD2ASM_LOG_SEED 0,0xbff0000000000000,d0
 MD2ASM_LOG_SEED 32,0x3fe0000000000000,d1
 MD2ASM_LOG_SEED 64,0xbfe0000000000000,d2
 cmp w1,#74
 b.hi .Llog_seed_wide_counter
.Llog_seed_fast_counter:
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 mov x6,x28
#else
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
#endif
 b .Llog_seed_count
.Llog_seed_wide_counter:
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 add x6,x28,#8
#else
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
#endif
.Llog_seed_count:
 ldr x7,[x6]
 add x7,x7,#3
 str x7,[x6]
 mov w1,w4
 mov w0,#0
 ret
.Llog_seed_zero:
 mov w4,#0
 MD2ASM_LOG_SEED_C 0,0xbff0000000000000,d0
 MD2ASM_LOG_SEED_C 32,0x3fe0000000000000,d1
 MD2ASM_LOG_SEED_C 64,0xbfe0000000000000,d2
 b .Llog_seed_fast_counter
.Llog_seed_small:
 mov w4,#16
 MD2ASM_LOG_SEED_C 0,0xbff0000000000000,d0
 MD2ASM_LOG_SEED_C 32,0x3fe0000000000000,d1
 MD2ASM_LOG_SEED_C 64,0xbfe0000000000000,d2
 b .Llog_seed_wide_counter
.Llog_seed_refuse:
 mov w1,#0
 mov w0,#1
 ret
.size md2asm_private_power_log_seed_triplet,.-md2asm_private_power_log_seed_triplet
.purgem MD2ASM_LOG_SEED
.purgem MD2ASM_LOG_SEED_C
// Exact residual of the parent's square product. d0=a=-r/2, d1=r, d2=-R(a*r).
// The coupled logarithm domain keeps r normal or zero and the residual normal
// or positive zero. The signed low-word error has magnitude at most 2^52.
// Preserve raw d1/d2. Return mask zero through the existing FAST hook.
.p2align 2
.global md2asm_private_power_square_residual
.hidden md2asm_private_power_square_residual
.type md2asm_private_power_square_residual,%function
md2asm_private_power_square_residual:
 mrs x17,fpcr
 cbnz x17,md2asm_private_power_product_sum_deferred
 fmov x1,d1
 ubfx x3,x1,#52,#11
 cbz w3,.Lpower_square_residual_zero
 and x6,x1,#0xfffffffffffff
 orr x6,x6,#0x10000000000000
 mul x11,x6,x6
 lsl w13,w3,#1
 sub w13,w13,#2151
 fmov x2,d2
 ubfx x4,x2,#52,#11
 sub w4,w4,#1075
 sub w15,w4,w13
 lsl x7,x2,x15
 sub x11,x7,x11
 cbz x11,.Lpower_square_residual_zero
 scvtf d0,x11
 add w13,w13,#1023
 lsl x0,x13,#52
 fmov d3,x0
 fmul d0,d0,d3
 mov w1,#0
 b .Lcompact_success_value_ready
.Lpower_square_residual_zero:
 fmov d0,xzr
 mov w1,#0
 b .Lcompact_success_value_ready
.size md2asm_private_power_square_residual,.-md2asm_private_power_square_residual

// Private exact product residual. d0=a,d1=b,d2=-RN(a*b).
// Normal operands/addend or the proved normal-a, zero-b identity use this route.
// The source relation is private; unsupported integer guards replay raw inputs.
// Preserve d1/d2, x18..x30, v8..v15, SP, FPCR, FPSR and errno.
// Only d0,d3, x0..x17 and NZCV are scratch. No frame or service call.
.p2align 2
.global md2asm_private_power_product_rounding_residual
.hidden md2asm_private_power_product_rounding_residual
.type md2asm_private_power_product_rounding_residual,%function
md2asm_private_power_product_rounding_residual:
 mrs x17,fpcr
 cbnz x17,md2asm_private_power_product_sum_deferred
 fmov x0,d0
 fmov x1,d1
 fmov x2,d2
 ubfx x3,x0,#52,#11
 sub w15,w3,#1
 cmp w15,#2045
 b.hi md2asm_private_power_product_sum_deferred
 lsl x15,x1,#1
 cbz x15,.Lpower_product_residual_zero
 ubfx x4,x1,#52,#11
 sub w15,w4,#1
 cmp w15,#2045
 b.hi md2asm_private_power_product_sum_deferred
 ubfx x5,x2,#52,#11
 sub w15,w5,#1
 cmp w15,#2045
 b.hi md2asm_private_power_product_sum_deferred
 add w13,w3,w4
 sub w13,w13,#2150
 cmn w13,#1022
 b.lt md2asm_private_power_product_sum_deferred
 sub w5,w5,#1075
 sub w15,w5,w13
 and x6,x0,#0xfffffffffffff
 orr x6,x6,#0x10000000000000
 and x7,x1,#0xfffffffffffff
 orr x7,x7,#0x10000000000000
 mul x11,x6,x7
 lsl x7,x2,x15
 sub x11,x11,x7
 eor x15,x0,x1
 tst x15,#0x8000000000000000
 cneg x11,x11,mi
 cbz x11,.Lpower_product_residual_zero
 scvtf d0,x11
 add w13,w13,#1023
 lsl x0,x13,#52
 fmov d3,x0
 fmul d0,d0,d3
 mov w1,#0
 b .Lcompact_success_value_ready
.Lpower_product_residual_zero:
 fmov d0,xzr
 mov w1,#0
 b .Lcompact_success_value_ready
.size md2asm_private_power_product_rounding_residual,.-md2asm_private_power_product_rounding_residual

// Private two-seed leaf. d10 is unchanged r; x16 points to the two exact
// exponential seed records. Guard both signed zeros or the complete normal
// box 2^-60 <= abs(r) < 1/128. Unsupported inputs refuse before effects.
// Return d0/d1, w1=required mask and w0=0; refusal w0=1,w1=0.
// Preserve x18..x30, full v8..v15, SP, FPCR/FPSR, errno and pending x27.
// Only x0..x17, d0/d1 and NZCV are scratch. No frame or service calls.
.macro MD2ASM_EXP_SEED_QUOTIENT offset, extra
 ldp x5,x6,[x16,#\offset]
 umulh x8,x2,x5
 add w13,w1,#\extra
 cmp w13,#64
 b.hi .Lexp_seed_high\@
 mul x7,x2,x5
 b.eq .Lexp_seed_64\@
 lsr x9,x7,x13
 neg w12,w13
 lsl x15,x8,x12
 orr x9,x9,x15
 sub w12,w13,#1
 lsr x10,x7,x12
 and x10,x10,#1
 b .Lexp_seed_quotient_ready\@
.Lexp_seed_64\@:
 mov x9,x8
 lsr x10,x7,#63
 b .Lexp_seed_quotient_ready\@
.Lexp_seed_high\@:
 sub w12,w13,#64
 lsr x9,x8,x12
 sub w12,w12,#1
 lsr x10,x8,x12
 and x10,x10,#1
.Lexp_seed_quotient_ready\@:
.endm
.macro MD2ASM_EXP_SEED_CONSTANT offset, bias, out
 ldr x6,[x16,#(\offset+8)]
 mov x14,#\bias
 add x6,x6,x14
 fmov \out,x6
.endm
.p2align 2
.global md2asm_private_power_exponential_seed_pair
.hidden md2asm_private_power_exponential_seed_pair
.type md2asm_private_power_exponential_seed_pair,%function
md2asm_private_power_exponential_seed_pair:
 mrs x17,fpcr
 cbnz x17,.Lexp_seed_pair_refuse
 fmov x0,d10
 lsl x5,x0,#1
 cbz x5,.Lexp_seed_pair_zero
 ubfx x1,x0,#52,#11
 sub w5,w1,#963
 cmp w5,#52
 b.hi .Lexp_seed_pair_refuse
 mov w5,#1075
 sub w1,w5,w1
 mov w4,#16
 cmp w1,#106
 b.hs .Lexp_seed_pair_constants
 and x2,x0,#0xfffffffffffff
 orr x2,x2,#0x10000000000000
 MD2ASM_EXP_SEED_QUOTIENT 0,1
 tbnz x0,#63,.Lexp_seed_pair_first_fine
 cmp x9,#579
 b.hs .Lexp_seed_pair_first_coarse
.Lexp_seed_pair_first_fine:
 add x9,x9,x10
 add x7,x6,x9
 sub x9,x6,x9
 tst x0,#0x8000000000000000
 csel x9,x9,x7,mi
 mov x14,#0x3fc0000000000000
 add x9,x9,x14
 fmov d0,x9
 b .Lexp_seed_pair_second
.Lexp_seed_pair_first_coarse:
 lsr x6,x6,#1
 lsr x9,x9,#1
 add x9,x9,x6
 add x9,x9,#1
 mov x14,#0x3fd0000000000000
 add x9,x9,x14
 fmov d0,x9
.Lexp_seed_pair_second:
 MD2ASM_EXP_SEED_QUOTIENT 32,2
 add x9,x9,x10
 add x7,x6,x9
 sub x9,x6,x9
 tst x0,#0x8000000000000000
 csel x9,x9,x7,mi
 mov x14,#0x3f90000000000000
 add x9,x9,x14
 fmov d1,x9
.Lexp_seed_pair_counters:
 cmp w1,#72
 b.ls .Lexp_seed_pair_fast_two
 cmp w1,#73
 b.eq .Lexp_seed_pair_mixed
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 add x6,x28,#8
#else
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#2
 str x7,[x6]
 b .Lexp_seed_pair_done
.Lexp_seed_pair_fast_two:
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 mov x6,x28
#else
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#2
 str x7,[x6]
 b .Lexp_seed_pair_done
.Lexp_seed_pair_mixed:
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 mov x6,x28
#else
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 add x6,x28,#8
#else
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
.Lexp_seed_pair_done:
 mov w1,w4
 mov w0,#0
 ret
.Lexp_seed_pair_zero:
 mov w4,#0
 mov w1,#0
.Lexp_seed_pair_constants:
 MD2ASM_EXP_SEED_CONSTANT 0,0x3fc0000000000000,d0
 MD2ASM_EXP_SEED_CONSTANT 32,0x3f90000000000000,d1
 b .Lexp_seed_pair_counters
.Lexp_seed_pair_refuse:
 mov w1,#0
 mov w0,#1
 ret
.size md2asm_private_power_exponential_seed_pair,.-md2asm_private_power_exponential_seed_pair
.purgem MD2ASM_EXP_SEED_QUOTIENT
.purgem MD2ASM_EXP_SEED_CONSTANT
.section .note.GNU-stack,"",%progbits

// Private log merges. The parent proves zero a, or negative normal a with
// 2^-121 <= abs(a) < 2^-15; 3/4 <= abs(b) <= 19/16 and 5/8 <= abs(c) <= 7/8.
// Product and c have the same sign. Their sum stays strictly inside [1/2,1).
// d0=a,d1=b,d2=c; return d0, w0=0 and w1=required mask. Preserve raw d1/d2,
// x18..x30, full q8..q15, x27, SP, FPCR, FPSR and errno. x0..x17/NZCV scratch.
// Nonzero FPCR tail-replays the original atomic entry before any effect.
.text
.p2align 2
.global md2asm_private_power_log_polynomial_merge
.hidden md2asm_private_power_log_polynomial_merge
.type md2asm_private_power_log_polynomial_merge,%function
md2asm_private_power_log_polynomial_merge:
 mrs x17,fpcr
 cbnz x17,md2asm_private_power_product_sum_deferred
 fmov x0,d0
 lsl x3,x0,#1
 cbz x3,.Llog_merge_zero
 fmov x1,d1
 ubfx x3,x0,#52,#11
 ubfx x4,x1,#52,#11
 add w3,w3,w4
 mov w4,#2097
 sub w3,w4,w3
 cmp w3,#107
 b.hs .Llog_merge_small
 and x6,x0,#0xfffffffffffff
 orr x6,x6,#0x10000000000000
 and x7,x1,#0xfffffffffffff
 orr x7,x7,#0x10000000000000
 mul x11,x6,x7
 umulh x12,x6,x7
 sub w10,w3,#64
 lsr x13,x12,x10
 sub w14,w10,#1
 lsr x14,x12,x14
 and x14,x14,#1
 mov w15,#65
 sub w15,w15,w10
 lsl x15,x12,x15
 orr x15,x15,x11
 cmp x15,#0
 cset w15,ne
 fmov x2,d2
 eor x16,x2,x13
 and x16,x16,#1
 orr w16,w16,w15
 and w16,w16,w14
 add x13,x13,x16
 orr w6,w14,w15
 lsl w6,w6,#4
 add x0,x2,x13
 cmp w3,#74
 b.hi .Llog_merge_wide_bits
 b .Lcompact_success_bits
.Llog_merge_small:
 fmov x0,d2
 mov w6,#16
 b .Llog_merge_wide_bits
.Llog_merge_zero:
 fmov x0,d2
 mov w6,#0
 b .Lcompact_success_bits
.Llog_merge_wide_bits:
 mov w1,w6
 fmov d0,x0
 mov w0,#0
#ifdef MD2ASM_CLOUD_PRIVATE_COUNTERS
 add x6,x28,#8
#else
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
#endif
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 ret
.size md2asm_private_power_log_polynomial_merge,.-md2asm_private_power_log_polynomial_merge

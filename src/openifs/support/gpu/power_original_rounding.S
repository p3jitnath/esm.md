/* Complete positive-normal power GPU phase.
 * Contract: skills/md2asm-gpu/references/openifs/support/positive_normal_power_complete_contract.md
 * The original all-GPU route remains below through one reversible symbol rename.
 */
// Copyright (C) 2018-2023 Free Software Foundation, Inc.
// SPDX-License-Identifier: LGPL-2.1-or-later
// Original arithmetic contract: skills/md2asm/references/openifs/support/power_original_rounding.md
/* Frozen positive-normal power transport; original route follows unchanged. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_pow_original_rounding_candidate
.type md2asm_pow_original_rounding_candidate,%function
md2asm_pow_original_rounding_candidate:
 fmov x16,d0
 lsr x17,x16,#52
 sub w17,w17,#1
 cmp w17,#0x7fe
 b.hs md2asm_pow_original_rounding_original_gpu_route
 fmov x16,d1
 ubfx x17,x16,#52,#11
 sub w17,w17,#0x3be
 cmp w17,#0x80
 b.hs md2asm_pow_original_rounding_original_gpu_route
 b md2asm_positive_normal_power_gpu_phase
.size md2asm_pow_original_rounding_candidate,.-md2asm_pow_original_rounding_candidate
.hidden md2asm_pow_original_rounding_original_gpu_route
#include "preserved_scalar_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_pow_original_rounding_original_gpu_route
.type md2asm_pow_original_rounding_original_gpu_route,%function
md2asm_pow_original_rounding_original_gpu_route:
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d9,real,x16,0,d9
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d10,destination,d8,real,x16,0,d8
 tbz x21,#63,.Lx_sign_known
 mov x0,x22
 bl .Lcheckint
 cmp w0,#1
 b.ne .Lx_sign_known
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d10,destination,d10,real,x16,0,zero
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d10
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d9
 b .Ldone
.Ltiny_y_add:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d9
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d8,real,x16,0,d0
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
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d11,destination,w2,general,w16,144,zero
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d2
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 fmov d12,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d13,destination,d12,real,x16,0,d10
 fmov d0,d11
 ldr d1,[x19,#8]
 ldr d2,[x26,#24]
 fmov x0,d11
 tst x0,#0x1ffffffffffff
 b.ne .Lpower_exact_log_low_original
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d2
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 b .Lpower_exact_log_low_done
.Lpower_exact_log_low_original:
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
.Lpower_exact_log_low_done:
 str d0,[sp,#160]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d12,real,x16,0,d13
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d10
 str d0,[sp,#168]
 ldr d0,[x19,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d10
 str d0,[sp,#176]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d14,destination,d10,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d15,destination,d10,real,x16,0,d14
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d12,destination,d13,real,x16,0,d14
 str d12,[sp,#184]
 fmov d1,d10
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d2,destination,d14,real,x16,0,zero
 bl md2asm_private_power_square_residual
 orr w27,w27,w1
 str d0,[sp,#192]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d13,real,x16,0,d12
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d14
 str d0,[sp,#200]
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d2,real,x16,0,d3
 ldr d3,[sp,#192]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d2,real,x16,0,d3
 ldr d3,[sp,#200]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d2,real,x16,0,d3
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d10,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d11,destination,d12,real,x16,0,d10
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d10,destination,d12,real,x16,0,d11
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d10,destination,d10,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d12,destination,d9,real,x16,0,d11
 fmov d0,d9
 fmov d1,d11
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d2,destination,d12,real,x16,0,zero
 bl md2asm_private_power_product_rounding_residual
 orr w27,w27,w1
 fmov d2,d0
 fmov d0,d9
 fmov d1,d10
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d13,d0
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d12
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,25,d11,destination,d0,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,19,x24,destination,d0,real,x16,0,zero
 fmov d0,d11
 ldr d1,[x20,#16]
 fmov d2,d12
 cmp x24,#0
 cneg x0,x24,lt
 cmp x0,#32,lsl #12
 b.hs .Lpower_exact_exp_original
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d2
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d10,destination,d0,real,x16,0,d13
 and x0,x24,#127
 add x0,x20,x0,lsl #4
 ldr d11,[x0,#112]
 ldr x26,[x0,#120]
 add x1,x24,x23
 lsl x1,x1,#45
 add x26,x26,x1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d14,destination,d10,real,x16,0,d10
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d11,real,x16,0,d10
 bl md2asm_private_power_product_sum_deferred
 orr w27,w27,w1
 fmov d2,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d14,real,x16,0,d14
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d12
 cbz w23,.Ldone
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d0,destination,d0,real,x16,0,zero
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 bl .Lcheck_oflow
 b .Ldone
.Lexp_subnormal:
 mov x0,#0x3fe0000000000000
 add x26,x26,x0
 fmov d11,x26
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d11,real,x16,0,d10
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d12,destination,d11,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d12,real,x16,0,zero
 fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
 b.ge .Lscale_subnormal
 fmov d13,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d12,real,x16,0,zero
 b.ge .Lsubnormal_one
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d13,destination,d13,real,x16,0,zero
.Lsubnormal_one:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d14,destination,d11,real,x16,0,d12
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d11,real,x16,0,d10
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d14,destination,d14,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d15,destination,d13,real,x16,0,d12
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d13,real,x16,0,d15
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d12
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d14,destination,d0,real,x16,0,d14
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d15,real,x16,0,d14
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d12,destination,d0,real,x16,0,d13
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d12,real,x16,0,zero
 b.ne .Lforce_underflow
 and x0,x26,#0x8000000000000000
 fmov d12,x0
.Lforce_underflow:
 mov x0,#0x10000000000000
 fmov d0,x0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d0
.Lscale_subnormal:
 mov x0,#0x10000000000000
 fmov d0,x0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d12
 bl .Lcheck_uflow
 b .Ldone
.Lnegative_invalid:
 fmov d0,d8
 bl .Linvalid
 b .Ldone
.Ladd_original:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d8,real,x16,0,d9
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
.size md2asm_pow_original_rounding_original_gpu_route,.-md2asm_pow_original_rounding_original_gpu_route
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
.Loflow:
 mov x1,#0x7000000000000000
 b .Lxflow
.Luflow:
 mov x1,#0x1000000000000000
.Lxflow:
 fmov d0,x1
 fmov d1,d0
 cbz w0,.Lxflow_positive
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d0,destination,d0,real,x16,0,zero
.Lxflow_positive:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 mov w0,#34
 b .Lwith_errno
.Ldivzero:
 fmov d0,#1.0
 cbz w0,.Ldivzero_positive
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d0,destination,d0,real,x16,0,zero
.Ldivzero_positive:
 fmov d1,xzr
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 mov w0,#34
 b .Lwith_errno
.Linvalid:
 fmov d2,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d1,destination,d0,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d2,real,x16,0,d2
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,zero
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
.p2align 4
.global md2asm_private_power_coefficient_records
.hidden md2asm_private_power_coefficient_records
.type md2asm_private_power_coefficient_records,%object
md2asm_private_power_coefficient_records:
 .quad 0x10002b8b263fc3,0x12495b9b4845e9
 .word 1023,1023
 .word 0,1
 .quad 0x1555555529a47a,0x1999999959554e
 .word 1022,1022
 .word 1,0
 .quad 0x10000000000006,0x15555555555560
 .word 1022,1022
 .word 0,1
 .quad 0x1555555555543c,0x1ffffffffffdbd
 .word 1020,1021
 .word 0,0
 .quad 0x11111167a4d017,0x155555cf172b91
 .word 1016,1018
 .word 0,0
.size md2asm_private_power_coefficient_records,160
.section .note.GNU-stack,"",%progbits

.text
// Private phase. The four private owners lie inside this 1024-byte frame.
.p2align 4
.hidden md2asm_positive_normal_power_gpu_phase
.type md2asm_positive_normal_power_gpu_phase,%function
md2asm_positive_normal_power_gpu_phase:
 sub sp,sp,#1024
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 stp x16,x17,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 stp x28,x29,[sp,#224]
 str x30,[sp,#240]
 stp q0,q1,[sp,#256]
 stp q2,q3,[sp,#288]
 stp q4,q5,[sp,#320]
 stp q6,q7,[sp,#352]
 stp q8,q9,[sp,#384]
 stp q10,q11,[sp,#416]
 stp q12,q13,[sp,#448]
 stp q14,q15,[sp,#480]
 stp q16,q17,[sp,#512]
 stp q18,q19,[sp,#544]
 stp q20,q21,[sp,#576]
 stp q22,q23,[sp,#608]
 stp q24,q25,[sp,#640]
 stp q26,q27,[sp,#672]
 stp q28,q29,[sp,#704]
 stp q30,q31,[sp,#736]
 mrs x9,fpcr
 mrs x10,fpsr
 mrs x11,nzcv
 str x9,[sp,#768]
 str x10,[sp,#776]
 str x11,[sp,#784]
 cbnz x9,.Lpower_phase_fatal
 bl __errno_location
 ldr x18,[sp,#144]
 str x0,[sp,#792]
 ldr w9,[x0]
 str w9,[sp,#800]
 bl omp_in_parallel
 ldr x18,[sp,#144]
 cbnz w0,.Lpower_phase_fatal
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#144]
 cbnz w0,.Lpower_phase_fatal
 add x19,sp,#832
 mov x9,#0
.Lpower_zero_private:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#24
 b.lo .Lpower_zero_private
 add x21,sp,#864
 add x20,sp,#896
 ldr x9,[sp,#256]
 ldr x10,[sp,#272]
 stp x9,x10,[x19]
 str x21,[x19,#16]
 mov w9,#1
 str w9,[x20,#4]
 add x16,sp,#960
 str x16,[x20,#48]
 mov x9,#32
 str x9,[x20,#56]
 mov x9,#24
 mov x10,#32
 stp x9,x10,[x16]
 ldr x9,[sp,#768]
 ldr x10,[sp,#776]
 msr fpcr,x9
 msr fpsr,x10
 ldr x9,[sp,#792]
 ldr w10,[sp,#800]
 str w10,[x9]
 adrp x0,.Lpower_complete_entry_name
 add x0,x0,:lo12:.Lpower_complete_entry_name
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#144]
 cbnz w0,.Lpower_phase_fatal
 ldr w9,[x20]
 cbnz w9,.Lpower_phase_fatal
 ldr w9,[x21,#12]
 cbz w9,.Lpower_event_zero
 cmp w9,#34
 b.ne .Lpower_phase_fatal
 ldr x10,[x20,#16]
 cmp x10,#290
 b.ne .Lpower_phase_fatal
 b .Lpower_event_valid
.Lpower_event_zero:
 ldr x10,[x20,#16]
 cbnz x10,.Lpower_phase_fatal
.Lpower_event_valid:
 ldr x10,[x21,#16]
 ldr x11,[x21,#24]
 adrp x9,:got:md2asm_product_sum_fast_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x12,[x9]
 add x12,x12,x10
 str x12,[x9]
 adrp x9,:got:md2asm_product_sum_wide_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_wide_calls]
 ldr x12,[x9]
 add x12,x12,x11
 str x12,[x9]
 ldr x9,[x21]
 str x9,[sp,#256]
 ldr x9,[sp,#768]
 msr fpcr,x9
 ldr x9,[sp,#776]
 ldr w10,[x20,#8]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x9,[sp,#792]
 ldr w10,[x21,#12]
 cbnz w10,.Lpower_store_errno
 ldr w10,[sp,#800]
.Lpower_store_errno:
 str w10,[x9]
 ldr x9,[sp,#784]
 msr nzcv,x9
 ldp q0,q1,[sp,#256]
 ldp q2,q3,[sp,#288]
 ldp q4,q5,[sp,#320]
 ldp q6,q7,[sp,#352]
 ldp q8,q9,[sp,#384]
 ldp q10,q11,[sp,#416]
 ldp q12,q13,[sp,#448]
 ldp q14,q15,[sp,#480]
 ldp q16,q17,[sp,#512]
 ldp q18,q19,[sp,#544]
 ldp q20,q21,[sp,#576]
 ldp q22,q23,[sp,#608]
 ldp q24,q25,[sp,#640]
 ldp q26,q27,[sp,#672]
 ldp q28,q29,[sp,#704]
 ldp q30,q31,[sp,#736]
 ldp x0,x1,[sp,#0]
 ldp x2,x3,[sp,#16]
 ldp x4,x5,[sp,#32]
 ldp x6,x7,[sp,#48]
 ldp x8,x9,[sp,#64]
 ldp x10,x11,[sp,#80]
 ldp x12,x13,[sp,#96]
 ldp x14,x15,[sp,#112]
 ldp x16,x17,[sp,#128]
 ldp x18,x19,[sp,#144]
 ldp x20,x21,[sp,#160]
 ldp x22,x23,[sp,#176]
 ldp x24,x25,[sp,#192]
 ldp x26,x27,[sp,#208]
 ldp x28,x29,[sp,#224]
 ldr x30,[sp,#240]
 add sp,sp,#1024
 ret
.Lpower_phase_fatal:
 bl abort
 brk #0
.size md2asm_positive_normal_power_gpu_phase,.-md2asm_positive_normal_power_gpu_phase
.section .rodata
.Lpower_complete_entry_name:.asciz "md2asm_gpu_positive_normal_power"
.section .note.GNU-stack,"",%progbits

// Exact RN(a*b+c) at the frozen POWER single-rounding source locations.
// Contract: skills/md2asm/references/openifs/support/power_original_rounding.md.
// ABI: d0,d1,d2 operands; d0 result; finite inputs; FPCR=0.
// Generic arrays use scale 2^-2148 inside the unchanged 1728-byte frame.
// Each compact or wide leaf call uses a separate 16-byte saved-LR frame.
// Preserve x18, x19-x29 and d8-d15, with sixteen-byte stack alignment.
.arch armv8-a
.text
.p2align 4
.global md2asm_round_product_sum_candidate
.type md2asm_round_product_sum_candidate,%function
md2asm_round_product_sum_candidate:
 // Try the exact compact representation before reserving the generic arrays.
 stp x29,x30,[sp,#-16]!
 bl md2asm_try_compact_product_sum
 ldp x29,x30,[sp],#16
 cbnz w0,.Lcandidate_try_wide_product_sum
 // A compact success belongs to the original fast operand class.
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 ret
.Lcandidate_try_wide_product_sum:
 // A wide success belongs to the original wide diagnostic class.
 stp x29,x30,[sp,#-16]!
 bl md2asm_try_wide_product_sum
 ldp x29,x30,[sp],#16
 cbnz w0,.Lcandidate_generic_product_sum
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 ret
.Lcandidate_generic_product_sum:
 sub sp,sp,#1728
 add x17,sp,#1616
 stp x19,x20,[x17,#0]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 mov x29,sp
 fmov x0,d0
 fmov x1,d1
 fmov x28,d2
 ubfx x3,x0,#52,#11
 ubfx x4,x1,#52,#11
 ubfx x5,x28,#52,#11
 cmp x3,#2047
 b.eq .Ldomain
 cmp x4,#2047
 b.eq .Ldomain
 cmp x5,#2047
 b.eq .Ldomain
 eor x6,x0,x1
 lsr x26,x6,#63
 lsr x27,x28,#63
 and x8,x0,#0xfffffffffffff
 and x9,x1,#0xfffffffffffff
 and x23,x28,#0xfffffffffffff
 mov x10,#0x10000000000000
 cmp x3,#0
 csel x6,x10,xzr,ne
 orr x8,x8,x6
 cmp x4,#0
 csel x6,x10,xzr,ne
 orr x9,x9,x6
 cmp x5,#0
 csel x6,x10,xzr,ne
 orr x23,x23,x6
 sub w6,w3,#1075
 mov w7,#-1074
 cmp w3,#0
 csel w6,w6,w7,ne
 sub w11,w4,#1075
 cmp w4,#0
 csel w11,w11,w7,ne
 add w24,w6,w11
 sub w25,w5,#1075
 cmp w5,#0
 csel w25,w25,w7,ne
 mul x13,x8,x9
 umulh x14,x8,x9
 orr x6,x13,x14
 cbz x6,.Lzero_product
 cbz x23,.Lclass_fast
 // Reproduce the reference counter choice from exact operand lengths.
 cmp w24,w25
 csel w10,w24,w25,lt
 clz x6,x14
 mov w7,#128
 sub w6,w7,w6
 clz x7,x13
 mov w8,#64
 sub w7,w8,w7
 cmp x14,#0
 csel w6,w6,w7,ne
 sub w7,w24,w10
 add w6,w6,w7
 cmp w6,#127
 b.gt .Lclass_wide
 clz x6,x23
 mov w7,#64
 sub w6,w7,w6
 sub w7,w25,w10
 add w6,w6,w7
 cmp w6,#127
 b.gt .Lclass_wide
.Lclass_fast:
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
 b .Lcount
.Lclass_wide:
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
.Lcount:
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 add x19,sp,#0
 add x20,sp,#536
 mov x6,x19
 movi v3.16b,#0
 mov w7,#16
.Lclear:
 stp q3,q3,[x6,#0]
 stp q3,q3,[x6,#32]
 add x6,x6,#64
 subs w7,w7,#1
 b.ne .Lclear
 stp q3,q3,[x6],#32
 str q3,[x6],#16
 // Insert the product's two words and the addend's significand.
 add w0,w24,#2148
 uxtw x0,w0
 mov x1,x19
 mov x2,x13
 bl .Linsert
 add w0,w24,#2212
 uxtw x0,w0
 mov x1,x19
 mov x2,x14
 bl .Linsert
 add w0,w25,#2148
 uxtw x0,w0
 mov x1,x20
 mov x2,x23
 bl .Linsert
 mov x21,x19
 cmp w26,w27
 b.ne .Ldifferent_signs
 mov w22,w26
 mov x0,#0
 adds xzr,xzr,xzr
.Ladd:
 ldr x1,[x19,x0,lsl #3]
 ldr x2,[x20,x0,lsl #3]
 adcs x3,x1,x2
 str x3,[x19,x0,lsl #3]
 add x0,x0,#1
 // Loop control must preserve the arithmetic carry.
 sub x4,x0,#67
 cbnz x4,.Ladd
 b.cs .Ldomain
 b .Lround
.Ldifferent_signs:
 mov x0,#66
.Lcompare:
 ldr x1,[x19,x0,lsl #3]
 ldr x2,[x20,x0,lsl #3]
 cmp x1,x2
 b.hi .Lx_larger
 b.lo .Ly_larger
 subs x0,x0,#1
 b.pl .Lcompare
 mov x0,#0
 b .Lreturn_bits
.Lx_larger:
 mov w22,w26
 mov x5,x19
 mov x6,x20
 b .Lsubtract
.Ly_larger:
 mov w22,w27
 mov x5,x20
 mov x6,x19
.Lsubtract:
 mov x0,#0
 cmp xzr,xzr
.Lsub_loop:
 ldr x1,[x5,x0,lsl #3]
 ldr x2,[x6,x0,lsl #3]
 sbcs x3,x1,x2
 str x3,[x19,x0,lsl #3]
 add x0,x0,#1
 sub x4,x0,#67
 cbnz x4,.Lsub_loop
 b.cc .Ldomain
.Lround:
 mov x0,#66
.Lfind_high:
 ldr x1,[x21,x0,lsl #3]
 cbnz x1,.Lhave_high
 subs x0,x0,#1
 b.pl .Lfind_high
 lsl x0,x22,#63
 b .Lreturn_bits
.Lhave_high:
 clz x2,x1
 lsl x3,x0,#6
 add x3,x3,#63
 sub x3,x3,x2
 sub w24,w3,#2148
 // A subnormal result retains bits beginning at the fixed bit 1074.
 mov w25,#0
 mov x4,#1074
 mov w5,#-1022
 cmp w24,w5
 b.lt .Lsubnormal_shift
 sub x4,x3,#52
 b .Lextract
.Lsubnormal_shift:
 mov w25,#1
.Lextract:
 lsr x5,x4,#6
 and x6,x4,#63
 ldr x7,[x21,x5,lsl #3]
 lsr x23,x7,x6
 cbz x6,.Lsig_ready
 add x8,x5,#1
 cmp x8,#67
 b.hs .Lsig_ready
 ldr x7,[x21,x8,lsl #3]
 neg x8,x6
 lsl x7,x7,x8
 orr x23,x23,x7
.Lsig_ready:
 // Reduce all bits below the halfway bit to one sticky bit.
 sub x9,x4,#1
 lsr x10,x9,#6
 and x11,x9,#63
 mov x12,#0
 mov x0,#0
.Lsticky_words:
 cmp x0,x10
 b.hs .Lsticky_part
 ldr x1,[x21,x0,lsl #3]
 orr x12,x12,x1
 add x0,x0,#1
 b .Lsticky_words
.Lsticky_part:
 ldr x1,[x21,x10,lsl #3]
 mov x2,#1
 lsl x2,x2,x11
 sub x2,x2,#1
 and x2,x2,x1
 orr x12,x12,x2
 lsr x1,x1,x11
 and x1,x1,#1
 orr x2,x12,x1
 cmp x2,#0
 cset w26,ne
 cbz x1,.Lrounded
 cbnz x12,.Lround_up
 tbz x23,#0,.Lrounded
.Lround_up:
 add x23,x23,#1
.Lrounded:
 lsl x0,x22,#63
 lsl w1,w26,#4
 cbz w25,.Lnormal_result
 cbz w26,.Lsubnormal_exact
 orr w1,w1,#8
.Lsubnormal_exact:
 orr x0,x0,x23
 b .Lset_status
.Lnormal_result:
 mov x2,#0x20000000000000
 cmp x23,x2
 b.ne .Lnormal_exponent
 lsr x23,x23,#1
 add w24,w24,#1
.Lnormal_exponent:
 cmp w24,#1023
 b.le .Lfinite_result
 mov x2,#0x7ff0000000000000
 orr x0,x0,x2
 mov w1,#20
 b .Lset_status
.Lfinite_result:
 add w2,w24,#1023
 orr x0,x0,x2,lsl #52
 and x23,x23,#0xfffffffffffff
 orr x0,x0,x23
.Lset_status:
 cbz w1,.Lreturn_bits
 mrs x2,fpsr
 orr x2,x2,x1
 msr fpsr,x2
.Lreturn_bits:
 fmov d0,x0
.Lreturn:
 add x17,sp,#1616
 ldp x19,x20,[x17,#0]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 add sp,sp,#1728
 ret
.Lzero_product:
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 cbz x23,.Lzero_both
 mov x0,x28
 b .Lreturn_bits
.Lzero_both:
 and x0,x26,x27
 lsl x0,x0,#63
 b .Lreturn_bits
.Ldomain:
 mov w0,#116
 bl _exit
 brk #116
.size md2asm_round_product_sum_candidate,.-md2asm_round_product_sum_candidate
// Insert a 64-bit word into a zeroed limb array. x0 is a bit index,
// x1 is the array and x2 is the word. The last write is within 67 limbs.
.Linsert:
 lsr x3,x0,#6
 and x4,x0,#63
 add x5,x1,x3,lsl #3
 lsl x6,x2,x4
 ldr x7,[x5]
 orr x7,x7,x6
 str x7,[x5]
 cbz x4,.Linsert_done
 neg x4,x4
 lsr x6,x2,x4
 ldr x7,[x5,#8]
 orr x7,x7,x6
 str x7,[x5,#8]
.Linsert_done:
 ret
.global md2asm_diagnostic_status_clear
.type md2asm_diagnostic_status_clear,%function
md2asm_diagnostic_status_clear:
 msr fpsr,xzr
 ret
.size md2asm_diagnostic_status_clear,.-md2asm_diagnostic_status_clear
.global md2asm_diagnostic_status_read
.type md2asm_diagnostic_status_read,%function
md2asm_diagnostic_status_read:
 mrs x0,fpsr
 ret
.size md2asm_diagnostic_status_read,.-md2asm_diagnostic_status_read
.bss
.p2align 3
.global md2asm_product_sum_fast_calls
.type md2asm_product_sum_fast_calls,%object
.size md2asm_product_sum_fast_calls,8
md2asm_product_sum_fast_calls: .zero 8
.global md2asm_product_sum_wide_calls
.type md2asm_product_sum_wide_calls,%object
.size md2asm_product_sum_wide_calls,8
md2asm_product_sum_wide_calls: .zero 8
.section .note.GNU-stack,"",%progbits

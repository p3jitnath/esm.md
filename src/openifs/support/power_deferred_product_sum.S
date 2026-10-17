/* Private atomic POWER entry. Borrow x27 as a read-only pending FPSR mask.
 * Preserve all saved registers and original fast/wide counter classification.
 * d0..d2 inputs, d0 result, w1=required mask. General return sets w1=0.
 * The only extra frame is 16 bytes across each child or the original general call. */
.arch armv8-a
.text
.p2align 4
.global md2asm_private_power_product_sum_deferred
.hidden md2asm_private_power_product_sum_deferred
.type md2asm_private_power_product_sum_deferred,%function
md2asm_private_power_product_sum_deferred:
 stp x29,x30,[sp,#-16]!
 bl md2asm_private_compact_deferred
 ldp x29,x30,[sp],#16
 cbnz w0,.Ldeferred_atomic_wide
 adrp x6,:got:md2asm_product_sum_fast_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x7,[x6]
 add x7,x7,#1
 str x7,[x6]
 ret
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
 adrp x6,:got:md2asm_product_sum_wide_calls
 ldr x6,[x6,:got_lo12:md2asm_product_sum_wide_calls]
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
.section .note.GNU-stack,"",%progbits

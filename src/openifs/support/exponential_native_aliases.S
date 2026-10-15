// Solver contract skills/md2asm/references/openifs/support/exponential_native_binding.md.
/* Original scalar EXP names; numerical body remains unchanged.
 * Contract: skills/md2asm/references/openifs/support/exponential_native_binding.md in this directory.
 * AAPCS64 input/result d0, FPCR zero. One integer counter precedes a tail jump.
 */
.arch armv8.2-a
.text
.p2align 4
.global exp
.global __exp_finite
.type exp,%function
.type __exp_finite,%function
exp:
__exp_finite:
 adrp x9,.Lexp_native_calls
 add x9,x9,:lo12:.Lexp_native_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 b md2asm_exp_original_rounding
.size exp,.-exp
.size __exp_finite,.-__exp_finite
.global md2asm_exponential_native_count_get
.type md2asm_exponential_native_count_get,%function
md2asm_exponential_native_count_get:
 adrp x9,.Lexp_native_calls
 ldr x0,[x9,:lo12:.Lexp_native_calls]
 ret
.size md2asm_exponential_native_count_get,.-md2asm_exponential_native_count_get
.bss
.p2align 3
.Lexp_native_calls: .zero 8
.section .note.GNU-stack,"",%progbits

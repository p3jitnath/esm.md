// Original POWER diagnostic owners and status-only services; no numerical stage.
.arch armv8-a
.bss
.balign 8
.global md2asm_product_sum_fast_calls
.type md2asm_product_sum_fast_calls,%object
md2asm_product_sum_fast_calls: .zero 8
.size md2asm_product_sum_fast_calls,8
.global md2asm_product_sum_wide_calls
.type md2asm_product_sum_wide_calls,%object
md2asm_product_sum_wide_calls: .zero 8
.size md2asm_product_sum_wide_calls,8
.text
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
.section .note.GNU-stack,"",%progbits

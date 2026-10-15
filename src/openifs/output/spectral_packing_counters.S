/* Serial spectral fit and LOG counters; return uint64 in x0.
 * Contract: skills/md2asm/references/openifs/output/spectral_packing_fit.md.
 * Leaves use no stack and preserve x18, saved state, FPCR/FPSR and errno.
 */
.text
.global md2asm_spectral_fit_count_get
.type md2asm_spectral_fit_count_get,%function
.hidden md2asm_fitspectrum_direct_calls
md2asm_spectral_fit_count_get:
 adrp x0,md2asm_fitspectrum_direct_calls
 add x0,x0,:lo12:md2asm_fitspectrum_direct_calls
 ldr x0,[x0]
 ret
.size md2asm_spectral_fit_count_get,.-md2asm_spectral_fit_count_get
.global md2asm_spectral_log_count_get
.type md2asm_spectral_log_count_get,%function
.hidden md2asm_log_positive_normal_calls
md2asm_spectral_log_count_get:
 adrp x0,md2asm_log_positive_normal_calls
 add x0,x0,:lo12:md2asm_log_positive_normal_calls
 ldr x0,[x0]
 ret
.size md2asm_spectral_log_count_get,.-md2asm_spectral_log_count_get
.section .note.GNU-stack,"",%progbits

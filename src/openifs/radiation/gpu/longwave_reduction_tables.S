/* Complete longwave corrections and relative weights.
 * Contract: skills/md2fort-gpu/references/openifs/radiation/longwave_corrections_weights_complete_contract.md
 * Original source: src/openifs/radiation/longwave_reduction_tables.S
 */
// Original contract: skills/md2fort/references/openifs/radiation/longwave_gpoint_reduction.md
// Device functions perform the complete source arithmetic.
.text
.p2align 4
.global md2asm_longwave_corrections_and_weights
.hidden md2asm_longwave_corrections_and_weights
.type md2asm_longwave_corrections_and_weights,%function
md2asm_longwave_corrections_and_weights:
 b md2asm_gpu_longwave_corrections_weights_phase_host
.size md2asm_longwave_corrections_and_weights,.-md2asm_longwave_corrections_and_weights
.section .rodata
.p2align 3
.Lcorrection_step:
 .double 0.005
.section .note.GNU-stack,"",%progbits

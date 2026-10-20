// Complete GPU Planck table. Contract: skills/md2asm-gpu/references/openifs/radiation/selected_spectral_planck_table_complete_contract.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_fill_selected_spectral_planck_table
.type md2asm_fill_selected_spectral_planck_table,%function
md2asm_fill_selected_spectral_planck_table:
 b md2asm_gpu_selected_planck_table_phase_host
.size md2asm_fill_selected_spectral_planck_table,.-md2asm_fill_selected_spectral_planck_table
.section .rodata
.p2align 3
.Lspt_range_constants:
 .double 1.0e-6,0.8,200.0e-6,20.0e-6,100.0
.section .note.GNU-stack,"",%progbits

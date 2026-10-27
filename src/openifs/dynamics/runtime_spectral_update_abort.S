// Physics formulations/openifs/dynamics/spectral_semi_implicit_update.md.
// Contract skills/md2asm/references/openifs/dynamics/runtime_pressure_and_rotation.md.
.text
.p2align 2
.global md2asm_abort_runtime_spectral_update
.hidden md2asm_abort_runtime_spectral_update
.type md2asm_abort_runtime_spectral_update,%function
md2asm_abort_runtime_spectral_update:
 mov w0,#0x44000000
 mov w1,#3
 bl MPI_Abort
 brk #0
.size md2asm_abort_runtime_spectral_update,.-md2asm_abort_runtime_spectral_update
.section .note.GNU-stack,"",%progbits

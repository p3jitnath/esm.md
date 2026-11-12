// Contract: skills/md2fort-gpu/references/openifs/radiation/aerosol_climatology_preparation.md.
/* Original integer-only three-child getter and assembly-owned diagnostic bytes. */
.arch armv8-a
.text
.p2align 2
.global md2asm_gpu_radact_child_count_get
.type md2asm_gpu_radact_child_count_get,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_radact_private_child_count_get
.type md2asm_radact_private_child_count_get,%function
md2asm_radact_private_child_count_get:
#endif
md2asm_gpu_radact_child_count_get:
cmp w0,#3
b.hs .Lradact_count_zero
adrp x1,md2asm_gpu_radact_child_counts_storage
add x1,x1,:lo12:md2asm_gpu_radact_child_counts_storage
ldr x0,[x1,x0,lsl #3]
ret
.Lradact_count_zero:mov x0,#0
ret
.size md2asm_gpu_radact_child_count_get,.-md2asm_gpu_radact_child_count_get
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_radact_private_child_count_get,.-md2asm_radact_private_child_count_get
#endif
.bss
.p2align 3
.global md2asm_gpu_radact_child_counts_storage
.hidden md2asm_gpu_radact_child_counts_storage
.type md2asm_gpu_radact_child_counts_storage,%object
md2asm_gpu_radact_child_counts_storage:.zero 24
.size md2asm_gpu_radact_child_counts_storage,24
.section .note.GNU-stack,"",%progbits

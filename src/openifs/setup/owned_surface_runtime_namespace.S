/* Contract: skills/md2asm/references/openifs/setup/ecmwf_physics_setup.md.
 * Explicit owned storage for runtime inputs; no original module is borrowed.
 * LSCMEC@0/LVDFTRAJ@4 are caller-produced selected zero logical words.
 * LROUGH@8 and REXTZ0M/H@16/@24 use the original ELF zero-fill policy.
 * Four padding bytes@12 remain untouched. This is no declared type default. */
.arch armv8.2-a
.bss
.p2align 3
.global md2asm_owned_surface_runtime_inputs
.type md2asm_owned_surface_runtime_inputs,%object
md2asm_owned_surface_runtime_inputs:
 .skip 32
.size md2asm_owned_surface_runtime_inputs,32
.section .note.GNU-stack,"",%progbits
.global __yommp0_MOD_lscmec
.type __yommp0_MOD_lscmec,%object
.set __yommp0_MOD_lscmec,md2asm_owned_surface_runtime_inputs
.size __yommp0_MOD_lscmec,4
.global __yomobs_MOD_lvdftraj
.type __yomobs_MOD_lvdftraj,%object
.set __yomobs_MOD_lvdftraj,md2asm_owned_surface_runtime_inputs+4
.size __yomobs_MOD_lvdftraj,4
.global __yomct0_MOD_lrough
.type __yomct0_MOD_lrough,%object
.set __yomct0_MOD_lrough,md2asm_owned_surface_runtime_inputs+8
.size __yomct0_MOD_lrough,4
.global __yomct0_MOD_rextz0m
.type __yomct0_MOD_rextz0m,%object
.set __yomct0_MOD_rextz0m,md2asm_owned_surface_runtime_inputs+16
.size __yomct0_MOD_rextz0m,8
.global __yomct0_MOD_rextz0h
.type __yomct0_MOD_rextz0h,%object
.set __yomct0_MOD_rextz0h,md2asm_owned_surface_runtime_inputs+24
.size __yomct0_MOD_rextz0h,8

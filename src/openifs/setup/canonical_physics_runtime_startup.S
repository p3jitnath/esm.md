/* Source-bound startup for the canonical physics runtime record.
 * Contract: skills/md2asm/references/openifs/setup/canonical_physics_runtime_startup.md.
 * int md2asm_initialize_canonical_physics_runtime_inputs(void).
 * The linked owner has 32 writable bytes and eight-byte alignment.
 * The accepted child writes source-default fields and preserves padding at bytes 12 through 15.
 * This tail entry preserves x18, saved registers, SP, FPCR, FPSR and errno. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_canonical_physics_runtime_inputs
.type md2asm_initialize_canonical_physics_runtime_inputs,%function
md2asm_initialize_canonical_physics_runtime_inputs:
 adrp x0,:got:md2asm_owned_surface_runtime_inputs
 ldr x0,[x0,:got_lo12:md2asm_owned_surface_runtime_inputs]
 mov x1,#32
 b md2asm_initialize_ecmwf_physics_runtime_inputs
.size md2asm_initialize_canonical_physics_runtime_inputs,.-md2asm_initialize_canonical_physics_runtime_inputs
.section .note.GNU-stack,"",%progbits

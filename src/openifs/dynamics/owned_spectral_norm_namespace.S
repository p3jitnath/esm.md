/* Owned persistent numerical norm state for original-compatible consumers.
 * Contract: skills/md2asm/references/openifs/dynamics/selected_spectral_norms.md.
 * Pass this same 24-byte address as x5 to the explicit norm utility. */
.bss
.p2align 3
.global md2asm_owned_spectral_norm_state
.type md2asm_owned_spectral_norm_state,%object
md2asm_owned_spectral_norm_state:
.zero 24
.size md2asm_owned_spectral_norm_state,24
.global __yomspnrm_MOD_avnrmdiv
.type __yomspnrm_MOD_avnrmdiv,%object
.set __yomspnrm_MOD_avnrmdiv,md2asm_owned_spectral_norm_state+0
.size __yomspnrm_MOD_avnrmdiv,8
.global __yomspnrm_MOD_avnrmpd
.type __yomspnrm_MOD_avnrmpd,%object
.set __yomspnrm_MOD_avnrmpd,md2asm_owned_spectral_norm_state+8
.size __yomspnrm_MOD_avnrmpd,8
.global __yomspnrm_MOD_avnrmvd
.type __yomspnrm_MOD_avnrmvd,%object
.set __yomspnrm_MOD_avnrmvd,md2asm_owned_spectral_norm_state+16
.size __yomspnrm_MOD_avnrmvd,8
.section .note.GNU-stack,"",%progbits

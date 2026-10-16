/* Contract: skills/md2asm/references/openifs/setup/selected_initialization_controls.md. */
/* Owned scalar addresses; call the explicit producer before reading them. */
.bss
.p2align 3
.global md2asm_owned_initialization_controls
.type md2asm_owned_initialization_controls,%object
md2asm_owned_initialization_controls:.zero 24
.size md2asm_owned_initialization_controls,24
.global __yomini_MOD_ldfi
.type __yomini_MOD_ldfi,%object
.set __yomini_MOD_ldfi,md2asm_owned_initialization_controls+0
.size __yomini_MOD_ldfi,4
.global __yomini_MOD_lbias
.type __yomini_MOD_lbias,%object
.set __yomini_MOD_lbias,md2asm_owned_initialization_controls+4
.size __yomini_MOD_lbias,4
.global __yomini_MOD_lincr
.type __yomini_MOD_lincr,%object
.set __yomini_MOD_lincr,md2asm_owned_initialization_controls+8
.size __yomini_MOD_lincr,4
.global __yomini_MOD_liniter
.type __yomini_MOD_liniter,%object
.set __yomini_MOD_liniter,md2asm_owned_initialization_controls+12
.size __yomini_MOD_liniter,4
.global __yomini_MOD_lscrini
.type __yomini_MOD_lscrini,%object
.set __yomini_MOD_lscrini,md2asm_owned_initialization_controls+16
.size __yomini_MOD_lscrini,4
.global __yomvar_MOD_ljcdfi
.type __yomvar_MOD_ljcdfi,%object
.set __yomvar_MOD_ljcdfi,md2asm_owned_initialization_controls+20
.size __yomvar_MOD_ljcdfi,4

.section .note.GNU-stack,"",%progbits

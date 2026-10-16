/* External transform helper binding to the accepted direct assembly body.
 * Inverse uses ten addresses and forward uses eleven, with x0..x7 first.
 * Their remaining addresses stay in the unchanged incoming stack slots.
 * This tail branch preserves every argument, saved register and return address.
 * Contracts: skills/md2asm/references/openifs/dynamics/inverse_legendre_reconstruction.md
 * and skills/md2asm/references/openifs/dynamics/legendre_wave_analysis.md.
 */
.arch armv8.2-a
.text
.p2align 2
.global __leinv_mod_MOD_leinv
.type __leinv_mod_MOD_leinv,%function
__leinv_mod_MOD_leinv:
 b md2asm_ltinv_leinv
.size __leinv_mod_MOD_leinv,.-__leinv_mod_MOD_leinv
.p2align 2
.global __ledir_mod_MOD_ledir
.type __ledir_mod_MOD_ledir,%function
__ledir_mod_MOD_ledir:
 b md2asm_ltdir_ledir_child_7358525
.size __ledir_mod_MOD_ledir,.-__ledir_mod_MOD_ledir
.section .note.GNU-stack,"",%progbits

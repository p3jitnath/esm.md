// YOMPPC declares these words without initial values. Define storage only.
// The source backup writer defines the count and active prefix before use.
.bss
.p2align 3
.global md2asm_owned_fullpos_physics_backup
.hidden md2asm_owned_fullpos_physics_backup
.type md2asm_owned_fullpos_physics_backup,%object
md2asm_owned_fullpos_physics_backup:
.global __yomppc_MOD_nfpphy
.type __yomppc_MOD_nfpphy,%object
__yomppc_MOD_nfpphy: .skip 4
.size __yomppc_MOD_nfpphy,4
.skip 4
.global __yomppc_MOD_mfpphy
.type __yomppc_MOD_mfpphy,%object
__yomppc_MOD_mfpphy: .skip 6556
.size __yomppc_MOD_mfpphy,6556
.skip 4
.size md2asm_owned_fullpos_physics_backup,6568
.section .note.GNU-stack,"",%progbits

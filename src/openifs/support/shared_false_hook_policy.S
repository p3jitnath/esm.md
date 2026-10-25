// Contract: skills/md2asm/references/openifs/support/shared_hook_snow_providers.md.
// One assembly-owned, aligned int32 false word; all spellings share its address.
.section .rodata
.p2align 2
.global md2asm_owned_shared_false_hook_policy
.type md2asm_owned_shared_false_hook_policy,%object
md2asm_owned_shared_false_hook_policy: .word 0
.size md2asm_owned_shared_false_hook_policy,4
.global __yomhook_MOD_lhook
.type __yomhook_MOD_lhook,%object
.set __yomhook_MOD_lhook,md2asm_owned_shared_false_hook_policy
.size __yomhook_MOD_lhook,4
.global md2asm_owned_height_wind_hook_policy
.type md2asm_owned_height_wind_hook_policy,%object
.set md2asm_owned_height_wind_hook_policy,md2asm_owned_shared_false_hook_policy
.size md2asm_owned_height_wind_hook_policy,4
.section .note.GNU-stack,"",%progbits

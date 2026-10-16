/* Optional owned descriptor exports; create takes this same 192-byte state. */
.bss
.p2align 3
.global md2asm_owned_empty_trajectory_state
.type md2asm_owned_empty_trajectory_state,%object
md2asm_owned_empty_trajectory_state:
.zero 192
.size md2asm_owned_empty_trajectory_state,192
.global __yomtraj_MOD_msteptrajw
.type __yomtraj_MOD_msteptrajw,%object
.set __yomtraj_MOD_msteptrajw,md2asm_owned_empty_trajectory_state
.size __yomtraj_MOD_msteptrajw,64
.global __yomtraj_MOD_msteptrajr
.type __yomtraj_MOD_msteptrajr,%object
.set __yomtraj_MOD_msteptrajr,md2asm_owned_empty_trajectory_state+64
.size __yomtraj_MOD_msteptrajr,64
.global __yomtraj_MOD_trajec
.type __yomtraj_MOD_trajec,%object
.set __yomtraj_MOD_trajec,md2asm_owned_empty_trajectory_state+128
.size __yomtraj_MOD_trajec,64
.section .note.GNU-stack,"",%progbits

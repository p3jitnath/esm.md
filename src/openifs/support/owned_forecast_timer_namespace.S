/* Optional caller-owned timer storage. Initialize once from the live FIAT clock.
 * Contract: skills/md2asm/references/openifs/support/forecast_timer_initialization.md. */
.bss
.p2align 3
.global md2asm_owned_forecast_timers
.type md2asm_owned_forecast_timers,%object
md2asm_owned_forecast_timers:.zero 24
.size md2asm_owned_forecast_timers,24
.global __yomtim_MOD_rstart
.type __yomtim_MOD_rstart,%object
.set __yomtim_MOD_rstart,md2asm_owned_forecast_timers
.size __yomtim_MOD_rstart,8
.global __yomtim_MOD_rvstart
.type __yomtim_MOD_rvstart,%object
.set __yomtim_MOD_rvstart,md2asm_owned_forecast_timers+8
.size __yomtim_MOD_rvstart,8
.global __yomtim_MOD_rtimef
.type __yomtim_MOD_rtimef,%object
.set __yomtim_MOD_rtimef,md2asm_owned_forecast_timers+16
.size __yomtim_MOD_rtimef,8
.section .note.GNU-stack,"",%progbits

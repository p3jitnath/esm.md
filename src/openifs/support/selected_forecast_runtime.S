/* Selected own forecast runtime, revision 1.
 * Contract: skills/md2asm/references/openifs/support/selected_forecast_runtime.md.
 * Initialization x0 immutable int32[2]={simulation index0, scheduler signals0}.
 * Return0 or2 before mutation. Its complete8-byte input is mapped/aligned4.
 * Getter has no argument and returns the owned int32 index in w0.
 * SIGPOST keeps the original void ABI with unused int32 time address in x0.
 * Integer leaves preserve x18, saved registers, FPCR, FPSR and errno.
 * Scheduler signaling is disabled in the selected forecast. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_forecast_runtime
.type md2asm_initialize_selected_forecast_runtime,%function
md2asm_initialize_selected_forecast_runtime:
 cbz x0,.Lruntime_bad
 tst x0,#3
 b.ne .Lruntime_bad
 adds x9,x0,#8
 b.cs .Lruntime_bad
 ldp w10,w11,[x0]
 orr w12,w10,w11
 cbnz w12,.Lruntime_bad
 adrp x9,md2asm_owned_forecast_runtime_words
 add x9,x9,:lo12:md2asm_owned_forecast_runtime_words
 stp w10,w11,[x9]
 mov w0,#0
 ret
.Lruntime_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_forecast_runtime,.-md2asm_initialize_selected_forecast_runtime
.p2align 4
.global __algorithm_state_mod_MOD_get_nsim4d
.type __algorithm_state_mod_MOD_get_nsim4d,%function
__algorithm_state_mod_MOD_get_nsim4d:
 adrp x9,md2asm_owned_forecast_runtime_words
 ldr w0,[x9,:lo12:md2asm_owned_forecast_runtime_words]
 ret
.size __algorithm_state_mod_MOD_get_nsim4d,.-__algorithm_state_mod_MOD_get_nsim4d
.p2align 4
.global sigpost_
.type sigpost_,%function
sigpost_:
 adrp x9,md2asm_owned_forecast_runtime_words
 add x9,x9,:lo12:md2asm_owned_forecast_runtime_words
 ldr w10,[x9,#4]
 cbnz w10,.Lruntime_unsupported_signal
 ret
.Lruntime_unsupported_signal:
 mov w0,#125
 b _exit
.size sigpost_,.-sigpost_
.data
.p2align 3
.global md2asm_owned_forecast_runtime_words
.type md2asm_owned_forecast_runtime_words,%object
md2asm_owned_forecast_runtime_words:
 .word 0,0
.size md2asm_owned_forecast_runtime_words,8
.global __yomct0_MOD_lsmssig
.set __yomct0_MOD_lsmssig,md2asm_owned_forecast_runtime_words+4
.type __yomct0_MOD_lsmssig,%object
.size __yomct0_MOD_lsmssig,4
.section .note.GNU-stack,"",%progbits

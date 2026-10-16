// Contract: skills/md2asm/references/openifs/setup/fresh_forecast_continuation.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_release_selected_fresh_forecast
.type md2asm_release_selected_fresh_forecast,%function
md2asm_release_selected_fresh_forecast:
 adrp x9,md2asm_owned_fresh_forecast_state
 add x9,x9,:lo12:md2asm_owned_fresh_forecast_state
 ldr x10,[x9,#112]
 cbz x10,.Lfresh_release_ok
 cmp x10,#31
 b.ne .Lfresh_release_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x9
 adrp x20,md2asm_owned_physics_runtime_data
 add x20,x20,:lo12:md2asm_owned_physics_runtime_data
 ldr x0,[x19]
 bl free
 str xzr,[x19]
 mov x21,#472
.Lfresh_release_array:
 ldr x0,[x20,x21]
 bl free
 str xzr,[x20,x21]
 cmp x21,#64
 b.eq .Lfresh_release_finished
 sub x21,x21,#136
 b .Lfresh_release_array
.Lfresh_release_finished:
 str xzr,[x19,#112]
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
.Lfresh_release_ok:
 mov w0,#0
 ret
.Lfresh_release_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_fresh_forecast,.-md2asm_release_selected_fresh_forecast
.section .note.GNU-stack,"",%progbits

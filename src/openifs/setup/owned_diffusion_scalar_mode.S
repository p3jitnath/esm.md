/* Contract: skills/md2asm/references/openifs/surface/runtime_surface_turbulence.md.
 * The entry publishes only the selected source words and returns 0 or 2.
 * No stack, allocation or floating-point operation is used. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_owned_diffusion_scalar_mode
.type md2asm_initialize_owned_diffusion_scalar_mode,%function
md2asm_initialize_owned_diffusion_scalar_mode:
 cbz x0,.Lmode_bad
 tst x0,#7
 b.ne .Lmode_bad
 cmp x1,#112
 b.lo .Lmode_bad
 adds x9,x0,#112
 b.cs .Lmode_bad
 adrp x9,:got:md2asm_owned_forecast_scalar_data
 ldr x9,[x9,:got_lo12:md2asm_owned_forecast_scalar_data]
 cmp x9,x0
 b.ne .Lmode_bad
 ldr w9,[x0,#80]
 cbnz w9,.Lmode_bad
 ldp x9,x10,[x0,#88]
 orr x9,x9,x10
 cbnz x9,.Lmode_bad
 mov w9,#-1
 str w9,[x0,#104]
 mov w0,#0
 ret
.Lmode_bad:
 mov w0,#2
 ret
.size md2asm_initialize_owned_diffusion_scalar_mode,.-md2asm_initialize_owned_diffusion_scalar_mode
.section .note.GNU-stack,"",%progbits

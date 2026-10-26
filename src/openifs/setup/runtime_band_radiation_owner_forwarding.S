/* Contract: skills/md2asm/references/openifs/setup/runtime_band_radiation_owner_forwarding.md.
 * x0 MODEL4275088, x1 capacity; first-call create or owned solar release.
 * Reuse accepted complete SULWN and selected SUSWN; no new FP arithmetic.
 */
.arch armv8.2-a
.text
.p2align 4
.macro BAND_OWNER reg,symbol
 adrp \reg,:got:\symbol
 ldr \reg,[\reg,:got_lo12:\symbol]
.endm
.macro BAND_SPAN reg,count,slot
 cbz \reg,.Llive_band_bad
 tst \reg,#7
 b.ne .Llive_band_bad
 mov x9,#\count
 adds x10,\reg,x9
 b.cs .Llive_band_bad
 stp \reg,x10,[sp,#96+16*\slot]
.endm
.global md2asm_initialize_runtime_band_radiation_from_model
.type md2asm_initialize_runtime_band_radiation_from_model,%function
md2asm_initialize_runtime_band_radiation_from_model:
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 cbz x19,.Llive_band_bad
 tst x19,#7
 b.ne .Llive_band_bad
 movz x9,#0x3b90
 movk x9,#0x41,lsl#16
 cmp x1,x9
 b.lo .Llive_band_bad
 adds x10,x19,x9
 b.cs .Llive_band_bad
 stp x19,x10,[sp,#96]
 movz x9,#15820
 movk x9,#63,lsl#16
 ldr w9,[x19,x9]
 cbnz w9,.Llive_band_bad
 BAND_OWNER x20,md2asm_owned_initial_physical_constants
 BAND_OWNER x21,md2asm_owned_dynamical_namespace
 BAND_OWNER x22,md2asm_owned_legacy_longwave_band_parameters
 BAND_SPAN x20,520,1
 BAND_SPAN x21,320,2
 BAND_SPAN x22,9440,3
 add x9,sp,#96
 mov x10,#0
.Llive_band_outer:
 ldp x11,x12,[x9]
 add x13,x9,#16
 add x14,x10,#1
.Llive_band_inner:
 cmp x14,#4
 b.hs .Llive_band_next
 ldp x15,x16,[x13]
 cmp x11,x16
 b.hs .Llive_band_separate
 cmp x15,x12
 b.lo .Llive_band_bad
.Llive_band_separate:
 add x13,x13,#16
 add x14,x14,#1
 b .Llive_band_inner
.Llive_band_next:
 add x9,x9,#16
 add x10,x10,#1
 cmp x10,#3
 b.lo .Llive_band_outer
 mov x9,#9440
 stp x22,x9,[sp,#64]
 movz x9,#0x9410
 movk x9,#0x18,lsl#16
 add x9,x19,x9
 mov x10,#10744
 stp x9,x10,[sp,#80]
 add x0,sp,#64
 movz x9,#0x8c18
 movk x9,#0x18,lsl#16
 add x1,x19,x9
 mov x2,x20
 mov x3,x21
 bl md2asm_initialize_selected_spectral_radiation_tables
 b .Llive_band_return
.Llive_band_bad:
 mov w0,#2
.Llive_band_return:
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.size md2asm_initialize_runtime_band_radiation_from_model,.-md2asm_initialize_runtime_band_radiation_from_model
.p2align 4
.global md2asm_release_runtime_band_radiation_from_model
.type md2asm_release_runtime_band_radiation_from_model,%function
md2asm_release_runtime_band_radiation_from_model:
 cbz x0,.Llive_band_release_bad
 tst x0,#7
 b.ne .Llive_band_release_bad
 movz x9,#0x3b90
 movk x9,#0x41,lsl#16
 cmp x1,x9
 b.lo .Llive_band_release_bad
 adds x10,x0,x9
 b.cs .Llive_band_release_bad
 stp x29,x30,[sp,#-32]!
 str x18,[sp,#16]
 mov x29,sp
 movz x9,#0x9410
 movk x9,#0x18,lsl#16
 add x0,x0,x9
 mov x1,#10744
 bl md2asm_release_selected_spectral_radiation_tables
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Llive_band_release_bad:
 mov w0,#2
 ret
.size md2asm_release_runtime_band_radiation_from_model,.-md2asm_release_runtime_band_radiation_from_model
.section .note.GNU-stack,"",%progbits

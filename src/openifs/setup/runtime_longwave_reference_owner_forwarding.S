/* Contract: skills/md2asm/references/openifs/setup/runtime_longwave_reference_owner_forwarding.md.
 * x0 MODEL4275088, x1 capacity; actual TERDI and canonical output forwarding.
 * Reuse complete accepted SURDI/SURRTAB/SURRTPK/SURRTRF; no allocation.
 */
.arch armv8.2-a
.text
.p2align 4
.macro LW_CONST reg,value
 movz \reg,#(\value&65535)
 movk \reg,#(\value>>16),lsl#16
.endm
.macro LW_OWNER reg,symbol
 adrp \reg,:got:\symbol
 ldr \reg,[\reg,:got_lo12:\symbol]
.endm
.macro LW_APART p1,e1,p2,e2
 cmp \p1,\e2
 b.hs .Llw_apart\@
 cmp \p2,\e1
 b.lo .Llive_lw_bad
.Llw_apart\@:
.endm
.global md2asm_initialize_runtime_longwave_reference_from_model
.type md2asm_initialize_runtime_longwave_reference_from_model,%function
md2asm_initialize_runtime_longwave_reference_from_model:
 cbz x0,.Llive_lw_bad
 tst x0,#7
 b.ne .Llive_lw_bad
 LW_CONST x9,4275088
 cmp x1,x9
 b.lo .Llive_lw_bad
 adds x10,x0,x9
 b.cs .Llive_lw_bad
 mov x6,x0
 LW_OWNER x4,md2asm_owned_initial_physical_constants
 cbz x4,.Llive_lw_bad
 tst x4,#7
 b.ne .Llive_lw_bad
 adds x11,x4,#520
 b.cs .Llive_lw_bad
 LW_OWNER x7,md2asm_owned_longwave_reference_parameters
 cbz x7,.Llive_lw_bad
 tst x7,#7
 b.ne .Llive_lw_bad
 LW_CONST x9,68224
 adds x12,x7,x9
 b.cs .Llive_lw_bad
 LW_APART x6,x10,x4,x11
 LW_APART x6,x10,x7,x12
 LW_APART x4,x11,x7,x12
 LW_CONST x9,1856400
 add x2,x6,x9
 mov x0,x7
 LW_CONST x1,68224
 mov x3,#176
 mov x5,#520
 b md2asm_initialize_longwave_reference_parameters
.Llive_lw_bad:
 mov w0,#2
 ret
.size md2asm_initialize_runtime_longwave_reference_from_model,.-md2asm_initialize_runtime_longwave_reference_from_model
.section .note.GNU-stack,"",%progbits

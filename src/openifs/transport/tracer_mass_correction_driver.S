/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
/* Direct selected TRMFIXERS. Sixteen source addresses, fifteen-address direct QMFIXER child.
 * Contract tracer_mass_correction_contract.md. Caller owns all buffers and metadata.
 * Outgoing stack arguments occupy bytes 0..55. Preserved registers and locals start at 64.
 * The 352-byte frame preserves x18, x19-x29 and x30, with 16-byte stack alignment.
 */
.text
.p2align 4
.macro FIXER_CALL target
 str x18,[sp,#336]
 bl \target
 ldr x18,[sp,#336]
.endm
.global md2asm_trmfixers_address_r2_7358525
.type md2asm_trmfixers_address_r2_7358525,%function
md2asm_trmfixers_address_r2_7358525:
 mov x16,sp
 sub sp,sp,#352
 stp x18,x30,[sp,#64]
 stp x19,x20,[sp,#80]
 stp x21,x22,[sp,#96]
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 stp x4,x5,[sp,#144]
 stp x6,x7,[sp,#160]
 ldp x9,x10,[x16]
 stp x9,x10,[sp,#176]
 ldp x9,x10,[x16,#16]
 stp x9,x10,[sp,#192]
 ldp x9,x10,[x16,#32]
 stp x9,x10,[sp,#208]
 ldp x9,x10,[x16,#48]
 stp x9,x10,[sp,#224]
 cbz x4,.Lfixer_bad
 cbz x6,.Lfixer_bad
 ldr w9,[x6]
 cmp w9,#1
 b.ne .Lfixer_bad
 add x19,x4,#184
 ldr w9,[x19,#160]
 cmp w9,#1
 b.ne .Lfixer_bad
 ldr w9,[x19,#272]
 cmp w9,#1
 b.ne .Lfixer_bad
 ldr w9,[x19,#268]
 cbnz w9,.Lfixer_bad
 ldr w9,[x19,#276]
 cbnz w9,.Lfixer_bad
 ldr w9,[x19,#280]
 cbnz w9,.Lfixer_bad
 ldr w9,[x19,#284]
 cbnz w9,.Lfixer_bad
 mrs x9,fpcr
 cbnz x9,.Lfixer_bad
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#256]
 cbz w9,.Lfixer_dispatch
 adr x0,.Lfixer_name
 add x1,sp,#260
 str wzr,[x1]
 add x2,sp,#264
 mov x3,#9
 FIXER_CALL __yomhook_MOD_dr_hook_default8
.Lfixer_dispatch:
 ldp x0,x1,[sp,#112]
 ldp x2,x3,[sp,#128]
 mov x4,x19
 ldr x5,[sp,#152]
 ldr x6,[sp,#168]
 ldr x7,[sp,#176]
 ldr x9,[sp,#184]
 str x9,[sp]
 ldr x9,[sp,#192]
 str x9,[sp,#8]
 ldr x9,[sp,#200]
 str x9,[sp,#16]
 ldr x9,[sp,#208]
 str x9,[sp,#24]
 ldr x9,[sp,#216]
 str x9,[sp,#32]
 ldr x9,[sp,#224]
 str x9,[sp,#40]
 ldr x9,[sp,#232]
 str x9,[sp,#48]
 FIXER_CALL md2asm_qmfixer_address_r2_7358525
 ldr w9,[sp,#256]
 cbz w9,.Lfixer_return
 adr x0,.Lfixer_name
 add x1,sp,#260
 mov w9,#1
 str w9,[x1]
 add x2,sp,#264
 mov x3,#9
 FIXER_CALL __yomhook_MOD_dr_hook_default8
.Lfixer_return:
 ldp x18,x30,[sp,#64]
 ldp x19,x20,[sp,#80]
 ldp x21,x22,[sp,#96]
 add sp,sp,#352
 ret
.size md2asm_trmfixers_address_r2_7358525,.-md2asm_trmfixers_address_r2_7358525
.Lfixer_bad:
 mov w0,#166
 FIXER_CALL exit
 brk #0
.section .rodata
.Lfixer_name: .ascii "TRMFIXERS"
.section .note.GNU-stack,"",%progbits

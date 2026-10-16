/* STEPX.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.text
.p2align 4
.global md2asm_stepx_7358525
.type md2asm_stepx_7358525,%function
md2asm_stepx_7358525:
 mrs x9,fpcr
 cbnz x9,.Lsx_bad
 cbz x1,.Lsx_bad
 movz x10,#(527712&65535)
 movk x10,#((527712>>16)&65535),lsl #16
 ldr w9,[x1,x10]
 cbnz w9,.Lsx_bad
 movz x10,#(197072&65535)
 movk x10,#((197072>>16)&65535),lsl #16
 ldr w9,[x1,x10]
 cbnz w9,.Lsx_bad
 sub sp,sp,#128
 stp x19,x20,[sp,#0]
 stp x29,x30,[sp,#16]
 str x18,[sp,#32]
 stp x0,x1,[sp,#48]
 stp x2,x3,[sp,#64]
 // Source entry and exit hooks retain their separate LHOOK reads.
 adrp x19,:got:__yomhook_MOD_lhook
 ldr x19,[x19,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x19]
 cmp w9,#1
 b.hi .Lsx_bad
 cbz w9,.Lsx_exit_hook
 adr x0,.Lsx_name
 add x1,sp,#88
 str wzr,[x1]
 add x2,sp,#96
 mov x3,#5
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#32]
.Lsx_exit_hook:
 ldr w9,[x19]
 cmp w9,#1
 b.hi .Lsx_bad
 cbz w9,.Lsx_return
 adr x0,.Lsx_name
 add x1,sp,#88
 mov w9,#1
 str w9,[x1]
 add x2,sp,#96
 mov x3,#5
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#32]
.Lsx_return:
 ldr x18,[sp,#32]
 ldp x29,x30,[sp,#16]
 ldp x19,x20,[sp]
 add sp,sp,#128
 ret
.Lsx_bad:
 brk #0x7c2
 b .Lsx_bad
.size md2asm_stepx_7358525,.-md2asm_stepx_7358525
.section .rodata
.Lsx_name: .ascii "STEPX"
.section .note.GNU-stack,"",%progbits

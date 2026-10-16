/* WRMLPP.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.text
.p2align 4
.macro CALL symbol
 str x18,[sp,#352]
 bl \symbol
 ldr x18,[sp,#352]
.endm
.macro GLOBAL_WORD reg,symbol
 adrp x9,:got:\symbol
 ldr x9,[x9,:got_lo12:\symbol]
 ldr \reg,[x9]
.endm
.macro RECORD reg,base,offset
 movz x17,#(\offset & 65535)
 movk x17,#((\offset >> 16) & 65535),lsl #16
 add \reg,\base,x17
.endm

.global md2asm_wrmlpp_7358525
.type md2asm_wrmlpp_7358525,%function
md2asm_wrmlpp_7358525:
 sub sp,sp,#512
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 ldr x9,[sp,#512]
 str x9,[sp,#192]
 ldr x9,[sp,#520]
 str x9,[sp,#200]
 ldr x9,[sp,#528]
 str x9,[sp,#208]
 ldr x9,[sp,#536]
 str x9,[sp,#216]
 ldr x9,[sp,#544]
 str x9,[sp,#224]
 stp x19,x20,[sp,#256]
 stp x21,x22,[sp,#272]
 stp x23,x24,[sp,#288]
 stp x25,x26,[sp,#304]
 stp x27,x28,[sp,#320]
 stp x29,x30,[sp,#336]
 mrs x9,fpcr
 cbnz x9,.Lreject
 ldr x9,[sp,#224]
 cmp x9,#1
 b.ne .Lreject
 GLOBAL_WORD w9,__yomct0_MOD_larpegef
 cbnz w9,.Lreject
 GLOBAL_WORD w9,__yomct0_MOD_lecfpos
 cmp w9,#1
 b.ne .Lreject
 ldr x19,[sp,#184]
 RECORD x9,x19,1588296
 ldr w9,[x9]
 cbnz w9,.Lreject
 GLOBAL_WORD w9,__yomhook_MOD_lhook
 cbz w9,.Lhook_0_done
 adr x0,.Lhook_name_0
 mov w9,#0
 str w9,[sp,#360]
 add x1,sp,#360
 add x2,sp,#368
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Lhook_0_done:
 GLOBAL_WORD w9,__yomhook_MOD_lhook
 cbz w9,.Lhook_1_done
 adr x0,.Lhook_name_1
 mov w9,#1
 str w9,[sp,#360]
 add x1,sp,#360
 add x2,sp,#368
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Lhook_1_done:
 ldp x19,x20,[sp,#256]
 ldp x21,x22,[sp,#272]
 ldp x23,x24,[sp,#288]
 ldp x25,x26,[sp,#304]
 ldp x27,x28,[sp,#320]
 ldp x29,x30,[sp,#336]
 add sp,sp,#512
 ret
.Lreject:
 CALL abort
.size md2asm_wrmlpp_7358525,.-md2asm_wrmlpp_7358525
.section .rodata
.Lhook_name_0:
.ascii "WRMLPP"
.Lhook_name_1:
.ascii "WRMLPP"
.section .note.GNU-stack,"",%progbits

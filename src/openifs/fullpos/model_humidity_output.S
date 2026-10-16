/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
.text
.p2align 4
// Direct PPQ body, from model_humidity_output_contract.md.
// 17 raw addresses, no hidden length. Own every temporary and closing copy.
.macro ARG reg,index
 ldr \reg,[sp,#(512+8*\index)]
.endm
.macro CALL symbol
 str x18,[sp,#232]
 bl \symbol
 ldr x18,[sp,#232]
.endm
.global md2asm_ppq_7358525
.type md2asm_ppq_7358525,%function
md2asm_ppq_7358525:
 sub sp,sp,#2,lsl #12
 stp x29,x30,[sp,#128]
 mov x29,sp
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 add x9,sp,#512
 stp x0,x1,[x9]
 stp x2,x3,[x9,#16]
 stp x4,x5,[x9,#32]
 stp x6,x7,[x9,#48]
 add x10,sp,#2,lsl #12
 add x9,sp,#576
 mov x11,#9
.Lsave_stack:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lsave_stack
 mrs x9,fpcr
 cbnz x9,.Lreject
 ARG x9,0
 ldr w19,[x9]
 cmp w19,#24
 b.ne .Lreject
 ARG x9,1
 ldr w20,[x9]
 cmp w20,#1
 b.lt .Lreject
 ARG x9,2
 ldr w21,[x9]
 cmp w21,w20
 b.lt .Lreject
 cmp w21,#24
 b.gt .Lreject
 ARG x9,3
 ldr w22,[x9]
 cmp w22,#19
 b.ne .Lreject
 ARG x9,4
 ldr w23,[x9]
 cmp w23,#19
 b.ne .Lreject
 ARG x9,5
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lreject
 ARG x9,6
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lreject
 ARG x9,15
 cbz x9,.LBOB_false
 ldr w9,[x9]
 cbnz w9,.Lreject
.LBOB_false:
 mov w9,#2
 str w9,[sp,#720]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#736]
 cbz w9,.Lentry_done
 adr x0,.Lhook_name
 str wzr,[sp,#740]
 add x1,sp,#740
 add x2,sp,#728
 mov x3,#3
 CALL __yomhook_MOD_dr_hook_default8
.Lentry_done:
 sub w20,w20,#1
 ARG x26,13
 add x27,sp,#2048
 mov x25,#0
.Lcopy_level:
 madd x10,x25,x19,x20
 add x11,x10,x19
 mov x24,x20
.Lcopy_row:
 ldr x9,[x26,x10,lsl #3]
 str x9,[x27,x11,lsl #3]
 add x10,x10,#1
 add x11,x11,#1
 add x24,x24,#1
 cmp x24,x21
 b.lt .Lcopy_row
 add x25,x25,#1
 cmp x25,x22
 b.lt .Lcopy_level
 add x28,sp,#1024
 sub x25,x22,#1
 madd x10,x25,x19,x20
 mov x24,x20
.Lprepare_edges:
 add x11,x24,x19
 ldr x9,[x27,x11,lsl #3]
 str x9,[x27,x24,lsl #3]
 ldr x9,[x26,x10,lsl #3]
 str x9,[x28,x24,lsl #3]
 add x10,x10,#1
 add x24,x24,#1
 cmp x24,x21
 b.lt .Lprepare_edges
 // Child positions8 through15, in original PPINTP order.
 add x9,sp,#720
 str x9,[sp,#0]
 ARG x9,9
 str x9,[sp,#8]
 ARG x9,10
 str x9,[sp,#16]
 ARG x9,8
 str x9,[sp,#24]
 ARG x9,11
 str x9,[sp,#32]
 ARG x9,12
 str x9,[sp,#40]
 str x27,[sp,#48]
 ARG x9,14
 str x9,[sp,#56]
 add x9,sp,#512
 ldp x0,x1,[x9]
 ldp x2,x3,[x9,#16]
 ldp x4,x5,[x9,#32]
 ldp x6,x7,[x9,#48]
 CALL md2asm_ppintp_7358525
 ARG x26,10
 ARG x27,9
 ARG x28,14
 mov x25,#0
.Lextrap_level:
 ldr w9,[x26,x25,lsl #2]
 cbz w9,.Lnext_extrap_level
 madd x10,x25,x19,x20
 mov x24,x20
.Lextrap_row:
 ldr w9,[x27,x10,lsl #2]
 cbz w9,.Lnext_extrap_row
 add x11,sp,#1024
 ldr x9,[x11,x24,lsl #3]
 str x9,[x28,x10,lsl #3]
.Lnext_extrap_row:
 add x10,x10,#1
 add x24,x24,#1
 cmp x24,x21
 b.lt .Lextrap_row
.Lnext_extrap_level:
 add x25,x25,#1
 cmp x25,x23
 b.lt .Lextrap_level
 ldr w9,[sp,#736]
 cbz w9,.Lexit_done
 adr x0,.Lhook_name
 mov w9,#1
 str w9,[sp,#740]
 add x1,sp,#740
 add x2,sp,#728
 mov x3,#3
 CALL __yomhook_MOD_dr_hook_default8
.Lexit_done:
 ldr x18,[sp,#224]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldp x29,x30,[sp,#128]
 add sp,sp,#2,lsl #12
 ret
.Lreject:
 CALL abort
.size md2asm_ppq_7358525,.-md2asm_ppq_7358525
.section .rodata
.Lhook_name:
.ascii "PPQ"
.section .note.GNU-stack,"",%progbits

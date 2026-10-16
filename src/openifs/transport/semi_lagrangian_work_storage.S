/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
/* Direct retained transport storage, complete selected CALL_SL_HEAP2.
 * Physics formulations/openifs/dynamics/retained_transport_storage.md.
 * Contract skills/md2asm/references/openifs/dynamics/retained_transport_storage.md.
 * 20 ordinary data addresses, no numerical Fortran fallback. */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_call_sl_heap2_7358525
.global call_sl_heap2_
.set call_sl_heap2_,md2asm_call_sl_heap2_7358525
.type md2asm_call_sl_heap2_7358525,%function
md2asm_call_sl_heap2_7358525:
 mov x17,sp
 sub sp,sp,#512
 stp x18,x19,[sp,#128]
 stp x20,x21,[sp,#144]
 stp x22,x23,[sp,#160]
 stp x24,x25,[sp,#176]
 stp x26,x27,[sp,#192]
 stp x28,x29,[sp,#208]
 str x30,[sp,#224]
 mov x29,sp
 str x0,[sp,#256]
 str x1,[sp,#264]
 str x2,[sp,#272]
 str x3,[sp,#280]
 str x4,[sp,#288]
 str x5,[sp,#296]
 str x6,[sp,#304]
 str x7,[sp,#312]
 ldr x9,[x17,#0]
 str x9,[sp,#320]
 ldr x9,[x17,#8]
 str x9,[sp,#328]
 ldr x9,[x17,#16]
 str x9,[sp,#336]
 ldr x9,[x17,#24]
 str x9,[sp,#344]
 ldr x9,[x17,#32]
 str x9,[sp,#352]
 ldr x9,[x17,#40]
 str x9,[sp,#360]
 ldr x9,[x17,#48]
 str x9,[sp,#368]
 ldr x9,[x17,#56]
 str x9,[sp,#376]
 ldr x9,[x17,#64]
 str x9,[sp,#384]
 ldr x9,[x17,#72]
 str x9,[sp,#392]
 ldr x9,[x17,#80]
 str x9,[sp,#400]
 ldr x9,[x17,#88]
 str x9,[sp,#408]
 mrs x9,fpcr
 cbnz x9,.Lreject
 ldr x9,[x29,#256]
 ldr w10,[x9,#5144]
 cmp w10,#24
 b.ne .Lreject
 ldr w10,[x9,#5224]
 cmp w10,#19
 b.ne .Lreject
 ldr w10,[x9,#5160]
 cmp w10,#86
 b.ne .Lreject
 ldr x9,[x29,#272]
 movz x16,#63452
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#66
 b.ne .Lreject
 ldr x9,[x29,#272]
 movz x16,#63616
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#4
 b.ne .Lreject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[x29,#424]
 ldr w9,[x29,#424]
 cbz w9,.Lprofile0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#0
 str w9,[x29,#428]
 add x1,x29,#428
 add x2,x29,#432
 mov x3,#13
 bl __yomhook_MOD_dr_hook_default8
.Lprofile0:
 adrp x19,.Lretained
 add x19,x19,:lo12:.Lretained
 ldr x9,[x19]
 cbnz x9,.Lready
 movz x0,#37632
 movk x0,#9,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x19,#0]
 movz x0,#62208
 movk x0,#315,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x19,#8]
 movz x0,#9728
 movk x0,#19,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x19,#16]
.Lready:
 ldr x0,[x29,#256]
 ldr x1,[x29,#264]
 ldr x2,[x29,#272]
 ldr x3,[x29,#280]
 ldr x4,[x29,#288]
 ldr x5,[x29,#296]
 ldr x6,[x29,#304]
 ldr x7,[x29,#312]
 ldr x9,[x29,#320]
 str x9,[sp,#0]
 ldr x9,[x29,#328]
 str x9,[sp,#8]
 ldr x9,[x29,#336]
 str x9,[sp,#16]
 ldr x9,[x29,#344]
 str x9,[sp,#24]
 ldr x9,[x29,#352]
 str x9,[sp,#32]
 ldr x9,[x29,#360]
 str x9,[sp,#40]
 ldr x9,[x29,#368]
 str x9,[sp,#48]
 ldr x9,[x29,#376]
 str x9,[sp,#56]
 ldr x9,[x29,#384]
 str x9,[sp,#64]
 ldr x9,[x29,#392]
 str x9,[sp,#72]
 ldr x9,[x29,#400]
 str x9,[sp,#80]
 ldr x9,[x29,#408]
 str x9,[sp,#88]
 ldr x9,[x19,#0]
 str x9,[sp,#96]
 ldr x9,[x19,#8]
 str x9,[sp,#104]
 ldr x9,[x19,#16]
 str x9,[sp,#112]
 bl md2asm_call_sl_7358525
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w9,[x29,#424]
 cbz w9,.Lprofile1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[x29,#428]
 add x1,x29,#428
 add x2,x29,#432
 mov x3,#13
 bl __yomhook_MOD_dr_hook_default8
.Lprofile1:
 ldp x18,x19,[sp,#128]
 ldp x20,x21,[sp,#144]
 ldp x22,x23,[sp,#160]
 ldp x24,x25,[sp,#176]
 ldp x26,x27,[sp,#192]
 ldp x28,x29,[sp,#208]
 ldr x30,[sp,#224]
 add sp,sp,#512
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_call_sl_heap2_7358525,.-md2asm_call_sl_heap2_7358525
.global md2asm_call_sl_heap2_count_get
.type md2asm_call_sl_heap2_count_get,%function
md2asm_call_sl_heap2_count_get:
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x0,[x9]
 ret
.section .rodata
.Lname: .ascii "CALL_SL_HEAP2"
.bss
.p2align 3
.Lretained: .zero 24
.Lcalls: .zero 8
.section .note.GNU-stack,"",%progbits

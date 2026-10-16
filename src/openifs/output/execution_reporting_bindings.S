/* Contract: skills/md2asm/references/openifs/output/execution_reporting_bindings.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_attach_execution_reporting_context
.type md2asm_attach_execution_reporting_context,%function
md2asm_attach_execution_reporting_context:
 cbz x0,.Lreport_bad
 tst x0,#7
 b.ne .Lreport_bad
 cmp x1,#152
 b.lo .Lreport_bad
 adds x9,x0,#152
 b.cs .Lreport_bad
 ldr w9,[x0]
 cmp w9,#1
 b.lt .Lreport_bad
 ldr w9,[x0,#4]
 cmp w9,#0
 b.lt .Lreport_bad
 ldr w9,[x0,#8]
 cmp w9,#0
 b.lt .Lreport_bad
 ldr w9,[x0,#12]
 cmp w9,#0
 b.lt .Lreport_bad
 ldr w9,[x0,#16]
 cmp w9,#1
 b.hi .Lreport_bad
 ldr x9,[x0,#144]
 cbz x9,.Lreport_bad
 tst x9,#7
 b.ne .Lreport_bad
 adrp x10,.Lreport_context
 ldr x9,[x10,:lo12:.Lreport_context]
 cbz x9,.Lreport_attach
 cmp x9,x0
 b.ne .Lreport_bad
.Lreport_attach:
 str x0,[x10,:lo12:.Lreport_context]
 mov w0,#0
 ret
.Lreport_bad:
 mov w0,#2
 ret
.size md2asm_attach_execution_reporting_context,.-md2asm_attach_execution_reporting_context
.p2align 4
.global logdis_
.type logdis_,%function
logdis_:
 orr x9,x6,x7
 cbnz x9,.Lreport_stop
 adrp x9,.Lreport_context
 ldr x9,[x9,:lo12:.Lreport_context]
 cbz x9,.Lreport_stop
 sub sp,sp,#80
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x9
 ldr w9,[x0]
 str w9,[sp,#32]
 ldr w9,[x4]
 str w9,[sp,#36]
 ldr w9,[x5]
 str w9,[sp,#40]
 str wzr,[sp,#44]
 ldr x9,[x1]
 str x9,[sp,#48]
 ldr x9,[x2]
 str x9,[sp,#56]
 ldr x9,[x3]
 str x9,[sp,#64]
 mov x0,x19
 add x1,sp,#32
 bl md2asm_logdis_selected
 cbnz w0,.Lreport_stop
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.size logdis_,.-logdis_
.p2align 4
.global opdis_
.type opdis_,%function
opdis_:
 ldr x9,[sp,#8]
 cmp x9,#9
 b.ne .Lreport_stop
 adrp x9,.Lreport_context
 ldr x9,[x9,:lo12:.Lreport_context]
 cbz x9,.Lreport_stop
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x9
 ldr x9,[x0]
 str x9,[sp,#32]
 str xzr,[sp,#40]
 ldrb w9,[x0,#8]
 strb w9,[sp,#40]
 str x1,[sp,#48]
 ldr x9,[sp,#144]
 str x9,[sp,#56]
 ldr x9,[x2]
 str x9,[sp,#64]
 ldr x9,[x3]
 str x9,[sp,#72]
 ldr x9,[x4]
 str x9,[sp,#80]
 ldr x9,[x5]
 str x9,[sp,#88]
 ldr x9,[x6]
 str x9,[sp,#96]
 ldr w9,[x7]
 str w9,[sp,#104]
 ldr x9,[sp,#128]
 ldr w9,[x9]
 str w9,[sp,#108]
 mov x0,x19
 add x1,sp,#32
 bl md2asm_opdis_selected
 cbnz w0,.Lreport_stop
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.size opdis_,.-opdis_
.p2align 4
.global md2asm_detach_execution_reporting_context
.type md2asm_detach_execution_reporting_context,%function
md2asm_detach_execution_reporting_context:
 cbz x0,.Lreport_bad
 adrp x9,.Lreport_context
 ldr x9,[x9,:lo12:.Lreport_context]
 cmp x9,x0
 b.ne .Lreport_bad
 sub sp,sp,#32
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 mov x29,sp
 bl md2asm_close_reporting_status
 cbnz w0,.Lreport_detach_return
 adrp x9,.Lreport_context
 str xzr,[x9,:lo12:.Lreport_context]
.Lreport_detach_return:
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#32
 ret
.size md2asm_detach_execution_reporting_context,.-md2asm_detach_execution_reporting_context
.Lreport_stop:
 mov w0,#126
 b _exit
.bss
.p2align 3
.Lreport_context:.zero 8
.section .note.GNU-stack,"",%progbits

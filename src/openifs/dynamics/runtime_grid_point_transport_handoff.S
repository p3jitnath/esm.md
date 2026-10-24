/* Contract: skills/md2asm/references/openifs/dynamics/runtime_transport_field_handoff.md. */
/* Complete accepted CPG_DYN call followed by the CPG transport-field scatter.
 * x0 names 47 ordinary addresses. x1 names the read-only scatter context96. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_complete_grid_point_transport_handoff
.type md2asm_complete_grid_point_transport_handoff,%function
md2asm_complete_grid_point_transport_handoff:
 cbz x0,.Lhandoff_bad_direct
 cbz x1,.Lhandoff_bad_direct
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lhandoff_bad_direct
 adds x9,x0,#376
 b.cs .Lhandoff_bad_direct
 adds x9,x1,#96
 b.cs .Lhandoff_bad_direct
 sub sp,sp,#448
 stp x18,x30,[sp,#320]
 stp x19,x20,[sp,#336]
 stp x21,x22,[sp,#352]
 stp x23,x24,[sp,#368]
 stp x25,x26,[sp,#384]
 stp x27,x28,[sp,#400]
 str x29,[sp,#416]
 mov x19,x0
 mov x20,x1
 ldr x0,[x19]
 ldr x1,[x19,#16]
 ldr x2,[x20,#72]
 ldr x3,[x19,#296]
 ldr x4,[x20,#80]
 mov x5,x20
 bl md2asm_admit_transport_field_block
 cbnz w0,.Lhandoff_return
 ldr x9,[x19,#16]
 movz x10,#(1573768&65535)
 movk x10,#(1573768>>16),lsl#16
 add x9,x9,x10
 ldr x10,[x20,#72]
 cmp x9,x10
 b.ne .Lhandoff_bad
 ldr x21,[x20,#80]
 ldr x22,[x20,#8]
 add x22,x21,x22
 add x9,x19,#376
 cmp x9,x21
 b.ls .Lhandoff_table_apart
 cmp x19,x22
 b.lo .Lhandoff_bad
.Lhandoff_table_apart:
 mov x23,#0
.Lhandoff_scalar:
 adr x24,.Lhandoff_scalar_offsets
 ldrb w9,[x24,x23]
 ldr x10,[x19,x9]
 cbz x10,.Lhandoff_bad
 tst x10,#3
 b.ne .Lhandoff_bad
 adds x11,x10,#4
 b.cs .Lhandoff_bad
 cmp x11,x21
 b.ls .Lhandoff_scalar_apart
 cmp x10,x22
 b.lo .Lhandoff_bad
.Lhandoff_scalar_apart:
 ldrsw x11,[x10]
 cmp x23,#0
 b.ne .Lhandoff_not_first
 ldr x12,[x20,#24]
 cmp x11,x12
 b.ne .Lhandoff_bad
 b .Lhandoff_next_scalar
.Lhandoff_not_first:
 cmp x23,#1
 b.ne .Lhandoff_block
 ldr x12,[x20,#32]
 cmp x11,x12
 b.ne .Lhandoff_bad
 b .Lhandoff_next_scalar
.Lhandoff_block:
 cmp x11,#1
 b.lt .Lhandoff_bad
 sub x11,x11,#1
 ldr x12,[x19]
 mov x13,#5144
 ldr w12,[x12,x13]
 mul x11,x11,x12
 add x11,x11,#1
 ldr x12,[x20,#16]
 cmp x11,x12
 b.ne .Lhandoff_bad
.Lhandoff_next_scalar:
 add x23,x23,#1
 cmp x23,#3
 b.lo .Lhandoff_scalar
 mov x9,#0
 add x10,x19,#64
.Lhandoff_stack:
 ldr x11,[x10,x9,lsl#3]
 str x11,[sp,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#39
 b.lo .Lhandoff_stack
 ldp x0,x1,[x19]
 ldp x2,x3,[x19,#16]
 ldp x4,x5,[x19,#32]
 ldp x6,x7,[x19,#48]
 bl md2asm_operational_grid_point_dynamics
 ldr x0,[x19]
 ldr x1,[x19,#16]
 ldr x2,[x20,#72]
 ldr x3,[x19,#296]
 ldr x4,[x20,#80]
 mov x5,x20
 bl md2asm_scatter_transport_field_block
 b .Lhandoff_return
.Lhandoff_bad:
 mov w0,#2
.Lhandoff_return:
 ldp x18,x30,[sp,#320]
 ldp x19,x20,[sp,#336]
 ldp x21,x22,[sp,#352]
 ldp x23,x24,[sp,#368]
 ldp x25,x26,[sp,#384]
 ldp x27,x28,[sp,#400]
 ldr x29,[sp,#416]
 add sp,sp,#448
 ret
.Lhandoff_bad_direct:
 mov w0,#2
 ret
.size md2asm_complete_grid_point_transport_handoff,.-md2asm_complete_grid_point_transport_handoff
.section .rodata
.Lhandoff_scalar_offsets: .byte 24,32,72
.section .note.GNU-stack,"",%progbits

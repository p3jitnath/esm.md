/* Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_transform_from_prefix.md. Integer join only.
 * x0 readonly context96, x1 capacity; six pointer/capacity pairs G,M,namespace,
 * completed partition,zero160B sidecar,configuration. Constants are cfg+64.
 * WORLD4 collective; return0success,1allocation,2refusal. Frame320B.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_runtime_radiation_transform_from_prefix
.type md2asm_create_runtime_radiation_transform_from_prefix,%function
md2asm_create_runtime_radiation_transform_from_prefix:
 sub sp,sp,#320
 stp x29,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 str x18,[sp,#112]
 mov x29,sp
 mov x19,x0
 mov x27,x1
 bl __errno_location
 mov x28,x0
 mrs x9,fpcr
 cbnz x9,.Ljoin_bad
 cbz x19,.Ljoin_bad
 tst x19,#7
 b.ne .Ljoin_bad
 cmp x27,#96
 b.lo .Ljoin_bad
 adds x27,x19,#96
 b.cs .Ljoin_bad
 mov x9,#0
 adr x10,.Ljoin_sizes
.Ljoin_spans:
 add x14,x19,x9,lsl#4
 ldp x11,x14,[x14]
 cbz x11,.Ljoin_bad
 tst x11,#7
 b.ne .Ljoin_bad
 ldr x12,[x10,x9,lsl#3]
 cmp x14,x12
 b.lo .Ljoin_bad
 adds x13,x11,x12
 b.cs .Ljoin_bad
 cmp x11,x27
 b.hs .Ljoin_table_apart
 cmp x19,x13
 b.lo .Ljoin_bad
.Ljoin_table_apart:
 mov x15,#0
.Ljoin_prior:
 cmp x15,x9
 b.hs .Ljoin_next_span
 add x14,x19,x15,lsl#4
 ldr x16,[x14]
 ldr x17,[x10,x15,lsl#3]
 add x17,x16,x17
 cmp x11,x17
 b.hs .Ljoin_pair_apart
 cmp x16,x13
 b.lo .Ljoin_bad
.Ljoin_pair_apart:
 add x15,x15,#1
 b .Ljoin_prior
.Ljoin_next_span:
 add x9,x9,#1
 cmp x9,#6
 b.lo .Ljoin_spans
 ldr x20,[x19]
 ldr x21,[x19,#16]
 ldr x22,[x19,#32]
 ldr x23,[x19,#48]
 ldr x24,[x19,#64]
 ldr x25,[x19,#80]
 ldr x9,[x21,#8]
 cmp x9,x20
 b.ne .Ljoin_bad
 ldr x9,[x23]
 cmp x9,x20
 b.ne .Ljoin_bad
 ldr x9,[x25]
 cmp x9,x21
 b.ne .Ljoin_bad
 ldr x9,[x25,#16]
 cmp x9,x20
 b.ne .Ljoin_bad
 ldr x9,[x25,#48]
 cmp x9,x23
 b.ne .Ljoin_bad
 ldr w9,[x23,#16]
 cmp w9,#3
 b.ne .Ljoin_bad
 ldr w9,[x23,#24]
 cmp w9,#4
 b.ne .Ljoin_bad
 ldp w9,w10,[x23,#48]
 cmp w9,#3
 b.ne .Ljoin_bad
 cmp w10,#2
 b.ne .Ljoin_bad
 ldr w9,[x23,#380]
 cbnz w9,.Ljoin_bad
 ldr w9,[x23,#392]
 cmp w9,#1
 b.ne .Ljoin_bad
 ldr w9,[x20,#5144]
 cmp w9,#17
 b.ne .Ljoin_bad
 ldr w9,[x20,#5224]
 cmp w9,#137
 b.ne .Ljoin_bad
 ldr w9,[x20,#5172]
 cmp w9,#1279
 b.ne .Ljoin_bad
 ldr w9,[x20,#4872]
 cmp w9,#2560
 b.ne .Ljoin_bad
 mov x9,#0
.Ljoin_fresh_sidecar:
 ldr x10,[x24,x9]
 cbnz x10,.Ljoin_bad
 add x9,x9,#8
 cmp x9,#160
 b.lo .Ljoin_fresh_sidecar
 ldr x9,=4098608
 add x9,x21,x9
 ldr w10,[x9]
 cbnz w10,.Ljoin_bad
 adr x10,.Ljoin_fresh_offsets
 mov x11,#0
.Ljoin_fresh_heads:
 ldr w12,[x10,x11,lsl#2]
 ldr x13,[x9,x12]
 cbnz x13,.Ljoin_bad
 add x11,x11,#1
 cmp x11,#10
 b.lo .Ljoin_fresh_heads
 mov w0,#0
 b .Ljoin_admit
.Ljoin_bad:
 mov w0,#2
.Ljoin_admit:
 bl .Ljoin_agree
 cbnz w0,.Ljoin_return
 mov x0,x20
 ldr x1,[x19,#8]
 mov x2,x21
 ldr x3,[x19,#24]
 mov x4,x22
 ldr x5,[x19,#40]
 bl md2asm_create_runtime_radiation_grid_from_prefix
 bl .Ljoin_agree
 mov w26,w0
 cbnz w26,.Ljoin_rows_cleanup
 ldr x9,=4098608
 add x9,x21,x9
 ldr w10,[x9,#52]
 str w10,[sp,#176]
 ldr w10,[x9,#20]
 str w10,[sp,#180]
 ldp w10,w11,[x9,#56]
 stp w10,w11,[sp,#184]
 ldr w10,[x9,#76]
 str w10,[sp,#192]
 ldr x10,=1608752
 ldr w10,[x21,x10]
 str w10,[sp,#196]
 ldp w10,w11,[x23,#48]
 stp w10,w11,[sp,#200]
 add x0,sp,#176
 add x1,sp,#208
 mov w2,#8
 ldr w3,=0x4c000405
 ldr w4,=0x58000002
 ldr w5,=0x44000000
 bl .Ljoin_reduce
 add x0,sp,#176
 add x1,sp,#240
 mov w2,#8
 ldr w3,=0x4c000405
 ldr w4,=0x58000001
 ldr w5,=0x44000000
 bl .Ljoin_reduce
 mov x9,#0
.Ljoin_shape_compare:
 add x10,sp,#208
 add x11,sp,#240
 ldr w12,[x10,x9,lsl#2]
 ldr w13,[x11,x9,lsl#2]
 cmp w12,w13
 b.ne .Ljoin_shape_bad
 add x9,x9,#1
 cmp x9,#8
 b.lo .Ljoin_shape_compare
 ldr x9,=1608752
 ldr w9,[x21,x9]
 str x9,[sp]
 ldr x9,=4098608
 add x0,x21,x9
 mov x1,#1376
 mov x2,x23
 ldr x3,[x19,#56]
 mov x4,x24
 ldr x5,[x19,#72]
 add x6,x25,#64
 mov x7,#520
 bl md2asm_create_live_radiation_gaussian_setup
 bl .Ljoin_agree
 mov w26,w0
 cbz w26,.Ljoin_return
 b .Ljoin_rows_cleanup
.Ljoin_shape_bad:
 mov w26,#2
.Ljoin_rows_cleanup:
 mov x0,x21
 ldr x1,[x19,#24]
 bl md2asm_release_runtime_radiation_grid_shape
 bl .Ljoin_agree
 cbnz w0,.Ljoin_abort
 mov w0,w26
.Ljoin_return:
 ldr x18,[sp,#112]
 ldp x27,x28,[sp,#96]
 ldp x25,x26,[sp,#80]
 ldp x23,x24,[sp,#64]
 ldp x21,x22,[sp,#48]
 ldp x19,x20,[sp,#32]
 ldp x29,x30,[sp,#16]
 add sp,sp,#320
 ret
/* These private integer reductions preserve the caller's numerical status. */
.Ljoin_agree:
 str x30,[sp,#288]
 str w0,[sp,#164]
 add x0,sp,#164
 add x1,sp,#168
 mov w2,#1
 ldr w3,=0x4c000405
 ldr w4,=0x58000001
 ldr w5,=0x44000000
 bl .Ljoin_reduce
 ldr w0,[sp,#168]
 ldr x30,[sp,#288]
 ret
.Ljoin_reduce:
 str x30,[sp,#280]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#144]
 ldr w11,[x28]
 str w11,[sp,#160]
 bl MPI_Allreduce
 cbnz w0,.Ljoin_abort
 ldp x9,x10,[sp,#144]
 msr fpcr,x9
 msr fpsr,x10
 ldr w11,[sp,#160]
 str w11,[x28]
 ldr x30,[sp,#280]
 ret
.Ljoin_abort:
 bl abort
 brk #0
.size md2asm_create_runtime_radiation_transform_from_prefix,.-md2asm_create_runtime_radiation_transform_from_prefix
.section .rodata
.p2align 3
.Ljoin_sizes:
 .quad 20400,4275088,744,4096,160,67616
.p2align 2
.Ljoin_fresh_offsets:
 .word 88,152,216,280,344,536,624,968,1032,1096
.section .note.GNU-stack,"",%progbits

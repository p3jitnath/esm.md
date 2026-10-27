/* Contract skills/md2asm/references/openifs/setup/runtime_coupled_field_accumulators.md.
 * Direct SUCPL0 setup with owned runtime storage. */
.arch armv8.2-a
.text
.p2align 4
.equ COUPLED_PRIVATE,256
.equ COUPLED_STATUS,176
.macro ACALL symbol
 str x18,[sp,#160]
 bl \symbol
 ldr x18,[sp,#160]
.endm
.global md2asm_initialize_runtime_coupled_field_accumulators
.type md2asm_initialize_runtime_coupled_field_accumulators,%function
md2asm_initialize_runtime_coupled_field_accumulators:
 sub sp,sp,#2048
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x27,#0
 cbz x19,.Lacc_bad
 cbz x20,.Lacc_bad
 cbz x21,.Lacc_bad
 orr x9,x19,x21
 tst x9,#7
 b.ne .Lacc_bad
 tst x20,#3
 b.ne .Lacc_bad
 mrs x9,fpcr
 cbnz x9,.Lacc_bad
 cbz x22,.Lacc_bad
 mov x9,#1
 lsl x9,x9,#36
 cmp x22,x9
 b.hi .Lacc_bad
 add x0,sp,#192
 mov x9,#20400
 stp x19,x9,[x0]
 mov x9,#88
 stp x20,x9,[x0,#16]
 mov x9,#1536
 stp x21,x9,[x0,#32]
 bl .Lacc_spans
 cbnz w0,.Lacc_bad
 ldr x9,[x21]
 cbnz x9,.Lacc_bad
 ldr x9,[x21,#16]
 cbnz x9,.Lacc_bad
 ldr w23,[x19,#7376]
 sub w9,w23,#1
 mov w10,#0x7ffffffe
 cmp w9,w10
 b.hi .Lacc_bad
 ldr w24,[x20,#76]
 cmp w24,#32
 b.hi .Lacc_bad
 add x24,x24,#1
 ldr w25,[x19,#4936]
 sub w9,w25,#1
 mov w10,#32767
 cmp w9,w10
 b.hi .Lacc_bad
 ldr w26,[x19,#4872]
 sub w9,w26,#1
 cmp w9,w10
 b.hi .Lacc_bad
 /* These bounded integer products cannot wrap under the declared caps. */
 mul x9,x23,x24
 lsl x9,x9,#2
 mov x10,#10
 madd x9,x23,x10,x9
 mul x10,x25,x26
 add x9,x9,x10,lsl#1
 lsl x29,x9,#3
 cmp x22,x29
 b.lo .Lacc_bad
 add x0,sp,#COUPLED_PRIVATE
 mov x1,#0
 mov x2,#1536
 ACALL memset
 mov x0,x29
 ACALL malloc
 cbz x0,.Lacc_alloc_bad
 mov x27,x0
 add x9,sp,#COUPLED_PRIVATE
 stp x27,x29,[x9]
 mov x10,#1
 str x10,[x9,#16]
 stp x23,x24,[x9,#24]
 stp x25,x26,[x9,#40]
 mov x22,x27
 mov x28,#0
.Lacc_descriptor_loop:
 adr x9,.Lacc_shapes
 ldrb w9,[x9,x28]
 mov x2,x23
 mov x3,#1
 mov w4,#1
 cbz w9,.Lacc_descriptor_ready
 mov w4,#2
 mov x3,x24
 cmp w9,#1
 b.eq .Lacc_descriptor_ready
 mov x2,x25
 mov x3,x26
.Lacc_descriptor_ready:
 mov x9,#88
 mul x9,x28,x9
 add x0,sp,#COUPLED_PRIVATE+128
 add x0,x0,x9
 mov x1,x22
 bl .Lacc_descriptor
 mul x9,x2,x3
 add x22,x22,x9,lsl#3
 add x28,x28,#1
 cmp x28,#16
 b.lo .Lacc_descriptor_loop
 add x9,x27,x29
 cmp x22,x9
 b.ne .Lacc_bad
 mov x28,#0
.Lacc_zero_source_order:
 adr x9,.Lacc_zero_indices
 ldrb w9,[x9,x28]
 mov x10,#88
 mul x9,x9,x10
 add x9,x9,#COUPLED_PRIVATE+128
 add x9,sp,x9
 ldr x0,[x9]
 ldr x2,[x9,#56]
 ldrb w10,[x9,#28]
 cmp w10,#2
 b.ne .Lacc_zero_bytes
 ldr x10,[x9,#80]
 mul x2,x2,x10
.Lacc_zero_bytes:
 lsl x2,x2,#3
 mov x1,#0
 ACALL memset
 add x28,x28,#1
 cmp x28,#14
 b.lo .Lacc_zero_source_order
 add x9,sp,#COUPLED_PRIVATE
 mov x10,#0
.Lacc_publish:
 ldr x11,[x9,x10]
 str x11,[x21,x10]
 add x10,x10,#8
 cmp x10,#1536
 b.lo .Lacc_publish
 mov x27,#0
 mov w0,#0
 b .Lacc_return
.Lacc_alloc_bad:
 mov w0,#1
 b .Lacc_return
.Lacc_bad:
 mov w0,#2
.Lacc_return:
 str w0,[sp,#COUPLED_STATUS]
 cbz x27,.Lacc_restore
 mov x0,x27
 ACALL free
.Lacc_restore:
 ldr w0,[sp,#COUPLED_STATUS]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#2048
 ret
.size md2asm_initialize_runtime_coupled_field_accumulators,.-md2asm_initialize_runtime_coupled_field_accumulators

/* x0 empty descriptor, x1 data, x2 first extent, x3 second extent, w4 rank. */
.Lacc_descriptor:
 str x1,[x0]
 mov x9,#-1
 cmp w4,#2
 b.ne .Lacc_offset_ready
 sub x9,x9,x2
.Lacc_offset_ready:
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 mov w9,#0x300
 orr w9,w9,w4
 str w9,[x0,#28]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x2,[x0,#56]
 cmp w4,#2
 b.ne .Lacc_descriptor_done
 str x2,[x0,#64]
 str x9,[x0,#72]
 str x3,[x0,#80]
.Lacc_descriptor_done:
 ret
/* Three complete pointer/byte-count pairs in x0. */
.Lacc_spans:
 mov x9,#0
.Lacc_span_outer:
 add x10,x0,x9,lsl#4
 ldp x11,x12,[x10]
 adds x12,x11,x12
 b.cs .Lacc_helper_bad
 add x13,x9,#1
.Lacc_span_inner:
 cmp x13,#3
 b.hs .Lacc_span_next
 add x10,x0,x13,lsl#4
 ldp x14,x15,[x10]
 adds x15,x14,x15
 b.cs .Lacc_helper_bad
 cmp x11,x15
 b.hs .Lacc_span_clear
 cmp x14,x12
 b.lo .Lacc_helper_bad
.Lacc_span_clear:
 add x13,x13,#1
 b .Lacc_span_inner
.Lacc_span_next:
 add x9,x9,#1
 cmp x9,#3
 b.lo .Lacc_span_outer
 mov w0,#0
 ret
.Lacc_helper_bad:
 mov w0,#2
 ret

.global md2asm_release_runtime_coupled_field_accumulators
.type md2asm_release_runtime_coupled_field_accumulators,%function
md2asm_release_runtime_coupled_field_accumulators:
 cbz x0,.Lacc_release_bad
 tst x0,#7
 b.ne .Lacc_release_bad
 cmp x1,#1536
 b.lo .Lacc_release_bad
 adds x9,x0,#1536
 b.cs .Lacc_release_bad
 stp x19,x30,[sp,#-32]!
 str x18,[sp,#16]
 mov x19,x0
 ldr x0,[x19]
 cbz x0,.Lacc_release_clear
 bl free
.Lacc_release_clear:
 stp xzr,xzr,[x19]
 str xzr,[x19,#16]
 add x9,x19,#128
 mov x10,#16
.Lacc_release_descriptors:
 str xzr,[x9],#88
 subs x10,x10,#1
 b.ne .Lacc_release_descriptors
 ldr x18,[sp,#16]
 ldp x19,x30,[sp],#32
 mov w0,#0
 ret
.Lacc_release_bad:
 mov w0,#2
 ret
.size md2asm_release_runtime_coupled_field_accumulators,.-md2asm_release_runtime_coupled_field_accumulators
.section .rodata
.p2align 3
.Lacc_shapes: .byte 0,0,1,1,1,0,1,0,0,0,0,0,2,2,0,0
.Lacc_zero_indices: .byte 2,3,4,6,0,1,5,7,8,9,10,11,14,15
.section .note.GNU-stack,"",%progbits

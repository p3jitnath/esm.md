/* Contract skills/md2asm/references/openifs/input/streaming_runtime_upper_air_loading.md.
 * Direct ownership of one decoded global record and uncommitted local fields.
 * The public output changes only after complete input success.
 */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_load_streaming_runtime_upper_air_state
.type md2asm_load_streaming_runtime_upper_air_state,%function
md2asm_load_streaming_runtime_upper_air_state:
 mrs x9,fpcr
 cbnz x9,.Lstream_bad_leaf
 sub sp,sp,#256
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 str xzr,[sp,#120]
 mov w9,#1
 str w9,[sp,#132]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x26,xzr
 cbz x19,.Lstream_finish
 cbz x20,.Lstream_finish
 cbz x21,.Lstream_finish
 cbz x23,.Lstream_finish
 orr x9,x20,x21
 orr x9,x9,x23
 tst x9,#7
 b.ne .Lstream_finish
 adds x15,x20,#64
 b.cs .Lstream_finish
 mov x9,#5232
 cmp x24,x9
 b.lo .Lstream_finish
 adds x16,x23,x9
 b.cs .Lstream_finish
 ldp x4,x8,[x20]
 ldp x10,x7,[x20,#16]
 ldp x5,x6,[x20,#32]
 ldp x11,x12,[x20,#48]
 cmp x12,#9
 b.ne .Lstream_finish
 sub x9,x5,#1
 cmp x9,#1023
 b.hi .Lstream_finish
 sub x9,x6,#1
 cmp x9,#255
 b.hi .Lstream_finish
 cbz x4,.Lstream_finish
 cbz x11,.Lstream_finish
 mov x9,#0x7fffffff
 cmp x4,x9
 b.hi .Lstream_finish
 cmp x11,x9
 b.hi .Lstream_finish
 cmp x4,x11
 b.hi .Lstream_finish
 cbz x8,.Lstream_finish
 tst x8,#3
 b.ne .Lstream_finish
 lsl x9,x4,#2
 cmp x10,x9
 b.ne .Lstream_finish
 adds x17,x8,x10
 b.cs .Lstream_finish
 add x9,x4,x5
 sub x9,x9,#1
 udiv x9,x9,x5
 cmp x7,x9
 b.ne .Lstream_finish
 mul x25,x5,x6
 mul x25,x25,x7
 mov x9,#72
 mul x25,x25,x9
 cmp x22,x25
 b.lo .Lstream_finish
 adds x14,x21,x25
 b.cs .Lstream_finish
 ldr w9,[x23,#16]
 cmp x6,x9
 b.ne .Lstream_finish
 ldr w9,[x23,#56]
 sub w12,w9,#1
 cmp w12,#1279
 b.hi .Lstream_finish
 lsl x9,x9,#2
 mov x12,#4215
 add x9,x9,x12
 and x9,x9,#-8
 mov x12,#5232
 cmp x9,x12
 csel x9,x9,x12,hs
 cmp x24,x9
 b.lo .Lstream_finish
 adds x16,x23,x9
 b.cs .Lstream_finish
 /* The commit must preserve all borrowed input records. */
 cmp x21,x15
 b.hs .Lstream_shape_separate
 cmp x20,x14
 b.lo .Lstream_finish
.Lstream_shape_separate:
 cmp x21,x17
 b.hs .Lstream_map_separate
 cmp x8,x14
 b.lo .Lstream_finish
.Lstream_map_separate:
 cmp x21,x16
 b.hs .Lstream_header_separate
 cmp x23,x14
 b.lo .Lstream_finish
.Lstream_header_separate:
 mov x0,x8
 mov x1,x4
.Lstream_map_check:
 ldrsw x2,[x0],#4
 cmp x2,#1
 b.lt .Lstream_finish
 cmp x2,x11
 b.gt .Lstream_finish
 subs x1,x1,#1
 b.ne .Lstream_map_check
 lsl x9,x11,#3
 str x9,[sp,#144]
 str x25,[sp,#152]
 mov x10,#280
 mul x10,x6,x10
 str x10,[sp,#160]
 add x9,x9,x25
 add x9,x9,x10
 add x9,x9,#80
 str x9,[sp,#168]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 ldr x0,[sp,#168]
 bl malloc
 mov x26,x0
 cbz x26,.Lstream_allocation_failed
 ldr x9,[sp,#144]
 add x28,x26,x9
 str x28,[sp,#184]
 add x10,x28,x25
 str x10,[sp,#192]
 ldr x9,[sp,#160]
 add x27,x10,x9
 str x27,[sp,#200]
 ldp q0,q1,[x20]
 ldp q2,q3,[x20,#32]
 stp q0,q1,[x27]
 stp q2,q3,[x27,#32]
 str x28,[x27,#64]
 str xzr,[x27,#72]
 mov x0,x28
 mov x1,x21
 mov x2,x25
 bl memcpy
 mov x0,x19
 mov x1,x26
 ldr x2,[sp,#144]
 ldr x3,[sp,#192]
 ldr x4,[sp,#160]
 add x5,x27,#72
 mov x6,x23
 mov x7,x24
 mov x8,x27
 bl md2asm_read_streaming_runtime_upper_air_records
 cbnz w0,.Lstream_read_failed
 mov x0,x27
 mov x1,x28
 bl .Lstream_zero_diagnostics
 mov x0,x21
 mov x1,x28
 mov x2,x25
 bl memcpy
 str wzr,[sp,#132]
 b .Lstream_release
.Lstream_read_failed:
 add w0,w0,#16
 str w0,[sp,#132]
 b .Lstream_release
.Lstream_allocation_failed:
 mov w9,#2
 str w9,[sp,#132]
.Lstream_release:
 cbz x26,.Lstream_finish
 mov x0,x26
 bl free
 mov x26,xzr
.Lstream_finish:
 ldr x9,[sp,#120]
 cbz x9,.Lstream_restore_registers
 ldr w10,[sp,#128]
 str w10,[x9]
.Lstream_restore_registers:
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr w0,[sp,#132]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.Lstream_bad_leaf:
 mov w0,#1
 ret
.size md2asm_load_streaming_runtime_upper_air_state,.-md2asm_load_streaming_runtime_upper_air_state

/* Private leaf receives a validated shape, one record, index and staging. */
.p2align 2
.global md2asm_place_streamed_upper_air_record
.hidden md2asm_place_streamed_upper_air_record
.type md2asm_place_streamed_upper_air_record,%function
md2asm_place_streamed_upper_air_record:
 ldr x5,[x0,#40]
 ldr x6,[x0,#32]
 ldp x7,x8,[x0]
 mov x9,#7
 mul x9,x5,x9
 cmp x2,x9
 b.hs .Lstream_record_bad
 lsl x12,x5,#1
 cmp x2,x12
 b.hs .Lstream_record_cloud
 lsr x11,x2,#1
 and x10,x2,#1
 b .Lstream_record_field
.Lstream_record_cloud:
 sub x12,x2,x12
 mov x13,#5
 udiv x11,x12,x13
 msub x10,x11,x13,x12
 add x10,x10,#2
.Lstream_record_field:
 adr x12,.Lstream_field_slots
 ldr w10,[x12,x10,lsl#2]
 madd x11,x10,x5,x11
 mul x11,x11,x6
 add x14,x3,x11,lsl#3
 mul x9,x5,x6
 mov x12,#72
 mul x9,x9,x12
.Lstream_record_block:
 cmp x7,x6
 csel x15,x7,x6,lo
 sub x7,x7,x15
 mov x0,x14
.Lstream_record_words:
 ldr w16,[x8],#4
 sub w16,w16,#1
 ldr x17,[x1,x16,lsl#3]
 str x17,[x0],#8
 subs x15,x15,#1
 b.ne .Lstream_record_words
 cbz x7,.Lstream_record_done
 add x14,x14,x9
 b .Lstream_record_block
.Lstream_record_done:
 mov w0,#0
 ret
.Lstream_record_bad:
 mov w0,#1
 ret
.size md2asm_place_streamed_upper_air_record,.-md2asm_place_streamed_upper_air_record

/* Source-defined zero planes include every padded row of each block. */
.p2align 2
.type .Lstream_zero_diagnostics,%function
.Lstream_zero_diagnostics:
 ldr x2,[x0,#24]
 ldp x3,x4,[x0,#32]
 mul x3,x3,x4
 lsl x4,x3,#3
 mov x5,#7
 madd x1,x4,x5,x1
 lsl x5,x3,#1
 mov x6,#9
 mul x4,x4,x6
.Lstream_zero_block:
 mov x6,x1
 mov x7,x5
.Lstream_zero_word:
 str xzr,[x6],#8
 subs x7,x7,#1
 b.ne .Lstream_zero_word
 add x1,x1,x4
 subs x2,x2,#1
 b.ne .Lstream_zero_block
 ret
.size .Lstream_zero_diagnostics,.-.Lstream_zero_diagnostics
.section .rodata
.p2align 2
.Lstream_field_slots:
 .word 0,6,4,3,1,2,5
.section .note.GNU-stack,"",%progbits

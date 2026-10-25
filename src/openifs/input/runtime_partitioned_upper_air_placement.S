/* Contract: skills/md2asm/references/openifs/input/runtime_partitioned_upper_air_placement.md.
 * Runtime shape binding and SUGRIDUG source assignments through NGLOBALINDEX.
 * Counts are dimensionless; copied FP64 words keep their bits and source units.
 */
.arch armv8.2-a
.text
.macro RPU_ENTER
 stp x29,x30,[sp,#-160]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
.endm
.macro RPU_LEAVE
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#160
 ret
.endm
/* Refuse overlap of [x19,x13) and [start,end); inputs remain read-only. */
.macro RPU_OUT_CLEAR start,end
 cmp x13,\start
 b.ls 991f
 cmp \end,x19
 b.hi .Lrpu_bind_bad
991:
.endm
.p2align 4
.global md2asm_bind_runtime_partitioned_upper_air_shape
.type md2asm_bind_runtime_partitioned_upper_air_shape,%function
md2asm_bind_runtime_partitioned_upper_air_shape:
 cbz x0,.Lrpu_bind_bad_leaf
 cbz x1,.Lrpu_bind_bad_leaf
 cbz x2,.Lrpu_bind_bad_leaf
 cbz x3,.Lrpu_bind_bad_leaf
 orr x8,x0,x1
 orr x8,x8,x2
 orr x8,x8,x3
 tst x8,#7
 b.ne .Lrpu_bind_bad_leaf
 adds x8,x0,#64
 b.cs .Lrpu_bind_bad_leaf
 mov x8,#5232
 cmp x4,x8
 b.lo .Lrpu_bind_bad_leaf
 adds x9,x3,x8
 b.cs .Lrpu_bind_bad_leaf
 RPU_ENTER
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 add x0,sp,#112
 bl md2asm_bind_runtime_distributed_gridpoint_shape
 cbnz w0,.Lrpu_bind_bad
 ldr w28,[sp,#112]
 ldr w27,[sp,#120]
 ldr w8,[sp,#124]
 cmp w8,#9
 b.ne .Lrpu_bind_bad
 mov x8,#7376
 ldr w24,[x20,x8]
 mov x8,#7388
 ldr w25,[x20,x8]
 ldr w8,[x22,#16]
 ldr w9,[sp,#116]
 cmp w8,w9
 b.ne .Lrpu_bind_bad
 ldr w10,[x22,#56]
 sub w8,w10,#1
 cmp w8,#1279
 b.hi .Lrpu_bind_bad
 ldr w8,[x22,#8]
 lsl w9,w10,#1
 cmp w8,w9
 b.ne .Lrpu_bind_bad
 lsl x13,x10,#2
 mov x14,#4208
 add x13,x13,x14
 add x13,x13,#7
 and x13,x13,#-8
 mov x14,#5232
 cmp x13,x14
 csel x13,x13,x14,hs
 cmp x23,x13
 b.lo .Lrpu_bind_bad
 adds x23,x22,x13
 b.cs .Lrpu_bind_bad
 add x17,x22,#4096
 add x17,x17,#112
 mov x14,#0
 mov w15,#0
 mov x16,x10
.Lrpu_sum_north:
 ldr w8,[x17],#4
 cmp w8,#1
 b.lt .Lrpu_bind_bad
 add x14,x14,x8
 cmp w15,w8
 csel w15,w15,w8,hs
 subs x16,x16,#1
 b.ne .Lrpu_sum_north
 lsl x14,x14,#1
 cmp x14,x25
 b.ne .Lrpu_bind_bad
 ldr w8,[x22,#12]
 cmp w8,w15
 b.ne .Lrpu_bind_bad
 /* The complete rank-one int32 descriptor is the actual map owner. */
 add x10,x20,#4096
 add x10,x10,#2552
 ldp x26,x8,[x10]
 cbz x26,.Lrpu_bind_bad
 tst x26,#3
 b.ne .Lrpu_bind_bad
 cmn x8,#1
 b.ne .Lrpu_bind_bad
 ldp x8,x9,[x10,#16]
 cmp x8,#4
 b.ne .Lrpu_bind_bad
 movz x11,#0x101,lsl#32
 cmp x9,x11
 b.ne .Lrpu_bind_bad
 ldp x8,x9,[x10,#32]
 cmp x8,#4
 b.ne .Lrpu_bind_bad
 cmp x9,#1
 b.ne .Lrpu_bind_bad
 ldp x8,x9,[x10,#48]
 cmp x8,#1
 b.ne .Lrpu_bind_bad
 cmp x9,x24
 b.ne .Lrpu_bind_bad
 lsl x11,x24,#2
 adds x12,x26,x11
 b.cs .Lrpu_bind_bad
 add x13,x19,#64
 mov x8,#20400
 adds x9,x20,x8
 b.cs .Lrpu_bind_bad
 RPU_OUT_CLEAR x20,x9
 movz x8,#(1359136 & 65535)
 movk x8,#(1359136 >> 16),lsl#16
 adds x9,x21,x8
 b.cs .Lrpu_bind_bad
 RPU_OUT_CLEAR x21,x9
 RPU_OUT_CLEAR x22,x23
 RPU_OUT_CLEAR x26,x12
 ldr w8,[sp,#116]
 ldr w9,[sp,#124]
 stp x24,x26,[x19]
 stp x11,x27,[x19,#16]
 stp x28,x8,[x19,#32]
 stp x25,x9,[x19,#48]
 mov w0,#0
 RPU_LEAVE
.Lrpu_bind_bad:
 mov w0,#2
 RPU_LEAVE
.Lrpu_bind_bad_leaf:
 mov w0,#2
 ret
.size md2asm_bind_runtime_partitioned_upper_air_shape,.-md2asm_bind_runtime_partitioned_upper_air_shape

/* Refuse overlap of mutable [x21,x17) and one consumed read-only span. */
.macro RPU_DEST_CLEAR start,end
 cmp x17,\start
 b.ls 992f
 cmp \end,x21
 b.hi .Lrpu_place_bad
992:
.endm
.p2align 4
.global md2asm_place_runtime_partitioned_upper_air_fields
.type md2asm_place_runtime_partitioned_upper_air_fields,%function
md2asm_place_runtime_partitioned_upper_air_fields:
 cbz x0,.Lrpu_place_bad_leaf
 cbz x2,.Lrpu_place_bad_leaf
 cbz x4,.Lrpu_place_bad_leaf
 cbz x6,.Lrpu_place_bad_leaf
 orr x7,x0,x2
 orr x7,x7,x4
 orr x7,x7,x6
 tst x7,#7
 b.ne .Lrpu_place_bad_leaf
 adds x7,x6,#64
 b.cs .Lrpu_place_bad_leaf
 RPU_ENTER
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x6
 ldp x23,x24,[x22]
 ldp x8,x25,[x22,#16]
 ldp x26,x27,[x22,#32]
 ldp x28,x9,[x22,#48]
 cmp x9,#9
 b.ne .Lrpu_place_bad
 sub x10,x26,#1
 cmp x10,#1023
 b.hi .Lrpu_place_bad
 sub x10,x27,#1
 cmp x10,#255
 b.hi .Lrpu_place_bad
 cbz x23,.Lrpu_place_bad
 mov x10,#0x7fffffff
 cmp x23,x10
 b.hi .Lrpu_place_bad
 cbz x28,.Lrpu_place_bad
 cmp x28,x10
 b.hi .Lrpu_place_bad
 cmp x23,x28
 b.hi .Lrpu_place_bad
 cbz x24,.Lrpu_place_bad
 tst x24,#3
 b.ne .Lrpu_place_bad
 lsl x10,x23,#2
 cmp x8,x10
 b.ne .Lrpu_place_bad
 adds x14,x24,x10
 b.cs .Lrpu_place_bad
 add x10,x23,x26
 sub x10,x10,#1
 udiv x10,x10,x26
 cmp x25,x10
 b.ne .Lrpu_place_bad
 mov x8,#7
 mul x8,x27,x8
 mul x9,x8,x28
 lsl x9,x9,#3
 cmp x1,x9
 b.lo .Lrpu_place_bad
 adds x15,x19,x9
 b.cs .Lrpu_place_bad
 str x9,[sp,#96]
 mov x10,#40
 mul x10,x8,x10
 cmp x3,x10
 b.lo .Lrpu_place_bad
 adds x16,x20,x10
 b.cs .Lrpu_place_bad
 str x10,[sp,#104]
 mul x11,x26,x27
 mov x12,#9
 mul x11,x11,x12
 lsl x11,x11,#3
 str x11,[sp,#120]
 mul x12,x11,x25
 cmp x5,x12
 b.lo .Lrpu_place_bad
 adds x17,x21,x12
 b.cs .Lrpu_place_bad
 str x12,[sp,#112]
 add x13,x22,#64
 RPU_DEST_CLEAR x19,x15
 RPU_DEST_CLEAR x20,x16
 RPU_DEST_CLEAR x22,x13
 RPU_DEST_CLEAR x24,x14
 /* Preserve the qualified specialization behind an exact runtime dispatch. */
 cmp x26,#17
 b.ne .Lrpu_generic_placement
 cmp x27,#137
 b.ne .Lrpu_generic_placement
 movz x8,#(6599680 & 65535)
 movk x8,#(6599680 >> 16),lsl#16
 cmp x28,x8
 b.ne .Lrpu_generic_placement
 mov x0,x19
 ldr x1,[sp,#96]
 mov x2,x20
 ldr x3,[sp,#104]
 mov x4,x21
 ldr x5,[sp,#112]
 mov x6,x22
 bl md2asm_place_partitioned_operational_upper_air_fields
 RPU_LEAVE
.Lrpu_generic_placement:
 /* Validate all map indices before any metadata or output write. */
 mov x0,x24
 mov x1,x23
.Lrpu_validate_map:
 ldrsw x2,[x0],#4
 cmp x2,#1
 b.lt .Lrpu_place_index_bad
 cmp x2,x28
 b.gt .Lrpu_place_index_bad
 subs x1,x1,#1
 b.ne .Lrpu_validate_map
 mov x0,x20
 mov x1,#7
 mul x1,x27,x1
 mov x2,#0
 adr x3,.Lrpu_fields
.Lrpu_validate_metadata:
 lsl x4,x27,#1
 cmp x2,x4
 b.hs .Lrpu_meta_five
 lsr x4,x2,#1
 and x5,x2,#1
 b .Lrpu_meta_identity
.Lrpu_meta_five:
 sub x6,x2,x4
 mov x7,#5
 udiv x4,x6,x7
 msub x5,x4,x7,x6
 add x5,x5,#2
.Lrpu_meta_identity:
 add x7,x3,x5,lsl#3
 ldr w7,[x7]
 ldr x8,[x0]
 cmp x8,x7
 b.ne .Lrpu_place_metadata_bad
 add x4,x4,#1
 ldr x8,[x0,#8]
 cmp x8,x4
 b.ne .Lrpu_place_metadata_bad
 ldr x8,[x0,#16]
 cmp x8,x28
 b.ne .Lrpu_place_metadata_bad
 add x0,x0,#40
 add x2,x2,#1
 cmp x2,x1
 b.lo .Lrpu_validate_metadata
 /* Source zeros cover both diagnostic fields, including padding. */
 mul x8,x26,x27
 lsl x9,x8,#3
 mov x10,#7
 madd x0,x9,x10,x21
 lsl x2,x8,#1
 ldr x8,[sp,#120]
 mov x1,x25
.Lrpu_zero_block:
 mov x3,x0
 mov x4,x2
.Lrpu_zero_words:
 str xzr,[x3],#8
 subs x4,x4,#1
 b.ne .Lrpu_zero_words
 add x0,x0,x8
 subs x1,x1,#1
 b.ne .Lrpu_zero_block
 mov x0,#0
 mov x1,x19
.Lrpu_copy_record:
 lsl x12,x27,#1
 cmp x0,x12
 b.hs .Lrpu_copy_five
 lsr x13,x0,#1
 and x14,x0,#1
 b .Lrpu_copy_destination
.Lrpu_copy_five:
 sub x12,x0,x12
 mov x15,#5
 udiv x13,x12,x15
 msub x14,x13,x15,x12
 add x14,x14,#2
.Lrpu_copy_destination:
 adr x15,.Lrpu_fields
 add x15,x15,x14,lsl#3
 ldr w14,[x15,#4]
 madd x13,x14,x27,x13
 mul x13,x13,x26
 add x2,x21,x13,lsl#3
 mov x3,x24
 mov x4,x23
 mov x5,x2
 ldr x8,[sp,#120]
.Lrpu_copy_block:
 cmp x4,x26
 csel x7,x4,x26,lo
 sub x4,x4,x7
 mov x6,x5
.Lrpu_copy_words:
 ldr w10,[x3],#4
 sub w10,w10,#1
 ldr x11,[x1,x10,lsl#3]
 str x11,[x6],#8
 subs x7,x7,#1
 b.ne .Lrpu_copy_words
 cbz x4,.Lrpu_record_done
 add x5,x5,x8
 b .Lrpu_copy_block
.Lrpu_record_done:
 add x1,x1,x28,lsl#3
 add x0,x0,#1
 mov x12,#7
 mul x12,x27,x12
 cmp x0,x12
 b.lo .Lrpu_copy_record
 mov w0,#0
 RPU_LEAVE
.Lrpu_place_bad:
 mov w0,#1
 RPU_LEAVE
.Lrpu_place_metadata_bad:
 mov w0,#2
 RPU_LEAVE
.Lrpu_place_index_bad:
 mov w0,#3
 RPU_LEAVE
.Lrpu_place_bad_leaf:
 mov w0,#1
 ret
.size md2asm_place_runtime_partitioned_upper_air_fields,.-md2asm_place_runtime_partitioned_upper_air_fields
.section .rodata
.p2align 3
.Lrpu_fields:
 .word 133,0,203,6,75,4,76,3,246,1,247,2,248,5
.section .note.GNU-stack,"",%progbits

/* Place every decoded operational upper-air field in owned blocked storage.
 * Contract: skills/md2asm/references/openifs/input/operational_upper_air_initial_state_placement.md.
 * x0 values, x1 value capacity, x2 metadata, x3 metadata capacity,
 * x4 mutable GFL, x5 GFL capacity, with byte capacities in 64-bit words.
 * Return0 success,1 invalid buffer,2 metadata before any output mutation.
 * Leaf, integer transfers only, no original provider or runtime call.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_place_operational_upper_air_fields
.type md2asm_place_operational_upper_air_fields,%function
md2asm_place_operational_upper_air_fields:
 cbz x0,.Lop_upper_buffer
 cbz x2,.Lop_upper_buffer
 cbz x4,.Lop_upper_buffer
 orr x6,x0,x2
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lop_upper_buffer
 adr x6,.Lop_upper_extents
 ldr x7,[x6]
 cmp x1,x7
 b.lo .Lop_upper_buffer
 adds x8,x0,x7
 b.cs .Lop_upper_buffer
 ldr x9,[x6,#8]
 cmp x3,x9
 b.lo .Lop_upper_buffer
 adds x10,x2,x9
 b.cs .Lop_upper_buffer
 ldr x11,[x6,#16]
 cmp x5,x11
 b.lo .Lop_upper_buffer
 adds x12,x4,x11
 b.cs .Lop_upper_buffer
 cmp x12,x0
 b.ls .Lop_upper_values_separate
 cmp x8,x4
 b.hi .Lop_upper_buffer
.Lop_upper_values_separate:
 cmp x12,x2
 b.ls .Lop_upper_metadata_separate
 cmp x10,x4
 b.hi .Lop_upper_buffer
.Lop_upper_metadata_separate:
 /* All959 records are checked before the first output store. */
 mov x1,#959
 mov x3,x2
 adr x5,.Lop_upper_schema
 adr x6,.Lop_upper_points
 ldr x6,[x6]
.Lop_upper_validate:
 ldr x7,[x3]
 ldr w8,[x5]
 cmp x7,x8
 b.ne .Lop_upper_metadata
 ldr x7,[x3,#8]
 ldr w8,[x5,#4]
 add x8,x8,#1
 cmp x7,x8
 b.ne .Lop_upper_metadata
 ldr x7,[x3,#16]
 cmp x7,x6
 b.ne .Lop_upper_metadata
 add x3,x3,#40
 add x5,x5,#12
 subs x1,x1,#1
 b.ne .Lop_upper_validate
 /* Both diagnostic fields use source positive-zero assignments. */
 adr x7,.Lop_upper_block_stride
 ldr x8,[x7]
 ldr x9,[x7,#8]
 add x1,x4,x9
 ldr x2,[x7,#16]
.Lop_upper_zero_block:
 mov x3,#4658
 mov x5,x1
.Lop_upper_zero_words:
 str xzr,[x5],#8
 subs x3,x3,#1
 b.ne .Lop_upper_zero_words
 add x1,x1,x8
 subs x2,x2,#1
 b.ne .Lop_upper_zero_block
 /* Record order and blocked output order are independent. */
 mov x1,x0
 mov x2,#0
 adr x5,.Lop_upper_schema
.Lop_upper_record:
 ldp w6,w7,[x5,#4]
 mov x9,#137
 madd x6,x7,x9,x6
 mov x9,#136
 mul x6,x6,x9
 add x3,x4,x6
 mov x10,x1
 adr x12,.Lop_upper_points
 ldr x12,[x12]
.Lop_upper_copy_block:
 mov x13,#17
 cmp x12,x13
 csel x13,x12,x13,lo
 sub x12,x12,x13
 mov x11,x3
.Lop_upper_copy_words:
 ldr x14,[x10],#8
 str x14,[x11],#8
 subs x13,x13,#1
 b.ne .Lop_upper_copy_words
 cbz x12,.Lop_upper_record_done
 add x3,x3,x8
 b .Lop_upper_copy_block
.Lop_upper_record_done:
 mov x1,x10
 add x5,x5,#12
 add x2,x2,#1
 cmp x2,#959
 b.lo .Lop_upper_record
 mov w0,#0
 ret
.Lop_upper_buffer:
 mov w0,#1
 ret
.Lop_upper_metadata:
 mov w0,#2
 ret
.size md2asm_place_operational_upper_air_fields,.-md2asm_place_operational_upper_air_fields
.section .rodata
.p2align 3
.Lop_upper_extents: .quad 50632744960,38360,65099332296
.Lop_upper_points: .quad 6599680
.Lop_upper_block_stride: .quad 167688,130424,388217
.p2align 3
.Lop_upper_schema:
 .set .Lop_upper_level,0
 .rept 137
 .word 133,.Lop_upper_level,0
 .word 203,.Lop_upper_level,6
 .set .Lop_upper_level,.Lop_upper_level+1
 .endr
 .set .Lop_upper_level,0
 .rept 137
 .word 75,.Lop_upper_level,4
 .word 76,.Lop_upper_level,3
 .word 246,.Lop_upper_level,1
 .word 247,.Lop_upper_level,2
 .word 248,.Lop_upper_level,5
 .set .Lop_upper_level,.Lop_upper_level+1
 .endr
.section .note.GNU-stack,"",%progbits

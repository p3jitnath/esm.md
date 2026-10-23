/* Contract: skills/md2asm/references/openifs/input/partitioned_operational_upper_air_loading.md.
 * Integer placement through the live packed-point map.
 * x0 partition32, x1 output, x2 capacity. See contract for private result ABI.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_validate_partitioned_upper_air_destination
.hidden md2asm_validate_partitioned_upper_air_destination
.type md2asm_validate_partitioned_upper_air_destination,%function
md2asm_validate_partitioned_upper_air_destination:
 cbz x0,.Lpua_destination_bad
 cbz x1,.Lpua_destination_bad
 orr x8,x0,x1
 tst x8,#7
 b.ne .Lpua_destination_bad
 adds x9,x0,#32
 b.cs .Lpua_destination_bad
 ldp x4,x5,[x0]
 ldp x6,x3,[x0,#16]
 cbz x4,.Lpua_destination_bad
 ldr x10,.Lpua_points
 cmp x4,x10
 b.hi .Lpua_destination_bad
 cbz x5,.Lpua_destination_bad
 tst x5,#3
 b.ne .Lpua_destination_bad
 lsl x8,x4,#2
 cmp x6,x8
 b.lo .Lpua_destination_bad
 mov x6,x8
 adds x17,x5,x6
 b.cs .Lpua_destination_bad
 add x7,x4,#16
 mov x8,#17
 udiv x7,x7,x8
 cmp x3,x7
 b.ne .Lpua_destination_bad
 ldr x8,.Lpua_stride
 mul x7,x3,x8
 cmp x2,x7
 b.lo .Lpua_destination_bad
 adds x15,x1,x7
 b.cs .Lpua_destination_bad
 cmp x15,x0
 b.ls .Lpua_record_separate
 cmp x9,x1
 b.hi .Lpua_destination_bad
.Lpua_record_separate:
 cmp x15,x5
 b.ls .Lpua_map_separate
 cmp x17,x1
 b.hi .Lpua_destination_bad
.Lpua_map_separate:
 mov x11,#0
.Lpua_check_index:
 ldr w12,[x5,x11,lsl#2]
 cmp w12,#1
 b.lt .Lpua_index_bad
 cmp w12,w10
 b.gt .Lpua_index_bad
 add x11,x11,#1
 cmp x11,x4
 b.lo .Lpua_check_index
 mov w0,#0
 ret
.Lpua_index_bad:
 mov w0,#3
 ret
.Lpua_destination_bad:
 mov w0,#1
 ret
.size md2asm_validate_partitioned_upper_air_destination,.-md2asm_validate_partitioned_upper_air_destination

/* x0 values,x1 bytes,x2 metadata,x3 bytes,x4 output,x5 bytes,x6 partition. */
.p2align 4
.global md2asm_place_partitioned_operational_upper_air_fields
.type md2asm_place_partitioned_operational_upper_air_fields,%function
md2asm_place_partitioned_operational_upper_air_fields:
 cbz x0,.Lpua_placement_bad_leaf
 cbz x2,.Lpua_placement_bad_leaf
 orr x7,x0,x2
 tst x7,#7
 b.ne .Lpua_placement_bad_leaf
 ldr x7,.Lpua_values_bytes
 cmp x1,x7
 b.lo .Lpua_placement_bad_leaf
 adds x8,x0,x7
 b.cs .Lpua_placement_bad_leaf
 mov x7,#38360
 cmp x3,x7
 b.lo .Lpua_placement_bad_leaf
 adds x9,x2,x7
 b.cs .Lpua_placement_bad_leaf
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x4
 mov x20,x0
 mov x21,x2
 mov x22,x6
 mov x0,x6
 mov x1,x4
 mov x2,x5
 bl md2asm_validate_partitioned_upper_air_destination
 cbnz w0,.Lpua_placement_return
 mov x25,x3
 mov x24,x4
 mov x23,x5
 add x11,x19,x7
 ldr x8,.Lpua_values_bytes
 add x8,x20,x8
 cmp x11,x20
 b.ls .Lpua_values_separate
 cmp x8,x19
 b.hi .Lpua_placement_bad
.Lpua_values_separate:
 mov x9,#38360
 add x9,x21,x9
 cmp x11,x21
 b.ls .Lpua_metadata_separate
 cmp x9,x19
 b.hi .Lpua_placement_bad
.Lpua_metadata_separate:
 mov x1,#959
 mov x3,x21
 adr x5,.Lpua_schema
 ldr x6,.Lpua_points
.Lpua_validate_metadata:
 ldr x7,[x3]
 ldr w8,[x5]
 cmp x7,x8
 b.ne .Lpua_metadata_bad
 ldr x7,[x3,#8]
 ldr w8,[x5,#4]
 add x8,x8,#1
 cmp x7,x8
 b.ne .Lpua_metadata_bad
 ldr x7,[x3,#16]
 cmp x7,x6
 b.ne .Lpua_metadata_bad
 add x3,x3,#40
 add x5,x5,#12
 subs x1,x1,#1
 b.ne .Lpua_validate_metadata
 ldr x8,.Lpua_stride
 ldr x9,.Lpua_diagnostic_offset
 add x1,x19,x9
 mov x2,x25
.Lpua_zero_block:
 mov x3,#4658
 mov x5,x1
.Lpua_zero_words:
 str xzr,[x5],#8
 subs x3,x3,#1
 b.ne .Lpua_zero_words
 add x1,x1,x8
 subs x2,x2,#1
 b.ne .Lpua_zero_block
 mov x26,x20
 adr x27,.Lpua_schema
 mov x28,#0
.Lpua_copy_record:
 ldp w6,w7,[x27,#4]
 mov x9,#137
 madd x6,x7,x9,x6
 mov x9,#136
 mul x6,x6,x9
 add x3,x19,x6
 mov x10,x23
 mov x12,x24
.Lpua_copy_block:
 mov x13,#17
 cmp x12,x13
 csel x13,x12,x13,lo
 sub x12,x12,x13
 mov x11,x3
.Lpua_copy_words:
 ldr w14,[x10],#4
 sub w14,w14,#1
 ldr x15,[x26,x14,lsl#3]
 str x15,[x11],#8
 subs x13,x13,#1
 b.ne .Lpua_copy_words
 cbz x12,.Lpua_record_done
 add x3,x3,x8
 b .Lpua_copy_block
.Lpua_record_done:
 ldr x9,.Lpua_plane_bytes
 add x26,x26,x9
 add x27,x27,#12
 add x28,x28,#1
 cmp x28,#959
 b.lo .Lpua_copy_record
 mov w0,#0
 b .Lpua_placement_return
.Lpua_placement_bad:
 mov w0,#1
 b .Lpua_placement_return
.Lpua_metadata_bad:
 mov w0,#2
.Lpua_placement_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.Lpua_placement_bad_leaf:
 mov w0,#1
 ret
.size md2asm_place_partitioned_operational_upper_air_fields,.-md2asm_place_partitioned_operational_upper_air_fields

/* x0 path,x1 borrowed partition32,x2 in/out GFL,x3 capacity. */
.p2align 4
.global md2asm_load_partitioned_operational_upper_air_state
.type md2asm_load_partitioned_operational_upper_air_state,%function
md2asm_load_partitioned_operational_upper_air_state:
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x25,fpsr
 mrs x26,fpcr
 mov x19,x0
 mov x27,x1
 mov x20,x2
 mov x21,x3
 mov x22,xzr
 mov x24,xzr
 mov w23,#1
 cbz x19,.Lpua_loader_restore
 cbnz x26,.Lpua_loader_restore
 mov x0,x27
 mov x1,x20
 mov x2,x21
 bl md2asm_validate_partitioned_upper_air_destination
 cbnz w0,.Lpua_loader_restore
 bl __errno_location
 mov x24,x0
 ldr w8,[x24]
 str w8,[sp,#104]
 ldr x0,.Lpua_private_bytes
 ldr x18,[sp,#96]
 bl malloc
 mov x22,x0
 mov w23,#2
 cbz x22,.Lpua_loader_restore_errno
 mov x0,x19
 mov x1,x22
 ldr x2,.Lpua_values_bytes
 add x3,x22,x2
 mov x4,#38360
 add x5,sp,#112
 ldr x18,[sp,#96]
 bl md2asm_read_operational_initial_upper_air_fields
 add w23,w0,#16
 cbnz w0,.Lpua_loader_cleanup
 mov x0,x22
 ldr x1,.Lpua_values_bytes
 add x2,x22,x1
 mov x3,#38360
 mov x4,x20
 mov x5,x21
 mov x6,x27
 ldr x18,[sp,#96]
 bl md2asm_place_partitioned_operational_upper_air_fields
 add w23,w0,#32
 cbnz w0,.Lpua_loader_cleanup
 mov w23,#0
.Lpua_loader_cleanup:
 mov x0,x22
 ldr x18,[sp,#96]
 bl free
.Lpua_loader_restore_errno:
 ldr w8,[sp,#104]
 str w8,[x24]
.Lpua_loader_restore:
 msr fpcr,x26
 msr fpsr,x25
 ldr x18,[sp,#96]
 mov w0,w23
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#128
 ret
.size md2asm_load_partitioned_operational_upper_air_state,.-md2asm_load_partitioned_operational_upper_air_state
.section .rodata
.p2align 3
.Lpua_points: .quad 6599680
.Lpua_values_bytes: .quad 50632744960
.Lpua_private_bytes: .quad 50632783320
.Lpua_plane_bytes: .quad 52797440
.Lpua_stride: .quad 167688
.Lpua_diagnostic_offset: .quad 130424
.p2align 3
.Lpua_schema:
 .set .Lpua_level,0
 .rept 137
 .word 133,.Lpua_level,0
 .word 203,.Lpua_level,6
 .set .Lpua_level,.Lpua_level+1
 .endr
 .set .Lpua_level,0
 .rept 137
 .word 75,.Lpua_level,4
 .word 76,.Lpua_level,3
 .word 246,.Lpua_level,1
 .word 247,.Lpua_level,2
 .word 248,.Lpua_level,5
 .set .Lpua_level,.Lpua_level+1
 .endr
.section .note.GNU-stack,"",%progbits

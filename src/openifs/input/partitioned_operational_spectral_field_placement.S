/* Contract: skills/md2asm/references/openifs/input/partitioned_operational_spectral_loading.md. Exact distributed spectral file placement.
 * x0 values,x1 capacity,x2 metadata,x3 capacity,x4 live record2992,x5 capacity.
 * All mapped owner bounds and nonoverlap obligations follow the owned record. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_place_partitioned_operational_spectral_fields
.type md2asm_place_partitioned_operational_spectral_fields,%function
md2asm_place_partitioned_operational_spectral_fields:
 sub sp,sp,#352
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 cbz x0,.Lps_bad
 cbz x2,.Lps_bad
 cbz x4,.Lps_bad
 orr x9,x0,x2
 orr x9,x9,x4
 tst x9,#7
 b.ne .Lps_bad
 ldr x9,.Lps_values_bytes
 cmp x1,x9
 b.lo .Lps_bad
 adds x10,x0,x9
 b.cs .Lps_bad
 stp x0,x10,[sp,#112]
 mov w9,#9912
 cmp x3,x9
 b.lo .Lps_bad
 adds x10,x2,x9
 b.cs .Lps_bad
 stp x2,x10,[sp,#128]
 cmp x5,#2992
 b.lo .Lps_bad
 adds x10,x4,#2992
 b.cs .Lps_bad
 stp x4,x10,[sp,#144]
 mov x19,x0
 mov x20,x2
 mov x21,x4
 ldr w24,[x21,#312]
 ldr w25,[x21,#296]
 cmp w24,#69
 b.ne .Lps_levels68
 cbnz w25,.Lps_map_bad
 adr x1,.Lps_three69
 adr x17,.Lps_two0
 b .Lps_level_ready
.Lps_levels68:
 cmp w24,#68
 b.ne .Lps_map_bad
 cmp w25,#2
 b.ne .Lps_map_bad
 adr x1,.Lps_three68
 adr x17,.Lps_two2
.Lps_level_ready:
 str x17,[sp,#272]
 add x0,x21,#88
 mov w2,#3
 bl .Lps_real_descriptor
 cbz x0,.Lps_map_bad
 mov x22,x0
 ldr x1,[sp,#272]
 mov x0,x21
 mov w2,#2
 bl .Lps_real_descriptor
 cbz x0,.Lps_map_bad
 mov x23,x0
 ldr w9,[x21,#288]
 cmp w9,#1279
 b.ne .Lps_map_bad
 ldr w9,[x21,#316]
 cmp w9,#137
 b.ne .Lps_map_bad
 ldr w9,[x21,#320]
 movz w10,#(819840&65535)
 movk w10,#(819840>>16),lsl#16
 cmp w9,w10
 b.ne .Lps_map_bad
 ldr w9,[x21,#324]
 lsl w10,w10,#1
 cmp w9,w10
 b.ne .Lps_map_bad
 ldr w9,[x21,#300]
 cmp w9,#3
 b.ne .Lps_map_bad
 ldr w9,[x21,#308]
 cmp w9,#2
 b.ne .Lps_map_bad
 ldr w9,[x21,#328]
 cmp w9,#640
 b.ne .Lps_map_bad
 /* Input maps have complete constructor-owned descriptors. */
 add x0,x21,#1200
 mov w1,#640
 mov w2,#1
 bl .Lps_integer_descriptor
 cbz x0,.Lps_map_bad
 mov x26,x0
 adds x9,x0,#2560
 b.cs .Lps_bad
 stp x0,x9,[sp,#160]
 add x0,x21,#408
 mov w1,#1280
 mov w2,#0
 bl .Lps_integer_descriptor
 cbz x0,.Lps_map_bad
 mov x27,x0
 adds x9,x0,#4096
 b.cs .Lps_bad
 adds x9,x9,#1024
 b.cs .Lps_bad
 stp x0,x9,[sp,#176]
 add x0,x21,#472
 mov w1,#1280
 mov w2,#0
 bl .Lps_integer_descriptor
 cbz x0,.Lps_map_bad
 mov x28,x0
 adds x9,x0,#4096
 b.cs .Lps_bad
 adds x9,x9,#1024
 b.cs .Lps_bad
 stp x0,x9,[sp,#192]
 add x0,x21,#1264
 mov w1,w24
 mov w2,#1
 bl .Lps_integer_descriptor
 cbz x0,.Lps_map_bad
 str x0,[sp,#104]
 lsl x9,x24,#2
 adds x9,x0,x9
 b.cs .Lps_bad
 stp x0,x9,[sp,#208]
 add x0,x21,#1328
 mov w1,#5
 mov w2,#1
 bl .Lps_integer_descriptor
 cbz x0,.Lps_map_bad
 adds x9,x0,#20
 b.cs .Lps_bad
 stp x0,x9,[sp,#224]
 adr x9,.Lps_codes
 mov w10,#0
.Lps_code:
 ldr w11,[x0,x10,lsl#2]
 ldr w12,[x9,x10,lsl#2]
 cmp w11,w12
 b.ne .Lps_map_bad
 add x10,x10,#1
 cmp x10,#5
 b.lo .Lps_code
 ldr x9,.Lps_local_words
 mul x10,x24,x9
 mov x11,#24
 mul x10,x10,x11
 adds x10,x22,x10
 b.cs .Lps_bad
 stp x22,x10,[sp,#240]
 mul x10,x25,x9
 lsl x10,x10,#3
 cmp x10,#0
 mov x11,#1
 csel x10,x10,x11,ne
 adds x10,x23,x10
 b.cs .Lps_bad
 stp x23,x10,[sp,#256]
 /* Both writable owners are separate from every read-only span. */
 mov x9,#8
.Lps_overlap_outer:
 add x10,sp,#112
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 mov x13,#0
.Lps_overlap_inner:
 add x10,sp,#112
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Lps_disjoint
 cmp x14,x12
 b.lo .Lps_bad
.Lps_disjoint:
 add x13,x13,#1
 cmp x13,x9
 b.lo .Lps_overlap_inner
 add x9,x9,#1
 cmp x9,#10
 b.lo .Lps_overlap_outer
 /* Every selected source and destination wave span is bounded before stores. */
 mov x9,#0
 ldr x16,.Lps_local_words
 lsl x17,x16,#1
.Lps_wave_check:
 ldr w10,[x26,x9,lsl#2]
 cmp w10,#1279
 b.hi .Lps_map_bad
 mov w11,#1280
 sub w11,w11,w10
 lsl w11,w11,#1
 ldr w12,[x27,x10,lsl#2]
 sub w12,w12,#1
 cmp w12,w16
 b.hs .Lps_map_bad
 add w12,w12,w11
 cmp w12,w16
 b.hi .Lps_map_bad
 ldr w12,[x28,x10,lsl#2]
 sub w12,w12,#1
 cmp w12,w17
 b.hs .Lps_map_bad
 add w12,w12,w11
 cmp w12,w17
 b.hi .Lps_map_bad
 add x9,x9,#1
 cmp x9,#640
 b.lo .Lps_wave_check
 ldr x9,[sp,#104]
 mov w10,#1
 cmp w24,#69
 mov w11,#70
 csel w10,w10,w11,eq
 mov x11,#0
.Lps_level_check:
 ldr w12,[x9,x11,lsl#2]
 add w13,w10,w11
 cmp w12,w13
 b.ne .Lps_map_bad
 add x11,x11,#1
 cmp x11,x24
 b.lo .Lps_level_check
 adr x8,.Lps_pairs
 mov x9,x20
 mov w10,#413
 ldr x17,.Lps_global_words
.Lps_metadata:
 ldp x11,x12,[x9],#16
 ldr x13,[x9],#8
 ldp x14,x15,[x8],#16
 cmp x11,x14
 b.ne .Lps_meta_bad
 cmp x12,x15
 b.ne .Lps_meta_bad
 cmp x13,x17
 b.ne .Lps_meta_bad
 subs w10,w10,#1
 b.ne .Lps_metadata
 /* Field, wave, local level, then real coefficient. */
 mov x0,#0
.Lps_field:
 mov x1,#0
.Lps_wave:
 ldr w3,[x26,x1,lsl#2]
 ldr w4,[x27,x3,lsl#2]
 sub x4,x4,#1
 ldr w5,[x28,x3,lsl#2]
 sub x5,x5,#1
 mov w6,#1280
 sub w6,w6,w3
 lsl w6,w6,#1
 mov x2,#0
.Lps_level:
 ldr x7,[sp,#104]
 ldr w7,[x7,x2,lsl#2]
 sub x7,x7,#1
 add x8,x7,x7,lsl#1
 add x8,x8,x0
 add x8,x8,#1
 ldr x9,.Lps_record_bytes
 madd x10,x8,x9,x19
 add x10,x10,x5,lsl#3
 ldr x9,.Lps_local_words
 madd x11,x0,x9,x4
 madd x11,x11,x24,x2
 add x12,x22,x11,lsl#3
 mov x13,x6
 lsl x15,x24,#3
.Lps_word:
 ldr x14,[x10],#8
 str x14,[x12]
 add x12,x12,x15
 subs x13,x13,#1
 b.ne .Lps_word
 add x2,x2,#1
 cmp x2,x24
 b.lo .Lps_level
 add x1,x1,#1
 cmp x1,#640
 b.lo .Lps_wave
 add x0,x0,#1
 cmp x0,#3
 b.lo .Lps_field
 cbz x25,.Lps_success
 mov x0,#0
.Lps_surface_field:
 mov x1,#0
.Lps_surface_wave:
 ldr w3,[x26,x1,lsl#2]
 ldr w4,[x27,x3,lsl#2]
 sub x4,x4,#1
 ldr w5,[x28,x3,lsl#2]
 sub x5,x5,#1
 mov w6,#1280
 sub w6,w6,w3
 lsl w6,w6,#1
 mov x10,x19
 cbz x0,.Lps_surface_source
 ldr x9,.Lps_orography_start
 add x10,x10,x9
.Lps_surface_source:
 add x10,x10,x5,lsl#3
 ldr x9,.Lps_local_words
 madd x11,x0,x9,x4
 add x12,x23,x11,lsl#3
.Lps_surface_words:
 ldp x13,x14,[x10],#16
 stp x13,x14,[x12],#16
 subs x6,x6,#2
 b.ne .Lps_surface_words
 add x1,x1,#1
 cmp x1,#640
 b.lo .Lps_surface_wave
 add x0,x0,#1
 cmp x0,#2
 b.lo .Lps_surface_field
.Lps_success:
 mov w0,#0
 b .Lps_return
.Lps_bad:
 mov w0,#1
 b .Lps_return
.Lps_meta_bad:
 mov w0,#2
 b .Lps_return
.Lps_map_bad:
 mov w0,#3
.Lps_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#352
 ret
.size md2asm_place_partitioned_operational_spectral_fields,.-md2asm_place_partitioned_operational_spectral_fields
/* x0 int32 descriptor,w1 count,w2 lower. Scratch x0..x17, no stores. */
.Lps_integer_descriptor:
 ldr x3,[x0]
 cbz x3,.Lps_desc_bad
 tst x3,#3
 b.ne .Lps_desc_bad
 ldr x4,[x0,#16]
 cmp x4,#4
 b.ne .Lps_desc_bad
 ldr w4,[x0,#24]
 cbnz w4,.Lps_desc_bad
 ldrh w4,[x0,#28]
 cmp w4,#257
 b.ne .Lps_desc_bad
 ldr x4,[x0,#32]
 cmp x4,#4
 b.ne .Lps_desc_bad
 ldr x4,[x0,#40]
 cmp x4,#1
 b.ne .Lps_desc_bad
 ldr x4,[x0,#48]
 cmp x4,x2
 b.ne .Lps_desc_bad
 add x5,x1,x2
 sub x5,x5,#1
 ldr x4,[x0,#56]
 cmp x4,x5
 b.ne .Lps_desc_bad
 neg x5,x2
 ldr x4,[x0,#8]
 cmp x4,x5
 b.ne .Lps_desc_bad
 mov x0,x3
 ret
.Lps_desc_bad:
 mov x0,#0
 ret

.type .Lps_real_descriptor,%function
.Lps_real_descriptor:
 ldr x3,[x0]
 cbz x3,.Lps_real_reject
 tst x3,#7
 b.ne .Lps_real_reject
 ldr x4,[x0,#8]
 ldr x5,[x1],#8
 cmp x4,x5
 b.ne .Lps_real_reject
 ldr x4,[x0,#16]
 cmp x4,#8
 b.ne .Lps_real_reject
 ldr w4,[x0,#24]
 cbnz w4,.Lps_real_reject
 ldrb w4,[x0,#28]
 cmp w4,w2
 b.ne .Lps_real_reject
 ldrb w4,[x0,#29]
 cmp w4,#3
 b.ne .Lps_real_reject
 ldr x4,[x0,#32]
 cmp x4,#8
 b.ne .Lps_real_reject
 add x0,x0,#40
.Lps_real_dimension:
 ldp x4,x5,[x0],#16
 ldp x6,x7,[x1],#16
 cmp x4,x6
 b.ne .Lps_real_reject
 cmp x5,x7
 b.ne .Lps_real_reject
 ldr x4,[x0],#8
 ldr x5,[x1],#8
 cmp x4,x5
 b.ne .Lps_real_reject
 subs w2,w2,#1
 b.ne .Lps_real_dimension
 mov x0,x3
 ret
.Lps_real_reject:
 mov x0,xzr
 ret
.size .Lps_real_descriptor,.-.Lps_real_descriptor

.section .rodata
.p2align 3
.Lps_values_bytes: .quad 5417502720
.Lps_record_bytes: .quad 13117440
.Lps_local_words: .quad 819840
.Lps_global_words: .quad 1639680
.Lps_orography_start: .quad 5404385280
.Lps_three69: .quad -(1+69+69*819840),1,1,69,69,1,819840,69*819840,1,3
.Lps_three68: .quad -(1+68+68*819840),1,1,68,68,1,819840,68*819840,1,3
.Lps_two0: .quad -819841,1,1,819840,819840,1,0
.Lps_two2: .quad -819841,1,1,819840,819840,1,2
.Lps_codes: .word 138,155,130,152,129
.p2align 3
.Lps_pairs:
 .quad 152,1
 .set .Lps_level_number,1
 .rept 137
 .quad 138,.Lps_level_number
 .quad 155,.Lps_level_number
 .quad 130,.Lps_level_number
 .set .Lps_level_number,.Lps_level_number+1
 .endr
 .quad 129,0
.section .note.GNU-stack,"",%progbits

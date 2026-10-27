/* Contract: skills/md2asm/references/openifs/setup/distributed_spectral_field_storage.md. Direct distributed CREATE_SPEC.
 * x0 record2992, x1 cap, x2 mapview160, x3 cap, x4 IDs20, x5 dummy24.
 * Return0 success,1 cleaned allocation failure,2 atomic admission refusal.
 * Shape-independent direct release provider is accepted serial release. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_distributed_spectral_field
.type md2asm_initialize_distributed_spectral_field,%function
md2asm_initialize_distributed_spectral_field:
 cbz x0,.Ldspec_reject
 cbz x2,.Ldspec_reject
 cbz x4,.Ldspec_reject
 cbz x5,.Ldspec_reject
 orr x9,x0,x2
 orr x9,x9,x5
 tst x9,#7
 b.ne .Ldspec_reject
 tst x4,#3
 b.ne .Ldspec_reject
 cmp x1,#2992
 b.lo .Ldspec_reject
 cmp x3,#160
 b.lo .Ldspec_reject
 adds x9,x0,#2992
 b.cs .Ldspec_reject
 adds x9,x2,#160
 b.cs .Ldspec_reject
 adds x9,x4,#20
 b.cs .Ldspec_reject
 adds x9,x5,#24
 b.cs .Ldspec_reject
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 /* Runtime dimensions and source-sized complete map spans. */
 ldp w6,w7,[x2,#8]
 sub w9,w6,#1
 mov w10,#65535
 cmp w9,w10
 b.hi .Ldspec_reject
 ldp w8,w9,[x2,#152]
 sub w10,w8,#1
 cmp w10,#4095
 b.hi .Ldspec_reject
 sub w10,w9,#1
 cmp w10,#255
 b.hi .Ldspec_reject
 sub w10,w7,#1
 cmp w10,w9
 b.hi .Ldspec_reject
 umull x10,w6,w7
 mov x11,#65536
 cmp x10,x11
 b.hi .Ldspec_reject
 ldp w10,w11,[x2]
 sub w10,w10,#1
 sub w11,w11,#1
 cmp w10,w6
 b.hs .Ldspec_reject
 cmp w11,w7
 b.hs .Ldspec_reject
 add w10,w8,#1
 add w11,w8,#2
 umull x10,w10,w11
 mov w11,#3
 madd w11,w9,w11,wzr
 add w11,w11,#2
 mul x11,x10,x11
 mov w12,#0x7fffffff
 cmp x11,x12
 b.hi .Ldspec_reject
 ldp w11,w12,[x2,#144]
 cmp w11,w10
 b.hi .Ldspec_reject
 tst w11,#1
 b.ne .Ldspec_reject
 add w13,w8,#1
 cmp w12,w13
 b.hi .Ldspec_reject
 add x10,x2,#16
 mov w11,#0
.Ldspec_runtime_span:
 mov w12,w6
 cmp w11,#0
 b.ne .Ldspec_runtime_not_local_span
 ldr w12,[x2,#148]
.Ldspec_runtime_not_local_span:
 cmp w11,#1
 csel w12,w13,w12,eq
 cmp w11,#3
 csel w12,w7,w12,eq
 cmp w11,#4
 csel w12,w7,w12,eq
 cmp w11,#5
 csel w12,w7,w12,eq
 cmp w11,#6
 csel w12,w13,w12,eq
 lsl x12,x12,#2
 ldp x14,x15,[x10],#16
 cbz x14,.Ldspec_reject
 tst x14,#3
 b.ne .Ldspec_reject
 cmp x15,x12
 b.lo .Ldspec_reject
 adds x15,x14,x12
 b.cs .Ldspec_reject
 add w11,w11,#1
 cmp w11,#8
 b.lo .Ldspec_runtime_span
 /* Level and surface maps retain source values and cover the full column. */
 ldr x10,[x2,#64]
 ldr x11,[x2,#80]
 ldr x12,[x2,#96]
 mov w13,#0
 mov w14,#0
 mov w15,#0
.Ldspec_runtime_level:
 ldr w16,[x10,x13,lsl#2]
 cmp w16,w9
 b.hi .Ldspec_reject
 add w14,w14,w16
 ldr w17,[x11,x13,lsl#2]
 add w16,w16,w17
 add w17,w9,#1
 cmp w16,w17
 b.hi .Ldspec_reject
 ldr w16,[x12,x13,lsl#2]
 cmp w16,#1
 b.hi .Ldspec_reject
 add w15,w15,w16
 add w13,w13,#1
 cmp w13,w7
 b.lo .Ldspec_runtime_level
 cmp w14,w9
 b.ne .Ldspec_reject
 cmp w15,#1
 b.ne .Ldspec_reject
 /* Per-group counts and starts select the actual source wave ordering. */
 ldr x10,[x2,#128]
 ldr x11,[x2,#48]
 udiv w12,w8,w6
 add w12,w12,#1
 mov w13,#0
 mov w14,#1
.Ldspec_runtime_wave_groups:
 ldr w15,[x10,x13,lsl#2]
 cmp w15,w12
 b.hi .Ldspec_reject
 ldr w16,[x11,x13,lsl#2]
 cmp w16,w14
 b.ne .Ldspec_reject
 add w14,w14,w15
 add w13,w13,#1
 cmp w13,w6
 b.lo .Ldspec_runtime_wave_groups
 add w15,w8,#2
 cmp w14,w15
 b.ne .Ldspec_reject
 ldr w13,[x2]
 sub w13,w13,#1
 ldr w14,[x10,x13,lsl#2]
 ldr w15,[x2,#148]
 cmp w14,w15
 b.ne .Ldspec_reject
 ldr w13,[x11,x13,lsl#2]
 sub w13,w13,#1
 ldr x10,[x2,#16]
 ldr x11,[x2,#32]
 ldr x12,[x2,#112]
 mov w14,#0
 mov w16,#1
.Ldspec_runtime_local_wave:
 cmp w14,w15
 b.hs .Ldspec_runtime_local_wave_done
 ldr w17,[x10,x14,lsl#2]
 cmp w17,w8
 b.hi .Ldspec_reject
 add w6,w13,w14
 ldr w6,[x11,x6,lsl#2]
 cmp w6,w17
 b.ne .Ldspec_reject
 ldr w6,[x12,x17,lsl#2]
 cmp w6,w16
 b.ne .Ldspec_reject
 add w6,w8,#1
 sub w6,w6,w17
 add w16,w16,w6,lsl#1
 add w14,w14,#1
 b .Ldspec_runtime_local_wave
.Ldspec_runtime_local_wave_done:
 sub w16,w16,#1
 ldr w17,[x2,#144]
 cmp w16,w17
 b.ne .Ldspec_reject

#else
 ldp w9,w10,[x2]
 sub w9,w9,#1
 sub w10,w10,#1
 cmp w9,#1
 b.hi .Ldspec_reject
 cmp w10,#1
 b.hi .Ldspec_reject
 ldp w9,w10,[x2,#8]
 cmp w9,#2
 b.ne .Ldspec_reject
 cmp w10,#2
 b.ne .Ldspec_reject
 ldp w9,w10,[x2,#144]
 movz w11,#(819840&65535)
 movk w11,#(819840>>16),lsl#16
 cmp w9,w11
 b.ne .Ldspec_reject
 cmp w10,#640
 b.ne .Ldspec_reject
 ldr x9,[x2,#152]
 cbnz x9,.Ldspec_reject
 adr x9,.Ldspec_input_sizes
 add x10,x2,#16
 mov w11,#8
.Ldspec_check_input_map:
 ldp x12,x13,[x10],#16
 ldr w14,[x9],#4
 cbz x12,.Ldspec_reject
 tst x12,#3
 b.ne .Ldspec_reject
 cmp x13,x14
 b.lo .Ldspec_reject
 adds x13,x12,x14
 b.cs .Ldspec_reject
 subs w11,w11,#1
 b.ne .Ldspec_check_input_map
 ldr x9,[x2,#64]
 ldp w10,w11,[x9]
 cmp w10,#69
 b.ne .Ldspec_reject
 cmp w11,#68
 b.ne .Ldspec_reject
 ldr x9,[x2,#80]
 ldp w10,w11,[x9]
 cmp w10,#1
 b.ne .Ldspec_reject
 cmp w11,#70
 b.ne .Ldspec_reject
 ldr x9,[x2,#96]
 ldp w10,w11,[x9]
 cbnz w10,.Ldspec_reject
 cmp w11,#1
 b.ne .Ldspec_reject
 ldr x9,[x2,#128]
 ldp w10,w11,[x9]
 cmp w10,#640
 b.ne .Ldspec_reject
 cmp w11,#640
 b.ne .Ldspec_reject

#endif
 mrs x9,fpcr
 cbnz x9,.Ldspec_reject
 /* A fresh record is an explicit owned input, not a source type table. */
 mov x9,#0
.Ldspec_check_zero_record:
 ldr x10,[x0,x9]
 cbnz x10,.Ldspec_reject
 add x9,x9,#8
 cmp x9,#2992
 b.lo .Ldspec_check_zero_record
 adr x9,.Ldspec_ids
 mov x10,#0
.Ldspec_check_ids:
 ldr w11,[x9,x10,lsl#2]
 cmp x10,#3
 mov x12,#0
 mov x13,#3
 b.lo .Ldspec_id_group
 mov x12,#3
 mov x13,#5
.Ldspec_id_group:
 ldr w14,[x4,x12,lsl#2]
 cmp w14,w11
 b.eq .Ldspec_id_found
 add x12,x12,#1
 cmp x12,x13
 b.lo .Ldspec_id_group
 b .Ldspec_reject
.Ldspec_id_found:
 add x10,x10,#1
 cmp x10,#5
 b.lo .Ldspec_check_ids
 sub sp,sp,#176
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x22,x2
 ldr w9,[x22,#4]
 sub w9,w9,#1
 ldr x10,[x22,#64]
 ldr w20,[x10,x9,lsl#2]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 ldr w21,[x22,#152]
#else
 mov w21,#1279
#endif

 mov x23,x5
 str x4,[sp,#144]
 ldr w28,[x22,#144]
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 adr x27,.Ldspec_owners
 mov x26,#0
.Ldspec_allocate:
 ldr w0,[x27,#12]
 bl .Ldspec_extent
 str x0,[sp,#112]
 ldr w0,[x27,#20]
 bl .Ldspec_extent
 str x0,[sp,#120]
 ldr w0,[x27,#24]
 bl .Ldspec_extent
 str x0,[sp,#128]
 ldr x9,[sp,#112]
 ldr x10,[sp,#120]
 mul x0,x0,x9
 mul x0,x0,x10
 ldr w9,[x27,#8]
 mul x0,x0,x9
 cmp x0,#0
 mov x9,#1
 csel x0,x0,x9,ne
 bl malloc
 cbz x0,.Ldspec_failed
 mov x1,x0
 ldr w9,[x27]
 add x0,x19,w9,uxtw
 ldp w3,w2,[x27,#4]
 ldr w4,[x27,#16]
 ldr x5,[sp,#112]
 add x5,x5,x4
 sub x5,x5,#1
 ldr x6,[sp,#120]
 ldr x7,[sp,#128]
 bl .Ldspec_descriptor
 add x27,x27,#32
 add x26,x26,#1
 cmp x26,#16
 b.lo .Ldspec_allocate
 /* Source scalars distinguish local and global dimensions. */
 str w21,[x19,#288]
 str wzr,[x19,#292]
 ldr w9,[x22,#4]
 sub w9,w9,#1
 ldr x10,[x22,#96]
 ldr w9,[x10,x9,lsl#2]
 lsl w9,w9,#1
 mov w10,#3
 str w9,[x19,#296]
 str w10,[x19,#300]
 str wzr,[x19,#304]
 mov w11,#2
 str w11,[x19,#308]
 str w20,[x19,#312]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 ldr w11,[x22,#156]
#else
 mov w11,#137
#endif

 str w11,[x19,#316]
 str w28,[x19,#320]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 add w11,w21,#1
 add w12,w21,#2
 mul w11,w11,w12
#else
 movz w11,#(1639680&65535)
 movk w11,#(1639680>>16),lsl#16
#endif

 str w11,[x19,#324]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 ldr w11,[x22,#148]
#else
 mov w11,#640
#endif

 str w11,[x19,#328]
 madd w10,w20,w10,w9
 mul w10,w10,w28
 str w10,[x19,#332]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 ldr w10,[x22,#156]
 mov w11,#3
 mul w10,w10,w11
 add w10,w10,#2
 ldr w11,[x19,#324]
 mul w10,w10,w11
#else
 movz w10,#(677187840&65535)
 movk w10,#(677187840>>16),lsl#16
#endif

 str w10,[x19,#336]
 /* Borrowed maps have the same qualified distribution inputs as CREATE_SPEC. */
 adr x27,.Ldspec_copy_maps
 mov w26,#8
.Ldspec_copy_map:
 ldp w9,w10,[x27]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 ldr w0,[x27,#8]
 bl .Ldspec_extent
 lsl x2,x0,#2
 ldp w9,w10,[x27]
 ldr x0,[x19,x9]
#else
 ldr w2,[x27,#8]
 ldr x0,[x19,x9]
#endif

 ldr x1,[x22,x10]
 bl memcpy
 add x27,x27,#16
 subs w26,w26,#1
 b.ne .Ldspec_copy_map
 /* Global starting coefficients retain the source running sum. */
 ldr x9,[x19,#472]
 mov w10,#1
 mov w11,#0
.Ldspec_global_waves:
 str w10,[x9,x11,lsl#2]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 add w12,w21,#1
#else
 mov w12,#1280
#endif

 sub w12,w12,w11
 add w10,w10,w12,lsl#1
 add w11,w11,#1
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 add w12,w21,#1
 cmp w11,w12
#else
 cmp w11,#1280
#endif

 b.lo .Ldspec_global_waves
 ldr x9,[x19,#1264]
 ldr w10,[x22,#4]
 sub w10,w10,#1
 ldr x11,[x22,#80]
 ldr w10,[x11,x10,lsl#2]
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 mov w11,#0
 cbz w20,.Ldspec_level_map_done
.Ldspec_level_map:
#else
 mov w11,#0
.Ldspec_level_map:
#endif

 add w12,w10,w11
 str w12,[x9,x11,lsl#2]
 add w11,w11,#1
 cmp w11,w20
 b.lo .Ldspec_level_map
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
.Ldspec_level_map_done:
 ldr x9,[x19,#344]
 ldr x10,[x22,#96]
 ldr w12,[x22,#12]
 mov w13,#0
.Ldspec_runtime_surface:
 ldr w11,[x10,x13,lsl#2]
 lsl w11,w11,#1
 str w11,[x9,x13,lsl#2]
 add w13,w13,#1
 cmp w13,w12
 b.lo .Ldspec_runtime_surface
#else
 ldr x9,[x19,#344]
 ldr x10,[x22,#96]
 ldp w11,w12,[x10]
 lsl w11,w11,#1
 lsl w12,w12,#1
 stp w11,w12,[x9]
#endif

#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 /* Populate only the source-defined cells of each process column. */
 ldr x9,[x19,#856]
 ldr x10,[x19,#792]
 ldr x11,[x19,#1136]
 ldr x17,[x19,#728]
 ldr w6,[x22,#8]
 udiv w7,w21,w6
 add w7,w7,#1
 mov w12,#0
.Ldspec_ms_process:
 ldr w13,[x11,x12,lsl#2]
 sub w13,w13,#1
 ldr w8,[x17,x12,lsl#2]
 mov w14,#0
 cbz w8,.Ldspec_ms_process_next
.Ldspec_ms_process_wave:
 add w15,w13,w14
 ldr w15,[x10,x15,lsl#2]
 madd w16,w12,w7,w14
 str w15,[x9,x16,lsl#2]
 add w14,w14,#1
 cmp w14,w8
 b.lo .Ldspec_ms_process_wave
.Ldspec_ms_process_next:
 add w12,w12,#1
 cmp w12,w6
 b.lo .Ldspec_ms_process

#else
 /* Two process columns are complete because both own640 waves. */
 ldr x9,[x19,#856]
 ldr x10,[x19,#792]
 ldr x11,[x19,#1136]
 mov w12,#0
.Ldspec_ms_process:
 ldr w13,[x11,x12,lsl#2]
 sub w13,w13,#1
 mov w14,#0
.Ldspec_ms_process_wave:
 add w15,w13,w14
 ldr w15,[x10,x15,lsl#2]
 mov w16,#640
 madd w16,w12,w16,w14
 str w15,[x9,x16,lsl#2]
 add w14,w14,#1
 cmp w14,#640
 b.lo .Ldspec_ms_process_wave
 add w12,w12,#1
 cmp w12,#2
 b.lo .Ldspec_ms_process

#endif
 ldr x9,[x19,#1328]
 adr x10,.Ldspec_ids
 mov x11,#0
.Ldspec_field_map:
 ldr w12,[x10,x11,lsl#2]
 str w12,[x9,x11,lsl#2]
 add x11,x11,#1
 cmp x11,#5
 b.lo .Ldspec_field_map
 /* Every numerical owner starts at positive zero, as CREATE_SPEC requires. */
 ldr x0,[x19,#88]
 mul x1,x20,x28
 mov x9,#24
 mul x1,x1,x9
 bl .Ldspec_zero
 ldr x0,[x19]
 ldr w1,[x19,#296]
 mul x1,x1,x28
 lsl x1,x1,#3
 bl .Ldspec_zero
 ldr x0,[x19,#200]
 mov x1,#16
 bl .Ldspec_zero
 stp xzr,xzr,[x23]
 str xzr,[x23,#16]
 add x0,x19,#1456
 ldr x1,[x19,#1328]
 mov w2,#4
 mov w3,#1
 mov x4,#1
 mov x5,#3
 mov x6,#1
 mov x7,#1
 bl .Ldspec_descriptor
 add x0,x19,#1392
 ldr x1,[x19,#1328]
 add x1,x1,#12
 mov w2,#4
 mov w3,#1
 mov x4,#1
 mov x5,#2
 mov x6,#1
 mov x7,#1
 bl .Ldspec_descriptor
 adr x27,.Ldspec_views
 mov x26,#0
.Ldspec_view_loop:
 ldr w0,[x27,#16]
 bl .Ldspec_extent
 str x0,[sp,#112]
 ldr w0,[x27,#20]
 bl .Ldspec_extent
 str x0,[sp,#120]
 ldr w0,[x27,#24]
 bl .Ldspec_extent
 str x0,[sp,#128]
 ldr w9,[x27,#8]
 cmp w9,#0
 b.eq .Ldspec_view_sp3
 cmp w9,#1
 b.eq .Ldspec_view_sp2
 cmp w9,#2
 b.eq .Ldspec_view_sp1
 cmp w9,#3
 b.eq .Ldspec_view_dummy3
 add x1,x23,#16
 b .Ldspec_view_address_ready
.Ldspec_view_dummy3:
 add x1,x23,#8
 b .Ldspec_view_address_ready
.Ldspec_view_sp3:
 ldr x1,[x19,#88]
 ldr w9,[x27,#12]
 mul x10,x20,x28
 mul x9,x9,x10
 add x1,x1,x9,lsl#3
 b .Ldspec_view_address_ready
.Ldspec_view_sp2:
 ldr w9,[x19,#296]
 cbz w9,.Ldspec_view_empty_surface
 ldr x1,[x19]
 ldr w9,[x27,#12]
 mul x9,x9,x28
 add x1,x1,x9,lsl#3
 b .Ldspec_view_address_ready
.Ldspec_view_empty_surface:
 mov x1,x23
 mov x9,#1
 str x9,[sp,#112]
 b .Ldspec_view_address_ready
.Ldspec_view_sp1:
 ldr x1,[x19,#200]
 ldr w9,[x27,#12]
 add x1,x1,x9,lsl#3
.Ldspec_view_address_ready:
 ldr w9,[x27]
 add x0,x19,w9,uxtw
 mov w2,#8
 ldr w3,[x27,#4]
 mov x4,#1
 ldr x5,[sp,#112]
 ldr x6,[sp,#120]
 ldr x7,[sp,#128]
 bl .Ldspec_descriptor
 add x27,x27,#32
 add x26,x26,#1
 cmp x26,#16
 b.lo .Ldspec_view_loop
 mov w0,#0
 b .Ldspec_return
.Ldspec_failed:
 mov x0,x19
 bl md2asm_release_serial_spectral_field
 mov w0,#1
.Ldspec_return:
 str w25,[x24]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#176
 ret
.Ldspec_reject:
 mov w0,#2
 ret
.size md2asm_initialize_distributed_spectral_field,.-md2asm_initialize_distributed_spectral_field
/* Explicit source extents. */
.Ldspec_extent:
 cbz w0,.Ldspec_extent_one
 cmp w0,#1
 b.eq .Ldspec_extent_waves
 cmp w0,#2
 b.eq .Ldspec_extent_levels
 cmp w0,#3
 b.eq .Ldspec_extent_five
 cmp w0,#4
 b.eq .Ldspec_extent_spectral
 cmp w0,#5
 b.eq .Ldspec_extent_three
 cmp w0,#6
 b.eq .Ldspec_extent_surface
 cmp w0,#7
 b.eq .Ldspec_extent_local_waves
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 cmp w0,#9
 b.eq .Ldspec_extent_process_width
 cmp w0,#10
 b.eq .Ldspec_extent_vertical_groups
 cmp w0,#11
 b.eq .Ldspec_extent_two
 ldr w0,[x22,#8]
 ret
.Ldspec_extent_process_width:
 ldr w9,[x22,#8]
 udiv w0,w21,w9
 add w0,w0,#1
 ret
.Ldspec_extent_vertical_groups:
 ldr w0,[x22,#12]
 ret
.Ldspec_extent_two:
 mov w0,#2
 ret
#else
 cmp w0,#9
 b.eq .Ldspec_extent_local_waves
 mov w0,#2
 ret
#endif

.Ldspec_extent_one: mov w0,#1
 ret
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
.Ldspec_extent_waves: add w0,w21,#1
#else
.Ldspec_extent_waves: mov w0,#1280
#endif

 ret
.Ldspec_extent_levels: mov w0,w20
 ret
.Ldspec_extent_five: mov w0,#5
 ret
.Ldspec_extent_spectral: mov w0,w28
 ret
.Ldspec_extent_three: mov w0,#3
 ret
.Ldspec_extent_surface:
 ldr w9,[x22,#4]
 sub w9,w9,#1
 ldr x10,[x22,#96]
 ldr w0,[x10,x9,lsl#2]
 lsl w0,w0,#1
 ret
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
.Ldspec_extent_local_waves: ldr w0,[x22,#148]
#else
.Ldspec_extent_local_waves: mov w0,#640
#endif

 ret
/* GNU descriptor from actual source type layout; higher lower bounds are1. */
.Ldspec_descriptor:
 str x1,[x0]
 str x2,[x0,#16]
 str xzr,[x0,#24]
 mov w9,#0x100
 mov w10,#0x300
 cmp w2,#8
 csel w9,w10,w9,eq
 orr w9,w9,w3
 str w9,[x0,#28]
 str x2,[x0,#32]
 mov x9,#1
 str x9,[x0,#40]
 stp x4,x5,[x0,#48]
 neg x11,x4
 sub x10,x5,x4
 add x10,x10,#1
 cmp w3,#2
 b.lo .Ldspec_descriptor_done
 str x10,[x0,#64]
 str x9,[x0,#72]
 str x6,[x0,#80]
 sub x11,x11,x10
 cmp w3,#3
 b.lo .Ldspec_descriptor_done
 mul x10,x10,x6
 str x10,[x0,#88]
 str x9,[x0,#96]
 str x7,[x0,#104]
 sub x11,x11,x10
.Ldspec_descriptor_done:
 str x11,[x0,#8]
 ret
.Ldspec_zero:
 cmp x1,#16
 b.lo .Ldspec_zero_tail
 stp xzr,xzr,[x0],#16
 sub x1,x1,#16
 b .Ldspec_zero
.Ldspec_zero_tail:
 cbz x1,.Ldspec_zero_done
 str xzr,[x0]
.Ldspec_zero_done: ret
.section .rodata
.p2align 3
.Ldspec_ids: .word 138,155,130,152,129
.Ldspec_owners:
 .word 1200,1,4,7,1,0,0,0 /* MYMS */
 .word 792,1,4,1,1,0,0,0 /* NALLMS */
 .word 1136,1,4,8,1,0,0,0 /* NPTRMS */
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 .word 944,1,4,10,1,0,0,0 /* NUMLL */
#else
 .word 944,1,4,8,1,0,0,0 /* NUMLL */
#endif

#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 .word 1008,1,4,10,1,0,0,0 /* NPTRLL */
#else
 .word 1008,1,4,8,1,0,0,0 /* NPTRLL */
#endif

#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 .word 1072,1,4,10,1,0,0,0 /* NPSURF */
#else
 .word 1072,1,4,8,1,0,0,0 /* NPSURF */
#endif

 .word 1264,1,4,2,1,0,0,0 /* MYLEVS */
 .word 408,1,4,1,0,0,0,0 /* NASM0 */
 .word 472,1,4,1,0,0,0,0 /* NASM0G */
 .word 728,1,4,8,1,0,0,0 /* NUMPP */
 .word 856,2,4,9,1,8,0,0 /* MS_PROC */
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 .word 344,1,4,10,1,0,0,0 /* NS2L */
#else
 .word 344,1,4,8,1,0,0,0 /* NS2L */
#endif

 .word 1328,1,4,3,1,0,0,0 /* NGRIB */
 .word 88,3,8,2,1,4,5,0 /* SP3D */
 .word 0,2,8,4,1,6,0,0 /* SP2D */
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
 .word 200,2,8,0,1,11,0,0,0 /* SP1D */
#else
 .word 200,2,8,0,1,8,0,0 /* SP1D */
#endif

.Ldspec_views:
 .word 1520,2,0,0,2,4,0,0 /* VOR */
 .word 1608,2,0,1,2,4,0,0 /* DIV */
 .word 1696,2,0,2,2,4,0,0 /* T */
 .word 1784,2,3,0,0,0,0,0 /* Q */
 .word 1872,2,3,0,0,0,0,0 /* O3 */
 .word 1960,2,3,0,0,0,0,0 /* L */
 .word 2136,2,3,0,0,0,0,0 /* SPD */
 .word 2224,2,3,0,0,0,0,0 /* SVD */
 .word 2312,2,3,0,0,0,0,0 /* NHX */
 .word 2400,1,1,0,4,0,0,0 /* SP */
 .word 2464,1,1,1,4,0,0,0 /* OROG */
 .word 2528,3,0,2,2,4,0,0 /* SCAL */
 .word 2640,3,4,0,0,0,0,0 /* GFL */
 .word 2752,3,0,2,2,4,0,0 /* HV */
 .word 2864,1,2,0,0,0,0,0 /* UB */
 .word 2928,1,2,1,0,0,0,0 /* VB */
 .p2align 3
.Ldspec_input_sizes: .word 2560,5120,8,8,8,8,5120,8
#ifdef MD2ASM_RUNTIME_DISTRIBUTED_PARTITION
.Ldspec_copy_maps:
 .word 1200,16,7,0
 .word 792,32,1,0
 .word 1136,48,8,0
 .word 944,64,10,0
 .word 1008,80,10,0
 .word 1072,96,10,0
 .word 408,112,1,0
 .word 728,128,8,0

#else
.Ldspec_copy_maps:
 .word 1200,16,2560,0
 .word 792,32,5120,0
 .word 1136,48,8,0
 .word 944,64,8,0
 .word 1008,80,8,0
 .word 1072,96,8,0
 .word 408,112,5120,0
 .word 728,128,8,0

#endif
.section .note.GNU-stack,"",%progbits

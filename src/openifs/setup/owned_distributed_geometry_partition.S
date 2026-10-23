/* Distributed setup contract: skills/md2asm/references/openifs/setup/owned_distributed_geometry_system.md. */
/* Contract: skills/md2asm/references/openifs/setup/owned_distributed_geometry_system.md..
 * x0 Geometry17096, x1 constants520, x2 text, x3 bytes, w4 world4,
 * x5 null output slot. Complete owner4096 borrows Geometry at its final address.
 * Integer control and metadata only. Public MPI/FIAT/ectrans and libc providers.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_owned_distributed_geometry_partition
.type md2asm_create_owned_distributed_geometry_partition,%function
md2asm_create_owned_distributed_geometry_partition:
 stp x29,x30,[sp,#-256]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov w23,w4
 mov x24,x5
 mov x25,#0
 bl .Ldp_guard
 str w0,[sp,#104]
 str wzr,[sp,#108]
 str wzr,[sp,#112]
 str wzr,[sp,#116]
 stp xzr,xzr,[sp,#128]
 stp xzr,xzr,[sp,#144]
 stp xzr,xzr,[sp,#160]
 stp xzr,xzr,[sp,#176]
 add x9,sp,#116
 str x9,[sp,#128]
 str x9,[sp,#160]
 str x9,[sp,#168]
 add x9,sp,#108
 str x9,[sp,#144]
 add x9,sp,#112
 str x9,[sp,#152]
 add x0,sp,#128
 bl md2asm_call_public_message_init
 ldr w9,[sp,#108]
 cbnz w9,.Ldp_abort
 ldr w9,[sp,#112]
 cmp w9,w23
 b.eq .Ldp_world_matched
 mov w9,#2
 str w9,[sp,#104]
.Ldp_world_matched:
 ldr w0,[sp,#104]
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 /* Read the actual populated process group from the live configuration. */
 mov x0,x21
 mov x1,x22
 mov w2,w23
 bl md2asm_operational_process_configuration_group
 cbnz w0,.Ldp_parse_done
 mov x0,x21
 mov x1,x22
 adr x2,.Ldp_vectors
 mov x3,#23
 bl md2asm_require_empty_geometry_group
 cbnz w0,.Ldp_parse_done
 mov x0,x21
 mov x1,x22
 mov x2,#0
 bl md2asm_empty_transform_configuration_group
 cbnz w0,.Ldp_parse_done
 mov x0,x21
 mov x1,x22
 mov x2,#1
 bl md2asm_operational_transform_configuration_group
.Ldp_parse_done:
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 mov x0,#1
 mov x1,#4096
 bl calloc
 mov x25,x0
 cmp x0,#0
 cset w0,eq
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 str x19,[x25]
 str w23,[x25,#24]
 bl mpl_myrank
 str w0,[x25,#28]
 cmp w0,#1
 b.lt .Ldp_abort
 cmp w0,w23
 b.gt .Ldp_abort
 mov w9,#1
 mov w10,w23
 cmp w23,#4
 b.ne .Ldp_factors
 mov w9,#2
 mov w10,#2
.Ldp_factors:
 stp w10,w9,[x25,#32]
 stp w10,w9,[x25,#40]
 add x0,x25,#32
 add x1,x25,#36
 bl __mpl_groups_MOD_mpl_groups_create
 add x0,x25,#28
 add x1,x25,#64
 add x2,x25,#68
 bl __mpl_groups_MOD_mpl_cart_coords
 ldr w9,[x25,#28]
 sub w9,w9,#1
 ldr w10,[x25,#36]
 udiv w11,w9,w10
 msub w12,w11,w10,w9
 add w11,w11,#1
 add w12,w12,#1
 ldp w13,w14,[x25,#64]
 cmp w11,w13
 b.ne .Ldp_abort
 cmp w12,w14
 b.ne .Ldp_abort
 /* Complete process control at owner+96. */
 add x26,x25,#96
 str w23,[x26]
 ldr w9,[x25,#28]
 str w9,[x26,#4]
 ldp w9,w10,[x25,#40]
 stp w9,w10,[x26,#8]
 ldp w9,w10,[x25,#32]
 stp w9,w10,[x26,#16]
 str w9,[x26,#24]
 ldr w9,[x25,#68]
 ldr w10,[x25,#64]
 stp w9,w10,[x26,#28]
 movz w9,#0x7740
 movk w9,#0x1b,lsl#16
 str w9,[x26,#40]
 mov w9,#1
 str w9,[x26,#52]
 str w9,[x26,#60]
 mov w10,#37
 str w10,[x26,#72]
 str w9,[x26,#76]
 ldr x10,[x20,#104]
 str x10,[x26,#96]
 mov w10,#6
 str w10,[x26,#288]
 str w9,[x26,#296]
 add x0,x25,#400
 add x1,x25,#464
 add w2,w23,#2
 mov x3,#0
 bl .Ldp_descriptor
 adr x27,.Ldp_setup_offsets
 mov x28,#0
.Ldp_setup_arguments:
 ldrsw x9,[x27,x28,lsl#2]
 tbnz x9,#63,.Ldp_setup_next
 add x10,x26,x9
 add x11,x25,#496
 str x10,[x11,x28,lsl#3]
.Ldp_setup_next:
 add x28,x28,#1
 cmp x28,#18
 b.lo .Ldp_setup_arguments
 add x9,x25,#400
 str x9,[x25,#616]
 add x0,x25,#496
 bl md2asm_call_public_transform_setup0
 ldp w9,w10,[x26,#104]
 stp w9,w10,[x25,#48]
 sub w11,w9,#1
 cmp w11,#3
 b.hi .Ldp_abort
 sub w11,w10,#1
 cmp w11,#3
 b.hi .Ldp_abort
 mul w11,w9,w10
 cmp w11,#8
 b.hi .Ldp_abort
 add x0,x26,#120
 add x1,x25,#464
 ldr w2,[x25,#48]
 mov x3,#0
 bl .Ldp_descriptor
 add x0,x26,#184
 add x1,x25,#3264
 ldr w2,[x25,#52]
 ldr w3,[x25,#48]
 bl .Ldp_descriptor
 mov x9,#0
 mov w10,#0
 add x11,x25,#464
 add x12,x25,#3264
.Ldp_region_map_outer:
 ldr w13,[x11,x9,lsl#2]
 mov x14,#0
.Ldp_region_map_inner:
 ldr w15,[x25,#52]
 mul x16,x9,x15
 add x16,x16,x14
 add w10,w10,#1
 str w10,[x12,x16,lsl#2]
 add x14,x14,#1
 cmp x14,x13
 b.lo .Ldp_region_map_inner
 add x9,x9,#1
 ldr w13,[x25,#48]
 cmp x9,x13
 b.lo .Ldp_region_map_outer
 cmp w10,w23
 b.ne .Ldp_abort
 mov x0,x19
 mov x1,x26
 mov x2,x21
 mov x3,x22
 bl md2asm_initialize_operational_transform_resolution
 cbnz w0,.Ldp_abort
 mov w9,#1
 str w9,[x25,#16]
 /* Original SUGEM1A insertion point, after public resolution and before SUMP. */
 mov w9,#1
 stp w9,w9,[sp,#224]
 mov x0,x19
 add x1,sp,#224
 bl md2asm_initialize_operational_global_grid_cutoffs
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 /* Allocate exactly the complete query payload. */
 ldp w9,w10,[x25,#48]
 mov w11,#5118
 add w11,w11,w9
 add w11,w11,w9,lsl#1
 mul w11,w11,w10
 mov w12,#7682
 add w12,w12,w9,lsl#2
 add w12,w12,w23
 add w12,w12,w23,lsl#2
 add w12,w12,w11
 str w12,[x25,#56]
 mov x0,x12
 mov x1,#4
 bl calloc
 str x0,[x25,#88]
 cmp x0,#0
 cset w0,eq
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 /* The common pointer table is reused after SETUP_TRANS0. */
 add x9,x25,#496
 mov x10,#0
.Ldp_query_zero:
 str xzr,[x9,x10,lsl#3]
 add x10,x10,#1
 cmp x10,#47
 b.lo .Ldp_query_zero
 add x9,x19,#4096
 add x9,x9,#1072
 str x9,[x25,#496]
 adr x27,.Ldp_scalar_indices
 mov x28,#0
.Ldp_query_scalars:
 ldrb w9,[x27,x28]
 add x10,x25,#880
 add x10,x10,x28,lsl#2
 add x11,x25,#496
 str x10,[x11,x9,lsl#3]
 add x28,x28,#1
 cmp x28,#20
 b.lo .Ldp_query_scalars
 ldr x27,[x25,#88]
 mov x28,#0
.Ldp_query_arrays:
 adr x12,.Ldp_array_table
 mov x13,#12
 madd x12,x28,x13,x12
 ldp w9,w10,[x12]
 ldr w2,[x12,#8]
 mov x3,#0
 cbz w10,.Ldp_array_dimensions
 cmp w10,#1
 b.ne .Ldp_array_mode2
 mov w2,w23
 b .Ldp_array_dimensions
.Ldp_array_mode2:
 cmp w10,#2
 b.ne .Ldp_array_mode3
 add w2,w23,#1
 b .Ldp_array_dimensions
.Ldp_array_mode3:
 ldr w2,[x25,#48]
 cmp w10,#3
 b.eq .Ldp_array_dimensions
 cmp w10,#5
 b.eq .Ldp_array_rank2
 add w2,w2,#2559
 cmp w10,#4
 b.eq .Ldp_array_dimensions
.Ldp_array_rank2:
 ldr w3,[x25,#52]
.Ldp_array_dimensions:
 mov x12,#88
 mul x12,x28,x12
 add x0,x25,#960
 add x0,x0,x12
 add x12,x25,#496
 str x0,[x12,x9,lsl#3]
 mov x1,x27
 bl .Ldp_descriptor
 cmp x28,#15
 b.ne .Ldp_query_dtype_ready
 mov x9,#0x201
 lsl x9,x9,#32
 str x9,[x0,#24]
.Ldp_query_dtype_ready:
 cmp x3,#0
 csinc x9,x3,xzr,ne
 mul x9,x9,x2
 add x27,x27,x9,lsl#2
 add x28,x28,#1
 cmp x28,#16
 b.lo .Ldp_query_arrays
 ldr x9,[x25,#88]
 sub x9,x27,x9
 ldr w10,[x25,#56]
 cmp x9,x10,lsl#2
 b.ne .Ldp_abort
 mov x0,x25
 bl md2asm_complete_owned_distributed_SUMP
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 ldr w9,[x25,#904]
 movz w10,#0xb400
 movk w10,#0x64,lsl#16
 cmp w9,w10
 b.ne .Ldp_abort
 ldr w9,[x25,#888]
 movz w10,#0x0500
 movk w10,#0x19,lsl#16
 cmp w9,w10
 b.ne .Ldp_abort
 ldr w9,[x25,#936]
 str w9,[x26,#112]
 ldr w9,[x25,#932]
 str w9,[x26,#116]
 ldr w9,[x25,#900]
 cmp w9,#1
 b.lt .Ldp_abort
 movz w10,#0xb400
 movk w10,#0x64,lsl#16
 cmp w9,w10
 b.gt .Ldp_abort
 sub w9,w9,#1
 mov w10,#17
 udiv w11,w9,w10
 msub w12,w11,w10,w9
 add w11,w11,#1
 add w12,w12,#1
 stp w11,w12,[x25,#72]
 umull x9,w11,w10
 str x9,[x25,#80]
 mov w0,#0
 bl .Ldp_agree
 cbnz w0,.Ldp_cleanup
 ldr x9,.Ldp_cookie
 str x9,[x25,#8]
 str x25,[x24]
 mov w0,#0
 b .Ldp_return
.Ldp_cleanup:
 str w0,[sp,#208]
 cbz x25,.Ldp_cleanup_message
 ldr w9,[x25,#16]
 cbz w9,.Ldp_cleanup_owner_message
 mov x0,x25
 bl .Ldp_destroy
 b .Ldp_cleanup_done
.Ldp_cleanup_owner_message:
 ldr x0,[x25,#88]
 bl free
 mov x0,x25
 bl free
.Ldp_cleanup_message:
 add x0,sp,#108
 add x1,sp,#116
 bl __mpl_end_mod_MOD_mpl_end
.Ldp_cleanup_done:
 ldr w0,[sp,#208]
.Ldp_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp],#256
 ret
.size md2asm_create_owned_distributed_geometry_partition,.-md2asm_create_owned_distributed_geometry_partition
/* Local validation introduces no collective call or mutation. */
.Ldp_guard:
 mov w0,#2
 mrs x9,fpcr
 cbnz x9,.Ldp_guard_return
 cbz x19,.Ldp_guard_return
 cbz x20,.Ldp_guard_return
 cbz x21,.Ldp_guard_return
 cbz x22,.Ldp_guard_return
 cbz x24,.Ldp_guard_return
 orr x9,x19,x20
 orr x9,x9,x24
 tst x9,#7
 b.ne .Ldp_guard_return
 cmp w23,#4
 b.ne .Ldp_guard_return
 mov x9,#262144
 cmp x22,x9
 b.hi .Ldp_guard_return
 ldr x9,[x24]
 cbnz x9,.Ldp_guard_return
 ldr w9,[x19,#5172]
 cmp w9,#1279
 b.ne .Ldp_guard_return
 ldr w9,[x19,#4872]
 cmp w9,#2560
 b.ne .Ldp_guard_return
 ldr w9,[x19,#5168]
 cbnz w9,.Ldp_guard_return
 ldr x9,[x19]
 cbz x9,.Ldp_guard_return
 ldr w9,[x9]
 cbnz w9,.Ldp_guard_return
 ldr w9,[x19,#5224]
 cmp w9,#137
 b.ne .Ldp_guard_return
 ldr w9,[x19,#5208]
 cmp w9,#1279
 b.ne .Ldp_guard_return
 ldr w9,[x19,#5176]
 cmp w9,#1279
 b.ne .Ldp_guard_return
 ldr w9,[x19,#5144]
 cmp w9,#16
 b.ne .Ldp_guard_return
 ldr w9,[x19,#5164]
 cmp w9,#1
 b.ne .Ldp_guard_return
 ldr w9,[x19,#4888]
 cmn w9,#1
 b.ne .Ldp_guard_return
 ldr w9,[x19,#4904]
 cmp w9,#2562
 b.ne .Ldp_guard_return
 ldr w9,[x19,#4936]
 mov w10,#5136
 cmp w9,w10
 b.ne .Ldp_guard_return
 adr x9,.Ldp_fresh_arrays
 mov x10,#0
.Ldp_guard_fresh:
 ldr w11,[x9,x10,lsl#2]
 ldr x11,[x19,x11]
 cbnz x11,.Ldp_guard_return
 add x10,x10,#1
 cmp x10,#34
 b.lo .Ldp_guard_fresh
 ldr x9,[x19,#7640]
 cbz x9,.Ldp_guard_return
 tst x9,#3
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7648]
 cmp x10,#1
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7656]
 cmp x10,#4
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7664]
 mov x11,#0x101
 lsl x11,x11,#32
 cmp x10,x11
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7672]
 cmp x10,#4
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7680]
 cmp x10,#1
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7688]
 cmn x10,#1
 b.ne .Ldp_guard_return
 ldr x10,[x19,#7696]
 cmp x10,#2562
 b.ne .Ldp_guard_return
 add x9,x9,#8
 mov x10,#0
 mov x11,#0
 mov w12,#5136
.Ldp_guard_rows:
 ldr w13,[x9,x10,lsl#2]
 cmp w13,#1
 b.lt .Ldp_guard_return
 cmp w13,w12
 b.gt .Ldp_guard_return
 add x11,x11,x13
 add x10,x10,#1
 cmp x10,#2560
 b.lo .Ldp_guard_rows
 movz x12,#0xb400
 movk x12,#0x64,lsl#16
 cmp x11,x12
 b.ne .Ldp_guard_return
 mov w0,#0
.Ldp_guard_return:
 ret
/* Agree on the largest nonnegative status before another collective stage. */
.Ldp_agree:
 stp x29,x30,[sp,#-64]!
 str x18,[sp,#16]
 str w0,[sp,#32]
 str wzr,[sp,#36]
 str wzr,[sp,#40]
 add x0,sp,#32
 adr x1,.Ldp_max
 add x2,sp,#40
 mov x3,#0
 add x4,sp,#36
 mov x5,#0
 mov x6,#3
 mov x7,#0
 bl __mpl_allreduce_mod_MOD_mpl_allreduce_int_scalar
 ldr w9,[sp,#36]
 cbnz w9,.Ldp_abort
 ldr w0,[sp,#32]
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
/* Create a complete rank-one or rank-two GNU int32 descriptor. */
.Ldp_descriptor:
 stp xzr,xzr,[x0]
 stp xzr,xzr,[x0,#16]
 stp xzr,xzr,[x0,#32]
 stp xzr,xzr,[x0,#48]
 stp xzr,xzr,[x0,#64]
 str xzr,[x0,#80]
 str x1,[x0]
 mov x9,#-1
 mov x10,#0x101
 cbz x3,.Ldp_desc_rank1
 sub x9,x9,x2
 mov x10,#0x102
.Ldp_desc_rank1:
 str x9,[x0,#8]
 mov x9,#4
 str x9,[x0,#16]
 str x9,[x0,#32]
 lsl x10,x10,#32
 str x10,[x0,#24]
 mov x9,#1
 str x9,[x0,#40]
 str x9,[x0,#48]
 str x2,[x0,#56]
 cbz x3,.Ldp_desc_done
 str x2,[x0,#64]
 str x9,[x0,#72]
 str x3,[x0,#80]
.Ldp_desc_done:
 ret
.Ldp_abort:
 mov w0,#3
 bl fortran_mpi_abort
 brk #0
.p2align 4
.global md2asm_release_owned_distributed_transform_partition
.type md2asm_release_owned_distributed_transform_partition,%function
md2asm_release_owned_distributed_transform_partition:
 cbz x0,.Ldp_release_null
 tst x0,#7
 b.ne .Ldp_release_bad
 ldr x9,[x0,#8]
 ldr x10,.Ldp_cookie
 cmp x9,x10
 b.ne .Ldp_release_bad
 b .Ldp_destroy
.Ldp_release_null:
 mov w0,#0
 ret
.Ldp_release_bad:
 mov w0,#2
 ret
.size md2asm_release_owned_distributed_transform_partition,.-md2asm_release_owned_distributed_transform_partition
.Ldp_destroy:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 ldr x20,[x19]
 ldr w9,[x19,#16]
 tbz w9,#1,.Ldp_destroy_external
 mov x0,x19
 bl md2asm_release_owned_distributed_partition_arrays
 add x0,x19,#2368
 bl md2asm_release_stream_geometry_metadata
 ldr x0,[x19,#3248]
 bl free
.Ldp_destroy_external:
 str wzr,[sp,#48]
 mov x0,x20
 add x1,sp,#48
 bl md2asm_finish_external_transform_context
 str wzr,[x20,#5168]
 ldr w21,[sp,#48]
 ldr x0,[x19,#88]
 bl free
 mov x0,x19
 bl free
 cmp w21,#0
 mov w0,#3
 csel w0,wzr,w0,eq
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.section .rodata
.p2align 3
.Ldp_cookie: .quad 0x445054585f4f574e
.Ldp_max: .ascii "MAX"
.Ldp_nampar0: .ascii "NAMPAR0"
.Ldp_vectors: .ascii "NAM_DISTRIBUTED_VECTORS"
.p2align 2
.Ldp_setup_offsets:
 .word 288,292,36,72,64,8,12,16,40,44,48,-1,52,104,108,-1,96,76
.Ldp_scalar_indices:
 .byte 1,2,3,4,5,6,7,8,19,23,29,30,31,32,33,35,38,39,43,44
.p2align 2
.Ldp_array_table:
 .word 9,5,0
 .word 12,1,0
 .word 13,2,0
 .word 14,1,0
 .word 15,0,1280
 .word 16,0,1281
 .word 17,3,0
 .word 18,3,0
 .word 20,0,2560
 .word 21,3,0
 .word 22,3,0
 .word 24,6,0
 .word 25,6,0
 .word 26,1,0
 .word 27,1,0
 .word 34,0,2560
.section .note.GNU-stack,"",%progbits

.global md2asm_agree_owned_distributed_partition_status
.set md2asm_agree_owned_distributed_partition_status,.Ldp_agree
.section .rodata
.p2align 2
.Ldp_fresh_arrays:
 .word 5832,6024,5256,5320,5384,7248,5448,7312,5512,5576,5640,5704,5768,5896,6088,6176,6264,6328,6392,7080,6456,6520,6584,4968,5056,7392,6992,6904,5960,7144,6648,6712,6776,6840
.section .note.GNU-stack,"",%progbits

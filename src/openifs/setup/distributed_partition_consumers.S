/* Contract: skills/md2asm/references/openifs/setup/operational_distributed_partition.md.
 * Internal source-ordered SUMP owner, inquiry and packed-map consumers.
 * The allocator receives owner4096 in x0 and phase0..2 in x1.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_owned_distributed_partition_phase
.type md2asm_allocate_owned_distributed_partition_phase,%function
md2asm_allocate_owned_distributed_partition_phase:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 ldr x20,[x19]
 adr x21,.Ldpa_phase0
 mov x22,#26
 cbz x1,.Ldpa_table_ready
 adr x21,.Ldpa_phase1
 mov x22,#2
 cmp x1,#1
 b.eq .Ldpa_table_ready
 adr x21,.Ldpa_phase2
 mov x22,#6
.Ldpa_table_ready:
 mov x23,#0
.Ldpa_allocate:
 add x24,x21,x23,lsl#4
 ldp w9,w10,[x24]
 ldrsw x1,[x24,#8]
 mov x2,#0
 mov x3,#0
 cmp w10,#1
 b.ne .Ldpa_mode2
 ldr w2,[x19,#36]
 add x2,x2,#1
 b .Ldpa_dimensions
.Ldpa_mode2:
 cmp w10,#2
 b.ne .Ldpa_mode3
 ldr w2,[x19,#36]
 b .Ldpa_dimensions
.Ldpa_mode3:
 cmp w10,#3
 b.ne .Ldpa_mode4
 ldr w2,[x19,#32]
 b .Ldpa_dimensions
.Ldpa_mode4:
 cmp w10,#4
 b.ne .Ldpa_mode5
 mov x2,#1280
 b .Ldpa_dimensions
.Ldpa_mode5:
 cmp w10,#5
 b.ne .Ldpa_mode6
 ldr w2,[x19,#32]
 add x2,x2,#1
 b .Ldpa_dimensions
.Ldpa_mode6:
 cmp w10,#6
 b.ne .Ldpa_mode7
 ldr w2,[x19,#48]
 b .Ldpa_dimensions
.Ldpa_mode7:
 cmp w10,#7
 b.ne .Ldpa_mode8
 ldrsw x1,[x20,#4888]
 ldr w2,[x20,#4904]
 ldr w3,[x19,#48]
 add x2,x2,x3
 sub x2,x2,x1
 ldr w3,[x19,#52]
 b .Ldpa_dimensions
.Ldpa_mode8:
 cmp w10,#8
 b.ne .Ldpa_mode9
 mov x2,#2560
 b .Ldpa_dimensions
.Ldpa_mode9:
 cmp w10,#9
 b.ne .Ldpa_mode10
 mov x2,#137
 b .Ldpa_dimensions
.Ldpa_mode10:
 cmp w10,#10
 b.ne .Ldpa_mode11
 ldp w2,w3,[x19,#48]
 b .Ldpa_dimensions
.Ldpa_mode11:
 cmp w10,#11
 b.ne .Ldpa_mode12
 ldr w2,[x20,#5144]
 ldr w3,[x20,#5160]
 b .Ldpa_dimensions
.Ldpa_mode12:
 cmp w10,#12
 b.ne .Ldpa_mode13
 ldr w2,[x20,#5228]
 b .Ldpa_dimensions
.Ldpa_mode13:
 cmp w10,#13
 b.ne .Ldpa_mode14
 ldrsw x1,[x20,#4892]
 ldr w2,[x20,#4908]
 sub x2,x2,x1
 add x2,x2,#1
 b .Ldpa_dimensions
.Ldpa_mode14:
 cmp w10,#14
 b.ne .Ldpa_global_points
 ldr w2,[x20,#7376]
 b .Ldpa_dimensions
.Ldpa_global_points:
 ldr w2,[x20,#7388]
.Ldpa_dimensions:
 add x0,x20,x9
 ldr w4,[x24,#12]
 bl .Ldpa_create_descriptor
 cbnz w0,.Ldpa_return
 add x23,x23,#1
 cmp x23,x22
 b.lo .Ldpa_allocate
 mov w0,#0
.Ldpa_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp],#112
 ret
.size md2asm_allocate_owned_distributed_partition_phase,.-md2asm_allocate_owned_distributed_partition_phase
/* A source descriptor spans64 bytes for rank1,88 bytes for rank2. */
.Ldpa_create_descriptor:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 cmp x3,#0
 csinc x9,x3,xzr,ne
 mul x0,x2,x9
 lsl x0,x0,#2
 cmp x0,#1
 csinc x0,x0,xzr,hs
 bl malloc
 cbz x0,.Ldpa_descriptor_failure
 str x0,[x19]
 neg x9,x20
 mov x10,#1
 cbz x22,.Ldpa_descriptor_rank1
 sub x9,x9,x21
 mov x10,#2
.Ldpa_descriptor_rank1:
 str x9,[x19,#8]
 mov x9,#4
 str x9,[x19,#16]
 str x9,[x19,#32]
 orr x10,x10,x23,lsl#8
 lsl x10,x10,#32
 str x10,[x19,#24]
 mov x9,#1
 str x9,[x19,#40]
 str x20,[x19,#48]
 add x10,x20,x21
 sub x10,x10,#1
 str x10,[x19,#56]
 cbz x22,.Ldpa_descriptor_done
 str x21,[x19,#64]
 str x9,[x19,#72]
 str x22,[x19,#80]
.Ldpa_descriptor_done:
 mov w0,#0
 b .Ldpa_descriptor_return
.Ldpa_descriptor_failure:
 mov w0,#1
.Ldpa_descriptor_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp],#96
 ret
.p2align 4
.global md2asm_release_owned_distributed_partition_arrays
.type md2asm_release_owned_distributed_partition_arrays,%function
md2asm_release_owned_distributed_partition_arrays:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 ldr x19,[x0]
 adr x20,.Ldpa_all_offsets
 mov x21,#0
.Ldpa_release_loop:
 ldr w9,[x20,x21,lsl#2]
 ldr x0,[x19,x9]
 cbz x0,.Ldpa_release_next
 bl free
 ldr w9,[x20,x21,lsl#2]
 str xzr,[x19,x9]
.Ldpa_release_next:
 add x21,x21,#1
 cmp x21,#34
 b.lo .Ldpa_release_loop
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_owned_distributed_partition_arrays,.-md2asm_release_owned_distributed_partition_arrays
.section .rodata
.p2align 4
/* Rows: Geometry offset, shape mode, first lower bound, GNU type(1int/2logical). */
.Ldpa_phase0:
 .word 5832,1,1,1
 .word 6024,2,1,1
 .word 5256,3,1,1
 .word 5320,4,0,1
 .word 5384,3,1,1
 .word 7248,5,1,1
 .word 5448,4,1,1
 .word 7312,4,0,1
 .word 5512,3,1,1
 .word 5576,1,1,1
 .word 5640,1,1,1
 .word 5704,1,1,1
 .word 5768,4,0,1
 .word 5896,1,1,1
 .word 6088,7,-1,1
 .word 6176,7,-1,1
 .word 6264,6,1,1
 .word 6328,6,1,1
 .word 6392,8,1,1
 .word 7080,8,1,2
 .word 6456,6,1,1
 .word 6520,6,1,1
 .word 6584,9,1,1
 .word 4968,7,-1,1
 .word 5056,7,-1,1
 .word 7392,10,1,1
.Ldpa_phase1:
 .word 6992,11,1,1
 .word 6904,11,1,1
.Ldpa_phase2:
 .word 5960,12,1,1
 .word 7144,13,1,1
 .word 6648,14,1,1
 .word 6712,14,1,1
 .word 6776,15,1,1
 .word 6840,15,1,1
.Ldpa_all_offsets:
 .word 5832,6024,5256,5320,5384,7248,5448,7312,5512,5576,5640,5704,5768,5896,6088,6176,6264,6328,6392,7080,6456,6520,6584,4968,5056,7392,6992,6904,5960,7144,6648,6712,6776,6840
.section .note.GNU-stack,"",%progbits
.text
.p2align 4
.global md2asm_complete_owned_distributed_SUMP
.type md2asm_complete_owned_distributed_SUMP,%function
md2asm_complete_owned_distributed_SUMP:
 mov x9,#8192
 sub sp,sp,x9
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x20,x0
 ldr x19,[x20]
 /* Source IGLOBAL is a complete rectangular temporary. */
 movz x0,#0x8000
 movk x0,#0x322,lsl#16
 bl malloc
 str x0,[x20,#3248]
 cmp x0,#0
 cset w0,eq
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldpc_return
 ldr w9,[x20,#16]
 orr w9,w9,#2
 str w9,[x20,#16]
 mov x0,x20
 mov x1,#0
 bl md2asm_allocate_owned_distributed_partition_phase
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldpc_return
 ldr w21,[x20,#36]
 ldr w22,[x20,#32]
 ldr w23,[x20,#68]
 ldr w24,[x20,#64]
 /* NUMLL and NPSURF retain the source increasing-set order. */
 mov w9,#137
 udiv w10,w9,w21
 msub w11,w10,w21,w9
 ldr x12,[x19,#5832]
 ldr x13,[x19,#6024]
 mov w14,#1
.Ldpc_levels:
 cmp w14,w11
 cinc w15,w10,ls
 sub w16,w14,#1
 str w15,[x12,x16,lsl#2]
 str wzr,[x13,x16,lsl#2]
 add w14,w14,#1
 cmp w14,w21
 b.ls .Ldpc_levels
 str wzr,[x12,x21,lsl#2]
 sub w9,w23,#1
 ldr w10,[x12,x9,lsl#2]
 str w10,[x19,#5228]
 str w10,[x19,#5236]
 ldr w11,[x12]
 str w11,[x19,#5232]
 sub w11,w21,#1
 mov w14,#1
 str w14,[x13,x11,lsl#2]
 ldr w10,[x13,x9,lsl#2]
 str w10,[x19,#7208]
 /* Public inquiry results feed their typed Geometry destinations. */
 mov x0,x20
 mov x1,#1
 bl md2asm_query_owned_distributed_partition_phase
 mov x0,x20
 mov x1,#1
 bl md2asm_copy_owned_distributed_public_partition
 /* Source INI_SPEC_DIST produces NPROCM and this rank's whole-column waves. */
 add x9,sp,#128
 mov x10,#0
.Ldpc_spec_zero:
 str xzr,[x9,x10,lsl#3]
 add x10,x10,#1
 cmp x10,#15
 b.lo .Ldpc_spec_zero
 mov x9,#5208
 add x9,x19,x9
 stp x9,x9,[sp,#128]
 add x9,x20,#32
 str x9,[sp,#144]
 add x9,x20,#64
 str x9,[sp,#152]
 ldr x9,[x19,#5320]
 str x9,[sp,#176]
 add x9,sp,#512
 str x9,[sp,#184]
 add x9,sp,#2048
 str x9,[sp,#224]
 add x0,sp,#128
 bl md2asm_call_public_spectral_distribution
 sub w9,w24,#1
 add x10,sp,#512
 ldr w9,[x10,x9,lsl#2]
 str w9,[x19,#5216]
 mov x0,x20
 mov x1,#2
 bl md2asm_query_owned_distributed_partition_phase
 mov x0,x20
 mov x1,#2
 bl md2asm_copy_owned_distributed_public_partition
 mov x0,x20
 mov x1,#3
 bl md2asm_query_owned_distributed_partition_phase
 mov x0,x20
 mov x1,#3
 bl md2asm_copy_owned_distributed_public_partition
 /* Local latitude dimensions and the source active-row scans. */
 sub w9,w24,#1
 add x10,x20,#2104
 ldr x10,[x10]
 ldr w11,[x10,x9,lsl#2]
 str w11,[x19,#4876]
 mov w9,#1
 str w9,[x19,#4892]
 str w9,[x19,#4928]
 ldr w25,[x20,#932]
 ldr w26,[x20,#936]
 sub w9,w25,#1
 ldr x10,[x19,#6520]
 ldr w12,[x10,x9,lsl#2]
 ldr w13,[x19,#7232]
 sub w14,w12,w13
 str w14,[x19,#4908]
 ldr x10,[x19,#6456]
 ldr w15,[x10,x9,lsl#2]
 ldr w16,[x19,#4924]
 add w17,w15,w11
 sub w16,w16,w15
 add w16,w16,#1
 ldr w9,[x19,#4924]
 cmp w17,w9
 csel w11,w11,w16,le
 str w11,[x19,#4932]
 str w15,[x19,#7236]
 str w12,[x19,#7240]
 ldr x10,[x19,#6176]
 ldr x11,[x19,#6240]
 sub w9,w26,#1
 mul x9,x9,x11
 ldrsw x11,[x19,#7244]
 add x9,x9,x11
 ldrsw x11,[x19,#6224]
 sub x9,x9,x11
 add x10,x10,x9,lsl#2
 ldr w12,[x19,#7236]
 sub w12,w12,w13
 ldr w14,[x19,#4908]
.Ldpc_first_active:
 ldr w9,[x10,x12,lsl#2]
 cbnz w9,.Ldpc_last_active
 ldr w9,[x19,#7236]
 add w9,w9,#1
 str w9,[x19,#7236]
 add w12,w12,#1
 cmp w12,w14
 b.le .Ldpc_first_active
.Ldpc_last_active:
 ldr w9,[x10,x14,lsl#2]
 cbnz w9,.Ldpc_scalar_partition
 ldr w9,[x19,#7240]
 sub w9,w9,#1
 str w9,[x19,#7240]
 sub w14,w14,#1
 cmp w14,w12
 b.ge .Ldpc_last_active
.Ldpc_scalar_partition:
 ldr w9,[x19,#5200]
 udiv w10,w9,w21
 msub w11,w10,w21,w9
 ldr x12,[x19,#5576]
 mov w13,#1
 str w13,[x12]
 mov w14,#1
.Ldpc_scalar_sets:
 cmp w14,w11
 cinc w15,w10,ls
 add w13,w13,w15
 str w13,[x12,x14,lsl#2]
 add w14,w14,#1
 cmp w14,w21
 b.ls .Ldpc_scalar_sets
 /* The whole-column partition retries in original reverse wave order. */
 mov w27,#0
 ldr x25,[x19,#5704]
 ldr x26,[x19,#5640]
.Ldpc_column_retry:
 add w27,w27,#1
 mov w9,#-999
 mov w10,#0
.Ldpc_column_reset:
 str w9,[x25,x10,lsl#2]
 add w10,w10,#1
 cmp w10,w21
 b.ls .Ldpc_column_reset
 str xzr,[sp,#544]
 mov w9,#1
 str w9,[x25]
 ldr w9,[x19,#5212]
 add w10,w9,#1
 str w10,[x25,x21,lsl#2]
 ldr w10,[x19,#5200]
 mov w28,w21
 sub w11,w10,#1
 udiv w11,w11,w28
 add w11,w11,#1
 sub w11,w11,w27
 sub w9,w9,#1
 add x12,sp,#2048
 add x13,sp,#544
.Ldpc_column_waves:
 ldr w14,[x12,x9,lsl#2]
 mov w15,#1280
 sub w15,w15,w14
 lsl w15,w15,#1
 sub w16,w28,#1
 ldr w17,[x13,x16,lsl#2]
 cmp w17,w11
 b.lt .Ldpc_column_add
 add w14,w9,#2
 str w14,[x25,x16,lsl#2]
 sub w10,w10,w17
 sub w28,w28,#1
 cbz w28,.Ldpc_external_abort
 sub w11,w10,#1
 udiv w11,w11,w28
 add w11,w11,#1
 sub w11,w11,w27
 sub w16,w28,#1
 ldr w17,[x13,x16,lsl#2]
.Ldpc_column_add:
 add w17,w17,w15
 str w17,[x13,x16,lsl#2]
 subs w9,w9,#1
 b.pl .Ldpc_column_waves
 mov w9,#1
.Ldpc_column_balanced:
 cmp w9,w21
 b.hs .Ldpc_column_prefix
 ldr w10,[x25,x9,lsl#2]
 cmn w10,#999
 b.eq .Ldpc_column_retry
 add w9,w9,#1
 b .Ldpc_column_balanced
.Ldpc_column_prefix:
 mov w9,#1
 str w9,[x26]
 mov w10,#0
.Ldpc_column_prefix_loop:
 ldr w11,[x13,x10,lsl#2]
 add w9,w9,w11
 add w10,w10,#1
 str w9,[x26,x10,lsl#2]
 cmp w10,w21
 b.lo .Ldpc_column_prefix_loop
 ldr x12,[x19,#5768]
 mov w9,#-999
 mov x10,#0
.Ldpc_start_sentinel:
 str w9,[x12,x10,lsl#2]
 add x10,x10,#1
 cmp x10,#1280
 b.lo .Ldpc_start_sentinel
 sub w9,w23,#1
 ldr w10,[x25,x9,lsl#2]
 ldr w11,[x25,x23,lsl#2]
 sub w10,w10,#1
 sub w11,w11,#1
 mov w13,#1
 add x14,sp,#2048
.Ldpc_starts:
 cmp w10,w11
 b.hs .Ldpc_level_prefix
 ldr w15,[x14,x10,lsl#2]
 str w13,[x12,x15,lsl#2]
 mov w16,#1280
 sub w16,w16,w15
 add w13,w13,w16,lsl#1
 add w10,w10,#1
 b .Ldpc_starts
.Ldpc_level_prefix:
 ldr x12,[x19,#5896]
 ldr x13,[x19,#5832]
 mov w9,#1
 str w9,[x12]
 mov w10,#0
.Ldpc_level_prefix_loop:
 ldr w11,[x13,x10,lsl#2]
 add w9,w9,w11
 add w10,w10,#1
 str w9,[x12,x10,lsl#2]
 cmp w10,w21
 b.lo .Ldpc_level_prefix_loop
 str w21,[x19,#7228]
 ldr x12,[x19,#6584]
 mov w9,#0
 mov w10,#0
.Ldpc_level_set_outer:
 ldr w11,[x13,x9,lsl#2]
 add w9,w9,#1
 mov w14,#0
.Ldpc_level_set_inner:
 str w9,[x12,x10,lsl#2]
 add w10,w10,#1
 add w14,w14,#1
 cmp w14,w11
 b.lo .Ldpc_level_set_inner
 cmp w9,w21
 b.lo .Ldpc_level_set_outer
 /* Source INI_IOSTREAM's selected owned metadata effect. */
 ldr w9,[x20,#28]
 ldr w10,[x20,#24]
 str w9,[sp,#864]
 str w10,[sp,#868]
 add x0,x20,#2368
 mov x1,x19
 add x2,sp,#864
 bl md2asm_initialize_distributed_stream_geometry_metadata
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldpc_return
 ldr x12,[x19,#5576]
 sub w9,w23,#1
 ldr w10,[x12,x9,lsl#2]
 ldr w11,[x12,x23,lsl#2]
 sub w11,w11,w10
 str w11,[x19,#7212]
 ldr x12,[x19,#5640]
 ldr w10,[x12,x9,lsl#2]
 ldr w11,[x12,x23,lsl#2]
 sub w11,w11,w10
 str w11,[x19,#7216]
 str wzr,[x19,#7224]
 str wzr,[sp,#872]
 mov w9,#1
 str w9,[sp,#876]
 mov x0,x19
 add x1,sp,#872
 bl md2asm_initialize_operational_distributed_block_size
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldpc_return
 ldr w9,[x19,#5144]
 ldr w10,[x19,#7376]
 sub w11,w10,#1
 udiv w11,w11,w9
 add w11,w11,#1
 str w11,[x19,#5160]
 str w10,[x19,#7380]
 mov x0,x20
 mov x1,#1
 bl md2asm_allocate_owned_distributed_partition_phase
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldpc_return
 mov x0,x20
 mov x1,#2
 bl md2asm_allocate_owned_distributed_partition_phase
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldpc_return
 mov x0,x20
 bl md2asm_fill_owned_distributed_grid_maps
 ldr x0,[x20,#3248]
 bl free
 str xzr,[x20,#3248]
 mov w0,#0
.Ldpc_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 mov x9,#8192
 add sp,sp,x9
 ret
.Ldpc_external_abort:
 mov w0,#3
 bl fortran_mpi_abort
 brk #0
.size md2asm_complete_owned_distributed_SUMP,.-md2asm_complete_owned_distributed_SUMP
.text
.p2align 4
.global md2asm_copy_owned_distributed_public_partition
.type md2asm_copy_owned_distributed_public_partition,%function
md2asm_copy_owned_distributed_public_partition:
 mov x17,x1
 ldr x1,[x0]
 adr x2,.Ldpc_scalar_destinations
 mov x3,#4
 cmp x17,#1
 b.eq .Ldpc_copy_scalar
 cmp x17,#3
 b.eq .Ldpc_array_phase_select
 add x2,x2,#32
 mov x3,#5
.Ldpc_copy_scalar:
 ldp w4,w5,[x2],#8
 ldr w6,[x0,x4]
 str w6,[x1,x5]
 subs x3,x3,#1
 b.ne .Ldpc_copy_scalar
.Ldpc_array_phase_select:
 adr x2,.Ldpc_array_spectral
 mov x3,#5
 cmp x17,#1
 b.eq .Ldpc_copy_array
 adr x2,.Ldpc_array_grid
 mov x3,#9
 cmp x17,#2
 b.eq .Ldpc_copy_array
 adr x2,.Ldpc_array_fourier
 mov x3,#1
.Ldpc_copy_array:
 ldp w4,w5,[x2]
 ldr w6,[x2,#8]
 add x2,x2,#12
 mov x7,#88
 mul x7,x4,x7
 add x7,x7,#960
 add x7,x0,x7
 add x8,x1,x5
 ldr x9,[x7]
 ldr x10,[x8]
 ldr x11,[x7,#56]
 mov x12,#1
 ldr x13,[x7,#24]
 ubfx x13,x13,#32,#8
 cmp x13,#2
 b.ne .Ldpc_copy_shape
 ldr x12,[x7,#80]
.Ldpc_copy_shape:
 ldr x17,[x7,#56]
 cbz w6,.Ldpc_copy_strides
 cmp w6,#1
 b.ne .Ldpc_copy_mode2
 ldr w11,[x0,#32]
 b .Ldpc_copy_strides
.Ldpc_copy_mode2:
 cmp w6,#2
 b.ne .Ldpc_copy_mode3
 ldr w11,[x0,#32]
 add x11,x11,#1
 b .Ldpc_copy_strides
.Ldpc_copy_mode3:
 cmp w6,#3
 b.ne .Ldpc_copy_strides
 mov x11,#1280
.Ldpc_copy_strides:
 mov x13,x11
 cmp w6,#4
 b.ne .Ldpc_copy_columns
 ldr x13,[x8,#64]
 ldr x14,[x8,#48]
 mov x15,#1
 sub x14,x15,x14
 add x10,x10,x14,lsl#2
.Ldpc_copy_columns:
 mov x15,#0
.Ldpc_copy_column:
 mov x14,#0
.Ldpc_copy_values:
 ldr w16,[x9,x14,lsl#2]
 str w16,[x10,x14,lsl#2]
 add x14,x14,#1
 cmp x14,x11
 b.lo .Ldpc_copy_values
 add x9,x9,x17,lsl#2
 add x10,x10,x13,lsl#2
 add x15,x15,#1
 cmp x15,x12
 b.lo .Ldpc_copy_column
 subs x3,x3,#1
 b.ne .Ldpc_copy_array
 mov w0,#0
 ret
.size md2asm_copy_owned_distributed_public_partition,.-md2asm_copy_owned_distributed_public_partition
.section .rodata
.p2align 2
.Ldpc_scalar_destinations:
 .word 880,5196,884,5200,892,5204,896,5212,900,7376,904,7388,908,7384,912,7232,916,7244,940,5172
.Ldpc_array_destinations:
 .word 0,7392,0
 .word 1,5256,1
 .word 2,7248,2
 .word 3,5384,1
 .word 4,5448,0
 .word 5,7312,3
 .word 6,6456,0
 .word 7,6520,0
 .word 8,6392,0
 .word 9,6264,0
 .word 10,6328,0
 .word 11,6088,4
 .word 12,6176,4
 .word 14,5512,1
 .word 15,7080,0
.section .note.GNU-stack,"",%progbits
.text
.p2align 4
.global md2asm_fill_owned_distributed_grid_maps
.type md2asm_fill_owned_distributed_grid_maps,%function
md2asm_fill_owned_distributed_grid_maps:
 stp x29,x30,[sp,#-192]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x20,x0
 ldr x19,[x20]
 ldr x21,[x20,#3248]
 /* MYLEVS and MYLATS follow the source local order. */
 ldr w9,[x20,#68]
 sub w9,w9,#1
 ldr x10,[x19,#5896]
 ldr w11,[x10,x9,lsl#2]
 ldr w12,[x19,#5228]
 ldr x13,[x19,#5960]
 mov x14,#0
.Ldpm_levels:
 str w11,[x13,x14,lsl#2]
 add w11,w11,#1
 add x14,x14,#1
 cmp x14,x12
 b.lo .Ldpm_levels
 ldr w9,[x20,#932]
 sub w9,w9,#1
 ldr x10,[x19,#6456]
 ldr w11,[x10,x9,lsl#2]
 ldr w12,[x19,#4908]
 ldr x13,[x19,#7144]
 mov x14,#0
.Ldpm_latitudes:
 str w11,[x13,x14,lsl#2]
 add w11,w11,#1
 add x14,x14,#1
 cmp x14,x12
 b.lo .Ldpm_latitudes
 mov x0,x21
 mov x1,#0
 movz x2,#0x8000
 movk x2,#0x322,lsl#16
 bl memset
 ldr x22,[x19,#7640]
 add x22,x22,#8
 mov x24,#0
 mov x25,#0
 mov x26,x21
.Ldpm_global_rows:
 ldr w9,[x22,x25,lsl#2]
 mov x10,#0
.Ldpm_global_row_points:
 add x24,x24,#1
 str w24,[x26,x10,lsl#2]
 add x10,x10,#1
 cmp x10,x9
 b.lo .Ldpm_global_row_points
 mov x11,#20544
 add x26,x26,x11
 add x25,x25,#1
 cmp x25,#2560
 b.lo .Ldpm_global_rows
 /* Pack local physical-point identities and global latitude numbers. */
 ldr w9,[x20,#932]
 sub w9,w9,#1
 ldr x10,[x19,#6456]
 ldr w25,[x10,x9,lsl#2]
 ldr x10,[x19,#6520]
 ldr w26,[x10,x9,lsl#2]
 ldr x10,[x19,#6264]
 ldr w27,[x10,x9,lsl#2]
 ldr w9,[x20,#936]
 sub w9,w9,#1
 ldr x10,[x19,#6152]
 mul x9,x9,x10
 ldrsw x10,[x19,#6136]
 sub x9,x9,x10
 ldr x23,[x19,#6088]
 add x23,x23,x9,lsl#2
 ldr x24,[x19,#6176]
 add x24,x24,x9,lsl#2
 ldr x14,[x19,#6648]
 ldr x15,[x19,#6712]
 mov x28,#0
 mov w9,w25
.Ldpm_local_rows:
 add w10,w27,w9
 sub w10,w10,w25
 ldr w11,[x23,x10,lsl#2]
 ldr w12,[x24,x10,lsl#2]
 cbz w12,.Ldpm_local_next_row
 sub w10,w9,#1
 mov w13,#5136
 umull x10,w10,w13
 sub w13,w11,#1
 add x10,x10,x13
 add x13,x21,x10,lsl#2
.Ldpm_local_points:
 ldr w16,[x13],#4
 cbz w16,.Ldpm_abort
 str w16,[x14,x28,lsl#2]
 str w9,[x15,x28,lsl#2]
 add x28,x28,#1
 subs w12,w12,#1
 b.ne .Ldpm_local_points
.Ldpm_local_next_row:
 add w9,w9,#1
 cmp w9,w26
 b.le .Ldpm_local_rows
 ldr w9,[x19,#7376]
 cmp x28,x9
 b.ne .Ldpm_abort
 /* Every rank retains the source complete global owner/reverse maps. */
 ldr x0,[x19,#6776]
 mov x1,#0
 ldr w2,[x19,#7388]
 lsl x2,x2,#2
 bl memset
 ldr x14,[x19,#6776]
 ldr x15,[x19,#6840]
 mov x23,#0
.Ldpm_region_outer:
 ldr x9,[x19,#6456]
 ldr w10,[x9,x23,lsl#2]
 str w10,[sp,#128]
 ldr x9,[x19,#6520]
 ldr w26,[x9,x23,lsl#2]
 ldr x9,[x19,#6264]
 ldr w10,[x9,x23,lsl#2]
 str w10,[sp,#136]
 mov x24,#0
.Ldpm_region_inner:
 ldr w9,[x20,#52]
 mul x9,x23,x9
 add x9,x9,x24
 add x10,x20,#3264
 ldr w28,[x10,x9,lsl#2]
 cbz w28,.Ldpm_abort
 ldr x9,[x19,#6152]
 mul x9,x24,x9
 ldrsw x10,[x19,#6136]
 sub x9,x9,x10
 ldr x22,[x19,#6088]
 add x22,x22,x9,lsl#2
 ldr x10,[x19,#6176]
 add x10,x10,x9,lsl#2
 str x10,[sp,#120]
 ldr w25,[sp,#128]
 mov x27,#0
.Ldpm_owner_rows:
 ldr w9,[sp,#136]
 add w9,w9,w25
 ldr w10,[sp,#128]
 sub w9,w9,w10
 ldr w11,[x22,x9,lsl#2]
 ldr x10,[sp,#120]
 ldr w12,[x10,x9,lsl#2]
 cbz w12,.Ldpm_owner_next_row
 sub w9,w25,#1
 mov w10,#5136
 umull x9,w9,w10
 sub w10,w11,#1
 add x9,x9,x10
 add x13,x21,x9,lsl#2
.Ldpm_owner_points:
 ldr w16,[x13],#4
 cbz w16,.Ldpm_abort
 sub w17,w16,#1
 str w28,[x14,x17,lsl#2]
 add x27,x27,#1
 str w27,[x15,x17,lsl#2]
 subs w12,w12,#1
 b.ne .Ldpm_owner_points
.Ldpm_owner_next_row:
 add w25,w25,#1
 cmp w25,w26
 b.le .Ldpm_owner_rows
 add x24,x24,#1
 add x9,x20,#464
 ldr w10,[x9,x23,lsl#2]
 cmp x24,x10
 b.lo .Ldpm_region_inner
 add x23,x23,#1
 ldr w9,[x20,#48]
 cmp x23,x9
 b.lo .Ldpm_region_outer
 /* Source padding sentinels precede the blocked physical-point stores. */
 ldr x14,[x19,#6904]
 ldr x15,[x19,#6992]
 ldr w9,[x19,#5144]
 ldr w10,[x19,#5160]
 umull x11,w9,w10
 mov w12,#0x7961
 movk w12,#0xfffe,lsl#16
 mov x13,#0
.Ldpm_block_sentinels:
 str w12,[x14,x13,lsl#2]
 str w12,[x15,x13,lsl#2]
 add x13,x13,#1
 cmp x13,x11
 b.lo .Ldpm_block_sentinels
 ldr w9,[x20,#936]
 sub w9,w9,#1
 ldr x10,[x19,#6152]
 mul x9,x9,x10
 ldrsw x10,[x19,#6136]
 sub x9,x9,x10
 ldr x23,[x19,#6088]
 add x23,x23,x9,lsl#2
 ldr x24,[x19,#6176]
 add x24,x24,x9,lsl#2
 ldr x25,[x19,#7144]
 ldr w26,[x19,#4908]
 ldr w27,[x19,#7244]
 mov x28,#0
 mov w9,#1
.Ldpm_block_rows:
 add w10,w27,w9
 ldr w11,[x23,x10,lsl#2]
 ldr w12,[x24,x10,lsl#2]
 cbz w12,.Ldpm_block_next_row
 sub w10,w9,#1
 ldr w10,[x25,x10,lsl#2]
.Ldpm_block_points:
 str w10,[x14,x28,lsl#2]
 str w11,[x15,x28,lsl#2]
 add w11,w11,#1
 add x28,x28,#1
 subs w12,w12,#1
 b.ne .Ldpm_block_points
.Ldpm_block_next_row:
 add w9,w9,#1
 cmp w9,w26
 b.le .Ldpm_block_rows
 ldr w9,[x19,#7376]
 cmp x28,x9
 b.ne .Ldpm_abort
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp],#192
 ret
.Ldpm_abort:
 mov w0,#3
 bl fortran_mpi_abort
 brk #0
.size md2asm_fill_owned_distributed_grid_maps,.-md2asm_fill_owned_distributed_grid_maps

.section .rodata
.p2align 2
.Ldpc_array_spectral:
 .word 1,5256,1,2,7248,2,3,5384,1,4,5448,0,5,7312,3
.Ldpc_array_grid:
 .word 0,7392,0,6,6456,0,7,6520,0,8,6392,0,9,6264,0,10,6328,0,11,6088,4,12,6176,4,15,7080,0
.Ldpc_array_fourier:
 .word 14,5512,1
.text
.p2align 4
.global md2asm_query_owned_distributed_partition_phase
.type md2asm_query_owned_distributed_partition_phase,%function
md2asm_query_owned_distributed_partition_phase:
 sub sp,sp,#448
 stp x29,x30,[sp,#384]
 stp x19,x18,[sp,#400]
 add x29,sp,#384
 mov x19,x0
 mov x9,#0
.Ldpc_query_clear:
 str xzr,[sp,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#47
 b.lo .Ldpc_query_clear
 adr x9,.Ldpc_query_spectral
 cmp x1,#1
 b.eq .Ldpc_query_select_done
 adr x9,.Ldpc_query_grid
 cmp x1,#2
 b.eq .Ldpc_query_select_done
 adr x9,.Ldpc_query_fourier
.Ldpc_query_select_done:
 add x10,x19,#496
.Ldpc_query_pack:
 ldrb w11,[x9],#1
 cmp w11,#255
 b.eq .Ldpc_query_call
 ldr x12,[x10,x11,lsl#3]
 str x12,[sp,x11,lsl#3]
 b .Ldpc_query_pack
.Ldpc_query_call:
 mov x0,sp
 bl md2asm_call_public_transform_inquiry
 ldp x29,x30,[sp,#384]
 ldp x19,x18,[sp,#400]
 add sp,sp,#448
 ret
.size md2asm_query_owned_distributed_partition_phase,.-md2asm_query_owned_distributed_partition_phase
.section .rodata
.Ldpc_query_spectral:
 .byte 0,1,2,3,4,5,12,13,14,15,16,35,38,39,43,44,255
.Ldpc_query_grid:
 .byte 0,6,7,8,9,17,18,19,20,21,22,23,24,25,29,30,31,32,33,34,255
.Ldpc_query_fourier:
 .byte 0,26,27,255
.section .note.GNU-stack,"",%progbits

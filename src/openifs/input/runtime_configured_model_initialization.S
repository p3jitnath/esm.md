/* Contract skills/md2asm/references/openifs/input/runtime_configured_model_initialization.md.
 * Seven register arguments. Runtime sizes come from live owned records.
 * Public libraries provide MPI, file formats, mathematics and transforms only. */
.arch armv8.2-a
.text
.macro INITIAL_PHASE name,code,flag=0,fatal=0
 bl \name
 .if \fatal
  cbz w0,.Linitial_child_ok\@
  add w0,w0,#\code
  bl fortran_mpi_abort
  brk #0
.Linitial_child_ok\@:
 .endif
 .if \flag
  cbnz w0,.Linitial_no_flag\@
  ldr x9,[sp,#112]
  ldr x10,[x9,#8]
  orr x10,x10,#\flag
  str x10,[x9,#8]
.Linitial_no_flag\@:
 .endif
 cbz w0,.Linitial_zero_status\@
 add w0,w0,#\code
.Linitial_zero_status\@:
 bl md2asm_agree_owned_distributed_partition_status
 mov w28,w0
 cbnz w0,.Linitial_model_failed
.endm
.p2align 4
.global md2asm_create_runtime_configured_initialized_operational_model
.type md2asm_create_runtime_configured_initialized_operational_model,%function
md2asm_create_runtime_configured_initialized_operational_model:
 sub sp,sp,#256
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,xzr
 mov x27,xzr
 str xzr,[sp,#112]
 cbz x19,.Linitial_admission_bad
 cbz x20,.Linitial_admission_bad
 cbz x21,.Linitial_admission_bad
 cbz x22,.Linitial_admission_bad
 cbz x23,.Linitial_admission_bad
 cbz x24,.Linitial_admission_bad
 cbz x25,.Linitial_admission_bad
 orr x9,x19,x20
 orr x9,x9,x24
 orr x9,x9,x25
 tst x9,#7
 b.ne .Linitial_admission_bad
 ldr x9,[x25]
 cbnz x9,.Linitial_admission_bad
 mrs x9,fpcr
 cbnz x9,.Linitial_admission_bad
 mov x9,#9968
 adds x9,x19,x9
 b.cs .Linitial_admission_bad
 adds x9,x20,#1872
 b.cs .Linitial_admission_bad
 adds x9,x24,#120
 b.cs .Linitial_admission_bad
 adds x9,x25,#8
 b.cs .Linitial_admission_bad
 ldr x9,[x19]
 movz x10,#0x5431
 movk x10,#0x5055,lsl#16
 movk x10,#0x494e,lsl#32
 movk x10,#0x4f50,lsl#48
 cmp x9,x10
 b.ne .Linitial_admission_bad
 ldr x27,[x19,#8]
 cbz x27,.Linitial_admission_bad
 ldr x9,[x20]
 cmp x9,x27
 b.ne .Linitial_admission_bad
 ldr x9,[x20,#8]
 cbz x9,.Linitial_admission_bad
 mov x0,x27
 bl md2asm_operational_initial_norm_result_bytes
 str x0,[sp,#192]
 cbz x0,.Linitial_admission_bad
 mov w0,#0
 b .Linitial_admission_agree
.Linitial_admission_bad:
 mov w0,#2
.Linitial_admission_agree:
 bl md2asm_agree_owned_distributed_partition_status
 mov w28,w0
 cbnz w0,.Linitial_model_return
 mov x0,#1
 mov x1,#64
 bl calloc
 str x0,[sp,#112]
 cbz x0,.Linitial_owner_allocation_failed
 str x27,[x0,#16]
 movz x9,#0x4949
 movk x9,#0x4e49,lsl#16
 movk x9,#0x4f57,lsl#32
 movk x9,#0x4e31,lsl#48
 str x9,[x0,#56]
 mov w0,#0
 b .Linitial_owner_allocation_agree
.Linitial_owner_allocation_failed:
 mov w0,#1
.Linitial_owner_allocation_agree:
 bl md2asm_agree_owned_distributed_partition_status
 mov w28,w0
 cbnz w0,.Linitial_model_failed
 mov x0,#1
 ldr x1,[sp,#192]
 bl calloc
 ldr x9,[sp,#112]
 str x0,[x9,#24]
 cmp x0,#0
 cset w0,eq
 bl md2asm_agree_owned_distributed_partition_status
 mov w28,w0
 cbnz w0,.Linitial_model_failed
 mov x0,x27
 mov x1,x24
 ldr x2,[sp,#112]
 INITIAL_PHASE md2asm_create_distributed_operational_model_storage,10
 ldr x9,[sp,#112]
 ldr x26,[x9]
 mov x0,x26
 add x1,x19,#120
 ldp x2,x3,[x19,#16]
 ldr x4,[x20,#8]
 INITIAL_PHASE md2asm_attach_distributed_operational_model_configuration,20
 ldp x0,x1,[x19,#16]
 mov x2,x27
 ldr x3,[x26,#16]
 ldr x4,[x26,#48]
 INITIAL_PHASE md2asm_initialize_operational_lagrangian_controls,25
 ldp x0,x1,[x19,#16]
 add x2,sp,#176
 mov x3,#16
 INITIAL_PHASE md2asm_initialize_operational_interpolation_policy,26
 mov x0,x27
 mov x1,#20400
 ldr x2,[x26,#16]
 mov x3,#(4275088&65535)
 movk x3,#(4275088>>16),lsl#16
 ldr x4,[x26,#56]
 mov x5,#4096
 ldr x6,[x26,#48]
 add x7,sp,#176
 INITIAL_PHASE md2asm_complete_runtime_operational_interpolation_halo,27,1
 mov x0,x26
 INITIAL_PHASE md2asm_begin_distributed_operational_model_work_storage,30
 mov x0,x26
 INITIAL_PHASE md2asm_advance_distributed_operational_model_work_storage,40
 mov x0,x26
 INITIAL_PHASE md2asm_advance_distributed_operational_model_work_storage,50
 mov x0,x26
 INITIAL_PHASE md2asm_allocate_distributed_operational_model_grid_motion,60
 mov x0,x26
 adr x1,.Linitial_spectral_ids
 INITIAL_PHASE md2asm_initialize_distributed_operational_model_spectral,70
 mov x0,x21
 mov x1,x26
 INITIAL_PHASE md2asm_load_distributed_operational_model_spectral_state,80
 mov x0,x27
 mov x1,#20400
 ldr x9,[x26,#24]
 mov x10,#22736
 add x9,x9,x10
 ldr x2,[x9,#2464]
 ldr x4,[x26,#48]
 mov x10,#2464
 add x10,x9,x10
 ldp x11,x12,[x10,#48]
 sub x3,x12,x11
 add x3,x3,#1
 lsl x3,x3,#3
 cbnz x3,.Linitial_terrain_extent_ready
 mov x3,#1
.Linitial_terrain_extent_ready:
 mov x9,#(67600&65535)
 movk x9,#(67600>>16),lsl#16
 add x4,x4,x9
 mov x5,#16
 INITIAL_PHASE md2asm_initialize_distributed_operational_orography,85,2,1
 mov x0,x22
 mov x1,x26
 INITIAL_PHASE md2asm_initialize_distributed_operational_model_surface,90
 /* Input decoding is local and may use a50GB temporary. Bound it to one rank. */
 mov w9,#1
 str w9,[sp,#160]
.Linitial_upper_visit:
 ldr x9,[x26,#56]
 ldr w10,[x9,#28]
 ldr w9,[sp,#160]
 cmp w9,w10
 b.ne .Linitial_upper_other_rank
 mov x0,x23
 mov x1,x26
 bl md2asm_load_distributed_operational_model_upper_air_state
 cbz w0,.Linitial_upper_agree
 add w0,w0,#100
 b .Linitial_upper_agree
.Linitial_upper_other_rank:
 mov w0,#0
.Linitial_upper_agree:
 bl md2asm_agree_owned_distributed_partition_status
 mov w28,w0
 cbnz w0,.Linitial_model_failed
 ldr w9,[sp,#160]
 add w9,w9,#1
 str w9,[sp,#160]
 ldr x10,[x26,#56]
 ldr w10,[x10,#24]
 cmp w9,w10
 b.ls .Linitial_upper_visit
 mov x0,x27
 ldr x1,[x26,#24]
 add x1,x1,#3416
 ldr x2,[x26,#16]
 add x2,x2,#192
 ldr x3,[x26,#24]
 mov x9,#22736
 add x3,x3,x9
 ldr x4,[x26,#48]
 add x4,x4,#64
 INITIAL_PHASE md2asm_initialize_operational_spectral_virtual_temperature,105,0,1
 mov x0,x26
 INITIAL_PHASE md2asm_advance_distributed_operational_model_work_storage,110
 stp xzr,xzr,[sp,#128]
 ldr x9,[x26,#56]
 ldr w9,[x9,#24]
 str w9,[sp,#144]
 str wzr,[sp,#148]
 mov x0,x27
 ldr x1,[x26,#16]
 ldr x2,[x26,#24]
 mov x9,#22736
 add x2,x2,x9
 ldr x3,[x26,#56]
 add x4,sp,#128
 ldr x5,[sp,#112]
 ldr x6,[x5,#24]
 add x5,x5,#32
 INITIAL_PHASE md2asm_compute_operational_distributed_spectral_norms,120
 ldr x9,[sp,#112]
 str x9,[x25]
 str xzr,[sp,#112]
 mov w28,#0
 b .Linitial_model_return
.Linitial_model_failed:
 add x0,sp,#112
 bl md2asm_release_initialized_operational_model
.Linitial_model_return:
 mov w0,w28
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.size md2asm_create_runtime_configured_initialized_operational_model,.-md2asm_create_runtime_configured_initialized_operational_model
.p2align 3
.Linitial_spectral_ids: .word 138,155,130,152,129

.p2align 4
.global md2asm_operational_initial_norm_result_bytes
.type md2asm_operational_initial_norm_result_bytes,%function
md2asm_operational_initial_norm_result_bytes:
 cbz x0,.Lnorm_bytes_bad
 tst x0,#7
 b.ne .Lnorm_bytes_bad
 mov x9,#20400
 adds x9,x0,x9
 b.cs .Lnorm_bytes_bad
 ldr w10,[x0,#5224]
 sub w11,w10,#1
 cmp w11,#4095
 b.hi .Lnorm_bytes_bad
 ldr w9,[x0,#5172]
 mov w11,#65534
 cmp w9,w11
 b.hi .Lnorm_bytes_bad
 add x9,x9,#2
 mul x9,x9,x10
 lsl x0,x9,#5
 add x0,x0,#48
 ret
.Lnorm_bytes_bad:
 mov x0,#0
 ret
.size md2asm_operational_initial_norm_result_bytes,.-md2asm_operational_initial_norm_result_bytes
.section .note.GNU-stack,"",%progbits

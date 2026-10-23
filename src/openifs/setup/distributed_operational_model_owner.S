/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md. */
/* Stable operational MODEL/FIELDS and source-ordered storage ownership.
 * Contract: skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md.
 * No temporary pointer-bearing state or original OpenIFS production callable.
 * All entries preserve x18, saved registers and FPCR. Pure storage calls keep their
 * accepted status rules; file-loading and surface calls retain natural FPSR/errno. */
.arch armv8.2-a
.text
.macro C_ENTER bytes
 sub sp,sp,#\bytes
 stp x29,x30,[sp]
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
.endm
.macro C_LEAVE bytes
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#\bytes
 ret
.endm
.macro C_ENV
 mrs x26,fpcr
 mrs x27,fpsr
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
.endm
.macro C_RESTORE
 str w25,[x24]
 msr fpcr,x26
 msr fpsr,x27
 mov w0,w28
.endm
.p2align 4
.global md2asm_create_distributed_operational_model_storage
.type md2asm_create_distributed_operational_model_storage,%function
md2asm_create_distributed_operational_model_storage:
 C_ENTER 128
 mov x19,x0
 mov x20,x1
 mov x21,x2
 cbz x19,.Lcontainer_create_bad
 cbz x20,.Lcontainer_create_bad
 cbz x21,.Lcontainer_create_bad
 orr x9,x19,x20
 orr x9,x9,x21
 tst x9,#7
 b.ne .Lcontainer_create_bad
 ldr x9,[x21]
 cbnz x9,.Lcontainer_create_bad
 mov x9,#20400
 adds x10,x19,x9
 b.cs .Lcontainer_create_bad
 adds x11,x20,#120
 b.cs .Lcontainer_create_bad
 adds x12,x21,#8
 b.cs .Lcontainer_create_bad
 cmp x19,x11
 b.hs .Lcontainer_create_pair2
 cmp x20,x10
 b.lo .Lcontainer_create_bad
.Lcontainer_create_pair2:
 cmp x19,x12
 b.hs .Lcontainer_create_pair3
 cmp x21,x10
 b.lo .Lcontainer_create_bad
.Lcontainer_create_pair3:
 cmp x20,x12
 b.hs .Lcontainer_alias_preflight
 cmp x21,x11
 b.lo .Lcontainer_create_bad
.Lcontainer_alias_preflight:
 mov x13,#0
.Lcontainer_alias_argument:
 ldr x14,[x20,x13,lsl#3]
 cbz x14,.Lcontainer_create_bad
 tst x14,#7
 b.ne .Lcontainer_create_bad
 adds x15,x14,#8
 b.cs .Lcontainer_create_bad
 ldr x9,[x14]
 cbnz x9,.Lcontainer_create_bad
 cmp x14,x10
 b.hs .Lcontainer_alias_table_span
 cmp x19,x15
 b.lo .Lcontainer_create_bad
.Lcontainer_alias_table_span:
 cmp x14,x11
 b.hs .Lcontainer_alias_output_span
 cmp x20,x15
 b.lo .Lcontainer_create_bad
.Lcontainer_alias_output_span:
 cmp x14,x12
 b.hs .Lcontainer_alias_argument_next
 cmp x21,x15
 b.lo .Lcontainer_create_bad
.Lcontainer_alias_argument_next:
 add x13,x13,#1
 cmp x13,#15
 b.lo .Lcontainer_alias_argument
 mrs x9,fpcr
 cbnz x9,.Lcontainer_create_bad
 C_ENV
 mov x0,#1
 mov x1,#800
 bl calloc
 cbz x0,.Lcontainer_create_nomemory
 mov x22,x0
 str x19,[x22,#8]
 mov x9,#0
 add x10,x22,#64
.Lcontainer_copy_alias_table:
 ldr x11,[x20,x9,lsl#3]
 str x11,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#15
 b.lo .Lcontainer_copy_alias_table
 mov x0,x19
 add x1,x22,#64
 add x2,x22,#16
 bl md2asm_create_selected_model_storage
 cbnz w0,.Lcontainer_create_unwind
 ldr x0,[x22,#16]
 add x1,x22,#24
 bl md2asm_create_initial_fields_storage
 cbnz w0,.Lcontainer_create_model_unwind
 adr x9,.Lcontainer_magic
 ldr x9,[x9]
 str x9,[x22]
 str x22,[x21]
 mov w28,#0
 b .Lcontainer_create_env
.Lcontainer_create_model_unwind:
 mov w28,w0
 add x0,x22,#16
 add x1,x22,#64
 bl md2asm_release_selected_model_storage
 b .Lcontainer_create_free
.Lcontainer_create_unwind:
 mov w28,w0
.Lcontainer_create_free:
 mov x0,x22
 bl free
 b .Lcontainer_create_env
.Lcontainer_create_nomemory:
 mov w28,#1
.Lcontainer_create_env:
 C_RESTORE
 b .Lcontainer_create_exit
.Lcontainer_create_bad:
 mov w0,#2
.Lcontainer_create_exit:
 C_LEAVE 128
.size md2asm_create_distributed_operational_model_storage,.-md2asm_create_distributed_operational_model_storage
.p2align 4
.global md2asm_begin_distributed_operational_model_work_storage
.type md2asm_begin_distributed_operational_model_work_storage,%function
md2asm_begin_distributed_operational_model_work_storage:
 C_ENTER 128
 mov x22,x0
 bl .Lcontainer_validate
 cbnz w0,.Lcontainer_begin_exit
 ldr x9,[x22,#48]
 cbz x9,.Lcontainer_begin_bad
 ldr x10,[x22,#56]
 cbz x10,.Lcontainer_begin_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lcontainer_begin_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lcontainer_begin_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lcontainer_begin_bad
 ldr x9,[x22,#32]
 cbnz x9,.Lcontainer_begin_bad
 ldr x9,[x22,#40]
 cbnz x9,.Lcontainer_begin_bad
 mov x0,x19
 mov x1,x20
 mov x2,x21
 add x3,x22,#32
 bl md2asm_create_distributed_forecast_work_storage
 b .Lcontainer_begin_exit
.Lcontainer_begin_bad:
 mov w0,#2
.Lcontainer_begin_exit:
 C_LEAVE 128
.size md2asm_begin_distributed_operational_model_work_storage,.-md2asm_begin_distributed_operational_model_work_storage
.p2align 4
.global md2asm_advance_distributed_operational_model_work_storage
.type md2asm_advance_distributed_operational_model_work_storage,%function
md2asm_advance_distributed_operational_model_work_storage:
 C_ENTER 128
 mov x22,x0
 bl .Lcontainer_validate
 cbnz w0,.Lcontainer_advance_exit
 ldr x9,[x22,#48]
 cbz x9,.Lcontainer_advance_bad
 ldr x10,[x22,#56]
 cbz x10,.Lcontainer_advance_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lcontainer_advance_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lcontainer_advance_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lcontainer_advance_bad
 ldr x0,[x22,#32]
 cbz x0,.Lcontainer_advance_bad
 ldr x9,[x0,#32]
 cmp x9,#3
 b.ne .Lcontainer_advance_call
 ldr x9,[x22,#40]
 cmp x9,#1
 b.ne .Lcontainer_advance_bad
.Lcontainer_advance_call:
 bl md2asm_advance_distributed_forecast_work_storage
 b .Lcontainer_advance_exit
.Lcontainer_advance_bad:
 mov w0,#2
.Lcontainer_advance_exit:
 C_LEAVE 128
.size md2asm_advance_distributed_operational_model_work_storage,.-md2asm_advance_distributed_operational_model_work_storage
.p2align 4
.global md2asm_load_distributed_operational_model_upper_air_state
.type md2asm_load_distributed_operational_model_upper_air_state,%function
md2asm_load_distributed_operational_model_upper_air_state:
 C_ENTER 176
 mov x23,x0
 mov x22,x1
 bl .Lcontainer_validate
 cbnz w0,.Lcontainer_load_exit
 ldr x9,[x22,#48]
 cbz x9,.Lcontainer_load_bad
 ldr x10,[x22,#56]
 cbz x10,.Lcontainer_load_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lcontainer_load_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lcontainer_load_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lcontainer_load_bad
 cbz x23,.Lcontainer_load_bad
 ldr x9,[x22,#40]
 cbnz x9,.Lcontainer_load_bad
 ldr x9,[x22,#32]
 cbz x9,.Lcontainer_load_bad
 ldr x9,[x9,#32]
 cmp x9,#3
 b.ne .Lcontainer_load_bad
 mrs x9,fpcr
 cbnz x9,.Lcontainer_load_bad
 mov x9,x23
 mov x10,#4096
.Lcontainer_load_path:
 ldrb w11,[x9]
 cbz w11,.Lcontainer_load_path_end
 adds x9,x9,#1
 b.cs .Lcontainer_load_bad
 subs x10,x10,#1
 b.ne .Lcontainer_load_path
 b .Lcontainer_load_bad
.Lcontainer_load_path_end:
 adds x12,x9,#1
 b.cs .Lcontainer_load_bad
 /* Require the path outside all mutable owned records. */
 mov x10,x22
 mov x11,#800
 bl .Lcontainer_path_clear
 cbnz w0,.Lcontainer_load_bad
 mov x10,x20
 mov x11,#(4275088 & 65535)
 movk x11,#(4275088 >> 16),lsl#16
 bl .Lcontainer_path_clear
 cbnz w0,.Lcontainer_load_bad
 mov x10,x21
 mov x11,#(529288 & 65535)
 movk x11,#(529288 >> 16),lsl#16
 bl .Lcontainer_path_clear
 cbnz w0,.Lcontainer_load_bad
 C_ENV
 add x0,x21,#3416
 adr x1,.Lcontainer_tgfl_shape
 add x2,x20,#192
 bl md2asm_initialize_distributed_gridpoint_field
 cbnz w0,.Lcontainer_load_raw_error
 add x9,x21,#3416
 ldr x10,[x9]
 /* Positive-zero only the15 padding rows of the959 copied planes. */
 movz x12,#39680
 movk x12,#51725,lsl#16
 movk x12,#3,lsl#32
 add x13,x10,x12
 mov w14,#959
.Lcontainer_padding_level:
 stp xzr,xzr,[x13]
 stp xzr,xzr,[x13,#16]
 stp xzr,xzr,[x13,#32]
 stp xzr,xzr,[x13,#48]
 stp xzr,xzr,[x13,#64]
 stp xzr,xzr,[x13,#80]
 stp xzr,xzr,[x13,#96]
 str xzr,[x13,#112]
 add x13,x13,#136
 subs w14,w14,#1
 b.ne .Lcontainer_padding_level
 mov x9,#7376
 ldr w9,[x19,x9]
 mov x11,#6648
 ldr x11,[x19,x11]
 stp x9,x11,[sp,#112]
 lsl x11,x9,#2
 mov x12,#5160
 ldr w12,[x19,x12]
 stp x11,x12,[sp,#128]
 mov x0,x23
 add x1,sp,#112
 mov x2,x10
 movz x3,#(167688&65535)
 movk x3,#(167688>>16),lsl#16
 mul x3,x12,x3
 bl md2asm_load_partitioned_operational_upper_air_state
 cbnz w0,.Lcontainer_load_file_error
 add x9,x21,#3416
 ldr x10,[x9]
 str x10,[x22,#192]
 ldr x10,[x9,#272]
 str x10,[x22,#200]
 ldr x10,[x9,#408]
 str x10,[x22,#208]
 ldr x10,[x9,#544]
 str x10,[x22,#216]
 mov x9,#1
 str x9,[x22,#40]
 mov w28,#0
 b .Lcontainer_load_env
.Lcontainer_load_file_error:
 add w28,w0,#32
 add x0,x21,#3416
 bl md2asm_release_gridpoint_field
 b .Lcontainer_load_clear
.Lcontainer_load_raw_error:
 add w28,w0,#16
.Lcontainer_load_clear:
 add x9,x21,#3416
 mov x10,#1096
.Lcontainer_failed_record:
 str xzr,[x9],#8
 subs x10,x10,#8
 b.ne .Lcontainer_failed_record
.Lcontainer_load_env:
 msr fpcr,x26
 mov w0,w28
 b .Lcontainer_load_exit
.Lcontainer_load_bad:
 mov w0,#2
.Lcontainer_load_exit:
 C_LEAVE 176
.size md2asm_load_distributed_operational_model_upper_air_state,.-md2asm_load_distributed_operational_model_upper_air_state
.p2align 4
.global md2asm_release_distributed_operational_model_storage
.type md2asm_release_distributed_operational_model_storage,%function
md2asm_release_distributed_operational_model_storage:
 cbz x0,.Lcontainer_null
 C_ENTER 128
 mov x22,x0
 bl .Lcontainer_validate
 cbnz w0,.Lcontainer_release_exit
 C_ENV
 ldr x0,[x22,#32]
 cbz x0,.Lcontainer_release_main
 bl md2asm_release_distributed_forecast_work_storage
 mov w28,w0
 cbnz w0,.Lcontainer_release_env
 str xzr,[x22,#32]
.Lcontainer_release_main:
 ldr x9,[x22,#224]
 cbz x9,.Lcontainer_release_surface
 add x0,x21,#1856
 bl md2asm_release_grid_motion_fields
 str xzr,[x22,#224]
 str xzr,[x22,#720]
 str xzr,[x22,#728]
.Lcontainer_release_surface:
 ldr x9,[x22,#232]
 cbz x9,.Lcontainer_release_spectral
 mov x9,#4512
 add x0,x21,x9
 bl md2asm_release_partitioned_operational_surface_state
 str xzr,[x22,#232]
.Lcontainer_release_spectral:
 ldr x9,[x22,#240]
 cbz x9,.Lcontainer_release_upper
 mov x9,#22736
 add x0,x21,x9
 bl md2asm_release_distributed_spectral_field
 str xzr,[x22,#240]
.Lcontainer_release_upper:
 ldr x9,[x22,#40]
 cbz x9,.Lcontainer_release_fields
 add x0,x21,#3416
 bl md2asm_release_gridpoint_field
 str xzr,[x22,#40]
.Lcontainer_release_fields:
 ldr x9,[x22,#48]
 cbz x9,.Lcontainer_release_outer_fields
 add x0,x22,#48
 bl md2asm_release_operational_model_configuration
.Lcontainer_release_outer_fields:
 add x0,x22,#24
 bl md2asm_release_initial_fields_storage
 add x0,x22,#16
 add x1,x22,#64
 bl md2asm_release_selected_model_storage
 str xzr,[x22]
 mov x0,x22
 bl free
 mov w28,#0
.Lcontainer_release_env:
 C_RESTORE
.Lcontainer_release_exit:
 C_LEAVE 128
.Lcontainer_null:
 mov w0,#0
 ret
.size md2asm_release_distributed_operational_model_storage,.-md2asm_release_distributed_operational_model_storage

.macro DMADDR out,base,offset
 movz \out,#((\offset)&65535)
 movk \out,#((\offset)>>16),lsl#16
 add \out,\base,\out
.endm
.p2align 4
.global md2asm_attach_distributed_operational_model_configuration
.type md2asm_attach_distributed_operational_model_configuration,%function
md2asm_attach_distributed_operational_model_configuration:
 C_ENTER 160
 mov x22,x0
 stp x1,x2,[sp,#112]
 stp x3,x4,[sp,#128]
 bl .Lcontainer_validate
 cbnz w0,.Lattach_exit
 ldr x9,[x22,#48]
 cbnz x9,.Lattach_bad
 ldr x9,[x22,#56]
 cbnz x9,.Lattach_bad
 ldr x9,[sp,#136]
 cbz x9,.Lattach_bad
 tst x9,#7
 b.ne .Lattach_bad
 adds x10,x9,#4096
 b.cs .Lattach_bad
 ldr x10,[x9]
 cmp x10,x19
 b.ne .Lattach_bad
 ldr x10,[x9,#8]
 adr x11,.Lcontainer_part_magic
 ldr x11,[x11]
 cmp x10,x11
 b.ne .Lattach_bad
 ldr w10,[x9,#16]
 cmp w10,#3
 b.ne .Lattach_bad
 mov x0,x20
 movz x1,#(4275088&65535)
 movk x1,#(4275088>>16),lsl#16
 mov x2,x21
 mov x3,x19
 ldp x4,x5,[sp,#112]
 ldr x6,[sp,#128]
 add x7,x22,#48
 bl md2asm_attach_operational_model_configuration
 cbnz w0,.Lattach_exit
 DMADDR x9,x20,1359332
 ldr w9,[x9]
 cmp w9,#8
 b.ne .Lattach_bad
 ldr x0,[x22,#48]
 ldr x1,[sp,#136]
 bl md2asm_associate_operational_model_partition
 cbnz w0,.Lattach_exit
 ldr x9,[sp,#136]
 str x9,[x22,#56]
 b .Lattach_exit
.Lattach_bad:
 mov w0,#2
.Lattach_exit:
 C_LEAVE 160
.size md2asm_attach_distributed_operational_model_configuration,.-md2asm_attach_distributed_operational_model_configuration
.p2align 4
.global md2asm_allocate_distributed_operational_model_grid_motion
.type md2asm_allocate_distributed_operational_model_grid_motion,%function
md2asm_allocate_distributed_operational_model_grid_motion:
 C_ENTER 240
 mov x22,x0
 bl .Lcontainer_validate
 cbnz w0,.Lmain_exit
 ldr x9,[x22,#48]
 cbz x9,.Lmain_bad
 ldr x10,[x22,#56]
 cbz x10,.Lmain_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lmain_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lmain_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lmain_bad
 ldr x9,[x22,#224]
 cbnz x9,.Lmain_bad
 str x19,[sp,#112]
 mov x9,#17096
 str x9,[sp,#120]
 DMADDR x9,x20,1577888
 str x9,[sp,#128]
 mov x9,#448
 str x9,[sp,#136]
 add x9,x20,#16
 str x9,[sp,#144]
 mov x9,#176
 str x9,[sp,#152]
 DMADDR x9,x20,4143760
 str x9,[sp,#160]
 mov x9,#1096
 str x9,[sp,#168]
 DMADDR x9,x20,1564136
 str x9,[sp,#176]
 mov x9,#456
 str x9,[sp,#184]
 ldr x9,[x22,#48]
 DMADDR x10,x9,35688
 ldr w10,[x10]
 str w10,[sp,#192]
 DMADDR x10,x9,40104
 ldr w10,[x10]
 str w10,[sp,#196]
 DMADDR x10,x9,40092
 ldr w10,[x10]
 str w10,[sp,#200]
 DMADDR x10,x9,51660
 ldr w10,[x10]
 str w10,[sp,#204]
 str xzr,[sp,#208]
 add x0,x21,#1856
 mov x1,#1560
 add x2,sp,#112
 add x3,sp,#192
 bl md2asm_allocate_distributed_grid_motion_fields
 cbnz w0,.Lmain_exit
 add x9,x21,#1856
 ldr x10,[x9]
 str x10,[x22,#720]
 ldr x10,[x9,#136]
 str x10,[x22,#728]
 mov x9,#1
 str x9,[x22,#224]
 b .Lmain_exit
.Lmain_bad:
 mov w0,#2
.Lmain_exit:
 C_LEAVE 240
.size md2asm_allocate_distributed_operational_model_grid_motion,.-md2asm_allocate_distributed_operational_model_grid_motion
.p2align 4
.global md2asm_initialize_distributed_operational_model_surface
.type md2asm_initialize_distributed_operational_model_surface,%function
md2asm_initialize_distributed_operational_model_surface:
 C_ENTER 160
 mov x23,x0
 mov x22,x1
 bl .Lcontainer_validate
 cbnz w0,.Lsurface_exit
 ldr x9,[x22,#48]
 cbz x9,.Lsurface_bad
 ldr x10,[x22,#56]
 cbz x10,.Lsurface_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lsurface_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lsurface_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lsurface_bad
 ldr x9,[x22,#232]
 cbnz x9,.Lsurface_bad
 add x9,x22,#664
 str x9,[x22,#672]
 str x19,[x22,#680]
 mov x9,#7376
 ldr w9,[x19,x9]
 mov x10,#6648
 ldr x10,[x19,x10]
 str x9,[x22,#688]
 str x10,[x22,#696]
 lsl x9,x9,#2
 mov x10,#5160
 ldr w10,[x19,x10]
 str x9,[x22,#704]
 str x10,[x22,#712]
 ldr x9,[x22,#48]
 mov x0,x23
 add x1,x9,#64
 DMADDR x2,x20,1577888
 DMADDR x3,x21,4512
 add x4,x22,#256
 DMADDR x5,x20,4155544
 DMADDR x6,x9,65360
 add x7,x22,#672
 bl md2asm_initialize_partitioned_operational_surface_state
 cbnz w0,.Lsurface_exit
 mov x9,#1
 str x9,[x22,#232]
.Lsurface_exit:
 C_LEAVE 160
.Lsurface_bad:
 mov w0,#2
 b .Lsurface_exit
.size md2asm_initialize_distributed_operational_model_surface,.-md2asm_initialize_distributed_operational_model_surface
.p2align 4
.global md2asm_initialize_distributed_operational_model_spectral
.type md2asm_initialize_distributed_operational_model_spectral,%function
md2asm_initialize_distributed_operational_model_spectral:
 C_ENTER 144
 mov x22,x0
 str x1,[sp,#112]
 bl .Lcontainer_validate
 cbnz w0,.Lspectral_exit
 ldr x9,[x22,#48]
 cbz x9,.Lspectral_bad
 ldr x10,[x22,#56]
 cbz x10,.Lspectral_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lspectral_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lspectral_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lspectral_bad
 ldr x9,[x22,#240]
 cbnz x9,.Lspectral_bad
 ldr x9,[sp,#112]
 cbz x9,.Lspectral_bad
 tst x9,#3
 b.ne .Lspectral_bad
 adds x10,x9,#20
 b.cs .Lspectral_bad
 ldp x10,x11,[x9]
 str x10,[x22,#760]
 str x11,[x22,#768]
 ldr w10,[x9,#16]
 str w10,[x22,#776]
 DMADDR x0,x21,22736
 mov x1,#2992
 mov x2,x19
 mov x3,#20400
 ldr x4,[x22,#56]
 mov x5,#4096
 add x6,x22,#760
 add x7,x22,#736
 bl md2asm_initialize_owned_distributed_spectral_field
 cbnz w0,.Lspectral_exit
 mov x9,#1
 str x9,[x22,#240]
.Lspectral_exit:
 C_LEAVE 144
.Lspectral_bad:
 mov w0,#2
 b .Lspectral_exit
.size md2asm_initialize_distributed_operational_model_spectral,.-md2asm_initialize_distributed_operational_model_spectral
.p2align 4
.global md2asm_load_distributed_operational_model_spectral_state
.type md2asm_load_distributed_operational_model_spectral_state,%function
md2asm_load_distributed_operational_model_spectral_state:
 C_ENTER 128
 mov x23,x0
 mov x22,x1
 bl .Lcontainer_validate
 cbnz w0,.Lspectral_load_exit
 cbz x23,.Lspectral_load_bad
 ldr x9,[x22,#48]
 cbz x9,.Lspectral_load_bad
 ldr x10,[x22,#56]
 cbz x10,.Lspectral_load_bad
 ldr x11,[x9,#48]
 cmp x11,x10
 b.ne .Lspectral_load_bad
 ldr x11,[x10]
 cmp x11,x19
 b.ne .Lspectral_load_bad
 ldr x11,[x10,#16]
 cmp x11,#3
 b.ne .Lspectral_load_bad
 ldr x9,[x22,#240]
 cmp x9,#1
 b.ne .Lspectral_load_bad
 ldr w9,[x22,#784]
 cbnz w9,.Lspectral_load_bad
 /* This source-selected caller uses explicit path input, so SUSPECG IFILE=-99:
  * same resolution, no IFILE7 control-variable branch, and loaded orography. */
 mov x9,#5172
 ldr w9,[x19,x9]
 cmp w9,#1279
 b.ne .Lspectral_load_bad
 mov x9,#5224
 ldr w9,[x19,x9]
 cmp w9,#137
 b.ne .Lspectral_load_bad
 ldr w9,[x20,#16]
 cmp w9,#1
 b.ne .Lspectral_load_bad
 ldr w9,[x20,#32]
 cmp w9,#3
 b.ne .Lspectral_load_bad
 ldr w9,[x20,#36]
 cmp w9,#2
 b.ne .Lspectral_load_bad
 ldr w9,[x20,#200]
 cbnz w9,.Lspectral_load_bad
 ldr w9,[x20,#192]
 cmp w9,#9
 b.ne .Lspectral_load_bad
 /* Every active field has genuine grid-point input. */
 DMADDR x9,x20,4040
 mov w10,#9
.Lspectral_load_grid_inputs:
 ldr w11,[x9,#44]
 cmp w11,#1
 b.ne .Lspectral_load_bad
 add x9,x9,#368
 subs w10,w10,#1
 b.ne .Lspectral_load_grid_inputs
 ldr w9,[x22,#760]
 cmp w9,#138
 b.ne .Lspectral_load_bad
 ldr w9,[x22,#764]
 cmp w9,#155
 b.ne .Lspectral_load_bad
 ldr w9,[x22,#768]
 cmp w9,#130
 b.ne .Lspectral_load_bad
 ldr w9,[x22,#772]
 cmp w9,#152
 b.ne .Lspectral_load_bad
 ldr w9,[x22,#776]
 cmp w9,#129
 b.ne .Lspectral_load_bad
 mov x0,x23
 DMADDR x1,x21,22736
 mov x2,#2992
 add x3,x22,#784
 bl md2asm_load_partitioned_operational_spectral_initial_state
 b .Lspectral_load_exit
.Lspectral_load_bad:
 mov w0,#2
.Lspectral_load_exit:
 C_LEAVE 128
.size md2asm_load_distributed_operational_model_spectral_state,.-md2asm_load_distributed_operational_model_spectral_state
/* The container is opaque and has been created by this entry. */
.Lcontainer_validate:
 cbz x22,.Lcontainer_bad
 tst x22,#7
 b.ne .Lcontainer_bad
 adds x9,x22,#800
 b.cs .Lcontainer_bad
 adr x9,.Lcontainer_magic
 ldr x9,[x9]
 ldr x10,[x22]
 cmp x9,x10
 b.ne .Lcontainer_bad
 ldp x19,x20,[x22,#8]
 ldr x21,[x22,#24]
 cbz x19,.Lcontainer_bad
 cbz x20,.Lcontainer_bad
 cbz x21,.Lcontainer_bad
 orr x9,x19,x20
 orr x9,x9,x21
 tst x9,#7
 b.ne .Lcontainer_bad
 ldr x9,[x20,#8]
 cmp x9,x19
 b.ne .Lcontainer_bad
 ldr x9,[x21,#1840]
 cmp x9,x20
 b.ne .Lcontainer_bad
 adr x9,.Lcontainer_alias_offsets
 mov x10,#0
 add x11,x22,#64
.Lcontainer_validate_alias:
 ldr x12,[x11,x10,lsl#3]
 cbz x12,.Lcontainer_bad
 tst x12,#7
 b.ne .Lcontainer_bad
 ldr w13,[x9,x10,lsl#2]
 add x13,x20,x13
 ldr x14,[x12]
 cmp x13,x14
 b.ne .Lcontainer_bad
 add x10,x10,#1
 cmp x10,#15
 b.lo .Lcontainer_validate_alias
 ldr x9,[x22,#40]
 cmp x9,#1
 b.hi .Lcontainer_bad
 add x10,x21,#3416
 cbz x9,.Lcontainer_validate_empty
 ldr x11,[x10]
 ldr x12,[x22,#192]
 cmp x11,x12
 b.ne .Lcontainer_bad
 ldr x11,[x10,#272]
 ldr x12,[x22,#200]
 cmp x11,x12
 b.ne .Lcontainer_bad
 ldr x11,[x10,#408]
 ldr x12,[x22,#208]
 cmp x11,x12
 b.ne .Lcontainer_bad
 ldr x11,[x10,#544]
 ldr x12,[x22,#216]
 cmp x11,x12
 b.ne .Lcontainer_bad
 ldr x11,[x10,#1088]
 add x12,x20,#192
 cmp x11,x12
 b.ne .Lcontainer_bad
 mov w0,#0
 ret
.Lcontainer_validate_empty:
 mov x11,#1096
.Lcontainer_validate_fresh:
 ldr x12,[x10],#8
 cbnz x12,.Lcontainer_bad
 subs x11,x11,#8
 b.ne .Lcontainer_validate_fresh
 mov w0,#0
 ret
.Lcontainer_bad:
 mov w0,#2
 ret
.Lcontainer_path_clear:
 add x11,x10,x11
 cmp x23,x11
 b.hs .Lcontainer_path_good
 cmp x10,x12
 b.lo .Lcontainer_bad
.Lcontainer_path_good:
 mov w0,#0
 ret
.section .rodata
.p2align 3
.Lcontainer_part_magic: .quad 0x445054585f4f574e
.Lcontainer_magic: .ascii "DPMODEL1"
.Lcontainer_tgfl_shape: .word 17,137,97055,9,3,0,0
.Lcontainer_alias_offsets:
 .word 1577368,192,1608728,1626696,1588296,1589160,1590360,1591240
 .word 1591584,1577888,4143760,4144856,4148312,4150008,4219384
.section .note.GNU-stack,"",%progbits

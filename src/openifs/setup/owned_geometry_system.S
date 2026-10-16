/* Contract: skills/md2asm/references/openifs/setup/owned_geometry_system.md.
 * x0 live vertical20400, x1 headers5232,x2 constants520,x3 text,x4 textbytes,
 * x5 output pointer. Return0 complete,1 allocation,2 input,3 external failure.
 * Own new horizontal/atmosphere state and sidecar1872; borrow all vertical owners.
 */
.arch armv8.2-a
.text
.macro GOFF reg,off
 mov \reg,#\off
 add \reg,x19,\reg
.endm
.macro CALL_OK name
 bl \name
 cbnz w0,.Lgeometry_failed
.endm
.p2align 4
.global md2asm_complete_owned_geometry
.type md2asm_complete_owned_geometry,%function
md2asm_complete_owned_geometry:
 mrs x9,fpcr
 cbnz x9,.Lgeometry_bad
 cbz x0,.Lgeometry_bad
 cbz x1,.Lgeometry_bad
 cbz x2,.Lgeometry_bad
 cbz x3,.Lgeometry_bad
 cbz x4,.Lgeometry_bad
 cbz x5,.Lgeometry_bad
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lgeometry_bad
 mov x9,#262144
 cmp x4,x9
 b.hi .Lgeometry_bad
 ldr x9,[x5]
 cbnz x9,.Lgeometry_bad
 /* The complete horizontal owner set must be fresh. */
 adr x10,.Lgeometry_owners
 mov x11,#121
.Lgeometry_fresh:
 ldr w12,[x10],#4
 ldr x13,[x0,x12]
 cbnz x13,.Lgeometry_bad
 subs x11,x11,#1
 b.ne .Lgeometry_fresh
 mov x10,#14024
 ldr x9,[x0,x10]
 cbnz x9,.Lgeometry_bad
 ldr x9,[x0]
 add x10,x0,#8
 cmp x9,x10
 b.ne .Lgeometry_bad
 ldr w9,[x0,#5224]
 cmp w9,#19
 b.ne .Lgeometry_bad
 ldp w9,w10,[x1]
 cmp w9,#21
 b.ne .Lgeometry_bad
 cmp w10,#21
 b.ne .Lgeometry_bad
 ldp w9,w10,[x1,#8]
 cmp w9,#32
 b.ne .Lgeometry_bad
 cmp w10,#64
 b.ne .Lgeometry_bad
 ldr w9,[x1,#16]
 cmp w9,#19
 b.ne .Lgeometry_bad
 sub sp,sp,#2048
 stp x29,x30,[sp]
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
 mov x23,x4
 mov x24,x5
 mov x25,#0
 /* Validate the selected groups before acquiring any owner. */
 mov x0,x22
 mov x1,x23
 adr x2,.Lgeometry_sta_name
 mov x3,#6
 CALL_OK md2asm_require_empty_geometry_group
 mov x0,x22
 mov x1,x23
 adr x2,.Lgeometry_atlas_name
 mov x3,#13
 CALL_OK md2asm_require_empty_geometry_group
 mov x0,x22
 mov x1,x23
 CALL_OK md2asm_read_spherical_geometry_group
 mov x0,x22
 mov x1,x23
 add x2,sp,#176
 add x3,sp,#224
 CALL_OK md2asm_read_grid_dimension_group
 /* Source SUDIM setup words, with live initial-file metadata. */
 adr x9,.Lgeometry_dimension_defaults
 add x10,sp,#128
 mov x11,#6
.Lgeometry_setup_defaults:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs x11,x11,#1
 b.ne .Lgeometry_setup_defaults
 ldr w9,[x20]
 str w9,[sp,#152]
 ldp w9,w10,[x20,#8]
 stp w9,w10,[sp,#156]
 ldr w9,[x20,#4]
 str w9,[sp,#164]
 ldr w9,[x20,#16]
 str w9,[sp,#168]
 mov x0,x19
 add x1,sp,#128
 add x2,sp,#176
 ldr w3,[sp,#224]
 CALL_OK md2asm_initialize_grid_dimensions
 mov w9,#1
 str w9,[sp,#232]
 ldr w9,[x20,#24]
 str w9,[sp,#236]
 ldr w9,[x20,#20]
 str w9,[sp,#240]
 ldp x9,x10,[x20,#72]
 stp x9,x10,[sp,#256]
 ldr x9,[x20,#64]
 str x9,[sp,#272]
 mov x0,x19
 add x1,sp,#232
 add x2,sp,#256
 CALL_OK md2asm_initialize_spherical_configuration
 mov x0,#1
 mov x1,#1872
 bl calloc
 cbz x0,.Lgeometry_allocation_failed
 mov x25,x0
 str x19,[x25]
 /* Independent owned transform namespace, source defaults. */
 add x10,x25,#880
 mov w9,#1
 mov x11,#0
.Lgeometry_transform_defaults:
 str w9,[x10,x11]
 add x11,x11,#4
 cmp x11,#36
 b.lo .Lgeometry_transform_defaults
 movz w9,#0x7740
 movk w9,#0x1b,lsl#16
 str w9,[x10,#40]
 mov w9,#1
 str w9,[x10,#52]
 str w9,[x10,#60]
 ldr x9,[x21,#104]
 str x9,[x10,#96]
 mov w9,#6
 str w9,[x10,#288]
 mov w9,#1
 str w9,[x10,#296]
 /* Initialize the permitted message API. */
 stp xzr,xzr,[sp,#288]
 stp xzr,xzr,[sp,#320]
 stp xzr,xzr,[sp,#336]
 stp xzr,xzr,[sp,#352]
 add x9,sp,#288
 str x9,[sp,#320]
 str x9,[sp,#352]
 str x9,[sp,#360]
 add x9,sp,#384
 str x9,[sp,#336]
 add x9,sp,#388
 str x9,[sp,#344]
 add x0,sp,#320
 CALL_OK md2asm_call_public_message_init
 ldr w9,[sp,#384]
 cbnz w9,.Lgeometry_external_failed
 ldr w9,[sp,#388]
 cmp w9,#1
 b.ne .Lgeometry_external_failed
 mov x0,x19
 add x1,x25,#880
 mov x2,x22
 mov x3,x23
 CALL_OK md2asm_initialize_owned_transform_context
 mov x9,#1
 str x9,[x25,#1264]
 mov w9,#1
 str w9,[sp,#288]
 str w9,[sp,#292]
 mov x0,x19
 add x1,sp,#288
 CALL_OK md2asm_initialize_global_grid_cutoffs
 /* Collect actual partition inputs from the owned transform result. */
 adr x9,.Lgeometry_partition_sources
 add x10,x25,#880
 add x11,x25,#1232
 mov x12,#7
.Lgeometry_partition_arguments:
 ldr w13,[x9],#4
 ldr w14,[x10,x13]
 str w14,[x11],#4
 subs x12,x12,#1
 b.ne .Lgeometry_partition_arguments
 mov x0,x19
 add x1,x25,#8
 add x2,x25,#1232
 CALL_OK md2asm_initialize_serial_partition_maps
 GOFF x0,4232
 ldr d0,[x21,#104]
 CALL_OK md2asm_initialize_latitude_geometry
 GOFF x0,3656
 ldr w1,[x19,#5172]
 ldr d0,[x21,#104]
 CALL_OK md2asm_initialize_serial_laplacian
 /* Existing complete SUVERT owners remain attached at this dependency point. */
 add x0,x25,#8
 mov x1,x19
 mov w2,#0
 CALL_OK md2asm_copy_stream_geometry_values
 ldr x9,[x21,#112]
 str x9,[sp,#432]
 ldr x9,[x21,#184]
 str x9,[sp,#440]
 mov x9,#0x3ff0000000000000
 str x9,[sp,#448]
 mov x10,#20320
 ldr x9,[x19,x10]
 str x9,[sp,#456]
 movz x9,#0xc000,lsl#32
 movk x9,#0x4062,lsl#48
 str x9,[sp,#464]
 mov x10,#20328
 ldr x9,[x19,x10]
 str x9,[sp,#472]
 ldr x9,[x21,#216]
 str x9,[sp,#480]
 mov x0,x19
 add x1,sp,#432
 mov w2,#1
 add x3,x25,#1280
 add x4,x25,#1856
 CALL_OK md2asm_initialize_standard_atmosphere
 /* Source SUGEM1B constants and local maps. */
 ldr w9,[x25,#1232]
 ldr w10,[x25,#1236]
 str w9,[sp,#400]
 str w10,[sp,#404]
 ldr x9,[x21]
 str x9,[sp,#408]
 ldr x9,[x21,#104]
 str x9,[sp,#416]
 mov x0,x19
 add x1,sp,#400
 CALL_OK md2asm_initialize_spherical_grid
 add x0,x25,#8
 mov x1,x19
 mov w2,#1
 CALL_OK md2asm_copy_stream_geometry_values
 ldr w9,[x19,#5172]
 ldr w10,[x19,#5212]
 str w9,[sp,#496]
 str w10,[sp,#500]
 ldr w9,[x19,#5196]
 str w9,[sp,#504]
 str wzr,[sp,#508]
 GOFF x0,14616
 add x1,sp,#496
 GOFF x9,3912
 ldr x2,[x9]
 GOFF x9,4040
 ldr x3,[x9]
 GOFF x4,7512
 CALL_OK md2asm_initialize_spectral_geometry_maps
 add x10,x25,#1184
 ldr x9,[x19,#7512]
 str x9,[x10]
 ldr x9,[x19,#7544]
 ldr x11,[x19,#7552]
 stp x9,x11,[x10,#8]
 ldr x9,[x21,#104]
 str x9,[x10,#24]
 ldr x9,[x21]
 str x9,[x10,#32]
 ldr x9,[x21,#96]
 str x9,[x10,#40]
 mov x0,x19
 add x1,x25,#1184
 add x2,sp,#288
 CALL_OK md2asm_initialize_spherical_geometry
 mov x0,x19
 mov w1,#1
 CALL_OK md2asm_initialize_local_geometry_maps
 mov x0,x19
 CALL_OK md2asm_allocate_orography_owners
 movz x9,#0x4f4d
 movk x9,#0x4745,lsl#16
 str x9,[x25,#1272]
 str x25,[x24]
 mov w28,#0
 b .Lgeometry_return
.Lgeometry_allocation_failed:
 mov w0,#1
 b .Lgeometry_failed
.Lgeometry_external_failed:
 mov w0,#3
.Lgeometry_failed:
 mov w28,w0
 cbz x25,.Lgeometry_cleanup_configuration
 mov x0,x25
 bl md2asm_release_owned_geometry
 mov x25,#0
 b .Lgeometry_return
.Lgeometry_cleanup_configuration:
 mov x0,x19
 bl md2asm_release_spherical_configuration
.Lgeometry_return:
 mov w0,w28
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#2048
 ret
.Lgeometry_bad:
 mov w0,#2
 ret
.size md2asm_complete_owned_geometry,.-md2asm_complete_owned_geometry
.global md2asm_release_owned_geometry
.type md2asm_release_owned_geometry,%function
md2asm_release_owned_geometry:
 cbz x0,.Lgeometry_bad
 tst x0,#7
 b.ne .Lgeometry_bad
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 ldr x20,[x19]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#64]
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 mov x0,x20
 bl md2asm_release_orography_owners
 adr x23,.Lgeometry_owners
 mov w9,#121
 str w9,[sp,#80]
.Lgeometry_release_owner:
 ldr w10,[x23],#4
 str w10,[sp,#84]
 ldr x0,[x20,x10]
 cbz x0,.Lgeometry_release_next
 bl free
 ldr w10,[sp,#84]
 str xzr,[x20,x10]
.Lgeometry_release_next:
 ldr w9,[sp,#80]
 subs w9,w9,#1
 str w9,[sp,#80]
 b.ne .Lgeometry_release_owner
 add x0,x19,#8
 bl md2asm_release_stream_geometry_values
 add x0,x19,#8
 bl md2asm_release_stream_geometry_metadata
 add x0,x19,#880
 bl md2asm_release_transform_environment_metadata
 ldr x9,[x19,#1264]
 tbz x9,#0,.Lgeometry_release_sidecar
 mov x0,x20
 add x1,sp,#88
 bl md2asm_finish_external_transform_context
.Lgeometry_release_sidecar:
 mov x0,x19
 bl free
 str w22,[x21]
 ldp x9,x10,[sp,#64]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.size md2asm_release_owned_geometry,.-md2asm_release_owned_geometry
.p2align 3
.Lgeometry_dimension_defaults:
 .word 1,0,1,0,0,1
.Lgeometry_partition_sources:
 .word 20,16,24,104,108,4,0
.Lgeometry_owners:
 .word 7576,7640,7704,7768,7832,5832,6024,5256,5320,5384,7248,5448,7312,5512,5576,5640,5704,5768,5896,6088,6176,6264,6328,6392,7080,6456,6520,6584,4968,5056,7392,6992,6904,5960,7144,6648,6712,6776,6840,4232,4296,4360,4424,4488,4552,4616,4680,4744,3656,3720,3784,3848,3912,3976,4040,4104,4168,3272,3336,3400,3464,3528,3592,7896,14616,14704,8536,8600,8664,8728,8792,8856,8920,8984,9048,9112,9176,9240,9304,9368,9432,9496,9560,9624,9688,9752,9816,9880,9944,8088,8152,8216,8280,8344,8408,10008,10096,10184,10272,10360,10448,10536,10624,10712,10800,10888,10976,11064,11152,11240,11328,11416,11504,11592,11680,11768,11856,11944,8472,8024,4808
.Lgeometry_sta_name:
 .ascii "NAMSTA"
.Lgeometry_atlas_name:
 .ascii "NAM_ATLAS_IFS"
.section .note.GNU-stack,"",%progbits

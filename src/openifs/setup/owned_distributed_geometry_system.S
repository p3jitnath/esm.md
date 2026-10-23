/* Distributed setup contract: skills/md2asm/references/openifs/setup/owned_distributed_geometry_system.md. */
/* Contract: skills/md2asm/references/openifs/setup/owned_distributed_geometry_system.md..
 * x0 live vertical20400, x1 headers9328,x2 constants520,x3 text,x4 textbytes,
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
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Logeometry_failed
.endm
.macro COLLECTIVE_OK name
 bl \name
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Logeometry_failed
.endm
.p2align 4
.global md2asm_complete_owned_distributed_geometry
.type md2asm_complete_owned_distributed_geometry,%function
md2asm_complete_owned_distributed_geometry:
 mov w17,#0
 mrs x9,fpcr
 cbnz x9,.Ldg_complete_preflight_bad
 cbz x0,.Ldg_complete_preflight_bad
 cbz x1,.Ldg_complete_preflight_bad
 cbz x2,.Ldg_complete_preflight_bad
 cbz x3,.Ldg_complete_preflight_bad
 cbz x4,.Ldg_complete_preflight_bad
 cbz x5,.Ldg_complete_preflight_bad
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x5
 tst x9,#7
 b.ne .Ldg_complete_preflight_bad
 mov x9,#262144
 cmp x4,x9
 b.hi .Ldg_complete_preflight_bad
 ldr x9,[x5]
 cbnz x9,.Ldg_complete_preflight_bad
 /* The complete horizontal owner set must be fresh. */
 adr x10,.Logeometry_owners
 mov x11,#121
.Logeometry_fresh:
 ldr w12,[x10],#4
 ldr x13,[x0,x12]
 cbnz x13,.Ldg_complete_preflight_bad
 subs x11,x11,#1
 b.ne .Logeometry_fresh
 mov x10,#14024
 ldr x9,[x0,x10]
 cbnz x9,.Ldg_complete_preflight_bad
 ldr x9,[x0]
 add x10,x0,#8
 cmp x9,x10
 b.ne .Ldg_complete_preflight_bad
 ldr w9,[x0,#5224]
 cmp w9,#137
 b.ne .Ldg_complete_preflight_bad
 ldp w9,w10,[x1]
 cmp w9,#1279
 b.ne .Ldg_complete_preflight_bad
 cmp w10,#1279
 b.ne .Ldg_complete_preflight_bad
 ldp w9,w10,[x1,#8]
 cmp w9,#2560
 b.ne .Ldg_complete_preflight_bad
 mov w11,#5136
 cmp w10,w11
 b.ne .Ldg_complete_preflight_bad
 ldr w9,[x1,#16]
 cmp w9,#137
 b.ne .Ldg_complete_preflight_bad
 b .Ldg_complete_prologue
.Ldg_complete_preflight_bad:
 mov w17,#2
.Ldg_complete_prologue:
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
 str w17,[sp,#736]
 /* The public message environment permits collective setup-failure agreement. */
 add x10,sp,#640
 stp xzr,xzr,[x10]
 stp xzr,xzr,[x10,#16]
 stp xzr,xzr,[x10,#32]
 stp xzr,xzr,[x10,#48]
 str xzr,[sp,#704]
 str wzr,[sp,#712]
 add x9,sp,#704
 str x9,[sp,#640]
 str x9,[sp,#672]
 str x9,[sp,#680]
 add x9,sp,#708
 str x9,[sp,#656]
 add x9,sp,#712
 str x9,[sp,#664]
 add x0,sp,#640
 bl md2asm_call_public_message_init
 ldr w9,[sp,#708]
 cbnz w9,.Ldg_complete_abort
 ldr w9,[sp,#712]
 cmp w9,#4
 mov w0,#2
 csel w0,wzr,w0,eq
 ldr w9,[sp,#736]
 cmp w9,w0
 csel w0,w9,w0,hi
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Logeometry_failed
 /* Validate the selected groups before acquiring any owner. */
 mov x0,x22
 mov x1,x23
 adr x2,.Logeometry_sta_name
 mov x3,#6
 CALL_OK md2asm_require_empty_geometry_group
 mov x0,x22
 mov x1,x23
 adr x2,.Logeometry_atlas_name
 mov x3,#13
 CALL_OK md2asm_require_empty_geometry_group
 mov x0,x22
 mov x1,x23
 add x2,sp,#176
 add x3,sp,#224
 CALL_OK md2asm_read_grid_dimension_group
 /* Source SUDIM setup words, with live initial-file metadata. */
 adr x9,.Logeometry_dimension_defaults
 add x10,sp,#128
 mov x11,#6
.Logeometry_setup_defaults:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs x11,x11,#1
 b.ne .Logeometry_setup_defaults
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
 add x3,x20,#4096
 add x3,x3,#112
 mov x4,#1280
 mov x5,x22
 mov x6,x23
 CALL_OK md2asm_initialize_operational_reduced_grid
 mov x0,#1
 mov x1,#1872
 bl calloc
 mov x25,x0
 cbz x25,.Ldg_complete_sidecar_ready
 str x19,[x25]
.Ldg_complete_sidecar_ready:
 cmp x25,#0
 cset w0,eq
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Logeometry_failed
 /* New sidecar word1 owns the complete live distributed partition. */
 mov x0,x19
 mov x1,x21
 mov x2,x22
 mov x3,x23
 mov w4,#4
 add x5,x25,#8
 CALL_OK md2asm_create_owned_distributed_geometry_partition
 ldr x26,[x25,#8]
 GOFF x0,4232
 GOFF x1,4872
 ldr x9,[x21,#104]
 str x9,[sp,#552]
 ldr x9,[x21]
 str x9,[sp,#560]
 add x2,sp,#552
 COLLECTIVE_OK md2asm_initialize_operational_latitude_geometry
 mov x0,x19
 mov x1,x21
 mov x2,x26
 COLLECTIVE_OK md2asm_initialize_distributed_laplacian
 /* Existing complete SUVERT owners remain attached at this dependency point. */
 add x0,x26,#2368
 mov x1,x19
 mov w2,#0
 COLLECTIVE_OK md2asm_copy_operational_stream_geometry_values
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
 COLLECTIVE_OK md2asm_initialize_standard_atmosphere
 /* Source SUGEM1B constants and local maps. */
 ldr w9,[x26,#64]
 ldr w10,[x26,#936]
 str w9,[sp,#400]
 str w10,[sp,#404]
 ldr x9,[x21]
 str x9,[sp,#408]
 ldr x9,[x21,#104]
 str x9,[sp,#416]
 mov x0,x19
 add x1,sp,#400
 COLLECTIVE_OK md2asm_initialize_distributed_spherical_grid
 add x0,x26,#2368
 mov x1,x19
 mov w2,#1
 COLLECTIVE_OK md2asm_copy_operational_stream_geometry_values
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
 COLLECTIVE_OK md2asm_initialize_distributed_spectral_geometry_maps
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
 add x2,sp,#400
 COLLECTIVE_OK md2asm_initialize_distributed_spherical_geometry
 mov x0,x19
 ldr w1,[x26,#64]
 add x2,x26,#384
 COLLECTIVE_OK md2asm_initialize_distributed_local_geometry_maps
 mov x0,x19
 COLLECTIVE_OK md2asm_allocate_distributed_orography_owners
 movz x9,#0x4f4d
 movk x9,#0x4745,lsl#16
 str x9,[x25,#1272]
 str x25,[x24]
 mov w28,#0
 b .Logeometry_return
.Logeometry_allocation_failed:
 mov w0,#1
 b .Logeometry_failed
.Logeometry_external_failed:
 mov w0,#3
.Logeometry_failed:
 mov w28,w0
 cbz x25,.Logeometry_cleanup_configuration
 mov x0,x25
 bl md2asm_release_owned_distributed_geometry
 mov x25,#0
 b .Logeometry_return
.Logeometry_cleanup_configuration:
 ldr w9,[sp,#736]
 cbnz w9,.Ldg_complete_cleanup_message
 mov x0,x19
 bl .Ldg_complete_early_cleanup
.Ldg_complete_cleanup_message:
 str wzr,[sp,#704]
 add x0,sp,#704
 add x1,sp,#704
 bl __mpl_end_mod_MOD_mpl_end
.Logeometry_return:
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
.Ldg_complete_abort:
 mov w0,#3
 bl fortran_mpi_abort
 brk #0
.Logeometry_bad:
 mov w0,#2
 ret
.size md2asm_complete_owned_distributed_geometry,.-md2asm_complete_owned_distributed_geometry

.global md2asm_release_owned_distributed_geometry
.type md2asm_release_owned_distributed_geometry,%function
md2asm_release_owned_distributed_geometry:
 cbz x0,.Logeometry_bad
 tst x0,#7
 b.ne .Logeometry_bad
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 ldr x20,[x19]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#64]
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 mov x0,x20
 bl .Ldg_complete_early_cleanup
 ldr x23,[x19,#8]
 cbz x23,.Ldg_complete_empty_partition
 add x0,x23,#2368
 bl md2asm_release_stream_geometry_values
 mov x0,x23
 bl md2asm_release_owned_distributed_transform_partition
 b .Ldg_complete_sidecar
.Ldg_complete_empty_partition:
 str wzr,[sp,#80]
 add x0,sp,#80
 add x1,sp,#80
 bl __mpl_end_mod_MOD_mpl_end
.Ldg_complete_sidecar:
 mov x0,x19
 bl free
 str w22,[x21]
 ldp x9,x10,[sp,#64]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,#0
 ldp x23,x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.size md2asm_release_owned_distributed_geometry,.-md2asm_release_owned_distributed_geometry
// Release owned horizontal/atmosphere/reduced-grid data, with partial staging allowed.
.Ldg_complete_early_cleanup:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 bl md2asm_release_distributed_horizontal_geometry
 adr x20,.Ldg_complete_extra_owners
 mov x21,#9
.Ldg_complete_extra:
 ldr w9,[x20],#4
 str w9,[sp,#48]
 ldr x0,[x19,x9]
 cbz x0,.Ldg_complete_extra_next
 bl free
 ldr w9,[sp,#48]
 str xzr,[x19,x9]
.Ldg_complete_extra_next:
 subs x21,x21,#1
 b.ne .Ldg_complete_extra
 mov w0,#0
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.p2align 2
.Ldg_complete_extra_owners:
 .word 7640,7768,7832,3272,3336,3400,3464,3528,3592
.p2align 3
.Logeometry_dimension_defaults:
 .word 1,0,1,1,0,1
.Logeometry_partition_sources:
 .word 20,16,24,104,108,4,0
.Logeometry_owners:
 .word 7576,7640,7704,7768,7832,5832,6024,5256,5320,5384,7248,5448,7312,5512,5576,5640,5704,5768,5896,6088,6176,6264,6328,6392,7080,6456,6520,6584,4968,5056,7392,6992,6904,5960,7144,6648,6712,6776,6840,4232,4296,4360,4424,4488,4552,4616,4680,4744,3656,3720,3784,3848,3912,3976,4040,4104,4168,3272,3336,3400,3464,3528,3592,7896,14616,14704,8536,8600,8664,8728,8792,8856,8920,8984,9048,9112,9176,9240,9304,9368,9432,9496,9560,9624,9688,9752,9816,9880,9944,8088,8152,8216,8280,8344,8408,10008,10096,10184,10272,10360,10448,10536,10624,10712,10800,10888,10976,11064,11152,11240,11328,11416,11504,11592,11680,11768,11856,11944,8472,8024,4808
.Logeometry_sta_name:
 .ascii "NAMSTA"
.Logeometry_atlas_name:
 .ascii "NAM_ATLAS_IFS"
.section .note.GNU-stack,"",%progbits

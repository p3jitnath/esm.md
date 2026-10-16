/* Contract: skills/md2asm/references/openifs/setup/owned_transform_setup_contract.md.
 * Setup0:x0 owned control[304],x1 mapped text,x2 byte count. Frame448B.
 * Setup:x0 Geometry[17096],x1 control[304],x2 text,x3 count. Frame384B.
 * Fixed public external interfaces only. Two region owners belong to control.
 */
.arch armv8.2-a
.text
.macro ENVARG n, off
 add x9,x19,#\off
 str x9,[sp,#128+8*\n]
.endm
.p2align 4
.global md2asm_initialize_transform_environment
.type md2asm_initialize_transform_environment,%function
md2asm_initialize_transform_environment:
 cbz x0,.Lenv_bad
 tst x0,#7
 b.ne .Lenv_bad
 ldp w9,w10,[x0]
 cmp w9,#1
 b.ne .Lenv_bad
 cmp w10,#1
 b.ne .Lenv_bad
 mov x9,#8
.Lenv_serial_inputs:
 ldr w10,[x0,x9]
 cmp w10,#1
 b.ne .Lenv_bad
 add x9,x9,#4
 cmp x9,#36
 b.lo .Lenv_serial_inputs
 ldr w9,[x0,#36]
 cbnz w9,.Lenv_bad
 ldr w9,[x0,#44]
 ldr w10,[x0,#48]
 orr w9,w9,w10
 cbnz w9,.Lenv_bad
 ldr w9,[x0,#52]
 cmp w9,#1
 b.ne .Lenv_bad
 ldr w9,[x0,#60]
 cmp w9,#1
 b.lt .Lenv_bad
 ldr x9,[x0,#120]
 ldr x10,[x0,#184]
 orr x9,x9,x10
 cbnz x9,.Lenv_bad
 sub sp,sp,#448
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x0,x1
 mov x1,x2
 mov x2,#0
 bl md2asm_empty_transform_configuration_group
 cbnz w0,.Lenv_return
 str wzr,[x19,#64]
 str wzr,[x19,#68]
 mov w9,#22
 add w9,w9,#15
 str w9,[x19,#72]
 mov w9,#1
 str w9,[x19,#76]
 str wzr,[x19,#80]
 mov x9,#0x3ff0
 lsl x9,x9,#48
 str x9,[x19,#88]
 mov x9,#0
 add x10,sp,#128
.Lenv_zero_arguments:
 str xzr,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#18
 b.lo .Lenv_zero_arguments
 ENVARG 0,288
 ENVARG 1,292
 ENVARG 2,36
 ENVARG 3,72
 ENVARG 4,64
 ENVARG 5,8
 ENVARG 6,12
 ENVARG 7,16
 ENVARG 8,40
 ENVARG 9,44
 ENVARG 10,48
 ENVARG 12,52
 ENVARG 13,104
 ENVARG 14,108
 add x9,sp,#304
 str x9,[sp,#248]
 ENVARG 16,96
 ENVARG 17,76
 /* Automatic I_REGIONS(1:NPROC+2), represented as its public descriptor. */
 add x9,sp,#368
 str x9,[sp,#304]
 mov x9,#-1
 str x9,[sp,#312]
 mov x9,#4
 str x9,[sp,#320]
 str x9,[sp,#336]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[sp,#328]
 mov x9,#1
 str x9,[sp,#344]
 str x9,[sp,#352]
 mov x9,#3
 str x9,[sp,#360]
 bl __errno_location
 mov x20,x0
 str wzr,[x20]
 add x0,sp,#128
 bl md2asm_call_public_transform_setup0
 ldr w9,[x19,#104]
 ldr w10,[x19,#108]
 cmp w9,#1
 b.ne .Lenv_external_shape
 cmp w10,#1
 b.ne .Lenv_external_shape
 mov x21,#0
.Lenv_allocate:
 mov x22,#120
 cbz x21,.Lenv_descriptor
 mov x22,#184
.Lenv_descriptor:
 add x22,x19,x22
 mov x0,#4
 bl malloc
 cbz x0,.Lenv_failed
 str x0,[x22]
 mov x9,#-1
 cbz x21,.Lenv_offset
 mov x9,#-2
.Lenv_offset:
 str x9,[x22,#8]
 mov x9,#4
 str x9,[x22,#16]
 str x9,[x22,#32]
 mov x9,#0x101
 cbz x21,.Lenv_rank
 mov x9,#0x102
.Lenv_rank:
 lsl x9,x9,#32
 str x9,[x22,#24]
 mov x9,#1
 stp x9,x9,[x22,#40]
 str x9,[x22,#56]
 cbz x21,.Lenv_copy_region
 stp x9,x9,[x22,#64]
 str x9,[x22,#80]
 mov w9,#1
 str w9,[x0]
 b .Lenv_next_owner
.Lenv_copy_region:
 ldr w9,[sp,#368]
 str w9,[x0]
.Lenv_next_owner:
 add x21,x21,#1
 cmp x21,#2
 b.lo .Lenv_allocate
 /* Selected PE2SET grid mapping, followed by its actual permitted cartesian query. */
 mov w9,#1
 str w9,[x19,#112]
 ldr w9,[x19,#4]
 str w9,[x19,#116]
 add x0,x19,#4
 add x1,sp,#384
 add x2,sp,#388
 bl __mpl_groups_MOD_mpl_cart_coords
 ldr w9,[sp,#384]
 ldr w10,[sp,#388]
 cmp w9,#1
 b.ne .Lenv_external_shape
 cmp w10,#1
 b.ne .Lenv_external_shape
 mov w0,#0
 b .Lenv_return
.Lenv_external_shape:
 mov w23,#3
 b .Lenv_cleanup
.Lenv_failed:
 mov w23,#1
.Lenv_cleanup:
 ldr x0,[x19,#120]
 cbz x0,.Lenv_cleanup_second
 bl free
 str xzr,[x19,#120]
.Lenv_cleanup_second:
 ldr x0,[x19,#184]
 cbz x0,.Lenv_cleanup_done
 bl free
 str xzr,[x19,#184]
.Lenv_cleanup_done:
 mov w0,w23
.Lenv_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#448
 ret
.Lenv_bad:
 mov w0,#2
 ret
.size md2asm_initialize_transform_environment,.-md2asm_initialize_transform_environment
.p2align 4
.global md2asm_initialize_transform_resolution
.type md2asm_initialize_transform_resolution,%function
md2asm_initialize_transform_resolution:
 cbz x0,.Lresolution_bad
 cbz x1,.Lresolution_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lresolution_bad
 ldr w9,[x0,#5172]
 cmp w9,#21
 b.ne .Lresolution_bad
 ldr w9,[x0,#4872]
 cmp w9,#32
 b.ne .Lresolution_bad
 ldr x9,[x0,#7640]
 cbz x9,.Lresolution_bad
 ldr w9,[x1,#296]
 cmp w9,#1
 b.ne .Lresolution_bad
 sub sp,sp,#384
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x0,x2
 mov x1,x3
 mov x2,#1
 bl md2asm_empty_transform_configuration_group
 cbnz w0,.Lresolution_return
 ldr w9,[x19,#5172]
 cmp w9,#1280
 cset w9,gt
 str w9,[x20,#272]
 eor w10,w9,#1
 str w10,[x20,#276]
 str w10,[x20,#280]
 str wzr,[x20,#284]
 mov x9,#0
 add x10,sp,#64
.Lresolution_zero_arguments:
 str xzr,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#24
 b.lo .Lresolution_zero_arguments
 mov x9,#5172
 add x9,x19,x9
 str x9,[sp,#64]
 mov x9,#4872
 add x9,x19,x9
 str x9,[sp,#72]
 add x9,sp,#256
 str x9,[sp,#88]
 add x9,x20,#296
 str x9,[sp,#96]
 mov x9,#5168
 add x9,x19,x9
 str x9,[sp,#120]
 add x9,x20,#276
 str x9,[sp,#144]
 add x9,x20,#280
 str x9,[sp,#152]
 add x9,x20,#272
 str x9,[sp,#160]
 add x9,x20,#284
 str x9,[sp,#184]
 /* Pass precisely NLOENG(1:32), including a possible stored halo origin. */
 ldr x9,[x19,#7640]
 ldr x10,[x19,#7688]
 mov x11,#1
 sub x10,x11,x10
 add x9,x9,x10,lsl#2
 str x9,[sp,#256]
 mov x9,#-1
 str x9,[sp,#264]
 mov x9,#4
 str x9,[sp,#272]
 str x9,[sp,#288]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[sp,#280]
 mov x9,#1
 str x9,[sp,#296]
 str x9,[sp,#304]
 mov x9,#32
 str x9,[sp,#312]
 bl __errno_location
 str wzr,[x0]
 add x0,sp,#64
 bl md2asm_call_public_transform_setup
.Lresolution_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#384
 ret
.Lresolution_bad:
 mov w0,#2
 ret
.size md2asm_initialize_transform_resolution,.-md2asm_initialize_transform_resolution
.p2align 4
.global md2asm_release_transform_environment_metadata
.type md2asm_release_transform_environment_metadata,%function
md2asm_release_transform_environment_metadata:
 cbz x0,.Lenv_release_bad
 tst x0,#7
 b.ne .Lenv_release_bad
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#48]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 ldr x0,[x19,#120]
 cbz x0,.Lenv_release_second
 bl free
 str xzr,[x19,#120]
.Lenv_release_second:
 ldr x0,[x19,#184]
 cbz x0,.Lenv_released
 bl free
 str xzr,[x19,#184]
.Lenv_released:
 str w21,[x20]
 ldp x9,x10,[sp,#48]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#80
 mov w0,#0
 ret
.Lenv_release_bad:
 mov w0,#2
 ret
.size md2asm_release_transform_environment_metadata,.-md2asm_release_transform_environment_metadata
.section .note.GNU-stack,"",%progbits
.text
.p2align 4
.global md2asm_finish_external_transform_context
.type md2asm_finish_external_transform_context,%function
md2asm_finish_external_transform_context:
 cbz x0,.Lfinish_bad
 cbz x1,.Lfinish_bad
 stp x29,x30,[sp,#-48]!
 stp x19,x18,[sp,#16]
 mov x29,sp
 mov x19,x1
 mov x9,#5168
 add x0,x0,x9
 bl trans_release_
 str wzr,[sp,#32]
 mov x0,x19
 add x1,sp,#32
 bl __mpl_end_mod_MOD_mpl_end
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#48
 mov w0,#0
 ret
.Lfinish_bad:
 mov w0,#2
 ret
.size md2asm_finish_external_transform_context,.-md2asm_finish_external_transform_context
.text
.p2align 4
.global md2asm_initialize_owned_transform_context
.type md2asm_initialize_owned_transform_context,%function
md2asm_initialize_owned_transform_context:
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 /* Validate the second supported group before creating any external resource. */
 mov x0,x21
 mov x1,x22
 mov x2,#1
 bl md2asm_empty_transform_configuration_group
 cbnz w0,.Lcontext_transform_return
 mov x0,x20
 mov x1,x21
 mov x2,x22
 bl md2asm_initialize_transform_environment
 cbnz w0,.Lcontext_transform_return
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x22
 bl md2asm_initialize_transform_resolution
 cbz w0,.Lcontext_transform_return
 str w0,[sp,#56]
 mov x0,x20
 bl md2asm_release_transform_environment_metadata
 ldr w0,[sp,#56]
.Lcontext_transform_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldr x18,[sp,#48]
 ldp x29,x30,[sp],#80
 ret
.size md2asm_initialize_owned_transform_context,.-md2asm_initialize_owned_transform_context

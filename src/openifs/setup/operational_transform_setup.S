/* Operational owned public-transform setup.
 * Contract: skills/md2asm/references/openifs/setup/operational_transform_setup.md.
 * Main x0 Geometry[17096], x1 control[304], x2 text, x3 byte count.
 * The resolution phase requires truncation 1279 and 2560 reduced-grid rows.
 * Owned environment, public calls and lifecycle retain their frozen interfaces.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_transform_context
.type md2asm_initialize_operational_transform_context,%function
md2asm_initialize_operational_transform_context:
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 /* Validate NAMTRANS before creating any external resource. */
 mov x0,x21
 mov x1,x22
 mov x2,#1
 bl md2asm_operational_transform_configuration_group
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
 bl md2asm_initialize_operational_transform_resolution
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
.size md2asm_initialize_operational_transform_context,.-md2asm_initialize_operational_transform_context
.p2align 4
.global md2asm_initialize_operational_transform_resolution
.type md2asm_initialize_operational_transform_resolution,%function
md2asm_initialize_operational_transform_resolution:
 cbz x0,.Lresolution_bad
 cbz x1,.Lresolution_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lresolution_bad
 ldr w9,[x0,#5172]
 cmp w9,#1279
 b.ne .Lresolution_bad
 ldr w9,[x0,#4872]
 cmp w9,#2560
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
 bl md2asm_operational_transform_configuration_group
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
 /* Pass precisely NLOENG(1:2560), including a possible stored halo origin. */
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
 mov x9,#2560
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
.size md2asm_initialize_operational_transform_resolution,.-md2asm_initialize_operational_transform_resolution
.section .note.GNU-stack,"",%progbits

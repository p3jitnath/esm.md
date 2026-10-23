/* Contract: skills/md2asm/references/openifs/setup/operational_distributed_partition.md.
 * Internal stream872 in x0, live Geometry17096 in x1, int32 rank/processes in x2.
 * Source order and two owned copied arrays are preserved. Frame112 bytes.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_distributed_stream_geometry_metadata
.type md2asm_initialize_distributed_stream_geometry_metadata,%function
md2asm_initialize_distributed_stream_geometry_metadata:
 cbz x0,.Ldstream_bad
 cbz x1,.Ldstream_bad
 cbz x2,.Ldstream_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Ldstream_bad
 tst x2,#3
 b.ne .Ldstream_bad
 ldp w9,w10,[x2]
 cmp w9,#1
 b.lt .Ldstream_bad
 cmp w10,#4
 b.ne .Ldstream_bad
 cmp w9,w10
 b.gt .Ldstream_bad
 ldr x9,[x0,#64]
 ldr x10,[x0,#144]
 orr x9,x9,x10
 cbnz x9,.Ldstream_bad
 ldr w9,[x1,#5224]
 cmp w9,#137
 b.eq .Ldstream_operational
 cmp w9,#19
 b.ne .Ldstream_bad
 ldr w9,[x1,#5172]
 cmp w9,#21
 b.ne .Ldstream_bad
 ldr w9,[x1,#4872]
 cmp w9,#32
 b.ne .Ldstream_bad
 b .Ldstream_dimensions_ready
.Ldstream_operational:
 ldr w9,[x1,#5172]
 cmp w9,#1279
 b.ne .Ldstream_bad
 ldr w9,[x1,#4872]
 cmp w9,#2560
 b.ne .Ldstream_bad
.Ldstream_dimensions_ready:
 ldr w9,[x1,#7228]
 cmp w9,#2
 b.ne .Ldstream_bad
 ldr x9,[x1,#6584]
 ldr x10,[x1,#7640]
 cbz x9,.Ldstream_bad
 cbz x10,.Ldstream_bad
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 ldp w9,w10,[x2]
 stp w9,w10,[sp,#96]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#80]
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 mov x23,#0
.Ldstream_allocate:
 mov x24,#64
 ldrsw x25,[x20,#5224]
 cbz x23,.Ldstream_shape
 mov x24,#144
 ldrsw x25,[x20,#4872]
.Ldstream_shape:
 add x24,x19,x24
 lsl x0,x25,#2
 bl malloc
 cbz x0,.Ldstream_failure
 str x0,[x24]
 mov x9,#-1
 str x9,[x24,#8]
 mov x9,#4
 str x9,[x24,#16]
 str x9,[x24,#32]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[x24,#24]
 mov x9,#1
 stp x9,x9,[x24,#40]
 str x25,[x24,#56]
 mov x10,#6584
 cbz x23,.Ldstream_copy_source
 mov x10,#7640
.Ldstream_copy_source:
 ldr x10,[x20,x10]
 cbz x23,.Ldstream_copy_active
 ldr x11,[x20,#7688]
 mov x12,#1
 sub x11,x12,x11
 add x10,x10,x11,lsl#2
.Ldstream_copy_active:
 mov x9,#0
.Ldstream_copy:
 ldr w11,[x10,x9,lsl#2]
 str w11,[x0,x9,lsl#2]
 add x9,x9,#1
 cmp x9,x25
 b.lo .Ldstream_copy
 add x23,x23,#1
 cmp x23,#2
 b.lo .Ldstream_allocate
 mov w9,#0x80000001
 str w9,[x19]
 str wzr,[x19,#4]
 mov w9,#6
 str w9,[x19,#8]
 ldp w9,w10,[sp,#96]
 str w9,[x19,#12]
 str w10,[x19,#16]
 mov x9,#800
 lsl x9,x9,#16
 str x9,[x19,#24]
 lsr x9,x9,#1
 str x9,[x19,#32]
 adr x10,.Ldstream_constants
 ldp x9,x10,[x10]
 stp x9,x10,[x19,#40]
 mov w9,#8
 mov w10,#4
 stp w9,w10,[x19,#56]
 ldr w9,[x20,#7228]
 str w9,[x19,#128]
 ldr w9,[x20,#5224]
 str w9,[x19,#132]
 ldr w9,[x20,#5172]
 str w9,[x19,#136]
 ldr w9,[x20,#4872]
 str w9,[x19,#140]
 str wzr,[x19,#864]
 str w22,[x21]
 mov w0,#0
 b .Ldstream_return
.Ldstream_failure:
 ldr x0,[x19,#64]
 cbz x0,.Ldstream_free_second
 bl free
 str xzr,[x19,#64]
.Ldstream_free_second:
 ldr x0,[x19,#144]
 cbz x0,.Ldstream_failed
 bl free
 str xzr,[x19,#144]
.Ldstream_failed:
 str w22,[x21]
 mov w0,#1
.Ldstream_return:
 ldp x9,x10,[sp,#80]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.Ldstream_bad:
 mov w0,#2
 ret
.size md2asm_initialize_distributed_stream_geometry_metadata,.-md2asm_initialize_distributed_stream_geometry_metadata
.section .rodata
.p2align 3
.Ldstream_constants:
 .quad 0x400921fb54442d18
 .quad 0x40f86a0000000000
.section .note.GNU-stack,"",%progbits

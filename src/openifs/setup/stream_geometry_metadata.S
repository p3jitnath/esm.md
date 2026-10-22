/* Contract: skills/md2asm/references/openifs/setup/stream_geometry_metadata_contract.md.
 * x0 owned stream[872], x1 owned Geometry[17096], x2 int32 {rank,processes}.
 * Selected first initialization owns two copied integer arrays. Frame112B.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_stream_geometry_metadata
.type md2asm_initialize_stream_geometry_metadata,%function
md2asm_initialize_stream_geometry_metadata:
 cbz x0,.Lstream_bad
 cbz x1,.Lstream_bad
 cbz x2,.Lstream_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lstream_bad
 tst x2,#3
 b.ne .Lstream_bad
 ldp w9,w10,[x2]
 cmp w9,#1
 b.ne .Lstream_bad
 cmp w10,#1
 b.ne .Lstream_bad
 ldr x9,[x0,#64]
 ldr x10,[x0,#144]
 orr x9,x9,x10
 cbnz x9,.Lstream_bad
 ldr w9,[x1,#5224]
 cmp w9,#137
 b.eq .Lstream_operational
 cmp w9,#19
 b.ne .Lstream_bad
 ldr w9,[x1,#5172]
 cmp w9,#21
 b.ne .Lstream_bad
 ldr w9,[x1,#4872]
 cmp w9,#32
 b.ne .Lstream_bad
 b .Lstream_dimensions_ready
.Lstream_operational:
 ldr w9,[x1,#5172]
 cmp w9,#1279
 b.ne .Lstream_bad
 ldr w9,[x1,#4872]
 cmp w9,#2560
 b.ne .Lstream_bad
.Lstream_dimensions_ready:
 ldr w9,[x1,#7228]
 cmp w9,#1
 b.ne .Lstream_bad
 ldr x9,[x1,#6584]
 ldr x10,[x1,#7640]
 cbz x9,.Lstream_bad
 cbz x10,.Lstream_bad
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#80]
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 mov x23,#0
.Lstream_allocate:
 mov x24,#64
 ldrsw x25,[x20,#5224]
 cbz x23,.Lstream_shape
 mov x24,#144
 ldrsw x25,[x20,#4872]
.Lstream_shape:
 add x24,x19,x24
 lsl x0,x25,#2
 bl malloc
 cbz x0,.Lstream_failure
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
 cbz x23,.Lstream_copy_source
 mov x10,#7640
.Lstream_copy_source:
 ldr x10,[x20,x10]
 cbz x23,.Lstream_copy_active
 ldr x11,[x20,#7688]
 mov x12,#1
 sub x11,x12,x11
 add x10,x10,x11,lsl#2
.Lstream_copy_active:
 mov x9,#0
.Lstream_copy:
 ldr w11,[x10,x9,lsl#2]
 str w11,[x0,x9,lsl#2]
 add x9,x9,#1
 cmp x9,x25
 b.lo .Lstream_copy
 add x23,x23,#1
 cmp x23,#2
 b.lo .Lstream_allocate
 mov w9,#0x80000001
 str w9,[x19]
 str wzr,[x19,#4]
 mov w9,#6
 str w9,[x19,#8]
 mov w9,#1
 str w9,[x19,#12]
 str w9,[x19,#16]
 mov x9,#800
 lsl x9,x9,#16
 str x9,[x19,#24]
 lsr x9,x9,#1
 str x9,[x19,#32]
 adr x10,.Lstream_constants
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
 b .Lstream_return
.Lstream_failure:
 ldr x0,[x19,#64]
 cbz x0,.Lstream_free_second
 bl free
 str xzr,[x19,#64]
.Lstream_free_second:
 ldr x0,[x19,#144]
 cbz x0,.Lstream_failed
 bl free
 str xzr,[x19,#144]
.Lstream_failed:
 str w22,[x21]
 mov w0,#1
.Lstream_return:
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
.Lstream_bad:
 mov w0,#2
 ret
.size md2asm_initialize_stream_geometry_metadata,.-md2asm_initialize_stream_geometry_metadata
.p2align 4
.global md2asm_release_stream_geometry_metadata
.type md2asm_release_stream_geometry_metadata,%function
md2asm_release_stream_geometry_metadata:
 cbz x0,.Lstream_bad_release
 tst x0,#7
 b.ne .Lstream_bad_release
 stp x29,x30,[sp,#-64]!
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
 ldr x0,[x19,#64]
 cbz x0,.Lstream_release_second
 bl free
 str xzr,[x19,#64]
.Lstream_release_second:
 ldr x0,[x19,#144]
 cbz x0,.Lstream_released
 bl free
 str xzr,[x19,#144]
.Lstream_released:
 str w21,[x20]
 ldp x9,x10,[sp,#48]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp],#64
 mov w0,#0
 ret
.Lstream_bad_release:
 mov w0,#2
 ret
.size md2asm_release_stream_geometry_metadata,.-md2asm_release_stream_geometry_metadata
.section .rodata
.p2align 3
.Lstream_constants:
 .quad 0x400921fb54442d18
 .quad 0x40f86a0000000000
.section .note.GNU-stack,"",%progbits

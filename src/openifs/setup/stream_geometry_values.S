/* Contract: skills/md2asm/references/openifs/setup/stream_geometry_values.md. x0 stream872, x1 Geometry17096,
 * w2 mode0 half-level coefficients or1 physical latitudes. First association.
 * Copy exact stored bits, translate the true source lower bound, own new buffers.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_copy_stream_geometry_values
.type md2asm_copy_stream_geometry_values,%function
md2asm_copy_stream_geometry_values:
 cbz x0,.Lsv_bad
 cbz x1,.Lsv_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lsv_bad
 cmp w2,#1
 b.hi .Lsv_bad
 ldr w9,[x1,#5224]
 cmp w9,#19
 b.ne .Lsv_bad
 ldr w9,[x1,#4872]
 cmp w9,#32
 b.ne .Lsv_bad
 sub sp,sp,#144
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov w21,w2
 mov x22,#0
 mov x23,#2
 cbz w21,.Lsv_preflight
 mov x23,#1
.Lsv_preflight:
 bl .Lsv_select
 ldr x9,[x24]
 cbnz x9,.Lsv_reject
 ldr x9,[x25]
 cbz x9,.Lsv_reject
 tst x9,#7
 b.ne .Lsv_reject
 ldr x10,[x25,#16]
 cmp x10,#8
 b.ne .Lsv_reject
 ldr x10,[x25,#24]
 mov x11,#0x301
 lsl x11,x11,#32
 cmp x10,x11
 b.ne .Lsv_reject
 ldr x10,[x25,#32]
 cmp x10,#8
 b.ne .Lsv_reject
 ldp x10,x11,[x25,#40]
 cmp x10,#1
 b.ne .Lsv_reject
 ldr x12,[x25,#8]
 adds x12,x12,x11
 b.ne .Lsv_reject
 ldr x12,[x25,#56]
 cbnz w21,.Lsv_lat_bounds
 cmp x11,#0
 b.ne .Lsv_reject
 cmp x12,#19
 b.ne .Lsv_reject
 b .Lsv_checked
.Lsv_lat_bounds:
 cmp x11,#1
 b.gt .Lsv_reject
 cmp x12,#32
 b.lt .Lsv_reject
.Lsv_checked:
 add x22,x22,#1
 cmp x22,x23
 b.lo .Lsv_preflight
 bl __errno_location
 mov x26,x0
 ldr w27,[x26]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#96]
 mov x22,#0
.Lsv_allocate:
 bl .Lsv_select
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lsv_failed
 str x0,[x24]
 mov x9,#-1
 str x9,[x24,#8]
 mov x9,#8
 str x9,[x24,#16]
 str x9,[x24,#32]
 mov x9,#0x301
 lsl x9,x9,#32
 str x9,[x24,#24]
 mov x9,#1
 stp x9,x9,[x24,#40]
 mov x9,#20
 cbz w21,.Lsv_count
 mov x9,#32
.Lsv_count:
 str x9,[x24,#56]
 ldr x10,[x25]
 ldr x11,[x25,#48]
 neg x11,x11
 cbz w21,.Lsv_origin
 add x11,x11,#1
.Lsv_origin:
 add x10,x10,x11,lsl#3
 mov x11,#0
.Lsv_copy:
 ldr x12,[x10,x11,lsl#3]
 str x12,[x0,x11,lsl#3]
 add x11,x11,#1
 cmp x11,x9
 b.lo .Lsv_copy
 add x22,x22,#1
 cmp x22,x23
 b.lo .Lsv_allocate
 mov w20,#0
 b .Lsv_status
.Lsv_failed:
 mov x22,#0
.Lsv_failure_free:
 bl .Lsv_select
 ldr x0,[x24]
 cbz x0,.Lsv_failure_next
 bl free
 str xzr,[x24]
.Lsv_failure_next:
 add x22,x22,#1
 cmp x22,x23
 b.lo .Lsv_failure_free
 mov w20,#1
.Lsv_status:
 str w27,[x26]
 ldp x9,x10,[sp,#96]
 msr fpcr,x9
 msr fpsr,x10
 b .Lsv_return
.Lsv_reject:
 mov w20,#2
.Lsv_return:
 mov w0,w20
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.Lsv_select:
 mov x0,#20
 add x24,x19,#208
 add x25,x20,#144
 cbnz w21,.Lsv_select_lat
 cbz x22,.Lsv_select_return
 add x24,x19,#272
 add x25,x20,#80
.Lsv_select_return:
 ret
.Lsv_select_lat:
 mov x0,#32
 add x24,x19,#336
 mov x25,#4744
 add x25,x20,x25
 ret
.Lsv_bad:
 mov w0,#2
 ret
.size md2asm_copy_stream_geometry_values,.-md2asm_copy_stream_geometry_values
.global md2asm_release_stream_geometry_values
.type md2asm_release_stream_geometry_values,%function
md2asm_release_stream_geometry_values:
 cbz x0,.Lsv_bad
 tst x0,#7
 b.ne .Lsv_bad
 sub sp,sp,#80
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#48]
 bl __errno_location
 mov x20,x0
 ldr w9,[x20]
 str w9,[sp,#64]
 mov x21,#208
.Lsv_release_loop:
 ldr x0,[x19,x21]
 cbz x0,.Lsv_release_next
 bl free
 str xzr,[x19,x21]
.Lsv_release_next:
 add x21,x21,#64
 cmp x21,#336
 b.ls .Lsv_release_loop
 ldr w9,[sp,#64]
 str w9,[x20]
 ldp x9,x10,[sp,#48]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.size md2asm_release_stream_geometry_values,.-md2asm_release_stream_geometry_values
.section .note.GNU-stack,"",%progbits

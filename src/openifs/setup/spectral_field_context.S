/* Contract: skills/md2asm/references/openifs/setup/spectral_field_storage.md. */
/* Owned outer SPECTRAL_FIELD context; no original metadata or module input.
 * create(w0 levels,w1 trunc,x2 IDs5,x3 output pointer)->w0=0/1/2.
 * The 3024-byte context owns the 2992-byte source record, three dummy words and an 8-byte marker.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_serial_spectral_field
.type md2asm_create_serial_spectral_field,%function
md2asm_create_serial_spectral_field:
 cmp w1,#1279
 b.ne .Lspec_context_legacy_dimensions
 cmp w0,#137
 b.eq .Lspec_context_dimensions_ready
.Lspec_context_legacy_dimensions:
 sub w9,w0,#1
 cmp w9,#63
 b.hi .Lspec_context_reject
 cmp w1,#63
 b.hi .Lspec_context_reject
.Lspec_context_dimensions_ready:
 cbz x2,.Lspec_context_reject
 cbz x3,.Lspec_context_reject
 tst x2,#3
 b.ne .Lspec_context_reject
 tst x3,#7
 b.ne .Lspec_context_reject
 mrs x9,fpcr
 cbnz x9,.Lspec_context_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov w20,w0
 mov w21,w1
 mov x22,x2
 mov x23,x3
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 mov x0,#3024
 bl malloc
 cbz x0,.Lspec_context_allocation_failed
 mov x19,x0
 mov x9,x0
 mov x10,#189
.Lspec_context_clear:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lspec_context_clear
 str w25,[x24]
 mov x0,x19
 mov w1,w20
 mov w2,w21
 mov x3,x22
 add x4,x19,#2992
 bl md2asm_initialize_serial_spectral_field
 cbnz w0,.Lspec_context_failed
 ldr x9,.Lspec_context_magic
 str x9,[x19,#3016]
 str x19,[x23]
 mov w0,#0
 b .Lspec_context_return
.Lspec_context_failed:
 str w0,[sp,#80]
 mov x0,x19
 bl md2asm_release_serial_spectral_field
 mov x0,x19
 bl free
 ldr w0,[sp,#80]
 b .Lspec_context_return
.Lspec_context_allocation_failed:
 mov w0,#1
.Lspec_context_return:
 str w25,[x24]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lspec_context_reject:
 mov w0,#2
 ret
.size md2asm_create_serial_spectral_field,.-md2asm_create_serial_spectral_field
.p2align 4
.global md2asm_release_serial_spectral_field_context
.type md2asm_release_serial_spectral_field_context,%function
md2asm_release_serial_spectral_field_context:
 cbz x0,.Lspec_context_release_reject
 tst x0,#7
 b.ne .Lspec_context_release_reject
 ldr x9,[x0,#3016]
 ldr x10,.Lspec_context_magic
 cmp x9,x10
 b.ne .Lspec_context_release_reject
 sub sp,sp,#80
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mrs x9,fpcr
 str x9,[sp,#48]
 mrs x9,fpsr
 str x9,[sp,#56]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 str xzr,[x19,#3016]
 mov x0,x19
 bl md2asm_release_serial_spectral_field
 mov x0,x19
 bl free
 str w21,[x20]
 ldr x9,[sp,#48]
 msr fpcr,x9
 ldr x9,[sp,#56]
 msr fpsr,x9
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.Lspec_context_release_reject:
 mov w0,#2
 ret
.size md2asm_release_serial_spectral_field_context,.-md2asm_release_serial_spectral_field_context
.p2align 3
.Lspec_context_magic: .quad 0x4d44325350454331
.section .note.GNU-stack,"",%progbits

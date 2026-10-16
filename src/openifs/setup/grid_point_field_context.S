/* Contract: skills/md2asm/references/openifs/setup/grid_point_field_storage.md. */
/* Owned outer TGFL context; borrowed field configuration remains caller-owned.
 * create(x0 cfg7,x1 owned YGFL,x2 output pointer)->w0 status.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_gridpoint_field_context
.type md2asm_create_gridpoint_field_context,%function
md2asm_create_gridpoint_field_context:
 cbz x1,.Ltgfl_context_reject
 cbz x2,.Ltgfl_context_reject
 orr x9,x1,x2
 tst x9,#7
 b.ne .Ltgfl_context_reject
 cbz x0,.Ltgfl_context_reject
 tst x0,#3
 b.ne .Ltgfl_context_reject
 ldr w9,[x0]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Ltgfl_context_reject
 ldr w9,[x0,#4]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Ltgfl_context_reject
 ldr w9,[x0,#8]
 sub w9,w9,#1
 cmp w9,#127
 b.hi .Ltgfl_context_reject
 ldr w9,[x0,#12]
 cmp w9,#8
 b.ne .Ltgfl_context_reject
 ldr w9,[x0,#16]
 cmp w9,#2
 b.ne .Ltgfl_context_reject
 ldr w9,[x0,#20]
 cbnz w9,.Ltgfl_context_reject
 ldr w9,[x0,#24]
 cbnz w9,.Ltgfl_context_reject
 mrs x9,fpcr
 cbnz x9,.Ltgfl_context_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mrs x25,fpcr
 mrs x26,fpsr
 bl __errno_location
 mov x23,x0
 ldr w24,[x23]
 mov x0,#1104
 bl malloc
 cbz x0,.Ltgfl_context_failed
 mov x22,x0
 mov x9,#0
.Ltgfl_context_clear:
 str xzr,[x22,x9]
 add x9,x9,#8
 cmp x9,#1096
 b.lo .Ltgfl_context_clear
 mov x0,x22
 mov x1,x19
 mov x2,x20
 bl md2asm_initialize_gridpoint_field
 cbnz w0,.Ltgfl_context_child_failed
 adr x9,.Ltgfl_context_magic
 ldr x9,[x9]
 str x9,[x22,#1096]
 str x22,[x21]
 mov w0,#0
 b .Ltgfl_context_restore
.Ltgfl_context_child_failed:
 mov w20,w0
 mov x0,x22
 bl free
 mov w0,w20
 b .Ltgfl_context_restore
.Ltgfl_context_failed:
 mov w0,#1
.Ltgfl_context_restore:
 str w24,[x23]
 msr fpcr,x25
 msr fpsr,x26
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldr x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Ltgfl_context_reject:
 mov w0,#2
 ret
.size md2asm_create_gridpoint_field_context,.-md2asm_create_gridpoint_field_context

.p2align 4
.global md2asm_release_gridpoint_field_context
.type md2asm_release_gridpoint_field_context,%function
md2asm_release_gridpoint_field_context:
 cbz x0,.Ltgfl_context_release_reject
 tst x0,#7
 b.ne .Ltgfl_context_release_reject
 adr x9,.Ltgfl_context_magic
 ldr x9,[x9]
 ldr x10,[x0,#1096]
 cmp x9,x10
 b.ne .Ltgfl_context_release_reject
 sub sp,sp,#80
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mrs x22,fpcr
 mrs x23,fpsr
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 mov x0,x19
 bl md2asm_release_gridpoint_field
 str xzr,[x19,#1096]
 mov x0,x19
 bl free
 str w21,[x20]
 msr fpcr,x22
 msr fpsr,x23
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.Ltgfl_context_release_reject:
 mov w0,#2
 ret
.size md2asm_release_gridpoint_field_context,.-md2asm_release_gridpoint_field_context
.section .rodata
.p2align 3
.Ltgfl_context_magic: .quad 0x5447464c43545831
.section .note.GNU-stack,"",%progbits

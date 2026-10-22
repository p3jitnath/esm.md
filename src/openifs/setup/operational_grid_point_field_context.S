/* Owned operational TGFL context and four numerical arrays.
 * Create: x0 int32 controls[7], x1 borrowed namespace[1359136],
 * x2 output pointer[8]; return status in w0.
 * Controls: 17,137,388217,9,3,0,0. Release receives context in x0.
 * No zero stage, input loading or padding preparation.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_point_field_context.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_operational_gridpoint_field_context
.type md2asm_create_operational_gridpoint_field_context,%function
md2asm_create_operational_gridpoint_field_context:
 cbz x1,.Ltgfl_context_reject
 cbz x2,.Ltgfl_context_reject
 orr x9,x1,x2
 tst x9,#7
 b.ne .Ltgfl_context_reject
 cbz x0,.Ltgfl_context_reject
 tst x0,#3
 b.ne .Ltgfl_context_reject
 ldr w9,[x0]
 cmp w9,#17
 b.ne .Ltgfl_context_reject
 ldr w9,[x0,#4]
 cmp w9,#137
 b.ne .Ltgfl_context_reject
 ldr w9,[x0,#8]
 movz w10,#0xec79
 movk w10,#5,lsl#16
 cmp w9,w10
 b.ne .Ltgfl_context_reject
 ldr w9,[x0,#12]
 cmp w9,#9
 b.ne .Ltgfl_context_reject
 ldr w9,[x0,#16]
 cmp w9,#3
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
 bl md2asm_initialize_operational_gridpoint_field
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
.size md2asm_create_operational_gridpoint_field_context,.-md2asm_create_operational_gridpoint_field_context

.p2align 4
.global md2asm_release_operational_gridpoint_field_context
.type md2asm_release_operational_gridpoint_field_context,%function
md2asm_release_operational_gridpoint_field_context:
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
.size md2asm_release_operational_gridpoint_field_context,.-md2asm_release_operational_gridpoint_field_context
.section .rodata
.p2align 3
.Ltgfl_context_magic: .quad 0x5447464c43545831
.section .note.GNU-stack,"",%progbits

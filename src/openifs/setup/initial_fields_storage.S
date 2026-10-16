/* Own the stable initial FIELDS allocation and CNT0's MODEL association.
 * Contract skills/md2asm/references/openifs/setup/initial_fields_storage.md.
 * create(x0 MODEL4275088,x1 initially null owner8), release(x0 owner8).
 * All numerical/metadata children construct directly at final addresses. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_initial_fields_storage
.type md2asm_create_initial_fields_storage,%function
md2asm_create_initial_fields_storage:
 cbz x0,.Lfields_bad_leaf
 cbz x1,.Lfields_bad_leaf
 orr x2,x0,x1
 tst x2,#7
 b.ne .Lfields_bad_leaf
 movz x2,#(4275088&65535)
 movk x2,#(4275088>>16),lsl#16
 adds x2,x0,x2
 b.cs .Lfields_bad_leaf
 adds x3,x1,#8
 b.cs .Lfields_bad_leaf
 cmp x1,x2
 b.hs .Lfields_separate
 cmp x0,x3
 b.lo .Lfields_bad_leaf
.Lfields_separate:
 ldr x2,[x1]
 cbnz x2,.Lfields_bad_leaf
 mrs x2,fpcr
 cbnz x2,.Lfields_bad_leaf
 stp x29,x30,[sp,#-80]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 bl __errno_location
 mov x21,x0
 ldr w22,[x0]
 mov x0,#1
 movz x1,#(529288&65535)
 movk x1,#(529288>>16),lsl#16
 bl calloc
 cbz x0,.Lfields_allocation_failed
 str x19,[x0,#1840]
 str x0,[x20]
 mov w0,#0
 b .Lfields_create_return
.Lfields_allocation_failed:
 mov w0,#1
.Lfields_create_return:
 str w22,[x21]
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp],#80
 ret
.Lfields_bad_leaf:
 mov w0,#2
 ret
.size md2asm_create_initial_fields_storage,.-md2asm_create_initial_fields_storage
.p2align 4
.global md2asm_release_initial_fields_storage
.type md2asm_release_initial_fields_storage,%function
/* Caller releases all embedded owners first and keeps MODEL alive. */
md2asm_release_initial_fields_storage:
 cbz x0,.Lfields_bad_leaf
 tst x0,#7
 b.ne .Lfields_bad_leaf
 adds x1,x0,#8
 b.cs .Lfields_bad_leaf
 ldr x1,[x0]
 cbz x1,.Lfields_empty_release
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 bl __errno_location
 mov x21,x0
 ldr w22,[x0]
 mov x0,x20
 bl free
 str xzr,[x19]
 str w22,[x21]
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp],#64
.Lfields_empty_release:
 mov w0,#0
 ret
.size md2asm_release_initial_fields_storage,.-md2asm_release_initial_fields_storage
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/vertical_startup_context.md. */
/* Assembly-owned persistent vertical startup context.
 * Create: x0 A[20],x1 B[20],x2 writable output context pointer,x3 config[4].
 * Config int32 order: levels,ECMWF,nonhydrostatic,two-dimensional;19,1,0,0.
 * All input buffers are aligned,mapped,disjoint. w0=0,1 allocation,2 input.
 * A context owns Geometry17096B, two201-word outputs,three pressure words,
 * five output addresses,config16B and a lifetime marker;20400B total.
 * No original module data, type record, vtable, callable or harness is used.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_vertical_startup_context
.type md2asm_create_vertical_startup_context,%function
md2asm_create_vertical_startup_context:
 cbz x0,.Lowned_vertical_reject
 cbz x1,.Lowned_vertical_reject
 cbz x2,.Lowned_vertical_reject
 cbz x3,.Lowned_vertical_reject
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lowned_vertical_reject
 adds x9,x0,#160
 b.cs .Lowned_vertical_reject
 adds x9,x1,#160
 b.cs .Lowned_vertical_reject
 adds x9,x2,#8
 b.cs .Lowned_vertical_reject
 adds x9,x3,#16
 b.cs .Lowned_vertical_reject
 mrs x9,fpcr
 cbnz x9,.Lowned_vertical_reject
 ldp w9,w10,[x3]
 cmp w9,#19
 b.ne .Lowned_vertical_reject
 cmp w10,#1
 b.ne .Lowned_vertical_reject
 ldp w9,w10,[x3,#8]
 orr w9,w9,w10
 cbnz w9,.Lowned_vertical_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x20,x0
 mov x21,x1
 mov x22,x2
 mov x23,x3
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 mov x0,#20400
 bl malloc
 cbz x0,.Lowned_vertical_allocation_failed
 mov x19,x0
 mov x9,x0
 mov x10,#1275
.Lowned_vertical_zero_record:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lowned_vertical_zero_record
 /* Empty descriptors and declaration RLAPL2PI=0 now have owned storage.
  * Other Geometry components remain unconstructed canonical scratch. */
 ldp x9,x10,[x23]
 str x9,[x19,#20376]
 str x10,[x19,#20384]
 add x9,x19,#8
 str x9,[x19]
 add x9,x19,#3024
 str x9,[x19,#3264]
 mov w10,#19
 str w10,[x19,#5224]
 str w10,[x19,#5252]
 mov x0,x9
 mov w1,#1
 mov w2,#0
 mov w3,#0
 bl md2asm_initialize_vertical_configuration
 cbnz w0,.Lowned_vertical_child_failed
 add x9,x19,#4,lsl#12
 add x9,x9,#3952
 add x10,x19,#4,lsl#12
 add x10,x10,#712
 str x10,[x9]
 add x10,x19,#4,lsl#12
 add x10,x10,#2320
 str x10,[x9,#8]
 add x10,x19,#4,lsl#12
 add x10,x10,#3928
 str x10,[x9,#16]
 add x10,x10,#8
 str x10,[x9,#24]
 add x10,x10,#8
 str x10,[x9,#32]
 str w25,[x24]
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x9
 bl md2asm_initialize_vertical_coordinate_setup
 cbnz w0,.Lowned_vertical_child_failed
 ldr x9,.Lowned_vertical_magic
 str x9,[x19,#20392]
 str x19,[x22]
 mov w0,#0
 b .Lowned_vertical_return
.Lowned_vertical_child_failed:
 str w0,[sp,#80]
 mov x0,x19
 bl md2asm_release_vertical_coordinate_setup
 mov x0,x19
 bl free
 ldr w0,[sp,#80]
 b .Lowned_vertical_return
.Lowned_vertical_allocation_failed:
 mov w0,#1
.Lowned_vertical_return:
 str w25,[x24]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lowned_vertical_reject:
 mov w0,#2
 ret
.size md2asm_create_vertical_startup_context,.-md2asm_create_vertical_startup_context
.p2align 4
.global md2asm_release_vertical_startup_context
.type md2asm_release_vertical_startup_context,%function
md2asm_release_vertical_startup_context:
 cbz x0,.Lowned_vertical_release_reject
 tst x0,#7
 b.ne .Lowned_vertical_release_reject
 ldr x9,[x0,#20392]
 ldr x10,.Lowned_vertical_magic
 cmp x9,x10
 b.ne .Lowned_vertical_release_reject
 sub sp,sp,#80
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mrs x9,fpcr
 str x9,[sp,#48]
 mrs x9,fpsr
 str x9,[sp,#56]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 str xzr,[x19,#20392]
 mov x0,x19
 bl md2asm_release_vertical_coordinate_setup
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
.Lowned_vertical_release_reject:
 mov w0,#2
 ret
.size md2asm_release_vertical_startup_context,.-md2asm_release_vertical_startup_context
.p2align 3
.Lowned_vertical_magic: .quad 0x4d44325645525431
.section .note.GNU-stack,"",%progbits

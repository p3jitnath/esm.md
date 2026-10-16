/* Own the five normal-mode arrays from SUALDYN lines 103 through 112.
 * Contract skills/md2asm/references/openifs/dynamics/semi_implicit_mode_setup.md.
 * Allocate(Geometry,capacity,MODEL,capacity). Release(MODEL,capacity).
 * Return zero, one for allocation failure, or two for invalid input. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_semi_implicit_mode_storage
.type md2asm_allocate_semi_implicit_mode_storage,%function
md2asm_allocate_semi_implicit_mode_storage:
 cbz x0,.Lmode_storage_bad
 cbz x2,.Lmode_storage_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lmode_storage_bad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lmode_storage_bad
 adds x10,x0,x9
 b.cs .Lmode_storage_bad
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x3,x9
 b.lo .Lmode_storage_bad
 adds x11,x2,x9
 b.cs .Lmode_storage_bad
 cmp x10,x2
 b.ls .Lmode_storage_disjoint
 cmp x11,x0
 b.hi .Lmode_storage_bad
.Lmode_storage_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lmode_storage_bad
 mov x9,#5224
 ldr w9,[x0,x9]
 sub w10,w9,#1
 cmp w10,#254
 b.hi .Lmode_storage_bad
 adr x10,.Lmode_offsets
 mov x11,#0
.Lmode_storage_empty:
 ldr w12,[x10,x11,lsl#2]
 ldr x13,[x2,x12]
 cbnz x13,.Lmode_storage_bad
 add x11,x11,#1
 cmp x11,#5
 b.lo .Lmode_storage_empty
 sub sp,sp,#160
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x2
 mov x20,x9
 mov x21,#0
 add x22,sp,#80
.Lmode_storage_allocate:
 mul x0,x20,x20
 cmp x21,#3
 csel x0,x20,x0,eq
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lmode_storage_rollback
 str x0,[x22,x21,lsl#3]
 add x21,x21,#1
 cmp x21,#5
 b.lo .Lmode_storage_allocate
 mov x21,#0
.Lmode_storage_publish:
 adr x9,.Lmode_offsets
 ldr w9,[x9,x21,lsl#2]
 add x0,x19,x9
 ldr x1,[x22,x21,lsl#3]
 mov x2,x20
 mov x3,#2
 mov x4,#1
 cmp x21,#3
 csel x3,x4,x3,eq
 bl .Lmode_storage_descriptor
 add x21,x21,#1
 cmp x21,#5
 b.lo .Lmode_storage_publish
 mov w0,#0
 b .Lmode_storage_return
.Lmode_storage_rollback:
 cbz x21,.Lmode_storage_failed
 sub x21,x21,#1
 ldr x0,[x22,x21,lsl#3]
 bl free
 b .Lmode_storage_rollback
.Lmode_storage_failed:
 mov w0,#1
.Lmode_storage_return:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#160
 ret
.Lmode_storage_descriptor:
 str x1,[x0]
 mov x9,#-1
 cmp x3,#2
 sub x10,x9,x2
 csel x9,x10,x9,eq
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str wzr,[x0,#24]
 add w10,w3,#0x300
 strh w10,[x0,#28]
 strh wzr,[x0,#30]
 str x9,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x2,[x0,#56]
 cmp x3,#2
 b.ne .Lmode_storage_descriptor_done
 stp x2,x9,[x0,#64]
 str x2,[x0,#80]
.Lmode_storage_descriptor_done:
 ret
.Lmode_storage_bad:
 mov w0,#2
 ret
.size md2asm_allocate_semi_implicit_mode_storage,.-md2asm_allocate_semi_implicit_mode_storage
.p2align 4
.global md2asm_release_semi_implicit_mode_storage
.type md2asm_release_semi_implicit_mode_storage,%function
md2asm_release_semi_implicit_mode_storage:
 cbz x0,.Lmode_storage_bad
 tst x0,#7
 b.ne .Lmode_storage_bad
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lmode_storage_bad
 adds x9,x0,x9
 b.cs .Lmode_storage_bad
 stp x18,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 mov x19,x0
 mov x20,#5
.Lmode_storage_release:
 sub x20,x20,#1
 adr x9,.Lmode_offsets
 ldr w9,[x9,x20,lsl#2]
 add x9,x19,x9
 ldr x0,[x9]
 cbz x0,.Lmode_storage_release_next
 str xzr,[x9]
 bl free
.Lmode_storage_release_next:
 cbnz x20,.Lmode_storage_release
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#48
 ret
.size md2asm_release_semi_implicit_mode_storage,.-md2asm_release_semi_implicit_mode_storage
.section .rodata
.p2align 2
.Lmode_offsets: .word 1567640,1567728,1567816,1567904,1569224
.section .note.GNU-stack,"",%progbits

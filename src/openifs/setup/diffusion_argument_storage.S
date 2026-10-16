/* Source-owned inactive-diffusion argument buffers from SUALDYNB.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity. Return 0, 1 or 2.
 * Contract skills/md2asm/references/openifs/dynamics/diffusion_argument_storage.md.
 * Both rank-one owners are published together. Their payloads are unwritten. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_allocate_diffusion_argument_storage
.type md2asm_allocate_diffusion_argument_storage,%function
md2asm_allocate_diffusion_argument_storage:
 cbz x0,.Lbad
 cbz x2,.Lbad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lbad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 mov x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x3,x9
 b.lo .Lbad
 adds x11,x2,x9
 b.cs .Lbad
 cmp x10,x2
 b.ls .Ldisjoint
 cmp x11,x0
 b.hi .Lbad
.Ldisjoint:
 mrs x9,fpcr
 cbnz x9,.Lbad
 MADDR x9,x2,1564212
 ldr w10,[x9]
 cbnz w10,.Lbad
 mov x9,#7376
 ldr w9,[x0,x9]
 sub w10,w9,#1
 cmp w10,#256,lsl#12
 b.hs .Lbad
 MADDR x10,x2,1565872
 ldr x11,[x10]
 cbnz x11,.Lbad
 MADDR x10,x2,1565968
 ldr x11,[x10]
 cbnz x11,.Lbad
 sub sp,sp,#256
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x2
 mov x20,x9
 MADDR x21,x19,1565872
 MADDR x22,x19,1565968
 lsl x0,x20,#3
 bl malloc
 cbz x0,.Lfailed
 mov x23,x0
 lsl x0,x20,#3
 bl malloc
 cbz x0,.Lrollback
 mov x24,x0
 /* Build only the source-defined GNU rank-one descriptor fields. */
 add x9,sp,#96
 mov x10,x21
 mov x11,x23
 bl .Ldescriptor
 add x9,sp,#160
 mov x10,x22
 mov x11,x24
 bl .Ldescriptor
 add x9,sp,#96
 mov x10,x21
 mov x11,#64
 bl .Lcopy
 add x9,sp,#160
 mov x10,x22
 mov x11,#64
 bl .Lcopy
 mov w0,#0
 b .Ldone
.Lrollback:
 mov x0,x23
 bl free
.Lfailed:
 mov w0,#1
.Ldone:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#256
 ret
.Ldescriptor:
 /* x9 scratch descriptor, x10 original descriptor, x11 new owner. */
 ldp x12,x13,[x10]
 stp x12,x13,[x9]
 ldp x12,x13,[x10,#16]
 stp x12,x13,[x9,#16]
 ldp x12,x13,[x10,#32]
 stp x12,x13,[x9,#32]
 ldp x12,x13,[x10,#48]
 stp x12,x13,[x9,#48]
 str x11,[x9]
 mov x12,#-1
 str x12,[x9,#8]
 mov x12,#8
 str x12,[x9,#16]
 str wzr,[x9,#24]
 mov w12,#0x301
 strh w12,[x9,#28]
 strh wzr,[x9,#30]
 mov x12,#8
 str x12,[x9,#32]
 mov x12,#1
 stp x12,x12,[x9,#40]
 str x20,[x9,#56]
 ret
.Lcopy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Lcopy
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_allocate_diffusion_argument_storage,.-md2asm_allocate_diffusion_argument_storage
.p2align 4
.global md2asm_release_diffusion_argument_storage
.type md2asm_release_diffusion_argument_storage,%function
md2asm_release_diffusion_argument_storage:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 mov x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 stp x18,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 mov x19,x0
 MADDR x20,x19,1565968
 ldr x0,[x20]
 cbz x0,.Lrelease_first
 str xzr,[x20]
 bl free
.Lrelease_first:
 MADDR x20,x19,1565872
 ldr x0,[x20]
 cbz x0,.Lreleased
 str xzr,[x20]
 bl free
.Lreleased:
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#48
 ret
.size md2asm_release_diffusion_argument_storage,.-md2asm_release_diffusion_argument_storage
.section .note.GNU-stack,"",%progbits

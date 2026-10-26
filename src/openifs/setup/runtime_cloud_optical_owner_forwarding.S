/* Contract: skills/md2asm/references/openifs/setup/runtime_cloud_optical_owner_forwarding.md.
 * x0 Geometry20400,x1 capacity,x2 MODEL4275088,x3 capacity; int0/2.
 * Forward actual source controls to complete SUCLOPN then SU_CLOP550.
 * One explicit existing48B namespace, no heap allocation or source fallback. */
.arch armv8.2-a
.text
.p2align 4
.macro VALUE reg,n
 movz \reg,#(\n&65535)
 movk \reg,#(\n>>16),lsl#16
.endm
.global md2asm_initialize_runtime_cloud_optical_from_owners
.type md2asm_initialize_runtime_cloud_optical_from_owners,%function
md2asm_initialize_runtime_cloud_optical_from_owners:
 cbz x0,.Lforward_bad
 cbz x2,.Lforward_bad
 orr x8,x0,x2
 tst x8,#7
 b.ne .Lforward_bad
 mov x8,#20400
 cmp x1,x8
 b.lo .Lforward_bad
 adds x9,x0,x8
 b.cs .Lforward_bad
 VALUE x8,4275088
 cmp x3,x8
 b.lo .Lforward_bad
 adds x10,x2,x8
 b.cs .Lforward_bad
 cmp x0,x10
 b.hs .Lforward_GM_clear
 cmp x2,x9
 b.lo .Lforward_bad
.Lforward_GM_clear:
 adrp x8,:got:md2asm_owned_cloud_optical_550_parameters
 ldr x8,[x8,:got_lo12:md2asm_owned_cloud_optical_550_parameters]
 cbz x8,.Lforward_bad
 tst x8,#7
 b.ne .Lforward_bad
 adds x11,x8,#48
 b.cs .Lforward_bad
 cmp x8,x9
 b.hs .Lforward_diag_G_clear
 cmp x0,x11
 b.lo .Lforward_bad
.Lforward_diag_G_clear:
 cmp x8,x10
 b.hs .Lforward_diag_M_clear
 cmp x2,x11
 b.lo .Lforward_bad
.Lforward_diag_M_clear:
 ldr x9,[x2,#8]
 cmp x9,x0
 b.ne .Lforward_bad
 mrs x9,fpcr
 cbnz x9,.Lforward_bad
 VALUE x9,4144588
 ldr w10,[x2,x9]
 cbnz w10,.Lforward_bad
 VALUE x9,4144600
 ldr w10,[x2,x9]
 cbnz w10,.Lforward_bad
 mov x9,#5224
 ldr w10,[x0,x9]
 cmp w10,#1
 b.lo .Lforward_bad
 cmp w10,#256
 b.hi .Lforward_bad
 stp x29,x30,[sp,#-112]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x18,x21,[sp,#32]
 mov x19,x0
 mov x20,x2
 mov x21,x8
 /* No public state is changed while the private inputs are formed. */
 VALUE x9,1608808
 ldr w8,[x20,x9]
 VALUE x9,1608788
 ldr w9,[x20,x9]
 stp w8,w9,[sp,#48]
 str w10,[sp,#56]
 str wzr,[sp,#60]
 VALUE x9,1608728
 add x8,x20,x9
 mov x9,#2040
 stp x8,x9,[sp,#64]
 VALUE x9,1610768
 add x8,x20,x9
 mov x9,#10744
 stp x8,x9,[sp,#80]
 mov x9,#48
 stp x21,x9,[sp,#96]
 add x0,sp,#48
 add x1,sp,#64
 bl md2asm_initialize_runtime_cloud_optical_parameters
 ldp x18,x21,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.Lforward_bad:
 mov w0,#2
 ret
.size md2asm_initialize_runtime_cloud_optical_from_owners,.-md2asm_initialize_runtime_cloud_optical_from_owners
.section .note.GNU-stack,"",%progbits

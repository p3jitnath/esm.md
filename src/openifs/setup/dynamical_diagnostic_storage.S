/* Selected source SUNDDH controls and complete SUALDYN_DDH storage.
 * Contract skills/md2asm/references/openifs/dynamics/dynamical_diagnostic_storage.md.
 * Owned records and declared array extents remain mapped until release. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_initialize_dynamical_diagnostic_controls
.type md2asm_initialize_dynamical_diagnostic_controls,%function
md2asm_initialize_dynamical_diagnostic_controls:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 MADDR x9,xzr,4275088
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 cbz x2,.Lbad
 cbz x3,.Lbad
 adds x11,x2,x3
 b.cs .Lbad
 cmp x10,x2
 b.ls .Lcontrols_disjoint
 cmp x11,x0
 b.hi .Lbad
.Lcontrols_disjoint:
 stp x18,x30,[sp,#-32]!
 stp x19,x20,[sp,#16]
 mov x19,x0
 mov x0,x2
 mov x1,x3
 adr x2,.Lgroup
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcontrols_done
 MADDR x9,x19,4233016
 stp wzr,wzr,[x9]
 str wzr,[x9,#8]
 /* SUNDDH850 combines the three admitted source defaults. */
 MADDR x9,x19,4233012
 str wzr,[x9]
.Lcontrols_done:
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#32
 ret
.size md2asm_initialize_dynamical_diagnostic_controls,.-md2asm_initialize_dynamical_diagnostic_controls
/* This leaf retains x0 through x3 and x16. */
.Lvalidate:
 mov w9,#2
 cbz x0,.Lvalidated
 cbz x2,.Lvalidated
 orr x10,x0,x2
 tst x10,#7
 b.ne .Lvalidated
 mov x10,#17096
 cmp x1,x10
 b.lo .Lvalidated
 adds x11,x0,x10
 b.cs .Lvalidated
 MADDR x10,xzr,4275088
 cmp x3,x10
 b.lo .Lvalidated
 adds x12,x2,x10
 b.cs .Lvalidated
 cmp x11,x2
 b.ls .Ldisjoint
 cmp x12,x0
 b.hi .Lvalidated
.Ldisjoint:
 MADDR x10,x2,4233012
 ldr w10,[x10]
 cbnz w10,.Lvalidated
 MADDR x10,x2,1564144
 ldr w10,[x10]
 cmp w10,#1
 b.hi .Lvalidated
 MADDR x10,x2,1564176
 ldr w10,[x10]
 cmp w10,#1
 b.hi .Lvalidated
 ldr w10,[x0,#5160]
 cmp w10,#0
 b.le .Lvalidated
 ldr w10,[x2,#16]
 cmp w10,#0
 b.lt .Lvalidated
 movz w11,#0xfffd
 movk w11,#0x7fff,lsl#16
 cmp w10,w11
 b.gt .Lvalidated
 ldr w10,[x2,#192]
 cmp w10,#0
 b.lt .Lvalidated
 ldr w10,[x2,#200]
 cmp w10,#0
 b.lt .Lvalidated
 MADDR x10,x2,4267708
 ldr w10,[x10]
 cmp w10,#0
 b.le .Lvalidated
 mov w9,#0
.Lvalidated:
 ret
.p2align 4
.global md2asm_allocate_dynamical_diagnostic_storage
.type md2asm_allocate_dynamical_diagnostic_storage,%function
md2asm_allocate_dynamical_diagnostic_storage:
 mov x16,x30
 bl .Lvalidate
 mov x30,x16
 cbnz w9,.Lbad
 adr x4,.Lowners
 mov x5,#0
.Lfresh:
 ldr w9,[x4],#32
 ldr x10,[x2,x9]
 cbnz x10,.Lbad
 add x5,x5,#1
 cmp x5,#17
 b.lo .Lfresh
 /* Every product fits signed64 FP64 storage before any allocation. */
 ldr w9,[x0,#5160]
 ldr w10,[x2,#192]
 umull x11,w9,w10
 lsr x11,x11,#60
 cbnz x11,.Lbad
 ldr w10,[x2,#200]
 mov w11,#1
 cmp w10,#1
 csel w10,w10,w11,ge
 umull x11,w9,w10
 lsr x11,x11,#60
 cbnz x11,.Lbad
 ldr w10,[x2,#16]
 add w10,w10,#2
 umull x11,w9,w10
 lsr x11,x11,#60
 cbnz x11,.Lbad
 MADDR x10,x2,4267708
 ldr w10,[x10]
 umull x11,w9,w10
 lsr x11,x11,#60
 cbnz x11,.Lbad
 sub sp,sp,#256
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x2
 mov x20,x0
 ldr w21,[x20,#5160]
 MADDR x9,x19,4267708
 ldr w22,[x9]
 ldr w23,[x19,#16]
 ldr w24,[x19,#192]
 ldr w25,[x19,#200]
 MADDR x9,x19,1564144
 ldr w26,[x9]
 MADDR x9,x19,1564176
 ldr w10,[x9]
 orr w26,w26,w10,lsl#1
 cmp w23,#0
 cset w10,gt
 orr w26,w26,w10,lsl#2
 adr x27,.Lowners
 mov x28,#0
.Lallocate:
 bl .Lshape
 cbnz x0,.Lnonzero_size
 mov x0,#1
.Lnonzero_size:
 bl malloc
 cbz x0,.Lrollback
 add x9,sp,#112
 str x0,[x9,x28,lsl#3]
 add x28,x28,#1
 cmp x28,#17
 b.lo .Lallocate
 mov x28,#0
.Lpublish:
 bl .Lshape
 add x9,sp,#112
 ldr x14,[x9,x28,lsl#3]
 add x15,x19,x13
 str x14,[x15]
 /* First two dimensions are source singleton work dimensions. */
 add x9,x10,#3
 cmp x11,#4
 csel x9,x9,x11,eq
 neg x9,x9
 str x9,[x15,#8]
 mov x9,#8
 str x9,[x15,#16]
 str wzr,[x15,#24]
 mov w9,#0x300
 orr w9,w9,w11
 str w9,[x15,#28]
 mov x9,#8
 str x9,[x15,#32]
 mov x9,#1
 stp x9,x9,[x15,#40]
 stp x9,x9,[x15,#56]
 stp x9,x9,[x15,#72]
 cmp x11,#2
 b.eq .Lclear
 str x9,[x15,#88]
 str x9,[x15,#96]
 str x10,[x15,#104]
 cmp x11,#3
 b.eq .Lclear
 str x10,[x15,#112]
 str x9,[x15,#120]
 str x21,[x15,#128]
.Lclear:
 cbz x12,.Lnext
 cmp x12,#1
 b.eq .Lzero
 sub x9,x12,#2
 lsrv x9,x26,x9
 tbz x9,#0,.Lnext
.Lzero:
 cbz x0,.Lnext
 mov x9,#0
.Lzero_word:
 str xzr,[x14,x9]
 add x9,x9,#8
 cmp x9,x0
 b.lo .Lzero_word
.Lnext:
 add x28,x28,#1
 cmp x28,#17
 b.lo .Lpublish
 mov w0,#0
 b .Ldone
.Lrollback:
 cbz x28,.Lallocation_failed
 sub x28,x28,#1
 add x9,sp,#112
 ldr x0,[x9,x28,lsl#3]
 bl free
 b .Lrollback
.Lallocation_failed:
 mov w0,#1
.Ldone:
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#256
 ret
.size md2asm_allocate_dynamical_diagnostic_storage,.-md2asm_allocate_dynamical_diagnostic_storage
/* x0 bytes, x10 third dimension, x11 rank, x12 zero rule, x13 offset. */
.Lshape:
 add x9,x27,x28,lsl#5
 ldp x13,x11,[x9]
 ldp x10,x12,[x9,#16]
 cmp x10,#0
 b.eq .Lunit
 cmp x10,#1
 b.eq .Lspectral_fields
 cmp x10,#2
 b.eq .Lsemi_implicit
 cmp x10,#3
 b.eq .Lthermal
 mov x10,x24
 b .Lsize
.Lunit:
 mov x10,#1
 b .Lsize
.Lspectral_fields:
 mov x9,#1
 cmp x25,#1
 csel x10,x25,x9,ge
 b .Lsize
.Lsemi_implicit:
 mov x10,x22
 b .Lsize
.Lthermal:
 add x10,x23,#2
.Lsize:
 mov x0,x10
 cmp x11,#4
 b.ne .Lbytes
 mul x0,x0,x21
.Lbytes:
 lsl x0,x0,#3
 ret
.p2align 4
.global md2asm_release_dynamical_diagnostic_storage
.type md2asm_release_dynamical_diagnostic_storage,%function
md2asm_release_dynamical_diagnostic_storage:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 MADDR x9,xzr,4275088
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 stp x18,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x19,x0
 adr x20,.Lowners
 mov x21,#17
.Lrelease:
 sub x21,x21,#1
 add x9,x20,x21,lsl#5
 ldr x9,[x9]
 add x22,x19,x9
 ldr x0,[x22]
 cbz x0,.Lrelease_next
 str xzr,[x22]
 bl free
.Lrelease_next:
 cbnz x21,.Lrelease
 mov w0,#0
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#64
 ret
.size md2asm_release_dynamical_diagnostic_storage,.-md2asm_release_dynamical_diagnostic_storage
.Lbad:
 mov w0,#2
 ret
.section .rodata
.Lgroup: .ascii "NAMDDH"
.p2align 3
.Lowners:
 .xword 4270360,2,0,1
 .xword 4270448,2,0,1
 .xword 4270536,2,0,4
 .xword 4270624,2,0,2
 .xword 4270712,2,0,2
 .xword 4269720,2,0,1
 .xword 4269808,2,0,1
 .xword 4269896,2,0,4
 .xword 4270248,3,1,1
 .xword 4269984,2,0,2
 .xword 4270072,2,0,2
 .xword 4270160,2,0,3
 .xword 4269136,4,2,1
 .xword 4268864,4,3,1
 .xword 4269000,4,1,1
 .xword 4269272,4,3,1
 .xword 4269408,4,4,1
.section .note.GNU-stack,"",%progbits

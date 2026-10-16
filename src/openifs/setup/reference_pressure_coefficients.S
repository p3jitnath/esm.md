/* Original selected SUDYN controls, SUALDYN owners and SUSI pressure stage.
 * Contract skills/md2asm/references/openifs/dynamics/reference_pressure_coefficients.md.
 * Complete Geometry and MODEL records remain owned by the caller. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.macro POSITIVE reg,bad
 fmov x10,\reg
 tbnz x10,#63,\bad
 lsl x11,x10,#1
 cbz x11,\bad
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq \bad
.endm
/* Leaf validation retains x0 through x8 and x16. */
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
 mov x10,#(4275088 & 65535)
 movk x10,#(4275088 >> 16),lsl#16
 cmp x3,x10
 b.lo .Lvalidated
 adds x12,x2,x10
 b.cs .Lvalidated
 cmp x11,x2
 b.ls .Lrecords_disjoint
 cmp x12,x0
 b.hi .Lvalidated
.Lrecords_disjoint:
 mrs x10,fpcr
 cbnz x10,.Lvalidated
 mov x10,#5224
 ldr w10,[x0,x10]
 sub w10,w10,#1
 cmp w10,#254
 b.hi .Lvalidated
 mov w9,#0
.Lvalidated:
 ret
.p2align 4
.global md2asm_initialize_reference_atmosphere_controls
.type md2asm_initialize_reference_atmosphere_controls,%function
md2asm_initialize_reference_atmosphere_controls:
 mov x16,x30
 bl .Lvalidate
 mov x30,x16
 cbnz w9,.Lbad
 cbz x4,.Lbad
 cbz x5,.Lbad
 cbz x6,.Lbad
 orr x9,x4,x6
 tst x9,#3
 b.ne .Lbad
 tst x5,#7
 b.ne .Lbad
 ldp w9,w10,[x4]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x4,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 ldr w9,[x6]
 cbnz w9,.Lbad
 MADDR x9,x2,1564136
 ldr w10,[x9,#8]
 cbnz w10,.Lbad
 ldp w10,w11,[x9,#20]
 cmp w10,#1
 b.ne .Lbad
 cmp w11,#1
 b.ne .Lbad
 MADDR x9,x2,1359332
 ldr w10,[x9]
 cmp w10,#0
 b.le .Lbad
 ldr d5,[x5]
 POSITIVE d5,.Lbad
 ldr x7,[x0,#3240]
 ldr x8,[x0,#3264]
 cbz x7,.Lbad
 cbz x8,.Lbad
 orr x9,x7,x8
 tst x9,#7
 b.ne .Lbad
 ldr w9,[x8,#52]
 cmp w9,#1
 b.hi .Lbad
 ldr x10,[x7,#128]
 cbz x10,.Lbad
 ldr x11,[x7,#176]
 cmp x11,#1
 b.gt .Lbad
 ldr x12,[x7,#184]
 cmp x12,#1
 b.lt .Lbad
 mov x12,#1
 sub x12,x12,x11
 ldr d0,[x10,x12,lsl#3]
 fmov x10,d0
 tbnz x10,#63,.Lbad
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lbad
 mov x10,#7512
 ldr d4,[x0,x10]
 POSITIVE d4,.Lbad
 /* Original ordered top-pressure choice. */
 fmov d1,#0.5
 fmul d0,d0,d1
 adr x10,.Lconstants
 ldr d1,[x10]
 fcmp d0,d1
 cset w11,lt
 orr w11,w11,w9
 ldr d0,[x10,#8]
 ldr d1,[x10,#16]
 cmp w11,#0
 fcsel d0,d0,d1,ne
 ldr d2,[x10,#24]
 fmul d3,d5,d0
 fmov d6,#1.0
 fdiv d6,d6,d2
 /* Original LLSTRSG and LSIDG, with admitted NCONF1 and NSTOP positive. */
 fmov d7,#1.0
 fsub d4,d4,d7
 fabs d4,d4
 ldr d7,[x10,#40]
 fcmp d4,d7
 cset w11,gt
 MADDR x9,x2,1567112
 str d0,[x9]
 MADDR x9,x2,1567104
 str d2,[x9]
 MADDR x9,x2,1567120
 str d0,[x9]
 MADDR x9,x2,1567184
 str wzr,[x9]
 MADDR x9,x2,1567152
 str d3,[x9]
 MADDR x9,x2,1567160
 str d6,[x9]
 ldr d0,[x10,#32]
 MADDR x9,x2,1568768
 str d0,[x9]
 MADDR x9,x2,1567068
 str w11,[x9]
 MADDR x9,x2,1570368
 str wzr,[x9]
 mov w0,#0
 ret
.size md2asm_initialize_reference_atmosphere_controls,.-md2asm_initialize_reference_atmosphere_controls
.p2align 4
.global md2asm_allocate_reference_pressure_coefficients
.type md2asm_allocate_reference_pressure_coefficients,%function
md2asm_allocate_reference_pressure_coefficients:
 mov x16,x30
 bl .Lvalidate
 mov x30,x16
 cbnz w9,.Lbad
 MADDR x9,x2,1567192
 mov x10,#7
.Lnull_owners:
 ldr x11,[x9],#64
 cbnz x11,.Lbad
 subs x10,x10,#1
 b.ne .Lnull_owners
 sub sp,sp,#192
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x2
 mov x9,#5224
 ldr w20,[x0,x9]
 add x21,sp,#80
 mov x22,#0
.Lallocate_owner:
 mov x0,x20
 cmp x22,#4
 cinc x0,x0,eq
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lrollback
 str x0,[x21,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#7
 b.lo .Lallocate_owner
 MADDR x23,x19,1567192
 mov x22,#0
.Lpublish_owner:
 ldr x9,[x21,x22,lsl#3]
 str x9,[x23]
 mov x9,#1
 cmp x22,#4
 csel x9,xzr,x9,eq
 neg x10,x9
 str x10,[x23,#8]
 mov x10,#8
 str x10,[x23,#16]
 str wzr,[x23,#24]
 mov w10,#0x301
 strh w10,[x23,#28]
 strh wzr,[x23,#30]
 mov x10,#8
 str x10,[x23,#32]
 mov x10,#1
 stp x10,x9,[x23,#40]
 str x20,[x23,#56]
 add x23,x23,#64
 add x22,x22,#1
 cmp x22,#7
 b.lo .Lpublish_owner
 mov w0,#0
 b .Lallocate_done
.Lrollback:
 cbz x22,.Lallocation_failed
 sub x22,x22,#1
 ldr x0,[x21,x22,lsl#3]
 bl free
 b .Lrollback
.Lallocation_failed:
 mov w0,#1
.Lallocate_done:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#192
 ret
.size md2asm_allocate_reference_pressure_coefficients,.-md2asm_allocate_reference_pressure_coefficients
.p2align 4
.global md2asm_initialize_reference_pressure_coefficients
.type md2asm_initialize_reference_pressure_coefficients,%function
md2asm_initialize_reference_pressure_coefficients:
 mov x16,x30
 bl .Lvalidate
 mov x30,x16
 cbnz w9,.Lbad
 cbz x4,.Lbad
 tst x4,#7
 b.ne .Lbad
 ldr d0,[x4]
 POSITIVE d0,.Lbad
 MADDR x9,x2,1567112
 ldr d0,[x9]
 POSITIVE d0,.Lbad
 MADDR x9,x2,1567104
 ldr d0,[x9]
 POSITIVE d0,.Lbad
 ldr x9,[x0,#3240]
 ldr x10,[x0,#3264]
 cbz x9,.Lbad
 cbz x10,.Lbad
 orr x9,x9,x10
 tst x9,#7
 b.ne .Lbad
 mov x9,#5224
 ldr w12,[x0,x9]
 MADDR x9,x2,1567192
 mov x13,#0
.Lowned_shape:
 ldr x10,[x9]
 cbz x10,.Lbad
 tst x10,#7
 b.ne .Lbad
 ldr x10,[x9,#16]
 cmp x10,#8
 b.ne .Lbad
 ldrh w10,[x9,#28]
 mov w11,#0x301
 cmp w10,w11
 b.ne .Lbad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lbad
 ldr x10,[x9,#48]
 mov x11,#1
 cmp x13,#4
 csel x11,xzr,x11,eq
 cmp x10,x11
 b.ne .Lbad
 ldr x10,[x9,#56]
 cmp x10,x12
 b.ne .Lbad
 add x9,x9,#64
 add x13,x13,#1
 cmp x13,#7
 b.lo .Lowned_shape
 sub sp,sp,#160
 stp x18,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x25,x12
 mov w9,#1
 str w9,[sp,#128]
 str w25,[sp,#132]
 mov x9,#9
 madd x0,x25,x9,x9
 sub x0,x0,#8
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lcompute_failed
 mov x22,x0
 add x9,x25,#1
 add x23,x22,x9,lsl#3
 add x24,x23,x25,lsl#3
 MADDR x9,x20,1567104
 ldr d0,[x9]
 str d0,[x22,x25,lsl#3]
 add x0,sp,#128
 add x1,sp,#132
 mov x2,x0
 mov x3,x0
 ldr x4,[x19,#3240]
 ldr x5,[x19,#3264]
 mov x6,x22
 mov x7,x24
 str x23,[sp]
 bl md2asm_ec_pressure_7358525
 mov x26,#0
.Lcopy_coefficients:
 ldr d0,[x24,x26,lsl#3]
 MADDR x9,x20,1567320
 ldr x9,[x9]
 str d0,[x9,x26,lsl#3]
 add x10,x24,x25,lsl#3
 ldr d0,[x10,x26,lsl#3]
 MADDR x9,x20,1567384
 ldr x9,[x9]
 str d0,[x9,x26,lsl#3]
 add x10,x10,x25,lsl#3
 ldr d0,[x10,x26,lsl#3]
 MADDR x9,x20,1567256
 ldr x9,[x9]
 str d0,[x9,x26,lsl#3]
 add x10,x10,x25,lsl#3
 ldr d0,[x10,x26,lsl#3]
 MADDR x9,x20,1567192
 ldr x9,[x9]
 str d0,[x9,x26,lsl#3]
 add x10,x26,#1
 ldr d0,[x22,x10,lsl#3]
 MADDR x9,x20,1567448
 ldr x9,[x9]
 str d0,[x9,x10,lsl#3]
 add x26,x26,#1
 cmp x26,x25
 b.lo .Lcopy_coefficients
 mov x26,#0
.Lcompute_pressure_terms:
 ldr d0,[x24,x26,lsl#3]
 add x10,x25,x25
 add x10,x24,x10,lsl#3
 ldr d1,[x10,x26,lsl#3]
 fdiv d2,d0,d1
 MADDR x9,x20,1567512
 ldr x9,[x9]
 str d2,[x9,x26,lsl#3]
 ldr d0,[x21]
 MADDR x9,x20,1567112
 ldr d2,[x9]
 fmul d0,d0,d2
 fmul d0,d0,d1
 MADDR x9,x20,1567576
 ldr x9,[x9]
 str d0,[x9,x26,lsl#3]
 add x26,x26,#1
 cmp x26,x25
 b.lo .Lcompute_pressure_terms
 ldr d0,[x22]
 MADDR x9,x20,1567448
 ldr x9,[x9]
 str d0,[x9]
 mov x0,x22
 bl free
 mov w0,#0
 b .Lcompute_done
.Lcompute_failed:
 mov w0,#1
.Lcompute_done:
 ldp x27,x28,[sp,#96]
 ldp x25,x26,[sp,#80]
 ldp x23,x24,[sp,#64]
 ldp x21,x22,[sp,#48]
 ldp x19,x20,[sp,#32]
 ldp x18,x30,[sp,#16]
 add sp,sp,#160
 ret
.size md2asm_initialize_reference_pressure_coefficients,.-md2asm_initialize_reference_pressure_coefficients
.p2align 4
.global md2asm_release_reference_pressure_coefficients
.type md2asm_release_reference_pressure_coefficients,%function
md2asm_release_reference_pressure_coefficients:
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
 stp x21,x22,[sp,#32]
 mov x19,x0
 MADDR x20,x19,1567576
 mov x21,#7
.Lrelease:
 ldr x0,[x20]
 cbz x0,.Lrelease_next
 str xzr,[x20]
 bl free
.Lrelease_next:
 sub x20,x20,#64
 subs x21,x21,#1
 b.ne .Lrelease
 mov w0,#0
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#48
 ret
.size md2asm_release_reference_pressure_coefficients,.-md2asm_release_reference_pressure_coefficients
.Lbad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lconstants:
 .double 100.0,350.0,300.0,100000.0,0.04
 .quad 0x79000000000000
.section .note.GNU-stack,"",%progbits

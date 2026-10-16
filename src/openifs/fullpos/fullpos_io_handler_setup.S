// Contract: skills/md2asm/references/openifs/fullpos/fullpos_io_handler_setup.md.
// Complete selected serial ECMWF SUFPIOH. See integration_contract.md.
// x0 table96: names336, I/O564, geometry848, user472, stream872, handler152.
// Return0 commits,1 allocation failure,2 reject. Frame720 plus accepted child.
.text
.p2align 2
.global md2asm_initialize_fullpos_io_handler
.type md2asm_initialize_fullpos_io_handler,%function
md2asm_initialize_fullpos_io_handler:
 cbz x0,.Learly_bad
 tst x0,#7
 b.ne .Learly_bad
 adds x9,x0,#96
 b.cs .Learly_bad
 sub sp,sp,#720
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#512]
 mov x29,sp
 mov x19,x0
 add x10,sp,#352
 stp x0,x9,[x10]
 adr x11,.Lsizes
 mov x12,#0
.Lviews:
 ldp x13,x14,[x0],#16
 ldr x15,[x11],#8
 cbz x13,.Lbad
 tst x13,#7
 b.ne .Lbad
 cmp x14,x15
 b.lo .Lbad
 adds x14,x13,x15
 b.cs .Lbad
 add x10,x10,#16
 stp x13,x14,[x10]
 add x12,x12,#1
 cmp x12,#6
 b.lo .Lviews
 ldr x27,[x19]
 ldr x24,[x19,#16]
 ldr x25,[x19,#32]
 ldr x26,[x19,#48]
 ldr x21,[x19,#64]
 ldr x20,[x19,#80]
 ldr x9,[x20,#24]
 ldr x10,[x20,#88]
 orr x9,x9,x10
 cbnz x9,.Lbad
 // Add the two consumed geometry payloads to the disjoint-view guard.
 ldr w9,[x25]
 sub w10,w9,#1
 cmp w10,#4095
 b.hi .Lbad
 ldr x10,[x25,#88]
 cbz x10,.Lbad
 adds x11,x10,#4
 b.cs .Lbad
 add x12,sp,#464
 stp x10,x11,[x12]
 ldr x10,[x25,#152]
 cbz x10,.Lbad
 lsl x9,x9,#2
 adds x11,x10,x9
 b.cs .Lbad
 stp x10,x11,[x12,#16]
 mov x9,#0
.Louter:
 add x10,sp,#352
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,x9,#1
.Linner:
 cmp x13,#9
 b.hs .Lnext
 add x10,sp,#352
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Ldisjoint
 cmp x14,x12
 b.lo .Lbad
.Ldisjoint:
 add x13,x13,#1
 b .Linner
.Lnext:
 add x9,x9,#1
 cmp x9,#8
 b.lo .Louter
 mov x22,#0
 mov x23,#0
 mov x0,#28
 bl malloc
 ldr x18,[sp,#512]
 cbz x0,.Lallocation_failed
 mov x22,x0
 mov x0,#1536
 bl malloc
 ldr x18,[sp,#512]
 cbz x0,.Lallocation_failed
 mov x23,x0
 // Copy every I/O bit, then apply the source signed MIN/MAX operation.
 ldp x9,x10,[x24]
 stp x9,x10,[sp,#96]
 ldr x9,[x24,#16]
 str x9,[sp,#112]
 ldr w9,[x24,#4]
 mov w10,#1
 cmp w9,w10
 csel w9,w9,w10,le
 mov w10,#-1
 cmp w9,w10
 csel w9,w9,w10,ge
 str w9,[sp,#100]
 add x0,sp,#120
 mov x1,x22
 mov x2,#28
 bl .Lderived_descriptor
 add x0,sp,#184
 mov x1,x23
 mov x2,#1536
 bl .Lderived_descriptor
 // Reuse the unchanged, checked complete GRIB child.
 add x9,sp,#256
 mov x10,#336
 stp x27,x10,[x9]
 // The byte-204 character field needs an aligned child view.
 add x10,sp,#528
 add x11,x24,#204
 mov x12,#0
.Lclimate_view:
 ldrb w13,[x11,x12]
 strb w13,[x10,x12]
 add x12,x12,#1
 cmp x12,#180
 b.lo .Lclimate_view
 mov x11,#180
 stp x10,x11,[x9,#16]
 mov x10,#848
 stp x25,x10,[x9,#32]
 mov x10,#472
 stp x26,x10,[x9,#48]
 mov x10,#1536
 stp x23,x10,[x9,#64]
 mov x10,#872
 stp x21,x10,[x9,#80]
 mov x0,x9
 bl md2asm_initialize_fullpos_grib_setup
 ldr x18,[sp,#512]
 cbnz w0,.Lchild_failed
 add x9,sp,#96
 mov x10,x20
 mov x11,#9
.Lcommit:
 ldp x12,x13,[x9],#16
 stp x12,x13,[x10],#16
 subs x11,x11,#1
 b.ne .Lcommit
 ldr x12,[x9]
 str x12,[x10]
 mov w0,#0
 b .Lreturn
.Lchild_failed:
 mov w28,w0
 b .Lfree_private
.Lallocation_failed:
 mov w28,#1
.Lfree_private:
 mov x0,x23
 bl free
 ldr x18,[sp,#512]
 mov x0,x22
 bl free
 ldr x18,[sp,#512]
 mov w0,w28
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#720
 ret
.Learly_bad:
 mov w0,#2
 ret
.Lderived_descriptor:
 mov x9,#-1
 stp x1,x9,[x0]
 mov x10,#0x501
 lsl x10,x10,#32
 stp x2,x10,[x0,#16]
 mov x9,#1
 stp x2,x9,[x0,#32]
 stp x9,x9,[x0,#48]
 ret
.size md2asm_initialize_fullpos_io_handler,.-md2asm_initialize_fullpos_io_handler

.global md2asm_release_fullpos_io_handler
.type md2asm_release_fullpos_io_handler,%function
md2asm_release_fullpos_io_handler:
 cbz x0,.Lrelease_bad
 tst x0,#7
 b.ne .Lrelease_bad
 cmp x1,#152
 b.lo .Lrelease_bad
 adds x9,x0,#152
 b.cs .Lrelease_bad
 cbz x2,.Lrelease_bad
 tst x2,#7
 b.ne .Lrelease_bad
 cmp x3,#872
 b.lo .Lrelease_bad
 adds x10,x2,#872
 b.cs .Lrelease_bad
 cmp x0,x10
 b.hs .Lrelease_distinct
 cmp x2,x9
 b.lo .Lrelease_bad
.Lrelease_distinct:
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x0,x2
 mov x1,x3
 bl md2asm_release_fullpos_grib_setup
 ldr x18,[sp,#48]
 cbnz w0,.Lrelease_return
 ldr x0,[x19,#24]
 bl free
 ldr x18,[sp,#48]
 ldr x0,[x19,#88]
 bl free
 ldr x18,[sp,#48]
 str xzr,[x19,#24]
 str xzr,[x19,#88]
 mov w0,#0
.Lrelease_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_fullpos_io_handler,.-md2asm_release_fullpos_io_handler
.section .rodata
.p2align 3
.Lsizes: .quad 336,564,848,472,872,152
.section .note.GNU-stack,"",%progbits

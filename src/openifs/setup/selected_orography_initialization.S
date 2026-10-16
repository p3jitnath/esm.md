/* Complete selected SUOROG, SPEREE and SPEUV(KINP=2).
 * Contract: skills/md2asm/references/openifs/setup/selected_orography_initialization.md. Live coefficients and Geometry only.
 * x0 Geometry, x1 capacity, x2 coefficients, x3 bytes, x4 controls, x5 bytes.
 * Return 0, 1 or 2. Frame 1024 bytes, outgoing arguments at offsets 0 through 127, saved registers at 128 through 239. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_orography
.type md2asm_initialize_selected_orography,%function
md2asm_initialize_selected_orography:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad
 cmp x3,#4048
 b.lo .Lbad
 cmp x5,#16
 b.lo .Lbad
 ldp w9,w10,[x4]
 orr w9,w9,w10
 cbnz w9,.Lbad
 ldp w9,w10,[x4,#8]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldr x9,[x0]
 cbz x9,.Lbad
 ldr w9,[x9]
 cbnz w9,.Lbad
 ldr w9,[x0,#5144]
 cmp w9,#24
 b.ne .Lbad
 ldr w9,[x0,#5160]
 cmp w9,#86
 b.ne .Lbad
 ldr w9,[x0,#5200]
 cmp w9,#506
 b.ne .Lbad
 ldr w9,[x0,#7376]
 cmp w9,#2048
 b.ne .Lbad
 ldr x9,[x0,#14088]
 ldr x10,[x0,#14176]
 ldr x11,[x0,#14264]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Lbad
 ldr x9,[x0,#14024]
 cbz x9,.Lbad
 mov x10,#0
.Lcheck_rows:
 mov x11,#0
 mov x12,#24
 cmp x10,#85
 mov x13,#8
 csel x12,x12,x13,ne
.Lcheck_fields:
 add x13,x9,x11,lsl#6
 ldr x14,[x13]
 cbz x14,.Lbad
 tst x14,#7
 b.ne .Lbad
 ldr x14,[x13,#16]
 cmp x14,#8
 b.ne .Lbad
 ldr x14,[x13,#40]
 cmp x14,#1
 b.ne .Lbad
 ldr x14,[x13,#48]
 cmp x14,#1
 b.ne .Lbad
 ldr x14,[x13,#56]
 cmp x14,x12
 b.ne .Lbad
 add x11,x11,#1
 cmp x11,#3
 b.lo .Lcheck_fields
 add x9,x9,#384
 add x10,x10,#1
 cmp x10,#86
 b.lo .Lcheck_rows
 ldr x9,[x0,#3912]
 ldr x10,[x0,#3720]
 ldr x11,[x0,#4104]
 cbz x9,.Lbad
 cbz x10,.Lbad
 cbz x11,.Lbad
 ldr x12,[x0,#4112]
 cmp x12,#1
 b.ne .Lbad
 ldr x12,[x0,#4144]
 cmp x12,#1
 b.ne .Lbad
 ldr x12,[x0,#4152]
 cmn x12,#1
 b.ne .Lbad
 ldr x12,[x0,#4160]
 cmp x12,#23
 b.ne .Lbad
 mov x12,#0
.Lcheck_modes:
 ldr w13,[x9,x12,lsl#2]
 cmp w13,w12
 b.ne .Lbad
 ldr w13,[x10,x12,lsl#2]
 cmp w13,#1
 b.lt .Lbad
 cmp w13,#505
 b.gt .Lbad
 add x12,x12,#1
 cmp x12,#22
 b.lo .Lcheck_modes
 sub sp,sp,#1024
 stp x18,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 stp x29,xzr,[sp,#224]
 mov x19,x0
 mov x20,x2
 mov x21,#0
 mov x23,#0
 mov x24,#0
 mov x25,#0
 mov x0,#57248
 bl malloc
 cbz x0,.Lallocation_failed
 mov x21,x0
 /* A one-field spectral view, one vertical-set index and one grid field. */
 add x0,sp,#512
 mov x1,x20
 bl .Lreal_spectral_descriptor
 add x0,sp,#800
 add x1,sp,#988
 mov w9,#1
 str w9,[x1]
 mov x2,#4
 mov x3,#1
 bl .Lrank_one_descriptor
 add x0,sp,#864
 mov x1,x21
 mov x2,#1
 bl .Lgrid_descriptor
 mov w9,#2048
 str w9,[sp,#984]
 bl .Lclear_transform_arguments
 add x2,sp,#512
 add x9,sp,#800
 str x9,[sp,#48]
 bl inv_trans_
 /* Source ZDIV is positive zero. Multiply each selected mode in source order. */
 ldr x22,[x19,#3720]
 ldr x26,[x19,#4104]
 ldr x9,[x19,#4112]
 add x26,x26,x9,lsl#3
 mov x27,#0
.Lmode:
 ldrsw x28,[x22,x27,lsl#2]
 sub x28,x28,#1
 mov x14,x27
.Ldegree:
 ldr d1,[x26,x14,lsl#3]
 fmov d0,xzr
 fmul d0,d0,d1
 mov x9,#16384
 add x9,x21,x9
 str d0,[x9,x28,lsl#3]
 ldr d2,[x20,x28,lsl#3]
 fmul d2,d2,d1
 mov x10,#20432
 add x10,x21,x10
 str d2,[x10,x28,lsl#3]
 add x28,x28,#1
 cbz x27,.Lzero_imaginary
 str d0,[x9,x28,lsl#3]
 ldr d2,[x20,x28,lsl#3]
 fmul d2,d2,d1
 str d2,[x10,x28,lsl#3]
 b .Lnext_degree
.Lzero_imaginary:
 str xzr,[x9,x28,lsl#3]
 str xzr,[x10,x28,lsl#3]
.Lnext_degree:
 add x28,x28,#1
 add x14,x14,#1
 cmp x14,#22
 b.lo .Ldegree
 add x27,x27,#1
 cmp x27,#22
 b.lo .Lmode
 add x0,sp,#608
 add x1,x21,#16384
 bl .Lreal_spectral_descriptor
 add x0,sp,#704
 mov x9,#20432
 add x1,x21,x9
 bl .Lreal_spectral_descriptor
 add x0,sp,#864
 mov x9,#24480
 add x1,x21,x9
 mov x2,#2
 bl .Lgrid_descriptor
 bl .Lclear_transform_arguments
 add x0,sp,#608
 add x1,sp,#704
 mov x2,#0
 add x9,sp,#800
 str x9,[sp,#40]
 bl inv_trans_
 /* SUOROG allocates these blocked owners after both transforms. */
 mov x0,#16512
 bl malloc
 cbz x0,.Lallocation_failed
 mov x23,x0
 mov x0,#16512
 bl malloc
 cbz x0,.Lallocation_failed
 mov x24,x0
 mov x0,#16512
 bl malloc
 cbz x0,.Lallocation_failed
 mov x25,x0
 mov x9,#14088
 add x0,x19,x9
 mov x1,x23
 bl .Lblocked_descriptor
 mov x9,#14176
 add x0,x19,x9
 mov x1,x24
 bl .Lblocked_descriptor
 mov x9,#14264
 add x0,x19,x9
 mov x1,x25
 bl .Lblocked_descriptor
 ldr x22,[x19,#14024]
 mov x26,#0
.Lcopy_point:
 mov x9,#24
 udiv x10,x26,x9
 msub x11,x10,x9,x26
 mov x12,#384
 madd x12,x10,x12,x22
 ldr x13,[x12]
 ldr x14,[x12,#64]
 ldr x15,[x12,#128]
 ldr x9,[x21,x26,lsl#3]
 str x9,[x13,x11,lsl#3]
 str x9,[x23,x26,lsl#3]
 mov x10,#24480
 add x10,x21,x10
 ldr x9,[x10,x26,lsl#3]
 str x9,[x14,x11,lsl#3]
 str x9,[x24,x26,lsl#3]
 add x10,x10,#16384
 ldr x9,[x10,x26,lsl#3]
 str x9,[x15,x11,lsl#3]
 str x9,[x25,x26,lsl#3]
 add x26,x26,#1
 cmp x26,#2048
 b.lo .Lcopy_point
 mov x0,x21
 bl free
 mov w0,#0
 b .Lreturn
.Lallocation_failed:
 cbz x23,.Lfree_second
 mov x0,x23
 bl free
.Lfree_second:
 cbz x24,.Lfree_third
 mov x0,x24
 bl free
.Lfree_third:
 cbz x25,.Lfree_workspace
 mov x0,x25
 bl free
.Lfree_workspace:
 cbz x21,.Lfailure_status
 mov x0,x21
 bl free
.Lfailure_status:
 mov w0,#1
.Lreturn:
 ldp x18,x30,[sp,#128]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldr x29,[sp,#224]
 add sp,sp,#1024
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_orography,.-md2asm_initialize_selected_orography
/* Leaf descriptor builders use only caller-saved integer registers. */
.Lreal_spectral_descriptor:
 str x1,[x0]
 mov x9,#-2
 str x9,[x0,#8]
 mov x9,#8
 stp x9,x9,[x0,#16]
 str x9,[x0,#32]
 mov x9,#0x302
 lsl x9,x9,#32
 str x9,[x0,#24]
 mov x9,#1
 stp x9,x9,[x0,#40]
 stp x9,x9,[x0,#56]
 str x9,[x0,#72]
 mov x9,#506
 str x9,[x0,#80]
 ret
.Lrank_one_descriptor:
 str x1,[x0]
 mov x9,#-1
 str x9,[x0,#8]
 str x2,[x0,#16]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[x0,#24]
 str x2,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x3,[x0,#56]
 ret
.Lgrid_descriptor:
 str x1,[x0]
 mov x9,#2048
 mul x10,x2,x9
 add x10,x10,x9
 add x10,x10,#1
 neg x10,x10
 str x10,[x0,#8]
 mov x10,#8
 str x10,[x0,#16]
 str x10,[x0,#32]
 mov x10,#0x303
 lsl x10,x10,#32
 str x10,[x0,#24]
 mov x10,#1
 stp x10,x10,[x0,#40]
 str x9,[x0,#56]
 str x9,[x0,#64]
 str x10,[x0,#72]
 str x2,[x0,#80]
 mul x9,x9,x2
 str x9,[x0,#88]
 stp x10,x10,[x0,#96]
 ret
.Lblocked_descriptor:
 str x1,[x0]
 mov x9,#-25
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 mov x9,#0x302
 lsl x9,x9,#32
 str x9,[x0,#24]
 mov x9,#1
 stp x9,x9,[x0,#40]
 mov x10,#24
 stp x10,x10,[x0,#56]
 str x9,[x0,#72]
 mov x10,#86
 str x10,[x0,#80]
 ret
.Lclear_transform_arguments:
 stp xzr,xzr,[sp]
 stp xzr,xzr,[sp,#16]
 stp xzr,xzr,[sp,#32]
 stp xzr,xzr,[sp,#48]
 stp xzr,xzr,[sp,#64]
 stp xzr,xzr,[sp,#80]
 stp xzr,xzr,[sp,#96]
 stp xzr,xzr,[sp,#112]
 add x9,sp,#984
 str x9,[sp,#32]
 mov x9,#5168
 add x9,x19,x9
 str x9,[sp,#56]
 add x9,sp,#864
 str x9,[sp,#88]
 mov x0,#0
 mov x1,#0
 mov x2,#0
 mov x3,#0
 mov x4,#0
 mov x5,#0
 mov x6,#0
 mov x7,#0
 ret
.p2align 4
.global md2asm_release_selected_orography
.type md2asm_release_selected_orography,%function
md2asm_release_selected_orography:
 cbz x0,.Lrelease_bad
 tst x0,#7
 b.ne .Lrelease_bad
 sub sp,sp,#64
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x9,#14088
 add x19,x0,x9
 mov x20,#3
.Lrelease_next:
 ldr x0,[x19]
 cbz x0,.Lrelease_skip
 bl free
 str xzr,[x19]
.Lrelease_skip:
 add x19,x19,#88
 subs x20,x20,#1
 b.ne .Lrelease_next
 mov w0,#0
 ldp x18,x30,[sp]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 add sp,sp,#64
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_orography,.-md2asm_release_selected_orography
.section .note.GNU-stack,"",%progbits

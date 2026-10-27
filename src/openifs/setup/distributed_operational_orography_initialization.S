/* Contract: skills/md2asm/references/openifs/setup/distributed_operational_orography_initialization.md.
 * Accepted component source. Complete operational forecast acceptance remains separate. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_distributed_operational_orography
.type md2asm_initialize_distributed_operational_orography,%function
md2asm_initialize_distributed_operational_orography:
 mrs x9,fpcr
 cbnz x9,.Ldistributed_orography_bad
 cbz x0,.Ldistributed_orography_bad
 cbz x2,.Ldistributed_orography_bad
 cbz x4,.Ldistributed_orography_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Ldistributed_orography_bad
 tst x4,#3
 b.ne .Ldistributed_orography_bad
 mov x9,#20400
 cmp x1,x9
 b.lo .Ldistributed_orography_bad
 cmp x5,#16
 b.lo .Ldistributed_orography_bad
 ldp w9,w10,[x4]
 orr w9,w9,w10
 cbnz w9,.Ldistributed_orography_bad
 ldp w9,w10,[x4,#8]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 sub w11,w10,#1
 cmp w11,#137
 b.hi .Ldistributed_orography_bad
 cmp w9,#1
 b.lt .Ldistributed_orography_bad
 cmp w9,w10
 b.hi .Ldistributed_orography_bad
#else
 cmp w10,#2
 b.ne .Ldistributed_orography_bad
 sub w11,w9,#1
 cmp w11,#1
 b.hi .Ldistributed_orography_bad
#endif
 cmp w9,w10
 cset w6,eq
 mov x7,#1
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w8,[x0,#5200]
 lsl x8,x8,#3
#else
 movz x8,#5120
 movk x8,#100,lsl#16
#endif
 cmp w6,#0
 csel x7,x7,x8,eq
 cmp x3,x7
 b.lo .Ldistributed_orography_bad
 mov x10,#20400
 adds x10,x0,x10
 b.cs .Ldistributed_orography_bad
 adds x11,x2,x7
 b.cs .Ldistributed_orography_bad
 adds x12,x4,#16
 b.cs .Ldistributed_orography_bad
 cmp x0,x11
 b.hs .Ldistributed_orography_disjoint1
 cmp x2,x10
 b.lo .Ldistributed_orography_bad
.Ldistributed_orography_disjoint1:
 cmp x0,x12
 b.hs .Ldistributed_orography_disjoint2
 cmp x4,x10
 b.lo .Ldistributed_orography_bad
.Ldistributed_orography_disjoint2:
 cmp x2,x12
 b.hs .Ldistributed_orography_disjoint3
 cmp x4,x11
 b.lo .Ldistributed_orography_bad
.Ldistributed_orography_disjoint3:
 ldr x9,[x0]
 cbz x9,.Ldistributed_orography_bad
 ldr w9,[x9]
 cbnz w9,.Ldistributed_orography_bad
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w12,[x0,#5144]
 sub w9,w12,#1
 cmp w9,#1023
 b.hi .Ldistributed_orography_bad
 ldr w13,[x0,#5160]
 sub w9,w13,#1
 mov w10,#(388216&65535)
 movk w10,#(388216>>16),lsl#16
 cmp w9,w10
 b.hi .Ldistributed_orography_bad
 ldr w14,[x0,#7376]
 cmp w14,#1
 b.lt .Ldistributed_orography_bad
 add x9,x14,x12
 sub x9,x9,#1
 udiv x9,x9,x12
 cmp x9,x13
 b.ne .Ldistributed_orography_bad
 ldr w15,[x0,#5172]
 sub w9,w15,#1
 cmp w9,#4095
 b.hi .Ldistributed_orography_bad
 ldr w14,[x0,#5200]
 tst w14,#1
 b.ne .Ldistributed_orography_bad
 add x9,x15,#1
 add x10,x15,#2
 mul x9,x9,x10
 cmp x14,x9
 b.hi .Ldistributed_orography_bad
 ldr w14,[x0,#5212]
 add w9,w15,#1
 cmp w14,w9
 b.hi .Ldistributed_orography_bad
#else
 ldr w9,[x0,#5144]
 cmp w9,#17
 b.ne .Ldistributed_orography_bad
 ldr w9,[x0,#5160]
 movz w10,#31519
 movk w10,#1,lsl#16
 cmp w9,w10
 b.ne .Ldistributed_orography_bad
 ldr w9,[x0,#5200]
 movz w10,#33408
 movk w10,#12,lsl#16
 cmp w9,w10
 b.ne .Ldistributed_orography_bad
 ldr w9,[x0,#7376]
 movz w10,#11520
 movk w10,#25,lsl#16
 cmp w9,w10
 b.ne .Ldistributed_orography_bad
 ldr w9,[x0,#5172]
 cmp w9,#1279
 b.ne .Ldistributed_orography_bad
 ldr w9,[x0,#5212]
 cmp w9,#640
 b.ne .Ldistributed_orography_bad
#endif
 ldr w9,[x0,#5168]
 cmp w9,#1
 b.lt .Ldistributed_orography_bad
 ldr x9,[x0,#14088]
 ldr x10,[x0,#14176]
 ldr x11,[x0,#14264]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Ldistributed_orography_bad
 ldr x9,[x0,#14024]
 ldr x10,[x0,#3912]
 ldr x11,[x0,#3720]
 ldr x12,[x0,#4104]
 cbz x9,.Ldistributed_orography_bad
 cbz x10,.Ldistributed_orography_bad
 cbz x11,.Ldistributed_orography_bad
 cbz x12,.Ldistributed_orography_bad
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 mov x13,#0
 ldr w14,[x0,#5212]
 cbz w14,.Ldistributed_orography_check_modes_done
.Ldistributed_orography_check_mode:
#else
 mov x13,#0
.Ldistributed_orography_check_mode:
#endif
 ldrsw x14,[x10,x13,lsl#2]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w16,[x0,#5172]
 cmp x14,x16
#else
 cmp x14,#1279
#endif
 b.hi .Ldistributed_orography_bad
 ldrsw x15,[x11,x14,lsl#2]
 cmp x15,#1
 b.lt .Ldistributed_orography_bad
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w16,[x0,#5172]
 add x16,x16,#1
#else
 mov x16,#1280
#endif
 sub x16,x16,x14
 add x15,x15,x16,lsl#1
 sub x15,x15,#1
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w16,[x0,#5200]
#else
 movz x16,#33408
 movk x16,#12,lsl#16
#endif
 cmp x15,x16
 b.hi .Ldistributed_orography_bad
 add x13,x13,#1
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w14,[x0,#5212]
 cmp x13,x14
 b.lo .Ldistributed_orography_check_mode
.Ldistributed_orography_check_modes_done:
#else
 cmp x13,#640
 b.lo .Ldistributed_orography_check_mode
#endif
 sub sp,sp,#1024
 stp x18,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 stp x29,xzr,[sp,#224]
 str x6,[sp,#240]
 mov x19,x0
 mov x20,x2
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[x4,#12]
 str w9,[sp,#344]
#endif
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[x19,#5144]
 str w9,[sp,#312]
 ldr w10,[x19,#5160]
 str w10,[sp,#316]
 mul x11,x9,x10
 str x11,[sp,#336]
 ldr w9,[x19,#7376]
 str w9,[sp,#320]
 lsl x9,x9,#3
 str x9,[sp,#248]
 ldr w10,[x19,#5172]
 str w10,[sp,#324]
 ldr w10,[x19,#5212]
 str w10,[sp,#328]
 ldr w10,[x19,#5200]
 str w10,[sp,#332]
 lsl x10,x10,#3
#else
 movz x9,#26624
 movk x9,#201,lsl#16
 str x9,[sp,#248]
 movz x10,#5120
 movk x10,#100,lsl#16
#endif
 mul x10,x10,x6
 str x10,[sp,#256]
 add x11,x9,x10
 str x9,[sp,#264]
 str x11,[sp,#272]
 add x11,x11,x10
 str x11,[sp,#280]
 mov x21,#0
 mov x23,#0
 mov x24,#0
 mov x25,#0
 ldr x9,[sp,#248]
 ldr x10,[sp,#256]
 add x0,x9,x9,lsl#1
 add x0,x0,x10,lsl#1
 bl malloc
 cbz x0,.Ldistributed_orography_allocation_failed
 mov x21,x0
 /* A one-field spectral view, one vertical-set index and one grid field. */
 add x0,sp,#512
 mov x1,x20
 bl .Ldistributed_orography_real_spectral_descriptor
 add x0,sp,#800
 add x1,sp,#988
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#344]
 str w9,[x1]
#else
 mov w9,#2
 str w9,[x1]
#endif
 mov x2,#4
 mov x3,#1
 bl .Ldistributed_orography_rank_one_descriptor
 add x0,sp,#864
 mov x1,x21
 mov x2,#1
 bl .Ldistributed_orography_grid_descriptor
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#320]
 str w9,[sp,#984]
#else
 movz w9,#11520
 movk w9,#25,lsl#16
 str w9,[sp,#984]
#endif
 bl .Ldistributed_orography_clear_transform_arguments
 add x2,sp,#512
 add x9,sp,#800
 str x9,[sp,#48]
 bl inv_trans_
 /* Source field count is zero outside the selected surface group. */
 ldr x9,[sp,#240]
 cbz x9,.Ldistributed_orography_modes_done
 ldr x22,[x19,#3720]
 ldr x26,[x19,#4104]
 ldr x9,[x19,#4112]
 add x26,x26,x9,lsl#3
 ldr x10,[x19,#3912]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 mov x27,#0
 ldr w9,[sp,#328]
 cbz w9,.Ldistributed_orography_modes_done
.Ldistributed_orography_mode:
#else
 mov x27,#0
.Ldistributed_orography_mode:
#endif
 ldrsw x14,[x10,x27,lsl#2]
 str x14,[sp,#288]
 ldrsw x28,[x22,x14,lsl#2]
 sub x28,x28,#1
.Ldistributed_orography_degree:
 ldr d1,[x26,x14,lsl#3]
 fmov d0,xzr
 fmul d0,d0,d1
 ldr x9,[sp,#264]
 add x9,x21,x9
 str d0,[x9,x28,lsl#3]
 ldr d2,[x20,x28,lsl#3]
 fmul d2,d2,d1
 ldr x11,[sp,#272]
 add x11,x21,x11
 str d2,[x11,x28,lsl#3]
 add x28,x28,#1
 ldr x12,[sp,#288]
 cbz x12,.Ldistributed_orography_zero_imaginary
 str d0,[x9,x28,lsl#3]
 ldr d2,[x20,x28,lsl#3]
 fmul d2,d2,d1
 str d2,[x11,x28,lsl#3]
 b .Ldistributed_orography_next_degree
.Ldistributed_orography_zero_imaginary:
 str xzr,[x9,x28,lsl#3]
 str xzr,[x11,x28,lsl#3]
.Ldistributed_orography_next_degree:
 add x28,x28,#1
 add x14,x14,#1
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#324]
 add x9,x9,#1
 cmp x14,x9
#else
 cmp x14,#1280
#endif
 b.lo .Ldistributed_orography_degree
 add x27,x27,#1
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#328]
 cmp x27,x9
#else
 cmp x27,#640
#endif
 b.lo .Ldistributed_orography_mode
.Ldistributed_orography_modes_done:
 add x0,sp,#608
 ldr x9,[sp,#264]
 add x1,x21,x9
 bl .Ldistributed_orography_real_spectral_descriptor
 add x0,sp,#704
 ldr x9,[sp,#272]
 add x1,x21,x9
 bl .Ldistributed_orography_real_spectral_descriptor
 add x0,sp,#864
 ldr x9,[sp,#280]
 add x1,x21,x9
 mov x2,#2
 bl .Ldistributed_orography_grid_descriptor
 bl .Ldistributed_orography_clear_transform_arguments
 add x0,sp,#608
 add x1,sp,#704
 mov x2,#0
 add x9,sp,#800
 str x9,[sp,#40]
 bl inv_trans_
 /* SUOROG allocates these blocked owners after both transforms. */
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr x0,[sp,#336]
 lsl x0,x0,#3
#else
 movz x0,#26744
 movk x0,#201,lsl#16
#endif
 bl malloc
 cbz x0,.Ldistributed_orography_allocation_failed
 mov x23,x0
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr x0,[sp,#336]
 lsl x0,x0,#3
#else
 movz x0,#26744
 movk x0,#201,lsl#16
#endif
 bl malloc
 cbz x0,.Ldistributed_orography_allocation_failed
 mov x24,x0
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr x0,[sp,#336]
 lsl x0,x0,#3
#else
 movz x0,#26744
 movk x0,#201,lsl#16
#endif
 bl malloc
 cbz x0,.Ldistributed_orography_allocation_failed
 mov x25,x0
 mov x9,#14088
 add x0,x19,x9
 mov x1,x23
 bl .Ldistributed_orography_blocked_descriptor
 mov x9,#14176
 add x0,x19,x9
 mov x1,x24
 bl .Ldistributed_orography_blocked_descriptor
 mov x9,#14264
 add x0,x19,x9
 mov x1,x25
 bl .Ldistributed_orography_blocked_descriptor
 ldr x22,[x19,#14024]
 mov x26,#0
.Ldistributed_orography_copy_point:
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#312]
 udiv x10,x26,x9
#else
 mov x9,#17
 udiv x10,x26,x9
#endif
 msub x11,x10,x9,x26
 mov x12,#384
 madd x12,x10,x12,x22
 ldr x13,[x12]
 ldr x14,[x12,#64]
 ldr x15,[x12,#128]
 ldr x9,[x21,x26,lsl#3]
 str x9,[x13,x11,lsl#3]
 str x9,[x23,x26,lsl#3]
 ldr x10,[sp,#280]
 add x10,x21,x10
 ldr x9,[x10,x26,lsl#3]
 str x9,[x14,x11,lsl#3]
 str x9,[x24,x26,lsl#3]
 ldr x9,[sp,#264]
 add x10,x10,x9
 ldr x9,[x10,x26,lsl#3]
 str x9,[x15,x11,lsl#3]
 str x9,[x25,x26,lsl#3]
 add x26,x26,#1
 ldr x9,[sp,#248]
 lsr x9,x9,#3
 cmp x26,x9
 b.lo .Ldistributed_orography_copy_point
 mov x0,x21
 bl free
 mov w0,#0
 b .Ldistributed_orography_return
.Ldistributed_orography_allocation_failed:
 cbz x23,.Ldistributed_orography_free_second
 mov x0,x23
 bl free
.Ldistributed_orography_free_second:
 cbz x24,.Ldistributed_orography_free_third
 mov x0,x24
 bl free
.Ldistributed_orography_free_third:
 cbz x25,.Ldistributed_orography_free_workspace
 mov x0,x25
 bl free
.Ldistributed_orography_free_workspace:
 cbz x21,.Ldistributed_orography_failure_status
 mov x0,x21
 bl free
.Ldistributed_orography_failure_status:
 mov w0,#1
.Ldistributed_orography_return:
 ldp x18,x30,[sp,#128]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldr x29,[sp,#224]
 add sp,sp,#1024
 ret
.Ldistributed_orography_bad:
 mov w0,#2
 ret
.size md2asm_initialize_distributed_operational_orography,.-md2asm_initialize_distributed_operational_orography
/* Leaf descriptor builders use only caller-saved integer registers. */
.Ldistributed_orography_real_spectral_descriptor:
 str x1,[x0]
 ldr x9,[sp,#240]
 add x10,x9,#1
 neg x10,x10
 str x10,[x0,#8]
 mov x10,#8
 stp x10,x10,[x0,#16]
 str x10,[x0,#32]
 mov x10,#0x302
 lsl x10,x10,#32
 str x10,[x0,#24]
 mov x10,#1
 stp x10,x10,[x0,#40]
 str x9,[x0,#56]
 str x9,[x0,#64]
 str x10,[x0,#72]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#332]
 str x9,[x0,#80]
#else
 movz x9,#33408
 movk x9,#12,lsl#16
 str x9,[x0,#80]
#endif
 ret
.Ldistributed_orography_rank_one_descriptor:
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
.Ldistributed_orography_grid_descriptor:
 str x1,[x0]
 ldr x9,[sp,#248]
 lsr x9,x9,#3
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
.Ldistributed_orography_blocked_descriptor:
 str x1,[x0]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w9,[sp,#312]
 add x9,x9,#1
 neg x9,x9
 str x9,[x0,#8]
#else
 mov x9,#-18
 str x9,[x0,#8]
#endif
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 mov x9,#0x302
 lsl x9,x9,#32
 str x9,[x0,#24]
 mov x9,#1
 stp x9,x9,[x0,#40]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w10,[sp,#312]
 stp x10,x10,[x0,#56]
 str x9,[x0,#72]
 ldr w10,[sp,#316]
 str x10,[x0,#80]
#else
 mov x10,#17
 stp x10,x10,[x0,#56]
 str x9,[x0,#72]
 movz x10,#31519
 movk x10,#1,lsl#16
 str x10,[x0,#80]
#endif
 ret
.Ldistributed_orography_clear_transform_arguments:
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
.global md2asm_release_distributed_operational_orography
.type md2asm_release_distributed_operational_orography,%function
md2asm_release_distributed_operational_orography:
 cbz x0,.Ldistributed_orography_release_bad
 tst x0,#7
 b.ne .Ldistributed_orography_release_bad
 sub sp,sp,#64
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x9,#14088
 add x19,x0,x9
 mov x20,#3
.Ldistributed_orography_release_next:
 ldr x0,[x19]
 cbz x0,.Ldistributed_orography_release_skip
 bl free
 str xzr,[x19]
.Ldistributed_orography_release_skip:
 add x19,x19,#88
 subs x20,x20,#1
 b.ne .Ldistributed_orography_release_next
 mov w0,#0
 ldp x18,x30,[sp]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 add sp,sp,#64
 ret
.Ldistributed_orography_release_bad:
 mov w0,#2
 ret
.size md2asm_release_distributed_operational_orography,.-md2asm_release_distributed_operational_orography
.section .note.GNU-stack,"",%progbits

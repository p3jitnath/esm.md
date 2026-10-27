/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md. */
/* Own operational SETUP_GMV and its accepted integer index maps.
 * Physics formulations/openifs/dynamics/forecast_time_loop.md.
 * Contract skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md; accepted body proof retained.
 * Explicit owned inputs, complete fresh GMV1560, five read-only record pairs,
 * and selected six-word controls. Return0/1/2. No original state or callable. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_distributed_grid_motion_fields
.type md2asm_allocate_distributed_grid_motion_fields,%function
md2asm_allocate_distributed_grid_motion_fields:
 cbz x0,.Lgm_bad_leaf
 cmp x1,#1560
 b.lo .Lgm_bad_leaf
 cbz x2,.Lgm_bad_leaf
 cbz x3,.Lgm_bad_leaf
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lgm_bad_leaf
 tst x3,#3
 b.ne .Lgm_bad_leaf
 adds x4,x0,#1560
 b.cs .Lgm_bad_leaf
 adds x5,x2,#80
 b.cs .Lgm_bad_leaf
 adds x6,x3,#24
 b.cs .Lgm_bad_leaf
 cmp x0,x5
 b.hs .Lgm_table_clear
 cmp x2,x4
 b.lo .Lgm_bad_leaf
.Lgm_table_clear:
 cmp x0,x6
 b.hs .Lgm_controls_clear
 cmp x3,x4
 b.lo .Lgm_bad_leaf
.Lgm_controls_clear:
 mrs x5,fpcr
 cbnz x5,.Lgm_bad_leaf
 adr x5,.Lgm_expected_controls
 mov x6,#0
.Lgm_control_loop:
 ldr w7,[x3,x6]
 ldr w8,[x5,x6]
 /* NUNDEFLD is a live NAMCT0 override and must be outside valid indices. */
 cmp x6,#12
 b.ne .Lgm_fixed_control
 cmp w7,#0
 b.ge .Lgm_bad_leaf
 b .Lgm_next_control
.Lgm_fixed_control:
 cmp w7,w8
 b.ne .Lgm_bad_leaf
.Lgm_next_control:
 add x6,x6,#4
 cmp x6,#24
 b.lo .Lgm_control_loop
 adr x5,.Lgm_record_sizes
 mov x6,#0
.Lgm_record_loop:
 lsl x7,x6,#4
 add x7,x2,x7
 ldp x8,x9,[x7]
 cbz x8,.Lgm_bad_leaf
 tst x8,#7
 b.ne .Lgm_bad_leaf
 ldr x10,[x5,x6,lsl#3]
 cmp x9,x10
 b.lo .Lgm_bad_leaf
 adds x11,x8,x10
 b.cs .Lgm_bad_leaf
 cmp x0,x11
 b.hs .Lgm_record_clear
 cmp x8,x4
 b.lo .Lgm_bad_leaf
.Lgm_record_clear:
 add x6,x6,#1
 cmp x6,#5
 b.lo .Lgm_record_loop
 ldr x8,[x2]
#ifdef MD2ASM_RUNTIME_INPUT_DIMENSIONS
 ldr w12,[x8,#5144]
 sub w9,w12,#1
 cmp w9,#1023
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#5224]
 cmp w9,#137
 b.ne .Lgm_bad_leaf
 ldr w13,[x8,#5160]
 sub w9,w13,#1
 mov w10,#(388216&65535)
 movk w10,#(388216>>16),lsl#16
 cmp w9,w10
 b.hi .Lgm_bad_leaf
 ldr w11,[x8,#7376]
 cmp w11,#1
 b.lt .Lgm_bad_leaf
 add x11,x11,x12
 sub x11,x11,#1
 udiv x11,x11,x12
 cmp x11,x13
 b.ne .Lgm_bad_leaf
#else
 ldr w9,[x8,#5144]
 cmp w9,#17
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#5224]
 cmp w9,#137
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#5160]
 movz w10,#(97055&65535)
 movk w10,#(97055>>16),lsl#16
 cmp w9,w10
 b.ne .Lgm_bad_leaf
#endif
 ldr x8,[x2,#64]
 ldr w9,[x8,#0]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#4]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#8]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#20]
 cmp w9,#1
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#40]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#44]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#48]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#56]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#68]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#200]
 cmp w9,#1
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#280]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#300]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#304]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#332]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#336]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr x8,[x2,#32]
 ldr w9,[x8,#164]
 cmp w9,#1
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#168]
 cmp w9,#1
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#0]
 cmp w9,#1
 b.ne .Lgm_bad_leaf
 /* Live maps are already owned by the final MODEL configuration.
  * Only payload owner bases must be null before these two allocations. */
 adr x5,.Ldistributed_gmv_owner_offsets
 mov x6,#8
.Ldistributed_gmv_fresh_owners:
 ldr w7,[x5],#4
 ldr x7,[x0,x7]
 cbnz x7,.Lgm_bad_leaf
 subs x6,x6,#1
 b.ne .Ldistributed_gmv_fresh_owners
 ldr w5,[x0,#992]
 ldr w6,[x0,#996]
 cmp w5,#14
 b.ne .Lgm_bad_leaf
 cmp w6,#3
 b.ne .Lgm_bad_leaf
 ldr w5,[x0,#1360]
 ldr w6,[x0,#1364]
 cmp w5,#3
 b.ne .Lgm_bad_leaf
 cmp w6,#1
 b.ne .Lgm_bad_leaf
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x18,x27,[sp,#80]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 bl __errno_location
 mov x22,x0
 ldr w23,[x0]
 ldr x1,[x20,#32]
 ldr x2,[x20,#64]
 mov x3,x21
 mov x0,x19
 bl md2asm_initialize_grid_motion_index_maps
 ldr x24,[x20]
 ldr w25,[x24,#5144]
 ldr w26,[x24,#5224]
 ldr w27,[x24,#5160]
 ldr w9,[x19,#992]
 umull x0,w25,w26
 mul x0,x0,x9
 mul x0,x0,x27
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lgm_alloc_failed
 str x0,[x19]
 mov x1,x19
 mov x2,#4
 mov x3,x25
 mov x4,x26
 ldr w5,[x19,#992]
 mov x6,x27
 bl .Lgm_descriptor
 ldr w9,[x19,#996]
 umull x0,w25,w9
 mul x0,x0,x27
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lgm_alloc_failed
 str x0,[x19,#136]
 add x1,x19,#136
 mov x2,#3
 mov x3,x25
 ldr w4,[x19,#996]
 mov x5,x27
 mov x6,#1
 bl .Lgm_descriptor
 mov w0,#0
 b .Lgm_return
.Lgm_alloc_failed:
 ldr x0,[x19]
 cbz x0,.Lgm_cleanup_done
 bl free
 str xzr,[x19]
.Lgm_cleanup_done:
 mov w0,#1
.Lgm_return:
 str w23,[x22]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x18,x27,[sp,#80]
 ldp x29,x30,[sp],#128
 ret
.Lgm_bad_leaf:
 mov w0,#2
 ret
.size md2asm_allocate_distributed_grid_motion_fields,.-md2asm_allocate_distributed_grid_motion_fields

/* Internal GNU descriptor writer. x1 descriptor, x2 rank3/4, x3..6 extents.
 * The owner word is already set. All lower bounds are one, element width8. */
.Lgm_descriptor:
 mov x7,#8
 str x7,[x1,#16]
 str wzr,[x1,#24]
 strb w2,[x1,#28]
 mov w8,#3
 strb w8,[x1,#29]
 strh wzr,[x1,#30]
 str x7,[x1,#32]
 mov x8,#1
 str x8,[x1,#40]
 str x8,[x1,#48]
 str x3,[x1,#56]
 str x3,[x1,#64]
 str x8,[x1,#72]
 str x4,[x1,#80]
 mul x9,x3,x4
 str x9,[x1,#88]
 str x8,[x1,#96]
 str x5,[x1,#104]
 add x10,x3,#1
 add x10,x10,x9
 cmp x2,#3
 b.eq .Lgm_descriptor_end
 mul x11,x9,x5
 str x11,[x1,#112]
 str x8,[x1,#120]
 str x6,[x1,#128]
 add x10,x10,x11
.Lgm_descriptor_end:
 neg x10,x10
 str x10,[x1,#8]
 ret


.section .rodata
.p2align 2
.Ldistributed_gmv_owner_offsets: .word 0,136,248,384,496,632,744,880
.Lgm_expected_controls: .word 1,1,0,0,0,0
.p2align 3
.Lgm_record_sizes: .quad 17096,448,176,1096,456
.section .note.GNU-stack,"",%progbits

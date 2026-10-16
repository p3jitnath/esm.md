/* Contract: skills/md2asm/references/openifs/setup/empty_trajectory_state.md.
 * create(x0 state192,x1 capacity,x2 controls5i32)->w0 status.
 * Six source-ordered owners, null pointer defaults and shared block views. */
.arch armv8.2-a
.text
/* x0 desc,x1 base,x2 element bytes,x3 lower,x4 upper,w5 dtype. */
.Ltrajectory_descriptor:
 str x1,[x0]
 neg x6,x3
 str x6,[x0,#8]
 str x2,[x0,#16]
 str wzr,[x0,#24]
 lsl w5,w5,#8
 orr w5,w5,#1
 str w5,[x0,#28]
 str x2,[x0,#32]
 mov x6,#1
 str x6,[x0,#40]
 stp x3,x4,[x0,#48]
 ret
.p2align 4
.global md2asm_create_empty_trajectory_state
.type md2asm_create_empty_trajectory_state,%function
md2asm_create_empty_trajectory_state:
 cbz x0,.Ltrajectory_reject
 cbz x2,.Ltrajectory_reject
 tst x0,#7
 b.ne .Ltrajectory_reject
 tst x2,#3
 b.ne .Ltrajectory_reject
 cmp x1,#192
 b.lo .Ltrajectory_reject
 adds x9,x0,#192
 b.cs .Ltrajectory_reject
 adds x10,x2,#20
 b.cs .Ltrajectory_reject
 cmp x0,x10
 b.hs .Ltrajectory_controls
 cmp x2,x9
 b.lo .Ltrajectory_reject
.Ltrajectory_controls:
 ldp w9,w10,[x2]
 cmp w9,#0
 b.lt .Ltrajectory_reject
 cmp w10,#4096
 b.hi .Ltrajectory_reject
 cmp w9,w10
 b.gt .Ltrajectory_reject
 ldr w11,[x2,#8]
 sub w11,w11,#1
 cmp w11,#127
 b.hi .Ltrajectory_reject
 ldp w11,w12,[x2,#12]
 orr w11,w11,w12
 cbnz w11,.Ltrajectory_reject
 ldr x9,[x0]
 ldr x10,[x0,#64]
 ldr x11,[x0,#128]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Ltrajectory_reject
 mrs x9,fpcr
 cbnz x9,.Ltrajectory_reject
 sub sp,sp,#208
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x20,x2
 ldp w21,w22,[x20]
 ldr w23,[x20,#8]
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 stp xzr,xzr,[sp,#128]
 stp xzr,xzr,[sp,#144]
 stp xzr,xzr,[sp,#160]
 mov x26,#0
.Ltrajectory_allocate:
 cmp x26,#2
 b.hs .Ltrajectory_record_size
 sub w0,w22,w21
 add w0,w0,#1
 lsl x0,x0,#2
 b .Ltrajectory_malloc
.Ltrajectory_record_size:
 cmp x26,#2
 b.ne .Ltrajectory_block_size
 add w0,w22,#1
 lsl x0,x0,#9
 b .Ltrajectory_malloc
.Ltrajectory_block_size:
 adr x9,.Ltrajectory_element_sizes
 sub x10,x26,#3
 ldr w0,[x9,x10,lsl#2]
 mul x0,x0,x23
.Ltrajectory_malloc:
 bl malloc
 cbz x0,.Ltrajectory_failed
 add x9,sp,#128
 str x0,[x9,x26,lsl#3]
 add x26,x26,#1
 cmp x26,#6
 b.lo .Ltrajectory_allocate
 /* Timer assignments occur before any trajectory default initialization. */
 mov x26,#0
 mov w10,#-99
 sub w11,w22,w21
 add w11,w11,#1
.Ltrajectory_timer:
 add x9,sp,#128
 ldr x9,[x9,x26,lsl#3]
 mov w12,w11
.Ltrajectory_timer_value:
 str w10,[x9],#4
 subs w12,w12,#1
 b.ne .Ltrajectory_timer_value
 add x26,x26,#1
 cmp x26,#2
 b.lo .Ltrajectory_timer
 /* Source default initialization changes pointer bases only. */
 ldr x9,[sp,#144]
 add w10,w22,#1
.Ltrajectory_null_outer:
 str xzr,[x9]
 str xzr,[x9,#64]
 str xzr,[x9,#128]
 str xzr,[x9,#192]
 str xzr,[x9,#256]
 str xzr,[x9,#320]
 str xzr,[x9,#384]
 str xzr,[x9,#448]
 add x9,x9,#512
 subs w10,w10,#1
 b.ne .Ltrajectory_null_outer
 mov x26,#0
.Ltrajectory_null_block_type:
 add x9,sp,#152
 ldr x27,[x9,x26,lsl#3]
 adr x9,.Ltrajectory_element_sizes
 ldr w28,[x9,x26,lsl#2]
 adr x9,.Ltrajectory_null_tables
 ldr w13,[x9,x26,lsl#2]
 add x9,x9,w13,sxtw
 adr x10,.Ltrajectory_null_counts
 ldr w10,[x10,x26,lsl#2]
 mov x11,#0
.Ltrajectory_null_block:
 mov x12,#0
.Ltrajectory_null_pointer:
 ldr w13,[x9,x12,lsl#2]
 str xzr,[x27,x13]
 add x12,x12,#1
 cmp x12,x10
 b.lo .Ltrajectory_null_pointer
 add x27,x27,x28
 add x11,x11,#1
 cmp x11,x23
 b.lo .Ltrajectory_null_block
 add x26,x26,#1
 cmp x26,#3
 b.lo .Ltrajectory_null_block_type
 /* Build the three associated views at time zero. */
 mov x26,#0
.Ltrajectory_block_descriptor:
 ldr x0,[sp,#144]
 add x0,x0,#128
 add x0,x0,x26,lsl#6
 add x9,sp,#152
 ldr x1,[x9,x26,lsl#3]
 adr x9,.Ltrajectory_element_sizes
 ldr w2,[x9,x26,lsl#2]
 mov x3,#1
 mov x4,x23
 mov w5,#5
 bl .Ltrajectory_descriptor
 add x26,x26,#1
 cmp x26,#3
 b.lo .Ltrajectory_block_descriptor
 /* Later levels point to the same block owners. */
 ldr x9,[sp,#144]
 add x10,x9,#512
 add x9,x9,#128
 mov x26,#0
.Ltrajectory_share_level:
 cmp x26,x22
 b.hs .Ltrajectory_publish
 add x11,x10,#128
 mov x12,x9
 mov x13,#12
.Ltrajectory_share_words:
 ldp x14,x15,[x12],#16
 stp x14,x15,[x11],#16
 subs x13,x13,#1
 b.ne .Ltrajectory_share_words
 add x10,x10,#512
 add x26,x26,#1
 b .Ltrajectory_share_level
.Ltrajectory_publish:
 mov x0,x19
 ldr x1,[sp,#128]
 mov x2,#4
 mov x3,x21
 mov x4,x22
 mov w5,#1
 bl .Ltrajectory_descriptor
 add x0,x19,#64
 ldr x1,[sp,#136]
 mov x2,#4
 mov x3,x21
 mov x4,x22
 mov w5,#1
 bl .Ltrajectory_descriptor
 add x0,x19,#128
 ldr x1,[sp,#144]
 mov x2,#512
 mov x3,#0
 mov x4,x22
 mov w5,#5
 bl .Ltrajectory_descriptor
 mov w0,#0
 b .Ltrajectory_return
.Ltrajectory_failed:
 mov x26,#6
.Ltrajectory_failure_release:
 subs x26,x26,#1
 b.mi .Ltrajectory_failure_done
 add x9,sp,#128
 ldr x0,[x9,x26,lsl#3]
 cbz x0,.Ltrajectory_failure_release
 bl free
 b .Ltrajectory_failure_release
.Ltrajectory_failure_done:
 mov w0,#1
.Ltrajectory_return:
 str w25,[x24]
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#208
 ret
.Ltrajectory_reject:
 mov w0,#2
 ret
.size md2asm_create_empty_trajectory_state,.-md2asm_create_empty_trajectory_state
.p2align 4
.global md2asm_release_empty_trajectory_state
.type md2asm_release_empty_trajectory_state,%function
md2asm_release_empty_trajectory_state:
 cbz x0,.Ltrajectory_release_reject
 tst x0,#7
 b.ne .Ltrajectory_release_reject
 cmp x1,#192
 b.lo .Ltrajectory_release_reject
 adds x9,x0,#192
 b.cs .Ltrajectory_release_reject
 mrs x9,fpcr
 cbnz x9,.Ltrajectory_release_reject
 sub sp,sp,#80
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mrs x9,fpsr
 str x9,[sp,#64]
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 ldr x20,[x19,#128]
 cbz x20,.Ltrajectory_release_timers
 ldr x0,[x20,#256]
 bl free
 ldr x0,[x20,#192]
 bl free
 ldr x0,[x20,#128]
 bl free
 mov x0,x20
 bl free
 str xzr,[x19,#128]
.Ltrajectory_release_timers:
 ldr x0,[x19,#64]
 bl free
 str xzr,[x19,#64]
 ldr x0,[x19]
 bl free
 str xzr,[x19]
 str w22,[x21]
 ldr x9,[sp,#64]
 msr fpsr,x9
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#80
 mov w0,#0
 ret
.Ltrajectory_release_reject:
 mov w0,#2
 ret
.size md2asm_release_empty_trajectory_state,.-md2asm_release_empty_trajectory_state
.section .rodata
.p2align 3
.Ltrajectory_element_sizes: .word 96,3536,5528
.Ltrajectory_null_counts: .word 1,42,66
.Ltrajectory_null_tables:
 .word .Lcst_nulls-.Ltrajectory_null_tables,.Lslag_nulls-.Ltrajectory_null_tables,.Lphys_nulls-.Ltrajectory_null_tables

/* Source-declared CST pointer bases; all other bytes stay incoming. */
.Lcst_nulls:
 .word 8

/* Source-declared SLAG pointer bases; all other bytes stay incoming. */
.Lslag_nulls:
 .word 8,96,184,272,360,448,536,624,712,800,888,976,1064,1152,1240,1328,1416,1504,1592,1680,1768,1856,1944,2032,2120,2208,2296,2384,2472,2560,2648,2736,2848,2960,3024,3088,3152,3216,3280,3344,3408,3472

/* Source-declared PHYS pointer bases; all other bytes stay incoming. */
.Lphys_nulls:
 .word 8,96,184,272,360,448,536,624,712,800,888,976,1064,1152,1240,1328,1416,1528,1640,1752,1864,1976,2088,2176,2264,2352,2440,2528,2592,2656,2720,2784,2848,2912,2976,3040,3104,3168,3256,3344,3432,3520,3608,3696,3784,3872,3960,4048,4136,4224,4288,4376,4464,4552,4640,4728,4816,4904,4992,5080,5144,5208,5272,5336,5400,5464

.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/runtime_empty_trajectory_state.md.
 * Runtime live G/M/init bindings and a total six-owner byte budget.
 * The accepted fresh/empty six-owner body and constants below are retained.
 * B<=128 uses its preserved guarded entry. Larger positive B enters the same
 * body after the wrapper has proved all corresponding bounds and relations.
 */
.arch armv8.2-a
.text
.macro RUNTIME_TRAJ_SEPARATE a,ae,b,be
 cmp \a,\be
 b.hs .Lruntime_traj_pair_\@
 cmp \b,\ae
 b.lo .Lruntime_traj_refuse
.Lruntime_traj_pair_\@:
.endm
.p2align 4
.global md2asm_create_runtime_empty_trajectory_state
.type md2asm_create_runtime_empty_trajectory_state,%function
md2asm_create_runtime_empty_trajectory_state:
 mrs x8,fpcr
 cbnz x8,.Lruntime_traj_refuse
 cbz x0,.Lruntime_traj_refuse
 cbz x2,.Lruntime_traj_refuse
 cbz x4,.Lruntime_traj_refuse
 cbz x6,.Lruntime_traj_refuse
 orr x8,x0,x2
 orr x8,x8,x4
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lruntime_traj_refuse
 cmp x1,#192
 b.lo .Lruntime_traj_refuse
 mov x8,#20400
 cmp x3,x8
 b.lo .Lruntime_traj_refuse
 movz x8,#15248
 movk x8,#65,lsl#16
 cmp x5,x8
 b.lo .Lruntime_traj_refuse
 cmp x7,#16
 b.lo .Lruntime_traj_refuse
 adds x9,x0,#192
 b.cs .Lruntime_traj_refuse
 mov x8,#20400
 adds x10,x2,x8
 b.cs .Lruntime_traj_refuse
 movz x8,#15248
 movk x8,#65,lsl#16
 adds x11,x4,x8
 b.cs .Lruntime_traj_refuse
 adds x12,x6,#16
 b.cs .Lruntime_traj_refuse
 RUNTIME_TRAJ_SEPARATE x0,x9,x2,x10
 RUNTIME_TRAJ_SEPARATE x0,x9,x4,x11
 RUNTIME_TRAJ_SEPARATE x0,x9,x6,x12
 RUNTIME_TRAJ_SEPARATE x2,x10,x4,x11
 RUNTIME_TRAJ_SEPARATE x2,x10,x6,x12
 RUNTIME_TRAJ_SEPARATE x4,x11,x6,x12
 ldr x13,[x6]
 cbz x13,.Lruntime_traj_refuse
 tst x13,#3
 b.ne .Lruntime_traj_refuse
 adds x14,x13,#24
 b.cs .Lruntime_traj_refuse
 RUNTIME_TRAJ_SEPARATE x0,x9,x13,x14
 RUNTIME_TRAJ_SEPARATE x2,x10,x13,x14
 RUNTIME_TRAJ_SEPARATE x4,x11,x13,x14
 RUNTIME_TRAJ_SEPARATE x6,x12,x13,x14
 ldr x8,[x4,#8]
 cmp x8,x2
 b.ne .Lruntime_traj_refuse
 mov x9,#5144
 ldr w8,[x2,x9]
 cmp w8,#1
 b.lt .Lruntime_traj_refuse
 mov x9,#7376
 ldr w10,[x2,x9]
 cmp w10,#1
 b.lt .Lruntime_traj_refuse
 mov x9,#5160
 ldr w12,[x2,x9]
 cmp w12,#1
 b.lt .Lruntime_traj_refuse
 sub w11,w10,#1
 udiv w11,w11,w8
 add w11,w11,#1
 cmp w11,w12
 b.ne .Lruntime_traj_refuse
 movz x9,#48608
 movk x9,#20,lsl#16
 add x9,x4,x9
 ldp w10,w11,[x9]
 cmp w10,#0
 b.lt .Lruntime_traj_refuse
 cmp w11,#4096
 b.hi .Lruntime_traj_refuse
 cmp w10,w11
 b.gt .Lruntime_traj_refuse
 ldr w8,[x13]
 ldr w9,[x13,#20]
 orr w8,w8,w9
 cbnz w8,.Lruntime_traj_refuse
 /* Exact byte budget:8R+512*(NSTOP+1)+9160*B, all computed in64bits. */
 ldr x14,[x6,#8]
 sub w8,w11,w10
 add w8,w8,#1
 uxtw x8,w8
 lsl x8,x8,#3
 add w9,w11,#1
 uxtw x9,w9
 add x8,x8,x9,lsl#9
 mov w9,#9160
 umull x9,w12,w9
 add x8,x8,x9
 cmp x8,x14
 b.hi .Lruntime_traj_refuse
 sub sp,sp,#64
 stp x29,x30,[sp]
 str x18,[sp,#16]
 mov x29,sp
 stp w10,w11,[sp,#32]
 str w12,[sp,#40]
 stp wzr,wzr,[sp,#44]
 add x2,sp,#32
 cmp w12,#128
 b.hi .Lruntime_traj_large_dispatch
 bl md2asm_private_create_empty_trajectory_state_128
 b .Lruntime_traj_return
.Lruntime_traj_large_dispatch:
 bl .Lruntime_trajectory_large_entry
.Lruntime_traj_return:
 ldr x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.Lruntime_traj_refuse:
 mov w0,#2
 ret
.size md2asm_create_runtime_empty_trajectory_state,.-md2asm_create_runtime_empty_trajectory_state

.p2align 4
/* BEGIN accepted shared body; originalselectedentry remains a separate publicfile. */
/* Contract: skills/md2asm/references/openifs/setup/empty_trajectory_state.md.
 * create(x0 state192,x1 capacity,x2 controls5i32)->w0 status.
 * Six source-ordered owners, null pointer defaults and shared block views. */
.arch armv8.2-a
.text
/* x0 desc,x1 base,x2 element bytes,x3 lower,x4 upper,w5 dtype. */
.LruntimeTrajectory_descriptor:
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
.local md2asm_private_create_empty_trajectory_state_128
.type md2asm_private_create_empty_trajectory_state_128,%function
md2asm_private_create_empty_trajectory_state_128:
 cbz x0,.LruntimeTrajectory_reject
 cbz x2,.LruntimeTrajectory_reject
 tst x0,#7
 b.ne .LruntimeTrajectory_reject
 tst x2,#3
 b.ne .LruntimeTrajectory_reject
 cmp x1,#192
 b.lo .LruntimeTrajectory_reject
 adds x9,x0,#192
 b.cs .LruntimeTrajectory_reject
 adds x10,x2,#20
 b.cs .LruntimeTrajectory_reject
 cmp x0,x10
 b.hs .LruntimeTrajectory_controls
 cmp x2,x9
 b.lo .LruntimeTrajectory_reject
.LruntimeTrajectory_controls:
 ldp w9,w10,[x2]
 cmp w9,#0
 b.lt .LruntimeTrajectory_reject
 cmp w10,#4096
 b.hi .LruntimeTrajectory_reject
 cmp w9,w10
 b.gt .LruntimeTrajectory_reject
 ldr w11,[x2,#8]
 sub w11,w11,#1
 cmp w11,#127
 b.hi .LruntimeTrajectory_reject
.Lruntime_trajectory_large_entry:
 ldp w11,w12,[x2,#12]
 orr w11,w11,w12
 cbnz w11,.LruntimeTrajectory_reject
 ldr x9,[x0]
 ldr x10,[x0,#64]
 ldr x11,[x0,#128]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.LruntimeTrajectory_reject
 mrs x9,fpcr
 cbnz x9,.LruntimeTrajectory_reject
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
.LruntimeTrajectory_allocate:
 cmp x26,#2
 b.hs .LruntimeTrajectory_record_size
 sub w0,w22,w21
 add w0,w0,#1
 lsl x0,x0,#2
 b .LruntimeTrajectory_malloc
.LruntimeTrajectory_record_size:
 cmp x26,#2
 b.ne .LruntimeTrajectory_block_size
 add w0,w22,#1
 lsl x0,x0,#9
 b .LruntimeTrajectory_malloc
.LruntimeTrajectory_block_size:
 adr x9,.LruntimeTrajectory_element_sizes
 sub x10,x26,#3
 ldr w0,[x9,x10,lsl#2]
 mul x0,x0,x23
.LruntimeTrajectory_malloc:
 bl malloc
 cbz x0,.LruntimeTrajectory_failed
 add x9,sp,#128
 str x0,[x9,x26,lsl#3]
 add x26,x26,#1
 cmp x26,#6
 b.lo .LruntimeTrajectory_allocate
 /* Timer assignments occur before any trajectory default initialization. */
 mov x26,#0
 mov w10,#-99
 sub w11,w22,w21
 add w11,w11,#1
.LruntimeTrajectory_timer:
 add x9,sp,#128
 ldr x9,[x9,x26,lsl#3]
 mov w12,w11
.LruntimeTrajectory_timer_value:
 str w10,[x9],#4
 subs w12,w12,#1
 b.ne .LruntimeTrajectory_timer_value
 add x26,x26,#1
 cmp x26,#2
 b.lo .LruntimeTrajectory_timer
 /* Source default initialization changes pointer bases only. */
 ldr x9,[sp,#144]
 add w10,w22,#1
.LruntimeTrajectory_null_outer:
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
 b.ne .LruntimeTrajectory_null_outer
 mov x26,#0
.LruntimeTrajectory_null_block_type:
 add x9,sp,#152
 ldr x27,[x9,x26,lsl#3]
 adr x9,.LruntimeTrajectory_element_sizes
 ldr w28,[x9,x26,lsl#2]
 adr x9,.LruntimeTrajectory_null_tables
 ldr w13,[x9,x26,lsl#2]
 add x9,x9,w13,sxtw
 adr x10,.LruntimeTrajectory_null_counts
 ldr w10,[x10,x26,lsl#2]
 mov x11,#0
.LruntimeTrajectory_null_block:
 mov x12,#0
.LruntimeTrajectory_null_pointer:
 ldr w13,[x9,x12,lsl#2]
 str xzr,[x27,x13]
 add x12,x12,#1
 cmp x12,x10
 b.lo .LruntimeTrajectory_null_pointer
 add x27,x27,x28
 add x11,x11,#1
 cmp x11,x23
 b.lo .LruntimeTrajectory_null_block
 add x26,x26,#1
 cmp x26,#3
 b.lo .LruntimeTrajectory_null_block_type
 /* Build the three associated views at time zero. */
 mov x26,#0
.LruntimeTrajectory_block_descriptor:
 ldr x0,[sp,#144]
 add x0,x0,#128
 add x0,x0,x26,lsl#6
 add x9,sp,#152
 ldr x1,[x9,x26,lsl#3]
 adr x9,.LruntimeTrajectory_element_sizes
 ldr w2,[x9,x26,lsl#2]
 mov x3,#1
 mov x4,x23
 mov w5,#5
 bl .LruntimeTrajectory_descriptor
 add x26,x26,#1
 cmp x26,#3
 b.lo .LruntimeTrajectory_block_descriptor
 /* Later levels point to the same block owners. */
 ldr x9,[sp,#144]
 add x10,x9,#512
 add x9,x9,#128
 mov x26,#0
.LruntimeTrajectory_share_level:
 cmp x26,x22
 b.hs .LruntimeTrajectory_publish
 add x11,x10,#128
 mov x12,x9
 mov x13,#12
.LruntimeTrajectory_share_words:
 ldp x14,x15,[x12],#16
 stp x14,x15,[x11],#16
 subs x13,x13,#1
 b.ne .LruntimeTrajectory_share_words
 add x10,x10,#512
 add x26,x26,#1
 b .LruntimeTrajectory_share_level
.LruntimeTrajectory_publish:
 mov x0,x19
 ldr x1,[sp,#128]
 mov x2,#4
 mov x3,x21
 mov x4,x22
 mov w5,#1
 bl .LruntimeTrajectory_descriptor
 add x0,x19,#64
 ldr x1,[sp,#136]
 mov x2,#4
 mov x3,x21
 mov x4,x22
 mov w5,#1
 bl .LruntimeTrajectory_descriptor
 add x0,x19,#128
 ldr x1,[sp,#144]
 mov x2,#512
 mov x3,#0
 mov x4,x22
 mov w5,#5
 bl .LruntimeTrajectory_descriptor
 mov w0,#0
 b .LruntimeTrajectory_return
.LruntimeTrajectory_failed:
 mov x26,#6
.LruntimeTrajectory_failure_release:
 subs x26,x26,#1
 b.mi .LruntimeTrajectory_failure_done
 add x9,sp,#128
 ldr x0,[x9,x26,lsl#3]
 cbz x0,.LruntimeTrajectory_failure_release
 bl free
 b .LruntimeTrajectory_failure_release
.LruntimeTrajectory_failure_done:
 mov w0,#1
.LruntimeTrajectory_return:
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
.LruntimeTrajectory_reject:
 mov w0,#2
 ret
.size md2asm_private_create_empty_trajectory_state_128,.-md2asm_private_create_empty_trajectory_state_128
.p2align 4
.global md2asm_release_runtime_empty_trajectory_state
.type md2asm_release_runtime_empty_trajectory_state,%function
md2asm_release_runtime_empty_trajectory_state:
 cbz x0,.LruntimeTrajectory_release_reject
 tst x0,#7
 b.ne .LruntimeTrajectory_release_reject
 cmp x1,#192
 b.lo .LruntimeTrajectory_release_reject
 adds x9,x0,#192
 b.cs .LruntimeTrajectory_release_reject
 mrs x9,fpcr
 cbnz x9,.LruntimeTrajectory_release_reject
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
 cbz x20,.LruntimeTrajectory_release_timers
 ldr x0,[x20,#256]
 bl free
 ldr x0,[x20,#192]
 bl free
 ldr x0,[x20,#128]
 bl free
 mov x0,x20
 bl free
 str xzr,[x19,#128]
.LruntimeTrajectory_release_timers:
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
.LruntimeTrajectory_release_reject:
 mov w0,#2
 ret
.size md2asm_release_runtime_empty_trajectory_state,.-md2asm_release_runtime_empty_trajectory_state
.section .rodata
.p2align 3
.LruntimeTrajectory_element_sizes: .word 96,3536,5528
.LruntimeTrajectory_null_counts: .word 1,42,66
.LruntimeTrajectory_null_tables:
 .word .Lcst_nulls-.LruntimeTrajectory_null_tables,.Lslag_nulls-.LruntimeTrajectory_null_tables,.Lphys_nulls-.LruntimeTrajectory_null_tables

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

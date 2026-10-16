// Complete selected serial SUFPCNT; x0 object8544,x1 cap,x2 owned
// SUCT0 namespace51112,x3 cap,x4 output504,x5 cap. Return0/1/2.
// Frame640; private two-owner commit. No FP instructions or original state.
.text
.p2align 2
.global md2asm_initialize_fullpos_output_control
.type md2asm_initialize_fullpos_output_control,%function
md2asm_initialize_fullpos_output_control:
 cbz x0,.Lbad_early
 cbz x2,.Lbad_early
 cbz x4,.Lbad_early
 orr x6,x0,x2
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lbad_early
 mov x6,#8544
 cmp x1,x6
 b.lo .Lbad_early
 adds x7,x0,x6
 b.cs .Lbad_early
 mov x6,#51112
 cmp x3,x6
 b.lo .Lbad_early
 adds x8,x2,x6
 b.cs .Lbad_early
 cmp x5,#504
 b.lo .Lbad_early
 adds x9,x4,#504
 b.cs .Lbad_early
 cmp x0,x8
 b.hs .Lfirst_second_disjoint
 cmp x2,x7
 b.lo .Lbad_early
.Lfirst_second_disjoint:
 cmp x0,x9
 b.hs .Lfirst_output_disjoint
 cmp x4,x7
 b.lo .Lbad_early
.Lfirst_output_disjoint:
 cmp x2,x9
 b.hs .Lrecords_disjoint
 cmp x4,x8
 b.lo .Lbad_early
.Lrecords_disjoint:
 ldr x6,[x4,#376]
 ldr x7,[x4,#440]
 orr x6,x6,x7
 cbnz x6,.Lbad_early
 mov x6,#34744
 add x6,x2,x6
 mov x7,#240
.Lblank_paths:
 ldrb w8,[x6],#1
 cmp w8,#32
 b.ne .Lbad_early
 subs x7,x7,#1
 b.ne .Lblank_paths
 add x6,x0,#485
 mov x7,#0
.Lmonitor_paths:
 ldrb w8,[x6,x7]
 mov w9,#32
 cmp x7,#0
 mov w10,#'.'
 csel w9,w10,w9,eq
 cmp w8,w9
 b.ne .Lbad_early
 add x7,x7,#1
 cmp x7,#180
 b.lo .Lmonitor_paths
 add x6,x0,#665
 mov x7,#0
.Lmonitor_out:
 ldrb w8,[x6,x7]
 mov w9,#32
 cmp x7,#0
 mov w10,#'.'
 csel w9,w10,w9,eq
 cmp w8,w9
 b.ne .Lbad_early
 add x7,x7,#1
 cmp x7,#180
 b.lo .Lmonitor_out
 mov x6,#34612
 add x6,x2,x6
 mov x7,#128
.Lmonitor_name:
 ldrb w8,[x6],#1
 sub w8,w8,#32
 cmp w8,#94
 b.hi .Lbad_early
 subs x7,x7,#1
 b.ne .Lmonitor_name
 ldr w6,[x0,#852]
 ldr w7,[x0,#4696]
 cmp w6,#0
 cneg w6,w6,lt
 cmp w6,#960
 b.hi .Lbad_early
 cmp w7,#0
 cneg w7,w7,lt
 cmp w7,#960
 b.hi .Lbad_early
 sub sp,sp,#640
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov w22,w6
 mov w23,w7
 add x24,sp,#112
 mov x25,#0
 mov x26,#0
 add x0,x22,#1
 lsl x0,x0,#2
 bl malloc
 ldr x18,[sp,#96]
 cbz x0,.Lallocation_failed
 mov x25,x0
 add x0,x23,#1
 lsl x0,x0,#2
 bl malloc
 ldr x18,[sp,#96]
 cbz x0,.Lallocation_failed
 mov x26,x0
 // Both source copies include element zero, which carries the signed count.
 add x9,x19,#852
 mov x10,x25
 add x11,x22,#1
.Lcopy_schedule:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs x11,x11,#1
 b.ne .Lcopy_schedule
 mov x9,#4696
 add x9,x19,x9
 mov x10,x26
 add x11,x23,#1
.Lcopy_minutes:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs x11,x11,#1
 b.ne .Lcopy_minutes
 stp wzr,wzr,[x24]
 str wzr,[x24,#8]
 add x9,x24,#12
 mov x10,#360
 mov w11,#32
.Lpad_names:
 strb w11,[x9],#1
 subs x10,x10,#1
 b.ne .Lpad_names
 mov x9,#34612
 add x9,x20,x9
 mov x10,#128
.Ltrim_monitor:
 cbz x10,.Lmonitor_ready
 sub x11,x10,#1
 ldrb w12,[x9,x11]
 cmp w12,#32
 b.ne .Lmonitor_ready
 sub x10,x10,#1
 b .Ltrim_monitor
.Lmonitor_ready:
 cbz x10,.Lblank_monitor
 mov w11,#'.'
 strb w11,[x24,#12]
 mov w11,#'/'
 strb w11,[x24,#13]
 add x11,x24,#14
 mov x12,#0
.Lcopy_monitor:
 ldrb w13,[x9,x12]
 strb w13,[x11,x12]
 add x12,x12,#1
 cmp x12,x10
 b.lo .Lcopy_monitor
.Lblank_monitor:
 mov x9,#8540
 ldr w9,[x19,x9]
 str w9,[x24,#372]
 add x0,x24,#376
 mov x1,x25
 mov x2,x22
 bl .Ldescriptor
 add x0,x24,#440
 mov x1,x26
 mov x2,x23
 bl .Ldescriptor
 mov x9,x24
 mov x10,x21
 mov x11,#63
.Lcommit:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcommit
 mov w0,#0
 b .Lreturn
.Lallocation_failed:
 cbz x25,.Lfailed
 mov x0,x25
 bl free
 ldr x18,[sp,#96]
.Lfailed:
 mov w0,#1
.Lreturn:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#640
 ret
.Lbad_early:
 mov w0,#2
 ret
.size md2asm_initialize_fullpos_output_control,.-md2asm_initialize_fullpos_output_control
.Ldescriptor:
 str x1,[x0]
 str xzr,[x0,#8]
 mov x9,#4
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x9,#0x0101,lsl#32
 str x9,[x0,#24]
 mov x9,#1
 str x9,[x0,#40]
 str xzr,[x0,#48]
 str x2,[x0,#56]
 ret
.global md2asm_release_fullpos_output_control
.type md2asm_release_fullpos_output_control,%function
md2asm_release_fullpos_output_control:
 cbz x0,.Lrelease_bad
 tst x0,#7
 b.ne .Lrelease_bad
 cmp x1,#504
 b.lo .Lrelease_bad
 adds x9,x0,#504
 b.cs .Lrelease_bad
 stp x29,x30,[sp,#-48]!
 stp x19,x18,[sp,#16]
 mov x19,x0
 ldr x0,[x19,#376]
 cbz x0,.Lrelease_second
 bl free
 ldr x18,[sp,#24]
 str xzr,[x19,#376]
.Lrelease_second:
 ldr x0,[x19,#440]
 cbz x0,.Lreleased
 bl free
 ldr x18,[sp,#24]
 str xzr,[x19,#440]
.Lreleased:
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#48
 mov w0,#0
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_fullpos_output_control,.-md2asm_release_fullpos_output_control
.section .note.GNU-stack,"",%progbits

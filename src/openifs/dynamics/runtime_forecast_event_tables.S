/* Contract skills/md2asm/references/openifs/dynamics/runtime_forecast_events.md.
 * Source CNT4 event order with live assembly-owned inputs. */
.arch armv8.2-a
.text
.p2align 4
.equ EVENT_PRIVATE,512
.equ EVENT_LIST,1664
.equ EVENT_MINUTES,1728
.equ EVENT_START,1800
.equ EVENT_ACTIVE,1804
.equ EVENT_ONE,1808
.equ EVENT_CONDITION,1812
.equ EVENT_STOP,1816
.equ EVENT_FREQUENCY,1820
.macro ECALL symbol
 str x18,[sp,#176]
 bl \symbol
 ldr x18,[sp,#176]
.endm
.macro EADDRESS reg,base,offset
 movz \reg,#(\offset&65535)
 movk \reg,#(\offset>>16),lsl#16
 add \reg,\base,\reg
.endm
.global md2asm_initialize_runtime_forecast_events
.type md2asm_initialize_runtime_forecast_events,%function
md2asm_initialize_runtime_forecast_events:
 sub sp,sp,#2048
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,#0
 mov x27,x6
 cmp x7,#1024
 b.lo .Le_bad
 cbz x19,.Le_bad
 cbz x20,.Le_bad
 cbz x21,.Le_bad
 cbz x22,.Le_bad
 cbz x24,.Le_bad
 orr x9,x19,x20
 orr x9,x9,x21
 orr x9,x9,x22
 orr x9,x9,x23
 orr x9,x9,x24
 tst x9,#7
 b.ne .Le_bad
 mrs x9,fpcr
 cbnz x9,.Le_bad
 cbz x27,.Le_bad
 mov x9,#1
 lsl x9,x9,#36
 cmp x27,x9
 b.hi .Le_bad
 ldr x9,[x24]
 cbnz x9,.Le_bad
 ldr w9,[x24,#16]
 cbnz w9,.Le_bad
 /* Complete owner spans, including optional Fullpos when present. */
 add x0,sp,#192
 mov x9,#67616&65535
 movk x9,#67616>>16,lsl#16
 stp x19,x9,[x0]
 movz x9,#4275088&65535
 movk x9,#4275088>>16,lsl#16
 stp x20,x9,[x0,#16]
 mov x9,#552
 stp x21,x9,[x0,#32]
 mov x9,#60
 stp x22,x9,[x0,#48]
 mov x9,#1024
 stp x24,x9,[x0,#64]
 mov x1,#5
 cbz x23,.Le_spans_ready
 movz x9,#503824&65535
 movk x9,#503824>>16,lsl#16
 stp x23,x9,[x0,#80]
 mov x1,#6
.Le_spans_ready:
 bl .Le_spans
 cbnz w0,.Le_bad
 ldr x9,[x19]
 cmp x9,x20
 b.ne .Le_bad
 mov x9,#35688
 ldr w9,[x19,x9]
 cmp w9,#1
 b.ne .Le_bad
 mov x9,#35872
 ldr w9,[x19,x9]
 cbnz w9,.Le_bad
 EADDRESS x9,x20,1359328
 ldp w10,w11,[x9]
 cbnz w10,.Le_bad
 cmp w11,#576
 b.hi .Le_bad
 str w11,[sp,#EVENT_STOP]
 EADDRESS x9,x20,4218356
 ldr w9,[x9]
 cbnz w9,.Le_bad
 EADDRESS x9,x20,4232912
 ldr w9,[x9]
 cbnz w9,.Le_bad
 mov x9,#0
.Le_n1_bounds:
 ldr w10,[x22,x9]
 cmp w10,#1
 b.hi .Le_bad
 add x9,x9,#4
 cmp x9,#60
 b.lo .Le_n1_bounds
 /* Private metadata remains unpublished until every schedule succeeds. */
 add x10,sp,#EVENT_PRIVATE
 mov x9,#0
.Le_clear_private:
 str xzr,[x10,x9]
 add x9,x9,#8
 cmp x9,#1024
 b.lo .Le_clear_private
 mov w9,#1
 str w9,[x10,#16]
 ldr w9,[sp,#EVENT_STOP]
 str w9,[x10,#24]
 cmp x23,#0
 cset w9,ne
 str w9,[x10,#28]
 str wzr,[sp,#EVENT_START]
 mov w9,#1
 str w9,[sp,#EVENT_ONE]
 mov x26,#0
 mov x28,#0
.Le_size_row:
 adr x9,.Le_rows
 add x9,x9,x26,lsl#5
 ldr w10,[x9]
 cmp w10,#-1
 b.eq .Le_size_restart
 cmp w10,#-2
 b.eq .Le_size_fullpos
 ldr w11,[x19,x10]
 b .Le_frequency_loaded
.Le_size_restart:
 ldr w11,[x21,#36]
 b .Le_frequency_loaded
.Le_size_fullpos:
 cbz x23,.Le_absent_fullpos
 ldr w11,[x23,#372]
 cbz w11,.Le_absent_fullpos
.Le_frequency_loaded:
 cmp x26,#3
 b.eq .Le_max_frequency
 cmp x26,#4
 b.ne .Le_positive_frequency
.Le_max_frequency:
 cmp w11,#1
 mov w12,#1
 csel w11,w11,w12,ge
.Le_positive_frequency:
 cmp w11,#1
 b.lt .Le_bad
 movz w12,#1000000&65535
 movk w12,#1000000>>16,lsl#16
 cmp w11,w12
 b.gt .Le_bad
 add x9,sp,#EVENT_PRIVATE+832
 str w11,[x9,x26,lsl#2]
 ldr w12,[sp,#EVENT_STOP]
 udiv w12,w12,w11
 add x12,x12,#1
 add x28,x28,x12,lsl#2
 b .Le_size_next
.Le_absent_fullpos:
 add x9,sp,#EVENT_PRIVATE+832
 str wzr,[x9,x26,lsl#2]
.Le_size_next:
 add x26,x26,#1
 cmp x26,#12
 b.lo .Le_size_row
 cmp x27,x28
 b.lo .Le_bad
 mov x0,x28
 ECALL malloc
 cbz x0,.Le_alloc_bad
 mov x25,x0
 /* Zeroing is the source restart preimage and private nonobservable padding. */
 mov x1,#0
 mov x2,x28
 ECALL memset
 add x9,sp,#EVENT_PRIVATE
 stp x25,x28,[x9]
 mov x26,#0
 mov x27,x25
.Le_build_row:
 add x9,sp,#EVENT_PRIVATE+832
 ldr w11,[x9,x26,lsl#2]
 add x9,sp,#EVENT_PRIVATE+64
 add x0,x9,x26,lsl#6
 cbz w11,.Le_build_next
 ldr w2,[sp,#EVENT_STOP]
 udiv w2,w2,w11
 mov x1,x27
 bl .Le_descriptor
 add x9,sp,#EVENT_PRIVATE+832
 ldr w11,[x9,x26,lsl#2]
 ldr w12,[sp,#EVENT_STOP]
 udiv w12,w12,w11
 add x12,x12,#1
 add x27,x27,x12,lsl#2
 adr x28,.Le_rows
 add x28,x28,x26,lsl#5
 ldr w9,[x28,#4]
 cmp w9,#-1
 b.eq .Le_restart_list
 cmp w9,#-2
 b.eq .Le_fullpos_list
 add x1,x19,x9
 add x0,sp,#EVENT_LIST
 mov x2,#960
 bl .Le_descriptor
 add x5,sp,#EVENT_LIST
 b .Le_list_ready
.Le_restart_list:
 add x1,x21,#248
 add x0,sp,#EVENT_LIST
 mov x2,#40
 bl .Le_descriptor
 add x5,sp,#EVENT_LIST
 b .Le_list_ready
.Le_fullpos_list:
 add x5,x23,#376
.Le_list_ready:
 mov x6,#0
 ldr w9,[x28,#8]
 cbz w9,.Le_minutes_ready
 cmp w9,#-2
 b.eq .Le_fullpos_minutes
 str x5,[sp,#184]
 add x1,x19,x9
 add x0,sp,#EVENT_MINUTES
 mov x2,#960
 bl .Le_descriptor
 ldr x5,[sp,#184]
 add x6,sp,#EVENT_MINUTES
 b .Le_minutes_ready
.Le_fullpos_minutes:
 add x6,x23,#440
.Le_minutes_ready:
 /* N1 is a source pointer. DDH passes the source literal one. */
 ldr w9,[x28,#12]
 cmp w9,#-1
 b.eq .Le_literal_one
 add x3,x22,x9
 b .Le_n1_ready
.Le_literal_one:
 add x3,sp,#EVENT_ONE
.Le_n1_ready:
 /* Original signed frequency remains the MONIO_T argument. */
 ldr w9,[x28]
 cmp w9,#-1
 b.eq .Le_restart_frequency
 cmp w9,#-2
 b.eq .Le_fullpos_frequency
 add x4,x19,x9
 b .Le_raw_frequency_ready
.Le_restart_frequency:
 add x4,x21,#36
 b .Le_raw_frequency_ready
.Le_fullpos_frequency:
 add x4,x23,#372
.Le_raw_frequency_ready:
 mov w9,#1
 ldr w10,[x28,#16]
 cmp w10,#1
 b.eq .Le_inactive
 cmp w10,#2
 b.eq .Le_inactive
 b .Le_active_ready
.Le_inactive:
 mov w9,#0
.Le_active_ready:
 str w9,[sp,#EVENT_ACTIVE]
 add x9,sp,#EVENT_ACTIVE
 str x9,[sp]
 mov x7,#0
 cmp w10,#3
 b.ne .Le_condition_ready
 ldr w9,[x4]
 ldr w11,[sp,#EVENT_STOP]
 cmp w9,w11
 cset w9,le
 str w9,[sp,#EVENT_CONDITION]
 add x7,sp,#EVENT_CONDITION
.Le_condition_ready:
 add x0,sp,#EVENT_START
 EADDRESS x1,x20,1359328
 add x9,sp,#EVENT_PRIVATE+64
 add x2,x9,x26,lsl#6
 ECALL md2asm_runtime_periodic_output_schedule
 cbnz w0,.Le_bad
.Le_build_next:
 add x26,x26,#1
 cmp x26,#12
 b.lo .Le_build_row
 /* The last reader owns one complete immutable private metadata view. */
 add x9,sp,#EVENT_PRIVATE
 mov x10,#0
.Le_publish:
 ldr x11,[x9,x10]
 str x11,[x24,x10]
 add x10,x10,#8
 cmp x10,#1024
 b.lo .Le_publish
 mov x25,#0
 mov w0,#0
 b .Le_return
.Le_alloc_bad:
 mov w0,#1
 b .Le_return
.Le_bad:
 mov w0,#2
.Le_return:
 str w0,[sp,#168]
 cbz x25,.Le_restore
 mov x0,x25
 ECALL free
.Le_restore:
 ldr w0,[sp,#168]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#2048
 ret
.size md2asm_initialize_runtime_forecast_events,.-md2asm_initialize_runtime_forecast_events

/* Complete GNU rank-one integer descriptor with bounds0throughx2. */
.Le_descriptor:
 mov x9,#0
.Le_descriptor_zero:
 str xzr,[x0,x9]
 add x9,x9,#8
 cmp x9,#64
 b.lo .Le_descriptor_zero
 str x1,[x0]
 mov x9,#4
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x9,#0x101
 lsl x9,x9,#32
 str x9,[x0,#24]
 mov x9,#1
 str x9,[x0,#40]
 str x2,[x0,#56]
 ret
/* x0 pointer/byte-count pairs, x1 count. */
.Le_spans:
 mov x9,#0
.Le_span_outer:
 add x10,x0,x9,lsl#4
 ldp x11,x12,[x10]
 adds x12,x11,x12
 b.cs .Le_helper_bad
 add x13,x9,#1
.Le_span_inner:
 cmp x13,x1
 b.hs .Le_span_next
 add x10,x0,x13,lsl#4
 ldp x14,x15,[x10]
 adds x15,x14,x15
 b.cs .Le_helper_bad
 cmp x11,x15
 b.hs .Le_span_disjoint
 cmp x14,x12
 b.lo .Le_helper_bad
.Le_span_disjoint:
 add x13,x13,#1
 b .Le_span_inner
.Le_span_next:
 add x9,x9,#1
 cmp x9,x1
 b.lo .Le_span_outer
 mov w0,#0
 ret
.Le_helper_bad:
 mov w0,#2
 ret

.global md2asm_release_runtime_forecast_events
.type md2asm_release_runtime_forecast_events,%function
md2asm_release_runtime_forecast_events:
 cbz x0,.Le_release_bad_leaf
 cmp x1,#1024
 b.lo .Le_release_bad_leaf
 tst x0,#7
 b.ne .Le_release_bad_leaf
 adds x9,x0,#1024
 b.cs .Le_release_bad_leaf
 stp x19,x30,[sp,#-32]!
 str x18,[sp,#16]
 mov x19,x0
 ldr x0,[x19]
 cbz x0,.Le_release_clear
 bl free
.Le_release_clear:
 stp xzr,xzr,[x19]
 str wzr,[x19,#16]
 add x9,x19,#64
 mov x10,#12
.Le_release_descriptors:
 str xzr,[x9],#64
 subs x10,x10,#1
 b.ne .Le_release_descriptors
 ldr x18,[sp,#16]
 ldp x19,x30,[sp],#32
 mov w0,#0
 ret
.Le_release_bad_leaf:
 mov w0,#2
 ret
.size md2asm_release_runtime_forecast_events,.-md2asm_release_runtime_forecast_events
.section .rodata
.p2align 3
/* frequency offset, list offset, minute offset, N1offset, activity, reserved. */
.Le_rows:
 .word 35708,584,47812,0,0,0,0,0
 .word 35712,4428,40124,4,0,0,0,0
 .word 40060,36216,43968,16,1,0,0,0
 .word 35720,8272,0,20,0,0,0,0
 .word 35724,12116,0,8,0,0,0,0
 .word 35732,15960,0,-1,2,0,0,0
 .word 35736,19804,0,-1,2,0,0,0
 .word 35740,23648,0,-1,2,0,0,0
 .word 35744,27492,0,-1,2,0,0,0
 .word -1,-1,0,12,0,0,0,0
 .word 35752,31336,0,48,3,0,0,0
 .word -2,-2,-2,0,0,0,0,0
.section .note.GNU-stack,"",%progbits

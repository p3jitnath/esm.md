// MONIO_T selects output steps from live forecast and request descriptors.
// Contract skills/md2asm/references/openifs/support/runtime_periodic_output_schedule.md.
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_runtime_periodic_output_schedule
.type md2asm_runtime_periodic_output_schedule,%function
md2asm_runtime_periodic_output_schedule:
 mov x17,sp
 sub sp,sp,#320
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x29,[sp,#96]
 mov x29,sp
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 stp x4,x5,[sp,#144]
 stp x6,x7,[sp,#160]
 ldr x9,[x17]
 str x9,[sp,#176]
 mrs x9,fpcr
 cbnz x9,.Lschedule_bad
 cbz x0,.Lschedule_bad
 cbz x1,.Lschedule_bad
 cbz x2,.Lschedule_bad
 cbz x3,.Lschedule_bad
 cbz x4,.Lschedule_bad
 cbz x5,.Lschedule_bad
 mov x23,x1
 ldrsw x21,[x0]
 mov x15,#16960
 movk x15,#15,lsl #16
 cmp x21,#0
 b.lt .Lschedule_bad
 cmp x21,x15
 b.gt .Lschedule_bad
 ldp w9,w10,[x23]
 cmp w9,#0
 b.lt .Lschedule_bad
 cmp w9,w10
 b.gt .Lschedule_bad
 cmp w10,w15
 b.gt .Lschedule_bad
 stp w9,w10,[sp,#208]
 ldr x9,[x23,#200]
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lschedule_bad
 ldrsw x9,[x4]
 str w9,[sp,#196]
 ldr w9,[x3]
 str w9,[sp,#192]
 mov w9,#1
 cbz x7,.Lschedule_condition_ready
 ldr w9,[x7]
 cmp w9,#1
 b.hi .Lschedule_bad
.Lschedule_condition_ready:
 str w9,[sp,#200]
 ldr x10,[sp,#176]
 cbz x10,.Lschedule_active_ready
 ldr w9,[x10]
 cmp w9,#1
 b.hi .Lschedule_bad
 cbnz w9,.Lschedule_active_ready
 str wzr,[sp,#192]
.Lschedule_active_ready:
 ldr x9,[x2,#16]
 cmp x9,#4
 b.ne .Lschedule_bad
 ldrb w9,[x2,#28]
 cmp w9,#1
 b.ne .Lschedule_bad
 ldr x20,[x2,#40]
 cmp x20,#1
 b.lt .Lschedule_bad
 cmp x20,x15
 b.gt .Lschedule_bad
 ldp x9,x10,[x2,#48]
 sub x22,x10,x9
 add x22,x22,#1
 cmp x22,#0
 b.lt .Lschedule_bad
 cmp x22,x15
 b.gt .Lschedule_bad
 add x22,x21,x22
 sub x22,x22,#1
 ldr x19,[x2]
 cmp x22,x21
 b.ge .Lschedule_nonempty_output
 cbz x21,.Lschedule_bad
 b .Lschedule_output_empty
.Lschedule_nonempty_output:
 cbz x19,.Lschedule_bad
.Lschedule_output_empty:
 lsl x20,x20,#2
 ldr x9,[x5,#16]
 cmp x9,#4
 b.ne .Lschedule_bad
 ldrb w9,[x5,#28]
 cmp w9,#1
 b.ne .Lschedule_bad
 ldr x25,[x5,#40]
 cmp x25,#1
 b.lt .Lschedule_bad
 cmp x25,x15
 b.gt .Lschedule_bad
 ldr x24,[x5]
 cbz x24,.Lschedule_bad
 ldrsw x26,[x24]
 cmp x26,x15
 b.gt .Lschedule_bad
 neg x9,x15
 cmp x26,x9
 b.lt .Lschedule_bad
 cmp x26,#0
 cneg x9,x26,lt
 str x9,[sp,#184]
 ldp x10,x11,[x5,#48]
 sub x11,x11,x10
 cmp x11,x9
 b.lt .Lschedule_bad
 lsl x25,x25,#2
 mov x27,#0
 mov x28,#0
 cmp x26,#0
 b.ge .Lschedule_list_admission
 cbz x6,.Lschedule_minutes_ready
 ldr x27,[x6]
 cbz x27,.Lschedule_minutes_ready
 ldr x9,[x6,#16]
 cmp x9,#4
 b.ne .Lschedule_bad
 ldrb w9,[x6,#28]
 cmp w9,#1
 b.ne .Lschedule_bad
 ldr x28,[x6,#40]
 cmp x28,#1
 b.lt .Lschedule_bad
 cmp x28,x15
 b.gt .Lschedule_bad
 ldp x9,x10,[x6,#48]
 sub x10,x10,x9
 ldr x9,[sp,#184]
 cmp x10,x9
 b.lt .Lschedule_bad
 lsl x28,x28,#2
.Lschedule_minutes_ready:
 ldr w9,[sp,#196]
 cmp w9,#0
 b.lt .Lschedule_bad
.Lschedule_list_admission:
 mov x12,#1
 ldr x13,[sp,#184]
 cbz x13,.Lschedule_admission_done
.Lschedule_admit_element:
 mul x9,x12,x25
 ldrsw x10,[x24,x9]
 cmp x26,#0
 b.lt .Lschedule_admit_time
 ldrsw x9,[sp,#196]
 mul x11,x10,x9
 sxtw x9,w11
 cmp x9,x11
 b.ne .Lschedule_bad
 b .Lschedule_admit_next
.Lschedule_admit_time:
 cmp x10,#0
 b.gt .Lschedule_bad
 mov x9,#-2147483648
 cmp x10,x9
 b.eq .Lschedule_bad
 cbz x27,.Lschedule_admit_next
 mul x9,x12,x28
 ldr w10,[x27,x9]
 cmp w10,#0
 b.lt .Lschedule_bad
.Lschedule_admit_next:
 add x12,x12,#1
 cmp x12,x13
 b.le .Lschedule_admit_element
.Lschedule_admission_done:
 ldr d0,[x23,#200]
 fabs d0,d0
 adrp x9,.Lschedule_constants
 add x9,x9,:lo12:.Lschedule_constants
 ldr d1,[x9]
 fcmpe d0,d1
 b.ge .Lschedule_dt_ready
 fmov d0,d1
.Lschedule_dt_ready:
 ldr d2,[x9,#8]
 ldr d3,[x9,#16]
 ldr d4,[x9,#24]
 ldr w10,[sp,#196]
 scvtf d5,w10
 mov x10,x21
 mov x11,x19
.Lschedule_clear:
 cmp x10,x22
 b.gt .Lschedule_select
 str wzr,[x11]
 add x11,x11,x20
 add x10,x10,#1
 b .Lschedule_clear
.Lschedule_select:
 cmp x26,#0
 b.gt .Lschedule_explicit
 b.lt .Lschedule_times
 ldr w9,[sp,#200]
 cbz w9,.Lschedule_good
 ldp w12,w13,[sp,#208]
 ldr w14,[sp,#196]
 cmp w14,#1
 mov w9,#1
 csel w14,w14,w9,ge
.Lschedule_periodic_loop:
 sdiv w10,w12,w14
 msub w9,w10,w14,w12
 cbnz w9,.Lschedule_periodic_next
 sxtw x10,w10
 bl .Lschedule_store
.Lschedule_periodic_next:
 add w12,w12,#1
 cmp w12,w13
 b.le .Lschedule_periodic_loop
 b .Lschedule_good
.Lschedule_explicit:
 mov x12,#1
 ldr w14,[sp,#196]
.Lschedule_explicit_loop:
 mul x9,x12,x25
 ldr w10,[x24,x9]
 mul w11,w10,w14
 ldp w9,w13,[sp,#208]
 cmp w11,w9
 b.lt .Lschedule_explicit_next
 cmp w11,w13
 b.gt .Lschedule_explicit_next
 sxtw x10,w10
 bl .Lschedule_store
.Lschedule_explicit_next:
 add x12,x12,#1
 cmp x12,x26
 b.le .Lschedule_explicit_loop
 b .Lschedule_good
.Lschedule_times:
 mov x12,#1
 ldr x13,[sp,#184]
 ldr w14,[sp,#196]
 cmp w14,#1
 mov w9,#1
 csel w14,w14,w9,ge
.Lschedule_time_loop:
 fmov d6,xzr
 cbz x27,.Lschedule_minute_value
 mul x9,x12,x28
 ldr w10,[x27,x9]
 scvtf d6,w10
 fdiv d6,d6,d4
.Lschedule_minute_value:
 mul x9,x12,x25
 ldr w10,[x24,x9]
 neg w10,w10
 scvtf d7,w10
 fadd d7,d7,d6
 fmul d7,d7,d3
 fmul d7,d7,d5
 fdiv d7,d7,d0
 fminnm d7,d7,d2
 fcvtas w11,d7
 ldp w9,w10,[sp,#208]
 cmp w11,w9
 b.lt .Lschedule_time_next
 cmp w11,w10
 b.gt .Lschedule_time_next
 sdiv w10,w11,w14
 sxtw x10,w10
 bl .Lschedule_store
.Lschedule_time_next:
 add x12,x12,#1
 cmp x12,x13
 b.le .Lschedule_time_loop
.Lschedule_good:
 mov w0,#0
 b .Lschedule_return
.Lschedule_bad:
 mov w0,#2
.Lschedule_return:
 ldp x18,x30,[sp]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x29,[sp,#96]
 add sp,sp,#320
 ret
.Lschedule_store:
 cmp x10,x21
 b.lt .Lschedule_store_done
 cmp x10,x22
 b.gt .Lschedule_store_done
 sub x9,x10,x21
 mul x9,x9,x20
 ldr w11,[sp,#192]
 str w11,[x19,x9]
.Lschedule_store_done:
 ret
.size md2asm_runtime_periodic_output_schedule,.-md2asm_runtime_periodic_output_schedule
.section .rodata
.p2align 3
.Lschedule_constants:
 .quad 0x0010000000000000
 .double 2147483647.0
 .double 3600.0
 .double 60.0
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/support/forecast_timer_initialization.md.
 * int initialize(x0 output24, x1 capacity). Output FP64 seconds:
 * RSTART0, RVSTART8, RTIMEF16. Public FIAT owns the clock observations. */
.text
.p2align 2
.global md2asm_initialize_forecast_timers
.type md2asm_initialize_forecast_timers,%function
md2asm_initialize_forecast_timers:
 cbz x0,.Ltimer_reject
 tst x0,#7
 b.ne .Ltimer_reject
 cmp x1,#24
 b.lo .Ltimer_reject
 adds x2,x0,#24
 b.cs .Ltimer_reject
 stp x29,x30,[sp,#-32]!
 str x18,[sp,#16]
 mov x29,sp
 mov x3,x0
 add x2,x0,#8
 add x0,x0,#16
 mov x1,xzr
 bl user_clock_
 mov w0,#0
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Ltimer_reject:
 mov w0,#2
 ret
.size md2asm_initialize_forecast_timers,.-md2asm_initialize_forecast_timers
.section .note.GNU-stack,"",%progbits

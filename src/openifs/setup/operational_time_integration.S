/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Direct operational SURIP stores from the live450-second hour clock.
 * Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md.
 * Every source store and preservation range follows the accepted body. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_time_integration_configuration
.type md2asm_initialize_operational_time_integration_configuration,%function
md2asm_initialize_operational_time_integration_configuration:
 cbz x0,.Ltime_setup_bad
 cbz x1,.Ltime_setup_bad
 cbz x2,.Ltime_setup_bad
 cbz x3,.Ltime_setup_bad
 orr x6,x0,x1
 orr x6,x6,x2
 orr x6,x6,x3
 orr x6,x6,x5
 tst x6,#7
 b.ne .Ltime_setup_bad
 movz x6,#0xaf68
 movk x6,#2,lsl#16
 cmp x4,x6
 b.lo .Ltime_setup_bad
 adds x7,x3,x6
 b.cs .Ltime_setup_bad
 adds x8,x0,#40
 b.cs .Ltime_setup_bad
 adds x9,x1,#360
 b.cs .Ltime_setup_bad
 adds x10,x2,#16
 b.cs .Ltime_setup_bad
 cbz x5,.Ltime_setup_no_optional_extent
 adds x11,x5,#8
 b.cs .Ltime_setup_bad
 cmp x3,x11
 b.hs .Ltime_setup_no_optional_extent
 cmp x5,x7
 b.lo .Ltime_setup_bad
.Ltime_setup_no_optional_extent:
 cmp x3,x8
 b.hs .Ltime_setup_clock_input_clear
 cmp x0,x7
 b.lo .Ltime_setup_bad
.Ltime_setup_clock_input_clear:
 cmp x3,x9
 b.hs .Ltime_setup_clock_state_clear
 cmp x1,x7
 b.lo .Ltime_setup_bad
.Ltime_setup_clock_state_clear:
 cmp x3,x10
 b.hs .Ltime_setup_ranges_clear
 cmp x2,x7
 b.lo .Ltime_setup_bad
.Ltime_setup_ranges_clear:
 ldp x6,x7,[x2]
 mov x8,#1
 orr x8,x8,x8,lsl#32
 cmp x6,x8
 b.ne .Ltime_setup_bad
 cbnz x7,.Ltime_setup_bad
 mrs x6,fpcr
 cbnz x6,.Ltime_setup_bad
 ldr x16,[x0,#8]
 movz x6,#0x2000,lsl#32
 movk x6,#0x407c,lsl#48
 cmp x16,x6
 b.ne .Ltime_setup_bad
 ldr w6,[x0,#24]
 cbnz w6,.Ltime_setup_bad
 ldr x6,[x0,#32]
 cmp x6,x16
 b.eq .Ltime_setup_input_trajectory
 movz x7,#0xbff0,lsl#48
 cmp x6,x7
 b.ne .Ltime_setup_bad
.Ltime_setup_input_trajectory:
 ldr x6,[x1,#40]
 cmp x6,x16
 b.ne .Ltime_setup_bad
 ldr x15,[x1,#8]
 ubfx x6,x15,#52,#11
 cmp x6,#2047
 b.eq .Ltime_setup_bad
 cbz x5,.Ltime_setup_parse_stop
 ldr x6,[x5]
 cmp x6,x16
 b.ne .Ltime_setup_bad
.Ltime_setup_parse_stop:
 ldr x17,[x0,#16]
 ldrb w6,[x0,#16]
 cmp w6,#104
 b.ne .Ltime_setup_bad
 mov w14,#0
 mov w12,#0
 mov w13,#0
 mov x8,#17
 mov w9,#10
.Ltime_setup_stop_digit:
 ldrb w6,[x0,x8]
 cmp w6,#32
 b.eq .Ltime_setup_stop_space
 cbnz w13,.Ltime_setup_bad
 sub w6,w6,#48
 cmp w6,#9
 b.hi .Ltime_setup_bad
 add w12,w12,#1
 cmp w12,#2
 b.hi .Ltime_setup_bad
 madd w14,w14,w9,w6
 b .Ltime_setup_stop_next
.Ltime_setup_stop_space:
 mov w13,#1
.Ltime_setup_stop_next:
 add x8,x8,#1
 cmp x8,#24
 b.lo .Ltime_setup_stop_digit
 cbz w12,.Ltime_setup_bad
 sub w6,w14,#1
 cmp w6,#71
 b.hi .Ltime_setup_bad
 lsl w14,w14,#3
 ldr w6,[x1,#24]
 cmp w6,w14
 b.ne .Ltime_setup_bad
 /* Complete selected source assignments; all other bytes survive. */
 str wzr,[x3]
 str w14,[x3,#4]
 str x17,[x3,#8]
 str xzr,[x3,#16]
 str wzr,[x3,#24]
 str xzr,[x3,#32]
 str x15,[x3,#40]
 add x6,x3,#48
 mov w7,#11
.Ltime_setup_initial_solar:
 str xzr,[x6],#8
 subs w7,w7,#1
 b.ne .Ltime_setup_initial_solar
 stp xzr,xzr,[x3,#168]
 stp xzr,xzr,[x3,#184]
 stp x16,x16,[x3,#200]
 add x6,x3,#216
 mov w7,#12
.Ltime_setup_remaining:
 str xzr,[x6],#8
 subs w7,w7,#1
 b.ne .Ltime_setup_remaining
 mov w0,#0
 ret
.Ltime_setup_bad:
 mov w0,#2
 ret
.size md2asm_initialize_operational_time_integration_configuration,.-md2asm_initialize_operational_time_integration_configuration
.section .note.GNU-stack,"",%progbits

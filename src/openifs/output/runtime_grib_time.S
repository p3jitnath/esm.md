/* Contract: skills/md2asm/references/openifs/output/runtime_grib_time.md.
 * GRIB_SET_TIME retains original seconds and public setter order. */
.arch armv8.2-a
.text
.p2align 4
.macro GTCALL target
 bl \target
 ldr x18,[sp,#96]
.endm
.macro GTLONG key,value
 mov x0,x19
 adr x1,\key
 sxtw x2,\value
 GTCALL codes_set_long
 cbnz w0,.Lgt_return
.endm
.macro GTUNIT value
 mov x0,x19
 adr x1,.Lgt_key_units
 adr x2,\value
 mov x9,#1
 str x9,[sp,#160]
 add x3,sp,#160
 GTCALL codes_set_string
 cbnz w0,.Lgt_return
.endm
.global md2asm_set_runtime_grib_time
.type md2asm_set_runtime_grib_time,%function
md2asm_set_runtime_grib_time:
 sub sp,sp,#384
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 str w3,[sp,#112]
 cmp w3,#1
 b.hi .Lgt_bad
 cbz x19,.Lgt_bad
 cbz x20,.Lgt_bad
 cbz x21,.Lgt_bad
 orr x9,x19,x20
 tst x9,#7
 b.ne .Lgt_bad
 tst x21,#3
 b.ne .Lgt_bad
 adds x9,x21,#4
 b.cs .Lgt_bad
 mrs x9,fpcr
 cbnz x9,.Lgt_bad
 mov x0,x20
 mov x1,#128
 mov x2,x21
 bl .Lgt_disjoint
 cbnz w0,.Lgt_bad
 ldp x9,x10,[x20,#96]
 orr x9,x9,x10
 ldp x10,x11,[x20,#112]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Lgt_bad
 ldr x26,[x20,#8]
 lsr x9,x26,#31
 cbnz x9,.Lgt_bad
 ldr x25,[x20,#40]
 lsr x9,x25,#31
 cbnz x9,.Lgt_bad
 ldr x9,[x20,#64]
 tbnz x9,#63,.Lgt_bad
 cbz x9,.Lgt_bad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lgt_bad
 ldr x22,[x20,#80]
 cbz x22,.Lgt_bad
 tst x22,#7
 b.ne .Lgt_bad
 mov x0,x22
 mov x1,#128
 mov x2,x21
 bl .Lgt_disjoint
 cbnz w0,.Lgt_bad
 ldr x23,[x22,#72]
 cbz x23,.Lgt_bad
 tst x23,#7
 b.ne .Lgt_bad
 mov x0,x23
 mov x1,#112
 mov x2,x21
 bl .Lgt_disjoint
 cbnz w0,.Lgt_bad
 ldr w9,[x23]
 cmp w9,#1
 b.ne .Lgt_bad
 ldr w9,[x23,#80]
 cmp w9,#1
 b.ne .Lgt_bad
 ldrh w9,[x23,#90]
 mov w10,#0x6366
 cmp w9,w10
 b.ne .Lgt_bad
 ldr x9,[x22,#80]
 cbz x9,.Lgt_bad
 tst x9,#3
 b.ne .Lgt_bad
 ldr w9,[x9]
 cbnz w9,.Lgt_bad
 ldr x0,[x22,#64]
 cbz x0,.Lgt_bad
 tst x0,#7
 b.ne .Lgt_bad
 mov x1,#552
 mov x2,x21
 bl .Lgt_disjoint
 cbnz w0,.Lgt_bad
 ldr x9,[x22,#64]
 ldrb w10,[x9,#44]
 cmp w10,#48
 b.ne .Lgt_bad
 ldr w11,[x9,#60]
 cbnz w11,.Lgt_bad
 ldr x24,[x20,#72]
 cbz x24,.Lgt_bad
 tst x24,#3
 b.ne .Lgt_bad
 mov x0,x24
 mov x1,#40
 mov x2,x21
 bl .Lgt_disjoint
 cbnz w0,.Lgt_bad
 /* ISRCHEQ retains the first matching source table entry. */
 mov w9,#0
 mov w10,#-1
.Lgt_previous:
 ldr w11,[x24,x9,lsl#2]
 cmp w11,w26
 b.eq .Lgt_previous_match
 add w9,w9,#1
 cmp w9,#5
 b.lo .Lgt_previous
 b .Lgt_previous_ready
.Lgt_previous_match:
 add x10,x24,#20
 ldr w10,[x10,x9,lsl#2]
.Lgt_previous_ready:
 str w10,[sp,#116]
 /* Original integer to FP64, multiplication and integer truncation. */
 scvtf d0,w25
 ldr w9,[sp,#112]
 cbz w9,.Lgt_model_seconds
 adr x9,.Lgt_hour_seconds
 ldr d1,[x9]
 b .Lgt_seconds_multiply
.Lgt_model_seconds:
 ldr d1,[x20,#64]
.Lgt_seconds_multiply:
 fmul d0,d0,d1
 adr x9,.Lgt_integer_limit
 ldr d2,[x9]
 fcmp d0,d2
 b.ge .Lgt_bad
 fcvtzs w27,d0
 mov w28,#1
 mov w9,#1
 str w9,[sp,#136]
 ldr w10,[sp,#116]
 cmp w10,#0
 b.lt .Lgt_parameter_case
 /* Integer admission leaves the previous-step FP work at its source seam. */
 cbz w10,.Lgt_apply
 ldr x9,[x20,#64]
 ubfx x11,x9,#52,#11
 cmp x11,#1022
 b.ls .Lgt_apply
 cmp x11,#1054
 b.hs .Lgt_bad
 ubfx x12,x9,#0,#52
 orr x12,x12,#0x10000000000000
 mul x13,x12,x10
 umulh x14,x12,x10
 cmp x11,#1053
 b.eq .Lgt_previous_high_exponent
 mov x15,#1052
 sub x15,x15,x11
 mov x16,#0x3fffffffffffff
 lsl x17,x16,x15
 neg x9,x15
 add x9,x9,#64
 lsr x16,x16,x9
 cmp x15,#0
 csel x16,x16,xzr,ne
 cmp x14,x16
 b.hi .Lgt_bad
 b.lo .Lgt_apply
 cmp x13,x17
 b.hs .Lgt_bad
 b .Lgt_apply
.Lgt_previous_high_exponent:
 cbnz x14,.Lgt_bad
 lsr x13,x13,#53
 cbnz x13,.Lgt_bad
 b .Lgt_apply
.Lgt_parameter_case:
 mov w9,#-9999
 str w9,[sp,#120]
 mov w9,#5
 str w9,[sp,#124]
 adr x9,.Lgt_cases
 mov x10,#24
.Lgt_case_find:
 ldr w11,[x9]
 cmp w11,w26
 b.eq .Lgt_case_found
 add x9,x9,#16
 subs x10,x10,#1
 b.ne .Lgt_case_find
 mov w9,#0x6331
 movk w9,#3,lsl#16
 sub w9,w26,w9
 cmp w9,#255
 b.ls .Lgt_accumulation
 mov w9,#0x6719
 movk w9,#3,lsl#16
 sub w9,w26,w9
 cmp w9,#255
 b.ls .Lgt_accumulation
 b .Lgt_apply
.Lgt_case_found:
 ldp w10,w11,[x9,#4]
 ldr w12,[x9,#12]
 str w11,[sp,#124]
 mov w9,#3600
 udiv w11,w27,w9
 msub w11,w11,w9,w27
 cbnz w11,.Lgt_bad
 sub w9,w27,w10
 cbz w12,.Lgt_window_valid
 cmp w9,#0
 csel w9,w9,wzr,ge
 b .Lgt_window_ready
.Lgt_window_valid:
 cmp w9,#0
 cset w28,ge
.Lgt_window_ready:
 str w9,[sp,#120]
 b .Lgt_apply
.Lgt_accumulation:
 mov w9,#4
 str w9,[sp,#124]
 str wzr,[sp,#120]
 str wzr,[sp,#136]
.Lgt_apply:
 GTLONG .Lgt_key_indicator,wzr
 ldr w9,[sp,#116]
 /* Negative values still select the parameter-specific source route. */
 cmp w9,#0
 b.lt .Lgt_apply_parameter
 /* This arithmetic follows the first public setter in the original body. */
 scvtf d0,w9
 ldr d1,[x20,#64]
 fmul d0,d0,d1
 scvtf d1,wzr
 fadd d0,d0,d1
 fcvtzs w9,d0
 str w9,[sp,#116]
 mov w0,#0
 bl .Lgt_type
 cbnz w0,.Lgt_return
 GTUNIT .Lgt_seconds
 ldr w9,[sp,#116]
 GTLONG .Lgt_key_start,w9
 GTLONG .Lgt_key_end,w27
 b .Lgt_zero
.Lgt_apply_parameter:
 ldr w0,[sp,#124]
 bl .Lgt_type
 cbnz w0,.Lgt_return
 GTUNIT .Lgt_seconds
 cbz w28,.Lgt_parameter_end
 ldr w9,[sp,#120]
 cmp w9,#0
 b.lt .Lgt_parameter_end
 GTLONG .Lgt_key_start,w9
.Lgt_parameter_end:
 GTLONG .Lgt_key_end,w27
.Lgt_zero:
 cbnz w27,.Lgt_hours
 cbz w28,.Lgt_hours
 ldr w9,[sp,#136]
 cbz w9,.Lgt_hours
 mov w0,#5
 bl .Lgt_type
 cbnz w0,.Lgt_return
 mov w9,#1
 GTLONG .Lgt_key_indicator,w9
.Lgt_hours:
 cbz w27,.Lgt_success
 mov w9,#3600
 udiv w10,w27,w9
 msub w10,w10,w9,w27
 cbnz w10,.Lgt_success
 GTUNIT .Lgt_hours_value
.Lgt_success:
 str w28,[x21]
 mov w0,#0
 b .Lgt_return
.Lgt_bad:
 mov w0,#2
.Lgt_return:
 ldr x18,[sp,#96]
 ldp x29,x30,[sp,#80]
 ldp x27,x28,[sp,#64]
 ldp x25,x26,[sp,#48]
 ldp x23,x24,[sp,#32]
 ldp x21,x22,[sp,#16]
 ldp x19,x20,[sp]
 add sp,sp,#384
 ret
.size md2asm_set_runtime_grib_time,.-md2asm_set_runtime_grib_time
/* Private metadata interval admission writes no caller storage. */
.Lgt_disjoint:
 adds x9,x0,x1
 b.cs .Lgt_overlap
 cmp x21,x9
 b.hs .Lgt_disjoint_ready
 add x10,x21,#4
 cmp x0,x10
 b.lo .Lgt_overlap
.Lgt_disjoint_ready:
 mov w0,#0
 ret
.Lgt_overlap:
 mov w0,#2
 ret
/* The only private service helper shares the declared384B parent frame. */
.Lgt_type:
 str x30,[sp,#176]
 adr x9,.Lgt_type_offsets
 ldr w10,[x9,x0,lsl#2]
 add x2,x9,x10
 adr x9,.Lgt_type_lengths
 ldrb w10,[x9,x0]
 str x10,[sp,#160]
 add x3,sp,#160
 adr x1,.Lgt_key_type
 mov x0,x19
 GTCALL codes_set_string
 ldr x30,[sp,#176]
 ret
.section .rodata
.p2align 3
.Lgt_hour_seconds:.double 3600.0
.Lgt_integer_limit:.double 2147483648.0
.Lgt_key_indicator:.asciz "timeRangeIndicator"
.Lgt_key_type:.asciz "stepType"
.Lgt_key_units:.asciz "stepUnits"
.Lgt_key_start:.asciz "startStep"
.Lgt_key_end:.asciz "endStep"
.Lgt_seconds:.asciz "s"
.Lgt_hours_value:.asciz "h"
.p2align 2
.Lgt_type_offsets:.word .Lgt_max-.Lgt_type_offsets,.Lgt_avg-.Lgt_type_offsets,.Lgt_mode-.Lgt_type_offsets,.Lgt_severity-.Lgt_type_offsets,.Lgt_accum-.Lgt_type_offsets,.Lgt_instant-.Lgt_type_offsets
.Lgt_type_lengths:.byte 3,3,4,8,5,7
.Lgt_max:.asciz "max"
.Lgt_avg:.asciz "avg"
.Lgt_mode:.asciz "mode"
.Lgt_severity:.asciz "severity"
.Lgt_accum:.asciz "accum"
.Lgt_instant:.asciz "instant"
.p2align 2
.Lgt_cases:
 .word 228026,10800,0,1
 .word 228027,10800,0,1
 .word 228028,10800,0,1
 .word 228222,10800,0,1
 .word 228223,10800,0,1
 .word 121,21600,0,1
 .word 122,21600,0,1
 .word 123,21600,0,1
 .word 228224,21600,0,1
 .word 228225,21600,0,1
 .word 228051,3600,1,0
 .word 228053,3600,1,0
 .word 228057,10800,1,0
 .word 228059,10800,1,0
 .word 228058,21600,1,0
 .word 228060,21600,1,0
 .word 228035,21600,0,0
 .word 228036,21600,0,0
 .word 260320,3600,2,0
 .word 260321,10800,2,0
 .word 260339,21600,2,0
 .word 260318,3600,3,0
 .word 260319,10800,3,0
 .word 260338,21600,3,0
.section .note.GNU-stack,"",%progbits

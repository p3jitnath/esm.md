/* Contract skills/md2asm/references/openifs/input/runtime_configured_model_initialization.md.
 * Private 32-byte first-NAMPAR1 scanner for the caller-owned policy producer.
 * The bounded input, literal values and atomic output follow the frozen contract. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_read_operational_interpolation_policy_private
.type md2asm_read_operational_interpolation_policy_private,%function
md2asm_read_operational_interpolation_policy_private:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#32
 mov x19,x0
 mov x21,x2
 mov x22,sp
 cbz x0,.Linterp_policy_bad
 cbz x2,.Linterp_policy_bad
 cbz x1,.Linterp_policy_bad
 cmp x1,#64,lsl#12
 b.hi .Linterp_policy_bad
 tst x2,#7
 b.ne .Linterp_policy_bad
 adds x20,x0,x1
 b.cs .Linterp_policy_bad
 adds x9,x2,#32
 b.cs .Linterp_policy_bad
 cmp x9,x0
 b.ls .Linterp_policy_disjoint
 cmp x2,x20
 b.lo .Linterp_policy_bad
.Linterp_policy_disjoint:
 mrs x9,fpcr
 cbnz x9,.Linterp_policy_bad
 mov x9,#0
.Linterp_policy_copy_in:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,x22,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#32
 b.lo .Linterp_policy_copy_in
 /* The source group marker is the first nonblank token on its line. */
.Linterp_policy_start_line:
 mov w28,#0
.Linterp_policy_find_line:
 cmp x19,x20
 b.hs .Linterp_policy_bad
 ldrb w9,[x19],#1
 add w28,w28,#1
 cmp w9,#10
 b.eq .Linterp_policy_start_line
 cmp w9,#32
 b.eq .Linterp_policy_find_line
 cmp w9,#9
 b.eq .Linterp_policy_find_line
 cmp w9,#13
 b.eq .Linterp_policy_find_line
 cmp w9,#10
 b.eq .Linterp_policy_find_line
 cmp w9,#38
 b.ne .Linterp_policy_skip_line
 cmp w28,#10
 b.hi .Linterp_policy_skip_line
 add x9,x19,#7
 cmp x9,x20
 b.hs .Linterp_policy_bad
 adr x10,.Linterp_policy_group
 mov w11,#0
.Linterp_policy_group_match:
 ldrb w12,[x19,x11]
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Linterp_policy_skip_line
 add w11,w11,#1
 cmp w11,#7
 b.lo .Linterp_policy_group_match
 add x19,x19,#7
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Linterp_policy_key
 cmp w9,#9
 b.eq .Linterp_policy_key
 cmp w9,#13
 b.eq .Linterp_policy_key
 cmp w9,#10
 b.eq .Linterp_policy_key
 cmp w9,#47
 b.eq .Linterp_policy_key
 cmp w9,#44
 b.eq .Linterp_policy_key
.Linterp_policy_skip_line:
 cmp x19,x20
 b.hs .Linterp_policy_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Linterp_policy_skip_line
 b .Linterp_policy_start_line
.Linterp_policy_key:
 mov x0,x19
 mov x1,x20
 bl .Linterp_policy_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Linterp_policy_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Linterp_policy_key_start
 add x19,x19,#1
 b .Linterp_policy_key
.Linterp_policy_key_start:
 cmp w9,#47
 b.eq .Linterp_policy_finish
 mov x27,x19
.Linterp_policy_key_scan:
 cmp x19,x20
 b.hs .Linterp_policy_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Linterp_policy_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Linterp_policy_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Linterp_policy_key_next
 cmp w9,#95
 b.eq .Linterp_policy_key_next
 cmp w9,#37
 b.ne .Linterp_policy_key_lookup_call
.Linterp_policy_key_next:
 add x19,x19,#1
 b .Linterp_policy_key_scan
.Linterp_policy_key_lookup_call:
 mov x0,x27
 sub x1,x19,x27
 bl .Linterp_policy_lookup
 tbnz w0,#31,.Linterp_policy_bad
 mov w25,w0
 mov w26,w1
 mov x0,x19
 mov x1,x20
 bl .Linterp_policy_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Linterp_policy_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Linterp_policy_bad
 mov x0,x19
 mov x1,x20
 bl .Linterp_policy_skip_blank
 mov x19,x0
 mov x27,x0
.Linterp_policy_value_scan:
 cmp x19,x20
 b.hs .Linterp_policy_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Linterp_policy_value_found
 cmp w9,#9
 b.eq .Linterp_policy_value_found
 cmp w9,#13
 b.eq .Linterp_policy_value_found
 cmp w9,#10
 b.eq .Linterp_policy_value_found
 cmp w9,#44
 b.eq .Linterp_policy_value_found
 cmp w9,#33
 b.eq .Linterp_policy_value_found
 cmp w9,#47
 b.eq .Linterp_policy_value_found
 add x19,x19,#1
 b .Linterp_policy_value_scan
.Linterp_policy_value_found:
 mov x0,x27
 sub x1,x19,x27
 cbnz w26,.Linterp_policy_integer_call
 bl .Linterp_policy_boolean
 b .Linterp_policy_value_result
.Linterp_policy_integer_call:
 bl .Linterp_policy_integer
.Linterp_policy_value_result:
 cbnz w1,.Linterp_policy_bad
 str w0,[x22,x25]
 b .Linterp_policy_key
.Linterp_policy_finish:
 mov x9,#0
.Linterp_policy_copy_out:
 add x12,x22,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#32
 b.lo .Linterp_policy_copy_out
 mov w0,#0
 b .Linterp_policy_return
.Linterp_policy_bad:
 mov w0,#2
.Linterp_policy_return:
 add sp,sp,#32
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_read_operational_interpolation_policy_private,.-md2asm_read_operational_interpolation_policy_private
/* Local helpers use only caller-saved x0..x17. */
.Linterp_policy_skip_blank:
 cmp x0,x1
 b.hs .Linterp_policy_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Linterp_policy_skip_next
 cmp w9,#9
 b.eq .Linterp_policy_skip_next
 cmp w9,#13
 b.eq .Linterp_policy_skip_next
 cmp w9,#10
 b.eq .Linterp_policy_skip_next
 cmp w9,#33
 b.ne .Linterp_policy_skip_return
.Linterp_policy_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Linterp_policy_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Linterp_policy_skip_comment
.Linterp_policy_skip_next:
 add x0,x0,#1
 b .Linterp_policy_skip_blank
.Linterp_policy_skip_return:
 ret
.Linterp_policy_lookup:
 adr x9,.Linterp_policy_keys
 mov w10,#11
.Linterp_policy_lookup_row:
 ldr w11,[x9,#16]
 cmp x1,x11
 b.ne .Linterp_policy_lookup_next
 mov x12,#0
.Linterp_policy_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Linterp_policy_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Linterp_policy_lookup_char
 ldp w0,w1,[x9,#20]
 ret
.Linterp_policy_lookup_next:
 add x9,x9,#32
 subs w10,w10,#1
 b.ne .Linterp_policy_lookup_row
 mov w0,#-1
 ret
.Linterp_policy_boolean:
 cbz x1,.Linterp_policy_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Linterp_policy_bool_core
 cmp x1,#3
 b.lo .Linterp_policy_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Linterp_policy_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Linterp_policy_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Linterp_policy_true
 cmp w9,#102
 b.ne .Linterp_policy_token_bad
 mov w15,#0
 adr x10,.Linterp_policy_false_text
 mov w11,#5
 b .Linterp_policy_bool_match
.Linterp_policy_true:
 mov w15,#1
 adr x10,.Linterp_policy_true_text
 mov w11,#4
.Linterp_policy_bool_match:
 cmp x1,#1
 b.eq .Linterp_policy_bool_good
 cmp x1,x11
 b.ne .Linterp_policy_token_bad
 mov x12,#0
.Linterp_policy_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Linterp_policy_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Linterp_policy_bool_char
.Linterp_policy_bool_good:
 mov w0,w15
 mov w1,#0
 ret
.Linterp_policy_integer:
 cmp x1,#1
 b.eq .Linterp_policy_integer_positive
 cmp x1,#2
 b.ne .Linterp_policy_token_bad
 ldrb w9,[x0],#1
 cmp w9,#43
 b.eq .Linterp_policy_integer_positive
 b .Linterp_policy_token_bad
.Linterp_policy_integer_positive:
 mov w10,#1
.Linterp_policy_integer_digit:
 ldrb w9,[x0]
 sub w9,w9,#48
 cmp w9,#4
 b.hi .Linterp_policy_token_bad
 mul w0,w9,w10
 mov w1,#0
 ret
.Linterp_policy_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Linterp_policy_group: .ascii "NAMPAR1"
.Linterp_policy_true_text: .ascii "true"
.Linterp_policy_false_text: .ascii "false"
.p2align 4
.Linterp_policy_keys:
 .ascii "lsplit"
 .zero 10
 .word 6,16,0,0
 .ascii "nfldin"
 .zero 10
 .word 6,20,1,0
 .ascii "nstrin"
 .zero 10
 .word 6,20,1,0
 .ascii "nstrout"
 .zero 9
 .word 7,20,1,0
 .ascii "nouttype"
 .zero 8
 .word 8,20,1,0
 .ascii "lslondem"
 .zero 8
 .word 8,8,0,0
 .ascii "nwrtout"
 .zero 9
 .word 7,20,1,0
 .ascii "lsync_slcom"
 .zero 5
 .word 11,0,0,0
 .ascii "lsldebug"
 .zero 8
 .word 8,4,0,0
 .ascii "lsync_trans"
 .zero 5
 .word 11,12,0,0
 .ascii "lsplitout"
 .zero 7
 .word 9,16,0,0
 .section .note.GNU-stack,"",%progbits

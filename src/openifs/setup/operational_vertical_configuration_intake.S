/* Read the selected first NAMCVER group into six explicit int32 controls.
 * Contract: skills/md2asm/references/openifs/setup/operational_vertical_configuration_intake.md.
 * x0 text, x1 bytes, x2 geometry controls[4], x3 output controls[6].
 * The complete output is unchanged on refusal. Return 0 or 2.
 * The 160-byte frame saves registers and holds nine private scalar words.
 * Only integer instructions and local helpers are used; no service is called.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_parse_operational_vertical_configuration
.type md2asm_parse_operational_vertical_configuration,%function
md2asm_parse_operational_vertical_configuration:
 stp x29,x30,[sp,#-160]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x23,x2
 mov x21,x3
 add x22,sp,#96
 cbz x0,.Lcver_bad
 cbz x1,.Lcver_bad
 cbz x2,.Lcver_bad
 cbz x3,.Lcver_bad
 cmp x1,#64,lsl#12
 b.hi .Lcver_bad
 orr x9,x2,x3
 tst x9,#7
 b.ne .Lcver_bad
 adds x20,x0,x1
 b.cs .Lcver_bad
 adds x10,x2,#16
 b.cs .Lcver_bad
 adds x11,x3,#24
 b.cs .Lcver_bad
 cmp x10,x0
 b.ls .Lcver_base_disjoint
 cmp x2,x20
 b.lo .Lcver_bad
.Lcver_base_disjoint:
 cmp x11,x0
 b.ls .Lcver_output_text_disjoint
 cmp x3,x20
 b.lo .Lcver_bad
.Lcver_output_text_disjoint:
 cmp x11,x2
 b.ls .Lcver_output_base_disjoint
 cmp x3,x10
 b.lo .Lcver_bad
.Lcver_output_base_disjoint:
 ldp w9,w10,[x23]
 cmp w9,#137
 b.ne .Lcver_bad
 cmp w10,#1
 b.ne .Lcver_bad
 ldp w9,w10,[x23,#8]
 orr w9,w9,w10
 cbnz w9,.Lcver_bad
 stp xzr,xzr,[x22]
 stp xzr,xzr,[x22,#16]
 str wzr,[x22,#32]
 mov w9,#1
 str w9,[x22]
 /* Detect every earlier uppercase prefix, including unsupported positions. */
.Lcver_new_line:
 mov x28,x19
 mov x24,#0
.Lcver_line_scan:
 cmp x19,x20
 b.hs .Lcver_bad
 ldrb w9,[x19]
 cmp w9,#10
 b.eq .Lcver_next_line
 cbnz x24,.Lcver_first_token_known
 cmp w9,#32
 b.eq .Lcver_line_next
 cmp w9,#9
 b.eq .Lcver_line_next
 cmp w9,#13
 b.eq .Lcver_line_next
 mov x24,x19
.Lcver_first_token_known:
 cmp w9,#38
 b.ne .Lcver_line_next
 sub x9,x20,x19
 cmp x9,#8
 b.lo .Lcver_line_next
 adr x10,.Lcver_group
 mov x11,#0
.Lcver_prefix_match:
 ldrb w12,[x19,x11]
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Lcver_line_next
 add x11,x11,#1
 cmp x11,#8
 b.lo .Lcver_prefix_match
 cmp x19,x24
 b.ne .Lcver_bad
 sub x9,x19,x28
 cmp x9,#9
 b.hi .Lcver_bad
 add x19,x19,#8
 cmp x19,x20
 b.hs .Lcver_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lcver_key
 cmp w9,#9
 b.eq .Lcver_key
 cmp w9,#13
 b.eq .Lcver_key
 cmp w9,#10
 b.eq .Lcver_key
 cmp w9,#44
 b.eq .Lcver_key
 cmp w9,#47
 b.eq .Lcver_key
 cmp w9,#33
 b.eq .Lcver_key
 b .Lcver_bad
.Lcver_line_next:
 add x19,x19,#1
 b .Lcver_line_scan
.Lcver_next_line:
 add x19,x19,#1
 b .Lcver_new_line
.Lcver_key:
 mov x0,x19
 mov x1,x20
 bl .Lcver_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lcver_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lcver_key_start
 add x19,x19,#1
 b .Lcver_key
.Lcver_key_start:
 cmp w9,#47
 b.eq .Lcver_finish
 mov x27,x19
.Lcver_key_scan:
 cmp x19,x20
 b.hs .Lcver_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lcver_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lcver_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lcver_key_next
 cmp w9,#95
 b.ne .Lcver_key_lookup
.Lcver_key_next:
 add x19,x19,#1
 b .Lcver_key_scan
.Lcver_key_lookup:
 mov x0,x27
 sub x1,x19,x27
 bl .Lcver_lookup
 tbnz w0,#31,.Lcver_bad
 mov w25,w0
 mov w26,w1
 mov x0,x19
 mov x1,x20
 bl .Lcver_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lcver_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Lcver_bad
 mov x0,x19
 mov x1,x20
 bl .Lcver_skip_blank
 mov x19,x0
 mov x27,x0
.Lcver_value_scan:
 cmp x19,x20
 b.hs .Lcver_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lcver_value_found
 cmp w9,#9
 b.eq .Lcver_value_found
 cmp w9,#13
 b.eq .Lcver_value_found
 cmp w9,#10
 b.eq .Lcver_value_found
 cmp w9,#44
 b.eq .Lcver_value_found
 cmp w9,#33
 b.eq .Lcver_value_found
 cmp w9,#47
 b.eq .Lcver_value_found
 add x19,x19,#1
 b .Lcver_value_scan
.Lcver_value_found:
 mov x0,x27
 sub x1,x19,x27
 cbnz w26,.Lcver_integer_call
 bl .Lcver_boolean
 b .Lcver_value_result
.Lcver_integer_call:
 bl .Lcver_integer
.Lcver_value_result:
 cbnz w1,.Lcver_bad
 str w0,[x22,x25]
 b .Lcver_key
.Lcver_finish:
 /* Hydrostatic resets discard Z/LAPL/LAPL_BC and reset NDLNPR to zero.
  * The selected context can represent only these final remaining controls. */
 ldr w9,[x22]
 cmp w9,#1
 b.ne .Lcver_bad
 ldr w9,[x22,#4]
 cmp w9,#3
 b.ne .Lcver_bad
 ldr w9,[x22,#8]
 cmp w9,#1
 b.ne .Lcver_bad
 ldr w9,[x22,#12]
 ldr w10,[x22,#20]
 orr w9,w9,w10
 cbnz w9,.Lcver_bad
 ldp x9,x10,[x23]
 stp x9,x10,[x21]
 ldp w9,w10,[x22,#4]
 stp w9,w10,[x21,#16]
 mov w0,#0
 b .Lcver_return
.Lcver_bad:
 mov w0,#2
.Lcver_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#160
 ret
.size md2asm_parse_operational_vertical_configuration,.-md2asm_parse_operational_vertical_configuration

/* Literal accepted blank, key and logical token helpers. */
.Lcver_skip_blank:
 cmp x0,x1
 b.hs .Lcver_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lcver_skip_next
 cmp w9,#9
 b.eq .Lcver_skip_next
 cmp w9,#13
 b.eq .Lcver_skip_next
 cmp w9,#10
 b.eq .Lcver_skip_next
 cmp w9,#33
 b.ne .Lcver_skip_return
.Lcver_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lcver_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lcver_skip_comment
.Lcver_skip_next:
 add x0,x0,#1
 b .Lcver_skip_blank
.Lcver_skip_return:
 ret
.Lcver_lookup:
 adr x9,.Lcver_keys
 mov w10,#9
.Lcver_lookup_row:
 ldr w11,[x9,#16]
 cmp x1,x11
 b.ne .Lcver_lookup_next
 mov x12,#0
.Lcver_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Lcver_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lcver_lookup_char
 ldp w0,w1,[x9,#20]
 ret
.Lcver_lookup_next:
 add x9,x9,#32
 subs w10,w10,#1
 b.ne .Lcver_lookup_row
 mov w0,#-1
 ret
.Lcver_boolean:
 cbz x1,.Lcver_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Lcver_bool_core
 cmp x1,#3
 b.lo .Lcver_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Lcver_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Lcver_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Lcver_true
 cmp w9,#102
 b.ne .Lcver_token_bad
 mov w15,#0
 adr x10,.Lcver_false_text
 mov w11,#5
 b .Lcver_bool_match
.Lcver_true:
 mov w15,#1
 adr x10,.Lcver_true_text
 mov w11,#4
.Lcver_bool_match:
 cmp x1,#1
 b.eq .Lcver_bool_good
 cmp x1,x11
 b.ne .Lcver_token_bad
 mov x12,#0
.Lcver_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Lcver_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lcver_bool_char
.Lcver_bool_good:
 mov w0,w15
 mov w1,#0
 ret
/* Parse one complete signed int32 token with checked decimal accumulation. */
.Lcver_integer:
 cbz x1,.Lcver_token_bad
 mov w10,#0
 ldrb w9,[x0]
 cmp w9,#43
 b.eq .Lcver_integer_sign
 cmp w9,#45
 b.ne .Lcver_integer_start
 mov w10,#1
.Lcver_integer_sign:
 add x0,x0,#1
 sub x1,x1,#1
 cbz x1,.Lcver_token_bad
.Lcver_integer_start:
 mov x12,#0
 mov x13,#0
 movz w14,#0xcccc
 movk w14,#0x0ccc,lsl#16
 mov w15,#7
 add w15,w15,w10
 mov x11,#10
.Lcver_integer_digit:
 ldrb w9,[x0,x13]
 sub w9,w9,#48
 cmp w9,#9
 b.hi .Lcver_token_bad
 cmp x12,x14
 b.hi .Lcver_token_bad
 b.ne .Lcver_integer_accumulate
 cmp w9,w15
 b.hi .Lcver_token_bad
.Lcver_integer_accumulate:
 madd x12,x12,x11,x9
 add x13,x13,#1
 cmp x13,x1
 b.lo .Lcver_integer_digit
 neg w11,w12
 cmp w10,#0
 csel w0,w11,w12,ne
 mov w1,#0
 ret
.Lcver_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Lcver_group: .ascii "&NAMCVER"
.Lcver_true_text: .ascii "true"
.Lcver_false_text: .ascii "false"
.p2align 4
.Lcver_keys:
 .ascii "lvertfe"
 .zero 9
 .word 7,0,0,0
 .ascii "nvsch"
 .zero 11
 .word 5,4,1,0
 .ascii "lvfe_gwmpa"
 .zero 6
 .word 10,8,0,0
 .ascii "lvfe_gw"
 .zero 9
 .word 7,12,0,0
 .ascii "lvfe_z_term"
 .zero 5
 .word 11,16,0,0
 .ascii "lvfe_x_term"
 .zero 5
 .word 11,20,0,0
 .ascii "lvfe_lapl_bc"
 .zero 4
 .word 12,24,0,0
 .ascii "lvfe_lapl"
 .zero 7
 .word 9,28,0,0
 .ascii "ndlnpr"
 .zero 10
 .word 6,32,1,0
.section .note.GNU-stack,"",%progbits

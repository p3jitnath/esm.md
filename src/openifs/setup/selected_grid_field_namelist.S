/* Parse the six selected NAMGFL assignments into nine owned source profiles.
 * x0 text[1..262144],x1 bytes,x2 profiles[2304],8-byte aligned and disjoint.
 * Return 0/2; output is unchanged on failure. Contract is in the repository.
 * The 2400-byte aligned frame owns a temporary copy; no external/FP calls.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_apply_selected_grid_field_namelist
.type md2asm_apply_selected_grid_field_namelist,%function
md2asm_apply_selected_grid_field_namelist:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#2304
 mov x19,x0
 mov x21,x2
 mov x22,sp
 cbz x0,.Lnamgfl_bad
 cbz x2,.Lnamgfl_bad
 cbz x1,.Lnamgfl_bad
 cmp x1,#64,lsl#12
 b.hi .Lnamgfl_bad
 tst x2,#7
 b.ne .Lnamgfl_bad
 adds x20,x0,x1
 b.cs .Lnamgfl_bad
 adds x9,x2,#2304
 b.cs .Lnamgfl_bad
 cmp x9,x0
 b.ls .Lnamgfl_disjoint
 cmp x2,x20
 b.lo .Lnamgfl_bad
.Lnamgfl_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lnamgfl_bad
 mov x9,#0
.Lnamgfl_copy_in:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,x22,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#2304
 b.lo .Lnamgfl_copy_in
 /* The source group marker is the first nonblank token on its line. */
.Lnamgfl_find_line:
 cmp x19,x20
 b.hs .Lnamgfl_bad
 ldrb w9,[x19],#1
 cmp w9,#32
 b.eq .Lnamgfl_find_line
 cmp w9,#9
 b.eq .Lnamgfl_find_line
 cmp w9,#13
 b.eq .Lnamgfl_find_line
 cmp w9,#10
 b.eq .Lnamgfl_find_line
 cmp w9,#38
 b.ne .Lnamgfl_skip_line
 add x9,x19,#6
 cmp x9,x20
 b.hs .Lnamgfl_bad
 adr x10,.Lnamgfl_group
 mov w11,#0
.Lnamgfl_group_match:
 ldrb w12,[x19,x11]
 orr w12,w12,#32
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Lnamgfl_skip_line
 add w11,w11,#1
 cmp w11,#6
 b.lo .Lnamgfl_group_match
 add x19,x19,#6
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lnamgfl_key
 cmp w9,#9
 b.eq .Lnamgfl_key
 cmp w9,#13
 b.eq .Lnamgfl_key
 cmp w9,#10
 b.eq .Lnamgfl_key
 cmp w9,#47
 b.eq .Lnamgfl_key
 cmp w9,#44
 b.eq .Lnamgfl_key
.Lnamgfl_skip_line:
 cmp x19,x20
 b.hs .Lnamgfl_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Lnamgfl_skip_line
 b .Lnamgfl_find_line
.Lnamgfl_key:
 mov x0,x19
 mov x1,x20
 bl .Lnamgfl_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lnamgfl_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lnamgfl_key_start
 add x19,x19,#1
 b .Lnamgfl_key
.Lnamgfl_key_start:
 cmp w9,#47
 b.eq .Lnamgfl_finish
 mov x27,x19
.Lnamgfl_key_scan:
 cmp x19,x20
 b.hs .Lnamgfl_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lnamgfl_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lnamgfl_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lnamgfl_key_next
 cmp w9,#95
 b.eq .Lnamgfl_key_next
 cmp w9,#37
 b.ne .Lnamgfl_key_lookup_call
.Lnamgfl_key_next:
 add x19,x19,#1
 b .Lnamgfl_key_scan
.Lnamgfl_key_lookup_call:
 mov x0,x27
 sub x1,x19,x27
 bl .Lnamgfl_lookup
 tbnz w0,#31,.Lnamgfl_bad
 mov w25,w0
 mov w26,w1
 mov x0,x19
 mov x1,x20
 bl .Lnamgfl_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lnamgfl_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Lnamgfl_bad
 mov x0,x19
 mov x1,x20
 bl .Lnamgfl_skip_blank
 mov x19,x0
 mov x27,x0
.Lnamgfl_value_scan:
 cmp x19,x20
 b.hs .Lnamgfl_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lnamgfl_value_found
 cmp w9,#9
 b.eq .Lnamgfl_value_found
 cmp w9,#13
 b.eq .Lnamgfl_value_found
 cmp w9,#10
 b.eq .Lnamgfl_value_found
 cmp w9,#44
 b.eq .Lnamgfl_value_found
 cmp w9,#33
 b.eq .Lnamgfl_value_found
 cmp w9,#47
 b.eq .Lnamgfl_value_found
 add x19,x19,#1
 b .Lnamgfl_value_scan
.Lnamgfl_value_found:
 mov x0,x27
 sub x1,x19,x27
 cbnz w26,.Lnamgfl_integer_call
 bl .Lnamgfl_boolean
 b .Lnamgfl_value_result
.Lnamgfl_integer_call:
 bl .Lnamgfl_integer
.Lnamgfl_value_result:
 cbnz w1,.Lnamgfl_bad
 str w0,[x22,x25]
 b .Lnamgfl_key
.Lnamgfl_finish:
 mov x9,#0
.Lnamgfl_copy_out:
 add x12,x22,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#2304
 b.lo .Lnamgfl_copy_out
 mov w0,#0
 b .Lnamgfl_return
.Lnamgfl_bad:
 mov w0,#2
.Lnamgfl_return:
 add sp,sp,#2304
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_apply_selected_grid_field_namelist,.-md2asm_apply_selected_grid_field_namelist
/* Local helpers use only caller-saved x0..x17. */
.Lnamgfl_skip_blank:
 cmp x0,x1
 b.hs .Lnamgfl_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lnamgfl_skip_next
 cmp w9,#9
 b.eq .Lnamgfl_skip_next
 cmp w9,#13
 b.eq .Lnamgfl_skip_next
 cmp w9,#10
 b.eq .Lnamgfl_skip_next
 cmp w9,#33
 b.ne .Lnamgfl_skip_return
.Lnamgfl_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lnamgfl_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lnamgfl_skip_comment
.Lnamgfl_skip_next:
 add x0,x0,#1
 b .Lnamgfl_skip_blank
.Lnamgfl_skip_return:
 ret
.Lnamgfl_lookup:
 adr x9,.Lnamgfl_keys
 mov w10,#6
.Lnamgfl_lookup_row:
 ldr w11,[x9,#16]
 cmp x1,x11
 b.ne .Lnamgfl_lookup_next
 mov x12,#0
.Lnamgfl_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Lnamgfl_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lnamgfl_lookup_char
 ldp w0,w1,[x9,#20]
 ret
.Lnamgfl_lookup_next:
 add x9,x9,#32
 subs w10,w10,#1
 b.ne .Lnamgfl_lookup_row
 mov w0,#-1
 ret
.Lnamgfl_boolean:
 cbz x1,.Lnamgfl_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Lnamgfl_bool_core
 cmp x1,#3
 b.lo .Lnamgfl_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Lnamgfl_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Lnamgfl_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Lnamgfl_true
 cmp w9,#102
 b.ne .Lnamgfl_token_bad
 mov w15,#0
 adr x10,.Lnamgfl_false_text
 mov w11,#5
 b .Lnamgfl_bool_match
.Lnamgfl_true:
 mov w15,#1
 adr x10,.Lnamgfl_true_text
 mov w11,#4
.Lnamgfl_bool_match:
 cmp x1,#1
 b.eq .Lnamgfl_bool_good
 cmp x1,x11
 b.ne .Lnamgfl_token_bad
 mov x12,#0
.Lnamgfl_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Lnamgfl_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lnamgfl_bool_char
.Lnamgfl_bool_good:
 mov w0,w15
 mov w1,#0
 ret
.Lnamgfl_integer:
 cmp x1,#1
 b.eq .Lnamgfl_integer_positive
 cmp x1,#2
 b.ne .Lnamgfl_token_bad
 ldrb w9,[x0],#1
 cmp w9,#43
 b.eq .Lnamgfl_integer_positive
 cmp w9,#45
 b.ne .Lnamgfl_token_bad
 mov w10,#-1
 b .Lnamgfl_integer_digit
.Lnamgfl_integer_positive:
 mov w10,#1
.Lnamgfl_integer_digit:
 ldrb w9,[x0]
 sub w9,w9,#48
 cmp w9,#1
 b.hi .Lnamgfl_token_bad
 mul w0,w9,w10
 mov w1,#0
 ret
.Lnamgfl_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Lnamgfl_group: .ascii "namgfl"
.Lnamgfl_true_text: .ascii "true"
.Lnamgfl_false_text: .ascii "false"
.p2align 4
.Lnamgfl_keys:
 .ascii "yq_nl%lgp"
 .zero 7
 .word 9,44,0,0
 .ascii "yq_nl%lsp"
 .zero 7
 .word 9,48,0,0
 .ascii "yo3_nl%lgp"
 .zero 6
 .word 10,1580,0,0
 .ascii "yq_nl%lgpingp"
 .zero 3
 .word 13,36,0,0
 .ascii "yr_nl%nreqin"
 .zero 4
 .word 12,1044,1,0
 .ascii "ys_nl%nreqin"
 .zero 4
 .word 12,788,1,0
.section .note.GNU-stack,"",%progbits

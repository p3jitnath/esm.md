/* Contract: skills/md2asm/references/openifs/setup/loop_data_bindings.md.
 * Apply literal first NAMPAR1 to a32-byte private scalar record.
 * x0 bounded text,x1 length,x2 private record. int0/2. Frame128bytes.
 * Reuses the accepted direct scanner, with only its record/group/key table changed. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_apply_selected_parallel_namelist
.type md2asm_apply_selected_parallel_namelist,%function
md2asm_apply_selected_parallel_namelist:
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
 cbz x0,.Lparallel_bad
 cbz x2,.Lparallel_bad
 cbz x1,.Lparallel_bad
 cmp x1,#64,lsl#12
 b.hi .Lparallel_bad
 tst x2,#7
 b.ne .Lparallel_bad
 adds x20,x0,x1
 b.cs .Lparallel_bad
 adds x9,x2,#32
 b.cs .Lparallel_bad
 cmp x9,x0
 b.ls .Lparallel_disjoint
 cmp x2,x20
 b.lo .Lparallel_bad
.Lparallel_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lparallel_bad
 mov x9,#0
.Lparallel_copy_in:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,x22,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#32
 b.lo .Lparallel_copy_in
 /* The source group marker is the first nonblank token on its line. */
.Lparallel_start_line:
 mov w28,#0
.Lparallel_find_line:
 cmp x19,x20
 b.hs .Lparallel_bad
 ldrb w9,[x19],#1
 add w28,w28,#1
 cmp w9,#10
 b.eq .Lparallel_start_line
 cmp w9,#32
 b.eq .Lparallel_find_line
 cmp w9,#9
 b.eq .Lparallel_find_line
 cmp w9,#13
 b.eq .Lparallel_find_line
 cmp w9,#10
 b.eq .Lparallel_find_line
 cmp w9,#38
 b.ne .Lparallel_skip_line
 cmp w28,#10
 b.hi .Lparallel_skip_line
 add x9,x19,#7
 cmp x9,x20
 b.hs .Lparallel_bad
 adr x10,.Lparallel_group
 mov w11,#0
.Lparallel_group_match:
 ldrb w12,[x19,x11]
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Lparallel_skip_line
 add w11,w11,#1
 cmp w11,#7
 b.lo .Lparallel_group_match
 add x19,x19,#7
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lparallel_key
 cmp w9,#9
 b.eq .Lparallel_key
 cmp w9,#13
 b.eq .Lparallel_key
 cmp w9,#10
 b.eq .Lparallel_key
 cmp w9,#47
 b.eq .Lparallel_key
 cmp w9,#44
 b.eq .Lparallel_key
.Lparallel_skip_line:
 cmp x19,x20
 b.hs .Lparallel_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Lparallel_skip_line
 b .Lparallel_start_line
.Lparallel_key:
 mov x0,x19
 mov x1,x20
 bl .Lparallel_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lparallel_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lparallel_key_start
 add x19,x19,#1
 b .Lparallel_key
.Lparallel_key_start:
 cmp w9,#47
 b.eq .Lparallel_finish
 mov x27,x19
.Lparallel_key_scan:
 cmp x19,x20
 b.hs .Lparallel_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lparallel_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lparallel_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lparallel_key_next
 cmp w9,#95
 b.eq .Lparallel_key_next
 cmp w9,#37
 b.ne .Lparallel_key_lookup_call
.Lparallel_key_next:
 add x19,x19,#1
 b .Lparallel_key_scan
.Lparallel_key_lookup_call:
 mov x0,x27
 sub x1,x19,x27
 bl .Lparallel_lookup
 tbnz w0,#31,.Lparallel_bad
 mov w25,w0
 mov w26,w1
 mov x0,x19
 mov x1,x20
 bl .Lparallel_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lparallel_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Lparallel_bad
 mov x0,x19
 mov x1,x20
 bl .Lparallel_skip_blank
 mov x19,x0
 mov x27,x0
.Lparallel_value_scan:
 cmp x19,x20
 b.hs .Lparallel_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lparallel_value_found
 cmp w9,#9
 b.eq .Lparallel_value_found
 cmp w9,#13
 b.eq .Lparallel_value_found
 cmp w9,#10
 b.eq .Lparallel_value_found
 cmp w9,#44
 b.eq .Lparallel_value_found
 cmp w9,#33
 b.eq .Lparallel_value_found
 cmp w9,#47
 b.eq .Lparallel_value_found
 add x19,x19,#1
 b .Lparallel_value_scan
.Lparallel_value_found:
 mov x0,x27
 sub x1,x19,x27
 cbnz w26,.Lparallel_integer_call
 bl .Lparallel_boolean
 b .Lparallel_value_result
.Lparallel_integer_call:
 bl .Lparallel_integer
.Lparallel_value_result:
 cbnz w1,.Lparallel_bad
 str w0,[x22,x25]
 b .Lparallel_key
.Lparallel_finish:
 mov x9,#0
.Lparallel_copy_out:
 add x12,x22,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#32
 b.lo .Lparallel_copy_out
 mov w0,#0
 b .Lparallel_return
.Lparallel_bad:
 mov w0,#2
.Lparallel_return:
 add sp,sp,#32
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_apply_selected_parallel_namelist,.-md2asm_apply_selected_parallel_namelist
/* Local helpers use only caller-saved x0..x17. */
.Lparallel_skip_blank:
 cmp x0,x1
 b.hs .Lparallel_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lparallel_skip_next
 cmp w9,#9
 b.eq .Lparallel_skip_next
 cmp w9,#13
 b.eq .Lparallel_skip_next
 cmp w9,#10
 b.eq .Lparallel_skip_next
 cmp w9,#33
 b.ne .Lparallel_skip_return
.Lparallel_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lparallel_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lparallel_skip_comment
.Lparallel_skip_next:
 add x0,x0,#1
 b .Lparallel_skip_blank
.Lparallel_skip_return:
 ret
.Lparallel_lookup:
 adr x9,.Lparallel_keys
 mov w10,#5
.Lparallel_lookup_row:
 ldr w11,[x9,#16]
 cmp x1,x11
 b.ne .Lparallel_lookup_next
 mov x12,#0
.Lparallel_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Lparallel_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lparallel_lookup_char
 ldp w0,w1,[x9,#20]
 ret
.Lparallel_lookup_next:
 add x9,x9,#32
 subs w10,w10,#1
 b.ne .Lparallel_lookup_row
 mov w0,#-1
 ret
.Lparallel_boolean:
 cbz x1,.Lparallel_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Lparallel_bool_core
 cmp x1,#3
 b.lo .Lparallel_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Lparallel_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Lparallel_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Lparallel_true
 cmp w9,#102
 b.ne .Lparallel_token_bad
 mov w15,#0
 adr x10,.Lparallel_false_text
 mov w11,#5
 b .Lparallel_bool_match
.Lparallel_true:
 mov w15,#1
 adr x10,.Lparallel_true_text
 mov w11,#4
.Lparallel_bool_match:
 cmp x1,#1
 b.eq .Lparallel_bool_good
 cmp x1,x11
 b.ne .Lparallel_token_bad
 mov x12,#0
.Lparallel_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Lparallel_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lparallel_bool_char
.Lparallel_bool_good:
 mov w0,w15
 mov w1,#0
 ret
.Lparallel_integer:
 cmp x1,#1
 b.eq .Lparallel_integer_positive
 cmp x1,#2
 b.ne .Lparallel_token_bad
 ldrb w9,[x0],#1
 cmp w9,#43
 b.eq .Lparallel_integer_positive
 b .Lparallel_token_bad
.Lparallel_integer_positive:
 mov w10,#1
.Lparallel_integer_digit:
 ldrb w9,[x0]
 sub w9,w9,#48
 cmp w9,#2
 b.hi .Lparallel_token_bad
 mul w0,w9,w10
 mov w1,#0
 ret
.Lparallel_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Lparallel_group: .ascii "NAMPAR1"
.Lparallel_true_text: .ascii "true"
.Lparallel_false_text: .ascii "false"
.p2align 4
.Lparallel_keys:
 .ascii "lsplit"
 .zero 10
 .word 6,0,0,0
 .ascii "nfldin"
 .zero 10
 .word 6,4,1,0
 .ascii "nstrin"
 .zero 10
 .word 6,8,1,0
 .ascii "nstrout"
 .zero 9
 .word 7,12,1,0
 .ascii "nouttype"
 .zero 8
 .word 8,16,1,0
 .section .note.GNU-stack,"",%progbits

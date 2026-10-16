/* Apply the first NAEPHY group to a448-byte typed record. Supported keys below.
 * x0 bounded text,x1 bytes1..262144,x2 record. Return0/2, no writes on rejection.
 * Scalar integer tokens0..2, boolean tokens as in Fortran. Frame544 bytes. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_apply_selected_physics_namelist
.type md2asm_apply_selected_physics_namelist,%function
md2asm_apply_selected_physics_namelist:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#448
 mov x19,x0
 mov x21,x2
 mov x22,sp
 cbz x0,.Lnaephy_bad
 cbz x2,.Lnaephy_bad
 cbz x1,.Lnaephy_bad
 cmp x1,#64,lsl#12
 b.hi .Lnaephy_bad
 tst x2,#7
 b.ne .Lnaephy_bad
 adds x20,x0,x1
 b.cs .Lnaephy_bad
 adds x9,x2,#448
 b.cs .Lnaephy_bad
 cmp x9,x0
 b.ls .Lnaephy_disjoint
 cmp x2,x20
 b.lo .Lnaephy_bad
.Lnaephy_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lnaephy_bad
 mov x9,#0
.Lnaephy_copy_in:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,x22,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#448
 b.lo .Lnaephy_copy_in
 /* The source group marker is the first nonblank token on its line. */
.Lnaephy_start_line:
 mov w28,#0
.Lnaephy_find_line:
 cmp x19,x20
 b.hs .Lnaephy_bad
 ldrb w9,[x19],#1
 add w28,w28,#1
 cmp w9,#10
 b.eq .Lnaephy_start_line
 cmp w9,#32
 b.eq .Lnaephy_find_line
 cmp w9,#9
 b.eq .Lnaephy_find_line
 cmp w9,#13
 b.eq .Lnaephy_find_line
 cmp w9,#10
 b.eq .Lnaephy_find_line
 cmp w9,#38
 b.ne .Lnaephy_skip_line
 cmp w28,#10
 b.hi .Lnaephy_skip_line
 add x9,x19,#6
 cmp x9,x20
 b.hs .Lnaephy_bad
 adr x10,.Lnaephy_group
 mov w11,#0
.Lnaephy_group_match:
 ldrb w12,[x19,x11]
 orr w12,w12,#32
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Lnaephy_skip_line
 add w11,w11,#1
 cmp w11,#6
 b.lo .Lnaephy_group_match
 add x19,x19,#6
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lnaephy_key
 cmp w9,#9
 b.eq .Lnaephy_key
 cmp w9,#13
 b.eq .Lnaephy_key
 cmp w9,#10
 b.eq .Lnaephy_key
 cmp w9,#47
 b.eq .Lnaephy_key
 cmp w9,#44
 b.eq .Lnaephy_key
.Lnaephy_skip_line:
 cmp x19,x20
 b.hs .Lnaephy_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Lnaephy_skip_line
 b .Lnaephy_start_line
.Lnaephy_key:
 mov x0,x19
 mov x1,x20
 bl .Lnaephy_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lnaephy_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lnaephy_key_start
 add x19,x19,#1
 b .Lnaephy_key
.Lnaephy_key_start:
 cmp w9,#47
 b.eq .Lnaephy_finish
 mov x27,x19
.Lnaephy_key_scan:
 cmp x19,x20
 b.hs .Lnaephy_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lnaephy_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lnaephy_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lnaephy_key_next
 cmp w9,#95
 b.eq .Lnaephy_key_next
 cmp w9,#37
 b.ne .Lnaephy_key_lookup_call
.Lnaephy_key_next:
 add x19,x19,#1
 b .Lnaephy_key_scan
.Lnaephy_key_lookup_call:
 mov x0,x27
 sub x1,x19,x27
 bl .Lnaephy_lookup
 tbnz w0,#31,.Lnaephy_bad
 mov w25,w0
 mov w26,w1
 mov x0,x19
 mov x1,x20
 bl .Lnaephy_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lnaephy_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Lnaephy_bad
 mov x0,x19
 mov x1,x20
 bl .Lnaephy_skip_blank
 mov x19,x0
 mov x27,x0
.Lnaephy_value_scan:
 cmp x19,x20
 b.hs .Lnaephy_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lnaephy_value_found
 cmp w9,#9
 b.eq .Lnaephy_value_found
 cmp w9,#13
 b.eq .Lnaephy_value_found
 cmp w9,#10
 b.eq .Lnaephy_value_found
 cmp w9,#44
 b.eq .Lnaephy_value_found
 cmp w9,#33
 b.eq .Lnaephy_value_found
 cmp w9,#47
 b.eq .Lnaephy_value_found
 add x19,x19,#1
 b .Lnaephy_value_scan
.Lnaephy_value_found:
 mov x0,x27
 sub x1,x19,x27
 cbnz w26,.Lnaephy_integer_call
 bl .Lnaephy_boolean
 b .Lnaephy_value_result
.Lnaephy_integer_call:
 bl .Lnaephy_integer
.Lnaephy_value_result:
 cbnz w1,.Lnaephy_bad
 str w0,[x22,x25]
 b .Lnaephy_key
.Lnaephy_finish:
 mov x9,#0
.Lnaephy_copy_out:
 add x12,x22,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#448
 b.lo .Lnaephy_copy_out
 mov w0,#0
 b .Lnaephy_return
.Lnaephy_bad:
 mov w0,#2
.Lnaephy_return:
 add sp,sp,#448
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_apply_selected_physics_namelist,.-md2asm_apply_selected_physics_namelist
/* Local helpers use only caller-saved x0..x17. */
.Lnaephy_skip_blank:
 cmp x0,x1
 b.hs .Lnaephy_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lnaephy_skip_next
 cmp w9,#9
 b.eq .Lnaephy_skip_next
 cmp w9,#13
 b.eq .Lnaephy_skip_next
 cmp w9,#10
 b.eq .Lnaephy_skip_next
 cmp w9,#33
 b.ne .Lnaephy_skip_return
.Lnaephy_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lnaephy_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lnaephy_skip_comment
.Lnaephy_skip_next:
 add x0,x0,#1
 b .Lnaephy_skip_blank
.Lnaephy_skip_return:
 ret
.Lnaephy_lookup:
 adr x9,.Lnaephy_keys
 mov w10,#8
.Lnaephy_lookup_row:
 ldr w11,[x9,#16]
 cmp x1,x11
 b.ne .Lnaephy_lookup_next
 mov x12,#0
.Lnaephy_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Lnaephy_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lnaephy_lookup_char
 ldp w0,w1,[x9,#20]
 ret
.Lnaephy_lookup_next:
 add x9,x9,#32
 subs w10,w10,#1
 b.ne .Lnaephy_lookup_row
 mov w0,#-1
 ret
.Lnaephy_boolean:
 cbz x1,.Lnaephy_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Lnaephy_bool_core
 cmp x1,#3
 b.lo .Lnaephy_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Lnaephy_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Lnaephy_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Lnaephy_true
 cmp w9,#102
 b.ne .Lnaephy_token_bad
 mov w15,#0
 adr x10,.Lnaephy_false_text
 mov w11,#5
 b .Lnaephy_bool_match
.Lnaephy_true:
 mov w15,#1
 adr x10,.Lnaephy_true_text
 mov w11,#4
.Lnaephy_bool_match:
 cmp x1,#1
 b.eq .Lnaephy_bool_good
 cmp x1,x11
 b.ne .Lnaephy_token_bad
 mov x12,#0
.Lnaephy_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Lnaephy_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lnaephy_bool_char
.Lnaephy_bool_good:
 mov w0,w15
 mov w1,#0
 ret
.Lnaephy_integer:
 cmp x1,#1
 b.eq .Lnaephy_integer_positive
 cmp x1,#2
 b.ne .Lnaephy_token_bad
 ldrb w9,[x0],#1
 cmp w9,#43
 b.eq .Lnaephy_integer_positive
 b .Lnaephy_token_bad
.Lnaephy_integer_positive:
 mov w10,#1
.Lnaephy_integer_digit:
 ldrb w9,[x0]
 sub w9,w9,#48
 cmp w9,#2
 b.hi .Lnaephy_token_bad
 mul w0,w9,w10
 mov w1,#0
 ret
.Lnaephy_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Lnaephy_group: .ascii "naephy"
.Lnaephy_true_text: .ascii "true"
.Lnaephy_false_text: .ascii "false"
.p2align 4
.Lnaephy_keys:
 .ascii "nalbedoscheme"
 .zero 3
 .word 13,376,1,0
 .ascii "lephys"
 .zero 10
 .word 6,0,0,0
 .ascii "lslphy"
 .zero 10
 .word 6,260,0,0
 .ascii "leradi"
 .zero 10
 .word 6,36,0,0
 .ascii "lelaiv"
 .zero 10
 .word 6,268,0,0
 .ascii "leo3ch"
 .zero 10
 .word 6,72,0,0
 .ascii "lesnml"
 .zero 10
 .word 6,340,0,0
 .ascii "nsnmlws"
 .zero 9
 .word 7,348,1,0
.section .note.GNU-stack,"",%progbits

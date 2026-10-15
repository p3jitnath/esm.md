/* Bounded scalar NAMDIM parser. Contract skills/md2asm/references/openifs/setup/grid_dimension_setup.md.
 * x0 text, x1 byte count, x2 twelve integer outputs, x3 presence-mask output.
 * Outputs change only after the complete first group passes. No allocation.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_read_grid_dimension_group
.type md2asm_read_grid_dimension_group,%function
md2asm_read_grid_dimension_group:
 cbz x0,.Ldp_bad
 cbz x1,.Ldp_bad
 adds x4,x0,x1
 b.cs .Ldp_bad
 cbz x2,.Ldp_bad
 tst x2,#3
 b.ne .Ldp_bad
 cbz x3,.Ldp_bad
 tst x3,#3
 b.ne .Ldp_bad
 sub sp,sp,#64
 stp xzr,xzr,[sp]
 stp xzr,xzr,[sp,#16]
 stp xzr,xzr,[sp,#32]
 mov w16,#0
 mov x4,#0
.Ldp_line:
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#32
 b.eq .Ldp_line_next
 cmp w5,#9
 b.eq .Ldp_line_next
 cmp w5,#10
 b.eq .Ldp_line_next
 cmp w5,#13
 b.eq .Ldp_line_next
 cmp w5,#38
 b.ne .Ldp_skip_line
 add x5,x4,#1
 adr x6,.Ldp_group_name
 mov x7,#0
.Ldp_group_match:
 cmp x5,x1
 b.hs .Ldp_stack_bad
 ldrb w8,[x0,x5]
 orr w8,w8,#32
 ldrb w9,[x6,x7]
 cmp w8,w9
 b.ne .Ldp_skip_line
 add x5,x5,#1
 add x7,x7,#1
 cmp x7,#6
 b.lo .Ldp_group_match
 cmp x5,x1
 b.hs .Ldp_stack_bad
 ldrb w8,[x0,x5]
 cmp w8,#32
 b.eq .Ldp_found
 cmp w8,#9
 b.eq .Ldp_found
 cmp w8,#10
 b.eq .Ldp_found
 cmp w8,#13
 b.eq .Ldp_found
 cmp w8,#47
 b.eq .Ldp_found
 cmp w8,#33
 b.ne .Ldp_skip_line
.Ldp_found:
 mov x4,x5
 adr x17,.Ldp_field_names
.Ldp_token:
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#47
 b.eq .Ldp_accept
 cmp w5,#33
 b.eq .Ldp_comment
 cmp w5,#32
 b.eq .Ldp_token_next
 cmp w5,#9
 b.eq .Ldp_token_next
 cmp w5,#10
 b.eq .Ldp_token_next
 cmp w5,#13
 b.eq .Ldp_token_next
 cmp w5,#44
 b.eq .Ldp_token_next
 mov x6,#0
.Ldp_field_candidate:
 add x8,x17,x6,lsl#4
 mov x11,x4
.Ldp_field_match:
 ldrb w10,[x8],#1
 cbz w10,.Ldp_field_end
 cmp x11,x1
 b.hs .Ldp_stack_bad
 ldrb w9,[x0,x11]
 orr w9,w9,#32
 cmp w9,w10
 b.ne .Ldp_field_next
 add x11,x11,#1
 b .Ldp_field_match
.Ldp_field_end:
 cmp x11,x1
 b.hs .Ldp_stack_bad
 ldrb w9,[x0,x11]
 cmp w9,#61
 b.eq .Ldp_key
 cmp w9,#32
 b.eq .Ldp_key
 cmp w9,#9
 b.eq .Ldp_key
 cmp w9,#10
 b.eq .Ldp_key
 cmp w9,#13
 b.eq .Ldp_key
 cmp w9,#33
 b.eq .Ldp_key
.Ldp_field_next:
 add x6,x6,#1
 cmp x6,#12
 b.lo .Ldp_field_candidate
 b .Ldp_stack_bad
.Ldp_key:
 mov w15,w6
 mov x4,x11
.Ldp_equal_space:
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#61
 b.eq .Ldp_equal
 cmp w5,#33
 b.eq .Ldp_equal_comment
 cmp w5,#32
 b.eq .Ldp_equal_next
 cmp w5,#9
 b.eq .Ldp_equal_next
 cmp w5,#10
 b.eq .Ldp_equal_next
 cmp w5,#13
 b.ne .Ldp_stack_bad
.Ldp_equal_next:
 add x4,x4,#1
 b .Ldp_equal_space
.Ldp_equal_comment:
 add x4,x4,#1
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#10
 b.ne .Ldp_equal_comment
 b .Ldp_equal_next
.Ldp_equal:
 add x4,x4,#1
.Ldp_value_space:
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#33
 b.eq .Ldp_value_comment
 cmp w5,#32
 b.eq .Ldp_value_next
 cmp w5,#9
 b.eq .Ldp_value_next
 cmp w5,#10
 b.eq .Ldp_value_next
 cmp w5,#13
 b.eq .Ldp_value_next
 mov w13,#0
 cmp w5,#45
 b.eq .Ldp_negative
 cmp w5,#43
 b.eq .Ldp_sign_next
 b .Ldp_digits_start
.Ldp_negative:
 mov w13,#1
.Ldp_sign_next:
 add x4,x4,#1
.Ldp_digits_start:
 mov x12,#0
 mov x14,#0
 movz x7,#0xffff
 movk x7,#0x7fff,lsl#16
 add x7,x7,x13
.Ldp_digits:
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 sub w6,w5,#48
 cmp w6,#9
 b.hi .Ldp_digits_end
 add x12,x12,x12,lsl#2
 lsl x12,x12,#1
 add x12,x12,x6
 cmp x12,x7
 b.hi .Ldp_stack_bad
 add x14,x14,#1
 add x4,x4,#1
 b .Ldp_digits
.Ldp_digits_end:
 cbz x14,.Ldp_stack_bad
 cmp w5,#32
 b.eq .Ldp_value_done
 cmp w5,#9
 b.eq .Ldp_value_done
 cmp w5,#10
 b.eq .Ldp_value_done
 cmp w5,#13
 b.eq .Ldp_value_done
 cmp w5,#44
 b.eq .Ldp_value_done
 cmp w5,#47
 b.eq .Ldp_value_done
 cmp w5,#33
 b.ne .Ldp_stack_bad
.Ldp_value_done:
 cmp w13,#0
 cneg w12,w12,ne
 str w12,[sp,x15,lsl#2]
 mov w6,#1
 lsl w6,w6,w15
 orr w16,w16,w6
 b .Ldp_token
.Ldp_value_next:
 add x4,x4,#1
 b .Ldp_value_space
.Ldp_value_comment:
 add x4,x4,#1
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#10
 b.ne .Ldp_value_comment
 b .Ldp_value_next
.Ldp_token_next:
 add x4,x4,#1
 b .Ldp_token
.Ldp_comment:
 add x4,x4,#1
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#10
 b.ne .Ldp_comment
 b .Ldp_token_next
.Ldp_line_next:
 add x4,x4,#1
 b .Ldp_line
.Ldp_skip_line:
 add x4,x4,#1
 cmp x4,x1
 b.hs .Ldp_stack_bad
 ldrb w5,[x0,x4]
 cmp w5,#10
 b.ne .Ldp_skip_line
 add x4,x4,#1
 b .Ldp_line
.Ldp_accept:
 mov x4,#0
.Ldp_copy:
 ldr w5,[sp,x4,lsl#2]
 str w5,[x2,x4,lsl#2]
 add x4,x4,#1
 cmp x4,#12
 b.lo .Ldp_copy
 str w16,[x3]
 add sp,sp,#64
 mov w0,#0
 ret
.Ldp_stack_bad:
 add sp,sp,#64
.Ldp_bad:
 mov w0,#2
 ret
.size md2asm_read_grid_dimension_group,.-md2asm_read_grid_dimension_group
.Ldp_group_name: .ascii "namdim"
.p2align 4
.Ldp_field_names:
 .asciz "ndglg"
 .zero 10
 .asciz "ndlon"
 .zero 10
 .asciz "ndguxg"
 .zero 9
 .asciz "ndluxg"
 .zero 9
 .asciz "nflevg"
 .zero 9
 .asciz "niolevg"
 .zero 8
 .asciz "nvarmax"
 .zero 8
 .asciz "nmsmax"
 .zero 9
 .asciz "nsmax"
 .zero 10
 .asciz "ncmax"
 .zero 10
 .asciz "nproma"
 .zero 9
 .asciz "nstencilwide"
 .zero 3
.section .note.GNU-stack,"",%progbits

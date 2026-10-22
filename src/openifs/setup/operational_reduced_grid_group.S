/* Contract: skills/md2asm/references/openifs/setup/operational_reduced_grid_configuration.md.
 * First NAMGEM group, selected NHTYP2 and false LNONHYD_GEOM. No mutation.
 * x0 bounded text, x1 byte count. w0 zero accepted, two unsupported.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_read_operational_reduced_grid_group
.type md2asm_read_operational_reduced_grid_group,%function
md2asm_read_operational_reduced_grid_group:
 cbz x0,.Lsgp_bad
 cbz x1,.Lsgp_bad
 adds x9,x0,x1
 b.cs .Lsgp_bad
 sub sp,sp,#16
 stp x29,x30,[sp]
 mov x29,sp
 mov x2,#0
.Lsgp_line:
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Lsgp_line_next
 cmp w3,#9
 b.eq .Lsgp_line_next
 cmp w3,#10
 b.eq .Lsgp_line_next
 cmp w3,#13
 b.eq .Lsgp_line_next
 cmp w3,#38
 b.ne .Lsgp_skip_line
 add x4,x2,#1
 mov x5,#0
 adr x6,.Lsgp_group_name
.Lsgp_group_match:
 cmp x4,x1
 b.hs .Lsgp_stack_bad
 ldrb w7,[x0,x4]
 orr w7,w7,#32
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lsgp_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,#6
 b.lo .Lsgp_group_match
 cmp x4,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Lsgp_found
 cmp w3,#9
 b.eq .Lsgp_found
 cmp w3,#10
 b.eq .Lsgp_found
 cmp w3,#13
 b.eq .Lsgp_found
 cmp w3,#47
 b.eq .Lsgp_found
 cmp w3,#33
 b.ne .Lsgp_skip_line
.Lsgp_found:
 mov x2,x4
.Lsgp_token:
 bl .Lsgp_space
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 cmp w3,#47
 b.eq .Lsgp_accept
 cmp w3,#44
 b.eq .Lsgp_token_next
 mov x4,#0
 mov x8,#0
 mov x9,#5
 adr x5,.Lsgp_field_name
 orr w6,w3,#32
 cmp w6,#108
 b.ne .Lsgp_key
 mov x8,#1
 mov x9,#12
 adr x5,.Lsgp_nonhyd_name
.Lsgp_key:
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w6,[x0,x2]
 sub w7,w6,#65
 cmp w7,#25
 orr w7,w6,#32
 csel w6,w7,w6,ls
 ldrb w7,[x5,x4]
 cmp w6,w7
 b.ne .Lsgp_stack_bad
 add x2,x2,#1
 add x4,x4,#1
 cmp x4,x9
 b.lo .Lsgp_key
 bl .Lsgp_space
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 cmp w3,#61
 b.ne .Lsgp_stack_bad
 add x2,x2,#1
 bl .Lsgp_space
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 cbnz x8,.Lsgp_false_value
 cmp w3,#50
 b.ne .Lsgp_stack_bad
 add x2,x2,#1
 b .Lsgp_value_end
.Lsgp_false_value:
 mov x10,#0
 cmp w3,#46
 b.ne .Lsgp_false_word
 mov x10,#1
 add x2,x2,#1
.Lsgp_false_word:
 adr x5,.Lsgp_false_name
 mov x4,#0
.Lsgp_false_letter:
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w6,[x0,x2]
 orr w6,w6,#32
 ldrb w7,[x5,x4]
 cmp w6,w7
 b.ne .Lsgp_stack_bad
 add x2,x2,#1
 add x4,x4,#1
 cmp x4,#5
 b.lo .Lsgp_false_letter
 cbz x10,.Lsgp_value_end
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x2]
 cmp w3,#46
 b.ne .Lsgp_stack_bad
 add x2,x2,#1
.Lsgp_value_end:
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Lsgp_token
 cmp w3,#44
 b.eq .Lsgp_token
 cmp w3,#33
 b.eq .Lsgp_token
 cmp w3,#32
 b.eq .Lsgp_token
 cmp w3,#9
 b.eq .Lsgp_token
 cmp w3,#10
 b.eq .Lsgp_token
 cmp w3,#13
 b.ne .Lsgp_stack_bad
 b .Lsgp_token
.Lsgp_token_next:
 add x2,x2,#1
 b .Lsgp_token
.Lsgp_line_next:
 add x2,x2,#1
 b .Lsgp_line
.Lsgp_skip_line:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lsgp_skip_line
 add x2,x2,#1
 b .Lsgp_line
.Lsgp_accept:
 ldp x29,x30,[sp]
 add sp,sp,#16
 mov w0,#0
 ret
.Lsgp_stack_bad:
 ldp x29,x30,[sp]
 add sp,sp,#16
.Lsgp_bad:
 mov w0,#2
 ret
.Lsgp_space:
 cmp x2,x1
 b.hs .Lsgp_space_return
 ldrb w3,[x0,x2]
 cmp w3,#33
 b.eq .Lsgp_comment
 cmp w3,#32
 b.eq .Lsgp_space_next
 cmp w3,#9
 b.eq .Lsgp_space_next
 cmp w3,#10
 b.eq .Lsgp_space_next
 cmp w3,#13
 b.ne .Lsgp_space_return
.Lsgp_space_next:
 add x2,x2,#1
 b .Lsgp_space
.Lsgp_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lsgp_space_return
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lsgp_comment
 b .Lsgp_space_next
.Lsgp_space_return:
 ret
.size md2asm_read_operational_reduced_grid_group,.-md2asm_read_operational_reduced_grid_group
.Lsgp_group_name: .ascii "namgem"
.Lsgp_field_name: .ascii "nhtyp"
.Lsgp_nonhyd_name: .ascii "lnonhyd_geom"
.Lsgp_false_name: .ascii "false"
.section .note.GNU-stack,"",%progbits

/* First NAMGEM group, selected scalar NHTYP=0 input. No mutation.
 * x0 bounded text, x1 byte count. w0 zero accepted, two unsupported.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_read_spherical_geometry_group
.type md2asm_read_spherical_geometry_group,%function
md2asm_read_spherical_geometry_group:
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
 adr x5,.Lsgp_field_name
.Lsgp_key:
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
 cmp w3,#45
 b.eq .Lsgp_sign
 cmp w3,#43
 b.ne .Lsgp_zero
.Lsgp_sign:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x2]
.Lsgp_zero:
 cmp w3,#48
 b.ne .Lsgp_stack_bad
.Lsgp_zero_next:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lsgp_stack_bad
 ldrb w3,[x0,x2]
 cmp w3,#48
 b.eq .Lsgp_zero_next
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
.size md2asm_read_spherical_geometry_group,.-md2asm_read_spherical_geometry_group
.Lsgp_group_name: .ascii "namgem"
.Lsgp_field_name: .ascii "nhtyp"
.section .note.GNU-stack,"",%progbits

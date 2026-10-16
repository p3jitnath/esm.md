/* Contract: skills/md2asm/references/openifs/setup/owned_geometry_system.md.
 * x0 mapped text, x1 byte count, x2 exact uppercase name, x3 name byte count.
 * w0=0 empty supported group,2 absent/nonempty/malformed. Leaf, no stack.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_require_empty_geometry_group
.type md2asm_require_empty_geometry_group,%function
md2asm_require_empty_geometry_group:
 mov x6,x2
 mov x12,x3
.Ltransform_group_selected:
 cbz x0,.Ltransform_group_reject
 cbz x1,.Ltransform_group_reject
 adds x9,x0,x1
 b.cs .Ltransform_group_reject
 mov x2,#0
 mov x13,#0
.Ltransform_group_line:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 cmp x13,#10
 b.hs .Ltransform_group_skip_line
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Ltransform_group_leading
 cmp w3,#9
 b.eq .Ltransform_group_leading
 cmp w3,#10
 b.eq .Ltransform_group_leading
 cmp w3,#13
 b.eq .Ltransform_group_leading
 cmp w3,#38
 b.ne .Ltransform_group_skip_line
 add x4,x2,#1
 mov x5,#0
.Ltransform_group_match:
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w7,[x0,x4]
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Ltransform_group_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,x12
 b.lo .Ltransform_group_match
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Ltransform_group_found
 cmp w3,#9
 b.eq .Ltransform_group_found
 cmp w3,#10
 b.eq .Ltransform_group_found
 cmp w3,#13
 b.eq .Ltransform_group_found
 cmp w3,#47
 b.eq .Ltransform_group_found
 cmp w3,#33
 b.ne .Ltransform_group_skip_line
.Ltransform_group_found:
 mov x2,x4
.Ltransform_group_empty:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Ltransform_group_accept
 cmp w3,#33
 b.eq .Ltransform_group_comment
 cmp w3,#32
 b.eq .Ltransform_group_empty_next
 cmp w3,#9
 b.eq .Ltransform_group_empty_next
 cmp w3,#10
 b.eq .Ltransform_group_empty_next
 cmp w3,#13
 b.ne .Ltransform_group_reject
.Ltransform_group_empty_next:
 add x2,x2,#1
 b .Ltransform_group_empty
.Ltransform_group_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Ltransform_group_comment
 b .Ltransform_group_empty_next
.Ltransform_group_leading:
 add x2,x2,#1
 add x13,x13,#1
 cmp w3,#10
 csel x13,xzr,x13,eq
 b .Ltransform_group_line
.Ltransform_group_skip_line:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 add x2,x2,#1
 cmp w3,#10
 b.ne .Ltransform_group_skip_line
 mov x13,#0
 b .Ltransform_group_line
.Ltransform_group_accept:
 mov w0,#0
 ret
.Ltransform_group_reject:
 mov w0,#2
 ret
.size md2asm_require_empty_geometry_group,.-md2asm_require_empty_geometry_group
.Ltransform_group_name0:
 .ascii "NAMTRANS0"
.Ltransform_group_name1:
 .ascii "NAMTRANS"
.section .note.GNU-stack,"",%progbits

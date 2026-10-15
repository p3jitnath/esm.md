/* Empty NAMCVER group check for the selected native setup route.
 * Contract: skills/md2asm/references/openifs/setup/vertical_coordinate_configuration.md.
 * x0 mapped text, x1 byte count. w0 zero for an empty group, otherwise two.
 * Only a group beginning after line-leading spaces/tabs is selected.
 * ASCII case is ignored, and exclamation comments extend to the next line.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_empty_vertical_configuration_group
.type md2asm_empty_vertical_configuration_group,%function
md2asm_empty_vertical_configuration_group:
 cbz x0,.Lvertical_group_reject
 cbz x1,.Lvertical_group_reject
 adds x9,x0,x1
 b.cs .Lvertical_group_reject
 mov x2,#0
.Lvertical_group_line:
 cmp x2,x1
 b.hs .Lvertical_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Lvertical_group_leading
 cmp w3,#9
 b.eq .Lvertical_group_leading
 cmp w3,#10
 b.eq .Lvertical_group_leading
 cmp w3,#13
 b.eq .Lvertical_group_leading
 cmp w3,#38
 b.ne .Lvertical_group_skip_line
 add x4,x2,#1
 mov x5,#0
 adr x6,.Lvertical_group_name
.Lvertical_group_match:
 cmp x4,x1
 b.hs .Lvertical_group_reject
 ldrb w7,[x0,x4]
 orr w7,w7,#32
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lvertical_group_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,#7
 b.lo .Lvertical_group_match
 cmp x4,x1
 b.hs .Lvertical_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Lvertical_group_found
 cmp w3,#9
 b.eq .Lvertical_group_found
 cmp w3,#10
 b.eq .Lvertical_group_found
 cmp w3,#13
 b.eq .Lvertical_group_found
 cmp w3,#47
 b.eq .Lvertical_group_found
 cmp w3,#33
 b.ne .Lvertical_group_skip_line
.Lvertical_group_found:
 mov x2,x4
.Lvertical_group_empty:
 cmp x2,x1
 b.hs .Lvertical_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Lvertical_group_accept
 cmp w3,#33
 b.eq .Lvertical_group_comment
 cmp w3,#32
 b.eq .Lvertical_group_empty_next
 cmp w3,#9
 b.eq .Lvertical_group_empty_next
 cmp w3,#10
 b.eq .Lvertical_group_empty_next
 cmp w3,#13
 b.ne .Lvertical_group_reject
.Lvertical_group_empty_next:
 add x2,x2,#1
 b .Lvertical_group_empty
.Lvertical_group_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lvertical_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lvertical_group_comment
 b .Lvertical_group_empty_next
.Lvertical_group_leading:
 add x2,x2,#1
 b .Lvertical_group_line
.Lvertical_group_skip_line:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lvertical_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lvertical_group_skip_line
 add x2,x2,#1
 b .Lvertical_group_line
.Lvertical_group_accept:
 mov w0,#0
 ret
.Lvertical_group_reject:
 mov w0,#2
 ret
.size md2asm_empty_vertical_configuration_group,.-md2asm_empty_vertical_configuration_group
.Lvertical_group_name: .ascii "namcver"
.section .note.GNU-stack,"",%progbits

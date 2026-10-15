// Solver contract skills/md2asm/references/openifs/setup/standard_atmosphere_native_entry.md.
/* Empty NAMSTA group check for the selected native setup route.
 * Contract: skills/md2asm/references/openifs/setup/standard_atmosphere_native_entry.md in this directory.
 * x0 mapped text, x1 byte count. w0 zero for an empty group, otherwise two.
 * Only a group beginning after line-leading spaces/tabs is selected.
 * ASCII case is ignored, and exclamation comments extend to the next line.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_empty_atmosphere_group
.type md2asm_empty_atmosphere_group,%function
md2asm_empty_atmosphere_group:
 cbz x0,.Lgroup_reject
 cbz x1,.Lgroup_reject
 adds x9,x0,x1
 b.cs .Lgroup_reject
 mov x2,#0
.Lgroup_line:
 cmp x2,x1
 b.hs .Lgroup_reject
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Lgroup_leading
 cmp w3,#9
 b.eq .Lgroup_leading
 cmp w3,#10
 b.eq .Lgroup_leading
 cmp w3,#13
 b.eq .Lgroup_leading
 cmp w3,#38
 b.ne .Lgroup_skip_line
 add x4,x2,#1
 mov x5,#0
 adr x6,.Lgroup_name
.Lgroup_match:
 cmp x4,x1
 b.hs .Lgroup_reject
 ldrb w7,[x0,x4]
 orr w7,w7,#32
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lgroup_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,#6
 b.lo .Lgroup_match
 cmp x4,x1
 b.hs .Lgroup_reject
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Lgroup_found
 cmp w3,#9
 b.eq .Lgroup_found
 cmp w3,#10
 b.eq .Lgroup_found
 cmp w3,#13
 b.eq .Lgroup_found
 cmp w3,#47
 b.eq .Lgroup_found
 cmp w3,#33
 b.ne .Lgroup_skip_line
.Lgroup_found:
 mov x2,x4
.Lgroup_empty:
 cmp x2,x1
 b.hs .Lgroup_reject
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Lgroup_accept
 cmp w3,#33
 b.eq .Lgroup_comment
 cmp w3,#32
 b.eq .Lgroup_empty_next
 cmp w3,#9
 b.eq .Lgroup_empty_next
 cmp w3,#10
 b.eq .Lgroup_empty_next
 cmp w3,#13
 b.ne .Lgroup_reject
.Lgroup_empty_next:
 add x2,x2,#1
 b .Lgroup_empty
.Lgroup_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lgroup_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lgroup_comment
 b .Lgroup_empty_next
.Lgroup_leading:
 add x2,x2,#1
 b .Lgroup_line
.Lgroup_skip_line:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lgroup_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lgroup_skip_line
 add x2,x2,#1
 b .Lgroup_line
.Lgroup_accept:
 mov w0,#0
 ret
.Lgroup_reject:
 mov w0,#2
 ret
.size md2asm_empty_atmosphere_group,.-md2asm_empty_atmosphere_group
.Lgroup_name: .ascii "namsta"
.section .note.GNU-stack,"",%progbits

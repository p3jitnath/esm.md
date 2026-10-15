/* Empty NAMDIM_TRAJ group check for the selected native setup route.
 * Contract: skills/md2asm/references/openifs/setup/trajectory_dimension_setup.md.
 * x0 mapped text, x1 byte count. w0 zero for an empty group, otherwise two.
 * Only a group beginning after line-leading spaces/tabs is selected.
 * ASCII case is ignored, and exclamation comments extend to the next line.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_empty_trajectory_dimension_group
.type md2asm_empty_trajectory_dimension_group,%function
md2asm_empty_trajectory_dimension_group:
 cbz x0,.Ltrajectory_group_reject
 cbz x1,.Ltrajectory_group_reject
 adds x9,x0,x1
 b.cs .Ltrajectory_group_reject
 mov x2,#0
.Ltrajectory_group_line:
 cmp x2,x1
 b.hs .Ltrajectory_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Ltrajectory_group_leading
 cmp w3,#9
 b.eq .Ltrajectory_group_leading
 cmp w3,#10
 b.eq .Ltrajectory_group_leading
 cmp w3,#13
 b.eq .Ltrajectory_group_leading
 cmp w3,#38
 b.ne .Ltrajectory_group_skip_line
 add x4,x2,#1
 mov x5,#0
 adr x6,.Ltrajectory_group_name
.Ltrajectory_group_match:
 cmp x4,x1
 b.hs .Ltrajectory_group_reject
 ldrb w7,[x0,x4]
 sub w9,w7,#65
 cmp w9,#25
 orr w9,w7,#32
 csel w7,w9,w7,ls
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Ltrajectory_group_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,#11
 b.lo .Ltrajectory_group_match
 cmp x4,x1
 b.hs .Ltrajectory_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Ltrajectory_group_found
 cmp w3,#9
 b.eq .Ltrajectory_group_found
 cmp w3,#10
 b.eq .Ltrajectory_group_found
 cmp w3,#13
 b.eq .Ltrajectory_group_found
 cmp w3,#47
 b.eq .Ltrajectory_group_found
 cmp w3,#33
 b.ne .Ltrajectory_group_skip_line
.Ltrajectory_group_found:
 mov x2,x4
.Ltrajectory_group_empty:
 cmp x2,x1
 b.hs .Ltrajectory_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Ltrajectory_group_accept
 cmp w3,#33
 b.eq .Ltrajectory_group_comment
 cmp w3,#32
 b.eq .Ltrajectory_group_empty_next
 cmp w3,#9
 b.eq .Ltrajectory_group_empty_next
 cmp w3,#10
 b.eq .Ltrajectory_group_empty_next
 cmp w3,#13
 b.ne .Ltrajectory_group_reject
.Ltrajectory_group_empty_next:
 add x2,x2,#1
 b .Ltrajectory_group_empty
.Ltrajectory_group_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Ltrajectory_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Ltrajectory_group_comment
 b .Ltrajectory_group_empty_next
.Ltrajectory_group_leading:
 add x2,x2,#1
 b .Ltrajectory_group_line
.Ltrajectory_group_skip_line:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Ltrajectory_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Ltrajectory_group_skip_line
 add x2,x2,#1
 b .Ltrajectory_group_line
.Ltrajectory_group_accept:
 mov w0,#0
 ret
.Ltrajectory_group_reject:
 mov w0,#2
 ret
.size md2asm_empty_trajectory_dimension_group,.-md2asm_empty_trajectory_dimension_group
.Ltrajectory_group_name: .ascii "namdim_traj"
.section .note.GNU-stack,"",%progbits

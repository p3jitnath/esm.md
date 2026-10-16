/* Require an empty first uppercase NAMDYNA group in bounded live text.
 * x0 text,x1 bytes1..262144; return0/2. Read-only integer leaf.
 * Supported markers are the first nonblank token within ten source columns.
 * Contract: skills/md2asm/references/openifs/setup/selected_dynamics_controls.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_require_empty_dynamics_namelist
.type md2asm_require_empty_dynamics_namelist,%function
md2asm_require_empty_dynamics_namelist:
 cbz x0,.Ldynamics_text_bad
 cbz x1,.Ldynamics_text_bad
 cmp x1,#64,lsl#12
 b.hi .Ldynamics_text_bad
 adds x2,x0,x1
 b.cs .Ldynamics_text_bad
.Ldynamics_start_line:
 mov w3,#0
.Ldynamics_find_marker:
 cmp x0,x2
 b.hs .Ldynamics_text_bad
 ldrb w4,[x0],#1
 cmp w4,#10
 b.eq .Ldynamics_start_line
 add w3,w3,#1
 cmp w4,#32
 b.eq .Ldynamics_find_marker
 cmp w4,#9
 b.eq .Ldynamics_find_marker
 cmp w4,#13
 b.eq .Ldynamics_find_marker
 cmp w4,#38
 b.ne .Ldynamics_skip_line
 cmp w3,#10
 b.hi .Ldynamics_skip_line
 add x5,x0,#7
 cmp x5,x2
 b.hs .Ldynamics_text_bad
 adr x6,.Ldynamics_group
 mov x7,#0
.Ldynamics_group_match:
 ldrb w8,[x0,x7]
 ldrb w9,[x6,x7]
 cmp w8,w9
 b.ne .Ldynamics_skip_line
 add x7,x7,#1
 cmp x7,#7
 b.lo .Ldynamics_group_match
 add x0,x0,#7
 ldrb w4,[x0]
 cmp w4,#32
 b.eq .Ldynamics_empty_body
 cmp w4,#9
 b.eq .Ldynamics_empty_body
 cmp w4,#13
 b.eq .Ldynamics_empty_body
 cmp w4,#10
 b.eq .Ldynamics_empty_body
 cmp w4,#47
 b.eq .Ldynamics_empty_body
 b .Ldynamics_skip_line
.Ldynamics_skip_line:
 cmp x0,x2
 b.hs .Ldynamics_text_bad
 ldrb w4,[x0],#1
 cmp w4,#10
 b.ne .Ldynamics_skip_line
 b .Ldynamics_start_line
.Ldynamics_empty_body:
 cmp x0,x2
 b.hs .Ldynamics_text_bad
 ldrb w4,[x0],#1
 cmp w4,#47
 b.eq .Ldynamics_text_ok
 cmp w4,#32
 b.eq .Ldynamics_empty_body
 cmp w4,#9
 b.eq .Ldynamics_empty_body
 cmp w4,#10
 b.eq .Ldynamics_empty_body
 cmp w4,#13
 b.eq .Ldynamics_empty_body
 cmp w4,#33
 b.ne .Ldynamics_text_bad
.Ldynamics_body_comment:
 cmp x0,x2
 b.hs .Ldynamics_text_bad
 ldrb w4,[x0],#1
 cmp w4,#10
 b.ne .Ldynamics_body_comment
 b .Ldynamics_empty_body
.Ldynamics_text_ok:
 mov w0,#0
 ret
.Ldynamics_text_bad:
 mov w0,#2
 ret
.size md2asm_require_empty_dynamics_namelist,.-md2asm_require_empty_dynamics_namelist
.section .rodata
.Ldynamics_group: .ascii "NAMDYNA"
.section .note.GNU-stack,"",%progbits

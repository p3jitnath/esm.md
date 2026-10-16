/* Contract: skills/md2asm/references/openifs/radiation/ecrad_configuration.md. */
/* Check the first uppercase-exact named group in bounded live text.
 * x0 text, x1 bytes1..262144, x2 group bytes, x3 group length1..16.
 * The first nonblank marker must be within ten source columns.
 * Return0 for absence or an empty body (comments allowed), otherwise2. No mutations.
 * Integer leaf; preserves x18, callee-saved registers and FP state.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_require_optional_empty_radiation_group
.type md2asm_require_optional_empty_radiation_group,%function
md2asm_require_optional_empty_radiation_group:
 cbz x0,.Lecrad_optional_text_bad
 cbz x1,.Lecrad_optional_text_bad
 cbz x2,.Lecrad_optional_text_bad
 cbz x3,.Lecrad_optional_text_bad
 cmp x3,#16
 b.hi .Lecrad_optional_text_bad
 cmp x1,#64,lsl#12
 b.hi .Lecrad_optional_text_bad
 adds x4,x0,x1
 b.cs .Lecrad_optional_text_bad
.Lecrad_optional_start_line:
 mov w5,#0
.Lecrad_optional_find_marker:
 cmp x0,x4
 b.hs .Lecrad_optional_text_ok
 ldrb w6,[x0],#1
 cmp w6,#10
 b.eq .Lecrad_optional_start_line
 add w5,w5,#1
 cmp w6,#32
 b.eq .Lecrad_optional_find_marker
 cmp w6,#9
 b.eq .Lecrad_optional_find_marker
 cmp w6,#13
 b.eq .Lecrad_optional_find_marker
 cmp w6,#38
 b.ne .Lecrad_optional_skip_line
 cmp w5,#10
 b.hi .Lecrad_optional_skip_line
 add x7,x0,x3
 cmp x7,x4
 b.hs .Lecrad_optional_text_bad
 mov x8,#0
.Lecrad_optional_group_match:
 ldrb w9,[x0,x8]
 ldrb w10,[x2,x8]
 cmp w9,w10
 b.ne .Lecrad_optional_skip_line
 add x8,x8,#1
 cmp x8,x3
 b.lo .Lecrad_optional_group_match
 mov x0,x7
 ldrb w6,[x0]
 cmp w6,#32
 b.eq .Lecrad_optional_empty_body
 cmp w6,#9
 b.eq .Lecrad_optional_empty_body
 cmp w6,#13
 b.eq .Lecrad_optional_empty_body
 cmp w6,#10
 b.eq .Lecrad_optional_empty_body
 cmp w6,#47
 b.eq .Lecrad_optional_empty_body
 b .Lecrad_optional_skip_line
.Lecrad_optional_skip_line:
 cmp x0,x4
 b.hs .Lecrad_optional_text_ok
 ldrb w6,[x0],#1
 cmp w6,#10
 b.ne .Lecrad_optional_skip_line
 b .Lecrad_optional_start_line
.Lecrad_optional_empty_body:
 cmp x0,x4
 b.hs .Lecrad_optional_text_bad
 ldrb w6,[x0],#1
 cmp w6,#47
 b.eq .Lecrad_optional_text_ok
 cmp w6,#32
 b.eq .Lecrad_optional_empty_body
 cmp w6,#9
 b.eq .Lecrad_optional_empty_body
 cmp w6,#10
 b.eq .Lecrad_optional_empty_body
 cmp w6,#13
 b.eq .Lecrad_optional_empty_body
 cmp w6,#33
 b.ne .Lecrad_optional_text_bad
.Lecrad_optional_body_comment:
 cmp x0,x4
 b.hs .Lecrad_optional_text_bad
 ldrb w6,[x0],#1
 cmp w6,#10
 b.ne .Lecrad_optional_body_comment
 b .Lecrad_optional_empty_body
.Lecrad_optional_text_ok:
 mov w0,#0
 ret
.Lecrad_optional_text_bad:
 mov w0,#2
 ret
.size md2asm_require_optional_empty_radiation_group,.-md2asm_require_optional_empty_radiation_group
.section .note.GNU-stack,"",%progbits

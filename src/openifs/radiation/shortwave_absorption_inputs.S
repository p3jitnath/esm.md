/* Contract: skills/md2asm/references/openifs/radiation/shortwave_absorption_setup.md.
 * x0 actual RADSRTM bytes, x1 exact length, x2 owned output, x3 capacity.
 * This leaf performs integer input conversion and source literal stores only. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_decode_shortwave_absorption_inputs
.type md2asm_decode_shortwave_absorption_inputs,%function
md2asm_decode_shortwave_absorption_inputs:
 cbz x0,.Lsw_bad
 cbz x2,.Lsw_bad
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lsw_bad
 movz x4,#(1332584 & 65535)
 movk x4,#(1332584 >> 16),lsl#16
 cmp x1,x4
 b.ne .Lsw_bad
 movz x5,#(4059736 & 65535)
 movk x5,#(4059736 >> 16),lsl#16
 cmp x3,x5
 b.lo .Lsw_bad
 adds x6,x0,x4
 b.cs .Lsw_bad
 adds x7,x2,x5
 b.cs .Lsw_bad
 cmp x0,x7
 b.hs .Lsw_clear
 cmp x2,x6
 b.lo .Lsw_bad
.Lsw_clear:
 adr x4,.Lsw_record_plan
 mov x5,#13
.Lsw_preflight:
 ldp x6,x7,[x4],#16
 add x8,x0,x6
 ldr w9,[x8]
 rev w9,w9
 cmp x9,x7
 b.ne .Lsw_bad
 add x8,x8,x7
 ldr w9,[x8,#4]
 rev w9,w9
 cmp x9,x7
 b.ne .Lsw_bad
 subs x5,x5,#1
 b.ne .Lsw_preflight
 adr x4,.Lsw_file_copy_plan
 mov x5,#24
.Lsw_file_field:
 ldp x6,x7,[x4]
 ldp x8,x9,[x4,#16]
 add x6,x0,x6
 add x7,x2,x7
 add x8,x2,x8
.Lsw_field_word:
 ldr x10,[x6],#8
 rev x10,x10
 str x10,[x7],#8
 str x10,[x8],#8
 subs x9,x9,#8
 b.ne .Lsw_field_word
 add x4,x4,#32
 subs x5,x5,#1
 b.ne .Lsw_file_field
 adr x4,.Lsw_literal_copy_plan
 adr x12,.Lsw_literal_values
 mov x5,#17
.Lsw_literal_range:
 ldp x6,x7,[x4]
 ldr x8,[x4,#16]
 add x6,x2,x6
 add x7,x12,x7
.Lsw_literal_word:
 ldr w9,[x7],#4
 str w9,[x6],#4
 subs x8,x8,#4
 b.ne .Lsw_literal_word
 add x4,x4,#24
 subs x5,x5,#1
 b.ne .Lsw_literal_range
 mov w0,#0
 ret
.Lsw_bad:
 mov w0,#2
 ret
.size md2asm_decode_shortwave_absorption_inputs,.-md2asm_decode_shortwave_absorption_inputs
#include "shortwave_absorption_literals.inc.S"
.section .note.GNU-stack,"",%progbits

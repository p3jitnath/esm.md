/* Contract: skills/md2asm/references/openifs/radiation/longwave_absorption_inputs.md.
 * x0 actual RADRRTM bytes, x1 exact length, x2 owned output, x3 capacity.
 * This leaf performs integer input conversion and source literal stores only. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_decode_longwave_absorption_inputs
.type md2asm_decode_longwave_absorption_inputs,%function
md2asm_decode_longwave_absorption_inputs:
 cbz x0,.Lrrtm_bad
 cbz x2,.Lrrtm_bad
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lrrtm_bad
 movz x4,#(1454208 & 65535)
 movk x4,#(1454208 >> 16),lsl#16
 cmp x1,x4
 b.ne .Lrrtm_bad
 movz x5,#(3148928 & 65535)
 movk x5,#(3148928 >> 16),lsl#16
 cmp x3,x5
 b.lo .Lrrtm_bad
 adds x6,x0,x4
 b.cs .Lrrtm_bad
 adds x7,x2,x5
 b.cs .Lrrtm_bad
 cmp x0,x7
 b.hs .Lrrtm_clear
 cmp x2,x6
 b.lo .Lrrtm_bad
.Lrrtm_clear:
 adrp x4,.Lrrtm_record_plan
 add x4,x4,:lo12:.Lrrtm_record_plan
 mov x5,#16
.Lrrtm_preflight:
 ldp x6,x7,[x4],#16
 add x8,x0,x6
 ldr w9,[x8]
 rev w9,w9
 cmp x9,x7
 b.ne .Lrrtm_bad
 add x8,x8,x7
 ldr w9,[x8,#4]
 rev w9,w9
 cmp x9,x7
 b.ne .Lrrtm_bad
 subs x5,x5,#1
 b.ne .Lrrtm_preflight
 adrp x4,.Lrrtm_file_copy_plan
 add x4,x4,:lo12:.Lrrtm_file_copy_plan
 mov x5,#28
.Lrrtm_file_field:
 ldp x6,x7,[x4]
 ldp x8,x9,[x4,#16]
 add x6,x0,x6
 add x7,x2,x7
 add x8,x2,x8
.Lrrtm_field_word:
 ldr x10,[x6],#8
 rev x10,x10
 str x10,[x7],#8
 str x10,[x8],#8
 subs x9,x9,#8
 b.ne .Lrrtm_field_word
 add x4,x4,#32
 subs x5,x5,#1
 b.ne .Lrrtm_file_field
 adrp x4,.Lrrtm_literal_copy_plan
 add x4,x4,:lo12:.Lrrtm_literal_copy_plan
 adrp x12,.Lrrtm_literal_values
 add x12,x12,:lo12:.Lrrtm_literal_values
 mov x5,#17
.Lrrtm_literal_range:
 ldp x6,x7,[x4]
 ldr x8,[x4,#16]
 add x6,x2,x6
 add x7,x12,x7
.Lrrtm_literal_word:
 ldr x9,[x7],#8
 str x9,[x6],#8
 subs x8,x8,#8
 b.ne .Lrrtm_literal_word
 add x4,x4,#24
 subs x5,x5,#1
 b.ne .Lrrtm_literal_range
 mov w0,#0
 ret
.Lrrtm_bad:
 mov w0,#2
 ret
.size md2asm_decode_longwave_absorption_inputs,.-md2asm_decode_longwave_absorption_inputs
#include "longwave_absorption_literals.inc.S"
.section .note.GNU-stack,"",%progbits

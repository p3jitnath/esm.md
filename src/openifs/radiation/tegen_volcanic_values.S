/* Contract: skills/md2asm/references/openifs/radiation/tegen_volcanic_values.md.
 * int init(x0volcanic578304,x1cap,x2latitude192,x3cap,x4security8,x5cap).
 * Source zeroing, PART1..7 stores and separately rounded scaling remain runtime. */
.text
.p2align 2
.global md2asm_initialize_tegen_volcanic_values
.type md2asm_initialize_tegen_volcanic_values,%function
md2asm_initialize_tegen_volcanic_values:
 cbz x0,.Lvolcanic_bad
 cbz x2,.Lvolcanic_bad
 cbz x4,.Lvolcanic_bad
 orr x6,x0,x2
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lvolcanic_bad
 movz x6,#0xd300
 movk x6,#8,lsl #16
 cmp x1,x6
 b.lo .Lvolcanic_bad
 cmp x3,#192
 b.lo .Lvolcanic_bad
 cmp x5,#8
 b.lo .Lvolcanic_bad
 adds x7,x0,x6
 b.cs .Lvolcanic_bad
 adds x8,x2,#192
 b.cs .Lvolcanic_bad
 adds x9,x4,#8
 b.cs .Lvolcanic_bad
 cmp x0,x8
 b.hs .Lvolcanic_security_span
 cmp x2,x7
 b.lo .Lvolcanic_bad
.Lvolcanic_security_span:
 cmp x0,x9
 b.hs .Lvolcanic_latitude_span
 cmp x4,x7
 b.lo .Lvolcanic_bad
.Lvolcanic_latitude_span:
 cmp x2,x9
 b.hs .Lvolcanic_mode
 cmp x4,x8
 b.lo .Lvolcanic_bad
.Lvolcanic_mode:
 mrs x6,fpcr
 cbnz x6,.Lvolcanic_bad
 mov x7,x0
 movz x8,#0x1a60
 movk x8,#1,lsl #16
.Lvolcanic_zero:
 str xzr,[x7],#8
 subs x8,x8,#1
 b.ne .Lvolcanic_zero
 adrp x9,.Lvolcanic_latitudes
 add x9,x9,:lo12:.Lvolcanic_latitudes
 mov x10,x2
 mov x11,#24
.Lvolcanic_latitude_copy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lvolcanic_latitude_copy
 adrp x9,.Lvolcanic_assignments
 add x9,x9,:lo12:.Lvolcanic_assignments
 mov x10,#648
.Lvolcanic_assignment:
 ldr x11,[x9],#8
 add x11,x0,x11
 mov x12,#24
.Lvolcanic_assignment_copy:
 ldr x13,[x9],#8
 str x13,[x11],#8
 subs x12,x12,#1
 b.ne .Lvolcanic_assignment_copy
 subs x10,x10,#1
 b.ne .Lvolcanic_assignment
 adrp x9,.Lvolcanic_scale
 add x9,x9,:lo12:.Lvolcanic_scale
 ldr d0,[x9]
 mov x7,x0
 movz x8,#0x1a60
 movk x8,#1,lsl #16
.Lvolcanic_scale_values:
 ldr d1,[x7]
 fmul d1,d0,d1
 str d1,[x7],#8
 subs x8,x8,#1
 b.ne .Lvolcanic_scale_values
 adrp x9,.Lvolcanic_security
 add x9,x9,:lo12:.Lvolcanic_security
 ldr x10,[x9]
 str x10,[x4]
 mov w0,#0
 ret
.Lvolcanic_bad:
 mov w0,#2
 ret
.size md2asm_initialize_tegen_volcanic_values,.-md2asm_initialize_tegen_volcanic_values
.section .rodata
.p2align 3
.Lvolcanic_scale:.double 1e-4
.Lvolcanic_security:.double 1e-12
.Lvolcanic_latitudes:
#include "tegen_volcanic_latitudes.inc.S"
.Lvolcanic_assignments:
#include "tegen_volcanic_assignments.inc.S"
.section .note.GNU-stack,"",%progbits

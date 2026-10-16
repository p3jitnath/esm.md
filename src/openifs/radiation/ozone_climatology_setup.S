/* Contract: skills/md2asm/references/openifs/radiation/ozone_climatology_setup.md.
 * Complete serial SUECOZC data stage, receiving the original ECOZC file bytes.
 * x0 file bytes,x1 length,x2 TEOZOC33008,x3 capacity. Return0/1/2.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_ozone_climatology
.type md2asm_initialize_ozone_climatology,%function
md2asm_initialize_ozone_climatology:
 cbz x0,.Lozone_bad
 cbz x2,.Lozone_bad
 tst x2,#7
 b.ne .Lozone_bad
 mov x9,#62024
 cmp x1,x9
 b.ne .Lozone_bad
 mov x10,#33008
 cmp x3,x10
 b.lo .Lozone_bad
 adds x9,x0,x9
 b.cs .Lozone_bad
 adds x10,x2,x10
 b.cs .Lozone_bad
 cmp x0,x10
 b.hs .Lozone_disjoint
 cmp x2,x9
 b.lo .Lozone_bad
.Lozone_disjoint:
 ldr x9,[x2]
 cbnz x9,.Lozone_bad
 mov w10,#62016
 ldr w9,[x0]
 rev w9,w9
 cmp w9,w10
 b.ne .Lozone_bad
 mov x11,#62020
 ldr w9,[x0,x11]
 rev w9,w9
 cmp w9,w10
 b.ne .Lozone_bad
 sub sp,sp,#224
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 mov x29,sp
 mov x19,x2
 mov x20,x0
 mov x9,#0
 add x10,sp,#80
.Lozone_copy_preimage:
 ldr x11,[x19,x9]
 str x11,[x10,x9]
 add x9,x9,#8
 cmp x9,#112
 b.lo .Lozone_copy_preimage
 mov w9,#19
 mov w10,#34
 stp w9,w10,[sp,#192]
 mov w9,#12
 stp w9,wzr,[sp,#200]
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 add x0,sp,#80
 mov w1,#3
 add x2,sp,#192
 mov w3,#1
 mov w4,#0
 bl md2asm_allocate_radiation_flux_array
 cbnz w0,.Lozone_return
 ldr x23,[sp,#80]
 add x9,x20,#4
 mov x10,x23
 mov x11,#7752
.Lozone_decode:
 ldr x12,[x9],#8
 rev x12,x12
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lozone_decode
 adrp x9,.Lozone_pressure
 add x9,x9,:lo12:.Lozone_pressure
 mov x10,#32520
 add x10,x19,x10
 mov x11,#61
.Lozone_pressure_copy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lozone_pressure_copy
 mov x9,#0
 add x10,sp,#80
.Lozone_commit:
 ldr x11,[x10,x9]
 str x11,[x19,x9]
 add x9,x9,#8
 cmp x9,#112
 b.lo .Lozone_commit
 str w22,[x21]
 mov w0,#0
.Lozone_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#224
 ret
.size md2asm_initialize_ozone_climatology,.-md2asm_initialize_ozone_climatology
.p2align 4
.global md2asm_release_ozone_climatology
.type md2asm_release_ozone_climatology,%function
md2asm_release_ozone_climatology:
 cbz x0,.Lozone_bad
 tst x0,#7
 b.ne .Lozone_bad
 mov x9,#33008
 cmp x1,x9
 b.lo .Lozone_bad
 adds x9,x0,x9
 b.cs .Lozone_bad
 stp x29,x30,[sp,#-64]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x29,sp
 mov x19,x0
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 ldr x0,[x19]
 bl free
 str xzr,[x19]
 str w21,[x20]
 mov w0,#0
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_ozone_climatology,.-md2asm_release_ozone_climatology
.Lozone_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lozone_pressure:
#include "ozone_pressure_literals.inc.S"
.section .note.GNU-stack,"",%progbits

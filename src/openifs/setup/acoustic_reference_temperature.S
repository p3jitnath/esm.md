/* Complete SUALDYN SITRAM allocation and SUDYN acoustic-temperature update.
 * Contract skills/md2asm/references/openifs/dynamics/acoustic_reference_temperature.md.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity. */
.arch armv8.2-a
.text
.macro AADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_initialize_acoustic_reference_temperature
.type md2asm_initialize_acoustic_reference_temperature,%function
md2asm_initialize_acoustic_reference_temperature:
 cbz x0,.Lbad
 cbz x2,.Lbad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lbad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 AADDR x9,xzr,4275088
 cmp x3,x9
 b.lo .Lbad
 adds x11,x2,x9
 b.cs .Lbad
 cmp x10,x2
 b.ls .Ldisjoint
 cmp x11,x0
 b.hi .Lbad
.Ldisjoint:
 mrs x9,fpcr
 cbnz x9,.Lbad
 mov x9,#5224
 ldr w12,[x0,x9]
 sub w9,w12,#1
 cmp w9,#254
 b.hi .Lbad
 AADDR x9,x2,1568704
 ldr x9,[x9]
 cbnz x9,.Lbad
 AADDR x9,x2,1567120
 ldr x13,[x9]
 /* Positive finite SITRA, checked without changing floating-point status. */
 tbnz x13,#63,.Lbad
 cbz x13,.Lbad
 ubfx x9,x13,#52,#11
 cmp x9,#2047
 b.eq .Lbad
 AADDR x9,x2,1567184
 ldr w14,[x9]
 mov x15,#0
 cmp w14,#1
 b.ne .Lvalidated
 add x9,x0,#3464
 ldr x15,[x9]
 cbz x15,.Lbad
 tst x15,#7
 b.ne .Lbad
 ldr x4,[x9,#8]
 cmn x4,#1
 b.ne .Lbad
 ldr x4,[x9,#16]
 cmp x4,#8
 b.ne .Lbad
 ldr w4,[x9,#24]
 cbnz w4,.Lbad
 ldr w4,[x9,#28]
 cmp w4,#0x301
 b.ne .Lbad
 ldr x4,[x9,#32]
 cmp x4,#8
 b.ne .Lbad
 ldp x4,x5,[x9,#40]
 cmp x4,#1
 b.ne .Lbad
 cmp x5,#1
 b.ne .Lbad
 ldr x4,[x9,#56]
 cmp x4,x12
 b.ne .Lbad
 adds x5,x15,x12,lsl#3
 b.cs .Lbad
 cmp x5,x0
 b.ls .Ltemperature_model
 cmp x15,x10
 b.lo .Lbad
.Ltemperature_model:
 cmp x5,x2
 b.ls .Ltemperature_values
 cmp x15,x11
 b.lo .Lbad
.Ltemperature_values:
 mov x9,#0
.Lvalidate_temperature:
 ldr x4,[x15,x9,lsl#3]
 tbnz x4,#63,.Lbad
 cbz x4,.Lbad
 ubfx x5,x4,#52,#11
 cmp x5,#2047
 b.eq .Lbad
 add x9,x9,#1
 cmp x9,x12
 b.lo .Lvalidate_temperature
.Lvalidated:
 stp x18,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x2
 mov x20,x12
 mov x21,x15
 mov x22,#0
 mov x23,x13
 mov w24,w14
 lsl x0,x20,#3
 bl malloc
 cbz x0,.Lallocation_failure
 mov x22,x0
 mov x9,#0
 cmp w24,#1
 b.eq .Lscaled
.Lconstant:
 str x23,[x22,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x20
 b.lo .Lconstant
 b .Lpublish
.Lscaled:
 sub x10,x20,#1
 ldr d2,[x21,x10,lsl#3]
 fmov d1,x23
.Lscaled_loop:
 ldr d0,[x21,x9,lsl#3]
 fdiv d0,d0,d2
 fmul d0,d1,d0
 fmov x10,d0
 tbnz x10,#63,.Ldomain_failure
 cbz x10,.Ldomain_failure
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Ldomain_failure
 str d0,[x22,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x20
 b.lo .Lscaled_loop
.Lpublish:
 AADDR x9,x19,1568704
 str x22,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str wzr,[x9,#24]
 mov w11,#0x301
 str w11,[x9,#28]
 str x10,[x9,#32]
 mov x10,#1
 stp x10,x10,[x9,#40]
 str x20,[x9,#56]
 mov w0,#0
 b .Lreturn
.Ldomain_failure:
 mov x0,x22
 bl free
 mov w0,#2
 b .Lreturn
.Lallocation_failure:
 mov w0,#1
.Lreturn:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#64
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_initialize_acoustic_reference_temperature,.-md2asm_initialize_acoustic_reference_temperature
.p2align 4
.global md2asm_release_acoustic_reference_temperature
.type md2asm_release_acoustic_reference_temperature,%function
md2asm_release_acoustic_reference_temperature:
 cbz x0,.Lbad_release
 tst x0,#7
 b.ne .Lbad_release
 AADDR x9,xzr,4275088
 cmp x1,x9
 b.lo .Lbad_release
 adds x10,x0,x9
 b.cs .Lbad_release
 stp x18,x30,[sp,#-32]!
 stp x19,x20,[sp,#16]
 AADDR x19,x0,1568704
 ldr x0,[x19]
 cbz x0,.Lreleased
 bl free
 str xzr,[x19]
.Lreleased:
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#32
 ret
.Lbad_release:
 mov w0,#2
 ret
.size md2asm_release_acoustic_reference_temperature,.-md2asm_release_acoustic_reference_temperature
.section .note.GNU-stack,"",%progbits

/* Source SUDYN conditional stable-level controls and pressure count.
 * Contract: skills/md2asm/references/openifs/dynamics/stable_level_configuration.md.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity, x4 platform16.
 * Return w0 0/2. No external call, allocation or changed saved register. */
.arch armv8.2-a
.text
.p2align 4
.macro ADDR reg,base,offset
 mov x17,#(\offset&65535)
 movk x17,#(\offset>>16),lsl#16
 add \reg,\base,x17
.endm
.global md2asm_initialize_stable_level_configuration
.type md2asm_initialize_stable_level_configuration,%function
md2asm_initialize_stable_level_configuration:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 mov x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x3,x9
 b.lo .Lbad
 adds x9,x2,x9
 b.cs .Lbad
 adds x9,x4,#16
 b.cs .Lbad
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldp w9,w10,[x4,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x4]
 cmp w10,#1
 b.hi .Lbad
 mov w11,#0
 cmp w9,#1
 cset w12,eq
 orr w11,w11,w12
 cmp w9,#131
 cset w12,eq
 orr w11,w11,w12
 cmp w9,#302
 cset w12,eq
 orr w11,w11,w12
 cmp w9,#401
 cset w12,eq
 orr w11,w11,w12
 cmp w9,#501
 cset w12,eq
 orr w11,w11,w12
 cmp w9,#801
 cset w12,eq
 orr w11,w11,w12
 and w11,w11,w10
 ADDR x9,x2,1564160
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lbad
 and w11,w11,w10
 ADDR x9,x2,1359332
 ldr w10,[x9]
 cmp w10,#0
 cset w12,gt
 and w11,w11,w12
 mov x9,#5224
 ldr w12,[x0,x9]
 sub w9,w12,#1
 cmp w9,#254
 b.hi .Lbad
 mov w13,#0
 cbz w11,.Lcommit
 /* Typed half-level pressure view. Source consumes indices1..NFLEVG. */
 add x9,x0,#3272
 ldr x10,[x9]
 cbz x10,.Lbad
 tst x10,#7
 b.ne .Lbad
 ldr x14,[x9,#16]
 cmp x14,#8
 b.ne .Lbad
 ldrh w14,[x9,#28]
 cmp w14,#0x301
 b.ne .Lbad
 ldr x14,[x9,#32]
 cmp x14,#8
 b.ne .Lbad
 ldr x14,[x9,#8]
 cbnz x14,.Lbad
 ldr x14,[x9,#40]
 cmp x14,#1
 b.ne .Lbad
 ldr x14,[x9,#48]
 cbnz x14,.Lbad
 ldr x14,[x9,#56]
 cmp x14,x12
 b.ne .Lbad
 add x14,x12,#1
 lsl x14,x14,#3
 adds x14,x10,x14
 b.cs .Lbad
 mov w14,#1
.Lvalidate_pressures:
 ldr x15,[x10,w14,uxtw#3]
 and x16,x15,#0x7fffffffffffffff
 cbz x16,.Lpressure_valid
 tbnz x15,#63,.Lbad
 ubfx x16,x15,#52,#11
 cmp x16,#2047
 b.eq .Lbad
.Lpressure_valid:
 add w14,w14,#1
 cmp w14,w12
 b.le .Lvalidate_pressures
 movz x15,#0x7000,lsl#32
 movk x15,#0x40b7,lsl#48
 fmov d1,x15
 mov w14,#1
.Lcount:
 ldr d0,[x10,w14,uxtw#3]
 fcmp d0,d1
 cinc w13,w13,le
 add w14,w14,#1
 cmp w14,w12
 b.le .Lcount
 cmp w13,w12
 csel w13,w13,w12,le
.Lcommit:
 ADDR x9,x2,1568832
 str w11,[x9]
 ADDR x9,x2,1569072
 movz x15,#0x7000,lsl#32
 movk x15,#0x40b7,lsl#48
 str x15,[x9]
 ADDR x9,x2,1569088
 movz x15,#0
 movk x15,#0x1e90,lsl#16
 movk x15,#0xbcc4,lsl#32
 movk x15,#0x42d6,lsl#48
 str x15,[x9]
 ADDR x9,x2,1569096
 movz x15,#0x2b9b
 movk x15,#0x86a1,lsl#16
 movk x15,#0x849b,lsl#32
 movk x15,#0x3d06,lsl#48
 str x15,[x9]
 ADDR x9,x2,1568840
 str wzr,[x9]
 ADDR x9,x2,1569080
 str w13,[x9]
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_initialize_stable_level_configuration,.-md2asm_initialize_stable_level_configuration
.section .note.GNU-stack,"",%progbits

/* Complete selected SUCOTWO and SUFARQUHAR parent. Contract: skills/md2asm/references/openifs/setup/photosynthesis_parameter_setup.md. */
.arch armv8.2-a
.text
.p2align 4
.macro PENTER bytes
 sub sp,sp,#\bytes
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
.endm
.macro PLEAVE bytes
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#\bytes
 ret
.endm
.macro PCALL name
 bl \name
 ldr x18,[x29,#96]
.endm
.macro RANGE ptr,bytes,slot,bad
 cbz \ptr,\bad
 tst \ptr,#7
 b.ne \bad
 adds x9,\ptr,#\bytes
 b.cs \bad
 stp \ptr,x9,[sp,#128+16*\slot]
.endm

.global md2asm_initialize_photosynthesis_parameters
.type md2asm_initialize_photosynthesis_parameters,%function
md2asm_initialize_photosynthesis_parameters:
 PENTER 3952
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 RANGE x19,128,0,.Lphoto_bad
 RANGE x20,776,1,.Lphoto_bad
 RANGE x21,1368,2,.Lphoto_bad
 RANGE x22,32,3,.Lphoto_bad
 ldp x23,x9,[x22]
 cmp x9,#2344
 b.lo .Lphoto_bad
 ldp x24,x9,[x22,#16]
 cmp x9,#1472
 b.lo .Lphoto_bad
 RANGE x23,2344,4,.Lphoto_bad
 RANGE x24,1472,5,.Lphoto_bad
 mrs x9,fpcr
 cbnz x9,.Lphoto_bad
 ldr w9,[x20]
 cmp w9,#20
 b.ne .Lphoto_bad
 ldr x9,[x19,#8]
 ldr x10,=0x4008000000000000
 cmp x9,x10
 b.lo .Lphoto_bad
 ldr x10,=0x4010000000000000
 cmp x9,x10
 b.hi .Lphoto_bad
 ldr x9,[x19,#16]
 ldr x10,=0x40e5180000000000
 cmp x9,x10
 b.eq .Lphoto_day_ok
 ldr x10,=0x40f5180000000000
 cmp x9,x10
 b.eq .Lphoto_day_ok
 ldr x10,=0x4105180000000000
 cmp x9,x10
 b.eq .Lphoto_day_ok
 b .Lphoto_bad
.Lphoto_day_ok:
 add x26,x21,#0
 ldr x25,[x26]
 RANGE x25,320,6,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#88
 ldr x25,[x26]
 RANGE x25,320,7,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#176
 ldr x25,[x26]
 RANGE x25,320,8,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#264
 ldr x25,[x26]
 RANGE x25,320,9,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#352
 ldr x25,[x26]
 RANGE x25,320,10,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#440
 ldr x25,[x26]
 RANGE x25,320,11,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#528
 ldr x25,[x26]
 RANGE x25,320,12,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#616
 ldr x25,[x26]
 RANGE x25,320,13,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad
 add x26,x21,#704
 ldr x25,[x26]
 RANGE x25,320,14,.Lphoto_bad
 ldr x9,[x26,#8]
 ldr x10,=-21
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#16]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#24]
 ldr x10,=3307124817920
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#32]
 ldr x10,=8
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#40]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#48]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#56]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#64]
 ldr x10,=20
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#72]
 ldr x10,=1
 cmp x9,x10
 b.ne .Lphoto_bad
 ldr x9,[x26,#80]
 ldr x10,=2
 cmp x9,x10
 b.ne .Lphoto_bad

 // All six record views and nine consumed arrays are distinct owned ranges.
 add x10,sp,#128
 mov x11,#0
.Lphoto_range_outer:
 ldp x12,x13,[x10]
 add x14,x10,#16
 add x15,x11,#1
.Lphoto_range_inner:
 cmp x15,#15
 b.hs .Lphoto_range_next
 ldp x16,x17,[x14]
 cmp x12,x17
 b.hs .Lphoto_range_disjoint
 cmp x16,x13
 b.lo .Lphoto_bad
.Lphoto_range_disjoint:
 add x14,x14,#16
 add x15,x15,#1
 b .Lphoto_range_inner
.Lphoto_range_next:
 add x10,x10,#16
 add x11,x11,#1
 cmp x11,#14
 b.lo .Lphoto_range_outer
 add x10,x23,#1296
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1360
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1424
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1488
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1552
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1616
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1680
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1744
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1808
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1872
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1936
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2000
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2280
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2064
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2128
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2216
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#336
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#400
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#464
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#528
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#592
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#656
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#720
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#784
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#848
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#912
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#976
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1040
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1104
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1168
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1232
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#384
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#472
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#560
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#648
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#736
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#824
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#912
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#1000
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#1088
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#1176
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lphoto_bad
 subs x11,x11,#1
 b.ne 1b

 PCALL __errno_location
 str x0,[sp,#104]
 ldr w9,[x0]
 str w9,[sp,#112]
 mov x0,x23
 add x1,sp,#128
 mov x2,#2344
 bl .Lphoto_copy
 mov x0,x24
 add x1,sp,#2472
 mov x2,#1472
 bl .Lphoto_copy
 adr x23,.Lphoto_owner_plan
 mov x24,#41
.Lphoto_allocate:
 ldr x9,[x23]
 add x25,sp,x9
 ldr x0,[x23,#8]
 PCALL malloc
 cbz x0,.Lphoto_allocation_failure
 str x0,[x25]
 add x10,x23,#16
 add x11,x25,#8
 ldrb w12,[x23,#36]
 cmp w12,#2
 mov x12,#7
 mov x13,#10
 csel x12,x13,x12,eq
.Lphoto_descriptor:
 ldr x9,[x10],#8
 str x9,[x11],#8
 subs x12,x12,#1
 b.ne .Lphoto_descriptor
 add x23,x23,#96
 subs x24,x24,#1
 b.ne .Lphoto_allocate
 ldr x9,[sp,#104]
 ldr w10,[sp,#112]
 str w10,[x9]
 add x0,sp,#128
 mov x1,x19
 mov x2,x21
 bl md2asm_carbon_assimilation_parameter_fields
 add x0,sp,#2472
 mov x1,x21
 bl md2asm_farquhar_parameter_fields
 add x0,sp,#128
 ldr x1,[x22]
 mov x2,#2344
 bl .Lphoto_copy
 add x0,sp,#2472
 ldr x1,[x22,#16]
 mov x2,#1472
 bl .Lphoto_copy
 mov w0,#0
 b .Lphoto_return
.Lphoto_allocation_failure:
 adr x23,.Lphoto_owner_plan
 mov x24,#41
.Lphoto_failed_free:
 ldr x9,[x23]
 add x25,sp,x9
 ldr x0,[x25]
 cbz x0,.Lphoto_failed_next
 PCALL free
.Lphoto_failed_next:
 add x23,x23,#96
 subs x24,x24,#1
 b.ne .Lphoto_failed_free
 mov w0,#1
.Lphoto_status:
 ldr x9,[sp,#104]
 ldr w10,[sp,#112]
 str w10,[x9]
.Lphoto_return:
 PLEAVE 3952
.Lphoto_bad:
 mov w0,#2
 PLEAVE 3952
.size md2asm_initialize_photosynthesis_parameters,.-md2asm_initialize_photosynthesis_parameters
.Lphoto_copy:
 ldr x9,[x0],#8
 str x9,[x1],#8
 subs x2,x2,#8
 b.ne .Lphoto_copy
 ret
.global md2asm_release_photosynthesis_parameters
.type md2asm_release_photosynthesis_parameters,%function
md2asm_release_photosynthesis_parameters:
 PENTER 256
 mov x19,x0
 RANGE x19,32,0,.Lphoto_release_bad
 ldp x20,x9,[x19]
 cmp x9,#2344
 b.lo .Lphoto_release_bad
 ldp x21,x9,[x19,#16]
 cmp x9,#1472
 b.lo .Lphoto_release_bad
 RANGE x20,2344,1,.Lphoto_release_bad
 RANGE x21,1472,2,.Lphoto_release_bad
 ldp x9,x10,[sp,#128]
 ldp x11,x12,[sp,#144]
 cmp x9,x12
 b.hs 1f
 cmp x11,x10
 b.lo .Lphoto_release_bad
1: ldp x13,x14,[sp,#160]
 cmp x9,x14
 b.hs 2f
 cmp x13,x10
 b.lo .Lphoto_release_bad
2: cmp x11,x14
 b.hs 3f
 cmp x13,x12
 b.lo .Lphoto_release_bad
3: PCALL __errno_location
 str x0,[sp,#104]
 ldr w9,[x0]
 str w9,[sp,#112]
 adr x23,.Lphoto_release_plan
 mov x24,#41
.Lphoto_release_next:
 ldp x9,x10,[x23]
 ldr x25,[x19,x9]
 add x25,x25,x10
 ldr x0,[x25]
 cbz x0,.Lphoto_release_continue
 str xzr,[x25]
 PCALL free
.Lphoto_release_continue:
 add x23,x23,#16
 subs x24,x24,#1
 b.ne .Lphoto_release_next
 ldr x9,[sp,#104]
 ldr w10,[sp,#112]
 str w10,[x9]
 mov w0,#0
 PLEAVE 256
.Lphoto_release_bad:
 mov w0,#2
 PLEAVE 256
.size md2asm_release_photosynthesis_parameters,.-md2asm_release_photosynthesis_parameters
.section .rodata
.p2align 3
.Lphoto_owner_plan:
/* TAGS%LVSTRESS */
.quad 1424,84,0,4,2203318222848,4,1,0,20,0,0,0
/* TAGS%RVBSLAI */
.quad 1488,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVLAIMIN */
.quad 1552,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVSEFOLD */
.quad 1616,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVGMES */
.quad 1680,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVGC */
.quad 1744,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVDMAX */
.quad 1808,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVF2I */
.quad 1872,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVCE */
.quad 1936,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVCF */
.quad 2000,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVCNA */
.quad 2064,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVBSLAI_NITRO */
.quad 2128,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVANMAX */
.quad 2408,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RXBOMEGAM */
.quad 2192,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVR0VT */
.quad 2256,336,-21,8,3307124817920,8,1,0,20,21,1,2
/* TAGS%RVCH4QVT */
.quad 2344,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVTOPT */
.quad 464,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVFZERO */
.quad 528,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVFZEROST */
.quad 592,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVEPSO */
.quad 656,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVGAMM */
.quad 720,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVQDGAMM */
.quad 784,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVQDGMES */
.quad 848,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVT1GMES */
.quad 912,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVT2GMES */
.quad 976,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVAMMAX */
.quad 1040,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVQDAMMAX */
.quad 1104,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVT1AMMAX */
.quad 1168,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVT2AMMAX */
.quad 1232,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVAH */
.quad 1296,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGS%RVBH */
.quad 1360,168,0,8,3302829850624,8,1,0,20,0,0,0
/* TAGF%RVCMAX25 */
.quad 2856,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RHUMREL */
.quad 2944,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RA1 */
.quad 3032,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RB1 */
.quad 3120,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RG0 */
.quad 3208,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RGM25 */
.quad 3296,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RE_VCMAX */
.quad 3384,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RE_JMAX */
.quad 3472,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RDOWNREGULATION_CO2_COEF */
.quad 3560,320,-21,8,3307124817920,8,1,1,20,20,1,2
/* TAGF%RSTRUCT_CONST */
.quad 3648,320,-21,8,3307124817920,8,1,1,20,20,1,2
.Lphoto_release_plan:
.quad 0,1296
.quad 0,1360
.quad 0,1424
.quad 0,1488
.quad 0,1552
.quad 0,1616
.quad 0,1680
.quad 0,1744
.quad 0,1808
.quad 0,1872
.quad 0,1936
.quad 0,2000
.quad 0,2280
.quad 0,2064
.quad 0,2128
.quad 0,2216
.quad 0,336
.quad 0,400
.quad 0,464
.quad 0,528
.quad 0,592
.quad 0,656
.quad 0,720
.quad 0,784
.quad 0,848
.quad 0,912
.quad 0,976
.quad 0,1040
.quad 0,1104
.quad 0,1168
.quad 0,1232
.quad 16,384
.quad 16,472
.quad 16,560
.quad 16,648
.quad 16,736
.quad 16,824
.quad 16,912
.quad 16,1000
.quad 16,1088
.quad 16,1176
.section .note.GNU-stack,"",%progbits

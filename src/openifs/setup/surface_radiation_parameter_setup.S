/* Contract: skills/md2asm/references/openifs/setup/surface_radiation_parameter_setup.md. */
/* Complete selected SUSRAD and SURWN parent. See the frozen contract for explicit upstream controls. */
.text
.p2align 2
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

.global md2asm_initialize_selected_surface_radiation_parameters
.type md2asm_initialize_selected_surface_radiation_parameters,%function
md2asm_initialize_selected_surface_radiation_parameters:
 PENTER 2112
 mov x19,x0
 mov x20,x1
 mov x21,x2
 RANGE x19,456,0,.Lparent_bad
 RANGE x20,16,1,.Lparent_bad
 RANGE x21,64,2,.Lparent_bad
 ldp x24,x10,[x21,#0]
 cmp x10,#48
 b.lo .Lparent_bad
 RANGE x24,48,3,.Lparent_bad
 ldp x24,x10,[x21,#16]
 cmp x10,#1256
 b.lo .Lparent_bad
 RANGE x24,1256,4,.Lparent_bad
 ldp x24,x10,[x21,#32]
 cmp x10,#304
 b.lo .Lparent_bad
 RANGE x24,304,5,.Lparent_bad
 ldp x24,x10,[x21,#48]
 cmp x10,#240
 b.lo .Lparent_bad
 RANGE x24,240,6,.Lparent_bad
 add x10,sp,#128
 mov x11,#0
.Lrange_outer:
 ldp x12,x13,[x10]
 add x14,x10,#16
 add x15,x11,#1
.Lrange_inner:
 cmp x15,#7
 b.hs .Lrange_next
 ldp x16,x17,[x14]
 cmp x12,x17
 b.hs .Lrange_disjoint
 cmp x16,x13
 b.lo .Lparent_bad
.Lrange_disjoint:
 add x14,x14,#16
 add x15,x15,#1
 b .Lrange_inner
.Lrange_next:
 add x10,x10,#16
 add x11,x11,#1
 cmp x11,#6
 b.lo .Lrange_outer
 mrs x9,fpcr
 cbnz x9,.Lparent_bad
 ldr w9,[x20,#8]
 cmp w9,#12
 b.ne .Lparent_bad
 ldr x9,[x19,#0]
 ldr x10,=0x0000000e00000006
 cmp x9,x10
 b.ne .Lparent_bad
 ldr x9,[x19,#8]
 ldr x10,=0x0000000200000006
 cmp x9,x10
 b.ne .Lparent_bad
 ldr x9,[x19,#16]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lparent_bad
 ldr x9,[x19,#24]
 ldr x10,=0x0000000100000001
 cmp x9,x10
 b.ne .Lparent_bad
 ldr x9,[x21,#48]
 mov x10,#30
.Lfresh:
 ldr x11,[x9],#8
 cbnz x11,.Lparent_bad
 subs x10,x10,#1
 b.ne .Lfresh
 ldr x9,[x21,#0]
 add x10,sp,#256
 mov x11,#6
.Lcopyin0:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcopyin0
 ldr x9,[x21,#16]
 add x10,sp,#304
 mov x11,#157
.Lcopyin1:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcopyin1
 ldr x9,[x21,#32]
 add x10,sp,#1560
 mov x11,#38
.Lcopyin2:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcopyin2
 ldr x9,[x21,#48]
 add x10,sp,#1864
 mov x11,#30
.Lcopyin3:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcopyin3
 PCALL __errno_location
 mov x22,x0
 ldr w23,[x22]
 mov x0,#1344
 PCALL malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#1928]
 ldr x9,=0xfffffffffffffff3
 str x9,[sp,#1936]
 ldr x9,=0x0000000000000008
 str x9,[sp,#1944]
 ldr x9,=0x0000030200000000
 str x9,[sp,#1952]
 ldr x9,=0x0000000000000008
 str x9,[sp,#1960]
 ldr x9,=0x0000000000000001
 str x9,[sp,#1968]
 ldr x9,=0x0000000000000001
 str x9,[sp,#1976]
 ldr x9,=0x000000000000000c
 str x9,[sp,#1984]
 ldr x9,=0x000000000000000c
 str x9,[sp,#1992]
 ldr x9,=0x0000000000000001
 str x9,[sp,#2000]
 ldr x9,=0x000000000000000e
 str x9,[sp,#2008]
 mov x0,#1344
 PCALL malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#2016]
 ldr x9,=0xfffffffffffffff3
 str x9,[sp,#2024]
 ldr x9,=0x0000000000000008
 str x9,[sp,#2032]
 ldr x9,=0x0000030200000000
 str x9,[sp,#2040]
 ldr x9,=0x0000000000000008
 str x9,[sp,#2048]
 ldr x9,=0x0000000000000001
 str x9,[sp,#2056]
 ldr x9,=0x0000000000000001
 str x9,[sp,#2064]
 ldr x9,=0x000000000000000c
 str x9,[sp,#2072]
 ldr x9,=0x000000000000000c
 str x9,[sp,#2080]
 ldr x9,=0x0000000000000001
 str x9,[sp,#2088]
 ldr x9,=0x000000000000000e
 str x9,[sp,#2096]
 mov x0,#112
 PCALL malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#1864]
 ldr x9,=0xffffffffffffffff
 str x9,[sp,#1872]
 ldr x9,=0x0000000000000008
 str x9,[sp,#1880]
 ldr x9,=0x0000030100000000
 str x9,[sp,#1888]
 ldr x9,=0x0000000000000008
 str x9,[sp,#1896]
 ldr x9,=0x0000000000000001
 str x9,[sp,#1904]
 ldr x9,=0x0000000000000001
 str x9,[sp,#1912]
 ldr x9,=0x000000000000000e
 str x9,[sp,#1920]
 str w23,[x22]
 mov x0,x19
 add x1,sp,#256
 add x2,sp,#304
 add x3,sp,#1560
 add x4,sp,#1864
 PCALL md2asm_surface_radiation_parameter_fields
 ldr x9,[x21,#0]
 add x10,sp,#256
 mov x11,#6
.Lcopyout0:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lcopyout0
 ldr x9,[x21,#16]
 add x10,sp,#304
 mov x11,#157
.Lcopyout1:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lcopyout1
 ldr x9,[x21,#32]
 add x10,sp,#1560
 mov x11,#38
.Lcopyout2:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lcopyout2
 ldr x9,[x21,#48]
 add x10,sp,#1864
 mov x11,#30
.Lcopyout3:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lcopyout3
 mov w0,#0
 PLEAVE 2112
.Lallocation_failed:
 ldr x0,[sp,#1928]
 cbz x0,.Lfailure_next0
 PCALL free
.Lfailure_next0:
 ldr x0,[sp,#2016]
 cbz x0,.Lfailure_next1
 PCALL free
.Lfailure_next1:
 ldr x0,[sp,#1864]
 cbz x0,.Lfailure_next2
 PCALL free
.Lfailure_next2:
 str w23,[x22]
 mov w0,#1
 PLEAVE 2112
.Lparent_bad:
 mov w0,#2
 PLEAVE 2112
.size md2asm_initialize_selected_surface_radiation_parameters,.-md2asm_initialize_selected_surface_radiation_parameters
.global md2asm_release_surface_radiation_parameters
.type md2asm_release_surface_radiation_parameters,%function
md2asm_release_surface_radiation_parameters:
 PENTER 160
 mov x19,x0
 cbz x19,.Lrelease_bad
 tst x19,#7
 b.ne .Lrelease_bad
 adds x9,x19,#64
 b.cs .Lrelease_bad
 ldp x20,x10,[x19,#48]
 cmp x10,#240
 b.lo .Lrelease_bad
 cbz x20,.Lrelease_bad
 tst x20,#7
 b.ne .Lrelease_bad
 adds x10,x20,#240
 b.cs .Lrelease_bad
 cmp x19,x10
 b.hs .Lrelease_disjoint
 cmp x20,x9
 b.lo .Lrelease_bad
.Lrelease_disjoint:
 PCALL __errno_location
 mov x21,x0
 ldr w22,[x21]
 ldr x0,[x20,#64]
 cbz x0,.Lrelease_next0
 PCALL free
 str xzr,[x20,#64]
.Lrelease_next0:
 ldr x0,[x20,#152]
 cbz x0,.Lrelease_next1
 PCALL free
 str xzr,[x20,#152]
.Lrelease_next1:
 ldr x0,[x20,#0]
 cbz x0,.Lrelease_next2
 PCALL free
 str xzr,[x20,#0]
.Lrelease_next2:
 str w22,[x21]
 mov w0,#0
 PLEAVE 160
.Lrelease_bad:
 mov w0,#2
 PLEAVE 160
.size md2asm_release_surface_radiation_parameters,.-md2asm_release_surface_radiation_parameters
.ltorg
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/surface_land_parameters.md.
 * Complete selected SUSSOIL, SUSVEG and SUVEXC parent.
 * x0 controls136,x1 TCST128,x2 TDIM16,x3 records48; return0/1/2. */
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
.macro POSITIVE_RANGE offset,lo,hi
 ldr x9,[x20,#\offset]
 ldr x10,=\lo
 cmp x9,x10
 b.lo .Lparent_bad
 ldr x10,=\hi
 cmp x9,x10
 b.hi .Lparent_bad
.endm
.global md2asm_initialize_surface_land_parameters
.type md2asm_initialize_surface_land_parameters,%function
md2asm_initialize_surface_land_parameters:
 PENTER 3472
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 RANGE x19,136,0,.Lparent_bad
 RANGE x20,128,1,.Lparent_bad
 RANGE x21,16,2,.Lparent_bad
 RANGE x22,48,3,.Lparent_bad
 ldp x23,x9,[x22]
 cmp x9,#2416
 b.lo .Lparent_bad
 ldp x24,x9,[x22,#16]
 cmp x9,#776
 b.lo .Lparent_bad
 ldp x25,x9,[x22,#32]
 cmp x9,#144
 b.lo .Lparent_bad
 RANGE x23,2416,4,.Lparent_bad
 RANGE x24,776,5,.Lparent_bad
 RANGE x25,144,6,.Lparent_bad
 // Check all seven bounded views before any external call or caller write.
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
 ldp x9,x10,[x21]
 ldr x11,=0x0000000900000004
 cmp x9,x11
 b.ne .Lparent_bad
 ldr x11,=0x000000050000000c
 cmp x10,x11
 b.ne .Lparent_bad
 mov x9,#0
.Lcontrol_flags:
 cmp x9,#16
 b.eq .Lcontrol_snow_count
 ldr w10,[x19,x9]
 cmp w10,#1
 b.hi .Lparent_bad
 b .Lcontrol_next
.Lcontrol_snow_count:
 ldr w10,[x19,x9]
 sub w10,w10,#1
 cmp w10,#2
 b.hi .Lparent_bad
.Lcontrol_next:
 add x9,x9,#4
 cmp x9,#76
 b.lo .Lcontrol_flags
 mov x9,#80
 ldr x11,=0x3ff0000000000000
.Lunit_controls:
 ldr x10,[x19,x9]
 and x12,x10,#0x7fffffffffffffff
 cbz x12,.Lunit_next
 cmp x10,x11
 b.hi .Lparent_bad
.Lunit_next:
 add x9,x9,#8
 cmp x9,#112
 b.lo .Lunit_controls
 ldr x9,[x19,#128]
 ldr x10,=0x3fe0000000000000
 cmp x9,x10
 b.eq .Lgravity_ok
 ldr x10,=0x3ff0000000000000
 cmp x9,x10
 b.eq .Lgravity_ok
 ldr x10,=0x4000000000000000
 cmp x9,x10
 b.ne .Lparent_bad
.Lgravity_ok:
 POSITIVE_RANGE 0,0x4069000000000000,0x4075e00000000000
 POSITIVE_RANGE 8,0x4008000000000000,0x4010000000000000
 POSITIVE_RANGE 48,0,0x4000000000000000

 add x10,x23,#1584
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1648
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1712
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#496
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#560
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#624
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#688
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#752
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#816
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#880
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#944
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1008
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1072
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1136
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1200
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1264
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1328
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1392
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1456
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1520
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#1896
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2120
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2184
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2248
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x23,#2312
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#8
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#72
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#136
 mov x11,#11
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#224
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#288
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#352
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#416
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#480
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#568
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b
 add x10,x24,#632
 mov x11,#8
1: ldr x9,[x10],#8
 cbnz x9,.Lparent_bad
 subs x11,x11,#1
 b.ne 1b

 PCALL __errno_location
 str x0,[sp,#104]
 ldr w9,[x0]
 str w9,[sp,#112]
 // The private outer records retain every source-unwritten scalar and padding byte.
 mov x0,x23
 add x1,sp,#128
 mov x2,#2416
 bl .Lcopy_words
 mov x0,x24
 add x1,sp,#2544
 mov x2,#776
 bl .Lcopy_words
 mov x0,x25
 add x1,sp,#3320
 mov x2,#144
 bl .Lcopy_words
 adr x23,.Lallocation_plan
 mov x24,#35
.Lallocate_next:
 ldr x9,[x23]
 add x25,sp,x9
 ldr x0,[x23,#8]
 PCALL malloc
 cbz x0,.Lallocation_failed
 str x0,[x25]
 ldr x9,[x23,#16]
 str x9,[x25,#8]
 mov x9,#8
 str x9,[x25,#16]
 ldr x10,[x23,#24]
 str x10,[x25,#24]
 str x9,[x25,#32]
 mov x9,#1
 str x9,[x25,#40]
 ldp x9,x10,[x23,#32]
 stp x9,x10,[x25,#48]
 ldrb w9,[x23,#28]
 cmp w9,#2
 b.ne .Lallocated_descriptor
 mov x9,#4
 str x9,[x25,#64]
 ldp x9,x10,[x23,#48]
 stp x9,x10,[x25,#72]
.Lallocated_descriptor:
 add x23,x23,#64
 subs x24,x24,#1
 b.ne .Lallocate_next
 add x0,sp,#128
 mov x1,x20
 mov x2,x19
 bl md2asm_soil_parameter_fields
 add x0,sp,#2544
 add x1,sp,#128
 mov x2,x20
 mov x3,x21
 mov x4,x19
 bl md2asm_vegetation_parameter_fields
 add x0,sp,#3320
 mov x1,x19
 bl md2asm_surface_exchange_parameter_fields
 add x0,sp,#128
 ldr x1,[x22]
 mov x2,#2416
 bl .Lcopy_words
 add x0,sp,#2544
 ldr x1,[x22,#16]
 mov x2,#776
 bl .Lcopy_words
 add x0,sp,#3320
 ldr x1,[x22,#32]
 mov x2,#144
 bl .Lcopy_words
 mov w0,#0
 b .Lparent_status
.Lallocation_failed:
 adr x23,.Lallocation_plan
 mov x24,#35
.Lfailed_free:
 ldr x9,[x23]
 add x25,sp,x9
 ldr x0,[x25]
 cbz x0,.Lfailed_next
 PCALL free
.Lfailed_next:
 add x23,x23,#64
 subs x24,x24,#1
 b.ne .Lfailed_free
 mov w0,#1
.Lparent_status:
 ldr x9,[sp,#104]
 ldr w10,[sp,#112]
 str w10,[x9]
 PLEAVE 3472
.Lparent_bad:
 mov w0,#2
 PLEAVE 3472
.size md2asm_initialize_surface_land_parameters,.-md2asm_initialize_surface_land_parameters
.Lcopy_words:
 ldr x9,[x0],#8
 str x9,[x1],#8
 subs x2,x2,#8
 b.ne .Lcopy_words
 ret
.global md2asm_release_surface_land_parameters
.type md2asm_release_surface_land_parameters,%function
md2asm_release_surface_land_parameters:
 PENTER 256
 mov x19,x0
 RANGE x19,48,0,.Lrelease_bad
 ldp x20,x9,[x19]
 cmp x9,#2416
 b.lo .Lrelease_bad
 ldp x21,x9,[x19,#16]
 cmp x9,#776
 b.lo .Lrelease_bad
 ldp x22,x9,[x19,#32]
 cmp x9,#144
 b.lo .Lrelease_bad
 RANGE x20,2416,1,.Lrelease_bad
 RANGE x21,776,2,.Lrelease_bad
 RANGE x22,144,3,.Lrelease_bad
 add x10,sp,#128
 mov x11,#0
.Lrelease_range_outer:
 ldp x12,x13,[x10]
 add x14,x10,#16
 add x15,x11,#1
.Lrelease_range_inner:
 cmp x15,#4
 b.hs .Lrelease_range_next
 ldp x16,x17,[x14]
 cmp x12,x17
 b.hs .Lrelease_range_disjoint
 cmp x16,x13
 b.lo .Lrelease_bad
.Lrelease_range_disjoint:
 add x14,x14,#16
 add x15,x15,#1
 b .Lrelease_range_inner
.Lrelease_range_next:
 add x10,x10,#16
 add x11,x11,#1
 cmp x11,#3
 b.lo .Lrelease_range_outer
 PCALL __errno_location
 str x0,[sp,#104]
 ldr w9,[x0]
 str w9,[sp,#112]
 adr x23,.Lrelease_plan
 mov x24,#35
.Lrelease_next:
 ldp x9,x10,[x23]
 ldr x25,[x19,x9]
 add x25,x25,x10
 ldr x0,[x25]
 cbz x0,.Lrelease_continue
 str xzr,[x25]
 PCALL free
.Lrelease_continue:
 add x23,x23,#16
 subs x24,x24,#1
 b.ne .Lrelease_next
 ldr x9,[sp,#104]
 ldr w10,[sp,#112]
 str w10,[x9]
 mov w0,#0
 PLEAVE 256
.Lrelease_bad:
 mov w0,#2
 PLEAVE 256
.size md2asm_release_surface_land_parameters,.-md2asm_release_surface_land_parameters
.section .rodata
.p2align 3
.Lallocation_plan:

/* TSOIL%RDAT */
.quad 1712,32,-1,3302829850624,1,4,0,0
/* TSOIL%RDAW */
.quad 1776,32,-1,3302829850624,1,4,0,0
/* TSOIL%RDAI */
.quad 1840,32,-1,3302829850624,1,4,0,0
/* TSOIL%RCWPSISM */
.quad 624,64,0,3302829850624,0,7,0,0
/* TSOIL%RMVGALPHA */
.quad 688,64,0,3302829850624,0,7,0,0
/* TSOIL%RWCONSM */
.quad 752,64,0,3302829850624,0,7,0,0
/* TSOIL%RMFACM */
.quad 816,64,0,3302829850624,0,7,0,0
/* TSOIL%RNFACM */
.quad 880,64,0,3302829850624,0,7,0,0
/* TSOIL%RLAMBDAM */
.quad 944,64,0,3302829850624,0,7,0,0
/* TSOIL%RWSATM */
.quad 1008,64,0,3302829850624,0,7,0,0
/* TSOIL%RWCAPM */
.quad 1072,64,0,3302829850624,0,7,0,0
/* TSOIL%RWPWPM */
.quad 1136,64,0,3302829850624,0,7,0,0
/* TSOIL%RWRESTM */
.quad 1200,64,0,3302829850624,0,7,0,0
/* TSOIL%RDMAXM */
.quad 1264,64,0,3302829850624,0,7,0,0
/* TSOIL%RDMINM */
.quad 1328,64,0,3302829850624,0,7,0,0
/* TSOIL%RQWEVAPM */
.quad 1392,64,0,3302829850624,0,7,0,0
/* TSOIL%RQWSBCRM */
.quad 1456,64,0,3302829850624,0,7,0,0
/* TSOIL%RLAMBDADRYM */
.quad 1520,56,-1,3302829850624,1,7,0,0
/* TSOIL%RLAMSAT1M */
.quad 1584,56,-1,3302829850624,1,7,0,0
/* TSOIL%RRCSOILM */
.quad 1648,56,-1,3302829850624,1,7,0,0
/* TSOIL%RSNDTDESTC_ML */
.quad 2024,40,-1,3302829850624,1,5,0,0
/* TSOIL%RLEVSNMIN */
.quad 2248,40,-1,3302829850624,1,5,0,0
/* TSOIL%RLEVSNMAX */
.quad 2312,40,-1,3302829850624,1,5,0,0
/* TSOIL%RLEVSNMIN_GL */
.quad 2376,40,-1,3302829850624,1,5,0,0
/* TSOIL%RLEVSNMAX_GL */
.quad 2440,40,-1,3302829850624,1,5,0,0
/* TVEG%RVCOV */
.quad 2552,168,0,3302829850624,0,20,0,0
/* TVEG%RVLAI */
.quad 2616,168,0,3302829850624,0,20,0,0
/* TVEG%RVROOTSA */
.quad 2680,672,-1,3307124817920,1,4,0,20
/* TVEG%RVLAMSK */
.quad 2768,168,0,3302829850624,0,20,0,0
/* TVEG%RVLAMSKS */
.quad 2832,168,0,3302829850624,0,20,0,0
/* TVEG%RVTRSR */
.quad 2896,168,0,3302829850624,0,20,0,0
/* TVEG%RVZ0M */
.quad 2960,168,0,3302829850624,0,20,0,0
/* TVEG%RVZ0H */
.quad 3024,168,0,3302829850624,0,20,0,0
/* TVEG%RVRSMIN */
.quad 3112,168,0,3302829850624,0,20,0,0
/* TVEG%RVHSTR */
.quad 3176,168,0,3302829850624,0,20,0,0
.Lrelease_plan:
.quad 0,1584
.quad 0,1648
.quad 0,1712
.quad 0,496
.quad 0,560
.quad 0,624
.quad 0,688
.quad 0,752
.quad 0,816
.quad 0,880
.quad 0,944
.quad 0,1008
.quad 0,1072
.quad 0,1136
.quad 0,1200
.quad 0,1264
.quad 0,1328
.quad 0,1392
.quad 0,1456
.quad 0,1520
.quad 0,1896
.quad 0,2120
.quad 0,2184
.quad 0,2248
.quad 0,2312
.quad 16,8
.quad 16,72
.quad 16,136
.quad 16,224
.quad 16,288
.quad 16,352
.quad 16,416
.quad 16,480
.quad 16,568
.quad 16,632
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/complete_surface_parameter_setup.md. */
/* Complete selected SUSURF and SUSURF_CTL parent. See the frozen contract for explicit upstream controls. */
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

/* Complete selected SUSURF/SUSURF_CTL. Contract frozen before emission. */
.macro SADDR reg,name
 mov \reg,#SURFACE_\name
 add \reg,x24,\reg
.endm
.equ SURFACE_TAGS,0
.equ SURFACE_TAGF,2344
.equ SURFACE_TCST,3816
.equ SURFACE_TDIM,3944
.equ SURFACE_TEXC,3960
.equ SURFACE_TFLAKE,4104
.equ SURFACE_TLW,4960
.equ SURFACE_TMLM,5264
.equ SURFACE_TOCEAN_ML,5640
.equ SURFACE_TRAD,6376
.equ SURFACE_TRDI,6424
.equ SURFACE_TSOIL,7680
.equ SURFACE_TSW,10096
.equ SURFACE_TVEG,10336
.equ SURFACE_TURB,11112
.global md2asm_create_selected_surface_parameters
.type md2asm_create_selected_surface_parameters,%function
md2asm_create_selected_surface_parameters:
 PENTER 1536
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 RANGE x19,184,0,.Lsurface_bad
 RANGE x20,456,1,.Lsurface_bad
 RANGE x21,1368,2,.Lsurface_bad
 RANGE x22,1016,3,.Lsurface_bad
 RANGE x23,16,4,.Lsurface_bad
 add x27,x21,#0
 ldr x24,[x27]
 RANGE x24,320,5,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#88
 ldr x24,[x27]
 RANGE x24,320,6,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#176
 ldr x24,[x27]
 RANGE x24,320,7,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#264
 ldr x24,[x27]
 RANGE x24,320,8,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#352
 ldr x24,[x27]
 RANGE x24,320,9,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#440
 ldr x24,[x27]
 RANGE x24,320,10,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#528
 ldr x24,[x27]
 RANGE x24,320,11,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#616
 ldr x24,[x27]
 RANGE x24,320,12,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x27,x21,#704
 ldr x24,[x27]
 RANGE x24,320,13,.Lsurface_bad
 ldr x9,[x27,#8]
 ldr x10,=0xffffffffffffffeb
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#16]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#24]
 ldr x10,=0x0000030200000000
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#32]
 ldr x10,=0x0000000000000008
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#40]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#48]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#56]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#64]
 ldr x10,=0x0000000000000014
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#72]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x27,#80]
 ldr x10,=0x0000000000000002
 cmp x9,x10
 b.ne .Lsurface_bad
 add x10,sp,#128
 mov x11,#0
.Lrange_outer:
 ldp x12,x13,[x10]
 add x14,x10,#16
 add x15,x11,#1
.Lrange_inner:
 cmp x15,#14
 b.hs .Lrange_next
 ldp x16,x17,[x14]
 cmp x12,x17
 b.hs .Lrange_clear
 cmp x16,x13
 b.lo .Lsurface_bad
.Lrange_clear:
 add x14,x14,#16
 add x15,x15,#1
 b .Lrange_inner
.Lrange_next:
 add x10,x10,#16
 add x11,x11,#1
 cmp x11,#13
 b.lo .Lrange_outer
 mrs x9,fpcr
 cbnz x9,.Lsurface_bad
 ldp x9,x10,[x23]
 orr x9,x9,x10
 cbnz x9,.Lsurface_bad
 mov x9,#0
.Lflags:
 ldr w10,[x19,x9]
 cmp x9,#16
 b.eq .Lsnow
 cmp w10,#1
 b.hi .Lsurface_bad
 b .Lflag_next
.Lsnow:
 sub w10,w10,#1
 cmp w10,#2
 b.hi .Lsurface_bad
.Lflag_next:
 add x9,x9,#4
 cmp x9,#76
 b.lo .Lflags
 ldr w9,[x19,#24]
 cmp w9,#1
 b.ne .Lsurface_bad
 ldr w9,[x19,#32]
 cmp w9,#1
 b.ne .Lsurface_bad
 mov x9,#80
 ldr x11,=0x3ff0000000000000
.Lunits:
 ldr x10,[x19,x9]
 and x12,x10,#0x7fffffffffffffff
 cbz x12,.Lunit_next
 cmp x10,x11
 b.hi .Lsurface_bad
.Lunit_next:
 add x9,x9,#8
 cmp x9,#112
 b.lo .Lunits
 ldr x9,[x19,#128]
 ldr x10,[x19,#144]
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x10,=0x3fe0000000000000
 cmp x9,x10
 b.eq .Lgravity
 ldr x10,=0x3ff0000000000000
 cmp x9,x10
 b.eq .Lgravity
 ldr x10,=0x4000000000000000
 cmp x9,x10
 b.ne .Lsurface_bad
.Lgravity:
 ldr x9,[x19,#136]
 lsl x10,x9,#1
 cbz x10,.Lrotation
 ldr x10,=0x3fe0000000000000
 cmp x9,x10
 b.eq .Lrotation
 ldr x10,=0x3ff0000000000000
 cmp x9,x10
 b.eq .Lrotation
 ldr x10,=0x4000000000000000
 cmp x9,x10
 b.ne .Lsurface_bad
.Lrotation:
 ldr w9,[x19,#152]
 cmp w9,#1
 b.hi .Lsurface_bad
 ldr x9,[x19,#160]
 cbnz x9,.Lsurface_bad
 ldr w9,[x19,#168]
 cmp w9,#4
 b.ne .Lsurface_bad
 ldr w9,[x19,#172]
 cmp w9,#9
 b.ne .Lsurface_bad
 ldr w9,[x19,#176]
 cmp w9,#5
 b.ne .Lsurface_bad
 ldr x9,[x20,#0]
 ldr x10,=0x0000000e00000006
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x20,#8]
 ldr x10,=0x0000000200000006
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x20,#16]
 ldr x10,=0x0000000000000001
 cmp x9,x10
 b.ne .Lsurface_bad
 ldr x9,[x20,#24]
 ldr x10,=0x0000000100000001
 cmp x9,x10
 b.ne .Lsurface_bad
 PCALL __errno_location
 mov x25,x0
 ldr w26,[x25]
 mov x0,#11584
 PCALL malloc
 mov x24,x0
 cbz x24,.Lallocate_failed
 adrp x9,.Lnull_bases
 add x9,x9,:lo12:.Lnull_bases
 mov x10,#85
.Lconstructor:
 ldr x11,[x9],#8
 str xzr,[x24,x11]
 subs x10,x10,#1
 b.ne .Lconstructor
 adrp x27,.Lowner_rows
 add x27,x27,:lo12:.Lowner_rows
 mov x28,#79
.Lallocate:
 ldr x0,[x27,#8]
 PCALL malloc
 cbz x0,.Lallocate_failed
 ldr x9,[x27]
 add x9,x24,x9
 str x0,[x9],#8
 ldp x10,x11,[x27,#16]
 adrp x12,.Lowner_rows
 add x12,x12,:lo12:.Lowner_rows
 add x10,x10,x12
.Ldescriptor:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Ldescriptor
 add x27,x27,#32
 subs x28,x28,#1
 b.ne .Lallocate
 str w26,[x25]
 SADDR x9,TDIM
 ldr w10,[x19,#168]
 ldr w11,[x19,#172]
 stp w10,w11,[x9]
 mov w10,#12
 ldr w11,[x19,#176]
 stp w10,w11,[x9,#8]
 SADDR x0,TCST
 add x1,x19,#136
 PCALL md2asm_initialize_surface_fundamental_constants
 add x0,sp,#512
 SADDR x1,TCST
 PCALL md2asm_initialize_surface_saturation_constants
 mov x0,x20
 SADDR x1,TRAD
 SADDR x2,TRDI
 SADDR x3,TLW
 SADDR x4,TSW
 PCALL md2asm_surface_radiation_parameter_fields
 SADDR x0,TSOIL
 SADDR x1,TCST
 mov x2,x19
 PCALL md2asm_soil_parameter_fields
 SADDR x0,TVEG
 SADDR x1,TSOIL
 SADDR x2,TCST
 SADDR x3,TDIM
 mov x4,x19
 PCALL md2asm_vegetation_parameter_fields
 SADDR x0,TAGS
 SADDR x1,TCST
 mov x2,x21
 PCALL md2asm_carbon_assimilation_parameter_fields
 SADDR x0,TAGF
 mov x1,x21
 PCALL md2asm_farquhar_parameter_fields
 SADDR x0,TEXC
 mov x1,x19
 PCALL md2asm_surface_exchange_parameter_fields
 add x0,sp,#584
 PCALL md2asm_initialize_surface_stability_constants
 SADDR x0,TFLAKE
 add x1,x19,#136
 PCALL md2asm_initialize_lake_parameter_constants
 SADDR x9,TMLM
 str wzr,[x9]
 SADDR x0,TURB
 PCALL md2asm_urban_surface_parameter_fields
 add x9,sp,#512
 mov x10,x22
 mov x11,#127
.Lcommit_globals:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcommit_globals
 mov x9,#11584
 stp x24,x9,[x23]
 mov w0,#0
 PLEAVE 1536
.Lallocate_failed:
 cbz x24,.Lfailure_done
 adrp x27,.Lowner_rows
 add x27,x27,:lo12:.Lowner_rows
 mov x28,#79
.Lfailure_loop:
 ldr x9,[x27]
 ldr x0,[x24,x9]
 cbz x0,.Lfailure_next
 PCALL free
.Lfailure_next:
 add x27,x27,#32
 subs x28,x28,#1
 b.ne .Lfailure_loop
 mov x0,x24
 PCALL free
.Lfailure_done:
 str w26,[x25]
 mov w0,#1
 PLEAVE 1536
.Lsurface_bad:
 mov w0,#2
 PLEAVE 1536
.size md2asm_create_selected_surface_parameters,.-md2asm_create_selected_surface_parameters
.global md2asm_release_selected_surface_parameters
.type md2asm_release_selected_surface_parameters,%function
md2asm_release_selected_surface_parameters:
 PENTER 160
 mov x19,x0
 cbz x19,.Lrelease_bad
 tst x19,#7
 b.ne .Lrelease_bad
 adds x9,x19,#16
 b.cs .Lrelease_bad
 ldp x24,x10,[x19]
 cbz x24,.Lreleased_empty
 tst x24,#7
 b.ne .Lrelease_bad
 mov x11,#11584
 cmp x10,x11
 b.ne .Lrelease_bad
 adds x10,x24,x11
 b.cs .Lrelease_bad
 cmp x19,x10
 b.hs .Lrelease_clear
 cmp x24,x9
 b.lo .Lrelease_bad
.Lrelease_clear:
 PCALL __errno_location
 mov x25,x0
 ldr w26,[x25]
 adrp x27,.Lowner_rows
 add x27,x27,:lo12:.Lowner_rows
 mov x28,#79
.Lrelease_loop:
 ldr x9,[x27]
 ldr x0,[x24,x9]
 cbz x0,.Lrelease_next
 PCALL free
.Lrelease_next:
 add x27,x27,#32
 subs x28,x28,#1
 b.ne .Lrelease_loop
 mov x0,x24
 PCALL free
 stp xzr,xzr,[x19]
 str w26,[x25]
 mov w0,#0
 PLEAVE 160
.Lreleased_empty:
 cbnz x10,.Lrelease_bad
 mov w0,#0
 PLEAVE 160
.Lrelease_bad:
 mov w0,#2
 PLEAVE 160
.size md2asm_release_selected_surface_parameters,.-md2asm_release_selected_surface_parameters
.ltorg
.section .rodata
.p2align 3
.Lnull_bases:
 .quad 10160,10248,10096,9264,9328,9392,8176,8240,8304,8368,8432,8496,8560,8624,8688,8752,8816,8880,8944,9008,9072,9136,9200,9576,9800,9864,9928,9992,10344,10408,10472,10560,10624,10688,10752,10816,10904,10968,1296,1360,1424,1488,1552,1616,1680,1744,1808,1872,1936,2000,2280,2064,2128,2216,336,400,464,528,592,656,720,784,848,912,976,1040,1104,1168,1232,2728,2816,2904,2992,3080,3168,3256,3344,3432,3520,5384,5448,5512,5576,6080,6168
.Lowner_rows:
 .quad 10160,1344,.Lmetadata0-.Lowner_rows,10
 .quad 10248,1344,.Lmetadata1-.Lowner_rows,10
 .quad 10096,112,.Lmetadata2-.Lowner_rows,7
 .quad 9264,32,.Lmetadata3-.Lowner_rows,7
 .quad 9328,32,.Lmetadata4-.Lowner_rows,7
 .quad 9392,32,.Lmetadata5-.Lowner_rows,7
 .quad 8176,64,.Lmetadata6-.Lowner_rows,7
 .quad 8240,64,.Lmetadata7-.Lowner_rows,7
 .quad 8304,64,.Lmetadata8-.Lowner_rows,7
 .quad 8368,64,.Lmetadata9-.Lowner_rows,7
 .quad 8432,64,.Lmetadata10-.Lowner_rows,7
 .quad 8496,64,.Lmetadata11-.Lowner_rows,7
 .quad 8560,64,.Lmetadata12-.Lowner_rows,7
 .quad 8624,64,.Lmetadata13-.Lowner_rows,7
 .quad 8688,64,.Lmetadata14-.Lowner_rows,7
 .quad 8752,64,.Lmetadata15-.Lowner_rows,7
 .quad 8816,64,.Lmetadata16-.Lowner_rows,7
 .quad 8880,64,.Lmetadata17-.Lowner_rows,7
 .quad 8944,64,.Lmetadata18-.Lowner_rows,7
 .quad 9008,64,.Lmetadata19-.Lowner_rows,7
 .quad 9072,56,.Lmetadata20-.Lowner_rows,7
 .quad 9136,56,.Lmetadata21-.Lowner_rows,7
 .quad 9200,56,.Lmetadata22-.Lowner_rows,7
 .quad 9576,40,.Lmetadata23-.Lowner_rows,7
 .quad 9800,40,.Lmetadata24-.Lowner_rows,7
 .quad 9864,40,.Lmetadata25-.Lowner_rows,7
 .quad 9928,40,.Lmetadata26-.Lowner_rows,7
 .quad 9992,40,.Lmetadata27-.Lowner_rows,7
 .quad 10344,168,.Lmetadata28-.Lowner_rows,7
 .quad 10408,168,.Lmetadata29-.Lowner_rows,7
 .quad 10472,672,.Lmetadata30-.Lowner_rows,10
 .quad 10560,168,.Lmetadata31-.Lowner_rows,7
 .quad 10624,168,.Lmetadata32-.Lowner_rows,7
 .quad 10688,168,.Lmetadata33-.Lowner_rows,7
 .quad 10752,168,.Lmetadata34-.Lowner_rows,7
 .quad 10816,168,.Lmetadata35-.Lowner_rows,7
 .quad 10904,168,.Lmetadata36-.Lowner_rows,7
 .quad 10968,168,.Lmetadata37-.Lowner_rows,7
 .quad 1296,84,.Lmetadata38-.Lowner_rows,7
 .quad 1360,168,.Lmetadata39-.Lowner_rows,7
 .quad 1424,168,.Lmetadata40-.Lowner_rows,7
 .quad 1488,168,.Lmetadata41-.Lowner_rows,7
 .quad 1552,168,.Lmetadata42-.Lowner_rows,7
 .quad 1616,168,.Lmetadata43-.Lowner_rows,7
 .quad 1680,168,.Lmetadata44-.Lowner_rows,7
 .quad 1744,168,.Lmetadata45-.Lowner_rows,7
 .quad 1808,168,.Lmetadata46-.Lowner_rows,7
 .quad 1872,168,.Lmetadata47-.Lowner_rows,7
 .quad 1936,168,.Lmetadata48-.Lowner_rows,7
 .quad 2000,168,.Lmetadata49-.Lowner_rows,7
 .quad 2280,168,.Lmetadata50-.Lowner_rows,7
 .quad 2064,168,.Lmetadata51-.Lowner_rows,7
 .quad 2128,336,.Lmetadata52-.Lowner_rows,10
 .quad 2216,168,.Lmetadata53-.Lowner_rows,7
 .quad 336,168,.Lmetadata54-.Lowner_rows,7
 .quad 400,168,.Lmetadata55-.Lowner_rows,7
 .quad 464,168,.Lmetadata56-.Lowner_rows,7
 .quad 528,168,.Lmetadata57-.Lowner_rows,7
 .quad 592,168,.Lmetadata58-.Lowner_rows,7
 .quad 656,168,.Lmetadata59-.Lowner_rows,7
 .quad 720,168,.Lmetadata60-.Lowner_rows,7
 .quad 784,168,.Lmetadata61-.Lowner_rows,7
 .quad 848,168,.Lmetadata62-.Lowner_rows,7
 .quad 912,168,.Lmetadata63-.Lowner_rows,7
 .quad 976,168,.Lmetadata64-.Lowner_rows,7
 .quad 1040,168,.Lmetadata65-.Lowner_rows,7
 .quad 1104,168,.Lmetadata66-.Lowner_rows,7
 .quad 1168,168,.Lmetadata67-.Lowner_rows,7
 .quad 1232,168,.Lmetadata68-.Lowner_rows,7
 .quad 2728,320,.Lmetadata69-.Lowner_rows,10
 .quad 2816,320,.Lmetadata70-.Lowner_rows,10
 .quad 2904,320,.Lmetadata71-.Lowner_rows,10
 .quad 2992,320,.Lmetadata72-.Lowner_rows,10
 .quad 3080,320,.Lmetadata73-.Lowner_rows,10
 .quad 3168,320,.Lmetadata74-.Lowner_rows,10
 .quad 3256,320,.Lmetadata75-.Lowner_rows,10
 .quad 3344,320,.Lmetadata76-.Lowner_rows,10
 .quad 3432,320,.Lmetadata77-.Lowner_rows,10
 .quad 3520,320,.Lmetadata78-.Lowner_rows,10
.Lmetadata0:
 .quad -13,8,3307124817920,8,1,1,12,12,1,14
.Lmetadata1:
 .quad -13,8,3307124817920,8,1,1,12,12,1,14
.Lmetadata2:
 .quad -1,8,3302829850624,8,1,1,14
.Lmetadata3:
 .quad -1,8,3302829850624,8,1,1,4
.Lmetadata4:
 .quad -1,8,3302829850624,8,1,1,4
.Lmetadata5:
 .quad -1,8,3302829850624,8,1,1,4
.Lmetadata6:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata7:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata8:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata9:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata10:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata11:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata12:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata13:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata14:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata15:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata16:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata17:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata18:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata19:
 .quad 0,8,3302829850624,8,1,0,7
.Lmetadata20:
 .quad -1,8,3302829850624,8,1,1,7
.Lmetadata21:
 .quad -1,8,3302829850624,8,1,1,7
.Lmetadata22:
 .quad -1,8,3302829850624,8,1,1,7
.Lmetadata23:
 .quad -1,8,3302829850624,8,1,1,5
.Lmetadata24:
 .quad -1,8,3302829850624,8,1,1,5
.Lmetadata25:
 .quad -1,8,3302829850624,8,1,1,5
.Lmetadata26:
 .quad -1,8,3302829850624,8,1,1,5
.Lmetadata27:
 .quad -1,8,3302829850624,8,1,1,5
.Lmetadata28:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata29:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata30:
 .quad -1,8,3307124817920,8,1,1,4,4,0,20
.Lmetadata31:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata32:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata33:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata34:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata35:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata36:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata37:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata38:
 .quad 0,4,2203318222848,4,1,0,20
.Lmetadata39:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata40:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata41:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata42:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata43:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata44:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata45:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata46:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata47:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata48:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata49:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata50:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata51:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata52:
 .quad -21,8,3307124817920,8,1,0,20,21,1,2
.Lmetadata53:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata54:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata55:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata56:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata57:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata58:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata59:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata60:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata61:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata62:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata63:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata64:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata65:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata66:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata67:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata68:
 .quad 0,8,3302829850624,8,1,0,20
.Lmetadata69:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata70:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata71:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata72:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata73:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata74:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata75:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata76:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata77:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.Lmetadata78:
 .quad -21,8,3307124817920,8,1,1,20,20,1,2
.section .note.GNU-stack,"",%progbits

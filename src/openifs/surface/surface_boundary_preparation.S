/* Direct selected VSURF body from OpenIFS 48.1.1.
 * Physics formulations/openifs/surface/surface_physical_updates.md.
 * Contract skills/md2asm/references/openifs/surface/surface_physical_updates.md.
 * Frozen numerical body and current private interfaces are preserved. */
.equ YDCST_RCPD, 80
.equ YDCST_RETV, 48
.equ YDCST_RLSTT, 56
.equ YDCST_RLVTT, 72
.equ YDCST_RTT, 0
.equ YDVEG_LEAGS, 760
.equ YDVEG_LECTESSEL, 756
.equ YDVEG_LEFARQUHAR, 764
.equ YDVEG_LEAIRCO2COUP, 768
.equ YDVEG_RCEPSW, 560
.equ YDVEG_RVHSTR, 632
.equ YDVEG_RVLAI, 72
.equ YDVEG_RVROOTSA, 136
.equ YDVEG_RVRSMIN, 568
.equ YDEXC_LEOCSA, 28
.equ YDSOIL_LEVGEN, 440
.equ YDSOIL_RQWEVAP, 168
.equ YDSOIL_RQWEVAPM, 1264
.equ YDSOIL_RTF1, 208
.equ YDSOIL_RTF2, 216
.equ YDSOIL_RTF3, 224
.equ YDSOIL_RTF4, 232
.equ YDSOIL_RWCAP, 128
.equ YDSOIL_RWCAPM, 944
.equ YDSOIL_RWPWP, 136
.equ YDSOIL_RWPWPM, 1008
.equ YDSOIL_RWRESTM, 1072
.equ YDURB_RURBRES, 392

.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro IN reg,arg
 ARG x9,\arg
 ldr x9,[x9]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro OUT reg,arg
 ARG x9,\arg
 ldr x9,[x9]
 str \reg,[x9,x20,lsl #3]
.endm
.macro IN2 reg,arg,index
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x9,[x9]
 madd x10,\index,x10,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg,arg,field
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x9,[x9]
 mov x11,#(\field-1)
 madd x10,x11,x10,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro DIAG reg,field
 ARG x9,41
 ldr x10,[x9,#64]
 ldr x11,[x9,#88]
 ldr x9,[x9]
 ARG x12,9
 ldr w12,[x12]
 sub x12,x12,#1
 madd x10,x12,x10,x20
 mov x12,#(\field-1)
 madd x10,x12,x11,x10
 str \reg,[x9,x10,lsl #3]
.endm
.macro PRIVATE reg,index
 ldr x9,[sp,#(1664+\index*8)]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro PRIVATE_OUT reg,index
 ldr x9,[sp,#(1664+\index*8)]
 str \reg,[x9,x20,lsl #3]
.endm
.macro CONST reg,name
 adr x9,.Lvsurf_\name
 ldr \reg,[x9]
.endm
.macro GLOBAL reg,name
 adrp x9,:got:__yos_thf_MOD_\name
 ldr x9,[x9,:got_lo12:__yos_thf_MOD_\name]
 ldr \reg,[x9]
.endm
.macro VP reg,field
 ldr \reg,[x24,#\field]
.endm
.macro SP reg,field
 ldr \reg,[x23,#\field]
.endm
.macro VTAB reg,field,index
 ldr x9,[x24,#\field]
 ldr \reg,[x9,\index,lsl #3]
.endm
.macro STAB reg,field
 ldr x9,[x23,#\field]
 ldr \reg,[x9,x28,lsl #3]
.endm
.macro CALL name
 str x18,[sp,#1776]
 bl \name
 ldr x18,[sp,#1776]
.endm
.macro PARG dest,arg
 ARG x9,\arg
 .if \dest<8
  mov x\dest,x9
 .else
  str x9,[sp,#((\dest-8)*8)]
 .endif
.endm
.macro DARG dest,index
 add x9,sp,#(1216+\index*64)
 .if \dest<8
  mov x\dest,x9
 .else
  str x9,[sp,#((\dest-8)*8)]
 .endif
.endm
.macro CHECK1 arg,element,kind
 ARG x9,\arg
 ldr x10,[x9]
 cbz x10,.Lvsurf_reject
 tst x10,#(\element-1)
 b.ne .Lvsurf_reject
 ldr x10,[x9,#16]
 cmp x10,#\element
 b.ne .Lvsurf_reject
 ldr x10,[x9,#32]
 cmp x10,#\element
 b.ne .Lvsurf_reject
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lvsurf_reject
 ldrb w10,[x9,#29]
 cmp w10,#\kind
 b.ne .Lvsurf_reject
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lvsurf_reject
 ldp x10,x11,[x9,#48]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,x21
 b.lt .Lvsurf_reject
 ldr x11,[x9,#8]
 add x11,x11,x10
 cbnz x11,.Lvsurf_reject
.endm
.macro CHECKM arg,element,kind,rank,min2,min3=0
 ARG x9,\arg
 ldr x10,[x9]
 cbz x10,.Lvsurf_reject
 tst x10,#(\element-1)
 b.ne .Lvsurf_reject
 ldr x10,[x9,#16]
 cmp x10,#\element
 b.ne .Lvsurf_reject
 ldr x10,[x9,#32]
 cmp x10,#\element
 b.ne .Lvsurf_reject
 ldrb w10,[x9,#28]
 cmp w10,#\rank
 b.ne .Lvsurf_reject
 ldrb w10,[x9,#29]
 cmp w10,#\kind
 b.ne .Lvsurf_reject
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lvsurf_reject
 ldp x10,x11,[x9,#48]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,x21
 b.lt .Lvsurf_reject
 ldr x12,[x9,#64]
 cmp x12,x11
 b.ne .Lvsurf_reject
 ldp x13,x14,[x9,#72]
 sub x14,x14,x13
 add x14,x14,#1
 cmp x14,#\min2
 b.lt .Lvsurf_reject
 ldr x15,[x9,#8]
 add x15,x15,x10
 madd x15,x13,x12,x15
 .if \rank==3
  mul x11,x11,x14
  ldr x12,[x9,#88]
  cmp x12,x11
  b.ne .Lvsurf_reject
  ldp x13,x14,[x9,#96]
  sub x14,x14,x13
  add x14,x14,#1
  cmp x14,#\min3
  b.lt .Lvsurf_reject
  madd x15,x13,x12,x15
 .endif
 cbnz x15,.Lvsurf_reject
.endm
.global md2asm_vsurf_sea_derivative_r2_7358525
.type md2asm_vsurf_sea_derivative_r2_7358525,%function
md2asm_vsurf_sea_derivative_r2_7358525:
 sub sp,sp,#4096
 stp x19,x20,[sp,#192]
 stp x21,x22,[sp,#208]
 stp x23,x24,[sp,#224]
 stp x25,x26,[sp,#240]
 stp x27,x28,[sp,#256]
 stp x29,x30,[sp,#272]
 str x18,[sp,#288]
 add x19,sp,#320
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 add x11,sp,#4096
 mov x10,#8
.Lvsurf_arguments:
 ldr x9,[x11],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#51
 b.lt .Lvsurf_arguments
 mrs x9,fpcr
 cbnz x9,.Lvsurf_reject
 mov x10,#0
.Lvsurf_pointers:
 ldr x9,[x19,x10,lsl #3]
 cbz x9,.Lvsurf_reject
 tst x9,#3
 b.ne .Lvsurf_reject
 add x10,x10,#1
 cmp x10,#51
 b.lt .Lvsurf_pointers
 ARG x9,2
 ldr w21,[x9]
 cmp w21,#1
 b.lt .Lvsurf_reject
 cmp w21,#4096
 b.gt .Lvsurf_reject
 ARG x9,0
 ldr w20,[x9]
 sub w20,w20,#1
 cmp w20,#0
 b.lt .Lvsurf_reject
 cmp w20,w21
 b.gt .Lvsurf_reject
 str w20,[sp,#1800]
 ARG x9,1
 ldr w25,[x9]
 cmp w25,#0
 b.lt .Lvsurf_reject
 cmp w25,w21
 b.gt .Lvsurf_reject
 cmp w25,w20
 b.lt .Lvsurf_reject
 ARG x9,3
 ldr w9,[x9]
 cmp w9,#9
 b.ne .Lvsurf_reject
 ARG x9,4
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lvsurf_reject
 ARG x9,5
 ldr w26,[x9]
 cmp w26,#1
 b.lt .Lvsurf_reject
 cmp w26,#9
 b.gt .Lvsurf_reject
 ARG x23,48
 ARG x24,44
 ldr w9,[x23,#YDSOIL_LEVGEN]
 cmp w9,#1
 b.ne .Lvsurf_reject
 ldr w9,[x24,#YDVEG_LECTESSEL]
 cmp w9,#1
 b.ne .Lvsurf_reject
 ldr w9,[x24,#YDVEG_LEAGS]
 cbnz w9,.Lvsurf_reject
 ldr w9,[x24,#YDVEG_LEFARQUHAR]
 cmp w9,#1
 b.ne .Lvsurf_reject
 ARG x9,45
 ldr w9,[x9,#YDEXC_LEOCSA]
 cmp w9,#1
 b.ne .Lvsurf_reject
 CHECK1 6,4,1
 CHECK1 7,4,1
 CHECK1 8,4,1
 CHECK1 24,4,1
 CHECK1 11,8,3
 CHECK1 12,8,3
 CHECK1 13,8,3
 CHECK1 15,8,3
 CHECK1 16,8,3
 CHECK1 17,8,3
 CHECK1 18,8,3
 CHECK1 19,8,3
 CHECK1 20,8,3
 CHECK1 21,8,3
 CHECK1 25,8,3
 CHECK1 26,8,3
 CHECK1 27,8,3
 CHECK1 28,8,3
 CHECK1 29,8,3
 CHECK1 30,8,3
 CHECK1 31,8,3
 CHECK1 32,8,3
 CHECK1 33,8,3
 CHECK1 34,8,3
 CHECK1 35,8,3
 CHECK1 36,8,3
 CHECK1 37,8,3
 CHECK1 38,8,3
 CHECK1 39,8,3
 CHECKM 10,4,1,2,9
 CHECKM 14,8,3,2,9
 CHECKM 22,8,3,2,4
 CHECKM 23,8,3,2,4
 CHECKM 41,8,3,3,2,7
 CHECKM 42,8,3,2,10

 // Validate active table indices before any public output is changed.
 ldr w20,[sp,#1800]
 cmp w20,w25
 b.ge .Lvsurf_allocate
.Lvsurf_domain:
 ARG x9,6
 ldr x9,[x9]
 ldr w10,[x9,x20,lsl #2]
 cmp w10,#20
 b.hi .Lvsurf_reject
 ARG x9,8
 ldr x9,[x9]
 ldr w10,[x9,x20,lsl #2]
 cmp w10,#20
 b.hi .Lvsurf_reject
 ARG x9,24
 ldr x9,[x9]
 ldr w10,[x9,x20,lsl #2]
 cmp w10,#7
 b.hi .Lvsurf_reject
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_domain
.Lvsurf_allocate:
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lvsurf_reject
 str w9,[sp,#1840]
 cbz w9,.Lvsurf_hook_entry_done
 adr x0,.Lvsurf_hook_name
 add x1,sp,#1844
 str wzr,[x1]
 add x2,sp,#1848
 mov x3,#15
 CALL __yomhook_MOD_dr_hook_default8
.Lvsurf_hook_entry_done:
 mov x0,x21
 mov x1,#112
 CALL calloc
 cbz x0,.Lvsurf_reject
 mov x22,x0
 lsl x9,x21,#3
 str x22,[sp,#1664]
 add x10,x22,x9
 str x10,[sp,#1672]
 add x10,x10,x9,lsl #2
 str x10,[sp,#1680]
 add x10,x10,x9,lsl #2
 str x10,[sp,#1688]
 add x10,x10,x9
 str x10,[sp,#1696]
 add x10,x10,x9
 str x10,[sp,#1704]
 add x10,x10,x9
 str x10,[sp,#1712]
 add x10,x10,x9
 str x10,[sp,#1720]
 CONST d0,one
 cmp w26,#1
 b.ne .Lvsurf_salinity_done
 CONST d0,salinity
.Lvsurf_salinity_done:
 str d0,[sp,#736]
 ldr w20,[sp,#1800]
 cmp w20,w25
 b.ge .Lvsurf_return
.Lvsurf_saturation:
 IN d0,21
 cmp w26,#7
 b.ne .Lvsurf_skin_ready
 sub x27,x26,#1
 IN2 d1,14,x27
 CONST d2,epsilon
 fcmp d1,d2
 b.gt .Lvsurf_skin_ready
 ARG x9,43
 ldr d1,[x9,#YDCST_RTT]
 CONST d3,hundred
 fmul d2,d3,d2
 fadd d2,d1,d2
 fcmp d0,d2
 b.le .Lvsurf_skin_ready
 fmov d0,d1
.Lvsurf_skin_ready:
 PRIVATE_OUT d0,0
 CALL .Lvsurf_saturation_function
 str d1,[sp,#1016]
 IN d1,20
 fdiv d0,d0,d1
 ARG x9,43
 ldr d1,[x9,#YDCST_RETV]
 fmul d1,d1,d0
 CONST d2,one
 fsub d1,d2,d1
 fmov d3,d1 // Retain the rounded original denominator.
 ldr d2,[sp,#736]
 fdiv d1,d2,d1
 fmul d0,d0,d1
 OUT d0,28
 cmp w26,#1
 b.ne .Lvsurf_derivative_factor_ready
 CONST d2,one
 fdiv d1,d2,d3 // Sea dq/dT has one salinity factor, already in q.
.Lvsurf_derivative_factor_ready:
 fmul d0,d0,d1
 ldr d1,[sp,#1016]
 fmul d0,d0,d1
 OUT d0,29
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_saturation
 // Tile four owns the original traditional resistance setup.
 cmp w26,#4
 b.ne .Lvsurf_apparent_begin
 CALL .Lvsurf_liquid_soil
 ldr w20,[sp,#1800]
.Lvsurf_traditional:
 CALL .Lvsurf_column_stress
 IN d0,15
 str d0,[sp,#872]
 IN d0,16
 str d0,[sp,#880]
 ARG x9,6
 ldr x9,[x9]
 ldr w27,[x9,x20,lsl #2]
 VTAB d0,YDVEG_RVRSMIN,x27
 str d0,[sp,#888]
 ARG x9,8
 ldr x9,[x9]
 ldr w27,[x9,x20,lsl #2]
 VTAB d0,YDVEG_RVRSMIN,x27
 str d0,[sp,#896]
 ldr d0,[sp,#872]
 fcmp d0,#0.0
 b.eq .Lvsurf_no_low_lai
 ldr d1,[sp,#848]
 fmul d0,d0,d1
 ldr d1,[sp,#832]
 fmul d0,d0,d1
 ldr d1,[sp,#856]
 fmul d0,d0,d1
 ldr d1,[sp,#888]
 fdiv d0,d1,d0
 b .Lvsurf_low_wet_ready
.Lvsurf_no_low_lai:
 CONST d0,million
.Lvsurf_low_wet_ready:
 OUT d0,32
 OUT2 d0,42,1
 ldr d0,[sp,#848]
 ldr d1,[sp,#856]
 fmul d0,d0,d1
 CONST d1,fifty
 fdiv d0,d1,d0
 OUT d0,33
 ldr d0,[sp,#880]
 fcmp d0,#0.0
 b.eq .Lvsurf_no_high_lai
 ldr d1,[sp,#848]
 fmul d0,d0,d1
 ldr d1,[sp,#840]
 fmul d0,d0,d1
 ldr d1,[sp,#864]
 fmul d0,d0,d1
 ldr d1,[sp,#896]
 fdiv d0,d1,d0
 b .Lvsurf_high_wet_ready
.Lvsurf_no_high_lai:
 CONST d0,million
.Lvsurf_high_wet_ready:
 OUT d0,34
 OUT d0,35
 OUT2 d0,42,6
 CONST d0,fifty
 ldr d1,[sp,#824]
 fdiv d0,d0,d1
 OUT d0,30
 ldr d0,[sp,#848]
 OUT2 d0,42,2
 OUT2 d0,42,7
 ldr d0,[sp,#832]
 OUT2 d0,42,3
 ldr d0,[sp,#840]
 OUT2 d0,42,8
 ldr d0,[sp,#856]
 OUT2 d0,42,4
 ldr d0,[sp,#864]
 OUT2 d0,42,9
 ldr d0,[sp,#872]
 OUT2 d0,42,5
 ldr d0,[sp,#880]
 OUT2 d0,42,10
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_traditional
.Lvsurf_apparent_begin:
 ldr w20,[sp,#1800]
.Lvsurf_apparent:
 cmp w26,#8
 b.eq .Lvsurf_apparent_bare
 cmp w26,#4
 b.eq .Lvsurf_apparent_low
 cmp w26,#6
 b.eq .Lvsurf_apparent_high
 cmp w26,#7
 b.eq .Lvsurf_apparent_snow
 IN d0,28
 OUT d0,27
 b .Lvsurf_apparent_next
.Lvsurf_apparent_bare:
 IN d2,30
 b .Lvsurf_apparent_dry
.Lvsurf_apparent_low:
 IN d2,32
 b .Lvsurf_apparent_dry
.Lvsurf_apparent_high:
 IN d2,34
 b .Lvsurf_apparent_dry
.Lvsurf_apparent_snow:
 IN d2,35
.Lvsurf_apparent_dry:
 IN d0,28
 IN d1,18
 fsub d1,d1,d0
 fmov d3,xzr
 fmin d1,d3,d1
 fmul d1,d1,d2
 IN d3,26
 fadd d2,d2,d3
 fdiv d1,d1,d2
 fadd d0,d0,d1
 OUT d0,27
.Lvsurf_apparent_next:
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_apparent
 // Carbon preparation runs independently of the legacy resistance outputs.
 cmp w26,#4
 b.eq .Lvsurf_carbon_soil
 cmp w26,#6
 b.eq .Lvsurf_carbon_soil
 cmp w26,#7
 b.eq .Lvsurf_carbon_soil
 cmp w26,#8
 b.eq .Lvsurf_carbon_soil
 // Other selected tiles expose zero liquid water.
 ldr w20,[sp,#1800]
.Lvsurf_zero_liquid_row:
 mov x27,#0
.Lvsurf_zero_liquid_level:
 ARG x9,40
 madd x10,x27,x21,x20
 str xzr,[x9,x10,lsl #3]
 add x27,x27,#1
 cmp x27,#4
 b.lt .Lvsurf_zero_liquid_level
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_zero_liquid_row
 b .Lvsurf_energy_begin
.Lvsurf_carbon_soil:
 CALL .Lvsurf_liquid_soil
 ldr w20,[sp,#1800]
.Lvsurf_carbon_common:
 CALL .Lvsurf_column_stress
 fmov d0,xzr
 PRIVATE_OUT d0,3
 CONST d0,one
 PRIVATE_OUT d0,4
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_carbon_common
 cmp w26,#8
 b.eq .Lvsurf_bare_carbon_begin
 ldr w20,[sp,#1800]
.Lvsurf_carbon_root_row:
 ARG x9,10
 ldr x10,[x9,#64]
 ldr x9,[x9]
 sub x11,x26,#1
 madd x10,x11,x10,x20
 ldr w28,[x9,x10,lsl #2]
 cmp w28,#20
 b.hi .Lvsurf_reject
 fmov d0,xzr
 mov x27,#0
.Lvsurf_carbon_root_level:
 ldr x9,[sp,#1672]
 madd x10,x27,x21,x20
 ldr d1,[x9,x10,lsl #3]
 ldr x9,[x24,#YDVEG_RVROOTSA]
 add x10,x27,x28,lsl #2
 ldr d2,[x9,x10,lsl #3]
 fmul d1,d1,d2
 fadd d0,d0,d1
 add x27,x27,#1
 cmp x27,#4
 b.lt .Lvsurf_carbon_root_level
 str d0,[sp,#1032]
 ARG x9,24
 ldr x9,[x9]
 ldr w28,[x9,x20,lsl #2]
 STAB d1,YDSOIL_RWPWPM
 str d1,[sp,#784]
 STAB d2,YDSOIL_RQWEVAPM
 str d2,[sp,#792]
 mov x27,#0
 IN2 d0,23,x27
 ARG x9,43
 ldr d1,[x9,#YDCST_RTT]
 fcmp d0,d1
 b.le .Lvsurf_carbon_frozen
 ldr d0,[sp,#1032]
 ldr d1,[sp,#784]
 fsub d0,d0,d1
 ldr d1,[sp,#792]
 fmul d0,d0,d1
 CONST d1,one
 fmin d0,d1,d0
 VP d1,YDVEG_RCEPSW
 fmax d0,d1,d0
 b .Lvsurf_carbon_water_ready
.Lvsurf_carbon_frozen:
 VP d0,YDVEG_RCEPSW
.Lvsurf_carbon_water_ready:
 PRIVATE_OUT d0,4
 cmp w26,#7
 b.eq .Lvsurf_carbon_water_no_diag
 DIAG d0,5
.Lvsurf_carbon_water_no_diag:
 mov x27,#0
.Lvsurf_carbon_copy_liquid:
 ldr x9,[sp,#1672]
 madd x10,x27,x21,x20
 ldr d0,[x9,x10,lsl #3]
 ARG x9,40
 str d0,[x9,x10,lsl #3]
 add x27,x27,#1
 cmp x27,#4
 b.lt .Lvsurf_carbon_copy_liquid
 mov x27,#2
 IN2 d0,23,x27
 PRIVATE_OUT d0,5
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_carbon_root_row
 // Seven descriptors expose owned local arrays and the selected vegetation view.
 mov x27,#0
.Lvsurf_child_descriptors:
 add x10,sp,#1216
 add x10,x10,x27,lsl #6
 cbnz x27,.Lvsurf_child_real_descriptor
 ARG x9,10
 ldr x11,[x9,#64]
 ldr x9,[x9]
 sub x12,x26,#1
 mul x11,x11,x12
 add x9,x9,x11,lsl #2
 mov x11,#4
 movz x12,#0x0101,lsl #32
 b .Lvsurf_child_descriptor_body
.Lvsurf_child_real_descriptor:
 adr x9,.Lvsurf_child_pool_indices
 ldr w9,[x9,x27,lsl #2]
 add x11,sp,#1664
 ldr x9,[x11,x9,lsl #3]
 mov x11,#8
 movz x12,#0x0301,lsl #32
.Lvsurf_child_descriptor_body:
 str x9,[x10]
 mov x9,#-1
 str x9,[x10,#8]
 str x11,[x10,#16]
 str x12,[x10,#24]
 str x11,[x10,#32]
 mov x9,#1
 str x9,[x10,#40]
 str x9,[x10,#48]
 str x21,[x10,#56]
 add x27,x27,#1
 cmp x27,#7
 b.lt .Lvsurf_child_descriptors
 PARG 0,0
 PARG 1,1
 PARG 2,2
 DARG 3,0
 PARG 4,7
 PARG 5,14
 PARG 6,17
 PARG 7,18
 PARG 8,19
 PARG 9,20
 DARG 10,1
 DARG 11,2
 PARG 12,36
 PARG 13,11
 PARG 14,25
 PARG 15,26
 PARG 16,12
 DARG 17,3
 PARG 18,28
 PARG 19,43
 PARG 20,46
 PARG 21,47
 PARG 22,44
 PARG 23,49
 PARG 24,37
 PARG 25,38
 PARG 26,39
 DARG 27,4
 DARG 28,5
 DARG 29,6
 CALL md2asm_cotworestress_7358525
 ldr w20,[sp,#1800]
.Lvsurf_carbon_diagnostics:
 IN d0,18
 IN d1,28
 fcmp d0,d1
 b.le .Lvsurf_no_dew
 fmov d0,xzr
 PRIVATE_OUT d0,3
.Lvsurf_no_dew:
 PRIVATE d0,6
 DIAG d0,6
 PRIVATE d0,7
 DIAG d0,7
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_carbon_diagnostics
 b .Lvsurf_energy_begin
.Lvsurf_bare_carbon_begin:
 ldr w20,[sp,#1800]
.Lvsurf_bare_carbon:
 ARG x9,24
 ldr x9,[x9]
 ldr w28,[x9,x20,lsl #2]
 CALL .Lvsurf_bare_water
 CONST d0,fifty
 ldr d1,[sp,#824]
 fdiv d0,d0,d1
 PRIVATE_OUT d0,3
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_bare_carbon
.Lvsurf_energy_begin:
 ldr w20,[sp,#1800]
.Lvsurf_energy:
 IN d0,21
 ARG x9,43
 ldr d1,[x9,#YDCST_RCPD]
 fmul d0,d0,d1
 IN d1,27
 GLOBAL d2,rvtmp2
 fmul d1,d2,d1
 CONST d2,one
 fadd d1,d2,d1
 fmul d0,d0,d1
 OUT d0,31
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_energy
.Lvsurf_return:
 mov x0,x22
 CALL free
 ldr w9,[sp,#1840]
 cbz w9,.Lvsurf_hook_exit_done
 adr x0,.Lvsurf_hook_name
 add x1,sp,#1844
 mov w9,#1
 str w9,[x1]
 add x2,sp,#1848
 mov x3,#15
 CALL __yomhook_MOD_dr_hook_default8
.Lvsurf_hook_exit_done:
 ldr x18,[sp,#288]
 ldp x19,x20,[sp,#192]
 ldp x21,x22,[sp,#208]
 ldp x23,x24,[sp,#224]
 ldp x25,x26,[sp,#240]
 ldp x27,x28,[sp,#256]
 ldp x29,x30,[sp,#272]
 add sp,sp,#4096
 ret
.Lvsurf_reject:
 bl abort
 brk #0
// Internal helpers retain the main frame and its private scalar slots.
.Lvsurf_saturation_function:
 str x30,[sp,#1000]
 str d0,[sp,#928]
 ARG x9,43
 ldr d1,[x9,#YDCST_RTT]
 fsub d2,d0,d1
 str d2,[sp,#960]
 fcmp d2,#0.0
 CONST d3,one
 fmov d4,xzr
 fcsel d3,d3,d4,ge
 CONST d4,one
 fsub d4,d4,d3
 GLOBAL d0,r3les
 fmul d0,d0,d3
 GLOBAL d1,r3ies
 fmul d1,d1,d4
 fadd d0,d0,d1
 GLOBAL d1,r4les
 fmul d1,d1,d3
 GLOBAL d2,r4ies
 fmul d2,d2,d4
 fadd d1,d1,d2
 ldr d2,[sp,#928]
 fsub d2,d2,d1
 str d2,[sp,#968]
 GLOBAL d1,r5les
 fmul d1,d3,d1
 GLOBAL d3,r5ies
 fmul d3,d4,d3
 fadd d1,d1,d3
 str d1,[sp,#976]
 ldr d1,[sp,#960]
 fmul d0,d0,d1
 fdiv d0,d0,d2
 CALL exp
 GLOBAL d1,r2es
 fmul d0,d1,d0
 ldr d1,[sp,#976]
 ldr d2,[sp,#968]
 fmul d2,d2,d2
 fdiv d1,d1,d2
 ldr x30,[sp,#1000]
 ret
.Lvsurf_liquid_soil:
 str x30,[sp,#984]
 mov x27,#0
.Lvsurf_liquid_level:
 ldr w20,[sp,#1800]
.Lvsurf_liquid_column:
 IN2 d0,23,x27
 SP d1,YDSOIL_RTF1
 fcmp d0,d1
 b.ge .Lvsurf_liquid_unfrozen
 SP d1,YDSOIL_RTF2
 fcmp d0,d1
 b.le .Lvsurf_liquid_frozen
 SP d1,YDSOIL_RTF3
 fsub d0,d0,d1
 SP d1,YDSOIL_RTF4
 fmul d0,d1,d0
 CALL md2asm_sin_original_rounding
 CONST d1,one
 fsub d0,d1,d0
 CONST d1,half
 fmul d0,d1,d0
 b .Lvsurf_liquid_fraction_ready
.Lvsurf_liquid_frozen:
 CONST d0,one
 b .Lvsurf_liquid_fraction_ready
.Lvsurf_liquid_unfrozen:
 fmov d0,xzr
.Lvsurf_liquid_fraction_ready:
 CONST d1,one
 fsub d0,d1,d0
 IN2 d1,22,x27
 fmul d0,d1,d0
 str d0,[sp,#760]
 ARG x9,24
 ldr x9,[x9]
 ldr w28,[x9,x20,lsl #2]
 STAB d1,YDSOIL_RWCAPM
 fmin d0,d1,d0
 STAB d1,YDSOIL_RWPWPM
 fmax d0,d1,d0
 ldr x9,[sp,#1672]
 madd x10,x27,x21,x20
 str d0,[x9,x10,lsl #3]
 ldr d0,[sp,#760]
 STAB d1,YDSOIL_RWCAPM
 fmin d0,d1,d0
 STAB d1,YDSOIL_RWRESTM
 fmax d0,d1,d0
 ldr x9,[sp,#1680]
 madd x10,x27,x21,x20
 str d0,[x9,x10,lsl #3]
 add x20,x20,#1
 cmp w20,w25
 b.lt .Lvsurf_liquid_column
 add x27,x27,#1
 cmp x27,#4
 b.lt .Lvsurf_liquid_level
 ldr x30,[sp,#984]
 ret
.Lvsurf_bare_water:
 str x30,[sp,#1024]
 mov x27,#7
 IN2 d0,14,x27
 str d0,[sp,#800]
 STAB d1,YDSOIL_RWPWPM
 STAB d2,YDSOIL_RWRESTM
 CONST d3,one
 fsub d3,d3,d0
 fmul d1,d1,d3
 fmul d2,d2,d0
 fadd d0,d1,d2
 str d0,[sp,#808]
 cbz x28,.Lvsurf_no_bare_response
 STAB d1,YDSOIL_RWCAPM
 fsub d0,d1,d0
 CONST d1,one
 fdiv d0,d1,d0
 b .Lvsurf_bare_response_ready
.Lvsurf_no_bare_response:
 fmov d0,xzr
.Lvsurf_bare_response_ready:
 str d0,[sp,#816]
 PRIVATE d0,2
 ldr d1,[sp,#808]
 fsub d0,d0,d1
 ldr d1,[sp,#816]
 fmul d0,d0,d1
 CONST d1,one
 fmin d0,d1,d0
 VP d1,YDVEG_RCEPSW
 fmax d0,d1,d0
 str d0,[sp,#824]
 ldr x30,[sp,#1024]
 ret
.Lvsurf_column_stress:
 str x30,[sp,#992]
 fmov d0,xzr
 str d0,[sp,#768]
 str d0,[sp,#776]
 mov x27,#0
.Lvsurf_low_high_roots:
 ldr x9,[sp,#1672]
 madd x10,x27,x21,x20
 ldr d0,[x9,x10,lsl #3]
 ARG x9,6
 ldr x9,[x9]
 ldr w28,[x9,x20,lsl #2]
 ldr x9,[x24,#YDVEG_RVROOTSA]
 add x10,x27,x28,lsl #2
 ldr d1,[x9,x10,lsl #3]
 fmul d1,d0,d1
 ldr d2,[sp,#768]
 fadd d1,d2,d1
 str d1,[sp,#768]
 ARG x9,8
 ldr x9,[x9]
 ldr w28,[x9,x20,lsl #2]
 ldr x9,[x24,#YDVEG_RVROOTSA]
 add x10,x27,x28,lsl #2
 ldr d1,[x9,x10,lsl #3]
 fmul d1,d0,d1
 ldr d2,[sp,#776]
 fadd d1,d2,d1
 str d1,[sp,#776]
 add x27,x27,#1
 cmp x27,#4
 b.lt .Lvsurf_low_high_roots
 ARG x9,24
 ldr x9,[x9]
 ldr w28,[x9,x20,lsl #2]
 STAB d0,YDSOIL_RWPWPM
 str d0,[sp,#784]
 STAB d0,YDSOIL_RQWEVAPM
 str d0,[sp,#792]
 CALL .Lvsurf_bare_water
 mov x27,#0
 IN2 d0,23,x27
 ARG x9,43
 ldr d1,[x9,#YDCST_RTT]
 fcmp d0,d1
 b.le .Lvsurf_traditional_frozen
 ldr d0,[sp,#768]
 ldr d1,[sp,#784]
 fsub d0,d0,d1
 ldr d1,[sp,#792]
 fmul d0,d0,d1
 CONST d1,one
 fmin d0,d1,d0
 VP d1,YDVEG_RCEPSW
 fmax d0,d1,d0
 str d0,[sp,#832]
 ldr d0,[sp,#776]
 ldr d1,[sp,#784]
 fsub d0,d0,d1
 ldr d1,[sp,#792]
 fmul d0,d0,d1
 CONST d1,one
 fmin d0,d1,d0
 VP d1,YDVEG_RCEPSW
 fmax d0,d1,d0
 str d0,[sp,#840]
 b .Lvsurf_traditional_water_done
.Lvsurf_traditional_frozen:
 VP d0,YDVEG_RCEPSW
 str d0,[sp,#832]
 str d0,[sp,#840]
.Lvsurf_traditional_water_done:
 IN d0,25
 CONST d1,two_hundred_fifty
 fdiv d0,d0,d1
 CONST d1,one
 fadd d1,d1,d0
 CONST d2,point_eighty_one
 fmul d1,d2,d1
 CONST d2,point_zero_five
 fadd d0,d0,d2
 fdiv d0,d1,d0
 CONST d1,one
 fmax d0,d1,d0
 fdiv d0,d1,d0
 str d0,[sp,#848]
 IN d0,17
 CALL .Lvsurf_saturation_function
 IN d1,20
 fdiv d0,d0,d1
 ARG x9,43
 ldr d1,[x9,#YDCST_RETV]
 fmul d1,d1,d0
 CONST d2,one
 fsub d1,d2,d1
 fdiv d1,d2,d1
 fmul d0,d0,d1
 str d0,[sp,#904]
 ARG x9,6
 ldr x9,[x9]
 ldr w27,[x9,x20,lsl #2]
 VTAB d0,YDVEG_RVHSTR,x27
 fneg d0,d0
 ldr d1,[sp,#904]
 IN d2,18
 fsub d1,d1,d2
 fmul d0,d0,d1
 CALL exp
 CONST d1,one
 fmin d0,d1,d0
 CONST d1,humidity_floor
 fmax d0,d1,d0
 str d0,[sp,#856]
 ARG x9,8
 ldr x9,[x9]
 ldr w27,[x9,x20,lsl #2]
 VTAB d0,YDVEG_RVHSTR,x27
 fneg d0,d0
 ldr d1,[sp,#904]
 IN d2,18
 fsub d1,d1,d2
 fmul d0,d0,d1
 CALL exp
 CONST d1,one
 fmin d0,d1,d0
 CONST d1,humidity_floor
 fmax d0,d1,d0
 str d0,[sp,#864]
 ldr x30,[sp,#992]
 ret
.size md2asm_vsurf_sea_derivative_r2_7358525,.-md2asm_vsurf_sea_derivative_r2_7358525
.section .rodata
.p2align 3
.Lvsurf_one: .double 1.0
.Lvsurf_half: .double 0.5
.Lvsurf_hundred: .double 100.0
.Lvsurf_fifty: .double 50.0
.Lvsurf_million: .double 1.0e6
.Lvsurf_two_hundred_fifty: .double 250.0
.Lvsurf_point_eighty_one: .double 0.81
.Lvsurf_point_zero_five: .double 0.05
.Lvsurf_humidity_floor: .double 1.0e-5
.Lvsurf_salinity: .double 0.98
.Lvsurf_epsilon: .double 2.220446049250313e-16
.Lvsurf_child_pool_indices: .word 0,0,5,4,3,6,7
.Lvsurf_hook_name: .ascii "VSURF_MOD:VSURF"
.section .note.GNU-stack,"",%progbits

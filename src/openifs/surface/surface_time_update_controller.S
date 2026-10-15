// SURFTSTP_CTL: selected-column surface state update.
// Physics: formulations/openifs/surface/surface_physical_updates.md.
// ABI and bounds: skills/md2asm/references/openifs/surface/surface_time_update_controller.md.
// Original source: surf/module/surftstp_ctl_mod.F90, SURFTSTP_CTL.
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
.macro IN2 reg,arg,col=x21
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x9,[x9]
 madd x10,\col,x10,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg,arg,col=x21
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x9,[x9]
 madd x10,\col,x10,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro IN3 reg,arg,second,third
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x11,[x9,#88]
 ldr x9,[x9]
 mov x12,#(\second-1)
 madd x10,x12,x10,x20
 mov x12,#(\third-1)
 madd x10,x12,x11,x10
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT3 reg,arg,second,third
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x11,[x9,#88]
 ldr x9,[x9]
 sub x12,\second,#1
 madd x10,x12,x10,x20
 mov x12,#(\third-1)
 madd x10,x12,x11,x10
 str \reg,[x9,x10,lsl #3]
.endm
.macro L reg,id
 ldr x9,[x27,#(\id*128)]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro LS reg,id
 ldr x9,[x27,#(\id*128)]
 str \reg,[x9,x20,lsl #3]
.endm
.macro L2 reg,id,col=x21
 ldr x9,[x27,#(\id*128)]
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro LS2 reg,id,col=x21
 ldr x9,[x27,#(\id*128)]
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro LI reg,id
 ldr x9,[x27,#(\id*128)]
 ldr \reg,[x9,x20,lsl #2]
.endm
.macro LIS reg,id
 ldr x9,[x27,#(\id*128)]
 str \reg,[x9,x20,lsl #2]
.endm
.macro CONST reg,name
 adr x9,.Lsu_\name
 ldr \reg,[x9]
.endm
.macro CALL name
 str x18,[sp,#2880]
 bl \name
 ldr x18,[sp,#2424]
.endm
.macro PLACE dest
 .if \dest<8
  mov x\dest,x9
 .else
  str x9,[sp,#((\dest-8)*8)]
 .endif
.endm
.macro PARG dest,arg
 ARG x9,\arg
 PLACE \dest
.endm
.macro DARG dest,id
 mov x9,#(\id*128)
 add x9,x27,x9
 PLACE \dest
.endm
.macro SARG dest,offset
 add x9,sp,#\offset
 PLACE \dest
.endm
.macro VIEW_BODY dest,slot
 add x13,sp,#(3072+\slot*64)
 str x9,[x13]
 mov x10,#-1
 str x10,[x13,#8]
 mov x10,#8
 str x10,[x13,#16]
 str x10,[x13,#32]
 movz x10,#0x0301,lsl #32
 str x10,[x13,#24]
 mov x10,#1
 str x10,[x13,#40]
 str x10,[x13,#48]
 str x22,[x13,#56]
 mov x9,x13
 PLACE \dest
.endm
.macro VARG dest,arg,slot,col=x21
 ARG x9,\arg
 ldr x10,[x9,#64]
 mul x10,\col,x10
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 VIEW_BODY \dest,\slot
.endm
.macro LVIEW dest,id,slot,col=x21
 ldr x9,[x27,#(\id*128)]
 mul x10,\col,x22
 add x9,x9,x10,lsl #3
 VIEW_BODY \dest,\slot
.endm
.macro ROWS label
 mov x20,x23
\label:
.endm
.macro NEXT label
 add x20,x20,#1
 cmp x20,x24
 b.lt \label
.endm
.macro CHECK arg,rank,kind,element,min2=1,min3=1
 ARG x9,\arg
 cbz x9,.Lsu_reject
 ldr x10,[x9,#16]
 cmp x10,#\element
 b.ne .Lsu_reject
 ldr x10,[x9,#32]
 cmp x10,#\element
 b.ne .Lsu_reject
 ldrb w10,[x9,#28]
 cmp w10,#\rank
 b.ne .Lsu_reject
 ldrb w10,[x9,#29]
 cmp w10,#\kind
 b.ne .Lsu_reject
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lsu_reject
 ldp x10,x11,[x9,#48]
 cmp x10,#1
 b.ne .Lsu_reject
 cmp x11,x22
 b.lt .Lsu_reject
 ldr x12,[x9,#8]
 add x12,x12,x10
 .if \rank>1
  ldr x13,[x9,#64]
  cmp x13,x11
  b.ne .Lsu_reject
  ldp x14,x15,[x9,#72]
  cmp x14,#1
  b.ne .Lsu_reject
  cmp x15,#\min2
  b.lt .Lsu_reject
  madd x12,x14,x13,x12
  .if \rank>2
   mul x13,x13,x15
   ldr x16,[x9,#88]
   cmp x13,x16
   b.ne .Lsu_reject
   ldp x14,x15,[x9,#96]
   cmp x14,#1
   b.ne .Lsu_reject
   cmp x15,#\min3
   b.lt .Lsu_reject
   madd x12,x14,x16,x12
  .endif
 .endif
 cbnz x12,.Lsu_reject
 ldr x10,[x9]
 cbz x10,.Lsu_reject
 tst x10,#(\element-1)
 b.ne .Lsu_reject
.endm
.global md2asm_surface_time_update_lake_partial_profile_r3_7358525
.type md2asm_surface_time_update_lake_partial_profile_r3_7358525,%function
.set md2asm_surface_time_update_lake_partial_profile_r3_7358525,md2asm_surface_time_update_lake_selected_range_r4_7358525
.global md2asm_surface_time_update_controller
.type md2asm_surface_time_update_controller,%function
.set md2asm_surface_time_update_controller,md2asm_surface_time_update_lake_selected_range_r4_7358525
.global md2asm_surface_time_update_lake_selected_range_r4_7358525
.type md2asm_surface_time_update_lake_selected_range_r4_7358525,%function
md2asm_surface_time_update_lake_selected_range_r4_7358525:
 mov x16,sp
 sub sp,sp,#3,lsl #12
 add x17,sp,#1024
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 stp d8,d9,[x17,#96]
 stp d10,d11,[x17,#112]
 stp d12,d13,[x17,#128]
 stp d14,d15,[x17,#144]
 str x18,[x17,#160]
 add x19,sp,#1280
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lsu_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#163
 b.lt .Lsu_arguments
 mrs x9,fpcr
 cbnz x9,.Lsu_reject
 ARG x9,2
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lsu_reject
 cmp w22,#4096
 b.gt .Lsu_reject
 ARG x9,0
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lsu_reject
 ARG x9,1
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lsu_reject
 cmp x24,x23
 b.le .Lsu_return
 ARG x9,3
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lsu_reject
 ARG x9,4
 ldr w9,[x9]
 cmp w9,#9
 b.ne .Lsu_reject
 ARG x9,5
 ldr w28,[x9]
 cmp w28,#1
 b.lt .Lsu_reject
 cmp w28,#64
 b.gt .Lsu_reject
 str w28,[sp,#2888]
 // Source-defined route guards. Missing controls remain unqualified.
 ARG x9,101
 ldr w10,[x9,#452]
 cmp w10,#1
 b.ne .Lsu_reject
 ldr w10,[x9,#440]
 cmp w10,#1
 b.ne .Lsu_reject
 ldr w10,[x9,#2396]
 cbnz w10,.Lsu_reject
 ARG x9,106
 ldr w10,[x9]
 cbnz w10,.Lsu_reject
 add x27,sp,#1,lsl #12
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lsu_reject
 str w9,[sp,#2700]
 cbz w9,.Lsu_entry_hook_done
 adr x0,.Lsu_hook_name
 add x1,sp,#2704
 str wzr,[x1]
 add x2,sp,#2712
 mov x3,#29
 CALL __yomhook_MOD_dr_hook_default8
.Lsu_entry_hook_done:
 ldr w28,[sp,#2888]
 mov x9,#4
 mul x9,x28,x9
 add x9,x9,#77
 mov x0,x22
 lsl x1,x9,#3
 CALL calloc
 cbz x0,.Lsu_reject
 mov x25,x0
 str x25,[sp,#2736]
 mov x26,#0
.Lsu_local_descriptors:
 adr x9,.Lsu_local_specs
 mov x10,#8
 madd x9,x26,x10,x9
 ldp w10,w11,[x9]
 cmp w10,#0
 csel w10,w28,w10,eq
 add x13,x27,x26,lsl #7
 str x25,[x13]
 mov x16,#8
 str x16,[x13,#16]
 str x16,[x13,#32]
 movz x17,#0x0300,lsl #32
 orr x17,x17,x11,lsl #32
 str x17,[x13,#24]
 mov x17,#1
 str x17,[x13,#40]
 str x17,[x13,#48]
 str x22,[x13,#56]
 mov x16,#-1
 cmp w11,#1
 b.eq .Lsu_local_bias
 str x22,[x13,#64]
 mov x17,#1
 str x17,[x13,#72]
 str x10,[x13,#80]
 sub x16,x16,x22
.Lsu_local_bias:
 str x16,[x13,#8]
 mul x10,x10,x22
 add x25,x25,x10,lsl #3
 add x26,x26,#1
 cmp x26,#38
 b.lt .Lsu_local_descriptors
 CONST d0,one
 ARG x9,14
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[sp,#2720]
 CONST d0,one
 adrp x9,:got:__yos_thf_MOD_rhoh2o
 ldr x9,[x9,:got_lo12:__yos_thf_MOD_rhoh2o]
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[sp,#2728]
 // Layer water depths and selected longwave tile flux.
 mov x21,#0
.Lsu_depth_layer:
 ARG x9,101
 ldr x9,[x9,#1648]
 ldr d3,[x9,x21,lsl #3]
 ROWS .Lsu_depth_row
 LS2 d3,26
 NEXT .Lsu_depth_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lsu_depth_layer
 mov x21,#0
.Lsu_longwave_tile:
 ROWS .Lsu_longwave_row
 ARG x9,100
 ldr w9,[x9,#4]
 cbz w9,.Lsu_longwave_column
 IN2 d0,23
 b .Lsu_longwave_store
.Lsu_longwave_column:
 IN d0,63
.Lsu_longwave_store:
 LS2 d0,27
 NEXT .Lsu_longwave_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsu_longwave_tile
 ROWS .Lsu_precipitation_row
 fmov d1,xzr
 OUT d1,110
 IN d0,61
 fmax d0,d1,d0
 LS d0,16
 IN d0,62
 fmax d0,d1,d0
 LS d0,17
 IN d0,64
 fmax d0,d1,d0
 LS d0,18
 IN d0,65
 fmax d0,d1,d0
 LS d0,19
 NEXT .Lsu_precipitation_row
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,3
 PARG 4,34
 PARG 5,35
 PARG 6,46
 PARG 7,13
 PARG 8,66
 PARG 9,67
 PARG 10,99
 PARG 11,101
 PARG 12,114
 CALL md2asm_soil_energy_support_7358525
 PARG 0,0
 PARG 1,1
 PARG 2,4
 PARG 3,14
 PARG 4,48
 PARG 5,66
 PARG 6,67
 PARG 7,69
 PARG 8,16
 PARG 9,21
 DARG 10,16
 DARG 11,17
 PARG 12,70
 DARG 13,6
 DARG 14,20
 DARG 15,14
 DARG 16,15
 DARG 17,25
 PARG 18,34
 PARG 19,101
 PARG 20,102
 PARG 21,159
 CALL md2asm_surface_interception_private_7358525
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,5
 PARG 4,14
 PARG 5,34
 PARG 6,15
 PARG 7,39
 PARG 8,40
 PARG 9,42
 PARG 10,43
 PARG 11,41
 PARG 12,16
 PARG 13,46
 PARG 14,71
 PARG 15,72
 PARG 16,73
 DARG 17,18
 DARG 18,19
 DARG 19,14
 DARG 20,15
 PARG 21,23
 PARG 22,22
 PARG 23,20
 PARG 24,21
 PARG 25,70
 PARG 26,49
 PARG 27,13
 PARG 28,44
 PARG 29,101
 PARG 30,99
 DARG 31,0
 DARG 32,1
 DARG 33,3
 DARG 34,8
 DARG 35,2
 DARG 36,22
 DARG 37,23
 DARG 38,24
 PARG 39,155
 PARG 40,158
 CALL md2asm_multilayer_snow_driver
 // Imposed permanent-snow mass boundary, after the full snow child.
 ROWS .Lsu_glacier_row
 fmov d3,xzr
 mov x21,#0
 ARG x9,39
 ldr x28,[x9,#80]
.Lsu_old_snow_mass:
 IN2 d0,39
 fadd d3,d3,d0
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lsu_old_snow_mass
 CONST d0,permanent_snow_threshold
 fcmp d3,d0
 b.lt .Lsu_glacier_next
 ARG x9,101
 ldr d0,[x9,#328]
 LS d0,2
 ARG x9,101
 ldr w9,[x9,#2412]
 cbnz w9,.Lsu_glacier_next
 ARG x9,101
 ldr d4,[x9,#360]
 ldr w28,[sp,#2888]
 mov x21,#0
.Lsu_glacier_density_layer:
 LS2 d4,3
 fmov d0,xzr
 LS2 d0,8
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lsu_glacier_density_layer
 fmov d3,xzr
 mov x21,#0
 sub x28,x28,#1
.Lsu_glacier_sum_layer:
 cmp x21,x28
 b.ge .Lsu_glacier_last_mass
 L2 d0,0
 fadd d3,d3,d0
 add x21,x21,#1
 b .Lsu_glacier_sum_layer
.Lsu_glacier_last_mass:
 CONST d0,glacier_mass
 fsub d0,d0,d3
 LS2 d0,0
.Lsu_glacier_next:
 NEXT .Lsu_glacier_row
 // Apparent heat capacity, soil temperature and optional sea-ice temperature.
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,4
 PARG 4,3
 PARG 5,34
 PARG 6,35
 PARG 7,46
 PARG 8,13
 PARG 9,66
 PARG 10,67
 PARG 11,68
 PARG 12,99
 PARG 13,101
 PARG 14,104
 DARG 15,13
 CALL md2asm_srfrcg
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,4
 PARG 4,3
 PARG 5,14
 PARG 6,46
 PARG 7,49
 PARG 8,13
 PARG 9,16
 PARG 10,20
 PARG 11,21
 DARG 12,27
 PARG 13,22
 DARG 14,22
 DARG 15,13
 PARG 16,34
 PARG 17,99
 PARG 18,101
 PARG 19,103
 PARG 20,104
 DARG 21,4
 PARG 22,108
 PARG 23,156
 CALL md2asm_srft
 ARG x9,36
 ldr w9,[x9]
 cbz w9,.Lsu_unchanged_sea_ice
 mov x21,#1
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,3
 PARG 4,7
 PARG 5,14
 PARG 6,47
 PARG 7,16
 PARG 8,20
 PARG 9,21
 LVIEW 10,27,0
 PARG 11,22
 PARG 12,35
 PARG 13,37
 PARG 14,99
 PARG 15,101
 DARG 16,5
 PARG 17,157
 CALL md2asm_sea_ice_temperature_private_7358525
 b .Lsu_sea_ice_done
.Lsu_unchanged_sea_ice:
 mov x21,#0
.Lsu_unchanged_ice_layer:
 ROWS .Lsu_unchanged_ice_row
 IN2 d0,47
 LS2 d0,5
 ARG x9,157
 bl .Lsu_diagnostic_present
 cbz w10,.Lsu_unchanged_ice_next
 fmov d0,xzr
 add x28,x21,#1
 OUT3 d0,157,x28,1
 OUT3 d0,157,x28,2
 OUT3 d0,157,x28,3
 OUT3 d0,157,x28,4
 OUT3 d0,157,x28,9
 OUT3 d0,157,x28,10
 OUT3 d0,157,x28,11
 OUT3 d0,157,x28,12
.Lsu_unchanged_ice_next:
 NEXT .Lsu_unchanged_ice_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lsu_unchanged_ice_layer
.Lsu_sea_ice_done:
 // Complete selected soil water calculation and final bottom drainage.
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,3
 PARG 4,4
 PARG 5,14
 PARG 6,10
 PARG 7,11
 PARG 8,13
 PARG 9,15
 PARG 10,16
 PARG 11,21
 PARG 12,49
 PARG 13,46
 PARG 14,68
 DARG 15,14
 DARG 16,15
 DARG 17,23
 DARG 18,24
 DARG 19,25
 PARG 20,70
 PARG 21,101
 PARG 22,102
 PARG 23,104
 PARG 24,110
 DARG 25,9
 DARG 26,10
 DARG 27,12
 DARG 28,20
 DARG 29,21
 PARG 30,34
 PARG 31,160
 CALL md2asm_soil_water_exchange
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,3
 PARG 4,49
 DARG 5,9
 DARG 6,10
 DARG 7,26
 PARG 8,101
 DARG 9,11
 PARG 10,34
 CALL md2asm_surface_soil_diffusion_private_7358525
 PARG 0,0
 PARG 1,1
 PARG 2,3
 PARG 3,14
 PARG 4,49
 DARG 5,11
 DARG 6,12
 DARG 7,9
 PARG 8,101
 DARG 9,7
 PARG 10,111
 PARG 11,34
 PARG 12,160
 CALL md2asm_surface_soil_increment_private_7358525
 PARG 0,0
 PARG 1,1
 PARG 2,3
 PARG 3,14
 PARG 4,13
 DARG 5,6
 PARG 6,69
 DARG 7,7
 PARG 8,101
 PARG 9,110
 PARG 10,109
 PARG 11,111
 PARG 12,34
 PARG 13,160
 CALL md2asm_surface_water_correction_private_7358525
 ROWS .Lsu_bottom_drainage
 ARG x9,34
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 cbz w11,.Lsu_bottom_drainage_next
 mov x21,#3
 L2 d0,12
 ARG x9,14
 ldr d1,[x9]
 fmul d0,d0,d1
 IN d1,109
 fadd d0,d1,d0
 OUT d0,109
.Lsu_bottom_drainage_next:
 NEXT .Lsu_bottom_drainage
 // Complete revised-child lake driver or unchanged old lake state.
 ARG x9,103
 ldr w9,[x9,#848]
 cbz w9,.Lsu_unchanged_lake
 mov x21,#8
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,59
 VARG 4,22,0
 LVIEW 5,27,1
 VARG 6,20,2
 VARG 7,21,3
 VARG 8,18,4
 VARG 9,19,5
 PARG 10,16
 PARG 11,58
 PARG 12,57
 PARG 13,14
 PARG 14,99
 PARG 15,103
 PARG 16,50
 PARG 17,51
 PARG 18,52
 PARG 19,53
 PARG 20,54
 PARG 21,55
 PARG 22,56
 DARG 23,28
 DARG 24,29
 DARG 25,30
 DARG 26,31
 DARG 27,32
 DARG 28,33
 DARG 29,34
 CALL md2asm_flake_driver_partial_profile_r3_7358525
 b .Lsu_lake_done
.Lsu_unchanged_lake:
 ROWS .Lsu_unchanged_lake_row
 IN d0,50
 LS d0,28
 IN d0,51
 LS d0,29
 IN d0,52
 LS d0,30
 IN d0,53
 LS d0,31
 IN d0,54
 LS d0,32
 IN d0,55
 LS d0,33
 IN d0,56
 LS d0,34
 NEXT .Lsu_unchanged_lake_row
.Lsu_lake_done:
 // Meaningful lake proxies on ocean cells and resolved lake soil temperature.
 ROWS .Lsu_ocean_proxy_row
 ARG x9,34
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 cbnz w11,.Lsu_ocean_proxy_next
 ARG x9,59
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 cbnz w11,.Lsu_resolved_lake_temperature
 IN d0,17
 ARG x9,99
 ldr d1,[x9]
 fmax d0,d0,d1
 LS d0,30
 LS d0,29
 LS d0,31
 CONST d0,proxy_shape
 LS d0,32
 mov x21,#0
 L2 d0,5
 LS d0,28
 ARG x9,35
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 cbz w11,.Lsu_ocean_ice_zero
 mov x21,#1
 IN2 d0,16
 CONST d1,ten
 fdiv d0,d0,d1
 CONST d1,proxy_ice_cap
 fmin d0,d0,d1
 b .Lsu_ocean_ice_store
.Lsu_ocean_ice_zero:
 fmov d0,xzr
.Lsu_ocean_ice_store:
 LS d0,33
 IN d0,58
 CONST d1,proxy_depth_cap
 fmin d0,d0,d1
 LS d0,34
 b .Lsu_ocean_proxy_next
.Lsu_resolved_lake_temperature:
 L d0,30
 mov x21,#0
.Lsu_resolved_lake_layer:
 LS2 d0,4
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lsu_resolved_lake_layer
.Lsu_ocean_proxy_next:
 NEXT .Lsu_ocean_proxy_row
 // LOCMLTKE was explicitly guarded before writes. No ocean numerical fallback.
 // Add complete trial changes to the incoming rates in source order.
 mov x21,#0
.Lsu_snow_rate_layer:
 ROWS .Lsu_snow_rate_row
 L2 d0,0
 IN2 d1,39
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,132
 fadd d0,d1,d0
 OUT2 d0,132
 L2 d0,1
 IN2 d1,40
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,133
 fadd d0,d1,d0
 OUT2 d0,133
 L2 d0,3
 IN2 d1,42
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,135
 fadd d0,d1,d0
 OUT2 d0,135
 L2 d0,8
 IN2 d1,43
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,136
 fadd d0,d1,d0
 OUT2 d0,136
 NEXT .Lsu_snow_rate_row
 add x21,x21,#1
 ldr w9,[sp,#2888]
 cmp x21,x9
 b.lt .Lsu_snow_rate_layer
 ROWS .Lsu_lake_and_albedo_rates
 L d0,2
 IN d1,41
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,134
 fadd d0,d1,d0
 OUT d0,134
 L d0,28
 IN d1,50
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,141
 fadd d0,d1,d0
 OUT d0,141
 L d0,29
 IN d1,51
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,142
 fadd d0,d1,d0
 OUT d0,142
 L d0,30
 IN d1,52
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,143
 fadd d0,d1,d0
 OUT d0,143
 L d0,31
 IN d1,53
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,144
 fadd d0,d1,d0
 OUT d0,144
 L d0,32
 IN d1,54
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,145
 fadd d0,d1,d0
 OUT d0,145
 L d0,33
 IN d1,55
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,146
 fadd d0,d1,d0
 OUT d0,146
 L d0,34
 IN d1,56
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,147
 fadd d0,d1,d0
 OUT d0,147
 NEXT .Lsu_lake_and_albedo_rates
 mov x21,#0
.Lsu_ice_rate_layer:
 ROWS .Lsu_ice_rate_row
 L2 d0,5
 IN2 d1,47
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,138
 fadd d0,d1,d0
 OUT2 d0,138
 NEXT .Lsu_ice_rate_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lsu_ice_rate_layer
 mov x21,#0
.Lsu_soil_heat_rate_layer:
 ROWS .Lsu_soil_heat_rate_row
 mov x28,#8
 IN2 d0,16,x28
 fcmp d0,#0.0
 b.le .Lsu_soil_heat_without_lake
 L2 d0,4
 IN2 d1,46
 fsub d0,d0,d1
 b .Lsu_soil_heat_change_ready
.Lsu_soil_heat_without_lake:
 L2 d0,5
 IN2 d1,47
 fsub d0,d0,d1
 mov x28,#1
 IN2 d1,16,x28
 fmul d3,d1,d0
 CONST d0,one
 mov x28,#0
 IN2 d1,16,x28
 fsub d0,d0,d1
 mov x28,#1
 IN2 d1,16,x28
 fsub d0,d0,d1
 L2 d1,4
 IN2 d2,46
 fsub d1,d1,d2
 fmul d0,d0,d1
 fadd d0,d3,d0
.Lsu_soil_heat_change_ready:
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,137
 fadd d0,d1,d0
 OUT2 d0,137
 NEXT .Lsu_soil_heat_rate_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lsu_soil_heat_rate_layer
 ROWS .Lsu_interception_rate_row
 L d0,6
 IN d1,48
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN d1,139
 fadd d0,d1,d0
 OUT d0,139
 NEXT .Lsu_interception_rate_row
 mov x21,#0
.Lsu_soil_water_rate_layer:
 ROWS .Lsu_soil_water_rate_row
 L2 d0,7
 IN2 d1,49
 fsub d0,d0,d1
 ldr d1,[sp,#2720]
 fmul d0,d0,d1
 IN2 d1,140
 fadd d0,d1,d0
 OUT2 d0,140
 NEXT .Lsu_soil_water_rate_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lsu_soil_water_rate_layer
 ROWS .Lsu_final_diagnostics
 L d0,20
 L d1,21
 fadd d0,d0,d1
 OUT d0,113
 ldr d1,[sp,#2720]
 IN d0,110
 fmul d0,d0,d1
 OUT d0,110
 IN d0,109
 fmul d0,d0,d1
 OUT d0,109
 IN d0,108
 fneg d0,d0
 OUT d0,108
 L d0,23
 OUT d0,112
 NEXT .Lsu_final_diagnostics
 ARG x9,101
 ldr w9,[x9,#2388]
 cbz w9,.Lsu_resolved_lake_runoff_done
 ROWS .Lsu_resolved_lake_runoff_row
 ARG x9,34
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 cbnz w11,.Lsu_resolved_lake_runoff_calving
 ARG x9,59
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 cbz w11,.Lsu_resolved_lake_runoff_calving
 IN d0,110
 L d1,16
 fadd d0,d0,d1
 L d1,17
 fadd d0,d0,d1
 L d1,18
 fadd d0,d0,d1
 L d1,19
 fadd d0,d0,d1
 OUT d0,110
.Lsu_resolved_lake_runoff_calving:
 IN d0,110
 L d1,35
 fadd d0,d0,d1
 OUT d0,110
 NEXT .Lsu_resolved_lake_runoff_row
.Lsu_resolved_lake_runoff_done:
 ARG x9,102
 ldr w9,[x9,#756]
 cbz w9,.Lsu_vegetation_disabled
 PARG 0,0
 PARG 1,1
 PARG 2,2
 PARG 3,3
 PARG 4,9
 PARG 5,14
 PARG 6,24
 ARG x9,27
 VIEW_BODY 7,0
 PARG 8,28
 PARG 9,66
 PARG 10,67
 PARG 11,12
 PARG 12,10
 PARG 13,11
 PARG 14,45
 PARG 15,46
 PARG 16,25
 PARG 17,26
 PARG 18,29
 PARG 19,30
 PARG 20,31
 PARG 21,32
 PARG 22,33
 PARG 23,119
 PARG 24,120
 PARG 25,121
 PARG 26,122
 PARG 27,123
 PARG 28,124
 PARG 29,125
 PARG 30,152
 PARG 31,153
 PARG 32,154
 PARG 33,126
 PARG 34,127
 PARG 35,128
 PARG 36,129
 PARG 37,130
 PARG 38,131
 PARG 39,161
 PARG 40,162
 PARG 41,99
 PARG 42,102
 PARG 43,105
 CALL md2asm_srfvegevol_7240564
 b .Lsu_vegetation_done
.Lsu_vegetation_disabled:
 ROWS .Lsu_inactive_vegetation_row
 IN d0,66
 IN d1,30
 fmul d0,d0,d1
 IN d1,67
 IN d2,31
 fmul d1,d1,d2
 fadd d0,d0,d1
 OUT d0,126
 fmov d0,xzr
 OUT d0,127
 OUT d0,128
 OUT d0,129
 OUT d0,130
 OUT d0,131
 NEXT .Lsu_inactive_vegetation_row
 ARG x9,161
 bl .Lsu_diagnostic_present
 cbz w10,.Lsu_vegetation_done
 ARG x9,102
 ldr w26,[x9,#4]
 mov x28,#1
.Lsu_inactive_biomass_tile:
 cmp x28,x26
 b.gt .Lsu_vegetation_done
 ROWS .Lsu_inactive_biomass_row
 fmov d0,xzr
 OUT3 d0,161,x28,1
 OUT3 d0,161,x28,2
 OUT3 d0,161,x28,3
 OUT3 d0,161,x28,4
 OUT3 d0,161,x28,5
 NEXT .Lsu_inactive_biomass_row
 add x28,x28,#1
 b .Lsu_inactive_biomass_tile
.Lsu_vegetation_done:
 // Source interactive budget printing is outside LEWBCHECK0 scope.
 ldr x0,[sp,#2736]
 CALL free
 ldr w9,[sp,#2700]
 cbz w9,.Lsu_return
 adr x0,.Lsu_hook_name
 add x1,sp,#2704
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2712
 mov x3,#29
 CALL __yomhook_MOD_dr_hook_default8
.Lsu_return:
 add x17,sp,#1024
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldp d8,d9,[x17,#96]
 ldp d10,d11,[x17,#112]
 ldp d12,d13,[x17,#128]
 ldp d14,d15,[x17,#144]
 ldr x18,[x17,#160]
 add sp,sp,#3,lsl #12
 ret
.Lsu_reject:
 brk #0x534
.size md2asm_surface_time_update_lake_selected_range_r4_7358525,.-md2asm_surface_time_update_lake_selected_range_r4_7358525
.Lsu_diagnostic_present:
 ldp x10,x11,[x9,#48]
 cmp x11,x10
 b.lt .Lsu_diagnostic_empty
 ldp x10,x11,[x9,#72]
 cmp x11,x10
 b.lt .Lsu_diagnostic_empty
 ldp x10,x11,[x9,#96]
 cmp x11,x10
 cset w10,ge
 ret
.Lsu_diagnostic_empty:
 mov w10,#0
 ret
.section .rodata
.p2align 3
.Lsu_one: .double 1.0
.Lsu_ten: .double 10.0
.Lsu_permanent_snow_threshold: .double 9000.0
.Lsu_glacier_mass: .double 10000.0
.Lsu_proxy_shape: .double 0.65
.Lsu_proxy_ice_cap: .double 0.1
.Lsu_proxy_depth_cap: .double 50.0
.Lsu_hook_name: .ascii "SURFTSTP_CTL_MOD:SURFTSTP_CTL"
.p2align 2
.Lsu_local_specs:
 .word 0,2
 .word 0,2
 .word 1,1
 .word 0,2
 .word 4,2
 .word 4,2
 .word 1,1
 .word 4,2
 .word 0,2
 .word 4,2
 .word 4,2
 .word 4,2
 .word 4,2
 .word 4,2
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 9,2
 .word 4,2
 .word 9,2
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
 .word 1,1
.section .note.GNU-stack,"",%progbits

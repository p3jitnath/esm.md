// Direct DIAG_CLOUDS from cloud_weather_diagnostics_contract.md.
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro IN reg,arg
 ARG x9,\arg
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro OUT reg,arg
 ARG x9,\arg
 str \reg,[x9,x20,lsl #3]
.endm
.macro IN2 reg,arg,col=x21
 ARG x9,\arg
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg,arg,col=x21
 ARG x9,\arg
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro L reg,id
 ldr x9,[sp,#(1792+\id*8)]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro LS reg,id
 ldr x9,[sp,#(1792+\id*8)]
 str \reg,[x9,x20,lsl #3]
.endm
.macro LI reg,id
 ldr x9,[sp,#(1792+\id*8)]
 ldr \reg,[x9,x20,lsl #2]
.endm
.macro LIS reg,id
 ldr x9,[sp,#(1792+\id*8)]
 str \reg,[x9,x20,lsl #2]
.endm
.macro L2 reg,id,col=x21
 ldr x9,[sp,#(1792+\id*8)]
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro LS2 reg,id,col=x21
 ldr x9,[sp,#(1792+\id*8)]
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro LBOOL reg,plane
 ldr x9,[sp,#1808]
 mov x10,#\plane
 madd x10,x10,x22,x20
 ldr \reg,[x9,x10,lsl #2]
.endm
.macro LSBOOL reg,plane
 ldr x9,[sp,#1808]
 mov x10,#\plane
 madd x10,x10,x22,x20
 str \reg,[x9,x10,lsl #2]
.endm
.macro CONST reg,name
 adr x9,.Ldg_\name
 ldr \reg,[x9]
.endm
.macro GLOBAL reg,module,name
 adrp x9,:got:__\module\()_MOD_\name
 ldr x9,[x9,:got_lo12:__\module\()_MOD_\name]
 ldr \reg,[x9]
.endm
.macro CALL name
 str x18,[sp,#1688]
 bl \name
 ldr x18,[sp,#1688]
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
.global md2asm_cloud_weather_diagnostics_phase_sign_r1_7388001
.type md2asm_cloud_weather_diagnostics_phase_sign_r1_7388001,%function
md2asm_cloud_weather_diagnostics_phase_sign_r1_7388001:
 mov x16,sp
 sub sp,sp,#1,lsl #12
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
.Ldg_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#35
 b.lt .Ldg_arguments
 mrs x9,fpcr
 cbnz x9,.Ldg_reject
 ARG x25,0
 ARG x9,3
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Ldg_reject
 cmp w22,#4096
 b.gt .Ldg_reject
 ARG x9,4
 ldr w28,[x9]
 cmp w28,#3
 b.lt .Ldg_reject
 cmp w28,#512
 b.gt .Ldg_reject
 ARG x9,1
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Ldg_reject
 ARG x9,2
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Ldg_reject
 cmp x24,x23
 b.le .Ldg_reject
 ARG x9,5
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ldg_reject
 str w9,[sp,#1680]
 // The source index slots are qualified by original module layout metadata.
 cbz w9,.Ldg_index_guards_done
 ldr w9,[x25,#312]
 cmp w9,#1
 b.lt .Ldg_reject
 cmp w9,w28
 b.gt .Ldg_reject
 str w9,[sp,#1632]
 ldr w9,[x25,#320]
 cmp w9,#1
 b.lt .Ldg_reject
 cmp w9,w28
 b.gt .Ldg_reject
 str w9,[sp,#1636]
 ldr w9,[x25,#324]
 cmp w9,#1
 b.lt .Ldg_reject
 cmp w9,w28
 b.gt .Ldg_reject
 str w9,[sp,#1640]
 ldr w9,[x25,#328]
 cmp w9,#1
 b.lt .Ldg_reject
 cmp w9,w28
 b.gt .Ldg_reject
 str w9,[sp,#1644]
 ROWS .Ldg_convective_index_guard
 ARG x9,6
 ldr w9,[x9,x20,lsl #2]
 cbz w9,.Ldg_convective_index_guard_next
 ARG x9,7
 ldr w9,[x9,x20,lsl #2]
 cmp w9,#1
 b.lt .Ldg_reject
 add w10,w28,#1
 cmp w9,w10
 b.gt .Ldg_reject
 ARG x9,8
 ldr w9,[x9,x20,lsl #2]
 cmp w9,#1
 b.lt .Ldg_reject
 cmp w9,w10
 b.gt .Ldg_reject
.Ldg_convective_index_guard_next:
 NEXT .Ldg_convective_index_guard
.Ldg_index_guards_done:
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ldg_reject
 str w9,[sp,#1664]
 cbz w9,.Ldg_entry_hook_done
 adr x0,.Ldg_hook_name
 add x1,sp,#1668
 str wzr,[x1]
 add x2,sp,#1672
 mov x3,#11
 CALL __yomhook_MOD_dr_hook_default8
.Ldg_entry_hook_done:
 // Integer allocation and layout of seven scratch owners.
 mov x0,#8
 madd x0,x28,x0,xzr
 add x0,x0,#44
 mul x0,x0,x22
 add x0,x0,#112
 CALL malloc
 cbz x0,.Ldg_reject
 str x0,[sp,#1656]
 mov x11,x0
 str x11,[sp,#1792]
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#1800]
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#1808]
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#1816]
 add x11,x11,x22,lsl #2
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#1824]
 add x11,x11,x22,lsl #2
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#1832]
 add x11,x11,x22,lsl #2
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#1840]
 CONST d0,one
 GLOBAL d1,yomcst,rg
 fdiv d8,d0,d1
 GLOBAL d0,yomcst,rtt
 CONST d1,ten
 fsub d9,d0,d1
 ldr d10,[x25,#232]
 ROWS .Ldg_initial_row
 OUT d10,25
 OUT d10,26
 OUT d10,27
 LS d10,0
 LS d10,1
 fmov d0,xzr
 OUT d0,28
 OUT d0,29
 OUT d0,31
 OUT d0,32
 OUT d0,34
 mov x21,#0
 OUT2 d0,30
 OUT2 d0,33
 mov x21,#1
 OUT2 d0,30
 OUT2 d0,33
 NEXT .Ldg_initial_row
 ldr w9,[sp,#1680]
 cbz w9,.Ldg_precipitation
 ROWS .Ldg_convective_row
 mov w11,#1
 LSBOOL w11,0
 LSBOOL w11,1
 mov w11,#0
 LIS w11,3
 LIS w11,4
 ARG x9,6
 ldr w9,[x9,x20,lsl #2]
 cbz w9,.Ldg_convective_next
 ARG x9,7
 ldrsw x21,[x9,x20,lsl #2]
 sub x21,x21,#1
 IN2 d0,12
 fmul d0,d0,d8
 LS d0,0
 ARG x9,8
 ldrsw x21,[x9,x20,lsl #2]
 sub x21,x21,#1
 IN2 d0,12
 fmul d0,d0,d8
 OUT d0,27
.Ldg_convective_next:
 NEXT .Ldg_convective_row
 sub x21,x28,#2
 ldrsw x26,[sp,#1632]
 sub x26,x26,#1
 cmp x21,x26
 b.lt .Ldg_vertical_done
.Ldg_vertical_level:
 ROWS .Ldg_stratiform_row
 LBOOL w11,0
 cbz w11,.Ldg_stratiform_next
 IN2 d0,17
 CONST d1,cloud_fraction
 fcmp d0,d1
 b.le .Ldg_stratiform_next
 IN2 d0,15
 IN2 d1,16
 fadd d0,d0,d1
 CONST d1,condensate
 fcmp d0,d1
 b.le .Ldg_stratiform_next
 IN2 d0,11
 fmul d0,d0,d8
 LS d0,1
 mov w11,#0
 LSBOOL w11,0
.Ldg_stratiform_next:
 NEXT .Ldg_stratiform_row
 ROWS .Ldg_aviation_row
 LBOOL w11,1
 cbz w11,.Ldg_aviation_next
 IN2 d0,17
 CONST d1,half
 fcmp d0,d1
 b.le .Ldg_aviation_next
 IN2 d0,11
 fmul d0,d0,d8
 OUT d0,26
 mov w11,#0
 LSBOOL w11,1
.Ldg_aviation_next:
 NEXT .Ldg_aviation_row
 ROWS .Ldg_temperature_crossing_row
 LI w11,3
 cmp w11,#2
 b.ge .Ldg_minus_ten_crossing
 add x27,x21,#1
 IN2 d0,13,x27
 GLOBAL d1,yomcst,rtt
 fcmp d0,d1
 b.le .Ldg_minus_ten_crossing
 IN2 d2,13
 fcmp d2,d1
 b.vs .Ldg_minus_ten_crossing
 b.gt .Ldg_minus_ten_crossing
 fsub d3,d1,d0
 IN2 d4,11
 IN2 d5,11,x27
 fsub d4,d4,d5
 fmul d3,d3,d4
 fsub d2,d2,d0
 CONST d4,negative_floor
 fmin d2,d4,d2
 fdiv d3,d3,d2
 fadd d3,d5,d3
 fmul d3,d3,d8
 OUT d3,28
 add w11,w11,#1
 LIS w11,3
.Ldg_minus_ten_crossing:
 LI w11,4
 cmp w11,#2
 b.ge .Ldg_temperature_crossing_next
 add x27,x21,#1
 IN2 d0,13,x27
 fcmp d0,d9
 b.le .Ldg_temperature_crossing_next
 IN2 d2,13
 fcmp d2,d9
 b.vs .Ldg_temperature_crossing_next
 b.gt .Ldg_temperature_crossing_next
 fsub d3,d9,d0
 IN2 d4,11
 IN2 d5,11,x27
 fsub d4,d4,d5
 fmul d3,d3,d4
 fsub d2,d2,d0
 CONST d4,negative_floor
 fmin d2,d4,d2
 fdiv d3,d3,d2
 fadd d3,d5,d3
 fmul d3,d3,d8
 OUT d3,29
 add w11,w11,#1
 LIS w11,4
.Ldg_temperature_crossing_next:
 NEXT .Ldg_temperature_crossing_row
 sub x21,x21,#1
 cmp x21,x26
 b.ge .Ldg_vertical_level
.Ldg_vertical_done:
 ROWS .Ldg_cloud_base_row
 L d0,1
 OUT d0,25
 L d1,0
 fcmp d1,d10
 b.vs .Ldg_cloud_base_next
 b.ge .Ldg_cloud_base_next
 fcmp d0,d10
 b.vs .Ldg_cloud_base_next
 b.ge .Ldg_cloud_base_next
 fmin d0,d1,d0
 OUT d0,25
.Ldg_cloud_base_next:
 NEXT .Ldg_cloud_base_row
 CONST d0,one
 GLOBAL d1,yoethf,r2es
 fdiv d11,d0,d1
 ROWS .Ldg_index_row
 ldrsw x21,[sp,#1636]
 sub x21,x21,#1
 IN2 d0,14
 CONST d1,humidity_floor
 fmax d0,d1,d0
 IN2 d1,9
 fmul d0,d0,d1
 fmul d0,d0,d11
 CALL log
 GLOBAL d1,yoethf,r4les
 fmul d1,d1,d0
 GLOBAL d2,yoethf,r3les
 GLOBAL d3,yomcst,rtt
 fmul d3,d2,d3
 fsub d1,d1,d3
 fsub d0,d0,d2
 fdiv d12,d1,d0
 IN2 d0,13
 fadd d0,d0,d12
 ldrsw x21,[sp,#1640]
 sub x21,x21,#1
 IN2 d1,13
 CONST d2,two
 fmul d1,d2,d1
 fsub d0,d0,d1
 mov x21,#0
 OUT2 d0,30
 ldrsw x21,[sp,#1644]
 sub x21,x21,#1
 IN2 d0,14
 CONST d1,humidity_floor
 fmax d0,d1,d0
 IN2 d1,9
 fmul d0,d0,d1
 fmul d0,d0,d11
 CALL log
 GLOBAL d1,yoethf,r4les
 fmul d1,d1,d0
 GLOBAL d2,yoethf,r3les
 GLOBAL d3,yomcst,rtt
 fmul d3,d2,d3
 fsub d1,d1,d3
 fsub d0,d0,d2
 fdiv d13,d1,d0
 ldrsw x21,[sp,#1636]
 sub x21,x21,#1
 IN2 d0,13
 ldrsw x21,[sp,#1640]
 sub x21,x21,#1
 IN2 d1,13
 fsub d0,d0,d1
 fadd d0,d0,d12
 ldrsw x21,[sp,#1644]
 sub x21,x21,#1
 IN2 d1,13
 fsub d0,d0,d1
 fadd d0,d0,d13
 GLOBAL d1,yomcst,rtt
 fsub d0,d0,d1
 mov x21,#1
 OUT2 d0,30
 mov w11,#0
 LIS w11,3
 NEXT .Ldg_index_row

 sub x21,x28,#1
.Ldg_wet_level:
 add x27,x21,#1
 sub x9,x28,#1
 cmp x27,x9
 csel x27,x27,x9,lt
 ROWS .Ldg_wet_row
 IN2 d0,9
 CONST d1,wet_pressure
 fcmp d0,d1
 b.le .Ldg_wet_next
 LI w11,3
 cmp w11,#2
 b.ge .Ldg_wet_next
 IN2 d0,13
 bl .Ldg_saturation_pressure
 IN2 d1,9
 fdiv d0,d0,d1
 CONST d1,half
 fmin d0,d0,d1
 GLOBAL d1,yomcst,retv
 fmul d1,d1,d0
 CONST d2,one
 fsub d1,d2,d1
 fdiv d0,d0,d1
 IN2 d1,14
 fsub d0,d0,d1
 fmov d1,xzr
 fmax d0,d0,d1
 IN2 d1,9
 CONST d2,wet3
 fsub d1,d1,d2
 CONST d2,wet2
 fmul d1,d2,d1
 CONST d2,wet1
 fadd d1,d2,d1
 IN2 d2,13
 CONST d3,wet5
 fsub d3,d2,d3
 CONST d4,wet4
 fmul d3,d4,d3
 fsub d1,d1,d3
 fmul d0,d0,d1
 fsub d0,d2,d0
 GLOBAL d1,yomcst,rtt
 fsub d0,d0,d1
 LS2 d0,6
 sub x9,x28,#1
 cmp x21,x9
 b.eq .Ldg_wet_next
 L2 d1,6,x27
 fcmp d1,#0.0
 b.le .Ldg_one_degree_crossing
 fcmp d0,#0.0
 b.gt .Ldg_one_degree_crossing
 b.vs .Ldg_one_degree_crossing
 fneg d2,d1
 IN2 d3,11
 IN2 d4,11,x27
 fsub d3,d3,d4
 fmul d2,d2,d3
 fsub d3,d0,d1
 CONST d5,negative_floor
 fmin d3,d5,d3
 fdiv d2,d2,d3
 fadd d2,d4,d2
 fmul d2,d2,d8
 mov x26,#0
 OUT2 d2,33,x26
 LI w11,3
 add w11,w11,#1
 LIS w11,3
.Ldg_one_degree_crossing:
 CONST d2,one
 fcmp d1,d2
 b.le .Ldg_wet_next
 fcmp d0,d2
 b.gt .Ldg_wet_next
 b.vs .Ldg_wet_next
 fsub d2,d2,d1
 IN2 d3,11
 IN2 d4,11,x27
 fsub d3,d3,d4
 fmul d2,d2,d3
 fsub d3,d0,d1
 CONST d5,negative_floor
 fmin d3,d5,d3
 fdiv d2,d2,d3
 fadd d2,d4,d2
 fmul d2,d2,d8
 mov x26,#1
 OUT2 d2,33,x26
.Ldg_wet_next:
 NEXT .Ldg_wet_row
 sub x21,x21,#1
 cmp x21,#0
 b.ge .Ldg_wet_level
 // Exact nine-address raw child map, with the original false humidity flag.
 ARG x0,3
 ARG x1,1
 ARG x2,2
 ARG x3,4
 add x4,sp,#1624
 str wzr,[x4]
 ARG x5,13
 ARG x6,14
 ARG x7,9
 ldr x9,[sp,#1832]
 str x9,[sp]
 CALL md2asm_tropopause_level_7358525
 ROWS .Ldg_tropopause_pressure_row
 LI w21,5
 cmp w21,#1
 b.lt .Ldg_reject
 cmp w21,w28
 b.gt .Ldg_reject
 sub x21,x21,#1
 IN2 d0,9
 OUT d0,34
 NEXT .Ldg_tropopause_pressure_row
.Ldg_precipitation:
 mov x21,x28
 ROWS .Ldg_precipitation_row
 IN2 d0,18
 IN2 d1,20
 fadd d4,d0,d1
 IN2 d0,19
 IN2 d1,21
 fadd d5,d0,d1
 fadd d0,d4,d5
 CONST d1,precipitation_floor
 fcmp d0,d1
 b.le .Ldg_precipitation_next
 fdiv d6,d4,d0
 IN d0,23
 GLOBAL d1,yomcst,rtt
 fcmp d0,d1
 b.le .Ldg_precipitation_cold
 CONST d0,rain_eighty
 fcmp d6,d0
 b.gt .Ldg_category_rain
 CONST d0,rain_twenty
 fcmp d6,d0
 b.gt .Ldg_category_melting
 // The earlier <=0.2 condition owns every finite <=0.01 warm fraction.
 b .Ldg_category_wet_snow
.Ldg_precipitation_cold:
 IN d0,22
 CONST d1,rain_one
 fcmp d0,d1
 b.lt .Ldg_cold_shallow_first
 CONST d1,rain_twenty
 fcmp d0,d1
 b.lt .Ldg_cold_shallow_second
 CONST d1,rain_eighty
 fcmp d0,d1
 b.lt .Ldg_cold_intermediate
 // Deep warm layer aloft: source final branch.
 CONST d0,half
 fcmp d6,d0
 b.le .Ldg_category_ice_pellets
 b .Ldg_category_freezing_rain
.Ldg_cold_shallow_first:
 CONST d0,rain_one
 fcmp d6,d0
 b.lt .Ldg_category_dry_snow
 CONST d0,half
 fcmp d6,d0
 b.lt .Ldg_category_dry_snow
 b .Ldg_category_freezing_drizzle
.Ldg_cold_shallow_second:
 CONST d0,rain_one
 fcmp d6,d0
 b.lt .Ldg_category_dry_snow
 CONST d0,half
 fcmp d6,d0
 b.lt .Ldg_category_dry_snow
 b .Ldg_category_freezing_rain
.Ldg_cold_intermediate:
 CONST d0,half
 fcmp d6,d0
 b.le .Ldg_category_ice_pellets
 b .Ldg_category_freezing_rain
.Ldg_category_rain:
 CONST d0,one
 b .Ldg_store_category
.Ldg_category_melting:
 CONST d0,constant_category_melting
 b .Ldg_store_category
.Ldg_category_wet_snow:
 CONST d0,constant_category_wet_snow
 b .Ldg_store_category
.Ldg_category_dry_snow:
 CONST d0,constant_category_dry_snow
 b .Ldg_store_category
.Ldg_category_ice_pellets:
 CONST d0,constant_category_ice_pellets
 b .Ldg_store_category
.Ldg_category_freezing_rain:
 CONST d0,constant_category_freezing_rain
 OUT d4,32
 b .Ldg_store_category
.Ldg_category_freezing_drizzle:
 CONST d0,constant_category_freezing_drizzle
 OUT d4,32
.Ldg_store_category:
 OUT d0,31
.Ldg_precipitation_next:
 NEXT .Ldg_precipitation_row
 ldr x0,[sp,#1656]
 CALL free
 ldr w9,[sp,#1664]
 cbz w9,.Ldg_exit_hook_done
 adr x0,.Ldg_hook_name
 add x1,sp,#1668
 mov w9,#1
 str w9,[x1]
 add x2,sp,#1672
 mov x3,#11
 CALL __yomhook_MOD_dr_hook_default8
.Ldg_exit_hook_done:
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
 add sp,sp,#1,lsl #12
 ret
.Ldg_reject:
 brk #0x539
.size md2asm_cloud_weather_diagnostics_phase_sign_r1_7388001,.-md2asm_cloud_weather_diagnostics_phase_sign_r1_7388001
// Model-scaled saturation pressure helper; both source exponentials remain evaluated.
.Ldg_saturation_pressure:
 str x30,[sp,#1704]
 str d0,[sp,#1712]
 GLOBAL d1,yomcst,rtt
 fsub d1,d0,d1
 fmov x11,d1
 CONST d2,one
 fmov d3,xzr
 tst x11,#0x8000000000000000
 fcsel d2,d3,d2,ne
 str d2,[sp,#1744]
 GLOBAL d2,yoethf,r3les
 fmul d0,d2,d1
 ldr d1,[sp,#1712]
 GLOBAL d2,yoethf,r4les
 fsub d1,d1,d2
 fdiv d0,d0,d1
 CALL exp
 GLOBAL d1,yoethf,r2es
 fmul d0,d1,d0
 str d0,[sp,#1728]
 ldr d0,[sp,#1712]
 GLOBAL d1,yomcst,rtt
 fsub d0,d0,d1
 GLOBAL d1,yoethf,r3ies
 fmul d0,d1,d0
 ldr d1,[sp,#1712]
 GLOBAL d2,yoethf,r4ies
 fsub d1,d1,d2
 fdiv d0,d0,d1
 CALL exp
 GLOBAL d1,yoethf,r2es
 fmul d0,d1,d0
 ldr d2,[sp,#1744]
 CONST d3,one
 fsub d3,d3,d2
 fmul d1,d3,d0
 ldr d0,[sp,#1728]
 fmul d0,d2,d0
 fadd d0,d0,d1
 ldr x30,[sp,#1704]
 ret
.section .rodata
.p2align 3
.Ldg_one: .double 1.0
.Ldg_two: .double 2.0
.Ldg_ten: .double 10.0
.Ldg_half: .double 0.5
.Ldg_cloud_fraction: .double 0.01
.Ldg_condensate: .double 0.000001
.Ldg_negative_floor: .double -0.00000001
.Ldg_humidity_floor: .double 0.000000001
.Ldg_wet_pressure: .double 6000.0
.Ldg_wet1: .double 1329.31
.Ldg_wet2: .double 0.0074615
.Ldg_wet3: .double 85000.0
.Ldg_wet4: .double 40.637
.Ldg_wet5: .double 275.0
.Ldg_precipitation_floor: .double 0.0000000001
.Ldg_rain_one: .double 0.01
.Ldg_rain_twenty: .double 0.2
.Ldg_rain_eighty: .double 0.8
.Ldg_constant_category_melting: .double 7.0
.Ldg_constant_category_wet_snow: .double 6.0
.Ldg_constant_category_dry_snow: .double 5.0
.Ldg_constant_category_ice_pellets: .double 8.0
.Ldg_constant_category_freezing_rain: .double 3.0
.Ldg_constant_category_freezing_drizzle: .double 12.0
.Ldg_hook_name: .ascii "DIAG_CLOUDS"
.section .note.GNU-stack,"",%progbits


.global md2asm_cloud_weather_diagnostics_7358525
.type md2asm_cloud_weather_diagnostics_7358525,%function
.set md2asm_cloud_weather_diagnostics_7358525,md2asm_cloud_weather_diagnostics_phase_sign_r1_7388001

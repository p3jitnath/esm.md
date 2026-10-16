/* POS and VPOS selected grid calculations.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.arch armv8.2-a+simd
.text
.p2align 4
.macro GLOBAL r,name
 adrp \r,:got:\name
 ldr \r,[\r,:got_lo12:\name]
.endm
.macro CALL name
 str x18,[sp,#320]
 bl \name
 ldr x18,[sp,#320]
.endm
.global md2asm_output_grid_fields_7358525
.type md2asm_output_grid_fields_7358525,%function
md2asm_output_grid_fields_7358525:
 mov x17,sp
 movz x16,#0
 movk x16,#2,lsl #16
 sub sp,sp,x16
 stp x18,x30,[sp,#192]
 stp x19,x20,[sp,#208]
 stp x21,x22,[sp,#224]
 stp x23,x24,[sp,#240]
 stp x25,x26,[sp,#256]
 stp x27,x28,[sp,#272]
 str x29,[sp,#288]
 str x0,[sp,#384]
 str x1,[sp,#392]
 str x2,[sp,#400]
 str x3,[sp,#408]
 str x4,[sp,#416]
 str x5,[sp,#424]
 str x6,[sp,#432]
 str x7,[sp,#440]
 ldr x9,[x17,#0]
 str x9,[sp,#448]
 ldr x9,[x17,#8]
 str x9,[sp,#456]
 ldr x9,[x17,#16]
 str x9,[sp,#464]
 ldr x9,[x17,#24]
 str x9,[sp,#472]
 ldr x9,[x17,#32]
 str x9,[sp,#480]
 mrs x9,fpcr
 cbnz x9,.Lg_bad
 ldr x19,[sp,#384]
 ldr x20,[sp,#440]
 ldr w20,[x20]
 cmp w20,#19
 b.eq .Lg_level_ready
 cmp w20,#4
 b.ne .Lg_bad
.Lg_level_ready:
 mov w24,#1
 str w24,[sp,#960]
 mov w9,#24
 str w9,[sp,#964]
 mov w9,#19
 str w9,[sp,#968]
 mov w9,#4
 str w9,[sp,#972]
 mov w9,#1
 str w9,[sp,#976]
 str w9,[sp,#980]
 mov x16,#4096
 add x9,sp,x16
 mov x10,#456
.Lg_zero:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lg_zero
 .Lg_block:
 str w24,[sp,#984]
 ldr x9,[sp,#392]
 str x9,[sp,#640]
 ldr x9,[sp,#400]
 str x9,[sp,#648]
 ldr x9,[sp,#408]
 str x9,[sp,#656]
 ldr x9,[sp,#432]
 str x9,[sp,#664]
 mov x16,#984
 add x9,sp,x16
 str x9,[sp,#672]
 mov x16,#2048
 add x9,sp,x16
 str x9,[sp,#680]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 CALL md2asm_output_block_views_
 ldr x9,[sp,#2048]
 cmp x9,#24
 b.ne .Lg_bad
 ldr x9,[sp,#2056]
 cmp x9,#19
 b.ne .Lg_bad
 ldr w25,[sp,#2064]
 str w25,[sp,#988]
 cmp w25,#24
 b.eq .Lg_active
 cmp w25,#8
 b.ne .Lg_bad
.Lg_active:
 GLOBAL x9,__yomsta_MOD_rdtdz1
 ldr d0,[x9]
 GLOBAL x9,__yomcst_MOD_rg
 ldr d1,[x9]
 fdiv d0,d0,d1
 movz x16,#54464
 movk x16,#1,lsl #16
 add x17,sp,x16
 str d0,[x17]
 mov w26,#0
.Lg_surface_exp_0:
 mov x16,#2120
 add x17,sp,x16
 ldr x9,[x17]
 ldr d0,[x9,x26,lsl #3]
 CALL exp
 mov x16,#11840
 add x9,sp,x16
 str d0,[x9,x26,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_surface_exp_0
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#664]
 mov x16,#2192
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#672]
 mov x16,#2200
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#680]
 mov x16,#8192
 add x9,sp,x16
 str x9,[sp,#688]
 mov x16,#16384
 add x9,sp,x16
 str x9,[sp,#696]
 mov x16,#12288
 add x9,sp,x16
 str x9,[sp,#704]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 CALL md2asm_output_gphpre_7358525
 mov x16,#2072
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#640]
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#2072
 add x17,sp,x16
 ldr x9,[x17]
 add x9,x9,#3264
 str x9,[sp,#664]
 mov x16,#11840
 add x9,sp,x16
 str x9,[sp,#672]
 mov x16,#15552
 add x9,sp,x16
 str x9,[sp,#680]
 mov x16,#2128
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#688]
 mov x16,#53760
 add x9,sp,x16
 str x9,[sp,#696]
 mov x16,#54016
 add x9,sp,x16
 str x9,[sp,#704]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 CALL md2asm_surface_temperature_extrapolation_7358525
 mov w26,#0
.Lg_metric:
 mov x16,#2136
 add x17,sp,x16
 ldr x9,[x17]
 ldr d0,[x9,x26,lsl #3]
 fmul d1,d0,d0
 mov x16,#2144
 add x17,sp,x16
 ldr x9,[x17]
 ldr d2,[x9,x26,lsl #3]
 fmul d2,d2,d0
 mov x16,#2152
 add x17,sp,x16
 ldr x9,[x17]
 ldr d2,[x9,x26,lsl #3]
 fmul d2,d2,d0
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_metric
 mov w27,#0
.Lg_wind_level:
 mov w26,#0
.Lg_wind:
 mov w9,#24
 madd w10,w27,w9,w26
 mov x16,#2176
 add x17,sp,x16
 ldr x9,[x17]
 ldr d0,[x9,x10,lsl #3]
 mov x16,#2136
 add x17,sp,x16
 ldr x9,[x17]
 ldr d1,[x9,x26,lsl #3]
 fmul d0,d0,d1
 mov x16,#2184
 add x17,sp,x16
 ldr x9,[x17]
 ldr d0,[x9,x10,lsl #3]
 fmul d0,d0,d1
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_wind
 add w27,w27,#1
 cmp w27,#19
 b.lt .Lg_wind_level
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#664]
 mov x16,#2080
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#672]
 mov x16,#2096
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#680]
 mov x16,#2088
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#688]
 mov x16,#2104
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#696]
 mov x16,#2112
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#704]
 mov x16,#4096
 add x9,sp,x16
 str x9,[sp,#712]
 mov x16,#42240
 add x9,sp,x16
 str x9,[sp,#720]
 mov x16,#46080
 add x9,sp,x16
 str x9,[sp,#728]
 mov x16,#49920
 add x9,sp,x16
 str x9,[sp,#736]
 mov x9,#0
 str x9,[sp,#744]
 mov x9,#0
 str x9,[sp,#752]
 mov x9,#0
 str x9,[sp,#760]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 ldr x9,[sp,#712]
 str x9,[sp,#8]
 ldr x9,[sp,#720]
 str x9,[sp,#16]
 ldr x9,[sp,#728]
 str x9,[sp,#24]
 ldr x9,[sp,#736]
 str x9,[sp,#32]
 ldr x9,[sp,#744]
 str x9,[sp,#40]
 ldr x9,[sp,#752]
 str x9,[sp,#48]
 ldr x9,[sp,#760]
 str x9,[sp,#56]
 CALL md2asm_scan_gprcp_7358525
 mov w26,#0
.Lg_surface_exp_1:
 mov x16,#2120
 add x17,sp,x16
 ldr x9,[x17]
 ldr d0,[x9,x26,lsl #3]
 CALL exp
 mov x16,#11840
 add x9,sp,x16
 str d0,[x9,x26,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_surface_exp_1
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#664]
 mov x16,#2192
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#672]
 mov x16,#2200
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#680]
 mov x16,#8192
 add x9,sp,x16
 str x9,[sp,#688]
 mov x16,#16384
 add x9,sp,x16
 str x9,[sp,#696]
 mov x16,#12288
 add x9,sp,x16
 str x9,[sp,#704]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 CALL md2asm_output_gphpre_7358525
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#2072
 add x17,sp,x16
 ldr x9,[x17]
 add x9,x9,#3264
 str x9,[sp,#664]
 mov x16,#11840
 add x9,sp,x16
 str x9,[sp,#672]
 mov x16,#15552
 add x9,sp,x16
 str x9,[sp,#680]
 mov x16,#2128
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#688]
 mov x16,#53760
 add x9,sp,x16
 str x9,[sp,#696]
 mov x16,#54016
 add x9,sp,x16
 str x9,[sp,#704]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 CALL md2asm_surface_temperature_extrapolation_7358525
 ldr x9,[sp,#456]
 ldr w9,[x9]
 cmp w9,#1
 b.eq .Lg_pressure_targets
 cmp w9,#5
 b.ne .Lg_bad
 mov w27,#0
.Lg_model_targets:
 ldr x9,[sp,#448]
 ldr d0,[x9,x27,lsl #3]
 fcvtzs w28,d0
 cmp w28,#1
 b.lt .Lg_bad
 cmp w28,#19
 b.gt .Lg_bad
 sub w28,w28,#1
 mov w26,#0
.Lg_model_target_rows:
 mov w9,#24
 madd w10,w28,w9,w26
 mov x16,#12288
 add x9,sp,x16
 ldr d0,[x9,x10,lsl #3]
 mov w9,#24
 madd w10,w27,w9,w26
 movz x16,#19712
 movk x16,#1,lsl #16
 add x9,sp,x16
 str d0,[x9,x10,lsl #3]
 CALL log
 mov w9,#24
 madd w10,w27,w9,w26
 movz x16,#23424
 movk x16,#1,lsl #16
 add x9,sp,x16
 str d0,[x9,x10,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_model_target_rows
 add w27,w27,#1
 cmp w27,w20
 b.lt .Lg_model_targets
 b .Lg_targets_done
.Lg_pressure_targets:
 mov w27,#0
.Lg_pressure_target_level:
 mov w26,#0
.Lg_pressure_target_rows:
 ldr x9,[sp,#448]
 ldr d0,[x9,x27,lsl #3]
 mov w9,#24
 madd w10,w27,w9,w26
 movz x16,#19712
 movk x16,#1,lsl #16
 add x9,sp,x16
 str d0,[x9,x10,lsl #3]
 CALL log
 mov w9,#24
 madd w10,w27,w9,w26
 movz x16,#23424
 movk x16,#1,lsl #16
 add x9,sp,x16
 str d0,[x9,x10,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_pressure_target_rows
 add w27,w27,#1
 cmp w27,w20
 b.lt .Lg_pressure_target_level
.Lg_targets_done:
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#664]
 mov x16,#972
 add x9,sp,x16
 str x9,[sp,#672]
 mov x16,#8192
 add x9,sp,x16
 str x9,[sp,#680]
 mov x16,#12288
 add x9,sp,x16
 str x9,[sp,#688]
 mov x16,#54272
 add x9,sp,x16
 str x9,[sp,#696]
 movz x16,#4224
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#704]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 CALL md2asm_ppinit_7358525
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#664]
 ldr x9,[sp,#440]
 str x9,[sp,#672]
 mov x16,#972
 add x9,sp,x16
 str x9,[sp,#680]
 movz x16,#19712
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#688]
 mov x16,#8192
 add x9,sp,x16
 str x9,[sp,#696]
 mov x16,#12288
 add x9,sp,x16
 str x9,[sp,#704]
 movz x16,#27136
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#712]
 movz x16,#34560
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#720]
 movz x16,#36480
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#728]
 movz x16,#38400
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#736]
 movz x16,#38528
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#744]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 ldr x9,[sp,#712]
 str x9,[sp,#8]
 ldr x9,[sp,#720]
 str x9,[sp,#16]
 ldr x9,[sp,#728]
 str x9,[sp,#24]
 ldr x9,[sp,#736]
 str x9,[sp,#32]
 ldr x9,[sp,#744]
 str x9,[sp,#40]
 CALL md2asm_ppflev_7358525
 adrp x9,.Lg_ppref
 add x9,x9,:lo12:.Lg_ppref
 str x9,[sp,#640]
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#664]
 mov x16,#992
 add x9,sp,x16
 str x9,[sp,#672]
 mov x16,#980
 add x9,sp,x16
 str x9,[sp,#680]
 mov x16,#58112
 add x9,sp,x16
 str x9,[sp,#688]
 movz x16,#256
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#696]
 movz x16,#38656
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#704]
 movz x16,#42624
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#712]
 mov x9,#5
 str x9,[sp,#720]
 mov w9,#20
 str w9,[sp,#992]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 ldr x9,[sp,#712]
 str x9,[sp,#8]
 ldr x9,[sp,#720]
 str x9,[sp,#16]
 CALL md2asm_ppsta_7358525
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#664]
 ldr x9,[sp,#440]
 str x9,[sp,#672]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#680]
 mov x16,#972
 add x9,sp,x16
 str x9,[sp,#688]
 movz x16,#27136
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#696]
 movz x16,#19712
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#704]
 movz x16,#23424
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#712]
 movz x16,#34560
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#720]
 movz x16,#36480
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#728]
 movz x16,#38400
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#736]
 movz x16,#38528
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#744]
 mov x16,#980
 add x9,sp,x16
 str x9,[sp,#752]
 mov x16,#2128
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#760]
 mov x16,#54272
 add x9,sp,x16
 str x9,[sp,#768]
 movz x16,#4224
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#776]
 mov x16,#53760
 add x9,sp,x16
 str x9,[sp,#784]
 mov x16,#54016
 add x9,sp,x16
 str x9,[sp,#792]
 mov x16,#46080
 add x9,sp,x16
 str x9,[sp,#800]
 mov x16,#2072
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#808]
 movz x16,#46592
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#816]
 movz x16,#38656
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#824]
 mov x9,#0
 str x9,[sp,#832]
 mov x9,#0
 str x9,[sp,#840]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 ldr x9,[sp,#712]
 str x9,[sp,#8]
 ldr x9,[sp,#720]
 str x9,[sp,#16]
 ldr x9,[sp,#728]
 str x9,[sp,#24]
 ldr x9,[sp,#736]
 str x9,[sp,#32]
 ldr x9,[sp,#744]
 str x9,[sp,#40]
 ldr x9,[sp,#752]
 str x9,[sp,#48]
 ldr x9,[sp,#760]
 str x9,[sp,#56]
 ldr x9,[sp,#768]
 str x9,[sp,#64]
 ldr x9,[sp,#776]
 str x9,[sp,#72]
 ldr x9,[sp,#784]
 str x9,[sp,#80]
 ldr x9,[sp,#792]
 str x9,[sp,#88]
 ldr x9,[sp,#800]
 str x9,[sp,#96]
 ldr x9,[sp,#808]
 str x9,[sp,#104]
 ldr x9,[sp,#816]
 str x9,[sp,#112]
 ldr x9,[sp,#824]
 str x9,[sp,#120]
 ldr x9,[sp,#832]
 str x9,[sp,#128]
 ldr x9,[sp,#840]
 str x9,[sp,#136]
 CALL md2asm_ppt_original_route_7358525
 ldr x9,[sp,#456]
 ldr w9,[x9]
 cmp w9,#5
 b.ne .Lg_no_humidity
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#640]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#648]
 mov x16,#988
 add x9,sp,x16
 str x9,[sp,#656]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#664]
 ldr x9,[sp,#440]
 str x9,[sp,#672]
 mov x16,#976
 add x9,sp,x16
 str x9,[sp,#680]
 mov x16,#972
 add x9,sp,x16
 str x9,[sp,#688]
 movz x16,#27136
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#696]
 movz x16,#19712
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#704]
 movz x16,#34560
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#712]
 movz x16,#38400
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#720]
 mov x16,#54272
 add x9,sp,x16
 str x9,[sp,#728]
 movz x16,#4224
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#736]
 mov x16,#2080
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#744]
 movz x16,#50304
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#752]
 mov x9,#0
 str x9,[sp,#760]
 mov x9,#0
 str x9,[sp,#768]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 ldr x9,[sp,#712]
 str x9,[sp,#8]
 ldr x9,[sp,#720]
 str x9,[sp,#16]
 ldr x9,[sp,#728]
 str x9,[sp,#24]
 ldr x9,[sp,#736]
 str x9,[sp,#32]
 ldr x9,[sp,#744]
 str x9,[sp,#40]
 ldr x9,[sp,#752]
 str x9,[sp,#48]
 ldr x9,[sp,#760]
 str x9,[sp,#56]
 ldr x9,[sp,#768]
 str x9,[sp,#64]
 CALL md2asm_ppq_7358525
 .Lg_no_humidity:
 mov w9,#6
 str w9,[sp,#996]
 str x19,[sp,#640]
 mov x16,#996
 add x9,sp,x16
 str x9,[sp,#648]
 movz x16,#55488
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#656]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 CALL md2asm_output_field_map_
 movz x16,#55488
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x9,[x17]
 cbz x9,.Lg_field_skip_6
 movz x16,#55488
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x21,[x17]
 movz x16,#55504
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x22,[x17]
 sub x22,x22,#1
 movz x16,#55512
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x23,[x17]
 movz x16,#55520
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x28,[x17]
 movz x16,#55496
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x9,[x17]
 cbz x9,.Lg_aux_6
 ldr x29,[sp,#464]
 b .Lg_dest_6
.Lg_aux_6:
 ldr x29,[sp,#472]
.Lg_dest_6:
 sub w9,w24,#1
 mul x9,x9,x28
 mov x10,#192
 mul x9,x9,x10
 add x29,x29,x9
 mov w27,#0
.Lg_pack_level_6:
 ldr w10,[x23,x27,lsl #2]
 sub w10,w10,#1
 mov x9,#192
 umull x10,w10,w9
 movz x16,#50304
 movk x16,#1,lsl #16
 add x11,sp,x16
 add x11,x11,x10
 add x12,x22,x27
 mov x9,#192
 mul x12,x12,x9
 add x12,x29,x12
 mov w26,#0
.Lg_pack_row_6:
 ldr x10,[x11,x26,lsl #3]
 str x10,[x12,x26,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_pack_row_6
 add w27,w27,#1
 cmp w27,w21
 b.lt .Lg_pack_level_6
.Lg_field_skip_6:
 mov w9,#5
 str w9,[sp,#996]
 str x19,[sp,#640]
 mov x16,#996
 add x9,sp,x16
 str x9,[sp,#648]
 movz x16,#55488
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#656]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 CALL md2asm_output_field_map_
 movz x16,#55488
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x9,[x17]
 cbz x9,.Lg_field_skip_5
 movz x16,#55488
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x21,[x17]
 movz x16,#55504
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x22,[x17]
 sub x22,x22,#1
 movz x16,#55512
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x23,[x17]
 movz x16,#55520
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x28,[x17]
 movz x16,#55496
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x9,[x17]
 cbz x9,.Lg_aux_5
 ldr x29,[sp,#464]
 b .Lg_dest_5
.Lg_aux_5:
 ldr x29,[sp,#472]
.Lg_dest_5:
 sub w9,w24,#1
 mul x9,x9,x28
 mov x10,#192
 mul x9,x9,x10
 add x29,x29,x9
 mov w27,#0
.Lg_pack_level_5:
 ldr w10,[x23,x27,lsl #2]
 sub w10,w10,#1
 mov x9,#192
 umull x10,w10,w9
 movz x16,#46592
 movk x16,#1,lsl #16
 add x11,sp,x16
 add x11,x11,x10
 add x12,x22,x27
 mov x9,#192
 mul x12,x12,x9
 add x12,x29,x12
 mov w26,#0
.Lg_pack_row_5:
 ldr x10,[x11,x26,lsl #3]
 str x10,[x12,x26,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_pack_row_5
 add w27,w27,#1
 cmp w27,w21
 b.lt .Lg_pack_level_5
.Lg_field_skip_5:
 mov w9,#454
 str w9,[sp,#996]
 str x19,[sp,#640]
 mov x16,#996
 add x9,sp,x16
 str x9,[sp,#648]
 movz x16,#55488
 movk x16,#1,lsl #16
 add x9,sp,x16
 str x9,[sp,#656]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 CALL md2asm_output_field_map_
 movz x16,#55488
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x9,[x17]
 cbz x9,.Lg_field_skip_454
 mov w26,#0
.Lg_log_surface:
 mov x16,#11840
 add x9,sp,x16
 ldr d0,[x9,x26,lsl #3]
 CALL log
 movz x16,#54720
 movk x16,#1,lsl #16
 add x9,sp,x16
 str d0,[x9,x26,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_log_surface
 movz x16,#55488
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x21,[x17]
 movz x16,#55504
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x22,[x17]
 sub x22,x22,#1
 movz x16,#55512
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x23,[x17]
 movz x16,#55520
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x28,[x17]
 movz x16,#55496
 movk x16,#1,lsl #16
 add x17,sp,x16
 ldr x9,[x17]
 cbz x9,.Lg_aux_454
 ldr x29,[sp,#464]
 b .Lg_dest_454
.Lg_aux_454:
 ldr x29,[sp,#472]
.Lg_dest_454:
 sub w9,w24,#1
 mul x9,x9,x28
 mov x10,#192
 mul x9,x9,x10
 add x29,x29,x9
 mov w27,#0
.Lg_pack_level_454:
 mov w10,#0
 mov x9,#192
 umull x10,w10,w9
 movz x16,#54720
 movk x16,#1,lsl #16
 add x11,sp,x16
 add x11,x11,x10
 add x12,x22,x27
 mov x9,#192
 mul x12,x12,x9
 add x12,x29,x12
 mov w26,#0
.Lg_pack_row_454:
 ldr x10,[x11,x26,lsl #3]
 str x10,[x12,x26,lsl #3]
 add w26,w26,#1
 cmp w26,w25
 b.lt .Lg_pack_row_454
 add w27,w27,#1
 cmp w27,w21
 b.lt .Lg_pack_level_454
.Lg_field_skip_454:
 add w24,w24,#1
 cmp w24,#86
 b.le .Lg_block
 adrp x9,.Lcounts
 add x9,x9,:lo12:.Lcounts
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldp x18,x30,[sp,#192]
 ldp x19,x20,[sp,#208]
 ldp x21,x22,[sp,#224]
 ldp x23,x24,[sp,#240]
 ldp x25,x26,[sp,#256]
 ldp x27,x28,[sp,#272]
 ldr x29,[sp,#288]
 movz x16,#0
 movk x16,#2,lsl #16
 add sp,sp,x16
 ret
.size md2asm_output_grid_fields_7358525,.-md2asm_output_grid_fields_7358525

.Lg_bad:
 CALL abort
 brk #0
.section .rodata
.Lg_ppref:.ascii "PPREF"
.bss
.p2align 3
.Lcounts:.skip 8
.section .note.GNU-stack,"",%progbits

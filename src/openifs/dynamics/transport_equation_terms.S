
/* Complete hydrostatic two-level LATTEX; all selected equations are assembly.
 * Physics: formulations/openifs/dynamics/transport_equation_terms.md.
 * Contract: skills/md2asm/references/openifs/dynamics/transport_equation_terms.md.
 * 42 ordinary pointers, no hidden length; all caller capacities remain explicit.
 * The complete accepted DNT child supplies its own numerical stages.
 */
.arch armv8.2-a+simd
.equ GMV_NDIMGMV,992
.equ GFL_NDIM,48
.equ D_TND_NDIM,404
.equ D_TND_U,380
.equ D_TND_V,384
.equ D_TND_T,388
.equ D_TWOTL,20
.equ D_SPLBUF2_FIELDS,9184
.equ D_RCMSLP0,4912
.equ CONF_RIP,1359320
.equ D_RCORDIF,2728
.equ D_RCORDIH,2664
.equ OROG_BYTES,384
.equ G_OROG,14024
.equ OROG_DATA,0
.equ GS_RCORI,0
.equ GMV_YT0_MSPD,1048
.equ GMV_YT0_MSVD,1060
.equ GMV_YT0_MT,1020
.equ GMV_YT0_MU,1012
.equ GMV_YT0_MV,1016
.equ GMV_YT1_MNHX,1396
.equ GMV_YT1_MSPD,1380
.equ GMV_YT1_MSVD,1384
.equ GMV_YT1_MT,1376
.equ GMV_YT1_MU,1368
.equ GMV_YT1_MV,1372
.equ GMV_YT1_NDIM,1360
.equ GMV_YT9_MCSPDNL,1280
.equ GMV_YT9_MCTNL,1268
.equ GMV_YT9_MCUNL,1260
.equ GMV_YT9_MCVNL,1264
.equ GMV_YT9_MCVWVNL,1276
.equ GMV_YT9_MGW,1232
.equ GMV_YT9_MNHX,1228
.equ GMV_YT9_MSPD,1204
.equ GMV_YT9_MSPDNL,1180
.equ GMV_YT9_MSVD,1216
.equ GMV_YT9_MT,1124
.equ GMV_YT9_MTNL,1156
.equ GMV_YT9_MU,1116
.equ GMV_YT9_MUNL,1140
.equ GMV_YT9_MV,1120
.equ GMV_YT9_MVNL,1148
.equ GMV_YT9_MVWVNL,1172
.equ D_NWLAG,4644
.equ D_NTLAG,4648
.equ D_NSPLTHOI,4660
.equ D_LSPLTHOIGFL,4664
.equ D_LRHS_CURV,4760
.equ D_LADVF,4896
.equ D_NCURRENT_ITER,3036
.equ D_RINTOPT,4968
.equ DA_LTWOTL,20
.equ DA_LSETTLS,292
.equ DA_LPC_FULL,336
.equ DA_LPC_CHEAP,340
.equ DA_LNHEE,0
.equ DA_LNHDYN,8
.equ DA_LSACC,12
.equ D_MSLB1GFL9,8972
.equ D_MSLB1GFLF9,9148
.equ D_MSLB1GFLSP9,8976
.equ D_MSLB1GFLSPF9,9156
.equ D_MSLB1NHX9,8988
.equ D_MSLB1PD0,9068
.equ D_MSLB1PD9,8980
.equ D_MSLB1PD9_NL,9172
.equ D_MSLB1PD9_SI,9124
.equ D_MSLB1T0,9064
.equ D_MSLB1T9,8968
.equ D_MSLB1T9_NL,9168
.equ D_MSLB1T9_SI,9120
.equ D_MSLB1TF9,9144
.equ D_MSLB1U0,9052
.equ D_MSLB1U9,8956
.equ D_MSLB1U9_NL,9160
.equ D_MSLB1U9_SI,9112
.equ D_MSLB1UF9,9136
.equ D_MSLB1V0,9056
.equ D_MSLB1V9,8960
.equ D_MSLB1V9_NL,9164
.equ D_MSLB1V9_SI,9116
.equ D_MSLB1VD0,9072
.equ D_MSLB1VD9,8984
.equ D_MSLB1VD9_NL,9176
.equ D_MSLB1VD9_SI,9128
.equ D_MSLB1VDF9,9152
.equ D_MSLB1VF9,9140
.equ D_MSLB1Z0,9060
.equ D_MSLB1Z9,8964
.equ D_MSLB2PDSI,9212
.equ D_MSLB2TSI,9208
.equ D_MSLB2USI,9200
.equ D_MSLB2VDSI,9216
.equ D_MSLB2VSI,9204
.equ MDDH_MSIDDH_U0,34700
.equ MDDH_MSIDDH_U9,34720
.equ MDDH_MSIDDH_V0,34704
.equ MDDH_MSIDDH_V9,34724
.equ MDDH_MSIDDH_T0,34708
.equ MDDH_MSIDDH_T9,34728
.equ COMP_MP,168
.equ COMP_MP9,180
.equ COMP_MP_SPL,212
.equ GFL_YQ_PTR,799840
.equ GFL_YCVGQ_PTR,800056
.equ COMP_LADV,20
.equ COMP_LMGRID,48
.equ COMP_LTDIABLIN,28
.equ COMP_MP_SL1,216
.equ COMP_CSLINT,156
.equ COMP_LGP,52
.text
.p2align 4
.macro arg reg,index
 ldr \reg,[sp,#(320+8*\index)]
.endm
.macro record reg,base,offset
 movz \reg,#(\offset & 65535)
 movk \reg,#((\offset >> 16) & 65535),lsl #16
 add \reg,\base,\reg
.endm
.macro gmv_view reg,owner,offset
 arg x9,1
 ldr w10,[x9,#\offset]
 cmp w10,#1
 b.lt 91f
 sub w10,w10,#1
 arg \reg,\owner
 madd \reg,x10,x25,\reg
 b 92f
91: mov \reg,xzr
92:
.endm
.macro buffer_view reg,owner,offset
 record x9,x20,\offset
 ldr w10,[x9]
 cmp w10,#1
 b.lt 91f
 sub w10,w10,#1
 mul x10,x10,x22
 arg \reg,\owner
 add \reg,\reg,x10,lsl #3
 b 92f
91: mov \reg,xzr
92:
.endm
.macro loop_begin name
 mov x4,#0
.L\name\()_level:
 mov x5,x26
 madd x6,x4,x22,x26
 cmp x5,x27
 b.ge .L\name\()_next
.L\name\()_cell:
.endm
.macro loop_end name
 add x6,x6,#1
 add x5,x5,#1
 cmp x5,x27
 b.lt .L\name\()_cell
.L\name\()_next:
 add x4,x4,#1
 cmp x4,x23
 b.lt .L\name\()_level
.endm
.macro count_child
 adrp x9,.Lchildren
 add x9,x9,:lo12:.Lchildren
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
.endm
.global md2asm_lattex_7259755
.type md2asm_lattex_7259755,%function
md2asm_lattex_7259755:
 mov x16,sp
 sub sp,sp,#2048
 stp x0,x1,[sp,#320]
 stp x2,x3,[sp,#336]
 stp x4,x5,[sp,#352]
 stp x6,x7,[sp,#368]
 add x9,sp,#384
 mov x10,#34
.Lsave_arguments:
 ldr x11,[x16],#8
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lsave_arguments
 add x9,sp,#704
 stp x19,x20,[x9,#0]
 stp x21,x22,[x9,#16]
 stp x23,x24,[x9,#32]
 stp x25,x26,[x9,#48]
 stp x27,x28,[x9,#64]
 stp x29,x30,[x9,#80]
 stp d8,d9,[x9,#96]
 stp d10,d11,[x9,#112]
 stp d12,d13,[x9,#128]
 stp d14,d15,[x9,#144]
 str x18,[sp,#864]
 mov x29,sp
 mov x19,x0
 arg x20,5
 arg x21,4
 mrs x9,fpcr
 cbnz x9,.Lunsupported
 ldr w22,[x19,#5144]
 ldr w23,[x19,#5224]
 cmp w22,#1
 b.lt .Lunsupported
 cmp w22,#1024
 b.gt .Lunsupported
 cmp w23,#4
 b.lt .Lunsupported
 cmp w23,#256
 b.gt .Lunsupported
 arg x9,6
 ldr w26,[x9]
 sub w26,w26,#1
 cmp w26,w22
 b.hs .Lunsupported
 arg x9,7
 ldr w27,[x9]
 cmp w27,w22
 b.hi .Lunsupported
 cmp w27,w26
 b.lt .Lunsupported
 ldr w9,[x20,#20]
 cmp w9,#1
 b.ne .Lunsupported
 record x9,x20,DA_LNHEE
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,DA_LNHDYN
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,DA_LSACC
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,DA_LPC_FULL
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,DA_LPC_CHEAP
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,D_LSPLTHOIGFL
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,D_LRHS_CURV
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,D_LADVF
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,D_NCURRENT_ITER
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,D_NSPLTHOI
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,D_NWLAG
 ldr w10,[x9]
 cmp w10,#3
 b.ne .Lunsupported
 record x9,x20,D_NTLAG
 ldr w10,[x9]
 cmp w10,#3
 b.ne .Lunsupported
 arg x9,2
 ldr w10,[x9,#100]
 cbnz w10,.Lunsupported
 ldr w10,[x9,#108]
 cbnz w10,.Lunsupported
 ldr x9,[x19,#3264]
 ldr w10,[x9,#52]
 cmp w10,#1
 b.ne .Lunsupported
 record x9,x20,D_RINTOPT
 ldr x10,[x9]
 mov x11,#0x3ff0000000000000
 cmp x10,x11
 b.ne .Lunsupported
 add x9,x21,#184
 movz x10,#(GFL_YCVGQ_PTR & 65535)
 movk x10,#((GFL_YCVGQ_PTR >> 16) & 65535),lsl #16
 ldr x10,[x9,x10]
 ldr w10,[x10,#52]
 cbnz w10,.Lunsupported

 /* A spline constituent has another numerical stage and is outside this route. */
 add x9,x21,#184
 ldr w10,[x9]
 cmp w10,#2163
 b.hi .Lunsupported
 mov x11,#3848
 add x11,x9,x11
 mov x12,#0
.Lcheck_spline_fields:
 cmp x12,x10
 b.ge .Lcheck_spline_done
 ldr w13,[x11,#COMP_LADV]
 cbz w13,.Lcheck_spline_next
 ldr x13,[x11,#COMP_CSLINT]
 movz x14,#0x414c
 movk x14,#0x5449,lsl #16
 movk x14,#0x5356,lsl #32
 movk x14,#0x4350,lsl #48
 cmp x13,x14
 b.ne .Lcheck_spline_next
 ldr w13,[x11,#(COMP_CSLINT+8)]
 movz w14,#0x4d51
 movk w14,#0x2020,lsl #16
 cmp w13,w14
 b.eq .Lunsupported
.Lcheck_spline_next:
 add x11,x11,#368
 add x12,x12,#1
 b .Lcheck_spline_fields
.Lcheck_spline_done:
 mul x24,x22,x23
 lsl x25,x24,#3
 /* Allocate the three complete private source fields before any output write. */
 add x0,x25,x25,lsl #1
 bl malloc
 cbz x0,.Lunsupported
 mov x28,x0
 str x0,[sp,#896]
 add x0,x0,x25
 str x0,[sp,#904]
 add x0,x0,x25
 str x0,[sp,#912]
 /* Preserve every scalar rounding and status contribution in source order. */
 adrp x9,:got:__yomcst_MOD_rd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 ldr d0,[x9]
 adrp x9,:got:__yomsta_MOD_rtsur
 ldr x9,[x9,:got_lo12:__yomsta_MOD_rtsur]
 ldr d1,[x9]
 fmul d0,d0,d1
 record x9,x20,D_RCMSLP0
 ldr d1,[x9]
 fdiv d0,d1,d0
 str d0,[sp,#920]
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 ldr d0,[x9]
 adrp x9,:got:__yomcst_MOD_ra
 ldr x9,[x9,:got_lo12:__yomcst_MOD_ra]
 ldr d1,[x9]
 fmul d1,d0,d1
 fmov d2,#2.0
 fdiv d1,d2,d1
 adrp x9,:got:__yomcst_MOD_romega
 ldr x9,[x9,:got_lo12:__yomcst_MOD_romega]
 ldr d1,[x9]
 fmul d1,d2,d1
 fdiv d1,d1,d0
 /* Obtain this block's immutable Coriolis and geopotential arrays. */
 arg x9,13
 ldr w10,[x9]
 ldr x11,[x19,#8520]
 sub x10,x10,x11
 mov x11,#1472
 mul x10,x10,x11
 ldr x11,[x19,#8472]
 add x11,x11,x10
 ldr x10,[x11]
 ldr x12,[x11,#8]
 add x10,x10,x12,lsl #3
 add x10,x10,#8
 str x10,[sp,#928]
 arg x9,13
 ldr w10,[x9]
 mov x9,#14072
 ldr x11,[x19,x9]
 sub x10,x10,x11
 mov x11,#384
 mul x10,x10,x11
 mov x9,#14024
 ldr x11,[x19,x9]
 add x11,x11,x10
 ldr x10,[x11]
 ldr x12,[x11,#8]
 add x10,x10,x12,lsl #3
 add x10,x10,#8
 str x10,[sp,#936]
 record x9,x20,D_RCORDIF
 ldr x10,[x9]
 ldr x11,[x9,#8]
 add x10,x10,x11,lsl #3
 add x10,x10,#8
 str x10,[sp,#944]
 record x9,x20,D_RCORDIH
 ldr x10,[x9]
 ldr x11,[x9,#8]
 add x10,x10,x11,lsl #3
 str x10,[sp,#952]
 ldr w9,[x19,#5244]
 str w9,[sp,#992]
 /* Wind source fields and their original linear time factors. */
 buffer_view x9,41,D_MSLB2USI
 str x9,[sp,#960]
 buffer_view x9,41,D_MSLB2VSI
 str x9,[sp,#968]
 gmv_view x9,37,GMV_YT0_MU
 str x9,[sp,#976]
 gmv_view x9,37,GMV_YT0_MV
 str x9,[sp,#984]
 loop_begin wind_prepare
 arg x9,8
 ldr d0,[x9]
 arg x9,9
 ldr d1,[x9]
 arg x10,17
 ldr d2,[x10,x6,lsl #3]
 fmul d2,d1,d2
 ldr x10,[sp,#960]
 str d2,[x10,x6,lsl #3]
 arg x10,18
 ldr d2,[x10,x6,lsl #3]
 fmul d2,d1,d2
 ldr x10,[sp,#968]
 str d2,[x10,x6,lsl #3]
 record x9,x20,D_TND_U
 ldr w10,[x9]
 sub w10,w10,#1
 arg x9,29
 madd x10,x10,x24,x6
 ldr d2,[x9,x10,lsl #3]
 fmul d2,d0,d2
 record x9,x20,D_TND_V
 ldr w10,[x9]
 sub w10,w10,#1
 arg x9,29
 madd x10,x10,x24,x6
 ldr d3,[x9,x10,lsl #3]
 fmul d3,d0,d3
 ldr x9,[sp,#928]
 ldr d4,[x9,x5,lsl #3]
 fmul d4,d0,d4
 ldr x9,[sp,#984]
 ldr d5,[x9,x6,lsl #3]
 fmul d5,d4,d5
 fadd d2,d2,d5
 ldr x9,[sp,#976]
 ldr d5,[x9,x6,lsl #3]
 fmul d5,d4,d5
 fsub d3,d3,d5
 ldr x9,[sp,#896]
 str d2,[x9,x6,lsl #3]
 ldr x9,[sp,#904]
 str d3,[x9,x6,lsl #3]
 loop_end wind_prepare
 /* Source wind flag: stable extrapolation is off when PESGP exceeds PESGM. */
 mov w9,#0
 arg x10,11
 ldr d0,[x10]
 arg x10,12
 ldr d1,[x10]
 fcmp d0,d1
 b.gt .Lwind_flag_ready
 ldr w9,[x20,#DA_LSETTLS]
.Lwind_flag_ready:
 str w9,[sp,#880]
 record x9,x20,D_NWLAG
 str x9,[sp,#0]
 arg x9,11
 str x9,[sp,#8]
 arg x9,12
 str x9,[sp,#16]
 gmv_view x9,37,GMV_YT0_MU
 str x9,[sp,#24]
 gmv_view x9,37,GMV_YT9_MU
 str x9,[sp,#32]
 ldr x9,[sp,#896]
 str x9,[sp,#40]
 arg x9,36
 str x9,[sp,#48]
 buffer_view x9,41,D_MSLB2USI
 str x9,[sp,#56]
 gmv_view x9,37,GMV_YT9_MUNL
 str x9,[sp,#64]
 gmv_view x9,38,GMV_YT1_MU
 str x9,[sp,#72]
 buffer_view x9,40,D_MSLB1U0
 str x9,[sp,#80]
 buffer_view x9,40,D_MSLB1U9
 str x9,[sp,#88]
 str xzr,[sp,#96]
 str xzr,[sp,#104]
 str xzr,[sp,#112]
 str xzr,[sp,#120]
 str xzr,[sp,#128]
 str xzr,[sp,#136]
 str xzr,[sp,#144]
 mov x0,x19
 arg x1,2
 record x2,x21,CONF_RIP
 add x3,x20,#456
 mov x4,x20
 arg x5,6
 arg x6,7
 add x7,sp,#880
 bl md2asm_lattex_dnt_7240564
 record x9,x20,D_NWLAG
 str x9,[sp,#0]
 arg x9,11
 str x9,[sp,#8]
 arg x9,12
 str x9,[sp,#16]
 gmv_view x9,37,GMV_YT0_MV
 str x9,[sp,#24]
 gmv_view x9,37,GMV_YT9_MV
 str x9,[sp,#32]
 ldr x9,[sp,#904]
 str x9,[sp,#40]
 arg x9,36
 str x9,[sp,#48]
 buffer_view x9,41,D_MSLB2VSI
 str x9,[sp,#56]
 gmv_view x9,37,GMV_YT9_MVNL
 str x9,[sp,#64]
 gmv_view x9,38,GMV_YT1_MV
 str x9,[sp,#72]
 buffer_view x9,40,D_MSLB1V0
 str x9,[sp,#80]
 buffer_view x9,40,D_MSLB1V9
 str x9,[sp,#88]
 str xzr,[sp,#96]
 str xzr,[sp,#104]
 str xzr,[sp,#112]
 str xzr,[sp,#120]
 str xzr,[sp,#128]
 str xzr,[sp,#136]
 str xzr,[sp,#144]
 mov x0,x19
 arg x1,2
 record x2,x21,CONF_RIP
 add x3,x20,#456
 mov x4,x20
 arg x5,6
 arg x6,7
 add x7,sp,#880
 bl md2asm_lattex_dnt_7240564
 /* Temperature preparation retains each original product and addition. */
 buffer_view x9,41,D_MSLB2TSI
 str x9,[sp,#960]
 loop_begin temperature_prepare
 arg x9,8
 ldr d0,[x9]
 ldr d1,[sp,#920]
 ldr x9,[sp,#944]
 ldr d2,[x9,x4,lsl #3]
 arg x9,10
 ldr d3,[x9,x5,lsl #3]
 arg x9,19
 ldr d4,[x9,x6,lsl #3]
 fmul d3,d3,d4
 ldr x9,[sp,#960]
 str d3,[x9,x6,lsl #3]
 arg x9,28
 add x10,x6,x22
 ldr d3,[x9,x10,lsl #3]
 arg x9,27
 ldr d4,[x9,x6,lsl #3]
 fmul d3,d3,d4
 fmul d4,d0,d1
 fmul d4,d4,d2
 ldr x9,[sp,#976]
 ldr d5,[x9,x6,lsl #3]
 fmul d4,d4,d5
 arg x9,14
 ldr d5,[x9,x5,lsl #3]
 fmul d4,d4,d5
 fmul d5,d0,d1
 fmul d5,d5,d2
 ldr x9,[sp,#984]
 ldr d6,[x9,x6,lsl #3]
 fmul d5,d5,d6
 arg x9,15
 ldr d6,[x9,x5,lsl #3]
 fmul d5,d5,d6
 fadd d4,d4,d5
 record x9,x20,D_TND_T
 ldr w10,[x9]
 sub w10,w10,#1
 madd x10,x10,x24,x6
 arg x9,29
 ldr d5,[x9,x10,lsl #3]
 fmul d5,d0,d5
 fadd d4,d4,d5
 ldr x9,[sp,#952]
 add x10,x4,#1
 ldr d5,[x9,x10,lsl #3]
 ldr d6,[x9,x4,lsl #3]
 fsub d5,d5,d6
 fmul d6,d0,d1
 fmul d6,d6,d5
 fmul d6,d6,d3
 ldr x9,[sp,#936]
 ldr d5,[x9,x5,lsl #3]
 fmul d6,d6,d5
 fadd d4,d4,d6
 ldr x9,[sp,#912]
 str d4,[x9,x6,lsl #3]
 loop_end temperature_prepare
 record x9,x20,D_NTLAG
 str x9,[sp,#0]
 arg x9,11
 str x9,[sp,#8]
 arg x9,12
 str x9,[sp,#16]
 gmv_view x9,37,GMV_YT0_MT
 str x9,[sp,#24]
 gmv_view x9,37,GMV_YT9_MT
 str x9,[sp,#32]
 ldr x9,[sp,#912]
 str x9,[sp,#40]
 arg x9,36
 str x9,[sp,#48]
 buffer_view x9,41,D_MSLB2TSI
 str x9,[sp,#56]
 gmv_view x9,37,GMV_YT9_MTNL
 str x9,[sp,#64]
 gmv_view x9,38,GMV_YT1_MT
 str x9,[sp,#72]
 buffer_view x9,40,D_MSLB1T0
 str x9,[sp,#80]
 buffer_view x9,40,D_MSLB1T9
 str x9,[sp,#88]
 str xzr,[sp,#96]
 str xzr,[sp,#104]
 str xzr,[sp,#112]
 str xzr,[sp,#120]
 str xzr,[sp,#128]
 str xzr,[sp,#136]
 str xzr,[sp,#144]
 mov x0,x19
 arg x1,2
 record x2,x21,CONF_RIP
 add x3,x20,#456
 mov x4,x20
 arg x5,6
 arg x6,7
 record x7,x20,DA_LSETTLS
 bl md2asm_lattex_dnt_7240564
 gmv_view x9,38,GMV_YT1_MT
 str x9,[sp,#960]
 buffer_view x9,40,D_MSLB1T9
 str x9,[sp,#968]
 loop_begin temperature_conversion
 ldr x9,[sp,#944]
 ldr d0,[x9,x4,lsl #3]
 ldr d1,[sp,#920]
 fmul d0,d0,d1
 ldr x9,[sp,#936]
 ldr d1,[x9,x5,lsl #3]
 fmul d0,d0,d1
 ldr x9,[sp,#960]
 ldr d1,[x9,x6,lsl #3]
 fsub d1,d1,d0
 str d1,[x9,x6,lsl #3]
 ldr w10,[sp,#992]
 sub x10,x4,x10
 add x10,x10,#1
 madd x10,x10,x22,x5
 ldr x9,[sp,#968]
 ldr d1,[x9,x10,lsl #3]
 fadd d1,d1,d0
 str d1,[x9,x10,lsl #3]
 loop_end temperature_conversion
 /* Complete constituent additions retain increasing field order. */
 add x11,x21,#184
 ldr w12,[x11]
 add x13,x11,#3848
 mov x14,#0
.Lconstituent_field:
 cmp x14,x12
 b.ge .Lcomplete
 ldr w9,[x13,#20]
 cbz w9,.Lnext_constituent
 ldr w9,[x13,#COMP_MP]
 sub w9,w9,#1
 arg x10,35
 madd x10,x9,x25,x10
 str x10,[sp,#960]
 ldr w9,[x13,#216]
 sub w9,w9,#1
 ldr w10,[x19,#5248]
 ldr w15,[sp,#992]
 sub w10,w10,w15
 add w10,w10,#1
 mul x9,x9,x10
 record x10,x20,D_MSLB1GFL9
 ldr w10,[x10]
 sub w10,w10,#1
 add x9,x9,x10
 mul x9,x9,x22
 arg x10,40
 add x10,x10,x9,lsl #3
 str x10,[sp,#968]
 loop_begin constituent
 ldr x9,[sp,#960]
 ldr d0,[x9,x6,lsl #3]
 ldr w10,[sp,#992]
 sub x10,x4,x10
 add x10,x10,#1
 madd x10,x10,x22,x5
 ldr x9,[sp,#968]
 ldr d1,[x9,x10,lsl #3]
 fadd d0,d1,d0
 str d0,[x9,x10,lsl #3]
 loop_end constituent
.Lnext_constituent:
 add x14,x14,#1
 add x13,x13,#368
 b .Lconstituent_field
.Lcomplete:
 mov x0,x28
 bl free
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#864]
 add x9,sp,#704
 ldp d8,d9,[x9,#96]
 ldp d10,d11,[x9,#112]
 ldp d12,d13,[x9,#128]
 ldp d14,d15,[x9,#144]
 ldp x19,x20,[x9,#0]
 ldp x21,x22,[x9,#16]
 ldp x23,x24,[x9,#32]
 ldp x25,x26,[x9,#48]
 ldp x27,x28,[x9,#64]
 ldp x29,x30,[x9,#80]
 add sp,sp,#2048
 ret
.Lunsupported:
 bl abort
 brk #0
.size md2asm_lattex_7259755,.-md2asm_lattex_7259755

/* The accepted body is unchanged. Count its completed private normal calls here. */
.hidden md2asm_lattex_dnt_body_7259755
.global md2asm_lattex_dnt_7240564
.type md2asm_lattex_dnt_7240564,%function
md2asm_lattex_dnt_7240564:
 mov x16,sp
 sub sp,sp,#192
 str x18,[sp,#152]
 stp x29,x30,[sp,#160]
 mov x29,sp
 mov x9,sp
 mov x10,#19
.Lcopy_private_child_stack:
 ldr x11,[x16],#8
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lcopy_private_child_stack
 bl md2asm_lattex_dnt_body_7259755
 count_child
 ldr x18,[sp,#152]
 ldp x29,x30,[sp,#160]
 add sp,sp,#192
 ret
.size md2asm_lattex_dnt_7240564,.-md2asm_lattex_dnt_7240564
.global md2asm_lattex_calls_get
.type md2asm_lattex_calls_get,%function
md2asm_lattex_calls_get:
 adrp x9,.Lcalls
 ldr x0,[x9,:lo12:.Lcalls]
 ret
.global md2asm_lattex_children_get
.type md2asm_lattex_children_get,%function
md2asm_lattex_children_get:
 adrp x9,.Lchildren
 ldr x0,[x9,:lo12:.Lchildren]
 ret
.bss
.p2align 3
.Lcalls: .zero 8
.Lchildren: .zero 8
.section .note.GNU-stack,"",%progbits

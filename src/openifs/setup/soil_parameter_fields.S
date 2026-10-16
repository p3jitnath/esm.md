/* Complete selected SUSSOIL fields. Inputs are typed owned records; all 25 arrays already belong to the caller. */
#include "land_parameter_layout.inc.S"
#include "land_parameter_abi.inc.S"
.text
.p2align 2
.macro SK reg,name
 ldr \reg,[x22,#C_\name]
.endm
.macro SS reg,name
 str \reg,[x19,#SOIL_\name]
.endm
.macro SA reg,name
 ldr x10,[x19,#SOIL_\name]
 str \reg,[x10,x23,lsl #3]
.endm
.macro SL reg,name
 ldr x10,[x19,#SOIL_\name]
 ldr \reg,[x10,x23,lsl #3]
.endm
.global md2asm_soil_parameter_fields
.type md2asm_soil_parameter_fields,%function
md2asm_soil_parameter_fields:
 LAND_ENTER 512
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adrp x22,.Lsoil_constants
 add x22,x22,:lo12:.Lsoil_constants
 SK d0,s_RLICE
 SS d0,RLICE
 SK d0,s_RGH2O
 SS d0,RGH2O
 SK d0,s_RWLMAX
 SS d0,RWLMAX
 SK d0,s_RPSFR
 SS d0,RPSFR
 SK d0,s_RLAMBDAICE
 SS d0,RLAMBDAICE
 SK d0,s_RLAMBDAWAT
 SS d0,RLAMBDAWAT
 SK d0,s_RKERST1
 SS d0,RKERST1
 SK d0,s_RKERST2
 SS d0,RKERST2
 SK d0,s_RKERST3
 SS d0,RKERST3
 SK d0,s_RSIMP
 SS d0,RSIMP
 SK d0,s_RDARSICE
 SS d0,RDARSICE
 SK d0,s_RDANSICE
 SS d0,RDANSICE
 SK d0,s_RRCSICE
 SS d0,RRCSICE
 SK d0,s_RCONDSICE
 SS d0,RCONDSICE
 SK d0,s_RCIMIN
 SS d0,RCIMIN
 SK d0,s_RSRDEP
 SS d0,RSRDEP
 SK d0,s_RSIGORMIN
 SS d0,RSIGORMIN
 SK d0,s_RSIGORMAX
 SS d0,RSIGORMAX
 SK d0,s_RHOICE
 SS d0,RHOICE
 SK d0,s_RLAMICE
 SS d0,RLAMICE
 SK d0,s_RHOCI
 SS d0,RHOCI
 SK d0,s_RALFMINSN
 SS d0,RALFMINSN
 SK d0,s_RALFMAXSN
 SS d0,RALFMAXSN
 SK d0,s_RHOMAXSN_NEW
 SS d0,RHOMAXSN_NEW
 SK d0,s_RHOMAXSN
 SS d0,RHOMAXSN
 SK d0,s_RSNPER
 SS d0,RSNPER
 SK d0,s_RHOMINSN
 SS d0,RHOMINSN
 SK d0,s_RTAUF
 SS d0,RTAUF
 SK d0,s_RTAUA
 SS d0,RTAUA
 SK d0,s_RFRTINY
 SS d0,RFRTINY
 SK d0,s_RALAMSN
 SS d0,RALAMSN
 SK d0,s_RDSNMAX
 SS d0,RDSNMAX
 SK d0,s_RLWCSWEA
 SS d0,RLWCSWEA
 SK d0,s_RLWCSWEB
 SS d0,RLWCSWEB
 SK d0,s_RLWCSWEC
 SS d0,RLWCSWEC
 SK d0,s_RTEMPAMP
 SS d0,RTEMPAMP
 SK d0,s_RHOMINSNA
 SS d0,RHOMINSNA
 SK d0,s_RHOMINSNB
 SS d0,RHOMINSNB
 SK d0,s_RHOMINSNC
 SS d0,RHOMINSNC
 SK d0,s_RHOMINSND
 SS d0,RHOMINSND
 SK d0,s_RSNDTOVERA
 SS d0,RSNDTOVERA
 SK d0,s_RSNDTOVERB
 SS d0,RSNDTOVERB
 SK d0,s_RSNDTOVERC
 SS d0,RSNDTOVERC
 SK d0,s_RSNDAMOB
 SS d0,RSNDAMOB
 SK d0,s_RSNDMOB
 SS d0,RSNDMOB
 SK d0,s_RSNDAW
 SS d0,RSNDAW
 SK d0,s_RSNDBW
 SS d0,RSNDBW
 SK d0,s_RSNDKV
 SS d0,RSNDKV
 SK d0,s_RSNDATAUW
 SS d0,RSNDATAUW
 SK d0,s_RSNDBTAUW
 SS d0,RSNDBTAUW
 SK d0,s_RSNDWCOMPMAX
 SS d0,RSNDWCOMPMAX
 SK d0,s_RSNDTDESTA
 SS d0,RSNDTDESTA
 SK d0,s_RSNDTDESTB
 SS d0,RSNDTDESTB
 SK d0,s_RSNDTDESTC
 SS d0,RSNDTDESTC
 SK d0,s_RSNDTDESTROI
 SS d0,RSNDTDESTROI
 SK d0,s_SSAG1
 SS d0,SSAG1
 SK d0,s_SSAG2
 SS d0,SSAG2
 SK d0,s_SSAG3
 SS d0,SSAG3
 SK d0,s_SSAGSNSMAX
 SS d0,SSAGSNSMAX
 SK d0,s_SSASNEXTMIN
 SS d0,SSASNEXTMIN
 SK d0,s_SSASNEXTMAX
 SS d0,SSASNEXTMAX
 SK d0,s_SSASNEXTCNST
 SS d0,SSASNEXTCNST
 SK d0,s_SNHCONDAV
 SS d0,SNHCONDAV
 SK d0,s_SNHCONDBV
 SS d0,SNHCONDBV
 SK d0,s_SNHCONDCV
 SS d0,SNHCONDCV
 ldr w9,[x21]
 SS w9,LEVGEN
 ldr w9,[x21,#4]
 SS w9,LESSRO
 ldr w9,[x21,#8]
 SS w9,LESN09
 ldr w9,[x21,#12]
 SS w9,LESNML
 ldr w9,[x21,#16]
 SS w9,NSNMLWS
 mov w9,#7
 SS w9,NSOTY
 mov w9,#5
 SS w9,NLEVSN
 SK d0,one
 SK d1,fifteen
 ldr w9,[x21,#8]
 cbz w9,1f
 SK d1,ten
1: fdiv d0,d0,d1
 SS d0,RQSNCR
 add x0,sp,#176
 bl md2asm_soil_texture_average_fields
 ldr x10,[x19,#SOIL_RDAT]
 adr x11,.Lsoil_depth
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x10,[x19,#SOIL_RDAW]
 adr x11,.Lsoil_depth
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x10,[x19,#SOIL_RDAI]
 adr x11,.Lsoil_depth
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x10,[x19,#SOIL_RCWPSISM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RMVGALPHA]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RWCONSM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RMFACM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RNFACM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RLAMBDAM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RWSATM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RWCAPM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RWPWPM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RWRESTM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RDMAXM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RDMINM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RQWEVAPM]
 str xzr,[x10]
 ldr x10,[x19,#SOIL_RQWSBCRM]
 str xzr,[x10]

 SK d8,hundred
 SK d0,grav
 fdiv d8,d8,d0
 SK d9,minus15
 fmul d9,d9,d8
 SK d10,minus10
 ldr w9,[x21]
 cbnz w9,2f
 SK d10,minus33
2: fmul d10,d10,d8
 mov x23,#1
.Lsoil_hydro:
 sub x9,x23,#1
 adr x10,.Lsoil_alpha
 ldr d11,[x10,x9,lsl #3]
 adr x10,.Lsoil_ksat
 ldr d12,[x10,x9,lsl #3]
 adr x10,.Lsoil_n
 ldr d13,[x10,x9,lsl #3]
 adr x10,.Lsoil_lambda
 ldr d14,[x10,x9,lsl #3]
 adr x10,.Lsoil_sat
 ldr d15,[x10,x9,lsl #3]
 adr x10,.Lsoil_res
 ldr d8,[x10,x9,lsl #3]
 SA d11,RMVGALPHA
 SA d12,RWCONSM
 SA d13,RNFACM
 SA d14,RLAMBDAM
 SA d15,RWSATM
 SA d8,RWRESTM
 SK d0,one
 fdiv d0,d0,d11
 SA d0,RCWPSISM
 SK d0,one
 fdiv d1,d0,d13
 fsub d0,d0,d1
 SA d0,RMFACM
 str d0,[sp,#320]
 fsub d0,d15,d8
 str d0,[sp,#328]
 // Both source retention curves use the same rounded inner and outer powers.
 fmul d0,d11,d10
 fabs d0,d0
 fmov d1,d13
 LAND_MATH pow
 SK d1,one
 fadd d0,d1,d0
 fdiv d0,d1,d0
 ldr d1,[sp,#320]
 LAND_MATH pow
 ldr d1,[sp,#328]
 fmul d0,d1,d0
 fadd d0,d8,d0
 SA d0,RWCAPM
 fmul d0,d11,d9
 fabs d0,d0
 fmov d1,d13
 LAND_MATH pow
 SK d1,one
 fadd d0,d1,d0
 fdiv d0,d1,d0
 ldr d1,[sp,#320]
 LAND_MATH pow
 ldr d1,[sp,#328]
 fmul d0,d1,d0
 fadd d0,d8,d0
 SA d0,RWPWPM
 // All seven source saturation gaps exceed 100 machine epsilons.
 ldr d0,[sp,#328]
 fabs d0,d0
 SK d1,eps
 fmax d0,d0,d1
 ldr x9,[sp,#328]
 fmov x10,d0
 lsr x9,x9,#63
 bfi x10,x9,#63,#1
 fmov d0,x10
 str d0,[sp,#336]
 SK d0,maxfac
 fmul d0,d0,d15
 fsub d0,d0,d8
 ldr d1,[sp,#336]
 fdiv d0,d0,d1
 ldr d1,[sp,#320]
 fmov d2,d14
 fmov d3,d11
 fmov d4,d12
 ldr d5,[sp,#336]
 bl .Lsoil_diffusivity
 SA d0,RDMAXM
 SK d0,minfac
 fmul d0,d0,d8
 fsub d0,d0,d8
 ldr d1,[sp,#336]
 fdiv d0,d0,d1
 ldr d1,[sp,#320]
 fmov d2,d14
 fmov d3,d11
 fmov d4,d12
 ldr d5,[sp,#336]
 bl .Lsoil_diffusivity
 SA d0,RDMINM
 SL d0,RWCAPM
 SL d1,RWPWPM
 fsub d0,d0,d1
 SK d1,one
 fdiv d0,d1,d0
 SA d0,RQWEVAPM
 SL d0,RWCAPM
 SK d1,one6
 fmul d0,d1,d0
 ldr d1,[x20,#8]
 fdiv d0,d1,d0
 SA d0,RQWSBCRM
 add x23,x23,#1
 cmp x23,#8
 b.ne .Lsoil_hydro
 // CPTAVE arrays have three values; source chooses the second class.
 ldr d0,[sp,#304]
 SS d0,RWB
 ldr d0,[sp,#256]
 SS d0,RWCONS
 ldr d0,[sp,#280]
 SS d0,RCWPSIS
 ldr d0,[sp,#184]
 SS d0,RWSAT
 ldr d0,[sp,#208]
 SS d0,RWCAP
 ldr d1,[sp,#232]
 SS d1,RWPWP
 fsub d0,d0,d1
 SK d1,one
 fdiv d0,d1,d0
 SS d0,RQWEVAP
 ldr d0,[x19,#SOIL_RWCAP]
 SK d1,one6
 fmul d0,d0,d1
 ldr d1,[x20,#8]
 fdiv d0,d1,d0
 SS d0,RQWSBCR
 SK d0,lambdaq
 SK d1,q
 LAND_MATH pow
 fmov d8,d0
 SK d0,lambdao
 SK d1,one
 SK d2,q
 fsub d1,d1,d2
 LAND_MATH pow
 fmul d8,d8,d0
 mov x23,#1
.Lsoil_thermal:
 SL d9,RWSATM
 SK d0,one
 fsub d9,d0,d9
 SK d0,rhosm
 fmul d10,d9,d0
 SK d0,therma
 fmul d0,d0,d10
 SK d1,thermb
 fadd d0,d0,d1
 SK d1,thermc_sp
 fmul d1,d1,d10
 SK d2,rhosm
 fsub d1,d2,d1
 fdiv d0,d0,d1
 ldr x10,[x19,#SOIL_RLAMBDADRYM]
 sub x9,x23,#1
 str d0,[x10,x9,lsl #3]
 fmov d0,d8
 fmov d1,d9
 LAND_MATH pow
 ldr x10,[x19,#SOIL_RLAMSAT1M]
 sub x9,x23,#1
 str d0,[x10,x9,lsl #3]
 SK d0,rcgdry
 fmul d0,d9,d0
 SL d1,RWCAPM
 SK d2,rgh2o
 fmul d1,d1,d2
 fadd d0,d0,d1
 ldr x10,[x19,#SOIL_RRCSOILM]
 sub x9,x23,#1
 str d0,[x10,x9,lsl #3]
 add x23,x23,#1
 cmp x23,#8
 b.ne .Lsoil_thermal
 ldr d9,[x19,#SOIL_RWSAT]
 SK d0,one
 fsub d9,d0,d9
 SK d0,rhosm
 fmul d10,d9,d0
 SK d0,therma
 fmul d0,d0,d10
 SK d1,thermb
 fadd d0,d0,d1
 SK d1,thermc
 fmul d1,d1,d10
 SK d2,rhosm
 fsub d1,d2,d1
 fdiv d0,d0,d1
 SS d0,RLAMBDADRY
 fmov d0,d8
 fmov d1,d9
 LAND_MATH pow
 SS d0,RLAMSAT1
 SK d0,rcgdry
 fmul d0,d9,d0
 ldr d1,[x19,#SOIL_RWCAP]
 SK d2,rgh2o
 fmul d1,d1,d2
 fadd d0,d0,d1
 SS d0,RRCSOIL
 ldr d0,[x20]
 SK d1,one
 fadd d1,d0,d1
 SS d1,RTF1
 SK d2,three
 fsub d2,d0,d2
 SS d2,RTF2
 fadd d3,d1,d2
 SK d4,half
 fmul d3,d4,d3
 SS d3,RTF3
 fsub d1,d1,d2
 ldr d2,[x20,#8]
 fdiv d1,d2,d1
 SS d1,RTF4
 SK d1,ice_delta
 fsub d1,d0,d1
 SS d1,RTFREEZSICE
 SS d0,RTMELTSICE
 ldr d0,[x19,#SOIL_RCONDSICE]
 ldr d1,[x19,#SOIL_RRCSICE]
 fdiv d0,d0,d1
 SS d0,RDFSICE
 ldr d0,[x21,#96]
 SS d0,RCIMIN
 ldr d0,[x21,#88]
 SS d0,RALFMINPSN
 SK d0,one
 SK d1,secs
 fdiv d0,d0,d1
 SS d0,RSFRESH
 ldr d0,[x19,#SOIL_RFRTINY]
 SK d1,ten
 fmul d0,d1,d0
 SS d0,RFRSMALL
 SK d0,thousand
 SK d1,hundred
 fmul d0,d0,d1
 SS d0,SNHCONDPOV
 ldr d0,[x21,#80]
 SS d0,RTHRFRTI
 ldr x10,[x19,#SOIL_RSNDTDESTC_ML]
 adr x11,.Lsoil_snowdest
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x9,[x11,#32]
 str x9,[x10,#32]
 ldr x10,[x19,#SOIL_RLEVSNMIN]
 adr x11,.Lsoil_snowmin
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x9,[x11,#32]
 str x9,[x10,#32]
 ldr x10,[x19,#SOIL_RLEVSNMAX]
 adr x11,.Lsoil_snowmax
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x9,[x11,#32]
 str x9,[x10,#32]
 ldr x10,[x19,#SOIL_RLEVSNMIN_GL]
 adr x11,.Lsoil_snowmingl
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x9,[x11,#32]
 str x9,[x10,#32]
 ldr x10,[x19,#SOIL_RLEVSNMAX_GL]
 adr x11,.Lsoil_snowmaxgl
 ldp q0,q1,[x11]
 stp q0,q1,[x10]
 ldr x9,[x11,#32]
 str x9,[x10,#32]
 mov w9,#0
 SS w9,LESKTI5
 mov w9,#0
 SS w9,LESKTI8
 mov w9,#1
 SS w9,LESOILCOND
 mov w9,#0
 SS w9,LEROLAKE
 mov w9,#1
 SS w9,LEWBSOILFIX
 mov w9,#0
 SS w9,LEWBCHECK
 mov w9,#0
 SS w9,LEWBCHECKAbort
 mov w9,#0
 SS w9,LESNCHECK
 mov w9,#0
 SS w9,LESNCHECKAbort
 mov w9,#0
 SS w9,LESNWBCON
 LAND_LEAVE 512
.size md2asm_soil_parameter_fields,.-md2asm_soil_parameter_fields

// Inputs are effective saturation, m, lambda, alpha, conductivity and saturation gap.
.Lsoil_diffusivity:
 LAND_ENTER 256
 fmov d8,d0
 fmov d9,d1
 fmov d10,d2
 fmov d11,d3
 fmov d12,d4
 fmov d13,d5
 fmov d14,#1.0
 fdiv d15,d14,d9
 fmov d0,d8
 fsub d1,d10,d15
 LAND_MATH pow
 str d0,[sp,#176]
 fmov d0,d8
 fmov d1,d15
 LAND_MATH pow
 fsub d15,d14,d0
 fmov d0,d15
 fmov d1,d9
 LAND_MATH pow
 str d0,[sp,#184]
 fmov d0,d15
 fneg d1,d9
 LAND_MATH pow
 ldr d1,[sp,#184]
 fadd d0,d1,d0
 fmov d1,#2.0
 fsub d0,d0,d1
 ldr d1,[sp,#176]
 fmul d0,d1,d0
 fsub d1,d14,d9
 fmul d1,d1,d12
 fmul d2,d11,d9
 fmul d2,d2,d13
 fdiv d1,d1,d2
 fmul d0,d1,d0
 LAND_LEAVE 256
.section .rodata
.p2align 3
.Lsoil_constants:
.equ C_zero,0
.quad 0x0000000000000000 /* zero */
.equ C_one,8
.quad 0x3ff0000000000000 /* one */
.equ C_two,16
.quad 0x4000000000000000 /* two */
.equ C_half,24
.quad 0x3fe0000000000000 /* half */
.equ C_fifteen,32
.quad 0x402e000000000000 /* fifteen */
.equ C_ten,40
.quad 0x4024000000000000 /* ten */
.equ C_hundred,48
.quad 0x4059000000000000 /* hundred */
.equ C_thousand,56
.quad 0x408f400000000000 /* thousand */
.equ C_grav,64
.quad 0x402399999999999a /* grav */
.equ C_minus15,72
.quad 0xc02e000000000000 /* minus15 */
.equ C_minus10,80
.quad 0xbfb999999999999a /* minus10 */
.equ C_minus33,88
.quad 0xbfd51eb851eb851f /* minus33 */
.equ C_maxfac,96
.quad 0x3feff7ced916872b /* maxfac */
.equ C_minfac,104
.quad 0x3ff004189374bc6a /* minfac */
.equ C_one6,112
.quad 0x3ff999999999999a /* one6 */
.equ C_rhosm,120
.quad 0x40a5180000000000 /* rhosm */
.equ C_lambdaq,128
.quad 0x401ecccccccccccd /* lambdaq */
.equ C_lambdao,136
.quad 0x4000000000000000 /* lambdao */
.equ C_q,144
.quad 0x3fd999999999999a /* q */
.equ C_rcgdry,152
.quad 0x41386a0000000000 /* rcgdry */
.equ C_therma,160
.quad 0x3fc147ae147ae148 /* therma */
.equ C_thermb,168
.quad 0x40502ccccccccccd /* thermb */
.equ C_thermc,176
.quad 0x3fee4dd2f1a9fbe7 /* thermc */
.equ C_thermc_sp,184
.quad 0x3fee4dd300000000 /* thermc_sp */
.equ C_rgh2o,192
.quad 0x414fe41000000000 /* rgh2o */
.equ C_three,200
.quad 0x4008000000000000 /* three */
.equ C_ice_delta,208
.quad 0x3ffb333333333333 /* ice_delta */
.equ C_secs,216
.quad 0x40ac200000000000 /* secs */
.equ C_eps,224
.quad 0x3d19000000000000 /* eps */
.equ C_s_RLICE,232
.quad 0x3fd3333333333333 /* s_RLICE */
.equ C_s_RGH2O,240
.quad 0x414fe41000000000 /* s_RGH2O */
.equ C_s_RWLMAX,248
.quad 0x3fc999999999999a /* s_RWLMAX */
.equ C_s_RPSFR,256
.quad 0x4000000000000000 /* s_RPSFR */
.equ C_s_NSOTY,264
.quad 0x401c000000000000 /* s_NSOTY */
.equ C_s_RLAMBDAICE,272
.quad 0x400199999999999a /* s_RLAMBDAICE */
.equ C_s_RLAMBDAWAT,280
.quad 0x3fe23d70a3d70a3d /* s_RLAMBDAWAT */
.equ C_s_RKERST1,288
.quad 0x3fb999999999999a /* s_RKERST1 */
.equ C_s_RKERST2,296
.quad 0x3ff0000000000000 /* s_RKERST2 */
.equ C_s_RKERST3,304
.quad 0x3ff0000000000000 /* s_RKERST3 */
.equ C_s_RSIMP,312
.quad 0x3ff0000000000000 /* s_RSIMP */
.equ C_s_RDARSICE,320
.quad 0x3ff8000000000000 /* s_RDARSICE */
.equ C_s_RDANSICE,328
.quad 0x3ff8000000000000 /* s_RDANSICE */
.equ C_s_RRCSICE,336
.quad 0x413cbf6000000000 /* s_RRCSICE */
.equ C_s_RCONDSICE,344
.quad 0x40003d70a3d70a3d /* s_RCONDSICE */
.equ C_s_RCIMIN,352
.quad 0x3f947ae147ae147b /* s_RCIMIN */
.equ C_s_RSRDEP,360
.quad 0x3fe0000000000000 /* s_RSRDEP */
.equ C_s_RSIGORMIN,368
.quad 0x4059000000000000 /* s_RSIGORMIN */
.equ C_s_RSIGORMAX,376
.quad 0x408f400000000000 /* s_RSIGORMAX */
.equ C_s_RHOICE,384
.quad 0x408cc00000000000 /* s_RHOICE */
.equ C_s_RLAMICE,392
.quad 0x4001c28f5c28f5c3 /* s_RLAMICE */
.equ C_s_RHOCI,400
.quad 0x413f47d000000000 /* s_RHOCI */
.equ C_s_RALFMINSN,408
.quad 0x3fe0000000000000 /* s_RALFMINSN */
.equ C_s_RALFMAXSN,416
.quad 0x3feb333333333333 /* s_RALFMAXSN */
.equ C_s_RHOMAXSN_NEW,424
.quad 0x407f400000000000 /* s_RHOMAXSN_NEW */
.equ C_s_RHOMAXSN,432
.quad 0x4072c00000000000 /* s_RHOMAXSN */
.equ C_s_RSNPER,440
.quad 0x408f400000000000 /* s_RSNPER */
.equ C_s_RHOMINSN,448
.quad 0x4059000000000000 /* s_RHOMINSN */
.equ C_s_RTAUF,456
.quad 0x3fceb851eb851eb8 /* s_RTAUF */
.equ C_s_RTAUA,464
.quad 0x3f80624dd2f1a9fc /* s_RTAUA */
.equ C_s_RFRTINY,472
.quad 0x3e7ad7f29abcaf48 /* s_RFRTINY */
.equ C_s_RALAMSN,480
.quad 0x3ffe147ae147ae14 /* s_RALAMSN */
.equ C_s_RDSNMAX,488
.quad 0x3ff0000000000000 /* s_RDSNMAX */
.equ C_s_RLWCSWEA,496
.quad 0x4069000000000000 /* s_RLWCSWEA */
.equ C_s_RLWCSWEB,504
.quad 0x3f9eb851eb851eb8 /* s_RLWCSWEB */
.equ C_s_RLWCSWEC,512
.quad 0x3fb999999999999a /* s_RLWCSWEC */
.equ C_s_RTEMPAMP,520
.quad 0x4010000000000000 /* s_RTEMPAMP */
.equ C_s_RHOMINSNA,528
.quad 0x405b400000000000 /* s_RHOMINSNA */
.equ C_s_RHOMINSNB,536
.quad 0x4018000000000000 /* s_RHOMINSNB */
.equ C_s_RHOMINSNC,544
.quad 0x403a000000000000 /* s_RHOMINSNC */
.equ C_s_RHOMINSND,552
.quad 0x4049000000000000 /* s_RHOMINSND */
.equ C_s_RSNDTOVERA,560
.quad 0x4181a49a00000000 /* s_RSNDTOVERA */
.equ C_s_RSNDTOVERB,568
.quad 0x3fb4bc6a7ef9db23 /* s_RSNDTOVERB */
.equ C_s_RSNDTOVERC,576
.quad 0x3f926e978d4fdf3b /* s_RSNDTOVERC */
.equ C_s_RSNDAMOB,584
.quad 0x3ff4000000000000 /* s_RSNDAMOB */
.equ C_s_RSNDMOB,592
.quad 0x4072700000000000 /* s_RSNDMOB */
.equ C_s_RSNDAW,600
.quad 0x4006f1a9fbe76c8b /* s_RSNDAW */
.equ C_s_RSNDBW,608
.quad 0x3fb5c28f5c28f5c3 /* s_RSNDBW */
.equ C_s_RSNDKV,616
.quad 0x3ff4000000000000 /* s_RSNDKV */
.equ C_s_RSNDATAUW,624
.quad 0x4024000000000000 /* s_RSNDATAUW */
.equ C_s_RSNDBTAUW,632
.quad 0x400a000000000000 /* s_RSNDBTAUW */
.equ C_s_RSNDWCOMPMAX,640
.quad 0x4075e00000000000 /* s_RSNDWCOMPMAX */
.equ C_s_RSNDTDESTA,648
.quad 0x3ec77cf44765195f /* s_RSNDTDESTA */
.equ C_s_RSNDTDESTB,656
.quad 0x3fa5810624dd2f1b /* s_RSNDTDESTB */
.equ C_s_RSNDTDESTC,664
.quad 0x407cc00000000000 /* s_RSNDTDESTC */
.equ C_s_RSNDTDESTROI,672
.quad 0x4062c00000000000 /* s_RSNDTDESTROI */
.equ C_s_SSAG1,680
.quad 0x3f24f8b588e368f1 /* s_SSAG1 */
.equ C_s_SSAG2,688
.quad 0x0000000000000000 /* s_SSAG2 */
.equ C_s_SSAG3,696
.quad 0x3d3ef655d91d9bf5 /* s_SSAG3 */
.equ C_s_SSAGSNSMAX,704
.quad 0x3f66e7a320000000 /* s_SSAGSNSMAX */
.equ C_s_SSASNEXTMIN,712
.quad 0x4014000000000000 /* s_SSASNEXTMIN */
.equ C_s_SSASNEXTMAX,720
.quad 0x4049000000000000 /* s_SSASNEXTMAX */
.equ C_s_SSASNEXTCNST,728
.quad 0x3f6f212d77318fc5 /* s_SSASNEXTCNST */
.equ C_s_SNHCONDAV,736
.quad 0xbfaed6777079e59f /* s_SNHCONDAV */
.equ C_s_SNHCONDBV,744
.quad 0x4004570a3d70a3d7 /* s_SNHCONDBV */
.equ C_s_SNHCONDCV,752
.quad 0x40721fd70a3d70a4 /* s_SNHCONDCV */
.Lsoil_alpha:
.quad 0x400ea3d70a3d70a4
.quad 0x40091eb851eb851f
.quad 0x3fea8f5c28f5c28f
.quad 0x400d5c28f5c28f5c
.quad 0x4005333333333333
.quad 0x3ff4cccccccccccd
.quad 0x40091eb851eb851f
.Lsoil_ksat:
.quad 0x3edd1bc4ac97ce12
.quad 0x3eb376297cfbff14
.quad 0x3e91a64e3b7fe673
.quad 0x3ec813472f946d35
.quad 0x3ebd313e3b79fe9f
.quad 0x3eaf34a3a0ae8bc4
.quad 0x3eb376297cfbff14
.Lsoil_n:
.quad 0x3ff609d495182a99
.quad 0x3ff2e2eb1c432ca5
.quad 0x3ff40ff972474539
.quad 0x3ff19e83e425aee6
.quad 0x3ff1a71de69ad42c
.quad 0x3ff3432ca57a786c
.quad 0x3ff2e2eb1c432ca5
.Lsoil_lambda:
.quad 0x3ff4000000000000
.quad 0xc002bc9eecbfb15b
.quad 0xbfe2d42c3c9eecc0
.quad 0xbfffa29c779a6b51
.quad 0x4004000000000000
.quad 0x3fd999999999999a
.quad 0xc002bc9eecbfb15b
.Lsoil_sat:
.quad 0x3fd9cac083126e98
.quad 0x3fdc189374bc6a7f
.quad 0x3fdb851eb851eb85
.quad 0x3fe0a3d70a3d70a4
.quad 0x3fe3a5e353f7ced9
.quad 0x3fe883126e978d50
.quad 0x3fdc189374bc6a7f
.Lsoil_res:
.quad 0x3f9999999999999a
.quad 0x3f847ae147ae147b
.quad 0x3f847ae147ae147b
.quad 0x3f847ae147ae147b
.quad 0x3f847ae147ae147b
.quad 0x3f847ae147ae147b
.quad 0x3f847ae147ae147b
.Lsoil_depth:
.quad 0x3fb1eb851eb851ec
.quad 0x3fcae147ae147ae1
.quad 0x3fe70a3d70a3d70a
.quad 0x3ffe3d70a3d70a3d
.Lsoil_snowdest:
.quad 0x3fbcac083126e979
.quad 0x3fc374bc6a7ef9db
.quad 0x3fc89374bc6a7efa
.quad 0x3fd26e978d4fdf3b
.quad 0x3fdf3b645a1cac08
.Lsoil_snowmin:
.quad 0x3fb3333333333333
.quad 0x3fa999999999999a
.quad 0x3fa999999999999a
.quad 0x3fa999999999999a
.quad 0x3fa999999999999a
.Lsoil_snowmax:
.quad 0x3fb3333333333333
.quad 0x3fb999999999999a
.quad 0x3fc999999999999a
.quad 0xbff0000000000000
.quad 0x3fc3333333333333
.Lsoil_snowmingl:
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.Lsoil_snowmaxgl:
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.quad 0x3fe0000000000000
.quad 0xbff0000000000000
.section .note.GNU-stack,"",%progbits

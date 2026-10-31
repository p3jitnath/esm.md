/* Contract: skills/md2asm/references/openifs/setup/photosynthesis_parameter_setup.md. */
/* Complete SUCOTWO field stage. x0 TAGS2344 with31ownedarrays,x1 TCST128,x2 optimizationnamespace1368. */
.arch armv8.2-a
#include "land_parameter_abi.inc.S"
#include "photosynthesis_parameter_layout.inc.S"
.text
.p2align 4
.macro CK reg,name
 ldr \reg,[x22,#CP_\name]
.endm
.macro CS reg,name
 str \reg,[x19,#AGS_\name]
.endm
.macro CL reg,name
 ldr x9,[x19,#AGS_\name]
 ldr \reg,[x9,x23,lsl #3]
.endm
.macro CA reg,name
 ldr x9,[x19,#AGS_\name]
 str \reg,[x9,x23,lsl #3]
.endm
.global md2asm_carbon_assimilation_parameter_fields
.type md2asm_carbon_assimilation_parameter_fields,%function
md2asm_carbon_assimilation_parameter_fields:
 LAND_ENTER 512
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adrp x22,.Lcarbon_parameter_constants
 add x22,x22,:lo12:.Lcarbon_parameter_constants
#include "carbon_parameter_literal_stores.inc.S"
 CK d0,CO2_massfrac
 CK d1,CO2_molmass
 fmul d0,d0,d1
 CK d1,air_molmass
 fdiv d0,d0,d1
 CS d0,RCO2
 adr x9,.Lcarbon_parameter_RVCH4S
 add x10,x19,#AGS_RVCH4S
 ldp x11,x12,[x9]
 stp x11,x12,[x10]
 ldr x11,[x9,#16]
 str x11,[x10,#16]
 adr x9,.Lcarbon_parameter_RVTOPT
 ldr x10,[x19,#AGS_RVTOPT]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVFZERO
 ldr x10,[x19,#AGS_RVFZERO]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVFZEROST
 ldr x10,[x19,#AGS_RVFZEROST]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVEPSO
 ldr x10,[x19,#AGS_RVEPSO]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVGAMM
 ldr x10,[x19,#AGS_RVGAMM]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVQDGAMM
 ldr x10,[x19,#AGS_RVQDGAMM]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVQDGMES
 ldr x10,[x19,#AGS_RVQDGMES]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVT1GMES
 ldr x10,[x19,#AGS_RVT1GMES]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVT2GMES
 ldr x10,[x19,#AGS_RVT2GMES]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVAMMAX
 ldr x10,[x19,#AGS_RVAMMAX]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVQDAMMAX
 ldr x10,[x19,#AGS_RVQDAMMAX]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVT1AMMAX
 ldr x10,[x19,#AGS_RVT1AMMAX]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVT2AMMAX
 ldr x10,[x19,#AGS_RVT2AMMAX]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVAH
 ldr x10,[x19,#AGS_RVAH]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVBH
 ldr x10,[x19,#AGS_RVBH]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_LVSTRESS
 ldr x10,[x19,#AGS_LVSTRESS]
 mov x12,#21
1: ldr w11,[x9],#4
 str w11,[x10],#4
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVBSLAI
 ldr x10,[x19,#AGS_RVBSLAI]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVLAIMIN
 ldr x10,[x19,#AGS_RVLAIMIN]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVGMES
 ldr x10,[x19,#AGS_RVGMES]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVGC
 ldr x10,[x19,#AGS_RVGC]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVDMAX
 ldr x10,[x19,#AGS_RVDMAX]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVF2I
 ldr x10,[x19,#AGS_RVF2I]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVCE
 ldr x10,[x19,#AGS_RVCE]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVCF
 ldr x10,[x19,#AGS_RVCF]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVCNA
 ldr x10,[x19,#AGS_RVCNA]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b
 adr x9,.Lcarbon_parameter_RVCH4QVT
 ldr x10,[x19,#AGS_RVCH4QVT]
 mov x12,#21
1: ldr x11,[x9],#8
 str x11,[x10],#8
 subs x12,x12,#1
 b.ne 1b

 // Respiration copies preserve all input bits, with type zero from type seven.
 ldr x9,[x21]
 ldr x10,[x19,#AGS_RVR0VT]
 mov x11,#2
.Lcarbon_respiration_column:
 ldr x12,[x9,#48]
 str x12,[x10],#8
 mov x13,#20
.Lcarbon_respiration_copy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x13,x13,#1
 b.ne .Lcarbon_respiration_copy
 subs x11,x11,#1
 b.ne .Lcarbon_respiration_column
 adr x10,.Lcarbon_parameter_RVSEFOLD
 ldr x11,[x19,#AGS_RVSEFOLD]
 ldr d1,[x20,#16]
 mov x9,#1
.Lcarbon_leaf_time:
 ldr d0,[x10,x9,lsl #3]
 fmul d0,d0,d1
 str d0,[x11,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#21
 b.ne .Lcarbon_leaf_time
 ldr x9,[x11,#56]
 str x9,[x11]
 mov x23,#0
.Lcarbon_nitrogen:
 CL d0,RVCE
 CL d1,RVCNA
 fmul d0,d0,d1
 CL d1,RVCF
 fadd d0,d0,d1
 CK d1,one
 fdiv d0,d1,d0
 CA d0,RVBSLAI_NITRO
 add x23,x23,#1
 cmp x23,#21
 b.ne .Lcarbon_nitrogen
 mov x23,#0
.Lcarbon_scattering:
 ldr d0,[x19,#AGS_RXBOMEGA]
 sub x9,x23,#3
 cmp x9,#3
 b.ls .Lcarbon_forest_scattering
 sub x9,x23,#18
 cmp x9,#1
 b.hi .Lcarbon_store_scattering
.Lcarbon_forest_scattering:
 CK d1,one
 fmul d0,d0,d1
.Lcarbon_store_scattering:
 CA d0,RXBOMEGAM
 add x23,x23,#1
 cmp x23,#21
 b.ne .Lcarbon_scattering
 // Coefficients passed to the complete one-cell COTWO child.
 ldr d0,[x19,#AGS_RAIRTOH2O]
 ldr d1,[x19,#AGS_RCO2TOH2O]
 stp d0,d1,[sp,#256]
 ldr d0,[x19,#AGS_RCONDSTMIN]
 ldr d1,[x19,#AGS_RRDCF]
 stp d0,d1,[sp,#272]
 mov x23,#0
.Lcarbon_optimum_type:
 CL d8,RVTOPT
 CK d0,twentyfive
 fsub d9,d8,d0
 CK d0,one_tenth
 fmul d9,d0,d9
 CL d0,RVQDGAMM
 fmov d1,d9
 LAND_MATH pow
 CL d1,RVGAMM
 fmul d10,d1,d0
 CL d0,RVQDAMMAX
 fmov d1,d9
 LAND_MATH pow
 CL d1,RVAMMAX
 fmul d11,d1,d0
 CL d0,RVT1AMMAX
 fsub d0,d0,d8
 CK d1,three_tenths
 fmul d0,d1,d0
 LAND_MATH exp
 CK d1,one
 fadd d12,d1,d0
 CL d0,RVT2AMMAX
 fsub d0,d8,d0
 CK d1,three_tenths
 fmul d0,d1,d0
 LAND_MATH exp
 CK d1,one
 fadd d0,d1,d0
 fmul d0,d12,d0
 fdiv d11,d11,d0
 CL d0,RVQDGMES
 fmov d1,d9
 LAND_MATH pow
 CL d1,RVGMES
 fmul d12,d1,d0
 CL d0,RVT1GMES
 fsub d0,d0,d8
 CK d1,three_tenths
 fmul d0,d1,d0
 LAND_MATH exp
 CK d1,one
 fadd d13,d1,d0
 CL d0,RVT2GMES
 fsub d0,d8,d0
 CK d1,three_tenths
 fmul d0,d1,d0
 LAND_MATH exp
 CK d1,one
 fadd d0,d1,d0
 fmul d0,d13,d0
 fdiv d12,d12,d0
 CK d0,one
 fmul d12,d12,d0
 CL d13,RVFZEROST
 sub x9,x23,#3
 cmp x9,#3
 b.ls .Lcarbon_forest_fraction
 sub x9,x23,#18
 cmp x9,#1
 b.hi .Lcarbon_pack_cell
.Lcarbon_forest_fraction:
 CL d0,RVGMES
 CK d1,thousand
 fmul d0,d0,d1
 LAND_MATH log
 ldr d1,[x19,#AGS_RAW]
 fsub d0,d1,d0
 ldr d1,[x19,#AGS_RBW]
 fdiv d13,d0,d1
.Lcarbon_pack_cell:
 CL d0,RVGC
 ldr d1,[x19,#AGS_RCO2]
 stp d0,d1,[sp,#176]
 ldr d0,[x19,#AGS_RDSPOPT]
 CL d1,RVDMAX
 stp d0,d1,[sp,#192]
 ldr d0,[x19,#AGS_RIAOPT]
 stp d0,d10,[sp,#208]
 stp d13,d12,[sp,#224]
 CL d0,RVEPSO
 stp d0,d11,[sp,#240]
 add x0,sp,#176
 add x1,sp,#256
 add x2,sp,#288
 bl md2asm_one_cell_carbon_assimilation_fields
 ldr d0,[sp,#288]
 CA d0,RVANMAX
 add x23,x23,#1
 cmp x23,#21
 b.ne .Lcarbon_optimum_type
 // Three-point Gaussian quadrature retains the last source Newton derivative.
 mov x23,#1
.Lcarbon_gauss_point:
 scvtf d0,x23
 CK d1,quarter
 fsub d0,d0,d1
 ldr d1,[x20,#8]
 fmul d0,d1,d0
 CK d1,gauss_threehalf
 fdiv d0,d0,d1
 LAND_MATH cos
 fmov d8,d0
 mov x24,#100
.Lcarbon_gauss_newton:
 CK d9,one
 CK d10,zero
 mov x25,#1
.Lcarbon_gauss_polynomial:
 fmov d11,d10
 fmov d10,d9
 scvtf d0,x25
 CK d1,two
 fmul d1,d1,d0
 CK d2,one
 fsub d1,d1,d2
 fmul d1,d1,d8
 fmul d1,d1,d10
 fsub d2,d0,d2
 fmul d2,d2,d11
 fsub d1,d1,d2
 fdiv d9,d1,d0
 add x25,x25,#1
 cmp x25,#4
 b.ne .Lcarbon_gauss_polynomial
 fmul d0,d8,d9
 fsub d0,d0,d10
 CK d1,three
 fmul d0,d1,d0
 fmul d1,d8,d8
 CK d2,one
 fsub d1,d1,d2
 fdiv d11,d0,d1
 fmov d12,d8
 fdiv d0,d9,d11
 fsub d8,d12,d0
 fsub d0,d8,d12
 fabs d0,d0
 CK d1,gauss_tolerance
 fcmp d0,d1
 b.le .Lcarbon_gauss_converged
 subs x24,x24,#1
 b.ne .Lcarbon_gauss_newton
.Lcarbon_gauss_converged:
 CK d0,half
 fmul d1,d0,d8
 fsub d2,d0,d1
 fadd d0,d0,d1
 sub x9,x23,#1
 mov x10,#3
 sub x10,x10,x23
 add x11,x19,#AGS_RABC
 str d2,[x11,x9,lsl #3]
 str d0,[x11,x10,lsl #3]
 fmul d0,d8,d8
 CK d1,one
 fsub d0,d1,d0
 fmul d0,d0,d11
 fmul d0,d0,d11
 CK d1,two
 CK d2,half
 fmul d1,d1,d2
 fdiv d0,d1,d0
 add x11,x19,#AGS_RPOI
 str d0,[x11,x9,lsl #3]
 str d0,[x11,x10,lsl #3]
 add x23,x23,#1
 cmp x23,#3
 b.ne .Lcarbon_gauss_point
 LAND_LEAVE 512
.size md2asm_carbon_assimilation_parameter_fields,.-md2asm_carbon_assimilation_parameter_fields
.section .rodata
#include "carbon_parameter_source_literals.inc.S"
.section .note.GNU-stack,"",%progbits

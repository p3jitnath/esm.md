/* Contract: skills/md2asm/references/openifs/setup/surface_land_parameters.md. */
.arch armv8.2-a
#include "land_parameter_abi.inc.S"
#include "land_parameter_layout.inc.S"
.text
.p2align 4
.global md2asm_vegetation_parameter_fields
.type md2asm_vegetation_parameter_fields,%function
/* x0 TVEG776,x1 TSOIL2416,x2 TCST128,x3 TDIM16,x4 controls136. */
md2asm_vegetation_parameter_fields:
 LAND_ENTER 256
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x4
 mov w9,#20
 str w9,[x19,#VEG_NVTYPES]
 mov w9,#2
 str w9,[x19,#VEG_NVTILES]
 adr x23,.Lland_vegetation_literals
 ldr d0,[x23]
 str d0,[x19,#VEG_REPEVAP]
 ldr d0,[x23,#8]
 str d0,[x19,#VEG_RVINTER]
 ldr x0,[x19,#VEG_RVCOV]
 adr x1,.Lland_vegetation_RVCOV
 bl .Lland_copy_vegetation_values
 ldr x0,[x19,#VEG_RVLAI]
 adr x1,.Lland_vegetation_RVLAI
 bl .Lland_copy_vegetation_values
 ldr w9,[x22,#20]
 str w9,[x19,#VEG_LELAIV]
 ldr w9,[x22,#24]
 str w9,[x19,#VEG_LECTESSEL]
 ldr w9,[x22,#28]
 str w9,[x19,#VEG_LEAGS]
 ldr w9,[x22,#32]
 str w9,[x19,#VEG_LEFARQUHAR]
 ldr w9,[x22,#36]
 str w9,[x19,#VEG_LEAIRCO2COUP]
 ldr x9,[x22,#104]
 str x9,[x19,#VEG_RLAIINT]
 ldp d0,d1,[x23,#16]
 str d0,[x19,#VEG_RLHAERO]
 str d1,[x19,#VEG_RLHAEROS]
 ldr x0,[x19,#VEG_RVLAMSK]
 adr x1,.Lland_vegetation_RVLAMSK
 bl .Lland_copy_vegetation_values
 ldr x0,[x19,#VEG_RVLAMSKS]
 adr x1,.Lland_vegetation_RVLAMSKS
 bl .Lland_copy_vegetation_values
 ldr x0,[x19,#VEG_RVTRSR]
 adr x1,.Lland_vegetation_RVTRSR
 bl .Lland_copy_vegetation_values
 ldr x0,[x19,#VEG_RVROOTSA]
 add x0,x0,#32
 ldr x1,[x20,#SOIL_RDAW]
 bl md2asm_vegetation_root_fraction_fields
 ldr x9,[x19,#VEG_RVROOTSA]
 ldp x10,x11,[x9,#256]
 stp x10,x11,[x9]
 ldp x10,x11,[x9,#272]
 stp x10,x11,[x9,#16]
 ldr d0,[x23,#32]
 str d0,[x19,#VEG_RCEPSW]
 ldr x0,[x19,#VEG_RVRSMIN]
 adr x1,.Lland_vegetation_RVRSMIN
 bl .Lland_copy_vegetation_values
 ldr x0,[x19,#VEG_RVHSTR]
 adr x1,.Lland_vegetation_RVHSTR
 bl .Lland_copy_vegetation_values
 ldr d0,[x21,#48]
 fmov d1,#1.0
 fadd d0,d0,d1
 ldr d1,[x23,#40]
 fmul d8,d1,d0
 ldr x24,[x19,#VEG_RVHSTR]
 mov x25,#0
.Lland_vegetation_humidity:
 ldr d0,[x24,x25,lsl#3]
 fmul d0,d8,d0
 str d0,[x24,x25,lsl#3]
 add x25,x25,#1
 cmp x25,#21
 b.lo .Lland_vegetation_humidity
 ldr x0,[x19,#VEG_RVZ0M]
 adr x1,.Lland_vegetation_RVZ0M
 bl .Lland_copy_vegetation_values
 ldr x24,[x19,#VEG_RVZ0M]
 ldr x25,[x19,#VEG_RVZ0H]
 adr x26,.Lland_vegetation_heat_divisors
 mov x27,#1
.Lland_vegetation_heat_roughness:
 ldr d0,[x24,x27,lsl#3]
 sub x9,x27,#1
 ldrb w9,[x26,x9]
 cbz w9,.Lland_vegetation_heat_store
 cmp w9,#1
 b.ne .Lland_vegetation_heat_ten
 ldr d1,[x23,#48]
 b .Lland_vegetation_heat_divide
.Lland_vegetation_heat_ten:
 ldr d1,[x23,#56]
.Lland_vegetation_heat_divide:
 fdiv d0,d0,d1
.Lland_vegetation_heat_store:
 str d0,[x25,x27,lsl#3]
 add x27,x27,#1
 cmp x27,#21
 b.lo .Lland_vegetation_heat_roughness
 ldr x9,[x25,#64]
 str x9,[x25]
 ldp d0,d1,[x23,#64]
 str d0,[x19,#VEG_RCVC]
 str d1,[x19,#VEG_RVLT]
 ldr d0,[x23,#8]
 str d0,[x19,#VEG_RVRAD]
 ldr d0,[x23]
 str d0,[x19,#VEG_REPSR]
 mov w0,#0
 LAND_LEAVE 256
.size md2asm_vegetation_parameter_fields,.-md2asm_vegetation_parameter_fields
/* Source order is entries1..20, then default entry0 from desert type8. */
.Lland_copy_vegetation_values:
 mov x4,x0
 add x0,x0,#8
 mov x2,#20
.Lland_copy_vegetation_loop:
 ldr x3,[x1],#8
 str x3,[x0],#8
 subs x2,x2,#1
 b.ne .Lland_copy_vegetation_loop
 ldr x3,[x4,#64]
 str x3,[x4]
 ret
.p2align 4
.global md2asm_surface_exchange_parameter_fields
.type md2asm_surface_exchange_parameter_fields,%function
/* Raw complete SUVEXC: x0 TEXC144,x1 controls136. */
md2asm_surface_exchange_parameter_fields:
 adr x8,.Lland_exchange_literals
 ldr d0,[x8]
 str d0,[x0,#EXC_RKAP]
 ldr d3,[x1,#128]
 ldr d0,[x8,#8]
 fdiv d0,d0,d3
 str d0,[x0,#EXC_RZ0ICE]
 ldr d0,[x8,#16]
 str d0,[x0,#EXC_RCHAR]
 ldr d0,[x8,#24]
 fmul d0,d0,d0
 str d0,[x0,#EXC_REPDU2]
 ldr d0,[x8,#32]
 str d0,[x0,#EXC_REPUST]
 ldr d0,[x8,#40]
 fdiv d0,d0,d3
 str d0,[x0,#EXC_RNU]
 ldr d1,[x8,#48]
 fmul d1,d1,d0
 str d1,[x0,#EXC_RNUM]
 ldr d1,[x8,#56]
 fmul d1,d1,d0
 str d1,[x0,#EXC_RNUH]
 ldr d1,[x8,#64]
 fmul d1,d1,d0
 str d1,[x0,#EXC_RNUQ]
 ldr d0,[x8,#72]
 fdiv d0,d0,d3
 str d0,[x0,#EXC_RPARZI]
 mov w9,#1
 str w9,[x0,#EXC_LELWDD]
 str w9,[x0,#EXC_LELWTL]
 ldr w9,[x1,#40]
 str w9,[x0,#EXC_LEOCWA]
 ldr w9,[x1,#44]
 str w9,[x0,#EXC_LEOCCO]
 ldr w9,[x1,#48]
 str w9,[x0,#EXC_LEOCSA]
 ldr w9,[x1,#52]
 str w9,[x0,#EXC_LEOCLA]
 ldr w9,[x1,#56]
 str w9,[x0,#EXC_LWCOU]
 ldr w9,[x1,#60]
 str w9,[x0,#EXC_LWCOU2W]
 ldr w9,[x1,#64]
 str w9,[x0,#EXC_LWCOUHMF]
 ldr w9,[x1,#68]
 str w9,[x0,#EXC_LSCMEC]
 ldr w9,[x1,#72]
 str w9,[x0,#EXC_LROUGH]
 ldr x9,[x1,#112]
 str x9,[x0,#EXC_REXTZ0M]
 ldr x9,[x1,#120]
 str x9,[x0,#EXC_REXTZ0H]
 mov w0,#0
 ret
.size md2asm_surface_exchange_parameter_fields,.-md2asm_surface_exchange_parameter_fields
.section .rodata
.p2align 3
.Lland_vegetation_literals: .double 1e-10,.5,15.0,10.0,.001,1013.25,100.0,10.0,240.0,4.0
.Lland_exchange_literals: .double .4,.001,.0155,.1,.0001,1.5e-5,.11,.40,.62,1000.0
.Lland_vegetation_heat_divisors: .byte 1,1,0,0,0,0,1,1,1,1,1,2,1,2,2,1,1,0,1,2
.p2align 3
.Lland_vegetation_RVCOV: .double 0.9,0.85,0.9,0.9,0.9,0.99,0.7,0.0,0.5,0.9,0.1,0.0,0.6,0.0,0.0,0.5,0.5,0.9,0.9,0.6
.Lland_vegetation_RVLAI: .double 3.0,2.0,5.0,5.0,5.0,6.0,2.0,0.5,1.0,3.0,0.5,0.0,4.0,0.0,0.0,3.0,1.5,5.0,2.5,4.0
.Lland_vegetation_RVLAMSK: .double 10.0,10.0,10.0,10.0,10.0,10.0,10.0,15.0,10.0,10.0,10.0,58.0,10.0,10000000000.0,10000000000.0,10.0,10.0,10.0,10.0,10000000000.0
.Lland_vegetation_RVLAMSKS: .double 10.0,10.0,10.0,10.0,10.0,10.0,10.0,15.0,10.0,10.0,10.0,58.0,10.0,10000000000.0,10000000000.0,10.0,10.0,10.0,10.0,10000000000.0
.Lland_vegetation_RVTRSR: .double 0.05,0.05,0.03,0.03,0.03,0.03,0.05,0.0,0.05,0.05,0.05,0.0,0.05,0.0,0.0,0.05,0.05,0.03,0.03,0.0
.Lland_vegetation_RVRSMIN: .double 100.0,100.0,250.0,250.0,175.0,240.0,100.0,250.0,80.0,100.0,150.0,0.0,240.0,0.0,0.0,225.0,225.0,250.0,175.0,150.0
.Lland_vegetation_RVHSTR: .double 0.0,0.0,0.03,0.03,0.03,0.03,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.03,0.03,0.0
.Lland_vegetation_RVZ0M: .double 0.25,0.1,2.0,2.0,2.0,2.0,0.47,0.013,0.034,0.5,0.17,0.0013,0.5,0.0001,0.0001,0.1,0.25,2.0,1.1,0.02
.section .note.GNU-stack,"",%progbits

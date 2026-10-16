/* Contract: skills/md2asm/references/openifs/setup/surface_land_parameters.md.
 * Complete fixed-shape CPTAVE and SRFROOTFR numerical children.
 * Buffers are valid, aligned and disjoint; FPCR0. Return0. */
.arch armv8.2-a
.text
#include "land_parameter_abi.inc.S"
.p2align 4
.global md2asm_soil_texture_average_fields
.type md2asm_soil_texture_average_fields,%function
/* x0 output144: six arrays of three, in original argument order. */
md2asm_soil_texture_average_fields:
 LAND_ENTER 256
 mov x19,x0
 adr x20,.Lland_usda_tables
 mov x21,#0
.Lland_average_table:
 mov x0,x20
 add x1,x19,x21
 bl .Lland_average_classes
 add x20,x20,#88
 add x21,x21,#24
 cmp x21,#96
 b.lo .Lland_average_table
 adr x20,.Lland_texture_constants
 ldr d0,[x20]
 ldr d1,[x20,#8]
 fmul d2,d0,d1
 ldr d1,[x20,#16]
 fmul d0,d0,d1
 fdiv d8,d2,d0 /* source ZFAC */
 ldr d0,[x20,#24]
 fmul d9,d0,d8 /* ZPSIPWP */
 ldr d0,[x20,#32]
 fmul d10,d0,d8 /* ZPSICAP */
 fdiv d0,d10,d9
 LAND_MATH log
 fmov d11,d0
 mov x21,#0
.Lland_texture_class:
 add x9,x19,#48
 ldr d0,[x9,x21,lsl#3]
 add x9,x19,#24
 ldr d1,[x9,x21,lsl#3]
 fdiv d0,d0,d1
 LAND_MATH log
 fdiv d12,d11,d0
 add x9,x19,#120
 str d12,[x9,x21,lsl#3] /* PB */
 ldr d0,[x19,x21,lsl#3]
 add x9,x19,#24
 ldr d1,[x9,x21,lsl#3]
 fdiv d0,d0,d1
 fmov d1,d12
 LAND_MATH pow
 fdiv d0,d10,d0
 add x9,x19,#96
 str d0,[x9,x21,lsl#3] /* PSISAT */
 add x21,x21,#1
 cmp x21,#3
 b.lo .Lland_texture_class
 mov w0,#0
 LAND_LEAVE 256
.size md2asm_soil_texture_average_fields,.-md2asm_soil_texture_average_fields
/* Complete source AVECLA: x0 eleven inputs, x1 three outputs. */
.Lland_average_classes:
 ldp d0,d1,[x0]
 fadd d0,d0,d1
 ldr d1,[x0,#16]
 fadd d0,d0,d1
 ldr d1,[x0,#40]
 fadd d0,d0,d1
 fmov d2,#4.0
 fdiv d0,d0,d2
 str d0,[x1]
 ldp d0,d1,[x0,#24]
 fadd d0,d0,d1
 ldr d1,[x0,#48]
 fadd d0,d0,d1
 ldr d1,[x0,#56]
 fadd d0,d0,d1
 fdiv d0,d0,d2
 str d0,[x1,#8]
 ldp d0,d1,[x0,#64]
 fadd d0,d0,d1
 ldr d1,[x0,#80]
 fadd d0,d0,d1
 fmov d2,#3.0
 fdiv d0,d0,d2
 str d0,[x1,#16]
 ret
.p2align 4
.global md2asm_vegetation_root_fraction_fields
.type md2asm_vegetation_root_fraction_fields,%function
/* x0 output640, four levels by twenty types; x1 four depths32. */
md2asm_vegetation_root_fraction_fields:
 LAND_ENTER 256
 mov x19,x0
 mov x20,x1
 add x26,sp,#176
 ldr d0,[x20]
 str d0,[x26]
 ldr d1,[x20,#8]
 fadd d0,d0,d1
 str d0,[x26,#8]
 ldr d1,[x20,#16]
 fadd d0,d0,d1
 str d0,[x26,#16]
 ldr d1,[x20,#24]
 fadd d0,d0,d1
 str d0,[x26,#24]
 adr x22,.Lland_root_aa
 adr x23,.Lland_root_bb
 fmov d12,#1.0
 fmov d13,#0.5
 mov x21,#0
.Lland_root_type:
 ldr d8,[x22,x21,lsl#3]
 ldr d9,[x23,x21,lsl#3]
 add x24,x19,x21,lsl#5
 adr x9,.Lland_root_cutoff
 ldr d0,[x9]
 fcmp d8,d0
 b.le .Lland_root_zero_type
 fneg d0,d8
 ldr d1,[x26]
 fmul d0,d0,d1
 LAND_MATH exp
 fmov d10,d0
 fneg d0,d9
 ldr d1,[x26]
 fmul d0,d0,d1
 LAND_MATH exp
 fadd d0,d10,d0
 fmul d0,d13,d0
 fsub d0,d12,d0
 str d0,[x24]
 mov x25,#1
.Lland_root_interior:
 sub x9,x25,#1
 ldr d1,[x26,x9,lsl#3]
 fneg d0,d8
 fmul d0,d0,d1
 LAND_MATH exp
 fmov d10,d0
 sub x9,x25,#1
 ldr d1,[x26,x9,lsl#3]
 fneg d0,d9
 fmul d0,d0,d1
 LAND_MATH exp
 fadd d10,d10,d0
 ldr d1,[x26,x25,lsl#3]
 fneg d0,d8
 fmul d0,d0,d1
 LAND_MATH exp
 fsub d10,d10,d0
 ldr d1,[x26,x25,lsl#3]
 fneg d0,d9
 fmul d0,d0,d1
 LAND_MATH exp
 fsub d10,d10,d0
 fmul d0,d13,d10
 str d0,[x24,x25,lsl#3]
 add x25,x25,#1
 cmp x25,#3
 b.lo .Lland_root_interior
 fmov d0,xzr
 ldr d1,[x24]
 fadd d0,d0,d1
 ldr d1,[x24,#8]
 fadd d0,d0,d1
 ldr d1,[x24,#16]
 fadd d0,d0,d1
 fsub d0,d12,d0
 str d0,[x24,#24]
 b .Lland_root_next
.Lland_root_zero_type:
 stp xzr,xzr,[x24]
 stp xzr,xzr,[x24,#16]
.Lland_root_next:
 add x21,x21,#1
 cmp x21,#20
 b.lo .Lland_root_type
 adr x20,.Lland_root_override_offsets
 mov x21,#5
.Lland_root_override:
 ldr x9,[x20],#8
 add x9,x19,x9
 str d12,[x9]
 str xzr,[x9,#8]
 stp xzr,xzr,[x9,#16]
 subs x21,x21,#1
 b.ne .Lland_root_override
 mov w0,#0
 LAND_LEAVE 256
.size md2asm_vegetation_root_fraction_fields,.-md2asm_vegetation_root_fraction_fields
.section .rodata
.p2align 3
.Lland_usda_tables:
 .double .395,.410,.435,.485,.451,.420,.477,.476,.426,.492,.482
 .double .093,.172,.229,.341,.288,.280,.345,.317,.311,.338,.384
 .double .033,.058,.100,.153,.145,.157,.201,.187,.188,.207,.250
 .double 176e-6,156e-6,34.7e-6,7.20e-6,6.95e-6,6.30e-6,1.70e-6,2.45e-6,2.16e-6,1.03e-6,1.28e-6
.Lland_texture_constants: .double 1000.0,100.0,9.8,-15.0,-0.33
.Lland_root_aa:
 .double 5.558,10.739,6.706,7.066,5.990,7.344,8.235,4.372,8.992,5.558,4.372,0.0,7.344,0.0,0.0,6.326,6.326,4.453,4.453,0.0
.Lland_root_bb:
 .double 2.614,2.608,2.175,1.953,1.955,1.303,1.627,.978,8.992,2.614,.978,0.0,1.303,0.0,0.0,1.567,1.567,1.631,1.631,0.0
.Lland_root_cutoff: .double .01
.Lland_root_override_offsets: .quad 224,352,416,448,608
.section .note.GNU-stack,"",%progbits

/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2fort-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/thermal_diffusion_parameter_setup.S
 */
// Original contract: skills/md2fort/references/openifs/setup/thermal_diffusion_parameter_setup.md
// Complete stability table: skills/md2fort-gpu/references/openifs/setup/stability_table_fields_complete_contract.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_initialize_thermal_diffusion_parameters
.type md2asm_initialize_thermal_diffusion_parameters,%function
md2asm_initialize_thermal_diffusion_parameters:
 cbz x0,.Lreject
 cbz x2,.Lreject
 cmp x1,#1920
 b.lo .Lreject
 cmp x3,#520
 b.lo .Lreject
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lreject
 adds x4,x0,#1920
 b.cs .Lreject
 adds x5,x2,#520
 b.cs .Lreject
 cmp x0,x5
 b.hs .Ldisjoint
 cmp x2,x4
 b.lo .Lreject
.Ldisjoint:
 mrs x4,fpcr
 cbnz x4,.Lreject
 adrp x4,.Linput_ranges
 add x4,x4,:lo12:.Linput_ranges
 mov x8,#7
.Lrange_loop:
 ldp x5,x6,[x4]
 ldr x7,[x4,#16]
 ldr x9,[x2,x5]
 cmp x9,x6
 b.lo .Lreject
 cmp x9,x7
 b.hi .Lreject
 add x4,x4,#24
 subs x8,x8,#1
 b.ne .Lrange_loop
 stp x29,x30,[sp,#-32]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 mov x19,x0
 mov x1,x2
 bl md2asm_initialize_thermal_namespace_fields
 add x0,x19,#184
 bl md2asm_initialize_stability_table_fields
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Lreject:
 mov w0,#2
 ret
.size md2asm_initialize_thermal_diffusion_parameters,.-md2asm_initialize_thermal_diffusion_parameters
.p2align 4
.global md2asm_initialize_thermal_namespace_fields
.type md2asm_initialize_thermal_namespace_fields,%function
md2asm_initialize_thermal_namespace_fields:
 adrp x8,.Lthermal_literals
 add x8,x8,:lo12:.Lthermal_literals
 ldr d0,[x8,#0]
 ldr d1,[x1,#184]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x1,#192]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x0,#0]
 ldp d0,d1,[x8,#8]
 stp d0,d1,[x0,#8]
 ldp d2,d3,[x8,#24]
 stp d2,d3,[x0,#24]
 ldr d4,[x1,#368]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d5,destination,d4,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d5,destination,d0,real,x16,0,d5
 str d5,[x0,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d6,destination,d4,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d6,destination,d1,real,x16,0,d6
 str d6,[x0,#48]
 stp xzr,xzr,[x0,#56]
 ldr d0,[x8,#40]
 str d0,[x0,#64]
 ldr d0,[x1,#376]
 ldr d1,[x1,#384]
 ldr d2,[x1,#200]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d5,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d3,destination,d3,real,x16,0,d2
 str d3,[x0,#72]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d6,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d3,destination,d3,real,x16,0,d2
 str d3,[x0,#80]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d2
 stp d0,d1,[x0,#88]
 ldr d0,[x1,#408]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 str d0,[x0,#104]
 str d4,[x0,#112]
 ldr d0,[x8,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d4,real,x16,0,d0
 stp d0,d0,[x0,#120]
 ldr d0,[x8,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d4,real,x16,0,d0
 stp d0,d0,[x0,#136]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d4,real,x16,0,d0
 fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d0
 stp d0,d0,[x0,#152]
 ldp d0,d1,[x8,#64]
 stp d0,d1,[x0,#168]
 mov w0,#0
 ret
.size md2asm_initialize_thermal_namespace_fields,.-md2asm_initialize_thermal_namespace_fields
.p2align 4
.global md2asm_initialize_stability_table_fields
.type md2asm_initialize_stability_table_fields,%function
md2asm_initialize_stability_table_fields:
 b md2asm_gpu_stability_table_phase_host
.size md2asm_initialize_stability_table_fields,.-md2asm_initialize_stability_table_fields
.section .rodata
.p2align 3
.Lthermal_literals:
 .double 611.21,17.502,22.587,32.19,-0.7,1000.0,5.0,23.0,2.583,0.0048116
.Literation_constants:
 .double 0.001
.Lstable_constants:
 .quad 0x3ff0000000000000
 .quad 0x3fe5555555555555
 .quad 0x4014000000000000
 .quad 0x3fd6666666666666
 .quad 0x3fe5555555555555
 .quad 0x40230c30c30c30c3
 .quad 0x402c924924924925
 .quad 0x4014000000000000
 .quad 0x4010000000000000
 .quad 0x4014000000000000
 .quad 0x4030000000000000
 .quad 0x3ff921fb54442d18
 .quad 0x4024000000000000
 .quad 0x3fb999999999999a
 .quad 0x3f5b4e81b4e81b50
.Linput_ranges:
 .quad 184,0x3ff0000000000000,0x40c3880000000000
 .quad 192,0x3ff0000000000000,0x40c3880000000000
 .quad 200,0x3ff0000000000000,0x40c3880000000000
 .quad 368,0x4069000000000000,0x4075e00000000000
 .quad 376,0x3ff0000000000000,0x4197d78400000000
 .quad 384,0x3ff0000000000000,0x4197d78400000000
 .quad 408,0x3ff0000000000000,0x4197d78400000000
.section .note.GNU-stack,"",%progbits

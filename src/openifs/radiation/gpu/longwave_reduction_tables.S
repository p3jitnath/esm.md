/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/radiation/longwave_reduction_tables.S
 */
// Original contract: skills/md2asm/references/openifs/radiation/longwave_gpoint_reduction.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.text
.p2align 4
.global md2asm_longwave_corrections_and_weights
.hidden md2asm_longwave_corrections_and_weights
.type md2asm_longwave_corrections_and_weights,%function
md2asm_longwave_corrections_and_weights:
 mov x1,#3328
 add x1,x0,x1
 add x2,x1,#1608
 fmov d0,#1.0
 str d0,[x1]
 str d0,[x2]
 str d0,[x1,#1600]
 str d0,[x2,#1600]
 adrp x3,.Lcorrection_step
 ldr d1,[x3,:lo12:.Lcorrection_step]
 mov x3,#1
.Lcorrection_loop:
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d2,destination,w3,general,w16,152,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,7,d3,destination,d2,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d4,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d5,destination,d0,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d6,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d5,destination,d5,real,x16,0,d6
 str d4,[x1,x3,lsl #3]
 str d5,[x2,x3,lsl #3]
 add x3,x3,#1
 cmp x3,#200
 b.lo .Lcorrection_loop
 add x1,x0,#3200
 add x2,x0,#128
 mov x3,#6544
 add x3,x0,x3
 mov x4,#0
.Lweight_band:
 ldr w5,[x0,x4,lsl #2]
 mov x6,#0
 cmp w5,#16
 b.eq .Lweight_unit
.Lweight_group:
 ldr w7,[x2],#4
 mov x8,x7
 fmov d1,xzr
 mov x9,x6
.Lweight_sum:
 ldr d2,[x1,x9,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d1,real,x16,0,d2
 add x9,x9,#1
 subs x8,x8,#1
 b.ne .Lweight_sum
.Lweight_divide:
 ldr d2,[x1,x6,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d2,real,x16,0,d1
 str d2,[x3],#8
 add x6,x6,#1
 cmp x6,x9
 b.lo .Lweight_divide
 cmp x6,#16
 b.lo .Lweight_group
 b .Lweight_next
.Lweight_unit:
 str d0,[x3],#8
 add x6,x6,#1
 cmp x6,#16
 b.lo .Lweight_unit
 add x2,x2,#64
.Lweight_next:
 add x4,x4,#1
 cmp x4,#16
 b.lo .Lweight_band
 ret
.size md2asm_longwave_corrections_and_weights,.-md2asm_longwave_corrections_and_weights
.section .rodata
.p2align 3
.Lcorrection_step:
 .double 0.005
.section .note.GNU-stack,"",%progbits

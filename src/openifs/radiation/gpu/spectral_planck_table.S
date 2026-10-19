/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/radiation/spectral_planck_table.S
 */
// Original contract: skills/md2asm/references/openifs/radiation/spectral_planck_setup.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_fill_selected_spectral_planck_table
.type md2asm_fill_selected_spectral_planck_table,%function
md2asm_fill_selected_spectral_planck_table:
 stp x29,x30,[sp,#-192]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 ldr x21,[x19,#24]
 ldr x22,[x19,#112]
 ldr x23,[x19,#176]
 fmov d0,#2.0
 ldr d1,[x20]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x20,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x20,#8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 str d0,[sp,#96]
 ldr d0,[x20,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x20,#24]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[sp,#104]
 mov x24,#0
.Lspt_temperature:
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d0,destination,x24,general,x16,320,zero
 ldr d1,[x19,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x19,#8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[sp,#112]
 mov x25,#0
.Lspt_range:
 cbz x25,.Lspt_first
 cmp x25,#2
 b.eq .Lspt_last
 ldp d0,d1,[x22]
 b .Lspt_bounds
.Lspt_first:
 ldr d1,[x22]
 adrp x9,.Lspt_range_constants
 add x9,x9,:lo12:.Lspt_range_constants
 ldr d0,[x9,#8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d2,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,6,d0,destination,d2,real,x16,0,d0
 b .Lspt_bounds
.Lspt_last:
 ldr d0,[x22,#8]
 adrp x9,.Lspt_range_constants
 add x9,x9,:lo12:.Lspt_range_constants
 ldp d1,d2,[x9,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,5,d1,destination,d1,real,x16,0,d2
.Lspt_bounds:
 str d0,[sp,#120]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d1,real,x16,0,d0
 adrp x9,.Lspt_range_constants
 add x9,x9,:lo12:.Lspt_range_constants
 ldr d1,[x9,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[sp,#128]
 str xzr,[sp,#136]
 mov x26,#0
.Lspt_wavelength:
 mov w9,#1
 cbz x26,.Lspt_weight
 cmp x26,#100
 b.eq .Lspt_weight
 and w9,w26,#1
 lsl w9,w9,#1
 add w9,w9,#2
.Lspt_weight:
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d0,destination,w9,general,w16,200,zero
 str d0,[sp,#160]
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d0,destination,x26,general,x16,336,zero
 ldr d1,[sp,#128]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#120]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[sp,#144]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d0,real,x16,0,d0
 str d1,[sp,#152]
 ldr d1,[sp,#112]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[sp,#104]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d0
 bl md2asm_exp_original_rounding
 ldr x18,[sp,#80]
 fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 ldr d1,[sp,#152]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d1
 ldr d2,[sp,#144]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#160]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#136]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[sp,#136]
 add x26,x26,#1
 cmp x26,#100
 b.ls .Lspt_wavelength
 ldr d0,[sp,#96]
 ldr d1,[sp,#136]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[sp,#128]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 fmov d1,#3.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 ldr w9,[x23,x25,lsl#2]
 sub w9,w9,#1
 add x9,x9,x24,lsl#1
 ldr d1,[x21,x9,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[x21,x9,lsl#3]
 add x25,x25,#1
 cmp x25,#3
 b.lo .Lspt_range
 add x24,x24,#1
 cmp x24,#201
 b.lo .Lspt_temperature
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#192
 ret
.size md2asm_fill_selected_spectral_planck_table,.-md2asm_fill_selected_spectral_planck_table
.section .rodata
.p2align 3
.Lspt_range_constants:
 .double 1.0e-6,0.8,200.0e-6,20.0e-6,100.0
.section .note.GNU-stack,"",%progbits

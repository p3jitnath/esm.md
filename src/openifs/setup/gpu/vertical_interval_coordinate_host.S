#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_vertical_interval_coordinate
.type md2asm_vertical_interval_coordinate,%function
md2asm_vertical_interval_coordinate:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d2,d2,d0 // fsub d2,d2,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d1,d1,d0 // fsub d1,d1,d0
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d2,d1 // fdiv d0,d2,d1
 ret
.size md2asm_vertical_interval_coordinate,.-md2asm_vertical_interval_coordinate
.p2align 4
.local __suvfe_hlp_MOD_fx2t
.type __suvfe_hlp_MOD_fx2t,%function
__suvfe_hlp_MOD_fx2t:
 ldr d0,[x0]
 ldr d1,[x1]
 ldr d2,[x2]
 b md2asm_vertical_interval_coordinate
.size __suvfe_hlp_MOD_fx2t,.-__suvfe_hlp_MOD_fx2t
.section .note.GNU-stack,"",%progbits

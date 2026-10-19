/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/cloud_beta_gamma_functions.S
 */
// Original contract: skills/md2asm/references/openifs/setup/prognostic_cloud_parameter_setup.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_cloud_gamma_log
.type md2asm_cloud_gamma_log,%function
md2asm_cloud_gamma_log:
 stp x29,x30,[sp,#-112]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 str x0,[sp,#32]
 str d0,[sp,#40]
 fmov d1,#5.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d0,real,x16,0,d1
 str d1,[sp,#48]
 fmov d2,#0.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d0,real,x16,0,d2
 str d2,[sp,#56]
 fmov d0,d1
 bl log
 ldr d1,[sp,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 str d0,[sp,#48]
 ldr x0,[sp,#32]
 adrp x19,.Lgamma_coefficients64
 add x19,x19,:lo12:.Lgamma_coefficients64
 cbz x0,.Lgamma_coefficients_selected
 adrp x19,.Lgamma_coefficients32
 add x19,x19,:lo12:.Lgamma_coefficients32
.Lgamma_coefficients_selected:
 ldr d0,[x19,#48]
 ldr d1,[sp,#40]
 mov x9,#1
.Lgamma_series:
 cbnz x0,.Lgamma_direct_denominator
 fmov d2,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d1,real,x16,0,d2
 b .Lgamma_denominator_ready
.Lgamma_direct_denominator:
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d2,destination,x9,general,x16,200,zero
 ldr d1,[sp,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d2,real,x16,0,d1
.Lgamma_denominator_ready:
 ldr d2,[x19],#8
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d2,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d2
 add x9,x9,#1
 cmp x9,#7
 b.lo .Lgamma_series
 ldr d1,[x19,#8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 bl log
 ldr d1,[sp,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.size md2asm_cloud_gamma_log,.-md2asm_cloud_gamma_log
.p2align 4
.global md2asm_cloud_generalized_gamma
.type md2asm_cloud_generalized_gamma,%function
md2asm_cloud_generalized_gamma:
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp d0,d1,[sp,#32]
 fmov d2,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d3,destination,d2,real,x16,0,d0
 fmov d4,xzr
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d3,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d3,real,x16,0,d0
 mov x0,#1
 bl md2asm_cloud_gamma_log
 bl md2asm_exp_original_rounding
 str d0,[sp,#48]
 ldp d0,d1,[sp,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 bl sin
 ldr d1,[sp,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 fmov d2,xzr
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 fmov d2,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_cloud_generalized_gamma,.-md2asm_cloud_generalized_gamma
.p2align 4
.global md2asm_cloud_beta_continued_fraction
.type md2asm_cloud_beta_continued_fraction,%function
md2asm_cloud_beta_continued_fraction:
 fmov d16,d0
 fmov d17,d1
 fmov d18,d2
 fmov d27,#1.0
 adrp x8,.Lbeta_iteration_constants
 add x8,x8,:lo12:.Lbeta_iteration_constants
 ldp d28,d29,[x8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d19,destination,d16,real,x16,0,d17
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d20,destination,d16,real,x16,0,d27
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d21,destination,d16,real,x16,0,d27
 fmov d22,d27
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d23,destination,d19,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d23,destination,d23,real,x16,0,d20
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d23,destination,d27,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d23,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d29
 b.ge .Lsetup_select_other_30
 fmov d23,d29
 b .Lsetup_select_done_30
.Lsetup_select_other_30:
 fmov d23,d23
.Lsetup_select_done_30:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d23,destination,d27,real,x16,0,d23
 fmov d24,d23
 mov x4,#1
.Lbeta_fraction_loop:
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d30,destination,x4,general,x16,160,zero
 add x5,x4,x4
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d31,destination,x5,general,x16,168,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d17,real,x16,0,d30
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d30,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d25,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d21,real,x16,0,d31
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d16,real,x16,0,d31
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d25,destination,d25,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d23,destination,d25,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d23,destination,d27,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d23,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d29
 b.ge .Lsetup_select_other_45
 fmov d23,d29
 b .Lsetup_select_done_45
.Lsetup_select_other_45:
 fmov d23,d23
.Lsetup_select_done_45:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d25,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d22,destination,d27,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d22,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d29
 b.ge .Lsetup_select_other_50
 fmov d22,d29
 b .Lsetup_select_done_50
.Lsetup_select_other_50:
 fmov d22,d22
.Lsetup_select_done_50:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d23,destination,d27,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d24,destination,d24,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d24,destination,d24,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d16,real,x16,0,d30
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d25,destination,d0,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d19,real,x16,0,d30
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d25,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d25,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d16,real,x16,0,d31
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d20,real,x16,0,d31
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d25,destination,d25,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d23,destination,d25,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d23,destination,d27,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d23,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d29
 b.ge .Lsetup_select_other_67
 fmov d23,d29
 b .Lsetup_select_done_67
.Lsetup_select_other_67:
 fmov d23,d23
.Lsetup_select_done_67:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d25,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d22,destination,d27,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d22,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d29
 b.ge .Lsetup_select_other_72
 fmov d22,d29
 b .Lsetup_select_done_72
.Lsetup_select_other_72:
 fmov d22,d22
.Lsetup_select_done_72:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d23,destination,d27,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d26,destination,d23,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d24,destination,d24,real,x16,0,d26
 add x4,x4,#1
 cmp x4,#100
 b.hi .Lbeta_fraction_done
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d26,real,x16,0,d27
 md2asm_gpu_preserved_scalar md2asm_gpu_soil_water_cell_host,16,d0,destination,d0,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d28
 b.gt .Lbeta_fraction_loop
.Lbeta_fraction_done:
 fmov d0,d24
 ret
.size md2asm_cloud_beta_continued_fraction,.-md2asm_cloud_beta_continued_fraction
.p2align 4
.global md2asm_cloud_incomplete_beta
.type md2asm_cloud_incomplete_beta,%function
md2asm_cloud_incomplete_beta:
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp d0,d1,[sp,#32]
 str d2,[sp,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d2,real,x16,0,zero
 b.le .Lbeta_zero_factor
 fmov d3,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d2,real,x16,0,d3
 b.ge .Lbeta_zero_factor
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 mov x0,#0
 bl md2asm_cloud_gamma_log
 str d0,[sp,#56]
 ldr d0,[sp,#32]
 mov x0,#0
 bl md2asm_cloud_gamma_log
 ldr d1,[sp,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d1,real,x16,0,d0
 str d0,[sp,#56]
 ldr d0,[sp,#40]
 mov x0,#0
 bl md2asm_cloud_gamma_log
 ldr d1,[sp,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d1,real,x16,0,d0
 str d0,[sp,#56]
 ldr d0,[sp,#48]
 bl log
 ldr d1,[sp,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[sp,#56]
 fmov d0,#1.0
 ldr d1,[sp,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 bl log
 ldr d1,[sp,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 bl md2asm_exp_original_rounding
 b .Lbeta_factor_ready
.Lbeta_zero_factor:
 fmov d0,xzr
.Lbeta_factor_ready:
 str d0,[sp,#64]
 ldp d0,d1,[sp,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d0,real,x16,0,d1
 fmov d3,#2.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d2,real,x16,0,d3
 fmov d3,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d3,destination,d0,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d3,real,x16,0,d2
 ldr d3,[sp,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d3,real,x16,0,d2
 b.ge .Lbeta_symmetric
 fmov d2,d3
 bl md2asm_cloud_beta_continued_fraction
 ldr d1,[sp,#64]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 b .Lbeta_return
.Lbeta_symmetric:
 fmov d2,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d2,destination,d2,real,x16,0,d3
 ldr d0,[sp,#40]
 ldr d1,[sp,#32]
 bl md2asm_cloud_beta_continued_fraction
 ldr d1,[sp,#64]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[sp,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d1,real,x16,0,d0
.Lbeta_return:
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#128
 ret
.size md2asm_cloud_incomplete_beta,.-md2asm_cloud_incomplete_beta
.section .rodata
.p2align 3
.Lbeta_iteration_constants:
 .double 0.0000003,0.000000000000000000000000000001
.Lgamma_coefficients64:
 .double 76.18009172947146,-86.50532032941677,24.01409824083091,-1.231739572450155,0.001208650973866179,-0.000005395239384953
 .double 1.000000000190015,2.5066282746310005
.Lgamma_coefficients32:
 .quad 0x40530b86a0000000
 .quad 0xc055a05720000000
 .quad 0x4038039c00000000
 .quad 0xbff3b53480000000
 .quad 0x3f53cd7320000000
 .quad 0xbed6a11820000000
 .quad 0x3ff0000000000000
 .quad 0x40040d9320000000
.section .note.GNU-stack,"",%progbits

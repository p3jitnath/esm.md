// Direct source-ordered SUCLDP beta/gamma children. No OpenIFS state inputs.
// Contract: skills/md2asm/references/openifs/setup/prognostic_cloud_parameter_setup.md
.arch armv8-a
.text
.p2align 4
.global md2asm_cloud_gamma_log
.type md2asm_cloud_gamma_log,%function
// d0=x>0; x0=0 for GAMMLN, 1 for widened-default-REAL FCGENERALIZED_GAMMA.
// The selected consumers use finite x in [2,8]. Return ln(Gamma(x)) in d0.
md2asm_cloud_gamma_log:
 stp x29,x30,[sp,#-112]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 str x0,[sp,#32]
 str d0,[sp,#40]
 fmov d1,#5.5
 fadd d1,d0,d1
 str d1,[sp,#48]
 fmov d2,#0.5
 fadd d2,d0,d2
 str d2,[sp,#56]
 fmov d0,d1
 bl log
 ldr d1,[sp,#56]
 fmul d0,d1,d0
 ldr d1,[sp,#48]
 fsub d0,d0,d1
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
 fadd d1,d1,d2
 b .Lgamma_denominator_ready
.Lgamma_direct_denominator:
 scvtf d2,x9
 ldr d1,[sp,#40]
 fadd d1,d2,d1
.Lgamma_denominator_ready:
 ldr d2,[x19],#8
 fdiv d2,d2,d1
 fadd d0,d0,d2
 add x9,x9,#1
 cmp x9,#7
 b.lo .Lgamma_series
 // x19 now addresses the initial series word; scale follows it.
 ldr d1,[x19,#8]
 fmul d0,d1,d0
 ldr d1,[sp,#40]
 fdiv d0,d0,d1
 bl log
 ldr d1,[sp,#48]
 fadd d0,d1,d0
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.size md2asm_cloud_gamma_log,.-md2asm_cloud_gamma_log

.p2align 4
.global md2asm_cloud_generalized_gamma
.type md2asm_cloud_generalized_gamma,%function
// d0=positive finite x in [2,8], d1=owned RPI. Preserve the evaluated reflection.
md2asm_cloud_generalized_gamma:
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp d0,d1,[sp,#32]
 fmov d2,#1.0
 fsub d3,d2,d0
 fmov d4,xzr
 fmul d3,d3,d4
 fmul d0,d0,d2
 fadd d0,d3,d0
 mov x0,#1
 bl md2asm_cloud_gamma_log
 bl md2asm_exp_original_rounding
 str d0,[sp,#48]
 ldp d0,d1,[sp,#32]
 fmul d0,d1,d0
 bl sin
 ldr d1,[sp,#40]
 fdiv d0,d1,d0
 ldr d1,[sp,#48]
 fdiv d0,d0,d1
 fmov d2,xzr
 fmul d0,d0,d2
 fmov d2,#1.0
 fmul d1,d1,d2
 fadd d0,d1,d0
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_cloud_generalized_gamma,.-md2asm_cloud_generalized_gamma

.p2align 4
.global md2asm_cloud_beta_continued_fraction
.type md2asm_cloud_beta_continued_fraction,%function
// d0=P, d1=Q, d2=X. Complete original BETACF recurrence; no calls or frame.
md2asm_cloud_beta_continued_fraction:
 fmov d16,d0
 fmov d17,d1
 fmov d18,d2
 fmov d27,#1.0
 adrp x8,.Lbeta_iteration_constants
 add x8,x8,:lo12:.Lbeta_iteration_constants
 ldp d28,d29,[x8]
 fadd d19,d16,d17
 fadd d20,d16,d27
 fsub d21,d16,d27
 fmov d22,d27
 fmul d23,d19,d18
 fdiv d23,d23,d20
 fsub d23,d27,d23
 fabs d0,d23
 fcmp d0,d29
 fcsel d23,d29,d23,lt
 fdiv d23,d27,d23
 fmov d24,d23
 mov x4,#1
.Lbeta_fraction_loop:
 scvtf d30,x4
 add x5,x4,x4
 scvtf d31,x5
 fsub d0,d17,d30
 fmul d25,d30,d0
 fmul d25,d25,d18
 fadd d0,d21,d31
 fadd d1,d16,d31
 fmul d0,d0,d1
 fdiv d25,d25,d0
 fmul d23,d25,d23
 fadd d23,d27,d23
 fabs d0,d23
 fcmp d0,d29
 fcsel d23,d29,d23,lt
 fdiv d0,d25,d22
 fadd d22,d27,d0
 fabs d0,d22
 fcmp d0,d29
 fcsel d22,d29,d22,lt
 fdiv d23,d27,d23
 fmul d24,d24,d23
 fmul d24,d24,d22
 fadd d0,d16,d30
 fneg d25,d0
 fadd d0,d19,d30
 fmul d25,d25,d0
 fmul d25,d25,d18
 fadd d0,d16,d31
 fadd d1,d20,d31
 fmul d0,d0,d1
 fdiv d25,d25,d0
 fmul d23,d25,d23
 fadd d23,d27,d23
 fabs d0,d23
 fcmp d0,d29
 fcsel d23,d29,d23,lt
 fdiv d0,d25,d22
 fadd d22,d27,d0
 fabs d0,d22
 fcmp d0,d29
 fcsel d22,d29,d22,lt
 fdiv d23,d27,d23
 fmul d26,d23,d22
 fmul d24,d24,d26
 add x4,x4,#1
 cmp x4,#100
 b.hi .Lbeta_fraction_done
 fsub d0,d26,d27
 fabs d0,d0
 fcmp d0,d28
 b.gt .Lbeta_fraction_loop
.Lbeta_fraction_done:
 fmov d0,d24
 ret
.size md2asm_cloud_beta_continued_fraction,.-md2asm_cloud_beta_continued_fraction

.p2align 4
.global md2asm_cloud_incomplete_beta
.type md2asm_cloud_incomplete_beta,%function
// d0=P, d1=Q, d2=X in [0,1]. Selected P/Q are 1+sqrt(2) and P+1.
md2asm_cloud_incomplete_beta:
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp d0,d1,[sp,#32]
 str d2,[sp,#48]
 fcmp d2,#0.0
 b.le .Lbeta_zero_factor
 fmov d3,#1.0
 fcmp d2,d3
 b.ge .Lbeta_zero_factor
 fadd d0,d0,d1
 mov x0,#0
 bl md2asm_cloud_gamma_log
 str d0,[sp,#56]
 ldr d0,[sp,#32]
 mov x0,#0
 bl md2asm_cloud_gamma_log
 ldr d1,[sp,#56]
 fsub d0,d1,d0
 str d0,[sp,#56]
 ldr d0,[sp,#40]
 mov x0,#0
 bl md2asm_cloud_gamma_log
 ldr d1,[sp,#56]
 fsub d0,d1,d0
 str d0,[sp,#56]
 ldr d0,[sp,#48]
 bl log
 ldr d1,[sp,#32]
 fmul d0,d1,d0
 ldr d1,[sp,#56]
 fadd d0,d1,d0
 str d0,[sp,#56]
 fmov d0,#1.0
 ldr d1,[sp,#48]
 fsub d0,d0,d1
 bl log
 ldr d1,[sp,#40]
 fmul d0,d1,d0
 ldr d1,[sp,#56]
 fadd d0,d1,d0
 bl md2asm_exp_original_rounding
 b .Lbeta_factor_ready
.Lbeta_zero_factor:
 fmov d0,xzr
.Lbeta_factor_ready:
 str d0,[sp,#64]
 ldp d0,d1,[sp,#32]
 fadd d2,d0,d1
 fmov d3,#2.0
 fadd d2,d2,d3
 fmov d3,#1.0
 fadd d3,d0,d3
 fdiv d2,d3,d2
 ldr d3,[sp,#48]
 fcmp d3,d2
 b.ge .Lbeta_symmetric
 fmov d2,d3
 bl md2asm_cloud_beta_continued_fraction
 ldr d1,[sp,#64]
 fmul d0,d1,d0
 ldr d1,[sp,#32]
 fdiv d0,d0,d1
 b .Lbeta_return
.Lbeta_symmetric:
 fmov d2,#1.0
 fsub d2,d2,d3
 ldr d0,[sp,#40]
 ldr d1,[sp,#32]
 bl md2asm_cloud_beta_continued_fraction
 ldr d1,[sp,#64]
 fmul d0,d1,d0
 ldr d1,[sp,#40]
 fdiv d0,d0,d1
 fmov d1,#1.0
 fsub d0,d1,d0
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

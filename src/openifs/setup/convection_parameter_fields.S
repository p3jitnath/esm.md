/* Contract: skills/md2asm/references/openifs/setup/convection_parameter_setup.md.
 * Explicit raw SUCUMF and SUCUMF2 fields, for checked selected inputs.
 * Both are frame-free leaves, using x0..x17 and d0..d7/d16..d18 only.
 * All input and output extents must meet the parent contract first.
 * No original data, type, vtable, callable or numerical fallback is used. */
.arch armv8.2-a
#include "convection_parameter_tables.inc.S"
.text
.p2align 4
.global md2asm_cumulus_convection_parameter_fields
.type md2asm_cumulus_convection_parameter_fields,%function
/* x0 TECUMF344, x1 STPRE152, x2 constants520, x3 scalings24,
 * x4 thermal24. Owns SUPHEC's RTWAT=RTT and the two SUCUMF outputs. */
md2asm_cumulus_convection_parameter_fields:
 adrp x5,.LCM_literal_rows
 add x5,x5,:lo12:.LCM_literal_rows
.Lcum_main_literals:
 ldp w6,w7,[x5],#8
 ldr x8,[x5],#8
 cmp w6,#-1
 b.eq .Lcum_main_math
 cmp w7,#8
 b.ne .Lcum_main_word
 str x8,[x0,x6]
 b .Lcum_main_literals
.Lcum_main_word:
 str w8,[x0,x6]
 b .Lcum_main_literals
.Lcum_main_math:
 adrp x5,.Lconvection_math
 add x5,x5,:lo12:.Lconvection_math
 ldr d16,[x3]
 ldr d17,[x3,#8]
 ldr d18,[x2,#112]
 ldr d0,[x5]
 fmul d0,d0,d16
 str d0,[x0,#CM_DETRPEN]
 ldr d0,[x5,#8]
 fmul d0,d0,d16
 str d0,[x0,#CM_ENTRORG]
 ldr d0,[x5,#16]
 fmul d0,d0,d16
 str d0,[x0,#CM_ENTRDD]
 ldr d0,[x5,#24]
 fmul d0,d0,d16
 str d0,[x0,#CM_RPRCON]
 ldr d0,[x5,#32]
 fdiv d0,d0,d18
 str d0,[x0,#CM_RCPECONS]
 ldr d0,[x5,#40]
 fdiv d0,d0,d16
 str d0,[x0,#CM_RCVRFACTOR]
 ldr d0,[x5,#56]
 fmul d1,d16,d17
 fdiv d0,d0,d1
 ldr d1,[x5,#64]
 fmul d0,d0,d1
 str d0,[x0,#CM_RTAUMEL]
 ldr d0,[x5,#48]
 fmul d0,d0,d17
 str d0,[x0,#CM_RMFLIA]
 /* The selected source RMFSOLTQ=1 makes the CFL factor three. */
 fmov d0,#3.0
 str d0,[x0,#CM_RMFCFL]
 ldr d0,[x2,#368]
 str d0,[x4]
 ldr d1,[x5,#72]
 fsub d2,d0,d1
 str d2,[x4,#8]
 fsub d2,d0,d2
 ldr d1,[x5,#80]
 fdiv d2,d1,d2
 str d2,[x4,#16]
 mov w6,#2
 str w6,[x0,#CM_NJKT1]
 str w6,[x0,#CM_NJKT2]
 str w6,[x0,#CM_NJKT8]
 mov w6,#17
 str w6,[x0,#CM_NJKT3]
 mov x6,#144
.Lcum_main_level:
 ldr d0,[x1,x6]
 adrp x5,.LCM_pressure_rows
 add x5,x5,:lo12:.LCM_pressure_rows
 mov w7,#8
.Lcum_main_threshold:
 ldr d1,[x5]
 ldr w8,[x5,#8]
 add x5,x5,#16
 fcmp d0,d1
 b.le .Lcum_main_threshold_next
 lsr w9,w6,#3
 add w9,w9,#1
 str w9,[x0,x8]
.Lcum_main_threshold_next:
 subs w7,w7,#1
 b.ne .Lcum_main_threshold
 subs x6,x6,#8
 b.ne .Lcum_main_level
 ldr w6,[x0,#CM_NJKT3]
 mov w7,#17
 cmp w6,w7
 csel w6,w6,w7,le
 str w6,[x0,#CM_NJKT3]
 ret
.size md2asm_cumulus_convection_parameter_fields,.-md2asm_cumulus_convection_parameter_fields
.p2align 4
.global md2asm_linearized_convection_parameter_fields
.type md2asm_linearized_convection_parameter_fields,%function
/* x0 TECUMF2_240, x1 TCUMFS12, x2 STPRE152, x3 constants520,
 * x4 scalings24, x5 live TSTEP8. The empty-group limiter switch is false,
 * so this selected source route does not read the timestep payload. */
md2asm_linearized_convection_parameter_fields:
 adrp x5,.LCL_literal_rows
 add x5,x5,:lo12:.LCL_literal_rows
.Lcum_linear_literals:
 ldp w6,w7,[x5],#8
 ldr x8,[x5],#8
 cmp w6,#-1
 b.eq .Lcum_linear_math
 cmp w7,#8
 b.ne .Lcum_linear_word
 str x8,[x0,x6]
 b .Lcum_linear_literals
.Lcum_linear_word:
 str w8,[x0,x6]
 b .Lcum_linear_literals
.Lcum_linear_math:
 adrp x5,.Lconvection_math
 add x5,x5,:lo12:.Lconvection_math
 ldr d16,[x4]
 ldr d17,[x4,#16]
 ldr d18,[x3,#112]
 ldr d0,[x5]
 fmul d0,d0,d16
 str d0,[x0,#CL_DETRPEN2]
 ldr d0,[x5,#8]
 fmul d0,d0,d16
 str d0,[x0,#CL_ENTRORG2]
 ldr d0,[x5,#16]
 fmul d0,d0,d16
 str d0,[x0,#CL_ENTRDD2]
 ldr d0,[x5,#24]
 fmul d0,d0,d16
 str d0,[x0,#CL_RPRCON2]
 ldr d0,[x5,#32]
 fdiv d0,d0,d18
 str d0,[x0,#CL_RCPECONS2]
 ldr d0,[x5,#88]
 fmul d0,d0,d17
 str d0,[x0,#CL_RTAU2]
 mov w6,#2
 str w6,[x0,#CL_NJKT12]
 str w6,[x0,#CL_NJKT22]
 mov w6,#17
 str w6,[x0,#CL_NJKT32]
 mov x6,#144
.Lcum_linear_level:
 ldr d0,[x2,x6]
 adrp x5,.LCL_pressure_rows
 add x5,x5,:lo12:.LCL_pressure_rows
 mov w7,#5
.Lcum_linear_threshold:
 ldr d1,[x5]
 ldr w8,[x5,#8]
 add x5,x5,#16
 fcmp d0,d1
 b.le .Lcum_linear_threshold_next
 lsr w9,w6,#3
 add w9,w9,#1
 str w9,[x0,x8]
.Lcum_linear_threshold_next:
 subs w7,w7,#1
 b.ne .Lcum_linear_threshold
 subs x6,x6,#8
 b.ne .Lcum_linear_level
 ldr w6,[x0,#CL_NJKT32]
 mov w7,#17
 cmp w6,w7
 csel w6,w6,w7,le
 str w6,[x0,#CL_NJKT32]
 str wzr,[x1]
 str wzr,[x1,#4]
 str wzr,[x1,#8]
 ret
.size md2asm_linearized_convection_parameter_fields,.-md2asm_linearized_convection_parameter_fields
.section .note.GNU-stack,"",%progbits

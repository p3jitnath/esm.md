/* Contract: skills/md2asm/references/openifs/setup/cloud_gravity_wave_setup.md. */
/* Direct complete SUCLD/SUGWD/selected SUGWWMS field calculations.
 * The parent validates all input domains and complete buffer bounds first.
 * All interfaces use explicit owned raw data, without original objects.
 * No FMA, external numerical calls or saved FP registers are used.
 */
.arch armv8.2-a
.text
#ifndef MD2ASM_RUNTIME_WMS_PARAMETERS
.p2align 4
.global md2asm_diagnostic_cloud_parameter_fields
.type md2asm_diagnostic_cloud_parameter_fields,%function
/* x0 TECLD264, x1 fresh CETA152 owner, x2 eta152. Integer leaf. */
md2asm_diagnostic_cloud_parameter_fields:
 mov x3,#-1
 stp x1,x3,[x0]
 mov x3,#8
 str x3,[x0,#16]
 str x3,[x0,#32]
 mov x3,#0x301
 lsl x3,x3,#32
 str x3,[x0,#24]
 mov x3,#1
 stp x3,x3,[x0,#40]
 mov x3,#19
 str x3,[x0,#56]
 adrp x3,.Lcloud_constants
 add x3,x3,:lo12:.Lcloud_constants
 add x4,x0,#64
 mov w5,#24
.Lcloud_scalar:
 ldr x6,[x3],#8
 str x6,[x4],#8
 subs w5,w5,#1
 b.ne .Lcloud_scalar
 mov w3,#1
 str w3,[x0,#256]
 mov x3,#0
.Lcloud_eta:
 ldr x4,[x2,x3]
 str x4,[x1,x3]
 add x3,x3,#8
 cmp x3,#152
 b.lo .Lcloud_eta
 ret
.size md2asm_diagnostic_cloud_parameter_fields,.-md2asm_diagnostic_cloud_parameter_fields
.p2align 4
.global md2asm_orographic_gravity_wave_parameter_fields
.type md2asm_orographic_gravity_wave_parameter_fields,%function
/* x0 TEGWD96, x1 STPRE152, x2 VAH160, x3 VBH160, x4 RHOUR8,
 * w5 LEPHYS. Leaf with160 bytes for the source ZPM1R(19) scratch. */
md2asm_orographic_gravity_wave_parameter_fields:
 sub sp,sp,#160
 adrp x6,.Lwave_constants
 add x6,x6,:lo12:.Lwave_constants
 ldp d16,d17,[x6] /* 80000 Pa and1/2. */
 ldp d18,d19,[x6,#16] /* sigma0.94 and pressure9.9Pa. */
 mov w6,#19
 str w6,[x0]
 mov x6,#144
.Lorographic_midpoint:
 ldr d0,[x2,x6]
 add x7,x6,#8
 ldr d1,[x2,x7]
 fadd d0,d0,d1
 ldr d2,[x3,x6]
 ldr d3,[x3,x7]
 fadd d2,d2,d3
 fmul d2,d16,d2
 fadd d0,d0,d2
 fmul d0,d17,d0
 str d0,[sp,x6]
 fdiv d1,d0,d16
 fcmp d1,d18
 b.lt .Lorographic_next
 lsr w7,w6,#3
 add w7,w7,#1
 str w7,[x0]
.Lorographic_next:
 subs x6,x6,#8
 b.pl .Lorographic_midpoint
 str d19,[x0,#80]
 mov w6,#1
 str w6,[x0,#8]
 mov x6,#0
.Lorographic_top:
 ldr d0,[sp,x6]
 fcmp d0,d19
 b.ge .Lorographic_top_next
 lsr w7,w6,#3
 add w7,w7,#1
 str w7,[x0,#8]
.Lorographic_top_next:
 add x6,x6,#8
 cmp x6,#152
 b.lo .Lorographic_top
 adrp x6,.Lwave_drag_constants
 add x6,x6,:lo12:.Lwave_drag_constants
 ldp x7,x8,[x6] /* Source initial GKDRAG and GKWAKE. */
 stp x7,x8,[x0,#32]
 ldp x7,x8,[x6,#16] /* Source revised GKDRAG and GKWAKE. */
 stp x7,x8,[x0,#32]
 ldp x7,x8,[x6,#32] /* GRCRIT, GFRCRIT in source order. */
 str x7,[x0,#24]
 str x8,[x0,#16]
 ldp x7,x8,[x6,#48] /* GVSEC, GSSEC. */
 str x7,[x0,#64]
 str x8,[x0,#48]
 ldr x7,[x6,#64]
 str x7,[x0,#56]
 mov w6,#0
 str w6,[x0,#4]
 ldr d16,[x4]
 adrp x6,.Lwave_limiter_pressure
 ldr d17,[x6,:lo12:.Lwave_limiter_pressure]
 mov x6,#144
.Lorographic_limit:
 ldr d0,[x1,x6]
 fcmp d0,d17
 b.lt .Lorographic_limit_next
 lsr w7,w6,#3
 add w7,w7,#1
 str w7,[x0,#4]
.Lorographic_limit_next:
 subs x6,x6,#8
 b.pl .Lorographic_limit
 cbnz w5,.Lorographic_physics
 str wzr,[x0,#4]
.Lorographic_physics:
 adrp x6,.Lwave_tendency_constants
 add x6,x6,:lo12:.Lwave_tendency_constants
 ldp d0,d1,[x6]
 fdiv d0,d0,d16
 str d0,[x0,#72]
 fdiv d1,d1,d16
 str d1,[x0,#72]
 str wzr,[x0,#88]
 mov w6,#5
 str w6,[x0,#12]
 str wzr,[x0,#92]
 add sp,sp,#160
 ret
.size md2asm_orographic_gravity_wave_parameter_fields,.-md2asm_orographic_gravity_wave_parameter_fields
#endif
.p2align 4
#ifdef MD2ASM_RUNTIME_WMS_PARAMETERS
#define WMS_FIELD_ENTRY md2asm_runtime_nonorographic_gravity_wave_parameter_fields
#else
#define WMS_FIELD_ENTRY md2asm_nonorographic_gravity_wave_parameter_fields
#endif
.global WMS_FIELD_ENTRY
.type WMS_FIELD_ENTRY,%function
/* x0 TEGWWMS168, x1 STPRE152, x2 RHOUR8, x3 live TSTEP8.
 * Selected NCONF1 and empty NAMGWWMS keep NLAUNCHLEV1. Leaf. */
WMS_FIELD_ENTRY:
#ifdef MD2ASM_RUNTIME_WMS_PARAMETERS
 mov w6,w4
#endif
 adrp x4,.Lnonorographic_constants
 add x4,x4,:lo12:.Lnonorographic_constants
 mov w5,#1
 str w5,[x0,#28]
 ldr x5,[x4]
 str x5,[x0,#72]
 str x5,[x0,#48]
 stp xzr,xzr,[x0,#56]
 ldr x5,[x4,#8]
 str x5,[x0,#104]
 ldr x5,[x4,#16]
 str x5,[x0,#80]
 mov w5,#1
 str w5,[x0,#36]
 ldr x5,[x4,#24]
 str x5,[x0,#112]
 mov w5,#1
 str w5,[x0]
 mov w5,#2
 str w5,[x0,#40]
 ldr x5,[x4,#32]
 str x5,[x0,#128]
 ldr x5,[x4,#40]
 stp x5,x5,[x0,#136]
 str x5,[x0,#152]
 ldr x5,[x4,#16]
 str x5,[x0,#160]
 str wzr,[x0,#4]
 str wzr,[x0,#8]
 str wzr,[x0,#12]
 ldr d16,[x2]
 ldr d17,[x3]
 ldr d18,[x4,#24]
 fmov d0,d16
 fcmp d17,d16
 b.lt .Lnonorographic_frequency
 fmul d0,d18,d17
.Lnonorographic_frequency:
 str d0,[x0,#120]
 fdiv d0,d0,d17
 fcvtzs w5,d0
 scvtf d0,w5
 fmul d0,d0,d17
 str d0,[x0,#120]
 /* The source repeats the one-launch amplitude after its empty group. */
 ldr x5,[x0,#72]
 str x5,[x0,#48]
#ifdef MD2ASM_RUNTIME_WMS_PARAMETERS
 sub w5,w6,#1
#else
 mov w5,#18
#endif
 stp w5,w5,[x0,#16]
 str w5,[x0,#24]
 adrp x4,.Lwave_launch_pressures
 add x4,x4,:lo12:.Lwave_launch_pressures
 ldp d16,d17,[x4]
 ldr d18,[x4,#16]
#ifdef MD2ASM_RUNTIME_WMS_PARAMETERS
 sub w4,w6,#1
 lsl x4,x4,#3
#else
 mov x4,#144
#endif
.Lnonorographic_launch:
 ldr d0,[x1,x4]
 lsr w5,w4,#3
 add w5,w5,#1
 fcmp d0,d16
 b.le .Lnonorographic_launch_second
 str w5,[x0,#16]
.Lnonorographic_launch_second:
 fcmp d0,d17
 b.le .Lnonorographic_launch_third
 str w5,[x0,#20]
.Lnonorographic_launch_third:
 fcmp d0,d18
 b.le .Lnonorographic_launch_next
 str w5,[x0,#24]
.Lnonorographic_launch_next:
 sub x4,x4,#8
 cbnz x4,.Lnonorographic_launch
 ldr w5,[x0,#16]
 str w5,[x0,#32]
 ret
.size WMS_FIELD_ENTRY,.-WMS_FIELD_ENTRY
.section .rodata
#include "cloud_parameter_constants.inc.S"
.p2align 3
.Lwave_constants: .double 80000.0,0.5,0.94,9.9
.Lwave_drag_constants: .double 0.3,1.0,0.15,3.0,0.25,0.40,0.10,1.0e-12,1.0e-7
.Lwave_limiter_pressure: .double 1000.0
.Lwave_tendency_constants: .double 20.0,80.0
.Lnonorographic_constants: .double 0.00375,1.0,2000.0,2.0,20.0,-0.25
.Lwave_launch_pressures: .double 45000.0,70000.0,20000.0
.section .note.GNU-stack,"",%progbits

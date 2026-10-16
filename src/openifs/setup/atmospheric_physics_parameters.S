/* Complete selected SUPHY0. Contract: skills/md2asm/references/openifs/setup/atmospheric_physics_parameters.md.
 * x0 text,x1 bytes,x2 output3456,x3 capacity,x4 explicit input48.
 * The parent validates the selected physics controls before mutation.
 * Literal and ordered-arithmetic children own every source-written field. */
.arch armv8.2-a
#include "atmospheric_parameter_layout.inc.S"
.text
.p2align 4
.global md2asm_initialize_atmospheric_physics_parameters
.type md2asm_initialize_atmospheric_physics_parameters,%function
md2asm_initialize_atmospheric_physics_parameters:
 cbz x0,.Latm_bad_leaf
 cbz x1,.Latm_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Latm_bad_leaf
 cbz x2,.Latm_bad_leaf
 cbz x4,.Latm_bad_leaf
 cmp x3,#3456
 b.lo .Latm_bad_leaf
 orr x5,x2,x4
 tst x5,#7
 b.ne .Latm_bad_leaf
 adds x5,x0,x1
 b.cs .Latm_bad_leaf
 adds x6,x2,#3456
 b.cs .Latm_bad_leaf
 adds x7,x4,#48
 b.cs .Latm_bad_leaf
 cmp x2,x5
 b.hs .Latm_text_clear
 cmp x0,x6
 b.lo .Latm_bad_leaf
.Latm_text_clear:
 cmp x2,x7
 b.hs .Latm_input_clear
 cmp x4,x6
 b.lo .Latm_bad_leaf
.Latm_input_clear:
 mrs x5,fpcr
 cbnz x5,.Latm_bad_leaf
 ldp x5,x7,[x4]
 cbz x5,.Latm_bad_leaf
 tst x5,#7
 b.ne .Latm_bad_leaf
 cmp x7,#1096
 b.lo .Latm_bad_leaf
 adds x7,x5,#1096
 b.cs .Latm_bad_leaf
 cmp x2,x7
 b.hs .Latm_phy_clear
 cmp x5,x6
 b.lo .Latm_bad_leaf
.Latm_phy_clear:
 ldr w6,[x4,#32]
 cbnz w6,.Latm_bad_leaf
 ldr w6,[x4,#36]
 cmp w6,#1
 b.ne .Latm_bad_leaf
 ldr w6,[x5,#736] /* LCOEFKTKE false */
 cbnz w6,.Latm_bad_leaf
 ldr w6,[x5,#12] /* LMPHYS false */
 cbnz w6,.Latm_bad_leaf
 adr x6,.Latm_control_offsets
 mov x7,#0
.Latm_logical_check:
 ldr w8,[x6,x7,lsl#2]
 ldr w8,[x5,x8]
 cmp w8,#1
 b.hi .Latm_bad_leaf
 add x7,x7,#1
 cmp x7,#7
 b.lo .Latm_logical_check
 ldr x6,[x4,#16]
 and x6,x6,#0x7fffffffffffffff
 mov x7,#0x3ff0000000000000
 cmp x6,x7
 b.hi .Latm_bad_leaf
 ldr x6,[x4,#24]
 cmp x6,x7
 b.lo .Latm_bad_leaf
 adr x7,.Latm_max_mesh
 ldr x7,[x7]
 cmp x6,x7
 b.hi .Latm_bad_leaf
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x2
 mov x20,x4
 adr x2,.Latm_group
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Latm_bad_frame
 mov x0,x19
 bl md2asm_set_atmospheric_parameter_literals_raw
 mov x0,x19
 mov x1,x20
 bl md2asm_set_atmospheric_parameter_arithmetic_raw
 mov w0,#0
 b .Latm_return
.Latm_bad_frame:
 mov w0,#2
.Latm_return:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Latm_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_atmospheric_physics_parameters,.-md2asm_initialize_atmospheric_physics_parameters
.p2align 4
.global md2asm_set_atmospheric_parameter_literals_raw
.type md2asm_set_atmospheric_parameter_literals_raw,%function
md2asm_set_atmospheric_parameter_literals_raw:
#include "atmospheric_parameter_literal_stores.inc.S"
.size md2asm_set_atmospheric_parameter_literals_raw,.-md2asm_set_atmospheric_parameter_literals_raw
.p2align 4
.global md2asm_set_atmospheric_parameter_arithmetic_raw
.type md2asm_set_atmospheric_parameter_arithmetic_raw,%function
md2asm_set_atmospheric_parameter_arithmetic_raw:
 /* x0 TPHY0, x1 checked explicit input. All FP registers are caller-saved. */
 ldr x2,[x1]
 ldr w3,[x2,#36]
 ldr w4,[x2,#200]
 and w3,w3,w4
 fmov d0,#1.0
 fmov d1,#0.5
 cmp w3,#0
 fcsel d0,d1,d0,ne
 str d0,[x0,#ATM_RDTFAC]
 ldr w3,[x2,#816]
 ldr w4,[x2,#908]
 orr w3,w3,w4
 ldr w4,[x2,#712]
 orr w3,w3,w4
 ldr w4,[x2,#808]
 and w3,w3,w4
 eor w3,w3,#1
 ldr w4,[x2,#916]
 and w3,w3,w4
 cbz w3,.Latm_tentrvl_ready
 str xzr,[x0,#ATM_TENTRVL]
.Latm_tentrvl_ready:
 ldr d0,[x1,#16]
 fcmp d0,#0.0
 b.eq .Latm_rotation_zero
 fmov d1,#1.0
 fdiv d0,d1,d0
 str d0,[x0,#ATM_GPETAU]
 b .Latm_rotation_ready
.Latm_rotation_zero:
 str xzr,[x0,#ATM_GPETAU]
.Latm_rotation_ready:
 fmov d0,#1.0
 fmov d1,#3.0
 fdiv d0,d0,d1
 str d0,[x0,#ATM_UCWSTAR]
 ldr d0,[x0,#ATM_ARSCH]
 fmul d0,d1,d0
 ldr d2,[x0,#ATM_ARSCQ]
 fmul d0,d0,d2
 fmov d2,#2.0
 fdiv d0,d2,d0
 str d0,[x0,#ATM_ARSC1]
 ldr d3,[x0,#ATM_ARSCH]
 fmul d3,d1,d3
 fmul d3,d3,d0
 fdiv d3,d3,d2
 str d3,[x0,#ATM_ARSB2]
 fsqrt d0,d1
 str d0,[x0,#ATM_STTBMIN]
 fdiv d0,d2,d1
 str d0,[x0,#ATM_ETKE_OLAM]
 fdiv d0,d2,d1
 str d0,[x0,#ATM_ETKE_LAM0]
 /* ZSM0 = NUPTKE**4 / 2. */
 ldr d16,[x0,#ATM_NUPTKE]
 fmul d16,d16,d16
 fmul d16,d16,d16
 fdiv d16,d16,d2
 ldr d17,[x0,#ATM_C3TKEFREE]
 fmul d18,d17,d17
 /* ZLAMF_X, retaining each written product and sum. */
 adr x9,.Latm_375
 ldr d0,[x9]
 fmul d0,d0,d18
 fmul d1,d2,d17
 fadd d1,d18,d1
 fmov d3,#1.0
 fadd d1,d1,d3
 fmul d0,d0,d1
 fmul d1,d16,d16
 fmul d0,d0,d1
 fadd d1,d18,d17
 fsub d1,d1,d3
 fmov d4,#20.0
 fmul d1,d4,d1
 fmul d1,d1,d16
 fsub d0,d0,d1
 fadd d0,d0,d3
 fsqrt d19,d0
 /* ZLAMBDA. */
 fmov d0,#5.0
 fsqrt d0,d0
 fmov d1,#3.0
 fmul d0,d0,d1
 fmov d1,#4.0
 fdiv d0,d0,d1
 fmul d0,d0,d19
 fmov d1,#30.0
 fmul d1,d1,d17
 fadd d2,d17,d3
 fmul d1,d1,d2
 fmul d1,d1,d16
 fsub d0,d0,d1
 fmov d1,#0.25
 fadd d20,d0,d1
 /* ZSF. */
 adr x9,.Latm_75
 ldr d1,[x9]
 fmul d1,d1,d17
 fmul d1,d1,d2
 fmul d1,d1,d16
 fmov d0,#10.0
 fsub d0,d0,d1
 fmov d1,#8.0
 fmul d1,d1,d20
 fdiv d21,d0,d1
 fmov d0,#4.0
 fmov d1,#15.0
 fdiv d0,d0,d1
 fmul d0,d0,d20
 str d0,[x0,#ATM_ETKE_LAM1]
 fmov d0,#14.0
 fmul d0,d0,d20
 fmul d0,d0,d21
 fmov d1,#5.0
 fmul d1,d1,d20
 fadd d0,d0,d1
 adr x9,.Latm_75
 ldr d2,[x9]
 fdiv d0,d0,d2
 str d0,[x0,#ATM_ETKE_LAM3]
 fmov d0,#6.0
 fmul d0,d0,d20
 fmul d0,d0,d21
 fsub d0,d1,d0
 fmov d2,#25.0
 fdiv d0,d0,d2
 str d0,[x0,#ATM_ETKE_LAM2]
 ldr d0,[x0,#ATM_C_EPSILON]
 fmul d0,d0,d17
 ldr d1,[x0,#ATM_ETKE_OLAM]
 fdiv d0,d0,d1
 str d0,[x0,#ATM_ETKE_CTHETA]
 fmov d2,#2.0
 fdiv d0,d20,d2
 str d0,[x0,#ATM_ETKE_KA1]
 fmul d2,d2,d17
 fdiv d0,d1,d2
 str d0,[x0,#ATM_ETKE_KA2]
 fmov d0,#1.0
 str d0,[x0,#ATM_ETKE_KA3]
 /* Convection thresholds scale with the live grid length. */
 ldr d1,[x1,#24]
 ldr d0,[x0,#ATM_REFLKUO]
 fdiv d0,d0,d1
 str d0,[x0,#ATM_TEQK]
 ldr d0,[x0,#ATM_REFLCAPE]
 fdiv d0,d0,d1
 str d0,[x0,#ATM_TEQC]
 ldr d0,[x0,#ATM_REFLRHC]
 fdiv d0,d0,d1
 str d0,[x0,#ATM_TEQH]
 ret
.size md2asm_set_atmospheric_parameter_arithmetic_raw,.-md2asm_set_atmospheric_parameter_arithmetic_raw
.section .rodata
.p2align 3
.Latm_group: .ascii "NAMPHY0"
.p2align 3
.Latm_control_offsets: .word 36,200,808,816,908,712,916
.p2align 3
.Latm_375: .double 375.0
.Latm_75: .double 75.0
.Latm_max_mesh: .double 100000000.0
.section .note.GNU-stack,"",%progbits

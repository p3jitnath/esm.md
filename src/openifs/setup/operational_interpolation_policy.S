/* Contract skills/md2asm/references/openifs/input/runtime_configured_model_initialization.md.
 * x0 bounded text, x1 bytes, x2 policy16, x3 capacity. Return 0 or atomic refusal 2.
 * Four int32 words LSYNC_SLCOM, LSLDEBUG, LSLONDEM and LSYNC_TRANS. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_interpolation_policy
.type md2asm_initialize_operational_interpolation_policy,%function
md2asm_initialize_operational_interpolation_policy:
 cbz x0,.Lpolicy_bad_leaf
 cbz x2,.Lpolicy_bad_leaf
 cmp x3,#16
 b.lo .Lpolicy_bad_leaf
 tst x2,#3
 b.ne .Lpolicy_bad_leaf
 adds x9,x2,#16
 b.cs .Lpolicy_bad_leaf
 adds x10,x0,x1
 b.cs .Lpolicy_bad_leaf
 cmp x9,x0
 b.ls .Lpolicy_disjoint
 cmp x2,x10
 b.lo .Lpolicy_bad_leaf
.Lpolicy_disjoint:
 stp x29,x30,[sp,#-64]!
 stp x19,x18,[sp,#16]
 mov x29,sp
 mov x19,x2
 stp xzr,xzr,[sp,#32]
 stp xzr,xzr,[sp,#48]
 mov w9,#1
 str w9,[sp,#40]
 add x2,sp,#32
 bl md2asm_read_operational_interpolation_policy_private
 cbnz w0,.Lpolicy_return
 ldp x9,x10,[sp,#32]
 stp x9,x10,[x19]
.Lpolicy_return:
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lpolicy_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_interpolation_policy,.-md2asm_initialize_operational_interpolation_policy
.section .note.GNU-stack,"",%progbits

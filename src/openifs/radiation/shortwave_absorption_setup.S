/* Selected source-owned SRTM_INIT with explicit original input bytes.
   Contract: skills/md2asm/references/openifs/radiation/shortwave_absorption_setup.md. */
.text
.p2align 4
.global md2asm_initialize_shortwave_absorption
.type md2asm_initialize_shortwave_absorption,%function
md2asm_initialize_shortwave_absorption:
 cbnz w4,.Lsw_parent_bad
 mrs x4,fpcr
 cbnz x4,.Lsw_parent_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x2
 bl md2asm_decode_shortwave_absorption_inputs
 cbnz w0,.Lsw_parent_return
 mov x0,x19
 bl md2asm_shortwave_absorption_weights
 adrp x21,.Lsw_reduction_plan
 add x21,x21,:lo12:.Lsw_reduction_plan
 mov x20,#71
.Lsw_parent_field:
 ldp x0,x1,[x21]
 ldp x2,x3,[x21,#16]
 ldr x4,[x21,#32]
 add x0,x19,x0
 add x1,x19,x1
 add x2,x19,x2
 cbz x4,.Lsw_parent_weight
 add x4,x19,x4
.Lsw_parent_weight:
 add x5,x21,#40
 bl md2asm_reduce_longwave_field
 add x21,x21,#80
 subs x20,x20,#1
 b.ne .Lsw_parent_field
 mov w0,#0
.Lsw_parent_return:
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lsw_parent_bad:
 mov w0,#2
 ret
.size md2asm_initialize_shortwave_absorption,.-md2asm_initialize_shortwave_absorption
.section .rodata
.p2align 3
#include "shortwave_reduction_plan.inc.S"
.section .note.GNU-stack,"",%progbits

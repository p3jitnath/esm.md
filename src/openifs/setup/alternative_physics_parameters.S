/* Complete selected SUPARAR. Contract: skills/md2asm/references/openifs/setup/alternative_physics_parameters.md.
 * x0 text,x1 bytes,x2 output904,x3 capacity,x4 input32.
 * Input int32 words are LMSE,LMPA,LRAYFM,LRAYFM15,hail,NUNDEFLD,LSFORCS,reserved.
 * The selected path has no pseudo-history allocation. Return0/2. */
.arch armv8.2-a
#include "alternative_parameter_layout.inc.S"
.text
.p2align 4
.global md2asm_initialize_alternative_physics_parameters
.type md2asm_initialize_alternative_physics_parameters,%function
md2asm_initialize_alternative_physics_parameters:
 cbz x0,.Lalt_bad_leaf
 cbz x1,.Lalt_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lalt_bad_leaf
 cbz x2,.Lalt_bad_leaf
 cbz x4,.Lalt_bad_leaf
 cmp x3,#904
 b.lo .Lalt_bad_leaf
 orr x5,x2,x4
 tst x5,#7
 b.ne .Lalt_bad_leaf
 adds x5,x0,x1
 b.cs .Lalt_bad_leaf
 adds x6,x2,#904
 b.cs .Lalt_bad_leaf
 adds x7,x4,#32
 b.cs .Lalt_bad_leaf
 cmp x2,x5
 b.hs .Lalt_text_clear
 cmp x0,x6
 b.lo .Lalt_bad_leaf
.Lalt_text_clear:
 cmp x2,x7
 b.hs .Lalt_input_clear
 cmp x4,x6
 b.lo .Lalt_bad_leaf
.Lalt_input_clear:
 ldp w5,w6,[x4]
 orr w5,w5,w6
 cbnz w5,.Lalt_bad_leaf
 ldp w5,w6,[x4,#8]
 cmp w5,#1
 b.hi .Lalt_bad_leaf
 cmp w6,#1
 b.hi .Lalt_bad_leaf
 ldr w5,[x4,#16]
 cmp w5,#1
 b.hi .Lalt_bad_leaf
 mrs x5,fpcr
 cbnz x5,.Lalt_bad_leaf
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x2
 mov x20,x4
 adr x2,.Lalt_group
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lalt_bad_frame
 mov x0,x19
 bl md2asm_set_alternative_parameter_literals_raw
 mov x0,x19
 mov x1,x20
 bl md2asm_set_alternative_parameter_arithmetic_raw
 mov w0,#0
 b .Lalt_return
.Lalt_bad_frame:
 mov w0,#2
.Lalt_return:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lalt_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_alternative_physics_parameters,.-md2asm_initialize_alternative_physics_parameters
.p2align 4
.global md2asm_set_alternative_parameter_literals_raw
.type md2asm_set_alternative_parameter_literals_raw,%function
md2asm_set_alternative_parameter_literals_raw:
#include "alternative_parameter_literal_stores.inc.S"
.size md2asm_set_alternative_parameter_literals_raw,.-md2asm_set_alternative_parameter_literals_raw
.p2align 4
.global md2asm_set_alternative_parameter_arithmetic_raw
.type md2asm_set_alternative_parameter_arithmetic_raw,%function
md2asm_set_alternative_parameter_arithmetic_raw:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 /* Source logarithm uses the widened single-precision autoconversion threshold. */
 ldr d0,[x19,#ALT_RCRIAUTI]
 bl log10
 ldr x18,[sp,#32]
 fmov d1,#3.5
 fadd d0,d0,d1
 adr x9,.Lalt_six_percent
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[x19,#ALT_RT0CRIAUTI]
 fmov d0,#2.0
 fmov d1,#3.0
 fdiv d0,d0,d1
 str d0,[x19,#ALT_XA1]
 ldr w9,[x20,#16]
 cbnz w9,.Lalt_hail
 mov w9,#6
 str w9,[x19,#ALT_NRR]
 mov w9,#3
 str w9,[x19,#ALT_NRRI]
 adr x10,.Lalt_old3
 ldr w9,[x10]
 b .Lalt_micro_ready
.Lalt_hail:
 mov w9,#7
 str w9,[x19,#ALT_NRR]
 mov w9,#4
 str w9,[x19,#ALT_NRRI]
 adr x10,.Lalt_old4
 ldr w9,[x10]
.Lalt_micro_ready:
 str w9,[x19,#ALT_CMICRO]
 ldp w9,w10,[x20,#8]
 orr w9,w9,w10
 mov w10,#1
 mov w11,#6
 cmp w9,#0
 csel w9,w11,w10,ne
 str w9,[x19,#ALT_NSWB_MNH]
 str wzr,[x19,#ALT_NGPAR]
 ldr w9,[x20,#20]
 str w9,[x19,#ALT_MINPRR]
 str w9,[x19,#ALT_MACPRR]
 str w9,[x19,#ALT_MINPRS]
 str w9,[x19,#ALT_MACPRS]
 str w9,[x19,#ALT_MINPRG]
 str w9,[x19,#ALT_MACPRG]
 str w9,[x19,#ALT_MALBDIR]
 str w9,[x19,#ALT_MALBSCA]
 str w9,[x19,#ALT_MVTS]
 str w9,[x19,#ALT_MVEMIS]
 str w9,[x19,#ALT_MSWDIR]
 str w9,[x19,#ALT_MSWDIF]
 str w9,[x19,#ALT_MRAIN]
 str w9,[x19,#ALT_MSNOW]
 str w9,[x19,#ALT_MVQS]
 str w9,[x19,#ALT_MLSM]
 str w9,[x19,#ALT_MGZ0]
 str w9,[x19,#ALT_MGZ0H]
 str w9,[x19,#ALT_MCD]
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_set_alternative_parameter_arithmetic_raw,.-md2asm_set_alternative_parameter_arithmetic_raw
.section .rodata
.p2align 3
.Lalt_group: .ascii "NAMPARAR"
.Lalt_old3: .ascii "OLD3"
.Lalt_old4: .ascii "OLD4"
.p2align 3
.Lalt_six_percent: .quad 0x3faeb851e0000000
.section .note.GNU-stack,"",%progbits

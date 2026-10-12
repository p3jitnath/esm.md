/* Complete calc_reflectance_transmittance_lw layer transport.
 * Physics formulations/openifs/radiation/longwave_layer_energy.md, P01-P03.
 * Contract skills/md2asm/references/openifs/radiation/longwave_layer_transport.md.
 * Ten ordinary addresses and complete separately rounded FP64 updates. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_reflectance_transmittance_lw
#endif
#ifndef EXP_SYMBOL
#define EXP_SYMBOL exp
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.global md2asm_longwave_layer
.type md2asm_longwave_layer,%function
ORIGINAL_SYMBOL:
md2asm_longwave_layer:
 ldr w9,[x0]
 cmp w9,#0
 b.le .Llayer_empty
 cmp w9,#4096
 b.gt .Llayer_unframed_reject
 mov x17,sp
 sub sp,sp,#192
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 str x18,[sp,#160]
 mrs x10,fpsr
 str x10,[sp,#168]
 lsl x19,x9,#3
 mov x20,#0
 mov x21,x1
 mov x22,x2
 mov x23,x3
 mov x24,x4
 mov x25,x5
 mov x26,x6
 mov x27,x7
 ldp x28,x10,[x17]
 str x10,[sp,#176]
 mrs x10,fpcr
 cbnz x10,.Llayer_reject
.Llayer_guard:
 ldr d8,[x21,x20]
 ldr d9,[x22,x20]
 ldr d10,[x23,x20]
 ldr d11,[x24,x20]
 ldr d12,[x25,x20]
 ldr d7,.Llayer_maximum
.macro layer_valid reg
 fmov x10,\reg
 ubfx x10,x10,#52,#11
 cmp x10,#2047
 b.eq .Llayer_reject
 fcmp \reg,#0.0
 b.lt .Llayer_reject
 fcmp \reg,d7
 b.gt .Llayer_reject
.endm
 layer_valid d8
 layer_valid d9
 layer_valid d10
 layer_valid d11
 layer_valid d12
 fcmp d9,d10
 b.le .Llayer_reject
 fsub d0,d9,d10
 fadd d1,d9,d10
 fmul d2,d0,d1
 ldr d3,.Llayer_k_minimum
 fcmp d2,d3
 b.le .Llayer_reject
 fsqrt d13,d2
 ldr d3,.Llayer_threshold
 fcmp d8,d3
 b.gt .Llayer_guard_next
 fmul d4,d13,d8
 fmov d5,#1.0
 fcmp d4,d5
 b.gt .Llayer_reject
 fsub d1,d9,d13
 fmul d1,d10,d1
 fmul d1,d1,d8
 fsub d1,d0,d1
 fcmp d1,#0.0
 b.lt .Llayer_reject
.Llayer_guard_next:
 add x20,x20,#8
 cmp x20,x19
 b.ne .Llayer_guard
 ldr x10,[sp,#168]
 msr fpsr,x10
 mov x20,#0
.Llayer_point:
 ldr d8,[x21,x20]
 ldr d9,[x22,x20]
 ldr d10,[x23,x20]
 ldr d11,[x24,x20]
 ldr d12,[x25,x20]
 fsub d0,d9,d10
 fadd d1,d9,d10
 fmul d0,d0,d1
 ldr d1,.Llayer_k_minimum
 fmax d0,d0,d1
 fsqrt d13,d0
 ldr d0,.Llayer_threshold
 fcmp d8,d0
 b.gt .Llayer_thick
 fmul d16,d10,d8
 fmul d0,d13,d8
 fmov d1,#1.0
 fsub d0,d1,d0
 fsub d2,d9,d13
 fmul d2,d8,d2
 fadd d2,d1,d2
 fdiv d17,d0,d2
 fsub d2,d1,d16
 fsub d2,d2,d17
 fmov d3,#0.5
 fmul d2,d2,d3
 fadd d3,d11,d12
 fmul d2,d2,d3
 fmov d3,d2
 b .Llayer_store
.Llayer_thick:
 fmul d0,d13,d8
 fneg d0,d0
 bl EXP_SYMBOL
 fmov d14,d0
 adrp x9,.Llayer_exp_count
 add x9,x9,:lo12:.Llayer_exp_count
.Llayer_count:
 ldxr x10,[x9]
 add x10,x10,#1
 stxr w11,x10,[x9]
 cbnz w11,.Llayer_count
 fmul d0,d14,d14
 fadd d1,d13,d9
 fsub d2,d13,d9
 fmul d2,d2,d0
 fadd d1,d1,d2
 fmov d2,#1.0
 fdiv d15,d2,d1
 fsub d0,d2,d0
 fmul d0,d10,d0
 fmul d16,d0,d15
 fmov d0,#2.0
 fmul d0,d0,d13
 fmul d0,d0,d14
 fmul d17,d0,d15
 fsub d0,d12,d11
 fadd d1,d9,d10
 fmul d1,d8,d1
 fdiv d0,d0,d1
 fadd d1,d0,d11
 fadd d2,d0,d12
 fneg d3,d0
 fadd d3,d3,d11
 fneg d4,d0
 fadd d4,d4,d12
 fmul d5,d16,d3
 fsub d1,d1,d5
 fmul d5,d17,d2
 fsub d6,d1,d5
 fmul d5,d16,d2
 fsub d4,d4,d5
 fmul d5,d17,d3
 fsub d3,d4,d5
 fmov d2,d6
.Llayer_store:
 str d16,[x26,x20]
 str d17,[x27,x20]
 str d2,[x28,x20]
 ldr x10,[sp,#176]
 str d3,[x10,x20]
 add x20,x20,#8
 cmp x20,x19
 b.ne .Llayer_point
 ldr x18,[sp,#160]
 ldp d8,d9,[sp,#96]
 ldp d10,d11,[sp,#112]
 ldp d12,d13,[sp,#128]
 ldp d14,d15,[sp,#144]
 ldp x19,x20,[sp]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x29,x30,[sp,#80]
 add sp,sp,#192
.Llayer_empty:
 ret
.Llayer_reject:
 bl abort
 brk #0
.Llayer_unframed_reject:
 bl abort
 brk #0
.size md2asm_longwave_layer,.-md2asm_longwave_layer
.p2align 2
.global md2asm_longwave_layer_exp_count_get
.type md2asm_longwave_layer_exp_count_get,%function
md2asm_longwave_layer_exp_count_get:
 adrp x9,.Llayer_exp_count
 ldr x0,[x9,:lo12:.Llayer_exp_count]
 ret
.size md2asm_longwave_layer_exp_count_get,.-md2asm_longwave_layer_exp_count_get
.p2align 3
.Llayer_threshold:
 .quad 0x3f50624dd2f1a9fc
.Llayer_k_minimum:
 .double 1e-12
.Llayer_maximum:
 .double 1e6
.bss
.p2align 3
.Llayer_exp_count:
 .zero 8
.section .note.GNU-stack,"",%progbits

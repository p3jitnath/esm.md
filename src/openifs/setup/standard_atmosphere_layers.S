// Solver contract skills/md2asm/references/openifs/setup/standard_atmosphere_layers.md.
// Contract: skills/md2asm/references/openifs/setup/standard_atmosphere_layers.md.
// x0 output288, x1 physical32, w2 LECMWF; return0 or2beforewrite.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_standard_atmosphere_layers
.type md2asm_initialize_standard_atmosphere_layers,%function
md2asm_initialize_standard_atmosphere_layers:
 mrs x9,fpcr
 cbnz x9,.Latmosphere_invalid
 cbz x0,.Latmosphere_invalid
 cbz x1,.Latmosphere_invalid
 orr x9,x0,x1
 tst x9,#7
 b.ne .Latmosphere_invalid
 cmp w2,#1
 b.hi .Latmosphere_invalid
 adds x9,x0,#288
 b.cs .Latmosphere_invalid
 adds x10,x1,#32
 b.cs .Latmosphere_invalid
 cmp x0,x10
 b.hs .Latmosphere_disjoint
 cmp x1,x9
 b.lo .Latmosphere_invalid
.Latmosphere_disjoint:
 adrp x9,.Latmosphere_constants
 add x9,x9,:lo12:.Latmosphere_constants
 mov x10,#0
.Latmosphere_guard:
 ldr x11,[x1,x10,lsl #3]
 add x12,x9,#216
 ldr x12,[x12,x10,lsl #3]
 cmp x11,x12
 b.lo .Latmosphere_invalid
 add x12,x9,#248
 ldr x12,[x12,x10,lsl #3]
 cmp x11,x12
 b.hi .Latmosphere_invalid
 add x10,x10,#1
 cmp x10,#4
 b.ne .Latmosphere_guard
 sub sp,sp,#128
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 stp d8,d9,[sp,#64]
 stp d10,d11,[sp,#80]
 stp d12,d13,[sp,#96]
 stp d14,d15,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov w22,w2
 mov x23,x9
 ldp d8,d9,[x20]
 ldp d10,d11,[x20,#16]
 add x9,x23,#72
 add x10,x23,#144
 cmp w22,#0
 csel x9,x10,x9,ne
 add x11,x19,#72
 mov x21,#0
.Latmosphere_defaults:
 ldr d0,[x23,x21,lsl #3]
 ldr d1,[x9,x21,lsl #3]
 str d0,[x19,x21,lsl #3]
 str d1,[x11,x21,lsl #3]
 add x21,x21,#1
 cmp x21,#9
 b.ne .Latmosphere_defaults
 ldr d14,[x23,#280]
 str d14,[x19,#144]
 str d11,[x19,#216]
 mov x21,#0
.Latmosphere_layers:
 add x9,x19,x21,lsl #3
 ldp d0,d1,[x9]
 fsub d13,d1,d0
 ldr d12,[x9,#72]
 ldr d14,[x9,#144]
 ldr d15,[x9,#216]
 fcmp d12,#0.0
 b.eq .Latmosphere_isothermal
 fmul d4,d12,d13
 fadd d5,d14,d4
 str d5,[x9,#152]
 fdiv d0,d4,d14
 ldr d1,[x23,#288]
 fadd d0,d1,d0
 fneg d1,d8
 fdiv d1,d1,d10
 fdiv d1,d1,d9
 fdiv d1,d1,d12
 bl md2asm_pow_original_rounding_candidate
 b .Latmosphere_pressure
.Latmosphere_isothermal:
 str d14,[x9,#152]
 fneg d0,d8
 fdiv d0,d0,d10
 fdiv d0,d0,d9
 fdiv d0,d0,d14
 fmul d0,d0,d13
 bl md2asm_exp_original_rounding
.Latmosphere_pressure:
 fmul d0,d15,d0
 add x9,x19,x21,lsl #3
 str d0,[x9,#224]
 add x21,x21,#1
 cmp x21,#8
 b.ne .Latmosphere_layers
 mov w0,#0
 ldp d14,d15,[sp,#112]
 ldp d12,d13,[sp,#96]
 ldp d10,d11,[sp,#80]
 ldp d8,d9,[sp,#64]
 ldp x23,x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.Latmosphere_invalid:
 mov w0,#2
 ret
.size md2asm_initialize_standard_atmosphere_layers,.-md2asm_initialize_standard_atmosphere_layers
.section .rodata
.p2align 4
.Latmosphere_constants:
 .quad 0x0000000000000000
 .quad 0x40c57c0000000000
 .quad 0x40d3880000000000
 .quad 0x40df590000000000
 .quad 0x40e7250000000000
 .quad 0x40e9190000000000
 .quad 0x40f1814000000000
 .quad 0x40f4ec4000000000
 .quad 0x40f86a0000000000
 .quad 0xbf7a9fbe76c8b439
 .quad 0x0000000000000000
 .quad 0x3f50624dd2f1a9fc
 .quad 0x3f66872b020c49ba
 .quad 0x0000000000000000
 .quad 0xbf66872b020c49ba
 .quad 0xbf602363b256ffc1
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0xbf7a9fbe76c8b439
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x4022000000000000
 .quad 0x4070e00000000000
 .quad 0x3fe0000000000000
 .quad 0x40f5f90000000000
 .quad 0x4024000000000000
 .quad 0x4073600000000000
 .quad 0x4000000000000000
 .quad 0x40fadb0000000000
 .quad 0x4072026666666666
 .quad 0x3ff0000000000000
.section .note.GNU-stack,"",%progbits

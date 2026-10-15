// Solver contract skills/md2asm/references/openifs/support/scalar_exponential.md.
// Contract: skills/md2asm/references/openifs/support/scalar_exponential.md. AAPCS64 d0 input and return.
// Source-ordered Arm scalar EXP, N128/order5, separately rounded FP64 only.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_exp_original_rounding
.type md2asm_exp_original_rounding,%function
md2asm_exp_original_rounding:
 adrp x17,md2asm_exp_constants
 add x17,x17,:lo12:md2asm_exp_constants
 fmov x15,d0
 ubfx x14,x15,#52,#11
 cmp w14,#0x3c9
 b.lo .Ltiny
 cmp w14,#0x408
 b.lo .Lreduce
 cmp w14,#0x409
 b.hs .Lhuge
 mov w14,#0
.Lreduce:
 ldp d1,d2,[x17]
 ldr d3,[x17,#24]
 fmul d4,d1,d0
 fadd d4,d4,d3
 fmov x10,d4
 fsub d3,d4,d3
 fmul d4,d3,d2
 fadd d4,d0,d4
 ldr d2,[x17,#16]
 fmul d5,d3,d2
 fadd d4,d4,d5
 and x11,x10,#127
 lsl x11,x11,#4
 lsl x12,x10,#45
 adrp x9,md2asm_exp_scale_table
 add x9,x9,:lo12:md2asm_exp_scale_table
 add x9,x9,x11
 ldr d6,[x9]
 ldr x13,[x9,#8]
 add x13,x13,x12
 fmul d5,d4,d4
 ldp d16,d17,[x17,#32]
 ldp d18,d19,[x17,#48]
 fadd d7,d6,d4
 fmul d20,d4,d17
 fadd d20,d16,d20
 fmul d20,d5,d20
 fadd d7,d7,d20
 fmul d21,d4,d19
 fadd d21,d18,d21
 fmul d22,d5,d5
 fmul d21,d22,d21
 fadd d7,d7,d21
 cbz w14,.Lspecial
 fmov d23,x13
 fmul d6,d23,d7
 fadd d0,d23,d6
 ret
.Ltiny:
 ldr d1,[x17,#64]
 fadd d0,d1,d0
 ret
.Lhuge:
 mov x9,#0xfff0000000000000
 cmp x15,x9
 b.eq .Lnegative_infinity
 cmp w14,#0x7ff
 b.hs .Ltiny
 tbnz x15,#63,.Lunderflow_zero
 ldr d0,[x17,#88]
 fmul d0,d0,d0
 b .Lrange_error
.Lunderflow_zero:
 ldr d0,[x17,#96]
 fmul d0,d0,d0
 b .Lrange_error
.Lnegative_infinity:
 fmov d0,xzr
 ret
.Lspecial:
 tbnz x10,#31,.Lsmall_scale
 mov x9,#1009
 lsl x9,x9,#52
 sub x13,x13,x9
 fmov d23,x13
 fmul d6,d23,d7
 fadd d0,d23,d6
 ldr d1,[x17,#72]
 fmul d0,d1,d0
 fmov x9,d0
 ubfx x9,x9,#52,#11
 cmp x9,#0x7ff
 b.eq .Lrange_error
 ret
.Lsmall_scale:
 mov x9,#1022
 lsl x9,x9,#52
 add x13,x13,x9
 fmov d23,x13
 fmul d6,d23,d7
 fadd d0,d23,d6
 ldr d1,[x17,#64]
 fcmp d0,d1
 b.ge .Lsubnormal_scale
 fsub d2,d23,d0
 fadd d2,d2,d6
 fadd d3,d1,d0
 fsub d4,d1,d3
 fadd d4,d4,d0
 fadd d2,d4,d2
 fadd d0,d3,d2
 fsub d0,d0,d1
 fcmp d0,#0.0
 b.ne .Lraise_underflow
 fmov d0,xzr
.Lraise_underflow:
 ldr d1,[x17,#80]
 fmul d2,d1,d1
.Lsubnormal_scale:
 ldr d1,[x17,#80]
 fmul d0,d1,d0
 fcmp d0,#0.0
 b.eq .Lrange_error
 ret
.Lrange_error:
 // __errno_location supplies only the C error slot, never a numerical stage.
 sub sp,sp,#64
 stp x29,x30,[sp]
 mov x29,sp
 str x18,[sp,#16]
 str d0,[sp,#24]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#32]
 bl __errno_location
 mov w9,#34
 str w9,[x0]
 ldp x9,x10,[sp,#32]
 msr fpcr,x9
 msr fpsr,x10
 ldr d0,[sp,#24]
 ldr x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.size md2asm_exp_original_rounding,.-md2asm_exp_original_rounding
.section .note.GNU-stack,"",%progbits

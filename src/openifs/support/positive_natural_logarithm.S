/* Positive natural logarithm, revision 1.
 * Contract: skills/md2asm/references/openifs/support/positive_natural_logarithm.md.
 * d0 carries the input and result. Support finite 2^-52 <= x <= DBL_MAX
 * with FPCR zero. Other routes stop through operating-system exit 116.
 * This leaf uses no stack and preserves x18, saved ABI state and errno.
 * Each FP64 multiply and add retains its original separate rounding.
 * Arithmetic and coefficient source: Arm optimized-routines log.c/log_data.c.
 * Copyright (c) 2018-2025, Arm Limited.
 * SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_log_positive_normal
.type md2asm_log_positive_normal,%function
md2asm_log_positive_normal:
 mrs x9,fpcr
 cbnz x9,.Lreject
 fmov x1,d0
 movz x2,#0x3cb0,lsl#48
 cmp x1,x2
 b.lo .Lreject
 movz x2,#0x7ff0,lsl#48
 cmp x1,x2
 b.hs .Lreject
 adrp x9,md2asm_log_positive_normal_calls
 add x9,x9,:lo12:md2asm_log_positive_normal_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 adrp x9,md2asm_log_source_data
 add x9,x9,:lo12:md2asm_log_source_data
 movz x2,#0x3fee,lsl#48
 sub x3,x1,x2
 movz x4,#0x3ff1,lsl#48
 movk x4,#0x0900,lsl#32
 sub x4,x4,x2
 cmp x3,x4
 b.lo .Lnear_one
 movz x2,#0x3fe6,lsl#48
 sub x2,x1,x2
 ubfx x3,x2,#45,#7
 lsl x3,x3,#4
 asr x4,x2,#52
 and x5,x2,#0xfff0000000000000
 sub x5,x1,x5
 fmov d16,x5
 scvtf d17,x4
 add x10,x9,#144
 add x10,x10,x3
 ldp d3,d4,[x10]
 add x10,x9,#2192
 add x10,x10,x3
 ldp d5,d6,[x10]
 fsub d18,d16,d5
 fsub d18,d18,d6
 fmul d18,d18,d3
 ldp d1,d2,[x9]
 fmul d19,d17,d1
 fadd d19,d19,d4
 fadd d20,d19,d18
 fsub d21,d19,d20
 fadd d21,d21,d18
 fmul d25,d17,d2
 fadd d21,d21,d25
 fmul d22,d18,d18
 ldp d3,d4,[x9,#40]
 fmul d23,d18,d4
 fadd d23,d3,d23
 ldp d3,d4,[x9,#24]
 fmul d24,d18,d4
 fadd d24,d3,d24
 fmul d25,d22,d23
 fadd d24,d24,d25
 ldr d3,[x9,#16]
 fmul d25,d22,d3
 fadd d21,d21,d25
 fmul d26,d18,d22
 fmul d26,d26,d24
 fadd d21,d21,d26
 fadd d0,d21,d20
 ret
.Lnear_one:
 fmov d1,#1.0
 fmov x10,d1
 cmp x1,x10
 b.eq .Lexact_one
 fsub d0,d0,d1
 fmul d2,d0,d0
 fmul d3,d0,d2
 ldp d24,d25,[x9,#112]
 fmul d4,d0,d25
 fadd d4,d24,d4
 ldr d24,[x9,#128]
 fmul d22,d2,d24
 fadd d4,d4,d22
 ldr d24,[x9,#136]
 fmul d22,d3,d24
 fadd d4,d4,d22
 ldp d24,d25,[x9,#88]
 fmul d5,d0,d25
 fadd d5,d24,d5
 ldr d24,[x9,#104]
 fmul d22,d2,d24
 fadd d5,d5,d22
 fmul d22,d3,d4
 fadd d5,d5,d22
 ldp d24,d25,[x9,#64]
 fmul d6,d0,d25
 fadd d6,d24,d6
 ldr d24,[x9,#80]
 fmul d22,d2,d24
 fadd d6,d6,d22
 fmul d22,d3,d5
 fadd d6,d6,d22
 fmul d6,d3,d6
 movz x10,#0x41a0,lsl#48
 fmov d7,x10
 fmul d7,d0,d7
 fadd d16,d0,d7
 fsub d16,d16,d7
 fsub d17,d0,d16
 ldr d21,[x9,#56]
 fmul d18,d16,d16
 fmul d18,d18,d21
 fadd d19,d0,d18
 fsub d20,d0,d19
 fadd d20,d20,d18
 fmul d22,d21,d17
 fadd d23,d16,d0
 fmul d22,d22,d23
 fadd d20,d20,d22
 fadd d6,d6,d20
 fadd d0,d6,d19
 ret
.Lexact_one:
 fmov d0,xzr
 ret
.Lreject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size md2asm_log_positive_normal,.-md2asm_log_positive_normal
.data
.p2align 3
.hidden md2asm_log_positive_normal_calls
.global md2asm_log_positive_normal_calls
.type md2asm_log_positive_normal_calls,%object
md2asm_log_positive_normal_calls:
 .quad 0
.size md2asm_log_positive_normal_calls,8
.section .note.GNU-stack,"",%progbits

/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/support/positive_natural_logarithm.md
 * Original source: src/openifs/support/positive_natural_logarithm.S
 */
// Copyright (c) 2018-2025, Arm Limited.
// SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
// Original contract: skills/md2asm/references/openifs/support/positive_natural_logarithm.md
#include "preserved_scalar_calls.inc.S"
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
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d17,destination,x4,general,x16,160,zero
 add x10,x9,#144
 add x10,x10,x3
 ldp d3,d4,[x10]
 add x10,x9,#2192
 add x10,x10,x3
 ldp d5,d6,[x10]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d18,destination,d16,real,x16,0,d5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d18,destination,d18,real,x16,0,d6
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d18,destination,d18,real,x16,0,d3
 ldp d1,d2,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d19,destination,d17,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d19,destination,d19,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d20,destination,d19,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d21,destination,d19,real,x16,0,d20
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d21,destination,d21,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d17,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d21,destination,d21,real,x16,0,d25
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d18,real,x16,0,d18
 ldp d3,d4,[x9,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d23,destination,d18,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d23,destination,d3,real,x16,0,d23
 ldp d3,d4,[x9,#24]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d24,destination,d18,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d24,destination,d3,real,x16,0,d24
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d22,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d24,destination,d24,real,x16,0,d25
 ldr d3,[x9,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d25,destination,d22,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d21,destination,d21,real,x16,0,d25
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d26,destination,d18,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d26,destination,d26,real,x16,0,d24
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d21,destination,d21,real,x16,0,d26
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d21,real,x16,0,d20
 ret
.Lnear_one:
 fmov d1,#1.0
 fmov x10,d1
 cmp x1,x10
 b.eq .Lexact_one
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d0,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d0,real,x16,0,d2
 ldp d24,d25,[x9,#112]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d4,destination,d0,real,x16,0,d25
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d4,destination,d24,real,x16,0,d4
 ldr d24,[x9,#128]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d2,real,x16,0,d24
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d4,destination,d4,real,x16,0,d22
 ldr d24,[x9,#136]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d3,real,x16,0,d24
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d4,destination,d4,real,x16,0,d22
 ldp d24,d25,[x9,#88]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d5,destination,d0,real,x16,0,d25
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d5,destination,d24,real,x16,0,d5
 ldr d24,[x9,#104]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d2,real,x16,0,d24
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d5,destination,d5,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d3,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d5,destination,d5,real,x16,0,d22
 ldp d24,d25,[x9,#64]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d6,destination,d0,real,x16,0,d25
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d6,destination,d24,real,x16,0,d6
 ldr d24,[x9,#80]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d2,real,x16,0,d24
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d6,destination,d6,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d3,real,x16,0,d5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d6,destination,d6,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d6,destination,d3,real,x16,0,d6
 movz x10,#0x41a0,lsl#48
 fmov d7,x10
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d7,destination,d0,real,x16,0,d7
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d16,destination,d0,real,x16,0,d7
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d16,destination,d16,real,x16,0,d7
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d17,destination,d0,real,x16,0,d16
 ldr d21,[x9,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d18,destination,d16,real,x16,0,d16
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d18,destination,d18,real,x16,0,d21
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d19,destination,d0,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d20,destination,d0,real,x16,0,d19
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d20,destination,d20,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d21,real,x16,0,d17
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d23,destination,d16,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d22,destination,d22,real,x16,0,d23
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d20,destination,d20,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d6,destination,d6,real,x16,0,d20
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d6,real,x16,0,d19
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

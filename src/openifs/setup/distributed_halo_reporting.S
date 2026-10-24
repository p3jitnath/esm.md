/* Source interfaces, bounds and source-order scope: skills/md2asm/references/openifs/radiation/live_radiation_second_interpolation.md. */
/* Unchanged accepted child; radiation forwarding scope: skills/md2asm/references/openifs/radiation/live_radiation_first_interpolation.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_write_distributed_halo_status
.type md2asm_write_distributed_halo_status,%function
md2asm_write_distributed_halo_status:
 stp x29,x30,[sp,#-128]!
 str x18,[sp,#16]
 mov x9,#1
 str x9,[sp,#32]
 str x0,[sp,#40]
 mov x9,#2
 str x9,[sp,#48]
 str x9,[sp,#56]
 add x9,x0,#1016
 str x9,[sp,#64]
 mov x9,#4
 str x9,[sp,#72]
 mov x9,#2
 str x9,[sp,#80]
 add x9,x0,#1020
 str x9,[sp,#88]
 mov x9,#4
 str x9,[sp,#96]
 mov x0,x1
 mov x1,#0
 adr x2,.Lhalo_format
 mov x3,#(.Lhalo_format_end-.Lhalo_format)
 add x4,sp,#32
 mov x5,#3
 bl .Lhalo_report_write
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#128
 ret
.size md2asm_write_distributed_halo_status,.-md2asm_write_distributed_halo_status
#include "shared_fortran_status_write.inc.S"
.section .rodata
.Lhalo_format: .ascii "(\" YDSL%CVER=\",A2,\" YDSL%NASLB1=\",I7,\" YDSL%NASLB1_TRUE=\",I7)"
.Lhalo_format_end:
.section .note.GNU-stack,"",%progbits

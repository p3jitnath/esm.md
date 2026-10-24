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
.type .Lhalo_report_write,%function
.Lhalo_report_write:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 sub sp,sp,#544
 mov x21,sp
 mov x19,x0
 mov x20,x1
 mov x22,x2
 mov x23,x3
 mov x24,x4
 mov x25,x5
 mov x9,#0
.Lhalo_statement_zero:
 add x10,x21,x9
 stp xzr,xzr,[x10]
 add x9,x9,#16
 cmp x9,#544
 b.lo .Lhalo_statement_zero
 mov w9,#32
 cbz x22,.Lhalo_statement_list
 orr w9,w9,#4096
 stp x22,x23,[x21,#80]
 b .Lhalo_statement_format_set
.Lhalo_statement_list:
 orr w9,w9,#128
.Lhalo_statement_format_set:
 cbz x20,.Lhalo_statement_external
 orr w9,w9,#16384
 stp x19,x20,[x21,#112]
 mov w10,#-1
 str w10,[x21,#4]
 b .Lhalo_statement_unit_set
.Lhalo_statement_external:
 ldr w10,[x19]
 str w10,[x21,#4]
.Lhalo_statement_unit_set:
 str w9,[x21]
 add x9,x21,#528
 str x9,[x21,#40]
 mov x0,x21
 bl _gfortran_st_write
.Lhalo_statement_item:
 cbz x25,.Lhalo_statement_done
 ldp x9,x1,[x24]
 ldr x2,[x24,#16]
 mov x0,x21
 cmp x9,#1
 b.eq .Lhalo_statement_character
 cmp x9,#4
 b.eq .Lhalo_statement_real
 bl _gfortran_transfer_integer_write
 b .Lhalo_statement_item_next
.Lhalo_statement_character:
 bl _gfortran_transfer_character_write
 b .Lhalo_statement_item_next
.Lhalo_statement_real:
 bl _gfortran_transfer_real_write
.Lhalo_statement_item_next:
 add x24,x24,#24
 sub x25,x25,#1
 b .Lhalo_statement_item
.Lhalo_statement_done:
 mov x0,x21
 bl _gfortran_st_write_done
 ldr w0,[x21,#528]
 cmp w0,#0
 cset w0,ne
 add sp,sp,#544
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.size .Lhalo_report_write,.-.Lhalo_report_write
.section .rodata
.Lhalo_format: .ascii "(\" YDSL%CVER=\",A2,\" YDSL%NASLB1=\",I7,\" YDSL%NASLB1_TRUE=\",I7)"
.Lhalo_format_end:
.section .note.GNU-stack,"",%progbits

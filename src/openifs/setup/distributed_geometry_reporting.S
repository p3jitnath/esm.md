/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */

.arch armv8.2-a
.text
.p2align 4
.global md2asm_report_distributed_local_geometry
.type md2asm_report_distributed_local_geometry,%function
// x0 Geometry, w1 source phase0/1, x2 live source output-unit address.
md2asm_report_distributed_local_geometry:
 stp x29,x30,[sp,#-176]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov x20,x2
 cbnz w1,.Ldgr_end
 mov x0,x20
 mov x1,#0
 adr x2,.Ldgr_alloc
 mov x3,#(.Ldgr_alloc_end-.Ldgr_alloc)
 mov x4,#0
 mov x5,#0
 bl .Ldg_report_write
 b .Ldgr_return
.Ldgr_end:
 mov x0,x20
 mov x1,#0
 adr x2,.Ldgr_print
 mov x3,#(.Ldgr_print_end-.Ldgr_print)
 mov x4,#0
 mov x5,#0
 bl .Ldg_report_write
 mov x9,#1
 str x9,[sp,#64]
 adr x9,.Ldgr_first_name
 str x9,[sp,#72]
 mov x9,#10
 str x9,[sp,#80]
 mov x9,#2
 str x9,[sp,#88]
 add x9,x19,#4096
 add x9,x9,#800
 str x9,[sp,#96]
 mov x9,#4
 str x9,[sp,#104]
 mov x9,#1
 str x9,[sp,#112]
 adr x9,.Ldgr_last_name
 str x9,[sp,#120]
 mov x9,#10
 str x9,[sp,#128]
 mov x9,#2
 str x9,[sp,#136]
 add x9,x19,#4096
 add x9,x9,#816
 str x9,[sp,#144]
 mov x9,#4
 str x9,[sp,#152]
 mov x0,x20
 mov x1,#0
 adr x2,.Ldgr_bounds
 mov x3,#(.Ldgr_bounds_end-.Ldgr_bounds)
 add x4,sp,#64
 mov x5,#4
 bl .Ldg_report_write
 mov x9,#2
 str x9,[sp,#64]
 add x9,x19,#4096
 add x9,x9,#3280
 str x9,[sp,#72]
 mov x9,#4
 str x9,[sp,#80]
 mov x0,x20
 mov x1,#0
 adr x2,.Ldgr_points
 mov x3,#(.Ldgr_points_end-.Ldgr_points)
 add x4,sp,#64
 mov x5,#1
 bl .Ldg_report_write
.Ldgr_return:
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#176
 ret
.size md2asm_report_distributed_local_geometry,.-md2asm_report_distributed_local_geometry
.type .Ldg_report_write,%function
.Ldg_report_write:
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
.Ldg_statement_zero:
 add x10,x21,x9
 stp xzr,xzr,[x10]
 add x9,x9,#16
 cmp x9,#544
 b.lo .Ldg_statement_zero
 mov w9,#32
 cbz x22,.Ldg_statement_list
 orr w9,w9,#4096
 stp x22,x23,[x21,#80]
 b .Ldg_statement_format_set
.Ldg_statement_list:
 orr w9,w9,#128
.Ldg_statement_format_set:
 cbz x20,.Ldg_statement_external
 orr w9,w9,#16384
 stp x19,x20,[x21,#112]
 mov w10,#-1
 str w10,[x21,#4]
 b .Ldg_statement_unit_set
.Ldg_statement_external:
 ldr w10,[x19]
 str w10,[x21,#4]
.Ldg_statement_unit_set:
 str w9,[x21]
 add x9,x21,#528
 str x9,[x21,#40]
 mov x0,x21
 bl _gfortran_st_write
.Ldg_statement_item:
 cbz x25,.Ldg_statement_done
 ldp x9,x1,[x24]
 ldr x2,[x24,#16]
 mov x0,x21
 cmp x9,#1
 b.eq .Ldg_statement_character
 cmp x9,#4
 b.eq .Ldg_statement_real
 bl _gfortran_transfer_integer_write
 b .Ldg_statement_item_next
.Ldg_statement_character:
 bl _gfortran_transfer_character_write
 b .Ldg_statement_item_next
.Ldg_statement_real:
 bl _gfortran_transfer_real_write
.Ldg_statement_item_next:
 add x24,x24,#24
 sub x25,x25,#1
 b .Ldg_statement_item
.Ldg_statement_done:
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
.size .Ldg_report_write,.-.Ldg_report_write

.section .rodata
.Ldgr_alloc: .ascii "(' Allocations in SUGEM3:')"
.Ldgr_alloc_end:
.Ldgr_print: .ascii "(' Printings in SUGEM3:')"
.Ldgr_print_end:
.Ldgr_bounds: .ascii "(2X,A,I5,A,I5)"
.Ldgr_bounds_end:
.Ldgr_points: .ascii "(' NGPTOT =',I9)"
.Ldgr_points_end:
.Ldgr_first_name: .ascii " NDGSAH = "
.Ldgr_last_name: .ascii " NDGENH = "
.section .note.GNU-stack,"",%progbits

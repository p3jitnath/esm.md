/* Same ten arguments as live point setup; assembly owns the next free. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_live_radiation_setup_through_zmu_retirement
.type md2asm_create_live_radiation_setup_through_zmu_retirement,%function
md2asm_create_live_radiation_setup_through_zmu_retirement:
 sub sp,sp,#64
 stp x29,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x4
 mov x20,x5
 ldp x9,x10,[sp,#64]
 stp x9,x10,[sp]
 bl md2asm_create_live_radiation_point_setup
 cbnz w0,.Lretire_parent_return
 mov x0,x19
 mov x1,x20
 bl md2asm_retire_live_radiation_zmu
 cbnz w0,.Lretire_parent_abort
.Lretire_parent_return:
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#32]
 ldp x29,x30,[sp,#16]
 add sp,sp,#64
 ret
.Lretire_parent_abort:
 bl abort
 brk #0
.size md2asm_create_live_radiation_setup_through_zmu_retirement,.-md2asm_create_live_radiation_setup_through_zmu_retirement
.section .note.GNU-stack,"",%progbits

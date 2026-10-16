/* Complete SUSRTAB/SUSRTAER/SUSRTCOP composition in genuine call order.
 * x0=three u64 address/capacity pairs. All fields are owned FP64 storage.
 * Return 0 complete,2 unsupported before writes. No allocation.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_shortwave_auxiliary_parameters
.type md2asm_initialize_selected_shortwave_auxiliary_parameters,%function
md2asm_initialize_selected_shortwave_auxiliary_parameters:
 cbz x0,.Lsw_bad
 tst x0,#7
 b.ne .Lsw_bad
 adds x9,x0,#48
 b.cs .Lsw_bad
 mrs x10,fpcr
 cbnz x10,.Lsw_bad
 adrp x11,.Lsw_sizes
 add x11,x11,:lo12:.Lsw_sizes
 mov x10,#0
.Lsw_check_view:
 add x17,x0,x10
 ldp x12,x13,[x17]
 lsr x17,x10,#1
 ldr x14,[x11,x17]
 cmp x13,x14
 b.lo .Lsw_bad
 cbz x12,.Lsw_bad
 tst x12,#7
 b.ne .Lsw_bad
 adds x13,x12,x14
 b.cs .Lsw_bad
 cmp x12,x9
 b.hs .Lsw_check_peer
 cmp x0,x13
 b.lo .Lsw_bad
.Lsw_check_peer:
 add x14,x10,#16
.Lsw_peer:
 cmp x14,#48
 b.hs .Lsw_next_view
 ldr x15,[x0,x14]
 lsr x17,x14,#1
 ldr x16,[x11,x17]
 adds x16,x15,x16
 b.cs .Lsw_bad
 cmp x12,x16
 b.hs .Lsw_next_peer
 cmp x15,x13
 b.lo .Lsw_bad
.Lsw_next_peer:
 add x14,x14,#16
 b .Lsw_peer
.Lsw_next_view:
 add x10,x10,#16
 cmp x10,#48
 b.lo .Lsw_check_view
 stp x29,x30,[sp,#-48]!
 mov x29,sp
 stp x19,x18,[sp,#16]
 mov x19,x0
 ldr x0,[x19]
 bl md2asm_shortwave_transmission_table_fields
 ldr x0,[x19,#16]
 bl md2asm_shortwave_aerosol_optical_fields
 ldr x0,[x19,#32]
 bl md2asm_shortwave_cloud_optical_fields
 mov w0,#0
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.Lsw_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_shortwave_auxiliary_parameters,.-md2asm_initialize_selected_shortwave_auxiliary_parameters
.p2align 4
.global md2asm_initialize_owned_shortwave_auxiliary_parameters
.type md2asm_initialize_owned_shortwave_auxiliary_parameters,%function
md2asm_initialize_owned_shortwave_auxiliary_parameters:
 stp x29,x30,[sp,#-80]!
 mov x29,sp
 str x18,[sp,#16]
 adrp x9,:got:md2asm_owned_shortwave_auxiliary_namespace
 ldr x9,[x9,:got_lo12:md2asm_owned_shortwave_auxiliary_namespace]
 movz x10,#0x38a0
 movk x10,#1,lsl #16
 stp x9,x10,[sp,#32]
 add x9,x9,x10
 mov x10,#2016
 stp x9,x10,[sp,#48]
 add x9,x9,x10
 mov x10,#4704
 stp x9,x10,[sp,#64]
 add x0,sp,#32
 bl md2asm_initialize_selected_shortwave_auxiliary_parameters
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.size md2asm_initialize_owned_shortwave_auxiliary_parameters,.-md2asm_initialize_owned_shortwave_auxiliary_parameters
.section .rodata
.p2align 3
.Lsw_sizes:.quad 80032,2016,4704
.section .note.GNU-stack,"",%progbits

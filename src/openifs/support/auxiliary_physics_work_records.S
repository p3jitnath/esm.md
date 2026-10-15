// Contract: skills/md2asm/references/openifs/support/auxiliary_physics_work_records.md.
/* AUX_TYPE source-scoped storage services. No weather values are calculated. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_auxiliary_work_record
.type md2asm_initialize_auxiliary_work_record,%function
md2asm_initialize_auxiliary_work_record:
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov w24,w3
 mov w25,w4
 str xzr,[x19,#1848]
 str xzr,[x19,#1856]
 str xzr,[x19,#1864]
 str xzr,[x19,#1912]
 str xzr,[x19,#1944]
 str xzr,[x19,#1936]
 str xzr,[x19,#1968]
 str xzr,[x19,#1920]
 str xzr,[x19,#1952]
 str xzr,[x19,#1928]
 str xzr,[x19,#1976]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 adrp x22,.Laux_borrowed
 add x22,x22,:lo12:.Laux_borrowed
 mov w23,#10
.Laux_borrow:
 ldp w9,w10,[x22],#8
 ldr x11,[x21,w10,uxtw]
 str x11,[x19,w9,uxtw]
 subs w23,w23,#1
 b.ne .Laux_borrow
 adrp x22,.Laux_owned
 add x22,x22,:lo12:.Laux_owned
 mov w23,#11
.Laux_create:
 ldp w9,w26,[x22]
 ldr w27,[x22,#8]
 mov x0,#72
 madd x0,x26,x0,xzr
 add x0,x0,#112
 bl malloc
 cbz x0,.Laux_init_failed
 mov x28,x0
 ldr w9,[x20,#5144]
 ldr w10,[x20,#5160]
 mov w11,#1
 cmp w25,#0
 csel w10,w10,w11,ne
 str w9,[sp,#160]
 cmp w26,#2
 b.eq .Laux_shape2
 add w9,w24,w27
 stp w9,w10,[sp,#164]
 b .Laux_shape_ready
.Laux_shape2:
 str w10,[sp,#164]
.Laux_shape_ready:
 mov x0,x28
 add x1,sp,#160
 mov w2,w26
 eor w3,w25,#1
 bl md2asm_registry_allocate_field
 cbnz w0,.Laux_data_failed
 ldr w9,[x22]
 str x28,[x19,w9,uxtw]
 add x22,x22,#12
 subs w23,w23,#1
 b.ne .Laux_create
 mov w28,#0
 b .Laux_init_return
.Laux_data_failed:
 mov x0,x28
 bl free
.Laux_init_failed:
 mov x0,x19
 bl md2asm_finalize_auxiliary_work_record
 mov w28,#1
.Laux_init_return:
 mov w0,w28
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.size md2asm_initialize_auxiliary_work_record,.-md2asm_initialize_auxiliary_work_record
.global md2asm_update_auxiliary_work_views
.type md2asm_update_auxiliary_work_views,%function
md2asm_update_auxiliary_work_views:
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov w20,w1
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 adrp x21,.Laux_views
 add x21,x21,:lo12:.Laux_views
 mov w22,#21
.Laux_view:
 ldp w23,w9,[x21]
 ldp w24,w25,[x21,#8]
 add x0,x19,w23,uxtw
 ldr x1,[x19,w9,uxtw]
 mov w2,w20
 cmp w24,#2
 b.eq .Laux_view2
 bl md2asm_physics_field_view_3d
 b .Laux_view_ready
.Laux_view2:
 bl md2asm_physics_field_view_2d
.Laux_view_ready:
 cbz w25,.Laux_view_next
 add x9,x19,w23,uxtw
 ldr x10,[x9,#64]
 ldr x11,[x9,#8]
 add x11,x11,x10
 str x11,[x9,#8]
 str xzr,[x9,#72]
 ldr x10,[x9,#80]
 sub x10,x10,#1
 str x10,[x9,#80]
.Laux_view_next:
 add x21,x21,#16
 subs w22,w22,#1
 b.ne .Laux_view
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.size md2asm_update_auxiliary_work_views,.-md2asm_update_auxiliary_work_views
.global md2asm_finalize_auxiliary_work_record
.type md2asm_finalize_auxiliary_work_record,%function
md2asm_finalize_auxiliary_work_record:
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 adrp x20,.Laux_owned
 add x20,x20,:lo12:.Laux_owned
 mov w21,#11
.Laux_delete:
 ldp w22,w23,[x20]
 ldr x24,[x19,w22,uxtw]
 cbz x24,.Laux_delete_next
 mov x9,#48
 madd x9,x23,x9,x24
 ldr x0,[x9,#56]
 cbz x0,.Laux_delete_meta
 bl free
.Laux_delete_meta:
 mov x0,x24
 bl free
 str xzr,[x19,w22,uxtw]
.Laux_delete_next:
 add x20,x20,#12
 subs w21,w21,#1
 b.ne .Laux_delete
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.size md2asm_finalize_auxiliary_work_record,.-md2asm_finalize_auxiliary_work_record
.global __ecphys_aux_type_mod_MOD_aux_type_init
.type __ecphys_aux_type_mod_MOD_aux_type_init,%function
__ecphys_aux_type_mod_MOD_aux_type_init:
 adrp x9,md2asm_auxiliary_work_record_native_counters
 add x9,x9,:lo12:md2asm_auxiliary_work_record_native_counters
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldr x0,[x0]
 ldr x1,[x1]
 ldr w3,[x3]
 cbz x4,.Laux_native_default
 ldr w4,[x4]
 b .Laux_native_call
.Laux_native_default:
 mov w4,#0
.Laux_native_call:
 stp x29,x30,[sp,#-32]!
 stp x18,x19,[sp,#16]
 bl md2asm_initialize_auxiliary_work_record
 cbnz w0,.Laux_native_abort
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Laux_native_abort:
 bl abort
.size __ecphys_aux_type_mod_MOD_aux_type_init,.-__ecphys_aux_type_mod_MOD_aux_type_init
.global __ecphys_aux_type_mod_MOD_aux_type_update_view
.type __ecphys_aux_type_mod_MOD_aux_type_update_view,%function
__ecphys_aux_type_mod_MOD_aux_type_update_view:
 adrp x9,md2asm_auxiliary_work_record_native_counters
 add x9,x9,:lo12:md2asm_auxiliary_work_record_native_counters
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldr x0,[x0]
 ldr w1,[x1]
 b md2asm_update_auxiliary_work_views
.size __ecphys_aux_type_mod_MOD_aux_type_update_view,.-__ecphys_aux_type_mod_MOD_aux_type_update_view
.global __ecphys_aux_type_mod_MOD_aux_type_final
.type __ecphys_aux_type_mod_MOD_aux_type_final,%function
__ecphys_aux_type_mod_MOD_aux_type_final:
 adrp x9,md2asm_auxiliary_work_record_native_counters
 add x9,x9,:lo12:md2asm_auxiliary_work_record_native_counters
 ldr x10,[x9,#16]
 add x10,x10,#1
 str x10,[x9,#16]
 ldr x0,[x0]
 b md2asm_finalize_auxiliary_work_record
.size __ecphys_aux_type_mod_MOD_aux_type_final,.-__ecphys_aux_type_mod_MOD_aux_type_final
.section .rodata
.p2align 3
.Laux_borrowed:
 .word 1808,45656
 .word 1816,46216
 .word 1824,52936
 .word 1832,46776
 .word 1840,47336
 .word 1872,44536
 .word 1880,53496
 .word 1888,50136
 .word 1896,50696
 .word 1904,45096
.Laux_owned:
 .word 1848,2,0
 .word 1856,2,0
 .word 1864,2,0
 .word 1912,3,1
 .word 1944,3,1
 .word 1936,3,1
 .word 1968,3,1
 .word 1920,3,0
 .word 1952,3,0
 .word 1928,3,0
 .word 1976,3,0
.Laux_views:
 .word 976,1808,2,0
 .word 1040,1816,2,0
 .word 1104,1824,2,0
 .word 1168,1832,2,0
 .word 1232,1840,2,0
 .word 1488,1872,2,0
 .word 1552,1880,2,0
 .word 1616,1888,2,0
 .word 1680,1896,2,0
 .word 1744,1904,2,0
 .word 1296,1848,2,0
 .word 1360,1856,2,0
 .word 1424,1864,2,0
 .word 8,1912,3,1
 .word 360,1944,3,1
 .word 272,1936,3,1
 .word 624,1968,3,1
 .word 96,1920,3,0
 .word 448,1952,3,0
 .word 184,1928,3,0
 .word 712,1976,3,0
.data
.p2align 3
.global md2asm_auxiliary_work_record_native_counters
.type md2asm_auxiliary_work_record_native_counters,%object
md2asm_auxiliary_work_record_native_counters:
 .quad 0,0,0
.size md2asm_auxiliary_work_record_native_counters,24
.section .note.GNU-stack,"",%progbits

// Solver contract skills/md2asm/references/openifs/support/physics_context_block_services.md.
// Selected context work view composition. Contract: skills/md2asm/references/openifs/support/physics_context_block_services.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_physics_storage_work_views
.type md2asm_physics_storage_work_views,%function
md2asm_physics_storage_work_views:
 adrp x9,md2asm_block_context_native_counters
 add x9,x9,:lo12:md2asm_block_context_native_counters
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
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
 mov w22,w1
 mov w23,w2
 mov w24,w3
 movz x9,#0
 add x9,x19,x9
 ldr x20,[x9]
 movz x9,#7192
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x21,[x9]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 movz x0,#8472
 add x0,x20,x0
 mov w1,w22
 mov w2,#1
 bl md2asm_context_block_address
 movz x4,#1344
 add x4,x0,x4
 movz x0,#17216
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 mov w2,w23
 mov w3,w24
 bl md2asm_update_physics_dimensions
 movz x0,#17408
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_update_surface_work_views
 movz x0,#31088
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_update_auxiliary_work_views
 movz x0,#33080
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_update_radiation_work_views
 stp w22,w24,[sp,#136]
 stp w23,wzr,[sp,#144]
 movz x9,#5144
 add x9,x20,x9
 ldr w9,[x9]
 str w9,[sp,#148]
 movz x9,#5224
 add x9,x20,x9
 ldr w9,[x9]
 str w9,[sp,#152]
 adrp x9,:got:__yomlcz_MOD_gpforceu
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforceu]
 str x9,[sp,#160]
 adrp x9,:got:__yomlcz_MOD_gpforcev
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforcev]
 str x9,[sp,#168]
 adrp x9,:got:__yomlcz_MOD_gpforcet
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforcet]
 str x9,[sp,#176]
 adrp x9,:got:__yomlcz_MOD_gpforceq
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforceq]
 str x9,[sp,#184]
 movz x0,#51256
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov x1,x21
 movz x2,#62936
 movk x2,#62,lsl #16
 add x2,x21,x2
 add x3,sp,#136
 add x4,sp,#160
 bl md2asm_update_perturbation_views
 cbnz w0,.Lwork_abort
 movz x0,#35744
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_flux_type_update_view
 movz x0,#40808
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_aux_diag_type_update_view
 movz x0,#44912
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_ddh_surf_type_update_view
 movz x0,#45824
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_aux_diag_local_type_update_view
 movz x0,#48160
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_surf_and_more_local_type_update_view
 movz x0,#50256
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov w1,w22
 bl md2asm_keys_local_type_update_view
 movz x0,#50920
 movk x0,#1,lsl #16
 add x0,x19,x0
 movz x9,#51224
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 mov w2,w22
 bl md2asm_physics_field_view_2d
 movz x0,#50984
 movk x0,#1,lsl #16
 add x0,x19,x0
 movz x9,#51240
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 mov w2,w22
 bl md2asm_physics_field_view_3d
 movz x0,#51072
 movk x0,#1,lsl #16
 add x0,x19,x0
 movz x9,#51232
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 mov w2,w22
 bl md2asm_physics_field_view_2d
 movz x0,#51136
 movk x0,#1,lsl #16
 add x0,x19,x0
 movz x9,#51248
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 mov w2,w22
 bl md2asm_physics_field_view_3d
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
.Lwork_abort:
 bl abort
.size md2asm_physics_storage_work_views,.-md2asm_physics_storage_work_views
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/support/runtime_self_owned_physics_work.md. Direct EC_PHYS work-owner parent.
 * create(x0 context80,x1 capacity,x2 owner_slot8):0 complete,1 allocation failure,
 * 2 pre-write refusal. update(x0 owner15608,w1 block0):0 complete,2 refusal.
 * release(x0 owner_slot8):0 released/null,2 invalid top-level owner.
 * All declared complete spans are mapped and aligned8. Borrowed owners stay live.
 * Source order and exact arithmetic remain in the unchanged raw children.
 * Each public entry has a256B frame when it calls a service; helper frame16B.
 * Preserve x18..x30,d8..d15,FPCR,FPSR,errno and aligned SP.
 */
.arch armv8.2-a
.text
.p2align 4
.macro SAVE_FRAME
 sub sp,sp,#256
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
.endm
.macro RESTORE_FRAME
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.endm
.macro SAVE_ERRNO
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
.endm
.macro RESTORE_STATUS
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
.endm
.global md2asm_create_runtime_self_owned_physics_work
.type md2asm_create_runtime_self_owned_physics_work,%function
md2asm_create_runtime_self_owned_physics_work:
 mrs x9,fpcr
 cbnz x9,.Lwork_bad
 cbz x0,.Lwork_bad
 cbz x2,.Lwork_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lwork_bad
 cmp x1,#80
 b.lo .Lwork_bad
 adds x9,x0,#80
 b.cs .Lwork_bad
 adds x10,x2,#8
 b.cs .Lwork_bad
 cmp x0,x10
 b.hs .Lwork_table_separate
 cmp x2,x9
 b.lo .Lwork_bad
.Lwork_table_separate:
 SAVE_FRAME
 mov x19,x0
 mov x20,x2
 /* Validate all complete capacities and table/output separation first. */
 adrp x15,.Lwork_input_sizes
 add x15,x15,:lo12:.Lwork_input_sizes
 mov x14,x19
 mov w16,#5
.Lwork_input_span:
 ldp x6,x7,[x14],#16
 ldr x13,[x15],#8
 cbz x6,.Lcreate_bad_early
 tst x6,#7
 b.ne .Lcreate_bad_early
 cmp x7,x13
 b.lo .Lcreate_bad_early
 adds x8,x6,x13
 b.cs .Lcreate_bad_early
 cmp x6,x9
 b.hs .Lwork_input_table_separate
 cmp x19,x8
 b.lo .Lcreate_bad_early
.Lwork_input_table_separate:
 cmp x6,x10
 b.hs .Lwork_input_slot_separate
 cmp x20,x8
 b.lo .Lcreate_bad_early
.Lwork_input_slot_separate:
 subs w16,w16,#1
 b.ne .Lwork_input_span
 ldr x9,[x20]
 cbnz x9,.Lcreate_bad_early
 ldr x21,[x19]
 ldr x22,[x19,#16]
 ldr x23,[x19,#32]
 ldr x24,[x19,#48]
 ldr x25,[x19,#64]
 add x0,sp,#144
 mov x1,x21
 mov x2,x22
 mov x3,x23
 mov x4,x24
 mov x5,x25
 bl md2asm_bind_runtime_physics_work_shape_counts
 cbnz w0,.Lcreate_bad_early
 /* Bounds avoid signed extent addition overflow in unchanged raw children. */
 ldr w9,[x21,#5144]
 sub w9,w9,#1
 cmp w9,#1023
 b.hi .Lcreate_bad_early
 ldr w9,[sp,#144]
 cbz w9,.Lcreate_bad_early
 add x10,sp,#144
 mov w11,#8
.Lwork_shape_bounds:
 ldr w9,[x10],#4
 cmp w9,#512
 b.hi .Lcreate_bad_early
 subs w11,w11,#1
 b.ne .Lwork_shape_bounds
 /* DDH reads only these nonnegative dimension extents and class counts. */
 ldr w9,[x24,#56]
 cmp w9,#512
 b.hi .Lcreate_bad_early
 add x10,x24,#68
 mov w11,#14
.Lwork_class_bounds:
 ldr w9,[x10],#4
 cmp w9,#512
 b.hi .Lcreate_bad_early
 subs w11,w11,#1
 b.ne .Lwork_class_bounds
 ldr w9,[x24,#12]
 ldr w10,[x21,#5144]
 cmp w9,w10
 b.ne .Lcreate_bad_early
 ldr w11,[x21,#7376]
 cmp w11,#0
 b.le .Lcreate_bad_early
 sub w11,w11,#1
 udiv w11,w11,w10
 add w11,w11,#1
 ldr w12,[x21,#5160]
 cmp w11,w12
 b.ne .Lcreate_bad_early
 SAVE_ERRNO
 bl __oml_mod_MOD_oml_max_threads
 cmp w0,#1
 b.ne .Lcreate_bad_status
 mov x0,#1
 mov x1,#15608
 bl calloc
 cbz x0,.Lcreate_failed_outer
 mov x26,x0
 movz w9,#0x4b31
 movk w9,#0x5752,lsl#16
 str x9,[x26]
 stp x21,x22,[x26,#8]
 stp x23,x24,[x26,#24]
 str x25,[x26,#40]
 ldp x9,x10,[sp,#144]
 ldp x11,x12,[sp,#160]
 stp x9,x10,[x26,#64]
 stp x11,x12,[x26,#80]
 /* Source constructor1: FLUX_TYPE. */
 mov w9,#1
 str x9,[x26,#48]
 mov x0,#96
 add x0,x26,x0
 mov x1,x21
 add x2,x26,#64
 mov w3,#0
 bl md2asm_flux_type_init
 cbnz w0,.Lcreate_failed_child
 /* Source constructor2: AUX_DIAG_TYPE. */
 mov w9,#2
 str x9,[x26,#48]
 mov x0,#5160
 add x0,x26,x0
 mov x1,x21
 add x2,x26,#64
 mov w3,#0
 bl md2asm_aux_diag_type_init
 cbnz w0,.Lcreate_failed_child
 /* Source constructor3: DDH_SURF_TYPE. */
 mov w9,#3
 str x9,[x26,#48]
 mov x0,#9264
 add x0,x26,x0
 mov x1,x21
 mov x2,x24
 mov w3,#0
 bl md2asm_ddh_surf_type_init
 cbnz w0,.Lcreate_failed_child
 /* Source constructor4: AUX_DIAG_LOCAL_TYPE. */
 mov w9,#4
 str x9,[x26,#48]
 mov x0,#10176
 add x0,x26,x0
 mov x1,x21
 add x2,x26,#64
 mov w3,#0
 bl md2asm_aux_diag_local_type_init
 cbnz w0,.Lcreate_failed_child
 /* Source constructor5: SURF_AND_MORE_LOCAL_TYPE. */
 mov w9,#5
 str x9,[x26,#48]
 mov x0,#12512
 add x0,x26,x0
 mov x1,x21
 add x2,x26,#80
 mov w3,#0
 bl md2asm_surf_and_more_local_type_init
 cbnz w0,.Lcreate_failed_child
 /* Source constructor6: KEYS_LOCAL_TYPE. */
 mov w9,#6
 str x9,[x26,#48]
 mov x0,#14608
 add x0,x26,x0
 mov x1,x21
 mov x2,xzr
 mov w3,#0
 bl md2asm_keys_local_type_init
 cbnz w0,.Lcreate_failed_child
 /* Source constructor7: PERTURB_LOCAL_TYPE. */
 mov w9,#7
 str x9,[x26,#48]
 mov x0,#15272
 add x0,x26,x0
 mov x1,x21
 add x2,x26,#64
 mov w3,#0
 bl md2asm_perturb_local_type_init
 cbnz w0,.Lcreate_failed_child
 str x26,[x20]
 mov w27,#0
 b .Lcreate_return_status
.Lcreate_failed_child:
 mov x19,x26
 bl .Lwork_finalize_prefix
 str xzr,[x26]
 mov x0,x26
 bl free
.Lcreate_failed_outer:
 mov w27,#1
 b .Lcreate_return_status
.Lcreate_bad_status:
 mov w27,#2
.Lcreate_return_status:
 RESTORE_STATUS
 mov w0,w27
 RESTORE_FRAME
.Lcreate_bad_early:
 mov w0,#2
 RESTORE_FRAME
.size md2asm_create_runtime_self_owned_physics_work,.-md2asm_create_runtime_self_owned_physics_work
.p2align 4
.global md2asm_update_runtime_self_owned_physics_work
.type md2asm_update_runtime_self_owned_physics_work,%function
md2asm_update_runtime_self_owned_physics_work:
 mrs x9,fpcr
 cbnz x9,.Lwork_bad
 cbz x0,.Lwork_bad
 tst x0,#7
 b.ne .Lwork_bad
 mov x9,#15608
 adds x9,x0,x9
 b.cs .Lwork_bad
 ldr x10,[x0]
 movz w11,#0x4b31
 movk w11,#0x5752,lsl#16
 cmp x10,x11
 b.ne .Lwork_bad
 ldr x10,[x0,#48]
 cmp x10,#7
 b.ne .Lwork_bad
 SAVE_FRAME
 mov x19,x0
 mov w20,w1
 ldr x0,[x19,#32]
 ldr x1,[x19,#8]
 mov w2,w20
 bl md2asm_update_runtime_physics_dimensions
 cbnz w0,.Lwork_update_return
 add w20,w20,#1
 mov x0,#96
 add x0,x19,x0
 mov w1,w20
 bl md2asm_flux_type_update_view
 mov x0,#5160
 add x0,x19,x0
 mov w1,w20
 bl md2asm_aux_diag_type_update_view
 mov x0,#9264
 add x0,x19,x0
 mov w1,w20
 bl md2asm_ddh_surf_type_update_view
 mov x0,#10176
 add x0,x19,x0
 mov w1,w20
 bl md2asm_aux_diag_local_type_update_view
 mov x0,#12512
 add x0,x19,x0
 mov w1,w20
 bl md2asm_surf_and_more_local_type_update_view
 mov x0,#14608
 add x0,x19,x0
 mov w1,w20
 bl md2asm_keys_local_type_update_view
 mov x0,#15272
 add x0,x19,x0
 mov w1,w20
 bl md2asm_perturb_local_type_update_view
 mov w0,#0
.Lwork_update_return:
 RESTORE_FRAME
.size md2asm_update_runtime_self_owned_physics_work,.-md2asm_update_runtime_self_owned_physics_work
.p2align 4
.global md2asm_release_runtime_self_owned_physics_work
.type md2asm_release_runtime_self_owned_physics_work,%function
md2asm_release_runtime_self_owned_physics_work:
 cbz x0,.Lwork_bad
 tst x0,#7
 b.ne .Lwork_bad
 adds x9,x0,#8
 b.cs .Lwork_bad
 ldr x1,[x0]
 cbz x1,.Lwork_ok
 tst x1,#7
 b.ne .Lwork_bad
 mov x10,#15608
 adds x10,x1,x10
 b.cs .Lwork_bad
 cmp x0,x10
 b.hs .Lrelease_slot_separate
 cmp x1,x9
 b.lo .Lwork_bad
.Lrelease_slot_separate:
 ldr x10,[x1]
 movz w11,#0x4b31
 movk w11,#0x5752,lsl#16
 cmp x10,x11
 b.ne .Lwork_bad
 ldr x10,[x1,#48]
 cmp x10,#7
 b.ne .Lwork_bad
 SAVE_FRAME
 mov x19,x1
 mov x20,x0
 SAVE_ERRNO
 bl .Lwork_finalize_prefix
 str xzr,[x19]
 mov x0,x19
 bl free
 str xzr,[x20]
 RESTORE_STATUS
 mov w0,#0
 RESTORE_FRAME
.size md2asm_release_runtime_self_owned_physics_work,.-md2asm_release_runtime_self_owned_physics_work
/* x19 names the unpublished or live owner; raw children preserve it. */
.p2align 4
.Lwork_finalize_prefix:
 stp x29,x30,[sp,#-16]!
 mov x29,sp
 ldr x9,[x19,#48]
 cmp x9,#1
 b.lo .Lwork_final_done
 mov x0,#96
 add x0,x19,x0
 bl md2asm_flux_type_final
 ldr x9,[x19,#48]
 cmp x9,#2
 b.lo .Lwork_final_done
 mov x0,#5160
 add x0,x19,x0
 bl md2asm_aux_diag_type_final
 ldr x9,[x19,#48]
 cmp x9,#3
 b.lo .Lwork_final_done
 mov x0,#9264
 add x0,x19,x0
 bl md2asm_ddh_surf_type_final
 ldr x9,[x19,#48]
 cmp x9,#4
 b.lo .Lwork_final_done
 mov x0,#10176
 add x0,x19,x0
 bl md2asm_aux_diag_local_type_final
 ldr x9,[x19,#48]
 cmp x9,#5
 b.lo .Lwork_final_done
 mov x0,#12512
 add x0,x19,x0
 bl md2asm_surf_and_more_local_type_final
 ldr x9,[x19,#48]
 cmp x9,#6
 b.lo .Lwork_final_done
 mov x0,#14608
 add x0,x19,x0
 bl md2asm_keys_local_type_final
 ldr x9,[x19,#48]
 cmp x9,#7
 b.lo .Lwork_final_done
 mov x0,#15272
 add x0,x19,x0
 bl md2asm_perturb_local_type_final
.Lwork_final_done:
 str xzr,[x19,#48]
 ldp x29,x30,[sp],#16
 ret
.Lwork_bad:
 mov w0,#2
 ret
.Lwork_ok:
 mov w0,#0
 ret
.section .rodata
.p2align 3
.Lwork_input_sizes:
 .quad 20400,4275088,18224,192,67616
.section .note.GNU-stack,"",%progbits

// Solver contract skills/md2asm/references/openifs/support/physics_context_construction.md.
// Physics context construction and release from temporary_storage_services.F90.
// Contract skills/md2asm/references/openifs/support/physics_context_construction.md. No forecast calculation.
// INIT x0 pointer table[53], x1 scratch pointers[4], returns the owned context.
// FINISH x0 complete live context after the last balanced block end.
.arch armv8.2-a
.text
.p2align 4
.macro context_address dst,base,offset
 movz x16,#(\offset&65535)
 movk x16,#((\offset>>16)&65535),lsl#16
 add \dst,\base,x16
.endm
.macro context_load_word dst,base,offset
 movz x16,#(\offset&65535)
 movk x16,#((\offset>>16)&65535),lsl#16
 ldr \dst,[\base,x16]
.endm
.macro context_enter
 sub sp,sp,#320
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
.macro context_save_error
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
.endm
.macro context_count index
 adrp x9,.Lcontext_lifetime_counts
 add x9,x9,:lo12:.Lcontext_lifetime_counts
 ldr x10,[x9,#(8*\index)]
 add x10,x10,#1
 str x10,[x9,#(8*\index)]
.endm
.macro context_return
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#320
 ret
.endm
.global md2asm_physics_storage_initialise
.type md2asm_physics_storage_initialise,%function
md2asm_physics_storage_initialise:
 context_enter
 mov x20,x0
 str x1,[sp,#136]
 context_save_error
 mov x0,#1
 movz x1,#(119384&65535)
 movk x1,#(119384>>16),lsl#16
 bl calloc
 cbz x0,.Lcontext_allocation_failure
 mov x19,x0
 ldp x21,x9,[x20]
 stp x21,x9,[x19]
 ldr x22,[x20,#40]
 context_address x9,x19,72728
 str x22,[x9]
 ldp x9,x23,[x20,#24]
 context_address x10,x19,72712
 stp x9,x23,[x10]
 add x24,x19,#16
 mov x0,x24
 ldr x1,[x20,#16]
 movz x2,#(72696&65535)
 movk x2,#(72696>>16),lsl#16
 bl memcpy
 context_address x0,x19,118768
 mov x1,x20
 mov x2,#424
 bl memcpy
 context_address x0,x19,119192
 ldr x1,[sp,#136]
 mov x2,#32
 bl memcpy
 // Intrinsic assignment gives this context separate allocated global records.
 adrp x25,.Lcontext_global_offsets
 add x25,x25,:lo12:.Lcontext_global_offsets
 mov w26,#18
.Lcontext_clone_global:
 ldr w9,[x25],#4
 add x28,x24,w9,uxtw
 ldr x27,[x28]
 cbz x27,.Lcontext_allocation_failure
 ldp x9,x10,[x28,#48]
 sub x10,x10,x9
 add x10,x10,#1
 mov x9,#728
 mul x10,x10,x9
 str x10,[sp,#280]
 cmp x10,#0
 mov x0,#1
 csel x0,x10,x0,gt
 bl malloc
 cbz x0,.Lcontext_allocation_failure
 str x0,[x28]
 mov x1,x27
 ldr x2,[sp,#280]
 bl memcpy
 subs w26,w26,#1
 b.ne .Lcontext_clone_global
 // Copy named LACTIVE flags into the declared eight-word field mask.
 adrp x25,.Lcontext_mask_sources
 add x25,x25,:lo12:.Lcontext_mask_sources
 context_address x26,x19,82720
 mov w27,#8
.Lcontext_copy_mask:
 ldr w9,[x25],#4
 ldr w10,[x24,w9,uxtw]
 str w10,[x26],#4
 subs w27,w27,#1
 b.ne .Lcontext_copy_mask
 // The first two states borrow previous-time and next-time field records.
 mov w27,#0
 context_address x28,x19,72736
.Lcontext_borrow_state:
 adrp x25,.Lcontext_state_variables
 add x25,x25,:lo12:.Lcontext_state_variables
 add x26,sp,#144
 mov w12,#11
 cbnz w27,.Lcontext_state_next_fields
 mov w13,#704
 b .Lcontext_state_fields
.Lcontext_state_next_fields:
 mov w13,#688
.Lcontext_state_fields:
 ldr w9,[x25],#4
 add w9,w9,w13
 ldr x10,[x24,w9,uxtw]
 str x10,[x26],#8
 subs w12,w12,#1
 b.ne .Lcontext_state_fields
 mov x0,x28
 mov x1,x21
 add x2,sp,#144
 context_address x3,x19,82720
 mov w4,#2047
 mov w5,#0
 bl md2asm_initialise_physics_state
 cbnz w0,.Lcontext_allocation_failure
 add x28,x28,#1240
 add w27,w27,#1
 cmp w27,#2
 b.ne .Lcontext_borrow_state
 mov w27,#6
.Lcontext_new_state:
 mov x0,x28
 mov x1,x21
 add x2,sp,#144
 context_address x3,x19,82720
 mov w4,#0
 mov w5,#0
 bl md2asm_initialise_physics_state
 cbnz w0,.Lcontext_allocation_failure
 add x28,x28,#1240
 subs w27,w27,#1
 b.ne .Lcontext_new_state
 // The zero-length PHY owner still has a distinct allocation address.
 mov x0,#1
 bl malloc
 cbz x0,.Lcontext_allocation_failure
 context_address x9,x19,82656
 str x0,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#1240
 str x10,[x9,#16]
 str x10,[x9,#32]
 mov w10,#1281
 strh w10,[x9,#28]
 mov x10,#1
 stp x10,x10,[x9,#40]
 context_address x0,x19,82752
 mov x1,x21
 mov x2,x22
 mov x3,x23
 bl md2asm_initialise_physics_dimensions
 // Surface levels in source order soil, snow, ocean.
 ldr w9,[x23,#5888]
 str w9,[sp,#232]
 context_load_word w9,x22,1577392
 str w9,[sp,#236]
 ldr w9,[x23,#7344]
 str w9,[sp,#240]
 context_address x0,x19,82944
 mov x1,x21
 mov x2,x24
 ldr x3,[x20,#8]
 context_address x16,x3,529280
 ldr x3,[x16]
 add x4,sp,#232
 mov w5,#0
 bl md2asm_initialize_surface_work_record
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,96624
 mov x1,x21
 mov x2,x24
 ldr w3,[x21,#5224]
 mov w4,#0
 bl md2asm_initialize_auxiliary_work_record
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,98616
 mov x1,x21
 mov x2,x24
 ldr w3,[x21,#5224]
 mov w4,#0
 bl md2asm_initialize_radiation_work_record
 cbnz w0,.Lcontext_allocation_failure
 ldr w9,[x21,#5224]
 str w9,[sp,#248]
 ldr w9,[sp,#232]
 str w9,[sp,#252]
 ldr w9,[x22,#304]
 str w9,[sp,#256]
 mov w9,#8
 str w9,[sp,#260]
 context_address x0,x19,101280
 mov x1,x21
 add x2,sp,#248
 mov w3,#0
 bl md2asm_flux_type_init
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,106344
 mov x1,x21
 context_address x2,x21,5224
 mov w3,#0
 bl md2asm_aux_diag_type_init
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,110448
 mov x1,x21
 context_address x2,x19,82752
 mov w3,#0
 bl md2asm_ddh_surf_type_init
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,111360
 mov x1,x21
 context_address x2,x21,5224
 mov w3,#0
 bl md2asm_aux_diag_local_type_init
 cbnz w0,.Lcontext_allocation_failure
 ldr w9,[sp,#236]
 str w9,[sp,#264]
 context_load_word w9,x22,1577396
 str w9,[sp,#268]
 context_load_word w9,x22,1608808
 str w9,[sp,#272]
 context_load_word w9,x22,1608800
 str w9,[sp,#276]
 context_address x0,x19,113696
 mov x1,x21
 add x2,sp,#264
 mov w3,#0
 bl md2asm_surf_and_more_local_type_init
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,115792
 mov x1,x21
 mov x2,#0
 mov w3,#0
 bl md2asm_keys_local_type_init
 cbnz w0,.Lcontext_allocation_failure
 context_address x0,x19,116456
 mov x1,x21
 context_address x2,x21,5224
 mov w3,#0
 bl md2asm_perturb_local_type_init
 cbnz w0,.Lcontext_allocation_failure
 ldr x10,[x20,#320]
 context_address x9,x19,118752
 str x10,[x9]
 context_count 0
 mov x0,x19
 context_return
.Lcontext_allocation_failure:
 mov w0,#116
 bl _exit
 brk #0
.size md2asm_physics_storage_initialise,.-md2asm_physics_storage_initialise
.global md2asm_physics_storage_finish
.type md2asm_physics_storage_finish,%function
md2asm_physics_storage_finish:
 context_enter
 mov x19,x0
 context_save_error
 context_address x20,x19,72736
 mov w21,#8
.Lcontext_finish_state:
 mov x0,x20
 bl md2asm_finalize_physics_state
 add x20,x20,#1240
 subs w21,w21,#1
 b.ne .Lcontext_finish_state
 context_address x9,x19,82656
 ldr x0,[x9]
 bl free
 context_address x0,x19,82944
 bl md2asm_finalize_surface_work_record
 context_address x0,x19,96624
 bl md2asm_finalize_auxiliary_work_record
 context_address x0,x19,98616
 bl md2asm_finalize_radiation_work_record
 context_address x0,x19,101280
 bl md2asm_flux_type_final
 context_address x0,x19,106344
 bl md2asm_aux_diag_type_final
 context_address x0,x19,110448
 bl md2asm_ddh_surf_type_final
 context_address x0,x19,111360
 bl md2asm_aux_diag_local_type_final
 context_address x0,x19,113696
 bl md2asm_surf_and_more_local_type_final
 context_address x0,x19,115792
 bl md2asm_keys_local_type_final
 context_address x0,x19,116456
 bl md2asm_perturb_local_type_final
 add x24,x19,#16
 adrp x20,.Lcontext_global_offsets
 add x20,x20,:lo12:.Lcontext_global_offsets
 mov w21,#18
.Lcontext_free_globals:
 ldr w9,[x20],#4
 ldr x0,[x24,w9,uxtw]
 bl free
 subs w21,w21,#1
 b.ne .Lcontext_free_globals
 mov x0,x19
 bl free
 context_count 1
 context_return
.size md2asm_physics_storage_finish,.-md2asm_physics_storage_finish
.global md2asm_physics_context_lifetime_count_get
.type md2asm_physics_context_lifetime_count_get,%function
md2asm_physics_context_lifetime_count_get:
 cmp x0,#2
 b.hs .Lcontext_lifetime_count_zero
 adrp x9,.Lcontext_lifetime_counts
 add x9,x9,:lo12:.Lcontext_lifetime_counts
 ldr x0,[x9,x0,lsl#3]
 ret
.Lcontext_lifetime_count_zero:
 mov x0,#0
 ret
.size md2asm_physics_context_lifetime_count_get,.-md2asm_physics_context_lifetime_count_get
.section .rodata
.p2align 3
.Lcontext_global_offsets:
 .word 29680,29808,29936,30792,30920,31048,31176,31304,31432,31560,31688,31816,31944,32072,32200,32328,41920,42776
.Lcontext_mask_sources:
 .word 22436,8604,21708,10060,9332,15884,15156,18068
.Lcontext_state_variables:
 .word 0,728,1456,22400,8568,21672,10024,9296,15848,15120,18032
.bss
.p2align 3
.Lcontext_lifetime_counts: .zero 16
.section .note.GNU-stack,"",%progbits

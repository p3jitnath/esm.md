/* Physics state storage from its frozen source and typed record layout.
 * Contract skills/md2asm/references/openifs/support/physics_state_storage.md. No weather value is computed.
 * Raw INIT x0 state, x1 geometry, x2 field pointer table, x3 mask,
 * w4 presence bits, w5 persistent. Return w0 zero or allocation error one.
 * Raw FINAL x0 state. Preserve views, borrowed fields and source flags.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialise_physics_state
.type md2asm_initialise_physics_state,%function
md2asm_initialise_physics_state:
 sub sp,sp,#208
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
 mov w23,w4
 eor w24,w5,#1
 ldp x9,x10,[x3]
 ldp x11,x12,[x3,#16]
 stp x9,x10,[x19]
 stp x11,x12,[x19,#16]
 // Define every ownership slot for safe partial-allocation cleanup.
 mov x9,#1112
 add x9,x19,x9
 mov x10,#12
.Lstate_clear_fields:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lstate_clear_fields
 mov x9,#1208
 add x9,x19,x9
 stp xzr,xzr,[x9]
 str xzr,[x9,#16]
 str wzr,[x9,#24]
 ldr w9,[x20,#5144]
 ldr w10,[x20,#5224]
 stp w9,w10,[sp,#144]
 ldr w9,[x20,#5160]
 mov w10,#1
 cmp w5,#0
 csel w9,w9,w10,ne
 str w9,[sp,#152]
 str w9,[sp,#156]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 adrp x22,.Lstate_field_rules
 add x22,x22,:lo12:.Lstate_field_rules
 mov w25,#0
.Lstate_construct_field:
 ldp w9,w10,[x22],#8
 str w10,[sp,#160]
 lsr w11,w23,w25
 tbz w11,#0,.Lstate_missing_field
 tbnz w9,#31,.Lstate_use_supplied
 ldr w11,[x19,w9,uxtw]
 cbz w11,.Lstate_missing_field
.Lstate_use_supplied:
 ldr x26,[x21,x25,lsl#3]
 b .Lstate_store_field
.Lstate_missing_field:
 mov x26,#0
 tbnz w10,#31,.Lstate_store_field
 mov x0,#328
 bl malloc
 cbz x0,.Lstate_initialise_failed
 mov x26,x0
 add x1,sp,#144
 mov w2,#3
 mov w3,w24
 bl md2asm_registry_allocate_field
 cbnz w0,.Lstate_field_data_failed
 ldr w9,[sp,#160]
 mov w10,#1
 str w10,[x19,w9,uxtw]
.Lstate_store_field:
 mov x9,#1112
 add x9,x19,x9
 str x26,[x9,x25,lsl#3]
 add w25,w25,#1
 cmp w25,#11
 b.ne .Lstate_construct_field
 mov x0,#400
 bl malloc
 cbz x0,.Lstate_initialise_failed
 mov x26,x0
 mov w9,#5
 str w9,[sp,#152]
 add x1,sp,#144
 mov w2,#4
 mov w3,w24
 bl md2asm_registry_allocate_field
 cbnz w0,.Lstate_field_data_failed
 str x26,[x19,#1200]
 mov w28,#0
 b .Lstate_initialise_return
.Lstate_field_data_failed:
 mov x0,x26
 bl free
.Lstate_initialise_failed:
 mov x0,x19
 bl md2asm_finalize_physics_state
 mov w28,#1
.Lstate_initialise_return:
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 mov w0,w28
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#208
 ret
.size md2asm_initialise_physics_state,.-md2asm_initialise_physics_state

.global md2asm_finalize_physics_state
.type md2asm_finalize_physics_state,%function
md2asm_finalize_physics_state:
 sub sp,sp,#112
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mrs x9,fpcr
 str x9,[sp,#48]
 mrs x9,fpsr
 str x9,[sp,#56]
 mov x19,x0
 bl __errno_location
 str x0,[sp,#64]
 ldr w9,[x0]
 str w9,[sp,#72]
 adrp x20,.Lstate_owned_fields
 add x20,x20,:lo12:.Lstate_owned_fields
 mov w21,#7
.Lstate_release_next:
 ldp w9,w10,[x20],#8
 ldr w11,[x19,w10,uxtw]
 cbz w11,.Lstate_release_skip
 add x0,x19,w9,uxtw
 mov w1,#3
 bl .Lrelease_state_field
.Lstate_release_skip:
 subs w21,w21,#1
 b.ne .Lstate_release_next
 add x0,x19,#1200
 mov w1,#4
 bl .Lrelease_state_field
 ldr x9,[sp,#64]
 ldr w10,[sp,#72]
 str w10,[x9]
 ldr x9,[sp,#48]
 msr fpcr,x9
 ldr x9,[sp,#56]
 msr fpsr,x9
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_finalize_physics_state,.-md2asm_finalize_physics_state

// Private cleanup. x0 pointer slot, w1 rank. Parent protects C status.
.Lrelease_state_field:
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov w21,w1
 ldr x20,[x19]
 cbz x20,.Lrelease_field_done
 mov x9,#72
 madd x9,x21,x9,x20
 ldr w10,[x9,#108]
 cbz w10,.Lrelease_metadata_only
 mov x9,#48
 madd x9,x21,x9,x20
 ldr x0,[x9,#56]
 cbz x0,.Lrelease_metadata_only
 bl free
.Lrelease_metadata_only:
 mov x0,x20
 bl free
 str xzr,[x19]
.Lrelease_field_done:
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret

.global md2asm_set_physics_field_mask
.type md2asm_set_physics_field_mask,%function
md2asm_set_physics_field_mask:
 ldp x2,x3,[x1]
 ldp x4,x5,[x1,#16]
 stp x2,x3,[x0]
 stp x4,x5,[x0,#16]
 ret
.size md2asm_set_physics_field_mask,.-md2asm_set_physics_field_mask

.p2align 4
.global __ecphys_state_type_mod_MOD_mask_gfl_type_init
.type __ecphys_state_type_mod_MOD_mask_gfl_type_init,%function
__ecphys_state_type_mod_MOD_mask_gfl_type_init:
 ldr x9,[x0]
 ldr w10,[x2]
 ldr w11,[x1]
 ldr w12,[x3]
 ldr w13,[x4]
 ldr w14,[x5]
 ldr w15,[x6]
 ldr w16,[x7]
 ldr x17,[sp]
 ldr w17,[x17]
 str w10,[x9,#4]
 str w11,[x9]
 str w12,[x9,#8]
 str w13,[x9,#12]
 str w14,[x9,#16]
 str w15,[x9,#20]
 str w16,[x9,#24]
 str w17,[x9,#28]
 adrp x9,md2asm_physics_state_native_counts
 add x9,x9,:lo12:md2asm_physics_state_native_counts
 ldr x10,[x9,#16]
 add x10,x10,#1
 str x10,[x9,#16]
 ret
.size __ecphys_state_type_mod_MOD_mask_gfl_type_init,.-__ecphys_state_type_mod_MOD_mask_gfl_type_init

.p2align 4
.global __ecphys_state_type_mod_MOD_state_type_init
.type __ecphys_state_type_mod_MOD_state_type_init,%function
__ecphys_state_type_mod_MOD_state_type_init:
 sub sp,sp,#208
 stp x29,x30,[sp]
 mov x29,sp
 str x18,[sp,#16]
 stp x0,x1,[sp,#32]
 stp x2,x3,[sp,#48]
 stp x4,x5,[sp,#64]
 stp x6,x7,[sp,#80]
 mov x10,#0
 mov w14,#0
.Lstate_optional_pointer:
 cmp x10,#6
 b.hs .Lstate_stack_pointer
 add x11,sp,#48
 ldr x11,[x11,x10,lsl#3]
 b .Lstate_pointer_argument
.Lstate_stack_pointer:
 sub x11,x10,#6
 add x12,sp,#208
 ldr x11,[x12,x11,lsl#3]
.Lstate_pointer_argument:
 mov x12,#0
 cbz x11,.Lstate_absent_pointer
 ldr x12,[x11]
 mov w13,#1
 lsl w13,w13,w10
 orr w14,w14,w13
.Lstate_absent_pointer:
 add x13,sp,#96
 str x12,[x13,x10,lsl#3]
 add x10,x10,#1
 cmp x10,#11
 b.ne .Lstate_optional_pointer
 ldr x0,[sp,#32]
 ldr x0,[x0]
 ldr x1,[sp,#40]
 add x2,sp,#96
 ldr x3,[sp,#248]
 mov w4,w14
 ldr x9,[sp,#256]
 mov w5,#0
 cbz x9,.Lstate_persistent_ready
 ldr w5,[x9]
.Lstate_persistent_ready:
 bl md2asm_initialise_physics_state
 cbnz w0,.Lstate_native_failed
 adrp x9,md2asm_physics_state_native_counts
 add x9,x9,:lo12:md2asm_physics_state_native_counts
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#208
 ret
.Lstate_native_failed:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size __ecphys_state_type_mod_MOD_state_type_init,.-__ecphys_state_type_mod_MOD_state_type_init

.p2align 4
.global __ecphys_state_type_mod_MOD_state_type_final
.type __ecphys_state_type_mod_MOD_state_type_final,%function
__ecphys_state_type_mod_MOD_state_type_final:
 stp x29,x30,[sp,#-16]!
 mov x29,sp
 ldr x0,[x0]
 bl md2asm_finalize_physics_state
 adrp x9,md2asm_physics_state_native_counts
 add x9,x9,:lo12:md2asm_physics_state_native_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldp x29,x30,[sp],#16
 ret
.size __ecphys_state_type_mod_MOD_state_type_final,.-__ecphys_state_type_mod_MOD_state_type_final

.global md2asm_physics_state_call_count_get
.type md2asm_physics_state_call_count_get,%function
md2asm_physics_state_call_count_get:
 cmp x0,#3
 b.hs .Lstate_count_zero
 adrp x9,md2asm_physics_state_native_counts
 add x9,x9,:lo12:md2asm_physics_state_native_counts
 ldr x0,[x9,x0,lsl#3]
 ret
.Lstate_count_zero:
 mov x0,#0
 ret
.size md2asm_physics_state_call_count_get,.-md2asm_physics_state_call_count_get
.section .rodata
.p2align 3
.Lstate_field_rules:
 // Mask offset, ownership flag offset. Minus one means no such rule.
 .word -1,1208
 .word -1,1212
 .word -1,1216
 .word 0,1220
 .word 4,1224
 .word 8,1228
 .word -1,-1
 .word -1,-1
 .word -1,-1
 .word -1,-1
 .word 28,1232
.Lstate_owned_fields:
 .word 1112,1208
 .word 1120,1212
 .word 1128,1216
 .word 1136,1220
 .word 1144,1224
 .word 1152,1228
 .word 1192,1232
.data
.p2align 3
.hidden md2asm_physics_state_native_counts
md2asm_physics_state_native_counts:
 .quad 0,0,0
.section .note.GNU-stack,"",%progbits

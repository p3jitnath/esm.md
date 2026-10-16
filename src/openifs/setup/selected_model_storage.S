/* Contract: skills/md2asm/references/openifs/input/owned_model_initial_state.md.
 * Create: x0 live vertical20400,x1 table15 owned pointer destinations,x2 owner.
 * Release: x0 owner word,x1 unchanged destination table. Return w0=0/1/2.
 * Source scalar defaults are literals, never a constructed-state packet.
 */
.arch armv8.2-a
.text
.macro model_offset dst,base,value
 movz \dst,#(\value & 65535)
 movk \dst,#(\value >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_create_selected_model_storage
.type md2asm_create_selected_model_storage,%function
md2asm_create_selected_model_storage:
 cbz x0,.Lmodel_storage_bad
 cbz x1,.Lmodel_storage_bad
 cbz x2,.Lmodel_storage_bad
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lmodel_storage_bad
 ldr x9,[x2]
 cbnz x9,.Lmodel_storage_bad
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x18,xzr,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 bl __errno_location
 mov x23,x0
 ldr w24,[x23]
 mov x0,#1
 movz x1,#(4275088 & 65535)
 movk x1,#(4275088 >> 16),lsl#16
 bl calloc
 mov x22,x0
 cbz x22,.Lmodel_storage_allocation_failed
 str x19,[x22,#8]
 /* TMSE declarations: three logicals, two counts, two prefixes and XZSEPS. */
 model_offset x9,x22,4219344
 adr x10,.Lmodel_mse_defaults
 ldp x11,x12,[x10]
 stp x11,x12,[x9]
 ldp x11,x12,[x10,#16]
 stp x11,x12,[x9,#16]
 ldr x11,[x10,#32]
 str x11,[x9,#32]
 /* Eight declared TPHYDS dimension constants, before surface setup. */
 model_offset x9,x22,4155544
 adr x10,.Lmodel_phyds_defaults
 ldp q0,q1,[x10]
 stp q0,q1,[x9]
 /* These zero values are explicit declared scalar defaults. */
 str wzr,[x22]
 model_offset x9,x22,1578316
 str wzr,[x9]
 model_offset x9,x22,4275064
 str wzr,[x9],#4
 mov w10,#32
 mov w11,#17
.Lmodel_object_name:
 strb w10,[x9],#1
 subs w11,w11,#1
 b.ne .Lmodel_object_name
 mov x0,x22
 mov x1,x20
 bl md2asm_set_model_component_aliases
 cbnz w0,.Lmodel_storage_alias_failed
 str x22,[x21]
 mov w0,#0
 b .Lmodel_storage_return
.Lmodel_storage_alias_failed:
 mov x0,x22
 bl free
 mov w0,#2
 b .Lmodel_storage_return
.Lmodel_storage_allocation_failed:
 mov w0,#1
.Lmodel_storage_return:
 str w24,[x23]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x18,xzr,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lmodel_storage_bad:
 mov w0,#2
 ret
.size md2asm_create_selected_model_storage,.-md2asm_create_selected_model_storage

.p2align 4
.global md2asm_release_selected_model_storage
.type md2asm_release_selected_model_storage,%function
md2asm_release_selected_model_storage:
 cbz x0,.Lmodel_storage_bad
 cbz x1,.Lmodel_storage_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lmodel_storage_bad
 ldr x2,[x0]
 cbz x2,.Lmodel_storage_empty
 tst x2,#7
 b.ne .Lmodel_storage_bad
 adr x9,.Lmodel_alias_offsets
 mov x3,#0
.Lmodel_storage_check_alias:
 ldr x4,[x1,x3,lsl#3]
 cbz x4,.Lmodel_storage_bad
 tst x4,#7
 b.ne .Lmodel_storage_bad
 ldr w5,[x9,x3,lsl#2]
 add x5,x2,x5
 ldr x6,[x4]
 cmp x5,x6
 b.ne .Lmodel_storage_bad
 add x3,x3,#1
 cmp x3,#15
 b.lo .Lmodel_storage_check_alias
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 bl __errno_location
 mov x22,x0
 ldr w23,[x22]
 mov x3,#0
.Lmodel_storage_clear_alias:
 ldr x4,[x20,x3,lsl#3]
 str xzr,[x4]
 add x3,x3,#1
 cmp x3,#15
 b.lo .Lmodel_storage_clear_alias
 mov x0,x21
 bl free
 str xzr,[x19]
 str w23,[x22]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#96
.Lmodel_storage_empty:
 mov w0,#0
 ret
.size md2asm_release_selected_model_storage,.-md2asm_release_selected_model_storage
.section .rodata
.p2align 3
.Lmodel_mse_defaults:
 .word 0,1,1,3,3
 .ascii "SFX.X   "
 .word 0
 .double 0.01
.Lmodel_phyds_defaults:
 .word 20,50,50,99,99,99,99,99
.Lmodel_alias_offsets:
 .word 1577368,192,1608728,1626696,1588296,1589160,1590360,1591240
 .word 1591584,1577888,4143760,4144856,4148312,4150008,4219384
.section .note.GNU-stack,"",%progbits

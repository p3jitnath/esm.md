// Original temporary state-view service, using direct named block descriptors.
// Contract skills/md2asm/references/openifs/support/physics_state_block_binding.md. No numerical value changes.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_physics_storage_state_view
.global md2asm_bind_physics_state_block
.type md2asm_physics_storage_state_view,%function
md2asm_physics_storage_state_view:
md2asm_bind_physics_state_block:
 cbz x0,.Lstate_view_reject
 tst x0,#7
 b.ne .Lstate_view_reject
 cbz x3,.Lstate_view_reject
 tst x3,#3
 b.ne .Lstate_view_reject
 sub w9,w1,#1
 cmp w9,#7
 b.hi .Lstate_view_reject
 sub w10,w2,#1
 cmp w10,#85
 b.hi .Lstate_view_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x10,#1240
 madd x19,x9,x10,x0
 movz x10,#0x1c20
 movk x10,#1,lsl#16
 add x19,x19,x10
 mov w20,w2
 mov x21,x3
 str wzr,[x21]
 adrp x22,.Lstate_view_rules
 add x22,x22,:lo12:.Lstate_view_rules
 mov w23,#12
 adrp x9,md2asm_physics_state_view_calls
 add x9,x9,:lo12:md2asm_physics_state_view_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
.Lstate_bind_next:
 ldp w9,w10,[x22]
 ldp w11,w24,[x22,#8]
 ldr w25,[x22,#16]
 ldr x1,[x19,w9,uxtw]
 cbz x1,.Lstate_bind_skip
 add x0,x19,w10,uxtw
 mov w2,w20
 cmp w11,#4
 b.eq .Lstate_bind_cloud_vector
 bl md2asm_physics_field_view_3d
 b .Lstate_bind_component_mask
.Lstate_bind_cloud_vector:
 bl md2asm_physics_field_view_4d
.Lstate_bind_component_mask:
 tbnz w24,#31,.Lstate_bind_skip
 ldr w9,[x19,w24,uxtw]
 cbz w9,.Lstate_bind_skip
 ldr w9,[x21]
 mov w10,#1
 lsl w10,w10,w25
 orr w9,w9,w10
 str w9,[x21]
.Lstate_bind_skip:
 add x22,x22,#24
 subs w23,w23,#1
 b.ne .Lstate_bind_next
 mov x0,x19
 ldp x25,x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lstate_view_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size md2asm_physics_storage_state_view,.-md2asm_physics_storage_state_view
.global md2asm_physics_state_view_call_count_get
.type md2asm_physics_state_view_call_count_get,%function
md2asm_physics_state_view_call_count_get:
 adrp x9,md2asm_physics_state_view_calls
 ldr x0,[x9,:lo12:md2asm_physics_state_view_calls]
 ret
.size md2asm_physics_state_view_call_count_get,.-md2asm_physics_state_view_call_count_get
.section .rodata
.p2align 3
.Lstate_view_rules:
 .word 1112,32,3,-1,-1,0
 .word 1120,120,3,-1,-1,0
 .word 1128,208,3,-1,-1,0
 .word 1136,296,3,-1,-1,0
 .word 1144,384,3,-1,-1,0
 .word 1152,472,3,-1,-1,0
 .word 1192,560,3,-1,-1,0
 .word 1200,1000,4,-1,-1,0
 .word 1160,648,3,12,0,0
 .word 1168,736,3,16,1,0
 .word 1176,824,3,20,2,0
 .word 1184,912,3,24,3,0
 .data
.p2align 3
.hidden md2asm_physics_state_view_calls
md2asm_physics_state_view_calls:
 .quad 0
.section .note.GNU-stack,"",%progbits

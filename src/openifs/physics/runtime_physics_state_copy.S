/* Original STATE_COPY with live dimensions and caller-owned false-hook policy. */
/* Move each enabled source state value to the same column and level.
 * Reuse the qualified 192-byte dimensions and 1240-byte state records.
 * Contract skills/md2asm/references/openifs/physics/runtime_physics_state_copy.md.
 */
.text
.p2align 4
.macro physics_copy_address result,object,descriptor,component
 add x3,\object,#\descriptor
 ldr \result,[x3]
 ldr x4,[x3,#8]
 ldr x5,[x3,#40]
 ldr x6,[x3,#64]
 madd x4,x24,x5,x4
 madd x4,x28,x6,x4
.if \component > 0
 ldr x5,[x3,#88]
 mov x6,#\component
 madd x4,x6,x5,x4
.endif
 add \result,\result,x4,lsl #3
.endm
.macro physics_copy_field descriptor,mask,component
.if \mask >= 0
 ldr w3,[x21,#\mask]
 cbz w3,990f
.endif
 physics_copy_address x0,x20,\descriptor,\component
 physics_copy_address x1,x21,\descriptor,\component
 mov x2,x27
991:
 ldr x3,[x0],#8
 str x3,[x1],#8
 subs x2,x2,#1
 b.ne 991b
990:
.endm
.global md2asm_copy_runtime_physics_state
.type md2asm_copy_runtime_physics_state,%function
md2asm_copy_runtime_physics_state:
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 cbz x19,.Lstate_refuse
 cbz x20,.Lstate_refuse
 cbz x21,.Lstate_refuse
 cbz x3,.Lstate_refuse
 orr x8,x19,x20
 orr x8,x8,x21
 orr x8,x8,x3
 tst x8,#7
 b.ne .Lstate_refuse
 ldr x8,[x3,#8]
 cbnz x8,.Lstate_refuse
 ldr x8,[x3]
 cbz x8,.Lstate_refuse
 tst x8,#3
 b.ne .Lstate_refuse
 ldr w8,[x8]
 cbnz w8,.Lstate_refuse
 ldrsw x9,[x19,#12]
 sub x8,x9,#1
 cmp x8,#1023
 b.hi .Lstate_refuse
 str x9,[sp,#128]
 ldrsw x10,[x19,#48]
 cmp x10,#512
 b.hi .Lstate_refuse
 ldrsw x11,[x19]
 cmp x11,#1
 b.lt .Lstate_refuse
 add x12,x9,#1
 cmp x11,x12
 b.gt .Lstate_refuse
 ldrsw x12,[x19,#4]
 cmp x12,x9
 b.gt .Lstate_refuse
 sub x11,x11,#1
 cmp x12,x11
 b.lt .Lstate_refuse
 /* Check every consumed source and destination descriptor before stores. */
 mov x28,#0
.Lstate_check_next:
 adr x8,.Lstate_fields
 add x8,x8,x28,lsl#3
 ldr w9,[x8]
 ldrsw x10,[x8,#4]
 cmp x10,#0
 b.lt .Lstate_check_enabled
 cmp x28,#7
 b.ne .Lstate_one_mask
 ldp w11,w12,[x21,#12]
 orr w11,w11,w12
 ldp w12,w13,[x21,#20]
 orr w12,w12,w13
 orr w11,w11,w12
 b .Lstate_mask_ready
.Lstate_one_mask:
 ldr w11,[x21,x10]
.Lstate_mask_ready:
 cmp w11,#1
 b.hi .Lstate_refuse
 cbz w11,.Lstate_check_skip
.Lstate_check_enabled:
 str x9,[sp,#136]
 add x0,x20,x9
 ldr x1,[sp,#128]
 ldrsw x2,[x19,#48]
 cmp x28,#7
 cset x3,eq
 add x3,x3,#2
 bl .Lstate_descriptor
 cbnz w0,.Lstate_refuse
 ldr x9,[sp,#136]
 add x0,x21,x9
 ldr x1,[sp,#128]
 ldrsw x2,[x19,#48]
 cmp x28,#7
 cset x3,eq
 add x3,x3,#2
 bl .Lstate_descriptor
 cbnz w0,.Lstate_refuse
.Lstate_check_skip:
 add x28,x28,#1
 cmp x28,#8
 b.lo .Lstate_check_next

 ldrsw x24,[x19]
 ldrsw x25,[x19,#4]
 ldrsw x26,[x19,#48]
 sub x27,x25,x24
 add x27,x27,#1

 cmp x27,#1
 b.lt .Lphysics_copy_done
 cmp x26,#1
 b.lt .Lphysics_copy_done
 mov x28,#1
.Lphysics_copy_level:
 physics_copy_field 32,-1,0
 physics_copy_field 120,-1,0
 physics_copy_field 208,-1,0
 physics_copy_field 384,4,0
 physics_copy_field 296,0,0
 physics_copy_field 472,8,0
 physics_copy_field 1000,12,1
 physics_copy_field 1000,16,2
 physics_copy_field 1000,20,3
 physics_copy_field 1000,24,4
 physics_copy_field 560,28,0
 add x28,x28,#1
 cmp x28,x26
 b.le .Lphysics_copy_level
.Lphysics_copy_done:
 mov w0,#0
 b .Lstate_restore
.Lstate_refuse:
 mov w0,#2
.Lstate_restore:
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.size md2asm_copy_runtime_physics_state,.-md2asm_copy_runtime_physics_state
/* Validate the canonical complete mapped owner, without FP operations. */
.Lstate_descriptor:
 ldr x4,[x0]
 cbz x4,.Lstate_descriptor_bad
 tst x4,#7
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#16]
 cmp x5,#8
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#24]
 mov x6,#0x300
 add x6,x6,x3
 lsl x6,x6,#32
 cmp x5,x6
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#32]
 cmp x5,#8
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#40]
 cmp x5,#1
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#48]
 cmp x5,#1
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#56]
 cmp x5,x1
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#64]
 cmp x5,x1
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#72]
 cmp x5,#1
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#80]
 cmp x5,x2
 b.ne .Lstate_descriptor_bad
 mul x7,x1,x2
 add x8,x1,#1
 neg x8,x8
 cmp x3,#3
 b.ne .Lstate_descriptor_rank2
 ldr x5,[x0,#88]
 cmp x5,x7
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#96]
 cmp x5,#1
 b.ne .Lstate_descriptor_bad
 ldr x5,[x0,#104]
 sub x6,x5,#4
 cmp x6,#60
 b.hi .Lstate_descriptor_bad
 sub x8,x8,x7
 mul x7,x7,x5
.Lstate_descriptor_rank2:
 ldr x5,[x0,#8]
 cmp x5,x8
 b.ne .Lstate_descriptor_bad
 lsl x7,x7,#3
 adds x7,x4,x7
 b.cs .Lstate_descriptor_bad
 mov w0,#0
 ret
.Lstate_descriptor_bad:
 mov w0,#2
 ret

.section .rodata
.p2align 3
.Lstate_fields: .word 32,-1,120,-1,208,-1,384,4,296,0,472,8,560,28,1000,12
.section .note.GNU-stack,"",%progbits

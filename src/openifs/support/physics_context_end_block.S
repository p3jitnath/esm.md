// Solver contract skills/md2asm/references/openifs/support/physics_context_block_services.md.
// Selected context end of block cleanup. Contract: skills/md2asm/references/openifs/support/physics_context_block_services.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_physics_storage_end_block
.type md2asm_physics_storage_end_block,%function
md2asm_physics_storage_end_block:
 adrp x9,md2asm_block_context_native_counters
 add x9,x9,:lo12:md2asm_block_context_native_counters
 ldr x10,[x9,#16]
 add x10,x10,#1
 str x10,[x9,#16]
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
 movz x9,#7184
 movk x9,#1,lsl #16
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
 movz x0,#51256
 movk x0,#1,lsl #16
 add x0,x19,x0
 mov x1,x21
 movz x2,#62936
 movk x2,#62,lsl #16
 add x2,x21,x2
 bl md2asm_finalize_perturbation_views
 cbnz w0,.Lend_abort
 movz x9,#5884
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_0
 movz x9,#26888
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26888
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_0:
 movz x9,#6172
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_1
 movz x9,#26664
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26664
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_1:
 movz x9,#6452
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_2
 movz x9,#25784
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#25784
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_2:
 movz x9,#6748
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_3
 movz x9,#25872
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#25872
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_3:
 movz x9,#7636
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_4
 movz x9,#27000
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#27000
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_4:
 movz x9,#7876
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_5
 movz x9,#25960
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#25960
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_5:
 movz x9,#7340
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_6
 movz x9,#26776
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26776
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_6:
 movz x9,#8900
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_7
 movz x9,#26136
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26136
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_7:
 movz x9,#10548
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_8
 movz x9,#26224
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26224
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_8:
 movz x9,#12604
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_9
 movz x9,#26400
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26400
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_9:
 movz x9,#15252
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_10
 movz x9,#26048
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26048
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_10:
 movz x9,#15564
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_11
 movz x9,#26576
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26576
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_11:
 movz x9,#16244
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_12
 movz x9,#27224
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#27224
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_12:
 movz x9,#17020
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_13
 movz x9,#26488
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26488
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_13:
 movz x9,#14996
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_14
 movz x9,#27336
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#27336
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_14:
 movz x9,#11956
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_15
 movz x9,#26312
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#26312
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_15:
 movz x9,#12244
 add x9,x20,x9
 ldr w9,[x9]
 cmp w9,#1
 b.ge .Lend_skip_16
 movz x9,#27112
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 bl free
 movz x9,#27112
 movk x9,#1,lsl #16
 add x9,x19,x9
 str xzr,[x9]
.Lend_skip_16:
 movz x0,#16
 add x0,x19,x0
 bl md2asm_reset_field_variable_arrays
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
.Lend_abort:
 bl abort
.size md2asm_physics_storage_end_block,.-md2asm_physics_storage_end_block
.section .note.GNU-stack,"",%progbits

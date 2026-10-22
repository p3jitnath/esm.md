/* Operational SUGEM1A. x0 Geometry17096, x1 options{1,1}; status w0.
 * Contract: skills/md2asm/references/openifs/setup/operational_global_grid_cutoffs.md.
 * Complete old regular-grid entry and shared release remain separate and literal.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_global_grid_cutoffs
.type md2asm_initialize_operational_global_grid_cutoffs,%function
md2asm_initialize_operational_global_grid_cutoffs:
 cbz x0,.Locut_reject
 cbz x1,.Locut_reject
 tst x0,#7
 b.ne .Locut_reject
 tst x1,#3
 b.ne .Locut_reject
 ldp w9,w10,[x1]
 cmp w9,#1
 b.ne .Locut_reject
 cmp w10,#1
 b.ne .Locut_reject
 ldr w9,[x0,#5172]
 cmp w9,#1279
 b.ne .Locut_reject
 ldr w9,[x0,#4872]
 cmp w9,#2560
 b.ne .Locut_reject
 ldr w9,[x0,#5168]
 cmp w9,#1
 b.lt .Locut_reject
 ldr w9,[x0,#4884]
 cmp w9,#2
 b.ne .Locut_reject
 mov w10,#1
 sub w10,w10,w9
 ldr w11,[x0,#4888]
 cmp w10,w11
 b.ne .Locut_reject
 add w10,w9,#2560
 ldr w11,[x0,#4904]
 cmp w10,w11
 b.ne .Locut_reject
 ldr x9,[x0,#7704]
 ldr x10,[x0,#7768]
 ldr x11,[x0,#7832]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Locut_reject
 sub sp,sp,#576
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 ldrsw x20,[x19,#4888]
 ldrsw x21,[x19,#4904]
 sub x21,x21,x20
 add x21,x21,#1
 bl __errno_location
 mov x27,x0
 ldr w28,[x27]
 mov x22,#0
.Locut_allocate:
 mov x23,#7704
 add x23,x23,x22,lsl#6
 add x23,x19,x23
 mov x24,x20
 mov x25,x21
 cmp x22,#2
 b.ne .Locut_shape_ready
 mov x24,#0
 mov x25,#1280
.Locut_shape_ready:
 lsl x0,x25,#2
 bl malloc
 cbz x0,.Locut_failure
 str x0,[x23]
 neg x9,x24
 str x9,[x23,#8]
 mov x9,#4
 str x9,[x23,#16]
 str x9,[x23,#32]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[x23,#24]
 mov x9,#1
 stp x9,x24,[x23,#40]
 add x9,x24,x25
 sub x9,x9,#1
 str x9,[x23,#56]
 add x22,x22,#1
 cmp x22,#3
 b.lo .Locut_allocate
 add x0,sp,#128
 mov x9,#0
.Locut_zero_arguments:
 str xzr,[x0,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#47
 b.lo .Locut_zero_arguments
 add x9,x19,#1,lsl#12
 add x9,x9,#1072
 str x9,[sp,#128]
 add x9,sp,#504
 str x9,[sp,#352]
 add x10,x19,#1,lsl#12
 add x10,x10,#3736
 str x10,[sp,#496]
 /* Caller-owned section NMENG(1:2560); retained halo cells stay untouched. */
 ldr x10,[x19,#7768]
 mov x11,#1
 sub x11,x11,x20
 add x10,x10,x11,lsl#2
 str x10,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#4
 str x10,[x9,#16]
 str x10,[x9,#32]
 mov x10,#0x101
 lsl x10,x10,#32
 str x10,[x9,#24]
 mov x10,#1
 stp x10,x10,[x9,#40]
 mov x10,#2560
 str x10,[x9,#56]
 str w28,[x27]
 bl md2asm_call_public_transform_inquiry
 ldr w22,[x19,#4884]
 ldr x23,[x19,#7768]
 mov x9,#1
.Locut_halo:
 cmp x9,x22
 b.hi .Locut_ready
 sub x10,x9,x20
 ldr w11,[x23,x10,lsl#2]
 mov x10,#1
 sub x10,x10,x9
 sub x10,x10,x20
 str w11,[x23,x10,lsl#2]
 mov x10,#2561
 sub x10,x10,x9
 sub x10,x10,x20
 ldr w11,[x23,x10,lsl#2]
 add x10,x9,#2560
 sub x10,x10,x20
 str w11,[x23,x10,lsl#2]
 add x9,x9,#1
 b .Locut_halo
.Locut_ready:
 mov w0,#0
 b .Locut_return
.Locut_failure:
 mov x22,#0
.Locut_failure_loop:
 mov x9,#7704
 add x9,x9,x22,lsl#6
 add x23,x19,x9
 ldr x0,[x23]
 cbz x0,.Locut_failure_next
 bl free
 str xzr,[x23]
.Locut_failure_next:
 add x22,x22,#1
 cmp x22,#3
 b.lo .Locut_failure_loop
 str w28,[x27]
 mov w0,#1
.Locut_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#576
 ret
.Locut_reject:
 mov w0,#2
 ret
.size md2asm_initialize_operational_global_grid_cutoffs,.-md2asm_initialize_operational_global_grid_cutoffs
.section .note.GNU-stack,"",%progbits

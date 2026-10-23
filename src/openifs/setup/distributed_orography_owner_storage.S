/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */
/* Operational terrain storage uses the exact 17-row, 6,599,680-point grid.
 * The old entry and release remain unchanged. The new paired entries retain
 * the source allocation order, complete descriptors and unwritten payloads.
 */
.text
.p2align 4
.global md2asm_allocate_distributed_orography_owners
.type md2asm_allocate_distributed_orography_owners,%function
md2asm_allocate_distributed_orography_owners:
 cbz x0,.Loporo_bad
 tst x0,#7
 b.ne .Loporo_bad
 mov x9,#17096
 adds x9,x0,x9
 b.cs .Loporo_bad
 ldr x9,[x0,#14024]
 cbnz x9,.Loporo_bad
 ldr x9,[x0]
 cbz x9,.Loporo_bad
 ldr w9,[x9]
 cbnz w9,.Loporo_bad
 ldr w10,[x0,#5144]
 cmp w10,#17
 b.ne .Loporo_bad
 ldr w11,[x0,#7376]
 movz w9,#0x2d00
 movk w9,#25,lsl#16
 cmp w11,w9
 b.ne .Loporo_bad
 sub w9,w11,#1
 sdiv w9,w9,w10
 add w9,w9,#1
 ldr w12,[x0,#5160]
 cmp w9,w12
 b.ne .Loporo_bad
 movz w9,#31519
 movk w9,#1,lsl#16
 cmp w12,w9
 b.ne .Loporo_bad
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#104]
 mov x29,sp
 mov x19,x0
 ldr w21,[x19,#7376]
 ldr w22,[x19,#5144]
 ldr w23,[x19,#5160]
 bl __errno_location
 mov x26,x0
 ldr w27,[x26]
 mov x9,#384
 mul x0,x23,x9
 bl malloc
 cbz x0,.Loporo_failed
 mov x28,x0
 str x28,[x19,#14024]
 mov x9,#-1
 str x9,[x19,#14032]
 mov x9,#384
 str x9,[x19,#14040]
 str x9,[x19,#14056]
 mov x9,#0x501
 lsl x9,x9,#32
 str x9,[x19,#14048]
 mov x9,#1
 str x9,[x19,#14064]
 str x9,[x19,#14072]
 str x23,[x19,#14080]
 mov x24,#0
 mov x20,x28
.Loporo_empty_records:
 str xzr,[x20]
 str xzr,[x20,#64]
 str xzr,[x20,#128]
 str xzr,[x20,#192]
 str xzr,[x20,#256]
 str xzr,[x20,#320]
 add x20,x20,#384
 add x24,x24,#1
 cmp x24,x23
 b.lo .Loporo_empty_records
 mov x24,#0
.Loporo_blocks:
 msub x9,x24,x22,x21
 cmp x9,x22
 csel x25,x9,x22,lo
 mov x9,#384
 madd x20,x24,x9,x28
 str xzr,[sp,#128]
.Loporo_payloads:
 lsl x0,x25,#3
 bl malloc
 cbz x0,.Loporo_partial_failure
 str x0,[x20]
 mov x9,#-1
 str x9,[x20,#8]
 mov x9,#8
 str x9,[x20,#16]
 str x9,[x20,#32]
 mov x9,#0x301
 lsl x9,x9,#32
 str x9,[x20,#24]
 mov x9,#1
 stp x9,x9,[x20,#40]
 str x25,[x20,#56]
 add x20,x20,#64
 ldr x9,[sp,#128]
 add x9,x9,#1
 str x9,[sp,#128]
 cmp x9,#3
 b.lo .Loporo_payloads
 add x24,x24,#1
 cmp x24,x23
 b.lo .Loporo_blocks
 mov w0,#0
 b .Loporo_return
.Loporo_partial_failure:
 mov x0,x19
 bl md2asm_release_distributed_orography_owners
.Loporo_failed:
 mov w0,#1
.Loporo_return:
 str w27,[x26]
 ldp x9,x10,[sp,#104]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Loporo_bad:
 mov w0,#2
 ret
.size md2asm_allocate_distributed_orography_owners,.-md2asm_allocate_distributed_orography_owners

.p2align 4
.global md2asm_release_distributed_orography_owners
.type md2asm_release_distributed_orography_owners,%function
md2asm_release_distributed_orography_owners:
 cbz x0,.Loporo_release_bad
 tst x0,#7
 b.ne .Loporo_release_bad
 ldr x9,[x0,#14024]
 cbz x9,.Loporo_release_empty
 ldr x10,[x0,#14080]
 movz x11,#31519
 movk x11,#1,lsl#16
 cmp x10,x11
 b.ne .Loporo_release_bad
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#80]
 mov x29,sp
 mov x19,x0
 ldr x20,[x19,#14024]
 ldr x25,[x19,#14080]
 mov x24,x20
 mov x23,#0
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
.Loporo_release_rows:
 ldr x0,[x24]
 cbz x0,.Loporo_release_l
 bl free
 str xzr,[x24]
.Loporo_release_l:
 ldr x0,[x24,#64]
 cbz x0,.Loporo_release_m
 bl free
 str xzr,[x24,#64]
.Loporo_release_m:
 ldr x0,[x24,#128]
 cbz x0,.Loporo_release_next
 bl free
 str xzr,[x24,#128]
.Loporo_release_next:
 add x24,x24,#384
 add x23,x23,#1
 cmp x23,x25
 b.lo .Loporo_release_rows
 mov x0,x20
 bl free
 str xzr,[x19,#14024]
 str w22,[x21]
 ldp x9,x10,[sp,#80]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#96
.Loporo_release_empty:
 mov w0,#0
 ret
.Loporo_release_bad:
 mov w0,#2
 ret
.size md2asm_release_distributed_orography_owners,.-md2asm_release_distributed_orography_owners
.section .note.GNU-stack,"",%progbits

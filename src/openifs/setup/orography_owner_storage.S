/* Contract: skills/md2asm/references/openifs/setup/orography_owner_storage.md.
 * x0 owned Geometry[17096], w0 status0/1/2. Hydrostatic true owner extents.
 * Allocate frame160B; release96B. No numerical payload initialization.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_orography_owners
.type md2asm_allocate_orography_owners,%function
md2asm_allocate_orography_owners:
 cbz x0,.Loro_bad
 tst x0,#7
 b.ne .Loro_bad
 ldr x9,[x0,#14024]
 cbnz x9,.Loro_bad
 ldr x9,[x0]
 cbz x9,.Loro_bad
 ldr w9,[x9]
 cbnz w9,.Loro_bad
 ldr w10,[x0,#5144]
 sub w9,w10,#1
 cmp w9,#23
 b.hi .Loro_bad
 ldr w11,[x0,#7376]
 sub w9,w11,#1
 cmp w9,#2047
 b.hi .Loro_bad
 sdiv w9,w9,w10
 add w9,w9,#1
 ldr w12,[x0,#5160]
 cmp w9,w12
 b.ne .Loro_bad
 cmp w12,#86
 b.hi .Loro_bad
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
 cbz x0,.Loro_failed
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
.Loro_empty_records:
 str xzr,[x20]
 str xzr,[x20,#64]
 str xzr,[x20,#128]
 str xzr,[x20,#192]
 str xzr,[x20,#256]
 str xzr,[x20,#320]
 add x20,x20,#384
 add x24,x24,#1
 cmp x24,x23
 b.lo .Loro_empty_records
 mov x24,#0
.Loro_blocks:
 msub x9,x24,x22,x21
 cmp x9,x22
 csel x25,x9,x22,lo
 mov x9,#384
 madd x20,x24,x9,x28
 str xzr,[sp,#128]
.Loro_payloads:
 lsl x0,x25,#3
 bl malloc
 cbz x0,.Loro_partial_failure
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
 b.lo .Loro_payloads
 add x24,x24,#1
 cmp x24,x23
 b.lo .Loro_blocks
 mov w0,#0
 b .Loro_return
.Loro_partial_failure:
 mov x0,x19
 bl md2asm_release_orography_owners
.Loro_failed:
 mov w0,#1
.Loro_return:
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
.Loro_bad:
 mov w0,#2
 ret
.size md2asm_allocate_orography_owners,.-md2asm_allocate_orography_owners
.p2align 4
.global md2asm_release_orography_owners
.type md2asm_release_orography_owners,%function
md2asm_release_orography_owners:
 cbz x0,.Loro_release_bad
 tst x0,#7
 b.ne .Loro_release_bad
 ldr x9,[x0,#14024]
 cbz x9,.Loro_release_empty
 ldr x10,[x0,#14080]
 sub x11,x10,#1
 cmp x11,#85
 b.hi .Loro_release_bad
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
.Loro_release_rows:
 ldr x0,[x24]
 cbz x0,.Loro_release_l
 bl free
 str xzr,[x24]
.Loro_release_l:
 ldr x0,[x24,#64]
 cbz x0,.Loro_release_m
 bl free
 str xzr,[x24,#64]
.Loro_release_m:
 ldr x0,[x24,#128]
 cbz x0,.Loro_release_next
 bl free
 str xzr,[x24,#128]
.Loro_release_next:
 add x24,x24,#384
 add x23,x23,#1
 cmp x23,x25
 b.lo .Loro_release_rows
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
.Loro_release_empty:
 mov w0,#0
 ret
.Loro_release_bad:
 mov w0,#2
 ret
.size md2asm_release_orography_owners,.-md2asm_release_orography_owners
.section .note.GNU-stack,"",%progbits

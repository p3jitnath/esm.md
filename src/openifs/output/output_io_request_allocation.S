/* Complete sixteen-owner allocation/release order from SUVFPOSL.
 * Unique child ABI x0=SP744, x1=GP744; counts already selected, one domain.
 */
.arch armv8.2-a
.text
.macro io_heap_enter
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mrs x25,fpcr
 mrs x26,fpsr
 bl __errno_location
 mov x27,x0
 ldr w28,[x0]
 adrp x21,.Lio_owner_order
 add x21,x21,:lo12:.Lio_owner_order
 mov x22,#16
.endm
.macro io_heap_return
 str w28,[x27]
 msr fpcr,x25
 msr fpsr,x26
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.endm
.p2align 4
.global md2asm_allocate_output_io_owners
.type md2asm_allocate_output_io_owners,%function
md2asm_allocate_output_io_owners:
 io_heap_enter
.Lio_allocate:
 ldp w9,w10,[x21]
 ldp w11,w12,[x21,#8]
 add x21,x21,#16
 cmp w9,#0
 csel x9,x19,x20,eq
 ldrsw x24,[x9]
 cmp x24,#4096
 b.hi .Lio_owner_reject
 add x23,x9,w10,uxtw
 ldr x9,[x23]
 cbnz x9,.Lio_owner_reject
 stp x11,x12,[sp,#112]
 mul x0,x24,x11
 mov x9,#1
 cmp x0,x9
 csel x0,x0,x9,ge
 bl malloc
 cbz x0,.Lio_owner_reject
 str x0,[x23]
 ldp x11,x12,[sp,#112]
 str x11,[x23,#16]
 str x11,[x23,#32]
 and x10,x12,#255
 lsr x12,x12,#8
 lsl x9,x10,#32
 orr x9,x9,x12,lsl #40
 str x9,[x23,#24]
 mov x9,#1
 stp x9,x9,[x23,#40]
 str x24,[x23,#56]
 mov x9,#-1
 cmp x10,#1
 b.eq .Lio_allocated_descriptor
 mov x10,#1
 str x10,[x23,#56]
 stp x10,x10,[x23,#64]
 str x24,[x23,#80]
 mov x9,#-2
.Lio_allocated_descriptor:
 str x9,[x23,#8]
 subs x22,x22,#1
 b.ne .Lio_allocate
 io_heap_return
.size md2asm_allocate_output_io_owners,.-md2asm_allocate_output_io_owners
.p2align 4
.global md2asm_release_output_io_requests
.type md2asm_release_output_io_requests,%function
md2asm_release_output_io_requests:
 io_heap_enter
.Lio_release:
 ldp w9,w10,[x21],#16
 cmp w9,#0
 csel x9,x19,x20,eq
 add x23,x9,w10,uxtw
 ldr x0,[x23]
 cbz x0,.Lio_owner_reject
 bl free
 str xzr,[x23]
 subs x22,x22,#1
 b.ne .Lio_release
 adrp x9,md2asm_output_io_request_counters
 add x9,x9,:lo12:md2asm_output_io_request_counters
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 io_heap_return
.size md2asm_release_output_io_requests,.-md2asm_release_output_io_requests
.Lio_owner_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 3
.Lio_owner_order:
 /* record 0=SP/1=GP, descriptor offset, element bytes, type<<8|rank */
 .word 1,8,4,0x0101
 .word 1,136,4,0x0201
 .word 1,264,8,0x0301
 .word 1,456,4,0x0101
 .word 1,520,4,0x0102
 .word 0,8,4,0x0101
 .word 0,136,4,0x0201
 .word 0,264,8,0x0301
 .word 0,616,4,0x0101
 .word 0,680,4,0x0101
 .word 0,392,8,0x0601
 .word 0,328,12,0x0601
 .word 0,72,4,0x0101
 .word 1,392,8,0x0601
 .word 1,328,12,0x0601
 .word 1,72,4,0x0101
.section .note.GNU-stack,"",%progbits

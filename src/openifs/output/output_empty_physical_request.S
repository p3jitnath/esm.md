// Solver contract skills/md2asm/references/openifs/output/output_empty_physical_request.md.
/* Empty physical request allocation from ALLOCATE_FPRQPHY.
 * x0 is a genuine TRQFP744 record, w1 is the domain count (1..8).
 * Eight source owners are malloc(1) allocated; there are no logical payload bytes.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_empty_physical_request
.type md2asm_allocate_empty_physical_request,%function
md2asm_allocate_empty_physical_request:
 cmp w1,#1
 b.lt .Lempty_reject
 cmp w1,#8
 b.gt .Lempty_reject
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
 sxtw x20,w1
 mrs x25,fpcr
 mrs x26,fpsr
 bl __errno_location
 mov x27,x0
 ldr w28,[x0]
 adrp x21,.Lempty_phy_descs
 add x21,x21,:lo12:.Lempty_phy_descs
 mov x22,#8
.Lempty_check:
 ldr w9,[x21],#16
 ldr x10,[x19,x9]
 cbnz x10,.Lempty_reject
 subs x22,x22,#1
 b.ne .Lempty_check
 str wzr,[x19]
 sub x21,x21,#128
 mov x22,#8
.Lempty_allocate:
 ldp w9,w10,[x21]
 ldp w11,w12,[x21,#8]
 add x21,x21,#16
 add x23,x19,w9,uxtw
 stp x10,x11,[sp,#112]
 str x12,[sp,#128]
 mov x0,#1
 bl malloc
 cbz x0,.Lempty_reject
 str x0,[x23]
 ldp x10,x11,[sp,#112]
 ldr x12,[sp,#128]
 str x10,[x23,#16]
 str x10,[x23,#32]
 lsl x9,x11,#32
 orr x9,x9,x12,lsl #40
 str x9,[x23,#24]
 mov x9,#1
 stp x9,x9,[x23,#40]
 str xzr,[x23,#56]
 mov x9,#-1
 cmp x11,#1
 b.eq .Lempty_descriptor_ready
 str x20,[x23,#56]
 str x20,[x23,#64]
 mov x10,#1
 stp x10,xzr,[x23,#72]
 sub x9,x9,x20
.Lempty_descriptor_ready:
 str x9,[x23,#8]
 subs x22,x22,#1
 b.ne .Lempty_allocate
 adrp x9,.Lempty_physical_count
 ldr x10,[x9,:lo12:.Lempty_physical_count]
 add x10,x10,#1
 str x10,[x9,:lo12:.Lempty_physical_count]
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
.size md2asm_allocate_empty_physical_request,.-md2asm_allocate_empty_physical_request
.global md2asm_empty_physical_request_count_get
.type md2asm_empty_physical_request_count_get,%function
md2asm_empty_physical_request_count_get:
 adrp x9,.Lempty_physical_count
 ldr x0,[x9,:lo12:.Lempty_physical_count]
 ret
.size md2asm_empty_physical_request_count_get,.-md2asm_empty_physical_request_count_get
.Lempty_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 3
.Lempty_phy_descs:
 /* descriptor offset, element bytes/span, rank, GNU type */
 .word 8,4,1,1
 .word 72,4,1,1
 .word 136,4,1,2
 .word 328,12,1,6
 .word 392,8,1,6
 .word 200,4,1,1
 .word 456,4,1,1
 .word 520,4,2,1
.bss
.p2align 3
.Lempty_physical_count: .zero 8
.section .note.GNU-stack,"",%progbits

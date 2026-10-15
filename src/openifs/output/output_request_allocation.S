// Solver contract skills/md2asm/references/openifs/output/output_request_allocation.md.
/* Selected request allocation from TYPE_FPRQDYNS, JPOSDYN686.
 * Canonical GNU12 integer/logical descriptors; payload is never initialized.
 * Only libc allocation and error-slot services are called.
 */
.arch armv8.2-a
.text
.p2align 4
.macro request_heap_enter
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mrs x25,fpcr
 mrs x26,fpsr
 bl __errno_location
 mov x27,x0
 ldr w28,[x0]
.endm
.macro request_heap_return
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
 add sp,sp,#160
 ret
.endm
.macro request_count index
 adrp x9,.Lrequest_counts
 add x9,x9,:lo12:.Lrequest_counts
 ldr x10,[x9,#(8*\index)]
 add x10,x10,#1
 str x10,[x9,#(8*\index)]
.endm
/* x0 Q1160, x1 domain-count i32*, x2 level-count i32*. */
.global md2asm_allocate_output_request
.type md2asm_allocate_output_request,%function
md2asm_allocate_output_request:
 ldrsw x3,[x1]
 ldrsw x4,[x2]
 cmp x3,#1
 b.lt .Lrequest_reject
 cmp x3,#8
 b.gt .Lrequest_reject
 mov x5,#1
 cmp x4,x5
 csel x4,x4,x5,ge
 cmp x4,#64
 b.gt .Lrequest_reject
 /* Save pointer arguments across the C error-slot service. */
 stp x3,x4,[sp,#-16]!
 request_heap_enter
 ldp x20,x21,[sp,#160]
 adrp x23,.Lrequest_descriptors
 add x23,x23,:lo12:.Lrequest_descriptors
 mov x22,#14
.Lrequest_check_unallocated:
 ldr w9,[x23]
 ldr x10,[x19,x9]
 cbnz x10,.Lrequest_reject
 add x23,x23,#16
 subs x22,x22,#1
 b.ne .Lrequest_check_unallocated
 str wzr,[x19]
 adrp x23,.Lrequest_descriptors
 add x23,x23,:lo12:.Lrequest_descriptors
 mov x22,#14
.Lrequest_allocate_next:
 ldp w9,w14,[x23]
 ldp w15,w16,[x23,#8]
 add x23,x23,#16
 add x24,x19,w9,uxtw
 mov x10,#686
 mov x11,#1
 mov x12,#1
 cmp w16,#0
 b.eq .Lrequest_dimensions_ready
 cmp w16,#1
 b.eq .Lrequest_level_dimensions
 cmp w16,#2
 b.eq .Lrequest_domain_dimensions
 mov x11,#3
 b .Lrequest_dimensions_ready
.Lrequest_level_dimensions:
 mov x10,x21
 mov x11,#686
 b .Lrequest_dimensions_ready
.Lrequest_domain_dimensions:
 mov x10,x20
 mov x11,x21
 mov x12,#686
.Lrequest_dimensions_ready:
 stp x10,x11,[sp,#112]
 str x12,[sp,#128]
 lsl x13,x14,#32
 orr x13,x13,x15,lsl #40
 str x13,[sp,#136]
 mul x0,x10,x11
 mul x0,x0,x12
 lsl x0,x0,#2
 bl malloc
 cbz x0,.Lrequest_reject
 str x0,[x24]
 mov x9,#4
 str x9,[x24,#16]
 str x9,[x24,#32]
 ldr x9,[sp,#136]
 str x9,[x24,#24]
 ubfx x14,x9,#32,#8
 ldp x10,x11,[sp,#112]
 ldr x12,[sp,#128]
 mov x13,#1
 stp x13,x13,[x24,#40]
 str x10,[x24,#56]
 mov x15,#-1
 cmp x14,#1
 b.eq .Lrequest_descriptor_ready
 ldr w16,[x23,#-4]
 cmp w16,#3
 cset x13,ne
 str x10,[x24,#64]
 str x13,[x24,#72]
 add x16,x11,x13
 sub x16,x16,#1
 str x16,[x24,#80]
 msub x15,x10,x13,x15
 cmp x14,#2
 b.eq .Lrequest_descriptor_ready
 mul x13,x10,x11
 str x13,[x24,#88]
 mov x16,#1
 stp x16,x12,[x24,#96]
 sub x15,x15,x13
.Lrequest_descriptor_ready:
 str x15,[x24,#8]
 subs x22,x22,#1
 b.ne .Lrequest_allocate_next
 request_count 0
 b .Lallocate_request_return
 .Lallocate_request_return:
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
 add sp,sp,#176
 ret
.size md2asm_allocate_output_request,.-md2asm_allocate_output_request
.global __type_fprqdyns_MOD_allocate_fprqdyn
.set __type_fprqdyns_MOD_allocate_fprqdyn,md2asm_allocate_output_request
/* x0 Q1160, all fourteen arrays allocated and exclusively owned. */
.p2align 4
.global md2asm_deallocate_output_request
.type md2asm_deallocate_output_request,%function
md2asm_deallocate_output_request:
 request_heap_enter
 adrp x23,.Lrequest_descriptors
 add x23,x23,:lo12:.Lrequest_descriptors
 mov x22,#14
.Lrequest_check_allocated:
 ldr w9,[x23]
 ldr x10,[x19,x9]
 cbz x10,.Lrequest_reject
 add x23,x23,#16
 subs x22,x22,#1
 b.ne .Lrequest_check_allocated
 str wzr,[x19]
 adrp x23,.Lrequest_descriptors
 add x23,x23,:lo12:.Lrequest_descriptors
 mov x22,#14
.Lrequest_free_next:
 ldr w9,[x23],#16
 add x24,x19,w9,uxtw
 ldr x0,[x24]
 bl free
 str xzr,[x24]
 subs x22,x22,#1
 b.ne .Lrequest_free_next
 add x9,x19,#1096
 stp xzr,xzr,[x9]
 stp xzr,xzr,[x9,#16]
 stp xzr,xzr,[x9,#32]
 stp xzr,xzr,[x9,#48]
 request_count 1
 request_heap_return
.size md2asm_deallocate_output_request,.-md2asm_deallocate_output_request
.global __type_fprqdyns_MOD_deallocate_fprqdyn
.set __type_fprqdyns_MOD_deallocate_fprqdyn,md2asm_deallocate_output_request
.p2align 4
.global md2asm_output_request_allocation_count_get
.type md2asm_output_request_allocation_count_get,%function
md2asm_output_request_allocation_count_get:
 cmp x0,#2
 b.hs .Lrequest_zero_count
 adrp x1,.Lrequest_counts
 add x1,x1,:lo12:.Lrequest_counts
 ldr x0,[x1,x0,lsl #3]
 ret
.Lrequest_zero_count:
 mov x0,#0
 ret
.size md2asm_output_request_allocation_count_get,.-md2asm_output_request_allocation_count_get
.Lrequest_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 3
.Lrequest_descriptors:
 .word 8,1,1,0
 .word 72,1,2,0
 .word 136,1,1,0
 .word 200,1,1,0
 .word 264,1,1,0
 .word 328,1,1,0
 .word 392,2,1,1
 .word 480,2,1,1
 .word 568,3,1,2
 .word 680,1,1,0
 .word 744,2,1,3
 .word 832,2,1,1
 .word 920,2,1,1
 .word 1008,2,1,1
.bss
.p2align 3
.Lrequest_counts: .zero 16
.section .note.GNU-stack,"",%progbits

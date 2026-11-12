/* Whole five-address spline basis; integer-only copies and GPU launch.
 * Frame1024. Input256..495, result512..735, context768..831,
 * record832..895, vector896..911, private counters912..927.
 * No CPU weather arithmetic. Contract: skills/md2fort-gpu/references/openifs/setup/complete_vertical_spline_calls.md.
 */
.arch armv8-a
.text
.p2align 4
.macro coarse_service name
 bl \name
 ldr x18,[sp,#96]
.endm
.global md2asm_vertical_spline_basis
.global md2asm_vertical_spline_basis_coarse_gpu
.type md2asm_vertical_spline_basis,%function
.type md2asm_vertical_spline_basis_coarse_gpu,%function
md2asm_vertical_spline_basis:
md2asm_vertical_spline_basis_coarse_gpu:
    cbz x0,.Lcoarse_reject
    cbz x1,.Lcoarse_reject
    cbz x2,.Lcoarse_reject
    cbz x3,.Lcoarse_reject
    cbz x4,.Lcoarse_reject
    orr x9,x0,x2
    tst x9,#3
    b.ne .Lcoarse_reject
    orr x9,x1,x3
    orr x9,x9,x4
    tst x9,#7
    b.ne .Lcoarse_reject
    ldr w5,[x0]
    ldr w6,[x2]
    sub w9,w5,#2
    cmp w9,#2
    b.hi .Lcoarse_reject
    cmp w6,w5
    b.lt .Lcoarse_reject
    cmp w6,#24
    b.gt .Lcoarse_reject
    add w7,w5,w6
    ldr x9,[x1]
    ubfx x10,x9,#52,#11
    cmp x10,#2047
    b.eq .Lcoarse_reject
 sub sp,sp,#1024
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 str x4,[sp,#144]
 str w6,[sp,#152]
 str w5,[sp,#156]
 stp d8,d9,[sp,#160]
 stp d10,d11,[sp,#176]
 stp d12,d13,[sp,#192]
 stp d14,d15,[sp,#208]
 mrs x8,fpcr
 mrs x9,fpsr
 stp x8,x9,[sp,#224]
 cbnz x8,.Lcoarse_runtime_failure
 coarse_service __errno_location
 str x0,[sp,#240]
 ldr w8,[x0]
 str w8,[sp,#248]
 coarse_service omp_in_parallel
 cbnz w0,.Lcoarse_runtime_failure
 coarse_service md2asm_openifs_gpu_prepare
 cbnz w0,.Lcoarse_runtime_failure
 add x19,sp,#256
 add x20,sp,#768
 ldr w22,[sp,#152]
 ldr w25,[sp,#156]
 ldr x23,[sp,#136]
 ldr x24,[sp,#144]
 mov x9,#0
.Lcoarse_zero_input:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#30
 b.lo .Lcoarse_zero_input
 stp w25,w22,[x19]
 ldr x10,[sp,#120]
 ldr x10,[x10]
 str x10,[x19,#8]
 add w10,w22,w25
 mov x9,#0
 add x11,x19,#16
.Lcoarse_copy_knots:
 ldr x12,[x23,x9,lsl #3]
 str x12,[x11,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lcoarse_copy_knots
 add x8,sp,#512
 mov x9,#0
.Lcoarse_zero_output:
 str xzr,[x8,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#28
 b.lo .Lcoarse_zero_output
 str x19,[sp,#896]
 str x8,[sp,#904]
 str xzr,[sp,#912]
 str xzr,[sp,#920]
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w8,#1
 str w8,[x20,#4]
 ldr w8,[sp,#232]
 str w8,[x20,#8]
 add x8,sp,#832
 str x8,[x20,#48]
 mov x9,#64
 str x9,[x20,#56]
 mov x8,#240
 mov x9,#224
 str x8,[sp,#832]
 str x9,[sp,#840]
 str xzr,[sp,#848]
 str xzr,[sp,#856]
 add x8,sp,#912
 mov x9,#8
 str x8,[sp,#864]
 str x9,[sp,#872]
 add x8,sp,#920
 str x8,[sp,#880]
 str x9,[sp,#888]
 ldp x8,x9,[sp,#224]
 msr fpcr,x8
 msr fpsr,x9
 ldr x21,[sp,#240]
 ldr w8,[sp,#248]
 str w8,[x21]
 adrp x0,.Lcoarse_entry
 add x0,x0,:lo12:.Lcoarse_entry
 add x1,sp,#896
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 coarse_service md2asm_openifs_gpu_launch
 cbnz w0,.Lcoarse_runtime_failure
 ldr w8,[x20]
 cbnz w8,.Lcoarse_runtime_failure
 ldr w8,[sp,#512]
 cbnz w8,.Lcoarse_no_commit
 add x10,sp,#544
 mov x9,#0
.Lcoarse_copy_weights:
 ldr x11,[x10,x9,lsl #3]
 str x11,[x24,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x22
 b.lo .Lcoarse_copy_weights
.Lcoarse_no_commit:
 ldr x8,[sp,#224]
 msr fpcr,x8
 ldr x9,[sp,#232]
 ldr w10,[sp,#776]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x21,[sp,#240]
 ldr w8,[sp,#248]
 str w8,[x21]
 ldp d8,d9,[sp,#160]
 ldp d10,d11,[sp,#176]
 ldp d12,d13,[sp,#192]
 ldp d14,d15,[sp,#208]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 ldr w0,[sp,#512]
 add sp,sp,#1024
 ret
.Lcoarse_runtime_failure:
 bl abort
 brk #0
.Lcoarse_reject:
 mov w0,#2
 ret
.size md2asm_vertical_spline_basis,.-md2asm_vertical_spline_basis
.size md2asm_vertical_spline_basis_coarse_gpu,.-md2asm_vertical_spline_basis_coarse_gpu
.section .rodata
.Lcoarse_entry:.asciz "md2asm_gpu_coarse_vertical_spline_basis"
.section .note.GNU-stack,"",%progbits

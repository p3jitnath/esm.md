// Direct assembly. Numerical and storage contract: ../../../../skills/md2asm-gpu/references/openifs/physics/monthly_gas_layer_amounts.md
// Original seven-address monthly gas child. The host performs storage work only.
.arch armv8-a
.text
.p2align 4
.macro monthly_service target
 bl \target
 ldr x18,[sp,#96]
.endm
.global md2asm_gpu_host_monthly_layer_amount
.type md2asm_gpu_host_monthly_layer_amount,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_climatology_layer
.type md2asm_climatology_layer,%function
md2asm_climatology_layer:
#endif
md2asm_gpu_host_monthly_layer_amount:
 sub sp,sp,#640
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 str x6,[sp,#176]
 add x19,sp,#128
 add x20,sp,#256
 add x21,sp,#320
 mrs x8,fpcr
 mrs x9,fpsr
 stp x8,x9,[sp,#104]
 cbnz x8,.Lmonthly_failure
 monthly_service __errno_location
 mov x22,x0
 ldr w8,[x22]
 str w8,[sp,#120]
 monthly_service omp_in_parallel
 cbnz w0,.Lmonthly_failure
 monthly_service md2asm_openifs_gpu_prepare
 cbnz w0,.Lmonthly_failure
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w8,#1
 str w8,[x20,#4]
 str x21,[x20,#48]
 mov x8,#48
 str x8,[x20,#56]
 stp xzr,xzr,[x21]
 stp xzr,xzr,[x21,#16]
 stp xzr,xzr,[x21,#32]
 ldr x9,[x19,#24]
 ldp x10,x11,[x9,#48]
 subs x10,x11,x10
 b.vs .Lmonthly_failure
 cmp x10,#512
 b.hi .Lmonthly_failure
 cbz x10,.Lmonthly_metadata_ready
 ldr x9,[x19,#48]
 ldp x10,x11,[x9,#48]
 subs x10,x11,x10
 b.vs .Lmonthly_failure
 adds x10,x10,#1
 b.vs .Lmonthly_failure
 cmp x10,#4096
 b.hi .Lmonthly_failure
 cbz x10,.Lmonthly_metadata_ready
 ldr x0,[x19,#24]
 mov x1,#1
 bl .Lmonthly_owner_span
 stp x0,x1,[x21]
 ldr x0,[x19,#40]
 mov x1,#3
 bl .Lmonthly_owner_span
 stp x0,x1,[x21,#16]
 ldr x0,[x19,#48]
 mov x1,#2
 bl .Lmonthly_owner_span
 stp x0,x1,[x21,#32]
.Lmonthly_metadata_ready:
 ldp x8,x9,[sp,#104]
 msr fpcr,x8
 msr fpsr,x9
 ldr w8,[sp,#120]
 str w8,[x22]
 adrp x0,.Lmonthly_entry
 add x0,x0,:lo12:.Lmonthly_entry
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 monthly_service md2asm_openifs_gpu_launch
 cbnz w0,.Lmonthly_failure
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#640
 ret
.size md2asm_gpu_host_monthly_layer_amount,.-md2asm_gpu_host_monthly_layer_amount
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_climatology_layer,.-md2asm_climatology_layer
#endif
// Return the complete signed-stride descriptor owner as its base and byte count.
.Lmonthly_owner_span:
 mov x5,x0
 mov x2,x1
 mov x3,#0
 mov x4,#0
 mov x9,x0
.Lmonthly_span_dimension:
 ldp x6,x7,[x9,#48]
 subs x11,x7,x6
 b.vs .Lmonthly_failure
 cmp x11,#0
 b.lt .Lmonthly_failure
 ldr x8,[x9,#40]
 cbz x8,.Lmonthly_failure
 lsl x10,x8,#3
 asr x12,x10,#3
 cmp x12,x8
 b.ne .Lmonthly_failure
 smulh x12,x10,x11
 mul x13,x10,x11
 asr x14,x13,#63
 cmp x12,x14
 b.ne .Lmonthly_failure
 tbnz x13,#63,.Lmonthly_span_negative
 adds x4,x4,x13
 b.vs .Lmonthly_failure
 b .Lmonthly_span_next
.Lmonthly_span_negative:
 adds x3,x3,x13
 b.vs .Lmonthly_failure
.Lmonthly_span_next:
 add x9,x9,#24
 subs x2,x2,#1
 b.ne .Lmonthly_span_dimension
 ldr x6,[x5]
 cbz x6,.Lmonthly_failure
 tbnz x6,#63,.Lmonthly_failure
 tst x6,#7
 b.ne .Lmonthly_failure
 adds x0,x6,x3
 b.vs .Lmonthly_failure
 tbnz x0,#63,.Lmonthly_failure
 subs x1,x4,x3
 b.vs .Lmonthly_failure
 adds x1,x1,#8
 b.vs .Lmonthly_failure
 adds x6,x0,x1
 b.cs .Lmonthly_failure
 tbnz x6,#63,.Lmonthly_failure
 ret
.Lmonthly_failure:
 bl abort
 brk #0
.section .rodata
.Lmonthly_entry:.asciz "md2asm_gpu_monthly_layer_amounts"
.section .note.GNU-stack,"",%progbits

// Original forecast ABI, pointer vectors and CUDA launch control only.
// Contract: skills/md2asm-gpu/references/openifs/pointwise_forecast_calls.md.
// Revision 3. Original call control with no weather arithmetic.
.text
.p2align 2
.macro GPU_FORECAST_CALL original,entry,count,is_increment
.global \original
.type \original,%function
\original:
 sub sp,sp,#256
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 stp x0,x1,[sp,#64]
 stp x2,x3,[sp,#80]
 stp x4,x5,[sp,#96]
 stp x6,x7,[sp,#112]
 ldp x9,x10,[sp,#256]
 stp x9,x10,[sp,#128]
 ldp x9,x10,[sp,#272]
 stp x9,x10,[sp,#144]
 .if \count == 14
 ldp x9,x10,[sp,#288]
 stp x9,x10,[sp,#160]
 .else
 ldr x9,[sp,#288]
 stp x9,xzr,[sp,#160]
 .endif
 stp xzr,xzr,[sp,#176]
 stp xzr,xzr,[sp,#192]
 stp xzr,xzr,[sp,#208]
 stp xzr,xzr,[sp,#224]
 mov w9,#1
 str w9,[sp,#180]
 add x19,sp,#64
 add x20,sp,#176
 .if \is_increment
 ldr x9,[sp,#88]
 cbz x9,.Lbridge_failure\@
 ldr w9,[x9]
 cbnz w9,.Lbridge_return\@
 .endif
 ldr x9,[sp,#64]
 cbz x9,.Lbridge_failure\@
 ldrsw x10,[x9,#5224]
 cbz x10,.Lbridge_return\@
 tbnz x10,#63,.Lbridge_failure\@
 ldrsw x11,[x9,#5144]
 cmp x11,#1
 b.lt .Lbridge_failure\@
 .if !\is_increment
 ldr x12,[sp,#80]
 ldr x13,[sp,#88]
 cbz x12,.Lbridge_failure\@
 cbz x13,.Lbridge_failure\@
 ldr w12,[x12]
 ldr w13,[x13]
 cmp w13,w12
 b.lt .Lbridge_return\@
 .endif
 mul x22,x10,x11
 add x22,x22,#127
 lsr x22,x22,#7
 mov w9,#0x7fffffff
 cmp x22,x9
 b.hi .Lbridge_failure\@
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#48]
 cbnz w0,.Lbridge_failure\@
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov x1,x19
 mov x2,x20
 mov w3,w22
 mov w4,#128
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#48]
 cbnz w0,.Lbridge_failure\@
 adrp x9,\original\()gpu_calls
 ldr x10,[x9,:lo12:\original\()gpu_calls]
 add x10,x10,#1
 str x10,[x9,:lo12:\original\()gpu_calls]
.Lbridge_return\@:
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.Lbridge_failure\@:
 bl abort
 brk #0
.size \original,.-\original
.section .rodata
.Lentry\@: .asciz "\entry"
.bss
.balign 8
.global \original\()gpu_calls
.hidden \original\()gpu_calls
\original\()gpu_calls: .zero 8
.text
.endm
GPU_FORECAST_CALL md2asm_drv_tendency_prepare_7358525,md2asm_gpu_gpmktend,14,0
.global gpmktend_
.set gpmktend_,md2asm_drv_tendency_prepare_7358525
.global gpmktend_gpu_calls
.hidden gpmktend_gpu_calls
.set gpmktend_gpu_calls,md2asm_drv_tendency_prepare_7358525gpu_calls
GPU_FORECAST_CALL gpaddslphy_,md2asm_gpu_gpaddslphy,13,1
.section .note.GNU-stack,"",%progbits

// Assembly-owned CUDA process services. No weather arithmetic is supplied here.
// Interface: skills/md2asm-gpu/references/openifs/cuda_runtime.md.
// Each public frame has 384 bytes, including 32 bytes of outgoing arguments.
// CUDA effects are isolated from the caller's numerical flags and errno.
.text
.p2align 2
.macro GPU_CALL target
 bl \target
 ldr x18,[sp,#128]
.endm
.macro GPU_ENTER
 sub sp,sp,#384
 stp x29,x30,[sp,#32]
 stp x19,x20,[sp,#48]
 stp x21,x22,[sp,#64]
 stp x23,x24,[sp,#80]
 stp x25,x26,[sp,#96]
 stp x27,x28,[sp,#112]
 str x18,[sp,#128]
 mrs x9,fpcr
 str x9,[sp,#136]
 mrs x24,fpsr
 str x24,[sp,#144]
 stp x0,x1,[sp,#160]
 stp x2,x3,[sp,#176]
 stp x4,x5,[sp,#192]
 add x29,sp,#32
 GPU_CALL __errno_location
 str x0,[sp,#152]
 ldr w25,[x0]
 str w25,[sp,#208]
 mov w26,#0
.endm
.macro GPU_RETURN
 ldr x9,[sp,#152]
 str w25,[x9]
 ldr x9,[sp,#136]
 msr fpcr,x9
 msr fpsr,x24
 mov w0,w26
 ldr x18,[sp,#128]
 ldp x19,x20,[sp,#48]
 ldp x21,x22,[sp,#64]
 ldp x23,x24,[sp,#80]
 ldp x25,x26,[sp,#96]
 ldp x27,x28,[sp,#112]
 ldp x29,x30,[sp,#32]
 add sp,sp,#384
 ret
.endm
.global md2asm_openifs_gpu_initialize
.type md2asm_openifs_gpu_initialize,%function
md2asm_openifs_gpu_initialize:
 GPU_ENTER
 ldp x19,x20,[sp,#160]
 ldr x9,[sp,#136]
 cbnz x9,.Linit_invalid
 cbz x19,.Linit_invalid
 adrp x9,.Lgpu_context
 ldr x10,[x9,:lo12:.Lgpu_context]
 cbnz x10,.Linit_invalid
 mov w0,#0
 GPU_CALL cuInit
 cbnz w0,.Linit_error
 add x0,sp,#216
 mov w1,w20
 GPU_CALL cuDeviceGet
 cbnz w0,.Linit_error
 add x0,sp,#220
 mov w1,#88
 ldr w2,[sp,#216]
 GPU_CALL cuDeviceGetAttribute
 cbnz w0,.Linit_error
 ldr w9,[sp,#220]
 cbz w9,.Linit_unsupported
 add x0,sp,#220
 mov w1,#100
 ldr w2,[sp,#216]
 GPU_CALL cuDeviceGetAttribute
 cbnz w0,.Linit_error
 ldr w9,[sp,#220]
 cbz w9,.Linit_unsupported
 str xzr,[sp,#224]
 str xzr,[sp,#232]
 add x0,sp,#224
 mov w1,#4
 ldr w2,[sp,#216]
 GPU_CALL cuCtxCreate_v2
 cbnz w0,.Linit_error
 add x0,sp,#232
 mov x1,x19
 GPU_CALL cuModuleLoad
 cbnz w0,.Linit_load_error
 add x0,sp,#240
 GPU_CALL cuCtxPopCurrent_v2
 cbnz w0,.Linit_pop_error
 adrp x9,.Lgpu_context
 ldr x10,[sp,#224]
 str x10,[x9,:lo12:.Lgpu_context]
 adrp x9,.Lgpu_module
 ldr x10,[sp,#232]
 str x10,[x9,:lo12:.Lgpu_module]
 GPU_RETURN
.Linit_load_error:
 mov w26,w0
 add x0,sp,#240
 GPU_CALL cuCtxPopCurrent_v2
 b .Linit_destroy
.Linit_pop_error:
 mov w26,w0
.Linit_destroy:
 ldr x0,[sp,#224]
 GPU_CALL cuCtxDestroy_v2
 GPU_RETURN
.Linit_invalid:
 mov w26,#1
 GPU_RETURN
.Linit_unsupported:
 mov w26,#801
 GPU_RETURN
.Linit_error:
 mov w26,w0
 GPU_RETURN
.size md2asm_openifs_gpu_initialize,.-md2asm_openifs_gpu_initialize

.global md2asm_openifs_gpu_launch
.type md2asm_openifs_gpu_launch,%function
md2asm_openifs_gpu_launch:
 GPU_ENTER
 ldp x19,x20,[sp,#160]
 ldr x21,[sp,#176]
 ldr w22,[sp,#184]
 ldr w23,[sp,#192]
 ldr w27,[sp,#200]
 mov w28,#0
 ldr x9,[sp,#136]
 cbnz x9,.Llaunch_invalid
 cbz x19,.Llaunch_invalid
 cbz x20,.Llaunch_invalid
 cbz x21,.Llaunch_invalid
 tst x20,#7
 b.ne .Llaunch_invalid
 tst x21,#7
 b.ne .Llaunch_invalid
 cbz w22,.Llaunch_invalid
 cbz w23,.Llaunch_invalid
 ldr w9,[x21,#4]
 cmp w9,#1
 b.ne .Llaunch_invalid
 adrp x9,.Lgpu_context
 ldr x0,[x9,:lo12:.Lgpu_context]
 cbz x0,.Llaunch_invalid
 GPU_CALL cuCtxPushCurrent_v2
 cbnz w0,.Llaunch_error
 mov w28,#1
 add x0,sp,#248
 adrp x9,.Lgpu_module
 ldr x1,[x9,:lo12:.Lgpu_module]
 mov x2,x19
 GPU_CALL cuModuleGetFunction
 cbnz w0,.Llaunch_error
 str wzr,[x21]
 str wzr,[x21,#8]
 str xzr,[x21,#16]
 stp x20,x21,[sp,#256]
 add x9,sp,#256
 add x10,sp,#264
 stp x9,x10,[sp,#272]
 str xzr,[sp]
 add x9,sp,#272
 str x9,[sp,#8]
 str xzr,[sp,#16]
 ldr x0,[sp,#248]
 mov w1,w22
 mov w2,#1
 mov w3,#1
 mov w4,w23
 mov w5,#1
 mov w6,#1
 mov w7,w27
 GPU_CALL cuLaunchKernel
 cbnz w0,.Llaunch_error
 GPU_CALL cuCtxSynchronize
 cbnz w0,.Llaunch_error
 ldr w9,[x21]
 cbnz w9,.Llaunch_invalid
 ldr w9,[x21,#8]
 orr x24,x24,x9
 ldr x9,[x21,#16]
 cbz x9,.Llaunch_pop
 and w25,w9,#255
 b .Llaunch_pop
.Llaunch_invalid:
 mov w26,#1
 b .Llaunch_pop
.Llaunch_error:
 mov w26,w0
.Llaunch_pop:
 cbz w28,.Llaunch_return
 add x0,sp,#240
 GPU_CALL cuCtxPopCurrent_v2
 cbnz w26,.Llaunch_return
 mov w26,w0
.Llaunch_return:
 GPU_RETURN
.size md2asm_openifs_gpu_launch,.-md2asm_openifs_gpu_launch

.global md2asm_openifs_gpu_finalize
.type md2asm_openifs_gpu_finalize,%function
md2asm_openifs_gpu_finalize:
 GPU_ENTER
 adrp x9,.Lgpu_context
 ldr x19,[x9,:lo12:.Lgpu_context]
 cbz x19,.Lfinal_return
 mov x0,x19
 GPU_CALL cuCtxPushCurrent_v2
 cbnz w0,.Lfinal_error
 adrp x9,.Lgpu_module
 ldr x0,[x9,:lo12:.Lgpu_module]
 cbz x0,.Lfinal_pop
 GPU_CALL cuModuleUnload
 mov w26,w0
.Lfinal_pop:
 add x0,sp,#240
 GPU_CALL cuCtxPopCurrent_v2
 cbnz w26,.Lfinal_destroy
 mov w26,w0
.Lfinal_destroy:
 mov x0,x19
 GPU_CALL cuCtxDestroy_v2
 cbnz w26,.Lfinal_clear
 mov w26,w0
.Lfinal_clear:
 adrp x9,.Lgpu_context
 str xzr,[x9,:lo12:.Lgpu_context]
 adrp x9,.Lgpu_module
 str xzr,[x9,:lo12:.Lgpu_module]
.Lfinal_return:
 GPU_RETURN
.Lfinal_error:
 mov w26,w0
 GPU_RETURN
.size md2asm_openifs_gpu_finalize,.-md2asm_openifs_gpu_finalize
.bss
.balign 8
.Lgpu_context: .zero 8
.Lgpu_module: .zero 8
.section .note.GNU-stack,"",%progbits

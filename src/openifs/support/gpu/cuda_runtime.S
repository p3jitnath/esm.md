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
.type mailbox_initialize_unlocked,%function
mailbox_initialize_unlocked:
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
 str xzr,[sp,#296]
 str xzr,[sp,#304]
 str xzr,[sp,#320]
 add x0,sp,#312
 ldr x1,[sp,#232]
 GPU_CALL cuModuleGetFunctionCount
 cbnz w0,.Linit_stream_error
 ldr w22,[sp,#312]
 cbz w22,.Linit_preloaded
 lsl x0,x22,#3
 GPU_CALL malloc
 cbz x0,.Linit_preload_memory
 mov x20,x0
 str x20,[sp,#320]
 mov w1,w22
 ldr x2,[sp,#232]
 GPU_CALL cuModuleEnumerateFunctions
 cbnz w0,.Linit_stream_error
 mov x21,#0
.Linit_preload_loop:
 ldr x0,[x20,x21,lsl #3]
 GPU_CALL cuFuncLoad
 cbnz w0,.Linit_stream_error
 add x21,x21,#1
 cmp x21,x22
 b.lo .Linit_preload_loop
 mov x0,x20
 GPU_CALL free
 str xzr,[sp,#320]
.Linit_preloaded:
 add x0,sp,#296
 mov w1,#1
 GPU_CALL cuStreamCreate
 cbnz w0,.Linit_stream_error
 add x0,sp,#304
 mov w1,#1
 GPU_CALL cuStreamCreate
 cbnz w0,.Linit_stream_error
 add x0,sp,#240
 GPU_CALL cuCtxPopCurrent_v2
 cbnz w0,.Linit_pop_error
 adrp x9,.Lgpu_context
 ldr x10,[sp,#224]
 str x10,[x9,:lo12:.Lgpu_context]
 adrp x9,.Lgpu_module
 ldr x10,[sp,#232]
 str x10,[x9,:lo12:.Lgpu_module]
 adrp x9,.Lordinary_stream
 ldr x10,[sp,#296]
 str x10,[x9,:lo12:.Lordinary_stream]
 adrp x9,.Lworker_stream
 ldr x10,[sp,#304]
 str x10,[x9,:lo12:.Lworker_stream]
 GPU_RETURN
.Linit_preload_memory:
 mov w0,#2
.Linit_stream_error:
 mov w26,w0
 ldr x0,[sp,#320]
 cbz x0,.Linit_cleanup_worker
 GPU_CALL free
 str xzr,[sp,#320]
.Linit_cleanup_worker:
 ldr x0,[sp,#304]
 cbz x0,.Linit_cleanup_ordinary
 GPU_CALL cuStreamDestroy_v2
.Linit_cleanup_ordinary:
 ldr x0,[sp,#296]
 cbz x0,.Linit_cleanup_module
 GPU_CALL cuStreamDestroy_v2
.Linit_cleanup_module:
 ldr x0,[sp,#232]
 GPU_CALL cuModuleUnload
 add x0,sp,#240
 GPU_CALL cuCtxPopCurrent_v2
 b .Linit_destroy
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
.size mailbox_initialize_unlocked,.-mailbox_initialize_unlocked


// One process-owned request lock; each public frame saves thread-local state first.
.macro MAILBOX_LOCK
 adrp x9,.Lrequest_lock
 add x9,x9,:lo12:.Lrequest_lock
1:
 ldaxr w10,[x9]
 cbnz w10,2f
 mov w10,#1
 stxr w11,w10,[x9]
 cbnz w11,1b
 b 3f
2:
 clrex
 yield
 b 1b
3:
.endm
.macro MAILBOX_UNLOCK
 adrp x9,.Lrequest_lock
 add x9,x9,:lo12:.Lrequest_lock
 stlr wzr,[x9]
.endm
.global md2asm_openifs_gpu_initialize
.type md2asm_openifs_gpu_initialize,%function
md2asm_openifs_gpu_initialize:
 GPU_ENTER
 MAILBOX_LOCK
 ldp x0,x1,[sp,#160]
 GPU_CALL mailbox_initialize_unlocked
 mov w26,w0
 MAILBOX_UNLOCK
 GPU_RETURN
.size md2asm_openifs_gpu_initialize,.-md2asm_openifs_gpu_initialize
.global md2asm_openifs_gpu_finalize
.type md2asm_openifs_gpu_finalize,%function
md2asm_openifs_gpu_finalize:
 GPU_ENTER
 MAILBOX_LOCK
 GPU_CALL mailbox_finalize_unlocked
 mov w26,w0
 MAILBOX_UNLOCK
 GPU_RETURN
.size md2asm_openifs_gpu_finalize,.-md2asm_openifs_gpu_finalize

.global md2asm_openifs_gpu_launch
.type md2asm_openifs_gpu_launch,%function
md2asm_openifs_gpu_launch:
 GPU_ENTER
 MAILBOX_LOCK
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
 cmp w22,#1
 b.ne .Lordinary_launch
 cmp w23,#1
 b.ne .Lordinary_launch
 cbnz w27,.Lordinary_launch
 mov x0,x19
 adrp x1,.Lhot_name
 add x1,x1,:lo12:.Lhot_name
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_soil
 mov x0,x19
 adrp x1,.Llake_hot_name
 add x1,x1,:lo12:.Llake_hot_name
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_lake
 mov x0,x19
 adrp x1,.Lstartup_hot_name
 add x1,x1,:lo12:.Lstartup_hot_name
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_startup
 mov x0,x19
 adrp x1,.Lscalar_name_4
 add x1,x1,:lo12:.Lscalar_name_4
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_canopy
 mov x0,x19
 adrp x1,.Lscalar_name_5
 add x1,x1,:lo12:.Lscalar_name_5
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_lake_energy
 mov x0,x19
 adrp x1,.Lscalar_name_6
 add x1,x1,:lo12:.Lscalar_name_6
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_output_numeric
 mov x0,x19
 adrp x1,.Lscalar_name_7
 add x1,x1,:lo12:.Lscalar_name_7
 GPU_CALL strcmp
 cbz w0,.Lscalar_kind_physical_setup_numeric
 b .Lordinary_launch
.Lscalar_kind_physical_setup_numeric:
 mov w9,#7
 b .Lscalar_kind_ready
.Lscalar_kind_output_numeric:
 mov w9,#6
 b .Lscalar_kind_ready
.Lscalar_kind_lake_energy:
 mov w9,#5
 b .Lscalar_kind_ready
.Lscalar_kind_canopy:
 mov w9,#4
 b .Lscalar_kind_ready
.Lscalar_kind_startup:
 mov w9,#3
 b .Lscalar_kind_ready
.Lscalar_kind_lake:
 mov w9,#2
 b .Lscalar_kind_ready
.Lscalar_kind_soil:
 mov w9,#1
 b .Lscalar_kind_ready
.Lscalar_kind_ready:
 str w9,[sp,#264]
 adrp x9,.Lworker_active
 ldr w10,[x9,:lo12:.Lworker_active]
 cbnz w10,.Lmailbox_request
 add x0,sp,#248
 adrp x9,.Lgpu_module
 ldr x1,[x9,:lo12:.Lgpu_module]
 adrp x2,.Lworker_name
 add x2,x2,:lo12:.Lworker_name
 GPU_CALL cuModuleGetFunction
 cbnz w0,.Llaunch_error
 adrp x9,.Lmailbox
 add x9,x9,:lo12:.Lmailbox
 stp xzr,xzr,[x9]
 stp xzr,xzr,[x9,#16]
 stp xzr,xzr,[x9,#32]
 stp xzr,xzr,[x9,#48]
 str x9,[sp,#256]
 add x10,sp,#256
 str x10,[sp,#272]
 adrp x9,.Lworker_stream
 ldr x9,[x9,:lo12:.Lworker_stream]
 str x9,[sp]
 add x9,sp,#272
 str x9,[sp,#8]
 str xzr,[sp,#16]
 ldr x0,[sp,#248]
 mov w1,#1
 mov w2,#1
 mov w3,#1
 mov w4,#1
 mov w5,#1
 mov w6,#1
 mov w7,#0
 GPU_CALL cuLaunchKernel
 cbnz w0,.Llaunch_error
 adrp x9,.Lworker_active
 mov w10,#1
 str w10,[x9,:lo12:.Lworker_active]
.Lmailbox_request:
 str wzr,[x21]
 str wzr,[x21,#8]
 str xzr,[x21,#16]
 adrp x9,.Lmailbox
 add x9,x9,:lo12:.Lmailbox
 ldr x10,[x9]
 add x10,x10,#1
 ldr w11,[sp,#264]
 str w11,[x9,#16]
 str wzr,[x9,#20]
 stp x20,x21,[x9,#24]
 stlr x10,[x9]
 mov w19,#8192
.Lmailbox_wait:
 add x11,x9,#8
 ldar x11,[x11]
 cmp x11,x10
 b.eq .Lmailbox_done
 yield
 subs w19,w19,#1
 b.ne .Lmailbox_wait
 adrp x9,.Lworker_stream
 ldr x0,[x9,:lo12:.Lworker_stream]
 GPU_CALL cuStreamQuery
 cmp w0,#600
 b.eq .Lmailbox_repoll
 cbnz w0,.Llaunch_error
 mov w0,#999
 b .Llaunch_error
.Lmailbox_repoll:
 mov w19,#8192
 adrp x9,.Lmailbox
 add x9,x9,:lo12:.Lmailbox
 ldr x10,[x9]
 b .Lmailbox_wait
.Lmailbox_done:
 ldr w0,[x9,#20]
 cbnz w0,.Llaunch_error
 b .Llaunch_status
.Lordinary_launch:
 // The request lock guarantees that no borrowed scalar owners remain in flight.
 // Join the idle worker before CUDA can resize resources for an ordinary launch.
 adrp x9,.Lworker_active
 ldr w10,[x9,:lo12:.Lworker_active]
 cbz w10,.Lordinary_worker_joined
 adrp x9,.Lmailbox
 add x9,x9,:lo12:.Lmailbox
 ldr x10,[x9]
 add x10,x10,#1
 str wzr,[x9,#16]
 str wzr,[x9,#20]
 stp xzr,xzr,[x9,#24]
 stlr x10,[x9]
 adrp x9,.Lworker_stream
 ldr x0,[x9,:lo12:.Lworker_stream]
 GPU_CALL cuStreamSynchronize
 cbnz w0,.Llaunch_error
 adrp x9,.Lworker_active
 str wzr,[x9,:lo12:.Lworker_active]
.Lordinary_worker_joined:
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
 adrp x9,.Lordinary_stream
 ldr x9,[x9,:lo12:.Lordinary_stream]
 str x9,[sp]
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
 adrp x9,.Lordinary_stream
 ldr x0,[x9,:lo12:.Lordinary_stream]
 GPU_CALL cuStreamSynchronize
 cbnz w0,.Llaunch_error
.Llaunch_status:
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
 MAILBOX_UNLOCK
 GPU_RETURN
.size md2asm_openifs_gpu_launch,.-md2asm_openifs_gpu_launch

.type mailbox_finalize_unlocked,%function
mailbox_finalize_unlocked:
 GPU_ENTER
 adrp x9,.Lgpu_context
 ldr x19,[x9,:lo12:.Lgpu_context]
 cbz x19,.Lfinal_return
 mov x0,x19
 GPU_CALL cuCtxPushCurrent_v2
 cbnz w0,.Lfinal_error
 adrp x9,.Lworker_active
 ldr w10,[x9,:lo12:.Lworker_active]
 cbz w10,.Lfinal_streams
 adrp x9,.Lmailbox
 add x9,x9,:lo12:.Lmailbox
 ldr x10,[x9]
 add x10,x10,#1
 str wzr,[x9,#16]
 str wzr,[x9,#20]
 stp xzr,xzr,[x9,#24]
 stlr x10,[x9]
 adrp x9,.Lworker_stream
 ldr x0,[x9,:lo12:.Lworker_stream]
 GPU_CALL cuStreamSynchronize
 mov w26,w0
.Lfinal_streams:
 adrp x9,.Lworker_stream
 ldr x0,[x9,:lo12:.Lworker_stream]
 cbz x0,.Lfinal_ordinary
 GPU_CALL cuStreamDestroy_v2
 cbnz w26,.Lfinal_ordinary
 mov w26,w0
.Lfinal_ordinary:
 adrp x9,.Lordinary_stream
 ldr x0,[x9,:lo12:.Lordinary_stream]
 cbz x0,.Lfinal_module
 GPU_CALL cuStreamDestroy_v2
 cbnz w26,.Lfinal_module
 mov w26,w0
.Lfinal_module:
 adrp x9,.Lgpu_module
 ldr x0,[x9,:lo12:.Lgpu_module]
 cbz x0,.Lfinal_pop
 GPU_CALL cuModuleUnload
 cbnz w26,.Lfinal_pop
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
 adrp x9,.Lordinary_stream
 str xzr,[x9,:lo12:.Lordinary_stream]
 adrp x9,.Lworker_stream
 str xzr,[x9,:lo12:.Lworker_stream]
 adrp x9,.Lworker_active
 str wzr,[x9,:lo12:.Lworker_active]
.Lfinal_return:
 GPU_RETURN
.Lfinal_error:
 mov w26,w0
 GPU_RETURN
.size mailbox_finalize_unlocked,.-mailbox_finalize_unlocked
.bss
.balign 8
.Lgpu_context: .zero 8
.Lgpu_module: .zero 8
.section .note.GNU-stack,"",%progbits

// Nonnumerical environment and module lifetime service.
// ABI and storage: skills/md2asm-gpu/references/openifs/cuda_runtime.md, revision 6.
.text
.p2align 2
.global md2asm_openifs_gpu_prepare
.type md2asm_openifs_gpu_prepare,%function
md2asm_openifs_gpu_prepare:
 GPU_ENTER
 MAILBOX_LOCK
 ldr x9,[sp,#136]
 cbnz x9,.Lprepare_invalid
 adrp x9,.Lgpu_context
 ldr x10,[x9,:lo12:.Lgpu_context]
 cbnz x10,.Lprepare_return
 adrp x0,.Lgpu_module_environment
 add x0,x0,:lo12:.Lgpu_module_environment
 GPU_CALL getenv
 cbz x0,.Lprepare_invalid
 mov w1,#0
 GPU_CALL mailbox_initialize_unlocked
 cbnz w0,.Lprepare_error
 adrp x0,:got:md2asm_openifs_gpu_finalize
 ldr x0,[x0,:got_lo12:md2asm_openifs_gpu_finalize]
 mov x1,xzr
 GPU_CALL on_exit
 cbz w0,.Lprepare_return
 GPU_CALL mailbox_finalize_unlocked
.Lprepare_invalid:
 mov w26,#1
 b .Lprepare_return
.Lprepare_error:
 mov w26,w0
.Lprepare_return:
 MAILBOX_UNLOCK
 GPU_RETURN
.size md2asm_openifs_gpu_prepare,.-md2asm_openifs_gpu_prepare
.section .rodata
.Lgpu_module_environment: .asciz "MD2ASM_OPENIFS_GPU_MODULE"

.bss
.balign 8
.Lordinary_stream: .zero 8
.Lworker_stream: .zero 8
.Lworker_active: .zero 4
.Lrequest_lock: .zero 4
.balign 64
.Lmailbox: .zero 64
.section .rodata
.Lhot_name: .asciz "md2asm_gpu_soil_water_cell"
.Lworker_name: .asciz "md2asm_gpu_soil_water_mailbox_worker"
.Llake_hot_name: .asciz "md2asm_gpu_lake_controller_cell"
.Lstartup_hot_name: .asciz "md2asm_gpu_startup_integer_cell"

.section .rodata
.Lscalar_name_4: .asciz "md2asm_gpu_canopy_light_cell"
.Lscalar_name_5: .asciz "md2asm_gpu_lake_energy_cell"
.Lscalar_name_6: .asciz "md2asm_gpu_output_numeric_cell"
.Lscalar_name_7: .asciz "md2asm_gpu_physical_setup_numeric_cell"

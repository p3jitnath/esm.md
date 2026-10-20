// Assembly-owned CUDA process services. No weather arithmetic is supplied here. // Contract: skills/md2asm-gpu/references/openifs/support/whole_scalar_mailbox_service.md.
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
 // Exact names use a fixed table. Empty slots retain ordinary dispatch.
 mov w9,#0x9dc5
 movk w9,#0x811c,lsl #16
 mov w12,#0x0193
 movk w12,#0x0100,lsl #16
 mov x10,x19
.Lbatch_hash:
 ldrb w11,[x10],#1
 cbz w11,.Lbatch_probe_start
 eor w9,w9,w11
 mul w9,w9,w12
 b .Lbatch_hash
.Lbatch_probe_start:
 and w14,w9,#511
 adrp x13,.Lbatch_table
 add x13,x13,:lo12:.Lbatch_table
.Lbatch_probe:
 mov x15,#24
 madd x15,x14,x15,x13
 ldr x17,[x15,#8]
 cbz x17,.Lordinary_launch
 ldr w16,[x15]
 cmp w16,w9
 b.ne .Lbatch_probe_next
 mov x10,x19
.Lbatch_compare:
 ldrb w0,[x10],#1
 ldrb w1,[x17],#1
 cmp w0,w1
 b.ne .Lbatch_probe_next
 cbnz w0,.Lbatch_compare
 ldr w9,[x15,#16]
 b .Lscalar_kind_ready
.Lbatch_probe_next:
 add w14,w14,#1
 and w14,w14,#511
 b .Lbatch_probe
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
// ABI and storage: skills/md2asm-gpu/references/openifs/cuda_runtime.md, revision 4.
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

.section .rodata
.Lscalar_name_8: .asciz "md2asm_gpu_r23_setup_span"

.section .rodata
.balign 8
.Lbatch_table:
 .quad 3677020672,.Lbatch_name_116,116
 .quad 343634433,.Lbatch_name_56,56
 .quad 0,0,0
 .quad 0,0,0
 .quad 3114221060,.Lbatch_name_45,45
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1979979784,.Lbatch_name_107,107
 .quad 2125273609,.Lbatch_name_101,101
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3588779535,.Lbatch_name_7,7
 .quad 0,0,0
 .quad 1685302801,.Lbatch_name_148,148
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3164727320,.Lbatch_name_123,123
 .quad 0,0,0
 .quad 0,0,0
 .quad 3608997915,.Lbatch_name_13,13
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1405807143,.Lbatch_name_1,1
 .quad 2920705575,.Lbatch_name_115,115
 .quad 2532469801,.Lbatch_name_117,117
 .quad 651683882,.Lbatch_name_53,53
 .quad 0,0,0
 .quad 0,0,0
 .quad 1278666285,.Lbatch_name_71,71
 .quad 1605649965,.Lbatch_name_157,157
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1355633714,.Lbatch_name_76,76
 .quad 0,0,0
 .quad 2276272180,.Lbatch_name_102,102
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2265467961,.Lbatch_name_24,24
 .quad 3075435066,.Lbatch_name_153,153
 .quad 0,0,0
 .quad 0,0,0
 .quad 138678845,.Lbatch_name_38,38
 .quad 719187517,.Lbatch_name_51,51
 .quad 0,0,0
 .quad 0,0,0
 .quad 4036490305,.Lbatch_name_39,39
 .quad 0,0,0
 .quad 0,0,0
 .quad 3316256324,.Lbatch_name_144,144
 .quad 0,0,0
 .quad 3415313990,.Lbatch_name_139,139
 .quad 2736638535,.Lbatch_name_55,55
 .quad 2292523592,.Lbatch_name_126,126
 .quad 3938883657,.Lbatch_name_64,64
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1194778190,.Lbatch_name_74,74
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1271745619,.Lbatch_name_77,77
 .quad 0,0,0
 .quad 2192384085,.Lbatch_name_97,97
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2117196377,.Lbatch_name_140,140
 .quad 0,0,0
 .quad 0,0,0
 .quad 3746190428,.Lbatch_name_20,20
 .quad 3688514652,.Lbatch_name_41,41
 .quad 1730155100,.Lbatch_name_62,62
 .quad 635323999,.Lbatch_name_150,150
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1350434403,.Lbatch_name_119,119
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1548663914,.Lbatch_name_109,109
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1000757875,.Lbatch_name_111,111
 .quad 2707370100,.Lbatch_name_58,58
 .quad 0,0,0
 .quad 2108495990,.Lbatch_name_100,100
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3590413436,.Lbatch_name_2,2
 .quad 0,0,0
 .quad 0,0,0
 .quad 3601349247,.Lbatch_name_54,54
 .quad 3207159424,.Lbatch_name_30,30
 .quad 2247058049,.Lbatch_name_84,84
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1115074697,.Lbatch_name_59,59
 .quad 0,0,0
 .quad 1751740043,.Lbatch_name_34,34
 .quad 2388595339,.Lbatch_name_57,57
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2410934417,.Lbatch_name_90,90
 .quad 0,0,0
 .quad 0,0,0
 .quad 3874971284,.Lbatch_name_141,141
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1261888666,.Lbatch_name_70,70
 .quad 246663322,.Lbatch_name_105,105
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3911169696,.Lbatch_name_44,44
 .quad 3606425248,.Lbatch_name_114,114
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2992631980,.Lbatch_name_149,149
 .quad 4050527405,.Lbatch_name_155,155
 .quad 0,0,0
 .quad 0,0,0
 .quad 3448281776,.Lbatch_name_22,22
 .quad 0,0,0
 .quad 0,0,0
 .quad 4228574899,.Lbatch_name_40,40
 .quad 0,0,0
 .quad 1907294389,.Lbatch_name_63,63
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1178000571,.Lbatch_name_73,73
 .quad 3127135931,.Lbatch_name_83,83
 .quad 377701564,.Lbatch_name_129,129
 .quad 0,0,0
 .quad 195650239,.Lbatch_name_66,66
 .quad 1254968000,.Lbatch_name_78,78
 .quad 1065377985,.Lbatch_name_6,6
 .quad 2175606466,.Lbatch_name_96,96
 .quad 601091779,.Lbatch_name_113,113
 .quad 4196567746,.Lbatch_name_152,152
 .quad 3552780485,.Lbatch_name_127,127
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3563780809,.Lbatch_name_16,16
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2021871326,.Lbatch_name_32,32
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2091718371,.Lbatch_name_99,99
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2315458791,.Lbatch_name_4,4
 .quad 2599688935,.Lbatch_name_10,10
 .quad 717584104,.Lbatch_name_88,88
 .quad 1392898281,.Lbatch_name_138,138
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 971705077,.Lbatch_name_28,28
 .quad 0,0,0
 .quad 3795753719,.Lbatch_name_25,25
 .quad 2979595000,.Lbatch_name_104,104
 .quad 776529144,.Lbatch_name_110,110
 .quad 0,0,0
 .quad 0,0,0
 .quad 3461395708,.Lbatch_name_29,29
 .quad 0,0,0
 .quad 2394156798,.Lbatch_name_91,91
 .quad 0,0,0
 .quad 2222212864,.Lbatch_name_36,36
 .quad 1921559809,.Lbatch_name_26,26
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1245111047,.Lbatch_name_69,69
 .quad 0,0,0
 .quad 0,0,0
 .quad 3746171658,.Lbatch_name_122,122
 .quad 0,0,0
 .quad 1322078476,.Lbatch_name_67,67
 .quad 3892945164,.Lbatch_name_128,128
 .quad 262049550,.Lbatch_name_23,23
 .quad 3767544591,.Lbatch_name_132,132
 .quad 804929805,.Lbatch_name_142,142
 .quad 3545480460,.Lbatch_name_156,156
 .quad 1388246802,.Lbatch_name_47,47
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2310268703,.Lbatch_name_92,92
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1161222952,.Lbatch_name_72,72
 .quad 589317416,.Lbatch_name_143,143
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2158828847,.Lbatch_name_95,95
 .quad 0,0,0
 .quad 4016180017,.Lbatch_name_118,118
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1473077047,.Lbatch_name_81,81
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2106921277,.Lbatch_name_112,112
 .quad 3959097662,.Lbatch_name_151,151
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 235029316,.Lbatch_name_12,12
 .quad 1527991108,.Lbatch_name_14,14
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1103264589,.Lbatch_name_61,61
 .quad 2561401678,.Lbatch_name_146,146
 .quad 0,0,0
 .quad 2074940752,.Lbatch_name_98,98
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 786451292,.Lbatch_name_3,3
 .quad 0,0,0
 .quad 1814476638,.Lbatch_name_19,19
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3363855719,.Lbatch_name_158,158
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 877387117,.Lbatch_name_89,89
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3318481777,.Lbatch_name_160,160
 .quad 0,0,0
 .quad 0,0,0
 .quad 1871612788,.Lbatch_name_33,33
 .quad 1228333428,.Lbatch_name_68,68
 .quad 3393409909,.Lbatch_name_145,145
 .quad 0,0,0
 .quad 0,0,0
 .quad 1305300857,.Lbatch_name_79,79
 .quad 409028986,.Lbatch_name_21,21
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3232092032,.Lbatch_name_46,46
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1246559620,.Lbatch_name_43,43
 .quad 3601752964,.Lbatch_name_52,52
 .quad 0,0,0
 .quad 0,0,0
 .quad 66609544,.Lbatch_name_15,15
 .quad 408255880,.Lbatch_name_106,106
 .quad 0,0,0
 .quad 47014283,.Lbatch_name_49,49
 .quad 2293491084,.Lbatch_name_93,93
 .quad 0,0,0
 .quad 0,0,0
 .quad 3618953615,.Lbatch_name_60,60
 .quad 0,0,0
 .quad 2241350545,.Lbatch_name_8,8
 .quad 1761559441,.Lbatch_name_134,134
 .quad 0,0,0
 .quad 55519124,.Lbatch_name_37,37
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2142051228,.Lbatch_name_94,94
 .quad 0,0,0
 .quad 0,0,0
 .quad 2335237023,.Lbatch_name_159,159
 .quad 0,0,0
 .quad 2863817633,.Lbatch_name_108,108
 .quad 2669164961,.Lbatch_name_131,131
 .quad 0,0,0
 .quad 1456299428,.Lbatch_name_82,82
 .quad 0,0,0
 .quad 3549218214,.Lbatch_name_133,133
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 4067570604,.Lbatch_name_65,65
 .quad 0,0,0
 .quad 0,0,0
 .quad 4015650735,.Lbatch_name_42,42
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1700638131,.Lbatch_name_137,137
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3162986942,.Lbatch_name_124,124
 .quad 170836927,.Lbatch_name_27,27
 .quad 1357404096,.Lbatch_name_120,120
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1372411333,.Lbatch_name_75,75
 .quad 3550344134,.Lbatch_name_48,48
 .quad 2293049799,.Lbatch_name_103,103
 .quad 2750666182,.Lbatch_name_125,125
 .quad 982691785,.Lbatch_name_50,50
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 714094033,.Lbatch_name_130,130
 .quad 1857290194,.Lbatch_name_85,85
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3050376156,.Lbatch_name_5,5
 .quad 3333050845,.Lbatch_name_18,18
 .quad 3825003484,.Lbatch_name_86,86
 .quad 4258450399,.Lbatch_name_11,11
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 1624258019,.Lbatch_name_121,121
 .quad 0,0,0
 .quad 1299162597,.Lbatch_name_154,154
 .quad 1288523238,.Lbatch_name_80,80
 .quad 307872743,.Lbatch_name_87,87
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 2277098476,.Lbatch_name_135,135
 .quad 91720173,.Lbatch_name_9,9
 .quad 0,0,0
 .quad 3362233327,.Lbatch_name_147,147
 .quad 0,0,0
 .quad 1979723761,.Lbatch_name_136,136
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3309579768,.Lbatch_name_17,17
 .quad 0,0,0
 .quad 0,0,0
 .quad 1973957115,.Lbatch_name_31,31
 .quad 0,0,0
 .quad 0,0,0
 .quad 0,0,0
 .quad 3505179135,.Lbatch_name_35,35
.Lbatch_name_1: .asciz "md2asm_gpu_soil_water_cell"
.Lbatch_name_2: .asciz "md2asm_gpu_lake_controller_cell"
.Lbatch_name_3: .asciz "md2asm_gpu_startup_integer_cell"
.Lbatch_name_4: .asciz "md2asm_gpu_canopy_light_cell"
.Lbatch_name_5: .asciz "md2asm_gpu_lake_energy_cell"
.Lbatch_name_6: .asciz "md2asm_gpu_output_numeric_cell"
.Lbatch_name_7: .asciz "md2asm_gpu_physical_setup_numeric_cell"
.Lbatch_name_8: .asciz "md2asm_gpu_r23_setup_span"
.Lbatch_name_9: .asciz "md2asm_gpu_add_aerosol_optics"
.Lbatch_name_10: .asciz "md2asm_gpu_adding_ica_sw"
.Lbatch_name_11: .asciz "md2asm_gpu_calc_ice_optics_fu_lw"
.Lbatch_name_12: .asciz "md2asm_gpu_calc_ice_optics_fu_sw"
.Lbatch_name_13: .asciz "md2asm_gpu_calc_liq_optics_socrates"
.Lbatch_name_14: .asciz "md2asm_gpu_calc_reflectance_transmittance_sw"
.Lbatch_name_15: .asciz "md2asm_gpu_cloud_generator"
.Lbatch_name_16: .asciz "md2asm_gpu_cloud_optics"
.Lbatch_name_17: .asciz "md2asm_gpu_coarse_vertical_spline_basis"
.Lbatch_name_18: .asciz "md2asm_gpu_coarse_vertical_spline_knots"
.Lbatch_name_19: .asciz "md2asm_gpu_complete_legendre_analysis"
.Lbatch_name_20: .asciz "md2asm_gpu_cpqtuv"
.Lbatch_name_21: .asciz "md2asm_gpu_cucalln_provisional_state"
.Lbatch_name_22: .asciz "md2asm_gpu_cum_cloud_cover_exp_ran"
.Lbatch_name_23: .asciz "md2asm_gpu_dynamical_configuration"
.Lbatch_name_24: .asciz "md2asm_gpu_ec_phys_lslphy"
.Lbatch_name_25: .asciz "md2asm_gpu_forecast_clock_pairs"
.Lbatch_name_26: .asciz "md2asm_gpu_forecast_event_time"
.Lbatch_name_27: .asciz "md2asm_gpu_generate_column_exp_ran"
.Lbatch_name_28: .asciz "md2asm_gpu_gpgrp"
.Lbatch_name_29: .asciz "md2asm_gpu_gprt"
.Lbatch_name_30: .asciz "md2asm_gpu_hybrid_coordinate_setup"
.Lbatch_name_31: .asciz "md2asm_gpu_model_time_and_forcing"
.Lbatch_name_32: .asciz "md2asm_gpu_nonorographic_parameter_fields"
.Lbatch_name_33: .asciz "md2asm_gpu_orographic_parameter_field"
.Lbatch_name_34: .asciz "md2asm_gpu_pressure_standard_complete_loop"
.Lbatch_name_35: .asciz "md2asm_gpu_r23_complete_output_boundaries"
.Lbatch_name_36: .asciz "md2asm_gpu_r23_complete_output_metadata"
.Lbatch_name_37: .asciz "md2asm_gpu_r23_complete_output_norms"
.Lbatch_name_38: .asciz "md2asm_gpu_r23_complete_spectral_fit"
.Lbatch_name_39: .asciz "md2asm_gpu_r23_complete_transform_spans"
.Lbatch_name_40: .asciz "md2asm_gpu_r23_fft992"
.Lbatch_name_41: .asciz "md2asm_gpu_r23_fft992_qpassf"
.Lbatch_name_42: .asciz "md2asm_gpu_r23_fft992_rpassf"
.Lbatch_name_43: .asciz "md2asm_gpu_r23_parameter_carbon_assimilation_parameter_fields_phase"
.Lbatch_name_44: .asciz "md2asm_gpu_r23_parameter_one_cell_carbon_assimilation_fields_phase"
.Lbatch_name_45: .asciz "md2asm_gpu_r23_parameter_soil_parameter_fields_phase"
.Lbatch_name_46: .asciz "md2asm_gpu_r23_parameter_soil_texture_average_fields_phase"
.Lbatch_name_47: .asciz "md2asm_gpu_r23_parameter_surface_exchange_parameter_fields_phase"
.Lbatch_name_48: .asciz "md2asm_gpu_r23_parameter_surface_radiation_parameter_fields_phase"
.Lbatch_name_49: .asciz "md2asm_gpu_r23_parameter_urban_surface_parameter_fields_phase"
.Lbatch_name_50: .asciz "md2asm_gpu_r23_parameter_vegetation_parameter_fields_phase"
.Lbatch_name_51: .asciz "md2asm_gpu_r23_parameter_vegetation_root_fraction_fields_phase"
.Lbatch_name_52: .asciz "md2asm_gpu_r23_ppflev_complete"
.Lbatch_name_53: .asciz "md2asm_gpu_r23_ppintp_complete"
.Lbatch_name_54: .asciz "md2asm_gpu_r23_remaining_pressure_spans"
.Lbatch_name_55: .asciz "md2asm_gpu_r23_spectral_uvtvd"
.Lbatch_name_56: .asciz "md2asm_gpu_r23_spectral_vdtuv"
.Lbatch_name_57: .asciz "md2asm_gpu_radaca"
.Lbatch_name_58: .asciz "md2asm_gpu_radact"
.Lbatch_name_59: .asciz "md2asm_gpu_radact_legendre"
.Lbatch_name_60: .asciz "md2asm_gpu_raddiag"
.Lbatch_name_61: .asciz "md2asm_gpu_radflux_layer"
.Lbatch_name_62: .asciz "md2asm_gpu_radheatn"
.Lbatch_name_63: .asciz "md2asm_gpu_restart_frequency"
.Lbatch_name_64: .asciz "md2asm_gpu_rrtm_gas_optical_depth"
.Lbatch_name_65: .asciz "md2asm_gpu_rrtm_prepare_gases"
.Lbatch_name_66: .asciz "md2asm_gpu_rrtm_setcoef_140gp"
.Lbatch_name_67: .asciz "md2asm_gpu_rrtm_taumol1"
.Lbatch_name_68: .asciz "md2asm_gpu_rrtm_taumol10"
.Lbatch_name_69: .asciz "md2asm_gpu_rrtm_taumol11"
.Lbatch_name_70: .asciz "md2asm_gpu_rrtm_taumol12"
.Lbatch_name_71: .asciz "md2asm_gpu_rrtm_taumol13"
.Lbatch_name_72: .asciz "md2asm_gpu_rrtm_taumol14"
.Lbatch_name_73: .asciz "md2asm_gpu_rrtm_taumol15"
.Lbatch_name_74: .asciz "md2asm_gpu_rrtm_taumol16"
.Lbatch_name_75: .asciz "md2asm_gpu_rrtm_taumol2"
.Lbatch_name_76: .asciz "md2asm_gpu_rrtm_taumol3"
.Lbatch_name_77: .asciz "md2asm_gpu_rrtm_taumol4"
.Lbatch_name_78: .asciz "md2asm_gpu_rrtm_taumol5"
.Lbatch_name_79: .asciz "md2asm_gpu_rrtm_taumol6"
.Lbatch_name_80: .asciz "md2asm_gpu_rrtm_taumol7"
.Lbatch_name_81: .asciz "md2asm_gpu_rrtm_taumol8"
.Lbatch_name_82: .asciz "md2asm_gpu_rrtm_taumol9"
.Lbatch_name_83: .asciz "md2asm_gpu_selected_spline_inverse"
.Lbatch_name_84: .asciz "md2asm_gpu_solver_mcica_sw"
.Lbatch_name_85: .asciz "md2asm_gpu_spline_inverse_from_lu"
.Lbatch_name_86: .asciz "md2asm_gpu_spline_lu_factor"
.Lbatch_name_87: .asciz "md2asm_gpu_spline_operator_matrix"
.Lbatch_name_88: .asciz "md2asm_gpu_spline_upper_inverse"
.Lbatch_name_89: .asciz "md2asm_gpu_srtm_setcoef"
.Lbatch_name_90: .asciz "md2asm_gpu_srtm_taumol16"
.Lbatch_name_91: .asciz "md2asm_gpu_srtm_taumol17"
.Lbatch_name_92: .asciz "md2asm_gpu_srtm_taumol18"
.Lbatch_name_93: .asciz "md2asm_gpu_srtm_taumol19"
.Lbatch_name_94: .asciz "md2asm_gpu_srtm_taumol20"
.Lbatch_name_95: .asciz "md2asm_gpu_srtm_taumol21"
.Lbatch_name_96: .asciz "md2asm_gpu_srtm_taumol22"
.Lbatch_name_97: .asciz "md2asm_gpu_srtm_taumol23"
.Lbatch_name_98: .asciz "md2asm_gpu_srtm_taumol24"
.Lbatch_name_99: .asciz "md2asm_gpu_srtm_taumol25"
.Lbatch_name_100: .asciz "md2asm_gpu_srtm_taumol26"
.Lbatch_name_101: .asciz "md2asm_gpu_srtm_taumol27"
.Lbatch_name_102: .asciz "md2asm_gpu_srtm_taumol28"
.Lbatch_name_103: .asciz "md2asm_gpu_srtm_taumol29"
.Lbatch_name_104: .asciz "md2asm_gpu_state_increment"
.Lbatch_name_105: .asciz "md2asm_gpu_state_update"
.Lbatch_name_106: .asciz "md2asm_gpu_update_fields"
.Lbatch_name_107: .asciz "md2asm_gpu_vertical_coordinate_setup"
.Lbatch_name_108: .asciz "md2asm_gpu_visibility_extinction"
.Lbatch_name_109: .asciz "md2asm_gpu_wind_tendency"
.Lbatch_name_110: .asciz "openifs_call_sl_parallel_prepare"
.Lbatch_name_111: .asciz "openifs_call_sl_prognostic_prepare"
.Lbatch_name_112: .asciz "openifs_call_sl_slextpol_ptx"
.Lbatch_name_113: .asciz "openifs_cpglag_ptx"
.Lbatch_name_114: .asciz "openifs_gp_spv_ptx"
.Lbatch_name_115: .asciz "openifs_gpgeo_ptx"
.Lbatch_name_116: .asciz "openifs_gpgrgeo_ptx"
.Lbatch_name_117: .asciz "openifs_gphpre_ptx"
.Lbatch_name_118: .asciz "openifs_gpinislb_ptx"
.Lbatch_name_119: .asciz "openifs_gpnorm1_ptx"
.Lbatch_name_120: .asciz "openifs_gppwc_ptx"
.Lbatch_name_121: .asciz "openifs_gptf1_ptx"
.Lbatch_name_122: .asciz "openifs_gptf2_ptx"
.Lbatch_name_123: .asciz "openifs_lacdyn_ptx"
.Lbatch_name_124: .asciz "openifs_laiddi_ptx"
.Lbatch_name_125: .asciz "openifs_laitli_ptx"
.Lbatch_name_126: .asciz "openifs_laitre_gfl_ptx"
.Lbatch_name_127: .asciz "openifs_laitre_gmv_ptx"
.Lbatch_name_128: .asciz "openifs_laitri_ptx"
.Lbatch_name_129: .asciz "openifs_laitri_weno_ptx"
.Lbatch_name_130: .asciz "openifs_laitriqm3d_ptx"
.Lbatch_name_131: .asciz "openifs_laminmaxint_ptx"
.Lbatch_name_132: .asciz "openifs_lapinea_ptx"
.Lbatch_name_133: .asciz "openifs_lapineb_ptx"
.Lbatch_name_134: .asciz "openifs_larcina_ptx"
.Lbatch_name_135: .asciz "openifs_larcinb_ptx"
.Lbatch_name_136: .asciz "openifs_larmes_xyz_ptx"
.Lbatch_name_137: .asciz "openifs_lascaw_cla_ptx"
.Lbatch_name_138: .asciz "openifs_lascaw_clo_ptx"
.Lbatch_name_139: .asciz "openifs_lascaw_ptx"
.Lbatch_name_140: .asciz "openifs_lascaw_vintw_ptx"
.Lbatch_name_141: .asciz "openifs_lassie_ptx"
.Lbatch_name_142: .asciz "openifs_lasure_ptx"
.Lbatch_name_143: .asciz "openifs_lattes_ptx"
.Lbatch_name_144: .asciz "openifs_lattex_dnt_ptx"
.Lbatch_name_145: .asciz "openifs_lattex_ptx"
.Lbatch_name_146: .asciz "openifs_lavabo_ptx"
.Lbatch_name_147: .asciz "openifs_pfixer_ptx"
.Lbatch_name_148: .asciz "openifs_qmfixer_ptx"
.Lbatch_name_149: .asciz "openifs_sigam_ptx"
.Lbatch_name_150: .asciz "openifs_simplico_ptx"
.Lbatch_name_151: .asciz "openifs_sitnu_ptx"
.Lbatch_name_152: .asciz "openifs_slextpol_ptx"
.Lbatch_name_153: .asciz "openifs_spchor_ptx"
.Lbatch_name_154: .asciz "openifs_spcimpfinit_ptx"
.Lbatch_name_155: .asciz "openifs_spcimpfpost_ptx"
.Lbatch_name_156: .asciz "openifs_spcimpfsolve_ptx"
.Lbatch_name_157: .asciz "openifs_spfilt_ptx"
.Lbatch_name_158: .asciz "openifs_verder_ptx"
.Lbatch_name_159: .asciz "openifs_verdisint_ptx"
.Lbatch_name_160: .asciz "openifs_verint_ptx"

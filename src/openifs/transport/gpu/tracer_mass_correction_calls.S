// Contract: skills/md2fort-gpu/references/openifs/transport/parallel_tracer_mass_correction.md.
.text
.p2align 2
.macro CONST reg,value
 movz \reg,#((\value)&65535)
 .if ((\value)>>16)
 movk \reg,#(((\value)>>16)&65535),lsl #16
 .endif
.endm
.macro BEGIN name,count
.global \name
.type \name,%function
\name:
 sub sp,sp,#4096
 stp x29,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 add x29,sp,#128
 stp x0,x1,[sp,#256]
 stp x2,x3,[sp,#272]
 stp x4,x5,[sp,#288]
 stp x6,x7,[sp,#304]
 .if \count>8
 add x9,sp,#4096
 add x10,sp,#320
 mov w11,#(\count-8)
.Lstack_copy\@:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Lstack_copy\@
 .endif
 add x19,sp,#256
 add x20,sp,#640
 add x21,sp,#1024
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
 mov x9,x21
 mov w10,#96
.Lzero_record\@:
 stp xzr,xzr,[x9],#16
 subs w10,w10,#1
 b.ne .Lzero_record\@
.endm
.macro RECORD bytes
 str x21,[x20,#48]
 mov x9,#\bytes
 str x9,[x20,#56]
.endm
.macro SERVICE target
 str x0,[sp,#3112]
 mrs x9,fpcr
 str x9,[sp,#3072]
 mrs x9,fpsr
 str x9,[sp,#3080]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#3088]
 ldr w9,[x0]
 str w9,[sp,#3096]
 ldr x0,[sp,#3112]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#3120]
 ldr x9,[sp,#3088]
 ldr w10,[sp,#3096]
 str w10,[x9]
 ldr x9,[sp,#3072]
 msr fpcr,x9
 ldr x9,[sp,#3080]
 msr fpsr,x9
 ldr x0,[sp,#3120]
.endm
.macro SERIAL_CALLER
 SERVICE __oml_mod_MOD_oml_in_parallel
 cbnz w0,.Ldraft_failure
.endm
.macro BYTES destination,left,right
 umulh x17,\left,\right
 cbnz x17,.Ldraft_failure
 mul \destination,\left,\right
 lsr x17,\destination,#60
 cbnz x17,.Ldraft_failure
 lsl \destination,\destination,#3
.endm
.macro ALLOC bytes
 str \bytes,[x20,#40]
 cbz \bytes,.Lallocated\@
 mov x0,\bytes
 SERVICE malloc
 cbz x0,.Ldraft_failure
 str x0,[x20,#32]
.Lallocated\@:
.endm
.macro FINISH name,entry,counter,release=0
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_owner_copy
 add x0,x0,:lo12:.Ltrm_owner_copy
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#256
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_pressure_exp
 add x0,x0,:lo12:.Ltrm_pressure_exp
 mov x1,x19
 mov x2,x20
 mov w3,#86
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_pressure_correction
 add x0,x0,:lo12:.Ltrm_pressure_correction
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_boundary_mass
 add x0,x0,:lo12:.Ltrm_boundary_mass
 mov x1,x19
 mov x2,x20
 mov w3,#86
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_mass_norm
 add x0,x0,:lo12:.Ltrm_mass_norm
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_weights
 add x0,x0,:lo12:.Ltrm_weights
 mov x1,x19
 mov x2,x20
 mov w3,#86
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_weight_norm
 add x0,x0,:lo12:.Ltrm_weight_norm
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_limiter
 add x0,x0,:lo12:.Ltrm_limiter
 mov x1,x19
 mov x2,x20
 mov w3,#86
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 adrp x0,.Ltrm_commit
 add x0,x0,:lo12:.Ltrm_commit
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#32
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 ldr x9,[x20,#32]
 CONST x10,2574208
 add x9,x9,x10
 ldr x9,[x9,#8]
 cbz x9,.Ltrm_no_fallback\@
 adrp x0,.Ltrm_serial
 add x0,x0,:lo12:.Ltrm_serial
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
.Ltrm_no_fallback\@:
 .if \release
 ldr x0,[x20,#32]
 cbz x0,.Lreleased\@
 SERVICE free
.Lreleased\@:
 .endif
 adrp x9,:got:\counter
 ldr x9,[x9,:got_lo12:\counter]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#224]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldp x29,x30,[sp,#128]
 add sp,sp,#4096
 ret
.size \name,.-\name
.section .rodata
.Lentry\@: .asciz "\entry"
.bss
.balign 8
.global \counter
.hidden \counter
\counter: .zero 8
.text
.endm
.macro ALIAS name,target
.global \name
.set \name,\target
.endm
BEGIN gpu_trmfixers,16
 RECORD 1536
 SERIAL_CALLER
 ldr x9,[x19,#0]
 str x9,[sp,#512]
 ldr x9,[x19,#8]
 str x9,[sp,#520]
 ldr x9,[x19,#16]
 str x9,[sp,#528]
 ldr x9,[x19,#24]
 str x9,[sp,#536]
 ldr x9,[x19,#32]
 add x9,x9,#184
 str x9,[sp,#544]
 ldr x9,[x19,#40]
 str x9,[sp,#552]
 ldr x9,[x19,#56]
 str x9,[sp,#560]
 ldr x9,[x19,#64]
 str x9,[sp,#568]
 ldr x9,[x19,#72]
 str x9,[sp,#576]
 ldr x9,[x19,#80]
 str x9,[sp,#584]
 ldr x9,[x19,#88]
 str x9,[sp,#592]
 ldr x9,[x19,#96]
 str x9,[sp,#600]
 ldr x9,[x19,#104]
 str x9,[sp,#608]
 ldr x9,[x19,#112]
 str x9,[sp,#616]
 ldr x9,[x19,#120]
 str x9,[sp,#624]
 add x0,sp,#512
 add x1,x21,#256
 bl md2asm_gpu_fill_trmfixers_qmf_record
 ldr x18,[sp,#224]
 cbnz x0,.Ldraft_failure
 ldr x9,[x21,#256]
 str x9,[x21,#0]
 ldr x9,[x21,#264]
 str x9,[x21,#8]
 ldr x9,[x21,#272]
 str x9,[x21,#16]
 ldr x9,[x21,#280]
 str x9,[x21,#24]
 CONST x9,1359320
 str x9,[x21,#32]
 ldr x9,[x21,#296]
 str x9,[x21,#40]
 ldr x9,[x21,#304]
 str x9,[x21,#56]
 ldr x9,[x21,#312]
 str x9,[x21,#64]
 ldr x9,[x21,#320]
 str x9,[x21,#72]
 ldr x9,[x21,#328]
 str x9,[x21,#80]
 ldr x9,[x21,#336]
 str x9,[x21,#88]
 ldr x9,[x21,#344]
 str x9,[x21,#96]
 ldr x9,[x21,#352]
 str x9,[x21,#104]
 ldr x9,[x21,#360]
 str x9,[x21,#112]
 ldr x9,[x21,#368]
 str x9,[x21,#120]
 mov x9,#4
 str x9,[x21,#48]
 mov x9,#128
 str x9,[x21,#128]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 str x9,[x21,#136]
 mov x9,#4
 str x9,[x21,#144]
 CONST x25,9869184
 ALLOC x25
 FINISH gpu_trmfixers,openifs_trmfixers_parallel_prepare,gpu_trmfixers_launches,1
 ALIAS md2asm_trmfixers_address_r2_7358525,gpu_trmfixers
.Ldraft_failure:
 bl abort
 brk #0

.pushsection .rodata
.Ltrm_owner_copy: .asciz "openifs_trmfixers_parallel_copy_owners"
.Ltrm_pressure_exp: .asciz "openifs_trmfixers_parallel_pressure_exp"
.Ltrm_pressure_correction: .asciz "openifs_trmfixers_parallel_pressure_correction"
.Ltrm_boundary_mass: .asciz "openifs_trmfixers_parallel_boundary_mass"
.Ltrm_mass_norm: .asciz "openifs_trmfixers_parallel_mass_norm"
.Ltrm_weights: .asciz "openifs_trmfixers_parallel_weights"
.Ltrm_weight_norm: .asciz "openifs_trmfixers_parallel_weight_norm"
.Ltrm_limiter: .asciz "openifs_trmfixers_parallel_limiter"
.Ltrm_commit: .asciz "openifs_trmfixers_parallel_commit"
.Ltrm_serial: .asciz "openifs_trmfixers_ptx"
.popsection
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2asm-gpu/references/openifs/transport/tracer_mass_correction.md.
// Original ABI storage/launch draft from original_host_contract.md revision1.
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
 add x21,sp,#768
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
 mov x9,x21
 mov w10,#64
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
 str x0,[sp,#1960]
 mrs x9,fpcr
 str x9,[sp,#1920]
 mrs x9,fpsr
 str x9,[sp,#1928]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#1936]
 ldr w9,[x0]
 str w9,[sp,#1944]
 ldr x0,[sp,#1960]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#1968]
 ldr x9,[sp,#1936]
 ldr w10,[sp,#1944]
 str w10,[x9]
 ldr x9,[sp,#1920]
 msr fpcr,x9
 ldr x9,[sp,#1928]
 msr fpsr,x9
 ldr x0,[sp,#1968]
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
// Exact accepted QMFIXER storage-only record preparation.
.global md2asm_gpu_fill_trmfixers_qmf_record
.type md2asm_gpu_fill_trmfixers_qmf_record,%function
md2asm_gpu_fill_trmfixers_qmf_record:
 sub sp,sp,#4096
 stp x29,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 mov x19,x0
 mov x21,x1
 CONST x9,17096
 str x9,[x21,#0]
 CONST x9,1560
 str x9,[x21,#8]
 CONST x9,1359136
 str x9,[x21,#32]
 CONST x9,13232
 str x9,[x21,#40]
 CONST x9,627456
 str x9,[x21,#48]
 CONST x9,3764736
 str x9,[x21,#56]
 CONST x9,11486104
 str x9,[x21,#64]
 CONST x9,1800
 str x9,[x21,#72]
 CONST x9,49536
 str x9,[x21,#80]
 CONST x9,16512
 str x9,[x21,#88]
 CONST x9,2509824
 str x9,[x21,#96]
 CONST x9,1882368
 str x9,[x21,#104]
 mov x9,#120
 str x9,[x21,#120]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbnz w9,.Ldraft_failure
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 str x9,[x21,#128]
 mov x10,#8
 str x10,[x21,#136]
 ldr x9,[x19]
 CONST x10,9816
 ldr x9,[x9,x10]
 str x9,[x21,#144]
 mov x10,#16384
 str x10,[x21,#152]
 adrp x9,:got:md2asm_exponential_native_calls_storage
 ldr x9,[x9,:got_lo12:md2asm_exponential_native_calls_storage]
 str x9,[x21,#160]
 cbz x9,.Lcounter_160
 mov x10,#8
 str x10,[x21,#168]
.Lcounter_160:
 adrp x9,:got:md2asm_product_sum_fast_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_fast_calls]
 str x9,[x21,#176]
 cbz x9,.Lcounter_176
 mov x10,#8
 str x10,[x21,#184]
.Lcounter_176:
 adrp x9,:got:md2asm_product_sum_wide_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_wide_calls]
 str x9,[x21,#192]
 cbz x9,.Lcounter_192
 mov x10,#8
 str x10,[x21,#200]
.Lcounter_192:
 mov x26,x21
 add x21,x21,#256
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 cbz x9,.Ldraft_failure
 str x9,[x21,#56]
 mov x9,#4
 str x9,[x21,#64]
 adrp x9,:got:__yomct0_MOD_lelam
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lelam]
 cbz x9,.Ldraft_failure
 str x9,[x21,#72]
 mov x9,#4
 str x9,[x21,#80]
 adrp x9,:got:__tpm_fields_MOD_f
 ldr x9,[x9,:got_lo12:__tpm_fields_MOD_f]
 cbz x9,.Ldraft_failure
 ldr x9,[x9]
 cbz x9,.Ldraft_failure
 ldr x9,[x9,#152]
 cbz x9,.Ldraft_failure
 str x9,[x21,#88]
 mov x9,#256
 str x9,[x21,#96]
 adrp x9,:got:__tpm_geometry_MOD_g
 ldr x9,[x9,:got_lo12:__tpm_geometry_MOD_g]
 cbz x9,.Ldraft_failure
 ldr x9,[x9]
 cbz x9,.Ldraft_failure
 ldr x9,[x9,#0]
 cbz x9,.Ldraft_failure
 str x9,[x21,#104]
 mov x9,#128
 str x9,[x21,#112]
 adrp x9,:got:__tpm_dim_MOD_r
 ldr x9,[x9,:got_lo12:__tpm_dim_MOD_r]
 cbz x9,.Ldraft_failure
 ldr x9,[x9]
 cbz x9,.Ldraft_failure
 add x9,x9,#20
 cbz x9,.Ldraft_failure
 str x9,[x21,#120]
 mov x9,#4
 str x9,[x21,#128]
 adrp x9,:got:__tpm_trans_MOD_nproma
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_nproma]
 cbz x9,.Ldraft_failure
 str x9,[x21,#136]
 mov x9,#4
 str x9,[x21,#144]
 adrp x9,:got:__tpm_trans_MOD_ngpblks
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_ngpblks]
 cbz x9,.Ldraft_failure
 str x9,[x21,#152]
 mov x9,#4
 str x9,[x21,#160]
 adrp x9,:got:gpu_gpnorm1_actual_calls
 ldr x9,[x9,:got_lo12:gpu_gpnorm1_actual_calls]
 cbz x9,.Ldraft_failure
 str x9,[x21,#168]
 mov x9,#8
 str x9,[x21,#176]
 mov x21,x26
 ldr x9,[x19]
 ldr x9,[x9,#3240]
 cbz x9,.Ldraft_failure
 ldr x10,[x9,#176]
 ldr x11,[x9,#184]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,#1
 b.lt .Ldraft_failure
 CONST x12,2000001
 cmp x11,x12
 b.hi .Ldraft_failure
 lsl x11,x11,#3
 str x11,[x21,#584]
 ldr x10,[x9,#112]
 ldr x11,[x9,#120]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,#1
 b.lt .Ldraft_failure
 CONST x12,2000001
 cmp x11,x12
 b.hi .Ldraft_failure
 lsl x11,x11,#3
 str x11,[x21,#592]
 mov x0,#0
 b .Lfiller_return
.Ldraft_failure:
 mov x0,#1
.Lfiller_return:
 ldr x18,[sp,#224]
 ldp x27,x28,[sp,#208]
 ldp x25,x26,[sp,#192]
 ldp x23,x24,[sp,#176]
 ldp x21,x22,[sp,#160]
 ldp x19,x20,[sp,#144]
 ldp x29,x30,[sp,#128]
 add sp,sp,#4096
 ret
.weak md2asm_exponential_native_calls_storage
.weak md2asm_product_sum_fast_calls
.weak md2asm_product_sum_wide_calls
.section .note.GNU-stack,"",%progbits

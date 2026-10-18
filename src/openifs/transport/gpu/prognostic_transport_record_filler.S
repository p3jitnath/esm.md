// Direct assembly. Numerical and storage contract: ../../../../skills/md2asm-gpu/references/openifs/transport/semi_lagrangian_transport.md
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
 sub sp,sp,#8192
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
 add x9,sp,#8192
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
 mov w10,#256
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
 str x0,[sp,#6184]
 mrs x9,fpcr
 str x9,[sp,#6144]
 mrs x9,fpsr
 str x9,[sp,#6152]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#6160]
 ldr w9,[x0]
 str w9,[sp,#6168]
 ldr x0,[sp,#6184]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#6192]
 ldr x9,[sp,#6160]
 ldr w10,[sp,#6168]
 str w10,[x9]
 ldr x9,[sp,#6144]
 msr fpcr,x9
 ldr x9,[sp,#6152]
 msr fpsr,x9
 ldr x0,[sp,#6192]
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
 add sp,sp,#8192
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
// Storage-only interface derived from the accepted LAPINEB host record body.
.global md2asm_gpu_fill_prognostic_departure_record
.type md2asm_gpu_fill_prognostic_departure_record,%function
md2asm_gpu_fill_prognostic_departure_record:
 sub sp,sp,#8192
 stp x29,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 add x29,sp,#128
 mov x19,x0
 mov x21,x1
 CONST x9,17096
 str x9,[x21,#0]
 CONST x9,1560
 str x9,[x21,#8]
 CONST x9,4275088
 str x9,[x21,#16]
 CONST x9,4
 str x9,[x21,#32]
 CONST x9,4
 str x9,[x21,#40]
 CONST x9,1800
 str x9,[x21,#48]
 CONST x9,4
 str x9,[x21,#64]
 CONST x9,4
 str x9,[x21,#72]
 mov x9,#288
 str x9,[x21,#288]
 ldr x9,[x19]
 ldrsw x22,[x9,#5144]
 cmp x22,#1
 b.lt .Ldraft_failure
 cmp x22,#1024
 b.gt .Ldraft_failure
 ldrsw x23,[x9,#5224]
 cmp x23,#4
 b.lt .Ldraft_failure
 cmp x23,#256
 b.gt .Ldraft_failure
 mul x24,x22,x23
 lsl x9,x24,#2
 str x9,[x21,#80]
 lsl x9,x24,#4
 str x9,[x21,#88]
 str x9,[x21,#96]
 ldr x25,[x19,#16]
 CONST x9,1564136
 add x26,x25,x9
 add x27,x25,#192

 ldrsw x10,[x26,#6472]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x24,x10
 str x11,[x21,#104]
 ldrsw x10,[x26,#6644]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x24,x10
 str x11,[x21,#112]
 ldrsw x10,[x26,#6808]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x24,x10
 str x11,[x21,#176]
 ldrsw x10,[x26,#6828]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x24,x10
 str x11,[x21,#184]
 lsl x9,x24,#3
 str x9,[x21,#168]
 str x9,[x21,#256]
 str x9,[x21,#264]
 ldr x9,[x19,#8]

 ldrsw x10,[x9,#1360]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x24,x10
 str x11,[x21,#200]
 ldrsw x10,[x9,#1364]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x22,x10
 str x11,[x21,#208]
 ldrsw x10,[x27,#64]
 cmp x10,#0
 b.lt .Ldraft_failure
 BYTES x11,x24,x10
 str x11,[x21,#216]
 add x9,sp,#1,lsl #12
 add x9,x9,#1024
 mov x10,#20
.Lzero_child_vector:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lzero_child_vector
 ldr x9,[x19]
 str x9,[sp,#5120]
 ldr x9,[x19,#8]
 str x9,[sp,#5128]
 CONST x9,4232912
 add x9,x25,x9
 str x9,[sp,#5136]
 CONST x9,4233032
 add x9,x25,x9
 str x9,[sp,#5144]
 add x9,x25,#8
 str x9,[sp,#5152]
 str x26,[sp,#5160]
 ldr x9,[x19,#48]
 add x9,x9,#1016
 str x9,[sp,#5184]
 add x0,sp,#1,lsl #12
 add x0,x0,#1024
 add x1,x21,#1024
 bl md2asm_gpu_fill_lapineb_transport_record
 cbnz w0,.Ldraft_failure
 ldr x9,[x21,#1152]
 str x9,[x21,#160]
 ldr x9,[x21,#1176]
 str x9,[x21,#232]
 ldr x9,[x21,#1184]
 str x9,[x21,#240]
 ldr x9,[x21,#1192]
 str x9,[x21,#248]
 ldr x9,[x21,#1296]
 str x9,[x21,#272]
 ldr x9,[x21,#1304]
 str x9,[x21,#280]
 adrp x9,:got:__yomcst_MOD_rd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 str x9,[x21,#296]
 mov x10,#8
 str x10,[x21,#304]
 adrp x9,:got:__yomct0_MOD_lrplane
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lrplane]
 str x9,[x21,#312]
 mov x10,#4
 str x10,[x21,#320]
 adrp x9,:got:gpu_lapineb_actual_counts
 ldr x9,[x9,:got_lo12:gpu_lapineb_actual_counts]
 str x9,[x21,#328]
 mov x10,#16
 str x10,[x21,#336]
 ldr x9,[x19]

 ldr x10,[x9,#3240]
 str x10,[x21,#352]
 mov x11,#512
 str x11,[x21,#360]
 ldr x10,[x9,#3264]
 str x10,[x21,#368]
 mov x11,#216
 str x11,[x21,#376]
 ldr x10,[x9,#3248]
 str x10,[x21,#384]
 mov x11,#320
 str x11,[x21,#392]
 ldr x10,[x9,#3256]
 str x10,[x21,#400]
 mov x11,#2176
 str x11,[x21,#408]
 ldr x9,[x21,#352]
 cbz x9,.Ldraft_failure
 add x0,x9,#448
 bl .Lreal_owner
 str x0,[x21,#416]
 str x1,[x21,#424]
 ldr x9,[x21,#368]
 cbz x9,.Ldraft_failure
 ldr w9,[x9,#52]
 cmp w9,#1
 b.hi .Ldraft_failure
 cbz w9,.Lfe_records_done
 ldr x9,[x21,#384]
 cbz x9,.Ldraft_failure
 add x0,x9,#256
 bl .Lreal_owner
 str x0,[x21,#432]
 str x1,[x21,#440]
 ldr x9,[x21,#400]
 cbz x9,.Ldraft_failure
 add x9,x9,#240
 ldr x0,[x9]
 ldr x10,[x9,#48]
 ldr x11,[x9,#56]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,#1
 b.lt .Ldraft_failure
 cmp x11,#1024
 b.gt .Ldraft_failure
 ldr x10,[x9,#72]
 ldr x12,[x9,#80]
 sub x12,x12,x10
 add x12,x12,#1
 cmp x12,#1
 b.lt .Ldraft_failure
 cmp x12,#1024
 b.gt .Ldraft_failure
 BYTES x1,x11,x12
 str x0,[x21,#448]
 str x1,[x21,#456]
.Lfe_records_done:
 ldr x9,[x19]
 CONST x10,8472
 add x9,x9,x10
 ldr x28,[x9]
 cbz x28,.Ldraft_failure
 ldr x10,[x9,#48]
 ldr x11,[x9,#56]
 sub x12,x11,x10
 add x12,x12,#1
 cmp x12,#1
 b.lt .Ldraft_failure
 CONST x13,1000000
 cmp x12,x13
 b.gt .Ldraft_failure
 mov x13,#1472
 mul x12,x12,x13
 str x28,[x21,#464]
 str x12,[x21,#472]
 ldr x9,[x19,#72]
 ldrsw x9,[x9]
 cmp x9,x10
 b.lt .Ldraft_failure
 cmp x9,x11
 b.gt .Ldraft_failure
 sub x9,x9,x10
 madd x28,x9,x13,x28
 add x0,x28,#960
 bl .Lreal_owner
 str x0,[x21,#480]
 str x1,[x21,#488]
 add x0,x28,#1024
 bl .Lreal_owner
 str x0,[x21,#496]
 str x1,[x21,#504]
 CONST x9,800248
 ldr x10,[x25,x9]
 str x10,[x21,#528]
 mov x9,#368
 str x9,[x21,#536]
 cbz x10,.Ldraft_failure
 ldr w9,[x10,#56]
 cbz w9,.Lmoisture_records_done
 CONST x9,800032
 ldr x10,[x25,x9]
 str x10,[x21,#512]
 mov x9,#368
 str x9,[x21,#520]
.Lmoisture_records_done:
 ldr x9,[x19,#8]
 ldrsw x10,[x9,#1420]
 cmp x10,#1
 b.lt .Ldraft_failure
 cmp x10,#64
 b.gt .Ldraft_failure
 add x10,x10,x10,lsl #1
 ldrsw x11,[x27]
 cmp x11,#0
 b.lt .Ldraft_failure
 cmp x11,#2163
 b.gt .Ldraft_failure
 add x10,x10,x11
 add x10,x10,#11
 BYTES x28,x24,x10
 mov x10,#48
 madd x28,x22,x10,x28
 CONST x10,536870912
 cmp x28,x10
 b.hi .Ldraft_failure
 lsl x10,x24,#4
 add x28,x28,x10
 add x28,x28,x22,lsl #3
 add x28,x28,#8192
 add x28,x28,#1024
 mov x1,x28
 mov x0,#0
 b .Lfiller_return
.Ldraft_failure:
 mov x0,#1
 mov x1,#0
.Lfiller_return:
 ldr x18,[sp,#224]
 ldp x27,x28,[sp,#208]
 ldp x25,x26,[sp,#192]
 ldp x23,x24,[sp,#176]
 ldp x21,x22,[sp,#160]
 ldp x19,x20,[sp,#144]
 ldp x29,x30,[sp,#128]
 add sp,sp,#8192
 ret
.size md2asm_gpu_fill_prognostic_departure_record,.-md2asm_gpu_fill_prognostic_departure_record
.Lreal_owner:
 ldr x9,[x0,#48]
 ldr x10,[x0,#56]
 sub x10,x10,x9
 add x10,x10,#1
 cmp x10,#1
 b.lt .Ldraft_failure
 CONST x11,2000001
 cmp x10,x11
 b.gt .Ldraft_failure
 lsl x1,x10,#3
 ldr x0,[x0]
 ret

.section .note.GNU-stack,"",%progbits

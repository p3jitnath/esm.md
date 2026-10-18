/* skills/md2asm-gpu/references/openifs/trajectories/trajectory_wind_preparation.md */
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
BEGIN gpu_lavent,19
 RECORD 512
 SERIAL_CALLER
 CONST x9,17096
 str x9,[x21,#0]
 CONST x9,1560
 str x9,[x21,#8]
 CONST x9,175976
 str x9,[x21,#16]
 CONST x9,13232
 str x9,[x21,#24]
 CONST x9,904
 str x9,[x21,#32]
 CONST x9,4
 str x9,[x21,#40]
 CONST x9,4
 str x9,[x21,#48]
 CONST x9,4
 str x9,[x21,#56]
 CONST x9,76
 str x9,[x21,#64]
 CONST x9,4
 str x9,[x21,#72]
 CONST x9,8
 str x9,[x21,#80]
 CONST x9,3648
 str x9,[x21,#88]
 CONST x9,3840
 str x9,[x21,#96]
 CONST x9,18240
 str x9,[x21,#104]
 CONST x9,65664
 str x9,[x21,#112]
 CONST x9,88896
 str x9,[x21,#120]
 CONST x9,29376
 str x9,[x21,#128]
 CONST x9,3648
 str x9,[x21,#136]
 CONST x9,3648
 str x9,[x21,#144]
mov x9,#152
 str x9,[x21,#152]
 adrp x9,:got:__yomct3_MOD_nstep
 ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
 str x9,[x21,#160]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 str x9,[x21,#168]
 adrp x9,:got:gpu_lavent_source_counts
 ldr x9,[x9,:got_lo12:gpu_lavent_source_counts]
 str x9,[x21,#176]
 mov x9,#16
 str x9,[x21,#184]
 ldr x22,[x19]
 cbz x22,.Ldraft_failure
 tst x22,#7
 b.ne .Ldraft_failure
 ldr x9,[x19,#56]
 cbz x9,.Ldraft_failure
 ldrsw x23,[x9]
 cmp x23,#1
 b.lt .Ldraft_failure
 cmp x23,#86
 b.gt .Ldraft_failure
 ldr x9,[x22,#3248]
 cbz x9,.Ldraft_failure
 tst x9,#7
 b.ne .Ldraft_failure
 str x9,[x21,#192]
 mov x10,#320
 str x10,[x21,#200]
 ldr x9,[x9]
 str x9,[x21,#208]
 mov x10,#160
 str x10,[x21,#216]
 CONST x9,8472
 add x0,x22,x9
 mov x2,#1472
 bl .Ltrajectory_declared_rank1_owner
 str x0,[x21,#224]
 str x1,[x21,#232]
 mov x24,x0
 mov x25,x1
 sub x9,x23,#1
 mov x10,#1472
 mul x9,x9,x10
 cmp x9,x25
 b.hi .Ldraft_failure
 sub x10,x25,x9
 cmp x10,#1472
 b.lo .Ldraft_failure
 add x26,x24,x9
 add x0,x26,#128
 mov x2,#8
 bl .Ltrajectory_declared_rank1_owner
 str x0,[x21,#240]
 str x1,[x21,#248]
 add x0,x26,#192
 mov x2,#8
 bl .Ltrajectory_declared_rank1_owner
 str x0,[x21,#256]
 str x1,[x21,#264]
 add x0,x26,#384
 mov x2,#8
 bl .Ltrajectory_declared_rank1_owner
 str x0,[x21,#272]
 str x1,[x21,#280]
 add x0,x26,#448
 mov x2,#8
 bl .Ltrajectory_declared_rank1_owner
 str x0,[x21,#288]
 str x1,[x21,#296]
FINISH gpu_lavent,openifs_lavent_ptx,gpu_lavent_launches,0
 ALIAS md2asm_lacdyn_private_lavent,gpu_lavent
 ALIAS md2asm_lacdyn_wind,gpu_lavent
 ALIAS md2asm_trajectory_wind_r3,gpu_lavent
 ALIAS lavent_,gpu_lavent
.Ldraft_failure:
 bl abort
 brk #0
// Source allocation descriptors have lower1 and contiguous declared elements.
.Ltrajectory_declared_rank1_owner:
 ldr x9,[x0,#16]
 cmp x9,x2
 b.ne .Ldraft_failure
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Ldraft_failure
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Ldraft_failure
 ldr x10,[x0,#56]
 cmp x10,#0
 b.lt .Ldraft_failure
 CONST x11,262144
 cmp x10,x11
 b.gt .Ldraft_failure
 umulh x11,x10,x2
 cbnz x11,.Ldraft_failure
 mul x1,x10,x2
 tbnz x1,#63,.Ldraft_failure
 ldr x0,[x0]
 cbz x1,.Ltrajectory_owner_ready
 cbz x0,.Ldraft_failure
 tst x0,#7
 b.ne .Ldraft_failure
.Ltrajectory_owner_ready:
 ret
.global md2asm_trajectory_wind_count_get
.type md2asm_trajectory_wind_count_get,%function
md2asm_trajectory_wind_count_get:
 adrp x9,:got:gpu_lavent_source_counts
 ldr x9,[x9,:got_lo12:gpu_lavent_source_counts]
 ldr x0,[x9]
 ret
.global md2asm_trajectory_tanh_count_get
.type md2asm_trajectory_tanh_count_get,%function
md2asm_trajectory_tanh_count_get:
 adrp x9,:got:gpu_lavent_source_counts
 ldr x9,[x9,:got_lo12:gpu_lavent_source_counts]
 ldr x0,[x9,#8]
 ret
.bss
.balign 8
.global gpu_lavent_source_counts
.hidden gpu_lavent_source_counts
gpu_lavent_source_counts:.zero 16
.section .note.GNU-stack,"",%progbits

// Qualified parallel interface and bounds in skills/md2asm-gpu/references/openifs/dynamics/forecast_grid_parallel_columns.md.
// Three complete parent interfaces. Only integer storage metadata runs here.
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
 sub sp,sp,#16384
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
 add x9,sp,#16384
 add x10,sp,#320
 mov w11,#(\count-8)
.Lstack_copy\@:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Lstack_copy\@
 .endif
 add x19,sp,#256
 add x20,sp,#896
 add x21,sp,#1024
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
 mov x9,x21
 mov w10,#512
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
 str x0,[sp,#10024]
 mrs x9,fpcr
 str x9,[sp,#9984]
 mrs x9,fpsr
 str x9,[sp,#9992]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#10000]
 ldr w9,[x0]
 str w9,[sp,#10008]
 ldr x0,[sp,#10024]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#10032]
 ldr x9,[sp,#10000]
 ldr w10,[sp,#10008]
 str w10,[x9]
 ldr x9,[sp,#9984]
 msr fpcr,x9
 ldr x9,[sp,#9992]
 msr fpsr,x9
 ldr x0,[sp,#10032]
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
 SERVICE md2asm_openifs_gpu_prepare
 ldr x18,[sp,#224]
 cbnz w0,.Ldraft_failure
 // A view can overlap another view only within the same column.
 // All original range and numerical guards still run on the selected device path.
 mrs x7,nzcv
 ldr x0,[x19]
 ldrsw x0,[x0,#5144]
 lsl x0,x0,#3
 mov w6,#1
 mov x9,#16
.Lparallel_i\@:
 ldr x11,[x19,x9,lsl #3]
 ldr x12,[x21,x9,lsl #3]
 cbz x12,.Lparallel_next_i\@
 cbz x11,.Lparallel_serial\@
 adds x13,x11,x12
 b.cs .Lparallel_serial\@
 mov x10,#16
.Lparallel_j\@:
 cmp x10,x9
 b.hs .Lparallel_next_i\@
 ldr x14,[x19,x10,lsl #3]
 ldr x15,[x21,x10,lsl #3]
 cbz x15,.Lparallel_next_j\@
 cbz x14,.Lparallel_serial\@
 adds x16,x14,x15
 b.cs .Lparallel_serial\@
 cmp x11,x16
 b.hs .Lparallel_next_j\@
 cmp x14,x13
 b.hs .Lparallel_next_j\@
 cmp x11,x14
 sub x17,x11,x14
 sub x16,x14,x11
 csel x17,x17,x16,hs
 udiv x16,x17,x0
 msub x17,x16,x0,x17
 cbnz x17,.Lparallel_serial\@
.Lparallel_next_j\@:
 add x10,x10,#1
 b .Lparallel_j\@
.Lparallel_next_i\@:
 add x9,x9,#1
 cmp x9,#74
 b.lo .Lparallel_i\@
 b .Lparallel_selected\@
.Lparallel_serial\@:
 mov w6,#0
.Lparallel_selected\@:
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov w4,#1
 cbz w6,.Lparallel_launch\@
 adrp x0,.Lparallel_entry\@
 add x0,x0,:lo12:.Lparallel_entry\@
 mov w4,#32
.Lparallel_launch\@:
 msr nzcv,x7
 mov x1,x19
 mov x2,x20
 mov w3,#1
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
 add sp,sp,#16384
 ret
.size \name,.-\name
.section .rodata
.Lentry\@: .asciz "\entry"
.Lparallel_entry\@: .asciz "r27_parallel_cpg_gp_entry"
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
/* x0 descriptor,x1 rank;return physical base x0 and full span bytes x1.
 * Metadata and pointers are unchanged;no model value is read. */
.Ldraft_descriptor_span:
 ldr x2,[x0]
 cbz x2,.Ldescriptor_empty
 ldr x3,[x0,#16]
 cmp x3,#8
 b.eq .Ldescriptor_real
 cmp x3,#4
 b.ne .Ldraft_failure
 mov x4,#2
 b .Ldescriptor_element
.Ldescriptor_real:
 mov x4,#3
.Ldescriptor_element:
 cmp x1,#1
 b.lt .Ldraft_failure
 cmp x1,#3
 b.gt .Ldraft_failure
 mov x5,#0
 mov x6,#0
 mov x7,#0
 add x8,x0,#40
.Ldescriptor_dimension:
 ldr x9,[x8]
 ldr x10,[x8,#8]
 ldr x11,[x8,#16]
 cmp x11,x10
 b.lt .Ldescriptor_empty
 sub x11,x11,x10
 tbnz x11,#63,.Ldraft_failure
 cbz x11,.Ldescriptor_dimension_next
 cbz x9,.Ldraft_failure
 mov x12,#0x8000000000000000
 cmp x9,x12
 b.eq .Ldraft_failure
 cmp x9,#0
 cneg x12,x9,lt
 umulh x13,x11,x12
 cbnz x13,.Ldraft_failure
 mul x12,x11,x12
 mov x13,#0x7fffffffffffffff
 lsr x13,x13,x4
 cmp x12,x13
 b.hi .Ldraft_failure
 cmp x9,#0
 b.lt .Ldescriptor_negative
 adds x6,x6,x12
 b.cs .Ldraft_failure
 b .Ldescriptor_dimension_next
.Ldescriptor_negative:
 adds x5,x5,x12
 b.cs .Ldraft_failure
.Ldescriptor_dimension_next:
 add x7,x7,#1
 add x8,x8,#24
 cmp x7,x1
 b.lt .Ldescriptor_dimension
 adds x14,x5,x6
 b.cs .Ldraft_failure
 adds x14,x14,#1
 b.cs .Ldraft_failure
 mov x13,#0x7fffffffffffffff
 lsr x13,x13,x4
 cmp x14,x13
 b.hi .Ldraft_failure
 lsl x1,x14,x4
 lsl x5,x5,x4
 cmp x2,x5
 b.lo .Ldraft_failure
 tbnz x2,#63,.Ldraft_failure
 sub x0,x2,x5
 cbz x0,.Ldraft_failure
 adds x14,x0,x1
 b.cs .Ldraft_failure
 tbnz x14,#63,.Ldraft_failure
 ret
.Ldescriptor_empty:
 mov x0,#0
 mov x1,#0
 ret


/* Allocated rank-one storage includes its actual offset and bounds.
 * x0 is its descriptor, x1 its element size. Return full base/bytes x0/x1.
 * All address products and sums must fit signed64 before pointer use. */
.macro ROOT_SIGNED_PRODUCT dst,left,right
 smulh x15,\left,\right
 mul \dst,\left,\right
 asr x16,\dst,#63
 cmp x15,x16
 b.ne .Ldraft_failure
.endm
.Lroot_allocated_span:
 mov x7,x1
 ldr x2,[x0]
 cbz x2,.Ldescriptor_empty
 ldr x3,[x0,#16]
 cmp x3,x7
 b.ne .Ldraft_failure
 ldr x3,[x0,#32]
 cmp x3,x7
 b.ne .Ldraft_failure
 ldr x3,[x0,#8]
 ldr x4,[x0,#40]
 ldr x5,[x0,#48]
 ldr x6,[x0,#56]
 cmp x6,x5
 b.lt .Ldescriptor_empty
 ROOT_SIGNED_PRODUCT x8,x4,x5
 adds x8,x8,x3
 b.vs .Ldraft_failure
 ROOT_SIGNED_PRODUCT x9,x4,x6
 adds x9,x9,x3
 b.vs .Ldraft_failure
 cmp x8,x9
 csel x10,x8,x9,le
 csel x11,x8,x9,ge
 ROOT_SIGNED_PRODUCT x12,x10,x7
 adds x0,x2,x12
 b.vs .Ldraft_failure
 cbz x0,.Ldraft_failure
 tbnz x0,#63,.Ldraft_failure
 subs x11,x11,x10
 b.vs .Ldraft_failure
 adds x11,x11,#1
 b.vs .Ldraft_failure
 umulh x15,x11,x7
 cbnz x15,.Ldraft_failure
 mul x1,x11,x7
 tbnz x1,#63,.Ldraft_failure
 adds x14,x0,x1
 b.vs .Ldraft_failure
 tbnz x14,#63,.Ldraft_failure
 ret


BEGIN md2asm_gpu_host_forecast_grid,75
 SERIAL_CALLER
 RECORD 8192
 CONST x9,17096
 str x9,[x21,#0]
 CONST x9,4275088
 str x9,[x21,#8]
 CONST x9,529288
 str x9,[x21,#16]
 CONST x9,8
 str x9,[x21,#96]
 CONST x9,8
 str x9,[x21,#104]
 CONST x9,968
 str x9,[x21,#120]
 CONST x9,704
 str x9,[x21,#592]
 CONST x9,4
 str x9,[x21,#24]
 CONST x9,4
 str x9,[x21,#32]
 CONST x9,4
 str x9,[x21,#40]
 CONST x9,4
 str x9,[x21,#48]
 CONST x9,4
 str x9,[x21,#56]
 CONST x9,4
 str x9,[x21,#64]
 CONST x9,4
 str x9,[x21,#72]
 CONST x9,4
 str x9,[x21,#80]
 CONST x9,4
 str x9,[x21,#88]
 CONST x9,4
 str x9,[x21,#112]
 CONST x9,600
 str x9,[x21,#600]
 ldr x22,[x19]
 ldrsw x23,[x22,#5144]
 cmp x23,#1
 b.lt .Ldraft_failure
 cmp x23,#256
 b.gt .Ldraft_failure
 ldr w9,[x22,#5224]
 cmp w9,#19
 b.ne .Ldraft_failure
 ldrsw x24,[x22,#5156]
 cmp x24,#0
 b.lt .Ldraft_failure
 cmp x24,x23
 b.gt .Ldraft_failure
 lsl x25,x23,#3
 mov x9,#19
 mul x26,x25,x9
 mov x9,#20
 mul x27,x25,x9
 mov x9,#8
 mul x9,x26,x9
 str x9,[x21,#128]
 mov x9,#18
 mul x9,x26,x9
 str x9,[x21,#136]
 mov x9,#3
 mul x9,x26,x9
 str x9,[x21,#192]
 mov x9,#8
 mul x9,x26,x9
 str x9,[x21,#200]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#248]
 mov x9,#7
 mul x9,x26,x9
 str x9,[x21,#272]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#288]
 mov x9,#3
 mul x9,x26,x9
 str x9,[x21,#296]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#312]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#320]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#336]
 mov x9,#7
 mul x9,x26,x9
 str x9,[x21,#360]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#376]
 mov x9,#3
 mul x9,x26,x9
 str x9,[x21,#384]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#392]
 mov x9,#3
 mul x9,x26,x9
 str x9,[x21,#416]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#456]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#464]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#472]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#480]
 mov x9,#5
 mul x9,x26,x9
 str x9,[x21,#488]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#552]
 mov x9,#1
 mul x9,x26,x9
 str x9,[x21,#560]
 mov x9,#3
 mul x9,x25,x9
 str x9,[x21,#144]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#208]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#216]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#232]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#240]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#400]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#424]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#440]
 mov x9,#1
 mul x9,x25,x9
 str x9,[x21,#448]
 mov x9,#1
 mul x9,x27,x9
 str x9,[x21,#224]
 mov x9,#3
 mul x9,x27,x9
 str x9,[x21,#280]
 mov x9,#5
 mul x9,x27,x9
 str x9,[x21,#304]
 mov x9,#1
 mul x9,x27,x9
 str x9,[x21,#328]
 mov x9,#1
 mul x9,x27,x9
 str x9,[x21,#368]
 ldr x9,[x19,#8]
 ldrsw x10,[x9,#256]
 cmp x10,#0
 b.lt .Ldraft_failure
 cmp x10,#2163
 b.gt .Ldraft_failure
 mul x10,x26,x10
 str x10,[x21,#432]
 CONST x10,1573320
 add x9,x9,x10
 ldrsw x10,[x9]
 cmp x10,#0
 b.lt .Ldraft_failure
 cmp x10,#4096
 b.gt .Ldraft_failure
 mul x10,x25,x10
 str x10,[x21,#408]
 adrp x9,:got:__yom_ygfl_MOD_ygfl
 ldr x9,[x9,:got_lo12:__yom_ygfl_MOD_ygfl]
 str x9,[x21,#608]
 adrp x9,:got:__yomct0_MOD_lsforc
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lsforc]
 str x9,[x21,#616]
 adrp x9,:got:__yomnud_MOD_lnudg
 ldr x9,[x9,:got_lo12:__yomnud_MOD_lnudg]
 str x9,[x21,#624]
 adrp x9,:got:md2asm_gpu_forecast_grid_counts
 ldr x9,[x9,:got_lo12:md2asm_gpu_forecast_grid_counts]
 str x9,[x21,#728]
 CONST x9,40
 str x9,[x21,#736]
 adrp x9,:got:md2asm_exponential_native_calls_storage
 ldr x9,[x9,:got_lo12:md2asm_exponential_native_calls_storage]
 str x9,[x21,#744]
 cmp x9,#0
 mov x10,#8
 csel x9,xzr,x10,eq
 str x9,[x21,#752]
 mov x9,#3400
 mul x9,x23,x9
 mov x10,#304
 madd x9,x24,x10,x9
 CONST x10,12296
 add x28,x9,x10
 ALLOC x28
 CONST x0,8472
 add x0,x22,x0
 mov x1,#1472
 bl .Lroot_allocated_span
 str x0,[x21,#632]
 str x1,[x21,#640]
 CONST x0,14024
 add x0,x22,x0
 mov x1,#384
 bl .Lroot_allocated_span
 str x0,[x21,#648]
 str x1,[x21,#656]
 ldr x9,[x19,#112]
 ldrsw x9,[x9]
 ldr x10,[x22,#8520]
 ldr x11,[x22,#8528]
 cmp x9,x10
 b.lt .Ldraft_failure
 cmp x9,x11
 b.gt .Ldraft_failure
 sub x9,x9,x10
 mov x10,#1472
 mul x9,x9,x10
 ldr x10,[x22,#8472]
 add x28,x10,x9
 ldr x9,[x21,#632]
 ldr x10,[x21,#640]
 cmp x28,x9
 b.lo .Ldraft_failure
 sub x11,x28,x9
 cmp x11,x10
 b.hi .Ldraft_failure
 sub x10,x10,x11
 cmp x10,#1472
 b.lo .Ldraft_failure
 add x0,x28,#704
 mov x1,#8
 bl .Lroot_allocated_span
 str x0,[x21,#664]
 str x1,[x21,#672]
 CONST x9,14024
 add x9,x22,x9
 ldr x10,[x19,#112]
 ldrsw x10,[x10]
 ldr x11,[x9,#48]
 ldr x12,[x9,#56]
 cmp x10,x11
 b.lt .Ldraft_failure
 cmp x10,x12
 b.gt .Ldraft_failure
 sub x10,x10,x11
 mov x11,#384
 mul x10,x10,x11
 ldr x9,[x9]
 add x28,x9,x10
 ldr x9,[x21,#648]
 ldr x10,[x21,#656]
 cmp x28,x9
 b.lo .Ldraft_failure
 sub x11,x28,x9
 cmp x11,x10
 b.hi .Ldraft_failure
 sub x10,x10,x11
 cmp x10,#384
 b.lo .Ldraft_failure
 add x0,x28,#0
 mov x1,#8
 bl .Lroot_allocated_span
 str x0,[x21,#680]
 str x1,[x21,#688]
 add x0,x28,#64
 mov x1,#8
 bl .Lroot_allocated_span
 str x0,[x21,#696]
 str x1,[x21,#704]
 add x0,x28,#128
 mov x1,#8
 bl .Lroot_allocated_span
 str x0,[x21,#712]
 str x1,[x21,#720]
 CONST x9,88
 str x9,[x21,#1120]
 CONST x9,152
 str x9,[x21,#1432]
 CONST x9,304
 str x9,[x21,#1840]
 CONST x9,216
 str x9,[x21,#1848]
 // A temporary original39-vector is for integer record ownership only.
 add x28,sp,#3,lsl #12
 str wzr,[x28,#512]
 ldr x9,[x19,#0]
 str x9,[x28,#0]
 ldr x9,[x19,#8]
 str x9,[x28,#8]
 ldr x9,[x19,#16]
 add x9,x9,#1856
 str x9,[x28,#16]
 ldr x9,[x19,#32]
 str x9,[x28,#24]
 ldr x9,[x19,#40]
 str x9,[x28,#32]
 ldr x9,[x19,#72]
 str x9,[x28,#40]
 add x9,x28,#512
 str x9,[x28,#48]
 ldr x9,[x19,#88]
 str x9,[x28,#56]
 ldr x9,[x19,#8]
 CONST x10,4218352
 add x9,x9,x10
 str x9,[x28,#64]
 ldr x9,[x19,#112]
 str x9,[x28,#72]
 ldr x9,[x21,#680]
 str x9,[x28,#80]
 ldr x9,[x19,#208]
 str x9,[x28,#88]
 ldr x9,[x19,#216]
 str x9,[x28,#96]
 ldr x9,[x19,#232]
 str x9,[x28,#104]
 ldr x9,[x19,#240]
 str x9,[x28,#112]
 ldr x9,[x19,#120]
 str x9,[x28,#120]
 ldr x9,[x19,#128]
 str x9,[x28,#128]
 ldr x9,[x19,#136]
 str x9,[x28,#136]
 ldr x9,[x19,#224]
 str x9,[x28,#144]
 ldr x9,[x19,#328]
 str x9,[x28,#152]
 ldr x9,[x19,#248]
 str x9,[x28,#160]
 ldr x9,[x19,#272]
 str x9,[x28,#168]
 ldr x9,[x19,#280]
 str x9,[x28,#176]
 ldr x9,[x19,#288]
 str x9,[x28,#184]
 ldr x9,[x19,#296]
 str x9,[x28,#192]
 ldr x9,[x19,#304]
 str x9,[x28,#200]
 ldr x9,[x19,#312]
 str x9,[x28,#208]
 ldr x9,[x20,#32]
 add x9,x9,#8192
 add x9,x9,x25,lsl #1
 str x9,[x28,#216]
 ldr x9,[x19,#320]
 str x9,[x28,#224]
 ldr x9,[x19,#336]
 str x9,[x28,#232]
 ldr x9,[x19,#360]
 str x9,[x28,#240]
 ldr x9,[x19,#368]
 str x9,[x28,#248]
 ldr x9,[x19,#376]
 str x9,[x28,#256]
 ldr x9,[x19,#384]
 str x9,[x28,#264]
 ldr x9,[x19,#392]
 str x9,[x28,#272]
 ldr x9,[x20,#32]
 add x9,x9,#8192
 add x9,x9,x25,lsl #1
 add x9,x9,x27
 str x9,[x28,#280]
 ldr x9,[x19,#488]
 str x9,[x28,#288]
 ldr x9,[x19,#552]
 str x9,[x28,#296]
 ldr x9,[x19,#560]
 str x9,[x28,#304]
 mov x0,x28
 add x1,x21,#4096
 bl md2asm_gpu_fill_hydrostatic_record
 FINISH md2asm_gpu_host_forecast_grid,openifs_cpg_gp_ptx,md2asm_gpu_host_forecast_grid_calls,1
 ALIAS cpg_gp_,md2asm_gpu_host_forecast_grid
.weak md2asm_exponential_native_calls_storage
.global md2asm_gpu_host_forecast_grid_count_get
.type md2asm_gpu_host_forecast_grid_count_get,%function
md2asm_gpu_host_forecast_grid_count_get:
 adrp x9,:got:md2asm_gpu_host_forecast_grid_calls
 ldr x9,[x9,:got_lo12:md2asm_gpu_host_forecast_grid_calls]
 ldr x0,[x9]
 ret
.size md2asm_gpu_host_forecast_grid_count_get,.-md2asm_gpu_host_forecast_grid_count_get
.global md2asm_cpg_gp_calls_get
.type md2asm_cpg_gp_calls_get,%function
md2asm_cpg_gp_calls_get:
 adrp x9,:got:md2asm_gpu_forecast_grid_counts
 ldr x9,[x9,:got_lo12:md2asm_gpu_forecast_grid_counts]
 ldr x0,[x9]
 ret
.size md2asm_cpg_gp_calls_get,.-md2asm_cpg_gp_calls_get
.global md2asm_cpg_gp_child_calls_get
.type md2asm_cpg_gp_child_calls_get,%function
md2asm_cpg_gp_child_calls_get:
 cmp w0,#3
 b.hi .Lno_child
 uxtw x0,w0
 adrp x9,:got:md2asm_gpu_forecast_grid_counts
 ldr x9,[x9,:got_lo12:md2asm_gpu_forecast_grid_counts]
 add x9,x9,#8
 ldr x0,[x9,x0,lsl #3]
 ret
.Lno_child:
 mov x0,#0
 ret
.size md2asm_cpg_gp_child_calls_get,.-md2asm_cpg_gp_child_calls_get
.bss
.balign 8
.global md2asm_gpu_forecast_grid_counts
.hidden md2asm_gpu_forecast_grid_counts
md2asm_gpu_forecast_grid_counts: .zero 40
.text
.Ldraft_failure:
 bl abort
 brk #0
.section .note.GNU-stack,"",%progbits

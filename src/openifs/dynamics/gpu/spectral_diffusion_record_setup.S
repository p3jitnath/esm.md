// Contract: skills/md2asm-gpu/references/openifs/dynamics/lagrangian_grid_update.md.
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

// Storage-only original child record setup for LACDYN.
.global md2asm_lacdyn_fill_lasure
.type md2asm_lacdyn_fill_lasure,%function
md2asm_lacdyn_fill_lasure:
 sub sp,sp,#8192
 stp x29,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 mov x19,x0
 mov x21,x1
 add x20,sp,#1024
 str xzr,[sp,#6880]
 RECORD 256
 CONST x9,17096
 str x9,[x21,#0]
 CONST x9,448
 str x9,[x21,#8]
 CONST x9,4720
 str x9,[x21,#16]
 CONST x9,1088
 str x9,[x21,#24]
 CONST x9,1096
 str x9,[x21,#32]
 CONST x9,4
 str x9,[x21,#40]
 CONST x9,4
 str x9,[x21,#48]
 CONST x9,8
 str x9,[x21,#56]
 CONST x9,8
 str x9,[x21,#64]
 CONST x9,4
 str x9,[x21,#72]
 CONST x9,8
 str x9,[x21,#80]
 CONST x9,8
 str x9,[x21,#88]
 CONST x9,4
 str x9,[x21,#96]
 CONST x9,8
 str x9,[x21,#120]
 CONST x9,8
 str x9,[x21,#128]
 CONST x9,136
 str x9,[x21,#136]
 ldr x22,[x19]
 ldrsw x23,[x22,#5144]
 cmp x23,#0
 b.lt .Ldraft_failure
 cmp x23,#4096
 b.gt .Ldraft_failure
 lsl x24,x23,#3
 ldr x9,[x19,#104]
 cmp x9,#0
 csel x9,xzr,x24,eq
 str x9,[x21,#104]
 ldr x9,[x19,#112]
 cmp x9,#0
 csel x9,xzr,x24,eq
 str x9,[x21,#112]
 ldr x9,[x19,#40]
 ldr w9,[x9]
 ldr x10,[x19,#48]
 ldr w10,[x10]
 cmp w9,w10
 b.gt .Llasure_maps_ready
 ldr x11,[x19,#16]
 ldr w11,[x11,#2476]
 cbnz w11,.Llasure_maps_ready
 CONST x0,8472
 add x0,x22,x0
 mov x1,#1472
 bl .Lroot_allocated_span
 stp x0,x1,[x21,#144]
 ldr x9,[x19,#72]
 ldrsw x9,[x9]
 ldr x10,[x22,#8520]
 cmp x9,x10
 b.lt .Ldraft_failure
 ldr x10,[x22,#8528]
 cmp x9,x10
 b.gt .Ldraft_failure
 ldr x10,[x22,#8472]
 ldr x11,[x22,#8480]
 ldr x12,[x22,#8512]
 ROOT_SIGNED_PRODUCT x13,x9,x12
 adds x13,x13,x11
 b.vs .Ldraft_failure
 mov x12,#1472
 ROOT_SIGNED_PRODUCT x13,x13,x12
 adds x23,x10,x13
 b.vs .Ldraft_failure
 cbz x23,.Ldraft_failure
 tbnz x23,#63,.Ldraft_failure
 ldp x9,x10,[x21,#144]
 cmp x23,x9
 b.lo .Ldraft_failure
 sub x11,x23,x9
 cmp x11,x10
 b.hi .Ldraft_failure
 sub x10,x10,x11
 cmp x10,#1472
 b.lo .Ldraft_failure
 add x0,x23,#704
 mov x1,#8
 bl .Lroot_allocated_span
 stp x0,x1,[x21,#160]
 ldr x9,[x19,#24]
 ldr w9,[x9,#1056]
 cbz w9,.Llasure_maps_ready
 add x0,x23,#768
 mov x1,#8
 bl .Lroot_allocated_span
 stp x0,x1,[x21,#176]
.Llasure_maps_ready:
 mov x0,#0
 ldr x1,[sp,#6880]
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
.size md2asm_lacdyn_fill_lasure,.-md2asm_lacdyn_fill_lasure
.section .note.GNU-stack,"",%progbits

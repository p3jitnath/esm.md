// Contract: skills/md2asm-gpu/references/openifs/dynamics/lagrangian_grid_update.md.
// Original ABI storage/launch draft from original_host_contract.md revision1.
.text
.p2align 2
.macro CONST reg,value
 movz \reg,#((\value)&65535)
 .if ((\value)>>16)
 movk \reg,#(((\value)>>16)&65535),lsl #16
 .endif
 .if ((\value)>>32)
 movk \reg,#(((\value)>>32)&65535),lsl #32
 .endif
 .if ((\value)>>48)
 movk \reg,#(((\value)>>48)&65535),lsl #48
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
 add x20,sp,#1024
 add x21,sp,#1280
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
 str x0,[sp,#6696]
 mrs x9,fpcr
 str x9,[sp,#6656]
 mrs x9,fpsr
 str x9,[sp,#6664]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#6672]
 ldr w9,[x0]
 str w9,[sp,#6680]
 ldr x0,[sp,#6696]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#6704]
 ldr x9,[sp,#6672]
 ldr w10,[sp,#6680]
 str w10,[x9]
 ldr x9,[sp,#6656]
 msr fpcr,x9
 ldr x9,[sp,#6664]
 msr fpsr,x9
 ldr x0,[sp,#6704]
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

.macro BULK_SIGNED_PRODUCT dst,left,right
 smulh x15,\left,\right
 mul \dst,\left,\right
 asr x16,\dst,#63
 cmp x15,x16
 b.ne .Ldraft_failure
.endm
/* Complete allocated descriptor owner, including its signed offset. */
.Lbulk_allocated_view:
 ldr x2,[x0]
 cbz x2,.Ldescriptor_empty
 ldr x3,[x0,#16]
 cbz x3,.Ldraft_failure
 ldr x4,[x0,#32]
 cmp x4,x3
 b.ne .Ldraft_failure
 cmp x1,#1
 b.lt .Ldraft_failure
 cmp x1,#3
 b.gt .Ldraft_failure
 ldr x5,[x0,#8]
 mov x6,x5
 mov x7,#0
 add x8,x0,#40
.Lbulk_allocated_dimension:
 ldr x4,[x8]
 ldr x9,[x8,#8]
 ldr x10,[x8,#16]
 cmp x10,x9
 b.lt .Ldescriptor_empty
 BULK_SIGNED_PRODUCT x11,x4,x9
 BULK_SIGNED_PRODUCT x12,x4,x10
 cmp x11,x12
 csel x9,x11,x12,le
 csel x10,x11,x12,ge
 adds x5,x5,x9
 b.vs .Ldraft_failure
 adds x6,x6,x10
 b.vs .Ldraft_failure
 add x8,x8,#24
 add x7,x7,#1
 cmp x7,x1
 b.lt .Lbulk_allocated_dimension
 BULK_SIGNED_PRODUCT x10,x5,x3
 adds x0,x2,x10
 b.vs .Ldraft_failure
 cbz x0,.Ldraft_failure
 tbnz x0,#63,.Ldraft_failure
 subs x6,x6,x5
 b.vs .Ldraft_failure
 adds x6,x6,#1
 b.vs .Ldraft_failure
 umulh x15,x6,x3
 cbnz x15,.Ldraft_failure
 mul x1,x6,x3
 tbnz x1,#63,.Ldraft_failure
 adds x14,x0,x1
 b.vs .Ldraft_failure
 tbnz x14,#63,.Ldraft_failure
 ret

// Storage-only original child record setup for LACDYN.
.global md2asm_lacdyn_fill_lassie
.type md2asm_lacdyn_fill_lassie,%function
md2asm_lacdyn_fill_lassie:
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
 RECORD 1024
 CONST x9,152
 str x9,[x21,#152]
 CONST x11,17096
 ldr x10,[x19,#0]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#0]
 CONST x11,1560
 ldr x10,[x19,#8]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#8]
 CONST x11,4720
 ldr x10,[x19,#24]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#24]
 CONST x11,456
 ldr x10,[x19,#32]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#32]
 CONST x11,4
 ldr x10,[x19,#40]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#40]
 CONST x11,4
 ldr x10,[x19,#48]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#48]
 ldr x9,[x19,#0]
 cbz x9,.Ldraft_failure
 ldrsw x22,[x9,#5144]; ldrsw x23,[x9,#5224]
 cmp x22,#1; b.lt .Ldraft_failure; cmp x22,#4096; b.gt .Ldraft_failure; cmp x23,#0; b.lt .Ldraft_failure; cmp x23,#512; b.gt .Ldraft_failure
 BYTES x24,x22,x23; lsl x25,x22,#3
 ldr x10,[x19,#56]; cmp x10,#0; csel x9,xzr,x25,eq; str x9,[x21,#56]
 ldr x10,[x19,#88]; cmp x10,#0; csel x9,xzr,x25,eq; str x9,[x21,#88]
 ldr x10,[x19,#96]; cmp x10,#0; csel x9,xzr,x25,eq; str x9,[x21,#96]
 ldr x10,[x19,#104]; cmp x10,#0; csel x9,xzr,x24,eq; str x9,[x21,#104]
 ldr x10,[x19,#112]; cmp x10,#0; csel x9,xzr,x24,eq; str x9,[x21,#112]
 ldr x10,[x19,#120]; cmp x10,#0; csel x9,xzr,x24,eq; str x9,[x21,#120]
 ldr x10,[x19,#128]; cmp x10,#0; csel x9,xzr,x24,eq; str x9,[x21,#128]
 ldr x10,[x19,#136]; cmp x10,#0; csel x9,xzr,x24,eq; str x9,[x21,#136]
 ldr x10,[x19,#144]; cmp x10,#0; csel x9,xzr,x24,eq; str x9,[x21,#144]
 ldr x16,[x19,#40]
 cbz x16,.Ldraft_failure
 ldrsw x26,[x16]
 CONST x17,1
 cmp x26,x17; b.lt .Ldraft_failure
 CONST x17,4096
 cmp x26,x17; b.gt .Ldraft_failure
 ldr x16,[x19,#48]
 cbz x16,.Ldraft_failure
 ldrsw x27,[x16]
 CONST x17,0
 cmp x27,x17; b.lt .Ldraft_failure
 CONST x17,4096
 cmp x27,x17; b.gt .Ldraft_failure
 cmp x27,x26; b.lt .Llassie_host_done; cbz x23,.Llassie_host_done
 ldr x27,[x19,#8]
 CONST x16,992
 add x16,x27,x16; ldrsw x12, [x16]
 cmp x12,#0; b.lt .Ldraft_failure
 lsr x13,x24,#3; BYTES x11,x13,x12
 ldr x10,[x19,#64]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#64]
 CONST x16,996
 add x16,x27,x16; ldrsw x12, [x16]
 cmp x12,#0; b.lt .Ldraft_failure
 lsr x13,x25,#3; BYTES x11,x13,x12
 ldr x10,[x19,#72]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#72]
 adrp x9,:got:__yomcst_MOD_rd; ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 str x9,[x21,#160]
 adrp x9,:got:__yomcst_MOD_rkappa; ldr x9,[x9,:got_lo12:__yomcst_MOD_rkappa]
 str x9,[x21,#168]
 adrp x9,:got:__yomcst_MOD_rcpd; ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
 str x9,[x21,#200]
 ldr x16,[x19,#40]
 cbz x16,.Ldraft_failure
 ldrsw x26,[x16]
 CONST x17,1
 cmp x26,x17; b.lt .Ldraft_failure
 CONST x17,4096
 cmp x26,x17; b.gt .Ldraft_failure
 ldr x16,[x19,#48]
 cbz x16,.Ldraft_failure
 ldrsw x27,[x16]
 CONST x17,0
 cmp x27,x17; b.lt .Ldraft_failure
 CONST x17,4096
 cmp x27,x17; b.gt .Ldraft_failure
 cmp x27,x26; b.lt .Llassie_host_done; cbz x23,.Llassie_host_done; sub x27,x27,x26; add x27,x27,#1; mov x28,#1024
 ldr x9,[x19,#0]
 ldr x9,[x9,#3264]; cbz x9,.Ldraft_failure; ldr w9,[x9,#52]; cbz w9,.Llassie_workspace_done; lsl x9,x23,#1; add x9,x9,#3; BYTES x11,x27,x9; add x28,x28,x11
.Llassie_workspace_done:
 ldr x9,[x19,#32]
 ldr w9,[x9,#16]; cbz w9,.Llassie_gas_done
 adrp x9,:got:__yom_ygfl_MOD_ygfl; ldr x9,[x9,:got_lo12:__yom_ygfl_MOD_ygfl]
 ldr x9,[x9]
 str x9,[x21,#176]
 CONST x9,1359136
 str x9,[x21,#184]
 ldr x9,[x21,#176]; cbz x9,.Ldraft_failure; ldrsw x12,[x9,#48]; cmp x12,#0; b.lt .Ldraft_failure
 str x12,[x21,#192]
 lsr x13,x24,#3; BYTES x11,x13,x12
 ldr x10,[x19,#80]; cmp x10,#0; csel x9,xzr,x11,eq; str x9,[x21,#80]
 add x28,x28,x24
.Llassie_gas_done: str x28,[sp,#6880]
 ldr x24,[x19,#0]
 ldr x25,[x19,#24]
 ldr x26,[x24,#3264]; cbz x26,.Ldraft_failure
 CONST x9,216
 str x9,[x21,#352]
 adrp x9,:got:__yomcst_MOD_rd; ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 str x9,[x21,#416]
 ldr w9,[x26,#52]; cbnz w9,.Llinear_fe_256_1
 CONST x0,2600
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#360]
 CONST x0,2664
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#368]
 CONST x0,2728
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#376]
 CONST x0,2792
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#384]
 b .Llinear_done_256_1
.Llinear_fe_256_1:
 CONST x9,320
 str x9,[x21,#336]
 CONST x9,2176
 str x9,[x21,#344]
 CONST x0,2664
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#368]
 CONST x0,2728
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#376]
 CONST x0,2920
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#392]
 ldr x28,[x24,#3248]
 CONST x0,256
 add x0,x28,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#400]
 ldr w9,[x26,#36]; cmp w9,#3; b.hi .Ldraft_failure; mov x10,#240; mov x11,#64; cmp w9,#0; csel x10,x11,x10,eq; mov x11,#1296; cmp w9,#2; csel x10,x11,x10,eq
 ldr x9,[x24,#3256]; add x0,x9,x10; mov w1,#2; bl .Ldraft_descriptor_span; str x1,[x21,#408]
.Llinear_done_256_1:
 ldr x26,[x24,#3264]; cbz x26,.Ldraft_failure
 CONST x9,216
 str x9,[x21,#608]
 adrp x9,:got:__yomcst_MOD_rkappa; ldr x9,[x9,:got_lo12:__yomcst_MOD_rkappa]
 str x9,[x21,#672]
 ldr w9,[x26,#52]; cbnz w9,.Llinear_fe_512_2
 CONST x0,2600
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#616]
 CONST x0,2664
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#624]
 CONST x0,2728
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#632]
 CONST x0,2792
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#640]
 b .Llinear_done_512_2
.Llinear_fe_512_2:
 CONST x9,320
 str x9,[x21,#592]
 CONST x9,2176
 str x9,[x21,#600]
 CONST x0,2664
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#624]
 CONST x0,2728
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#632]
 CONST x0,2920
 add x0,x25,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#648]
 ldr x28,[x24,#3248]
 CONST x0,256
 add x0,x28,x0; mov w1,#1; bl .Ldraft_descriptor_span
 str x1,[x21,#656]
 ldr w9,[x26,#36]; cmp w9,#3; b.hi .Ldraft_failure; mov x10,#240; mov x11,#64; cmp w9,#0; csel x10,x11,x10,eq; mov x11,#1296; cmp w9,#2; csel x10,x11,x10,eq
 ldr x9,[x24,#3256]; add x0,x9,x10; mov w1,#2; bl .Ldraft_descriptor_span; str x1,[x21,#664]
.Llinear_done_512_2:
.Llassie_host_done:
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
.size md2asm_lacdyn_fill_lassie,.-md2asm_lacdyn_fill_lassie
.section .note.GNU-stack,"",%progbits

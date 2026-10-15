/* Complete source-owned output request allocation children.
 * Contract: skills/md2asm/references/openifs/output/output_request_preparation.md.
 * Private descriptor builder receives the declared rank, type and live extents.
 */
.arch armv8.2-a
.text
.macro prep_enter
 sub sp,sp,#224
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#104]
 stp x2,x3,[sp,#120]
 stp x4,x5,[sp,#136]
 str x6,[sp,#152]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#160]
 bl __errno_location
 str x0,[sp,#176]
 ldr w9,[x0]
 str w9,[sp,#184]
 ldp x0,x1,[sp,#104]
 ldp x2,x3,[sp,#120]
 ldp x4,x5,[sp,#136]
 ldr x6,[sp,#152]
.endm
.macro prep_return
 ldr x9,[sp,#176]
 ldr w10,[sp,#184]
 str w10,[x9]
 ldp x9,x10,[sp,#160]
 msr fpcr,x9
 msr fpsr,x10
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#224
 ret
.endm
/* x0=descriptor,x1=element bytes,x2=rank,x3=type,x4..6=extents.
 * Bounds start at one; strides retain zero extents exactly.
 */
.global md2asm_allocate_output_request_descriptor
.hidden md2asm_allocate_output_request_descriptor
.type md2asm_allocate_output_request_descriptor,%function
md2asm_allocate_output_request_descriptor:
 sub sp,sp,#80
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mul x0,x20,x23
 cmp x21,#1
 b.eq .Lprep_allocate_size
 mul x0,x0,x24
 cmp x21,#2
 b.eq .Lprep_allocate_size
 mul x0,x0,x25
.Lprep_allocate_size:
 mov x9,#1
 cmp x0,#0
 csel x0,x0,x9,ne
 bl malloc
 cbz x0,.Lprep_failure
 str x0,[x19]
 str x20,[x19,#16]
 str xzr,[x19,#24]
 strb w21,[x19,#28]
 strb w22,[x19,#29]
 str x20,[x19,#32]
 mov x9,#1
 stp x9,x9,[x19,#40]
 str x23,[x19,#56]
 mov x10,#-1
 cmp x21,#1
 b.eq .Lprep_descriptor_ready
 stp x23,x9,[x19,#64]
 str x24,[x19,#80]
 sub x10,x10,x23
 cmp x21,#2
 b.eq .Lprep_descriptor_ready
 mul x11,x23,x24
 stp x11,x9,[x19,#88]
 str x25,[x19,#104]
 sub x10,x10,x11
.Lprep_descriptor_ready:
 str x10,[x19,#8]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.size md2asm_allocate_output_request_descriptor,.-md2asm_allocate_output_request_descriptor
/* x0=TRQ3FP496,w1=field count,w2=level count; one selected domain. */
.p2align 4
.global md2asm_allocate_output_dynamic_3d_request
.type md2asm_allocate_output_dynamic_3d_request,%function
md2asm_allocate_output_dynamic_3d_request:
 prep_enter
 mov x19,x0
 uxtw x20,w1
 uxtw x21,w2
 cmp x20,#64
 b.hi .Lprep_failure
 cmp x21,#64
 b.hi .Lprep_failure
 mov x9,#0
.Lprep_clear_3d:
 str xzr,[x19,x9]
 add x9,x9,#8
 cmp x9,#496
 b.lo .Lprep_clear_3d
 stp w20,w21,[x19]
 mov w9,#1
 str w9,[x19,#12]
 add x0,x19,#16
 mov x1,#8
 mov x2,#1
 mov x3,#3
 mov x4,x21
 bl md2asm_allocate_output_request_descriptor
 add x0,x19,#80
 mov x1,#4
 mov x2,#1
 mov x3,#1
 mov x4,x20
 bl md2asm_allocate_output_request_descriptor
 add x0,x19,#144
 mov x1,#4
 mov x2,#1
 mov x3,#1
 mov x4,x20
 bl md2asm_allocate_output_request_descriptor
 ldr x9,[x19,#144]
 mov x10,#0
.Lprep_set_levels:
 cmp x10,x20
 b.hs .Lprep_3d_arrays
 str w21,[x9,x10,lsl#2]
 add x10,x10,#1
 b .Lprep_set_levels
.Lprep_3d_arrays:
 add x0,x19,#208
 mov x1,#4
 mov x2,#2
 mov x3,#1
 mov x4,x21
 mov x5,x20
 bl md2asm_allocate_output_request_descriptor
 add x0,x19,#296
 mov x1,#4
 mov x2,#2
 mov x3,#1
 mov x4,x21
 mov x5,x20
 bl md2asm_allocate_output_request_descriptor
 add x0,x19,#384
 mov x1,#4
 mov x2,#3
 mov x3,#1
 mov x4,#1
 mov x5,x21
 mov x6,x20
 bl md2asm_allocate_output_request_descriptor
 ldr x9,[x19,#208]
 ldr x10,[x19,#296]
 ldr x11,[x19,#384]
 mov x12,#0
 mov x13,#0
 mov w14,#1
.Lprep_3d_field_loop:
 cmp x12,x20
 b.hs .Lprep_3d_ready
 mov x15,#1
.Lprep_3d_level_loop:
 cmp x15,x21
 b.hi .Lprep_3d_next_field
 str w15,[x9,x13,lsl#2]
 str w14,[x10,x13,lsl#2]
 str w14,[x11,x13,lsl#2]
 add x15,x15,#1
 add x13,x13,#1
 b .Lprep_3d_level_loop
.Lprep_3d_next_field:
 add x12,x12,#1
 b .Lprep_3d_field_loop
.Lprep_3d_ready:
 prep_return
.size md2asm_allocate_output_dynamic_3d_request,.-md2asm_allocate_output_dynamic_3d_request
/* x0=TRQ2FP224,w1=field count; one selected domain. */
.p2align 4
.global md2asm_allocate_output_dynamic_2d_request
.type md2asm_allocate_output_dynamic_2d_request,%function
md2asm_allocate_output_dynamic_2d_request:
 prep_enter
 mov x19,x0
 uxtw x20,w1
 cmp x20,#64
 b.hi .Lprep_failure
 mov x9,#0
.Lprep_clear_2d:
 str xzr,[x19,x9]
 add x9,x9,#8
 cmp x9,#224
 b.lo .Lprep_clear_2d
 str w20,[x19]
 add x0,x19,#8
 mov x1,#4
 mov x2,#1
 mov x3,#1
 mov x4,x20
 bl md2asm_allocate_output_request_descriptor
 add x0,x19,#72
 mov x1,#4
 mov x2,#1
 mov x3,#1
 mov x4,x20
 bl md2asm_allocate_output_request_descriptor
 add x0,x19,#136
 mov x1,#4
 mov x2,#2
 mov x3,#1
 mov x4,#1
 mov x5,x20
 bl md2asm_allocate_output_request_descriptor
 ldr x9,[x19,#72]
 ldr x10,[x19,#136]
 mov x11,#0
 mov w12,#1
.Lprep_2d_domains:
 cmp x11,x20
 b.hs .Lprep_2d_ready
 str w12,[x9,x11,lsl#2]
 str w12,[x10,x11,lsl#2]
 add x11,x11,#1
 b .Lprep_2d_domains
.Lprep_2d_ready:
 prep_return
.size md2asm_allocate_output_dynamic_2d_request,.-md2asm_allocate_output_dynamic_2d_request
.Lprep_failure:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/setup/runtime_distributed_gridpoint_field_storage.md.
 * Live Geometry/YGFL control binding and original SUSC2C four-owner storage.
 * bind(x0 out28,x1 Geometry20400,x2 YGFL1359136):0 or prewrite2.
 * init(x0 freshTGFL1096,x1 Geometry20400,x2 YGFL1359136,x3 bytecap):0/1/2.
 * All complete mapped spans have declared alignment and are separate.
 * No file decoder, original model call or weather arithmetic.
 * The exact accepted17/137/97055 specialization remains behind runtime dispatch.
 */
.arch armv8.2-a
.text
.macro RGS_CONST dst,value
 movz \dst,#((\value)&65535)
 movk \dst,#(((\value)>>16)&65535),lsl#16
.endm
.p2align 4
.global md2asm_bind_runtime_distributed_gridpoint_shape
.type md2asm_bind_runtime_distributed_gridpoint_shape,%function
md2asm_bind_runtime_distributed_gridpoint_shape:
 cbz x0,.Lrgs_bad
 cbz x1,.Lrgs_bad
 cbz x2,.Lrgs_bad
 tst x0,#3
 b.ne .Lrgs_bad
 orr x9,x1,x2
 tst x9,#7
 b.ne .Lrgs_bad
 adds x3,x0,#28
 b.cs .Lrgs_bad
 mov x9,#20400
 adds x4,x1,x9
 b.cs .Lrgs_bad
 RGS_CONST x9,1359136
 adds x5,x2,x9
 b.cs .Lrgs_bad
 cmp x0,x4
 b.hs .Lrgs_bind_pair02
 cmp x1,x3
 b.lo .Lrgs_bad
.Lrgs_bind_pair02:
 cmp x0,x5
 b.hs .Lrgs_bind_pair12
 cmp x2,x3
 b.lo .Lrgs_bad
.Lrgs_bind_pair12:
 cmp x1,x5
 b.hs .Lrgs_bind_source
 cmp x2,x4
 b.lo .Lrgs_bad
.Lrgs_bind_source:
 ldr w6,[x1,#5144]
 sub w9,w6,#1
 cmp w9,#1023
 b.hi .Lrgs_bad
 ldr w7,[x1,#5224]
 sub w9,w7,#1
 cmp w9,#255
 b.hi .Lrgs_bad
 ldr w8,[x1,#5160]
 ldr w9,[x1,#7376]
 cmp w9,#0
 b.le .Lrgs_bad
 ldr w10,[x1,#7388]
 cmp w10,#0
 b.le .Lrgs_bad
 cmp w9,w10
 b.hi .Lrgs_bad
 sub w9,w9,#1
 udiv w9,w9,w6
 add w9,w9,#1
 cmp w8,w9
 b.ne .Lrgs_bad
 ldr w11,[x2,#48]
 ldr w12,[x2,#72]
 ldr w13,[x2,#80]
 ldr w14,[x2,#84]
 cmp w11,#512
 b.hi .Lrgs_bad
 cmp w12,#512
 b.hi .Lrgs_bad
 cmp w13,#512
 b.hi .Lrgs_bad
 cmp w14,#512
 b.hi .Lrgs_bad
 stp w6,w7,[x0]
 stp w8,w11,[x0,#8]
 stp w12,w13,[x0,#16]
 str w14,[x0,#24]
 mov w0,#0
 ret
.size md2asm_bind_runtime_distributed_gridpoint_shape,.-md2asm_bind_runtime_distributed_gridpoint_shape
.macro RGS_FRAME
 sub sp,sp,#256
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
.endm
.macro RGS_LEAVE
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.endm
.p2align 4
.global md2asm_initialize_runtime_distributed_gridpoint_field
.type md2asm_initialize_runtime_distributed_gridpoint_field,%function
md2asm_initialize_runtime_distributed_gridpoint_field:
 mrs x9,fpcr
 cbnz x9,.Lrgs_bad
 cbz x0,.Lrgs_bad
 cbz x1,.Lrgs_bad
 cbz x2,.Lrgs_bad
 cmp x3,#0
 b.le .Lrgs_bad
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lrgs_bad
 adds x4,x0,#1096
 b.cs .Lrgs_bad
 mov x9,#20400
 adds x5,x1,x9
 b.cs .Lrgs_bad
 RGS_CONST x9,1359136
 adds x6,x2,x9
 b.cs .Lrgs_bad
 cmp x0,x5
 b.hs .Lrgs_init_pair02
 cmp x1,x4
 b.lo .Lrgs_bad
.Lrgs_init_pair02:
 cmp x0,x6
 b.hs .Lrgs_init_pair12
 cmp x2,x4
 b.lo .Lrgs_bad
.Lrgs_init_pair12:
 cmp x1,x6
 b.hs .Lrgs_init_fresh
 cmp x2,x5
 b.lo .Lrgs_bad
.Lrgs_init_fresh:
 mov x9,#0
.Lrgs_fresh_loop:
 ldr x10,[x0,x9]
 cbnz x10,.Lrgs_bad
 add x9,x9,#8
 cmp x9,#1096
 b.lo .Lrgs_fresh_loop
 RGS_FRAME
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 add x0,sp,#144
 bl md2asm_bind_runtime_distributed_gridpoint_shape
 cbnz w0,.Lrgs_init_bad_early
 ldp w26,w27,[sp,#144]
 ldr w28,[sp,#152]
 mul x24,x26,x27
 mul x24,x24,x28
 lsl x24,x24,#3
 mov x23,#0
 mov x20,#0
 add x14,sp,#156
 add x15,sp,#176
.Lrgs_sizes:
 ldr w9,[x14,x23,lsl#2]
 mul x11,x24,x9
 str x11,[x15,x23,lsl#3]
 mov x12,#1
 cmp x11,#0
 csel x12,x11,x12,ne
 adds x20,x20,x12
 b.cs .Lrgs_init_bad_early
 tbnz x20,#63,.Lrgs_init_bad_early
 cmp x20,x22
 b.hi .Lrgs_init_bad_early
 add x23,x23,#1
 cmp x23,#4
 b.lo .Lrgs_sizes
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 /* Preserve the accepted full-shape specialization under exact runtime checks. */
 cmp w26,#17
 b.ne .Lrgs_generic
 cmp w27,#137
 b.ne .Lrgs_generic
 RGS_CONST w9,97055
 cmp w28,w9
 b.ne .Lrgs_generic
 ldr w9,[sp,#156]
 cmp w9,#9
 b.ne .Lrgs_generic
 ldr w9,[sp,#160]
 cmp w9,#3
 b.ne .Lrgs_generic
 ldr w9,[sp,#164]
 cbnz w9,.Lrgs_generic
 ldr w9,[sp,#168]
 cbnz w9,.Lrgs_generic
 mov x0,x19
 add x1,sp,#144
 mov x2,x21
 bl md2asm_initialize_distributed_gridpoint_field
 mov w28,w0
 b .Lrgs_return_status
.Lrgs_generic:
 str x21,[x19,#1088]
 mov x25,#0
.Lrgs_allocate:
 add x9,sp,#176
 ldr x0,[x9,x25,lsl#3]
 mov x9,#1
 cmp x0,#0
 csel x0,x0,x9,ne
 bl malloc
 cbz x0,.Lrgs_allocation_failed
 mov x1,x0
 adr x9,.Lrgs_owner_offsets
 ldr w9,[x9,x25,lsl#2]
 add x0,x19,x9
 mov w2,w26
 mov w3,w27
 add x9,sp,#156
 ldr w4,[x9,x25,lsl#2]
 mov w5,w28
 bl .Lrgs_rank_four_descriptor
 add x25,x25,#1
 cmp x25,#4
 b.lo .Lrgs_allocate
 mov w28,#0
 b .Lrgs_return_status
.Lrgs_allocation_failed:
 mov x0,x19
 bl md2asm_release_gridpoint_field
 mov w28,#1
.Lrgs_return_status:
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 mov w0,w28
 RGS_LEAVE
.Lrgs_init_bad_early:
 mov w0,#2
 RGS_LEAVE
.size md2asm_initialize_runtime_distributed_gridpoint_field,.-md2asm_initialize_runtime_distributed_gridpoint_field
/* Unchanged source rank-four descriptor equations with runtime extents. */
.p2align 4
.Lrgs_rank_four_descriptor:
 uxtw x2,w2
 uxtw x3,w3
 uxtw x4,w4
 uxtw x5,w5
 str x1,[x0]
 mul x6,x2,x3
 mul x7,x6,x4
 add x8,x2,x6
 add x8,x8,x7
 add x8,x8,#1
 neg x8,x8
 str x8,[x0,#8]
 mov x8,#8
 str x8,[x0,#16]
 str wzr,[x0,#24]
 mov w8,#0x304
 str w8,[x0,#28]
 mov x8,#8
 str x8,[x0,#32]
 mov x8,#1
 stp x8,x8,[x0,#40]
 str x2,[x0,#56]
 stp x2,x8,[x0,#64]
 str x3,[x0,#80]
 stp x6,x8,[x0,#88]
 str x4,[x0,#104]
 stp x7,x8,[x0,#112]
 str x5,[x0,#128]
 ret
.Lrgs_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 2
.Lrgs_owner_offsets: .word 0,272,408,544
.section .note.GNU-stack,"",%progbits

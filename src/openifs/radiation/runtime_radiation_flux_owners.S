/* Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_flux_owners.md. */
/* Live source-order TRADF ownership. x0 MODEL,x1 capacity,x2 Geometry,
 * x3 capacity,x4 byte quota. Return 0 success,1 allocation,2 admission.
 * No floating-point instruction is used. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_runtime_radiation_flux_owners
.type md2asm_create_runtime_radiation_flux_owners,%function
md2asm_create_runtime_radiation_flux_owners:
 cbz x0,.Lrfo_bad_leaf
 cbz x2,.Lrfo_bad_leaf
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lrfo_bad_leaf
 movz x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x1,x9
 b.lo .Lrfo_bad_leaf
 adds x10,x0,x9
 b.cs .Lrfo_bad_leaf
 mov x9,#20400
 cmp x3,x9
 b.lo .Lrfo_bad_leaf
 adds x11,x2,x9
 b.cs .Lrfo_bad_leaf
 cmp x0,x11
 b.hs .Lrfo_spans_ok
 cmp x2,x10
 b.lo .Lrfo_bad_leaf
.Lrfo_spans_ok:
 cbz x4,.Lrfo_bad_leaf
 mov x9,#1
 lsl x9,x9,#36
 cmp x4,x9
 b.hi .Lrfo_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Lrfo_bad_leaf
 sub sp,sp,#4096
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#112]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 movz x9,#(1577888&65535)
 movk x9,#(1577888>>16),lsl#16
 add x9,x19,x9
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lrfo_bad_frame
 ldr w11,[x9,#380]
 cmp w11,#1
 b.hi .Lrfo_bad_frame
 movz x9,#(1608728&65535)
 movk x9,#(1608728>>16),lsl#16
 add x9,x19,x9
 ldr w12,[x9,#488]
 cmp w12,#1
 b.hi .Lrfo_bad_frame
 ldr w13,[x9,#76]
 mov w10,#1
 cbz w11,.Lrfo_control_ready
 cbz w12,.Lrfo_control_ready
 mov w10,#6
.Lrfo_control_ready:
 cmp w13,w10
 b.ne .Lrfo_bad_frame
 str w12,[sp,#120]
 str w13,[sp,#124]
 mov x9,#5144
 ldrsw x22,[x20,x9]
 mov x9,#5224
 ldrsw x23,[x20,x9]
 mov x9,#5160
 ldrsw x24,[x20,x9]
 cmp x22,#1
 b.lt .Lrfo_bad_frame
 cmp x22,#4096
 b.gt .Lrfo_bad_frame
 cmp x23,#1
 b.lt .Lrfo_bad_frame
 cmp x23,#512
 b.gt .Lrfo_bad_frame
 cmp x24,#1
 b.lt .Lrfo_bad_frame
 movz x9,#(1606488&65535)
 movk x9,#(1606488>>16),lsl#16
 add x20,x19,x9
 adrp x9,.Lrfo_all_heads
 add x9,x9,:lo12:.Lrfo_all_heads
 mov x10,#0
.Lrfo_fresh:
 ldr w11,[x9,x10,lsl#2]
 ldr x12,[x20,x11]
 cbnz x12,.Lrfo_bad_frame
 add x10,x10,#1
 cmp x10,#23
 b.lo .Lrfo_fresh
 add x25,sp,#128
 mov x9,#0
.Lrfo_copy:
 add x10,x20,x9
 ldp x11,x12,[x10]
 add x10,x25,x9
 stp x11,x12,[x10]
 add x9,x9,#16
 cmp x9,#2240
 b.lo .Lrfo_copy
 add x26,sp,#2432
 adrp x28,.Lrfo_templates
 add x28,x28,:lo12:.Lrfo_templates
 mov x27,#0
 mov x14,#0
.Lrfo_plan:
 add x9,x28,x27,lsl#4
 ldp w10,w11,[x9]
 ldp w12,w13,[x9,#8]
 add x9,x26,x27,lsl#5
 stp w10,w11,[x9]
 str w12,[x9,#8]
 str wzr,[x9,#12]
 mov w10,w22
 mov w11,w24
 mov w12,#1
 mov w15,#1
 cmp w13,#4
 b.eq .Lrfo_dimensions
 add w11,w23,#1
 mov w12,w24
 cmp w13,#0
 b.eq .Lrfo_dimensions
 cmp w13,#1
 b.ne .Lrfo_not_lw
 ldr w11,[sp,#124]
 b .Lrfo_dimensions
.Lrfo_not_lw:
 cmp w13,#2
 b.ne .Lrfo_derivative
 mov w11,w23
 mov w12,#6
 mov w15,w24
 b .Lrfo_dimensions
.Lrfo_derivative:
 ldr w16,[sp,#120]
 cbnz w16,.Lrfo_dimensions
 mov w10,#1
 mov w11,#1
 mov w12,#1
.Lrfo_dimensions:
 stp w10,w11,[x9,#16]
 stp w12,w15,[x9,#24]
 ldr w11,[x9,#4]
 add x10,x9,#16
 mov x12,#8
 mov x13,#0
.Lrfo_product:
 ldr w15,[x10,x13,lsl#2]
 umulh x16,x12,x15
 cbnz x16,.Lrfo_bad_frame
 mul x12,x12,x15
 add x13,x13,#1
 cmp x13,x11
 b.lo .Lrfo_product
 adds x14,x14,x12
 b.cs .Lrfo_bad_frame
 cmp x14,x21
 b.hi .Lrfo_bad_frame
 add x27,x27,#1
 cmp x27,#21
 b.lo .Lrfo_plan
 bl __errno_location
 str x0,[sp,#96]
 ldr w9,[x0]
 str w9,[sp,#104]
 mov x27,#0
.Lrfo_allocate:
 add x9,x26,x27,lsl#5
 ldp w10,w1,[x9]
 add x0,x25,x10
 add x2,x9,#16
 mov w3,#1
 ldr w4,[x9,#8]
 bl md2asm_allocate_radiation_flux_array
 cbnz w0,.Lrfo_failed
 add x27,x27,#1
 cmp x27,#21
 b.lo .Lrfo_allocate
 mov x9,#0
.Lrfo_commit:
 add x10,x25,x9
 ldp x11,x12,[x10]
 add x10,x20,x9
 stp x11,x12,[x10]
 add x9,x9,#16
 cmp x9,#2240
 b.lo .Lrfo_commit
 ldr x9,[sp,#96]
 ldr w10,[sp,#104]
 str w10,[x9]
 mov w0,#0
 b .Lrfo_return
.Lrfo_failed:
 mov x0,x25
 mov x1,#2240
 bl md2asm_release_selected_radiation_fluxes
 mov w0,#1
 b .Lrfo_return
.Lrfo_bad_frame:
 mov w0,#2
.Lrfo_return:
 ldr x18,[sp,#112]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#4096
 ret
.Lrfo_bad_leaf:
 mov w0,#2
 ret
.size md2asm_create_runtime_radiation_flux_owners,.-md2asm_create_runtime_radiation_flux_owners
.section .rodata
.p2align 3
.Lrfo_templates:
 .word 0,3,0,0 // EMTD
 .word 112,3,0,0 // TRSW
 .word 224,3,0,0 // EMTC
 .word 336,3,0,0 // TRSC
 .word 560,4,1,2 // TAUAER
 .word 696,2,0,4 // SRSWD
 .word 984,2,0,4 // SRSWDC
 .word 872,3,0,1 // SRLWD
 .word 784,2,0,4 // SRLWDC
 .word 1072,2,0,4 // SRSWDCS
 .word 1160,2,0,4 // SRLWDCS
 .word 1248,2,0,4 // SRSWDV
 .word 1336,2,0,4 // SRSWDUV
 .word 1424,2,0,4 // EDRO
 .word 1512,2,0,4 // SRSWPAR
 .word 1600,2,0,4 // SRSWUVB
 .word 1688,2,0,4 // SRSWPARC
 .word 1776,2,0,4 // SRSWTINC
 .word 1864,2,0,4 // SRFDIR
 .word 1952,2,0,4 // SRCDIR
 .word 2128,3,0,3 // DERIVATIVELW
.Lrfo_all_heads:
 .word 0,112,224,336,448,560,696,784,872,984,1072,1160,1248,1336,1424,1512,1600,1688,1776,1864,1952,2040,2128
.section .note.GNU-stack,"",%progbits

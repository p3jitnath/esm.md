/* Actual distributed GPNORM1. Contract skills/md2asm/references/openifs/transport/distributed_grid_point_norms.md.
 * Original6 addresses,zero hidden character length,dependency32 in x0..x7.
 * dependency={partition4096*,configuration67616*,HYD64*,reserved0}.
 * The1280-byte frame preserves x18,x19..x30. No floating-point instructions.
 * Public ECTRANS performs the source norm; public FIAT retains its broadcasts. */
.arch armv8.2-a
.text
.p2align 4
.macro OGN_CALL target
 bl \target
 ldr x18,[sp,#48]
.endm
.global md2asm_operational_grid_point_norm
.type md2asm_operational_grid_point_norm,%function
md2asm_operational_grid_point_norm:
 cbz x0,.Logn_early_refuse
 cbz x1,.Logn_early_refuse
 cbz x2,.Logn_early_refuse
 cbz x3,.Logn_early_refuse
 cbnz x4,.Logn_early_refuse
 cbz x5,.Logn_early_refuse
 cbnz x6,.Logn_early_refuse
 cbz x7,.Logn_early_refuse
 orr x9,x0,x1
 orr x9,x9,x5
 orr x9,x9,x7
 tst x9,#7
 b.ne .Logn_early_refuse
 orr x9,x2,x3
 tst x9,#3
 b.ne .Logn_early_refuse
 ldr w9,[x3]
 cbnz w9,.Logn_early_refuse
 ldr w9,[x2]
 sub w10,w9,#1
 cmp w10,#15
 b.hi .Logn_early_refuse
 mrs x10,fpcr
 cbnz x10,.Logn_early_refuse
 ldr x10,[x7,#24]
 cbnz x10,.Logn_early_refuse
 ldp x10,x11,[x7]
 cbz x10,.Logn_early_refuse
 cbz x11,.Logn_early_refuse
 orr x12,x10,x11
 tst x12,#7
 b.ne .Logn_early_refuse
 ldr w12,[x10,#24]
 cmp w12,#4
 b.ne .Logn_early_refuse
 ldr w12,[x10,#28]
 sub w12,w12,#1
 cmp w12,#3
 b.hi .Logn_early_refuse
 movz x12,#(67600&65535)
 movk x12,#(67600>>16),lsl#16
 ldr w12,[x11,x12]
 cbnz w12,.Logn_early_refuse
 ldr w10,[x0,#5144]
 cmp w10,#17
 b.ne .Logn_early_refuse
 ldr w10,[x0,#5160]
 mov w11,#31519
 movk w11,#1,lsl#16
 cmp w10,w11
 b.ne .Logn_early_refuse
 ldr w10,[x0,#7376]
 mov w11,#(1649920&65535)
 movk w11,#25,lsl#16
 cmp w10,w11
 b.ne .Logn_early_refuse
 /* Bound complete input/output ranges before constructing public descriptors. */
 mov x10,#(13199480&65535)
 movk x10,#(13199480>>16),lsl#16
 mul x10,x9,x10
 adds x11,x1,x10
 b.cs .Logn_early_refuse
 mov x12,#24
 mul x12,x12,x9
 adds x13,x5,x12
 b.cs .Logn_early_refuse
 cmp x5,x11
 b.hs .Logn_ranges_disjoint
 cmp x13,x1
 b.hi .Logn_early_refuse
.Logn_ranges_disjoint:
 sub sp,sp,#1280
 stp x29,x30,[sp,#32]
 stp x18,x19,[sp,#48]
 stp x20,x21,[sp,#64]
 stp x22,x23,[sp,#80]
 stp x24,x25,[sp,#96]
 stp x26,x27,[sp,#112]
 str x28,[sp,#128]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x9
 mov x23,x5
 mov x24,x7
 str wzr,[sp,#168]
 mov w9,#1
 str w9,[sp,#172]
 add x0,sp,#192
 mov x1,x20
 mov x2,#17
 mov x3,x22
 mov x4,#31519
 movk x4,#1,lsl#16
 mov w5,#3
 bl .Logn_descriptor
 add x0,sp,#320
 add x1,sp,#576
 mov x2,x22
 mov w5,#1
 bl .Logn_descriptor
 add x0,sp,#384
 add x1,sp,#704
 mov x2,x22
 mov w5,#1
 bl .Logn_descriptor
 add x0,sp,#448
 add x1,sp,#832
 mov x2,x22
 mov w5,#1
 bl .Logn_descriptor
 add x0,sp,#192
 mov x1,x21
 mov x9,#5144
 add x2,x19,x9
 add x3,sp,#320
 add x4,sp,#384
 add x5,sp,#448
 add x6,sp,#168
 mov x9,#5168
 add x7,x19,x9
 OGN_CALL gpnorm_trans_
 mov x25,#0
.Logn_broadcast:
 adr x9,.Logn_tags
 ldr w10,[x9,x25,lsl#2]
 str w10,[sp,#176]
 add x0,sp,#320
 add x0,x0,x25,lsl#6
 add x1,sp,#176
 add x2,sp,#172
 mov x3,xzr
 mov x4,xzr
 mov x5,xzr
 mov x6,xzr
 adr x7,.Logn_labels
 mov x9,#12
 madd x7,x25,x9,x7
 str x9,[sp]
 OGN_CALL __mpl_broadcast_mod_MOD_mpl_broadcast_real8
 add x25,x25,#1
 cmp x25,#3
 b.lo .Logn_broadcast
 mov x25,#0
.Logn_publish:
 add x9,sp,#576
 ldr x10,[x9,x25,lsl#3]
 add x9,sp,#704
 ldr x11,[x9,x25,lsl#3]
 add x9,sp,#832
 ldr x12,[x9,x25,lsl#3]
 mov x9,#24
 madd x9,x25,x9,x23
 stp x10,x11,[x9]
 str x12,[x9,#16]
 add x25,x25,#1
 cmp x25,x22
 b.lo .Logn_publish
 mov w0,#0
 ldr x28,[sp,#128]
 ldp x26,x27,[sp,#112]
 ldp x24,x25,[sp,#96]
 ldp x22,x23,[sp,#80]
 ldp x20,x21,[sp,#64]
 ldp x18,x19,[sp,#48]
 ldp x29,x30,[sp,#32]
 add sp,sp,#1280
 ret
.Logn_early_refuse:
 mov w0,#2
 ret
.size md2asm_operational_grid_point_norm,.-md2asm_operational_grid_point_norm
/* Same GNU REAL8 descriptor layout as accepted public ECTRANS callers. */
.Logn_descriptor:
 str x1,[x0]
 mov x6,#8
 str x6,[x0,#16]
 str wzr,[x0,#24]
 mov w6,#0x300
 orr w6,w6,w5
 str w6,[x0,#28]
 mov x6,#8
 str x6,[x0,#32]
 mov x6,#1
 mov x7,#1
 mov x8,#0
 add x9,x0,#40
.Logn_descriptor_dimension:
 stp x6,x7,[x9]
 str x2,[x9,#16]
 add x8,x8,x6
 mul x6,x6,x2
 add x9,x9,#24
 subs w5,w5,#1
 b.eq .Logn_descriptor_done
 mov x2,x3
 mov x3,x4
 b .Logn_descriptor_dimension
.Logn_descriptor_done:
 neg x8,x8
 str x8,[x0,#8]
 ret
.section .rodata
.p2align 2
.Logn_tags: .word 12345,12445,12545
.Logn_labels: .ascii "GPNORM1-AVE:GPNORM1-MIN:GPNORM1-MAX:"
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/radiation/radiation_control_setup.md.
 * Raw array owner: x0 descriptor, w1 rank1..4, x2 uint32 extents[4],
 * w3 first lower bound0/1, w4 zero-payload flag. All spans are prevalidated.
 * Return0 or1. Only malloc and memset are external services. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_radiation_flux_array
.type md2asm_allocate_radiation_flux_array,%function
md2asm_allocate_radiation_flux_array:
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov w20,w1
 mov x21,x2
 mov w22,w3
 mov w23,w4
 mov x24,#8
 mov x9,#0
.Lra_count:
 ldr w10,[x21,x9,lsl#2]
 mul x24,x24,x10
 add x9,x9,#1
 cmp x9,x20
 b.lo .Lra_count
 mov x0,x24
 bl malloc
 cbz x0,.Lra_failed
 mov x25,x0
 str x0,[x19]
 mov x9,#8
 str x9,[x19,#16]
 str xzr,[x19,#24]
 strb w20,[x19,#28]
 mov w10,#3
 strb w10,[x19,#29]
 str x9,[x19,#32]
 mov x26,#1
 mov x12,#0
 mov x13,#0
 add x14,x19,#40
.Lra_dimension:
 ldr w10,[x21,x12,lsl#2]
 mov x11,#1
 cbnz x12,.Lra_lower_set
 mov w11,w22
.Lra_lower_set:
 add x15,x10,x11
 sub x15,x15,#1
 stp x26,x11,[x14]
 str x15,[x14,#16]
 madd x13,x26,x11,x13
 mul x26,x26,x10
 add x14,x14,#24
 add x12,x12,#1
 cmp x12,x20
 b.lo .Lra_dimension
 neg x13,x13
 str x13,[x19,#8]
 cbz w23,.Lra_success
 mov x0,x25
 mov w1,#0
 mov x2,x24
 bl memset
.Lra_success:
 mov w0,#0
 b .Lra_return
.Lra_failed:
 mov w0,#1
.Lra_return:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_allocate_radiation_flux_array,.-md2asm_allocate_radiation_flux_array


.section .note.GNU-stack,"",%progbits

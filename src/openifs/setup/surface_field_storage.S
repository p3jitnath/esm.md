/* Contract: skills/md2asm/references/openifs/setup/surface_field_storage.md. */
/* Complete ALLO_SURF/DEALLO_SURF owner stage, revision 1.
 * initialize(x0 fresh TSURF18224B,w1 rows,w2 blocks) -> w0 0/1/2.
 * Only the 34 source numerical owners and their descriptors change.
 * Count fields are caller-owned explicit configuration. No original data/call.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_surface_field_owners
.type md2asm_allocate_surface_field_owners,%function
md2asm_allocate_surface_field_owners:
 cbz x0,.Lsurface_reject
 tst x0,#7
 b.ne .Lsurface_reject
 sub w9,w1,#1
 cmp w9,#63
 b.hi .Lsurface_reject
 sub w9,w2,#1
 cmp w9,#127
 b.hi .Lsurface_reject
 mrs x9,fpcr
 cbnz x9,.Lsurface_reject
 adr x9,.Lsurface_owners
 mov w10,#34
.Lsurface_validate:
 ldr w11,[x9]
 add x11,x0,w11,uxtw
 ldr w12,[x9,#12]
 mov w13,#14
 cmp w12,#4
 b.ne .Lsurface_empty_descriptor
 mov w13,#17
.Lsurface_empty_descriptor:
 ldr x14,[x11],#8
 cbnz x14,.Lsurface_reject
 subs w13,w13,#1
 b.ne .Lsurface_empty_descriptor
 ldr w11,[x9,#4]
 ldr w11,[x0,w11,uxtw]
 cmp w11,#512
 b.hi .Lsurface_reject
 /* Form the checked complete element count without reduced-width products. */
 umull x13,w1,w2
 mul x13,x13,x11
 cmp w12,#4
 b.ne .Lsurface_check_bytes
 ldr w11,[x9,#8]
 ldr w11,[x0,w11,uxtw]
 cmp w11,#64
 b.hi .Lsurface_reject
 mul x13,x13,x11
.Lsurface_check_bytes:
 lsl x13,x13,#3
 mov x14,#0x4000000
 cmp x13,x14
 b.hi .Lsurface_reject
 add x9,x9,#16
 subs w10,w10,#1
 b.ne .Lsurface_validate
.Lsurface_operational_validated:
 sub sp,sp,#144
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov w20,w1
 mov w21,w2
 adr x22,.Lsurface_owners
 mov w23,#34
 mrs x9,fpcr
 str x9,[sp,#112]
 mrs x9,fpsr
 str x9,[sp,#120]
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
.Lsurface_allocate:
 ldr w9,[x22,#4]
 ldr w9,[x19,w9,uxtw]
 umull x26,w20,w21
 mul x26,x26,x9
 ldr w27,[x22,#12]
 cmp w27,#4
 b.ne .Lsurface_allocate_bytes
 ldr w9,[x22,#8]
 ldr w9,[x19,w9,uxtw]
 mul x26,x26,x9
.Lsurface_allocate_bytes:
 lsl x26,x26,#3
 cmp x26,#0
 mov x9,#1
 csel x0,x26,x9,ne
 bl malloc
 cbz x0,.Lsurface_failed
 mov x28,x0
 ldr w9,[x22]
 add x0,x19,w9,uxtw
 mov x1,x28
 mov w2,w27
 mov w3,w20
 ldr w9,[x22,#4]
 ldr w4,[x19,w9,uxtw]
 mov w5,w21
 mov x6,#1
 cmp w27,#4
 b.ne .Lsurface_describe
 mov w5,w4
 ldr w9,[x22,#8]
 ldr w4,[x19,w9,uxtw]
 mov w6,w21
.Lsurface_describe:
 bl .Lsurface_descriptor
 add x22,x22,#16
 subs w23,w23,#1
 b.ne .Lsurface_allocate
 /* Original assignment order after all allocations is SL, RR, SG, VF. */
 adr x22,.Lsurface_zero_order
 mov w23,#4
.Lsurface_zero_selected:
 ldr w9,[x22],#4
 adr x10,.Lsurface_owners
 add x10,x10,x9,lsl#4
 ldr w9,[x10]
 ldr x0,[x19,w9,uxtw]
 ldr w9,[x10,#4]
 ldr w9,[x19,w9,uxtw]
 umull x1,w20,w21
 mul x1,x1,x9
 ldr w9,[x10,#12]
 cmp w9,#4
 b.ne .Lsurface_zero_bytes
 ldr w9,[x10,#8]
 ldr w9,[x19,w9,uxtw]
 mul x1,x1,x9
.Lsurface_zero_bytes:
 lsl x1,x1,#3
 bl .Lsurface_zero_owner
 subs w23,w23,#1
 b.ne .Lsurface_zero_selected
 mov w0,#0
 b .Lsurface_return
.Lsurface_failed:
 mov x0,x19
 bl md2asm_release_surface_field_owners
 mov w0,#1
.Lsurface_return:
 str w25,[x24]
 ldr x9,[sp,#112]
 msr fpcr,x9
 ldr x9,[sp,#120]
 msr fpsr,x9
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.Lsurface_reject:
 mov w0,#2
 ret
.size md2asm_allocate_surface_field_owners,.-md2asm_allocate_surface_field_owners

/* Descriptor arguments are base, data, rank, then up to four extents. */
.Lsurface_descriptor:
 str x1,[x0]
 mov x7,#8
 str x7,[x0,#16]
 str xzr,[x0,#24]
 orr w7,w2,#0x300
 str w7,[x0,#28]
 mov x7,#8
 str x7,[x0,#32]
 mov x7,#1
 str x7,[x0,#40]
 str x7,[x0,#48]
 str x3,[x0,#56]
 str x3,[x0,#64]
 str x7,[x0,#72]
 str x4,[x0,#80]
 mul x8,x3,x4
 str x8,[x0,#88]
 str x7,[x0,#96]
 str x5,[x0,#104]
 neg x9,x7
 sub x9,x9,x3
 sub x9,x9,x8
 cmp w2,#4
 b.ne .Lsurface_descriptor_done
 mul x8,x8,x5
 str x8,[x0,#112]
 str x7,[x0,#120]
 str x6,[x0,#128]
 sub x9,x9,x8
.Lsurface_descriptor_done:
 str x9,[x0,#8]
 ret
.Lsurface_zero_owner:
 cmp x1,#16
 b.lo .Lsurface_zero_tail
 stp xzr,xzr,[x0],#16
 sub x1,x1,#16
 b .Lsurface_zero_owner
.Lsurface_zero_tail:
 cbz x1,.Lsurface_zero_return
 str xzr,[x0]
.Lsurface_zero_return:
 ret

.p2align 4
.global md2asm_release_surface_field_owners
.type md2asm_release_surface_field_owners,%function
md2asm_release_surface_field_owners:
 cbz x0,.Lsurface_release_reject
 tst x0,#7
 b.ne .Lsurface_release_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mrs x9,fpcr
 str x9,[sp,#64]
 mrs x9,fpsr
 str x9,[sp,#72]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 adr x22,.Lsurface_owners
 mov w23,#34
.Lsurface_release_loop:
 ldr w9,[x22]
 ldr x0,[x19,w9,uxtw]
 cbz x0,.Lsurface_release_next
 bl free
 ldr w9,[x22]
 str xzr,[x19,w9,uxtw]
.Lsurface_release_next:
 add x22,x22,#16
 subs w23,w23,#1
 b.ne .Lsurface_release_loop
 str w21,[x20]
 ldr x9,[sp,#64]
 msr fpcr,x9
 ldr x9,[sp,#72]
 msr fpsr,x9
 mov w0,#0
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lsurface_release_reject:
 mov w0,#2
 ret
.size md2asm_release_surface_field_owners,.-md2asm_release_surface_field_owners
/* Allocate the complete operational shape after checking every source tuple.
 * x0 is the 18,224-byte surface record; w1=17 and w2=388217.
 * The original allocation, descriptor, zero and release paths are shared.
 */
.text
.p2align 4
.global md2asm_allocate_operational_surface_field_owners
.type md2asm_allocate_operational_surface_field_owners,%function
md2asm_allocate_operational_surface_field_owners:
 cbz x0,.Lsurface_reject
 tst x0,#7
 b.ne .Lsurface_reject
 mov x9,#18224
 adds x9,x0,x9
 b.cs .Lsurface_reject
 cmp w1,#17
 b.ne .Lsurface_reject
 movz w9,#0xec79
 movk w9,#5,lsl#16
 cmp w2,w9
 b.ne .Lsurface_reject
 mrs x9,fpcr
 cbnz x9,.Lsurface_reject
 adr x9,.Lsurface_owners
 adr x15,.Lsurface_operational_counts
 mov w10,#34
.Lsurface_operational_validate:
 ldr w11,[x9]
 add x11,x0,w11,uxtw
 ldr w12,[x9,#12]
 mov w13,#14
 cmp w12,#4
 b.ne .Lsurface_operational_empty
 mov w13,#17
.Lsurface_operational_empty:
 ldr x14,[x11],#8
 cbnz x14,.Lsurface_reject
 subs w13,w13,#1
 b.ne .Lsurface_operational_empty
 ldr w11,[x9,#4]
 ldr w11,[x0,w11,uxtw]
 ldr w16,[x15]
 cmp w11,w16
 b.ne .Lsurface_reject
 cmp w12,#4
 b.ne .Lsurface_operational_next
 ldr w11,[x9,#8]
 ldr w11,[x0,w11,uxtw]
 ldr w17,[x15,#4]
 cmp w11,w17
 b.ne .Lsurface_reject
.Lsurface_operational_next:
 add x9,x9,#16
 add x15,x15,#8
 subs w10,w10,#1
 b.ne .Lsurface_operational_validate
 b .Lsurface_operational_validated
.size md2asm_allocate_operational_surface_field_owners,.-md2asm_allocate_operational_surface_field_owners

.section .rodata
.p2align 3
.Lsurface_owners:
 .word 5744,5884,5888,4 /* SP_SB */
 .word 6032,6172,6176,4 /* SP_SG */
 .word 6336,6452,0,3 /* SP_SL */
 .word 6632,6748,0,3 /* SP_RR */
 .word 6912,7028,0,3 /* SP_CL */
 .word 7200,7340,7344,4 /* SP_OM */
 .word 7496,7636,7640,4 /* SP_EP */
 .word 7760,7876,0,3 /* SP_X2 */
 .word 8000,8116,0,3 /* SP_CI */
 .word 8784,8900,0,3 /* SD_VF */
 .word 9856,9972,0,3 /* SD_VP */
 .word 10112,10228,0,3 /* SD_VV */
 .word 10432,10548,0,3 /* SD_VN */
 .word 10712,10828,0,3 /* SD_VH */
 .word 11040,11156,0,3 /* SD_VK */
 .word 11288,11404,0,3 /* SD_VA */
 .word 11576,11692,0,3 /* SD_VC */
 .word 11840,11956,0,3 /* SD_V2 */
 .word 12104,12244,12248,4 /* SD_V3 */
 .word 12488,12604,0,3 /* SD_VD */
 .word 14856,14996,15000,4 /* SD_SM */
 .word 15136,15252,0,3 /* SD_WS */
 .word 15448,15564,0,3 /* SD_WW */
 .word 15752,15868,0,3 /* SD_VX */
 .word 16104,16244,16248,4 /* SD_XA */
 .word 16640,16780,16784,4 /* SD_XR */
 .word 16904,17020,0,3 /* SD_X2 */
 .word 17144,17260,0,3 /* SD_SFL */
 .word 17384,17500,0,3 /* SD_SFO */
 .word 17624,17764,17768,4 /* SD_PF */
 .word 16368,16508,16512,4 /* SD_DI */
 .word 17888,18004,0,3 /* SD_OC */
 .word 8240,8380,8384,4 /* SD_XP */
 .word 8512,8652,8656,4 /* SD_XP2 */
 .p2align 2
.Lsurface_zero_order: .word 2,3,1,9

.p2align 3
.Lsurface_operational_counts:
 .word 6,4 /* SP_SB */
 .word 10,5 /* SP_SG */
 .word 14,1 /* SP_SL */
 .word 4,1 /* SP_RR */
 .word 0,1 /* SP_CL */
 .word 0,0 /* SP_OM */
 .word 0,0 /* SP_EP */
 .word 0,1 /* SP_X2 */
 .word 0,1 /* SP_CI */
 .word 38,1 /* SD_VF */
 .word 0,1 /* SD_VP */
 .word 0,1 /* SD_VV */
 .word 5,1 /* SD_VN */
 .word 0,1 /* SD_VH */
 .word 0,1 /* SD_VK */
 .word 0,1 /* SD_VA */
 .word 0,1 /* SD_VC */
 .word 0,1 /* SD_V2 */
 .word 0,0 /* SD_V3 */
 .word 272,1 /* SD_VD */
 .word 0,0 /* SD_SM */
 .word 3,1 /* SD_WS */
 .word 6,1 /* SD_WW */
 .word 0,1 /* SD_VX */
 .word 0,0 /* SD_XA */
 .word 0,0 /* SD_XR */
 .word 0,1 /* SD_X2 */
 .word 0,1 /* SD_SFL */
 .word 0,1 /* SD_SFO */
 .word 1,137 /* SD_PF */
 .word 0,0 /* SD_DI */
 .word 0,1 /* SD_OC */
 .word 0,0 /* SD_XP */
 .word 0,0 /* SD_XP2 */
.section .note.GNU-stack,"",%progbits

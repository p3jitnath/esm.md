/* Original GNU12 surface default metadata, fixed 33 source groups.
 * Inputs are geometry and surface objects. Outputs have 1536,98304,64 bytes.
 * Copy raw original default constants and owner bounds, never forecast values.
 * 192-byte frame preserves x19..x28. No child or floating-point instruction.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_surface_default_metadata_direct_
.type md2asm_surface_default_metadata_direct_,%function
md2asm_surface_default_metadata_direct_:
 mov x5,x2
 mov x6,#96
.Lclear_owners:
 stp xzr,xzr,[x5],#16
 subs x6,x6,#1
 b.ne .Lclear_owners
 mov x5,x3
 mov x6,#6144
.Lclear_assignments:
 stp xzr,xzr,[x5],#16
 subs x6,x6,#1
 b.ne .Lclear_assignments
 stp xzr,xzr,[x4]
 stp xzr,xzr,[x4,#16]
 stp xzr,xzr,[x4,#32]
 stp xzr,xzr,[x4,#48]
 mov x5,#1
 str x5,[x4]
 ldr w5,[x0,#5144]
 cmp w5,#24
 b.ne .Learly
 ldr w5,[x0,#5160]
 cmp w5,#86
 b.ne .Learly
 stp x19,x20,[sp,#-192]!
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 mov x19,x1
 mov x20,x2
 mov x21,x3
 mov x22,x4
 adrp x23,.Lgroups
 add x23,x23,:lo12:.Lgroups
 mov x24,#0
 mov x25,#0
 mov x26,#0
 mov x27,#33
.Lgroup:
 ldr w8,[x23,#4]
 add x8,x19,x8
 ldrsw x9,[x8,#4]
 cmp x9,#0
 b.le .Lnext_group
 cmp x9,#4096
 b.hi .Lreject
 str x9,[sp,#88]
 ldrsw x10,[x8]
 cmp x10,#0
 b.lt .Lreject
 str x10,[sp,#104]
 ldr w11,[x23,#12]
 str x11,[sp,#80]
 mov x12,#1
 cmp x11,#4
 b.ne .Llevels_ready
 ldrsw x12,[x8,#8]
 cmp x12,#1
 b.lt .Lreject
.Llevels_ready:
 str x12,[sp,#96]
 mul x13,x9,x12
 cmp x13,#4096
 b.hi .Lreject
 ldr w14,[x23]
 add x14,x19,x14
 ldr x15,[x14]
 cbz x15,.Lreject
 ldr x16,[x14,#16]
 cmp x16,#8
 b.ne .Lreject
 ldrb w16,[x14,#28]
 cmp x16,x11
 b.ne .Lreject
 // Validate every dimension of the true complete allocation.
 mov x0,#0
 mov x1,#1
.Ldimension:
 cmp x0,#0
 b.ne .Lnot_first
 mov x2,#24
 b .Ldimension_extent
.Lnot_first:
 sub x3,x11,#1
 cmp x0,x3
 b.ne .Lnot_last
 mov x2,#86
 b .Ldimension_extent
.Lnot_last:
 cmp x11,#4
 b.ne .Lplane_dimension
 cmp x0,#1
 b.ne .Lplane_dimension
 mov x2,x12
 b .Ldimension_extent
.Lplane_dimension:
 mov x2,x9
.Ldimension_extent:
 add x3,x0,x0,lsl#1
 add x3,x14,x3,lsl#3
 ldr x4,[x3,#40]
 cmp x4,x1
 b.ne .Lreject
 ldp x4,x5,[x3,#48]
 sub x5,x5,x4
 add x5,x5,#1
 cmp x5,x2
 b.ne .Lreject
 mul x1,x1,x2
 add x0,x0,#1
 cmp x0,x11
 b.ne .Ldimension
 // Validate the original contiguous array of field metadata.
 ldr w8,[x23,#8]
 add x8,x19,x8
 ldr x28,[x8]
 cbz x28,.Lreject
 ldr x0,[x8,#40]
 cmp x0,#1
 b.ne .Lreject
 ldp x0,x1,[x8,#48]
 sub x1,x1,x0
 add x1,x1,#1
 cmp x10,x1
 b.gt .Lreject
 ldrb w0,[x8,#28]
 cmp w0,#1
 b.ne .Lreject
 mov x0,#64
 cmp x11,#3
 b.eq .Lmetadata_size
 mov x0,#288
.Lmetadata_size:
 ldr x1,[x8,#16]
 cmp x1,x0
 b.ne .Lreject
 str x0,[sp,#112]
 mov x0,#16512
 mul x0,x13,x0
 add x1,x24,x24,lsl#1
 add x1,x20,x1,lsl#3
 stp x15,x0,[x1]
 str x13,[x1,#16]
 add x26,x26,x0
 add x24,x24,#1
 str x10,[sp,#120]
 cbz x10,.Lnext_group
.Lfield:
 ldr x11,[sp,#80]
 cmp x11,#4
 b.eq .Llayered
 ldr w0,[x28,#56]
 cmn w0,#1
 b.ne .Lnext_field
 ldrsw x1,[x28]
 ldr x2,[sp,#88]
 cmp x1,#1
 b.lt .Lreject
 cmp x1,x2
 b.gt .Lreject
 sub x1,x1,#1
 ldr x2,[x28,#48]
 b .Lappend_2d
.Llayered:
 add x8,x28,#224
 ldr x9,[x8]
 cbz x9,.Lreject
 ldr x10,[x8,#16]
 cmp x10,#4
 b.ne .Lreject
 ldr x10,[x8,#40]
 cmp x10,#1
 b.ne .Lreject
 ldp x10,x11,[x8,#48]
 cmp x10,#1
 b.gt .Lreject
 ldr x12,[sp,#96]
 cmp x11,x12
 b.lt .Lreject
 sub x10,x10,#1
 sub x9,x9,x10,lsl#2
 str x9,[sp,#144]
 mov x4,#0
.Llevel:
 ldr x9,[sp,#144]
 ldr w0,[x9,x4,lsl#2]
 cmn w0,#1
 b.ne .Lnext_level
 add x8,x28,#160
 ldr x9,[x8]
 cbz x9,.Lreject
 ldr x10,[x8,#16]
 cmp x10,#8
 b.ne .Lreject
 ldr x10,[x8,#40]
 cmp x10,#1
 b.ne .Lreject
 ldp x10,x11,[x8,#48]
 add x12,x4,#1
 cmp x12,x10
 b.lt .Lreject
 cmp x12,x11
 b.gt .Lreject
 sub x12,x12,x10
 ldr x2,[x9,x12,lsl#3]
 ldrsw x1,[x28]
 ldr x9,[sp,#88]
 cmp x1,#1
 b.lt .Lreject
 cmp x1,x9
 b.gt .Lreject
 sub x1,x1,#1
 ldr x9,[sp,#96]
 madd x1,x1,x9,x4
 cmp x25,#4096
 b.hs .Lreject
 add x8,x25,x25,lsl#1
 add x8,x21,x8,lsl#3
 sub x0,x24,#1
 stp x0,x1,[x8]
 str x2,[x8,#16]
 add x25,x25,#1
.Lnext_level:
 add x4,x4,#1
 ldr x9,[sp,#96]
 cmp x4,x9
 b.ne .Llevel
 b .Lnext_field
.Lappend_2d:
 cmp x25,#4096
 b.hs .Lreject
 add x8,x25,x25,lsl#1
 add x8,x21,x8,lsl#3
 sub x0,x24,#1
 stp x0,x1,[x8]
 str x2,[x8,#16]
 add x25,x25,#1
.Lnext_field:
 ldr x0,[sp,#112]
 add x28,x28,x0
 ldr x0,[sp,#120]
 subs x0,x0,#1
 str x0,[sp,#120]
 b.ne .Lfield
.Lnext_group:
 add x23,x23,#16
 subs x27,x27,#1
 b.ne .Lgroup
 str xzr,[x22]
 stp x24,x25,[x22,#8]
 mov x0,#24
 mov x1,#86
 stp x0,x1,[x22,#24]
 str x26,[x22,#40]
.Lreject:
 ldp x19,x20,[sp]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 add sp,sp,#192
.Learly:
 ret
.size md2asm_surface_default_metadata_direct_,.-md2asm_surface_default_metadata_direct_
.section .rodata
.p2align 3
.Lgroups:
 .word 5744,5880,5968,4 // SP_SB
 .word 6032,6168,6272,4 // SP_SG
 .word 6336,6448,6568,3 // SP_SL
 .word 6632,6744,6848,3 // SP_RR
 .word 6912,7024,7136,3 // SP_CL
 .word 7200,7336,7432,4 // SP_OM
 .word 7496,7632,7696,4 // SP_EP
 .word 7760,7872,7936,3 // SP_X2
 .word 8784,8896,9792,3 // SD_VF
 .word 9856,9968,10048,3 // SD_VP
 .word 10112,10224,10368,3 // SD_VV
 .word 10432,10544,10648,3 // SD_VN
 .word 10712,10824,10936,3 // SD_VH
 .word 11040,11152,11224,3 // SD_VK
 .word 11288,11400,11512,3 // SD_VA
 .word 11576,11688,11776,3 // SD_VC
 .word 11840,11952,12040,3 // SD_V2
 .word 12104,12240,12424,4 // SD_V3
 .word 17888,18000,18152,3 // SD_OC
 .word 12488,12600,14704,3 // SD_VD
 .word 14856,14992,15072,4 // SD_SM
 .word 15136,15248,15312,3 // SD_WS
 .word 15448,15560,15624,3 // SD_WW
 .word 15752,15864,16040,3 // SD_VX
 .word 16104,16240,16304,4 // SD_XA
 .word 16640,16776,16840,4 // SD_XR
 .word 16368,16504,16568,4 // SD_DI
 .word 16904,17016,17080,3 // SD_X2
 .word 17144,17256,17320,3 // SD_SFL
 .word 17384,17496,17560,3 // SD_SFO
 .word 17624,17760,17824,4 // SD_PF
 .word 8240,8376,8448,4 // SD_XP
 .word 8512,8648,8720,4 // SD_XP2
.section .note.GNU-stack,"",%progbits

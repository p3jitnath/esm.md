/* Contract: skills/md2asm/references/openifs/support/physics_surface_block_views.md.
 * Runtime source block metadata, with complete private allocation before commit.
 * Fallback payloads are undefined and are never initialized or read here.
 */
.arch armv8.2-a
.text
.p2align 4
.macro SURFACE_CALL name
 bl \name
 ldr x18,[sp,#96]
.endm
.global md2asm_prepare_physics_surface_block_views
.type md2asm_prepare_physics_surface_block_views,%function
md2asm_prepare_physics_surface_block_views:
 sub sp,sp,#1824
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x10,fpsr
 str x10,[sp,#112]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x7
 uxtw x6,w6
 str x6,[sp,#152]
 cbnz x9,.Lsurface_bad
 cbz x19,.Lsurface_bad
 tst x19,#7
 b.ne .Lsurface_bad
 mov x9,#13680
 cmp x1,x9
 b.lo .Lsurface_bad
 adds x10,x19,x9
 b.cs .Lsurface_bad
 cbz x20,.Lsurface_bad
 tst x20,#7
 b.ne .Lsurface_bad
 mov x9,#18224
 cmp x3,x9
 b.lo .Lsurface_bad
 adds x11,x20,x9
 b.cs .Lsurface_bad
 cbz x21,.Lsurface_bad
 tst x21,#7
 b.ne .Lsurface_bad
 mov x9,#20400
 cmp x5,x9
 b.lo .Lsurface_bad
 adds x12,x21,x9
 b.cs .Lsurface_bad
 cmp x19,x11
 b.hs .Lsurface_pair02
 cmp x20,x10
 b.lo .Lsurface_bad
.Lsurface_pair02:
 cmp x19,x12
 b.hs .Lsurface_pair12
 cmp x21,x10
 b.lo .Lsurface_bad
.Lsurface_pair12:
 cmp x20,x12
 b.hs .Lsurface_top_clear
 cmp x21,x11
 b.lo .Lsurface_bad
.Lsurface_top_clear:
 mov x9,#5144
 ldr w9,[x21,x9]
 sub w10,w9,#1
 cmp w10,#1023
 b.hi .Lsurface_bad
 uxtw x27,w9
 mov x10,#7376
 ldr w10,[x21,x10]
 cmp w10,#1
 b.lt .Lsurface_bad
 sub w10,w10,#1
 udiv w10,w10,w9
 add w10,w10,#1
 mov x11,#5160
 ldr w11,[x21,x11]
 cmp w11,w10
 b.ne .Lsurface_bad
 uxtw x28,w11
 cmp x6,x28
 b.hs .Lsurface_bad
 add x25,sp,#160
 mov x9,#8376
 add x9,x19,x9
 mov x10,x25
 mov x11,#208
.Lsurface_stage_copy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lsurface_stage_copy
 adrp x23,.Lsurface_rows
 add x23,x23,:lo12:.Lsurface_rows
 mov x24,#17
 mov x26,#0
.Lsurface_preflight_row:
 ldp w9,w10,[x23]
 ldp w11,w12,[x23,#8]
 ldr w13,[x23,#16]
 add x0,x25,x9
 ldrsw x14,[x20,x11]
 cmp x14,#0
 b.le .Lsurface_fallback_preflight
 add x1,x20,x10
 mov w2,w13
 mov x3,x14
 cmp w13,#3
 b.ne .Lsurface_active_dimensions
 ldrsw x3,[x20,x12]
 cmp x3,#0
 b.lt .Lsurface_bad
.Lsurface_active_dimensions:
 mov x4,x14
 ldr x5,[sp,#152]
 mov x6,x28
 mov x7,x27
 bl .Lsurface_borrowed_view
 cbnz w0,.Lsurface_bad
 b .Lsurface_preflight_next
.Lsurface_fallback_preflight:
 ldr x15,[x0]
 cbnz x15,.Lsurface_bad
 mov x1,x27
 mov x2,#1
 cmp w13,#3
 b.ne .Lsurface_fallback_dimensions
 ldrsw x2,[x20,x12]
 mov x15,#1
 cmp x2,x15
 csel x2,x2,x15,ge
.Lsurface_fallback_dimensions:
 mov w3,w13
 bl .Lsurface_fallback_view
 adds x26,x26,x0
 b.cs .Lsurface_bad
 cmp x26,x22
 b.hi .Lsurface_bad
.Lsurface_preflight_next:
 add x23,x23,#20
 subs x24,x24,#1
 b.ne .Lsurface_preflight_row
 SURFACE_CALL __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 adrp x23,.Lsurface_rows
 add x23,x23,:lo12:.Lsurface_rows
 mov x24,#17
.Lsurface_allocate_row:
 ldr w9,[x23,#8]
 ldrsw x9,[x20,x9]
 cmp x9,#0
 b.gt .Lsurface_allocate_next
 ldr w9,[x23]
 add x10,x25,x9
 ldr x9,[x10,#56]
 ldr x10,[x10,#80]
 mul x0,x9,x10
 lsl x0,x0,#3
 SURFACE_CALL malloc
 cbz x0,.Lsurface_allocation_failed
 ldr w9,[x23]
 add x10,x25,x9
 str x0,[x10]
.Lsurface_allocate_next:
 add x23,x23,#20
 subs x24,x24,#1
 b.ne .Lsurface_allocate_row
 mov x9,#8376
 add x9,x19,x9
 mov x10,x25
 mov x11,#208
.Lsurface_commit:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lsurface_commit
 mov w0,#0
 b .Lsurface_restore_errno
.Lsurface_allocation_failed:
 ldr x9,[sp,#120]
 ldr w10,[x9]
 str w10,[sp,#132]
 adrp x23,.Lsurface_rows
 add x23,x23,:lo12:.Lsurface_rows
 mov x24,#17
.Lsurface_failed_row:
 ldr w9,[x23,#8]
 ldrsw x9,[x20,x9]
 cmp x9,#0
 b.gt .Lsurface_failed_next
 ldr w9,[x23]
 add x10,x25,x9
 ldr x0,[x10]
 cbz x0,.Lsurface_failed_next
 SURFACE_CALL free
 ldr w9,[x23]
 add x10,x25,x9
 str xzr,[x10]
.Lsurface_failed_next:
 add x23,x23,#20
 subs x24,x24,#1
 b.ne .Lsurface_failed_row
 ldr w9,[sp,#132]
 str w9,[sp,#128]
 mov w0,#1
.Lsurface_restore_errno:
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 b .Lsurface_return
.Lsurface_bad:
 mov w0,#2
.Lsurface_return:
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1824
 ret
.size md2asm_prepare_physics_surface_block_views,.-md2asm_prepare_physics_surface_block_views

/* Validate a canonical source and describe its retained full block.
 * x0 destination, x1 source, w2 output rank, x3 dim2, x4 dim3,
 * x5 block0, x6 blocks, x7 width. No pointer target is read.
 */
.Lsurface_borrowed_view:
 ldr x8,[x1]
 cbz x8,.Lsurface_view_bad
 tst x8,#7
 b.ne .Lsurface_view_bad
 ldr x9,[x1,#16]
 cmp x9,#8
 b.ne .Lsurface_view_bad
 ldr x9,[x1,#32]
 cmp x9,#8
 b.ne .Lsurface_view_bad
 add x10,x2,#1
 movz x11,#0x300,lsl#32
 orr x10,x11,x10,lsl#32
 ldr x9,[x1,#24]
 cmp x9,x10
 b.ne .Lsurface_view_bad
 mov x9,#0
 mov x10,#1
 mov x11,#0
 add x13,x1,#40
 add x14,x0,#40
.Lsurface_source_dimension:
 mov x12,x7
 cbz x9,.Lsurface_extent_ready
 mov x12,x3
 cmp x9,#1
 b.eq .Lsurface_extent_ready
 mov x12,x4
.Lsurface_extent_ready:
 ldp x15,x16,[x13]
 cmp x15,x10
 b.ne .Lsurface_view_bad
 cmp x16,#1
 b.ne .Lsurface_view_bad
 ldr x15,[x13,#16]
 cmp x15,x12
 b.ne .Lsurface_view_bad
 mov x16,#1
 stp x10,x16,[x14]
 str x12,[x14,#16]
 sub x11,x11,x10
 umulh x16,x10,x12
 cbnz x16,.Lsurface_view_bad
 mul x10,x10,x12
 tbnz x10,#63,.Lsurface_view_bad
 add x9,x9,#1
 add x13,x13,#24
 add x14,x14,#24
 cmp x9,x2
 b.lo .Lsurface_source_dimension
 ldp x15,x16,[x13]
 cmp x15,x10
 b.ne .Lsurface_view_bad
 cmp x16,#1
 b.ne .Lsurface_view_bad
 ldr x15,[x13,#16]
 cmp x15,x6
 b.ne .Lsurface_view_bad
 sub x16,x11,x10
 ldr x15,[x1,#8]
 cmp x15,x16
 b.ne .Lsurface_view_bad
 umulh x16,x10,x6
 cbnz x16,.Lsurface_view_bad
 mul x15,x10,x6
 lsr x16,x15,#60
 cbnz x16,.Lsurface_view_bad
 lsl x15,x15,#3
 mov x16,#1
 cmp x15,#0
 csel x15,x15,x16,ne
 adds x16,x8,x15
 b.cs .Lsurface_view_bad
 mov x15,#13680
 add x15,x19,x15
 cmp x8,x15
 b.hs .Lsurface_payload_clear
 cmp x19,x16
 b.lo .Lsurface_view_bad
.Lsurface_payload_clear:
 mul x16,x5,x10
 add x8,x8,x16,lsl#3
 str x8,[x0]
 str x11,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x10,#0x300,lsl#32
 orr x10,x10,x2,lsl#32
 str x10,[x0,#24]
 mov w0,#0
 ret
.Lsurface_view_bad:
 mov w0,#2
 ret

/* Build only the owned fallback description and return its request bytes.
 * x0 destination, x1 width, x2 second extent, w3 output rank.
 */
.Lsurface_fallback_view:
 str xzr,[x0]
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x10,#0x300,lsl#32
 orr x10,x10,x3,lsl#32
 str x10,[x0,#24]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x1,[x0,#56]
 stp x1,x9,[x0,#64]
 str x2,[x0,#80]
 add x10,x1,#1
 neg x10,x10
 mul x11,x1,x2
 cmp w3,#3
 b.ne .Lsurface_fallback_rank_ready
 stp x11,x9,[x0,#88]
 str x9,[x0,#104]
 sub x10,x10,x11
.Lsurface_fallback_rank_ready:
 str x10,[x0,#8]
 lsl x0,x11,#3
 ret

.p2align 4
.global md2asm_release_physics_surface_block_views
.type md2asm_release_physics_surface_block_views,%function
md2asm_release_physics_surface_block_views:
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mrs x9,fpcr
 str x9,[sp,#56]
 mrs x10,fpsr
 str x10,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 cbnz x9,.Lsurface_release_bad
 cbz x19,.Lsurface_release_bad
 tst x19,#7
 b.ne .Lsurface_release_bad
 mov x9,#13680
 cmp x1,x9
 b.lo .Lsurface_release_bad
 adds x10,x19,x9
 b.cs .Lsurface_release_bad
 cbz x20,.Lsurface_release_bad
 tst x20,#7
 b.ne .Lsurface_release_bad
 mov x9,#18224
 cmp x3,x9
 b.lo .Lsurface_release_bad
 adds x11,x20,x9
 b.cs .Lsurface_release_bad
 cmp x19,x11
 b.hs .Lsurface_release_spans_clear
 cmp x20,x10
 b.lo .Lsurface_release_bad
.Lsurface_release_spans_clear:
 bl __errno_location
 ldr x18,[sp,#48]
 str x0,[sp,#72]
 ldr w9,[x0]
 str w9,[sp,#80]
 adrp x21,.Lsurface_rows
 add x21,x21,:lo12:.Lsurface_rows
 mov x22,#17
.Lsurface_release_row:
 ldr w9,[x21,#8]
 ldrsw x9,[x20,x9]
 cmp x9,#0
 b.gt .Lsurface_release_next
 ldr w9,[x21]
 mov x10,#8376
 add x9,x9,x10
 ldr x0,[x19,x9]
 cbz x0,.Lsurface_release_next
 bl free
 ldr x18,[sp,#48]
 ldr w9,[x21]
 mov x10,#8376
 add x9,x9,x10
 str xzr,[x19,x9]
.Lsurface_release_next:
 add x21,x21,#20
 subs x22,x22,#1
 b.ne .Lsurface_release_row
 ldr x9,[sp,#72]
 ldr w10,[sp,#80]
 str w10,[x9]
 mov w0,#0
 b .Lsurface_release_return
.Lsurface_release_bad:
 mov w0,#2
.Lsurface_release_return:
 ldr x9,[sp,#56]
 msr fpcr,x9
 ldr x9,[sp,#64]
 msr fpsr,x9
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.size md2asm_release_physics_surface_block_views,.-md2asm_release_physics_surface_block_views

.section .rodata
.p2align 3
/* destination relative to SURF+8376, source description, NDIM, NLEVS, rank */
.Lsurface_rows:
 .word 1104,5744,5884,5888,3 // PSP_SB
 .word 880,6032,6172,6176,3 // PSP_SG
 .word 0,6336,6452,0,2 // PSP_SL
 .word 88,6632,6748,0,2 // PSP_RR
 .word 1216,7496,7636,7640,3 // PSP_EP
 .word 176,7760,7876,0,2 // PSP_X2
 .word 992,7200,7340,7344,3 // PSP_OM
 .word 352,8784,8900,0,2 // PSD_VF
 .word 440,10432,10548,0,2 // PSD_VN
 .word 616,12488,12604,0,2 // PSD_VD
 .word 264,15136,15252,0,2 // PSD_WS
 .word 792,15448,15564,0,2 // PSD_WW
 .word 1440,16104,16244,16248,3 // PSD_XA
 .word 704,16904,17020,0,2 // PSD_X2
 .word 1552,14856,14996,15000,3 // PSD_SM
 .word 528,11840,11956,0,2 // PSD_V2
 .word 1328,12104,12244,12248,3 // PSD_V3
.section .note.GNU-stack,"",%progbits

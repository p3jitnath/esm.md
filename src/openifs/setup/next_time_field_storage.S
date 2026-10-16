/* Contract: skills/md2asm/references/openifs/setup/next_time_field_storage.md.
 * prepare(x0 FIELDS529288,x1 capacity,x2 shape4i32)->w0 status.
 * Allocate/zero only missing GMVT1,GMVT1S,GFLT1 owners in source order. */
.arch armv8.2-a
.text
/* GNU contiguous real descriptor; x0 desc,x1 owner,x2-x5 extents,w6 rank. */
.Lnext_descriptor:
 str x1,[x0]
 mov x7,#8
 str x7,[x0,#16]
 str wzr,[x0,#24]
 mov w7,#0x300
 orr w7,w7,w6
 str w7,[x0,#28]
 mov x7,#8
 str x7,[x0,#32]
 mov x7,#1
 mov x8,#1
 mov x9,#0
 add x10,x0,#40
 mov x11,x2
.Lnext_descriptor_dimension:
 stp x7,x8,[x10]
 str x11,[x10,#16]
 add x9,x9,x7
 mul x7,x7,x11
 add x10,x10,#24
 subs w6,w6,#1
 b.eq .Lnext_descriptor_done
 mov x11,x3
 mov x3,x4
 mov x4,x5
 b .Lnext_descriptor_dimension
.Lnext_descriptor_done:
 neg x9,x9
 str x9,[x0,#8]
 ret
/* x0 owner,x1 multiple-of-eight span; positive-zero stores only. */
.Lnext_zero:
 cmp x1,#16
 b.lo .Lnext_zero_tail
 stp xzr,xzr,[x0],#16
 sub x1,x1,#16
 b .Lnext_zero
.Lnext_zero_tail:
 cbz x1,.Lnext_zero_done
 str xzr,[x0]
.Lnext_zero_done:
 ret
.p2align 4
.global md2asm_prepare_next_time_fields
.type md2asm_prepare_next_time_fields,%function
md2asm_prepare_next_time_fields:
 cbz x0,.Lnext_reject
 cbz x2,.Lnext_reject
 tst x0,#7
 b.ne .Lnext_reject
 tst x2,#3
 b.ne .Lnext_reject
 movz x9,#(529288 & 65535)
 movk x9,#(529288 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lnext_reject
 adds x10,x0,x9
 b.cs .Lnext_reject
 adds x11,x2,#16
 b.cs .Lnext_reject
 cmp x0,x11
 b.hs .Lnext_shape
 cmp x2,x10
 b.lo .Lnext_reject
.Lnext_shape:
 ldr w9,[x2]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Lnext_reject
 ldr w9,[x2,#4]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Lnext_reject
 ldr w9,[x2,#8]
 sub w9,w9,#1
 cmp w9,#127
 b.hi .Lnext_reject
 ldr w9,[x2,#12]
 cmp w9,#64
 b.hi .Lnext_reject
 ldr w9,[x0,#3216]
 cmp w9,#64
 b.hi .Lnext_reject
 ldr w9,[x0,#3220]
 cmp w9,#64
 b.hi .Lnext_reject
 mrs x9,fpcr
 cbnz x9,.Lnext_reject
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 str xzr,[sp,#136]
 mov x19,x0
 mov x20,x2
 ldr w24,[x20]
 ldr w25,[x20,#4]
 ldr w26,[x20,#8]
 ldr w9,[x20,#12]
 str x9,[sp,#128]
 ldr w27,[x19,#3216]
 ldr w28,[x19,#3220]
 bl __errno_location
 mov x22,x0
 ldr w23,[x22]
 mov x21,#0
.Lnext_owner:
 adr x9,.Lnext_owner_offsets
 ldr w9,[x9,x21,lsl#2]
 str x9,[sp,#152]
 ldr x10,[x19,x9]
 cbnz x10,.Lnext_owner_done
 mov x0,x24
 cmp x21,#1
 b.eq .Lnext_surface_size
 mul x0,x0,x25
 cbnz x21,.Lnext_grid_size
 mul x0,x0,x27
 b .Lnext_block_size
.Lnext_grid_size:
 ldr x9,[sp,#128]
 mul x0,x0,x9
 b .Lnext_block_size
.Lnext_surface_size:
 mul x0,x0,x28
.Lnext_block_size:
 mul x0,x0,x26
 lsl x0,x0,#3
 str x0,[sp,#144]
 mov x9,#1
 cmp x0,#1
 csel x0,x0,x9,hs
 bl malloc
 cbz x0,.Lnext_failed
 mov x1,x0
 ldr x9,[sp,#152]
 add x0,x19,x9
 mov x2,x24
 cmp x21,#1
 b.eq .Lnext_surface_shape
 mov x3,x25
 mov x5,x26
 mov w6,#4
 cbnz x21,.Lnext_grid_shape
 mov x4,x27
 b .Lnext_set_descriptor
.Lnext_grid_shape:
 ldr x4,[sp,#128]
 b .Lnext_set_descriptor
.Lnext_surface_shape:
 mov x3,x28
 mov x4,x26
 mov x5,#1
 mov w6,#3
.Lnext_set_descriptor:
 bl .Lnext_descriptor
 mov x9,#1
 lsl x9,x9,x21
 ldr x10,[sp,#136]
 orr x10,x10,x9
 str x10,[sp,#136]
 ldr x9,[sp,#152]
 ldr x0,[x19,x9]
 ldr x1,[sp,#144]
 bl .Lnext_zero
.Lnext_owner_done:
 add x21,x21,#1
 cmp x21,#3
 b.lo .Lnext_owner
 mov w0,#0
 b .Lnext_restore
.Lnext_failed:
 mov x0,x19
 ldr w1,[sp,#136]
 bl .Lnext_release_mask
 mov w0,#1
.Lnext_restore:
 str w23,[x22]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Lnext_reject:
 mov w0,#2
 ret
.size md2asm_prepare_next_time_fields,.-md2asm_prepare_next_time_fields
.p2align 4
.global md2asm_release_next_time_fields
.type md2asm_release_next_time_fields,%function
md2asm_release_next_time_fields:
 cbz x0,.Lnext_release_empty
 tst x0,#7
 b.ne .Lnext_reject
 mov w1,#7
 b .Lnext_release_mask
.size md2asm_release_next_time_fields,.-md2asm_release_next_time_fields
/* x0 valid FIELDS, w1 exact acquired-owner bit set. */
.Lnext_release_mask:
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov w23,w1
 mrs x9,fpcr
 str x9,[sp,#64]
 mrs x9,fpsr
 str x9,[sp,#72]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 mov x22,#0
.Lnext_free_owner:
 mov w9,#1
 lsl w9,w9,w22
 tst w9,w23
 b.eq .Lnext_free_done
 adr x9,.Lnext_owner_offsets
 ldr w9,[x9,x22,lsl#2]
 ldr x0,[x19,x9]
 cbz x0,.Lnext_free_done
 bl free
 adr x9,.Lnext_owner_offsets
 ldr w9,[x9,x22,lsl#2]
 str xzr,[x19,x9]
.Lnext_free_done:
 add x22,x22,#1
 cmp x22,#3
 b.lo .Lnext_free_owner
 str w21,[x20]
 ldr x9,[sp,#64]
 msr fpcr,x9
 ldr x9,[sp,#72]
 msr fpsr,x9
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#96
.Lnext_release_empty:
 mov w0,#0
 ret
.section .rodata
.p2align 2
.Lnext_owner_offsets: .word 2104,2240,3552
.section .note.GNU-stack,"",%progbits

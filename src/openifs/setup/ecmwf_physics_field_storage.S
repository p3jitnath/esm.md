/* Contract: skills/md2asm/references/openifs/setup/ecmwf_physics_field_storage.md.
 * x0 fresh704B record,x1 capacity,x2 shape4i32,x3 owned field-count4B.
 * Source allocation order: five TILEPROP arrays, then PHYS_MWAVE.
 * Only libc allocation/release/errno services are external. */
.arch armv8.2-a
.text
/* GNU contiguous real descriptor; x0 desc,x1 owner,x2-x5 extents,w6 rank. */
.Lphysics_descriptor:
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
.Lphysics_descriptor_dimension:
 stp x7,x8,[x10]
 str x11,[x10,#16]
 add x9,x9,x7
 mul x7,x7,x11
 add x10,x10,#24
 subs w6,w6,#1
 b.eq .Lphysics_descriptor_done
 mov x11,x3
 mov x3,x4
 mov x4,x5
 b .Lphysics_descriptor_dimension
.Lphysics_descriptor_done:
 neg x9,x9
 str x9,[x0,#8]
 ret
/* x0 owner,x1 multiple-of-eight span; positive-zero stores only. */
.Lphysics_zero:
 cmp x1,#16
 b.lo .Lphysics_zero_tail
 stp xzr,xzr,[x0],#16
 sub x1,x1,#16
 b .Lphysics_zero
.Lphysics_zero_tail:
 cbz x1,.Lphysics_zero_done
 str xzr,[x0]
.Lphysics_zero_done:
 ret
.p2align 4
.global md2asm_initialize_ecmwf_physics_fields
.type md2asm_initialize_ecmwf_physics_fields,%function
md2asm_initialize_ecmwf_physics_fields:
 cbz x0,.Lphysics_reject
 cbz x2,.Lphysics_reject
 cbz x3,.Lphysics_reject
 tst x0,#7
 b.ne .Lphysics_reject
 orr x4,x2,x3
 tst x4,#3
 b.ne .Lphysics_reject
 cmp x1,#704
 b.lo .Lphysics_reject
 adds x4,x0,#704
 b.cs .Lphysics_reject
 adds x5,x2,#16
 b.cs .Lphysics_reject
 adds x6,x3,#4
 b.cs .Lphysics_reject
 cmp x0,x5
 b.hs .Lphysics_count_range
 cmp x2,x4
 b.lo .Lphysics_reject
.Lphysics_count_range:
 cmp x0,x6
 b.hs .Lphysics_input_ranges
 cmp x3,x4
 b.lo .Lphysics_reject
.Lphysics_input_ranges:
 cmp x2,x6
 b.hs .Lphysics_shape
 cmp x3,x5
 b.lo .Lphysics_reject
.Lphysics_shape:
 ldr w4,[x2]
 sub w4,w4,#1
 cmp w4,#63
 b.hi .Lphysics_reject
 ldr w4,[x2,#4]
 sub w4,w4,#1
 cmp w4,#63
 b.hi .Lphysics_reject
 ldr w4,[x2,#8]
 sub w4,w4,#1
 cmp w4,#127
 b.hi .Lphysics_reject
 ldr w4,[x2,#12]
 sub w4,w4,#1
 cmp w4,#15
 b.hi .Lphysics_reject
 mrs x4,fpcr
 cbnz x4,.Lphysics_reject
 mov x4,#0
.Lphysics_fresh:
 ldr x5,[x0,x4]
 cbnz x5,.Lphysics_reject
 add x4,x4,#8
 cmp x4,#704
 b.lo .Lphysics_fresh
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mrs x4,fpcr
 str x4,[sp,#104]
 mrs x4,fpsr
 str x4,[sp,#112]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 ldr w24,[x20]
 ldr w25,[x20,#4]
 ldr w26,[x20,#8]
 ldr w27,[x20,#12]
 mul x4,x24,x27
 mul x4,x4,x26
 lsl x4,x4,#3
 str x4,[sp,#128]
 bl __errno_location
 mov x22,x0
 ldr w23,[x22]
 /* TETILEPROP.CREATE allocates all five owners before zeroing them. */
 mov x28,#0
.Lphysics_allocate_tiles:
 ldr x0,[sp,#128]
 bl malloc
 cbz x0,.Lphysics_allocation_failed
 mov x1,x0
 mov x9,#112
 madd x0,x28,x9,x19
 mov x2,x24
 mov x3,x27
 mov x4,x26
 mov x5,#1
 mov w6,#3
 bl .Lphysics_descriptor
 add x28,x28,#1
 cmp x28,#5
 b.lo .Lphysics_allocate_tiles
 mov x28,#0
.Lphysics_zero_tiles:
 mov x9,#112
 madd x9,x28,x9,x19
 ldr x0,[x9]
 ldr x1,[sp,#128]
 bl .Lphysics_zero
 add x28,x28,#1
 cmp x28,#5
 b.lo .Lphysics_zero_tiles
 /* TEPHYSMWAVE.CREATE sets this scalar before its allocation. */
 mov w9,#9
 str w9,[x21]
 mul x0,x24,x25
 mul x0,x0,x26
 mov x9,#9
 mul x0,x0,x9
 lsl x0,x0,#3
 str x0,[sp,#136]
 bl malloc
 cbz x0,.Lphysics_allocation_failed
 mov x1,x0
 add x0,x19,#568
 mov x2,x24
 mov x3,x25
 mov x4,#9
 mov x5,x26
 mov w6,#4
 bl .Lphysics_descriptor
 ldr x0,[x19,#568]
 ldr x1,[sp,#136]
 bl .Lphysics_zero
 mov w0,#0
 b .Lphysics_restore
.Lphysics_allocation_failed:
 mov x0,x19
 bl md2asm_release_ecmwf_physics_fields
 mov w0,#1
.Lphysics_restore:
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
.Lphysics_reject:
 mov w0,#2
 ret
.size md2asm_initialize_ecmwf_physics_fields,.-md2asm_initialize_ecmwf_physics_fields
.p2align 4
.global md2asm_release_ecmwf_physics_fields
.type md2asm_release_ecmwf_physics_fields,%function
md2asm_release_ecmwf_physics_fields:
 cbz x0,.Lphysics_release_empty
 tst x0,#7
 b.ne .Lphysics_reject
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
 adr x23,.Lphysics_owner_offsets
 mov x22,#0
.Lphysics_release_owner:
 ldr w9,[x23,x22,lsl#2]
 ldr x0,[x19,x9]
 cbz x0,.Lphysics_release_next
 bl free
 ldr w9,[x23,x22,lsl#2]
 str xzr,[x19,x9]
.Lphysics_release_next:
 add x22,x22,#1
 cmp x22,#6
 b.lo .Lphysics_release_owner
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
.Lphysics_release_empty:
 mov w0,#0
 ret
.size md2asm_release_ecmwf_physics_fields,.-md2asm_release_ecmwf_physics_fields
.section .rodata
.p2align 2
.Lphysics_owner_offsets: .word 0,112,224,336,448,568
.section .note.GNU-stack,"",%progbits

// Allocate coarse spherical block owners and bind source-equivalent views.
// Contract: skills/md2asm/references/openifs/setup/geometry_block_storage.md. No numerical arithmetic.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_geometry_block_storage
.type md2asm_allocate_geometry_block_storage,%function
md2asm_allocate_geometry_block_storage:
 cbz x0,.Linvalid
 cbz x1,.Linvalid
 cbz x2,.Linvalid
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Linvalid
 adds x9,x0,#2024
 b.cs .Linvalid
 adds x10,x1,#64
 b.cs .Linvalid
 adds x11,x2,#64
 b.cs .Linvalid
 cmp x0,x10
 b.hs .Labs_disjoint
 cmp x1,x9
 b.lo .Linvalid
.Labs_disjoint:
 cmp x0,x11
 b.hs .Labc_disjoint
 cmp x2,x9
 b.lo .Linvalid
.Labc_disjoint:
 cmp x1,x11
 b.hs .Lroots_disjoint
 cmp x2,x10
 b.lo .Linvalid
.Lroots_disjoint:
 mov x9,x0
 mov w10,#23
.Lcheck_empty:
 ldr x11,[x9]
 cbnz x11,.Linvalid
 add x9,x9,#88
 subs w10,w10,#1
 b.ne .Lcheck_empty
 ldr x9,[x1]
 ldr x10,[x2]
 orr x9,x9,x10
 cbnz x9,.Linvalid
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adrp x22,.Lallocation_rules
 add x22,x22,:lo12:.Lallocation_rules
 mov w23,#0
.Lallocate_next:
 ldp w9,w10,[x22]
 mov x24,x19
 cmp w9,#1
 csel x24,x20,x24,eq
 cmp w9,#2
 csel x24,x21,x24,eq
 add x24,x24,w10,uxtw
 ldr w0,[x22,#12]
 bl malloc
 cbz x0,.Lallocation_failed
 str x0,[x24]
 ldr w25,[x22,#8]
 ldp w9,w10,[x22,#16]
 mov x11,#-1
 cmp w9,#2
 mov x12,#-25
 csel x11,x12,x11,eq
 str x11,[x24,#8]
 str x25,[x24,#16]
 lsl x10,x10,#40
 orr x10,x10,x9,lsl#32
 str x10,[x24,#24]
 str x25,[x24,#32]
 mov x10,#1
 stp x10,x10,[x24,#40]
 mov x11,#86
 cmp w9,#2
 b.eq .Lrank_two
 str x11,[x24,#56]
 b .Lallocation_done
.Lrank_two:
 mov x12,#24
 str x12,[x24,#56]
 stp x12,x10,[x24,#64]
 str x11,[x24,#80]
.Lallocation_done:
 add x22,x22,#24
 add w23,w23,#1
 cmp w23,#25
 b.ne .Lallocate_next
 mov w0,#0
 b .Lallocate_return
.Lallocation_failed:
 adrp x22,.Lallocation_rules
 add x22,x22,:lo12:.Lallocation_rules
 mov w23,#25
.Lrelease_next:
 ldp w9,w10,[x22]
 mov x24,x19
 cmp w9,#1
 csel x24,x20,x24,eq
 cmp w9,#2
 csel x24,x21,x24,eq
 add x24,x24,w10,uxtw
 ldr x0,[x24]
 cbz x0,.Lreleased
 bl free
 str xzr,[x24]
.Lreleased:
 add x22,x22,#24
 subs w23,w23,#1
 b.ne .Lrelease_next
 mov w0,#1
.Lallocate_return:
 ldp x25,x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Linvalid:
 mov w0,#2
 ret
.size md2asm_allocate_geometry_block_storage,.-md2asm_allocate_geometry_block_storage

// x0 blocked2024, x1 spherical-root64, x2 computational-root64,
// x3 spherical nonblocked1472, x4 computational nonblocked384.
.global md2asm_bind_geometry_blocks
.type md2asm_bind_geometry_blocks,%function
md2asm_bind_geometry_blocks:
 ldr x7,[x1]
 mov x6,x3
 mov x8,#23
 mov x9,#1472
 mov w1,#0
.Lview_field:
 ldr x11,[x6]
 ldr x13,[x6,#16]
 mov x10,#0
 mov x12,#0
 mov x16,x7
.Lview_block:
 ldp x14,x15,[x6]
 stp x14,x15,[x16]
 ldp x14,x15,[x6,#16]
 stp x14,x15,[x16,#16]
 ldp x14,x15,[x6,#32]
 stp x14,x15,[x16,#32]
 ldp x14,x15,[x6,#48]
 stp x14,x15,[x16,#48]
 add x14,x11,x12
 str x14,[x16]
 mov x17,#24
 cmp x10,#85
 mov x14,#8
 csel x17,x14,x17,eq
 str x17,[x16,#56]
 mov x14,#24
 madd x12,x13,x14,x12
 add x16,x16,x9
 add x10,x10,#1
 cmp x10,#86
 b.ne .Lview_block
 add x7,x7,#64
 add x6,x6,#64
 subs x8,x8,#1
 b.ne .Lview_field
 cbnz w1,.Lcopy_block_owners
 ldr x7,[x2]
 mov x6,x4
 mov x8,#6
 mov x9,#384
 mov w1,#1
 b .Lview_field
.Lcopy_block_owners:
 mov x6,x3
 mov x7,x0
 mov x8,#0
.Lcopy_owner:
 ldr x9,[x6]
 ldr x12,[x7]
 mov x13,#1024
 cmp x8,#21
 mov x14,#512
 csel x13,x14,x13,hs
.Lcopy_pair:
 ldp x10,x11,[x9],#16
 stp x10,x11,[x12],#16
 subs x13,x13,#1
 b.ne .Lcopy_pair
 add x6,x6,#64
 add x7,x7,#88
 add x8,x8,#1
 cmp x8,#23
 b.ne .Lcopy_owner
 ret
.size md2asm_bind_geometry_blocks,.-md2asm_bind_geometry_blocks
.section .rodata
.p2align 3
.Lallocation_rules:
 .word 0,0,8,16512,2,3
 .word 0,88,8,16512,2,3
 .word 0,176,8,16512,2,3
 .word 0,264,8,16512,2,3
 .word 0,352,8,16512,2,3
 .word 0,440,8,16512,2,3
 .word 0,528,8,16512,2,3
 .word 0,616,8,16512,2,3
 .word 0,968,8,16512,2,3
 .word 0,1056,8,16512,2,3
 .word 0,1144,8,16512,2,3
 .word 0,1232,8,16512,2,3
 .word 0,1320,8,16512,2,3
 .word 0,1408,8,16512,2,3
 .word 0,1496,8,16512,2,3
 .word 0,1584,8,16512,2,3
 .word 0,1672,8,16512,2,3
 .word 0,1760,8,16512,2,3
 .word 0,1848,4,8256,2,1
 .word 0,1936,4,8256,2,1
 .word 0,704,8,16512,2,3
 .word 0,792,8,16512,2,3
 .word 0,880,8,16512,2,3
 .word 1,0,1472,126592,1,5
 .word 2,0,384,33024,1,5
.section .note.GNU-stack,"",%progbits

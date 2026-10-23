/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */
// Operational SUGEM2 computation and storage composition for the reduced grid.
// Contract: skills/md2asm/references/openifs/setup/spherical_geometry_setup.md. x0 Geometry17096,
// x1 physical48, x2 two INT32 process indices; all mapped and aligned8.
// Return0 ready,1 allocation failure,2 unsupported input before mutation.
// Frame128, alignment16. No original constructor, vtable or callable target.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_distributed_spherical_geometry
.type md2asm_initialize_distributed_spherical_geometry,%function
md2asm_initialize_distributed_spherical_geometry:
 mrs x9,fpcr
 cbnz x9,.Lop_parent_spherical_setup_invalid
 cbz x0,.Lop_parent_spherical_setup_invalid
 cbz x1,.Lop_parent_spherical_setup_invalid
 cbz x2,.Lop_parent_spherical_setup_invalid
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lop_parent_spherical_setup_invalid
 mov x9,#17096
 adds x9,x0,x9
 b.cs .Lop_parent_spherical_setup_invalid
 adds x10,x1,#48
 b.cs .Lop_parent_spherical_setup_invalid
 cmp x0,x10
 b.hs .Lop_parent_physical_disjoint
 cmp x1,x9
 b.lo .Lop_parent_spherical_setup_invalid
.Lop_parent_physical_disjoint:
 adds x10,x2,#8
 b.cs .Lop_parent_spherical_setup_invalid
 cmp x0,x10
 b.hs .Lop_parent_process_disjoint
 cmp x2,x9
 b.lo .Lop_parent_spherical_setup_invalid
.Lop_parent_process_disjoint:
 ldp w9,w10,[x2]
 sub w9,w9,#1
 sub w10,w10,#1
 cmp w9,#1
 b.hi .Lop_parent_spherical_setup_invalid
 cmp w10,#1
 b.hi .Lop_parent_spherical_setup_invalid
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 str x2,[sp,#112]
 adrp x21,.Lop_parent_dimension_rules
 add x21,x21,:lo12:.Lop_parent_dimension_rules
 mov w22,#7
.Lop_parent_dimension_next:
 ldp w9,w10,[x21],#8
 ldr w11,[x19,w9,uxtw]
 cmp w11,w10
 b.ne .Lop_parent_invalid_frame
 subs w22,w22,#1
 b.ne .Lop_parent_dimension_next
 ldr x9,[x20]
 movz x10,#0x3ff0,lsl#48
 cmp x9,x10
 b.ne .Lop_parent_invalid_frame
 ldr x11,[x19,#7512]
 cmp x9,x11
 b.ne .Lop_parent_invalid_frame
 ldr x9,[x20,#8]
 movz x10,#0x4000,lsl#48
 cmp x9,x10
 b.ne .Lop_parent_invalid_frame
 ldr x11,[x19,#7544]
 cmp x9,x11
 b.ne .Lop_parent_invalid_frame
 ldr x9,[x20,#16]
 cbnz x9,.Lop_parent_invalid_frame
 ldr x11,[x19,#7552]
 cbnz x11,.Lop_parent_invalid_frame
 ldr x9,[x20,#24]
 adrp x10,.Lop_parent_spherical_radius
 ldr x10,[x10,:lo12:.Lop_parent_spherical_radius]
 cmp x9,x10
 b.ne .Lop_parent_invalid_frame
 ldr x9,[x20,#32]
 movz x10,#0x2d18
 movk x10,#0x5444,lsl#16
 movk x10,#0x21fb,lsl#32
 movk x10,#0x4009,lsl#48
 cmp x9,x10
 b.ne .Lop_parent_invalid_frame
 ldr x9,[x20,#40]
 movz x10,#0x3e10,lsl#48
 cmp x9,x10
 b.lo .Lop_parent_invalid_frame
 movz x10,#0x3f70,lsl#48
 cmp x9,x10
 b.hi .Lop_parent_invalid_frame
 // Check every fresh numerical owner and both fresh view arrays before mutation.
 adrp x21,.Lop_parent_owner_groups
 add x21,x21,:lo12:.Lop_parent_owner_groups
 mov w22,#5
.Lop_parent_empty_group:
 ldp w9,w10,[x21]
 ldr w11,[x21,#8]
 add x9,x19,w9,uxtw
.Lop_parent_empty_owner:
 ldr x12,[x9]
 cbnz x12,.Lop_parent_invalid_frame
 add x9,x9,w11,uxtw
 subs w10,w10,#1
 b.ne .Lop_parent_empty_owner
 add x21,x21,#12
 subs w22,w22,#1
 b.ne .Lop_parent_empty_group
 // Global Gaussian and PL owners stay global; local traversal is in the children.
 ldr x25,[x19,#7640]
 add x25,x25,#8
 str x25,[sp,#104]
 mov x9,#4296
 add x0,x19,x9
 mov x1,#1
 mov x2,#2560
 mov x3,#8
 mov x4,#3
 bl .Lop_parent_vector_segment
 cbz x0,.Lop_parent_invalid_frame
 mov x21,x0
 mov x9,#4232
 add x0,x19,x9
 mov x1,#1
 mov x2,#2560
 mov x3,#8
 mov x4,#3
 bl .Lop_parent_vector_segment
 cbz x0,.Lop_parent_invalid_frame
 mov x22,x0
 mov x9,#4552
 add x0,x19,x9
 mov x1,#1
 mov x2,#2560
 mov x3,#8
 mov x4,#3
 bl .Lop_parent_vector_segment
 cbz x0,.Lop_parent_invalid_frame
 mov x23,x0
 // Numerical children allocate and define all active owners.
 mov x9,#8536
 add x0,x19,x9
 mov x1,x20
 mov x2,x19
 mov x3,x21
 ldr x5,[sp,#112]
 mov x4,x22
 bl md2asm_initialize_distributed_spherical_point_geometry
 cbnz w0,.Lop_parent_setup_failed
 mov x9,#10008
 add x0,x19,x9
 mov x9,#8472
 add x1,x19,x9
 mov x9,#8024
 add x2,x19,x9
 bl md2asm_allocate_distributed_geometry_block_storage
 cbnz w0,.Lop_parent_setup_failed
 mov x9,#8088
 add x0,x19,x9
 mov x1,x20
 mov x2,x21
 mov x3,x23
 ldr x4,[sp,#104]
 mov x5,x19
 ldr x6,[sp,#112]
 bl md2asm_initialize_distributed_computational_geometry
 cbnz w0,.Lop_parent_setup_failed
 mov x9,#10008
 add x0,x19,x9
 mov x9,#8472
 add x1,x19,x9
 mov x9,#8024
 add x2,x19,x9
 mov x9,#8536
 add x3,x19,x9
 mov x9,#8088
 add x4,x19,x9
 bl md2asm_bind_distributed_geometry_blocks
 mov x9,#7488
 add x0,x19,x9
 mov x1,x20
 mov x9,#5172
 add x2,x19,x9
 bl md2asm_operational_spherical_resolution_scale
 mov w0,#0
 b .Lop_parent_setup_return
.Lop_parent_setup_failed:
 adrp x21,.Lop_parent_owner_groups
 add x21,x21,:lo12:.Lop_parent_owner_groups
 mov w22,#5
.Lop_parent_cleanup_group:
 ldp w9,w23,[x21]
 ldr w24,[x21,#8]
 add x25,x19,w9,uxtw
.Lop_parent_cleanup_owner:
 ldr x0,[x25]
 cbz x0,.Lop_parent_cleanup_done
 bl free
 str xzr,[x25]
.Lop_parent_cleanup_done:
 add x25,x25,w24,uxtw
 subs w23,w23,#1
 b.ne .Lop_parent_cleanup_owner
 add x21,x21,#12
 subs w22,w22,#1
 b.ne .Lop_parent_cleanup_group
 mov w0,#1
 b .Lop_parent_setup_return
.Lop_parent_invalid_frame:
 mov w0,#2
.Lop_parent_setup_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#128
 ret
.Lop_parent_spherical_setup_invalid:
 mov w0,#2
 ret
.size md2asm_initialize_distributed_spherical_geometry,.-md2asm_initialize_distributed_spherical_geometry

// Local guard for the bounded original rank-one maps and latitude owners.
// x0 descriptor,x1 first,x2 last,x3 element bytes,x4 intrinsic type; x0 result/0.
.Lop_parent_vector_segment:
 ldr x5,[x0]
 cbz x5,.Lop_parent_bad_segment
 sub x6,x3,#1
 tst x5,x6
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#16]
 cmp x6,x3
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#32]
 cmp x6,x3
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#24]
 lsl x7,x4,#40
 mov x8,#1
 orr x7,x7,x8,lsl#32
 cmp x6,x7
 b.ne .Lop_parent_bad_segment
 ldp x6,x7,[x0,#40]
 cmp x6,#1
 b.ne .Lop_parent_bad_segment
 cmn x7,#1
 b.lt .Lop_parent_bad_segment
 cmp x7,#1
 b.gt .Lop_parent_bad_segment
 ldr x8,[x0,#56]
 cmp x8,#2562
 b.gt .Lop_parent_bad_segment
 cmp x7,x1
 b.gt .Lop_parent_bad_segment
 cmp x8,x2
 b.lt .Lop_parent_bad_segment
 ldr x6,[x0,#8]
 adds x6,x6,x7
 b.ne .Lop_parent_bad_segment
 sub x1,x1,x7
 madd x0,x1,x3,x5
 subs x2,x2,x7
 add x2,x2,#1
 mul x2,x2,x3
 adds x2,x5,x2
 b.cs .Lop_parent_bad_segment
 ret
.Lop_parent_bad_segment:
 mov x0,#0
 ret

// The consumed column is1; bounded original integer row owners are contiguous.
.Lop_parent_matrix_rows:
 ldr x5,[x0]
 cbz x5,.Lop_parent_bad_segment
 tst x5,#3
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#16]
 cmp x6,#4
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#32]
 cmp x6,#4
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#24]
 movz x7,#0x0102,lsl#32
 cmp x6,x7
 b.ne .Lop_parent_bad_segment
 ldp x6,x7,[x0,#40]
 cmp x6,#1
 b.ne .Lop_parent_bad_segment
 cmn x7,#1
 b.lt .Lop_parent_bad_segment
 cmp x7,#1
 b.gt .Lop_parent_bad_segment
 ldr x8,[x0,#56]
 cmp x8,#2562
 b.gt .Lop_parent_bad_segment
 cmp x7,x1
 b.gt .Lop_parent_bad_segment
 cmp x8,x2
 b.lt .Lop_parent_bad_segment
 sub x8,x8,x7
 add x8,x8,#1
 ldp x9,x10,[x0,#64]
 cmp x9,x8
 b.ne .Lop_parent_bad_segment
 cmp x10,#1
 b.ne .Lop_parent_bad_segment
 ldr x11,[x0,#80]
 cmp x11,#1
 b.ne .Lop_parent_bad_segment
 ldr x6,[x0,#8]
 add x6,x6,x7
 adds x6,x6,x8
 b.ne .Lop_parent_bad_segment
 sub x1,x1,x7
 add x0,x5,x1,lsl#2
 sub x2,x2,x7
 add x2,x2,#1
 adds x2,x5,x2,lsl#2
 b.cs .Lop_parent_bad_segment
 ret
.section .rodata
.p2align 3
.Lop_parent_dimension_rules:
 .word 4872,2560,4936,5136,5144,17
 .word 5160,97055,5172,1279,7376,1649920,7520,1
.Lop_parent_owner_groups:
 .word 8536,23,64
 .word 8088,6,64
 .word 10008,23,88
 .word 8472,1,64
 .word 8024,1,64
.p2align 3
.Lop_parent_spherical_radius:
 .double 6371229.0
.section .note.GNU-stack,"",%progbits

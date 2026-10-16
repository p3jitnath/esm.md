/* Contract: skills/md2asm/references/openifs/radiation/cloud_overlap_setup.md.
 * Original SUALLO owner and complete SUOVLP profile, in separate source stages. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_cloud_overlap_storage
.type md2asm_create_cloud_overlap_storage,%function
md2asm_create_cloud_overlap_storage:
 cbz x0,.Loc_bad
 tst x0,#7
 b.ne .Loc_bad
 cmp x1,#64
 b.lo .Loc_bad
 adds x9,x0,#64
 b.cs .Loc_bad
 sub w9,w2,#1
 cmp w9,#255
 b.hi .Loc_bad
 ldr x9,[x0]
 cbnz x9,.Loc_bad
 sub sp,sp,#144
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov w22,w2
 ldp x9,x10,[x19]
 stp x9,x10,[sp,#64]
 ldp x9,x10,[x19,#16]
 stp x9,x10,[sp,#80]
 ldp x9,x10,[x19,#32]
 stp x9,x10,[sp,#96]
 ldp x9,x10,[x19,#48]
 stp x9,x10,[sp,#112]
 str w22,[sp,#128]
 str wzr,[sp,#132]
 str xzr,[sp,#136]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 add x0,sp,#64
 mov w1,#1
 add x2,sp,#128
 mov w3,#1
 mov w4,#0
 bl md2asm_allocate_radiation_flux_array
 cbnz w0,.Loc_create_return
 ldp x9,x10,[sp,#64]
 stp x9,x10,[x19]
 ldp x9,x10,[sp,#80]
 stp x9,x10,[x19,#16]
 ldp x9,x10,[sp,#96]
 stp x9,x10,[x19,#32]
 ldp x9,x10,[sp,#112]
 stp x9,x10,[x19,#48]
 str w21,[x20]
.Loc_create_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.size md2asm_create_cloud_overlap_storage,.-md2asm_create_cloud_overlap_storage
.p2align 4
.global md2asm_release_cloud_overlap_storage
.type md2asm_release_cloud_overlap_storage,%function
md2asm_release_cloud_overlap_storage:
 cbz x0,.Loc_bad
 tst x0,#7
 b.ne .Loc_bad
 cmp x1,#64
 b.lo .Loc_bad
 adds x9,x0,#64
 b.cs .Loc_bad
 stp x29,x30,[sp,#-64]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x29,sp
 mov x19,x0
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 ldr x0,[x19]
 bl free
 str xzr,[x19]
 str w21,[x20]
 mov w0,#0
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_cloud_overlap_storage,.-md2asm_release_cloud_overlap_storage
.p2align 4
.global md2asm_initialize_cloud_overlap_profile
.type md2asm_initialize_cloud_overlap_profile,%function
md2asm_initialize_cloud_overlap_profile:
 cbz x0,.Loc_bad
 cbz x1,.Loc_bad
 cbz x2,.Loc_bad
 orr x4,x0,x1
 orr x4,x4,x2
 tst x4,#7
 b.ne .Loc_bad
 sub w4,w3,#1
 cmp w4,#255
 b.hi .Loc_bad
 uxtw x3,w3
 mrs x4,fpcr
 cbnz x4,.Loc_bad
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x0,x1,[sp,#16]
 stp x2,x3,[sp,#32]
 adds x4,x0,#384
 b.cs .Loc_profile_bad
 stp x0,x4,[sp,#48]
 adds x4,x1,#64
 b.cs .Loc_profile_bad
 stp x1,x4,[sp,#64]
 adds x4,x2,#2040
 b.cs .Loc_profile_bad
 stp x2,x4,[sp,#80]
 add x4,x0,#320
 mov x5,x1
 mov x12,#0
.Loc_descriptor:
 cmp x12,#0
 csel x14,x4,x5,eq
 ldr x15,[x14]
 cbz x15,.Loc_profile_bad
 tst x15,#7
 b.ne .Loc_profile_bad
 ldr x15,[x14,#8]
 mov x16,#-1
 cmp x15,x16
 b.ne .Loc_profile_bad
 ldr x15,[x14,#16]
 cmp x15,#8
 b.ne .Loc_profile_bad
 ldr x15,[x14,#24]
 movz x16,#0x301,lsl #32
 cmp x15,x16
 b.ne .Loc_profile_bad
 ldr x15,[x14,#32]
 cmp x15,#8
 b.ne .Loc_profile_bad
 ldr x15,[x14,#40]
 cmp x15,#1
 b.ne .Loc_profile_bad
 ldr x15,[x14,#48]
 cmp x15,#1
 b.ne .Loc_profile_bad
 ldr x15,[x14,#56]
 cmp x15,x3
 b.ne .Loc_profile_bad
 add x12,x12,#1
 cmp x12,#2
 b.lo .Loc_descriptor
 ldr x7,[x4]
 ldr x8,[x5]
 lsl x9,x3,#3
 adds x10,x7,x9
 b.cs .Loc_profile_bad
 stp x7,x10,[sp,#96]
 adds x10,x8,x9
 b.cs .Loc_profile_bad
 stp x8,x10,[sp,#112]
 add x4,sp,#48
 mov x5,#0
.Loc_span_outer:
 add x6,x4,x5,lsl #4
 ldp x7,x8,[x6]
 add x9,x5,#1
.Loc_span_inner:
 cmp x9,#5
 b.hs .Loc_span_next
 add x6,x4,x9,lsl #4
 ldp x10,x11,[x6]
 cmp x7,x11
 b.hs .Loc_span_apart
 cmp x10,x8
 b.lo .Loc_profile_bad
.Loc_span_apart:
 add x9,x9,#1
 b .Loc_span_inner
.Loc_span_next:
 add x5,x5,#1
 cmp x5,#4
 b.lo .Loc_span_outer
 movz x16,#0x7ff0,lsl #48
 ldr x7,[sp,#32]
 add x7,x7,#536
 mov x8,#0
.Loc_coefficient_finite:
 ldr x15,[x7,x8,lsl #3]
 and x15,x15,#0x7fffffffffffffff
 cmp x15,x16
 b.hs .Loc_profile_bad
 add x8,x8,#1
 cmp x8,#2
 b.lo .Loc_coefficient_finite
 ldr x7,[sp,#96]
 ldr x3,[sp,#40]
 mov x8,#0
.Loc_height_finite:
 ldr x15,[x7,x8,lsl #3]
 and x15,x15,#0x7fffffffffffffff
 cmp x15,x16
 b.hs .Loc_profile_bad
 add x8,x8,#1
 cmp x8,x3
 b.lo .Loc_height_finite
 ldr x0,[sp,#112]
 mov x1,x7
 ldr x2,[sp,#32]
 add x2,x2,#536
 bl md2asm_cloud_overlap_profile_values
 mov w0,#0
 b .Loc_profile_return
.Loc_profile_bad:
 mov w0,#2
.Loc_profile_return:
 ldp x29,x30,[sp],#128
 ret
.size md2asm_initialize_cloud_overlap_profile,.-md2asm_initialize_cloud_overlap_profile
.p2align 4
.global md2asm_cloud_overlap_profile_values
.hidden md2asm_cloud_overlap_profile_values
.type md2asm_cloud_overlap_profile_values,%function
/* Internal checked leaf: output, heights, two coefficients, positive level count. */
md2asm_cloud_overlap_profile_values:
 ldp d0,d1,[x2]
.Loc_value:
 ldr d2,[x1],#8
 fmul d2,d0,d2
 fadd d2,d2,d1
 str d2,[x0],#8
 subs x3,x3,#1
 b.ne .Loc_value
 ret
.size md2asm_cloud_overlap_profile_values,.-md2asm_cloud_overlap_profile_values
.Loc_bad:
 mov w0,#2
 ret
.section .note.GNU-stack,"",%progbits

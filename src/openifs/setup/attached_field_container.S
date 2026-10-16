/* Selected source-owned FIELD_CONTAINER_GP creation and complete owned release.
 * Contract: skills/md2asm/references/openifs/setup/attached_field_container.md
 * Create: x0 record1752,x1 capacity,x2 five address/capacity pairs80,
 * x3 levels44,x4 controls32. Return0/1/2. Release: x0 record, return0/2/3.
 * Complete mapped/disjoint/nonwrapping ranges and pointer targets are required.
 */
.text
.p2align 4
.macro A1 off,count,elem,typ
 add x0,x19,#\off
 mov x1,#\count
 mov x2,#\elem
 mov x3,#\typ
 bl .Lcontainer_allocate1
 cbnz w0,.Lcontainer_fail
.endm
.global md2asm_create_attached_field_container
.type md2asm_create_attached_field_container,%function
md2asm_create_attached_field_container:
 cbz x0,.Lcontainer_reject
 cbz x2,.Lcontainer_reject
 cbz x3,.Lcontainer_reject
 cbz x4,.Lcontainer_reject
 cmp x1,#1752
 b.lo .Lcontainer_reject
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lcontainer_reject
 orr x9,x3,x4
 tst x9,#3
 b.ne .Lcontainer_reject
 ldr w9,[x0]
 cbnz w9,.Lcontainer_reject
 adrp x9,.Lcontainer_owners
 add x9,x9,:lo12:.Lcontainer_owners
 mov w10,#21
.Lcontainer_fresh:
 ldr w11,[x9],#4
 ldr x12,[x0,x11]
 cbnz x12,.Lcontainer_reject
 subs w10,w10,#1
 b.ne .Lcontainer_fresh
 mov x9,#0
 adrp x10,.Lcontainer_minimums
 add x10,x10,:lo12:.Lcontainer_minimums
.Lcontainer_pair_guard:
 add x14,x2,x9
 ldp x11,x12,[x14]
 cbz x11,.Lcontainer_reject
 tst x11,#7
 b.ne .Lcontainer_reject
 ldr w13,[x10],#4
 cmp x12,x13
 b.lo .Lcontainer_reject
 add x9,x9,#16
 cmp x9,#80
 b.lo .Lcontainer_pair_guard
 ldr w9,[x4]
 sub w9,w9,#1
 cmp w9,#4095
 b.hi .Lcontainer_reject
 ldr w9,[x4,#4]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Lcontainer_reject
 ldr w9,[x4,#8]
 sub w9,w9,#1
 cmp w9,#2
 b.hi .Lcontainer_reject
 ldr w9,[x4,#12]
 cmp w9,#1
 b.hi .Lcontainer_reject
 ldp w9,w10,[x4,#16]
 mov w11,#4200
 cmp w9,w11
 b.hi .Lcontainer_reject
 cmp w10,w11
 b.hi .Lcontainer_reject
 ldr w9,[x4,#28]
 cbnz w9,.Lcontainer_reject
 mov w9,#0
.Lcontainer_levels_guard:
 ldr w10,[x3,x9]
 cmp w10,#256
 b.hi .Lcontainer_reject
 add w9,w9,#4
 cmp w9,#44
 b.lo .Lcontainer_levels_guard
 ldr w9,[x3]
 cbz w9,.Lcontainer_reject
 ldr x9,[x2,#32]
 ldr w10,[x9,#100]
 ldr w11,[x9,#200]
 ldr w12,[x9,#108]
 orr w10,w10,w11
 orr w10,w10,w12
 cbnz w10,.Lcontainer_reject
 ldr x10,[x2,#16]
 ldr x10,[x10,#1088]
 cmp x10,x9
 b.ne .Lcontainer_reject
 sub sp,sp,#192
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#120]
 mov x19,x0
 mov x24,x2
 mov x22,x3
 mov x23,x4
 mov x25,#0
 mov x26,#0
 mov x27,#0
 bl __errno_location
 str x0,[sp,#96]
 ldr w9,[x0]
 str w9,[sp,#104]
 mov w9,#1
 str w9,[x19]
 mov w9,#3
 str w9,[x19,#4]
 ldr w9,[x23,#8]
 str w9,[x19,#8]
 mov w9,#4200
 str w9,[x19,#12]
 mov w9,#11
 str w9,[x19,#216]
 mov w9,#2
 str w9,[x19,#220]
 ldr w9,[x23]
 str w9,[x19,#928]
 A1 224,4200,184,5
 ldr x0,[x19,#224]
 movz x1,#0xcac0
 movk x1,#0xb,lsl #16
 ldr x2,[x24,#64]
 add x3,sp,#112
 mov x4,#0
 bl md2asm_initialize_main_field_metadata
 cbnz w0,.Lcontainer_fail
 A1 936,11,4,1
 ldr x9,[x19,#936]
 mov w10,#0
.Lcontainer_copy_levels:
 ldr w11,[x22,x10]
 str w11,[x9,x10]
 add w10,w10,#4
 cmp w10,#44
 b.lo .Lcontainer_copy_levels
 A1 1064,11,3,6
 ldr x9,[x19,#1064]
 adrp x10,.Lcontainer_level_names
 add x10,x10,:lo12:.Lcontainer_level_names
 mov w11,#33
.Lcontainer_copy_names:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs w11,w11,#1
 b.ne .Lcontainer_copy_names
 A1 88,4200,8,5
 ldr x9,[x19,#88]
 mov w10,#4200
.Lcontainer_flags_zero:
 str xzr,[x9],#8
 subs w10,w10,#1
 b.ne .Lcontainer_flags_zero
 A1 1000,2,4,1
 ldr x9,[x19,#1000]
 mov x10,#0
 ldr w11,[x23,#8]
 cmp w11,#2
 b.ne .Lcontainer_no_dim3
 ldr x10,[x23,#16]
.Lcontainer_no_dim3:
 str x10,[x9]
 ldr w9,[x23]
 ldr w10,[x23,#4]
 sub w11,w9,#1
 udiv w11,w11,w10
 add w11,w11,#1
 str w11,[x19,#1676]
 add x0,x19,#1680
 mov w1,w11
 mov x2,#4
 mov x3,#1
 bl .Lcontainer_allocate1
 cbnz w0,.Lcontainer_fail
 ldr x9,[x19,#1680]
 ldr w10,[x23,#4]
 ldr w11,[x19,#1676]
 mov w12,w11
.Lcontainer_block_points:
 str w10,[x9],#4
 subs w12,w12,#1
 b.ne .Lcontainer_block_points
 ldr w12,[x23]
 udiv w13,w12,w11
 msub w13,w13,w11,w12
 cbz w13,.Lcontainer_full_last
 sub w11,w11,#1
 msub w12,w11,w10,w12
 cmp w12,w10
 csel w12,w12,w10,lt
 str w12,[x9,#-4]
.Lcontainer_full_last:
 A1 1224,4200,40,5
 ldr x9,[x19,#1224]
 mov w10,#4200
 mov x11,#-1
.Lcontainer_index_defaults:
 str xzr,[x9]
 str x11,[x9,#8]
 str wzr,[x9,#16]
 str xzr,[x9,#32]
 add x9,x9,#40
 subs w10,w10,#1
 b.ne .Lcontainer_index_defaults
 ldr x9,[x24]
 str x9,[x19,#1128]
 ldr x9,[x24,#16]
 str x9,[x19,#1136]
 ldr x9,[x24,#48]
 str x9,[x19,#1144]
 str wzr,[x19,#1672]
 ldr w9,[x23,#12]
 str w9,[x19,#1744]
 mov w9,#1
 str w9,[x19,#1376]
 A1 416,4200,4,1
 A1 864,4200,4,1
 A1 288,4200,4,1
 A1 352,4200,4,1
 A1 480,4200,4,1
 A1 544,4200,4,1
 A1 608,4200,4,1
 A1 672,4200,4,1
 A1 736,4200,4,1
 A1 800,4200,4,1
 movz x0,#0x9040
 movk x0,#2,lsl #16
 bl malloc
 cbz x0,.Lcontainer_fail
 mov x25,x0
 movz x1,#0x9040
 movk x1,#2,lsl #16
 ldr x2,[x24]
 ldr x3,[x24,#32]
 ldr x4,[x24,#48]
 add x5,x23,#24
 bl md2asm_initialize_live_field_maps
 cbnz w0,.Lcontainer_fail
 mov x9,x25
 add x10,x19,#288
 mov w11,#10
.Lcontainer_copy_map:
 ldr x12,[x10],#64
 mov w13,#2100
.Lcontainer_copy_map_words:
 ldr x14,[x9],#8
 str x14,[x12],#8
 subs w13,w13,#1
 b.ne .Lcontainer_copy_map_words
 subs w11,w11,#1
 b.ne .Lcontainer_copy_map
 mov x0,#16800
 bl malloc
 cbz x0,.Lcontainer_fail
 mov x26,x0
 mov x0,#16800
 bl malloc
 cbz x0,.Lcontainer_fail
 mov x27,x0
 mov x9,x26
 mov x10,x27
 mov w11,#2100
.Lcontainer_temporary_zero:
 str xzr,[x9],#8
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Lcontainer_temporary_zero
 ldr w9,[x23,#8]
 sub w9,w9,#1
 adrp x10,.Lcontainer_attachment_offsets
 add x10,x10,:lo12:.Lcontainer_attachment_offsets
 ldr w9,[x10,x9,lsl #2]
 ldr x28,[x19,x9]
 mov x9,x28
 mov w10,#4200
 mov w11,#0
.Lcontainer_count_fields:
 ldr w12,[x9],#4
 cmp w12,#0
 cinc w11,w11,ne
 subs w10,w10,#1
 b.ne .Lcontainer_count_fields
 str w11,[x19,#16]
 add x0,x19,#24
 mov w1,w11
 mov x2,#4
 mov x3,#1
 bl .Lcontainer_allocate1
 cbnz w0,.Lcontainer_fail
 mov x0,x28
 mov x1,#4200
 mov x2,x26
 mov x3,x27
 ldr x4,[x19,#24]
 add x5,x19,#16
 bl md2asm_initialize_field_membership
 cbnz w0,.Lcontainer_fail
 ldr x9,[x19,#88]
 ldr x10,[x19,#1224]
 mov w11,#0
 ldr w15,[x23,#12]
.Lcontainer_copy_membership:
 ldr w12,[x26,x11,lsl #2]
 ldr w13,[x27,x11,lsl #2]
 stp w12,w13,[x9],#8
 cmp w15,#0
 csel w14,w12,wzr,ne
 str w14,[x10,#16]
 add x10,x10,#40
 add w11,w11,#1
 mov w12,#4200
 cmp w11,w12
 b.lo .Lcontainer_copy_membership
 ldr x9,[x19,#88]
 ldr x10,[x19,#224]
 add x10,x10,#144
 mov w11,#4200
 mov w28,#0
.Lcontainer_count_rank2:
 ldr w12,[x9],#8
 ldr w13,[x10]
 add x10,x10,#184
 cmp w13,#2
 ccmp w12,#0,#4,eq
 cinc w28,w28,ne
 subs w11,w11,#1
 b.ne .Lcontainer_count_rank2
 add x0,x19,#1384
 ldr w9,[x19,#1676]
 sub w9,w9,#1
 ldr x10,[x19,#1680]
 ldr w1,[x10,x9,lsl #2]
 ldr w2,[x22]
 mov w3,w28
 bl .Lcontainer_allocate3
 cbnz w0,.Lcontainer_fail
 A1 1496,4200,4,1
 ldr x9,[x19,#88]
 ldr x10,[x19,#224]
 add x10,x10,#144
 ldr x11,[x19,#1496]
 mov w12,#4200
 mov w13,#1
.Lcontainer_rank2_index:
 ldr w14,[x9],#8
 ldr w15,[x10]
 add x10,x10,#184
 cmp w15,#2
 ccmp w14,#0,#4,eq
 b.eq .Lcontainer_rank2_off
 str w13,[x11],#4
 add w13,w13,#1
 b .Lcontainer_rank2_next
.Lcontainer_rank2_off:
 mov w14,#-1
 str w14,[x11],#4
.Lcontainer_rank2_next:
 subs w12,w12,#1
 b.ne .Lcontainer_rank2_index
 add x0,x19,#1560
 ldr w1,[x23,#4]
 ldr w2,[x22]
 mov x3,#1
 bl .Lcontainer_allocate3
 cbnz w0,.Lcontainer_fail
 ldr x9,[x19,#1560]
 ldr w10,[x23,#4]
 ldr w11,[x22]
 mul w10,w10,w11
 movz x12,#0xffff
 movk x12,#0xffff,lsl #16
 movk x12,#0xffff,lsl #32
 movk x12,#0xffef,lsl #48
.Lcontainer_sentinel:
 str x12,[x9],#8
 subs w10,w10,#1
 b.ne .Lcontainer_sentinel
 mov w28,#0
 b .Lcontainer_temporaries
.Lcontainer_fail:
 mov w28,#1
 mov x0,x19
 bl .Lcontainer_free_owners
.Lcontainer_temporaries:
 mov x0,x25
 bl free
 mov x0,x26
 bl free
 mov x0,x27
 bl free
 ldr x9,[sp,#96]
 ldr w10,[sp,#104]
 str w10,[x9]
 mov w0,w28
 ldr x18,[sp,#120]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.Lcontainer_reject:
 mov w0,#2
 ret
.size md2asm_create_attached_field_container,.-md2asm_create_attached_field_container
/* GNU rank-one owned descriptor; element and logical extents are explicit. */
.Lcontainer_allocate1:
 stp x19,x30,[sp,#-32]!
 mov x19,x0
 mov x9,#-1
 str x9,[x0,#8]
 str x2,[x0,#16]
 lsl x3,x3,#40
 mov x9,#1
 orr x3,x3,x9,lsl #32
 str x3,[x0,#24]
 str x2,[x0,#32]
 str x9,[x0,#40]
 str x9,[x0,#48]
 str x1,[x0,#56]
 mul x0,x1,x2
 cmp x0,#0
 csinc x0,x0,xzr,ne
 bl malloc
 str x0,[x19]
 cmp x0,#0
 cset w0,eq
 ldp x19,x30,[sp],#32
 ret
.Lcontainer_allocate3:
 stp x19,x30,[sp,#-32]!
 mov x19,x0
 mul x9,x1,x2
 add x10,x9,x1
 add x10,x10,#1
 neg x10,x10
 str x10,[x0,#8]
 mov x10,#8
 str x10,[x0,#16]
 movz x10,#0x303,lsl #32
 str x10,[x0,#24]
 mov x10,#8
 str x10,[x0,#32]
 mov x10,#1
 str x10,[x0,#40]
 str x10,[x0,#48]
 str x1,[x0,#56]
 str x1,[x0,#64]
 str x10,[x0,#72]
 str x2,[x0,#80]
 str x9,[x0,#88]
 str x10,[x0,#96]
 str x3,[x0,#104]
 mul x0,x9,x3
 lsl x0,x0,#3
 cmp x0,#0
 csinc x0,x0,xzr,ne
 bl malloc
 str x0,[x19]
 cmp x0,#0
 cset w0,eq
 ldp x19,x30,[sp],#32
 ret
/* Free source destroy owners followed by the explicitly owned leak cleanup. */
.Lcontainer_free_owners:
 stp x19,x20,[sp,#-48]!
 stp x21,x30,[sp,#16]
 mov x19,x0
 adrp x20,.Lcontainer_owners
 add x20,x20,:lo12:.Lcontainer_owners
 mov w21,#21
.Lcontainer_free_next:
 ldr w9,[x20],#4
 str w9,[sp,#32]
 ldr x0,[x19,x9]
 bl free
 ldr w9,[sp,#32]
 str xzr,[x19,x9]
 subs w21,w21,#1
 b.ne .Lcontainer_free_next
 str wzr,[x19]
 ldp x21,x30,[sp,#16]
 ldp x19,x20,[sp],#48
 ret
.global md2asm_release_attached_field_container
.type md2asm_release_attached_field_container,%function
md2asm_release_attached_field_container:
 cbz x0,.Lcontainer_reject
 tst x0,#7
 b.ne .Lcontainer_reject
 ldr w9,[x0]
 cbz w9,.Lcontainer_release_empty
 cmp w9,#1
 b.ne .Lcontainer_reject
 ldr x9,[x0,#1560]
 cbz x9,.Lcontainer_reject
 ldr x10,[x0,#1616]
 ldr x11,[x0,#1640]
 mul x10,x10,x11
 ldr x11,[x0,#1664]
 mul x10,x10,x11
 movz x12,#0xffff
 movk x12,#0xffff,lsl #16
 movk x12,#0xffff,lsl #32
 movk x12,#0xffef,lsl #48
.Lcontainer_release_guard:
 cbz x10,.Lcontainer_release_begin
 ldr x11,[x9],#8
 cmp x11,x12
 b.ne .Lcontainer_modified
 sub x10,x10,#1
 b .Lcontainer_release_guard
.Lcontainer_release_begin:
 stp x19,x20,[sp,#-48]!
 stp x21,x30,[sp,#16]
 str x18,[sp,#32]
 mov x19,x0
 bl __errno_location
 mov x20,x0
 ldr w21,[x0]
 mov x0,x19
 bl .Lcontainer_free_owners
 str w21,[x20]
 ldr x18,[sp,#32]
 ldp x21,x30,[sp,#16]
 ldp x19,x20,[sp],#48
.Lcontainer_release_empty:
 mov w0,#0
 ret
.Lcontainer_modified:
 mov w0,#3
 ret
.size md2asm_release_attached_field_container,.-md2asm_release_attached_field_container
.section .rodata
.p2align 3
.Lcontainer_minimums:.word 1560,1096,1359136,18224,32
.Lcontainer_attachment_offsets:.word 288,416,352
.Lcontainer_level_names:.ascii "ML ML SFCSFCSFCSFCSFCSFCSFCSFCSFC"
.p2align 2
.Lcontainer_owners:.word 1384,1496,1560,1224,24,936,224,1680,88,1064,1000,416,864,288,352,480,544,608,672,736,800
.section .note.GNU-stack,"",%progbits

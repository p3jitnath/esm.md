// Contract: skills/md2asm/references/openifs/output/fullpos_field_metadata_and_file_names.md.
/* SUVFPOSL creates the exact field and level records consumed by GRIB output. */
.arch armv8.2-a
.text
.macro IA reg,n
 ldr \reg,[sp,#(192+8*\n)]
.endm
.macro IW dst,record,offset,index
 ldr x16,[\record,#\offset]
 str \dst,[x16,\index,lsl#2]
.endm
.p2align 4
.global md2asm_create_runtime_output_field_metadata
.type md2asm_create_runtime_output_field_metadata,%function
md2asm_create_runtime_output_field_metadata:
 mov x17,sp
 sub sp,sp,#768
 stp x29,x30,[sp,#64]
 stp x19,x20,[sp,#80]
 stp x21,x22,[sp,#96]
 stp x23,x24,[sp,#112]
 stp x25,x26,[sp,#128]
 stp x27,x28,[sp,#144]
 str x18,[sp,#160]
 str x0,[sp,#192]
 str x1,[sp,#200]
 str x2,[sp,#208]
 str x3,[sp,#216]
 str x4,[sp,#224]
 str x5,[sp,#232]
 str x6,[sp,#240]
 str x7,[sp,#248]
 ldr x9,[x17]
 str x9,[sp,#256]
 ldr x9,[x17,#8]
 str x9,[sp,#264]
 ldr x9,[x17,#16]
 str x9,[sp,#272]
 ldr x9,[x17,#24]
 cmp x9,#16
 b.ne .Li_bad
 ldr x9,[x17,#32]
 cmp x9,#1
 b.ne .Li_bad
 ldr x28,[x17,#40]
 cbz x28,.Li_bad
 ldr x9,[x28]
 cbz x9,.Li_bad
 ldr w9,[x9]
 cbnz w9,.Li_bad
 mrs x9,fpcr
 cbnz x9,.Li_bad
 mov x21,x0
 mov x19,x1
 mov x20,x2
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x28
 tst x9,#7
 b.ne .Li_bad
 cbz x0,.Li_bad
 cbz x1,.Li_bad
 cbz x2,.Li_bad
 ldr w22,[x6]
 sub w9,w22,#1
 cmp w9,#7
 b.hi .Li_bad
 ldr w9,[x7]
 cmp w9,#512
 b.hi .Li_bad
 str w9,[sp,#344]
 IA x9,9
 ldr w9,[x9]
 cmp w9,#2
 b.hi .Li_bad
 cmp w9,#1
 cset w28,ne
 str w28,[sp,#348]
 IA x9,10
 ldrb w9,[x9]
 cmp w9,#83
 b.eq .Li_coordinate
 cmp w9,#80
 b.eq .Li_coordinate
 cmp w9,#66
 b.eq .Li_coordinate
 cmp w9,#84
 b.eq .Li_coordinate
 cmp w9,#86
 b.ne .Li_bad
.Li_coordinate:
 ldr w9,[x21]
 cmp w9,#686
 b.hi .Li_bad
 str w9,[sp,#352]
 ldr w9,[x21,#1124]
 mov w10,#0x5c00
 movk w10,#5,lsl#16
 cmp w9,w10
 b.hi .Li_bad
 ldr w24,[x21,#1100]
 cmp w24,w9
 b.hi .Li_bad
 sub w23,w9,w24
 ldr w10,[x21,#1116]
 cmp w10,w9
 b.hi .Li_bad
 cbnz w28,.Li_counts
 mov w24,w9
 mov w23,#0
 mov w10,#0
.Li_counts:
 str w10,[sp,#356]
 /* All selected descriptor bases must be unassociated before publication. */
 adrp x25,.Li_allocations
 add x25,x25,:lo12:.Li_allocations
 mov x26,#0
 mov x27,#0
.Li_owner_preflight:
 ldp w9,w10,[x25]
 ldp w11,w12,[x25,#8]
 add x25,x25,#16
 cmp w9,#0
 csel x13,x19,x20,eq
 ldr x14,[x13,x10]
 cbnz x14,.Li_bad
 cmp w9,#0
 csel x13,x23,x24,eq
 and w12,w12,#255
 cmp w12,#2
 mul x14,x13,x22
 csel x13,x14,x13,eq
 mul x13,x13,x11
 cmp x13,#1
 mov x14,#1
 csel x13,x13,x14,hs
 adds x27,x27,x13
 b.cs .Li_bad
 add x26,x26,#1
 cmp x26,#16
 b.lo .Li_owner_preflight
 ldr x9,[x17,#40]
 ldr x9,[x9,#8]
 mov x10,#0x8000000
 cmp x9,x10
 b.hi .Li_bad
 cmp x27,x9
 b.hi .Li_bad
 /* The three public name/code inputs use complete lower-one source arrays. */
 IA x0,3
 mov x1,#4
 mov x2,#1
 bl .Li_input_descriptor
 cbnz w0,.Li_bad
 IA x0,4
 mov x1,#4
 mov x2,#2
 bl .Li_input_descriptor
 cbnz w0,.Li_bad
 IA x0,5
 mov x1,#16
 mov x2,#6
 bl .Li_input_descriptor
 cbnz w0,.Li_bad
 /* Count source rows before allocating, reading only active request metadata. */
 mov x25,#0
 mov x26,#0
 mov x27,#0
.Li_count_field:
 ldr w9,[sp,#352]
 cmp x25,x9
 b.hs .Li_count_done
 ldr x9,[x21,#8]
 ldr w10,[x9,x25,lsl#2]
 sub w10,w10,#1
 cmp w10,#685
 b.hi .Li_bad
 ldr x9,[x21,#328]
 ldrsw x11,[x9,x10,lsl#2]
 cmp x11,#1
 b.lt .Li_bad
 ldr x12,[x21,#448]
 cmp x11,x12
 b.gt .Li_bad
 cbz w28,.Li_count_grid
 ldr x9,[x21,#136]
 ldr w9,[x9,x10,lsl#2]
 cmp w9,#1
 b.lt .Li_count_grid
 add x26,x26,x11
 b .Li_count_next
.Li_count_grid:
 add x27,x27,x11
.Li_count_next:
 add x25,x25,#1
 b .Li_count_field
.Li_count_done:
 cmp x26,x23
 b.ne .Li_bad
 cmp x27,x24
 b.ne .Li_bad
 str w23,[x19]
 ldr w9,[sp,#356]
 str w9,[x19,#608]
 str w24,[x20]
 /* Exact source allocation order from SUVFPOSL. */
 adrp x25,.Li_allocations
 add x25,x25,:lo12:.Li_allocations
 mov x26,#0
.Li_allocate_next:
 ldp w9,w10,[x25]
 ldp w11,w12,[x25,#8]
 add x25,x25,#16
 cmp w9,#0
 csel x0,x19,x20,eq
 add x0,x0,x10
 csel x1,x23,x24,eq
 mov x2,x11
 mov x3,x12
 mov x4,x22
 bl .Li_allocate
 ldr x18,[sp,#160]
 cbnz w0,.Li_allocation_bad
 add x26,x26,#1
 cmp x26,#16
 b.lo .Li_allocate_next
 mov x25,#0
 mov x26,#0
 mov x27,#0
.Li_field:
 ldr w9,[sp,#352]
 cmp x25,x9
 b.hs .Li_complete
 ldr x9,[x21,#8]
 ldr w10,[x9,x25,lsl#2]
 str w10,[sp,#360]
 sub w10,w10,#1
 str x10,[sp,#368]
 ldr x9,[x21,#328]
 ldr w11,[x9,x10,lsl#2]
 str w11,[sp,#364]
 IA x9,4
 ldr x9,[x9]
 ldr w11,[x9,x10,lsl#2]
 str w11,[sp,#376]
 IA x9,3
 ldr x9,[x9]
 ldr w11,[x9,x10,lsl#2]
 str w11,[sp,#380]
 IA x9,5
 ldr x9,[x9]
 add x9,x9,x10,lsl#4
 str x9,[sp,#384]
 mov x9,#0
 str x9,[sp,#392]
 ldr w28,[sp,#348]
 cbz w28,.Li_grid_kind
 ldr x9,[x21,#136]
 ldr w9,[x9,x10,lsl#2]
 cmp w9,#1
 b.lt .Li_grid_kind
 str x19,[sp,#400]
 str x26,[sp,#408]
 mov w9,#1
 str w9,[sp,#416]
 b .Li_level
.Li_grid_kind:
 str x20,[sp,#400]
 str x27,[sp,#408]
 str wzr,[sp,#416]
.Li_level:
 ldr x9,[sp,#392]
 ldr w10,[sp,#364]
 cmp x9,x10
 b.hs .Li_field_next
 ldr x12,[sp,#400]
 ldr x13,[sp,#408]
 ldr w14,[sp,#360]
 IW w14,x12,8,x13
 ldr w14,[sp,#376]
 IW w14,x12,136,x13
 ldr w14,[sp,#380]
 IW w14,x12,72,x13
 ldr x14,[x12,#392]
 add x14,x14,x13,lsl#3
 mov x15,#0x2020202020202020
 str x15,[x14]
 ldr x15,[sp,#384]
 ldr w16,[sp,#376]
 cbz w16,.Li_upper
 ldr w16,[x15]
 str w16,[x14]
 ldr x14,[x12,#264]
 str xzr,[x14,x13,lsl#3]
 add x15,x15,#4
 b .Li_name
.Li_upper:
 IA x16,10
 ldrb w16,[x16]
 strb w16,[x14]
 ldr x16,[x21,#392]
 ldr x17,[sp,#368]
 ldr x14,[x21,#456]
 madd x17,x17,x14,x9
 ldr w17,[x16,x17,lsl#2]
 sub w17,w17,#1
 ldr w14,[sp,#344]
 cmp w17,w14
 b.hs .Li_consistency_bad
 IA x16,8
 ldr x17,[x16,x17,lsl#3]
 ldr x14,[x12,#264]
 str x17,[x14,x13,lsl#3]
.Li_name:
 ldr x14,[x12,#328]
 mov x16,#12
 madd x14,x13,x16,x14
 ldr x16,[x15]
 ldr w17,[x15,#8]
 str x16,[x14]
 str w17,[x14,#8]
 ldr x10,[sp,#368]
 ldr x11,[x21,#456]
 madd x10,x10,x11,x9
 ldr w11,[sp,#416]
 cbz w11,.Li_domain
 ldr x11,[x21,#832]
 ldr w14,[x11,x10,lsl#2]
 IW w14,x12,616,x13
 ldr x11,[x21,#920]
 ldr w14,[x11,x10,lsl#2]
 IW w14,x12,680,x13
 add x26,x26,#1
 b .Li_level_next
.Li_domain:
 ldr x11,[x21,#480]
 ldrsw x14,[x11,x10,lsl#2]
 cmp x14,x22
 b.hi .Li_consistency_bad
 IW w14,x12,456,x13
 ldr x15,[x21,#568]
 ldr x16,[x21,#632]
 mul x17,x10,x16
 add x15,x15,x17,lsl#2
 ldr x16,[x12,#520]
 mul x17,x13,x22
 add x16,x16,x17,lsl#2
 mov x17,#0
.Li_domain_loop:
 cmp x17,x14
 b.hs .Li_domain_zero
 ldr w11,[x15,x17,lsl#2]
 cmp w11,#1
 b.lt .Li_consistency_bad
 cmp w11,w22
 b.gt .Li_consistency_bad
 b .Li_domain_store
.Li_domain_zero:
 mov w11,#0
.Li_domain_store:
 str w11,[x16,x17,lsl#2]
 add x17,x17,#1
 cmp x17,x22
 b.lo .Li_domain_loop
 add x27,x27,#1
.Li_level_next:
 ldr x9,[sp,#392]
 add x9,x9,#1
 str x9,[sp,#392]
 ldr x9,[sp,#408]
 add x9,x9,#1
 str x9,[sp,#408]
 b .Li_level
.Li_field_next:
 add x25,x25,#1
 b .Li_field
.Li_complete:
 cmp x26,x23
 b.ne .Li_consistency_bad
 cmp x27,x24
 b.ne .Li_consistency_bad
 mov w0,#0
 b .Li_return
.Li_allocation_bad:
 mov x0,x19
 mov x1,x20
 bl md2asm_release_runtime_output_field_metadata
 mov w0,#1
 b .Li_return
.Li_consistency_bad:
 mov w0,#3
 b .Li_return
.Li_bad:
 mov w0,#2
.Li_return:
 ldr x18,[sp,#160]
 ldp x27,x28,[sp,#144]
 ldp x25,x26,[sp,#128]
 ldp x23,x24,[sp,#112]
 ldp x21,x22,[sp,#96]
 ldp x19,x20,[sp,#80]
 ldp x29,x30,[sp,#64]
 add sp,sp,#768
 ret
.size md2asm_create_runtime_output_field_metadata,.-md2asm_create_runtime_output_field_metadata
/* Inputs are source contiguous lower-one INTEGER, LOGICAL or CHARACTER arrays. */
.Li_input_descriptor:
 ldr x9,[x0]
 cbz x9,.Li_input_bad
 ldr x10,[x0,#16]
 cmp x10,x1
 b.ne .Li_input_bad
 ldr x10,[x0,#32]
 cmp x10,x1
 b.ne .Li_input_bad
 ldr x10,[x0,#24]
 lsl x11,x2,#40
 mov x12,#0x100000000
 orr x11,x11,x12
 cmp x10,x11
 b.ne .Li_input_bad
 ldr x10,[x0,#40]
 cmp x10,#1
 b.ne .Li_input_bad
 ldr x10,[x0,#48]
 cmp x10,#1
 b.ne .Li_input_bad
 ldr x10,[x0,#56]
 cmp x10,#686
 b.lt .Li_input_bad
 ldr x10,[x0,#8]
 cmn x10,#1
 b.ne .Li_input_bad
 mov w0,#0
 ret
.Li_input_bad:
 mov w0,#2
 ret
/* x0 descriptor, x1 count, x2 element bytes, x3 rank, x4 domain extent. */
.Li_allocate:
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 and x22,x3,#255
 lsr x24,x3,#8
 mov x23,x4
 cmp x22,#2
 mul x9,x20,x23
 csel x9,x9,x20,eq
 mul x0,x9,x21
 cmp x0,#1
 mov x10,#1
 csel x0,x0,x10,hs
 bl malloc
 ldr x18,[sp,#64]
 cbz x0,.Li_allocate_failed
 str x0,[x19]
 str x21,[x19,#16]
 str x21,[x19,#32]
 lsl x9,x24,#40
 orr x9,x9,x22,lsl#32
 str x9,[x19,#24]
 mov x9,#1
 str x9,[x19,#40]
 str x9,[x19,#48]
 cmp x22,#2
 b.eq .Li_allocate_rank2
 str x20,[x19,#56]
 mov x9,#-1
 str x9,[x19,#8]
 b .Li_allocate_success
.Li_allocate_rank2:
 str x23,[x19,#56]
 str x23,[x19,#64]
 str x9,[x19,#72]
 str x20,[x19,#80]
 add x9,x23,#1
 neg x9,x9
 str x9,[x19,#8]
.Li_allocate_success:
 mov w0,#0
 b .Li_allocate_return
.Li_allocate_failed:
 mov w0,#1
.Li_allocate_return:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.p2align 4
.global md2asm_release_runtime_output_field_metadata
.type md2asm_release_runtime_output_field_metadata,%function
md2asm_release_runtime_output_field_metadata:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 adrp x21,.Li_allocations
 add x21,x21,:lo12:.Li_allocations
 mov x22,#0
.Li_release_loop:
 ldp w9,w10,[x21],#16
 cmp w9,#0
 csel x9,x19,x20,eq
 add x9,x9,x10
 str x9,[sp,#56]
 ldr x0,[x9]
 cbz x0,.Li_release_next
 bl free
 ldr x18,[sp,#48]
 ldr x9,[sp,#56]
 str xzr,[x9]
.Li_release_next:
 add x22,x22,#1
 cmp x22,#16
 b.lo .Li_release_loop
 mov w0,#0
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_runtime_output_field_metadata,.-md2asm_release_runtime_output_field_metadata
.section .rodata
.p2align 3
/* Record0 is spectral, record1 is gridpoint. Last word packs source dtype and rank. */
.Li_allocations:
 .word 1,8,4,0x101
 .word 1,136,4,0x201
 .word 1,264,8,0x301
 .word 1,456,4,0x101
 .word 1,520,4,0x102
 .word 0,8,4,0x101
 .word 0,136,4,0x201
 .word 0,264,8,0x301
 .word 0,616,4,0x101
 .word 0,680,4,0x101
 .word 0,392,8,0x601
 .word 0,328,12,0x601
 .word 0,72,4,0x101
 .word 1,392,8,0x601
 .word 1,328,12,0x601
 .word 1,72,4,0x101
.section .note.GNU-stack,"",%progbits

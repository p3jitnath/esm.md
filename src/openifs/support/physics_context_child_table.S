// Solver contract skills/md2asm/references/openifs/support/physics_context_block_services.md.
// Selected context child pointer table and fallback storage. Contract: skills/md2asm/references/openifs/support/physics_context_block_services.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_physics_storage_child_table
.type md2asm_physics_storage_child_table,%function
md2asm_physics_storage_child_table:
 adrp x9,md2asm_block_context_native_counters
 add x9,x9,:lo12:md2asm_block_context_native_counters
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov w24,w1
 mov x23,x2
 movz x9,#7184
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x20,[x9]
 movz x9,#7192
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x21,[x9]
 movz x9,#0
 add x9,x19,x9
 ldr x22,[x9]
 movz x9,#5144
 add x9,x22,x9
 ldr w25,[x9]
 movz x9,#5224
 add x9,x22,x9
 ldr w26,[x9]
 movz x9,#5160
 add x9,x22,x9
 ldr w27,[x9]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 adrp x28,.Lsurface_groups
 add x28,x28,:lo12:.Lsurface_groups
 mov w9,#17
 str w9,[sp,#136]
.Lgroup_next:
 ldp w9,w10,[x28]
 ldr w11,[x28,#12]
 str w9,[sp,#144]
 str w11,[sp,#140]
 ldr w10,[x20,w10,uxtw]
 str w10,[sp,#148]
 cmp w11,#3
 b.ne .Lgroup_no_levels
 ldr w9,[x28,#8]
 ldr w9,[x20,w9,uxtw]
 b .Lgroup_levels_ready
.Lgroup_no_levels:
 mov w9,#1
.Lgroup_levels_ready:
 str w9,[sp,#152]
 str w25,[sp,#160]
 cmp w10,#0
 b.le .Lgroup_fallback
 cmp w11,#3
 b.ne .Lgroup_borrow_rank2
 stp w9,w10,[sp,#164]
 mul x9,x9,x10
 b .Lgroup_borrow_extent
.Lgroup_borrow_rank2:
 str w10,[sp,#164]
 mov w9,w10
.Lgroup_borrow_extent:
 mul x9,x9,x25
 sub w10,w24,#1
 mul x9,x9,x10
 ldr w10,[x28,#16]
 movz x11,#53232
 movk x11,#1,lsl #16
 add x11,x19,x11
 ldr x1,[x11,w10,uxtw]
 add x1,x1,x9,lsl #3
 b .Lgroup_descriptor
.Lgroup_fallback:
 mov w10,#1
 cmp w9,#1
 csel w9,w9,w10,ge
 cmp w11,#3
 b.ne .Lgroup_fallback_rank2
 stp w9,w10,[sp,#164]
 b .Lgroup_allocate
.Lgroup_fallback_rank2:
 mov w9,#1
 str w9,[sp,#164]
.Lgroup_allocate:
 mul x0,x25,x9
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lchild_abort
 mov x1,x0
.Lgroup_descriptor:
 ldr w9,[sp,#144]
 add x0,x19,w9,uxtw
 add x2,sp,#160
 ldr w3,[sp,#140]
 bl .Lcontext_descriptor
 add x28,x28,#20
 ldr w9,[sp,#136]
 subs w9,w9,#1
 str w9,[sp,#136]
 b.ne .Lgroup_next
 str w25,[sp,#160]
 str w26,[sp,#164]
 movz x9,#4548
 movk x9,#24,lsl #16
 add x9,x21,x9
 ldr w9,[x9]
 str w9,[sp,#168]
 movz x9,#53328
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 ldr w9,[sp,#160]
 ldr w10,[sp,#164]
 mul x9,x9,x10
 ldr w10,[sp,#168]
 mul x9,x9,x10
 sub w10,w24,#1
 mul x9,x9,x10
 add x1,x1,x9,lsl #3
 movz x0,#27448
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#3
 bl .Lcontext_descriptor
 movz x9,#17768
 add x9,x20,x9
 ldr w10,[x9]
 str w25,[sp,#160]
 str w10,[sp,#164]
 movz x9,#17764
 add x9,x20,x9
 ldr w11,[x9]
 mul x10,x10,x11
 mul x10,x10,x25
 sub w11,w24,#1
 mul x10,x10,x11
 movz x9,#53336
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 add x1,x1,x10,lsl #3
 movz x0,#27560
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#2
 bl .Lcontext_descriptor
 str w25,[sp,#160]
 str w26,[sp,#164]
 movz x9,#53296
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 ldr w9,[sp,#160]
 ldr w10,[sp,#164]
 mul x9,x9,x10
 sub w10,w24,#1
 mul x9,x9,x10
 add x1,x1,x9,lsl #3
 movz x0,#52840
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#2
 bl .Lcontext_descriptor
 str w25,[sp,#160]
 str w26,[sp,#164]
 movz x9,#53304
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 ldr w9,[sp,#160]
 ldr w10,[sp,#164]
 mul x9,x9,x10
 sub w10,w24,#1
 mul x9,x9,x10
 add x1,x1,x9,lsl #3
 movz x0,#52928
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#2
 bl .Lcontext_descriptor
 str w25,[sp,#160]
 str w26,[sp,#164]
 movz x9,#53312
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 ldr w9,[sp,#160]
 ldr w10,[sp,#164]
 mul x9,x9,x10
 sub w10,w24,#1
 mul x9,x9,x10
 add x1,x1,x9,lsl #3
 movz x0,#53016
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#2
 bl .Lcontext_descriptor
 str w25,[sp,#160]
 str w26,[sp,#164]
 movz x9,#264
 add x9,x21,x9
 ldr w9,[x9]
 str w9,[sp,#168]
 movz x9,#53320
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 ldr w9,[sp,#160]
 ldr w10,[sp,#164]
 mul x9,x9,x10
 ldr w10,[sp,#168]
 mul x9,x9,x10
 sub w10,w24,#1
 mul x9,x9,x10
 add x1,x1,x9,lsl #3
 movz x0,#53104
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#3
 bl .Lcontext_descriptor
 str w25,[sp,#160]
 str w26,[sp,#164]
 movz x9,#456
 movk x9,#24,lsl #16
 add x9,x21,x9
 ldr w10,[x9]
 movz x9,#496
 movk x9,#24,lsl #16
 add x9,x21,x9
 ldr w11,[x9]
 sub w12,w24,#1
 mul x10,x10,x12
 sub w11,w11,#1
 add x10,x10,x11
 mul x10,x10,x25
 movz x9,#53288
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x1,[x9]
 add x1,x1,x10,lsl #3
 movz x0,#31976
 movk x0,#1,lsl #16
 add x0,x19,x0
 add x2,sp,#160
 mov w3,#2
 bl .Lcontext_descriptor
 movz x9,#53640
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 cbz x0,.Luse_oops
 movz x17,#256
 add x0,x0,x17
 b .Ltrajectory_descriptor
.Luse_oops:
 movz x9,#53648
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 movz x17,#21776
 add x0,x0,x17
.Ltrajectory_descriptor:
 mov w1,w24
 mov w2,#1
 bl md2asm_context_block_address
 movz x9,#53224
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x0,[x9]
 movz x9,#53232
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#0]
 movz x9,#16
 add x9,x19,x9
 str x9,[x23,#8]
 movz x9,#53256
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#16]
 movz x9,#53264
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#24]
 movz x9,#53272
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#32]
 movz x9,#53280
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#40]
 movz x9,#17216
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#48]
 movz x9,#16
 add x9,x19,x9
 str x9,[x23,#56]
 movz x9,#744
 add x9,x19,x9
 str x9,[x23,#64]
 movz x9,#1472
 add x9,x19,x9
 str x9,[x23,#72]
 movz x9,#8024
 add x9,x19,x9
 str x9,[x23,#80]
 movz x9,#8584
 add x9,x19,x9
 str x9,[x23,#88]
 movz x9,#9312
 add x9,x19,x9
 str x9,[x23,#96]
 movz x9,#10040
 add x9,x19,x9
 str x9,[x23,#104]
 movz x9,#21688
 add x9,x19,x9
 str x9,[x23,#112]
 movz x9,#31088
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#160]
 movz x9,#17408
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#168]
 movz x9,#33080
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#192]
 movz x9,#51256
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#200]
 movz x9,#35744
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#208]
 movz x9,#40808
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#216]
 movz x9,#44912
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#224]
 movz x9,#45824
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#232]
 movz x9,#48160
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#240]
 movz x9,#50256
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#248]
 movz x9,#50920
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#256]
 movz x9,#52840
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#264]
 movz x9,#53224
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#280]
 movz x9,#53560
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#288]
 movz x9,#53568
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#296]
 movz x9,#53576
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#304]
 movz x9,#53584
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#312]
 movz x9,#53592
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#320]
 movz x9,#53600
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#328]
 movz x9,#53608
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#336]
 movz x9,#53616
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#344]
 movz x9,#53624
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#352]
 movz x9,#53632
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#360]
 movz x9,#7200
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#368]
 movz x9,#8440
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#376]
 movz x9,#9680
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#384]
 movz x9,#10920
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#392]
 movz x9,#12160
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#400]
 movz x9,#13400
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#408]
 movz x9,#14640
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#416]
 movz x9,#15880
 movk x9,#1,lsl #16
 add x9,x19,x9
 str x9,[x23,#424]
 movz x9,#17120
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 str x9,[x23,#432]
 movz x9,#256
 add x9,x21,x9
 ldr w10,[x9]
 mul x10,x10,x25
 mul x10,x10,x26
 sub w11,w24,#1
 mul x10,x10,x11
 movz x9,#53376
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 str x9,[x23,#120]
 movz x9,#240
 add x9,x21,x9
 ldr w10,[x9]
 mul x10,x10,x25
 mul x10,x10,x26
 sub w11,w24,#1
 mul x10,x10,x11
 movz x9,#53392
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 str x9,[x23,#128]
 movz x9,#264
 add x9,x21,x9
 ldr w10,[x9]
 mul x10,x10,x25
 mul x10,x10,x26
 sub w11,w24,#1
 mul x10,x10,x11
 movz x9,#53400
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 str x9,[x23,#136]
 movz x9,#53664
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 sub w10,w24,#1
 mul x10,x10,x25
 mul x10,x10,x26
 add x9,x9,x10,lsl #3
 str x9,[x23,#144]
 movz x9,#53672
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 sub w10,w24,#1
 mul x10,x10,x25
 add x9,x9,x10,lsl #3
 str x9,[x23,#176]
 movz x9,#53680
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x9,[x9]
 sub w10,w24,#1
 mul x10,x10,x25
 add x9,x9,x10,lsl #3
 str x9,[x23,#184]
 movz x9,#53216
 movk x9,#1,lsl #16
 add x9,x19,x9
 ldr x0,[x9]
 movz x17,#8
 add x0,x0,x17
 mov w1,w24
 mov w2,#4
 bl md2asm_context_block_address
 str x0,[x23,#152]
 movz x0,#4664
 movk x0,#24,lsl #16
 add x0,x21,x0
 mov w1,w24
 mov w2,#4
 bl md2asm_context_block_address
 str x0,[x23,#272]
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
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
 add sp,sp,#192
 ret
.Lchild_abort:
 bl abort
.size md2asm_physics_storage_child_table,.-md2asm_physics_storage_child_table
.Lcontext_descriptor:
 str x1,[x0]
 mov x4,#8
 str x4,[x0,#16]
 str xzr,[x0,#24]
 strb w3,[x0,#28]
 mov w5,#3
 strb w5,[x0,#29]
 str x4,[x0,#32]
 mov x4,#1
 mov x5,#0
 mov x6,#0
 add x7,x0,#40
 mov x12,#1
.Lcontext_dimensions:
 ldr w8,[x2,x5,lsl #2]
 sub x6,x6,x4
 stp x4,x12,[x7]
 str x8,[x7,#16]
 mul x4,x4,x8
 add x7,x7,#24
 add x5,x5,#1
 cmp x5,x3
 b.lo .Lcontext_dimensions
 str x6,[x0,#8]
 ret
.global md2asm_context_block_address
.hidden md2asm_context_block_address
.type md2asm_context_block_address,%function
md2asm_context_block_address:
 ldr x4,[x0]
 ldr x5,[x0,#16]
 sub w2,w2,#1
 mov x6,#24
 madd x6,x2,x6,x0
 add x6,x6,#40
 ldp x7,x8,[x6]
 sxtw x9,w1
 sub x9,x9,x8
 mul x9,x9,x7
 madd x0,x9,x5,x4
 ret
.size md2asm_context_block_address,.-md2asm_context_block_address
.section .rodata
.p2align 3
.Lsurface_groups:
 .word 92424,5884,5888,3,176
 .word 92200,6172,6176,3,184
 .word 91320,6452,0,2,192
 .word 91408,6748,0,2,200
 .word 92536,7636,7640,3,208
 .word 91496,7876,0,2,216
 .word 92312,7340,7344,3,288
 .word 91672,8900,0,2,224
 .word 91760,10548,0,2,232
 .word 91936,12604,0,2,240
 .word 91584,15252,0,2,248
 .word 92112,15564,0,2,256
 .word 92760,16244,16248,3,264
 .word 92024,17020,0,2,272
 .word 92872,14996,15000,3,280
 .word 91848,11956,0,2,296
 .word 92648,12244,12248,3,304
.bss
.p2align 3
.global md2asm_block_context_native_counters
.type md2asm_block_context_native_counters,%object
md2asm_block_context_native_counters:
 .zero 32
.size md2asm_block_context_native_counters,32
.section .note.GNU-stack,"",%progbits

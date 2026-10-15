/* Read original GNU12 live surface constants as integer metadata.
 * Four arguments are gem, coupling controls, physics controls and 2304 output bytes.
 * Input type objects and true allocation descriptors follow the frozen original ABI.
 * Vegetation allocations are contiguous FP64 with stride one and span eight.
 * No forecast field is read or changed. No FP instruction, child or stack is used.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_surface_config_words_direct_
.type md2asm_surface_config_words_direct_,%function
md2asm_surface_config_words_direct_:
 mov x4,x3
 mov x5,#144
.Lclear:
 stp xzr,xzr,[x4],#16
 subs x5,x5,#1
 b.ne .Lclear
 mov x4,#1
 str x4,[x3]
 ldr x6,[x2,#440]
 cbz x6,.Ldone
 ldrsw x7,[x6,#10336]
 ldrsw x4,[x0]
 stp x4,x7,[x3,#8]
 adrp x16,:got:__yomct0_MOD_lecmwf
 ldr x16,[x16,:got_lo12:__yomct0_MOD_lecmwf]
 ldrsw x17,[x16]
 str x17,[x3,#24]
 ldrsw x17,[x2,#124]
 str x17,[x3,#32]
 ldrsw x17,[x2,#176]
 str x17,[x3,#40]
 ldrsw x17,[x2,#172]
 str x17,[x3,#48]
 ldrsw x17,[x1,#6764]
 str x17,[x3,#56]
 adrp x16,:got:__yomcst_MOD_rg
 ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
 ldr x17,[x16]
 str x17,[x3,#64]
 adrp x16,:got:__yomcst_MOD_rtt
 ldr x16,[x16,:got_lo12:__yomcst_MOD_rtt]
 ldr x17,[x16]
 str x17,[x3,#72]
 adrp x16,:got:__yoethf_MOD_rhoh2o
 ldr x16,[x16,:got_lo12:__yoethf_MOD_rhoh2o]
 ldr x17,[x16]
 str x17,[x3,#80]
 ldr x17,[x6,#7872]
 str x17,[x3,#88]
 ldr x17,[x6,#7968]
 str x17,[x3,#96]
 mov x17,#1
 str x17,[x3,#136]
 cmp x7,#127
 b.hi .Ldone
 mov x8,#10344
 add x8,x6,x8
 add x9,x8,#64
 ldr x10,[x8]
 ldr x11,[x9]
 cbz x10,.Ldone
 cbz x11,.Ldone
 ldp x12,x13,[x8,#48]
 ldp x14,x15,[x9,#48]
 stp x12,x13,[x3,#104]
 stp x14,x15,[x3,#120]
 cmp x12,#0
 b.gt .Ldone
 cmp x14,#0
 b.gt .Ldone
 cmp x13,x7
 b.lt .Ldone
 cmp x15,x7
 b.lt .Ldone
 ldr x16,[x8,#40]
 cmp x16,#1
 b.ne .Ldone
 ldr x16,[x9,#40]
 cmp x16,#1
 b.ne .Ldone
 sub x10,x10,x12,lsl#3
 sub x11,x11,x14,lsl#3
 add x8,x3,#256
 add x9,x3,#1280
 mov x16,#0
.Lcopy:
 ldr x17,[x10,x16,lsl#3]
 str x17,[x8,x16,lsl#3]
 ldr x17,[x11,x16,lsl#3]
 str x17,[x9,x16,lsl#3]
 add x16,x16,#1
 cmp x16,x7
 b.le .Lcopy
 str xzr,[x3]
.Ldone:
 ret
.size md2asm_surface_config_words_direct_,.-md2asm_surface_config_words_direct_
.section .note.GNU-stack,"",%progbits

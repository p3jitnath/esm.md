// Contract: skills/md2asm/references/openifs/setup/operational_forecast_work_storage.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_prepare_operational_fresh_forecast
.type md2asm_prepare_operational_fresh_forecast,%function
md2asm_prepare_operational_fresh_forecast:
 cbz x0,.Lfresh_bad_leaf
 tst x0,#7
 b.ne .Lfresh_bad_leaf
 adds x9,x0,#64
 b.cs .Lfresh_bad_leaf
 sub sp,sp,#1152
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x27,x0
 adrp x12,.Lfresh_required
 add x12,x12,:lo12:.Lfresh_required
 mov x9,#0
.Lfresh_views:
 add x10,x27,x9,lsl#4
 ldp x10,x11,[x10]
 cbz x10,.Lfresh_bad
 tst x10,#7
 b.ne .Lfresh_bad
 ldr x13,[x12,x9,lsl#3]
 cmp x11,x13
 b.lo .Lfresh_bad
 adds x14,x10,x13
 b.cs .Lfresh_bad
 add x11,x27,#64
 cmp x10,x11
 b.hs .Lfresh_table_clear
 cmp x27,x14
 b.lo .Lfresh_bad
.Lfresh_table_clear:
 add x11,sp,#112
 str x10,[x11,x9,lsl#3]
 add x11,sp,#144
 str x14,[x11,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#4
 b.lo .Lfresh_views
 mov x9,#0
.Lfresh_pair_i:
 add x11,sp,#112
 ldr x12,[x11,x9,lsl#3]
 add x11,sp,#144
 ldr x13,[x11,x9,lsl#3]
 add x10,x9,#1
.Lfresh_pair_j:
 cmp x10,#4
 b.hs .Lfresh_pair_next
 add x11,sp,#112
 ldr x14,[x11,x10,lsl#3]
 add x11,sp,#144
 ldr x15,[x11,x10,lsl#3]
 cmp x12,x15
 b.hs .Lfresh_pair_clear
 cmp x14,x13
 b.lo .Lfresh_bad
.Lfresh_pair_clear:
 add x10,x10,#1
 b .Lfresh_pair_j
.Lfresh_pair_next:
 add x9,x9,#1
 cmp x9,#3
 b.lo .Lfresh_pair_i
 ldp x19,x20,[sp,#112]
 ldp x21,x22,[sp,#128]
 adrp x23,md2asm_owned_physics_runtime_data
 add x23,x23,:lo12:md2asm_owned_physics_runtime_data
 adrp x24,md2asm_owned_fresh_forecast_state
 add x24,x24,:lo12:md2asm_owned_fresh_forecast_state
 // The pointer table itself is also a borrowed, unchanged input.
 add x9,x27,#64
 add x10,x23,#608
 cmp x27,x10
 b.hs .Lfresh_table_state
 cmp x23,x9
 b.lo .Lfresh_bad
.Lfresh_table_state:
 add x10,x24,#128
 cmp x27,x10
 b.hs .Lfresh_table_owned_clear
 cmp x24,x9
 b.lo .Lfresh_bad
.Lfresh_table_owned_clear:
 // All borrowed views must be disjoint from both descriptor owners.
 mov x9,#0
.Lfresh_owner_disjoint:
 add x11,sp,#112
 ldr x12,[x11,x9,lsl#3]
 add x11,sp,#144
 ldr x13,[x11,x9,lsl#3]
 add x14,x23,#608
 cmp x12,x14
 b.hs .Lfresh_own2
 cmp x23,x13
 b.lo .Lfresh_bad
.Lfresh_own2:
 add x14,x24,#128
 cmp x12,x14
 b.hs .Lfresh_own_clear
 cmp x24,x13
 b.lo .Lfresh_bad
.Lfresh_own_clear:
 add x9,x9,#1
 cmp x9,#4
 b.lo .Lfresh_owner_disjoint
 ldr x9,[x24,#112]
 cbnz x9,.Lfresh_bad
 ldr w9,[x24,#120]
 cbnz w9,.Lfresh_bad
 ldr x9,[x24]
 cbnz x9,.Lfresh_bad
 mov x9,#64
.Lfresh_old_bases:
 ldr x10,[x23,x9]
 cbnz x10,.Lfresh_bad
 add x9,x9,#136
 cmp x9,#608
 b.lo .Lfresh_old_bases
 mov x9,#35104
 ldr w10,[x21,x9]
 cmp w10,#1
 b.ne .Lfresh_bad
 mov x9,#35288
 ldr w10,[x21,x9]
 cmp w10,#0
 b.ne .Lfresh_bad
 mov x9,#39520
 ldr w10,[x21,x9]
 cmp w10,#1
 b.ne .Lfresh_bad
 mov x9,#51088
 ldr w10,[x21,x9]
 cmp w10,#0
 b.ne .Lfresh_bad
 adrp x9,md2asm_owned_loop_data
 add x9,x9,:lo12:md2asm_owned_loop_data
 ldr w10,[x9,#56]
 cbnz w10,.Lfresh_bad
 movz x9,#5024
 movk x9,#24,lsl#16
 ldr w10,[x19,x9]
 cmp w10,#1
 b.ne .Lfresh_bad
 movz x9,#5092
 movk x9,#24,lsl#16
 ldr w10,[x19,x9]
 cmp w10,#1
 b.ne .Lfresh_bad
 movz x9,#64636
 movk x9,#62,lsl#16
 ldr w10,[x19,x9]
 cmp w10,#0
 b.ne .Lfresh_bad
 movz x9,#(1359328 & 65535)
 movk x9,#(1359328 >> 16),lsl#16
 add x28,x19,x9
 ldp w9,w10,[x28]
 cbnz w9,.Lfresh_bad
 cmp w10,#1
 b.lt .Lfresh_bad
 // Copy the actual source character path, trim spaces, and append one C NUL.
 mov x9,#0
 mov x11,#0
 add x12,sp,#320
.Lfresh_path:
 ldrb w10,[x22,x9]
 cmp w10,#32
 b.lo .Lfresh_bad
 cmp w10,#126
 b.hi .Lfresh_bad
 strb w10,[x12,x9]
 add x9,x9,#1
 cmp w10,#32
 csel x11,x9,x11,ne
 cmp x9,#120
 b.lo .Lfresh_path
 cbz x11,.Lfresh_bad
 strb wzr,[x12,x11]
.Lfresh_stat:
 mov x0,#-100
 add x1,sp,#320
 add x2,sp,#192
 mov x3,#0
 mov x8,#79
 svc #0
 cmn x0,#4
 b.eq .Lfresh_stat
 cbz x0,.Lfresh_existing
 cmn x0,#2
 b.ne .Lfresh_IO_error
 // Construct every descriptor privately before committing source-visible state.
 mov x25,#0
 mov x26,#0
.Lfresh_allocate:
 adrp x9,.Lfresh_private_offsets
 add x9,x9,:lo12:.Lfresh_private_offsets
 ldr w9,[x9,x25,lsl#2]
 add x0,sp,#448
 add x0,x0,x9
 cmp x25,#4
 mov w1,#4
 mov w10,#3
 csel w1,w10,w1,eq
 adrp x2,.Lfresh_extents4
 add x2,x2,:lo12:.Lfresh_extents4
 adrp x9,.Lfresh_extents3
 add x9,x9,:lo12:.Lfresh_extents3
 csel x2,x9,x2,eq
 mov w3,#1
 mov w4,#0
 bl md2asm_allocate_radiation_flux_array
 cbnz w0,.Lfresh_rollback
 add x26,x26,#1
 adrp x9,.Lfresh_private_offsets
 add x9,x9,:lo12:.Lfresh_private_offsets
 ldr w9,[x9,x25,lsl#2]
 add x10,sp,#448
 add x10,x10,x9
 cmp x25,#4
 b.eq .Lfresh_lower3
 mov x9,#-3
 str x9,[x10,#8]
 str xzr,[x10,#120]
 mov x9,#1
 str x9,[x10,#128]
 b .Lfresh_lower_done
.Lfresh_lower3:
 mov x9,#-2
 str x9,[x10,#8]
 str xzr,[x10,#96]
 mov x9,#1
 str x9,[x10,#104]
.Lfresh_lower_done:
 add x25,x25,#1
 cmp x25,#5
 b.lo .Lfresh_allocate
 // Commit complete descriptors and then the source control assignments.
 mov x25,#0
.Lfresh_commit:
 adrp x9,.Lfresh_private_offsets
 add x9,x9,:lo12:.Lfresh_private_offsets
 ldr w9,[x9,x25,lsl#2]
 add x10,sp,#448
 add x10,x10,x9
 cmp x25,#4
 b.eq .Lfresh_commit_sp
 mov x11,#136
 mul x11,x25,x11
 add x11,x23,x11
 add x11,x11,#64
 mov x12,#136
 b .Lfresh_copy
.Lfresh_commit_sp:
 mov x11,x24
 mov x12,#112
.Lfresh_copy:
 ldr x9,[x10],#8
 str x9,[x11],#8
 subs x12,x12,#8
 b.ne .Lfresh_copy
 add x25,x25,#1
 cmp x25,#5
 b.lo .Lfresh_commit
 ldp w9,w10,[x28]
 stp w9,w10,[x20,#20]
 mov w9,#1
 str w9,[x20,#28]
 mov w10,#-999
 str w10,[x20,#36]
 mov x10,#35176
 str w9,[x21,x10]
 mov x9,#31
 str x9,[x24,#112]
 mov w0,#0
 b .Lfresh_return
.Lfresh_rollback:
 cbz x26,.Lfresh_alloc_failed
 sub x26,x26,#1
 adrp x9,.Lfresh_private_offsets
 add x9,x9,:lo12:.Lfresh_private_offsets
 ldr w9,[x9,x26,lsl#2]
 add x10,sp,#448
 ldr x0,[x10,x9]
 bl free
 b .Lfresh_rollback
.Lfresh_alloc_failed:
 mov w0,#1
 b .Lfresh_return
.Lfresh_existing:
 mov w0,#3
 b .Lfresh_return
.Lfresh_IO_error:
 mov w0,#4
 b .Lfresh_return
.Lfresh_bad:
 mov w0,#2
.Lfresh_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1152
 ret
.Lfresh_bad_leaf:
 mov w0,#2
 ret
.size md2asm_prepare_operational_fresh_forecast,.-md2asm_prepare_operational_fresh_forecast
.section .rodata
.p2align 3
.Lfresh_required:.quad 4275088,360,51512,248
.Lfresh_private_offsets:.word 0,136,272,408,544
.Lfresh_extents4:.word 1,1,1,2
.Lfresh_extents3:.word 1,1,2,1
.section .note.GNU-stack,"",%progbits

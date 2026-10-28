/* Source-selected output family ownership before public file writing.
 * Contract skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md.
 */
.arch armv8.2-a
.text
.macro SF_CALL target
 bl \target
 ldr x18,[sp,#112]
.endm
.p2align 4
.global md2asm_write_runtime_selected_output_family
.type md2asm_write_runtime_selected_output_family,%function
md2asm_write_runtime_selected_output_family:
 sub sp,sp,#640
 stp x29,x30,[sp,#32]
 add x29,sp,#32
 stp x19,x20,[sp,#48]
 stp x21,x22,[sp,#64]
 stp x23,x24,[sp,#80]
 stp x25,x26,[sp,#96]
 str x18,[sp,#112]
 stp x27,x28,[sp,#128]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov w26,w7
 stp xzr,xzr,[sp,#144]
 stp xzr,xzr,[sp,#160]
 stp xzr,xzr,[sp,#176]
 stp xzr,xzr,[sp,#192]
 mov w28,#2
 cbz x19,.Lsf_admit
 cbz x20,.Lsf_admit
 cbz x21,.Lsf_admit
 cbz x23,.Lsf_admit
 cbz x24,.Lsf_admit
 cmp w26,#2
 b.hi .Lsf_admit
 orr x9,x19,x20
 orr x9,x9,x21
 orr x9,x9,x23
 tst x9,#7
 b.ne .Lsf_admit
 mov x9,#20400
 adds x9,x19,x9
 b.cs .Lsf_admit
 adds x9,x20,#128
 b.cs .Lsf_admit
 adds x9,x21,#744
 b.cs .Lsf_admit
 adds x9,x23,#64
 b.cs .Lsf_admit
 adds x9,x24,#256
 b.cs .Lsf_admit
 ldr x9,[x20,#40]
 cbz x9,.Lsf_admit
 tst x9,#7
 b.ne .Lsf_admit
 adds x10,x9,#4096
 b.cs .Lsf_admit
 ldr x10,[x9]
 cmp x10,x19
 b.ne .Lsf_admit
 ldr x10,[x9,#16]
 cmp x10,#7
 b.ne .Lsf_admit
 ldr w10,[x9,#24]
 cmp w10,#1
 b.lt .Lsf_admit
 ldr w11,[x9,#28]
 cmp w11,#1
 b.lt .Lsf_admit
 cmp w11,w10
 b.gt .Lsf_admit
 ldp x10,x11,[x23,#24]
 cbz x10,.Lsf_admit
 cbz x11,.Lsf_admit
 movz x12,#0xffff
 movk x12,#0x7fff,lsl#16
 cmp x10,x12
 b.hi .Lsf_admit
 cmp x11,x12
 b.hi .Lsf_admit
 cmp x10,x11
 b.hi .Lsf_admit
 ldr w12,[x23]
 cbz w26,.Lsf_spectral_plan
 cbnz w12,.Lsf_admit
 ldrsw x12,[x19,#7376]
 cmp x10,x12
 b.ne .Lsf_admit
 ldrsw x12,[x19,#7388]
 cmp x11,x12
 b.ne .Lsf_admit
 b .Lsf_plan_ready
.Lsf_spectral_plan:
 cmp w12,#1
 b.ne .Lsf_admit
 ldr w12,[x23,#16]
 mov w14,#32766
 cmp w12,w14
 b.hi .Lsf_admit
 add x13,x12,#1
 add x12,x12,#2
 mul x12,x12,x13
 cmp x11,x12
 b.ne .Lsf_admit
.Lsf_plan_ready:
 ldrsw x27,[x21]
 cmp x27,#16,lsl#12
 b.hi .Lsf_admit
 cmp w26,#1
 b.ne .Lsf_count_ready
 cmp x27,#1639
 b.hi .Lsf_admit
.Lsf_count_ready:
 cbz x27,.Lsf_valid
 cbz x22,.Lsf_admit
 tst x22,#7
 b.ne .Lsf_admit
 adds x9,x22,#112
 b.cs .Lsf_admit
 cmp w26,#2
 b.ne .Lsf_valid
 ldr w9,[x23,#4]
 cmp w9,#109
 b.ne .Lsf_valid
 cbz x25,.Lsf_admit
 tst x25,#7
 b.ne .Lsf_admit
 adds x9,x25,#2776
 b.cs .Lsf_admit
.Lsf_valid:
 mov w28,#0
.Lsf_admit:
 mov w0,w28
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_return
 cbz x27,.Lsf_return
 mov x9,#0
.Lsf_copy_plan:
 ldr x10,[x23,x9]
 add x11,sp,#208
 str x10,[x11,x9]
 add x9,x9,#8
 cmp x9,#64
 b.lo .Lsf_copy_plan
 mov x9,#0
.Lsf_copy_context:
 ldr x10,[x20,x9]
 add x11,sp,#272
 str x10,[x11,x9]
 add x9,x9,#8
 cmp x9,#128
 b.lo .Lsf_copy_context
 mov x9,#16
 cbz w26,.Lsf_stride
 mov x9,#8
 cmp w26,#1
 mov x10,#12
 csel x9,x9,x10,eq
.Lsf_stride:
 str w9,[sp,#228]
 mul x9,x27,x9
 str x9,[sp,#176]
 cmp w26,#0
 b.ne .Lsf_grid_bytes
 ldrsw x10,[x21,#608]
 cmp x10,#16,lsl#12
 b.hi .Lsf_bad_before_owners
 lsl x10,x10,#2
 cmp x10,#0
 csinc x10,x10,xzr,ne
 str x10,[sp,#184]
 mov x11,#0
 b .Lsf_admit_bytes
.Lsf_grid_bytes:
 ldr x10,[x23,#24]
 mul x11,x27,x10
 lsr x10,x11,#61
 cbnz x10,.Lsf_bad_before_owners
 lsl x11,x11,#3
.Lsf_admit_bytes:
 str x11,[sp,#192]
 ldr x9,[sp,#176]
 ldr x10,[sp,#184]
 adds x9,x9,x10
 b.cs .Lsf_bad_before_owners
 adds x9,x9,x11
 b.cs .Lsf_bad_before_owners
 adds x9,x9,#2,lsl#12
 b.cs .Lsf_bad_before_owners
 ldr x10,[x20,#96]
 cmp x9,x10
 b.hi .Lsf_bad_before_owners
 str x9,[sp,#200]
 sub x10,x10,x9
 str x10,[sp,#368]
 mov w0,#0
 b .Lsf_budget_agree
.Lsf_bad_before_owners:
 mov w0,#2
.Lsf_budget_agree:
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
 ldr x0,[sp,#176]
 SF_CALL malloc
 str x0,[sp,#144]
 cmp x0,#0
 cset w0,eq
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
 cbnz w26,.Lsf_allocate_dense
 ldr x0,[sp,#184]
 SF_CALL malloc
 str x0,[sp,#152]
 cmp x0,#0
 cset w0,eq
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
 add x9,sp,#400
 str x9,[sp]
 mov x0,x21
 ldr w1,[x23,#4]
 ldr w2,[x23,#32]
 ldr x9,[x20,#40]
 ldr w3,[x9,#68]
 ldr x4,[sp,#144]
 mov x5,x27
 ldr x6,[sp,#152]
 ldrsw x7,[x21,#608]
 SF_CALL md2asm_build_runtime_spectral_output_selection
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
 ldr w9,[sp,#404]
 ldr x10,[x23,#24]
 umull x9,w9,w10
 lsr x10,x9,#61
 cbnz x10,.Lsf_spectral_budget_bad
 lsl x9,x9,#3
 cmp x9,#0
 csinc x9,x9,xzr,ne
 str x9,[sp,#192]
 ldr x10,[sp,#200]
 adds x10,x10,x9
 b.cs .Lsf_spectral_budget_bad
 ldr x11,[x20,#96]
 cmp x10,x11
 b.hi .Lsf_spectral_budget_bad
 sub x11,x11,x10
 str x11,[sp,#368]
 mov w0,#0
 b .Lsf_spectral_budget_agree
.Lsf_spectral_budget_bad:
 mov w0,#2
.Lsf_spectral_budget_agree:
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
.Lsf_allocate_dense:
 ldr x0,[sp,#192]
 SF_CALL malloc
 str x0,[sp,#160]
 cmp x0,#0
 cset w0,eq
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
 cbnz w26,.Lsf_grid_select
 mov x0,x22
 ldr x1,[sp,#152]
 ldr w2,[sp,#404]
 ldr x3,[x23,#24]
 ldr x4,[sp,#160]
 ldr x5,[sp,#192]
 SF_CALL md2asm_pack_runtime_spectral_output_fields
 b .Lsf_selected_agree
.Lsf_grid_select:
 cmp w26,#2
 b.eq .Lsf_upper_select
 ldr x9,[x20,#24]
 ldr d0,[x9,#112]
 adrp x9,:got:md2asm_owned_ecmwf_thermal_namespace
 ldr x9,[x9,:got_lo12:md2asm_owned_ecmwf_thermal_namespace]
 ldr d1,[x9,#64]
 stp d0,d1,[sp,#416]
 mov x0,x21
 mov x1,x22
 ldr w2,[x19,#7376]
 ldr w3,[x19,#5144]
 ldr x4,[sp,#144]
 ldr x5,[sp,#160]
 ldr x6,[sp,#192]
 add x7,sp,#416
 ldr x9,[sp,#176]
 str x9,[sp]
 SF_CALL md2asm_select_runtime_physical_output_fields
 str w27,[sp,#400]
 b .Lsf_selected_agree
.Lsf_upper_select:
 ldr x9,[sp,#176]
 stp x9,x25,[sp]
 add x9,sp,#400
 str x9,[sp,#16]
 mov x0,x21
 mov x1,x22
 ldr w2,[x19,#7376]
 ldr w3,[x19,#5144]
 ldr w4,[x23,#4]
 ldr x5,[sp,#144]
 ldr x6,[sp,#160]
 ldr x7,[sp,#192]
 SF_CALL md2asm_select_runtime_upper_grid_output_fields
.Lsf_selected_agree:
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
 mov x0,x19
 add x1,sp,#272
 add x2,sp,#208
 ldr x3,[sp,#144]
 ldr x4,[sp,#160]
 ldr w5,[sp,#400]
 mov x6,x24
 mov x7,#256
 mov x9,#210
 cmp w26,#0
 csel x7,x9,x7,eq
 SF_CALL md2asm_write_runtime_gathered_fields
 cbnz w0,.Lsf_cleanup
 cmp w26,#1
 b.ne .Lsf_cleanup
 ldr x9,[x20,#40]
 ldr w9,[x9,#24]
 cmp w9,#1
 b.le .Lsf_after_surface_reduce
 adrp x0,:got:md2asm_owned_runtime_grib_writer_state64
 ldr x0,[x0,:got_lo12:md2asm_owned_runtime_grib_writer_state64]
 adr x1,.Lsf_wrout_name
 mov x2,#10
 SF_CALL .Lsf_reduce_last_steps
 SF_CALL .Lsf_agreement
 cbnz w0,.Lsf_cleanup
.Lsf_after_surface_reduce:
 adrp x0,:got:md2asm_owned_runtime_grib_writer_state64
 ldr x0,[x0,:got_lo12:md2asm_owned_runtime_grib_writer_state64]
 add x1,x23,#40
 ldr x2,[sp,#144]
 mov x3,x27
 SF_CALL .Lsf_update_steps
.Lsf_cleanup:
 str w0,[sp,#432]
 ldr x0,[sp,#160]
 cbz x0,.Lsf_free_indices
 SF_CALL free
.Lsf_free_indices:
 ldr x0,[sp,#152]
 cbz x0,.Lsf_free_codes
 SF_CALL free
.Lsf_free_codes:
 ldr x0,[sp,#144]
 cbz x0,.Lsf_final_agree
 SF_CALL free
.Lsf_final_agree:
 ldr w0,[sp,#432]
 SF_CALL .Lsf_agreement
.Lsf_return:
 ldr x18,[sp,#112]
 ldp x27,x28,[sp,#128]
 ldp x19,x20,[sp,#48]
 ldp x21,x22,[sp,#64]
 ldp x23,x24,[sp,#80]
 ldp x25,x26,[sp,#96]
 ldp x29,x30,[sp,#32]
 add sp,sp,#640
 ret
.size md2asm_write_runtime_selected_output_family,.-md2asm_write_runtime_selected_output_family
/* The public FIAT vector reduction keeps the source MAX and default communicator. */
.Lsf_update_steps:
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 ldr w23,[x1]
 mov x3,#0
 bl md2asm_update_runtime_last_physics_output_steps
 bl .Lsf_agreement
 cbnz w0,.Lsf_steps_return
 mov x9,#0
 mov w22,#0
.Lsf_step_rows:
 cmp x9,x21
 b.eq .Lsf_steps_reduce
 add x12,x20,x9,lsl#3
 ldr w10,[x12]
 mov x11,#0
 add x12,x19,#16
.Lsf_step_codes:
 ldr w13,[x12,x11,lsl#2]
 cmp w10,w13
 b.ne .Lsf_step_code_next
 add x14,x19,#36
 str w23,[x14,x11,lsl#2]
.Lsf_step_code_next:
 cset w13,eq
 orr w22,w22,w13
 add x11,x11,#1
 cmp x11,#5
 b.lo .Lsf_step_codes
 add x9,x9,#1
 b .Lsf_step_rows
.Lsf_steps_reduce:
 cbz w22,.Lsf_steps_success
 mov x0,x19
 mov x1,#0
 mov x2,#0
 bl .Lsf_reduce_last_steps
 b .Lsf_steps_return
.Lsf_steps_success:
 mov w0,#0
.Lsf_steps_return:
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret

/* WROUTGPGB reduces first; WRMLFP reduces again after tracked step writes. */
.Lsf_reduce_last_steps:
 sub sp,sp,#144
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 mov x19,x0
 stp x1,x2,[sp,#48]
 add x9,sp,#64
 add x10,x19,#36
 str x10,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#4
 str x10,[x9,#16]
 mov x11,#0x10100000000
 str x11,[x9,#24]
 str x10,[x9,#32]
 mov x10,#1
 stp x10,x10,[x9,#40]
 mov x10,#5
 str x10,[x9,#56]
 str wzr,[sp,#128]
 add x0,sp,#64
 adr x1,.Lsf_max
 mov x2,#0
 mov x3,#0
 add x4,sp,#128
 ldr x5,[sp,#48]
 mov x6,#3
 ldr x7,[sp,#56]
 bl __mpl_allreduce_mod_MOD_mpl_allreduce_int
 ldr w9,[sp,#128]
 cmp w9,#0
 mov w0,#3
 csel w0,wzr,w0,eq
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret

.p2align 2
.Lsf_agreement:
 stp x29,x30,[sp,#-80]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 str w0,[sp,#48]
 mrs x19,fpsr
 mrs x20,fpcr
 bl __errno_location
 mov x21,x0
 ldr w9,[x21]
 str w9,[sp,#52]
 ldr w0,[sp,#48]
 bl md2asm_agree_owned_distributed_partition_status
 str w0,[sp,#56]
 ldr w9,[sp,#52]
 str w9,[x21]
 msr fpcr,x20
 msr fpsr,x19
 ldr w0,[sp,#56]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#80
 ret

.section .rodata
.Lsf_max: .ascii "MAX"
.Lsf_wrout_name: .ascii "WROUTGPGB:"
.section .note.GNU-stack,"",%progbits

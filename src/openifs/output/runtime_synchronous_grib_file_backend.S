/* Source field order, public ECTRANS gather and synchronous GRIB framing.
 * Contract skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md.
 */
.arch armv8.2-a
.text
.macro FILE_CALL target
 bl \target
 ldr x18,[sp,#112]
.endm
.p2align 4
.global md2asm_write_runtime_gathered_fields
.type md2asm_write_runtime_gathered_fields,%function
md2asm_write_runtime_gathered_fields:
 mov x9,#4864
 sub sp,sp,x9
 stp x29,x30,[sp,#16]
 add x29,sp,#16
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 str x18,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,x7
 mov x9,#-1
 str x9,[sp,#128]
 stp xzr,xzr,[sp,#136]
 stp xzr,xzr,[sp,#152]
 stp xzr,xzr,[sp,#168]
 stp xzr,xzr,[sp,#184]
 str xzr,[sp,#200]
 str wzr,[sp,#352]
 mov w27,#2
 cbz x19,.Lfile_admission
 cbz x20,.Lfile_admission
 cbz x21,.Lfile_admission
 orr x9,x19,x20
 orr x9,x9,x21
 tst x9,#7
 b.ne .Lfile_admission
 mov x9,#20400
 adds x9,x19,x9
 b.cs .Lfile_admission
 adds x9,x20,#128
 b.cs .Lfile_admission
 adds x9,x21,#64
 b.cs .Lfile_admission
 adrp x9,:got:md2asm_owned_runtime_grib_writer_state64
 ldr x9,[x9,:got_lo12:md2asm_owned_runtime_grib_writer_state64]
 movz x10,#0x4752
 movk x10,#0x4257,lsl#16
 movk x10,#0x5354,lsl#32
 movk x10,#1,lsl#48
 ldr x11,[x9]
 cmp x11,x10
 b.ne .Lfile_admission
 ldr x10,[x9,#8]
 cmp x10,#1
 b.ne .Lfile_admission
 ldr w10,[x9,#56]
 cbnz w10,.Lfile_admission
 ldr w10,[x9,#60]
 cmp w10,#1
 b.ne .Lfile_admission
 ldr x9,[x20,#40]
 cbz x9,.Lfile_admission
 str x9,[sp,#376]
 ldr x10,[x9]
 cmp x10,x19
 b.ne .Lfile_admission
 ldr x10,[x9,#16]
 cmp x10,#7
 b.ne .Lfile_admission
 cmp x24,#16,lsl#12
 b.hi .Lfile_admission
 cbz x24,.Lfile_valid
 cbz x22,.Lfile_admission
 cbz x23,.Lfile_admission
 cbz x25,.Lfile_admission
 cbz x26,.Lfile_admission
 cmp x26,#256
 b.hi .Lfile_admission
 adds x9,x25,x26
 b.cs .Lfile_admission
 tst x23,#7
 b.ne .Lfile_admission
 tst x22,#3
 b.ne .Lfile_admission
 ldr w9,[x21]
 cmp w9,#1
 b.hi .Lfile_admission
 ldr w10,[x21,#8]
 cmp w10,#1
 b.hi .Lfile_admission
 ldr w10,[x21,#20]
 cmp w10,#8
 b.eq .Lfile_stride_ready
 cmp w10,#12
 b.eq .Lfile_stride_ready
 cmp w10,#16
 b.ne .Lfile_admission
.Lfile_stride_ready:
 cbz w9,.Lfile_grid_stride
 cmp w10,#16
 b.ne .Lfile_admission
 b .Lfile_count_bounds
.Lfile_grid_stride:
 cmp w10,#16
 b.eq .Lfile_admission
.Lfile_count_bounds:
 umull x11,w10,w24
 adds x11,x22,x11
 b.cs .Lfile_admission
 ldp x10,x11,[x21,#24]
 cbz x10,.Lfile_admission
 cbz x11,.Lfile_admission
 movz x12,#0xffff
 movk x12,#0x7fff,lsl#16
 cmp x10,x12
 b.hi .Lfile_admission
 cmp x11,x12
 b.hi .Lfile_admission
 mul x12,x10,x24
 lsr x13,x12,#61
 cbnz x13,.Lfile_admission
 adds x12,x23,x12,lsl#3
 b.cs .Lfile_admission
 ldr x10,[x21,#56]
 cbnz x10,.Lfile_admission
.Lfile_valid:
 mov w27,#0
.Lfile_admission:
 mov w0,w27
 FILE_CALL .Lfile_agreement
 cbnz w0,.Lfile_return_status
 cbz x24,.Lfile_return_status
 /* Keep one reduced context for the entire root field lifetime. */
 mov x9,#0
.Lfile_context_copy:
 ldr x10,[x20,x9]
 add x11,sp,#384
 str x10,[x11,x9]
 add x9,x9,#8
 cmp x9,#128
 b.lo .Lfile_context_copy
 ldr x9,[sp,#376]
 ldr w9,[x9,#28]
 cmp w9,#1
 b.ne .Lfile_root_prepared
 ldr x10,[x21,#32]
 lsl x10,x10,#3
 ldr x11,[x20,#96]
 cmp x10,x11
 b.hi .Lfile_root_unsupported
 sub x11,x11,x10
 str x11,[sp,#480]
 mov x0,x10
 FILE_CALL malloc
 cbz x0,.Lfile_root_allocation_failed
 str x0,[sp,#136]
 /* The path buffer is4096 bytes including its final NUL. */
 mov x9,x26
.Lfile_trim_name:
 cbz x9,.Lfile_root_unsupported
 sub x10,x9,#1
 ldrb w11,[x25,x10]
 cmp w11,#32
 b.ne .Lfile_name_length
 mov x9,x10
 b .Lfile_trim_name
.Lfile_name_length:
 str x9,[sp,#4640]
 add x11,sp,#512
 mov x12,#0
 ldrb w10,[x25]
 cmp w10,#47
 b.eq .Lfile_name_copy_start
 ldr x13,[x20,#104]
 ldr x14,[x20,#112]
 cbz x14,.Lfile_name_copy_start
 cbz x13,.Lfile_root_unsupported
 cmp x14,#3839
 b.hi .Lfile_root_unsupported
.Lfile_directory_copy:
 ldrb w10,[x13,x12]
 cbz w10,.Lfile_root_unsupported
 strb w10,[x11,x12]
 add x12,x12,#1
 cmp x12,x14
 b.lo .Lfile_directory_copy
 sub x10,x12,#1
 ldrb w10,[x11,x10]
 cmp w10,#47
 b.eq .Lfile_name_copy_start
 mov w10,#47
 strb w10,[x11,x12]
 add x12,x12,#1
.Lfile_name_copy_start:
 ldr x14,[sp,#4640]
 add x15,x12,x14
 cmp x15,#4095
 b.hi .Lfile_root_unsupported
 mov x13,#0
.Lfile_name_copy:
 ldrb w10,[x25,x13]
 cbz w10,.Lfile_root_unsupported
 strb w10,[x11,x12]
 add x12,x12,#1
 add x13,x13,#1
 cmp x13,x14
 b.lo .Lfile_name_copy
 strb wzr,[x11,x12]
 add x0,sp,#512
 mov w1,#577
 ldr w9,[x21,#8]
 cbz w9,.Lfile_open
 mov w1,#1089
.Lfile_open:
 mov w2,#420
 FILE_CALL open
 tbnz w0,#31,.Lfile_root_service_failed
 sxtw x0,w0
 str x0,[sp,#128]
.Lfile_root_prepared:
 mov w0,#0
 b .Lfile_open_agree
.Lfile_root_unsupported:
 mov w0,#2
 b .Lfile_open_agree
.Lfile_root_allocation_failed:
 mov w0,#1
 b .Lfile_open_agree
.Lfile_root_service_failed:
 mov w0,#3
.Lfile_open_agree:
 FILE_CALL .Lfile_agreement
 cbnz w0,.Lfile_cleanup_status
 mov x27,#0
 mov x28,#0
.Lfile_field:
 ldr w9,[x21,#20]
 madd x9,x27,x9,x22
 str x9,[sp,#4632]
 ldr w10,[x21]
 ldr w11,[x21,#16]
 mov w12,#1
 stp w10,w12,[sp,#208]
 stp w11,w12,[sp,#216]
 mov x4,xzr
 cbz w10,.Lfile_local_field
 ldr w11,[x9,#8]
 str w11,[sp,#212]
 ldr x12,[sp,#376]
 ldr w12,[x12,#68]
 cmp w11,w12
 b.ne .Lfile_gather
.Lfile_local_field:
 ldr x9,[x21,#24]
 mul x9,x9,x28
 add x4,x23,x9,lsl#3
 add x28,x28,#1
.Lfile_gather:
 mov x0,x19
 ldr x1,[sp,#376]
 add x2,x21,#12
 add x3,sp,#208
 ldr x5,[x21,#24]
 mov x6,#4616
 add x6,sp,x6
 ldr x9,[sp,#136]
 cmp x9,#0
 csel x6,x9,x6,ne
 ldr x7,[x21,#32]
 FILE_CALL md2asm_gather_runtime_output_field
 cbnz w0,.Lfile_cleanup_status
 ldr x9,[sp,#376]
 ldr w9,[x9,#28]
 cmp w9,#1
 b.ne .Lfile_field_complete
 /* Original model-level routes always select the model-level samples. */
 ldr w9,[x21,#4]
 cmp w9,#109
 b.ne .Lfile_nonmodel_template
 ldr w9,[x21]
 mov w10,#3
 cmp w9,#0
 mov w9,#1
 csel w9,w10,w9,eq
 b .Lfile_template_kind
.Lfile_nonmodel_template:
 ldr x10,[sp,#4632]
 ldp w0,w1,[x10]
 FILE_CALL md2asm_runtime_grib_edition
 ldr w9,[x21]
 cbz w9,.Lfile_grid_template
 cmp w0,#1
 b.ne .Lfile_root_service_failed_field
 mov w9,#0
 b .Lfile_template_kind
.Lfile_grid_template:
 cmp w0,#1
 mov w9,#2
 mov w10,#4
 csel w9,w9,w10,eq
.Lfile_template_kind:
 str w9,[sp,#368]
 add x10,sp,#144
 ldr x11,[x10,x9,lsl#3]
 cbnz x11,.Lfile_template_ready
 mov x0,x19
 add x1,sp,#384
 mov w2,w9
 add x3,x10,x9,lsl#3
 FILE_CALL md2asm_create_runtime_grib_template
 cbnz w0,.Lfile_root_service_failed_field
 ldr w9,[sp,#368]
 add x10,sp,#144
 ldr x11,[x10,x9,lsl#3]
 cbz x11,.Lfile_root_service_failed_field
.Lfile_template_ready:
 add x10,sp,#224
 str x11,[x10]
 ldr x9,[sp,#4632]
 ldrsw x11,[x9]
 ldrsw x12,[x9,#4]
 stp x11,x12,[x10,#8]
 ldr w11,[x21]
 ldr w12,[x21,#4]
 stp x11,x12,[x10,#24]
 ldr x11,[x21,#40]
 ldr x12,[x21,#32]
 stp x11,x12,[x10,#40]
 ldrsw x11,[x21,#16]
 ldr x12,[x21,#48]
 stp x11,x12,[x10,#56]
 adrp x11,:got:md2asm_owned_runtime_grib_writer_state64
 ldr x11,[x11,:got_lo12:md2asm_owned_runtime_grib_writer_state64]
 add x11,x11,#16
 add x12,sp,#384
 stp x11,x12,[x10,#72]
 adrp x11,:got:md2asm_owned_grib_soil_levels
 ldr x11,[x11,:got_lo12:md2asm_owned_grib_soil_levels]
 str x11,[x10,#88]
 stp xzr,xzr,[x10,#96]
 stp xzr,xzr,[x10,#112]
 stp xzr,xzr,[sp,#184]
 str xzr,[sp,#200]
 mov x0,x10
 ldr x1,[sp,#136]
 add x2,sp,#184
 add x3,sp,#192
 add x4,sp,#200
 FILE_CALL md2asm_encode_runtime_grib_field
 cbnz w0,.Lfile_root_service_failed_field
 ldr x9,[sp,#192]
 cbz x9,.Lfile_release_clone
 ldr x10,[sp,#184]
 cbz x10,.Lfile_root_service_failed_field
 adds x11,x10,x9
 b.cs .Lfile_root_service_failed_field
 ldr x0,[sp,#128]
 mov x1,x10
 mov x2,x9
 FILE_CALL .Lfile_write_all
 cbnz w0,.Lfile_root_service_failed_field
 ldr x9,[sp,#192]
 neg x2,x9
 and x2,x2,#3
 cbz x2,.Lfile_release_clone
 mov w9,#0x2020
 movk w9,#0x2020,lsl#16
 str w9,[sp,#4608]
 ldr x0,[sp,#128]
 mov x1,#4608
 add x1,sp,x1
 FILE_CALL .Lfile_write_all
 cbnz w0,.Lfile_root_service_failed_field
.Lfile_release_clone:
 ldr x0,[sp,#200]
 cbz x0,.Lfile_field_complete
 FILE_CALL codes_handle_delete
 str xzr,[sp,#200]
 cbnz w0,.Lfile_root_service_failed_field
.Lfile_field_complete:
 mov w0,#0
 b .Lfile_field_agree
.Lfile_root_service_failed_field:
 mov w0,#3
.Lfile_field_agree:
 FILE_CALL .Lfile_agreement
 cbnz w0,.Lfile_cleanup_status
 add x27,x27,#1
 cmp x27,x24
 b.lo .Lfile_field
 mov w0,#0
.Lfile_cleanup_status:
 str w0,[sp,#352]
 ldr x0,[sp,#200]
 cbz x0,.Lfile_cleanup_templates
 FILE_CALL codes_handle_delete
 str xzr,[sp,#200]
 FILE_CALL .Lfile_record_cleanup_status
.Lfile_cleanup_templates:
 mov x27,#0
.Lfile_template_cleanup:
 add x9,sp,#144
 ldr x0,[x9,x27,lsl#3]
 cbz x0,.Lfile_template_cleanup_next
 FILE_CALL codes_handle_delete
 add x9,sp,#144
 str xzr,[x9,x27,lsl#3]
 FILE_CALL .Lfile_record_cleanup_status
.Lfile_template_cleanup_next:
 add x27,x27,#1
 cmp x27,#5
 b.lo .Lfile_template_cleanup
 ldr x0,[sp,#128]
 tbnz x0,#63,.Lfile_cleanup_owner
 FILE_CALL close
 str xzr,[sp,#128]
 cbz w0,.Lfile_cleanup_owner
 ldr w9,[sp,#352]
 cbnz w9,.Lfile_cleanup_owner
 mov w9,#3
 str w9,[sp,#352]
.Lfile_cleanup_owner:
 ldr x0,[sp,#136]
 cbz x0,.Lfile_cleanup_agree
 FILE_CALL free
.Lfile_cleanup_agree:
 ldr w0,[sp,#352]
 FILE_CALL .Lfile_agreement
.Lfile_return_status:
 ldr x18,[sp,#112]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#16]
 mov x9,#4864
 add sp,sp,x9
 ret
.size md2asm_write_runtime_gathered_fields,.-md2asm_write_runtime_gathered_fields
/* Keep an earlier error and report a cleanup service error after success. */
.Lfile_record_cleanup_status:
 cbz w0,.Lfile_cleanup_status_return
 ldr w9,[sp,#352]
 cbnz w9,.Lfile_cleanup_status_return
 mov w9,#3
 str w9,[sp,#352]
.Lfile_cleanup_status_return:
 ret

/* Public writes can be short or interrupted before transferring any byte. */
.p2align 2
.Lfile_write_all:
 stp x29,x30,[sp,#-64]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x19,x0
 mov x20,x1
 mov x21,x2
.Lfile_write_next:
 cbz x21,.Lfile_write_ok
 mov x0,x19
 mov x1,x20
 mov x2,x21
 bl write
 cmp x0,#0
 b.gt .Lfile_write_progress
 b.eq .Lfile_write_failed
 bl __errno_location
 ldr w9,[x0]
 cmp w9,#4
 b.eq .Lfile_write_next
 b .Lfile_write_failed
.Lfile_write_progress:
 cmp x0,x21
 b.hi .Lfile_write_failed
 add x20,x20,x0
 sub x21,x21,x0
 b .Lfile_write_next
.Lfile_write_ok:
 mov w0,#0
 b .Lfile_write_return
.Lfile_write_failed:
 mov w0,#3
.Lfile_write_return:
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#64
 ret

.p2align 2
.Lfile_agreement:
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

.section .note.GNU-stack,"",%progbits

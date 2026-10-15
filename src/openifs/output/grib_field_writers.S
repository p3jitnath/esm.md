/* Original WROUTSPGB/WROUTGPGB interfaces, direct encoding and file writing.
 * Contract: skills/md2asm/references/openifs/output/grib_field_writers.md. Selected regular T21 output route.
 * Numerical children are admitted direct FITSPECTRUM and positive-normal LOG.
 */
.arch armv8.2-a
.macro writer_save
 sub sp,sp,#320
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
.endm
.macro writer_scalar destination,symbol
 adrp x17,:got:\symbol
 ldr x17,[x17,:got_lo12:\symbol]
 ldr \destination,[x17]
.endm
.macro writer_zero symbol
 writer_scalar w9,\symbol
 cbnz w9,.Lwriter_reject
.endm
.text
.p2align 4
.global wroutspgb_
.type wroutspgb_,%function
wroutspgb_:
 writer_save
 mrs x9,fpcr
 cbnz x9,.Lwriter_reject
 cbz x0,.Lwriter_reject
 cbz x1,.Lwriter_reject
 cbz x2,.Lwriter_reject
 cbz x3,.Lwriter_reject
 cbz x4,.Lwriter_reject
 cbz x5,.Lwriter_reject
 cbz x6,.Lwriter_reject
 cbz x7,.Lwriter_reject
 mov x9,#4872
 sub x19,x0,x9
 mov x20,x1
 ldrsw x21,[x2]
 mov x22,x3
 ldrb w23,[x4]
 mov x25,x6
 mov x26,#210
 mov x27,#0
 mov x28,#16
 str xzr,[sp,#112]
 ldr x9,[sp,#320]
 cmp x9,#1
 b.ne .Lwriter_reject
 ldr x9,[sp,#328]
 cmp x9,#210
 b.lo .Lwriter_reject
 ldr x9,[x7]
 movz x10,#0x2000,lsl#32
 movk x10,#0x40ac,lsl#48
 cmp x9,x10
 b.ne .Lwriter_reject
 sub x9,x21,#1
 cmp x9,#24
 b.hi .Lwriter_reject
 cmp w23,#109
 b.eq .Lwriter_spectral_model
 cmp w23,#112
 b.ne .Lwriter_reject
 mov x23,#0
 b .Lwriter_spectral_descriptor
.Lwriter_spectral_model:
 mov x23,#1
.Lwriter_spectral_descriptor:
 ldr x9,[x20]
 cbz x9,.Lwriter_reject
 ldr x10,[x20,#8]
 mov x11,#-507
 cmp x10,x11
 b.ne .Lwriter_reject
 ldr x10,[x20,#16]
 cmp x10,#8
 b.ne .Lwriter_reject
 ldr w10,[x20,#24]
 cbnz w10,.Lwriter_reject
 ldrb w10,[x20,#28]
 cmp w10,#2
 b.ne .Lwriter_reject
 ldrb w10,[x20,#29]
 cmp w10,#3
 b.ne .Lwriter_reject
 ldrh w10,[x20,#30]
 cbnz w10,.Lwriter_reject
 ldr x10,[x20,#32]
 cmp x10,#8
 b.ne .Lwriter_reject
 ldr x10,[x20,#40]
 cmp x10,#1
 b.ne .Lwriter_reject
 ldr x10,[x20,#48]
 cmp x10,#1
 b.ne .Lwriter_reject
 ldr x10,[x20,#56]
 cmp x10,#506
 b.ne .Lwriter_reject
 ldr x10,[x20,#64]
 cmp x10,#506
 b.ne .Lwriter_reject
 ldr x10,[x20,#72]
 cmp x10,#1
 b.ne .Lwriter_reject
 ldr x10,[x20,#80]
 cmp x10,x21
 b.ne .Lwriter_reject
 tst x9,#7
 b.ne .Lwriter_reject
 mov x20,x9
 mov x24,#506
 mov x0,x19
 bl .Lprepare_output_context
 cbnz w0,.Lwriter_reject
 b .Lwriter_common
.size wroutspgb_,.-wroutspgb_
.global md2asm_wroutspgb_direct
.set md2asm_wroutspgb_direct,wroutspgb_
.p2align 4
.global wroutgpgb_
.type wroutgpgb_,%function
wroutgpgb_:
 writer_save
 mrs x9,fpcr
 cbnz x9,.Lwriter_reject
 cbz x0,.Lwriter_reject
 cbz x1,.Lwriter_reject
 cbz x2,.Lwriter_reject
 cbz x3,.Lwriter_reject
 cbz x4,.Lwriter_reject
 cbz x5,.Lwriter_reject
 cbz x6,.Lwriter_reject
 cbz x7,.Lwriter_reject
 mov x20,x0
 tst x20,#7
 b.ne .Lwriter_reject
 ldr w9,[x1]
 cmp w9,#2048
 b.ne .Lwriter_reject
 ldrsw x21,[x2]
 sub x9,x21,#1
 cmp x9,#18
 b.hi .Lwriter_reject
 mov x22,x3
 ldrb w9,[x4]
 cmp w9,#109
 b.ne .Lwriter_reject
 mov x23,#1
 ldrb w9,[x5]
 mov x27,#0
 cmp w9,#97
 b.eq .Lwriter_grid_mode
 cmp w9,#119
 b.ne .Lwriter_reject
 mov x27,#1
.Lwriter_grid_mode:
 mov x25,x7
 ldr x9,[sp,#328]
 cmp x9,#1
 b.ne .Lwriter_reject
 ldr x9,[sp,#336]
 cmp x9,#1
 b.ne .Lwriter_reject
 ldr x26,[sp,#344]
 cbz x26,.Lwriter_reject
 cmp x26,#256
 b.hi .Lwriter_reject
 ldr x9,[sp,#320]
 cbz x9,.Lwriter_reject
 ldr x9,[x9]
 movz x10,#0x2000,lsl#32
 movk x10,#0x40ac,lsl#48
 cmp x9,x10
 b.ne .Lwriter_reject
 adrp x9,.Lcontext_ready
 ldr x9,[x9,:lo12:.Lcontext_ready]
 cmp x9,#1
 b.ne .Lwriter_reject
 mov x24,#2048
 mov x28,#8
 mov x9,#1
 str x9,[sp,#112]
.Lwriter_common:
 writer_scalar w9,__yommp0_MOD_nproc
 cmp w9,#1
 b.ne .Lwriter_reject
 writer_scalar w9,__yommp0_MOD_nouttype
 cmp w9,#2
 b.eq .Lwriter_reject
 writer_scalar w9,__yomct0_MOD_nconf
 cmp w9,#1
 b.ne .Lwriter_reject
 writer_scalar w9,__yomct0_MOD_lecmwf
 cmp w9,#1
 b.ne .Lwriter_reject
 writer_zero __yomct0_MOD_l_oops
 writer_zero __yomvar_MOD_ltwgra
 writer_zero __yomvar_MOD_ltwinc
 writer_zero __yomvar_MOD_ltwbgv
 writer_zero __yomvar_MOD_ltwcgl
 writer_zero __yomdyncore_MOD_lppsteps
 writer_zero __yomvareps_MOD_lvareps
 writer_scalar w9,__yomct3_MOD_nstep
 cmp w9,#24
 b.hi .Lwriter_reject
 mov x10,#3600
 mul x9,x9,x10
 str x9,[sp,#128]
 mov x0,x25
 mov x1,x26
 mov x2,x27
 bl md2asm_open_grib_output
 tbnz w0,#31,.Lwriter_reject
 sxtw x9,w0
 str x9,[sp,#248]
 str xzr,[sp,#136]
.Lwriter_field:
 ldr x9,[sp,#112]
 mov x10,#0
 cbz x9,.Lwriter_select_template
 mov x10,#2
 b .Lwriter_have_template
.Lwriter_select_template:
 mov x10,x23
.Lwriter_have_template:
 adrp x9,.Ltemplate_handles
 add x9,x9,:lo12:.Ltemplate_handles
 ldr x9,[x9,x10,lsl#3]
 str x9,[sp,#160]
 ldrsw x9,[x22]
 str x9,[sp,#168]
 ldrsw x9,[x22,#4]
 str x9,[sp,#176]
 mov x9,#0
 ldr x10,[sp,#112]
 cbnz x10,.Lwriter_grid_spec
 ldr w9,[x22,#8]
 cmp w9,#1
 b.ne .Lwriter_reject
 mov x9,#1
.Lwriter_grid_spec:
 str x9,[sp,#184]
 str x23,[sp,#192]
 ldr x9,[sp,#128]
 str x9,[sp,#200]
 str x24,[sp,#208]
 writer_scalar w9,__fitspectrum_mod_MOD_lforcelnsp
 uxtw x9,w9
 str x9,[sp,#216]
 add x0,sp,#160
 mov x1,x20
 add x2,sp,#224
 add x3,sp,#232
 add x4,sp,#240
 bl md2asm_encode_grib_field
 cbnz w0,.Lwriter_reject
 ldr x0,[sp,#248]
 ldr x1,[sp,#224]
 ldr x2,[sp,#232]
 bl md2asm_write_grib_record
 cbnz w0,.Lwriter_reject
 adrp x9,.Lwriter_record_count
 add x9,x9,:lo12:.Lwriter_record_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x10,[sp,#112]
 adrp x9,.Lwriter_record_kind_counts
 add x9,x9,:lo12:.Lwriter_record_kind_counts
 ldr x11,[x9,x10,lsl#3]
 add x11,x11,#1
 str x11,[x9,x10,lsl#3]
 cbnz x10,.Lwriter_counted_special
 ldr x9,[sp,#168]
 cmp x9,#152
 b.ne .Lwriter_counted_special
 ldr x9,[sp,#192]
 cmp x9,#1
 b.ne .Lwriter_counted_special
 ldr x9,[sp,#216]
 cmp x9,#1
 b.ne .Lwriter_counted_special
 adrp x9,.Lwriter_forced_count
 add x9,x9,:lo12:.Lwriter_forced_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
.Lwriter_counted_special:
 adrp x9,.Lwriter_byte_count
 add x9,x9,:lo12:.Lwriter_byte_count
 ldr x10,[x9]
 ldr x11,[sp,#232]
 add x11,x11,#3
 and x11,x11,#-4
 add x10,x10,x11
 str x10,[x9]
 ldr x0,[sp,#240]
 bl codes_handle_delete
 cbnz w0,.Lwriter_reject
 add x20,x20,x24,lsl#3
 add x22,x22,x28
 ldr x9,[sp,#136]
 add x9,x9,#1
 str x9,[sp,#136]
 cmp x9,x21
 b.ne .Lwriter_field
 ldr x0,[sp,#248]
 bl md2asm_close_grib_output
 cbnz w0,.Lwriter_reject
 adrp x9,.Lwriter_call_counts
 add x9,x9,:lo12:.Lwriter_call_counts
 ldr x10,[sp,#112]
 ldr x11,[x9,x10,lsl#3]
 add x11,x11,#1
 str x11,[x9,x10,lsl#3]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#320
 ret
.size wroutgpgb_,.-wroutgpgb_
.global md2asm_wroutgpgb_direct
.set md2asm_wroutgpgb_direct,wroutgpgb_
.Lwriter_reject:
 mov x0,#116
 mov x8,#93
 svc #0
 brk #0
/* x0 Geometry, one persistent output context per selected forecast process. */
.Lprepare_output_context:
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x19,x0
 adrp x9,.Lcontext_ready
 ldr x9,[x9,:lo12:.Lcontext_ready]
 cbz x9,.Lprepare_new_context
 adrp x9,.Lgeometry_owner
 ldr x9,[x9,:lo12:.Lgeometry_owner]
 cmp x9,x19
 mov w0,#2
 csel w0,wzr,w0,eq
 b .Lprepare_context_return
.Lprepare_new_context:
 adrp x0,.Lsample_directory_environment
 add x0,x0,:lo12:.Lsample_directory_environment
 bl getenv
 cbz x0,.Lprepare_missing_directory
 mov x1,x0
 mov x0,#0
 bl codes_context_set_samples_path
 mov x0,x19
 adrp x1,.Lmetadata_record
 add x1,x1,:lo12:.Lmetadata_record
 bl md2asm_read_grib_output_metadata
 cbnz w0,.Lprepare_context_return
 mov x20,#0
.Lprepare_template:
 adrp x0,.Lmetadata_record
 add x0,x0,:lo12:.Lmetadata_record
 mov x1,x20
 adrp x2,.Ltemplate_handles
 add x2,x2,:lo12:.Ltemplate_handles
 add x2,x2,x20,lsl#3
 bl md2asm_initialize_grib_template
 cbnz w0,.Lprepare_context_return
 add x20,x20,#1
 cmp x20,#3
 b.ne .Lprepare_template
 adrp x9,.Lgeometry_owner
 str x19,[x9,:lo12:.Lgeometry_owner]
 adrp x9,.Lcontext_ready
 mov x10,#1
 str x10,[x9,:lo12:.Lcontext_ready]
 mov w0,#0
 b .Lprepare_context_return_from_success
.Lprepare_missing_directory:
 mov w0,#2
.Lprepare_context_return_from_success:
.Lprepare_context_return:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.macro writer_getter name,label,offset=0
 .global \name
 .type \name,%function
\name:
 adrp x0,\label
 add x0,x0,:lo12:\label
 ldr x0,[x0,#\offset]
 ret
 .size \name,.-\name
.endm
writer_getter md2asm_wroutspgb_count_get,.Lwriter_call_counts,0
writer_getter md2asm_wroutgpgb_count_get,.Lwriter_call_counts,8
writer_getter md2asm_grib_output_record_count_get,.Lwriter_record_count
writer_getter md2asm_grib_output_byte_count_get,.Lwriter_byte_count
writer_getter md2asm_grib_spectral_record_count_get,.Lwriter_record_kind_counts,0
writer_getter md2asm_grib_grid_record_count_get,.Lwriter_record_kind_counts,8
writer_getter md2asm_grib_forced_record_count_get,.Lwriter_forced_count
.global md2asm_grib_fitted_record_count_get
.type md2asm_grib_fitted_record_count_get,%function
md2asm_grib_fitted_record_count_get:
 adrp x0,.Lwriter_record_kind_counts
 ldr x0,[x0,:lo12:.Lwriter_record_kind_counts]
 adrp x1,.Lwriter_forced_count
 ldr x1,[x1,:lo12:.Lwriter_forced_count]
 sub x0,x0,x1
 ret
.size md2asm_grib_fitted_record_count_get,.-md2asm_grib_fitted_record_count_get
.section .rodata
.Lsample_directory_environment: .asciz "MD2ASM_GRIB_SAMPLES_PATH"
.bss
.p2align 3
.Lcontext_ready: .zero 8
.Lgeometry_owner: .zero 8
.Ltemplate_handles: .zero 24
.Lmetadata_record: .zero 512
.Lwriter_call_counts: .zero 16
.Lwriter_record_count: .zero 8
.Lwriter_byte_count: .zero 8
.Lwriter_record_kind_counts: .zero 16
.Lwriter_forced_count: .zero 8
.section .note.GNU-stack,"",%progbits

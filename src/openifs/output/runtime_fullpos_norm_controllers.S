/* Fullpos norm controllers retain source arithmetic and owned result lifetimes.
 * The numerical leaves retain original field and point order. */
.arch armv8.2-a
.text
.p2align 4
.equ NC_COOKIE,0x46504e4f524d3031
.macro NC64 reg,value
 movz \reg,#(\value&65535)
 movk \reg,#((\value>>16)&65535),lsl#16
 movk \reg,#((\value>>32)&65535),lsl#32
 movk \reg,#((\value>>48)&65535),lsl#48
.endm
.macro NCCALL target
 str x18,[sp,#736]
 bl \target
 ldr x18,[sp,#736]
.endm
.macro NCSAVE
 sub sp,sp,#1536
 stp x0,x1,[sp,#64]
 stp x2,x3,[sp,#80]
 stp x4,x5,[sp,#96]
 stp x6,x7,[sp,#112]
 add x16,sp,#640
 stp x19,x20,[x16,#0]
 stp x21,x22,[x16,#16]
 stp x23,x24,[x16,#32]
 stp x25,x26,[x16,#48]
 stp x27,x28,[x16,#64]
 stp x29,x30,[x16,#80]
 str x18,[sp,#736]
 mov x29,sp
 str xzr,[sp,#1040]
 str xzr,[sp,#1080]
.endm
.macro NCRETURN
 add x16,sp,#640
 ldp x19,x20,[x16,#0]
 ldp x21,x22,[x16,#16]
 ldp x23,x24,[x16,#32]
 ldp x25,x26,[x16,#48]
 ldp x27,x28,[x16,#64]
 ldp x29,x30,[x16,#80]
 ldr x18,[sp,#736]
 add sp,sp,#1536
 ret
.endm
.macro NCOWNER reg
 adrp \reg,:got:md2asm_runtime_fullpos_norm_results
 ldr \reg,[\reg,:got_lo12:md2asm_runtime_fullpos_norm_results]
.endm
/* Validate a dense one-dimensional GNU descriptor.
 * x1 expected count, or minus one to derive a positive count.
 * x2 kind and x3 element bytes. Return x5 data and x6 count. */
.Lnc_vector:
 cbz x0,.Lnc_vector_bad
 tst x0,#7
 b.ne .Lnc_vector_bad
 adds x9,x0,#64
 b.cs .Lnc_vector_bad
 ldr x9,[x0,#8]
 cmn x9,#1
 b.ne .Lnc_vector_bad
 ldr x9,[x0,#16]
 cmp x9,x3
 b.ne .Lnc_vector_bad
 lsl x9,x2,#8
 add x9,x9,#1
 lsl x9,x9,#32
 ldr x10,[x0,#24]
 cmp x9,x10
 b.ne .Lnc_vector_bad
 ldr x9,[x0,#32]
 cmp x9,x3
 b.ne .Lnc_vector_bad
 ldp x9,x10,[x0,#40]
 cmp x9,#1
 b.ne .Lnc_vector_bad
 cmp x10,#1
 b.ne .Lnc_vector_bad
 ldr x6,[x0,#56]
 cmp x6,#1
 b.lt .Lnc_vector_bad
 mov x9,#65536
 cmp x6,x9
 b.hi .Lnc_vector_bad
 cmn x1,#1
 b.eq .Lnc_vector_count
 cmp x6,x1
 b.ne .Lnc_vector_bad
.Lnc_vector_count:
 ldr x5,[x0]
 cbz x5,.Lnc_vector_bad
 cmp x2,#6
 b.eq .Lnc_vector_address
 sub x9,x3,#1
 tst x5,x9
 b.ne .Lnc_vector_bad
.Lnc_vector_address:
 mul x9,x6,x3
 adds x9,x5,x9
 b.cs .Lnc_vector_bad
 mov w0,#0
 ret
.Lnc_vector_bad:
 mov w0,#2
 ret
/* Bind only public MPI owners and actual source records.
 * Scratch has part8, Geometry16, budget24, comm32, rank0at36, world40. */
.Lnc_bind:
 sub sp,sp,#96
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x29,x30,[sp,#48]
 str x18,[sp,#64]
 mov x19,x0
 mov x20,x1
 adrp x9,:got:__mpl_data_module_MOD_mpl_comm
 ldr x9,[x9,:got_lo12:__mpl_data_module_MOD_mpl_comm]
 ldr w21,[x9]
 str w21,[x20,#32]
 mov w0,w21
 add x1,x20,#36
 bl MPI_Comm_rank
 cbnz w0,.Lnc_bind_mpi
 ldr x18,[sp,#64]
 mov w0,w21
 add x1,x20,#40
 bl MPI_Comm_size
 cbnz w0,.Lnc_bind_mpi
 ldr x18,[sp,#64]
 cbz x19,.Lnc_bind_bad
 tst x19,#7
 b.ne .Lnc_bind_bad
 adds x9,x19,#128
 b.cs .Lnc_bind_bad
 mrs x9,fpcr
 cbnz x9,.Lnc_bind_bad
 ldr x9,[x19,#80]
 cbz x9,.Lnc_bind_bad
 tst x9,#3
 b.ne .Lnc_bind_bad
 ldr w9,[x9]
 cbnz w9,.Lnc_bind_bad
 ldr x22,[x19,#40]
 cbz x22,.Lnc_bind_bad
 tst x22,#7
 b.ne .Lnc_bind_bad
 adds x9,x22,#4096
 b.cs .Lnc_bind_bad
 str x22,[x20,#8]
 ldr x10,[x22]
 cbz x10,.Lnc_bind_bad
 tst x10,#7
 b.ne .Lnc_bind_bad
 str x10,[x20,#16]
 ldr w9,[x10,#5172]
 sub w9,w9,#1
 mov w10,#8190
 cmp w9,w10
 b.hi .Lnc_bind_bad
 ldr w9,[x22,#16]
 cmp w9,#7
 b.ne .Lnc_bind_bad
 ldr w9,[x20,#40]
 sub w10,w9,#1
 mov w11,#65535
 cmp w10,w11
 b.hi .Lnc_bind_bad
 ldr w10,[x22,#24]
 cmp w9,w10
 b.ne .Lnc_bind_bad
 ldr w10,[x20,#36]
 add w10,w10,#1
 ldr w11,[x22,#28]
 cmp w10,w11
 b.ne .Lnc_bind_bad
 ldp w10,w11,[x22,#32]
 cmp w10,#1
 b.lt .Lnc_bind_bad
 cmp w11,#1
 b.lt .Lnc_bind_bad
 umull x12,w10,w11
 cmp x12,x9
 b.ne .Lnc_bind_bad
 ldp w12,w13,[x22,#64]
 sub w12,w12,#1
 cmp w12,w10
 b.hs .Lnc_bind_bad
 sub w13,w13,#1
 cmp w13,w11
 b.hs .Lnc_bind_bad
 ldr x9,[x19,#48]
 cbz x9,.Lnc_bind_bad
 tst x9,#7
 b.ne .Lnc_bind_bad
 mov x10,#35872
 ldr w9,[x9,x10]
 cbnz w9,.Lnc_bind_bad
 ldr x9,[x19,#96]
 cbz x9,.Lnc_bind_bad
 mov x10,#0x1000000000
 cmp x9,x10
 b.hi .Lnc_bind_bad
 str x9,[x20,#24]
 adrp x9,:got:__mpl_data_module_MOD_mpl_ids
 ldr x9,[x9,:got_lo12:__mpl_data_module_MOD_mpl_ids]
 ldr x10,[x9]
 cbz x10,.Lnc_bind_bad
 tst x10,#3
 b.ne .Lnc_bind_bad
 ldr x11,[x9,#8]
 cmn x11,#1
 b.ne .Lnc_bind_bad
 ldr x11,[x9,#16]
 cmp x11,#4
 b.ne .Lnc_bind_bad
 ldr x11,[x9,#24]
 movz x12,#0x0101,lsl#32
 cmp x11,x12
 b.ne .Lnc_bind_bad
 ldr x11,[x9,#32]
 cmp x11,#4
 b.ne .Lnc_bind_bad
 ldp x11,x12,[x9,#40]
 cmp x11,#1
 b.ne .Lnc_bind_bad
 cmp x12,#1
 b.ne .Lnc_bind_bad
 ldr x11,[x9,#56]
 ldr w12,[x20,#40]
 cmp x11,x12
 b.ne .Lnc_bind_bad
 adds x9,x10,x12,lsl#2
 b.cs .Lnc_bind_bad
 mov x9,#0
.Lnc_bind_ids:
 ldr w11,[x10,x9,lsl#2]
 add w13,w9,#1
 cmp w11,w13
 b.ne .Lnc_bind_bad
 add x9,x9,#1
 cmp x9,x12
 b.lo .Lnc_bind_ids
 mov w0,#0
 b .Lnc_bind_return
.Lnc_bind_bad:
 mov w0,#2
.Lnc_bind_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp,#48]
 ldr x18,[sp,#64]
 add sp,sp,#96
 ret
.Lnc_bind_mpi:
 mov w0,w21
 mov w1,#3
 bl MPI_Abort
 brk #1
/* Common integer agreement does not reduce numerical values. */
.Lnc_agree:
 sub sp,sp,#48
 str w0,[sp]
 str w1,[sp,#8]
 stp x18,x30,[sp,#16]
 mov x0,sp
 add x1,sp,#4
 mov w2,#1
 movz w3,#0x0405
 movk w3,#0x4c00,lsl#16
 movz w4,#1
 movk w4,#0x5800,lsl#16
 ldr w5,[sp,#8]
 bl MPI_Allreduce
 cbnz w0,.Lnc_agree_mpi
 ldr w0,[sp,#4]
 ldp x18,x30,[sp,#16]
 add sp,sp,#48
 ret
.Lnc_agree_mpi:
 ldr w0,[sp,#8]
 mov w1,#3
 bl MPI_Abort
 brk #1
/* Check the unique result owner and return its retained byte total in x1. */
.Lnc_owner:
 NCOWNER x9
 ldr x10,[x9]
 cbnz x10,.Lnc_owner_ready
 mov x10,#0
.Lnc_owner_zero:
 ldr x11,[x9,x10]
 cbnz x11,.Lnc_owner_bad
 add x10,x10,#8
 cmp x10,#80
 b.lo .Lnc_owner_zero
 mov x1,#0
 mov w0,#0
 ret
.Lnc_owner_ready:
 NC64 x11,NC_COOKIE
 cmp x10,x11
 b.ne .Lnc_owner_bad
 ldr x10,[x9,#8]
 cmp x10,x0
 b.ne .Lnc_owner_bad
 ldr w10,[x9,#64]
 add w11,w1,#1
 cmp w10,w11
 b.ne .Lnc_owner_bad
 ldr w10,[x9,#68]
 cmp w10,w2
 b.ne .Lnc_owner_bad
 ldr x10,[x9,#32]
 mov x11,#65536
 cmp x10,x11
 b.hi .Lnc_owner_bad
 ldp x12,x13,[x9,#16]
 cbnz w1,.Lnc_owner_remote_spec
 cbz x10,.Lnc_owner_empty_spec
 cbz x12,.Lnc_owner_bad
 tst x12,#7
 b.ne .Lnc_owner_bad
 lsl x14,x10,#4
 cmp x13,x14
 b.ne .Lnc_owner_bad
 adds x14,x12,x13
 b.cs .Lnc_owner_bad
 b .Lnc_owner_grid
.Lnc_owner_empty_spec:
 cbnz x12,.Lnc_owner_bad
 cbnz x13,.Lnc_owner_bad
 b .Lnc_owner_grid
.Lnc_owner_remote_spec:
 cbnz x12,.Lnc_owner_bad
 cbnz x13,.Lnc_owner_bad
.Lnc_owner_grid:
 ldp w10,w11,[x9,#56]
 ldp x12,x14,[x9,#40]
 cbz w11,.Lnc_owner_empty_grid
 mov x15,#65536
 cmp x11,x15
 b.hi .Lnc_owner_bad
 cmp w10,#1
 b.ne .Lnc_owner_bad
 cbnz w1,.Lnc_owner_remote_grid
 cbz x12,.Lnc_owner_bad
 tst x12,#7
 b.ne .Lnc_owner_bad
 mov x15,#48
 mul x15,x11,x15
 cmp x14,x15
 b.ne .Lnc_owner_bad
 adds x15,x12,x14
 b.cs .Lnc_owner_bad
 b .Lnc_owner_total
.Lnc_owner_empty_grid:
 cbnz w10,.Lnc_owner_bad
.Lnc_owner_remote_grid:
 cbnz x12,.Lnc_owner_bad
 cbnz x14,.Lnc_owner_bad
.Lnc_owner_total:
 adds x1,x13,x14
 b.cs .Lnc_owner_bad
 mov w0,#0
 ret
.Lnc_owner_bad:
 mov w0,#2
 ret
/* Publish common source identity after complete result agreement. */
.Lnc_stamp:
 NC64 x9,NC_COOKIE
 str x9,[x0]
 ldr x9,[x1,#8]
 str x9,[x0,#8]
 ldp w9,w10,[x1,#36]
 add w9,w9,#1
 stp w9,w10,[x0,#64]
 ldr x9,[x0,#72]
 add x9,x9,#1
 str x9,[x0,#72]
 ret
/* The actual present-configuration source helper retains NINT and V scaling. */
.Lnc_level:
 ldr d0,[x0]
 ldrb w9,[x1]
 cmp w9,#'V'
 b.ne .Lnc_level_integer
 adrp x9,.Lnc_level_scale
 ldr d1,[x9,:lo12:.Lnc_level_scale]
 fmul d0,d0,d1
.Lnc_level_integer:
 fcvtas w0,d0
 ret

.global md2asm_runtime_fullpos_spectral_norms
.type md2asm_runtime_fullpos_spectral_norms,%function
md2asm_runtime_fullpos_spectral_norms:
 NCSAVE
 add x9,sp,#1536
 add x10,sp,#128
 mov x11,#5
.Lsn_args:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lsn_args
 ldr x19,[sp,#160]
 mov x0,x19
 add x1,sp,#768
 bl .Lnc_bind
 ldr w27,[sp,#800]
 cbnz w0,.Lsn_admission_agree
 NCOWNER x20
 ldr x22,[sp,#776]
 ldr w24,[sp,#804]
 ldr w25,[sp,#808]
 mov x0,x22
 mov w1,w24
 mov w2,w25
 bl .Lnc_owner
 cbnz w0,.Lsn_admission_agree
 str x1,[sp,#1104]
 ldr x0,[sp,#104]
 mov x1,#-1
 mov x2,#3
 mov x3,#8
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
 mov x21,x6
 str w21,[sp,#1056]
 ldr x9,[sp,#136]
 cmp x9,#8
 b.ne .Lsn_scope_bad
 ldr x9,[sp,#144]
 cmp x9,#12
 b.ne .Lsn_scope_bad
 /* Validate original equal-length arrays without reading display strings. */
 ldr x0,[sp,#88]
 mov x1,x21
 mov x2,#2
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
 str x5,[sp,#1120]
 ldr x0,[sp,#96]
 mov x1,x21
 mov x2,#6
 mov x3,#8
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
 ldr x0,[sp,#112]
 mov x1,x21
 mov x2,#6
 mov x3,#12
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
 ldr x0,[sp,#120]
 cbz x0,.Lsn_grib_ready
 mov x1,x21
 mov x2,#1
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
.Lsn_grib_ready:
 ldr x0,[sp,#80]
 mov x1,x21
 mov x2,#1
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
 mov x26,#0
 mov x10,#0
 ldr w11,[x22,#36]
 ldr w12,[x22,#68]
 ldr x13,[sp,#1120]
.Lsn_field_sets:
 ldr w9,[x5,x26,lsl#2]
 sub w14,w9,#1
 cmp w14,w11
 b.hs .Lsn_scope_bad
 cmp w9,w12
 cinc x10,x10,eq
 ldr w9,[x13,x26,lsl#2]
 cmp w9,#1
 b.hi .Lsn_scope_bad
 add x26,x26,#1
 cmp x26,x21
 b.lo .Lsn_field_sets
 str x10,[sp,#1112]
 ldr x9,[sp,#128]
 ldr x10,[sp,#152]
 cbz x9,.Lsn_no_configuration
 cmp x10,#1
 b.ne .Lsn_scope_bad
 ldrb w9,[x9]
 cmp w9,#'P'
 b.eq .Lsn_configuration_ready
 cmp w9,#'V'
 b.eq .Lsn_configuration_ready
 cmp w9,#'T'
 b.eq .Lsn_configuration_ready
 cmp w9,#'S'
 b.ne .Lsn_scope_bad
 b .Lsn_configuration_ready
.Lsn_no_configuration:
 cbnz x10,.Lsn_scope_bad
 mov x10,#0
.Lsn_all_surface:
 ldr w9,[x13,x10,lsl#2]
 cmp w9,#1
 b.ne .Lsn_scope_bad
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lsn_all_surface
.Lsn_configuration_ready:
 ldr x0,[sp,#64]
 mov x1,#1
 mov x2,#1
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lsn_admission_agree
 ldr w9,[x5]
 cmp w9,#1
 b.lt .Lsn_scope_bad
 str x5,[sp,#1128]
 /* Public SPECNORM receives the exact original dense local field matrix. */
 ldr x9,[sp,#72]
 cbz x9,.Lsn_scope_bad
 tst x9,#7
 b.ne .Lsn_scope_bad
 ldr x10,[x9,#16]
 cmp x10,#8
 b.ne .Lsn_scope_bad
 ldr x10,[x9,#24]
 movz x11,#0x0302,lsl#32
 cmp x10,x11
 b.ne .Lsn_scope_bad
 ldr x10,[x9,#32]
 cmp x10,#8
 b.ne .Lsn_scope_bad
 ldp x10,x11,[x9,#40]
 cmp x10,#1
 b.ne .Lsn_scope_bad
 cmp x11,#1
 b.ne .Lsn_scope_bad
 ldr x10,[x9,#56]
 ldr x11,[sp,#1112]
 cmp x10,x11
 b.ne .Lsn_scope_bad
 ldr x12,[x9,#72]
 cmp x12,#1
 b.ne .Lsn_scope_bad
 ldr x12,[x9,#80]
 ldr x13,[sp,#784]
 ldr w14,[x13,#5172]
 ldrsw x13,[x13,#5200]
 cmp x13,#0
 b.lt .Lsn_scope_bad
 add w14,w14,#1
 add w15,w14,#1
 umull x14,w14,w15
 cmp x13,x14
 b.hi .Lsn_scope_bad
 cmp x12,x13
 b.ne .Lsn_scope_bad
 mul x14,x10,x12
 cbz x14,.Lsn_empty_matrix
 ldr x15,[x9,#64]
 cmp x15,x10
 b.ne .Lsn_scope_bad
 sub x15,xzr,x10
 sub x15,x15,#1
 ldr x16,[x9,#8]
 cmp x15,x16
 b.ne .Lsn_scope_bad
 ldr x9,[x9]
 cbz x9,.Lsn_scope_bad
 tst x9,#7
 b.ne .Lsn_scope_bad
 lsl x14,x14,#3
 adds x14,x9,x14
 b.cs .Lsn_scope_bad
.Lsn_empty_matrix:
 lsl x23,x21,#4
 ldr x9,[sp,#1104]
 adds x9,x9,x23
 b.cs .Lsn_scope_bad
 add x9,x9,#1632
 ldr x10,[sp,#792]
 cmp x9,x10
 b.hi .Lsn_scope_bad
 mov w0,#0
 b .Lsn_admission_agree
.Lsn_scope_bad:
 mov w0,#2
.Lsn_admission_agree:
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lsn_return
 mov x0,x23
 NCCALL malloc
 str x0,[sp,#1040]
 cmp x0,#0
 cset w0,eq
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lsn_failed
 ldr x23,[sp,#1040]
 add x9,sp,#256
 str x23,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str x10,[x9,#32]
 movz x10,#0x0301,lsl#32
 str x10,[x9,#24]
 mov x10,#1
 stp x10,x10,[x9,#40]
 str x21,[x9,#56]
 str w10,[sp,#1140]
 ldr x0,[sp,#72]
 ldr x1,[sp,#80]
 add x2,sp,#1140
 ldr x3,[sp,#1128]
 mov x4,#0
 add x5,sp,#256
 NCCALL specnorm_
 cbnz w24,.Lsn_complete
 /* Source WHERE threshold precedes all field formatting conversions. */
 mov x26,#0
 adrp x9,.Lnc_epsilon
 ldr d1,[x9,:lo12:.Lnc_epsilon]
 add x10,x23,x21,lsl#3
.Lsn_adjust:
 ldr d0,[x23,x26,lsl#3]
 fcmp d0,d1
 b.mi .Lsn_zero
 b .Lsn_adjust_store
.Lsn_zero:
 fmov d0,xzr
.Lsn_adjust_store:
 str d0,[x10,x26,lsl#3]
 add x26,x26,#1
 cmp x26,x21
 b.lo .Lsn_adjust
 ldr x9,[sp,#104]
 ldr x28,[x9]
 ldr x25,[sp,#128]
 ldr x26,[sp,#1120]
 mov x24,#0
.Lsn_levels:
 ldr w9,[x26,x24,lsl#2]
 cbnz w9,.Lsn_level_done
 add x0,x28,x24,lsl#3
 mov x1,x25
 bl .Lnc_level
.Lsn_level_done:
 add x24,x24,#1
 cmp x24,x21
 b.lo .Lsn_levels
 mov w24,#0
.Lsn_complete:
 mov w0,#0
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lsn_failed
 ldr w24,[sp,#804]
 cbnz w24,.Lsn_remote_publish
 ldr x26,[x20,#16]
 str x23,[x20,#16]
 lsl x9,x21,#4
 str x9,[x20,#24]
 b .Lsn_shape_publish
.Lsn_remote_publish:
 mov x0,x23
 NCCALL free
 mov x26,#0
 str xzr,[x20,#16]
 str xzr,[x20,#24]
.Lsn_shape_publish:
 str x21,[x20,#32]
 mov x0,x20
 add x1,sp,#768
 bl .Lnc_stamp
 cbz x26,.Lsn_success
 mov x0,x26
 NCCALL free
.Lsn_success:
 mov w0,#0
 b .Lsn_return
.Lsn_failed:
 str w0,[sp,#1136]
 ldr x0,[sp,#1040]
 cbz x0,.Lsn_failed_code
 NCCALL free
.Lsn_failed_code:
 ldr w0,[sp,#1136]
.Lsn_return:
 NCRETURN
.size md2asm_runtime_fullpos_spectral_norms,.-md2asm_runtime_fullpos_spectral_norms

.text
/* Dense rank-two result descriptors retain original domain-first storage. */
.Lnc_matrix:
 str x1,[x0]
 mov x9,#-2
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x9,#0x0302,lsl#32
 str x9,[x0,#24]
 mov x9,#1
 stp x9,x9,[x0,#40]
 stp x9,x9,[x0,#56]
 str x9,[x0,#72]
 str x2,[x0,#80]
 ret

.global md2asm_runtime_fullpos_grid_norms
.type md2asm_runtime_fullpos_grid_norms,%function
md2asm_runtime_fullpos_grid_norms:
 NCSAVE
 add x9,sp,#1536
 add x10,sp,#128
 mov x11,#12
.Lgn_args:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lgn_args
 ldr x19,[sp,#216]
 mov x0,x19
 add x1,sp,#768
 bl .Lnc_bind
 ldr w27,[sp,#800]
 cbnz w0,.Lgn_admission_agree
 NCOWNER x20
 ldr x22,[sp,#776]
 ldr w24,[sp,#804]
 ldr w25,[sp,#808]
 mov x0,x22
 mov w1,w24
 mov w2,w25
 bl .Lnc_owner
 cbnz w0,.Lgn_admission_agree
 str x1,[sp,#1104]
 ldr x9,[sp,#184]
 cmp x9,#32
 b.ne .Lgn_bad
 ldr x9,[sp,#192]
 cmp x9,#8
 b.ne .Lgn_bad
 ldr x9,[sp,#200]
 cmp x9,#12
 b.ne .Lgn_bad
 ldr x9,[sp,#80]
 cbz x9,.Lgn_bad
 tst x9,#3
 b.ne .Lgn_bad
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgn_bad
 ldr x9,[sp,#88]
 cbz x9,.Lgn_bad
 /* LDSURF defines the common positive field extent. */
 ldr x0,[sp,#120]
 mov x1,#-1
 mov x2,#2
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lgn_admission_agree
 mov x21,x6
 str w21,[sp,#1056]
 str x5,[sp,#1120]
 mov x10,#0
 mov x11,#0
.Lgn_flags:
 ldr w9,[x5,x10,lsl#2]
 cmp w9,#1
 b.hi .Lgn_bad
 cmp w9,#0
 cinc x11,x11,eq
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lgn_flags
 str x11,[sp,#1168]
 ldr x0,[sp,#128]
 mov x1,x21
 mov x2,#6
 mov x3,#8
 bl .Lnc_vector
 cbnz w0,.Lgn_admission_agree
 ldr x0,[sp,#160]
 mov x1,x21
 mov x2,#6
 mov x3,#12
 bl .Lnc_vector
 cbnz w0,.Lgn_admission_agree
 ldr x0,[sp,#168]
 cbz x0,.Lgn_grib_ready
 mov x1,x21
 mov x2,#1
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lgn_admission_agree
.Lgn_grib_ready:
 ldr x0,[sp,#144]
 mov x1,x21
 mov x2,#1
 mov x3,#4
 bl .Lnc_vector
 cbnz w0,.Lgn_admission_agree
 mov x10,#0
.Lgn_domains:
 ldr w9,[x5,x10,lsl#2]
 cmp w9,#1
 b.ne .Lgn_bad
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lgn_domains
 ldr x9,[sp,#152]
 cbz x9,.Lgn_bad
 tst x9,#7
 b.ne .Lgn_bad
 ldr x10,[x9,#8]
 cmn x10,#2
 b.ne .Lgn_bad
 ldr x10,[x9,#16]
 cmp x10,#4
 b.ne .Lgn_bad
 ldr x10,[x9,#24]
 movz x11,#0x0102,lsl#32
 cmp x10,x11
 b.ne .Lgn_bad
 ldr x10,[x9,#32]
 cmp x10,#4
 b.ne .Lgn_bad
 ldp x10,x11,[x9,#40]
 cmp x10,#1
 b.ne .Lgn_bad
 cmp x11,#1
 b.ne .Lgn_bad
 ldp x10,x11,[x9,#56]
 cmp x10,#1
 b.ne .Lgn_bad
 cmp x11,#1
 b.ne .Lgn_bad
 ldp x10,x11,[x9,#72]
 cmp x10,#1
 b.ne .Lgn_bad
 cmp x11,x21
 b.ne .Lgn_bad
 ldr x9,[x9]
 cbz x9,.Lgn_bad
 tst x9,#3
 b.ne .Lgn_bad
 adds x10,x9,x21,lsl#2
 b.cs .Lgn_bad
 mov x10,#0
.Lgn_domain_pointers:
 ldr w11,[x9,x10,lsl#2]
 cmp w11,#1
 b.ne .Lgn_bad
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lgn_domain_pointers
 /* Levels remain unread on the all-surface optional route. */
 str xzr,[sp,#1128]
 ldr x0,[sp,#136]
 cbz x0,.Lgn_no_levels
 mov x1,x21
 mov x2,#3
 mov x3,#8
 bl .Lnc_vector
 cbnz w0,.Lgn_admission_agree
 str x5,[sp,#1128]
 b .Lgn_levels_ready
.Lgn_no_levels:
 ldr x9,[sp,#1168]
 cbnz x9,.Lgn_bad
.Lgn_levels_ready:
 ldr x9,[sp,#176]
 ldr x10,[sp,#208]
 cbz x9,.Lgn_no_configuration
 cmp x10,#1
 b.ne .Lgn_bad
 ldrb w9,[x9]
 cmp w9,#'P'
 b.eq .Lgn_configuration_ready
 cmp w9,#'V'
 b.eq .Lgn_configuration_ready
 cmp w9,#'T'
 b.eq .Lgn_configuration_ready
 cmp w9,#'S'
 b.ne .Lgn_bad
 b .Lgn_configuration_ready
.Lgn_no_configuration:
 cbnz x10,.Lgn_bad
 ldr x9,[sp,#1168]
 cbnz x9,.Lgn_bad
.Lgn_configuration_ready:
 ldr x9,[sp,#72]
 cbz x9,.Lgn_bad
 tst x9,#7
 b.ne .Lgn_bad
 adds x10,x9,#848
 b.cs .Lgn_bad
 ldp w10,w11,[x9]
 cmp w10,#1
 b.lt .Lgn_bad
 cmp w11,#0
 b.lt .Lgn_bad
 cmp w11,w10
 b.hi .Lgn_bad
 ldr w12,[x9,#8]
 cmp w12,w11
 b.lt .Lgn_bad
 cmp w12,w10
 b.hi .Lgn_bad
 ldr w12,[x9,#12]
 sub w13,w12,#1
 cmp w13,#1023
 b.hi .Lgn_bad
 ldr w14,[x9,#16]
 cmp w14,#0
 b.lt .Lgn_bad
 add x13,x11,x12
 sub x13,x13,#1
 udiv x13,x13,x12
 cmp x13,x14
 b.ne .Lgn_bad
 ldr x9,[sp,#104]
 cbz x9,.Lgn_bad
 tst x9,#3
 b.ne .Lgn_bad
 ldr w9,[x9]
 cmp w9,w10
 b.ne .Lgn_bad
 /* PGP has exact width, field and local-block extents. */
 ldr x9,[sp,#112]
 cbz x9,.Lgn_bad
 tst x9,#7
 b.ne .Lgn_bad
 ldr x10,[x9,#16]
 cmp x10,#8
 b.ne .Lgn_bad
 ldr x10,[x9,#24]
 movz x11,#0x0303,lsl#32
 cmp x10,x11
 b.ne .Lgn_bad
 ldr x10,[x9,#32]
 cmp x10,#8
 b.ne .Lgn_bad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lgn_bad
 ldr x10,[x9,#48]
 cmp x10,#1
 b.ne .Lgn_bad
 ldr x10,[x9,#56]
 cmp x10,x12
 b.ne .Lgn_bad
 ldr x10,[x9,#72]
 cmp x10,#1
 b.ne .Lgn_bad
 ldr x10,[x9,#80]
 cmp x10,x21
 b.ne .Lgn_bad
 ldr x10,[x9,#96]
 cmp x10,#1
 b.ne .Lgn_bad
 ldr x10,[x9,#104]
 cmp x10,x14
 b.ne .Lgn_bad
 cbz x14,.Lgn_pgp_ready
 ldr x10,[x9,#64]
 cmp x10,x12
 b.ne .Lgn_bad
 mul x13,x12,x21
 ldr x10,[x9,#88]
 cmp x10,x13
 b.ne .Lgn_bad
 add x10,x13,x12
 add x10,x10,#1
 neg x10,x10
 ldr x11,[x9,#8]
 cmp x11,x10
 b.ne .Lgn_bad
 ldr x9,[x9]
 cbz x9,.Lgn_bad
 tst x9,#7
 b.ne .Lgn_bad
 mul x13,x13,x14
 lsl x13,x13,#3
 adds x13,x9,x13
 b.cs .Lgn_bad
.Lgn_pgp_ready:
 ldr x9,[sp,#64]
 cbz x9,.Lgn_bad
 tst x9,#3
 b.ne .Lgn_bad
 ldr w28,[x9]
 cmp w28,#0
 csel w28,w28,w21,gt
 cmp w28,w21
 csel w28,w28,w21,lo
 str w28,[sp,#1152]
 mov x9,#48
 mul x9,x21,x9
 str x9,[sp,#1048]
 ldr x10,[sp,#1104]
 adds x9,x9,x10
 b.cs .Lgn_bad
 add x9,x9,x25,lsl#3
 add x9,x9,#1632
 ldr x10,[sp,#792]
 cmp x9,x10
 b.hi .Lgn_bad
 /* Copy the shared context and reserve all simultaneously live controller work. */
 add x10,sp,#896
 mov x11,#0
.Lgn_context_copy:
 ldr x12,[x19,x11]
 str x12,[x10,x11]
 add x11,x11,#8
 cmp x11,#128
 b.lo .Lgn_context_copy
 ldr x9,[sp,#1048]
 ldr x10,[sp,#1104]
 add x9,x9,x10
 add x9,x9,x25,lsl#3
 add x9,x9,#1632
 ldr x10,[sp,#792]
 subs x10,x10,x9
 b.ls .Lgn_bad
 str x10,[sp,#992]
 mov w0,#0
 b .Lgn_admission_agree
.Lgn_bad:
 mov w0,#2
.Lgn_admission_agree:
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lgn_return
 ldr x0,[sp,#1048]
 NCCALL malloc
 str x0,[sp,#1040]
 cmp x0,#0
 cset w0,eq
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lgn_failed
 lsl x0,x25,#3
 NCCALL malloc
 str x0,[sp,#1080]
 cmp x0,#0
 cset w0,eq
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lgn_failed
 ldr x23,[sp,#1040]
 ldr x9,[sp,#1080]
 add x9,x9,x25,lsl#2
 str x9,[sp,#1088]
 /* KFPSIZEG is explicit-shape here and assumed-shape in EXTFPNORM. */
 add x9,sp,#256
 ldr x10,[sp,#104]
 str x10,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#4
 str x10,[x9,#16]
 str x10,[x9,#32]
 movz x10,#0x0101,lsl#32
 str x10,[x9,#24]
 mov x10,#1
 stp x10,x10,[x9,#40]
 str x10,[x9,#56]
 str w10,[sp,#1140]
 str w10,[sp,#1156]
.Lgn_chunk:
 ldr w9,[sp,#1156]
 sub w9,w9,#1
 sub w10,w21,w9
 ldr w11,[sp,#1152]
 cmp w10,w11
 csel w10,w10,w11,lo
 str w10,[sp,#1160]
 udiv w11,w10,w25
 msub w12,w11,w25,w10
 mov w13,#0
 mov w14,#0
 ldr x15,[sp,#1080]
 ldr x16,[sp,#1088]
.Lgn_distribution:
 cmp w13,w12
 cinc w17,w11,lo
 str w17,[x15,x13,lsl#2]
 str w14,[x16,x13,lsl#2]
 add w14,w14,w17
 add w13,w13,#1
 cmp w13,w25
 b.lo .Lgn_distribution
 add x1,x23,x9,lsl#3
 add x0,sp,#320
 mov x2,x10
 bl .Lnc_matrix
 ldr w9,[sp,#1156]
 sub w9,w9,#1
 add x1,x23,x21,lsl#3
 add x1,x1,x9,lsl#3
 add x0,sp,#408
 ldr w2,[sp,#1160]
 bl .Lnc_matrix
 ldr w9,[sp,#1156]
 sub w9,w9,#1
 add x1,x23,x21,lsl#4
 add x1,x1,x9,lsl#3
 add x0,sp,#496
 ldr w2,[sp,#1160]
 bl .Lnc_matrix
 add x9,sp,#1156
 str x9,[sp]
 add x9,sp,#1140
 str x9,[sp,#8]
 add x9,sp,#320
 str x9,[sp,#16]
 add x9,sp,#408
 str x9,[sp,#24]
 add x9,sp,#496
 str x9,[sp,#32]
 add x9,sp,#896
 str x9,[sp,#40]
 ldr x0,[sp,#72]
 ldr x1,[sp,#112]
 ldr x2,[sp,#144]
 ldr x3,[sp,#152]
 add x4,sp,#256
 ldr x5,[sp,#1080]
 ldr x6,[sp,#1088]
 add x7,sp,#1160
 NCCALL md2asm_runtime_extract_fullpos_norms
 cbnz w0,.Lgn_failed
 ldr w9,[sp,#1156]
 ldr w10,[sp,#1160]
 add w9,w9,w10
 str w9,[sp,#1156]
 cmp w9,w21
 b.ls .Lgn_chunk
 mov w0,w27
 NCCALL MPI_Barrier
 cbnz w0,.Lgn_mpi
 ldr w24,[sp,#804]
 cbnz w24,.Lgn_complete
 ldr x25,[sp,#1128]
 ldr x28,[sp,#176]
 mov x26,#0
.Lgn_adjust_field:
 ldr x9,[sp,#1120]
 ldr w9,[x9,x26,lsl#2]
 cbnz w9,.Lgn_surface
 add x0,x25,x26,lsl#3
 mov x1,x28
 bl .Lnc_level
.Lgn_surface:
 adrp x9,.Lnc_epsilon
 ldr d1,[x9,:lo12:.Lnc_epsilon]
 mov x10,x26
 mov x11,#0
 mov x12,#3
 mul x12,x21,x12
 add x12,x23,x12,lsl#3
.Lgn_adjust_triple:
 ldr d0,[x23,x10,lsl#3]
 fabs d2,d0
 fcmp d2,d1
 b.mi .Lgn_adjust_zero
 b .Lgn_adjust_store
.Lgn_adjust_zero:
 fmov d0,xzr
.Lgn_adjust_store:
 str d0,[x12,x10,lsl#3]
 add x10,x10,x21
 add x11,x11,#1
 cmp x11,#3
 b.lo .Lgn_adjust_triple
 add x26,x26,#1
 cmp x26,x21
 b.lo .Lgn_adjust_field
.Lgn_complete:
 ldr x0,[sp,#1080]
 NCCALL free
 str xzr,[sp,#1080]
 mov w0,#0
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lgn_failed
 ldr w24,[sp,#804]
 cbnz w24,.Lgn_remote_publish
 ldr x26,[x20,#40]
 str x23,[x20,#40]
 ldr x9,[sp,#1048]
 str x9,[x20,#48]
 b .Lgn_shape_publish
.Lgn_remote_publish:
 mov x0,x23
 NCCALL free
 mov x26,#0
 str xzr,[x20,#40]
 str xzr,[x20,#48]
.Lgn_shape_publish:
 mov w9,#1
 stp w9,w21,[x20,#56]
 mov x0,x20
 add x1,sp,#768
 bl .Lnc_stamp
 cbz x26,.Lgn_success
 mov x0,x26
 NCCALL free
.Lgn_success:
 mov w0,#0
 b .Lgn_return
.Lgn_failed:
 str w0,[sp,#1136]
 ldr x0,[sp,#1080]
 cbz x0,.Lgn_failed_stage
 NCCALL free
.Lgn_failed_stage:
 ldr x0,[sp,#1040]
 cbz x0,.Lgn_failed_code
 NCCALL free
.Lgn_failed_code:
 ldr w0,[sp,#1136]
.Lgn_return:
 NCRETURN
.Lgn_mpi:
 mov w0,w27
 mov w1,#3
 NCCALL MPI_Abort
 brk #1
.size md2asm_runtime_fullpos_grid_norms,.-md2asm_runtime_fullpos_grid_norms

.global md2asm_release_runtime_fullpos_norm_results
.type md2asm_release_runtime_fullpos_norm_results,%function
md2asm_release_runtime_fullpos_norm_results:
 NCSAVE
 mov x19,x0
 mov x0,x19
 add x1,sp,#768
 bl .Lnc_bind
 ldr w27,[sp,#800]
 cbnz w0,.Lnr_agree
 NCOWNER x20
 ldr x0,[sp,#776]
 ldr w1,[sp,#804]
 ldr w2,[sp,#808]
 bl .Lnc_owner
.Lnr_agree:
 mov w1,w27
 bl .Lnc_agree
 cbnz w0,.Lnr_return
 ldr x21,[x20,#16]
 ldr x22,[x20,#40]
 cbz x21,.Lnr_grid
 mov x0,x21
 NCCALL free
.Lnr_grid:
 cbz x22,.Lnr_clear
 mov x0,x22
 NCCALL free
.Lnr_clear:
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 stp xzr,xzr,[x20,#64]
 mov w0,#0
.Lnr_return:
 NCRETURN
.size md2asm_release_runtime_fullpos_norm_results,.-md2asm_release_runtime_fullpos_norm_results

.section .rodata
.p2align 3
.Lnc_epsilon: .quad 0x3cb0000000000000
.Lnc_level_scale: .double 10000000.0
.bss
.p2align 4
.global md2asm_runtime_fullpos_norm_results
.type md2asm_runtime_fullpos_norm_results,%object
.size md2asm_runtime_fullpos_norm_results,80
md2asm_runtime_fullpos_norm_results: .zero 80
.section .note.GNU-stack,"",%progbits

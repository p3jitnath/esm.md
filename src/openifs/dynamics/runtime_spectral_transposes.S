/* TRMTOS and TRSTOM use the live source maps.
 * Original arguments retain their order and optional null slots.
 * The final argument borrows the complete phase7 partition4096.
 * Contract runtime_spectral_transpose_contract.md froze before emission.
 */
.arch armv8.2-a
.text
.macro IMM reg,value
 movz \reg,#((\value)&65535)
 movk \reg,#(((\value)>>16)&65535),lsl#16
.endm
.macro ARG reg,index
 ldr \reg,[x19,#(112+8*\index)]
.endm
.macro SERVICE name
 bl \name
 ldr x18,[x19,#16]
 cbnz w0,.Lmpi_fatal
.endm
.p2align 4
.global md2asm_runtime_trmtos
.type md2asm_runtime_trmtos,%function
md2asm_runtime_trmtos:
 mov w17,#0
 b .Ltranspose_enter
.size md2asm_runtime_trmtos,.-md2asm_runtime_trmtos
.global md2asm_runtime_trstom
.type md2asm_runtime_trstom,%function
md2asm_runtime_trstom:
 mov w17,#1
.Ltranspose_enter:
 mov x16,sp
 sub sp,sp,#1536
 stp x29,x30,[sp]
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x19,sp
 stp x0,x1,[x19,#112]
 stp x2,x3,[x19,#128]
 stp x4,x5,[x19,#144]
 stp x6,x7,[x19,#160]
 str w17,[x19,#352]
 add w11,w17,#29
 mov w10,#8
.Lsave_args:
 ldr x9,[x16],#8
 add x12,x19,#112
 str x9,[x12,x10,lsl#3]
 add w10,w10,#1
 cmp w10,w11
 b.lo .Lsave_args
 stp xzr,xzr,[x19,#432]
 str wzr,[x19,#420]
 str wzr,[x19,#424]
 str wzr,[x19,#896]
 str wzr,[x19,#900]
 str wzr,[x19,#904]
 add x0,x19,#880
 bl MPI_Initialized
 ldr x18,[x19,#16]
 cbnz w0,.Lbad_local_return
 ldr w9,[x19,#880]
 cbz w9,.Lbad_local_return
 adrp x9,:got:__mpl_data_module_MOD_mpl_comm
 ldr x9,[x9,:got_lo12:__mpl_data_module_MOD_mpl_comm]
 ldr w0,[x9]
 /* Public MPICH MPI_Comm_f2c is the exact integer cast in mpi.h721. */
 str w0,[x19,#356]
 add x1,x19,#360
 SERVICE MPI_Comm_size
 ldr w0,[x19,#356]
 add x1,x19,#364
 SERVICE MPI_Comm_rank
 ARG x20,0
 cbz x20,.Lbad_admission
 tst x20,#7
 b.ne .Lbad_admission
 ldr w9,[x19,#352]
 add w9,w9,#28
 add x10,x19,#112
 ldr x21,[x10,x9,lsl#3]
 cbz x21,.Lbad_admission
 tst x21,#7
 b.ne .Lbad_admission
 ldr x9,[x21]
 cmp x9,x20
 b.ne .Lbad_admission
 ldr x9,[x21,#8]
 movz x10,#0x574e
 movk x10,#0x5f4f,lsl#16
 movk x10,#0x5458,lsl#32
 movk x10,#0x4450,lsl#48
 cmp x9,x10
 b.ne .Lbad_admission
 ldr w9,[x21,#16]
 cmp w9,#7
 b.ne .Lbad_admission
 ldr w9,[x21,#24]
 sub w10,w9,#1
 IMM w11,65535
 cmp w10,w11
 b.hi .Lbad_admission
 ldr w10,[x19,#360]
 cmp w9,w10
 b.ne .Lbad_admission
 ldr w9,[x21,#28]
 ldr w10,[x19,#364]
 add w10,w10,#1
 cmp w9,w10
 b.ne .Lbad_admission
 ldp w9,w10,[x21,#32]
 cmp w9,#1
 b.lt .Lbad_admission
 cmp w10,#1
 b.lt .Lbad_admission
 umull x11,w9,w10
 ldr w12,[x19,#360]
 cmp x11,x12
 b.ne .Lbad_admission
 str w9,[x19,#368]
 str w10,[x19,#372]
 ldp w11,w12,[x21,#64]
 sub w13,w11,#1
 cmp w13,w9
 b.hs .Lbad_admission
 sub w13,w12,#1
 cmp w13,w10
 b.hs .Lbad_admission
 str w11,[x19,#376]
 str w12,[x19,#380]
 sub w11,w11,#1
 madd w11,w11,w10,w12
 ldr w12,[x21,#28]
 cmp w11,w12
 b.ne .Lbad_admission
 mrs x9,fpcr
 cbnz x9,.Lbad_admission
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbnz w9,.Lbad_admission
 ldr w9,[x20,#5172]
 sub w10,w9,#1
 IMM w11,8190
 cmp w10,w11
 b.hi .Lbad_admission
 ldr w9,[x20,#5224]
 sub w10,w9,#1
 cmp w10,#511
 b.hi .Lbad_admission
 str w9,[x19,#384]
 ldr w10,[x19,#372]
 add w11,w9,#1
 cmp w10,w11
 b.hi .Lbad_admission
 ldr w9,[x20,#5228]
 str w9,[x19,#388]
 ldr w9,[x20,#5200]
 tbnz w9,#31,.Lbad_admission
 str w9,[x19,#392]
 ldr w9,[x20,#7208]
 cmp w9,#1
 b.hi .Lbad_admission
 str w9,[x19,#400]
 ARG x9,1
 cbz x9,.Lbad_admission
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lbad_admission
 str w9,[x19,#408]
 ARG x9,2
 cbz x9,.Lbad_admission
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lbad_admission
 str w9,[x19,#412]
 ARG x9,27
 mov w10,#0
 cbz x9,.Lfull_ready
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lbad_admission
.Lfull_ready:
 str w10,[x19,#416]
 mov w11,#7212
 cmp w10,#0
 mov w12,#7216
 csel w11,w11,w12,eq
 ldr w9,[x20,x11]
 tbnz w9,#31,.Lbad_admission
 str w9,[x19,#396]
 str wzr,[x19,#404]
 ldr w9,[x19,#352]
 cbz w9,.Lneed_ready
 ARG x9,28
 cbz x9,.Lneed_ready
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lbad_admission
 str w10,[x19,#404]
.Lneed_ready:
 /* Canonical local and column descriptor tables keep source names. */
 mov w9,#0
 ldr w12,[x19,#352]
.Ltable_args:
 add w10,w9,#3
 add w11,w9,#14
 cmp w12,#0
 csel w13,w10,w11,eq
 csel w14,w11,w10,eq
 add x15,x19,#112
 ldr x13,[x15,x13,lsl#3]
 ldr x14,[x15,x14,lsl#3]
 add x15,x19,#512
 str x13,[x15,x9,lsl#3]
 add x15,x19,#600
 str x14,[x15,x9,lsl#3]
 add w9,w9,#1
 cmp w9,#11
 b.lo .Ltable_args
 /* Normalize the source pointer maps, including empty intervals. */
 ldr w9,[x19,#416]
 mov x10,#5576
 mov x11,#5640
 cmp w9,#0
 csel x10,x10,x11,eq
 add x0,x20,x10
 add x1,x19,#688
 mov w2,#1
 ldr w3,[x19,#372]
 add w3,w3,#1
 mov x4,#0
 mov w5,#4
 mov w7,#1
 bl .Lnormalize
 cbnz w0,.Lbad_admission
 ldr x9,[x19,#696]
 cmp x9,#4
 b.ne .Lbad_admission
 ldr x9,[x19,#688]
 str x9,[x19,#464]
 mov x10,#5896
 add x0,x20,x10
 add x1,x19,#688
 mov w2,#1
 ldr w3,[x19,#372]
 add w3,w3,#1
 mov x4,#0
 mov w5,#4
 mov w7,#1
 bl .Lnormalize
 cbnz w0,.Lbad_admission
 ldr x9,[x19,#696]
 cmp x9,#4
 b.ne .Lbad_admission
 ldr x9,[x19,#688]
 str x9,[x19,#472]
 mov x10,#6024
 add x0,x20,x10
 add x1,x19,#688
 mov w2,#1
 ldr w3,[x19,#372]
 mov x4,#0
 mov w5,#4
 mov w7,#1
 bl .Lnormalize
 cbnz w0,.Lbad_admission
 ldr x9,[x19,#696]
 cmp x9,#4
 b.ne .Lbad_admission
 ldr x9,[x19,#688]
 str x9,[x19,#480]
 bl .Lcheck_maps
 cbnz w0,.Lbad_admission
 /* Reserve only the possible live field channels. */
 mov w22,#7
 ldr x9,[x19,#560]
 cbz x9,.Lcapacity_sel
 ldp x10,x11,[x9,#96]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,#0
 csel x11,x11,xzr,gt
 cmp x11,#4096
 b.hi .Lbad_admission
 add w22,w22,w11
.Lcapacity_sel:
 ldr x9,[x19,#584]
 cbz x9,.Lcapacity_done
 ldp x10,x11,[x9,#96]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,#0
 csel x11,x11,xzr,gt
 cmp x11,#4096
 b.hi .Lbad_admission
 add w22,w22,w11
.Lcapacity_done:
 cmp w22,#4096
 b.hi .Lbad_admission
 mov x9,#48
 mul x9,x22,x9
 str x9,[x19,#488]
 mov w0,#0
 b .Ladmit_common
.Lbad_admission:
 mov w0,#2
.Ladmit_common:
 bl .Lagreement
 cbnz w0,.Lreturn
 ldr x0,[x19,#488]
 bl malloc
 ldr x18,[x19,#16]
 str x0,[x19,#432]
 cmp x0,#0
 cset w0,eq
 bl .Lagreement
 cbnz w0,.Lfree_return
 /* Build ordinary fields in the original packing order. */
 mov w22,#0
.Lordinary_field:
 adr x9,.Lordinary_indices
 ldrb w23,[x9,x22]
 cmp w23,#3
 b.eq .Lnh_field
 cmp w23,#4
 b.eq .Lnh_field
 cmp w23,#5
 b.ne .Lordinary_enabled
 ldr w9,[x19,#412]
 cbz w9,.Lordinary_next
 b .Lordinary_enabled
.Lnh_field:
 ldr w9,[x19,#408]
 cbz w9,.Lordinary_next
.Lordinary_enabled:
 add x9,x19,#512
 ldr x0,[x9,x23,lsl#3]
 cbz x0,.Lordinary_next
 add x9,x19,#600
 ldr x1,[x9,x23,lsl#3]
 mov w2,#2
 bl .Lnormalize_pair
 cbnz w0,.Lbad_fields
 mov w0,#0
 mov w1,#0
 bl .Lappend_channel
.Lordinary_next:
 add w22,w22,#1
 cmp w22,#7
 b.lo .Lordinary_field
 /* All spectral GFL fields follow AUX. */
 ldr x0,[x19,#560]
 cbz x0,.Lselected3d
 ldp x9,x10,[x0,#96]
 sub x10,x10,x9
 add x10,x10,#1
 cmp x10,#0
 b.le .Lselected3d
 add x1,x19,#688
 mov w2,#3
 ldr w3,[x19,#388]
 ldr w4,[x19,#392]
 mov w5,#8
 mov w7,#3
 bl .Lnormalize
 cbnz w0,.Lbad_fields
 ldr x9,[x19,#728]
 ldr w10,[x19,#392]
 cmp x9,x10
 b.ne .Lbad_fields
 ldr x23,[x19,#736]
 cmp x23,#4096
 b.hi .Lbad_fields
 cbz x23,.Lselected3d
 ldr x0,[x19,#648]
 add x1,x19,#752
 mov w2,#3
 ldr w3,[x19,#384]
 ldr w4,[x19,#396]
 mov w5,#8
 mov w7,#3
 bl .Lnormalize
 cbnz w0,.Lbad_fields
 ldr x9,[x19,#792]
 ldr w10,[x19,#396]
 cmp x9,x10
 b.ne .Lbad_fields
 ldr x9,[x19,#800]
 cmp x9,x23
 b.ne .Lbad_fields
 mov x22,#0
.Lgfl_channels:
 mov x0,x22
 mov x1,x22
 bl .Lappend_channel
 add x22,x22,#1
 cmp x22,x23
 b.lo .Lgfl_channels
.Lselected3d:
 ldr x0,[x19,#584]
 cbz x0,.Lpressure
 ldr x1,[x19,#672]
 mov w2,#3
 bl .Lnormalize_pair
 cbnz w0,.Lbad_fields
 ldr x23,[x19,#736]
 ARG x0,25
 mov x1,x23
 bl .Lselection_mask
 cbnz w0,.Lbad_fields
 mov x24,x1
 mov x25,x2
 ldr x9,[x19,#800]
 cmp x9,x24
 b.ne .Lbad_fields
 mov x22,#0
 mov x26,#0
.Lselected3d_channels:
 cmp x22,x23
 b.hs .Lpressure
 ldr x10,[x19,#912]
 mul x9,x22,x10
 ldr w9,[x25,x9]
 cbz w9,.Lselected3d_next
 mov x0,x22
 mov x1,x26
 bl .Lappend_channel
 add x26,x26,#1
.Lselected3d_next:
 add x22,x22,#1
 b .Lselected3d_channels
.Lpressure:
 ldr x0,[x19,#568]
 cbz x0,.Lselected2d
 ldr x1,[x19,#656]
 mov w2,#1
 bl .Lnormalize_pressure_pair
 cbnz w0,.Lbad_fields
 bl .Lsave_pressure
 mov w9,#1
 str w9,[x19,#424]
 str w9,[x19,#896]
 str w9,[x19,#900]
.Lselected2d:
 ldr x0,[x19,#592]
 cbz x0,.Lneed_validate
 ldr x1,[x19,#680]
 mov w2,#2
 bl .Lnormalize_pressure_pair
 cbnz w0,.Lbad_fields
 ldr x23,[x19,#728]
 ARG x0,26
 mov x1,x23
 bl .Lselection_mask
 cbnz w0,.Lbad_fields
 mov x24,x1
 mov x25,x2
 cmp x24,#1
 b.hi .Lbad_fields
 ldr x9,[x19,#792]
 cmp x9,x24
 b.ne .Lbad_fields
 mov w9,#1
 str w9,[x19,#896]
 str w24,[x19,#904]
 cbz x24,.Lneed_validate
 ldr w9,[x19,#424]
 cbnz w9,.Lbad_fields
 mov x22,#0
.Lfind_selected2d:
 ldr x10,[x19,#912]
 mul x9,x22,x10
 ldr w9,[x25,x9]
 cbnz w9,.Lselected2d_found
 add x22,x22,#1
 b .Lfind_selected2d
.Lselected2d_found:
 ldr x9,[x19,#688]
 ldr x10,[x19,#704]
 madd x9,x22,x10,x9
 str x9,[x19,#688]
 bl .Lsave_pressure
 mov w9,#1
 str w9,[x19,#424]
.Lneed_validate:
 ldr w9,[x19,#352]
 cbz w9,.Lfields_good
 ARG x9,28
 cbz x9,.Lfields_good
 ldr x9,[x19,#568]
 ldr x10,[x19,#520]
 cbz x9,.Lbad_fields
 cbz x10,.Lbad_fields
 ldp x11,x12,[x9,#48]
 sub x12,x12,x11
 add x12,x12,#1
 ldp x13,x14,[x10,#72]
 sub x14,x14,x13
 add x14,x14,#1
 cmp x12,x14
 b.ne .Lbad_fields
 ldr w9,[x19,#404]
 cbz w9,.Lfields_good
 ldr w9,[x19,#900]
 cbz w9,.Lbad_fields
 ldr w9,[x19,#904]
 cbnz w9,.Lbad_fields
.Lfields_good:
 mov w0,#0
 b .Lfields_common
.Lbad_fields:
 mov w0,#2
.Lfields_common:
 bl .Lagreement
 cbnz w0,.Lfree_return
 bl .Lmake_peers
 cbnz w0,.Lfree_return
 bl .Lself_copy
 bl .Lcommunicate
 mov w0,#0
.Lfree_return:
 str w0,[x19,#504]
 ldr x0,[x19,#440]
 bl free
 ldr x0,[x19,#432]
 bl free
 ldr w0,[x19,#504]
.Lreturn:
 ldr x28,[x19,#96]
 ldp x26,x27,[x19,#80]
 ldp x24,x25,[x19,#64]
 ldp x22,x23,[x19,#48]
 ldp x20,x21,[x19,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1536
 ret
.Lbad_local_return:
 mov w0,#2
 b .Lreturn
.Lmpi_fatal:
 ldr w0,[x19,#356]
 mov w1,#3
 bl MPI_Abort
 brk #0
.size md2asm_runtime_trstom,.-md2asm_runtime_trstom
/* Normalize one borrowed GNU array descriptor into a64 byte private view.
 * x0 descriptor,x1 result,w2 rank,x3/x4 required first/second extents.
 * w5 element bytes,w7 GNU intrinsic type code. All strides stay exact.
 */
.Lnormalize:
 cbz x0,.Lnormalize_bad
 tst x0,#7
 b.ne .Lnormalize_bad
 ldr x9,[x0,#16]
 cmp x9,x5
 b.ne .Lnormalize_bad
 ldr x9,[x0,#32]
 cmp x9,x5
 b.ne .Lnormalize_bad
 ldrb w9,[x0,#28]
 cmp w9,w2
 b.ne .Lnormalize_bad
 ldrb w9,[x0,#29]
 cmp w9,w7
 b.ne .Lnormalize_bad
 ldr x8,[x0]
 cbz x8,.Lnormalize_bad
 sub x9,x5,#1
 tst x8,x9
 b.ne .Lnormalize_bad
 stp xzr,xzr,[x1,#8]
 stp xzr,xzr,[x1,#24]
 stp xzr,xzr,[x1,#40]
 ldr x6,[x0,#8]
 mov w7,#0
 mov w15,#0
 add x9,x0,#40
.Lnormalize_dimension:
 ldp x10,x11,[x9]
 ldr x12,[x9,#16]
 tbnz x10,#63,.Lnormalize_bad
 subs x12,x12,x11
 b.vs .Lnormalize_bad
 adds x12,x12,#1
 b.vs .Lnormalize_bad
 cmp x12,#0
 csel x12,x12,xzr,gt
 cmp x12,#0
 csinc w15,w15,wzr,ne
 cbnz x10,.Lnormalize_stride_ready
 cbz w15,.Lnormalize_bad
.Lnormalize_stride_ready:
 lsr x13,x12,#31
 cbnz x13,.Lnormalize_bad
 cbnz w7,.Lnormalize_second
 cmp x12,x3
 b.lo .Lnormalize_bad
 b .Lnormalize_extent_done
.Lnormalize_second:
 cmp w7,#1
 b.ne .Lnormalize_extent_done
 cmp x12,x4
 b.lo .Lnormalize_bad
.Lnormalize_extent_done:
 add x13,x1,#32
 str x12,[x13,x7,lsl#3]
 smulh x13,x11,x10
 mul x14,x11,x10
 cmp x13,x14,asr#63
 b.ne .Lnormalize_bad
 adds x6,x6,x14
 b.vs .Lnormalize_bad
 umulh x13,x10,x5
 cbnz x13,.Lnormalize_bad
 mul x10,x10,x5
 tbnz x10,#63,.Lnormalize_bad
 add x13,x1,#8
 str x10,[x13,x7,lsl#3]
 add w7,w7,#1
 add x9,x9,#24
 cmp w7,w2
 b.lo .Lnormalize_dimension
 tbnz x6,#63,.Lnormalize_bad
 umulh x9,x6,x5
 cbnz x9,.Lnormalize_bad
 mul x6,x6,x5
 adds x8,x8,x6
 b.cs .Lnormalize_bad
 /* Bound the last byte reached by every positive-stride dimension. */
 mov x6,#0
 mov w7,#0
.Lnormalize_span:
 add x9,x1,#32
 ldr x10,[x9,x7,lsl#3]
 cbz x10,.Lnormalize_empty
 sub x10,x10,#1
 add x9,x1,#8
 ldr x11,[x9,x7,lsl#3]
 umulh x12,x10,x11
 cbnz x12,.Lnormalize_bad
 mul x10,x10,x11
 adds x6,x6,x10
 b.cs .Lnormalize_bad
 add w7,w7,#1
 cmp w7,w2
 b.lo .Lnormalize_span
 adds x6,x6,x5
 b.cs .Lnormalize_bad
 adds x6,x8,x6
 b.cs .Lnormalize_bad
.Lnormalize_empty:
 str x8,[x1]
 mov w0,#0
 ret
.Lnormalize_bad:
 mov w0,#2
 ret

.Lnormalize_pair:
 stp x29,x30,[sp,#-48]!
 stp x1,x2,[sp,#16]
 add x1,x19,#688
 ldr w3,[x19,#388]
 ldr w4,[x19,#392]
 mov w5,#8
 mov w7,#3
 bl .Lnormalize
 cbnz w0,.Lpair_return
 ldr x9,[x19,#728]
 ldr w10,[x19,#392]
 cmp x9,x10
 b.ne .Lpair_bad
 ldp x0,x2,[sp,#16]
 add x1,x19,#752
 ldr w3,[x19,#384]
 ldr w4,[x19,#396]
 mov w5,#8
 mov w7,#3
 bl .Lnormalize
 cbnz w0,.Lpair_return
 ldr x9,[x19,#792]
 ldr w10,[x19,#396]
 cmp x9,x10
 b.eq .Lpair_return
.Lpair_bad:
 mov w0,#2
.Lpair_return:
 ldp x29,x30,[sp],#48
 ret

.Lnormalize_pressure_pair:
 stp x29,x30,[sp,#-48]!
 stp x1,x2,[sp,#16]
 add x1,x19,#688
 ldr w3,[x19,#392]
 mov x4,#0
 mov w5,#8
 mov w7,#3
 bl .Lnormalize
 cbnz w0,.Lpressure_pair_return
 ldr x9,[x19,#720]
 ldr w10,[x19,#392]
 cmp x9,x10
 b.ne .Lpressure_pair_bad
 ldp x0,x2,[sp,#16]
 add x1,x19,#752
 ldr w3,[x19,#396]
 mov x4,#0
 mov w5,#8
 mov w7,#3
 bl .Lnormalize
 cbnz w0,.Lpressure_pair_return
 ldr x9,[x19,#784]
 ldr w10,[x19,#396]
 cmp x9,x10
 b.eq .Lpressure_pair_return
.Lpressure_pair_bad:
 mov w0,#2
.Lpressure_pair_return:
 ldp x29,x30,[sp],#48
 ret

/* x0 local field index,x1 packed column field index, both zero based. */
.Lappend_channel:
 ldr x9,[x19,#688]
 ldr x10,[x19,#712]
 madd x9,x0,x10,x9
 ldr x11,[x19,#752]
 ldr x10,[x19,#776]
 madd x11,x1,x10,x11
 ldr x10,[x19,#432]
 ldr w12,[x19,#420]
 mov x13,#48
 madd x10,x12,x13,x10
 ldr x13,[x19,#696]
 ldr x14,[x19,#704]
 stp x9,x13,[x10]
 stp x14,x11,[x10,#16]
 ldr x13,[x19,#760]
 ldr x14,[x19,#768]
 stp x13,x14,[x10,#32]
 add w12,w12,#1
 str w12,[x19,#420]
 ret
.Lsave_pressure:
 ldr x9,[x19,#688]
 ldr x10,[x19,#696]
 str x9,[x19,#816]
 str x10,[x19,#832]
 ldr x9,[x19,#752]
 ldr x10,[x19,#760]
 str x9,[x19,#840]
 str x10,[x19,#856]
 ret

/* Keep normalized field pairs intact while checking a logical mask. */
.Lselection_mask:
 stp x29,x30,[sp,#-32]!
 str x1,[sp,#16]
 mov x3,x1
 add x1,x19,#960
 mov w2,#1
 mov x4,#0
 mov w5,#4
 mov w7,#2
 bl .Lnormalize
 cbnz w0,.Lmask_return
 ldr x9,[sp,#16]
 ldr x10,[x19,#992]
 cmp x9,x10
 b.ne .Lmask_bad
 ldr x2,[x19,#960]
 ldr x3,[x19,#968]
 str x3,[x19,#912]
 mov x1,#0
 mov x10,#0
.Lmask_count:
 cmp x10,x9
 b.hs .Lmask_good
 mul x11,x10,x3
 ldr w12,[x2,x11]
 cmp w12,#1
 b.hi .Lmask_bad
 add x1,x1,x12
 add x10,x10,#1
 b .Lmask_count
.Lmask_good:
 mov w0,#0
 b .Lmask_return
.Lmask_bad:
 mov w0,#2
.Lmask_return:
 ldp x29,x30,[sp],#32
 ret

.Lcheck_maps:
 ldr x9,[x19,#464]
 ldr x10,[x19,#472]
 ldr x11,[x19,#480]
 ldr w12,[x9]
 cmp w12,#1
 b.ne .Lmaps_bad
 ldr w12,[x10]
 cmp w12,#1
 b.ne .Lmaps_bad
 ldr w13,[x19,#372]
 ldr w14,[x9,x13,lsl#2]
 ldr w15,[x19,#392]
 add w15,w15,#1
 cmp w14,w15
 b.ne .Lmaps_bad
 ldr w14,[x10,x13,lsl#2]
 ldr w15,[x19,#384]
 add w15,w15,#1
 cmp w14,w15
 b.ne .Lmaps_bad
 mov w12,#0
 mov w16,#0
.Lmaps_loop:
 ldr w14,[x9,x12,lsl#2]
 add w15,w12,#1
 ldr w15,[x9,x15,lsl#2]
 cmp w14,#1
 b.lt .Lmaps_bad
 cmp w14,w15
 b.gt .Lmaps_bad
 ldr w14,[x10,x12,lsl#2]
 add w15,w12,#1
 ldr w15,[x10,x15,lsl#2]
 cmp w14,#1
 b.lt .Lmaps_bad
 cmp w14,w15
 b.gt .Lmaps_bad
 ldr w14,[x11,x12,lsl#2]
 cmp w14,#1
 b.hi .Lmaps_bad
 add w16,w16,w14
 add w12,w12,#1
 cmp w12,w13
 b.lo .Lmaps_loop
 cmp w16,#1
 b.ne .Lmaps_bad
 ldr w12,[x19,#380]
 sub w12,w12,#1
 ldr w13,[x9,x12,lsl#2]
 add w14,w12,#1
 ldr w15,[x9,x14,lsl#2]
 sub w15,w15,w13
 ldr w16,[x19,#396]
 cmp w15,w16
 b.ne .Lmaps_bad
 sub w13,w13,#1
 str w13,[x19,#496]
 ldr w13,[x10,x12,lsl#2]
 ldr w15,[x10,x14,lsl#2]
 sub w15,w15,w13
 ldr w16,[x19,#388]
 cmp w15,w16
 b.ne .Lmaps_bad
 sub w13,w13,#1
 str w13,[x19,#500]
 ldr w13,[x11,x12,lsl#2]
 ldr w14,[x19,#400]
 cmp w13,w14
 b.ne .Lmaps_bad
 mov w0,#0
 ret
.Lmaps_bad:
 mov w0,#2
 ret

.Lagreement:
 stp x29,x30,[sp,#-16]!
 str w0,[x19,#428]
 add x0,x19,#428
 add x1,x19,#880
 mov w2,#1
 IMM w3,0x4c000405
 IMM w4,0x58000001
 ldr w5,[x19,#356]
 SERVICE MPI_Allreduce
 ldr w0,[x19,#880]
 ldp x29,x30,[sp],#16
 ret
/* w0 is a zero-based vertical peer. Returned counts exclude the headers. */
.Lpeer_counts:
 ldr x9,[x19,#464]
 ldr x10,[x19,#472]
 ldr x11,[x19,#480]
 ldr w2,[x9,x0,lsl#2]
 add w12,w0,#1
 ldr w3,[x9,x12,lsl#2]
 sub w3,w3,w2
 sub w2,w2,#1
 ldr w4,[x10,x0,lsl#2]
 ldr w5,[x10,x12,lsl#2]
 sub w5,w5,w4
 sub w4,w4,#1
 ldr w12,[x11,x0,lsl#2]
 ldr w13,[x19,#400]
 ldr w14,[x19,#352]
 cbnz w14,.Lcounts_reverse
 mov w6,w13
 mov w7,w12
 b .Lcounts_pressure
.Lcounts_reverse:
 ldr w15,[x19,#404]
 orr w6,w12,w15
 orr w7,w13,w15
.Lcounts_pressure:
 ldr w15,[x19,#424]
 and w6,w6,w15
 and w7,w7,w15
 ldr w15,[x19,#420]
 ldr w16,[x19,#388]
 ldr w17,[x19,#396]
 cbnz w14,.Lcounts_reverse_sizes
 umaddl x0,w16,w15,x6
 mul x0,x0,x3
 umaddl x1,w5,w15,x7
 mul x1,x1,x17
 ret
.Lcounts_reverse_sizes:
 umaddl x0,w5,w15,x6
 mul x0,x0,x17
 umaddl x1,w16,w15,x7
 mul x1,x1,x3
 ret

.Lmake_peers:
 stp x29,x30,[sp,#-96]!
 stp x20,x21,[sp,#16]
 stp x22,x23,[sp,#32]
 stp x24,x25,[sp,#48]
 stp x26,x27,[sp,#64]
 ldr w24,[x19,#372]
 cmp w24,#1
 b.eq .Lpeers_empty
 mov x9,#92
 mul x23,x24,x9
 add x23,x23,#15
 and x23,x23,#-16
 str x23,[x19,#944]
 mov w22,#0
 ldr w25,[x19,#380]
 sub w25,w25,#1
.Lpeers_measure:
 cmp w22,w25
 b.eq .Lpeers_measure_next
 mov w0,w22
 bl .Lpeer_counts
 IMM w9,0x7ffffffd
 cmp x0,x9
 b.hi .Lpeers_bound_bad
 cmp x1,x9
 b.hi .Lpeers_bound_bad
 cmp x0,#0
 add x10,x0,#2
 csel x0,x10,xzr,ne
 cmp x1,#0
 add x10,x1,#2
 csel x1,x10,xzr,ne
 add x9,x0,x1
 lsl x9,x9,#3
 adds x23,x23,x9
 b.cs .Lpeers_bound_bad
.Lpeers_measure_next:
 add w22,w22,#1
 cmp w22,w24
 b.lo .Lpeers_measure
 ldr x9,[x19,#488]
 adds x9,x9,x23
 b.cs .Lpeers_bound_bad
 mov x10,#1
 lsl x10,x10,#33
 cmp x9,x10
 b.hi .Lpeers_bound_bad
 str x9,[x19,#456]
 mov w0,#0
 b .Lpeers_size_common
.Lpeers_bound_bad:
 mov w0,#2
.Lpeers_size_common:
 bl .Lagreement
 cbnz w0,.Lpeers_return
 mov x0,x23
 bl malloc
 ldr x18,[x19,#16]
 str x0,[x19,#440]
 cmp x0,#0
 cset w0,eq
 bl .Lagreement
 cbnz w0,.Lpeers_return
 ldr x20,[x19,#440]
 add x23,x20,x23
 str x23,[x19,#1032]
 add x23,x20,x24,lsl#6
 str x23,[x19,#920]
 add x26,x23,x24,lsl#2
 str x26,[x19,#928]
 add x27,x26,x24,lsl#2
 str x27,[x19,#936]
 ldr x9,[x19,#944]
 add x23,x20,x9
 mov w22,#0
.Lpeers_materialize:
 IMM w9,0x2c000000
 ldr x10,[x19,#920]
 str w9,[x10,x22,lsl#2]
 str w9,[x26,x22,lsl#2]
 mov x9,#64
 madd x21,x22,x9,x20
 stp xzr,xzr,[x21]
 stp xzr,xzr,[x21,#16]
 cmp w22,w25
 b.eq .Lpeers_materialize_next
 mov w0,w22
 bl .Lpeer_counts
 stp w2,w3,[x21,#32]
 stp w4,w5,[x21,#40]
 stp w6,w7,[x21,#48]
 cbz x0,.Lpeers_recv_span
 add x0,x0,#2
 str x23,[x21]
 str x0,[x21,#16]
 add x23,x23,x0,lsl#3
.Lpeers_recv_span:
 cbz x1,.Lpeers_materialize_next
 add x1,x1,#2
 str x23,[x21,#8]
 str x1,[x21,#24]
 add x23,x23,x1,lsl#3
.Lpeers_materialize_next:
 add w22,w22,#1
 cmp w22,w24
 b.lo .Lpeers_materialize
 ldr x9,[x19,#1032]
 cmp x23,x9
 b.ne .Lmpi_fatal
.Lpeers_empty:
 mov w0,#0
.Lpeers_return:
 ldp x26,x27,[sp,#64]
 ldp x24,x25,[sp,#48]
 ldp x22,x23,[sp,#32]
 ldp x20,x21,[sp,#16]
 ldp x29,x30,[sp],#96
 ret

.Lself_copy:
 stp x29,x30,[sp,#-96]!
 stp x20,x21,[sp,#16]
 stp x22,x23,[sp,#32]
 stp x24,x25,[sp,#48]
 stp x26,x27,[sp,#64]
 str x28,[sp,#80]
 ldr x20,[x19,#432]
 ldr w21,[x19,#420]
 ldr w22,[x19,#396]
 ldr w23,[x19,#388]
 ldr w24,[x19,#496]
 ldr w25,[x19,#500]
 ldr w26,[x19,#352]
 cbz w21,.Lself_pressure
 cbz w22,.Lself_pressure
 cbz w23,.Lself_pressure
 mov w27,#0
.Lself_channel:
 mov x9,#48
 madd x28,x27,x9,x20
 mov w6,#0
.Lself_coefficient:
 ldp x9,x10,[x28]
 ldr x11,[x28,#16]
 add w12,w24,w6
 madd x9,x12,x11,x9
 ldp x12,x13,[x28,#24]
 ldr x14,[x28,#40]
 madd x12,x6,x14,x12
 madd x12,x25,x13,x12
 mov w7,#0
.Lself_level:
 cbnz w26,.Lself_reverse
 ldr x15,[x9]
 str x15,[x12]
 b .Lself_level_next
.Lself_reverse:
 ldr x15,[x12]
 str x15,[x9]
.Lself_level_next:
 add x9,x9,x10
 add x12,x12,x13
 add w7,w7,#1
 cmp w7,w23
 b.lo .Lself_level
 add w6,w6,#1
 cmp w6,w22
 b.lo .Lself_coefficient
 add w27,w27,#1
 cmp w27,w21
 b.lo .Lself_channel
.Lself_pressure:
 ldr w9,[x19,#424]
 cbz w9,.Lself_done
 ldr w9,[x19,#400]
 cbnz w9,.Lself_pressure_ready
 cbz w26,.Lself_done
 ldr w9,[x19,#372]
 cmp w9,#1
 b.eq .Lself_done
 ldr w9,[x19,#404]
 cbz w9,.Lself_done
.Lself_pressure_ready:
 cbz w22,.Lself_done
 ldr x9,[x19,#816]
 ldr x10,[x19,#832]
 madd x9,x24,x10,x9
 ldr x12,[x19,#840]
 ldr x13,[x19,#856]
 mov w6,#0
.Lself_pressure_loop:
 cbnz w26,.Lself_pressure_reverse
 ldr x15,[x9]
 str x15,[x12]
 b .Lself_pressure_next
.Lself_pressure_reverse:
 ldr x15,[x12]
 str x15,[x9]
.Lself_pressure_next:
 add x9,x9,x10
 add x12,x12,x13
 add w6,w6,#1
 cmp w6,w22
 b.lo .Lself_pressure_loop
.Lself_done:
 ldr x28,[sp,#80]
 ldp x26,x27,[sp,#64]
 ldp x24,x25,[sp,#48]
 ldp x22,x23,[sp,#32]
 ldp x20,x21,[sp,#16]
 ldp x29,x30,[sp],#96
 ret

/* Match both exact source message headers. w0 peer,w1 pack0/unpack1. */
.Lmessage_header:
 ldr x9,[x19,#480]
 ldr w10,[x9,x0,lsl#2]
 ldr w11,[x19,#400]
 ldr w12,[x19,#352]
 cbnz w12,.Lheader_reverse
 cmp w1,#0
 csel w10,w11,w10,eq
 b .Lheader_condition
.Lheader_reverse:
 cmp w1,#0
 csel w10,w10,w11,eq
 ldr w11,[x19,#404]
 orr w10,w10,w11
.Lheader_condition:
 ldr w11,[x19,#896]
 and w10,w10,w11
 mov x0,#0x3ff0000000000000
 cmp w10,#0
 csel x0,x0,xzr,eq
 ldr w10,[x19,#352]
 eor w10,w10,w1
 cbz w10,.Lheader_local_side
 ldr w10,[x19,#396]
 b .Lheader_coefficient_ready
.Lheader_local_side:
 ldr w10,[x2,#36]
.Lheader_coefficient_ready:
 scvtf d0,w10
 fmov x1,d0
 ret

/* w0 peer,w1 pack0/unpack1. x19 remains the enclosing private frame. */
.Lpeer_transfer:
 stp x29,x30,[sp,#-128]!
 stp x20,x21,[sp,#16]
 stp x22,x23,[sp,#32]
 stp x24,x25,[sp,#48]
 stp x26,x27,[sp,#64]
 str x28,[sp,#80]
 mov w20,w0
 mov w21,w1
 ldr x9,[x19,#440]
 mov x10,#64
 madd x22,x20,x10,x9
 cmp w21,#0
 ldr x9,[x22]
 ldr x10,[x22,#8]
 csel x23,x9,x10,eq
 cbz x23,.Ltransfer_done
 mov x2,x22
 bl .Lmessage_header
 cbnz w21,.Ltransfer_check_header
 stp x0,x1,[x23]
 b .Ltransfer_header_done
.Ltransfer_check_header:
 ldp x9,x10,[x23]
 cmp x9,x0
 b.ne .Lmpi_fatal
 cmp x10,x1
 b.ne .Lmpi_fatal
.Ltransfer_header_done:
 add x23,x23,#16
 ldr w9,[x19,#352]
 eor w24,w9,w21
 cbnz w24,.Ltransfer_column_shape
 ldp w25,w26,[x22,#32]
 ldr w27,[x19,#388]
 mov w28,#0
 b .Ltransfer_shape_ready
.Ltransfer_column_shape:
 mov w25,#0
 ldr w26,[x19,#396]
 ldp w28,w27,[x22,#40]
.Ltransfer_shape_ready:
 /* Pressure precedes every three-dimensional channel. */
 cmp w21,#0
 ldr w9,[x22,#48]
 ldr w10,[x22,#52]
 csel w9,w9,w10,eq
 cbz w9,.Ltransfer_fields
 cbz w26,.Ltransfer_fields
 add x9,x19,#816
 mov x10,#24
 madd x9,x24,x10,x9
 ldr x10,[x9]
 ldr x11,[x9,#16]
 madd x10,x25,x11,x10
 mov w12,#0
.Ltransfer_pressure:
 cbnz w21,.Ltransfer_pressure_put
 ldr x13,[x10]
 str x13,[x23],#8
 b .Ltransfer_pressure_next
.Ltransfer_pressure_put:
 ldr x13,[x23],#8
 str x13,[x10]
.Ltransfer_pressure_next:
 add x10,x10,x11
 add w12,w12,#1
 cmp w12,w26
 b.lo .Ltransfer_pressure
.Ltransfer_fields:
 cbz w26,.Ltransfer_finish_count
 cbz w27,.Ltransfer_finish_count
 ldr w9,[x19,#420]
 cbz w9,.Ltransfer_finish_count
 mov w0,#0
.Ltransfer_coefficient:
 mov w1,#0
.Ltransfer_channel:
 ldr x9,[x19,#432]
 mov x10,#48
 madd x9,x1,x10,x9
 mov x10,#24
 madd x9,x24,x10,x9
 ldp x10,x11,[x9]
 ldr x12,[x9,#16]
 add w13,w25,w0
 madd x10,x13,x12,x10
 madd x10,x28,x11,x10
 mov w2,#0
.Ltransfer_level:
 cbnz w21,.Ltransfer_put
 ldr x13,[x10]
 str x13,[x23],#8
 b .Ltransfer_level_next
.Ltransfer_put:
 ldr x13,[x23],#8
 str x13,[x10]
.Ltransfer_level_next:
 add x10,x10,x11
 add w2,w2,#1
 cmp w2,w27
 b.lo .Ltransfer_level
 add w1,w1,#1
 ldr w9,[x19,#420]
 cmp w1,w9
 b.lo .Ltransfer_channel
 add w0,w0,#1
 cmp w0,w26
 b.lo .Ltransfer_coefficient
.Ltransfer_finish_count:
 cmp w21,#0
 ldp x9,x10,[x22]
 csel x9,x9,x10,eq
 ldp x10,x11,[x22,#16]
 csel x10,x10,x11,eq
 add x9,x9,x10,lsl#3
 cmp x23,x9
 b.ne .Lmpi_fatal
.Ltransfer_done:
 ldr x28,[sp,#80]
 ldp x26,x27,[sp,#64]
 ldp x24,x25,[sp,#48]
 ldp x22,x23,[sp,#32]
 ldp x20,x21,[sp,#16]
 ldp x29,x30,[sp],#128
 ret
/* w0 source ring distance,w1 receive1/send0. */
.Lring_peer:
 ldr w9,[x19,#380]
 sub w9,w9,#1
 ldr w10,[x19,#372]
 cbnz w1,.Lring_receive
 add w0,w9,w0
 udiv w11,w0,w10
 msub w0,w11,w10,w0
 ret
.Lring_receive:
 add w9,w9,w10
 sub w0,w9,w0
 udiv w11,w0,w10
 msub w0,w11,w10,w0
 ret

.Lcommunicate:
 stp x29,x30,[sp,#-96]!
 stp x20,x21,[sp,#16]
 stp x22,x23,[sp,#32]
 stp x24,x25,[sp,#48]
 stp x26,x27,[sp,#64]
 ldr w24,[x19,#372]
 cmp w24,#1
 b.eq .Lcommunication_done
 ldr x20,[x19,#440]
 ldr w25,[x19,#376]
 sub w25,w25,#1
 mul w25,w25,w24
 ldr w9,[x19,#352]
 mov w10,#200
 mov w26,#1000
 madd w26,w9,w10,w26
 mov w22,#1
 /* Receives use the backward source ring. */
.Lpost_receives:
 mov w0,w22
 mov w1,#1
 bl .Lring_peer
 mov w23,w0
 mov x9,#64
 madd x21,x23,x9,x20
 ldr x0,[x21,#8]
 cbz x0,.Lpost_receive_next
 ldr w1,[x21,#24]
 IMM w2,0x4c00080b
 add w3,w25,w23
 mov w4,w26
 ldr w5,[x19,#356]
 ldr x6,[x19,#928]
 add x6,x6,x23,lsl#2
 SERVICE MPI_Irecv
.Lpost_receive_next:
 add w22,w22,#1
 cmp w22,w24
 b.lo .Lpost_receives
 /* Complete packing before the first source send. */
 mov w22,#1
.Lpack_all:
 mov w0,w22
 mov w1,#0
 bl .Lring_peer
 mov w1,#0
 bl .Lpeer_transfer
 add w22,w22,#1
 cmp w22,w24
 b.lo .Lpack_all
 mov w22,#1
.Lpost_sends:
 mov w0,w22
 mov w1,#0
 bl .Lring_peer
 mov w23,w0
 mov x9,#64
 madd x21,x23,x9,x20
 ldr x0,[x21]
 cbz x0,.Lpost_send_next
 ldr w1,[x21,#16]
 IMM w2,0x4c00080b
 add w3,w25,w23
 mov w4,w26
 ldr w5,[x19,#356]
 ldr x6,[x19,#920]
 add x6,x6,x23,lsl#2
 SERVICE MPI_Isend
.Lpost_send_next:
 add w22,w22,#1
 cmp w22,w24
 b.lo .Lpost_sends
 mov w0,w24
 ldr x1,[x19,#928]
 ldr x2,[x19,#936]
 SERVICE MPI_Waitall
 mov w22,#1
.Lunpack_all:
 mov w0,w22
 mov w1,#1
 bl .Lring_peer
 mov w23,w0
 mov x9,#64
 madd x21,x23,x9,x20
 ldr x9,[x21,#8]
 cbz x9,.Lunpack_next
 ldr x0,[x19,#936]
 mov x9,#20
 madd x0,x23,x9,x0
 IMM w1,0x4c00080b
 add x2,x19,#888
 SERVICE MPI_Get_count
 ldr w9,[x19,#888]
 ldr w10,[x21,#24]
 cmp w9,w10
 b.ne .Lmpi_fatal
 mov w0,w23
 mov w1,#1
 bl .Lpeer_transfer
.Lunpack_next:
 add w22,w22,#1
 cmp w22,w24
 b.lo .Lunpack_all
 mov w0,w24
 ldr x1,[x19,#920]
 mov x2,#1
 SERVICE MPI_Waitall
.Lcommunication_done:
 ldp x26,x27,[sp,#64]
 ldp x24,x25,[sp,#48]
 ldp x22,x23,[sp,#32]
 ldp x20,x21,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.section .rodata
.Lordinary_indices: .byte 0,1,2,3,4,5,8
.section .note.GNU-stack,"",%progbits

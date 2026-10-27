/* Contract skills/md2asm/references/openifs/output/runtime_physical_grid_output.md. */
/* Original HPOS selected ECMWF model-grid output.
 * The common context follows the 29 original address arguments.
 * Storage and limits are recorded in the runtime physical grid output contract. */
.arch armv8.2-a
.text
.p2align 4
.macro HC reg,value
 movz \reg,#(\value&65535)
 movk \reg,#((\value>>16)&65535),lsl#16
.endm
.macro HNOALIAS base,bytes
 adds x17,\base,\bytes
 b.cs .Lh_bad
 ldr x16,[x29,#392]
 add x16,x19,x16
 cmp \base,x16
 b.hs 991f
 cmp x19,x17
 b.lo .Lh_bad
991:
.endm
.global md2asm_runtime_hpos
.type md2asm_runtime_hpos,%function
md2asm_runtime_hpos:
 sub sp,sp,#512
 stp x0,x1,[sp]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x19,x20,[sp,#256]
 stp x21,x22,[sp,#272]
 stp x23,x24,[sp,#288]
 stp x25,x26,[sp,#304]
 stp x27,x28,[sp,#320]
 stp x29,x30,[sp,#336]
 str x18,[sp,#352]
 mov x29,sp
 add x9,sp,#512
 add x10,sp,#64
 mov x11,#21
.Lh_arguments:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lh_arguments
 ldr x28,[sp,#680]
 str x28,[sp,#232]
 cbz x28,.Lh_bad
 tst x28,#7
 b.ne .Lh_bad
 adds x9,x28,#128
 b.cs .Lh_bad
 mrs x9,fpcr
 cbnz x9,.Lh_bad
 ldr x19,[sp,#224]
 cbz x19,.Lh_bad
 tst x19,#7
 b.ne .Lh_bad
 /* Complete formal record admission before their metadata is read. */
 adrp x9,.Lh_record_sizes
 add x9,x9,:lo12:.Lh_record_sizes
 mov x10,#0
.Lh_records:
 ldr x11,[x29,x10,lsl#3]
 cbz x11,.Lh_bad
 mov x12,#7
 cmp x10,#4
 b.eq .Lh_int_record
 cmp x10,#8
 b.lo .Lh_record_align
.Lh_int_record:
 mov x12,#3
.Lh_record_align:
 tst x11,x12
 b.ne .Lh_bad
 ldr w12,[x9,x10,lsl#2]
 adds x12,x11,x12
 b.cs .Lh_bad
 add x10,x10,#1
 cmp x10,#10
 b.lo .Lh_records
 ldr x20,[x29,#24]
 ldr x21,[x29,#48]
 ldr x9,[x29,#32]
 ldr w9,[x9]
 cbnz w9,.Lh_bad
 ldr x9,[x29,#16]
 ldr w9,[x9,#52]
 cbnz w9,.Lh_bad
 ldr x10,[x29,#56]
 HC x9,1577888
 ldr w9,[x10,x9]
 cmp w9,#1
 b.ne .Lh_bad
 HC x9,4143772
 ldr w9,[x10,x9]
 cbnz w9,.Lh_bad
 HC x9,1562916
 ldr w9,[x10,x9]
 cbnz w9,.Lh_bad
 HC x9,1577368
 ldr w9,[x10,x9]
 sub w11,w9,#1
 cmp w11,#255
 b.hi .Lh_bad
 str w9,[x29,#404]
 HC x9,1577392
 ldr w9,[x10,x9]
 sub w11,w9,#1
 cmp w11,#5
 b.hi .Lh_bad
 str w9,[x29,#408]
 ldr x9,[x28,#80]
 cbz x9,.Lh_bad
 tst x9,#3
 b.ne .Lh_bad
 ldr w9,[x9]
 cbnz w9,.Lh_bad
 ldr x9,[x28,#40]
 cbz x9,.Lh_bad
 tst x9,#7
 b.ne .Lh_bad
 ldr x10,[x29,#40]
 ldr x11,[x9]
 cmp x11,x10
 b.ne .Lh_bad
 ldr w11,[x9,#16]
 cmp w11,#7
 b.ne .Lh_bad
 ldr w22,[x10,#5144]
 sub w11,w22,#1
 cmp w11,#1023
 b.hi .Lh_bad
 str w22,[x29,#240]
 ldr w12,[x10,#7376]
 cmp w12,#0
 b.le .Lh_bad
 sub w13,w12,#1
 udiv w13,w13,w22
 add w13,w13,#1
 ldr w14,[x10,#5160]
 cmp w13,w14
 b.ne .Lh_bad
 ldr x9,[x29,#64]
 ldr w24,[x9]
 cmp w24,#1
 b.lt .Lh_bad
 cmp w24,w22
 b.gt .Lh_bad
 str w24,[x29,#248]
 ldr x9,[x29,#72]
 ldr w9,[x9]
 cmp w9,#1
 b.lt .Lh_bad
 cmp w9,w12
 b.gt .Lh_bad
 str w9,[x29,#252]
 sub w9,w9,#1
 udiv w10,w9,w22
 msub w11,w10,w22,w9
 cbnz w11,.Lh_bad
 sub w12,w12,w9
 cmp w12,w22
 csel w12,w12,w22,lo
 cmp w12,w24
 b.ne .Lh_bad
 ldr x9,[x29]
 ldr w23,[x9]
 sub w10,w23,#1
 mov w11,#1638
 cmp w10,w11
 b.hi .Lh_bad
 str w23,[x29,#244]
 add x9,x9,#8
 ldr x10,[x9]
 cbz x10,.Lh_bad
 tst x10,#3
 b.ne .Lh_bad
 ldr x11,[x9,#8]
 cmn x11,#1
 b.ne .Lh_bad
 ldr x11,[x9,#16]
 cmp x11,#4
 b.ne .Lh_bad
 ldr x11,[x9,#24]
 movz x12,#0x0101,lsl#32
 cmp x11,x12
 b.ne .Lh_bad
 ldr x11,[x9,#32]
 cmp x11,#4
 b.ne .Lh_bad
 ldp x11,x12,[x9,#40]
 cmp x11,#1
 b.ne .Lh_bad
 cmp x12,#1
 b.ne .Lh_bad
 ldr x11,[x9,#56]
 cmp x11,x23
 b.ne .Lh_bad
 umull x11,w22,w23
 lsl x11,x11,#3
 str x11,[x29,#392]
 adds x12,x19,x11
 b.cs .Lh_bad
 ldr x12,[x28,#96]
 cbz x12,.Lh_bad
 mov x13,#0x1000000000
 cmp x12,x13
 b.hi .Lh_bad
 cmp x11,x12
 b.hi .Lh_bad
 /* Plan rows and three source snow vectors are private to this block. */
 lsl x9,x23,#5
 str x9,[x29,#376]
 mov x10,#24
 madd x9,x22,x10,x9
 add x9,x9,#15
 and x9,x9,#-16
 str x9,[x29,#384]
 add x10,x9,#512
 cmp x10,x12
 b.hi .Lh_bad
 sub sp,sp,x9
 mov x25,sp
 ldr x9,[x29,#376]
 add x9,x25,x9
 str x9,[x29,#448]
 add x9,x9,x22,lsl#3
 str x9,[x29,#456]
 add x9,x9,x22,lsl#3
 str x9,[x29,#464]
 str xzr,[x29,#360]
 str xzr,[x29,#368]
 /* The output cannot overwrite any formal input record or code list. */
 adrp x9,.Lh_record_sizes
 add x9,x9,:lo12:.Lh_record_sizes
 mov x10,#0
.Lh_record_disjoint:
 ldr x11,[x29,x10,lsl#3]
 ldr w12,[x9,x10,lsl#2]
 HNOALIAS x11,x12
 add x10,x10,#1
 cmp x10,#10
 b.lo .Lh_record_disjoint
 mov x12,#128
 HNOALIAS x28,x12
 ldr x11,[x28,#24]
 cbz x11,.Lh_bad
 tst x11,#7
 b.ne .Lh_bad
 mov x12,#520
 HNOALIAS x11,x12
 ldr x11,[x28,#32]
 cbz x11,.Lh_bad
 tst x11,#7
 b.ne .Lh_bad
 mov x12,#580
 HNOALIAS x11,x12
 ldr x9,[x29]
 ldr x11,[x9,#8]
 lsl x12,x23,#2
 HNOALIAS x11,x12
 /* Required snow fields are source-defined on this selected route. */
 mov w0,#HPOS_SNOW_F_SLOT
 mov w1,#11
 mov w2,#1
 mov w3,#5
 bl .Lh_resolve_field
 str x0,[x29,#416]
 mov w0,#HPOS_SNOW_R_SLOT
 mov w1,#11
 mov w2,#1
 mov w3,#5
 bl .Lh_resolve_field
 str x0,[x29,#424]
 mov w0,#HPOS_SNOW_T_SLOT
 mov w1,#11
 mov w2,#1
 mov w3,#5
 bl .Lh_resolve_field
 str x0,[x29,#432]
 mov w0,#HPOS_SNOW_W_SLOT
 mov w1,#11
 mov w2,#1
 mov w3,#5
 bl .Lh_resolve_field
 str x0,[x29,#440]
 mov x26,#0
.Lh_plan_next:
 add x27,x25,x26,lsl#5
 stp xzr,xzr,[x27]
 stp xzr,xzr,[x27,#16]
 ldr x9,[x29]
 ldr x9,[x9,#8]
 ldr w8,[x9,x26,lsl#2]
 cmp w8,#1
 b.lt .Lh_bad
 adrp x10,.Lphysical_plan_table
 add x10,x10,:lo12:.Lphysical_plan_table
 mov x11,#103
.Lh_lookup:
 ldr w12,[x10]
 add x12,x20,x12
 ldr w13,[x12,#20]
 cmp w13,w8
 b.eq .Lh_plan_found
 add x10,x10,#24
 subs x11,x11,#1
 b.ne .Lh_lookup
 b .Lh_bad
.Lh_plan_found:
 str x10,[x29,#472]
 ldr w9,[x10,#20]
 cmp w9,#2
 b.lo .Lh_plan_direct
 cmp w9,#5
 b.ls .Lh_plan_snow
 cmp w9,#6
 b.eq .Lh_plan_sum
 cmp w9,#7
 b.eq .Lh_plan_orog
 /* The remaining special field is true or fallback SST. */
 ldr w9,[x10,#4]
 ldr x9,[x21,x9]
 cbz x9,.Lh_bad
 tst x9,#7
 b.ne .Lh_bad
 mov x15,#64
 HNOALIAS x9,x15
 ldr w9,[x9,#24]
 cmp w9,#1
 b.hi .Lh_bad
 cbnz w9,.Lh_plan_direct
 mov w0,#HPOS_SOIL_T_SLOT
 mov w1,#10
 mov w2,#1
 mov w3,#3
 bl .Lh_resolve_field
 b .Lh_plan_store
.Lh_plan_direct:
 ldp w0,w1,[x10,#4]
 ldp w2,w3,[x10,#12]
 bl .Lh_resolve_field
 str x0,[x27]
 ldr x10,[x29,#472]
 ldr w9,[x10,#20]
 cmp w9,#1
 b.ne .Lh_plan_store
 mov w0,#HPOS_CP_SLOT
 mov w1,#16
 mov w2,#1
 mov w3,#0
 bl .Lh_resolve_field
 str x0,[x27,#8]
 mov w9,#1
 str w9,[x27,#16]
 b .Lh_plan_done
.Lh_plan_snow:
 sub w11,w9,#2
 add x11,x29,x11,lsl#2
 ldr w2,[x11,#360]
 add w12,w2,#1
 str w12,[x11,#360]
 cmp w9,#3
 b.hi .Lh_plan_snow_layer
 cbnz w2,.Lh_plan_snow_resolve
 cmp w9,#2
 ldr x0,[x29,#456]
 ldr x12,[x29,#464]
 csel x0,x0,x12,eq
 b .Lh_plan_store
.Lh_plan_snow_layer:
 mov w2,w12
.Lh_plan_snow_resolve:
 ldr w12,[x29,#408]
 cmp w2,w12
 b.hi .Lh_bad
 ldp w0,w1,[x10,#4]
 ldr w3,[x10,#16]
 bl .Lh_resolve_field
 str x0,[x27]
 ldr x10,[x29,#472]
 ldr w9,[x10,#20]
 cmp w9,#4
 b.lo .Lh_plan_store
 mov w9,#2
 str w9,[x27,#16]
 b .Lh_plan_done
.Lh_plan_sum:
 ldr x0,[x29,#448]
 b .Lh_plan_store
.Lh_plan_orog:
 bl .Lh_orography
.Lh_plan_store:
 str x0,[x27]
 cbnz x0,.Lh_plan_done
 mov w9,#3
 str w9,[x27,#16]
.Lh_plan_done:
 add x26,x26,#1
 cmp x26,x23
 b.lo .Lh_plan_next
 /* Retain the source standard-atmosphere initialization. */
 ldr x9,[x28,#24]
 cbz x9,.Lh_bad
 ldr d0,[x9,#8]
 ldr x9,[x28,#32]
 cbz x9,.Lh_bad
 ldr d1,[x9,#72]
 fdiv d2,d1,d0
 /* HPOS initializes the complete block, including final padding. */
 ldr x9,[x29,#392]
 mov x10,x19
.Lh_zero:
 str xzr,[x10],#8
 subs x9,x9,#8
 b.ne .Lh_zero
 bl .Lh_snow_aggregate
 mov x26,#0
.Lh_publish_field:
 add x27,x25,x26,lsl#5
 ldp x10,x11,[x27]
 ldr w12,[x27,#16]
 cmp w12,#3
 b.eq .Lh_publish_next
 mul x9,x26,x22
 add x9,x19,x9,lsl#3
 mov x13,#0
 cbz w12,.Lh_copy_cells
 cmp w12,#1
 b.eq .Lh_add_cells
 fmov d2,xzr
.Lh_clamp_cells:
 ldr d0,[x10,x13,lsl#3]
 fmaxnm d0,d2,d0
 str d0,[x9,x13,lsl#3]
 add x13,x13,#1
 cmp x13,x24
 b.lo .Lh_clamp_cells
 b .Lh_publish_next
.Lh_add_cells:
 ldr d0,[x10,x13,lsl#3]
 ldr d1,[x11,x13,lsl#3]
 fadd d0,d0,d1
 str d0,[x9,x13,lsl#3]
 add x13,x13,#1
 cmp x13,x24
 b.lo .Lh_add_cells
 b .Lh_publish_next
.Lh_copy_cells:
 ldr x14,[x10,x13,lsl#3]
 str x14,[x9,x13,lsl#3]
 add x13,x13,#1
 cmp x13,x24
 b.lo .Lh_copy_cells
.Lh_publish_next:
 add x26,x26,#1
 cmp x26,x23
 b.lo .Lh_publish_field
 mov w0,#0
 b .Lh_return
.Lh_bad:
 mov w0,#2
.Lh_return:
 mov sp,x29
 ldp x19,x20,[sp,#256]
 ldp x21,x22,[sp,#272]
 ldp x23,x24,[sp,#288]
 ldp x25,x26,[sp,#304]
 ldp x27,x28,[sp,#320]
 ldp x29,x30,[sp,#336]
 ldr x18,[sp,#352]
 add sp,sp,#512
 ret
/* Resolve a live named field with its original MP or MP0 index.
 * w0 slot, w1 argument, w2 level, w3 index and LSET policy. */
.Lh_resolve_field:
 ldr x9,[x21,x0]
 cbz x9,.Lh_bad
 tst x9,#7
 b.ne .Lh_bad
 mov x15,#64
 cmp w1,#12
 b.hs .Lh_field_record_size
 mov x15,#288
.Lh_field_record_size:
 HNOALIAS x9,x15
 tst w3,#6
 b.eq .Lh_field_set
 ldr w10,[x9,#24]
 cmp w10,#1
 b.hi .Lh_bad
 cbnz w10,.Lh_field_set
 tbz w3,#1,.Lh_bad
 mov x0,#0
 ret
.Lh_field_set:
 and w10,w3,#1
 ldr w10,[x9,x10,lsl#2]
 cmp w10,#1
 b.lt .Lh_bad
 ldr x11,[x29,x1,lsl#3]
 cbz x11,.Lh_bad
 tst x11,#7
 b.ne .Lh_bad
 mov x15,#88
 cmp w1,#12
 b.hs .Lh_field_descriptor_size
 mov x15,#112
.Lh_field_descriptor_size:
 HNOALIAS x11,x15
 ldr x12,[x11]
 cbz x12,.Lh_bad
 tst x12,#7
 b.ne .Lh_bad
 ldr x13,[x11,#16]
 cmp x13,#8
 b.ne .Lh_bad
 ldr x13,[x11,#32]
 cmp x13,#8
 b.ne .Lh_bad
 ldp x13,x14,[x11,#40]
 cmp x13,#1
 b.ne .Lh_bad
 cmp x14,#1
 b.ne .Lh_bad
 ldr x13,[x11,#56]
 cmp x13,x22
 b.ne .Lh_bad
 ldr x13,[x11,#64]
 cmp x13,x22
 b.ne .Lh_bad
 ldr x13,[x11,#72]
 cmp x13,#1
 b.ne .Lh_bad
 ldr x13,[x11,#80]
 mov x14,#1
 cmp w1,#12
 b.hs .Lh_rank2_field
 ldr w14,[x29,#404]
 cmp w1,#10
 b.eq .Lh_expected_levels
 ldr w14,[x29,#408]
.Lh_expected_levels:
 cmp x13,x14
 b.ne .Lh_bad
 cmp w2,#1
 b.lt .Lh_bad
 cmp x2,x14
 b.hi .Lh_bad
 mul x15,x22,x14
 ldr x13,[x11,#88]
 cmp x13,x15
 b.ne .Lh_bad
 ldr x13,[x11,#96]
 cmp x13,#1
 b.ne .Lh_bad
 ldr x13,[x11,#104]
 movz x15,#0x0303,lsl#32
 b .Lh_field_dtype
.Lh_rank2_field:
 movz x15,#0x0302,lsl#32
.Lh_field_dtype:
 ldr x16,[x11,#24]
 cmp x16,x15
 b.ne .Lh_bad
 cmp x13,#1
 b.lt .Lh_bad
 mov x15,#65536
 cmp x13,x15
 b.hi .Lh_bad
 cmp x10,x13
 b.hi .Lh_bad
 mul x15,x22,x14
 sub x16,xzr,x22
 sub x16,x16,#1
 cmp w1,#12
 b.hs .Lh_field_bias
 sub x16,x16,x15
.Lh_field_bias:
 ldr x17,[x11,#8]
 cmp x16,x17
 b.ne .Lh_bad
 mul x15,x15,x13
 lsl x15,x15,#3
 ldr x16,[x28,#96]
 cmp x15,x16
 b.hi .Lh_bad
 HNOALIAS x12,x15
 sub x10,x10,#1
 mul x10,x10,x14
 cmp w1,#12
 b.hs .Lh_field_element
 sub x13,x2,#1
 add x10,x10,x13
.Lh_field_element:
 mul x10,x10,x22
 add x0,x12,x10,lsl#3
 ret
/* The source YROROG block record owns its first OROG descriptor. */
.Lh_orography:
 ldr x9,[x29,#40]
 add x10,x9,#3,lsl#12
 add x10,x10,#1736
 ldr x11,[x10,#8]
 cmn x11,#1
 b.ne .Lh_bad
 ldr x11,[x10,#16]
 cmp x11,#384
 b.ne .Lh_bad
 ldr x11,[x10,#24]
 movz x12,#0x0501,lsl#32
 cmp x11,x12
 b.ne .Lh_bad
 ldr x11,[x10,#32]
 cmp x11,#384
 b.ne .Lh_bad
 ldp x11,x12,[x10,#40]
 cmp x11,#1
 b.ne .Lh_bad
 cmp x12,#1
 b.ne .Lh_bad
 ldr x11,[x10,#56]
 ldr w12,[x9,#5160]
 cmp x11,x12
 b.ne .Lh_bad
 ldr x10,[x10]
 cbz x10,.Lh_bad
 tst x10,#7
 b.ne .Lh_bad
 mov x12,#384
 mul x12,x11,x12
 HNOALIAS x10,x12
 ldr w11,[x29,#252]
 sub w11,w11,#1
 udiv w11,w11,w22
 mov x12,#384
 madd x10,x11,x12,x10
 HNOALIAS x10,x12
 ldr x0,[x10]
 cbz x0,.Lh_bad
 tst x0,#7
 b.ne .Lh_bad
 ldr x11,[x10,#16]
 cmp x11,#8
 b.ne .Lh_bad
 ldr x11,[x10,#24]
 movz x12,#0x0301,lsl#32
 cmp x11,x12
 b.ne .Lh_bad
 ldr x11,[x10,#8]
 cmn x11,#1
 b.ne .Lh_bad
 ldr x11,[x10,#40]
 cmp x11,#1
 b.ne .Lh_bad
 ldr x11,[x10,#48]
 cmp x11,#1
 b.ne .Lh_bad
 ldr x11,[x10,#56]
 cmp x11,x22
 b.lo .Lh_bad
 lsl x12,x22,#3
 HNOALIAS x0,x12
 ret
/* Source layer-ordered mass and depth sums with the first-layer fallback. */
.Lh_snow_aggregate:
 ldp x10,x11,[x29,#416]
 ldr x12,[x29,#432]
 ldr x13,[x29,#448]
 ldp x14,x15,[x29,#456]
 ldr w16,[x29,#408]
 mov x9,#0
 cmp w16,#1
 b.eq .Lh_single_snow
.Lh_snow_point:
 fmov d0,xzr
 fmov d1,xzr
 mov x0,x9
 mov x1,#0
.Lh_snow_layer:
 ldr d2,[x10,x0,lsl#3]
 fcmp d2,#0.0
 b.le .Lh_snow_layer_next
 fadd d0,d0,d2
 ldr d3,[x11,x0,lsl#3]
 fdiv d2,d2,d3
 fadd d1,d1,d2
.Lh_snow_layer_next:
 add x0,x0,x22
 add x1,x1,#1
 cmp x1,x16
 b.lo .Lh_snow_layer
 fcmp d0,#0.0
 b.le .Lh_snow_fallback
 fcmp d1,#0.0
 b.le .Lh_snow_fallback
 fdiv d2,d0,d1
 b .Lh_snow_save
.Lh_snow_fallback:
 ldr d2,[x11,x9,lsl#3]
.Lh_snow_save:
 str d0,[x13,x9,lsl#3]
 str d2,[x14,x9,lsl#3]
 ldr x0,[x12,x9,lsl#3]
 str x0,[x15,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x24
 b.lo .Lh_snow_point
 ret
.Lh_single_snow:
 ldr x0,[x10,x9,lsl#3]
 str x0,[x13,x9,lsl#3]
 ldr x0,[x11,x9,lsl#3]
 str x0,[x14,x9,lsl#3]
 ldr x0,[x12,x9,lsl#3]
 str x0,[x15,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x24
 b.lo .Lh_single_snow
 ret
.size md2asm_runtime_hpos,.-md2asm_runtime_hpos
.section .rodata
.p2align 2
.Lh_record_sizes:
 .word 744,744,312,497368,4,20400,18224,4275088,4,4
/* Source-selected physical field map with live ICOD and MP indices. */
.equ HPOS_SNOW_W_SLOT,6264
.equ HPOS_SNOW_T_SLOT,6256
.equ HPOS_SNOW_R_SLOT,6248
.equ HPOS_SNOW_F_SLOT,6232
.equ HPOS_SOIL_T_SLOT,5944
.equ HPOS_CP_SLOT,12672
.p2align 2
.Lphysical_plan_table:
 .word 356976,13792,16,1,0,0 /* GFP%EC10FG source line1640 */
 .word 357168,13872,16,1,0,0 /* GFP%I10FG source line1647 */
 .word 325168,12768,16,1,0,0 /* GFP%EC10U source line1476 */
 .word 325232,12776,16,1,0,0 /* GFP%EC10V source line1478 */
 .word 325424,12792,16,1,0,0 /* GFP%EC2D source line1486 */
 .word 325360,12784,16,1,0,0 /* GFP%EC2T source line1484 */
 .word 327856,13096,16,1,0,0 /* GFP%ALB source line1552 */
 .word 356016,6240,11,1,1,0 /* GFP%ASN source line556 */
 .word 324592,12696,16,1,0,0 /* GFP%BLD source line1464 */
 .word 348656,13504,16,1,0,0 /* GFP%BLH source line1624 */
 .word 348592,15376,15,1,0,0 /* GFP%CHAR source line1771 */
 .word 355952,9168,18,1,0,0 /* GFP%CI source line522 */
 .word 324336,12672,16,1,0,0 /* GFP%CP source line1455 */
 .word 327344,13344,16,1,0,0 /* GFP%CRR source line1584 */
 .word 327472,13360,16,1,0,0 /* GFP%CSFR source line1588 */
 .word 325936,12856,16,1,0,0 /* GFP%E source line1502 */
 .word 356784,13776,16,1,0,0 /* GFP%ES source line1636 */
 .word 325808,12840,16,1,0,0 /* GFP%EWSS source line1498 */
 .word 324528,12688,16,1,0,0 /* GFP%FZRA source line1462 */
 .word 319536,0,0,0,0,7 /* GFP%GFIS source line1197 */
 .word 326448,12920,16,1,0,0 /* GFP%GWD source line1518 */
 .word 326256,12896,16,1,0,0 /* GFP%HCC source line1512 */
 .word 328112,13128,16,1,0,0 /* GFP%IE source line1560 */
 .word 327920,13104,16,1,0,0 /* GFP%IEWSS source line1554 */
 .word 327984,13112,16,1,0,0 /* GFP%INSSS source line1556 */
 .word 328048,13120,16,1,0,0 /* GFP%ISSHF source line1558 */
 .word 356272,5960,10,1,1,0 /* GFP%ISTL1 source line510 */
 .word 356336,5960,10,2,1,0 /* GFP%ISTL2 source line513 */
 .word 356400,5960,10,3,1,0 /* GFP%ISTL3 source line516 */
 .word 356464,5960,10,4,1,0 /* GFP%ISTL4 source line519 */
 .word 326128,12880,16,1,0,0 /* GFP%LCC source line1508 */
 .word 326320,12904,16,1,0,0 /* GFP%LGWS source line1514 */
 .word 327280,13336,16,1,0,0 /* GFP%LSRR source line1582 */
 .word 327408,13352,16,1,0,0 /* GFP%LSSFR source line1586 */
 .word 319472,8992,18,1,4,0 /* GFP%LSM source line424 */
 .word 324272,12664,16,1,0,0 /* GFP%LSP source line1453 */
 .word 356912,13880,16,1,0,0 /* GFP%LSPF source line1649 */
 .word 327600,13376,16,1,0,0 /* GFP%ILSPF source line1592 */
 .word 328624,13392,16,1,0,0 /* GFP%LZ0H source line1596 */
 .word 326192,12888,16,1,0,0 /* GFP%MCC source line1510 */
 .word 326384,12912,16,1,0,0 /* GFP%MGWS source line1516 */
 .word 326576,12936,16,1,0,0 /* GFP%MN2T source line1522 */
 .word 324976,12744,16,1,0,0 /* GFP%MSLD source line1470 */
 .word 326512,12928,16,1,0,0 /* GFP%MX2T source line1520 */
 .word 325872,12848,16,1,0,0 /* GFP%NSSS source line1500 */
 .word 326000,12864,16,1,0,0 /* GFP%PEV source line1504 */
 .word 327536,13368,16,1,0,0 /* GFP%PTYPE source line1590 */
 .word 327664,13072,16,1,0,0 /* GFP%RO source line1534 */
 .word 327728,13080,16,1,0,0 /* GFP%SRO source line1536 */
 .word 327792,13088,16,1,0,0 /* GFP%SSRO source line1538 */
 .word 324464,12680,16,1,0,0 /* GFP%SF source line1460 */
 .word 324208,6808,13,1,3,0 /* GFP%SKT source line480 */
 .word 324720,12712,16,1,0,0 /* GFP%SLHF source line1468 */
 .word 356848,13784,16,1,0,0 /* GFP%SMLT source line1638 */
 .word 324144,6816,13,1,3,0 /* GFP%SRC source line495 */
 .word 324656,12704,16,1,0,0 /* GFP%SSHF source line1466 */
 .word 325552,12808,16,1,0,0 /* GFP%SSR source line1490 */
 .word 356656,13760,16,1,0,0 /* GFP%SSRC source line1632 */
 .word 328816,13472,16,1,0,0 /* GFP%SSRD source line1616 */
 .word 356208,9048,18,1,0,8 /* GFP%SST source line470 */
 .word 422000,9176,18,1,0,0 /* GFP%UCUR source line1877 */
 .word 422064,9184,18,1,0,0 /* GFP%VCUR source line1884 */
 .word 323312,5944,10,1,1,0 /* GFP%STL1 source line483 */
 .word 323376,5944,10,2,1,0 /* GFP%STL2 source line486 */
 .word 323440,5944,10,3,1,0 /* GFP%STL3 source line489 */
 .word 323504,5944,10,4,1,0 /* GFP%STL4 source line492 */
 .word 325616,12816,16,1,0,0 /* GFP%STR source line1492 */
 .word 356720,13768,16,1,0,0 /* GFP%STRC source line1634 */
 .word 328880,13480,16,1,0,0 /* GFP%STRD source line1618 */
 .word 348528,13512,16,1,0,0 /* GFP%SUND source line1626 */
 .word 323568,5952,10,1,1,0 /* GFP%SWL1 source line498 */
 .word 323632,5952,10,2,1,0 /* GFP%SWL2 source line501 */
 .word 323696,5952,10,3,1,0 /* GFP%SWL3 source line504 */
 .word 323760,5952,10,4,1,0 /* GFP%SWL4 source line507 */
 .word 325104,12760,16,1,0,0 /* GFP%TCC source line1474 */
 .word 329072,13888,16,1,0,0 /* GFP%TCO3 source line1653 */
 .word 320304,6232,11,1,1,4 /* GFP%SD source line1015 */
 .word 320368,6232,11,1,1,6 /* GFP%SDSL source line1027 */
 .word 323824,6256,11,1,1,3 /* GFP%TSN source line544 */
 .word 356080,6248,11,1,1,2 /* GFP%RSN source line559 */
 .word 356144,6264,11,1,1,5 /* GFP%WSN source line579 */
 .word 328688,13416,16,1,0,0 /* GFP%TCW source line1602 */
 .word 328752,13424,16,1,0,0 /* GFP%TCWV source line1604 */
 .word 348784,13432,16,1,0,0 /* GFP%TCLW source line1606 */
 .word 348848,13440,16,1,0,0 /* GFP%TCIW source line1608 */
 .word 348912,13448,16,1,0,0 /* GFP%TCRW source line1610 */
 .word 348976,13456,16,1,0,0 /* GFP%TCSW source line1612 */
 .word 324400,12664,16,1,0,1 /* GFP%TP source line1458 */
 .word 325680,12824,16,1,0,0 /* GFP%TSR source line1494 */
 .word 356528,13744,16,1,0,0 /* GFP%TSRC source line1628 */
 .word 325744,12832,16,1,0,0 /* GFP%TTR source line1496 */
 .word 356592,13752,16,1,0,0 /* GFP%TTRC source line1630 */
 .word 358832,13896,16,1,0,0 /* GFP%VIMD source line1651 */
 .word 359088,13944,16,1,0,0 /* GFP%VISIH source line1809 */
 .word 328560,13384,16,1,0,0 /* GFP%Z0F source line1594 */
 .word 359152,13952,16,1,0,0 /* GFP%CIN source line1811 */
 .word 359344,13976,16,1,0,0 /* GFP%KINDEX source line1817 */
 .word 359408,13984,16,1,0,0 /* GFP%TTINDEX source line1819 */
 .word 357808,13520,16,1,0,0 /* GFP%SPAR source line1773 */
 .word 357872,13528,16,1,0,0 /* GFP%SUVB source line1775 */
 .word 357936,13560,16,1,0,0 /* GFP%CAPE source line1777 */
 .word 358576,13912,16,1,0,0 /* GFP%STINC source line1797 */
 .word 358768,13552,16,1,0,0 /* GFP%SDSRP source line1998 */

.section .note.GNU-stack,"",%progbits

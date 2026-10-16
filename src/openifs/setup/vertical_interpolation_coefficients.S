/* Complete selected SUVSLETA numerical setup from its frozen source contract.
 * Contract skills/md2asm/references/openifs/dynamics/vertical_interpolation_coefficients.md.
 * All source-unwritten owner bytes retain their ordinary allocation preimages. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.macro GEOM_ARRAY record,desc,lo,extra,slot
 ldr x9,[x19,#\record]
 cbz x9,.Lreject
 tst x9,#7
 b.ne .Lreject
 add x9,x9,#\desc
 mov x10,#\lo
 add x11,x21,#\extra
 bl .Lcheck_array
 cbz x0,.Lreject
 str x0,[sp,#\slot]
.endm
.p2align 4
.global md2asm_initialize_vertical_interpolation_coefficients
.type md2asm_initialize_vertical_interpolation_coefficients,%function
md2asm_initialize_vertical_interpolation_coefficients:
 cbz x0,.Lbad_leaf
 cbz x2,.Lbad_leaf
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lbad_leaf
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad_leaf
 adds x10,x0,x9
 b.cs .Lbad_leaf
 MADDR x9,xzr,4275088
 cmp x3,x9
 b.lo .Lbad_leaf
 adds x11,x2,x9
 b.cs .Lbad_leaf
 cmp x10,x2
 b.ls .Ldisjoint
 cmp x11,x0
 b.hi .Lbad_leaf
.Ldisjoint:
 mrs x9,fpcr
 cbnz x9,.Lbad_leaf
 mov x9,#5224
 ldr w10,[x0,x9]
 sub w11,w10,#4
 cmp w11,#251
 b.hi .Lbad_leaf
 MADDR x9,x2,1564212
 ldr w9,[x9]
 cbnz w9,.Lbad_leaf
 MADDR x9,x2,1564244
 ldr w9,[x9]
 cbnz w9,.Lbad_leaf
 MADDR x9,x2,1564444
 ldr w9,[x9]
 cbnz w9,.Lbad_leaf
 MADDR x9,x2,1564464
 ldr w9,[x9]
 cbnz w9,.Lbad_leaf
 MADDR x9,x2,1564368
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lbad_leaf
 MADDR x9,x2,1564288
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lbad_leaf
 adr x4,.Lowners
 mov x5,#0
.Lfresh:
 ldr x9,[x4],#32
 ldr x9,[x2,x9]
 cbnz x9,.Lbad_leaf
 add x5,x5,#1
 cmp x5,#12
 b.lo .Lfresh
 sub sp,sp,#512
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 mov x19,x0
 mov x20,x2
 mov x9,#5224
 ldr w21,[x19,x9]
 mov x26,#0
 str xzr,[sp,#160]
 add x9,sp,#240
 mov x10,#6
.Lclear_temporaries:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lclear_temporaries
 GEOM_ARRAY 3248,128,0,1,184
 GEOM_ARRAY 3248,0,0,0,192
 ldr x22,[sp,#184]
 ldr x23,[sp,#192]
 ldr x9,[x19,#3264]
 cbz x9,.Lreject
 tst x9,#7
 b.ne .Lreject
 ldr w9,[x9,#16]
 cmp w9,#1
 b.hi .Lreject
 str w9,[sp,#232]
 /* Compare finite coordinates without adding arithmetic to the source stream. */
 mov x25,x22
 add x24,x21,#2
 bl .Lmonotone
 cbnz w0,.Lreject
 mov x25,x23
 add x24,x21,#1
 bl .Lmonotone
 cbnz w0,.Lreject
 MADDR x9,x20,1564288
 ldr w9,[x9]
 str w9,[sp,#224]
 cbz w9,.Linputs_ready
 MADDR x9,x20,1564296
 mov x10,#5
.Lfilter_constants:
 ldr x11,[x9],#8
 ubfx x12,x11,#52,#11
 cmp x12,#2047
 b.eq .Lreject
 subs x10,x10,#1
 b.ne .Lfilter_constants
 MADDR x9,x20,1564296
 ldr d0,[x9]
 fcmp d0,#0.0
 b.lt .Lreject
 ldr d0,[x9,#8]
 fcmp d0,#0.0
 b.lt .Lreject
 ldr d0,[x9,#16]
 fcmp d0,#0.0
 b.lt .Lreject
 fmov d1,#1.0
 fcmp d0,d1
 b.gt .Lreject
 ldr d0,[x9,#24]
 fcmp d0,#0.0
 b.le .Lreject
 ldr d0,[x9,#32]
 fcmp d0,#0.0
 b.le .Lreject
 add x9,x19,#3336
 mov x10,#1
 mov x11,x21
 bl .Lcheck_array
 cbz x0,.Lreject
 str x0,[sp,#216]
 MADDR x9,x20,1564304
 ldr d0,[x9]
 fcmp d0,#0.0
 b.ne .Lborrow_half_pressure
 GEOM_ARRAY 3240,64,0,0,200
 b .Linputs_ready
.Lborrow_half_pressure:
 add x9,x19,#3272
 mov x10,#0
 mov x11,x21
 bl .Lcheck_array
 cbz x0,.Lreject
 str x0,[sp,#208]
.Linputs_ready:
 add x0,x21,x21
 add x0,x0,#1
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#160]
 add x9,x21,#1
 add x9,x0,x9,lsl#3
 str x9,[sp,#176]
 ldr w9,[sp,#224]
 cbz w9,.Lmask_done
 mov x24,#0
.Lmask_zero:
 str xzr,[x0,x24,lsl#3]
 add x24,x24,#1
 cmp x24,x21
 b.ls .Lmask_zero
 MADDR x9,x20,1564304
 ldr d0,[x9]
 fcmp d0,#0.0
 b.ne .Lmask_pressure
 ldr x25,[sp,#200]
 mov x24,#0
 fmov d1,#1.0
.Lmask_pure_pressure:
 ldr d0,[x25,x24,lsl#3]
 fcmp d0,#0.0
 b.ne .Lmask_strength
 str d1,[x0,x24,lsl#3]
 add x24,x24,#1
 cmp x24,x21
 b.ls .Lmask_pure_pressure
 b .Lmask_strength
.Lmask_pressure:
 ldr x25,[sp,#208]
 mov x24,#1
 mov x10,#0
.Lcount_pressure:
 ldr d1,[x25,x24,lsl#3]
 fcmp d1,d0
 cinc x10,x10,le
 add x24,x24,#1
 cmp x24,x21
 b.ls .Lcount_pressure
 mov x24,#0
 fmov d1,#1.0
.Lmask_selected:
 str d1,[x0,x24,lsl#3]
 add x24,x24,#1
 cmp x24,x10
 b.ls .Lmask_selected
.Lmask_strength:
 MADDR x9,x20,1564296
 ldr d8,[x9]
 ldr d9,[x9,#16]
 ldr d10,[x9,#24]
 ldr d11,[x9,#32]
 fmov d14,#1.0
 mov x24,#0
 ldr x25,[sp,#216]
.Lstrength_level:
 ldr d0,[x25,x24,lsl#3]
 fsub d0,d14,d0
 fdiv d0,d0,d11
 bl md2asm_exp_original_rounding
 fdiv d0,d0,d10
 fadd d0,d14,d0
 fsub d12,d14,d9
 fmul d12,d12,d14
 fdiv d12,d12,d0
 fadd d12,d9,d12
 fmul d12,d8,d12
 ldr x9,[sp,#176]
 str d12,[x9,x24,lsl#3]
 add x24,x24,#1
 cmp x24,x21
 b.lo .Lstrength_level
.Lmask_done:
 mov x28,#0
.Lcoefficient_group:
 add x27,x26,#4
.Lallocate_group:
 bl .Lallocate_one
 cbnz w0,.Lallocation_failed
 cmp x26,x27
 b.lo .Lallocate_group
 cmp x28,#0
 csel x25,x22,x23,eq
 bl .Lcoefficient_values
 add x28,x28,#1
 cmp x28,#2
 b.lo .Lcoefficient_group
 bl .Lallocate_one
 cbnz w0,.Lallocation_failed
 ldr w9,[sp,#232]
 cbnz w9,.Lgamma_done
 mov x24,#2
 sub x25,x21,#4
 cmp x24,x25
 b.gt .Lgamma_done
.Lgamma_level:
 sub x9,x24,#1
 ldr d8,[x22,x9,lsl#3]
 ldr d9,[x22,x24,lsl#3]
 add x9,x24,#3
 ldr d10,[x22,x9,lsl#3]
 add x9,x24,#4
 ldr d11,[x22,x9,lsl#3]
 fsub d0,d8,d10
 fsub d1,d8,d11
 fsub d2,d9,d10
 fsub d3,d9,d11
 fsub d4,d9,d8
 ldr x10,[sp,#304]
 sub x9,x24,#1
 add x10,x10,x9,lsl#3
 fmov d14,#1.0
 fmul d5,d0,d1
 fdiv d6,d14,d5
 add x11,x21,x21
 str d6,[x10,x11,lsl#3]
 fmul d6,d1,d3
 fdiv d6,d14,d6
 str d6,[x10,x21,lsl#3]
 fmul d6,d2,d3
 fdiv d6,d6,d5
 fsub d6,d14,d6
 fmul d7,d4,d3
 fdiv d6,d6,d7
 str d6,[x10]
 add x24,x24,#1
 cmp x24,x25
 b.ls .Lgamma_level
.Lgamma_done:
 fmov d8,#1.0
 mov x24,#1
.Lminimum_spacing:
 ldr d0,[x23,x24,lsl#3]
 sub x9,x24,#1
 ldr d1,[x23,x9,lsl#3]
 fsub d0,d0,d1
 fcmp d8,d0
 fcsel d8,d8,d0,le
 add x24,x24,#1
 cmp x24,x21
 b.ls .Lminimum_spacing
 fmov d0,#2.0
 fdiv d0,d0,d8
 fmov d1,#0.5
 fadd d0,d0,d1
 fcvtas w9,d0
 add w9,w9,#1
 cmp w9,#1
 b.lt .Lreject
 movz w10,#(2000000 & 65535)
 movk w10,#(2000000 >> 16),lsl#16
 cmp w9,w10
 b.gt .Lreject
 str w9,[sp,#336]
 scvtf d8,w9
 str d8,[sp,#344]
 add x9,x21,#1
 ldr d0,[x22,x9,lsl#3]
 ldr d1,[x22]
 fsub d0,d0,d1
 fdiv d8,d0,d8
 str d8,[sp,#352]
 bl .Lallocate_one
 cbnz w0,.Lallocation_failed
 mov x28,#0
.Llookup_group:
 mov x24,#0
 mov x10,#1
 ldr w25,[sp,#336]
 cmp x28,#0
 ldr x11,[sp,#312]
 ldr x12,[sp,#320]
 csel x11,x11,x12,eq
.Llookup_position:
 scvtf d0,x24
 fmul d0,d0,d8
 cmp x28,#0
 b.ne .Lhalf_lookup_coordinate
 add x9,x10,#1
 ldr d1,[x22,x9,lsl#3]
 b .Llookup_compare
.Lhalf_lookup_coordinate:
 ldr d1,[x23,x10,lsl#3]
.Llookup_compare:
 fcmp d0,d1
 b.lt .Llookup_store
 sub x9,x21,#1
 cmp x10,x9
 cinc x10,x10,lt
.Llookup_store:
 str w10,[x11,x24,lsl#2]
 add x24,x24,#1
 cmp x24,x25
 b.ls .Llookup_position
 cbnz x28,.Llookup_done
 bl .Lallocate_one
 cbnz w0,.Lallocation_failed
 mov x28,#1
 b .Llookup_group
.Llookup_done:
 bl .Lallocate_one
 cbnz w0,.Lallocation_failed
 ldr x10,[sp,#328]
 mov x24,#2
.Lspacing_ratios:
 ldr d0,[x23,x24,lsl#3]
 sub x9,x24,#1
 ldr d1,[x23,x9,lsl#3]
 fsub d0,d0,d1
 sub x9,x24,#2
 ldr d2,[x23,x9,lsl#3]
 fsub d1,d1,d2
 fdiv d0,d0,d1
 sub x9,x24,#1
 str d0,[x10,x9,lsl#3]
 add x24,x24,#1
 cmp x24,x21
 b.ls .Lspacing_ratios
 fmov d0,#1.0
 str d0,[x10]
 bl .Lpublish
 MADDR x9,x20,1572472
 ldr w10,[sp,#336]
 str w10,[x9]
 ldr d0,[sp,#344]
 str d0,[x9,#8]
 ldr x0,[sp,#160]
 bl free
 mov w0,#0
 b .Ldone
.Lallocation_failed:
 mov w28,#1
 b .Lrollback
.Lreject:
 mov w28,#2
.Lrollback:
 cbz x26,.Lfree_scratch
 sub x26,x26,#1
 add x9,sp,#240
 ldr x0,[x9,x26,lsl#3]
 bl free
 b .Lrollback
.Lfree_scratch:
 ldr x0,[sp,#160]
 cbz x0,.Lfailed_status
 bl free
.Lfailed_status:
 mov w0,w28
.Ldone:
 ldp d14,d15,[sp,#144]
 ldp d12,d13,[sp,#128]
 ldp d10,d11,[sp,#112]
 ldp d8,d9,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#512
 ret
.size md2asm_initialize_vertical_interpolation_coefficients,.-md2asm_initialize_vertical_interpolation_coefficients
/* Typed array bounds and finite elements. No floating-point arithmetic. */
.Lcheck_array:
 ldr x0,[x9]
 cbz x0,.Larray_bad
 tst x0,#7
 b.ne .Larray_bad
 ldr x12,[x9,#8]
 neg x13,x10
 cmp x12,x13
 b.ne .Larray_bad
 ldr x12,[x9,#16]
 cmp x12,#8
 b.ne .Larray_bad
 ldr w12,[x9,#24]
 cbnz w12,.Larray_bad
 ldr w12,[x9,#28]
 mov w13,#0x301
 cmp w12,w13
 b.ne .Larray_bad
 ldr x12,[x9,#32]
 cmp x12,#8
 b.ne .Larray_bad
 ldr x12,[x9,#40]
 cmp x12,#1
 b.ne .Larray_bad
 ldr x12,[x9,#48]
 cmp x12,x10
 b.ne .Larray_bad
 ldr x12,[x9,#56]
 cmp x12,x11
 b.ne .Larray_bad
 sub x12,x11,x10
 mov x13,#0
.Lfinite_array:
 ldr x14,[x0,x13,lsl#3]
 ubfx x14,x14,#52,#11
 cmp x14,#2047
 b.eq .Larray_bad
 add x13,x13,#1
 cmp x13,x12
 b.ls .Lfinite_array
 ret
.Larray_bad:
 mov x0,#0
 ret
.Lmonotone:
 mov x9,#1
 ldr d0,[x25]
.Lmonotone_element:
 ldr d1,[x25,x9,lsl#3]
 fcmp d1,d0
 b.le .Lmonotone_bad
 fmov d0,d1
 add x9,x9,#1
 cmp x9,x24
 b.lo .Lmonotone_element
 mov w0,#0
 ret
.Lmonotone_bad:
 mov w0,#2
 ret
/* Private source-order allocation. Parent saved registers remain intact. */
.Lallocate_one:
 str x30,[sp,#408]
 adr x9,.Lallocation_multipliers
 ldr x10,[x9,x26,lsl#3]
 mov x11,x21
 cmp x26,#9
 b.lo .Lallocation_size
 cmp x26,#10
 b.hi .Lallocation_size
 ldr w11,[sp,#336]
 add x11,x11,#1
.Lallocation_size:
 mul x0,x10,x11
 bl malloc
 cbz x0,.Lallocate_one_failed
 add x9,sp,#240
 str x0,[x9,x26,lsl#3]
 add x26,x26,#1
 mov w0,#0
 ldr x30,[sp,#408]
 ret
.Lallocate_one_failed:
 mov w0,#1
 ldr x30,[sp,#408]
 ret
/* Full and half coefficients share their exact source difference order. */
.Lcoefficient_values:
 mov x24,#1
 sub x17,x21,#3
 str x17,[sp,#360]
 fmov d14,#1.0
.Lcoefficient_level:
 sub x9,x24,x28
 add x9,x25,x9,lsl#3
 ldp d8,d9,[x9]
 ldp d10,d11,[x9,#16]
 fsub d0,d8,d9
 fsub d1,d8,d10
 fsub d2,d8,d11
 fsub d3,d9,d10
 fsub d4,d9,d11
 fsub d5,d10,d11
 add x9,sp,#240
 lsl x10,x28,#2
 ldr x10,[x9,x10,lsl#3]
 add x10,x10,x24,lsl#5
 fmul d6,d0,d1
 fmul d6,d6,d2
 fdiv d7,d14,d6
 str d7,[x10]
 fmul d6,d0,d3
 fmul d6,d6,d4
 fneg d7,d14
 fdiv d7,d7,d6
 str d7,[x10,#8]
 fmul d6,d1,d3
 fmul d6,d6,d5
 fdiv d7,d14,d6
 str d7,[x10,#16]
 fmul d6,d2,d4
 fmul d6,d6,d5
 fneg d7,d14
 fdiv d7,d7,d6
 str d7,[x10,#24]
 lsl x10,x28,#2
 add x10,x10,#1
 ldr x10,[x9,x10,lsl#3]
 mov x11,#24
 madd x10,x24,x11,x10
 stp xzr,xzr,[x10]
 str xzr,[x10,#16]
 lsl x10,x28,#2
 add x10,x10,#2
 ldr x10,[x9,x10,lsl#3]
 mov x11,#72
 madd x10,x24,x11,x10
 str d14,[x10]
 str xzr,[x10,#24]
 str xzr,[x10,#48]
 str xzr,[x10,#8]
 str d14,[x10,#32]
 str xzr,[x10,#56]
 str xzr,[x10,#16]
 str xzr,[x10,#40]
 str d14,[x10,#64]
 lsl x10,x28,#2
 add x10,x10,#3
 ldr x10,[x9,x10,lsl#3]
 mov x11,#72
 madd x10,x24,x11,x10
 ldr w11,[sp,#224]
 cbz w11,.Lfilter_identity
 ldr x11,[sp,#176]
 sub x12,x24,#1
 ldr d8,[x11,x12,lsl#3]
 ldr x11,[sp,#160]
 ldr d9,[x11,x24,lsl#3]
 cbnz x28,.Lhalf_filter_factor
 ldr d10,[x11,x12,lsl#3]
 fadd d9,d10,d9
 fmul d8,d8,d9
 b .Lfilter_factor_ready
.Lhalf_filter_factor:
 fmov d10,#2.0
 fmul d8,d10,d8
 fmul d8,d8,d9
.Lfilter_factor_ready:
 fmul d6,d8,d3
 fdiv d6,d6,d0
 fsub d7,d14,d6
 str d7,[x10]
 fmul d6,d8,d3
 fdiv d6,d6,d4
 str d6,[x10,#24]
 str xzr,[x10,#48]
 fmul d6,d8,d3
 fdiv d6,d6,d1
 str d6,[x10,#8]
 fmul d6,d8,d3
 fdiv d6,d6,d5
 fsub d7,d14,d6
 str d7,[x10,#32]
 str xzr,[x10,#56]
 str xzr,[x10,#16]
 fmul d6,d3,d3
 fmul d6,d8,d6
 fmul d7,d4,d5
 fdiv d6,d6,d7
 str d6,[x10,#40]
 str d14,[x10,#64]
 b .Lcoefficient_next
.Lfilter_identity:
 str d14,[x10]
 str xzr,[x10,#24]
 str xzr,[x10,#48]
 str xzr,[x10,#8]
 str d14,[x10,#32]
 str xzr,[x10,#56]
 str xzr,[x10,#16]
 str xzr,[x10,#40]
 str d14,[x10,#64]
.Lcoefficient_next:
 add x24,x24,#1
 ldr x9,[sp,#360]
 cmp x24,x9
 b.ls .Lcoefficient_level
 ret
/* Publish the queried rank, bounds and every exact contiguous stride. */
.Lpublish:
 adr x4,.Lowners
 mov x5,#0
.Lpublish_owner:
 add x9,x4,x5,lsl#5
 ldp x6,x7,[x9]
 ldp x8,x14,[x9,#16]
 add x6,x20,x6
 add x9,sp,#240
 ldr x9,[x9,x5,lsl#3]
 str x9,[x6]
 str x8,[x6,#16]
 str wzr,[x6,#24]
 mov w9,#0x300
 cmp x8,#4
 mov w10,#0x100
 csel w9,w10,w9,eq
 orr w9,w9,w7
 str w9,[x6,#28]
 str x8,[x6,#32]
 mov x10,#1
 mov x11,#0
 mov x12,#0
.Lpublish_dimension:
 mov x13,#1
 mov x15,#1
 cmp x14,#4
 b.eq .Ldimension_lookup
 cmp x14,#5
 b.eq .Ldimension_ratio
 cmp x14,#3
 b.eq .Ldimension_gamma
 cbnz x12,.Ldimension_other
 mov x15,#3
 cmp x14,#0
 cinc x15,x15,eq
 b .Ldimension_store
.Ldimension_other:
 cmp x14,#2
 b.ne .Ldimension_last
 cmp x12,#1
 b.ne .Ldimension_last
 mov x15,#3
 b .Ldimension_store
.Ldimension_last:
 mov x13,#0
 mov x15,x21
 b .Ldimension_store
.Ldimension_lookup:
 mov x13,#0
 ldr w15,[sp,#336]
 add x15,x15,#1
 b .Ldimension_store
.Ldimension_ratio:
 mov x15,x21
 b .Ldimension_store
.Ldimension_gamma:
 mov x15,#3
 cmp x12,#0
 csel x15,x21,x15,eq
.Ldimension_store:
 msub x11,x13,x10,x11
 mov x9,#24
 madd x9,x12,x9,x6
 stp x10,x13,[x9,#40]
 add x16,x13,x15
 sub x16,x16,#1
 str x16,[x9,#56]
 mul x10,x10,x15
 add x12,x12,#1
 cmp x12,x7
 b.lo .Lpublish_dimension
 str x11,[x6,#8]
 add x5,x5,#1
 cmp x5,#12
 b.lo .Lpublish_owner
 ret
.p2align 4
.global md2asm_release_vertical_interpolation_coefficients
.type md2asm_release_vertical_interpolation_coefficients,%function
md2asm_release_vertical_interpolation_coefficients:
 cbz x0,.Lbad_leaf
 tst x0,#7
 b.ne .Lbad_leaf
 MADDR x9,xzr,4275088
 cmp x1,x9
 b.lo .Lbad_leaf
 adds x9,x0,x9
 b.cs .Lbad_leaf
 stp x18,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x19,x0
 adr x20,.Lowners
 mov x21,#12
.Lrelease:
 sub x21,x21,#1
 add x9,x20,x21,lsl#5
 ldr x9,[x9]
 add x22,x19,x9
 ldr x0,[x22]
 cbz x0,.Lrelease_next
 str xzr,[x22]
 bl free
.Lrelease_next:
 cbnz x21,.Lrelease
 mov w0,#0
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#64
 ret
.size md2asm_release_vertical_interpolation_coefficients,.-md2asm_release_vertical_interpolation_coefficients
.Lbad_leaf:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lallocation_multipliers:
 .xword 32,24,72,72,32,24,72,72,24,4,4,8
.Lowners:
 .xword 1571520,2,8,0
 .xword 1571696,2,8,1
 .xword 1571872,3,8,2
 .xword 1572096,3,8,2
 .xword 1571608,2,8,0
 .xword 1571784,2,8,1
 .xword 1571984,3,8,2
 .xword 1572208,3,8,2
 .xword 1572320,2,8,3
 .xword 1572488,1,4,4
 .xword 1572552,1,4,4
 .xword 1572408,1,8,5
.section .note.GNU-stack,"",%progbits

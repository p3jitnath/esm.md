// Contract: skills/md2asm/references/openifs/setup/complete_fullpos_setup.md.
/* Complete selected MODEL SUBFPOS. Frozen integration_contract.md precedes code.
 * x0 table224,x1 scratch804160,x2 capacity. Return0 success,1 allocation,2 reject.
 * Owned records only. Original OpenIFS functions, state and type tables excluded.
 */
.arch armv8.2-a
.macro LI r,v
 movz \r,#((\v)&65535)
.if ((\v)>>16)&65535
 movk \r,#(((\v)>>16)&65535),lsl#16
.endif
.if ((\v)>>32)&65535
 movk \r,#(((\v)>>32)&65535),lsl#32
.endif
.if ((\v)>>48)&65535
 movk \r,#(((\v)>>48)&65535),lsl#48
.endif
.endm
.macro WS r,v
 LI x17,\v
 add \r,x20,x17
.endm
.macro SPAIR a,b,n
 add x16,sp,#\n
 stp \a,\b,[x16]
.endm
.macro CALL sym
 bl \sym
 ldr x18,[sp,#96]
.endm
.text
.p2align 4
.global md2asm_initialize_selected_fullpos
.type md2asm_initialize_selected_fullpos,%function
md2asm_initialize_selected_fullpos:
 cbz x0,.Learly_bad
 cbz x1,.Learly_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Learly_bad
 adds x10,x0,#224
 b.cs .Learly_bad
 LI x9,804160
 cmp x2,x9
 b.lo .Learly_bad
 adds x11,x1,x9
 b.cs .Learly_bad
 sub sp,sp,#1536
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 stp xzr,xzr,[sp,#112]
 str xzr,[sp,#128]
 str wzr,[sp,#136]
 str wzr,[sp,#140]
 add x12,sp,#160
 stp x0,x10,[x12]
 stp x1,x11,[x12,#16]
 adr x13,.Lview_sizes
 mov x14,#0
.Lview_loop:
 add x9,x19,x14,lsl#4
 ldp x10,x11,[x9]
 cbz x10,.Lbad
 ldr x15,[x13,x14,lsl#3]
 cbnz x14,.Lfixed_view
 cbz x11,.Lbad
 cmp x11,#64,lsl#12
 b.hi .Lbad
 mov x15,x11
 b .Lrange_size
.Lfixed_view:
 tst x10,#7
 b.ne .Lbad
 cmp x11,x15
 b.lo .Lbad
.Lrange_size:
 adds x11,x10,x15
 b.cs .Lbad
 add x9,x14,#2
 add x9,x12,x9,lsl#4
 stp x10,x11,[x9]
 add x14,x14,#1
 cmp x14,#14
 b.lo .Lview_loop
 mov x9,#0
.Louter_disjoint:
 add x10,sp,#160
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,x9,#1
.Linner_disjoint:
 cmp x13,#16
 b.hs .Lnext_range
 add x10,sp,#160
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Ldisjoint
 cmp x14,x12
 b.lo .Lbad
.Ldisjoint:
 add x13,x13,#1
 b .Linner_disjoint
.Lnext_range:
 add x9,x9,#1
 cmp x9,#15
 b.lo .Louter_disjoint
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldr x21,[x19,#16]
 ldr x22,[x19,#80]
 ldp w9,w10,[x22]
 cmp w9,#2
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x22,#8]
 cbnz w9,.Lbad
 cmp w10,#8
 b.ne .Lbad
 ldr w9,[x22,#16]
 cmp w9,#5
 b.ne .Lbad
 ldp w9,w10,[x22,#32]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldr w9,[x21,#5224]
 cmp w9,#19
 b.ne .Lbad
 ldr w9,[x21,#5144]
 sub w10,w9,#1
 cmp w10,#4095
 b.hi .Lbad
 ldr w10,[x21,#7388]
 sub w11,w10,#1
 cmp w11,#4095
 b.hi .Lbad
 // All source-read GFL component pointers must target its declared array.
 ldr x9,[x19,#96]
 LI x10,799848
 add x10,x9,x10
 ldp x11,x12,[x10]
 ldr x13,[x10,#136]
 add x14,x9,#3848
 LI x15,795984
 add x15,x14,x15
 cmp x11,x14
 b.lo .Lbad
 adds x16,x11,#368
 b.cs .Lbad
 cmp x16,x15
 b.hi .Lbad
 cmp x12,x14
 b.lo .Lbad
 adds x16,x12,#368
 b.cs .Lbad
 cmp x16,x15
 b.hi .Lbad
 cmp x13,x14
 b.lo .Lbad
 adds x16,x13,#368
 b.cs .Lbad
 cmp x16,x15
 b.hi .Lbad
 // Reject an already-owned outer output before starting a new constructor.
 ldr x10,[x19,#192]
 adr x11,.Lowned_base_offsets
.Lfresh_loop:
 ldr w12,[x11],#4
 cmn w12,#1
 b.eq .Lfresh_done
 ldr x13,[x10,x12]
 cbnz x13,.Lbad
 b .Lfresh_loop
.Lfresh_done:
 ldr x10,[x19,#176]
 ldr x11,[x10,#400]
 ldr x12,[x10,#480]
 orr x11,x11,x12
 cbnz x11,.Lbad
 mov x0,x21
 mov x1,x19
 mov x2,x20
 bl .Lvalidate_map_inputs
 cbnz w0,.Lbad
 // Own the declaration constructor in private fresh zero storage.
 mov x0,x20
 LI x1,503824
 bl .Lzero
 // The original constructor reuses a prior blank character template at this gap.
 LI w10,0x20202020
 str w10,[x20,#588]
 add x9,x20,#3488
 mov w10,#0x5858
 strh w10,[x9]
 LI w10,999999
 str w10,[x9,#1040]
 LI x10,0x412e847e00000000
 str x10,[x9,#1048]
 mov w10,#1
 str w10,[x20,#2724]
 mov x0,x20
 add x0,x0,#12
 mov x1,#360
 mov w2,#32
 bl .Lfill
 adr x1,.Lmonitor
 add x0,x20,#12
 mov x2,#7
 bl .Lcopy
 WS x23,503824
 WS x24,504696
 WS x0,6072
 LI x1,497368
 CALL md2asm_initialize_fullpos_field_descriptor_defaults
 cbnz w0,.Lfailed
 WS x23,503824
 ldr x1,[x19,#176]
 mov x0,x23
 mov x2,#872
 bl .Lcopy
 WS x24,504696
 ldr x1,[x19,#208]
 mov x0,x24
 mov x2,#48
 bl .Lcopy
 // Source GSTATS entry is the admitted public FIAT routine.
 adr x0,.Lprofile_event
 adr x1,.Lprofile_enter
 CALL gstats_
 mov w9,#1
 str w9,[sp,#140]
 // SUFPC partial read, with live caller controls.
 ldr x9,[x19,#32]
 LI x10,51112
 stp x9,x10,[sp,#432]
 ldp w9,w10,[x22]
 SPAIR w9,w10,448
 mov w9,#2
 str w9,[sp,#456]
 str wzr,[sp,#460]
 WS x9,504744
 mov x10,#8544
 stp x9,x10,[sp,#464]
 WS x9,503440
 mov x10,#312
 stp x9,x10,[sp,#480]
 WS x9,503752
 mov x10,#72
 stp x9,x10,[sp,#496]
 SPAIR xzr,xzr,512
 mov x10,#48
 SPAIR x24,x10,528
 ldp x0,x1,[x19]
 add x2,sp,#432
 add x3,sp,#464
 WS x4,576104
 LI x5,71360
 CALL md2asm_initialize_selected_fullpos_configuration
 cbnz w0,.Lfailed
 WS x0,504744
 mov x1,#8544
 ldr x2,[x19,#32]
 LI x3,51112
 mov x4,x20
 mov x5,#504
 CALL md2asm_initialize_fullpos_output_control
 cbnz w0,.Lfailed
 // Own UPDTRANS over the selected public global transform API.
 mov x0,x21
 add x0,x0,#4096
 add x0,x0,#1072
 CALL .Lupdate_transform
 cbnz w0,.Lfailed
 mov x0,#472
 CALL malloc
 cbz x0,.Lallocation_failed
 mov x25,x0
 str x25,[x20,#504]
 mov x1,#472
 bl .Lzero
 mov x0,x25
 mov x1,#472
 CALL md2asm_initialize_fullpos_user_geometry_defaults
 cbnz w0,.Lfailed
 // Rank-one derived descriptor, lower1, upper1, original element size472.
 add x0,x20,#504
 mov x1,x25
 mov x2,#472
 bl .Lderived_descriptor
 // The source20-character actual is blank-padded into the32-character user field.
 add x0,sp,#1024
 mov x1,#32
 mov w2,#32
 bl .Lfill
 WS x1,504749
 add x0,sp,#1024
 mov x2,#20
 bl .Lcopy
 SPAIR xzr,xzr,544
 ldr x9,[x22,#24]
 str x9,[sp,#560]
 mov x0,x21
 add x1,sp,#1024
 add x2,sp,#544
 mov x3,x25
 mov x4,#472
 CALL md2asm_initialize_selected_fullpos_model_geometry
 cbnz w0,.Lfailed
 // Source sets both global counts before SUMPFPOS.
 ldr w9,[x21,#7388]
 str w9,[x20,#568]
 str w9,[x20,#1416]
 str wzr,[x20,#2724]
 ldr w10,[x21,#5168]
 str w10,[x20,#2720]
 SPAIR w9,wzr,576
 mov w10,#1
 str w10,[sp,#580]
 str w10,[sp,#584]
 ldr w10,[x21,#5144]
 neg w10,w10
 str w10,[sp,#588]
 add x0,sp,#576
 ldr x1,[x21,#6776]
 add x2,x20,#568
 mov x3,#848
 CALL md2asm_initialize_selected_fullpos_distribution
 cbnz w0,.Lfailed
 // Allocate/copy the sole new map-factor owner in source block order.
 mov x0,x21
 add x1,x20,#568
 CALL .Lmap_factor
 cbnz w0,.Lfailed
 // SUFPV then SUFPVERT, with live host A, B and reference pressure.
 ldr x9,[x21,#144]
 ldr x10,[x21,#80]
 SPAIR x9,x10,592
 LI x9,20320
 ldr x10,[x21,x9]
 str x10,[sp,#608]
 mov w9,#19
 str w9,[sp,#616]
 ldr x10,[x19,#32]
 LI x9,39516
 ldr w10,[x10,x9]
 str w10,[sp,#620]
 ldp x0,x1,[x19]
 add x2,sp,#592
 WS x3,647464
 mov x4,#3224
 add x5,x20,#2728
 mov x6,#512
 CALL md2asm_initialize_selected_fullpos_vertical
 cbnz w0,.Lfailed
 // Three automatic filename owners, allocated before SUFPIOS.
 mov x0,#180
 CALL malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#112]
 mov x0,#180
 CALL malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#120]
 mov x0,#180
 CALL malloc
 cbz x0,.Lallocation_failed
 str x0,[sp,#128]
 ldp x0,x1,[x19]
 WS x2,504744
 ldr x3,[x19,#64]
 WS x4,659112
 mov x5,#564
 CALL md2asm_initialize_fullpos_io_scheme
 cbnz w0,.Lfailed
 ldr x0,[sp,#112]
 WS x1,659136
 mov x2,#180
 bl .Lcopy
 ldr x0,[sp,#120]
 WS x1,659316
 mov x2,#180
 bl .Lcopy
 ldr x0,[sp,#128]
 WS x1,659496
 mov x2,#180
 bl .Lcopy
 // Complete SUFPIOH reuses the source-produced names and geometry owners.
 ldr x9,[x19,#48]
 mov x10,#336
 SPAIR x9,x10,624
 WS x9,659112
 mov x10,#564
 SPAIR x9,x10,640
 add x9,x20,#568
 mov x10,#848
 SPAIR x9,x10,656
 mov x10,#472
 SPAIR x25,x10,672
 mov x10,#872
 SPAIR x23,x10,688
 WS x9,5920
 mov x10,#152
 SPAIR x9,x10,704
 add x0,sp,#624
 CALL md2asm_initialize_fullpos_io_handler
 cbnz w0,.Lfailed
 // Source LLNEWCL uses actual live component LGP and PHNC flags.
 SPAIR xzr,xzr,720
 SPAIR xzr,xzr,736
 SPAIR xzr,xzr,752
 ldr x9,[x19,#128]
 ldr w10,[x9,#8]
 str w10,[sp,#724]
 ldp w9,w10,[x22,#8]
 str w9,[sp,#728]
 ldr x11,[x19,#32]
 LI x12,35184
 ldr w9,[x11,x12]
 str w9,[sp,#732]
 LI x12,35288
 ldr w9,[x11,x12]
 str w9,[sp,#736]
 LI x12,35104
 ldr w9,[x11,x12]
 str w9,[sp,#740]
 LI x12,35596
 ldr w9,[x11,x12]
 str w9,[sp,#764]
 ldr w9,[x22,#4]
 str w9,[sp,#752]
 LI x12,39520
 ldr w9,[x11,x12]
 str w9,[sp,#756]
 str w10,[sp,#760]
 ldr x9,[x19,#96]
 LI x10,799848
 add x10,x9,x10
 ldp x11,x12,[x10]
 ldr x13,[x10,#136]
 ldr w11,[x11,#52]
 ldr w12,[x12,#52]
 ldr w13,[x13,#52]
 orr w14,w11,w12
 orr w14,w14,w13
 ldr x10,[x19,#112]
 ldp w11,w12,[x10,#48]
 orr w14,w14,w11
 cmp w14,#0
 cset w14,eq
 cmp w12,#0
 cset w12,ne
 and w14,w14,w12
 str w14,[sp,#744]
 cmp w13,#0
 cset w13,eq
 cmp w11,#0
 cset w11,ne
 and w13,w13,w11
 str w13,[sp,#748]
 WS x9,503440
 mov x10,#312
 SPAIR x9,x10,768
 ldp x9,x10,[x19,#96]
 SPAIR x9,x10,784
 ldp x9,x10,[x19,#144]
 SPAIR x9,x10,800
 ldp x9,x10,[x19,#160]
 SPAIR x9,x10,816
 ldr x9,[sp,#128]
 mov x10,#180
 SPAIR x9,x10,832
 add x9,sp,#720
 mov x10,#48
 SPAIR x9,x10,848
 ldp x0,x1,[x19]
 add x2,sp,#768
 WS x3,6072
 LI x4,497368
 CALL md2asm_initialize_selected_fullpos_field_descriptors
 cbnz w0,.Lfailed
 // SUFPF, followed by the qualified complete selected filter parent.
 ldp x0,x1,[x19]
 WS x2,650688
 mov x3,#8424
 CALL md2asm_initialize_selected_fullpos_filter_controls
 cbnz w0,.Lfailed
 ldr w9,[x21,#5224]
 ldr w10,[x22,#16]
 SPAIR w9,w10,864
 SPAIR xzr,xzr,872
 SPAIR xzr,xzr,880
 ldr w9,[x21,#5172]
 str w9,[sp,#896]
 str wzr,[sp,#900]
 ldr x9,[x21,#7512]
 str x9,[sp,#904]
 // The filter parent exposes its own source-equivalent field request read.
 mov w9,#1
 str w9,[sp,#460]
 ldp x9,x10,[x19]
 SPAIR x9,x10,912
 add x9,sp,#432
 mov x10,#32
 SPAIR x9,x10,928
 WS x9,503440
 mov x10,#312
 SPAIR x9,x10,944
 WS x9,650688
 mov x10,#8424
 SPAIR x9,x10,960
 add x9,sp,#864
 mov x10,#48
 SPAIR x9,x10,976
 add x9,x20,#3240
 mov x10,#248
 SPAIR x9,x10,992
 mov x10,#48
 SPAIR x24,x10,1008
 add x0,sp,#912
 WS x1,659680
 LI x2,144480
 CALL md2asm_initialize_selected_fullpos_filters
 cbnz w0,.Lfailed
 adr x0,.Lprofile_event
 adr x1,.Lprofile_exit
 CALL gstats_
 str wzr,[sp,#140]
 // Commit complete owned records only after every source stage passed.
 ldr x0,[x19,#192]
 mov x1,x20
 LI x2,503824
 bl .Lcopy
 ldr x0,[x19,#176]
 mov x1,x23
 mov x2,#872
 bl .Lcopy
 ldr x0,[x19,#208]
 mov x1,x24
 mov x2,#48
 bl .Lcopy
 str wzr,[sp,#136]
 b .Ltemporaries
.Lallocation_failed:
 mov w0,#1
.Lfailed:
 str w0,[sp,#136]
 // Balance the public profiling event before a recoverable owned rollback.
 ldr w9,[sp,#140]
 cbz w9,.Lfailure_profile_closed
 adr x0,.Lprofile_event
 adr x1,.Lprofile_exit
 CALL gstats_
 str wzr,[sp,#140]
.Lfailure_profile_closed:
 mov x0,x20
 LI x1,503824
 mov x2,x23
 mov x3,#872
 CALL md2asm_release_selected_fullpos
.Ltemporaries:
 ldr x0,[sp,#112]
 cbz x0,.Ltemporary2
 CALL free
.Ltemporary2:
 ldr x0,[sp,#120]
 cbz x0,.Ltemporary3
 CALL free
.Ltemporary3:
 ldr x0,[sp,#128]
 cbz x0,.Lreturn_status
 CALL free
.Lreturn_status:
 ldr w0,[sp,#136]
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#1536
 ret
.Learly_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_fullpos,.-md2asm_initialize_selected_fullpos

/* Selected UPDTRANS: public API, preserving both requested and current state. */
.Lupdate_transform:
 sub sp,sp,#512
 stp x29,x30,[sp]
 stp x19,x18,[sp,#16]
 mov x19,x0
 add x0,sp,#32
 add x1,sp,#36
 bl get_current_
 ldr x18,[sp,#24]
 ldr w9,[sp,#36]
 cbnz w9,.Ltransform_bad
 add x0,sp,#48
 mov x1,#376
 bl .Lzero
 str x19,[sp,#48]
 add x9,sp,#40
 str x9,[sp,#360]
 add x0,sp,#48
 bl md2asm_call_public_transform_inquiry
 ldr x18,[sp,#24]
 cbnz w0,.Ltransform_return
 add x9,sp,#32
 str x9,[sp,#48]
 str xzr,[sp,#360]
 add x0,sp,#48
 bl md2asm_call_public_transform_inquiry
 ldr x18,[sp,#24]
 cbnz w0,.Ltransform_return
 ldr w9,[sp,#40]
 cbnz w9,.Ltransform_bad
 mov w0,#0
 b .Ltransform_return
.Ltransform_bad:
 mov w0,#2
.Ltransform_return:
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#512
 ret

/* Validate borrowed map-factor storage before any private constructor write. */
.Lvalidate_map_inputs:
 mov x4,x0
 mov x5,x1
 mov x6,x2
 ldr w7,[x4,#5144]
 ldr w8,[x4,#7388]
 cmp w7,w8
 csel w7,w7,w8,lo
 sub w9,w8,#1
 udiv w9,w9,w7
 add w9,w9,#1
 ldr x10,[x4,#8472]
 cbz x10,.Lvmap_bad
 tst x10,#7
 b.ne .Lvmap_bad
 ldr x11,[x4,#8480]
 cmn x11,#1
 b.ne .Lvmap_bad
 ldr x11,[x4,#8488]
 cmp x11,#1472
 b.ne .Lvmap_bad
 ldr x11,[x4,#8512]
 cmp x11,#1
 b.ne .Lvmap_bad
 ldr x11,[x4,#8520]
 cmp x11,#1
 b.ne .Lvmap_bad
 ldr x11,[x4,#8528]
 cmp x11,x9
 b.lo .Lvmap_bad
 mov x11,#1472
 umull x11,w9,w11
 adds x13,x10,x11
 b.cs .Lvmap_bad
 mov x12,x10
 mov x14,#-1
 b .Lvmap_check_range
.Lvmap_block:
 mov x11,#1472
 madd x11,x14,x11,x10
 ldr x12,[x11,#704]
 cbz x12,.Lvmap_bad
 tst x12,#7
 b.ne .Lvmap_bad
 ldr x13,[x11,#712]
 cmn x13,#1
 b.ne .Lvmap_bad
 ldr x13,[x11,#720]
 cmp x13,#8
 b.ne .Lvmap_bad
 ldr x13,[x11,#744]
 cmp x13,#1
 b.ne .Lvmap_bad
 ldr x13,[x11,#752]
 cmp x13,#1
 b.ne .Lvmap_bad
 mul w15,w14,w7
 sub w15,w8,w15
 cmp w15,w7
 csel w15,w15,w7,lo
 ldr x13,[x11,#760]
 cmp x13,x15
 b.lo .Lvmap_bad
 adds x13,x12,x15,lsl#3
 b.cs .Lvmap_bad
.Lvmap_check_range:
 LI x15,804160
 add x15,x6,x15
 cmp x12,x15
 b.hs .Lvmap_output_ranges
 cmp x6,x13
 b.lo .Lvmap_bad
.Lvmap_output_ranges:
 mov x11,#176
.Lvmap_output_loop:
 ldr x15,[x5,x11]
 cmp x11,#176
 b.eq .Lvmap_stream_size
 cmp x11,#192
 b.eq .Lvmap_record_size
 mov x16,#48
 b .Lvmap_output_size
.Lvmap_stream_size:
 mov x16,#872
 b .Lvmap_output_size
.Lvmap_record_size:
 LI x16,503824
.Lvmap_output_size:
 add x16,x15,x16
 cmp x12,x16
 b.hs .Lvmap_disjoint
 cmp x15,x13
 b.lo .Lvmap_bad
.Lvmap_disjoint:
 add x11,x11,#16
 cmp x11,#224
 b.lo .Lvmap_output_loop
 add x14,x14,#1
 cmp x14,x9
 b.lo .Lvmap_block
 mov w0,#0
 ret
.Lvmap_bad:
 mov w0,#2
 ret

/* New source map-factor allocation; numerical bytes are copied without FP work. */
.Lmap_factor:
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 ldr w21,[x20,#12]
 ldr w22,[x20,#16]
 ldr x23,[x19,#8472]
 cbz x23,.Lmap_bad
 tst x23,#7
 b.ne .Lmap_bad
 ldr x9,[x19,#8512]
 cmp x9,#1
 b.ne .Lmap_bad
 ldr x9,[x19,#8520]
 cmp x9,#1
 b.ne .Lmap_bad
 ldr x9,[x19,#8528]
 cmp x9,x22
 b.lo .Lmap_bad
 ldr x9,[x19,#8488]
 cmp x9,#1472
 b.ne .Lmap_bad
 ldr x9,[x19,#8504]
 cmp x9,#1472
 b.ne .Lmap_bad
 ldr x10,[x20,#24]
 mov x11,#0
.Lmap_validate:
 mov x12,#1472
 madd x12,x11,x12,x23
 ldr x13,[x12,#704]
 cbz x13,.Lmap_bad
 tst x13,#7
 b.ne .Lmap_bad
 ldr w14,[x10,x11,lsl#2]
 cmp w14,w21
 b.hi .Lmap_bad
 cbz w14,.Lmap_bad
 ldr x15,[x12,#744]
 cmp x15,#1
 b.ne .Lmap_bad
 ldr x15,[x12,#752]
 cmp x15,#1
 b.ne .Lmap_bad
 ldr x15,[x12,#760]
 cmp x15,x14
 b.lo .Lmap_bad
 ldr x15,[x12,#720]
 cmp x15,#8
 b.ne .Lmap_bad
 adds x15,x13,x14,lsl#3
 b.cs .Lmap_bad
 add x11,x11,#1
 cmp x11,x22
 b.lo .Lmap_validate
 umull x0,w21,w22
 lsl x0,x0,#3
 bl malloc
 ldr x18,[sp,#56]
 cbz x0,.Lmap_allocation
 str x0,[x20,#240]
 mov x9,#0
.Lmap_block:
 mov x10,#1472
 madd x10,x9,x10,x23
 ldr x10,[x10,#704]
 ldr x11,[x20,#24]
 ldr w11,[x11,x9,lsl#2]
 umull x12,w9,w21
 ldr x13,[x20,#240]
 add x13,x13,x12,lsl#3
 mov x12,#0
.Lmap_element:
 ldr x14,[x10,x12,lsl#3]
 str x14,[x13,x12,lsl#3]
 add x12,x12,#1
 cmp x12,x11
 b.lo .Lmap_element
 add x9,x9,#1
 cmp x9,x22
 b.lo .Lmap_block
 // GNU rank-two descriptor, source lower bounds1/1 and element bytes8.
 add x9,x20,#240
 mov x10,#-1
 sub x10,x10,x21
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 LI x11,0x30200000000
 str x11,[x9,#24]
 str x10,[x9,#32]
 mov x10,#1
 stp x10,x10,[x9,#40]
 stp x21,x21,[x9,#56]
 stp x10,x22,[x9,#72]
 mov w0,#0
 b .Lmap_return
.Lmap_allocation:
 mov w0,#1
 b .Lmap_return
.Lmap_bad:
 mov w0,#2
.Lmap_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret

/* Every persistent owner is released through its declared data word. */
.p2align 4
.global md2asm_release_selected_fullpos
.type md2asm_release_selected_fullpos,%function
md2asm_release_selected_fullpos:
 cbz x0,.Lrelease_bad
 cbz x2,.Lrelease_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lrelease_bad
 LI x9,503824
 cmp x1,x9
 b.lo .Lrelease_bad
 adds x9,x0,x9
 b.cs .Lrelease_bad
 cmp x3,#872
 b.lo .Lrelease_bad
 adds x9,x2,#872
 b.cs .Lrelease_bad
 sub sp,sp,#48
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mov x20,x2
 // User arrays precede their enclosing user-record owner.
 ldr x21,[x19,#504]
 cbz x21,.Lrelease_outer
 mov x0,x21
 mov x1,#472
 bl md2asm_release_selected_fullpos_model_geometry
 ldr x18,[sp,#40]
 mov x0,x21
 bl free
 ldr x18,[sp,#40]
 str xzr,[x19,#504]
.Lrelease_outer:
 adr x21,.Lpersistent_base_offsets
.Lrelease_loop:
 ldr w9,[x21],#4
 cmn w9,#1
 b.eq .Lrelease_stream
 add x9,x19,x9
 ldr x0,[x9]
 cbz x0,.Lrelease_loop
 str xzr,[x9]
 bl free
 ldr x18,[sp,#40]
 b .Lrelease_loop
.Lrelease_stream:
 ldr x0,[x20,#400]
 cbz x0,.Lrelease_stream2
 str xzr,[x20,#400]
 bl free
 ldr x18,[sp,#40]
.Lrelease_stream2:
 ldr x0,[x20,#480]
 cbz x0,.Lrelease_done
 str xzr,[x20,#480]
 bl free
 ldr x18,[sp,#40]
.Lrelease_done:
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#48
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_fullpos,.-md2asm_release_selected_fullpos

.Lderived_descriptor:
 str x1,[x0]
 mov x9,#-1
 str x9,[x0,#8]
 str x2,[x0,#16]
 LI x9,0x50100000000
 str x9,[x0,#24]
 str x2,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x9,[x0,#56]
 ret
.Lzero:
 mov x2,xzr
.Lfill:
 cbz x1,.Lfill_done
 mov x9,#0
.Lfill_loop:
 strb w2,[x0,x9]
 add x9,x9,#1
 cmp x9,x1
 b.lo .Lfill_loop
.Lfill_done:
 ret
.Lcopy:
 mov x9,#0
 cbz x2,.Lcopy_done
.Lcopy_loop:
 ldrb w10,[x1,x9]
 strb w10,[x0,x9]
 add x9,x9,#1
 cmp x9,x2
 b.lo .Lcopy_loop
.Lcopy_done:
 ret

.section .rodata
.p2align 3
.Lview_sizes:
.quad 1,20400,51112,336,296,48,1359136,100,456,280,392,872,503824,48
.Lmonitor:.ascii "monitor"
.p2align 2
.Lprofile_event:.word 2001
.Lprofile_enter:.word 0
.Lprofile_exit:.word 1
#include "fullpos_owner_tables.inc.S"
.section .note.GNU-stack,"",%progbits

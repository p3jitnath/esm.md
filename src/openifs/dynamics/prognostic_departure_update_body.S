/*
 * Provisional fields after transport along the air trajectory.
 * Physics: formulations/openifs/dynamics/prognostic_departure_update.md
 * Contract: skills/md2asm/references/openifs/dynamics/prognostic_departure_update.md
 * Original interface: LAPINEB, 36 ordinary pointers, no hidden argument.
 * Every selected calculation is direct AArch64 assembly. LARCINB is an
 * accepted direct assembly child. Runtime services allocate and free storage.
 */
.text
.p2align 4
.macro argument reg, index
 ldr \reg, [sp, #(320 + 8 * \index)]
.endm
.macro scratch reg, index
 ldr \reg, [sp, #(880 + 8 * \index)]
.endm
.macro integer_value reg, value
 movz \reg, #(\value & 65535)
 movk \reg, #((\value >> 16) & 65535), lsl #16
 movk \reg, #((\value >> 32) & 65535), lsl #32
 movk \reg, #((\value >> 48) & 65535), lsl #48
.endm
.macro child_stack_argument index, parent
 argument x9, \parent
 str x9, [sp, #(8 * (\index - 8))]
.endm
.macro child_scratch_argument index, local
 scratch x9, \local
 str x9, [sp, #(8 * (\index - 8))]
.endm
.global md2asm_lapineb_7259755
.type md2asm_lapineb_7259755,%function
md2asm_lapineb_7259755:
 sub sp, sp, #2048
 stp x0,x1,[sp,#320]
 stp x2,x3,[sp,#336]
 stp x4,x5,[sp,#352]
 stp x6,x7,[sp,#368]
 add x9,sp,#640
 stp x19,x20,[x9,#0]
 stp x21,x22,[x9,#16]
 stp x23,x24,[x9,#32]
 stp x25,x26,[x9,#48]
 stp x27,x28,[x9,#64]
 stp x29,x30,[x9,#80]
 stp d8,d9,[x9,#96]
 stp d10,d11,[x9,#112]
 stp d12,d13,[x9,#128]
 stp d14,d15,[x9,#144]
 mov x29,sp
 add x9,sp,#2048
 add x10,sp,#384
 mov x11,#28
.Lsave_stack_arguments:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lsave_stack_arguments
#ifdef LAPINEB_EXPLICIT_CONTEXT
 /* The original 28 stack pointers end at incoming byte 224. */
 ldr x9,[x9]
 cbz x9,.Lunsupported
 tst x9,#7
 b.ne .Lunsupported
 adds x10,x9,#16
 b.cs .Lunsupported
 str x9,[sp,#1504]
 ldp x10,x11,[x9]
 cbz x10,.Lunsupported
 cbz x11,.Lunsupported
 orr x12,x10,x11
 tst x12,#7
 b.ne .Lunsupported
 adds x12,x10,#520
 b.cs .Lunsupported
 mov x12,#51512
 adds x12,x11,x12
 b.cs .Lunsupported
 str x10,[sp,#1512]
 str x11,[sp,#1520]
#endif
 mov x19,x0
 mov x20,x2
 integer_value x9,1564136
 add x21,x20,x9
 mrs x9,fpcr
 cbnz x9,.Lunsupported
 ldr w22,[x19,#5144]
 ldr w23,[x19,#5224]
 cmp w22,#1
 b.lt .Lunsupported
 cmp w22,#1024
 b.gt .Lunsupported
 cmp w23,#4
 b.lt .Lunsupported
 cmp w23,#256
 b.gt .Lunsupported
 argument x9,4
 ldr w26,[x9]
 sub w26,w26,#1
 cmp w26,w22
 b.hi .Lunsupported
 argument x9,5
 ldr w27,[x9]
 cmp w27,w22
 b.hi .Lunsupported
 ldr w9,[x21,#0]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#8]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#48]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#56]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#216]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#300]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#304]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#340]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#4760]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#4896]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#4904]
 cbnz w9,.Lunsupported
 ldr w9,[x21,#368]
 cmp w9,#1
 b.ne .Lunsupported
 ldr w9,[x21,#4640]
 cmp w9,#3
 b.ne .Lunsupported
 ldr w9,[x21,#4644]
 cmp w9,#3
 b.ne .Lunsupported
 ldr w9,[x21,#4648]
 cmp w9,#3
 b.ne .Lunsupported
#ifdef LAPINEB_EXPLICIT_CONTEXT
 ldr x9,[sp,#1520]
 mov x10,#35292
 add x9,x9,x10
#else
 adrp x9,:got:__yomct0_MOD_lrplane
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lrplane]
#endif
 ldr w9,[x9]
 cbnz w9,.Lunsupported
 ldr x9,[x19,#3264]
 cbz x9,.Lunsupported
 ldr w10,[x9,#52]
 cmp w10,#1
 b.hi .Lunsupported
 cbz w10,.Lvertical_configuration_ready
 ldr w10,[x9,#36]
 cmp w10,#3
 b.ne .Lunsupported
.Lvertical_configuration_ready:
 mul x24,x22,x23
 lsl x25,x24,#3
 argument x9,1
 ldr w10,[x9,#1420]
 cmp w10,#1
 b.lt .Lunsupported
 cmp w10,#64
 b.gt .Lunsupported
 str w10,[sp,#808]
 add x9,x20,#192
 ldr w11,[x9]
 cmp w11,#0
 b.lt .Lunsupported
 cmp w11,#2163
 b.gt .Lunsupported
 str w11,[sp,#812]
#ifdef LAPINEB_EXPLICIT_CONTEXT
 /* New read-only owners must survive every complete returned owner. */
 ldr x0,[sp,#1504]
 add x1,x0,#16
 bl .Lruntime_readonly_overlap
 ldr x0,[sp,#1512]
 add x1,x0,#520
 bl .Lruntime_readonly_overlap
 ldr x0,[sp,#1520]
 mov x1,#51512
 add x1,x0,x1
 bl .Lruntime_readonly_overlap
 /* The original allocation calculation consumes both saved counts. */
 ldr w10,[sp,#808]
 ldr w11,[sp,#812]
#endif
 /* Allocate three main-field arrays, constituent terms and local scalars. */
 add x12,x10,x10,lsl #1
 add x12,x12,x11
 add x12,x12,#9
 mul x0,x12,x25
 add x12,x22,x22,lsl #1
 add x0,x0,x12,lsl #3
 add x12,x23,x23
 add x12,x12,#3
 mul x12,x12,x22
 add x0,x0,x12,lsl #3
 integer_value x9,536870912
 cmp x0,x9
 b.hi .Lunsupported
 bl malloc
 cbz x0,.Lunsupported
 mov x28,x0
 ldr w9,[sp,#808]
 mul x11,x9,x25
 str x28,[sp,#880]
 add x10,x28,x11
 str x10,[sp,#888]
 add x10,x10,x11
 str x10,[sp,#896]
 add x10,x10,x11
 str x10,[sp,#904]
 add x10,x10,x25
 str x10,[sp,#912]
 ldr w9,[sp,#812]
 madd x10,x9,x25,x10
 str x10,[sp,#920]
 add x10,x10,x25
 str x10,[sp,#928]
 add x10,x10,x25
 str x10,[sp,#936]
 add x10,x10,x25
 str x10,[sp,#944]
 add x10,x10,x25
 str x10,[sp,#952]
 add x10,x10,x25
 str x10,[sp,#960]
 add x10,x10,x25
 str x10,[sp,#968]
 add x10,x10,x25
 str x10,[sp,#976]
 add x10,x10,x22,lsl #3
 str x10,[sp,#984]
 add x10,x10,x22,lsl #3
 str x10,[sp,#992]
 add x10,x10,x22,lsl #3
 str x10,[sp,#1000]
 add x10,x10,x25
 str x10,[sp,#1064]
 add x9,x23,#2
 mul x9,x9,x22
 add x10,x10,x9,lsl #3
 str x10,[sp,#1072]
 /* The source sets every provisional main-field term to positive zero. */
 mov x0,x28
 mov x1,x11
 bl .Lpositive_zero
 argument x9,8
 ldr w9,[x9]
 cbz w9,.Lscan_vertical_selectors
 scratch x0,10
 mov x1,x25
 bl .Lpositive_zero
 scratch x0,11
 mov x1,x25
 bl .Lpositive_zero
.Lscan_vertical_selectors:
 str wzr,[sp,#272]
 str wzr,[sp,#276]
 add x9,x20,#4040
 ldr w10,[sp,#812]
 cbz w10,.Ltransport_child
 integer_value x12,0x202054564849414c
 integer_value x13,0x4d5154564849414c
 integer_value x14,0x20202020
 integer_value x15,0x20202048
.Lselector_loop:
 ldr x11,[x9,#156]
 ldr w16,[x9,#164]
 cmp x11,x12
 b.ne .Lother_vertical_selector
 cmp w16,w14
 b.eq .Lselected_vertical_method
 b .Lnext_vertical_selector
.Lother_vertical_selector:
 cmp x11,x13
 b.ne .Lnext_vertical_selector
 cmp w16,w14
 b.eq .Lselected_vertical_method
 cmp w16,w15
 b.ne .Lnext_vertical_selector
.Lselected_vertical_method:
 mov w11,#1
 str w11,[sp,#272]
.Lnext_vertical_selector:
 add x9,x9,#368
 subs w10,w10,#1
 b.ne .Lselector_loop
.Ltransport_child:
 argument x9,6
 add x9,x9,#1016
 str x9,[sp,#0]
 add x9,sp,#272
 str x9,[sp,#8]
 child_stack_argument 10,8
 add x9,sp,#276
 str x9,[sp,#24]
 child_stack_argument 12,11
 child_stack_argument 13,12
 child_stack_argument 14,13
 child_stack_argument 15,14
 child_stack_argument 16,20
 child_stack_argument 17,9
 child_stack_argument 18,10
 child_stack_argument 19,29
 child_stack_argument 20,30
 child_stack_argument 21,31
 child_scratch_argument 22,0
 child_scratch_argument 23,1
 child_scratch_argument 24,2
 child_scratch_argument 25,3
 child_scratch_argument 26,4
 child_scratch_argument 27,5
 child_scratch_argument 28,6
 child_scratch_argument 29,7
 child_scratch_argument 30,8
 child_scratch_argument 31,9
 child_scratch_argument 32,10
 child_scratch_argument 33,11
 child_stack_argument 34,34
 child_stack_argument 35,35
 child_scratch_argument 36,12
 child_scratch_argument 37,13
 child_scratch_argument 38,14
 mov x0,x19
 argument x1,1
 integer_value x9,4232912
 add x2,x20,x9
 integer_value x9,4233032
 add x3,x20,x9
 add x4,x20,#8
 mov x5,x21
 argument x6,4
 argument x7,5
 bl md2asm_larcinb_7259755
 /* Choose the caller's finite-difference or finite-element integral. */
 ldr x9,[x19,#3264]
 ldr w9,[x9,#52]
 cbnz w9,.Lfinite_element_pressure
 /* Integrate the finite-difference terms in increasing level order. */
 argument x9,1
 ldr w9,[x9,#1400]
 sub w9,w9,#1
 mul x9,x9,x22
 argument x10,26
 add x10,x10,x9,lsl #3
 str x10,[sp,#1048]
 ldr x11,[x19,#3240]
 ldr x12,[x11,#448]
 ldr x13,[x11,#456]
 add x12,x12,x13,lsl #3
 add x12,x12,#8
 str x12,[sp,#1040]
 mov x14,#0
.Lpressure_level:
 ldr x12,[sp,#1040]
 ldr d0,[x12,x14,lsl #3]
 scratch x10,3
 scratch x11,5
 madd x15,x14,x22,x26
 ldr x12,[sp,#1048]
 add x12,x12,x26,lsl #3
 mov x16,x26
 cmp x16,x27
 b.ge .Lnext_pressure_level
.Lpressure_column:
 ldr d1,[x10,x15,lsl #3]
 ldr d2,[x11,x15,lsl #3]
 fadd d3,d1,d2
 fmul d3,d0,d3
 ldr d4,[x12]
 fadd d4,d4,d3
 str d4,[x12],#8
 add x15,x15,#1
 add x16,x16,#1
 cmp x16,x27
 b.lt .Lpressure_column
.Lnext_pressure_level:
 add x14,x14,#1
 cmp x14,x23
 b.lt .Lpressure_level
 b .Lpressure_finished
.Lfinite_element_pressure:
 ldr x0,[sp,#1064]
 add x1,x23,#2
 mul x1,x1,x22
 lsl x1,x1,#3
 bl .Lpositive_zero
 cmp x26,x27
 b.ge .Lfinite_element_integrate
 ldr x9,[x19,#3240]
 ldr x10,[x9,#448]
 ldr x11,[x9,#456]
 add x10,x10,x11,lsl #3
 add x10,x10,#8
 ldr x9,[x19,#3248]
 ldr x11,[x9,#256]
 ldr x12,[x9,#264]
 add x11,x11,x12,lsl #3
 add x11,x11,#8
 scratch x12,3
 scratch x13,5
 ldr x14,[sp,#1064]
 mov x15,#0
.Lfinite_element_level:
 ldr d0,[x10,x15,lsl #3]
 ldr d1,[x11,x15,lsl #3]
 fmul d2,d0,d1
 mov x16,x26
 madd x17,x15,x22,x26
 add x9,x17,x22
 cmp x16,x27
 b.ge .Lnext_finite_element_level
.Lfinite_element_column:
 ldr d3,[x12,x17,lsl #3]
 ldr d4,[x13,x17,lsl #3]
 fadd d3,d3,d4
 fmul d3,d2,d3
 str d3,[x14,x9,lsl #3]
 add x9,x9,#1
 add x17,x17,#1
 add x16,x16,#1
 cmp x16,x27
 b.lt .Lfinite_element_column
.Lnext_finite_element_level:
 add x15,x15,#1
 cmp x15,x23
 b.lt .Lfinite_element_level
.Lfinite_element_integrate:
 ldr x9,[sp,#1064]
 str x9,[sp,#0]
 ldr x9,[sp,#1072]
 str x9,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 mov x9,#4
 str x9,[sp,#32]
 mov x9,#2
 str x9,[sp,#40]
 ldr x0,[x19,#3256]
 ldr x1,[x19,#3264]
 adrp x2,.Loperation_top
 add x2,x2,:lo12:.Loperation_top
 adrp x3,.Lboundary_derivatives
 add x3,x3,:lo12:.Lboundary_derivatives
 add x4,x19,#1,lsl #12
 add x4,x4,#1048
 argument x5,4
 argument x6,5
 add x7,x19,#1,lsl #12
 add x7,x7,#1128
 bl md2asm_lapineb_vertical_integral
 adrp x9,.Lvertical_calls
 add x9,x9,:lo12:.Lvertical_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 argument x9,1
 ldr w9,[x9,#1400]
 sub w9,w9,#1
 mul x9,x9,x22
 argument x10,26
 add x10,x10,x9,lsl #3
 ldr x11,[sp,#1072]
 mul x12,x23,x22
 add x11,x11,x12,lsl #3
 mov x12,x26
 cmp x12,x27
 b.ge .Lpressure_finished
.Lfinite_element_surface_add:
 ldr d0,[x10,x12,lsl #3]
 ldr d1,[x11,x12,lsl #3]
 fadd d0,d0,d1
 str d0,[x10,x12,lsl #3]
 add x12,x12,#1
 cmp x12,x27
 b.lt .Lfinite_element_surface_add
.Lpressure_finished:
 /* Express the transported wind in the local arrival basis. */
 ldr x9,[x19,#8472]
 ldr x10,[x19,#8520]
 argument x11,9
 ldr w11,[x11]
 sub x11,x11,x10
 mov x10,#1472
 madd x9,x11,x10,x9
 ldr x11,[x9,#960]
 ldr x10,[x9,#968]
 add x11,x11,x10,lsl #3
 add x11,x11,#8
 ldr x12,[x9,#1024]
 ldr x10,[x9,#1032]
 add x12,x12,x10,lsl #3
 add x12,x12,#8
 ldr w9,[x21,#6820]
 sub w9,w9,#1
 argument x10,23
 madd x9,x9,x25,x10
 ldr w10,[x21,#6824]
 sub w10,w10,#1
 argument x13,23
 madd x10,x10,x25,x13
 argument x13,1
 ldr w14,[x13,#1424]
 sub w14,w14,#1
 scratch x15,0
 madd x13,x14,x25,x15
 argument x14,1
 ldr w14,[x14,#1428]
 sub w14,w14,#1
 madd x14,x14,x25,x15
 argument x15,1
 ldr w16,[x15,#1368]
 sub w16,w16,#1
 argument x17,25
 madd x15,x16,x25,x17
 argument x16,1
 ldr w16,[x16,#1372]
 sub w16,w16,#1
 madd x16,x16,x25,x17
 argument x17,32
 argument x0,33
 argument x1,8
 ldr w1,[x1]
 scratch x2,10
 scratch x3,11
 mov x4,#0
.Lwind_level:
 mov x5,x26
 madd x6,x4,x22,x26
 cmp x5,x27
 b.ge .Lnext_wind_level
.Lwind_column:
 ldr d0,[x12,x5,lsl #3]
 ldr d1,[x11,x5,lsl #3]
 ldr d2,[x9,x6,lsl #3]
 ldr d3,[x10,x6,lsl #3]
 fmul d6,d2,d0
 fmul d7,d3,d1
 fsub d16,d6,d7
 fmul d6,d3,d0
 fmul d7,d2,d1
 fadd d17,d6,d7
 ldr d4,[x13,x6,lsl #3]
 ldr d5,[x14,x6,lsl #3]
 ldr d18,[x15,x6,lsl #3]
 ldr d19,[x16,x6,lsl #3]
 fmul d6,d16,d4
 fadd d20,d18,d6
 fmul d7,d17,d5
 fadd d20,d20,d7
 fmul d6,d17,d4
 fsub d21,d19,d6
 fmul d7,d16,d5
 fadd d21,d21,d7
 str d20,[x15,x6,lsl #3]
 str d21,[x16,x6,lsl #3]
 cbz w1,.Lnext_wind_column
 ldr d4,[x2,x6,lsl #3]
 ldr d5,[x3,x6,lsl #3]
 fmul d6,d16,d4
 fmul d7,d17,d5
 fadd d20,d6,d7
 fneg d6,d17
 fmul d6,d6,d4
 fmul d7,d16,d5
 fadd d21,d6,d7
 str d20,[x17,x6,lsl #3]
 str d21,[x0,x6,lsl #3]
.Lnext_wind_column:
 add x6,x6,#1
 add x5,x5,#1
 cmp x5,x27
 b.lt .Lwind_column
.Lnext_wind_level:
 add x4,x4,#1
 cmp x4,x23
 b.lt .Lwind_level
 /* Add the transported temperature term after all wind cells. */
 argument x9,1
 ldr w10,[x9,#1376]
 sub w10,w10,#1
 argument x11,25
 madd x10,x10,x25,x11
 str x10,[sp,#1056]
 ldr w9,[x9,#1432]
 sub w9,w9,#1
 scratch x11,0
 madd x11,x9,x25,x11
 mov x12,#0
.Ltemperature_level:
 mov x13,x26
 madd x14,x12,x22,x26
 cmp x13,x27
 b.ge .Lnext_temperature_level
.Ltemperature_column:
 ldr d0,[x10,x14,lsl #3]
 ldr d1,[x11,x14,lsl #3]
 fadd d0,d0,d1
 str d0,[x10,x14,lsl #3]
 add x14,x14,#1
 add x13,x13,#1
 cmp x13,x27
 b.lt .Ltemperature_column
.Lnext_temperature_level:
 add x12,x12,#1
 cmp x12,x23
 b.lt .Ltemperature_level
 /* Keep the field order when constituent destinations share storage. */
 mov x9,#0
 add x10,x20,#4040
.Lconstituent_field:
 ldr w11,[sp,#812]
 cmp x9,x11
 b.ge .Lspectral_moisture_copy
 ldr w11,[x10,#20]
 cbz w11,.Lnext_constituent_field
 mov w11,#0
 ldr x12,[x10]
 integer_value x13,0x2020202051475643
 cmp x12,x13
 b.ne .Lordinary_constituent
 ldr x12,[x10,#8]
 integer_value x13,0x2020202020202020
 cmp x12,x13
 b.ne .Lordinary_constituent
 ldr w12,[x10,#52]
 cbz w12,.Lordinary_constituent
 mov w11,#1
 b .Lconstituent_destination
.Lordinary_constituent:
 ldr w12,[x10,#48]
 cbnz w12,.Lnext_constituent_field
.Lconstituent_destination:
 ldr w12,[x10,#188]
 sub w12,w12,#1
 argument x13,27
 madd x12,x12,x25,x13
 scratch x13,4
 madd x13,x9,x25,x13
 argument x14,21
 mov x15,#0
.Lconstituent_level:
 mov x16,x26
 madd x17,x15,x22,x26
 cmp x16,x27
 b.ge .Lnext_constituent_level
.Lconstituent_column:
 ldr d0,[x13,x17,lsl #3]
 cbnz w11,.Lmoisture_convergence
 ldr d1,[x12,x17,lsl #3]
 fadd d0,d1,d0
 b .Lstore_constituent
.Lmoisture_convergence:
 ldr d1,[x14,x17,lsl #3]
 fsub d0,d0,d1
.Lstore_constituent:
 str d0,[x12,x17,lsl #3]
 add x17,x17,#1
 add x16,x16,#1
 cmp x16,x27
 b.lt .Lconstituent_column
.Lnext_constituent_level:
 add x15,x15,#1
 cmp x15,x23
 b.lt .Lconstituent_level
.Lnext_constituent_field:
 add x10,x10,#368
 add x9,x9,#1
 b .Lconstituent_field
.Lspectral_moisture_copy:
 add x9,x20,#192
 integer_value x10,800056
 ldr x10,[x9,x10]
 ldr w11,[x10,#56]
 cbz w11,.Ldry_air_temperature_product
 ldr w11,[x10,#188]
 sub w11,w11,#1
 integer_value x10,799840
 ldr x10,[x9,x10]
 ldr w12,[x10,#188]
 sub w12,w12,#1
 argument x13,27
 madd x11,x11,x25,x13
 madd x12,x12,x25,x13
 mov x14,#0
.Lcopy_moisture_level:
 mov x15,x26
 madd x16,x14,x22,x26
 cmp x15,x27
 b.ge .Lnext_copy_moisture_level
.Lcopy_moisture_column:
 ldr x17,[x12,x16,lsl #3]
 str x17,[x11,x16,lsl #3]
 add x16,x16,#1
 add x15,x15,#1
 cmp x15,x27
 b.lt .Lcopy_moisture_column
.Lnext_copy_moisture_level:
 add x14,x14,#1
 cmp x14,x23
 b.lt .Lcopy_moisture_level
.Ldry_air_temperature_product:
#ifdef LAPINEB_EXPLICIT_CONTEXT
 ldr x9,[sp,#1512]
 add x9,x9,#184
#else
 adrp x9,:got:__yomcst_MOD_rd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
#endif
 ldr d0,[x9]
 ldr x10,[sp,#1056]
 scratch x11,15
 mov x12,#0
.Ldry_air_level:
 mov x13,x26
 madd x14,x12,x22,x26
 cmp x13,x27
 b.ge .Lnext_dry_air_level
.Ldry_air_column:
 ldr d1,[x10,x14,lsl #3]
 fmul d1,d0,d1
 str d1,[x11,x14,lsl #3]
 add x14,x14,#1
 add x13,x13,#1
 cmp x13,x27
 b.lt .Ldry_air_column
.Lnext_dry_air_level:
 add x12,x12,#1
 cmp x12,x23
 b.lt .Ldry_air_level
 mov x0,x28
 bl free
 adrp x9,.Lcomplete_calls
 add x9,x9,:lo12:.Lcomplete_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x9,sp,#640
 ldp d8,d9,[x9,#96]
 ldp d10,d11,[x9,#112]
 ldp d12,d13,[x9,#128]
 ldp d14,d15,[x9,#144]
 ldp x19,x20,[x9,#0]
 ldp x21,x22,[x9,#16]
 ldp x23,x24,[x9,#32]
 ldp x25,x26,[x9,#48]
 ldp x27,x28,[x9,#64]
 ldp x29,x30,[x9,#80]
 add sp,sp,#2048
 ret
#ifdef LAPINEB_EXPLICIT_CONTEXT
/* x0..x1 is a new read-only interval. Preserve x19..x28 and all FP state.
 * Each size comes from the producer named in interface_records.json.
 * The caller supplies complete mapped owners; these checks prove address
 * arithmetic and disjointness before any allocation or public mutation. */
.Lruntime_readonly_overlap:
 mov x2,#22
.Lruntime_owner_loop:
 argument x3,0
 mov x4,x25
 cmp x2,#22
 b.ne .Lruntime_not_sco
 ldrsw x5,[x21,#6808]
 b .Lruntime_field_planes
.Lruntime_not_sco:
 cmp x2,#23
 b.ne .Lruntime_not_cco
 ldrsw x5,[x21,#6828]
 b .Lruntime_field_planes
.Lruntime_not_cco:
 cmp x2,#24
 b.ne .Lruntime_not_slbuf2
 argument x5,3
 ldrsw x5,[x5]
 lsl x4,x22,#3
 b .Lruntime_field_planes
.Lruntime_not_slbuf2:
 cmp x2,#25
 b.ne .Lruntime_not_gmv
 argument x5,1
 ldrsw x5,[x5,#1360]
 b .Lruntime_field_planes
.Lruntime_not_gmv:
 cmp x2,#26
 b.ne .Lruntime_not_gmvs
 argument x5,1
 ldrsw x5,[x5,#1364]
 lsl x4,x22,#3
 b .Lruntime_field_planes
.Lruntime_not_gmvs:
 cmp x2,#27
 b.ne .Lruntime_not_gfl
 ldrsw x5,[x20,#256]
 b .Lruntime_field_planes
.Lruntime_not_gfl:
 cmp x2,#28
 b.ne .Lruntime_not_pc
 ldrsw x5,[x20,#276]
 b .Lruntime_field_planes
.Lruntime_not_pc:
 cmp x2,#31
 b.gt .Lruntime_split_outputs
 /* LRDDHDYN defines either full P*L storage or a one-cell diagnostic. */
 integer_value x5,4233012
 ldr w5,[x20,x5]
 cbnz w5,.Lruntime_diagnostic_cells_ready
 mov x4,#8
.Lruntime_diagnostic_cells_ready:
 cmp x2,#29
 b.ne .Lruntime_not_gmv_diagnostic
 ldrsw x5,[x20,#16]
 cmp x5,#0
 b.lt .Lunsupported
 add x5,x5,#2
 b .Lruntime_field_planes
.Lruntime_not_gmv_diagnostic:
 cmp x2,#30
 b.ne .Lruntime_si_diagnostic
 ldrsw x5,[sp,#812]
 b .Lruntime_field_planes
.Lruntime_si_diagnostic:
 integer_value x5,4267708
 ldrsw x5,[x20,x5]
 b .Lruntime_field_planes
.Lruntime_split_outputs:
 cmp x2,#35
 b.ne .Lruntime_owner_extent
 ldrsw x5,[x20,#264]
.Lruntime_field_planes:
 cmp x5,#0
 b.lt .Lunsupported
 /* P*L <= 262144 and each count is a nonnegative int32, so this
  * complete byte extent fits uint64 without multiplication overflow. */
 mul x4,x4,x5
.Lruntime_owner_extent:
 cbz x4,.Lruntime_owner_next
 add x6,sp,#320
 ldr x3,[x6,x2,lsl#3]
 cbz x3,.Lunsupported
 tst x3,#7
 b.ne .Lunsupported
 adds x5,x3,x4
 b.cs .Lunsupported
 cmp x0,x5
 b.hs .Lruntime_owner_next
 cmp x3,x1
 b.lo .Lunsupported
.Lruntime_owner_next:
 add x2,x2,#1
 cmp x2,#36
 b.lo .Lruntime_owner_loop
 ret
#endif
.Lunsupported:
 bl abort
 brk #0
.size md2asm_lapineb_7259755,.-md2asm_lapineb_7259755
/* Write complete positive-zero FP64 words without floating-point arithmetic. */
.Lpositive_zero:
 cbz x1,.Lzero_return
.Lzero_word:
 str xzr,[x0],#8
 subs x1,x1,#8
 b.ne .Lzero_word
.Lzero_return:
 ret
.global md2asm_lapineb_calls_get
.type md2asm_lapineb_calls_get,%function
md2asm_lapineb_calls_get:
 adrp x9,.Lcomplete_calls
 ldr x0,[x9,:lo12:.Lcomplete_calls]
 ret
.size md2asm_lapineb_calls_get,.-md2asm_lapineb_calls_get
.global md2asm_lapineb_vertical_calls_get
.type md2asm_lapineb_vertical_calls_get,%function
md2asm_lapineb_vertical_calls_get:
 adrp x9,.Lvertical_calls
 ldr x0,[x9,:lo12:.Lvertical_calls]
 ret
.size md2asm_lapineb_vertical_calls_get,.-md2asm_lapineb_vertical_calls_get
.section .rodata
.Loperation_top: .ascii "ITOP"
.Lboundary_derivatives: .ascii "11"
.bss
.p2align 3
.Lcomplete_calls:
 .zero 8
.Lvertical_calls:
 .zero 8
.section .note.GNU-stack,"",%progbits

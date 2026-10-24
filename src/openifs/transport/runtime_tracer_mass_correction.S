/* Complete selected direct QMFIXER tracer correction.
 * Contract skills/md2asm/references/openifs/transport/runtime_tracer_mass_correction.md. Fifteen original addresses plus explicit dependency16.
 * Owns all pressure setup, packing, mass differences, weights, correction and limiting.
 * All children are direct private assembly. EXP/LOG/POW supply only declared elementary functions.
 * The 1536-byte frame has outgoing pointers at 0..95, preserved registers at 96..199,
 * original argument map at 216..335, scalar/control slots at 352..399 and work pointers at 400..511.
 * Arithmetic scratch, means and factors start at 600, with x18 protection at 1512.
 */
.text
.p2align 4
.macro QM_CALL target
 str x18,[sp,#1512]
 bl \target
 ldr x18,[sp,#1512]
.endm
.global md2asm_runtime_tracer_mass_correction
.type md2asm_runtime_tracer_mass_correction,%function
md2asm_runtime_tracer_mass_correction:
 mov x16,sp
 sub sp,sp,#1536
 stp x18,x30,[sp,#96]
 stp x19,x20,[sp,#112]
 stp x21,x22,[sp,#128]
 stp x23,x24,[sp,#144]
 stp x25,x26,[sp,#160]
 stp x27,x28,[sp,#176]
 str x29,[sp,#192]
 stp x0,x1,[sp,#216]
 stp x2,x3,[sp,#232]
 stp x4,x5,[sp,#248]
 stp x6,x7,[sp,#264]
 ldp x9,x10,[x16]
 stp x9,x10,[sp,#280]
 ldp x9,x10,[x16,#16]
 stp x9,x10,[sp,#296]
 ldp x9,x10,[x16,#32]
 stp x9,x10,[sp,#312]
 ldr x9,[x16,#48]
 str x9,[sp,#328]
 ldr x9,[x16,#56]
 str x9,[sp,#336]
 mov x20,#0
 add x19,sp,#216
 mrs x9,fpcr
 cbnz x9,.Lqm_bad
 mov x9,#0
.Lqm_pointer_guard:
 ldr x10,[x19,x9,lsl #3]
 cbz x10,.Lqm_bad
 add x9,x9,#1
 cmp x9,#15
 b.lt .Lqm_pointer_guard
 ldr x9,[sp,#336]
 cbz x9,.Lqm_bad
 tst x9,#7
 b.ne .Lqm_bad
 ldr x10,[x9,#24]
 cbnz x10,.Lqm_bad
 ldp x10,x11,[x9]
 cbz x10,.Lqm_bad
 cbz x11,.Lqm_bad
 ldr x10,[x9,#16]
 cbz x10,.Lqm_bad
 ldr x9,[x19]
 ldr w10,[x9,#5144]
 sub w11,w10,#1
 cmp w11,#4095
 b.hi .Lqm_bad
 str w10,[sp,#368]
 ldrsw x11,[x9,#5160]
 cmp x11,#1
 b.lt .Lqm_bad
 str x11,[sp,#384]
 ldrsw x12,[x9,#7376]
 cmp x12,#1
 b.lt .Lqm_bad
 str x12,[sp,#392]
 uxtw x10,w10
 mul x13,x10,x11
 cmp x12,x13
 b.hi .Lqm_bad
 sub x14,x13,x10
 cmp x12,x14
 b.ls .Lqm_bad
 sub x14,x12,x14
 str w14,[sp,#592]
 str x13,[sp,#536]
 lsl x13,x13,#3
 str x13,[sp,#584]
 ldr w11,[x9,#5224]
 sub w12,w11,#1
 cmp w12,#4095
 b.hi .Lqm_bad
 str w11,[sp,#372]
 uxtw x11,w11
 mul x12,x10,x11
 str x12,[sp,#512]
 lsl x12,x12,#3
 str x12,[sp,#520]
 add x13,x12,x10,lsl #3
 str x13,[sp,#528]
 lsl x13,x12,#1
 str x13,[sp,#560]
 mov x13,#5
 mul x13,x12,x13
 str x13,[sp,#576]
 ldrsw x10,[x9,#5244]
 ldrsw x11,[x9,#5248]
 subs x11,x11,x10
 b.lt .Lqm_bad
 add x11,x11,#1
 str x11,[sp,#1240]
 ldr x10,[x19,#72]
 ldrsw x10,[x10,#1016]
 cmp x10,#1
 b.lt .Lqm_bad
 mul x12,x10,x11
 mov x13,#2147483647
 cmp x12,x13
 b.hi .Lqm_bad
 str x10,[sp,#1288]
 ldr x9,[x19,#32]
 ldr w10,[x9,#48]
 cmp w10,#5
 b.lt .Lqm_bad
 cmp w10,#2163
 b.hi .Lqm_bad
 ldr x11,[sp,#520]
 uxtw x10,w10
 mul x10,x10,x11
 str x10,[sp,#544]
 ldr w10,[x9,#64]
 cmp w10,#5
 b.lt .Lqm_bad
 cmp w10,#2163
 b.hi .Lqm_bad
 uxtw x10,w10
 mul x10,x10,x11
 str x10,[sp,#552]
 ldr w10,[x9,#304]
 cmp w10,#5
 b.ne .Lqm_bad
 ldr w10,[x9,#308]
 cmp w10,#3
 b.ne .Lqm_bad
 ldr w10,[x9,#164]
 cmp w10,#1
 b.ne .Lqm_bad
 ldr w10,[x9,#316]
 cbnz w10,.Lqm_bad
 ldr w10,[x9,#320]
 cbnz w10,.Lqm_bad
 ldr w10,[x9,#168]
 cbnz w10,.Lqm_bad
 ldr w10,[x9,#284]
 cbnz w10,.Lqm_bad
 ldr w10,[x9,#300]
 cbnz w10,.Lqm_bad
 ldr x10,[x19,#40]
 ldr w11,[x10,#268]
 cbnz w11,.Lqm_bad
 ldrsw x11,[x10,#6472]
 cmp x11,#6
 b.lt .Lqm_bad
 cmp x11,#4096
 b.hi .Lqm_bad
 ldr x12,[sp,#520]
 mul x13,x11,x12
 str x13,[sp,#568]
 ldrsw x13,[x10,#6452]
 sub x13,x13,#1
 cmp x13,x11
 b.hs .Lqm_bad
 mul x13,x13,x12
 str x13,[sp,#1264]
 ldrsw x13,[x10,#6448]
 cmp x13,#1
 b.lt .Lqm_bad
 cmp x13,x11
 b.hs .Lqm_bad
 mul x13,x13,x12
 str x13,[sp,#1272]
 ldrsw x13,[x10,#6456]
 sub x13,x13,#1
 cmp x13,x11
 b.hs .Lqm_bad
 mul x13,x13,x12
 str x13,[sp,#1280]
 ldrsw x11,[x10,#8880]
 cmp x11,#1
 b.lt .Lqm_bad
 mov x12,#16777216
 cmp x11,x12
 b.hi .Lqm_bad
 str x11,[sp,#1248]
 ldrsw x11,[x10,#8972]
 cmp x11,#1
 b.lt .Lqm_bad
 sub x11,x11,#1
 str x11,[sp,#1256]
 ldr x10,[x19,#8]
 ldrsw x11,[x10,#996]
 cmp x11,#1
 b.lt .Lqm_bad
 cmp x11,#4096
 b.hi .Lqm_bad
 ldr w12,[sp,#368]
 mul x11,x11,x12
 str x11,[sp,#1200]
 ldrsw x11,[x10,#1096]
 cmp x11,#1
 b.lt .Lqm_bad
 sub x11,x11,#1
 mul x11,x11,x12
 str x11,[sp,#1208]
 ldr w11,[x10,#1364]
 cmp w11,#1
 b.ne .Lqm_bad
 ldr w11,[x10,#1400]
 cmp w11,#1
 b.ne .Lqm_bad
 mov x21,#0
.Lqm_field_guard:
 add x10,x9,#324
 ldr w11,[x10,x21,lsl #2]
 add x12,x21,#1
 cmp x11,x12
 b.ne .Lqm_bad
 mov x10,#368
 mul x10,x21,x10
 add x10,x9,x10
 add x10,x10,#3848
 ldr w11,[x10,#168]
 cmp x11,x12
 b.ne .Lqm_bad
 ldr w11,[x10,#188]
 cmp x11,x12
 b.ne .Lqm_bad
 ldr x11,[x10,#344]
 ldr x12,.Lqm_beta_word
 cmp x11,x12
 b.ne .Lqm_bad
 ldr w11,[x10,#324]
 cbnz w11,.Lqm_bad
 ldrsw x11,[x10,#216]
 cmp x11,#1
 b.lt .Lqm_bad
 sub x11,x11,#1
 ldr x12,[sp,#1240]
 mul x11,x11,x12
 ldr x13,[sp,#1256]
 add x11,x11,x13
 add x11,x11,x12
 ldr x12,[sp,#1248]
 cmp x11,x12
 b.hi .Lqm_bad
 add x21,x21,#1
 cmp x21,#5
 b.lt .Lqm_field_guard
 /* One bounded owner contains all fourteen source temporaries. */
 mov x14,#0
 str x14,[sp,#400]
 ldr x13,[sp,#584]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#408]
 ldr x13,[sp,#584]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#416]
 ldr x13,[sp,#528]
 ldr x12,[sp,#384]
 mul x13,x13,x12
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#424]
 ldr x13,[sp,#528]
 ldr x12,[sp,#384]
 mul x13,x13,x12
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#432]
 ldr x13,[sp,#520]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#440]
 ldr x13,[sp,#520]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#448]
 ldr x13,[sp,#528]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#456]
 ldr x13,[sp,#528]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#464]
 ldr x13,[sp,#520]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#472]
 ldr x13,[sp,#520]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#480]
 ldr x13,[sp,#520]
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#488]
 ldr x13,[sp,#576]
 ldr x12,[sp,#384]
 mul x13,x13,x12
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#496]
 ldr x13,[sp,#584]
 mov x12,#10
 mul x13,x13,x12
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#504]
 ldr x13,[sp,#584]
 mov x12,#5
 mul x13,x13,x12
 adds x14,x14,x13
 b.cs .Lqm_bad
 str x14,[sp,#1328]
 mov x0,x14
 QM_CALL malloc
 mov x20,x0
 cmp x0,#0
 cset w0,eq
 QM_CALL .Lqm_agree
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 ldr x9,[sp,#400]
 add x9,x20,x9
 str x9,[sp,#400]
 ldr x9,[sp,#408]
 add x9,x20,x9
 str x9,[sp,#408]
 ldr x9,[sp,#416]
 add x9,x20,x9
 str x9,[sp,#416]
 ldr x9,[sp,#424]
 add x9,x20,x9
 str x9,[sp,#424]
 ldr x9,[sp,#432]
 add x9,x20,x9
 str x9,[sp,#432]
 ldr x9,[sp,#440]
 add x9,x20,x9
 str x9,[sp,#440]
 ldr x9,[sp,#448]
 add x9,x20,x9
 str x9,[sp,#448]
 ldr x9,[sp,#456]
 add x9,x20,x9
 str x9,[sp,#456]
 ldr x9,[sp,#464]
 add x9,x20,x9
 str x9,[sp,#464]
 ldr x9,[sp,#472]
 add x9,x20,x9
 str x9,[sp,#472]
 ldr x9,[sp,#480]
 add x9,x20,x9
 str x9,[sp,#480]
 ldr x9,[sp,#488]
 add x9,x20,x9
 str x9,[sp,#488]
 ldr x9,[sp,#496]
 add x9,x20,x9
 str x9,[sp,#496]
 ldr x9,[sp,#504]
 add x9,x20,x9
 str x9,[sp,#504]
 str wzr,[sp,#352]
.Lqm_pressure_start:
 mov x22,#0
 ldr w28,[sp,#368]
.Lqm_pressure_block:
 ldr x9,[sp,#384]
 cmp x22,x9
 b.ge .Lqm_pressure_fix
 ldr w24,[sp,#368]
 ldr x9,[sp,#384]
 sub x9,x9,#1
 cmp x22,x9
 ldr w9,[sp,#592]
 csel x24,x9,x24,eq
 mov x23,#0
.Lqm_pressure_row:
 cmp x23,x24
 b.ge .Lqm_pressure_next
 ldr x9,[sp,#1200]
 madd x9,x22,x9,x23
 ldr x10,[sp,#1208]
 add x9,x9,x10
 ldr x10,[x19,#80]
 ldr d0,[x10,x9,lsl #3]
 QM_CALL exp
 ldr x10,[sp,#400]
 madd x9,x22,x28,x23
 str d0,[x10,x9,lsl #3]
 ldr x10,[x19,#88]
 ldr w9,[sp,#368]
 madd x9,x22,x9,x23
 ldr d0,[x10,x9,lsl #3]
 QM_CALL exp
 ldr x10,[sp,#408]
 madd x9,x22,x28,x23
 str d0,[x10,x9,lsl #3]
 add x23,x23,#1
 b .Lqm_pressure_row
.Lqm_pressure_next:
 add x22,x22,#1
 b .Lqm_pressure_block
.Lqm_pressure_fix:
 ldr x0,[x19,#0]
 ldr x1,[x19,#8]
 ldr x2,[x19,#32]
 ldr x3,[x19,#40]
 add x3,x3,#456
 ldr x4,[sp,#400]
 ldr x5,[sp,#408]
 ldr x6,[x19,#88]
 ldr x7,[sp,#336]
 QM_CALL md2asm_runtime_surface_pressure_mass_correction
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 mov x22,#0
.Lqm_hybrid_block:
 ldr x9,[sp,#384]
 cmp x22,x9
 b.ge .Lqm_mass_begin
 ldr w24,[sp,#368]
 ldr x9,[sp,#384]
 sub x9,x9,#1
 cmp x22,x9
 ldr w9,[sp,#592]
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x10,[sp,#400]
 ldr x11,[sp,#416]
 ldr x9,[sp,#528]
 madd x11,x22,x9,x11
 mov x23,#0
.Lqm_bottom_0:
 cmp x23,x24
 b.ge .Lqm_hybrid_0
 ldr w9,[sp,#368]
 madd x9,x22,x9,x23
 ldr d0,[x10,x9,lsl #3]
 ldr x9,[sp,#520]
 add x9,x11,x9
 str d0,[x9,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_bottom_0
.Lqm_hybrid_0:
 add x0,sp,#368
 add x1,sp,#372
 adr x2,.Lqm_one
 add x3,sp,#376
 ldr x9,[x19,#0]
 ldr x4,[x9,#3240]
 ldr x5,[x9,#3264]
 ldr x6,[sp,#416]
 ldr x9,[sp,#528]
 madd x6,x22,x9,x6
 mov x7,#0
 str xzr,[sp]
 ldr x9,[sp,#336]
 ldr x9,[x9,#16]
 str x9,[sp,#8]
 QM_CALL md2asm_operational_hydrostatic_private_gphpre
 ldr x10,[sp,#408]
 ldr x11,[sp,#424]
 ldr x9,[sp,#528]
 madd x11,x22,x9,x11
 mov x23,#0
.Lqm_bottom_1:
 cmp x23,x24
 b.ge .Lqm_hybrid_1
 ldr w9,[sp,#368]
 madd x9,x22,x9,x23
 ldr d0,[x10,x9,lsl #3]
 ldr x9,[sp,#520]
 add x9,x11,x9
 str d0,[x9,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_bottom_1
.Lqm_hybrid_1:
 add x0,sp,#368
 add x1,sp,#372
 adr x2,.Lqm_one
 add x3,sp,#376
 ldr x9,[x19,#0]
 ldr x4,[x9,#3240]
 ldr x5,[x9,#3264]
 ldr x6,[sp,#424]
 ldr x9,[sp,#528]
 madd x6,x22,x9,x6
 mov x7,#0
 str xzr,[sp]
 ldr x9,[sp,#336]
 ldr x9,[x9,#16]
 str x9,[sp,#8]
 QM_CALL md2asm_operational_hydrostatic_private_gphpre
 add x22,x22,#1
 b .Lqm_hybrid_block
.Lqm_mass_begin:
 mov x21,#0
.Lqm_mass_field:
 cmp x21,#5
 b.ge .Lqm_mass_norm
 mov x22,#0
.Lqm_mass_block:
 ldr x9,[sp,#384]
 cmp x22,x9
 b.ge .Lqm_mass_next_field
 ldr w24,[sp,#368]
 ldr x9,[sp,#384]
 sub x9,x9,#1
 cmp x22,x9
 ldr w9,[sp,#592]
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x27,[x19,#96]
 ldr x9,[sp,#544]
 mul x9,x22,x9
 ldr x10,[sp,#520]
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#432]
 mov x23,#0
.Lqm_copy_0:
 ldr x9,[sp,#512]
 cmp x23,x9
 b.ge .Lqm_integrate_0
 ldr w9,[sp,#368]
 udiv x10,x23,x9
 msub x10,x10,x9,x23
 cmp x10,x24
 b.ge .Lqm_copy_next_0
 ldr d0,[x27,x23,lsl #3]
 str d0,[x28,x23,lsl #3]
.Lqm_copy_next_0:
 add x23,x23,#1
 b .Lqm_copy_0
.Lqm_integrate_0:
 add x0,sp,#368
 adr x1,.Lqm_one
 add x2,sp,#376
 add x3,sp,#372
 ldr x4,[sp,#448]
 ldr x5,[sp,#432]
 ldr x6,[sp,#416]
 ldr x9,[sp,#528]
 madd x6,x22,x9,x6
 ldr x7,[sp,#336]
 ldr x7,[x7,#16]
 QM_CALL md2asm_explicit_pressure_weighted_column_integral
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 ldr x27,[sp,#448]
 ldr x9,[sp,#520]
 add x27,x27,x9
 ldr x28,[sp,#496]
 ldr w9,[sp,#368]
 mov x10,#10
 mul x9,x9,x10
 mul x9,x22,x9
 add x10,x21,x21
 add x10,x10,#0
 ldr w11,[sp,#368]
 madd x9,x10,x11,x9
 add x28,x28,x9,lsl #3
 mov x23,#0
.Lqm_pack_mass_0:
 cmp x23,x24
 b.ge .Lqm_packed_mass_0
 ldr d0,[x27,x23,lsl #3]
 str d0,[x28,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_pack_mass_0
.Lqm_packed_mass_0:
 ldr x27,[x19,#104]
 ldr x9,[sp,#552]
 mul x9,x22,x9
 ldr x10,[sp,#520]
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#440]
 mov x23,#0
.Lqm_copy_1:
 ldr x9,[sp,#512]
 cmp x23,x9
 b.ge .Lqm_integrate_1
 ldr w9,[sp,#368]
 udiv x10,x23,x9
 msub x10,x10,x9,x23
 cmp x10,x24
 b.ge .Lqm_copy_next_1
 ldr d0,[x27,x23,lsl #3]
 str d0,[x28,x23,lsl #3]
.Lqm_copy_next_1:
 add x23,x23,#1
 b .Lqm_copy_1
.Lqm_integrate_1:
 add x0,sp,#368
 adr x1,.Lqm_one
 add x2,sp,#376
 add x3,sp,#372
 ldr x4,[sp,#456]
 ldr x5,[sp,#440]
 ldr x6,[sp,#424]
 ldr x9,[sp,#528]
 madd x6,x22,x9,x6
 ldr x7,[sp,#336]
 ldr x7,[x7,#16]
 QM_CALL md2asm_explicit_pressure_weighted_column_integral
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 ldr x27,[sp,#456]
 ldr x9,[sp,#520]
 add x27,x27,x9
 ldr x28,[sp,#496]
 ldr w9,[sp,#368]
 mov x10,#10
 mul x9,x9,x10
 mul x9,x22,x9
 add x10,x21,x21
 add x10,x10,#1
 ldr w11,[sp,#368]
 madd x9,x10,x11,x9
 add x28,x28,x9,lsl #3
 mov x23,#0
.Lqm_pack_mass_1:
 cmp x23,x24
 b.ge .Lqm_packed_mass_1
 ldr d0,[x27,x23,lsl #3]
 str d0,[x28,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_pack_mass_1
.Lqm_packed_mass_1:
 add x22,x22,#1
 b .Lqm_mass_block
.Lqm_mass_next_field:
 add x21,x21,#1
 b .Lqm_mass_field
.Lqm_mass_norm:
 ldr x0,[x19,#0]
 ldr x1,[sp,#496]
 adr x2,.Lqm_ten
 adr x3,.Lqm_false
 mov x4,#0
 add x5,sp,#800
 mov x6,#0
 ldr x7,[sp,#336]
 QM_CALL md2asm_runtime_grid_point_norm
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 mov x21,#0
.Lqm_weight_field:
 cmp x21,#5
 b.ge .Lqm_weight_norm
 mov x9,#48
 mul x9,x21,x9
 add x9,sp,x9
 ldr d0,[x9,#800]
 ldr d1,[x9,#824]
 fsub d0,d1,d0
 add x9,sp,#600
 str d0,[x9,x21,lsl #3]
 fmov d1,xzr
 fcmp d0,d1
 b.lt .Lqm_scale_negative
 ldr d1,.Lqm_eps
 fmax d0,d0,d1
 b .Lqm_scale_store
.Lqm_scale_negative:
 ldr d1,.Lqm_eps
 fneg d1,d1
 fmin d0,d0,d1
.Lqm_scale_store:
 add x9,sp,#640
 str d0,[x9,x21,lsl #3]
 mov x22,#0
.Lqm_weight_block:
 ldr x9,[sp,#384]
 cmp x22,x9
 b.ge .Lqm_weight_next_field
 ldr w24,[sp,#368]
 ldr x9,[sp,#384]
 sub x9,x9,#1
 cmp x22,x9
 ldr w9,[sp,#592]
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x9,[x19,#72]
 add x0,x9,#1016
 add x1,sp,#368
 adr x2,.Lqm_one
 add x3,sp,#376
 add x4,sp,#372
 ldr x9,[x19]
 mov x10,#5244
 add x5,x9,x10
 mov x10,#5248
 add x6,x9,x10
 ldr x7,[x19,#56]
 ldr x9,[sp,#568]
 madd x7,x22,x9,x7
 ldr x9,[sp,#1272]
 add x10,x7,x9
 str x10,[sp]
 ldr x10,[x19,#48]
 ldr x9,[sp,#560]
 madd x10,x22,x9,x10
 ldr x9,[sp,#512]
 add x10,x10,x9,lsl #2
 str x10,[sp,#8]
 ldr x9,[sp,#1280]
 add x10,x7,x9
 str x10,[sp,#16]
 ldr x9,[sp,#1264]
 add x7,x7,x9
 ldr x10,[x19,#32]
 mov x9,#368
 madd x10,x21,x9,x10
 add x10,x10,#3848
 ldrsw x10,[x10,#216]
 sub x10,x10,#1
 ldr x9,[sp,#1240]
 mul x10,x10,x9
 ldr x9,[sp,#1256]
 add x10,x10,x9
 ldr x9,[sp,#1288]
 mul x10,x10,x9
 ldr x11,[x19,#64]
 add x10,x11,x10,lsl #3
 str x10,[sp,#24]
 ldr x10,[sp,#464]
 str x10,[sp,#32]
 QM_CALL laitli_assembly_
 ldr x27,[x19,#104]
 ldr x9,[sp,#552]
 mul x9,x22,x9
 ldr x10,[sp,#520]
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#488]
 mov x9,#5
 madd x9,x22,x9,x21
 ldr x10,[sp,#520]
 mul x9,x9,x10
 add x28,x28,x9
 mov x23,#0
.Lqm_weight_cell:
 ldr x9,[sp,#512]
 cmp x23,x9
 b.ge .Lqm_weight_integral
 ldr w9,[sp,#368]
 udiv x10,x23,x9
 msub x11,x10,x9,x23
 cmp x11,x24
 b.ge .Lqm_weight_cell_next
 ldr x9,[sp,#464]
 ldr d0,[x27,x23,lsl #3]
 ldr d1,[x9,x23,lsl #3]
 fsub d0,d0,d1
 add x9,sp,#640
 ldr d1,[x9,x21,lsl #3]
 fdiv d0,d0,d1
 ldr d1,.Lqm_floor
 fcmp d0,d1
 b.le .Lqm_weight_zero
 fmov d1,#1.0
 QM_CALL pow
 str d0,[sp,#720]
 ldr x9,[sp,#424]
 ldr x10,[sp,#528]
 madd x9,x22,x10,x9
 ldr w10,[sp,#368]
 add x10,x23,x10
 ldr d1,[x9,x23,lsl #3]
 ldr d2,[x9,x10,lsl #3]
 fsub d2,d2,d1
 ldr w9,[sp,#368]
 udiv x10,x23,x9
 msub x10,x10,x9,x23
 madd x10,x22,x9,x10
 ldr x9,[x19,#0]
 mov x11,#9816
 ldr x9,[x9,x11]
 ldr d1,[x9,x10,lsl #3]
 fmul d1,d1,d2
 fabs d1,d1
 ldr d0,[sp,#720]
 fmul d0,d0,d1
 ldr d1,[x27,x23,lsl #3]
 fmul d0,d0,d1
 b .Lqm_weight_store
.Lqm_weight_zero:
 fmov d0,xzr
.Lqm_weight_store:
 str d0,[x28,x23,lsl #3]
 ldr x9,[sp,#440]
 str d0,[x9,x23,lsl #3]
.Lqm_weight_cell_next:
 add x23,x23,#1
 b .Lqm_weight_cell
.Lqm_weight_integral:
 add x0,sp,#368
 adr x1,.Lqm_one
 add x2,sp,#376
 add x3,sp,#372
 ldr x4,[sp,#456]
 ldr x5,[sp,#440]
 ldr x6,[sp,#424]
 ldr x9,[sp,#528]
 madd x6,x22,x9,x6
 ldr x7,[sp,#336]
 ldr x7,[x7,#16]
 QM_CALL md2asm_explicit_pressure_weighted_column_integral
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 ldr x27,[sp,#456]
 ldr x9,[sp,#520]
 add x27,x27,x9
 ldr x28,[sp,#504]
 mov x9,#5
 madd x9,x22,x9,x21
 ldr w10,[sp,#368]
 mul x9,x9,x10
 add x28,x28,x9,lsl #3
 mov x23,#0
.Lqm_pack_weight:
 cmp x23,x24
 b.ge .Lqm_packed_weight
 ldr d0,[x27,x23,lsl #3]
 str d0,[x28,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_pack_weight
.Lqm_packed_weight:
 add x22,x22,#1
 b .Lqm_weight_block
.Lqm_weight_next_field:
 add x21,x21,#1
 b .Lqm_weight_field
.Lqm_weight_norm:
 ldr x0,[x19,#0]
 ldr x1,[sp,#504]
 adr x2,.Lqm_five
 adr x3,.Lqm_false
 mov x4,#0
 add x5,sp,#1040
 mov x6,#0
 ldr x7,[sp,#336]
 QM_CALL md2asm_runtime_grid_point_norm
 str w0,[sp,#596]
 cbnz w0,.Lqm_release
 mov x21,#0
.Lqm_limit_field:
 cmp x21,#5
 b.ge .Lqm_done
 mov x9,#(3*8)
 mul x9,x21,x9
 add x9,sp,x9
 ldr d0,[x9,#1040]
 ldr d1,.Lqm_floor
 fmax d0,d0,d1
 add x9,sp,#600
 ldr d1,[x9,x21,lsl #3]
 fdiv d0,d1,d0
 add x9,sp,#680
 str d0,[x9,x21,lsl #3]
 mov x22,#0
.Lqm_limit_block:
 ldr x9,[sp,#384]
 cmp x22,x9
 b.ge .Lqm_limit_next_field
 ldr w24,[sp,#368]
 ldr x9,[sp,#384]
 sub x9,x9,#1
 cmp x22,x9
 ldr w9,[sp,#592]
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x9,[x19,#72]
 add x0,x9,#1016
 add x1,sp,#368
 adr x2,.Lqm_one
 add x3,sp,#376
 add x4,sp,#372
 ldr x9,[x19]
 mov x10,#5244
 add x5,x9,x10
 mov x10,#5248
 add x6,x9,x10
 ldr x7,[x19,#48]
 ldr x9,[sp,#560]
 madd x7,x22,x9,x7
 ldr x10,[x19,#32]
 mov x9,#368
 madd x10,x21,x9,x10
 add x10,x10,#3848
 ldrsw x10,[x10,#216]
 sub x10,x10,#1
 ldr x9,[sp,#1240]
 mul x10,x10,x9
 ldr x9,[sp,#1256]
 add x10,x10,x9
 ldr x9,[sp,#1288]
 mul x10,x10,x9
 ldr x11,[x19,#64]
 add x10,x11,x10,lsl #3
 str x10,[sp]
 ldr x10,[sp,#472]
 str x10,[sp,#8]
 ldr x10,[sp,#480]
 str x10,[sp,#16]
 QM_CALL laminmaxint_md2asm
 ldr x27,[x19,#104]
 ldr x9,[sp,#552]
 mul x9,x22,x9
 ldr x10,[sp,#520]
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#488]
 mov x9,#5
 madd x9,x22,x9,x21
 ldr x10,[sp,#520]
 mul x9,x9,x10
 add x28,x28,x9
 mov x23,#0
.Lqm_limit_cell:
 ldr x9,[sp,#512]
 cmp x23,x9
 b.ge .Lqm_limit_next_block
 ldr w9,[sp,#368]
 udiv x10,x23,x9
 msub x10,x10,x9,x23
 cmp x10,x24
 b.ge .Lqm_limit_next_cell
 add x9,sp,#680
 ldr d0,[x9,x21,lsl #3]
 fneg d0,d0
 ldr d1,[x28,x23,lsl #3]
 fmul d0,d0,d1
 ldr d1,[x27,x23,lsl #3]
 fadd d1,d1,d0
 ldr x9,[sp,#472]
 ldr d2,[x9,x23,lsl #3]
 fcmp d1,d2
 b.ge .Lqm_limit_upper
 fcmp d0,#0.0
 b.ge .Lqm_limit_upper
 fmov d1,d2
 b .Lqm_limit_store
.Lqm_limit_upper:
 ldr x9,[sp,#480]
 ldr d2,[x9,x23,lsl #3]
 fcmp d1,d2
 b.le .Lqm_limit_store
 fcmp d0,#0.0
 b.le .Lqm_limit_store
 fmov d1,d2
.Lqm_limit_store:
 str d1,[x27,x23,lsl #3]
.Lqm_limit_next_cell:
 add x23,x23,#1
 b .Lqm_limit_cell
.Lqm_limit_next_block:
 add x22,x22,#1
 b .Lqm_limit_block
.Lqm_limit_next_field:
 add x21,x21,#1
 b .Lqm_limit_field
 .Lqm_done:
 str wzr,[sp,#596]
.Lqm_release:
 cbz x20,.Lqm_return
 mov x0,x20
 QM_CALL free
.Lqm_return:
 ldr w0,[sp,#596]
 ldp x18,x30,[sp,#96]
 ldp x19,x20,[sp,#112]
 ldp x21,x22,[sp,#128]
 ldp x23,x24,[sp,#144]
 ldp x25,x26,[sp,#160]
 ldp x27,x28,[sp,#176]
 ldr x29,[sp,#192]
 add sp,sp,#1536
 ret
.size md2asm_runtime_tracer_mass_correction,.-md2asm_runtime_tracer_mass_correction
.Lqm_bad:
 mov w0,#2
 str w0,[sp,#596]
 b .Lqm_release
.Lqm_agree:
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
.p2align 3
.Lqm_beta_word: .quad 0x3ff0000000000000
.Lqm_eps: .double 1e-8
.Lqm_floor: .double 1e-25
.p2align 2
.Lqm_one: .word 1
.Lqm_false: .word 0
.Lqm_ten: .word 10
.Lqm_five: .word 5
.section .note.GNU-stack,"",%progbits

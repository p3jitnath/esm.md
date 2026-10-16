/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
/* Complete selected direct QMFIXER tracer correction.
 * Contract tracer_mass_correction_contract.md. Fifteen original addresses.
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
.global md2asm_qmfixer_address_r2_7358525
.type md2asm_qmfixer_address_r2_7358525,%function
md2asm_qmfixer_address_r2_7358525:
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
 ldr x9,[x19]
 ldr w10,[x9,#5144]
 cmp w10,#24
 b.ne .Lqm_bad
 ldr w10,[x9,#7376]
 cmp w10,#2048
 b.ne .Lqm_bad
 ldr w10,[x9,#5224]
 cmp w10,#19
 b.ne .Lqm_bad
 ldr x9,[x19,#32]
 ldr w10,[x9,#48]
 cmp w10,#8
 b.ne .Lqm_bad
 ldr w10,[x9,#64]
 cmp w10,#6
 b.ne .Lqm_bad
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
 ldr w11,[x10,#6472]
 cmp w11,#12
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
 add x21,x21,#1
 cmp x21,#5
 b.lt .Lqm_field_guard
 movz x0,#45376
 movk x0,#38,lsl #16
 QM_CALL malloc
 cbz x0,.Lqm_bad
 mov x20,x0
 movz x9,#0
 movk x9,#0,lsl #16
 add x9,x20,x9
 str x9,[sp,#400]
 movz x9,#16512
 movk x9,#0,lsl #16
 add x9,x20,x9
 str x9,[sp,#408]
 movz x9,#33024
 movk x9,#0,lsl #16
 add x9,x20,x9
 str x9,[sp,#416]
 movz x9,#35584
 movk x9,#5,lsl #16
 add x9,x20,x9
 str x9,[sp,#424]
 movz x9,#38144
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#432]
 movz x9,#41792
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#440]
 movz x9,#45440
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#448]
 movz x9,#49280
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#456]
 movz x9,#53120
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#464]
 movz x9,#56768
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#472]
 movz x9,#60416
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#480]
 movz x9,#64064
 movk x9,#10,lsl #16
 add x9,x20,x9
 str x9,[sp,#488]
 movz x9,#59840
 movk x9,#34,lsl #16
 add x9,x20,x9
 str x9,[sp,#496]
 movz x9,#28352
 movk x9,#37,lsl #16
 add x9,x20,x9
 str x9,[sp,#504]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#352]
 cbz w9,.Lqm_pressure_start
 adr x0,.Lqm_name
 add x1,sp,#356
 str wzr,[x1]
 add x2,sp,#360
 mov x3,#7
 QM_CALL __yomhook_MOD_dr_hook_default8
.Lqm_pressure_start:
 mov x22,#0
 mov x28,#24
.Lqm_pressure_block:
 cmp x22,#86
 b.ge .Lqm_pressure_fix
 mov x24,#24
 cmp x22,#85
 mov x9,#8
 csel x24,x9,x24,eq
 mov x23,#0
.Lqm_pressure_row:
 cmp x23,x24
 b.ge .Lqm_pressure_next
 mov x9,#72
 madd x9,x22,x9,x23
 ldr x10,[x19,#80]
 ldr d0,[x10,x9,lsl #3]
 QM_CALL exp
 ldr x10,[sp,#400]
 madd x9,x22,x28,x23
 str d0,[x10,x9,lsl #3]
 ldr x10,[x19,#88]
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
 QM_CALL md2asm_pfixer_7358525
 mov x22,#0
.Lqm_hybrid_block:
 cmp x22,#86
 b.ge .Lqm_mass_begin
 mov x24,#24
 cmp x22,#85
 mov x9,#8
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x10,[sp,#400]
 ldr x11,[sp,#416]
 mov x9,#3840
 madd x11,x22,x9,x11
 mov x23,#0
.Lqm_bottom_0:
 cmp x23,x24
 b.ge .Lqm_hybrid_0
 mov x9,#24
 madd x9,x22,x9,x23
 ldr d0,[x10,x9,lsl #3]
 add x9,x11,#3648
 str d0,[x9,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_bottom_0
.Lqm_hybrid_0:
 adr x0,.Lqm_p
 adr x1,.Lqm_l
 adr x2,.Lqm_one
 add x3,sp,#376
 ldr x9,[x19,#0]
 ldr x4,[x9,#3240]
 ldr x5,[x9,#3264]
 ldr x6,[sp,#416]
 mov x9,#3840
 madd x6,x22,x9,x6
 mov x7,#0
 str xzr,[sp]
 QM_CALL md2asm_qm_gphpre_child
 ldr x10,[sp,#408]
 ldr x11,[sp,#424]
 mov x9,#3840
 madd x11,x22,x9,x11
 mov x23,#0
.Lqm_bottom_1:
 cmp x23,x24
 b.ge .Lqm_hybrid_1
 mov x9,#24
 madd x9,x22,x9,x23
 ldr d0,[x10,x9,lsl #3]
 add x9,x11,#3648
 str d0,[x9,x23,lsl #3]
 add x23,x23,#1
 b .Lqm_bottom_1
.Lqm_hybrid_1:
 adr x0,.Lqm_p
 adr x1,.Lqm_l
 adr x2,.Lqm_one
 add x3,sp,#376
 ldr x9,[x19,#0]
 ldr x4,[x9,#3240]
 ldr x5,[x9,#3264]
 ldr x6,[sp,#424]
 mov x9,#3840
 madd x6,x22,x9,x6
 mov x7,#0
 str xzr,[sp]
 QM_CALL md2asm_qm_gphpre_child
 add x22,x22,#1
 b .Lqm_hybrid_block
.Lqm_mass_begin:
 mov x21,#0
.Lqm_mass_field:
 cmp x21,#5
 b.ge .Lqm_mass_norm
 mov x22,#0
.Lqm_mass_block:
 cmp x22,#86
 b.ge .Lqm_mass_next_field
 mov x24,#24
 cmp x22,#85
 mov x9,#8
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x27,[x19,#96]
 mov x9,#29184
 mul x9,x22,x9
 mov x10,#3648
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#432]
 mov x23,#0
.Lqm_copy_0:
 cmp x23,#456
 b.ge .Lqm_integrate_0
 mov x9,#24
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
 adr x0,.Lqm_p
 adr x1,.Lqm_one
 add x2,sp,#376
 adr x3,.Lqm_l
 ldr x4,[sp,#448]
 ldr x5,[sp,#432]
 ldr x6,[sp,#416]
 mov x9,#3840
 madd x6,x22,x9,x6
 QM_CALL md2asm_qm_gppwc_child
 ldr x27,[sp,#448]
 add x27,x27,#3648
 ldr x28,[sp,#496]
 mov x9,#240
 mul x9,x22,x9
 add x10,x21,x21
 add x10,x10,#0
 mov x11,#24
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
 mov x9,#21888
 mul x9,x22,x9
 mov x10,#3648
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#440]
 mov x23,#0
.Lqm_copy_1:
 cmp x23,#456
 b.ge .Lqm_integrate_1
 mov x9,#24
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
 adr x0,.Lqm_p
 adr x1,.Lqm_one
 add x2,sp,#376
 adr x3,.Lqm_l
 ldr x4,[sp,#456]
 ldr x5,[sp,#440]
 ldr x6,[sp,#424]
 mov x9,#3840
 madd x6,x22,x9,x6
 QM_CALL md2asm_qm_gppwc_child
 ldr x27,[sp,#456]
 add x27,x27,#3648
 ldr x28,[sp,#496]
 mov x9,#240
 mul x9,x22,x9
 add x10,x21,x21
 add x10,x10,#1
 mov x11,#24
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
 QM_CALL md2asm_gpnorm1_7358525
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
 cmp x22,#86
 b.ge .Lqm_weight_next_field
 mov x24,#24
 cmp x22,#85
 mov x9,#8
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x9,[x19,#72]
 add x0,x9,#1016
 adr x1,.Lqm_p
 adr x2,.Lqm_one
 add x3,sp,#376
 adr x4,.Lqm_l
 adr x5,.Lqm_zero
 adr x6,.Lqm_len
 ldr x7,[x19,#56]
 mov x9,#43776
 madd x7,x22,x9,x7
 mov x9,#14592
 add x7,x7,x9
 mov x9,#10944
 sub x10,x7,x9
 str x10,[sp]
 ldr x10,[x19,#48]
 mov x9,#7296
 madd x10,x22,x9,x10
 add x10,x10,#1824
 str x10,[sp,#8]
 add x10,x7,#3648
 str x10,[sp,#16]
 ldr x10,[x19,#32]
 mov x9,#368
 madd x10,x21,x9,x10
 add x10,x10,#3848
 ldr w10,[x10,#216]
 sub w10,w10,#1
 mov w9,#21
 mul w10,w10,w9
 add w10,w10,#63
 mov x9,#3101
 mul x10,x10,x9
 ldr x11,[x19,#64]
 add x10,x11,x10,lsl #3
 str x10,[sp,#24]
 ldr x10,[sp,#464]
 str x10,[sp,#32]
 QM_CALL md2asm_qm_laitli_child
 ldr x27,[x19,#104]
 mov x9,#21888
 mul x9,x22,x9
 mov x10,#3648
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#488]
 mov x9,#5
 madd x9,x22,x9,x21
 mov x10,#3648
 mul x9,x9,x10
 add x28,x28,x9
 mov x23,#0
.Lqm_weight_cell:
 cmp x23,#456
 b.ge .Lqm_weight_integral
 mov x9,#24
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
 mov x10,#3840
 madd x9,x22,x10,x9
 mov x10,#24
 add x10,x23,x10
 ldr d1,[x9,x23,lsl #3]
 ldr d2,[x9,x10,lsl #3]
 fsub d2,d2,d1
 mov x9,#24
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
 adr x0,.Lqm_p
 adr x1,.Lqm_one
 add x2,sp,#376
 adr x3,.Lqm_l
 ldr x4,[sp,#456]
 ldr x5,[sp,#440]
 ldr x6,[sp,#424]
 mov x9,#3840
 madd x6,x22,x9,x6
 QM_CALL md2asm_qm_gppwc_child
 ldr x27,[sp,#456]
 add x27,x27,#3648
 ldr x28,[sp,#504]
 mov x9,#5
 madd x9,x22,x9,x21
 mov x10,#24
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
 QM_CALL md2asm_gpnorm1_7358525
 mov x21,#0
.Lqm_limit_field:
 cmp x21,#5
 b.ge .Lqm_done
 mov x9,#24
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
 cmp x22,#86
 b.ge .Lqm_limit_next_field
 mov x24,#24
 cmp x22,#85
 mov x9,#8
 csel x24,x9,x24,eq
 str w24,[sp,#376]
 ldr x9,[x19,#72]
 add x0,x9,#1016
 adr x1,.Lqm_p
 adr x2,.Lqm_one
 add x3,sp,#376
 adr x4,.Lqm_l
 adr x5,.Lqm_zero
 adr x6,.Lqm_len
 ldr x7,[x19,#48]
 mov x9,#7296
 madd x7,x22,x9,x7
 ldr x10,[x19,#32]
 mov x9,#368
 madd x10,x21,x9,x10
 add x10,x10,#3848
 ldr w10,[x10,#216]
 sub w10,w10,#1
 mov w9,#21
 mul w10,w10,w9
 add w10,w10,#63
 mov x9,#3101
 mul x10,x10,x9
 ldr x11,[x19,#64]
 add x10,x11,x10,lsl #3
 str x10,[sp]
 ldr x10,[sp,#472]
 str x10,[sp,#8]
 ldr x10,[sp,#480]
 str x10,[sp,#16]
 QM_CALL md2asm_qm_laminmaxint_child
 ldr x27,[x19,#104]
 mov x9,#21888
 mul x9,x22,x9
 mov x10,#3648
 madd x9,x21,x10,x9
 add x27,x27,x9
 ldr x28,[sp,#488]
 mov x9,#5
 madd x9,x22,x9,x21
 mov x10,#3648
 mul x9,x9,x10
 add x28,x28,x9
 mov x23,#0
.Lqm_limit_cell:
 cmp x23,#456
 b.ge .Lqm_limit_next_block
 mov x9,#24
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
 mov x0,x20
 QM_CALL free
 ldr w9,[sp,#352]
 cbz w9,.Lqm_return
 adr x0,.Lqm_name
 add x1,sp,#356
 mov w9,#1
 str w9,[x1]
 add x2,sp,#360
 mov x3,#7
 QM_CALL __yomhook_MOD_dr_hook_default8
.Lqm_return:
 ldp x18,x30,[sp,#96]
 ldp x19,x20,[sp,#112]
 ldp x21,x22,[sp,#128]
 ldp x23,x24,[sp,#144]
 ldp x25,x26,[sp,#160]
 ldp x27,x28,[sp,#176]
 ldr x29,[sp,#192]
 add sp,sp,#1536
 ret
.size md2asm_qmfixer_address_r2_7358525,.-md2asm_qmfixer_address_r2_7358525
.Lqm_bad:
 mov w0,#167
 QM_CALL exit
 brk #0
.section .rodata
.p2align 3
.Lqm_beta_word: .quad 0x3ff0000000000000
.Lqm_eps: .double 1e-8
.Lqm_floor: .double 1e-25
.Lqm_name: .ascii "QMFIXER"
.p2align 2
.Lqm_p: .word 24
.Lqm_l: .word 19
.Lqm_one: .word 1
.Lqm_zero: .word 0
.Lqm_false: .word 0
.Lqm_len: .word 20
.Lqm_ten: .word 10
.Lqm_five: .word 5
.section .note.GNU-stack,"",%progbits

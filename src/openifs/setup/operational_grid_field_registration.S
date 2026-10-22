/* Construct the selected nine-field registration and attribute stages.
 * x0 fresh owned TYPE_GFLD[1359136], x1 profiles[9][256], x2 constants[520],
 * w3 vertical levels 137 only, w4 supplementary levels 0 only, x5 effects[8].
 * effects: LVSPLIP, LSPLTHOIGFL; selected source values are both false.
 * This child composes qualified direct children. It reads no original objects.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_field_registration.md in the repository.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_register_operational_grid_fields
.type md2asm_register_operational_grid_fields,%function
md2asm_register_operational_grid_fields:
 cbz x0,.Lop_reg_registration_reject_leaf
 cbz x1,.Lop_reg_registration_reject_leaf
 cbz x2,.Lop_reg_registration_reject_leaf
 cbz x5,.Lop_reg_registration_reject_leaf
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lop_reg_registration_reject_leaf
 cmp w3,#137
 b.ne .Lop_reg_registration_reject_leaf
 cbnz w4,.Lop_reg_registration_reject_leaf
 mrs x9,fpcr
 cbnz x9,.Lop_reg_registration_reject_leaf
 mov x9,#0xbd20
 movk x9,#0x14,lsl#16
 adds x10,x0,x9
 b.cs .Lop_reg_registration_reject_leaf
 adds x11,x1,#2304
 b.cs .Lop_reg_registration_reject_leaf
 cmp x11,x0
 b.ls .Lop_reg_registration_profiles_separate
 cmp x1,x10
 b.lo .Lop_reg_registration_reject_leaf
.Lop_reg_registration_profiles_separate:
 adds x11,x2,#520
 b.cs .Lop_reg_registration_reject_leaf
 cmp x11,x0
 b.ls .Lop_reg_registration_constants_separate
 cmp x2,x10
 b.lo .Lop_reg_registration_reject_leaf
.Lop_reg_registration_constants_separate:
 adds x11,x5,#8
 b.cs .Lop_reg_registration_reject_leaf
 cmp x11,x0
 b.ls .Lop_reg_registration_effects_separate
 cmp x5,x10
 b.lo .Lop_reg_registration_reject_leaf
.Lop_reg_registration_effects_separate:
 adds x12,x1,#2304
 cmp x11,x1
 b.ls .Lop_reg_registration_effects_profiles_separate
 cmp x5,x12
 b.lo .Lop_reg_registration_reject_leaf
.Lop_reg_registration_effects_profiles_separate:
 adds x12,x2,#520
 cmp x11,x2
 b.ls .Lop_reg_registration_effects_constants_separate
 cmp x5,x12
 b.lo .Lop_reg_registration_reject_leaf
.Lop_reg_registration_effects_constants_separate:
 ldr w9,[x2,#512]
 cmp w9,#1
 b.ne .Lop_reg_registration_reject_leaf
 adr x16,.Lop_reg_registration_constant_offsets
 mov w15,#6
.Lop_reg_registration_finite_constants:
 ldrh w9,[x16],#2
 ldr x9,[x2,x9]
 tbnz x9,#63,.Lop_reg_registration_reject_leaf
 cbz x9,.Lop_reg_registration_reject_leaf
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lop_reg_registration_reject_leaf
 subs w15,w15,#1
 b.ne .Lop_reg_registration_finite_constants
 /* An explicit fresh zero record owns every otherwise unwritten byte. */
 mov x11,x0
 mov x9,#0xbd20
 movk x9,#0x14,lsl#16
 add x12,x0,x9
.Lop_reg_registration_fresh_loop:
 ldr x9,[x11],#8
 cbnz x9,.Lop_reg_registration_reject_leaf
 cmp x11,x12
 b.lo .Lop_reg_registration_fresh_loop
 sub sp,sp,#2688
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x5
 mov w23,w3
 mov w24,w4
 /* Validate all selected profiles against their source defaults before writes. */
 add x0,sp,#112
 mov w9,#288
 mov x10,x0
.Lop_reg_registration_clear_profiles:
 str xzr,[x10],#8
 subs w9,w9,#1
 b.ne .Lop_reg_registration_clear_profiles
 bl md2asm_initialize_selected_grid_field_profiles
 cbnz w0,.Lop_reg_registration_internal
 mov w9,#1
 str w9,[sp,#1692]
 ldr w9,[x20,#788]
 cmp w9,#1
 b.ne .Lop_reg_registration_reject
 str w9,[sp,#900]
 ldr w9,[x20,#1044]
 cmp w9,#1
 b.ne .Lop_reg_registration_reject
 str w9,[sp,#1156]
 add x10,sp,#112
 mov x11,x20
 mov w12,#288
.Lop_reg_registration_compare_profiles:
 ldr x9,[x10],#8
 ldr x13,[x11],#8
 cmp x9,x13
 b.ne .Lop_reg_registration_reject
 subs w12,w12,#1
 b.ne .Lop_reg_registration_compare_profiles
 /* Declared component defaults precede the genuine FALSIFY stage. */
 add x27,x19,#3848
 mov w25,#2163
.Lop_reg_registration_component_defaults:
 mov w9,#64
 cmp w25,w9
 csel w1,w25,w9,lo
 str w1,[sp,#2640]
 mov x0,x27
 bl md2asm_initialize_field_component_defaults
 cbnz w0,.Lop_reg_registration_internal
 ldr w9,[sp,#2640]
 mov w10,#368
 madd x27,x9,x10,x27
 sub w25,w25,w9
 cbnz w25,.Lop_reg_registration_component_defaults
 add x0,x19,#3848
 mov w1,#2163
 mov w2,#0x7961
 movk w2,#0xfffe,lsl#16
 bl md2asm_reset_grid_field_components
 cbnz w0,.Lop_reg_registration_internal
 /* The input profiles are copied as complete records, including padding. */
 adr x26,.Lop_reg_registration_profile_offsets
 mov w25,#0
.Lop_reg_registration_copy_profiles:
 ldr w9,[x26,x25,lsl#2]
 add x10,x19,x9
 add x11,x20,x25,lsl#8
 mov w12,#32
.Lop_reg_registration_copy_profile_words:
 ldr x9,[x11],#8
 str x9,[x10],#8
 subs w12,w12,#1
 b.ne .Lop_reg_registration_copy_profile_words
 add w25,w25,#1
 cmp w25,#9
 b.lo .Lop_reg_registration_copy_profiles
 mov w9,#2
 str w9,[x19,#124]
 mov w9,#1
 str w9,[x19,#160]
 str w9,[x19,#272]
 str w9,[x19,#164]
 str w9,[x19,#312]
 str w9,[x19,#260]
 mov w9,#3
 str w9,[x19,#308]
 /* Source phase-2 threshold is exactly 2*epsilon(1), or 2**-51. */
 mov x9,#0x3cc0
 lsl x9,x9,#48
 str x9,[x19,#2664]
 mov w25,#0
 adr x26,.Lop_reg_registration_species
.Lop_reg_registration_define_loop:
 add x27,x19,#3848
 mov w9,#368
 madd x27,x25,x9,x27
 ldr w9,[x26,#24]
 add x28,x20,x9,lsl#8
 add x10,sp,#2416
 mov w11,#14
.Lop_reg_registration_clear_definition:
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Lop_reg_registration_clear_definition
 ldp x9,x10,[x26]
 str x9,[sp,#2416]
 str x10,[sp,#2424]
 ldp w9,w10,[x26,#16]
 str w9,[sp,#2432]
 str w10,[sp,#2436]
 ldr w9,[x28,#20]
 str w9,[sp,#2440]
 ldr w9,[x28,#32]
 str w9,[sp,#2444]
 ldr w9,[x28,#36]
 cmp w25,#7
 mov w10,#1
 csel w9,w9,w10,lo
 str w9,[sp,#2448]
 ldr w9,[x28,#40]
 str w9,[sp,#2452]
 ldr w9,[x28,#76]
 str w9,[sp,#2456]
 ldp w9,w10,[x26,#32]
 str w9,[sp,#2460]
 str w10,[sp,#2464]
 ldr w9,[x28,#208]
 str w9,[sp,#2468]
 ldr w9,[x28,#140]
 str w9,[sp,#2472]
 ldr w9,[x28,#204]
 str w9,[sp,#2476]
 ldr x9,[x28,#24]
 str x9,[sp,#2480]
 ldr w10,[x26,#40]
 mov x9,xzr
 tbnz w10,#31,.Lop_reg_registration_no_r
 ldr x9,[x21,x10]
.Lop_reg_registration_no_r:
 str x9,[sp,#2488]
 ldr w10,[x26,#44]
 mov x9,xzr
 tbnz w10,#31,.Lop_reg_registration_no_rcp
 ldr x9,[x21,x10]
.Lop_reg_registration_no_rcp:
 str x9,[sp,#2496]
 ldr w10,[x26,#48]
 mov x9,xzr
 tbnz w10,#31,.Lop_reg_registration_no_lzer
 ldr x9,[x21,x10]
.Lop_reg_registration_no_lzer:
 str x9,[sp,#2504]
 ldr x9,[x28,#128]
 str x9,[sp,#2512]
 ldr x9,[x28,#216]
 str x9,[sp,#2520]
 mov x0,x19
 mov x1,x27
 add x2,sp,#2416
 ldr w3,[x26,#28]
 bl md2asm_define_operational_grid_field_component
 cbnz w0,.Lop_reg_registration_internal
 add x26,x26,#56
 add w25,w25,#1
 cmp w25,#9
 b.lo .Lop_reg_registration_define_loop
 mov x0,x19
 bl md2asm_bind_operational_grid_field_aliases
 cbnz w0,.Lop_reg_registration_internal
 /* SUGFL3 visits O3,Q,A,L,I,S,R,then both NOGW fields. */
 mov w25,#0
 adr x26,.Lop_reg_registration_attribute_order
.Lop_reg_registration_attribute_loop:
 ldp w9,w10,[x26]
 mov w11,#368
 madd x27,x9,x11,x19
 add x27,x27,#3848
 add x28,x20,x10,lsl#8
 add x10,sp,#2528
 mov w11,#8
.Lop_reg_registration_clear_attributes:
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Lop_reg_registration_clear_attributes
 ldr w9,[x28,#88]
 str w9,[sp,#2528]
 ldr w9,[x28,#40]
 str w9,[sp,#2532]
 ldr w9,[x28,#92]
 str w9,[sp,#2536]
 ldr w9,[x28,#100]
 str w9,[sp,#2540]
 ldr w9,[x28,#104]
 str w9,[sp,#2544]
 ldr w9,[x28,#68]
 str w9,[sp,#2552]
 ldr w9,[x28,#152]
 str w9,[sp,#2564]
 ldr x9,[x28,#160]
 str x9,[sp,#2568]
 cmp w25,#7
 b.hs .Lop_reg_registration_attribute_no_name
 adr x16,.Lop_reg_registration_interpolation_flags
 add x10,sp,#2592
 mov w11,#10
.Lop_reg_registration_gather_flags:
 ldrh w9,[x16],#2
 ldr w9,[x28,x9]
 str w9,[x10],#4
 subs w11,w11,#1
 b.ne .Lop_reg_registration_gather_flags
 add x0,sp,#2592
 add x1,sp,#2576
 bl md2asm_grid_field_interpolation_name
 cbnz w0,.Lop_reg_registration_internal
.Lop_reg_registration_attribute_no_name:
 mov x0,x19
 mov x1,x27
 add x2,sp,#2528
 mov w3,w23
 mov w4,w24
 cmp w25,#7
 cset w5,hs
 bl md2asm_set_operational_grid_field_attributes
 cbnz w0,.Lop_reg_registration_internal
 add x26,x26,#8
 add w25,w25,#1
 cmp w25,#9
 b.lo .Lop_reg_registration_attribute_loop
 /* Exact selected interpolation names are higher-order and all mgrid flags false.
  * Preserve the source scan order when building the mass-fixer membership list. */
 mov w11,#0
 mov w12,#0
 add x10,x19,#3848
 add x13,x19,#324
.Lop_reg_registration_mass_fixer_loop:
 ldr w9,[x10,#336]
 cbz w9,.Lop_reg_registration_no_mass_fixer
 ldr w9,[x10,#20]
 cbz w9,.Lop_reg_registration_no_mass_fixer
 add w9,w12,#1
 str w9,[x13,x11,lsl#2]
 add w11,w11,#1
.Lop_reg_registration_no_mass_fixer:
 add x10,x10,#368
 add w12,w12,#1
 cmp w12,#9
 b.lo .Lop_reg_registration_mass_fixer_loop
 str w11,[x19,#304]
 str wzr,[x19,#256]
 str wzr,[x19,#268]
 str wzr,[x19,#2672]
 str xzr,[x22]
 mov w0,#0
 b .Lop_reg_registration_restore
.Lop_reg_registration_reject:
 mov w0,#2
 b .Lop_reg_registration_restore
.Lop_reg_registration_internal:
 mov w0,#3
.Lop_reg_registration_restore:
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#2688
 ret
.Lop_reg_registration_reject_leaf:
 mov w0,#2
 ret
.size md2asm_register_operational_grid_fields,.-md2asm_register_operational_grid_fields
.p2align 3
.Lop_reg_registration_constant_offsets:
 .hword 192,208,344,352,392,400
.Lop_reg_registration_profile_offsets:
 .word 801344,801856,801600,803648,803904,805952,806208,880192,880448
.Lop_reg_registration_interpolation_flags:
 .hword 136,140,148,144,108,112,116,120,96,124
.p2align 3
.Lop_reg_registration_attribute_order:
 .word 6,6,0,0,5,5,1,1,2,2,3,3,4,4,7,7,8,8
.p2align 3
.Lop_reg_registration_species:
 /* name16,code,field-id,profile,family,thermal,precipitation,R,RCP,LZER,pad */
 .ascii " HUMIDITY       "
 .word 133,47,0,0,1,0,192,208,-1,0
 .ascii " LIQUID WATER   "
 .word 246,49,1,0,1,0,-1,344,392,0
 .ascii " ICE WATER      "
 .word 247,50,2,0,1,0,-1,352,400,0
 .ascii "SNOW            "
 .word 76,56,3,0,1,1,-1,352,400,0
 .ascii "RAIN            "
 .word 75,57,4,0,1,1,-1,344,392,0
 .ascii " CLOUD FRACTION "
 .word 248,51,5,1,0,0,-1,-1,-1,0
 .ascii " OZONE          "
 .word 203,48,6,1,0,0,-1,-1,-1,0
 .ascii "TENUNOGW        "
 .word 228134,-1,7,2,0,0,-1,-1,-1,0
 .ascii "TENVNOGW        "
 .word 228136,-1,8,2,0,0,-1,-1,-1,0
.section .note.GNU-stack,"",%progbits

/* Define the next field in the selected nine-field grid-point sequence.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_field_registration.md in the repository.
 * x0 TYPE_GFLD[1359136],x1 next embedded component[368],x2 plan[112],w3 family.
 * Return w0=0 on success or 2 before mutation. Only integer registers x0..x17.
 * Original source: gfl_subs_mod.F90 DEFINE_GFL_COMP, selected SUGFL2 calls.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_define_operational_grid_field_component
.type md2asm_define_operational_grid_field_component,%function
md2asm_define_operational_grid_field_component:
 cbz x0,.Lop_def_define_reject
 cbz x1,.Lop_def_define_reject
 cbz x2,.Lop_def_define_reject
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lop_def_define_reject
 cmp w3,#2
 b.hi .Lop_def_define_reject
 mrs x9,fpcr
 cbnz x9,.Lop_def_define_reject
 adr x9,.Lop_def_configuration_bytes
 ldr x9,[x9]
 adds x10,x0,x9
 b.cs .Lop_def_define_reject
 adds x11,x2,#112
 b.cs .Lop_def_define_reject
 cmp x11,x0
 b.ls .Lop_def_define_plan_separate
 cmp x2,x10
 b.lo .Lop_def_define_reject
.Lop_def_define_plan_separate:
 ldr w4,[x0]
 cmp w4,#8
 b.hi .Lop_def_define_reject
 cmp w4,#5
 b.lo .Lop_def_define_water_family
 cmp w4,#7
 b.lo .Lop_def_define_cloud_family
 cmp w3,#2
 b.ne .Lop_def_define_reject
 b .Lop_def_define_family_valid
.Lop_def_define_water_family:
 cbnz w3,.Lop_def_define_reject
 b .Lop_def_define_family_valid
.Lop_def_define_cloud_family:
 cmp w3,#1
 b.ne .Lop_def_define_reject
.Lop_def_define_family_valid:
 mov w9,#368
 umull x10,w4,w9
 add x10,x10,#3848
 add x10,x0,x10
 cmp x1,x10
 b.ne .Lop_def_define_reject
 cmp w4,#7
 mov w9,#7
 csel w5,w4,w9,lo
 ldr w9,[x0,#12]
 cmp w9,w4
 b.ne .Lop_def_define_reject
 ldr w9,[x0,#48]
 cmp w9,w4
 b.ne .Lop_def_define_reject
 ldr w9,[x0,#56]
 cmp w9,w4
 b.ne .Lop_def_define_reject
 ldr w9,[x0,#20]
 cmp w9,w5
 b.ne .Lop_def_define_reject
 ldr w9,[x0,#64]
 cmp w9,w5
 b.ne .Lop_def_define_reject
 adr x8,.Lop_def_zero_counter_offsets
 mov w6,#16
.Lop_def_define_zero_counter_loop:
 ldrb w9,[x8],#1
 ldr w10,[x0,x9]
 cbnz w10,.Lop_def_define_reject
 subs w6,w6,#1
 b.ne .Lop_def_define_zero_counter_loop
 /* Check the source's selected backward chain before any store. */
 adr x16,.Lop_def_head_offset
 ldr x16,[x16]
 add x16,x0,x16
 ldr x7,[x16]
 mov x11,xzr
 add x8,x0,#3848
 mov w6,#0
.Lop_def_define_chain_loop:
 cmp w6,w4
 b.eq .Lop_def_define_chain_done
 ldr w9,[x8,#52]
 cmp w9,#1
 b.ne .Lop_def_define_reject
 ldr w9,[x8,#60]
 cbnz w9,.Lop_def_define_reject
 ldr w9,[x8,#96]
 cbnz w9,.Lop_def_define_reject
 add w9,w6,#1
 ldr w10,[x8,#168]
 cmp w9,w10
 b.ne .Lop_def_define_reject
 ldr x10,[x8,#360]
 cmp x10,x11
 b.ne .Lop_def_define_reject
 mov x11,x8
 add x8,x8,#368
 add w6,w6,#1
 b .Lop_def_define_chain_loop
.Lop_def_define_chain_done:
 cmp x7,x11
 b.ne .Lop_def_define_reject
 /* All consumed logical values must use the source's canonical 0/1 form. */
 ldr w9,[x2,#28]
 cmp w9,#1
 b.hi .Lop_def_define_reject
 ldr w9,[x2,#24]
 add w9,w9,#1
 cmp w9,#2
 b.hi .Lop_def_define_reject
 ldr w9,[x1,#112]
 cbnz w9,.Lop_def_define_reject
 cmp w3,#2
 b.eq .Lop_def_define_nogw_inputs
 mov x8,x2
 add x8,x8,#32
 mov w6,#3
.Lop_def_define_common_flags:
 ldr w9,[x8],#4
 cmp w9,#1
 b.hi .Lop_def_define_reject
 subs w6,w6,#1
 b.ne .Lop_def_define_common_flags
 add x8,x2,#52
 mov w6,#3
.Lop_def_define_interpolation_flags:
 ldr w9,[x8],#4
 cmp w9,#1
 b.hi .Lop_def_define_reject
 subs w6,w6,#1
 b.ne .Lop_def_define_interpolation_flags
 cbnz w3,.Lop_def_define_nonwater_inputs
 ldr w9,[x2,#44]
 cmp w9,#1
 b.hi .Lop_def_define_reject
 ldr w9,[x2,#48]
 cmp w9,#1
 b.hi .Lop_def_define_reject
 b .Lop_def_define_store
.Lop_def_define_nogw_inputs:
 ldr w9,[x2,#24]
 cbnz w9,.Lop_def_define_reject
.Lop_def_define_nonwater_inputs:
 ldr w9,[x1,#68]
 cbnz w9,.Lop_def_define_reject
 ldr w9,[x1,#232]
 cbnz w9,.Lop_def_define_reject
.Lop_def_define_store:
 mov w9,#1
 str w9,[x1,#64]
 ldp x10,x11,[x2]
 stp x10,x11,[x1]
 ldr w10,[x2,#16]
 str w10,[x1,#16]
 ldr w10,[x2,#24]
 str w10,[x1,#36]
 ldr x10,[x2,#64]
 str x10,[x1,#120]
 cmp w3,#2
 b.eq .Lop_def_define_no_identifier
 ldr w10,[x2,#20]
 str w10,[x1,#352]
.Lop_def_define_no_identifier:
 ldr w10,[x2,#28]
 str w10,[x1,#40]
 str w9,[x1,#52]
 str wzr,[x1,#56]
 str wzr,[x1,#96]
 cmp w3,#2
 cset w10,ne
 str w10,[x1,#92]
 str wzr,[x1,#60]
 cmp w3,#2
 b.eq .Lop_def_define_nogw_common
 ldr w10,[x2,#32]
 str w10,[x1,#44]
 ldr w10,[x2,#36]
 str w10,[x1,#48]
 ldr w10,[x2,#40]
 str w10,[x1,#108]
 b .Lop_def_define_common_stored
.Lop_def_define_nogw_common:
 str w9,[x1,#44]
 str wzr,[x1,#48]
 str wzr,[x1,#108]
.Lop_def_define_common_stored:
 cbnz w3,.Lop_def_define_thermodynamic_done
 ldr w10,[x2,#44]
 str w10,[x1,#68]
 cbz w10,.Lop_def_define_thermodynamic_done
 ldp x10,x11,[x2,#72]
 stp x10,x11,[x1,#72]
.Lop_def_define_thermodynamic_done:
 mov w10,#-1
 str w10,[x1,#248]
 str wzr,[x1,#252]
 str w9,[x1,#276]
 str w9,[x1,#280]
 mov w10,#-9999
 str w10,[x1,#260]
 str w10,[x1,#264]
 str w10,[x1,#268]
 str w10,[x1,#272]
 str w10,[x1,#256]
 adr x8,.Lop_def_extension_real_default
 ldr x10,[x8]
 stp x10,x10,[x1,#288]
 stp x10,x10,[x1,#304]
 str wzr,[x1,#324]
 str wzr,[x1,#336]
 str xzr,[x1,#328]
 str wzr,[x1,#320]
 mov x10,#0x3ff0000000000000
 str x10,[x1,#344]
 cmp w3,#2
 b.eq .Lop_def_define_extensions_done
 ldr x10,[x2,#104]
 str x10,[x1,#344]
 ldr w10,[x2,#52]
 str w10,[x1,#336]
 ldr x10,[x2,#96]
 str x10,[x1,#328]
 ldr w10,[x2,#56]
 str w10,[x1,#324]
 ldr w10,[x2,#60]
 str w10,[x1,#320]
.Lop_def_define_extensions_done:
 cbnz w3,.Lop_def_define_water_done
 str w9,[x1,#232]
 ldr w10,[x2,#48]
 str w10,[x1,#236]
 ldr x10,[x2,#88]
 str x10,[x1,#240]
 ldr x10,[x2,#80]
 str x10,[x1,#80]
.Lop_def_define_water_done:
 add w4,w4,#1
 str w4,[x0]
 str w4,[x0,#48]
 str w4,[x0,#56]
 str w4,[x0,#12]
 cmp w3,#2
 b.eq .Lop_def_define_time_count_done
 add w5,w5,#1
 str w5,[x0,#20]
 str w5,[x0,#64]
.Lop_def_define_time_count_done:
 adr x8,.Lop_def_undefined
 ldr w10,[x8]
 str w10,[x1,#192]
 str w4,[x1,#168]
 str w10,[x1,#172]
 str w10,[x1,#176]
 str w10,[x1,#196]
 str w10,[x1,#200]
 str w10,[x1,#208]
 cmp w3,#2
 csel w11,w5,w10,ne
 str w11,[x1,#188]
 /* The validated existing chain has no derivative/trajectory reassignment. */
 str x7,[x1,#360]
 str x1,[x16]
 mov w0,#0
 ret
.Lop_def_define_reject:
 mov w0,#2
 ret
.size md2asm_define_operational_grid_field_component,.-md2asm_define_operational_grid_field_component
.section .rodata
.p2align 3
.Lop_def_configuration_bytes: .xword 1359136
.Lop_def_head_offset: .xword 799832
.Lop_def_extension_real_default: .double -99999.9
.Lop_def_undefined: .word -99999
.Lop_def_zero_counter_offsets: .byte 4,8,16,24,28,32,36,40,44,52,60,68,72,76,80,84
.section .note.GNU-stack,"",%progbits

/* Bind all selected SUGFL2 component aliases to the owned embedded array.
 * x0 is an aligned owned TYPE_GFLD record of 1359136 bytes.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_field_registration.md. Return 0 or 2 before mutation.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_bind_operational_grid_field_aliases
.type md2asm_bind_operational_grid_field_aliases,%function
md2asm_bind_operational_grid_field_aliases:
 cbz x0,.Lop_alias_aliases_reject
 tst x0,#7
 b.ne .Lop_alias_aliases_reject
 mrs x9,fpcr
 cbnz x9,.Lop_alias_aliases_reject
 adr x9,.Lop_alias_aliases_record_bytes
 ldr x9,[x9]
 adds x9,x0,x9
 b.cs .Lop_alias_aliases_reject
 ldr w9,[x0]
 cmp w9,#9
 b.ne .Lop_alias_aliases_reject
 ldr w9,[x0,#12]
 cmp w9,#9
 b.ne .Lop_alias_aliases_reject
 ldr w9,[x0,#124]
 cmp w9,#2
 b.ne .Lop_alias_aliases_reject
 adr x2,.Lop_alias_aliases_zero_controls
 mov w13,#15
.Lop_alias_aliases_zero_control_loop:
 ldrb w9,[x2],#1
 ldr w9,[x0,x9]
 cbnz w9,.Lop_alias_aliases_reject
 subs w13,w13,#1
 b.ne .Lop_alias_aliases_zero_control_loop
 adr x2,.Lop_alias_aliases_table
 mov w13,#61
 adr x10,.Lop_alias_aliases_undefined
 ldr w10,[x10]
 /* Check every borrowed target before changing any association. */
.Lop_alias_aliases_validate_row:
 ldp w3,w4,[x2]
 ldr w5,[x2,#8]
 sub w9,w4,#1
 mov w8,#368
 umull x7,w9,w8
 add x7,x7,#3848
 add x7,x0,x7
.Lop_alias_aliases_validate_target:
 cmp w4,#9
 cset w9,ls
 ldr w8,[x7,#64]
 cmp w8,w9
 b.ne .Lop_alias_aliases_reject
 cmp w4,#9
 csel w9,w4,w10,ls
 ldr w8,[x7,#168]
 cmp w8,w9
 b.ne .Lop_alias_aliases_reject
 add x7,x7,#368
 add w4,w4,#1
 subs w5,w5,#1
 b.ne .Lop_alias_aliases_validate_target
 add x2,x2,#16
 subs w13,w13,#1
 b.ne .Lop_alias_aliases_validate_row
 adr x2,.Lop_alias_aliases_table
 mov w13,#61
 mov x11,#-1
 mov x12,#368
 adr x9,.Lop_alias_aliases_dtype
 ldr x14,[x9]
 mov x15,#1
.Lop_alias_aliases_store_row:
 ldp w3,w4,[x2]
 ldp w5,w6,[x2,#8]
 sub w9,w4,#1
 umull x7,w9,w12
 add x7,x7,#3848
 add x7,x0,x7
 add x16,x0,x3
 cbnz w6,.Lop_alias_aliases_store_descriptor
 str x7,[x16]
 b .Lop_alias_aliases_store_next
.Lop_alias_aliases_store_descriptor:
 stp x7,x11,[x16]
 stp x12,x14,[x16,#16]
 stp x12,x15,[x16,#32]
 stp x15,x5,[x16,#48]
.Lop_alias_aliases_store_next:
 add x2,x2,#16
 subs w13,w13,#1
 b.ne .Lop_alias_aliases_store_row
 mov w0,#0
 ret
.Lop_alias_aliases_reject:
 mov w0,#2
 ret
.size md2asm_bind_operational_grid_field_aliases,.-md2asm_bind_operational_grid_field_aliases
.section .rodata
.p2align 3
.Lop_alias_aliases_record_bytes: .xword 1359136
.Lop_alias_aliases_dtype: .xword 0x0000050100000000
.Lop_alias_aliases_undefined: .word -99999
.p2align 4
.Lop_alias_aliases_zero_controls: .byte 88,92,96,100,200,108,120,240,128,132,136,140,144,244,176
.p2align 4
.Lop_alias_aliases_table:
 .word 799840,1,1,0 // YQ
 .word 799856,2,1,0 // YL
 .word 799848,3,1,0 // YI
 .word 799912,4,1,0 // YS
 .word 799920,5,1,0 // YR
 .word 799928,2158,1,0 // YG
 .word 799936,2157,1,0 // YH
 .word 799944,2156,1,0 // YTKE
 .word 799960,2155,1,0 // YEFB1
 .word 799968,2154,1,0 // YEFB2
 .word 799976,2153,1,0 // YEFB3
 .word 799984,6,1,0 // YA
 .word 799992,7,1,0 // YO3
 .word 800040,2150,1,0 // YCPF
 .word 800048,2149,1,0 // YSPF
 .word 800000,2148,1,0 // YSRC
 .word 800056,2147,1,0 // YCVGQ
 .word 799864,2146,1,0 // YLCONV
 .word 799872,2145,1,0 // YICONV
 .word 799880,2144,1,0 // YRCONV
 .word 799888,2143,1,0 // YSCONV
 .word 799904,2142,1,0 // YLRAD
 .word 799896,2141,1,0 // YIRAD
 .word 801120,2140,1,0 // YSDSAT
 .word 801128,2139,1,0 // YCVV
 .word 800064,2138,1,0 // YQVA
 .word 801160,2137,1,0 // YUOM
 .word 801168,2136,1,0 // YUAL
 .word 801176,2135,1,0 // YDOM
 .word 801184,2134,1,0 // YDAL
 .word 801192,2133,1,0 // YUEN
 .word 801200,2132,1,0 // YUNEBH
 .word 799952,2131,1,0 // YTTE
 .word 800008,2130,1,0 // YMXL
 .word 800016,2129,1,0 // YSHTUR
 .word 800024,2128,1,0 // YFQTUR
 .word 800032,2127,1,0 // YFSTUR
 .word 801136,2126,1,0 // YRKTH
 .word 801112,2125,1,0 // YRSPEC
 .word 801144,2124,1,0 // YRKTQV
 .word 801152,2123,1,0 // YRKTQC
 .word 800264,2122,1,0 // YLRCH4
 .word 801104,2121,1,0 // YPHYCTY
 .word 801272,2120,1,0 // YFSD
 .word 801280,2119,1,1 // YEXT
 .word 800336,2118,1,1 // YFORC
 .word 800400,2117,1,1 // YEZDIAG
 .word 800072,2116,1,1 // YGHG
 .word 800136,2115,1,1 // YCHEM
 .word 800200,2114,1,1 // YAERO
 .word 800464,2113,1,1 // YERA40
 .word 800528,8,2,1 // YNOGW
 .word 800272,2112,1,1 // YEMIS3D
 .word 800592,2111,1,1 // YEDRP
 .word 800720,2110,1,1 // YAERAOT
 .word 800784,2109,1,1 // YAERLISI
 .word 800848,2108,1,1 // YAEROUT
 .word 800912,2107,1,1 // YAEROCLIM
 .word 800976,2106,1,1 // YUVP
 .word 800656,2105,1,1 // YSLDIA
 .word 801208,2104,1,1 // YLIMA
 .section .note.GNU-stack,"",%progbits

/* Apply selected SET_GFL_ATTR calls to an owned nine-field configuration.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_field_registration.md in the repository.
 * x0 cfg[1359136],x1 embedded component[368],x2 plan[64],w3 levels,
 * w4 supplementary levels,w5 family 0 named moist/cloud or 1 NOGW.
 * Return 0 on success or 2 before mutation. No service or original-data input.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_set_operational_grid_field_attributes
.type md2asm_set_operational_grid_field_attributes,%function
md2asm_set_operational_grid_field_attributes:
 cbz x0,.Lop_attr_attr_reject
 cbz x1,.Lop_attr_attr_reject
 cbz x2,.Lop_attr_attr_reject
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lop_attr_attr_reject
 cmp w5,#1
 b.hi .Lop_attr_attr_reject
 cmp w3,#137
 b.ne .Lop_attr_attr_reject
 cbnz w4,.Lop_attr_attr_reject
 mrs x9,fpcr
 cbnz x9,.Lop_attr_attr_reject
 adr x9,.Lop_attr_attr_configuration_bytes
 ldr x9,[x9]
 adds x6,x0,x9
 b.cs .Lop_attr_attr_reject
 adds x7,x2,#64
 b.cs .Lop_attr_attr_reject
 cmp x7,x0
 b.ls .Lop_attr_attr_plan_separate
 cmp x2,x6
 b.lo .Lop_attr_attr_reject
.Lop_attr_attr_plan_separate:
 ldr w9,[x0]
 cmp w9,#9
 b.ne .Lop_attr_attr_reject
 ldr w9,[x0,#12]
 cmp w9,#9
 b.ne .Lop_attr_attr_reject
 ldr w9,[x0,#48]
 cmp w9,#9
 b.ne .Lop_attr_attr_reject
 ldr w9,[x0,#56]
 cmp w9,#9
 b.ne .Lop_attr_attr_reject
 ldr w9,[x0,#20]
 cmp w9,#7
 b.ne .Lop_attr_attr_reject
 ldr w9,[x0,#64]
 cmp w9,#7
 b.ne .Lop_attr_attr_reject
 adr x16,.Lop_attr_attr_zero_counters
 mov w10,#11
.Lop_attr_attr_zero_counters_loop:
 ldrb w9,[x16],#1
 ldr w9,[x0,x9]
 cbnz w9,.Lop_attr_attr_reject
 subs w10,w10,#1
 b.ne .Lop_attr_attr_zero_counters_loop
 ldr w8,[x1,#168]
 sub w9,w8,#1
 cmp w9,#8
 b.hi .Lop_attr_attr_reject
 mov w10,#368
 umull x9,w9,w10
 add x9,x9,#3848
 add x9,x0,x9
 cmp x1,x9
 b.ne .Lop_attr_attr_reject
 cmp w8,#7
 b.hi .Lop_attr_attr_nogw_target
 cbnz w5,.Lop_attr_attr_reject
 b .Lop_attr_attr_target_valid
.Lop_attr_attr_nogw_target:
 cmp w5,#1
 b.ne .Lop_attr_attr_reject
.Lop_attr_attr_target_valid:
 ldr w9,[x1,#52]
 cmp w9,#1
 b.ne .Lop_attr_attr_reject
 ldr w9,[x1,#60]
 cbnz w9,.Lop_attr_attr_reject
 ldr w9,[x1,#96]
 cbnz w9,.Lop_attr_attr_reject
 /* All source-consumed logicals are0 or 1, with no extra time/tendency owners. */
 ldr w9,[x2,#20]
 cbnz w9,.Lop_attr_attr_reject
 ldr w9,[x2,#28]
 cbnz w9,.Lop_attr_attr_reject
 ldr w9,[x2,#32]
 cbnz w9,.Lop_attr_attr_reject
 ldr w9,[x2,#24]
 cmp w9,#1
 b.hi .Lop_attr_attr_reject
 cbnz w5,.Lop_attr_attr_nogw_flags
 mov x16,x2
 mov w10,#5
.Lop_attr_attr_named_flags_loop:
 ldr w9,[x16],#4
 cmp w9,#1
 b.hi .Lop_attr_attr_reject
 subs w10,w10,#1
 b.ne .Lop_attr_attr_named_flags_loop
 b .Lop_attr_attr_flags_valid
.Lop_attr_attr_nogw_flags:
 ldp w9,w10,[x2]
 orr w9,w9,w10
 cbnz w9,.Lop_attr_attr_reject
.Lop_attr_attr_flags_valid:
 ldr w11,[x0,#40]
 cmp w11,#7
 b.hi .Lop_attr_attr_reject
 ldr w9,[x2]
 cbz w9,.Lop_attr_attr_advection_valid
 ldr w9,[x1,#92]
 cmp w9,#1
 b.ne .Lop_attr_attr_reject
 add w11,w11,#1
 cmp w11,#7
 b.hi .Lop_attr_attr_reject
.Lop_attr_attr_advection_valid:
 ldr w12,[x0,#32]
 cmp w12,#7
 b.hi .Lop_attr_attr_reject
 ldr w9,[x0,#72]
 cmp w9,w12
 b.ne .Lop_attr_attr_reject
 mov w14,#0
 ldr w9,[x1,#204]
 cmn w9,#99
 b.ne .Lop_attr_attr_physics_valid
 ldr w9,[x2,#24]
 cbz w9,.Lop_attr_attr_physics_valid
 ldr w9,[x1,#92]
 cmp w9,#1
 b.ne .Lop_attr_attr_reject
 add w12,w12,#1
 cmp w12,#7
 b.hi .Lop_attr_attr_reject
 mov w14,#1
.Lop_attr_attr_physics_valid:
 ldr w13,[x0,#36]
 cmp w13,#7
 b.hi .Lop_attr_attr_reject
 ldr w9,[x0,#76]
 cmp w9,w13
 b.ne .Lop_attr_attr_reject
 mov w15,#0
 cbnz w5,.Lop_attr_attr_spline_valid
 adr x16,.Lop_attr_attr_undefined
 ldr w10,[x16]
 ldr w9,[x1,#212]
 cmp w9,w10
 b.ne .Lop_attr_attr_spline_valid
 adr x16,.Lop_attr_attr_spline_name
 ldr x9,[x16]
 ldr x10,[x2,#48]
 cmp x9,x10
 b.ne .Lop_attr_attr_spline_valid
 ldr w9,[x16,#8]
 ldr w10,[x2,#56]
 cmp w9,w10
 b.ne .Lop_attr_attr_spline_valid
 add w13,w13,#1
 cmp w13,#7
 b.hi .Lop_attr_attr_reject
 mov w15,#1
.Lop_attr_attr_spline_valid:
 /* Write only after every selected-domain check has completed. */
 ldr w9,[x2]
 str w9,[x1,#20]
 cbz w9,.Lop_attr_attr_advection_done
 str w11,[x0,#40]
 str w11,[x1,#216]
 sub w9,w11,#1
 add w10,w3,w4,lsl#1
 mul w9,w9,w10
 str w9,[x1,#220]
.Lop_attr_attr_advection_done:
 ldr w9,[x2,#4]
 str w9,[x1,#48]
 cbnz w5,.Lop_attr_attr_nogw_optional
 ldr w9,[x2,#8]
 str w9,[x1,#24]
 ldr w9,[x2,#12]
 str w9,[x1,#28]
 ldr w9,[x2,#16]
 str w9,[x1,#32]
 b .Lop_attr_attr_optional_done
.Lop_attr_attr_nogw_optional:
 str wzr,[x1,#28]
 str wzr,[x1,#32]
.Lop_attr_attr_optional_done:
 str wzr,[x1,#88]
 str w8,[x1,#180]
 str w8,[x1,#184]
 ldr w9,[x2,#24]
 str w9,[x1,#100]
 ldr w10,[x1,#204]
 cmn w10,#99
 b.ne .Lop_attr_attr_physics_done
 cbz w14,.Lop_attr_attr_no_physics_owner
 str w12,[x0,#32]
 str w12,[x0,#72]
 str w12,[x1,#204]
 b .Lop_attr_attr_physics_done
.Lop_attr_attr_no_physics_owner:
 adr x16,.Lop_attr_attr_undefined
 ldr w9,[x16]
 str w9,[x1,#204]
.Lop_attr_attr_physics_done:
 str wzr,[x1,#104]
 str wzr,[x1,#116]
 ldr w9,[x2,#36]
 str w9,[x1,#136]
 ldr x9,[x2,#40]
 str x9,[x1,#144]
 cbnz w5,.Lop_attr_attr_spline_done
 ldr x9,[x2,#48]
 str x9,[x1,#156]
 ldr w9,[x2,#56]
 str w9,[x1,#164]
 cbz w15,.Lop_attr_attr_spline_done
 str w13,[x0,#36]
 str w13,[x0,#76]
 str w13,[x1,#212]
.Lop_attr_attr_spline_done:
 mov w0,#0
 ret
.Lop_attr_attr_reject:
 mov w0,#2
 ret
.size md2asm_set_operational_grid_field_attributes,.-md2asm_set_operational_grid_field_attributes
.section .rodata
.p2align 3
.Lop_attr_attr_configuration_bytes: .xword 1359136
.Lop_attr_attr_undefined: .word -99999
.Lop_attr_attr_spline_name: .ascii "LAITVSPCQM  "
.Lop_attr_attr_zero_counters: .byte 4,8,16,24,28,44,52,60,68,80,84
.section .note.GNU-stack,"",%progbits

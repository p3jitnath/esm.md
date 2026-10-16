/* Construct the selected eight-field registration and attribute stages.
 * x0 fresh owned TYPE_GFLD[1359136], x1 profiles[9][256], x2 constants[520],
 * w3 vertical levels 1..64, w4 supplementary levels 0..64, x5 effects[8].
 * effects: LVSPLIP, LSPLTHOIGFL; selected source values are both false.
 * This child composes qualified direct children. It reads no original objects.
 * Contract: skills/md2asm/references/openifs/setup/selected_grid_field_registration.md in the repository.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_register_selected_grid_fields
.type md2asm_register_selected_grid_fields,%function
md2asm_register_selected_grid_fields:
 cbz x0,.Lregistration_reject_leaf
 cbz x1,.Lregistration_reject_leaf
 cbz x2,.Lregistration_reject_leaf
 cbz x5,.Lregistration_reject_leaf
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lregistration_reject_leaf
 sub w9,w3,#1
 cmp w9,#63
 b.hi .Lregistration_reject_leaf
 cmp w4,#64
 b.hi .Lregistration_reject_leaf
 mrs x9,fpcr
 cbnz x9,.Lregistration_reject_leaf
 mov x9,#0xbd20
 movk x9,#0x14,lsl#16
 adds x10,x0,x9
 b.cs .Lregistration_reject_leaf
 adds x11,x1,#2304
 b.cs .Lregistration_reject_leaf
 cmp x11,x0
 b.ls .Lregistration_profiles_separate
 cmp x1,x10
 b.lo .Lregistration_reject_leaf
.Lregistration_profiles_separate:
 adds x11,x2,#520
 b.cs .Lregistration_reject_leaf
 cmp x11,x0
 b.ls .Lregistration_constants_separate
 cmp x2,x10
 b.lo .Lregistration_reject_leaf
.Lregistration_constants_separate:
 adds x11,x5,#8
 b.cs .Lregistration_reject_leaf
 cmp x11,x0
 b.ls .Lregistration_effects_separate
 cmp x5,x10
 b.lo .Lregistration_reject_leaf
.Lregistration_effects_separate:
 adds x12,x1,#2304
 cmp x11,x1
 b.ls .Lregistration_effects_profiles_separate
 cmp x5,x12
 b.lo .Lregistration_reject_leaf
.Lregistration_effects_profiles_separate:
 adds x12,x2,#520
 cmp x11,x2
 b.ls .Lregistration_effects_constants_separate
 cmp x5,x12
 b.lo .Lregistration_reject_leaf
.Lregistration_effects_constants_separate:
 ldr w9,[x2,#512]
 cmp w9,#1
 b.ne .Lregistration_reject_leaf
 adr x16,.Lregistration_constant_offsets
 mov w15,#6
.Lregistration_finite_constants:
 ldrh w9,[x16],#2
 ldr x9,[x2,x9]
 tbnz x9,#63,.Lregistration_reject_leaf
 cbz x9,.Lregistration_reject_leaf
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lregistration_reject_leaf
 subs w15,w15,#1
 b.ne .Lregistration_finite_constants
 /* An explicit fresh zero record owns every otherwise unwritten byte. */
 mov x11,x0
 mov x9,#0xbd20
 movk x9,#0x14,lsl#16
 add x12,x0,x9
.Lregistration_fresh_loop:
 ldr x9,[x11],#8
 cbnz x9,.Lregistration_reject_leaf
 cmp x11,x12
 b.lo .Lregistration_fresh_loop
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
.Lregistration_clear_profiles:
 str xzr,[x10],#8
 subs w9,w9,#1
 b.ne .Lregistration_clear_profiles
 bl md2asm_initialize_selected_grid_field_profiles
 cbnz w0,.Lregistration_internal
 ldr w9,[x20,#788]
 add w10,w9,#1
 cmp w10,#2
 b.hi .Lregistration_reject
 str w9,[sp,#900]
 ldr w9,[x20,#1044]
 add w10,w9,#1
 cmp w10,#2
 b.hi .Lregistration_reject
 str w9,[sp,#1156]
 add x10,sp,#112
 mov x11,x20
 mov w12,#288
.Lregistration_compare_profiles:
 ldr x9,[x10],#8
 ldr x13,[x11],#8
 cmp x9,x13
 b.ne .Lregistration_reject
 subs w12,w12,#1
 b.ne .Lregistration_compare_profiles
 /* Declared component defaults precede the genuine FALSIFY stage. */
 add x27,x19,#3848
 mov w25,#2163
.Lregistration_component_defaults:
 mov w9,#64
 cmp w25,w9
 csel w1,w25,w9,lo
 str w1,[sp,#2640]
 mov x0,x27
 bl md2asm_initialize_field_component_defaults
 cbnz w0,.Lregistration_internal
 ldr w9,[sp,#2640]
 mov w10,#368
 madd x27,x9,x10,x27
 sub w25,w25,w9
 cbnz w25,.Lregistration_component_defaults
 add x0,x19,#3848
 mov w1,#2163
 mov w2,#0x7961
 movk w2,#0xfffe,lsl#16
 bl md2asm_reset_grid_field_components
 cbnz w0,.Lregistration_internal
 /* The input profiles are copied as complete records, including padding. */
 adr x26,.Lregistration_profile_offsets
 mov w25,#0
.Lregistration_copy_profiles:
 ldr w9,[x26,x25,lsl#2]
 add x10,x19,x9
 add x11,x20,x25,lsl#8
 mov w12,#32
.Lregistration_copy_profile_words:
 ldr x9,[x11],#8
 str x9,[x10],#8
 subs w12,w12,#1
 b.ne .Lregistration_copy_profile_words
 add w25,w25,#1
 cmp w25,#9
 b.lo .Lregistration_copy_profiles
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
 adr x26,.Lregistration_species
.Lregistration_define_loop:
 add x27,x19,#3848
 mov w9,#368
 madd x27,x25,x9,x27
 ldr w9,[x26,#24]
 add x28,x20,x9,lsl#8
 add x10,sp,#2416
 mov w11,#14
.Lregistration_clear_definition:
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Lregistration_clear_definition
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
 cmp w25,#6
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
 tbnz w10,#31,.Lregistration_no_r
 ldr x9,[x21,x10]
.Lregistration_no_r:
 str x9,[sp,#2488]
 ldr w10,[x26,#44]
 mov x9,xzr
 tbnz w10,#31,.Lregistration_no_rcp
 ldr x9,[x21,x10]
.Lregistration_no_rcp:
 str x9,[sp,#2496]
 ldr w10,[x26,#48]
 mov x9,xzr
 tbnz w10,#31,.Lregistration_no_lzer
 ldr x9,[x21,x10]
.Lregistration_no_lzer:
 str x9,[sp,#2504]
 ldr x9,[x28,#128]
 str x9,[sp,#2512]
 ldr x9,[x28,#216]
 str x9,[sp,#2520]
 mov x0,x19
 mov x1,x27
 add x2,sp,#2416
 ldr w3,[x26,#28]
 bl md2asm_define_grid_field_component
 cbnz w0,.Lregistration_internal
 add x26,x26,#56
 add w25,w25,#1
 cmp w25,#8
 b.lo .Lregistration_define_loop
 mov x0,x19
 bl md2asm_bind_selected_grid_field_aliases
 cbnz w0,.Lregistration_internal
 /* SUGFL3 deliberately visits Q,A,L,I,S,R,then both NOGW fields. */
 mov w25,#0
 adr x26,.Lregistration_attribute_order
.Lregistration_attribute_loop:
 ldp w9,w10,[x26]
 mov w11,#368
 madd x27,x9,x11,x19
 add x27,x27,#3848
 add x28,x20,x10,lsl#8
 add x10,sp,#2528
 mov w11,#8
.Lregistration_clear_attributes:
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Lregistration_clear_attributes
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
 cmp w25,#6
 b.hs .Lregistration_attribute_no_name
 adr x16,.Lregistration_interpolation_flags
 add x10,sp,#2592
 mov w11,#10
.Lregistration_gather_flags:
 ldrh w9,[x16],#2
 ldr w9,[x28,x9]
 str w9,[x10],#4
 subs w11,w11,#1
 b.ne .Lregistration_gather_flags
 add x0,sp,#2592
 add x1,sp,#2576
 bl md2asm_grid_field_interpolation_name
 cbnz w0,.Lregistration_internal
.Lregistration_attribute_no_name:
 mov x0,x19
 mov x1,x27
 add x2,sp,#2528
 mov w3,w23
 mov w4,w24
 cmp w25,#6
 cset w5,hs
 bl md2asm_set_grid_field_attributes
 cbnz w0,.Lregistration_internal
 add x26,x26,#8
 add w25,w25,#1
 cmp w25,#8
 b.lo .Lregistration_attribute_loop
 /* Exact selected interpolation names are higher-order and all mgrid flags false.
  * Preserve the source scan order when building the mass-fixer membership list. */
 mov w11,#0
 mov w12,#0
 add x10,x19,#3848
 add x13,x19,#324
.Lregistration_mass_fixer_loop:
 ldr w9,[x10,#336]
 cbz w9,.Lregistration_no_mass_fixer
 ldr w9,[x10,#20]
 cbz w9,.Lregistration_no_mass_fixer
 add w9,w12,#1
 str w9,[x13,x11,lsl#2]
 add w11,w11,#1
.Lregistration_no_mass_fixer:
 add x10,x10,#368
 add w12,w12,#1
 cmp w12,#8
 b.lo .Lregistration_mass_fixer_loop
 str w11,[x19,#304]
 str wzr,[x19,#256]
 str wzr,[x19,#268]
 str wzr,[x19,#2672]
 str xzr,[x22]
 mov w0,#0
 b .Lregistration_restore
.Lregistration_reject:
 mov w0,#2
 b .Lregistration_restore
.Lregistration_internal:
 mov w0,#3
.Lregistration_restore:
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#2688
 ret
.Lregistration_reject_leaf:
 mov w0,#2
 ret
.size md2asm_register_selected_grid_fields,.-md2asm_register_selected_grid_fields
.p2align 3
.Lregistration_constant_offsets:
 .hword 192,208,344,352,392,400
.Lregistration_profile_offsets:
 .word 801344,801856,801600,803648,803904,805952,806208,880192,880448
.Lregistration_interpolation_flags:
 .hword 136,140,148,144,108,112,116,120,96,124
.p2align 3
.Lregistration_attribute_order:
 .word 0,0,5,5,1,1,2,2,3,3,4,4,6,7,7,8
.p2align 3
.Lregistration_species:
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
 .ascii "TENUNOGW        "
 .word 228134,-1,7,2,0,0,-1,-1,-1,0
 .ascii "TENVNOGW        "
 .word 228136,-1,8,2,0,0,-1,-1,-1,0
.section .note.GNU-stack,"",%progbits

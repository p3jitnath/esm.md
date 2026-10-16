/* Selected owned GFL namespace: source-derived defaults, live NAMGFL, registration.
 * x0 fresh GFL[1359136],x1 owned constants[520],x2 text,x3 text bytes,
 * x4 controls[8] = levels,supplementary,NSTOP,NGRIBFILE,LSPRT,LTRAJHR,NCONF,LECMWF,
 * x5 effects[2] = LVSPLIP,LSPLTHOIGFL. The selected control tuple is guarded.
 * No OpenIFS callable, data, type, virtual table or harness is an input.
 * Contract: skills/md2asm/references/openifs/setup/selected_grid_field_configuration.md in the repository.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_grid_field_configuration
.type md2asm_initialize_selected_grid_field_configuration,%function
md2asm_initialize_selected_grid_field_configuration:
 cbz x0,.Lconfiguration_reject_leaf
 cbz x1,.Lconfiguration_reject_leaf
 cbz x2,.Lconfiguration_reject_leaf
 cbz x4,.Lconfiguration_reject_leaf
 cbz x5,.Lconfiguration_reject_leaf
 cbz x3,.Lconfiguration_reject_leaf
 mov x9,#4
 lsl x9,x9,#16
 cmp x3,x9
 b.hi .Lconfiguration_reject_leaf
 orr x9,x0,x1
 orr x9,x9,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lconfiguration_reject_leaf
 mrs x9,fpcr
 cbnz x9,.Lconfiguration_reject_leaf
 adr x16,.Lconfiguration_selected_controls
 mov x10,x4
 mov w11,#8
.Lconfiguration_controls_loop:
 ldr w9,[x16],#4
 ldr w12,[x10],#4
 cmp w9,w12
 b.ne .Lconfiguration_reject_leaf
 subs w11,w11,#1
 b.ne .Lconfiguration_controls_loop
 /* Neither text nor control words may overlap an output range. */
 adds x11,x2,x3
 b.cs .Lconfiguration_reject_leaf
 mov x9,#0xbd20
 movk x9,#0x14,lsl#16
 adds x12,x0,x9
 b.cs .Lconfiguration_reject_leaf
 cmp x11,x0
 b.ls .Lconfiguration_text_gfl_separate
 cmp x2,x12
 b.lo .Lconfiguration_reject_leaf
.Lconfiguration_text_gfl_separate:
 adds x10,x4,#32
 b.cs .Lconfiguration_reject_leaf
 cmp x10,x0
 b.ls .Lconfiguration_controls_gfl_separate
 cmp x4,x12
 b.lo .Lconfiguration_reject_leaf
.Lconfiguration_controls_gfl_separate:
 adds x9,x5,#8
 b.cs .Lconfiguration_reject_leaf
 cmp x11,x5
 b.ls .Lconfiguration_text_effects_separate
 cmp x2,x9
 b.lo .Lconfiguration_reject_leaf
.Lconfiguration_text_effects_separate:
 cmp x10,x5
 b.ls .Lconfiguration_controls_effects_separate
 cmp x4,x9
 b.lo .Lconfiguration_reject_leaf
.Lconfiguration_controls_effects_separate:
 sub sp,sp,#2416
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 add x0,sp,#112
 mov x10,x0
 mov w11,#288
.Lconfiguration_zero_profiles:
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Lconfiguration_zero_profiles
 bl md2asm_initialize_selected_grid_field_profiles
 cbnz w0,.Lconfiguration_internal
 mov x0,x21
 mov x1,x22
 add x2,sp,#112
 bl md2asm_apply_selected_grid_field_namelist
 cbnz w0,.Lconfiguration_reject
 /* The complete selected caller requires the actual rain/snow input route. */
 ldr w9,[sp,#900]
 cmn w9,#1
 b.ne .Lconfiguration_reject
 ldr w9,[sp,#1156]
 cmn w9,#1
 b.ne .Lconfiguration_reject
 mov x0,x19
 add x1,sp,#112
 mov x2,x20
 ldp w3,w4,[x23]
 mov x5,x24
 bl md2asm_register_selected_grid_fields
 cbnz w0,.Lconfiguration_restore
 /* These inactive profiles and scalars occupy disjoint source-default slots.
  * Their selected bit copies commute with the active registration above. */
 mov x0,x19
 bl md2asm_initialize_selected_inactive_grid_defaults
 cbnz w0,.Lconfiguration_internal
 mov w0,#0
 b .Lconfiguration_restore
.Lconfiguration_reject:
 mov w0,#2
 b .Lconfiguration_restore
.Lconfiguration_internal:
 mov w0,#3
.Lconfiguration_restore:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#2416
 ret
.Lconfiguration_reject_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_selected_grid_field_configuration,.-md2asm_initialize_selected_grid_field_configuration
.p2align 2
.Lconfiguration_selected_controls:
 .word 19,0,25,1,1,0,1,1
.section .note.GNU-stack,"",%progbits

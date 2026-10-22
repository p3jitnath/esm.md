/* Construct the complete 137-layer grid-field description record.
 * x0: fresh zero output[1359136]; x1: read-only constants[520].
 * x2: read-only text; x3: text bytes; x4: read-only controls[9] int32.
 * x5: writable effects[10] int32. Buffer sizes are in bytes.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_field_configuration.md.
 * The existing selected_grid_field_configuration.S entry remains unchanged.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_grid_field_configuration
.type md2asm_initialize_operational_grid_field_configuration,%function
md2asm_initialize_operational_grid_field_configuration:
 cbz x0,.Loperational_configuration_reject_leaf
 cbz x1,.Loperational_configuration_reject_leaf
 cbz x2,.Loperational_configuration_reject_leaf
 cbz x4,.Loperational_configuration_reject_leaf
 cbz x5,.Loperational_configuration_reject_leaf
 cbz x3,.Loperational_configuration_reject_leaf
 mov x14,#64
 lsl x14,x14,#12
 cmp x3,x14
 b.hi .Loperational_configuration_reject_leaf
 orr x14,x0,x1
 orr x14,x14,x4
 orr x14,x14,x5
 tst x14,#7
 b.ne .Loperational_configuration_reject_leaf
 mrs x14,fpcr
 cbnz x14,.Loperational_configuration_reject_leaf
 /* Check every complete extent before reading controls or writing output. */
 mov x14,#0xbd20
 movk x14,#0x14,lsl#16
 adds x9,x0,x14
 b.cs .Loperational_configuration_reject_leaf
 adds x10,x1,#520
 b.cs .Loperational_configuration_reject_leaf
 adds x11,x2,x3
 b.cs .Loperational_configuration_reject_leaf
 adds x12,x4,#36
 b.cs .Loperational_configuration_reject_leaf
 adds x13,x5,#40
 b.cs .Loperational_configuration_reject_leaf
 cmp x10,x0
 b.ls .Loperational_configuration_constants_gfl_separate
 cmp x1,x9
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_constants_gfl_separate:
 cmp x11,x0
 b.ls .Loperational_configuration_text_gfl_separate
 cmp x2,x9
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_text_gfl_separate:
 cmp x12,x0
 b.ls .Loperational_configuration_controls_gfl_separate
 cmp x4,x9
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_controls_gfl_separate:
 cmp x13,x0
 b.ls .Loperational_configuration_effects_gfl_separate
 cmp x5,x9
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_effects_gfl_separate:
 cmp x10,x5
 b.ls .Loperational_configuration_constants_effects_separate
 cmp x1,x13
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_constants_effects_separate:
 cmp x11,x5
 b.ls .Loperational_configuration_text_effects_separate
 cmp x2,x13
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_text_effects_separate:
 cmp x12,x5
 b.ls .Loperational_configuration_controls_effects_separate
 cmp x4,x13
 b.lo .Loperational_configuration_reject_leaf
.Loperational_configuration_controls_effects_separate:
 /* NSTOP remains an explicit positive signed input; no duration is selected. */
 ldr w9,[x4,#8]
 cmp w9,#0
 b.le .Loperational_configuration_reject_leaf
 adr x16,.Loperational_configuration_fixed_controls
 mov w15,#8
.Loperational_configuration_controls:
 ldp w9,w10,[x16],#8
 ldr w11,[x4,x9]
 cmp w11,w10
 b.ne .Loperational_configuration_reject_leaf
 subs w15,w15,#1
 b.ne .Loperational_configuration_controls
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
.Loperational_configuration_zero_profiles:
 str xzr,[x10],#8
 subs w11,w11,#1
 b.ne .Loperational_configuration_zero_profiles
 bl md2asm_initialize_selected_grid_field_profiles
 cbnz w0,.Loperational_configuration_internal
 mov x0,x21
 mov x1,x22
 add x2,sp,#112
 bl md2asm_apply_selected_grid_field_namelist
 cbnz w0,.Loperational_configuration_reject
 /* Required source ozone and precipitation input settings are checked before publication. */
 ldr w9,[sp,#1692]
 cmp w9,#1
 b.ne .Loperational_configuration_reject
 ldr w9,[sp,#900]
 cmp w9,#1
 b.ne .Loperational_configuration_reject
 ldr w9,[sp,#1156]
 cmp w9,#1
 b.ne .Loperational_configuration_reject
 mov x0,x19
 add x1,sp,#112
 mov x2,x20
 ldp w3,w4,[x23]
 mov x5,x24
 bl md2asm_register_operational_grid_fields
 cbnz w0,.Loperational_configuration_restore
 /* These inactive profiles and scalars occupy disjoint source-default slots.
  * Their selected bit copies commute with the active registration above. */
 mov x0,x19
 bl md2asm_initialize_operational_inactive_grid_defaults
 cbnz w0,.Loperational_configuration_internal
 stp xzr,xzr,[x24,#8]
 stp xzr,xzr,[x24,#24]
 mov w0,#0
 b .Loperational_configuration_restore
.Loperational_configuration_reject:
 mov w0,#2
 b .Loperational_configuration_restore
.Loperational_configuration_internal:
 mov w0,#3
.Loperational_configuration_restore:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#2416
 ret
.Loperational_configuration_reject_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_grid_field_configuration,.-md2asm_initialize_operational_grid_field_configuration
.section .rodata
.p2align 3
.Loperational_configuration_fixed_controls:
 .word 0,137,4,0,12,1,16,1,20,0,24,1,28,1,32,1
.section .note.GNU-stack,"",%progbits

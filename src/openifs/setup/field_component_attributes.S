/* Apply selected SET_GFL_ATTR calls to an owned eight-field configuration.
 * Contract: skills/md2asm/references/openifs/setup/field_component_attributes.md in the repository.
 * x0 cfg[1359136],x1 embedded component[368],x2 plan[64],w3 levels,
 * w4 supplementary levels,w5 family 0 named moist/cloud or 1 NOGW.
 * Return 0 on success or 2 before mutation. No service or original-data input.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_set_grid_field_attributes
.type md2asm_set_grid_field_attributes,%function
md2asm_set_grid_field_attributes:
 cbz x0,.Lattr_reject
 cbz x1,.Lattr_reject
 cbz x2,.Lattr_reject
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lattr_reject
 cmp w5,#1
 b.hi .Lattr_reject
 sub w9,w3,#1
 cmp w9,#63
 b.hi .Lattr_reject
 cmp w4,#64
 b.hi .Lattr_reject
 mrs x9,fpcr
 cbnz x9,.Lattr_reject
 adr x9,.Lattr_configuration_bytes
 ldr x9,[x9]
 adds x6,x0,x9
 b.cs .Lattr_reject
 adds x7,x2,#64
 b.cs .Lattr_reject
 cmp x7,x0
 b.ls .Lattr_plan_separate
 cmp x2,x6
 b.lo .Lattr_reject
.Lattr_plan_separate:
 ldr w9,[x0]
 cmp w9,#8
 b.ne .Lattr_reject
 ldr w9,[x0,#12]
 cmp w9,#8
 b.ne .Lattr_reject
 ldr w9,[x0,#48]
 cmp w9,#8
 b.ne .Lattr_reject
 ldr w9,[x0,#56]
 cmp w9,#8
 b.ne .Lattr_reject
 ldr w9,[x0,#20]
 cmp w9,#6
 b.ne .Lattr_reject
 ldr w9,[x0,#64]
 cmp w9,#6
 b.ne .Lattr_reject
 adr x16,.Lattr_zero_counters
 mov w10,#11
.Lattr_zero_counters_loop:
 ldrb w9,[x16],#1
 ldr w9,[x0,x9]
 cbnz w9,.Lattr_reject
 subs w10,w10,#1
 b.ne .Lattr_zero_counters_loop
 ldr w8,[x1,#168]
 sub w9,w8,#1
 cmp w9,#7
 b.hi .Lattr_reject
 mov w10,#368
 umull x9,w9,w10
 add x9,x9,#3848
 add x9,x0,x9
 cmp x1,x9
 b.ne .Lattr_reject
 cmp w8,#6
 b.hi .Lattr_nogw_target
 cbnz w5,.Lattr_reject
 b .Lattr_target_valid
.Lattr_nogw_target:
 cmp w5,#1
 b.ne .Lattr_reject
.Lattr_target_valid:
 ldr w9,[x1,#52]
 cmp w9,#1
 b.ne .Lattr_reject
 ldr w9,[x1,#60]
 cbnz w9,.Lattr_reject
 ldr w9,[x1,#96]
 cbnz w9,.Lattr_reject
 /* All source-consumed logicals are0 or 1, with no extra time/tendency owners. */
 ldr w9,[x2,#20]
 cbnz w9,.Lattr_reject
 ldr w9,[x2,#28]
 cbnz w9,.Lattr_reject
 ldr w9,[x2,#32]
 cbnz w9,.Lattr_reject
 ldr w9,[x2,#24]
 cmp w9,#1
 b.hi .Lattr_reject
 cbnz w5,.Lattr_nogw_flags
 mov x16,x2
 mov w10,#5
.Lattr_named_flags_loop:
 ldr w9,[x16],#4
 cmp w9,#1
 b.hi .Lattr_reject
 subs w10,w10,#1
 b.ne .Lattr_named_flags_loop
 b .Lattr_flags_valid
.Lattr_nogw_flags:
 ldp w9,w10,[x2]
 orr w9,w9,w10
 cbnz w9,.Lattr_reject
.Lattr_flags_valid:
 ldr w11,[x0,#40]
 cmp w11,#6
 b.hi .Lattr_reject
 ldr w9,[x2]
 cbz w9,.Lattr_advection_valid
 ldr w9,[x1,#92]
 cmp w9,#1
 b.ne .Lattr_reject
 add w11,w11,#1
 cmp w11,#6
 b.hi .Lattr_reject
.Lattr_advection_valid:
 ldr w12,[x0,#32]
 cmp w12,#6
 b.hi .Lattr_reject
 ldr w9,[x0,#72]
 cmp w9,w12
 b.ne .Lattr_reject
 mov w14,#0
 ldr w9,[x1,#204]
 cmn w9,#99
 b.ne .Lattr_physics_valid
 ldr w9,[x2,#24]
 cbz w9,.Lattr_physics_valid
 ldr w9,[x1,#92]
 cmp w9,#1
 b.ne .Lattr_reject
 add w12,w12,#1
 cmp w12,#6
 b.hi .Lattr_reject
 mov w14,#1
.Lattr_physics_valid:
 ldr w13,[x0,#36]
 cmp w13,#6
 b.hi .Lattr_reject
 ldr w9,[x0,#76]
 cmp w9,w13
 b.ne .Lattr_reject
 mov w15,#0
 cbnz w5,.Lattr_spline_valid
 adr x16,.Lattr_undefined
 ldr w10,[x16]
 ldr w9,[x1,#212]
 cmp w9,w10
 b.ne .Lattr_spline_valid
 adr x16,.Lattr_spline_name
 ldr x9,[x16]
 ldr x10,[x2,#48]
 cmp x9,x10
 b.ne .Lattr_spline_valid
 ldr w9,[x16,#8]
 ldr w10,[x2,#56]
 cmp w9,w10
 b.ne .Lattr_spline_valid
 add w13,w13,#1
 cmp w13,#6
 b.hi .Lattr_reject
 mov w15,#1
.Lattr_spline_valid:
 /* Write only after every selected-domain check has completed. */
 ldr w9,[x2]
 str w9,[x1,#20]
 cbz w9,.Lattr_advection_done
 str w11,[x0,#40]
 str w11,[x1,#216]
 sub w9,w11,#1
 add w10,w3,w4,lsl#1
 mul w9,w9,w10
 str w9,[x1,#220]
.Lattr_advection_done:
 ldr w9,[x2,#4]
 str w9,[x1,#48]
 cbnz w5,.Lattr_nogw_optional
 ldr w9,[x2,#8]
 str w9,[x1,#24]
 ldr w9,[x2,#12]
 str w9,[x1,#28]
 ldr w9,[x2,#16]
 str w9,[x1,#32]
 b .Lattr_optional_done
.Lattr_nogw_optional:
 str wzr,[x1,#28]
 str wzr,[x1,#32]
.Lattr_optional_done:
 str wzr,[x1,#88]
 str w8,[x1,#180]
 str w8,[x1,#184]
 ldr w9,[x2,#24]
 str w9,[x1,#100]
 ldr w10,[x1,#204]
 cmn w10,#99
 b.ne .Lattr_physics_done
 cbz w14,.Lattr_no_physics_owner
 str w12,[x0,#32]
 str w12,[x0,#72]
 str w12,[x1,#204]
 b .Lattr_physics_done
.Lattr_no_physics_owner:
 adr x16,.Lattr_undefined
 ldr w9,[x16]
 str w9,[x1,#204]
.Lattr_physics_done:
 str wzr,[x1,#104]
 str wzr,[x1,#116]
 ldr w9,[x2,#36]
 str w9,[x1,#136]
 ldr x9,[x2,#40]
 str x9,[x1,#144]
 cbnz w5,.Lattr_spline_done
 ldr x9,[x2,#48]
 str x9,[x1,#156]
 ldr w9,[x2,#56]
 str w9,[x1,#164]
 cbz w15,.Lattr_spline_done
 str w13,[x0,#36]
 str w13,[x0,#76]
 str w13,[x1,#212]
.Lattr_spline_done:
 mov w0,#0
 ret
.Lattr_reject:
 mov w0,#2
 ret
.size md2asm_set_grid_field_attributes,.-md2asm_set_grid_field_attributes
.section .rodata
.p2align 3
.Lattr_configuration_bytes: .xword 1359136
.Lattr_undefined: .word -99999
.Lattr_spline_name: .ascii "LAITVSPCQM  "
.Lattr_zero_counters: .byte 4,8,16,24,28,44,52,60,68,80,84
.section .note.GNU-stack,"",%progbits

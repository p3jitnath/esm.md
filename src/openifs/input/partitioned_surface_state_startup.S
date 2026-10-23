/* Qualified live-provider contract: skills/md2asm/references/openifs/input/partitioned_surface_state_startup.md. */
/* Owned partitioned surface state startup, revision 1.
 * x0 path, x1 constants520, x2 TEPHY448, x3 TSURF18224,
 * x4 trajectory408, x5 descriptions46080, x6 controls48, x7 upstream48. TSURF/trajectory are fresh zero; TPHYDS is zero or declared counts+zero tail.
 * Contract: skills/md2asm/references/openifs/setup/owned_surface_state_startup.md. */
.arch armv8.2-a
.macro SS_WORK out,offset
 movz \out,#((\offset)&65535)
 movk \out,#((\offset)>>16),lsl#16
 add \out,x27,\out
.endm
.text
.p2align 4
.global md2asm_initialize_partitioned_operational_surface_state
.type md2asm_initialize_partitioned_operational_surface_state,%function
md2asm_initialize_partitioned_operational_surface_state:
 sub sp,sp,#336
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 stp x6,x7,[sp,#256]
 mrs x9,fpcr
 str x9,[sp,#112]
 cbnz x9,.Lss_reject
 mrs x9,fpsr
 str x9,[sp,#120]
 cbz x19,.Lss_reject
 cbz x20,.Lss_reject
 cbz x21,.Lss_reject
 cbz x22,.Lss_reject
 cbz x23,.Lss_reject
 cbz x24,.Lss_reject
 ldr x9,[sp,#264]
 cbz x9,.Lss_reject
 tst x9,#7
 b.ne .Lss_reject
 adds x10,x9,#48
 b.cs .Lss_reject
 str x9,[sp,#280]
 str x10,[sp,#320]
 ldr x10,[x9]
 str x10,[sp,#264]
 ldr x10,[x9,#8]
 cbz x10,.Lss_reject
 tst x10,#7
 b.ne .Lss_reject
 mov x11,#20400
 adds x11,x10,x11
 b.cs .Lss_reject
 str x10,[sp,#272]
 ldp x11,x12,[x9,#16]
 stp x11,x12,[sp,#288]
 ldp x13,x14,[x9,#32]
 stp x13,x14,[sp,#304]
 mov x15,#7376
 ldr w15,[x10,x15]
 cmp x11,x15
 b.ne .Lss_reject
 movz w15,#(1649920&65535)
 movk w15,#(1649920>>16),lsl#16
 cmp x11,x15
 b.ne .Lss_reject
 mov x15,#5144
 ldr w15,[x10,x15]
 cmp w15,#17
 b.ne .Lss_reject
 mov x15,#5160
 ldr w15,[x10,x15]
 cmp x14,x15
 b.ne .Lss_reject
 movz w15,#(97055&65535)
 movk w15,#(97055>>16),lsl#16
 cmp x14,x15
 b.ne .Lss_reject
 mov x15,#6648
 ldr x15,[x10,x15]
 cmp x12,x15
 b.ne .Lss_reject
 cbz x12,.Lss_reject
 tst x12,#3
 b.ne .Lss_reject
 lsl x15,x11,#2
 cmp x13,x15
 b.lo .Lss_reject
 adds x15,x12,x13
 b.cs .Lss_reject
 orr x9,x20,x21
 orr x9,x9,x22
 orr x9,x9,x23
 orr x9,x9,x24
 tst x9,#7
 b.ne .Lss_reject
 adds x9,x19,#4096
 b.cs .Lss_reject
 adds x9,x20,#520
 b.cs .Lss_reject
 stp x20,x9,[sp,#160]
 adds x9,x21,#448
 b.cs .Lss_reject
 stp x21,x9,[sp,#176]
 mov x9,#18224
 adds x9,x22,x9
 b.cs .Lss_reject
 stp x22,x9,[sp,#192]
 adds x9,x23,#408
 b.cs .Lss_reject
 stp x23,x9,[sp,#208]
 mov x9,#46080
 adds x9,x24,x9
 b.cs .Lss_reject
 stp x24,x9,[sp,#224]
 mov x9,x19
 mov w10,#4096
.Lss_path:
 ldrb w11,[x9],#1
 cbz w11,.Lss_path_end
 subs w10,w10,#1
 b.ne .Lss_path
 b .Lss_reject
.Lss_path_end:
 sub x10,x9,x19
 cmp x10,#1
 b.eq .Lss_reject
 stp x19,x9,[sp,#144]
 ldp x8,x10,[sp,#256]
 cbz x8,.Lss_reject
 cbz x10,.Lss_reject
 tst x8,#7
 b.ne .Lss_reject
 tst x10,#3
 b.ne .Lss_reject
 adds x9,x8,#48
 b.cs .Lss_reject
 adds x11,x10,#4
 b.cs .Lss_reject
 cmp x8,x11
 b.hs .Lss_extra_separate
 cmp x10,x9
 b.lo .Lss_reject
.Lss_extra_separate:
 mov w12,#0
.Lss_effect_ranges:
 add x13,sp,#144
 add x13,x13,x12,lsl#4
 ldp x14,x15,[x13]
 cmp x10,x15
 b.hs .Lss_effect_separate
 cmp x14,x11
 b.lo .Lss_reject
.Lss_effect_separate:
 add w12,w12,#1
 cmp w12,#6
 b.ne .Lss_effect_ranges
 mov w12,#3
.Lss_borrowed_output_ranges:
 add x13,sp,#144
 add x13,x13,x12,lsl#4
 ldp x14,x15,[x13]
 ldr x16,[sp,#280]
 ldr x17,[sp,#320]
 cmp x16,x15
 b.hs .Lss_upstream_separate
 cmp x14,x17
 b.lo .Lss_reject
.Lss_upstream_separate:
 ldr x16,[sp,#272]
 mov x17,#20400
 add x17,x16,x17
 cmp x16,x15
 b.hs .Lss_geometry_separate
 cmp x14,x17
 b.lo .Lss_reject
.Lss_geometry_separate:
 add w12,w12,#1
 cmp w12,#6
 b.ne .Lss_borrowed_output_ranges
 mov w12,#3
.Lss_control_ranges:
 add x13,sp,#144
 add x13,x13,x12,lsl#4
 ldp x14,x15,[x13]
 cmp x8,x15
 b.hs .Lss_control_separate
 cmp x14,x9
 b.lo .Lss_reject
.Lss_control_separate:
 add w12,w12,#1
 cmp w12,#6
 b.ne .Lss_control_ranges
 mov w9,#3
.Lss_output_range:
 add x11,sp,#144
 add x11,x11,x9,lsl#4
 ldp x12,x13,[x11]
 mov w10,#0
.Lss_prior_range:
 add x11,sp,#144
 add x11,x11,x10,lsl#4
 ldp x14,x15,[x11]
 cmp x12,x15
 b.hs .Lss_separate
 cmp x14,x13
 b.lo .Lss_reject
.Lss_separate:
 add w10,w10,#1
 cmp w10,w9
 b.ne .Lss_prior_range
 mov x11,x12
 cmp w9,#5
 b.ne .Lss_fresh_output
 ldp x14,x15,[x11]
 orr x14,x14,x15
 ldp x15,x16,[x11,#16]
 orr x14,x14,x15
 orr x14,x14,x16
 cbz x14,.Lss_fresh_output
 adr x0,.Lss_declared_phyds_counts
 mov w1,#4
.Lss_declared_phyds:
 ldr x14,[x11],#8
 ldr x15,[x0],#8
 cmp x14,x15
 b.ne .Lss_reject
 subs w1,w1,#1
 b.ne .Lss_declared_phyds
.Lss_fresh_output:
 ldr x14,[x11],#8
 cbnz x14,.Lss_reject
 cmp x11,x13
 b.ne .Lss_fresh_output
 add w9,w9,#1
 cmp w9,#6
 b.ne .Lss_output_range
 ldr w9,[x20,#512]
 cmp w9,#1
 b.ne .Lss_reject
 ldr w9,[x21,#176]
 cmp w9,#1
 b.ne .Lss_reject
 ldr w9,[x21,#172]
 cmp w9,#1
 b.ne .Lss_reject

 bl __errno_location
 mov x25,x0
 ldr w26,[x25]
 mov x27,#0
 mov x0,x22
 mov x1,x23
 mov x2,x24
 mov x3,x21
 ldr x4,[sp,#256]
 bl md2asm_construct_operational_surface_configuration
 cbnz w0,.Lss_metadata_failed
 mov x0,x22
 mov w1,#17
 movz w2,#(97055&65535)
 movk w2,#(97055>>16),lsl#16
 bl md2asm_allocate_distributed_surface_field_owners
 cbnz w0,.Lss_numerical_failed
 movz x0,#54128
 movk x0,#1,lsl#16
 bl malloc
 mov x27,x0
 ldr x9,[sp,#112]
 msr fpcr,x9
 ldr x9,[sp,#120]
 msr fpsr,x9
 str w26,[x25]
 cbz x27,.Lss_plan_allocation_failed
 mov x0,x27
 movz x1,#54128
 movk x1,#1,lsl#16
 bl .Lss_zero
 ldr x0,[sp,#272]
 mov x1,x22
 SS_WORK x2,17096
 SS_WORK x3,18632
 SS_WORK x4,116936
 bl md2asm_partitioned_surface_default_metadata
 SS_WORK x9,116936
 ldr x10,[x9]
 cbnz x10,.Lss_defaults_failed
 ldp x10,x11,[x9,#8]
 cmp x10,#10
 b.ne .Lss_defaults_failed
 cmp x11,#423
 b.ne .Lss_defaults_failed
 ldr x10,[x9,#40]
 movz x11,#43832
 movk x11,#45842,lsl#16
 movk x11,#1,lsl#32
 cmp x10,x11
 b.ne .Lss_defaults_failed
 SS_WORK x0,17096
 mov x1,#1536
 SS_WORK x2,18632
 movz x3,#32768
 movk x3,#1,lsl#16
 mov x4,#423
 mov x5,#10
 ldr x6,[sp,#264]
 bl md2asm_set_partitioned_initial_surface_defaults
 cbnz w0,.Lss_defaults_failed
 mov x0,x20
 SS_WORK x1,117000
 mov x2,#2304
 bl md2asm_initialize_operational_surface_input_configuration
 cbnz w0,.Lss_configuration_failed
 mov x0,x22
 SS_WORK x1,119304
 SS_WORK x2,119432
 bl .Lss_input_plan
 cbnz w0,.Lss_input_plan_failed
 SS_WORK x9,119400
 ldp x10,x11,[sp,#288]
 stp x10,x11,[x9]
 ldp x10,x11,[sp,#304]
 stp x10,x11,[x9,#16]
 mov x0,x19
 SS_WORK x1,117000
 mov x2,#2304
 SS_WORK x3,119304
 mov x4,#128
 SS_WORK x5,119432
 mov x6,#220
 bl md2asm_load_partitioned_operational_surface_state
 mov w28,w0
 cbz w0,.Lss_free_workspace
 add w28,w28,#1000
 b .Lss_cleanup
.Lss_metadata_failed:
 cmp w0,#2
 mov w28,#2
 b.eq .Lss_initial_status
 mov w28,#101
 b .Lss_initial_status
.Lss_numerical_failed:
 mov w28,#201
 b .Lss_cleanup
.Lss_plan_allocation_failed:
 mov w28,#301
 b .Lss_cleanup
.Lss_defaults_failed:
 mov w28,#401
 b .Lss_cleanup
.Lss_configuration_failed:
 mov w28,#501
 b .Lss_cleanup
.Lss_input_plan_failed:
 mov w28,#601
.Lss_cleanup:
 mrs x9,fpsr
 str x9,[sp,#240]
 ldr w9,[x25]
 str w9,[sp,#248]
 mov x0,x22
 bl md2asm_release_partitioned_operational_surface_state
 mov x0,x22
 mov x1,#18224
 bl .Lss_zero
 mov x0,x23
 mov x1,#408
 bl .Lss_zero
 mov x0,x24
 mov x1,#46080
 bl .Lss_zero
 b .Lss_free_saved_workspace
.Lss_free_workspace:
 mrs x9,fpsr
 str x9,[sp,#240]
 ldr w9,[x25]
 str w9,[sp,#248]
.Lss_free_saved_workspace:
 cbz x27,.Lss_restore_observed
 mov x0,x27
 bl free
.Lss_restore_observed:
 ldr x9,[sp,#112]
 msr fpcr,x9
 ldr x9,[sp,#240]
 msr fpsr,x9
 ldr w9,[sp,#248]
 str w9,[x25]
 mov w0,w28
 b .Lss_return
.Lss_initial_status:
 ldr x9,[sp,#112]
 msr fpcr,x9
 ldr x9,[sp,#120]
 msr fpsr,x9
 str w26,[x25]
 mov w0,w28
 b .Lss_return
.Lss_reject:
 mov w0,#2
.Lss_return:
 ldp x29,x30,[sp]
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 add sp,sp,#336
 ret
.size md2asm_initialize_partitioned_operational_surface_state,.-md2asm_initialize_partitioned_operational_surface_state

/* Zero x1 bytes at x0; both are multiples of eight. Only x0/x1 change. */
.Lss_zero:
 cbz x1,.Lss_zero_done
.Lss_zero_word:
 str xzr,[x0],#8
 subs x1,x1,#8
 b.ne .Lss_zero_word
.Lss_zero_done:
 ret

/* Private input plan: x0 owned TSURF, x1 owners80, x2 identifiers208.
 * Uses x0 through x17 only. Shapes and live source metadata must agree. */
.Lss_input_plan:
 mov x5,x0
 mov x6,x1
 mov x7,x2
 adrp x3,.Lss_input_owners
 add x3,x3,:lo12:.Lss_input_owners
 mov w4,#6
.Lss_input_owner:
 ldp w9,w10,[x3]
 add x11,x5,w9,uxtw
 ldr x12,[x11]
 cbz x12,.Lss_bad_plan
 ldr x9,[x11,#16]
 cmp x9,#8
 b.ne .Lss_bad_plan
 ldrb w9,[x11,#29]
 cmp w9,#3
 b.ne .Lss_bad_plan
 ldr w13,[x3,#8]
 ldrb w9,[x11,#28]
 cmp w9,w13
 b.ne .Lss_bad_plan
 add x16,x11,#40
 add x8,x3,#12
 mov x14,#0
 mov x15,#1
.Lss_input_dimension:
 ldr x9,[x16]
 cmp x9,x15
 b.ne .Lss_bad_plan
 sub x14,x14,x15
 ldr x9,[x16,#8]
 cmp x9,#1
 b.ne .Lss_bad_plan
 ldr w17,[x8],#4
 ldr x9,[x16,#16]
 cmp x9,x17
 b.ne .Lss_bad_plan
 mul x15,x15,x17
 add x16,x16,#24
 subs w13,w13,#1
 b.ne .Lss_input_dimension
 lsl x15,x15,#3
 cmp x15,x10
 b.ne .Lss_bad_plan
 ldr x9,[x11,#8]
 cmp x9,x14
 b.ne .Lss_bad_plan
 stp x12,x10,[x6],#16
 add x3,x3,#32
 subs w4,w4,#1
 b.ne .Lss_input_owner
 adrp x3,.Lss_parameter_routes
 add x3,x3,:lo12:.Lss_parameter_routes
 mov w4,#55
.Lss_parameter:
 ldp w9,w10,[x3]
 ldp w11,w12,[x3,#8]
 ldp w13,w15,[x3,#16]
 ldr x14,[x5,w9,uxtw]
 cbz x14,.Lss_bad_plan
 add x14,x14,w10,uxtw
 ldr w16,[x14]
 cmp w16,w15
 b.ne .Lss_bad_plan
 cmp w11,#2
 b.ne .Lss_layered_parameter
 ldr w9,[x14,#28]
 ldr w10,[x14,#56]
 b .Lss_parameter_values
.Lss_layered_parameter:
 ldr x16,[x14,#32]
 cbz x16,.Lss_bad_plan
 ldr w9,[x16,w12,uxtw#2]
 ldr x16,[x14,#224]
 cbz x16,.Lss_bad_plan
 ldr w10,[x16,w12,uxtw#2]
.Lss_parameter_values:
 cmp w9,w13
 b.ne .Lss_bad_plan
 cmp w10,#1
 b.ne .Lss_bad_plan
 str w9,[x7],#4
 add x3,x3,#24
 subs w4,w4,#1
 b.ne .Lss_parameter
 mov w0,#0
 ret
.Lss_bad_plan:
 mov w0,#2
 ret

.p2align 4
.global md2asm_release_partitioned_operational_surface_state
.type md2asm_release_partitioned_operational_surface_state,%function
md2asm_release_partitioned_operational_surface_state:
 cbz x0,.Lss_release_done
 stp x29,x30,[sp,#-32]!
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x0
 bl md2asm_release_surface_field_owners
 mov x0,x19
 bl md2asm_release_selected_surface_configuration
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#32
.Lss_release_done:
 mov w0,#0
 ret
.size md2asm_release_partitioned_operational_surface_state,.-md2asm_release_partitioned_operational_surface_state
.section .rodata
.p2align 3
.Lss_input_owners:
 .word 5744,316787520,4,17,4,6,97055,0
 .word 6336,184792720,3,17,14,97055,0,0
 .word 6032,659974000,4,17,5,10,97055,0
 .word 6632,52797920,3,17,4,97055,0,0
 .word 8784,501580240,3,17,38,97055,0,0
 .word 15136,39598440,3,17,3,97055,0,0
.Lss_parameter_routes:
 .word 5968,0,3,0,139,1
 .word 5968,0,3,1,170,1
 .word 5968,0,3,2,183,1
 .word 5968,0,3,3,236,1
 .word 5968,288,3,0,39,2
 .word 5968,288,3,1,40,2
 .word 5968,288,3,2,41,2
 .word 5968,288,3,3,42,2
 .word 5968,576,3,0,35,3
 .word 5968,576,3,1,36,3
 .word 5968,576,3,2,37,3
 .word 5968,576,3,3,38,3
 .word 6568,0,2,0,228008,1
 .word 6568,64,2,0,228009,2
 .word 6568,128,2,0,228010,3
 .word 6568,192,2,0,228011,4
 .word 6568,256,2,0,228012,5
 .word 6568,320,2,0,228013,6
 .word 6568,384,2,0,228014,7
 .word 6848,0,2,0,235,1
 .word 6848,64,2,0,198,2
 .word 9792,0,2,0,173,1
 .word 9792,64,2,0,174,2
 .word 9792,192,2,0,160,4
 .word 9792,256,2,0,172,5
 .word 9792,320,2,0,161,6
 .word 9792,384,2,0,162,7
 .word 9792,448,2,0,163,8
 .word 9792,512,2,0,234,9
 .word 9792,576,2,0,27,10
 .word 9792,640,2,0,129172,11
 .word 9792,704,2,0,28,12
 .word 9792,768,2,0,200199,13
 .word 9792,896,2,0,29,15
 .word 9792,960,2,0,30,16
 .word 9792,1024,2,0,66,17
 .word 9792,1088,2,0,67,18
 .word 9792,1152,2,0,43,19
 .word 9792,1216,2,0,26,20
 .word 9792,1280,2,0,228007,21
 .word 9792,1344,2,0,31,22
 .word 9792,1408,2,0,34,23
 .word 9792,1600,2,0,74,26
 .word 9792,1920,2,0,210186,31
 .word 9792,1984,2,0,210187,32
 .word 9792,2048,2,0,210188,33
 .word 9792,2112,2,0,210189,34
 .word 9792,2176,2,0,210190,35
 .word 9792,2240,2,0,210191,36
 .word 15312,0,2,0,148,1
 .word 6272,0,3,0,228141,1
 .word 6272,288,3,0,32,2
 .word 6272,576,3,0,33,3
 .word 6272,864,3,0,238,4
 .word 6272,1152,3,0,228038,5

.section .note.GNU-stack,"",%progbits

.section .rodata
.p2align 3
.Lss_declared_phyds_counts: .word 20,50,50,99,99,99,99,99

/* Contract: skills/md2asm/references/openifs/setup/cloud_gravity_wave_setup.md.
 * Own selected SUCLD, SUGWD and one-launch SUGWWMS setup.
 * x0 text, x1 bytes, x2 three record pairs, x3 six input pairs,
 * x4 int32 controls {19, LEPHYS}. Return 0/1 allocation/2 unsupported.
 * All bounds and domains are checked before allocation or record writes.
 * The 160-byte frame preserves x18 and all saved registers. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_cloud_gravity_wave_parameters
.type md2asm_initialize_cloud_gravity_wave_parameters,%function
md2asm_initialize_cloud_gravity_wave_parameters:
 cbz x0,.Lcloud_bad_leaf
 cbz x1,.Lcloud_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lcloud_bad_leaf
 adds x5,x0,x1
 b.cs .Lcloud_bad_leaf
 cbz x2,.Lcloud_bad_leaf
 cbz x3,.Lcloud_bad_leaf
 cbz x4,.Lcloud_bad_leaf
 orr x5,x2,x3
 orr x5,x5,x4
 tst x5,#7
 b.ne .Lcloud_bad_leaf
 adds x5,x2,#48
 b.cs .Lcloud_bad_leaf
 adds x5,x3,#96
 b.cs .Lcloud_bad_leaf
 adds x5,x4,#8
 b.cs .Lcloud_bad_leaf
 ldp w5,w6,[x4]
 cmp w5,#19
 b.ne .Lcloud_bad_leaf
 cmp w6,#1
 b.hi .Lcloud_bad_leaf
 mrs x5,fpcr
 cbnz x5,.Lcloud_bad_leaf
 stp x29,x30,[sp,#-160]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x6,fpsr
 stp x5,x6,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 /* Validate the complete consumed extent of each output and input. */
 adrp x12,.Lcloud_output_sizes
 add x12,x12,:lo12:.Lcloud_output_sizes
 mov x6,#0
.Lcloud_output_bounds:
 lsl x9,x6,#4
 add x13,x21,x9
 ldp x7,x8,[x13]
 cbz x7,.Lcloud_bad
 tst x7,#7
 b.ne .Lcloud_bad
 ldr x10,[x12,x6,lsl#3]
 cmp x8,x10
 b.lo .Lcloud_bad
 adds x11,x7,x10
 b.cs .Lcloud_bad
 add x6,x6,#1
 cmp x6,#3
 b.lo .Lcloud_output_bounds
 adrp x12,.Lcloud_input_sizes
 add x12,x12,:lo12:.Lcloud_input_sizes
 mov x6,#0
.Lcloud_input_bounds:
 lsl x9,x6,#4
 add x13,x22,x9
 ldp x7,x8,[x13]
 cbz x7,.Lcloud_bad
 tst x7,#7
 b.ne .Lcloud_bad
 ldr x10,[x12,x6,lsl#3]
 cmp x8,x10
 b.lo .Lcloud_bad
 adds x11,x7,x10
 b.cs .Lcloud_bad
 add x6,x6,#1
 cmp x6,#6
 b.lo .Lcloud_input_bounds
 /* Each output must be disjoint from all other live data. */
 mov x6,#0
.Lcloud_disjoint_output:
 lsl x9,x6,#4
 ldr x7,[x21,x9]
 adrp x12,.Lcloud_output_sizes
 add x12,x12,:lo12:.Lcloud_output_sizes
 ldr x10,[x12,x6,lsl#3]
 add x8,x7,x10
 add x11,x19,x20
 cmp x7,x11
 b.hs .Lcloud_text_clear
 cmp x19,x8
 b.lo .Lcloud_bad
.Lcloud_text_clear:
 add x11,x21,#48
 cmp x7,x11
 b.hs .Lcloud_records_clear
 cmp x21,x8
 b.lo .Lcloud_bad
.Lcloud_records_clear:
 add x11,x22,#96
 cmp x7,x11
 b.hs .Lcloud_inputs_clear
 cmp x22,x8
 b.lo .Lcloud_bad
.Lcloud_inputs_clear:
 add x11,x23,#8
 cmp x7,x11
 b.hs .Lcloud_controls_clear
 cmp x23,x8
 b.lo .Lcloud_bad
.Lcloud_controls_clear:
 add x9,x6,#1
.Lcloud_other_output:
 cmp x9,#3
 b.hs .Lcloud_input_disjoint_start
 lsl x10,x9,#4
 ldr x10,[x21,x10]
 ldr x11,[x12,x9,lsl#3]
 add x11,x10,x11
 cmp x7,x11
 b.hs .Lcloud_other_output_clear
 cmp x10,x8
 b.lo .Lcloud_bad
.Lcloud_other_output_clear:
 add x9,x9,#1
 b .Lcloud_other_output
.Lcloud_input_disjoint_start:
 adrp x12,.Lcloud_input_sizes
 add x12,x12,:lo12:.Lcloud_input_sizes
 mov x9,#0
.Lcloud_input_disjoint:
 lsl x10,x9,#4
 ldr x10,[x22,x10]
 ldr x11,[x12,x9,lsl#3]
 add x11,x10,x11
 cmp x7,x11
 b.hs .Lcloud_one_input_clear
 cmp x10,x8
 b.lo .Lcloud_bad
.Lcloud_one_input_clear:
 add x9,x9,#1
 cmp x9,#6
 b.lo .Lcloud_input_disjoint
 add x6,x6,#1
 cmp x6,#3
 b.lo .Lcloud_disjoint_output
 ldr x7,[x21]
 ldr x7,[x7]
 cbnz x7,.Lcloud_bad
 /* Positive binary64 encodings are ordered like unsigned integers.
  * This rejects nonfinite values without touching FPSR; -0 is allowed
  * only in the three nonnegative input roles. */
 adrp x12,.Lcloud_upper_bounds
 add x12,x12,:lo12:.Lcloud_upper_bounds
 mov x6,#0
.Lcloud_role:
 lsl x9,x6,#4
 ldr x7,[x22,x9]
 ldr x8,[x12,x6,lsl#3]
 mov x9,#19
 cmp x6,#2
 cinc x9,x9,hs
 mov x10,#0
.Lcloud_value:
 ldr x11,[x7,x10,lsl#3]
 and x13,x11,#0x7fffffffffffffff
 tbz x11,#63,.Lcloud_nonnegative
 cbnz x13,.Lcloud_bad
.Lcloud_nonnegative:
 cmp x13,x8
 b.hi .Lcloud_bad
 cmp x6,#1
 b.ne .Lcloud_value_clear
 cbz x13,.Lcloud_bad
.Lcloud_value_clear:
 add x10,x10,#1
 cmp x10,x9
 b.lo .Lcloud_value
 add x6,x6,#1
 cmp x6,#4
 b.lo .Lcloud_role
 ldr x7,[x22,#64]
 ldr x8,[x7,#56]
 adrp x12,.Lcloud_rhour
 ldr x9,[x12,:lo12:.Lcloud_rhour]
 cmp x8,x9
 b.ne .Lcloud_bad
 ldr x7,[x22,#80]
 ldr x8,[x7]
 adrp x12,.Lcloud_timestep_bounds
 add x12,x12,:lo12:.Lcloud_timestep_bounds
 ldp x9,x10,[x12]
 cmp x8,x9
 b.lo .Lcloud_bad
 cmp x8,x10
 b.hi .Lcloud_bad
 mov x0,x19
 mov x1,x20
 adrp x2,.Lcloud_namgwd
 add x2,x2,:lo12:.Lcloud_namgwd
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcloud_bad
 mov x0,x19
 mov x1,x20
 adrp x2,.Lcloud_namgwwms
 add x2,x2,:lo12:.Lcloud_namgwwms
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcloud_bad
 /* Isolate libc allocation status, then let the numerical status accrue. */
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 mov x0,#152
 bl malloc
 mov x26,x0
 str w25,[x24]
 ldp x9,x10,[sp,#112]
 msr fpcr,x9
 msr fpsr,x10
 cbz x26,.Lcloud_no_memory
 ldr x0,[x21]
 mov x1,x26
 ldr x2,[x22]
 bl md2asm_diagnostic_cloud_parameter_fields
 ldr x0,[x21,#16]
 ldr x1,[x22,#16]
 ldr x2,[x22,#32]
 ldr x3,[x22,#48]
 ldr x4,[x22,#64]
 add x4,x4,#56
 ldr w5,[x23,#4]
 bl md2asm_orographic_gravity_wave_parameter_fields
 ldr x0,[x21,#32]
 ldr x1,[x22,#16]
 ldr x2,[x22,#64]
 add x2,x2,#56
 ldr x3,[x22,#80]
 bl md2asm_nonorographic_gravity_wave_parameter_fields
 mov w0,#0
 b .Lcloud_return
.Lcloud_no_memory:
 mov w0,#1
 b .Lcloud_return
.Lcloud_bad:
 mov w0,#2
.Lcloud_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#160
 ret
.Lcloud_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_cloud_gravity_wave_parameters,.-md2asm_initialize_cloud_gravity_wave_parameters
.p2align 4
.global md2asm_release_cloud_parameter_eta
.type md2asm_release_cloud_parameter_eta,%function
/* x0 live TECLD, x1 capacity. Clear only its first descriptor word.
 * The 80-byte frame preserves status around libc free. */
md2asm_release_cloud_parameter_eta:
 cbz x0,.Lcloud_release_bad
 tst x0,#7
 b.ne .Lcloud_release_bad
 cmp x1,#264
 b.lo .Lcloud_release_bad
 adds x2,x0,#264
 b.cs .Lcloud_release_bad
 stp x29,x30,[sp,#-80]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 mrs x2,fpcr
 mrs x3,fpsr
 stp x2,x3,[sp,#48]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 ldr x0,[x19]
 cbz x0,.Lcloud_release_empty
 bl free
 str xzr,[x19]
.Lcloud_release_empty:
 str w21,[x20]
 ldp x2,x3,[sp,#48]
 msr fpcr,x2
 msr fpsr,x3
 mov w0,#0
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Lcloud_release_bad:
 mov w0,#2
 ret
.size md2asm_release_cloud_parameter_eta,.-md2asm_release_cloud_parameter_eta
.section .rodata
.p2align 3
.Lcloud_output_sizes: .quad 264,96,168
.Lcloud_input_sizes: .quad 152,152,160,160,520,8
.Lcloud_upper_bounds:
 .quad 0x3ff0000000000000,0x7fefffffffffffff,0x40f8bcd000000000,0x3ff0000000000000
.Lcloud_rhour: .quad 0x40ac200000000000
.Lcloud_timestep_bounds: .quad 0x3ff0000000000000,0x40f5180000000000
.Lcloud_namgwd: .ascii "NAMGWD"
.Lcloud_namgwwms: .ascii "NAMGWWMS"
.section .note.GNU-stack,"",%progbits

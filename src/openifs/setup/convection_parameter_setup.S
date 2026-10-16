/* Contract: skills/md2asm/references/openifs/setup/convection_parameter_setup.md.
 * x0 text,x1 bytes,x2 four output pairs,x3 four input pairs,
 * x4 int32 controls {19,21}. Return0/2; no mutation on rejection.
 * Complete ranges and domains are validated before the two direct children.
 * The160-byte frame preserves x18 and saved registers; no heap or libc call. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_convection_parameters
.type md2asm_initialize_convection_parameters,%function
md2asm_initialize_convection_parameters:
 cbz x0,.Lconvection_bad_leaf
 cbz x1,.Lconvection_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lconvection_bad_leaf
 adds x5,x0,x1
 b.cs .Lconvection_bad_leaf
 cbz x2,.Lconvection_bad_leaf
 cbz x3,.Lconvection_bad_leaf
 cbz x4,.Lconvection_bad_leaf
 orr x5,x2,x3
 orr x5,x5,x4
 tst x5,#7
 b.ne .Lconvection_bad_leaf
 adds x5,x2,#64
 b.cs .Lconvection_bad_leaf
 adds x5,x3,#64
 b.cs .Lconvection_bad_leaf
 adds x5,x4,#8
 b.cs .Lconvection_bad_leaf
 ldp w5,w6,[x4]
 cmp w5,#19
 b.ne .Lconvection_bad_leaf
 cmp w6,#21
 b.ne .Lconvection_bad_leaf
 mrs x5,fpcr
 cbnz x5,.Lconvection_bad_leaf
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
 adrp x12,.Lconvection_output_sizes
 add x12,x12,:lo12:.Lconvection_output_sizes
 mov x6,#0
.Lconvection_output_bounds:
 lsl x9,x6,#4
 add x13,x21,x9
 ldp x7,x8,[x13]
 cbz x7,.Lconvection_bad
 cmp x6,#2
 b.eq .Lconvection_four_byte_output
 tst x7,#7
 b.ne .Lconvection_bad
 b .Lconvection_output_alignment_clear
.Lconvection_four_byte_output:
 tst x7,#3
 b.ne .Lconvection_bad
.Lconvection_output_alignment_clear:
 ldr x10,[x12,x6,lsl#3]
 cmp x8,x10
 b.lo .Lconvection_bad
 adds x11,x7,x10
 b.cs .Lconvection_bad
 add x6,x6,#1
 cmp x6,#4
 b.lo .Lconvection_output_bounds
 adrp x12,.Lconvection_input_sizes
 add x12,x12,:lo12:.Lconvection_input_sizes
 mov x6,#0
.Lconvection_input_bounds:
 lsl x9,x6,#4
 add x13,x22,x9
 ldp x7,x8,[x13]
 cbz x7,.Lconvection_bad
 tst x7,#7
 b.ne .Lconvection_bad
 ldr x10,[x12,x6,lsl#3]
 cmp x8,x10
 b.lo .Lconvection_bad
 adds x11,x7,x10
 b.cs .Lconvection_bad
 add x6,x6,#1
 cmp x6,#4
 b.lo .Lconvection_input_bounds
 /* Each output must be disjoint from all other live data. */
 mov x6,#0
.Lconvection_disjoint_output:
 lsl x9,x6,#4
 ldr x7,[x21,x9]
 adrp x12,.Lconvection_output_sizes
 add x12,x12,:lo12:.Lconvection_output_sizes
 ldr x10,[x12,x6,lsl#3]
 add x8,x7,x10
 add x11,x19,x20
 cmp x7,x11
 b.hs .Lconvection_text_clear
 cmp x19,x8
 b.lo .Lconvection_bad
.Lconvection_text_clear:
 add x11,x21,#64
 cmp x7,x11
 b.hs .Lconvection_records_clear
 cmp x21,x8
 b.lo .Lconvection_bad
.Lconvection_records_clear:
 add x11,x22,#64
 cmp x7,x11
 b.hs .Lconvection_inputs_clear
 cmp x22,x8
 b.lo .Lconvection_bad
.Lconvection_inputs_clear:
 add x11,x23,#8
 cmp x7,x11
 b.hs .Lconvection_controls_clear
 cmp x23,x8
 b.lo .Lconvection_bad
.Lconvection_controls_clear:
 add x9,x6,#1
.Lconvection_other_output:
 cmp x9,#4
 b.hs .Lconvection_input_disjoint_start
 lsl x10,x9,#4
 ldr x10,[x21,x10]
 ldr x11,[x12,x9,lsl#3]
 add x11,x10,x11
 cmp x7,x11
 b.hs .Lconvection_other_output_clear
 cmp x10,x8
 b.lo .Lconvection_bad
.Lconvection_other_output_clear:
 add x9,x9,#1
 b .Lconvection_other_output
.Lconvection_input_disjoint_start:
 adrp x12,.Lconvection_input_sizes
 add x12,x12,:lo12:.Lconvection_input_sizes
 mov x9,#0
.Lconvection_input_disjoint:
 lsl x10,x9,#4
 ldr x10,[x22,x10]
 ldr x11,[x12,x9,lsl#3]
 add x11,x10,x11
 cmp x7,x11
 b.hs .Lconvection_one_input_clear
 cmp x10,x8
 b.lo .Lconvection_bad
.Lconvection_one_input_clear:
 add x9,x9,#1
 cmp x9,#4
 b.lo .Lconvection_input_disjoint
 add x6,x6,#1
 cmp x6,#4
 b.lo .Lconvection_disjoint_output
 /* Finite positive pressures, checked without FP operations. */
 ldr x7,[x22]
 mov x6,#0
 mov x9,#0x7fefffffffffffff
.Lconvection_pressure:
 ldr x8,[x7,x6]
 cbz x8,.Lconvection_bad
 cmp x8,x9
 b.hi .Lconvection_bad
 add x6,x6,#8
 cmp x6,#152
 b.lo .Lconvection_pressure
 adrp x12,.Lconvection_domains
 add x12,x12,:lo12:.Lconvection_domains
 ldr x7,[x22,#16]
 ldr x8,[x7,#112]
 ldp x9,x10,[x12]
 cmp x8,x9
 b.lo .Lconvection_bad
 cmp x8,x10
 b.hi .Lconvection_bad
 ldr x8,[x7,#368]
 ldp x9,x10,[x12,#16]
 cmp x8,x9
 b.lo .Lconvection_bad
 cmp x8,x10
 b.hi .Lconvection_bad
 ldr x7,[x22,#32]
 ldp x9,x10,[x12,#32]
 mov x6,#0
.Lconvection_scaling:
 ldr x8,[x7,x6]
 cmp x8,x9
 b.lo .Lconvection_bad
 cmp x8,x10
 b.hi .Lconvection_bad
 add x6,x6,#8
 cmp x6,#24
 b.lo .Lconvection_scaling
 ldr x7,[x22,#48]
 ldr x8,[x7]
 ldp x9,x10,[x12,#48]
 cmp x8,x9
 b.lo .Lconvection_bad
 cmp x8,x10
 b.hi .Lconvection_bad
 mov x0,x19
 mov x1,x20
 adrp x2,.Lconvection_namcumf
 add x2,x2,:lo12:.Lconvection_namcumf
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lconvection_bad
 mov x0,x19
 mov x1,x20
 adrp x2,.Lconvection_namcumfs
 add x2,x2,:lo12:.Lconvection_namcumfs
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lconvection_bad
 ldr x0,[x21]
 ldr x1,[x22]
 ldr x2,[x22,#16]
 ldr x3,[x22,#32]
 ldr x4,[x21,#48]
 bl md2asm_cumulus_convection_parameter_fields
 ldr x0,[x21,#16]
 ldr x1,[x21,#32]
 ldr x2,[x22]
 ldr x3,[x22,#16]
 ldr x4,[x22,#32]
 ldr x5,[x22,#48]
 bl md2asm_linearized_convection_parameter_fields
 mov w0,#0
 b .Lconvection_return
.Lconvection_bad:
 mov w0,#2
.Lconvection_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#160
 ret
.Lconvection_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_convection_parameters,.-md2asm_initialize_convection_parameters
.section .rodata
.p2align 3
.Lconvection_output_sizes: .quad 344,240,12,24
.Lconvection_input_sizes: .quad 152,520,24,8
.Lconvection_domains: .double 1.0,100.0,200.0,350.0,0.25,4.0,1.0,86400.0
.Lconvection_namcumf: .ascii "NAMCUMF"
.Lconvection_namcumfs: .ascii "NAMCUMFS"
.section .note.GNU-stack,"",%progbits

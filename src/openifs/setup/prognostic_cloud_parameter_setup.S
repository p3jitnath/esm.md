// Guarded complete selected SUCLDP producer. Source metadata stays caller-owned.
// Contract: skills/md2asm/references/openifs/setup/prognostic_cloud_parameter_setup.md
.arch armv8-a
.text
.p2align 4
.global md2asm_initialize_prognostic_cloud_parameters
.type md2asm_initialize_prognostic_cloud_parameters,%function
// x0=text, x1=bytes, x2=TECLDP, x3=capacity, x4=four input address/size pairs.
md2asm_initialize_prognostic_cloud_parameters:
 cbz x0,.Lcloud_bad_leaf
 cbz x1,.Lcloud_bad_leaf
 cmp x1,#64,lsl #12
 b.hi .Lcloud_bad_leaf
 cbz x2,.Lcloud_bad_leaf
 cmp x3,#2776
 b.lo .Lcloud_bad_leaf
 cbz x4,.Lcloud_bad_leaf
 orr x5,x2,x4
 tst x5,#7
 b.ne .Lcloud_bad_leaf
 adds x5,x0,x1
 b.cs .Lcloud_bad_leaf
 adds x5,x2,#2776
 b.cs .Lcloud_bad_leaf
 adds x5,x4,#64
 b.cs .Lcloud_bad_leaf
 mrs x5,fpcr
 cbnz x5,.Lcloud_bad_leaf
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x4
 add x23,x21,#2776
 add x24,x19,x20
 add x25,x22,#64
 cmp x21,x24
 b.hs .Lcloud_check_table_overlap
 cmp x19,x23
 b.lo .Lcloud_bad
.Lcloud_check_table_overlap:
 cmp x21,x25
 b.hs .Lcloud_check_input_bounds
 cmp x22,x23
 b.lo .Lcloud_bad
.Lcloud_check_input_bounds:
 adrp x12,.Lcloud_input_sizes
 add x12,x12,:lo12:.Lcloud_input_sizes
 mov x6,#0
.Lcloud_input_loop:
 lsl x7,x6,#4
 add x7,x22,x7
 ldp x8,x9,[x7]
 cbz x8,.Lcloud_bad
 tst x8,#7
 b.ne .Lcloud_bad
 ldr x10,[x12,x6,lsl #3]
 cmp x9,x10
 b.lo .Lcloud_bad
 adds x11,x8,x10
 b.cs .Lcloud_bad
 cmp x21,x11
 b.hs .Lcloud_input_disjoint
 cmp x8,x23
 b.lo .Lcloud_bad
.Lcloud_input_disjoint:
 add x6,x6,#1
 cmp x6,#4
 b.lo .Lcloud_input_loop
 // Read-only domain checks use positive IEEE-754 bit ordering.
 ldr x7,[x22]
 mov x6,#19
 mov x10,#0x7ff0000000000000
.Lcloud_pressure_domain:
 ldr x8,[x7],#8
 cbz x8,.Lcloud_bad
 cmp x8,x10
 b.hs .Lcloud_bad
 subs x6,x6,#1
 b.ne .Lcloud_pressure_domain
 ldr x7,[x22,#16]
 ldr x8,[x7]
 ldr x9,.Lcloud_pi_bits
 cmp x8,x9
 b.ne .Lcloud_bad
 ldr x8,[x7,#112]
 ldr x9,.Lcloud_one_bits
 cmp x8,x9
 b.lo .Lcloud_bad
 ldr x10,.Lcloud_hundred_bits
 cmp x8,x10
 b.hi .Lcloud_bad
 ldr x8,[x7,#368]
 ldr x9,.Lcloud_200_bits
 cmp x8,x9
 b.lo .Lcloud_bad
 ldr x10,.Lcloud_350_bits
 cmp x8,x10
 b.hi .Lcloud_bad
 ldr x7,[x22,#32]
 ldp x8,x9,[x7]
 ldr x10,.Lcloud_quarter_bits
 ldr x11,.Lcloud_four_bits
 cmp x8,x10
 b.lo .Lcloud_bad
 cmp x8,x11
 b.hi .Lcloud_bad
 cmp x9,x10
 b.lo .Lcloud_bad
 cmp x9,x11
 b.hi .Lcloud_bad
 ldr x7,[x22,#48]
 ldr x8,[x7]
 ldr x9,.Lcloud_one_bits
 cmp x8,x9
 b.lo .Lcloud_bad
 ldr x10,.Lcloud_day_bits
 cmp x8,x10
 b.hi .Lcloud_bad
 ldr x8,[x21,#144]
 ldr x10,.Lcloud_million_bits
 cmp x8,x10
 b.hi .Lcloud_bad
 mov x0,x19
 mov x1,x20
 adrp x2,.Lcloud_group_name
 add x2,x2,:lo12:.Lcloud_group_name
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcloud_bad
 mov x0,x21
 ldr x1,[x22]
 ldr x2,[x22,#16]
 ldr x3,[x22,#32]
 ldr x4,[x22,#48]
 bl md2asm_prognostic_cloud_parameter_fields
 b .Lcloud_return
.Lcloud_bad:
 mov w0,#2
.Lcloud_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.Lcloud_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_prognostic_cloud_parameters,.-md2asm_initialize_prognostic_cloud_parameters
.section .rodata
.p2align 3
.Lcloud_input_sizes:.quad 152,520,16,8
.Lcloud_pi_bits:.double 3.1415926535897932384626433832795
.Lcloud_one_bits:.double 1.0
.Lcloud_hundred_bits:.double 100.0
.Lcloud_200_bits:.double 200.0
.Lcloud_350_bits:.double 350.0
.Lcloud_quarter_bits:.double 0.25
.Lcloud_four_bits:.double 4.0
.Lcloud_day_bits:.double 86400.0
.Lcloud_million_bits:.double 1000000.0
.Lcloud_group_name:.ascii "NAMCLDP"
.section .note.GNU-stack,"",%progbits

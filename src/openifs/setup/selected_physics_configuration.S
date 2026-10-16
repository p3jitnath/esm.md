/* Contract: skills/md2asm/references/openifs/setup/selected_physics_configuration.md. */
/* Own the selected complete SU0PHY configuration state effects.
 * x0 live fort.4 bytes; x1 length1..262144; x2 record table[34 u64];
 * x3 controls[2 i32]={LSLAG,LUVPOUT}; x4 counts[5 i32].
 * Record table entries are {pointer,capacity}, in contract order.
 * Records use their declared alignment (4 for NCL/EGWDWMS, 8 otherwise),
 * are mutually disjoint, and are disjoint from
 * live text, record table, controls and counts. Counts align4.
 * Return0/2; validation failures leave all outputs unchanged.
 * Frame5808 plus6240 in private NAMFPC validation; no external services.
 * Numerical FPCR must be0. FPSR and errno are preserved by this utility.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_physics_configuration
.type md2asm_initialize_selected_physics_configuration,%function
md2asm_initialize_selected_physics_configuration:
 cbz x0,.Lphysics_parent_bad_leaf
 cbz x1,.Lphysics_parent_bad_leaf
 cbz x2,.Lphysics_parent_bad_leaf
 cbz x3,.Lphysics_parent_bad_leaf
 cbz x4,.Lphysics_parent_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lphysics_parent_bad_leaf
 orr x9,x2,x3
 tst x9,#7
 b.ne .Lphysics_parent_bad_leaf
 tst x4,#3
 b.ne .Lphysics_parent_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Lphysics_parent_bad_leaf
 adds x5,x0,x1
 b.cs .Lphysics_parent_bad_leaf
 adds x6,x2,#272
 b.cs .Lphysics_parent_bad_leaf
 adds x7,x3,#8
 b.cs .Lphysics_parent_bad_leaf
 adds x8,x4,#20
 b.cs .Lphysics_parent_bad_leaf
 /* Counts are disjoint from the three live input ranges. */
 cmp x8,x0
 b.ls .Lphysics_count_text_ok
 cmp x4,x5
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_count_text_ok:
 cmp x8,x2
 b.ls .Lphysics_count_table_ok
 cmp x4,x6
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_count_table_ok:
 cmp x8,x3
 b.ls .Lphysics_count_controls_ok
 cmp x4,x7
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_count_controls_ok:
 ldp w9,w10,[x3]
 cmp w9,#1
 b.hi .Lphysics_parent_bad_leaf
 cmp w10,#1
 b.hi .Lphysics_parent_bad_leaf
 mov x9,#0
 adr x10,.Lphysics_record_sizes
.Lphysics_validate_record:
 add x11,x2,x9,lsl#4
 ldp x12,x13,[x11]
 cbz x12,.Lphysics_parent_bad_leaf
 cmp x9,#11
 b.eq .Lphysics_record_alignment4
 cmp x9,#12
 b.eq .Lphysics_record_alignment4
 tst x12,#7
 b.ne .Lphysics_parent_bad_leaf
 b .Lphysics_record_aligned
.Lphysics_record_alignment4:
 tst x12,#3
 b.ne .Lphysics_parent_bad_leaf
.Lphysics_record_aligned:
 ldr w14,[x10,x9,lsl#2]
 cmp x13,x14
 b.lo .Lphysics_parent_bad_leaf
 adds x13,x12,x14
 b.cs .Lphysics_parent_bad_leaf
 cmp x13,x0
 b.ls .Lphysics_record_text_ok
 cmp x12,x5
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_record_text_ok:
 cmp x13,x2
 b.ls .Lphysics_record_table_ok
 cmp x12,x6
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_record_table_ok:
 cmp x13,x3
 b.ls .Lphysics_record_control_ok
 cmp x12,x7
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_record_control_ok:
 cmp x13,x4
 b.ls .Lphysics_record_counts_ok
 cmp x12,x8
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_record_counts_ok:
 mov x14,#0
.Lphysics_record_pair:
 cmp x14,x9
 b.hs .Lphysics_record_valid
 add x15,x2,x14,lsl#4
 ldr x15,[x15]
 ldr w16,[x10,x14,lsl#2]
 add x16,x15,x16
 cmp x13,x15
 b.ls .Lphysics_pair_valid
 cmp x12,x16
 b.lo .Lphysics_parent_bad_leaf
.Lphysics_pair_valid:
 add x14,x14,#1
 b .Lphysics_record_pair
.Lphysics_record_valid:
 add x9,x9,#1
 cmp x9,#17
 b.lo .Lphysics_validate_record
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#1,lsl#12
 sub sp,sp,#1600
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 adr x24,.Lphysics_empty_groups
 adr x25,.Lphysics_empty_groups_end
.Lphysics_validate_group:
 ldr x26,[x24]
 mov x0,x19
 mov x1,x20
 add x2,x24,#8
 mov x3,x26
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lphysics_parent_return
 add x24,x24,#24
 cmp x24,x25
 b.lo .Lphysics_validate_group
 /* Parse supported request-only NAMFPC; shared-global overrides reject. */
 mov x0,x19
 mov x1,x20
 mov x2,sp
 bl md2asm_parse_physics_output_requests
 cbnz w0,.Lphysics_parent_return
 /* TEPHY validates into its private record before committing any byte. */
 mov x0,x19
 mov x1,x20
 ldr x2,[x21,#144]
 ldr x3,[x21,#152]
 mov x4,x22
 mov x5,x23
 bl md2asm_initialize_selected_physics_controls
 cbnz w0,.Lphysics_parent_return
 /* No remaining source-selected path can fail after this child commits. */
 mov x0,x21
 bl md2asm_default_remaining_physics_configuration
.Lphysics_parent_return:
 add sp,sp,#1,lsl#12
 add sp,sp,#1600
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.Lphysics_parent_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_selected_physics_configuration,.-md2asm_initialize_selected_physics_configuration
.section .rodata
.p2align 3
.Lphysics_record_sizes:
 .word 1096,40,368,1024,88,168,100,80,32,448,2776,8,4,232,120,1024,24
.p2align 3
.Lphysics_empty_groups:
 .quad 6; .ascii "NAMPHY"; .zero 10
 .quad 8; .ascii "NAMDVISI"; .zero 8
 .quad 8; .ascii "NAMARPHY"; .zero 8
 .quad 6; .ascii "NAPHLC"; .zero 10
 .quad 8; .ascii "NAMTRAJP"; .zero 8
 .quad 9; .ascii "NAMSIMPHL"; .zero 7
 .quad 8; .ascii "NAMRCOEF"; .zero 8
 .quad 6; .ascii "NAMSCM"; .zero 10
.Lphysics_empty_groups_end:
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2asm/references/openifs/input/operational_registry_owner_lease.md.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_actual_registry_physics_data
.type md2asm_initialize_actual_registry_physics_data,%function
md2asm_initialize_actual_registry_physics_data:
 cbz x0,.Lphy_data_bad
 cbz x1,.Lphy_data_bad
 cbz x2,.Lphy_data_bad
 tst x0,#7
 b.ne .Lphy_data_bad
 cmp x2,#64,lsl#12
 b.hi .Lphy_data_bad
 mov x9,#51512
 adds x10,x0,x9
 b.cs .Lphy_data_bad
 adds x11,x1,x2
 b.cs .Lphy_data_bad
 cmp x0,x11
 b.hs .Lphy_inputs_disjoint
 cmp x1,x10
 b.lo .Lphy_data_bad
.Lphy_inputs_disjoint:
 adrp x12,:got:md2asm_owned_physics_runtime_data
 ldr x12,[x12,:got_lo12:md2asm_owned_physics_runtime_data]
 add x13,x12,#608
 cmp x0,x13
 b.hs .Lphy_input2_disjoint
 cmp x12,x10
 b.lo .Lphy_data_bad
.Lphy_input2_disjoint:
 cmp x1,x13
 b.hs .Lphy_controls
 cmp x12,x11
 b.lo .Lphy_data_bad
.Lphy_controls:
 mov x9,#35104
 ldr w10,[x0,x9]
 cmp w10,#1
 b.ne .Lphy_data_bad
 mov x9,#35184
 ldr w10,[x0,x9]
 cmp w10,#0
 b.ne .Lphy_data_bad
 mov x9,#35288
 ldr w10,[x0,x9]
 cmp w10,#0
 b.ne .Lphy_data_bad
 mov x9,#35588
 ldr w10,[x0,x9]
 cmp w10,#0
 b.ne .Lphy_data_bad
 mov x9,#35592
 ldr w10,[x0,x9]
 cmp w10,#0
 b.ne .Lphy_data_bad
 mov x9,#35620
 ldr w10,[x0,x9]
 cmp w10,#0
 b.ne .Lphy_data_bad
 mov x9,#39520
 ldr w10,[x0,x9]
 cmp w10,#1
 b.ne .Lphy_data_bad
 // The explicit original BSS policy is checked, not repaired.
 mov x9,#20
.Lphy_fresh_scalars:
 ldr w10,[x12,x9]
 cbnz w10,.Lphy_data_bad
 add x9,x9,#4
 cmp x9,#60
 b.lo .Lphy_fresh_scalars
 mov x9,#64
.Lphy_fresh_descriptors:
 ldr x10,[x12,x9]
 cbnz x10,.Lphy_data_bad
 add x9,x9,#8
 cmp x9,#608
 b.lo .Lphy_fresh_descriptors
 sub sp,sp,#80
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x1
 mov x20,x2
 mov x21,x12
 mov x0,x19
 mov x1,x20
 adrp x2,.Lphy_namdyna
 add x2,x2,:lo12:.Lphy_namdyna
 mov x3,#14
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lphy_data_return
 mov x0,x19
 mov x1,x20
 adrp x2,.Lphy_namtest
 add x2,x2,:lo12:.Lphy_namtest
 mov x3,#10
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lphy_data_return
 // Five exact source-selected false assignments; reserved bytes are untouched.
 stp wzr,wzr,[x21]
 stp wzr,wzr,[x21,#8]
 str wzr,[x21,#16]
 mov w0,#0
.Lphy_data_return:
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.Lphy_data_bad:
 mov w0,#2
 ret
.size md2asm_initialize_actual_registry_physics_data,.-md2asm_initialize_actual_registry_physics_data
.section .rodata
.Lphy_namdyna: .ascii "NAMDYNA_STATIC"
.Lphy_namtest: .ascii "NAMTESTVAR"
.section .note.GNU-stack,"",%progbits

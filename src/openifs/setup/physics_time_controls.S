/* Contract: skills/md2asm/references/openifs/setup/physics_time_controls.md.
 * Complete selected SUPHY2. x0 text, x1 length, x2 TPHY2 output160,
 * x3 capacity, x4 hybrid-input record40. Return0/2. FPCR0.
 * All checks finish before mutation. The 80-byte parent frame preserves
 * x18 and x19..x24. The raw child is a leaf and keeps source FP64 order. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_physics_time_controls
.type md2asm_initialize_physics_time_controls,%function
md2asm_initialize_physics_time_controls:
 cbz x0,.Ltime_bad_leaf
 cbz x1,.Ltime_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Ltime_bad_leaf
 adds x9,x0,x1
 b.cs .Ltime_bad_leaf
 cbz x2,.Ltime_bad_leaf
 tst x2,#7
 b.ne .Ltime_bad_leaf
 cmp x3,#160
 b.lo .Ltime_bad_leaf
 adds x10,x2,#160
 b.cs .Ltime_bad_leaf
 cmp x2,x9
 b.hs .Ltime_text_disjoint
 cmp x0,x10
 b.lo .Ltime_bad_leaf
.Ltime_text_disjoint:
 cbz x4,.Ltime_bad_leaf
 tst x4,#7
 b.ne .Ltime_bad_leaf
 adds x9,x4,#40
 b.cs .Ltime_bad_leaf
 cmp x2,x9
 b.hs .Ltime_control_disjoint
 cmp x4,x10
 b.lo .Ltime_bad_leaf
.Ltime_control_disjoint:
 mrs x9,fpcr
 cbnz x9,.Ltime_bad_leaf
 ldr w9,[x4,#32]
 cmp w9,#19
 b.ne .Ltime_bad_leaf
 ldr w9,[x4,#36]
 cmp w9,#1
 b.ne .Ltime_bad_leaf
 ldp x5,x6,[x4]
 ldp x7,x8,[x4,#16]
 cbz x5,.Ltime_bad_leaf
 tst x5,#7
 b.ne .Ltime_bad_leaf
 cmp x6,#160
 b.lo .Ltime_bad_leaf
 adds x9,x5,#160
 b.cs .Ltime_bad_leaf
 cmp x2,x9
 b.hs .Ltime_array_a_disjoint
 cmp x5,x10
 b.lo .Ltime_bad_leaf
.Ltime_array_a_disjoint:
 cbz x7,.Ltime_bad_leaf
 tst x7,#7
 b.ne .Ltime_bad_leaf
 cmp x8,#160
 b.lo .Ltime_bad_leaf
 adds x9,x7,#160
 b.cs .Ltime_bad_leaf
 cmp x2,x9
 b.hs .Ltime_array_b_disjoint
 cmp x7,x10
 b.lo .Ltime_bad_leaf
.Ltime_array_b_disjoint:
 /* Integer domain checks leave flags unchanged on rejected values. */
 mov x11,#0x3ff0000000000000
 mov x12,#0
.Ltime_check_values:
 ldr x9,[x5,x12,lsl#3]
 ldr x10,[x7,x12,lsl#3]
 and x13,x9,#0x7fffffffffffffff
 cmp x13,x11
 b.hi .Ltime_bad_leaf
 cmp x9,#0
 b.ge .Ltime_a_nonnegative
 cbnz x13,.Ltime_bad_leaf
.Ltime_a_nonnegative:
 and x13,x10,#0x7fffffffffffffff
 cmp x13,x11
 b.hi .Ltime_bad_leaf
 cmp x10,#0
 b.ge .Ltime_b_nonnegative
 cbnz x13,.Ltime_bad_leaf
.Ltime_b_nonnegative:
 add x12,x12,#1
 cmp x12,#20
 b.lo .Ltime_check_values
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x29,sp
 mov x19,x2
 mov x20,x5
 mov x21,x7
 adr x2,.Ltime_group
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Ltime_bad
 mov x0,x19
 mov x1,x20
 mov x2,x21
 bl md2asm_set_physics_time_controls_raw
 mov w0,#0
 b .Ltime_return
.Ltime_bad:
 mov w0,#2
.Ltime_return:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Ltime_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_physics_time_controls,.-md2asm_initialize_physics_time_controls
.p2align 4
.global md2asm_set_physics_time_controls_raw
.type md2asm_set_physics_time_controls_raw,%function
md2asm_set_physics_time_controls_raw:
 /* x0 output160, x1 VALH20, x2 VBH20, validated, disjoint output. */
 adr x9,.Ltime_XMULAF
 ldr x9,[x9]
 str x9,[x0,#24] /* XMULAF */
 str xzr,[x0,#16] /* XMUCVPP, positive zero */
 str xzr,[x0,#32] /* XDAMP, positive zero */
 adr x9,.Ltime_HCLP
 ldr x9,[x9]
 str x9,[x0,#40] /* HCLP */
 adr x9,.Ltime_HTCLS
 ldr x9,[x9]
 str x9,[x0,#48] /* HTCLS */
 adr x9,.Ltime_HVCLS
 ldr x9,[x9]
 str x9,[x0,#56] /* HVCLS */
 adr x9,.Ltime_HTSHM
 ldr x9,[x9]
 str x9,[x0,#64] /* HTSHM */
 adr x9,.Ltime_HTSML
 ldr x9,[x9]
 str x9,[x0,#72] /* HTSML */
 adr x9,.Ltime_TSPHY
 ldr x9,[x9]
 str x9,[x0,#8] /* TSPHY */
 str wzr,[x0,#144] /* LRAFTUR */
 str wzr,[x0,#156] /* LRAFTKE */
 adr x9,.Ltime_GZ0RAF
 ldr x9,[x9]
 str x9,[x0,#96] /* GZ0RAF */
 adr x9,.Ltime_FACRAF
 ldr x9,[x9]
 str x9,[x0,#104] /* FACRAF */
 str xzr,[x0,#112] /* FACRAFCV, positive zero */
 str xzr,[x0,#120] /* FACRAFDCAPE, positive zero */
 adr x9,.Ltime_GCAPERAF
 ldr x9,[x9]
 str x9,[x0,#128] /* GCAPERAF */
 str wzr,[x0,#148] /* LMULAF */
 str wzr,[x0,#152] /* LWMOCLOUD */
 adr x9,.Ltime_HWMOHIGH
 ldr x9,[x9]
 str x9,[x0,#80] /* HWMOHIGH */
 adr x9,.Ltime_HWMOLOW
 ldr x9,[x9]
 str x9,[x0,#88] /* HWMOLOW */
 adr x9,.Ltime_HTKERAF
 ldr x9,[x9]
 str x9,[x0,#136] /* HTKERAF */
 str xzr,[x0] /* NTSHM and NTSML */
 ldr d4,[x0,#64] /* HTSHM */
 ldr d5,[x0,#72] /* HTSML */
 fmov d6,#0.5
 mov x9,#1
.Ltime_layer:
 ldr d0,[x1,x9,lsl#3]
 ldr d1,[x2,x9,lsl#3]
 fadd d0,d0,d1
 sub x10,x9,#1
 ldr d1,[x1,x10,lsl#3]
 fadd d0,d0,d1
 ldr d1,[x2,x10,lsl#3]
 fadd d0,d0,d1
 fmul d0,d0,d6
 fcmp d0,d4
 b.gt .Ltime_high_done
 str w9,[x0]
.Ltime_high_done:
 fcmp d0,d5
 b.gt .Ltime_low_done
 str w9,[x0,#4]
.Ltime_low_done:
 add x9,x9,#1
 cmp x9,#19
 b.ls .Ltime_layer
 ret
.size md2asm_set_physics_time_controls_raw,.-md2asm_set_physics_time_controls_raw
.section .rodata
.p2align 3
.Ltime_group:
 .ascii "NAMPHY2"
.p2align 3
.Ltime_XMULAF:
 .quad 0xbffc000000000000
.p2align 3
.Ltime_HCLP:
 .quad 0x4097700000000000
.p2align 3
.Ltime_HTCLS:
 .quad 0x4000000000000000
.p2align 3
.Ltime_HVCLS:
 .quad 0x4024000000000000
.p2align 3
.Ltime_HTSHM:
 .quad 0x3fdccccccccccccd
.p2align 3
.Ltime_HTSML:
 .quad 0x3fe91eb851eb851f
.p2align 3
.Ltime_TSPHY:
 .quad 0x3ff0000000000000
.p2align 3
.Ltime_GZ0RAF:
 .quad 0x4024000000000000
.p2align 3
.Ltime_FACRAF:
 .quad 0x402e000000000000
.p2align 3
.Ltime_GCAPERAF:
 .quad 0x4059000000000000
.p2align 3
.Ltime_HWMOHIGH:
 .quad 0x40b3880000000000
.p2align 3
.Ltime_HWMOLOW:
 .quad 0x40a3880000000000
.p2align 3
.Ltime_HTKERAF:
 .quad 0x4034000000000000
.section .note.GNU-stack,"",%progbits

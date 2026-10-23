/* Live operational SUDYNA control intake, with unchanged accepted defaults.
 * x0 text,x1 bytes,x2 TDYNA456,x3 capacity,x4 controls32.
 * Complete spans, alignment, atomic publication and register obligations are
 * in skills/md2asm/references/openifs/setup/operational_dynamics_controls.md. No original dependency. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_dynamics_controls
.type md2asm_initialize_operational_dynamics_controls,%function
md2asm_initialize_operational_dynamics_controls:
 cbz x0,.Lod_bad_leaf
 cbz x1,.Lod_bad_leaf
 cbz x2,.Lod_bad_leaf
 cbz x4,.Lod_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lod_bad_leaf
 cmp x3,#456
 b.lo .Lod_bad_leaf
 orr x9,x2,x4
 tst x9,#7
 b.ne .Lod_bad_leaf
 adds x10,x0,x1
 b.cs .Lod_bad_leaf
 adds x11,x2,#456
 b.cs .Lod_bad_leaf
 adds x12,x4,#32
 b.cs .Lod_bad_leaf
 cmp x11,x0
 b.ls .Lod_text_clear
 cmp x2,x10
 b.lo .Lod_bad_leaf
.Lod_text_clear:
 cmp x11,x4
 b.ls .Lod_controls_clear
 cmp x2,x12
 b.lo .Lod_bad_leaf
.Lod_controls_clear:
 mrs x9,fpcr
 cbnz x9,.Lod_bad_leaf
 adr x9,.Lod_controls
 mov x10,x4
 mov w11,#8
.Lod_controls_next:
 ldr w12,[x9],#4
 ldr w13,[x10],#4
 cmp w12,w13
 b.ne .Lod_bad_leaf
 subs w11,w11,#1
 b.ne .Lod_controls_next
 sub sp,sp,#560
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 add x21,sp,#96
 add x22,x0,x1
 mov x9,#0
.Lod_copy_private:
 ldr x10,[x20,x9]
 str x10,[x21,x9]
 add x9,x9,#8
 cmp x9,#456
 b.lo .Lod_copy_private
 mov x0,x21
 bl md2asm_default_selected_dynamics_controls
 cbnz w0,.Lod_return
 mov x0,x19
 mov x1,x22
 adr x2,.Lod_group
 mov w3,#7
 adr x4,.Lod_keys
 mov x5,x21
 bl md2asm_parse_bounded_scalar_group
 cbnz w0,.Lod_return
 ldp w9,w10,[x21]
 orr w9,w9,w10
 cbnz w9,.Lod_bad
 ldr w9,[x21,#24]
 cmp w9,#1
 b.ne .Lod_bad
 mov x9,#0
.Lod_publish:
 ldr x10,[x21,x9]
 str x10,[x20,x9]
 add x9,x9,#8
 cmp x9,#456
 b.lo .Lod_publish
 mov w0,#0
 b .Lod_return
.Lod_bad:
 mov w0,#2
.Lod_return:
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#560
 ret
.Lod_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_operational_dynamics_controls,.-md2asm_initialize_operational_dynamics_controls
.p2align 3
.Lod_controls: .word 5136,2560,1279,1279,1,0,0,1
.Lod_group: .ascii "NAMDYNA"
.p2align 3
.Lod_keys:
 .word 5,2,24,0,1,0
 .ascii "LSLAG"
 .zero 11
 .word 5,2,0,0,1,0
 .ascii "LNHEE"
 .zero 11
 .word 5,2,4,0,1,0
 .ascii "LNHQE"
 .zero 11
 .word 7,2,200,0,1,0
 .ascii "LGRADSP"
 .zero 9
 .zero 40
.section .note.GNU-stack,"",%progbits

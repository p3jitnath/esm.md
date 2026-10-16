/* Complete selected SUVDF parameter record, revision 1.
 * x0 live text, x1 bytes, x2 TVDF72, x3 capacity; return zero or two.
 * Contract: skills/md2asm/references/openifs/setup/selected_diffusion_parameters.md.
 * Source-undefined padding remains incoming. No original state or callable. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_diffusion_parameters
.type md2asm_initialize_selected_diffusion_parameters,%function
md2asm_initialize_selected_diffusion_parameters:
 cbz x0,.Lvp_bad
 cbz x1,.Lvp_bad
 cmp x1,#64,lsl#12
 b.hi .Lvp_bad
 cbz x2,.Lvp_bad
 tst x2,#7
 b.ne .Lvp_bad
 cmp x3,#72
 b.lo .Lvp_bad
 mrs x8,fpcr
 cbnz x8,.Lvp_bad
 adds x4,x0,x1
 b.cs .Lvp_bad
 adds x5,x2,#72
 b.cs .Lvp_bad
 cmp x0,x5
 b.hs .Lvp_disjoint
 cmp x2,x4
 b.lo .Lvp_bad
.Lvp_disjoint:
 stp x29,x30,[sp,#-48]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adrp x2,.Lvp_namvdf
 add x2,x2,:lo12:.Lvp_namvdf
 mov x3,#6
 bl .Lvp_empty_group
 cbnz w0,.Lvp_return
 mov x0,x19
 mov x1,x20
 adrp x2,.Lvp_namdyncore
 add x2,x2,:lo12:.Lvp_namdyncore
 mov x3,#10
 bl .Lvp_empty_group
 cbnz w0,.Lvp_return
 /* Empty NAMDYNCORE establishes RUSPLRG one, then RPLRG one divided by it. */
 fmov d0,#1.0
 fdiv d1,d0,d0
 adrp x9,.Lvp_values
 add x9,x9,:lo12:.Lvp_values
 ldr d0,[x9]
 fdiv d0,d0,d1
 str d0,[x21]
 ldr x10,[x9,#8]
 str x10,[x21,#8]
 str wzr,[x21,#16]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[x21,#24]
 ldp x10,x11,[x9,#32]
 stp x10,x11,[x21,#40]
 ldr x10,[x9,#48]
 str x10,[x21,#56]
 mov w10,#1
 str w10,[x21,#64]
 mov w0,#0
.Lvp_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x29,x30,[sp],#48
 ret
.Lvp_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_diffusion_parameters,.-md2asm_initialize_selected_diffusion_parameters
/* Integer-only bounded first-group reader. x2/x3 name points to owned literals.
 * The caller already checks the complete text span. Scratch x0 through x10. */
.Lvp_empty_group:
 add x4,x0,x1
.Lvp_line:
 mov w5,#0
.Lvp_marker:
 cmp x0,x4
 b.hs .Lvp_group_bad
 ldrb w6,[x0],#1
 cmp w6,#10
 b.eq .Lvp_line
 add w5,w5,#1
 cmp w6,#32
 b.eq .Lvp_marker
 cmp w6,#9
 b.eq .Lvp_marker
 cmp w6,#13
 b.eq .Lvp_marker
 cmp w6,#38
 b.ne .Lvp_skip_line
 cmp w5,#10
 b.hi .Lvp_skip_line
 adds x7,x0,x3
 b.cs .Lvp_group_bad
 cmp x7,x4
 b.hs .Lvp_group_bad
 mov x8,#0
.Lvp_match:
 ldrb w9,[x0,x8]
 ldrb w10,[x2,x8]
 cmp w9,w10
 b.ne .Lvp_skip_line
 add x8,x8,#1
 cmp x8,x3
 b.lo .Lvp_match
 add x0,x0,x3
 ldrb w6,[x0]
 cmp w6,#32
 b.eq .Lvp_body
 cmp w6,#9
 b.eq .Lvp_body
 cmp w6,#13
 b.eq .Lvp_body
 cmp w6,#10
 b.eq .Lvp_body
 cmp w6,#47
 b.eq .Lvp_body
 b .Lvp_skip_line
.Lvp_skip_line:
 cmp x0,x4
 b.hs .Lvp_group_bad
 ldrb w6,[x0],#1
 cmp w6,#10
 b.ne .Lvp_skip_line
 b .Lvp_line
.Lvp_body:
 cmp x0,x4
 b.hs .Lvp_group_bad
 ldrb w6,[x0],#1
 cmp w6,#47
 b.eq .Lvp_group_ok
 cmp w6,#32
 b.eq .Lvp_body
 cmp w6,#9
 b.eq .Lvp_body
 cmp w6,#13
 b.eq .Lvp_body
 cmp w6,#10
 b.eq .Lvp_body
 cmp w6,#33
 b.ne .Lvp_group_bad
.Lvp_comment:
 cmp x0,x4
 b.hs .Lvp_group_bad
 ldrb w6,[x0],#1
 cmp w6,#10
 b.ne .Lvp_comment
 b .Lvp_body
.Lvp_group_ok:
 mov w0,#0
 ret
.Lvp_group_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lvp_values:
 .quad 0x4062c00000000000
 .quad 0x3ff8000000000000
 .quad 0x40122f92041e92a0
 .quad 0x3ff482f4bc842d15
 .quad 0x400b504f333f9de6
 .quad 0x4038000000000000
 .quad 0x4014000000000000
.Lvp_namvdf: .ascii "NAMVDF"
.Lvp_namdyncore: .ascii "NAMDYNCORE"
.section .note.GNU-stack,"",%progbits

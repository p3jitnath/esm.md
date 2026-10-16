/* Owned two-dimensional surface field registration, revision 1.
 * Contract: skills/md2asm/references/openifs/setup/surface_field_registration.md.
 * x0 60-byte group, x1 64-byte field, x2 408-byte trajectory, x3 40-byte plan. */
.arch armv8.2-a
.macro DISJOINT first,first_end,second,second_end
 cmp \first,\second_end
 b.hs .Lsurface_separate\@
 cmp \second,\first_end
 b.lo .Lsurface_field_reject
.Lsurface_separate\@:
.endm
.text
.p2align 4
.global md2asm_define_surface_field_2d
.type md2asm_define_surface_field_2d,%function
md2asm_define_surface_field_2d:
 cbz x0,.Lsurface_field_reject
 cbz x1,.Lsurface_field_reject
 cbz x2,.Lsurface_field_reject
 cbz x3,.Lsurface_field_reject
 orr x12,x0,x2
 tst x12,#3
 b.ne .Lsurface_field_reject
 orr x12,x1,x3
 tst x12,#7
 b.ne .Lsurface_field_reject
 adds x8,x0,#60
 b.cs .Lsurface_field_reject
 adds x9,x1,#64
 b.cs .Lsurface_field_reject
 adds x10,x2,#408
 b.cs .Lsurface_field_reject
 adds x11,x3,#40
 b.cs .Lsurface_field_reject
 DISJOINT x0,x8,x1,x9
 DISJOINT x0,x8,x2,x10
 DISJOINT x0,x8,x3,x11
 DISJOINT x1,x9,x2,x10
 DISJOINT x1,x9,x3,x11
 DISJOINT x2,x10,x3,x11
 ldr w12,[x0,#8]
 cmn w12,#1
 b.ne .Lsurface_field_reject
 ldr w12,[x0,#56]
 cbnz w12,.Lsurface_field_reject
 ldr w4,[x0,#12]
 sub w12,w4,#1
 cmp w12,#692
 b.hi .Lsurface_field_reject
 ldr w12,[x1,#20]
 cmp w12,w4
 b.ne .Lsurface_field_reject
 ldr w5,[x3]
 cmp w5,#31
 b.hi .Lsurface_field_reject
 mov w6,#0
 tbz w5,#3,.Lsurface_field_write
 ldr w6,[x3,#16]
 cmp w6,#2
 b.hi .Lsurface_field_reject
 ldr w12,[x0,#20]
 cmp w12,w4
 b.hs .Lsurface_field_reject
 cbz w6,.Lsurface_field_write
 cmp w6,#1
 b.ne .Lsurface_field_constant_bound
 ldr w12,[x2]
 cmp w12,#100
 b.hs .Lsurface_field_reject
 b .Lsurface_field_write
.Lsurface_field_constant_bound:
 ldr w12,[x2,#4]
 tbnz w12,#31,.Lsurface_field_reject
 adds w12,w12,#1
 b.vs .Lsurface_field_reject
.Lsurface_field_write:
 mov w12,#-999
 tbz w5,#0,.Lsurface_field_identifier
 ldr w12,[x3,#4]
.Lsurface_field_identifier:
 str w12,[x1,#28]
 mov w12,#-1
 tbz w5,#4,.Lsurface_field_request
 ldr w12,[x3,#20]
.Lsurface_field_request:
 str w12,[x1,#56]
 adrp x14,.Lsurface_blank_name
 add x14,x14,:lo12:.Lsurface_blank_name
 tbz w5,#1,.Lsurface_field_name
 add x14,x3,#24
.Lsurface_field_name:
 ldp x12,x13,[x14]
 stp x12,x13,[x1,#32]
 mov x12,xzr
 tbz w5,#2,.Lsurface_field_default
 ldr x12,[x3,#8]
.Lsurface_field_default:
 str x12,[x1,#48]
 tbz w5,#3,.Lsurface_field_trajectory_done
 cbz w6,.Lsurface_field_trajectory_count
 cmp w6,#1
 b.ne .Lsurface_field_constant_increment
 ldr w12,[x2]
 add x13,x2,#8
 ldr w14,[x1,#28]
 str w14,[x13,x12,lsl#2]
 add w12,w12,#1
 str w12,[x2]
 b .Lsurface_field_trajectory_count
.Lsurface_field_constant_increment:
 ldr w12,[x2,#4]
 add w12,w12,#1
 str w12,[x2,#4]
.Lsurface_field_trajectory_count:
 ldr w12,[x0,#20]
 add w12,w12,#1
 str w12,[x0,#20]
.Lsurface_field_trajectory_done:
 str w6,[x1,#16]
 mov w12,#1
 str w12,[x1,#24]
 add w4,w4,#1
 str w4,[x0,#12]
 mov w0,#0
 ret
.Lsurface_field_reject:
 mov w0,#2
 ret
.size md2asm_define_surface_field_2d,.-md2asm_define_surface_field_2d
.section .rodata
.p2align 3
.Lsurface_blank_name: .ascii "                "
.section .note.GNU-stack,"",%progbits

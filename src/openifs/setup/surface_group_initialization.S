/* Owned surface group initialization, revision 1.
 * Contract: skills/md2asm/references/openifs/setup/surface_group_initialization.md.
 * x0 48-byte controls, x1 60-byte group, x2 fields, x3 field byte capacity.
 * No allocation or physical value is changed by this metadata stage. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_surface_group
.type md2asm_initialize_surface_group,%function
md2asm_initialize_surface_group:
 cbz x0,.Lsurface_group_reject
 cbz x1,.Lsurface_group_reject
 cbz x2,.Lsurface_group_reject
 orr x9,x0,x1
 tst x9,#3
 b.ne .Lsurface_group_reject
 tst x2,#7
 b.ne .Lsurface_group_reject
 adds x9,x0,#48
 b.cs .Lsurface_group_reject
 adds x10,x1,#60
 b.cs .Lsurface_group_reject
 ldr w4,[x0]
 sub w12,w4,#2
 cmp w12,#1
 b.hi .Lsurface_group_reject
 ldr w5,[x0,#40]
 sub w12,w5,#1
 cmp w12,#693
 b.hi .Lsurface_group_reject
 ldr w6,[x0,#4]
 cmp w4,#2
 b.ne .Lsurface_group_layers
 cmn w6,#1
 b.ne .Lsurface_group_reject
 b .Lsurface_group_logical
.Lsurface_group_layers:
 cmp w6,#64
 b.hi .Lsurface_group_reject
.Lsurface_group_logical:
 ldr w7,[x0,#8]
 cmp w7,#1
 b.hi .Lsurface_group_reject
 ldr w12,[x0,#12]
 tbnz w12,#31,.Lsurface_group_reject
 ldr w12,[x0,#16]
 tbnz w12,#31,.Lsurface_group_reject
 mov w13,#0x7961
 movk w13,#0xfffe,lsl#16
 ldr w12,[x0,#20]
 cmp w12,w13
 b.ne .Lsurface_group_reject
 mov x8,#64
 mov x12,#288
 cmp w4,#2
 csel x8,x8,x12,eq
 mul x8,x8,x5
 cmp x3,x8
 b.lo .Lsurface_group_reject
 adds x11,x2,x8
 b.cs .Lsurface_group_reject
 /* The complete three ranges must be disjoint before any write. */
 cmp x0,x10
 b.hs .Lsurface_group_control_fields
 cmp x1,x9
 b.lo .Lsurface_group_reject
.Lsurface_group_control_fields:
 cmp x0,x11
 b.hs .Lsurface_group_group_fields
 cmp x2,x9
 b.lo .Lsurface_group_reject
.Lsurface_group_group_fields:
 cmp x1,x11
 b.hs .Lsurface_group_write
 cmp x2,x10
 b.lo .Lsurface_group_reject
.Lsurface_group_write:
 str wzr,[x1,#56]
 str w6,[x1,#8]
 mov w12,#1
 str w12,[x1,#12]
 str w7,[x1,#52]
 ldp x12,x13,[x0,#24]
 stp x12,x13,[x1,#32]
 str wzr,[x1,#20]
 ldp w12,w13,[x0,#12]
 stp w12,w13,[x1,#24]
 mov x12,#64
 mov x13,#288
 cmp w4,#2
 csel x12,x12,x13,eq
 ldr w13,[x0,#20]
 mov x14,x2
 mov w15,#1
.Lsurface_group_field:
 stp w13,w13,[x14]
 stp w13,w13,[x14,#8]
 str wzr,[x14,#16]
 str wzr,[x14,#24]
 str w15,[x14,#20]
 add x14,x14,x12
 add w15,w15,#1
 subs w5,w5,#1
 b.ne .Lsurface_group_field
 mov w0,#0
 ret
.Lsurface_group_reject:
 mov w0,#2
 ret
.size md2asm_initialize_surface_group,.-md2asm_initialize_surface_group
.section .note.GNU-stack,"",%progbits

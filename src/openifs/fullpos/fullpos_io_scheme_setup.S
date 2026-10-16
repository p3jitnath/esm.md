// Contract: skills/md2asm/references/openifs/fullpos/fullpos_io_scheme_setup.md.
// Complete selected SUFPIOS: text,bytes,object8544,upstream296,out564,cap.
// First NAMFPIOS empty; one domain, no Surfex handoff. Return0 or2.
// Frame160, plus unchanged empty-group child. Integer/character stores only.
.text
.p2align 2
.global md2asm_initialize_fullpos_io_scheme
.type md2asm_initialize_fullpos_io_scheme,%function
md2asm_initialize_fullpos_io_scheme:
 cbz x0,.Lio_bad_early
 cbz x1,.Lio_bad_early
 cmp x1,#64,lsl#12
 b.hi .Lio_bad_early
 cbz x2,.Lio_bad_early
 cbz x3,.Lio_bad_early
 cbz x4,.Lio_bad_early
 orr x6,x2,x3
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lio_bad_early
 cmp x5,#564
 b.lo .Lio_bad_early
 adds x6,x0,x1
 b.cs .Lio_bad_early
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 stp x0,x6,[sp,#96]
 mov x6,#8544
 adds x6,x2,x6
 b.cs .Lio_bad
 stp x2,x6,[sp,#112]
 adds x6,x3,#296
 b.cs .Lio_bad
 stp x3,x6,[sp,#128]
 adds x6,x4,#564
 b.cs .Lio_bad
 stp x4,x6,[sp,#144]
 mov x6,#0
.Lio_outer:
 add x7,sp,#96
 add x7,x7,x6,lsl#4
 ldp x8,x9,[x7]
 add x10,x6,#1
.Lio_inner:
 cmp x10,#4
 b.hs .Lio_next
 add x7,sp,#96
 add x7,x7,x10,lsl#4
 ldp x11,x12,[x7]
 cmp x8,x12
 b.hs .Lio_disjoint
 cmp x11,x9
 b.lo .Lio_bad
.Lio_disjoint:
 add x10,x10,#1
 b .Lio_inner
.Lio_next:
 add x6,x6,#1
 cmp x6,#3
 b.lo .Lio_outer
 ldr w6,[x22,#280]
 ldr w7,[x22,#284]
 orr w6,w6,w7
 cbnz w6,.Lio_bad
 ldr w6,[x22,#288]
 cmp w6,#1
 b.ne .Lio_bad
 add x0,x22,#16
 mov x1,#256
 bl .Lio_trim
 cbz x1,.Lio_bad
 mov x24,x1
 add x0,x21,#5
 mov x1,#20
 bl .Lio_trim
 mov x25,x1
 add x0,x22,#272
 mov x1,#8
 bl .Lio_trim
 mov x26,x1
 add x0,x21,#305
 mov x1,#180
 bl .Lio_trim
 mov x27,x1
 mov x0,x19
 mov x1,x20
 adr x2,.Lio_group
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lio_return
 // Complete TNAMFPIOS includes the declaration-default false flags.
 ldr w6,[x21,#848]
 str w6,[x23]
 mov w6,#1
 str w6,[x23,#4]
 mov w6,#-999
 str w6,[x23,#8]
 mov w6,#6
 str w6,[x23,#12]
 str xzr,[x23,#16]
 add x6,x23,#24
 mov x7,#540
 mov w8,#32
.Lio_pad_names:
 strb w8,[x6],#1
 subs x7,x7,#1
 b.ne .Lio_pad_names
 add x0,x23,#24
 mov x1,#0
 add x2,x21,#305
 mov x3,x27
 bl .Lio_append
 mov x2,x22
 mov x3,#4
 bl .Lio_append
 add x2,x21,#5
 mov x3,x25
 bl .Lio_append
 add x0,x23,#204
 mov x1,#0
 add x2,x22,#16
 mov x3,x24
 bl .Lio_append
 add x2,x21,#5
 mov x3,x25
 bl .Lio_append
 add x0,x23,#384
 mov x1,#0
 add x2,x22,#16
 sub x3,x24,#1
 bl .Lio_append
 add x2,x22,#272
 mov x3,x26
 bl .Lio_append
 add x2,x22,#16
 add x2,x2,x24
 sub x2,x2,#1
 mov x3,#1
 bl .Lio_append
 add x2,x21,#5
 mov x3,x25
 bl .Lio_append
 mov w0,#0
 b .Lio_return
.Lio_bad:
 mov w0,#2
.Lio_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Lio_bad_early:
 mov w0,#2
 ret
.size md2asm_initialize_fullpos_io_scheme,.-md2asm_initialize_fullpos_io_scheme
.Lio_trim:
 cbz x1,.Lio_trim_done
 sub x2,x1,#1
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.ne .Lio_trim_done
 sub x1,x1,#1
 b .Lio_trim
.Lio_trim_done:
 ret
// Append with the source CHARACTER180 assignment truncation.
.Lio_append:
 mov x4,#0
.Lio_append_loop:
 cmp x4,x3
 b.hs .Lio_append_done
 cmp x1,#180
 b.hs .Lio_append_done
 ldrb w5,[x2,x4]
 strb w5,[x0,x1]
 add x4,x4,#1
 add x1,x1,#1
 b .Lio_append_loop
.Lio_append_done:
 ret
.section .rodata
.Lio_group: .ascii "NAMFPIOS"
.section .note.GNU-stack,"",%progbits

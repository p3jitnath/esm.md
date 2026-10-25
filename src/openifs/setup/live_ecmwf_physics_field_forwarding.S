/* Contract: skills/md2asm/references/openifs/setup/live_ecmwf_physics_field_forwarding.md.
 * Create: x0 FIELDS529288, x1 Geometry20400, x2 MODEL4275088,
 * x3 configuration67616, x4 explicit owned int32 microwave count.
 * Release: x0 the same live FIELDS; release embedded children before outer FIELDS.
 * Derive P/L/B/T from actual producers and forward the complete unchanged child.
 * Return0 succeeds,1 is clean child allocation failure,2 is pre-write refusal.
 * Preserve x18..x30, required vector registers, FPCR/FPSR and errno.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_runtime_ecmwf_physics_fields_from_owners
.type md2asm_create_runtime_ecmwf_physics_fields_from_owners,%function
md2asm_create_runtime_ecmwf_physics_fields_from_owners:
 cbz x0,.Llive_physics_fields_refuse
 cbz x1,.Llive_physics_fields_refuse
 cbz x2,.Llive_physics_fields_refuse
 cbz x3,.Llive_physics_fields_refuse
 cbz x4,.Llive_physics_fields_refuse
 orr x10,x0,x1
 orr x10,x10,x2
 orr x10,x10,x3
 tst x10,#7
 b.ne .Llive_physics_fields_refuse
 tst x4,#3
 b.ne .Llive_physics_fields_refuse
 movz x10,#(529288 & 65535)
 movk x10,#(529288 >> 16),lsl#16
 adds x5,x0,x10
 b.cs .Llive_physics_fields_refuse
 mov x10,#20400
 adds x6,x1,x10
 b.cs .Llive_physics_fields_refuse
 movz x10,#(4275088 & 65535)
 movk x10,#(4275088 >> 16),lsl#16
 adds x7,x2,x10
 b.cs .Llive_physics_fields_refuse
 movz x10,#(67616 & 65535)
 movk x10,#(67616 >> 16),lsl#16
 adds x8,x3,x10
 b.cs .Llive_physics_fields_refuse
 adds x9,x4,#4
 b.cs .Llive_physics_fields_refuse
 /* All ten complete range pairs are separate before any record read. */
 cmp x0,x6
 b.hs .Llive_physics_span01
 cmp x1,x5
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span01:
 cmp x0,x7
 b.hs .Llive_physics_span02
 cmp x2,x5
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span02:
 cmp x0,x8
 b.hs .Llive_physics_span03
 cmp x3,x5
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span03:
 cmp x0,x9
 b.hs .Llive_physics_span04
 cmp x4,x5
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span04:
 cmp x1,x7
 b.hs .Llive_physics_span12
 cmp x2,x6
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span12:
 cmp x1,x8
 b.hs .Llive_physics_span13
 cmp x3,x6
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span13:
 cmp x1,x9
 b.hs .Llive_physics_span14
 cmp x4,x6
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span14:
 cmp x2,x8
 b.hs .Llive_physics_span23
 cmp x3,x7
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span23:
 cmp x2,x9
 b.hs .Llive_physics_span24
 cmp x4,x7
 b.lo .Llive_physics_fields_refuse
.Llive_physics_span24:
 cmp x3,x9
 b.hs .Llive_physics_spans_separate
 cmp x4,x8
 b.lo .Llive_physics_fields_refuse
.Llive_physics_spans_separate:
 ldr x10,[x3]
 cmp x10,x2
 b.ne .Llive_physics_fields_refuse
 ldr x10,[x3,#8]
 cmp x10,x0
 b.ne .Llive_physics_fields_refuse
 ldr x10,[x3,#16]
 cmp x10,x1
 b.ne .Llive_physics_fields_refuse
 ldr x10,[x2,#8]
 cmp x10,x1
 b.ne .Llive_physics_fields_refuse
 ldr x10,[x3,#24]
 movz w11,#0x4346
 movk w11,#0x4731,lsl#16
 cmp x10,x11
 b.ne .Llive_physics_fields_refuse
 mov x10,#40088
 ldr w10,[x3,x10]
 cbnz w10,.Llive_physics_fields_refuse
 mov x10,#40104
 ldr w10,[x3,x10]
 cmp w10,#1
 b.ne .Llive_physics_fields_refuse
 /* The unchanged runtime body admits exactly these live shape bounds. */
 ldr w5,[x1,#5144]
 sub w9,w5,#1
 cmp w9,#1023
 b.hi .Llive_physics_fields_refuse
 ldr w6,[x1,#5224]
 sub w9,w6,#1
 cmp w9,#1023
 b.hi .Llive_physics_fields_refuse
 ldr w7,[x1,#5160]
 cmp w7,#1
 b.lt .Llive_physics_fields_refuse
 movz x9,#(1577396 & 65535)
 movk x9,#(1577396 >> 16),lsl#16
 add x9,x2,x9
 ldr w8,[x9]
 sub w9,w8,#1
 cmp w9,#15
 b.hi .Llive_physics_fields_refuse
 sub sp,sp,#32
 stp x29,x30,[sp]
 mov x29,sp
 stp w5,w6,[sp,#16]
 stp w7,w8,[sp,#24]
 mov x5,#25728
 add x0,x0,x5
 mov x1,#704
 add x2,sp,#16
 mov x3,x4
 bl md2asm_initialize_runtime_ecmwf_physics_fields
 ldp x29,x30,[sp]
 add sp,sp,#32
 ret
.Llive_physics_fields_refuse:
 mov w0,#2
 ret
.size md2asm_create_runtime_ecmwf_physics_fields_from_owners,.-md2asm_create_runtime_ecmwf_physics_fields_from_owners
.p2align 4
.global md2asm_release_runtime_ecmwf_physics_fields_from_owners
.type md2asm_release_runtime_ecmwf_physics_fields_from_owners,%function
md2asm_release_runtime_ecmwf_physics_fields_from_owners:
 cbz x0,.Llive_physics_release_empty
 tst x0,#7
 b.ne .Llive_physics_fields_refuse
 movz x1,#(529288 & 65535)
 movk x1,#(529288 >> 16),lsl#16
 adds x1,x0,x1
 b.cs .Llive_physics_fields_refuse
 mov x1,#25728
 add x0,x0,x1
 b md2asm_release_runtime_ecmwf_physics_fields
.Llive_physics_release_empty:
 mov w0,#0
 ret
.size md2asm_release_runtime_ecmwf_physics_fields_from_owners,.-md2asm_release_runtime_ecmwf_physics_fields_from_owners
.section .note.GNU-stack,"",%progbits

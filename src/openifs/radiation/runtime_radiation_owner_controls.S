/* Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_flux_owners.md. */
/* Contract: runtime radiation owner controls and storage.
 * x0 MODEL, x1 capacity, x2 text, x3 text bytes. Return 0 or 2.
 * Only the two source-selected int32 output words are written. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_runtime_radiation_owner_controls
.type md2asm_initialize_runtime_radiation_owner_controls,%function
md2asm_initialize_runtime_radiation_owner_controls:
 cbz x0,.Lroc_bad_leaf
 cbz x2,.Lroc_bad_leaf
 tst x0,#7
 b.ne .Lroc_bad_leaf
 movz x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x1,x9
 b.lo .Lroc_bad_leaf
 adds x10,x0,x9
 b.cs .Lroc_bad_leaf
 cbz x3,.Lroc_bad_leaf
 cmp x3,#64,lsl#12
 b.hi .Lroc_bad_leaf
 adds x11,x2,x3
 b.cs .Lroc_bad_leaf
 cmp x0,x11
 b.hs .Lroc_spans_ok
 cmp x2,x10
 b.lo .Lroc_bad_leaf
.Lroc_spans_ok:
 mrs x9,fpcr
 cbnz x9,.Lroc_bad_leaf
 movz x9,#(1577888&65535)
 movk x9,#(1577888>>16),lsl#16
 add x9,x0,x9
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lroc_bad_leaf
 ldr w10,[x9,#380]
 cmp w10,#1
 b.hi .Lroc_bad_leaf
 sub sp,sp,#1280
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x3
 mov w22,w10
 add x9,sp,#128
 mov x10,#0
.Lroc_clear:
 add x11,x9,x10
 stp xzr,xzr,[x11]
 add x10,x10,#16
 cmp x10,#1072
 b.lo .Lroc_clear
 mov w10,#1
 str w10,[x9,#36]
 str w10,[x9,#44]
 mov x0,x20
 mov x1,x21
 add x2,sp,#128
 bl md2asm_apply_radiation_owner_namelist
 cbnz w0,.Lroc_bad_frame
 // The original second POSNAM selects and reads the same first group.
 mov x0,x20
 mov x1,x21
 add x2,sp,#128
 bl md2asm_apply_radiation_owner_namelist
 cbnz w0,.Lroc_bad_frame
 ldr w9,[sp,#172]
 cmp w9,#1
 b.ne .Lroc_bad_frame
 ldr w9,[sp,#164]
 cmp w9,#1
 b.hi .Lroc_bad_frame
 mov w10,#1
 cbz w22,.Lroc_publish
 cbz w9,.Lroc_publish
 mov w10,#6
.Lroc_publish:
 movz x11,#(1608728&65535)
 movk x11,#(1608728>>16),lsl#16
 add x11,x19,x11
 str w9,[x11,#488]
 str w10,[x11,#76]
 mov w0,#0
 b .Lroc_return
.Lroc_bad_frame:
 mov w0,#2
.Lroc_return:
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1280
 ret
.Lroc_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_runtime_radiation_owner_controls,.-md2asm_initialize_runtime_radiation_owner_controls
.section .note.GNU-stack,"",%progbits

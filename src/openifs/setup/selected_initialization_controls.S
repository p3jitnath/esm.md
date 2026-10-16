/* Contract: skills/md2asm/references/openifs/setup/selected_initialization_controls.md.
 * init(text,bytes,out24,capacity,NCONF*)->w0 status0/2, no allocation. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_initialization_controls
.type md2asm_initialize_selected_initialization_controls,%function
md2asm_initialize_selected_initialization_controls:
 cbz x0,.Linit_bad
 cbz x1,.Linit_bad
 cbz x2,.Linit_bad
 cbz x4,.Linit_bad
 cmp x1,#64,lsl#12
 b.hi .Linit_bad
 cmp x3,#24
 b.lo .Linit_bad
 tst x2,#3
 b.ne .Linit_bad
 tst x4,#3
 b.ne .Linit_bad
 adds x9,x0,x1
 b.cs .Linit_bad
 adds x10,x2,#24
 b.cs .Linit_bad
 adds x11,x4,#4
 b.cs .Linit_bad
 cmp x2,x9
 b.hs .Linit_overlap_upstream
 cmp x0,x10
 b.lo .Linit_bad
.Linit_overlap_upstream:
 cmp x2,x11
 b.hs .Linit_value
 cmp x4,x10
 b.lo .Linit_bad
.Linit_value:
 ldr w9,[x4]
 cmp w9,#1
 b.ne .Linit_bad
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adr x2,.LNAMINI
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Linit_return
 mov x0,x19
 mov x1,x20
 adr x2,.LNAMVAR
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Linit_return
 stp xzr,xzr,[x21]
 str xzr,[x21,#16]
 mov w0,#0
.Linit_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.Linit_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_initialization_controls,.-md2asm_initialize_selected_initialization_controls
.section .rodata
.LNAMINI:.ascii "NAMINI"
.LNAMVAR:.ascii "NAMVAR"
.section .note.GNU-stack,"",%progbits

/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md.
 * init(text,bytes,out40,capacity,NCONF*)->w0 status0/2, no allocation. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_initialization_controls
.type md2asm_initialize_operational_initialization_controls,%function
md2asm_initialize_operational_initialization_controls:
 cbz x0,.Linit_bad
 cbz x1,.Linit_bad
 cbz x2,.Linit_bad
 cbz x4,.Linit_bad
 cmp x1,#64,lsl#12
 b.hi .Linit_bad
 cmp x3,#40
 b.lo .Linit_bad
 tst x2,#3
 b.ne .Linit_bad
 tst x4,#3
 b.ne .Linit_bad
 adds x9,x0,x1
 b.cs .Linit_bad
 adds x10,x2,#40
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
 sub sp,sp,#80
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
 stp xzr,xzr,[sp,#64]
 mov x0,x19
 add x1,x19,x20
 adr x2,.LNAMVAR
 mov x3,#6
 adr x4,.Loperational_var_keys
 add x5,sp,#64
 bl md2asm_parse_operational_forecast_group
 cbnz w0,.Linit_return
 ldp x9,x10,[sp,#64]
 orr x9,x9,x10
 cbnz x9,.Linit_bad_saved
 stp xzr,xzr,[x21]
 stp xzr,xzr,[x21,#16]
 str xzr,[x21,#32]
 mov w0,#0
.Linit_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
 .p2align 2
.Linit_bad_saved:
 mov w0,#2
 b .Linit_return
.Linit_bad:
 mov w0,#2
 ret
.size md2asm_initialize_operational_initialization_controls,.-md2asm_initialize_operational_initialization_controls
.section .rodata
.LNAMINI:.ascii "NAMINI"
.LNAMVAR:.ascii "NAMVAR"

.p2align 3
.Loperational_var_keys:
 .word 7,2,0,0,1,0
 .ascii "LMODERR"
 .zero 9
 .word 6,2,4,0,1,0
 .ascii "LJCDFI"
 .zero 10
 .word 9,2,8,0,1,0
 .ascii "LUSEJCDFI"
 .zero 7
 .word 4,2,12,0,1,0
 .ascii "LECV"
 .zero 12
 .zero 40
.section .note.GNU-stack,"",%progbits

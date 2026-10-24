/* Selected SUPHY2 initial TSPHY assignment only.
 * x0 actual MODEL4275088, x1 capacity; int0/2.
 * Contract: skills/md2asm/references/openifs/setup/initial_physics_interval.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_owned_initial_physics_interval
.type md2asm_initialize_owned_initial_physics_interval,%function
md2asm_initialize_owned_initial_physics_interval:
 cbz x0,.Linitial_interval_bad
 tst x0,#7
 b.ne .Linitial_interval_bad
 mov x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x1,x9
 b.lo .Linitial_interval_bad
 adds x9,x0,x9
 b.cs .Linitial_interval_bad
 mrs x9,fpcr
 cbnz x9,.Linitial_interval_bad
 mov x9,#(4150016&65535)
 movk x9,#(4150016>>16),lsl#16
 movz x10,#0x3ff0,lsl#48
 str x10,[x0,x9]
 mov w0,#0
 ret
.Linitial_interval_bad:
 mov w0,#2
 ret
.size md2asm_initialize_owned_initial_physics_interval,.-md2asm_initialize_owned_initial_physics_interval
.section .note.GNU-stack,"",%progbits

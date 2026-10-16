/* Source SUDYN trajectory-speed controls at sudyn.F90:854-862.
 * Contract: skills/md2asm/references/openifs/dynamics/semi_lagrangian_buffer_setup.md.
 * x0 MODEL, x1 capacity, x2 live int32 levels, x3 levels capacity. Return0/2. */
.text
.p2align 4
.global md2asm_initialize_selected_sl_velocity_controls
.type md2asm_initialize_selected_sl_velocity_controls,%function
md2asm_initialize_selected_sl_velocity_controls:
 cbz x0,.Lvelocity_bad
 cbz x2,.Lvelocity_bad
 tst x0,#7
 b.ne .Lvelocity_bad
 tst x2,#3
 b.ne .Lvelocity_bad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lvelocity_bad
 adds x9,x0,x9
 b.cs .Lvelocity_bad
 cmp x3,#4
 b.lo .Lvelocity_bad
 adds x9,x2,#4
 b.cs .Lvelocity_bad
 ldr w9,[x2]
 sub w10,w9,#1
 cmp w10,#254
 b.hi .Lvelocity_bad
 cmp w9,#91
 movz x10,#0x8000,lsl#32
 movk x10,#0x406b,lsl#48
 mov x11,#0x4074000000000000
 movz x12,#0x4000,lsl#32
 movk x12,#0x406f,lsl#48
 mov x13,#0x4079000000000000
 csel x10,x12,x10,ge
 csel x11,x13,x11,ge
 mov x9,#(1566928&65535)
 movk x9,#(1566928>>16),lsl#16
 add x9,x0,x9
 stp x10,x11,[x9]
 mov w0,#0
 ret
.Lvelocity_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_sl_velocity_controls,.-md2asm_initialize_selected_sl_velocity_controls
.section .note.GNU-stack,"",%progbits

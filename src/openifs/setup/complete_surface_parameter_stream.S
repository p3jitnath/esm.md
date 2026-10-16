/* Contract: skills/md2asm/references/openifs/setup/complete_surface_parameter_setup.md. */
/* Stream only declared source-written parameter bytes. See frozen integration_contract.md.
 * x0 open fd,x1 completed TSURF11584,x2 globals1016. Return0 success/1 failure. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_write_selected_surface_parameter_stream
.type md2asm_write_selected_surface_parameter_stream,%function
md2asm_write_selected_surface_parameter_stream:
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adr x1,.Lstream_magic
 mov x2,#8
 bl .Lwrite
 cbnz w0,.Lfailed
 adr x22,.Lobject_ranges
 mov x23,#19
.Lobjects:
 ldp x9,x2,[x22],#16
 add x1,x20,x9
 bl .Lwrite
 cbnz w0,.Lfailed
 subs x23,x23,#1
 b.ne .Lobjects
 mov x1,x21
 mov x2,#1016
 bl .Lwrite
 cbnz w0,.Lfailed
 adr x22,.Lowner_ranges
 mov x23,#79
.Lowners:
 ldp x9,x2,[x22],#16
 ldr x1,[x20,x9]
 bl .Lwrite
 cbnz w0,.Lfailed
 subs x23,x23,#1
 b.ne .Lowners
 mov w0,#0
 b .Lreturn
.Lfailed:
 mov w0,#1
.Lreturn:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Lwrite:
 mov x0,x19
 mov x8,#64
 svc #0
 cmn x0,#4
 b.eq .Lwrite
 cmp x0,#0
 b.le .Lwrite_failed
 add x1,x1,x0
 subs x2,x2,x0
 b.ne .Lwrite
 mov w0,#0
 ret
.Lwrite_failed:
 mov w0,#1
 ret
.size md2asm_write_selected_surface_parameter_stream,.-md2asm_write_selected_surface_parameter_stream
.section .rodata
.p2align 3
.Lstream_magic: .ascii "SUSFOWN1"
.Lobject_ranges:
 .quad 0,16
 .quad 24,272
 .quad 312,2044
 .quad 2360,1644
 .quad 4008,948
 .quad 4960,4
 .quad 4968,300
 .quad 5384,8
 .quad 5448,8
 .quad 5512,8
 .quad 5576,8
 .quad 6080,8
 .quad 6168,8
 .quad 6376,1308
 .quad 7688,448
 .quad 8164,8
 .quad 8176,2932
 .quad 11112,280
 .quad 11400,176
.Lowner_ranges:
 .quad 10160,576
 .quad 10248,576
 .quad 10096,48
 .quad 9264,32
 .quad 9328,32
 .quad 9392,32
 .quad 8176,64
 .quad 8240,64
 .quad 8304,64
 .quad 8368,64
 .quad 8432,64
 .quad 8496,64
 .quad 8560,64
 .quad 8624,64
 .quad 8688,64
 .quad 8752,64
 .quad 8816,64
 .quad 8880,64
 .quad 8944,64
 .quad 9008,64
 .quad 9072,56
 .quad 9136,56
 .quad 9200,56
 .quad 9576,40
 .quad 9800,40
 .quad 9864,40
 .quad 9928,40
 .quad 9992,40
 .quad 10344,168
 .quad 10408,168
 .quad 10472,672
 .quad 10560,168
 .quad 10624,168
 .quad 10688,168
 .quad 10752,168
 .quad 10816,168
 .quad 10904,168
 .quad 10968,168
 .quad 1296,84
 .quad 1360,168
 .quad 1424,168
 .quad 1488,168
 .quad 1552,168
 .quad 1616,168
 .quad 1680,168
 .quad 1744,168
 .quad 1808,168
 .quad 1872,168
 .quad 1936,168
 .quad 2000,168
 .quad 2280,168
 .quad 2064,168
 .quad 2128,336
 .quad 2216,168
 .quad 336,168
 .quad 400,168
 .quad 464,168
 .quad 528,168
 .quad 592,168
 .quad 656,168
 .quad 720,168
 .quad 784,168
 .quad 848,168
 .quad 912,168
 .quad 976,168
 .quad 1040,168
 .quad 1104,168
 .quad 1168,168
 .quad 1232,168
 .quad 2728,320
 .quad 2816,320
 .quad 2904,320
 .quad 2992,320
 .quad 3080,320
 .quad 3168,320
 .quad 3256,320
 .quad 3344,320
 .quad 3432,320
 .quad 3520,320
.section .note.GNU-stack,"",%progbits

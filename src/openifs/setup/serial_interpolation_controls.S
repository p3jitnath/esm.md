/* Named control join for serial SLCSET. Contract: skills/md2asm/references/openifs/dynamics/serial_interpolation_buffer_setup.md.
 * x0 output32, x1 capacity, x2 owned transform304, x3 capacity,
 * x4 owned LELAM address, x5 owned NCONF address. Prior NAMPAR1 is admitted.
 * SUTRANS0 copies public transform region outputs into bytes104/108.
 * SUMP0 lines123/143 set NSLPAD=0 and LSLDEBUG=false. The original SUSC2B
 * call omits LDCSETONLY, selecting SLCSET's declared local false default. */
.text
.p2align 4
.global md2asm_initialize_serial_interpolation_controls
.type md2asm_initialize_serial_interpolation_controls,%function
md2asm_initialize_serial_interpolation_controls:
 cbz x0,.Lbad_controls
 cbz x2,.Lbad_controls
 cbz x4,.Lbad_controls
 cbz x5,.Lbad_controls
 orr x9,x0,x4
 orr x9,x9,x5
 tst x9,#3
 b.ne .Lbad_controls
 tst x2,#7
 b.ne .Lbad_controls
 cmp x1,#32
 b.lo .Lbad_controls
 cmp x3,#304
 b.lo .Lbad_controls
 adds x9,x0,#32
 b.cs .Lbad_controls
 adds x9,x2,#304
 b.cs .Lbad_controls
 adds x9,x4,#4
 b.cs .Lbad_controls
 adds x9,x5,#4
 b.cs .Lbad_controls
 ldr w9,[x2]
 cmp w9,#1
 b.ne .Lbad_controls
 ldp w10,w11,[x2,#104]
 cmp w10,#1
 b.ne .Lbad_controls
 cmp w11,#1
 b.ne .Lbad_controls
 ldr w12,[x4]
 cbnz w12,.Lbad_controls
 ldr w13,[x5]
 cmp w13,#1
 b.ne .Lbad_controls
 stp w9,w10,[x0]
 stp w11,w12,[x0,#8]
 stp w13,wzr,[x0,#16]
 stp wzr,wzr,[x0,#24]
 mov w0,#0
 ret
.Lbad_controls:
 mov w0,#2
 ret
.size md2asm_initialize_serial_interpolation_controls,.-md2asm_initialize_serial_interpolation_controls
.section .note.GNU-stack,"",%progbits

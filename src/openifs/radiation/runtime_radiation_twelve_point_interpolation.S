/* Interpolate each field from the source twelve-point neighbourhood.
 * Contract skills/md2asm/references/openifs/radiation/runtime_radiation_interpolation.md
 * Four unused corner indices remain opaque.
 */
.arch armv8.2-a
.text
.macro point value,slot
 ldr x9,[sp,#(80+8*\slot)]
 ldr \value,[x19,x9]
.endm
.macro middle result,slot,w1,w2,w3
 point d0,\slot
 point d1,(\slot+1)
 fsub d1,d1,d0
 fmul d1,\w1,d1
 fadd \result,d0,d1
 point d1,(\slot+2)
 fsub d1,d1,d0
 fmul d1,\w2,d1
 fadd \result,\result,d1
 point d1,(\slot+3)
 fsub d1,d1,d0
 fmul d1,\w3,d1
 fadd \result,\result,d1
.endm
.p2align 4
.global md2asm_runtime_radiation_twelve_point_interpolation
.type md2asm_runtime_radiation_twelve_point_interpolation,%function
md2asm_runtime_radiation_twelve_point_interpolation:
 cbz x0,.Ltwelve_bad
 cbz x1,.Ltwelve_bad
 orr x8,x0,x1
 tst x8,#3
 b.ne .Ltwelve_bad
 mrs x8,fpcr
 cbnz x8,.Ltwelve_bad
 ldrsw x8,[x0]
 sub x9,x8,#1
 mov x10,#0x10000000
 cmp x9,x10
 b.hs .Ltwelve_bad
 ldrsw x9,[x1]
 tbnz x9,#63,.Ltwelve_bad
 cmp x9,#4,lsl#12
 b.hi .Ltwelve_bad
 cbz x9,.Ltwelve_empty
 cbz x2,.Ltwelve_bad
 cbz x3,.Ltwelve_bad
 cbz x4,.Ltwelve_bad
 cbz x5,.Ltwelve_bad
 cbz x6,.Ltwelve_bad
 cbz x7,.Ltwelve_bad
 orr x10,x2,x3
 orr x10,x10,x4
 orr x10,x10,x6
 orr x10,x10,x7
 tst x10,#7
 b.ne .Ltwelve_bad
 tst x5,#3
 b.ne .Ltwelve_bad
 mul x10,x8,x9
 lsl x10,x10,#3
 adds x10,x6,x10
 b.cs .Ltwelve_bad
 lsl x11,x9,#3
 adds x11,x7,x11
 b.cs .Ltwelve_bad
 cmp x7,x10
 b.hs .Ltwelve_PRE_apart
 cmp x6,x11
 b.lo .Ltwelve_bad
.Ltwelve_PRE_apart:
 sub sp,sp,#256
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 mov x19,x6
 mov x20,x9
 mov x21,x7
 lsl x22,x8,#3
 stp x0,x1,[sp,#192]
 stp x2,x3,[sp,#208]
 stp x4,x5,[sp,#224]
 adr x23,.Ltwelve_input_sizes
 add x24,sp,#192
 mov x25,#0
.Ltwelve_inputs:
 ldr x26,[x24,x25,lsl#3]
 ldr x27,[x23,x25,lsl#3]
 adds x27,x26,x27
 b.cs .Ltwelve_frame_bad
 cmp x21,x27
 b.hs .Ltwelve_next_input
 cmp x26,x11
 b.lo .Ltwelve_frame_bad
.Ltwelve_next_input:
 add x25,x25,#1
 cmp x25,#6
 b.lo .Ltwelve_inputs
 adr x23,.Ltwelve_indices
 mov x24,#0
.Ltwelve_index_admission:
 ldr w25,[x23,x24,lsl#2]
 ldrsw x26,[x5,x25,lsl#2]
 sub x26,x26,#1
 cmp x26,x8
 b.hs .Ltwelve_frame_bad
 lsl x26,x26,#3
 add x27,sp,#80
 str x26,[x27,x24,lsl#3]
 add x24,x24,#1
 cmp x24,#12
 b.lo .Ltwelve_index_admission
 ldr d16,[x3]
 ldr d17,[x3,#24]
 ldp d18,d19,[x2]
 ldr d20,[x2,#16]
 ldp d21,d22,[x4]
 ldp d23,d24,[x4,#16]
 ldp d25,d26,[x4,#32]
.Ltwelve_fields:
 point d0,0
 point d1,1
 fsub d1,d1,d0
 fmul d1,d16,d1
 fadd d27,d0,d1
 middle d28,2,d21,d22,d23
 middle d29,6,d24,d25,d26
 point d0,10
 point d1,11
 fsub d1,d1,d0
 fmul d1,d17,d1
 fadd d30,d0,d1
 fsub d0,d28,d27
 fmul d0,d18,d0
 fadd d0,d27,d0
 fsub d1,d29,d27
 fmul d1,d19,d1
 fadd d0,d0,d1
 fsub d1,d30,d27
 fmul d1,d20,d1
 fadd d0,d0,d1
 str d0,[x21],#8
 add x19,x19,x22
 subs x20,x20,#1
 b.ne .Ltwelve_fields
 mov w0,#0
 b .Ltwelve_return
.Ltwelve_frame_bad:
 mov w0,#2
.Ltwelve_return:
 ldp x27,x28,[sp,#64]
 ldp x25,x26,[sp,#48]
 ldp x23,x24,[sp,#32]
 ldp x21,x22,[sp,#16]
 ldp x19,x20,[sp]
 add sp,sp,#256
 ret
.Ltwelve_bad:
 mov w0,#2
 ret
.Ltwelve_empty:
 mov w0,#0
 ret
.size md2asm_runtime_radiation_twelve_point_interpolation,.-md2asm_runtime_radiation_twelve_point_interpolation
.section .rodata
.p2align 3
.Ltwelve_input_sizes:
 .quad 4,4,24,32,48,64
.p2align 2
.Ltwelve_indices:
 .word 4,8,1,5,9,13,2,6,10,14,7,11
.section .note.GNU-stack,"",%progbits

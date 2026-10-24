/* Direct source-order SUECRAD angular conversions and extrema. See skills/md2asm/references/openifs/radiation/grid_angular_extrema.md. */
.arch armv8.2-a
.text
.p2align 4
.global MD2ASM_ANGULAR_ENTRY
.type MD2ASM_ANGULAR_ENTRY,%function
MD2ASM_ANGULAR_ENTRY:
#ifdef MD2ASM_CAPTURE_DEGREES
 cbz x7,.Le_bad
 tst x7,#7
 b.ne .Le_bad
 adds x8,x7,#32
 b.cs .Le_bad
 adds x9,x5,#32
 b.cs .Le_bad
 cmp x7,x9
 b.hs .Le_context_output_apart
 cmp x5,x8
 b.lo .Le_bad
.Le_context_output_apart:
 ldp x13,x9,[x7]
 ldp x14,x10,[x7,#16]
 cbz x13,.Le_bad
 cbz x14,.Le_bad
 orr x8,x13,x14
 tst x8,#7
 b.ne .Le_bad
 lsl x11,x2,#3
 cmp x9,x11
 b.lo .Le_bad
 cmp x10,x11
 b.lo .Le_bad
 adds x11,x13,x9
 b.cs .Le_bad
 adds x12,x14,x10
 b.cs .Le_bad
 cmp x13,x12
 b.hs .Le_work_apart
 cmp x14,x11
 b.lo .Le_bad
.Le_work_apart:
 lsl x8,x2,#3
 adds x8,x0,x8
 b.cs .Le_bad
 cmp x13,x8
 b.hs .Le_capture_apart_0_0
 cmp x0,x11
 b.lo .Le_bad
.Le_capture_apart_0_0:
 lsl x8,x2,#3
 adds x8,x0,x8
 b.cs .Le_bad
 cmp x14,x8
 b.hs .Le_capture_apart_0_1
 cmp x0,x12
 b.lo .Le_bad
.Le_capture_apart_0_1:
 lsl x8,x2,#3
 adds x8,x1,x8
 b.cs .Le_bad
 cmp x13,x8
 b.hs .Le_capture_apart_1_0
 cmp x1,x11
 b.lo .Le_bad
.Le_capture_apart_1_0:
 lsl x8,x2,#3
 adds x8,x1,x8
 b.cs .Le_bad
 cmp x14,x8
 b.hs .Le_capture_apart_1_1
 cmp x1,x12
 b.lo .Le_bad
.Le_capture_apart_1_1:
 mov x8,#520
 adds x8,x3,x8
 b.cs .Le_bad
 cmp x13,x8
 b.hs .Le_capture_apart_2_0
 cmp x3,x11
 b.lo .Le_bad
.Le_capture_apart_2_0:
 mov x8,#520
 adds x8,x3,x8
 b.cs .Le_bad
 cmp x14,x8
 b.hs .Le_capture_apart_2_1
 cmp x3,x12
 b.lo .Le_bad
.Le_capture_apart_2_1:
 mov x8,#32
 adds x8,x5,x8
 b.cs .Le_bad
 cmp x13,x8
 b.hs .Le_capture_apart_3_0
 cmp x5,x11
 b.lo .Le_bad
.Le_capture_apart_3_0:
 mov x8,#32
 adds x8,x5,x8
 b.cs .Le_bad
 cmp x14,x8
 b.hs .Le_capture_apart_3_1
 cmp x5,x12
 b.lo .Le_bad
.Le_capture_apart_3_1:
 mov x8,#32
 adds x8,x7,x8
 b.cs .Le_bad
 cmp x13,x8
 b.hs .Le_capture_apart_4_0
 cmp x7,x11
 b.lo .Le_bad
.Le_capture_apart_4_0:
 mov x8,#32
 adds x8,x7,x8
 b.cs .Le_bad
 cmp x14,x8
 b.hs .Le_capture_apart_4_1
 cmp x7,x12
 b.lo .Le_bad
.Le_capture_apart_4_1:
#endif
 cbz x0,.Le_bad
 cbz x1,.Le_bad
 cbz x3,.Le_bad
 cbz x5,.Le_bad
 orr x7,x0,x1
 orr x7,x7,x3
 orr x7,x7,x5
 tst x7,#7
 b.ne .Le_bad
 sub x7,x2,#1
 mov x8,#0x10000000
 cmp x7,x8
 b.hs .Le_bad
 cmp x4,#520
 b.lo .Le_bad
 cmp x6,#32
 b.lo .Le_bad
 mrs x7,fpcr
 cbnz x7,.Le_bad
 lsl x7,x2,#3
 adds x8,x0,x7
 b.cs .Le_bad
 adds x9,x1,x7
 b.cs .Le_bad
 adds x10,x3,#520
 b.cs .Le_bad
 adds x11,x5,#32
 b.cs .Le_bad
 cmp x5,x8
 b.hs .Le_lat_apart
 cmp x0,x11
 b.lo .Le_bad
.Le_lat_apart:
 cmp x5,x9
 b.hs .Le_lon_apart
 cmp x1,x11
 b.lo .Le_bad
.Le_lon_apart:
 cmp x5,x10
 b.hs .Le_phys_apart
 cmp x3,x11
 b.lo .Le_bad
.Le_phys_apart:
 ldr x7,[x3]
 ldr x8,=0x4008000000000000
 cmp x7,x8
 b.lo .Le_bad
 ldr x8,=0x4010000000000000
 cmp x7,x8
 b.hs .Le_bad
 fmov d2,x7
 fmov d3,#2.0
 fmov d6,#0.5
 fmul d6,d2,d6
 fneg d7,d6
 fmul d20,d2,d3
 mov x7,#0
.Le_check:
 ldr x8,[x0,x7,lsl#3]
 ldr x9,[x1,x7,lsl#3]
 and x10,x8,#0x7fffffffffffffff
 and x11,x9,#0x7fffffffffffffff
 ldr x12,=0x7ff0000000000000
 cmp x10,x12
 b.hs .Le_bad
 cmp x11,x12
 b.hs .Le_bad
 fmov d0,x8
 fmov d1,x9
 fcmp d0,d6
 b.gt .Le_bad
 fcmp d0,d7
 b.lt .Le_bad
 fcmp d1,#0.0
 b.lt .Le_bad
 fcmp d1,d20
 b.gt .Le_bad
 add x7,x7,#1
 cmp x7,x2
 b.lo .Le_check
 ldr d4,.Le_90
 ldr d5,.Le_180
 mov x7,#0
.Le_loop:
 ldr d0,[x0,x7,lsl#3]
 ldr d1,[x1,x7,lsl#3]
 fdiv d0,d0,d2
 fmul d0,d0,d3
 fmul d0,d0,d4
 fsub d1,d1,d2
 fdiv d1,d1,d2
 fmul d1,d1,d5
 fadd d1,d1,d5
#ifdef MD2ASM_CAPTURE_DEGREES
 str d0,[x13,x7,lsl#3]
 str d1,[x14,x7,lsl#3]
#endif
 cbz x7,.Le_first
 fcmp d16,d0
 fcsel d16,d0,d16,gt
 fcmp d17,d0
 fcsel d17,d0,d17,lt
 fcmp d18,d1
 fcsel d18,d1,d18,gt
 fcmp d19,d1
 fcsel d19,d1,d19,lt
 b .Le_next
.Le_first:
 fmov d16,d0
 fmov d17,d0
 fmov d18,d1
 fmov d19,d1
.Le_next:
 add x7,x7,#1
 cmp x7,x2
 b.lo .Le_loop
 stp d16,d17,[x5]
 stp d18,d19,[x5,#16]
 mov w0,#0
 ret
.Le_bad:
 mov w0,#2
 ret
.size MD2ASM_ANGULAR_ENTRY,.-MD2ASM_ANGULAR_ENTRY
.p2align 3
.Le_90: .quad 0x4056800000000000
.Le_180: .quad 0x4066800000000000
.section .note.GNU-stack,"",%progbits

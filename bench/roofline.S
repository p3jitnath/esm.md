// Measure compatible FP64 arithmetic and load/store throughput on the target.
// Scalar probes take x0=iterations and x1=[numerator, denominator, radicand].
// They return the final z0 lane in d0 and preserve every callee-saved register.
.text

.macro OP instruction, reg
.ifc \instruction,fdiv
    mov z\reg\().d, z24.d
    fdiv z\reg\().d, p0/m, z\reg\().d, z25.d
.else
.ifc \instruction,fsqrt
    fsqrt z\reg\().d, p0/m, z26.d
.else
.ifc \instruction,fsqrt_neon
    fsqrt v\reg\().2d, v26.2d
.else
    \instruction z\reg\().d, z24.d, z25.d
.endif
.endif
.endif
.endm

.macro LOAD_OPERANDS
    ptrue p0.d
    ld1rd {z24.d}, p0/z, [x1]
    ld1rd {z25.d}, p0/z, [x1, #8]
    ld1rd {z26.d}, p0/z, [x1, #16]
.endm

.macro DEFINE_PROBE name, instruction
.p2align 4
.global \name
.type \name, %function
\name:
    movi v0.2d, #0
    cbz x0, .Lprobe_return\@
    LOAD_OPERANDS
.Lprobe_loop\@:
    OP \instruction, 0
    OP \instruction, 1
    OP \instruction, 2
    OP \instruction, 3
    OP \instruction, 4
    OP \instruction, 5
    OP \instruction, 6
    OP \instruction, 7
    OP \instruction, 16
    OP \instruction, 17
    OP \instruction, 18
    OP \instruction, 19
    OP \instruction, 20
    OP \instruction, 21
    OP \instruction, 22
    OP \instruction, 23
    subs x0, x0, #1
    b.ne .Lprobe_loop\@
.Lprobe_return\@:
    ret
.size \name, .-\name
.endm

DEFINE_PROBE roof_add, fadd
DEFINE_PROBE roof_multiply, fmul
DEFINE_PROBE roof_divide, fdiv
DEFINE_PROBE roof_sqrt, fsqrt
DEFINE_PROBE roof_sqrt_neon, fsqrt_neon

.macro DEFINE_MIXED name, sqrt_instruction
.p2align 4
.global \name
.type \name, %function
\name:
    movi v0.2d, #0
    cbz x0, .Lmixed_return\@
    LOAD_OPERANDS
.Lmixed_loop\@:
    // Independent groups match the kernel's four divides and two square roots.
    OP fdiv, 0
    OP fdiv, 1
    OP \sqrt_instruction, 2
    OP fdiv, 3
    OP fdiv, 4
    OP \sqrt_instruction, 5
    OP fdiv, 6
    OP fdiv, 7
    OP \sqrt_instruction, 16
    OP fdiv, 17
    OP fdiv, 18
    OP \sqrt_instruction, 19
    subs x0, x0, #1
    b.ne .Lmixed_loop\@
.Lmixed_return\@:
    ret
.size \name, .-\name
.endm

DEFINE_MIXED roof_mixed, fsqrt
DEFINE_MIXED roof_mixed_neon, fsqrt_neon

// Memory probes take destination, contiguous source fields, field length,
// and iteration count in x0-x3. Predication protects every remainder.
.macro MEMORY_GROUP streams
    whilelo p0.d, x11, x2
    ld1d {z0.d}, p0/z, [x1, x11, lsl #3]
.if \streams == 7
    ld1d {z1.d}, p0/z, [x5, x11, lsl #3]
    ld1d {z2.d}, p0/z, [x6, x11, lsl #3]
    ld1d {z3.d}, p0/z, [x7, x11, lsl #3]
    ld1d {z4.d}, p0/z, [x8, x11, lsl #3]
    ld1d {z5.d}, p0/z, [x9, x11, lsl #3]
    ld1d {z6.d}, p0/z, [x10, x11, lsl #3]
    fadd z0.d, z0.d, z1.d
    fadd z2.d, z2.d, z3.d
    fadd z4.d, z4.d, z5.d
    fadd z0.d, z0.d, z2.d
    fadd z4.d, z4.d, z6.d
    fadd z0.d, z0.d, z4.d
.endif
 .if \streams == 5
    ld1d {z1.d}, p0/z, [x5, x11, lsl #3]
    ld1d {z2.d}, p0/z, [x6, x11, lsl #3]
    ld1d {z3.d}, p0/z, [x7, x11, lsl #3]
    ld1d {z4.d}, p0/z, [x8, x11, lsl #3]
    st1d {z1.d}, p0, [x12, x11, lsl #3]
.endif
.if \streams == 11
    // Eleven reads and two writes match the EBM's combined stage traffic ratio.
    ld1d {z1.d}, p0/z, [x5, x11, lsl #3]
    ld1d {z2.d}, p0/z, [x6, x11, lsl #3]
    ld1d {z3.d}, p0/z, [x7, x11, lsl #3]
    ld1d {z4.d}, p0/z, [x8, x11, lsl #3]
    ld1d {z5.d}, p0/z, [x9, x11, lsl #3]
    ld1d {z6.d}, p0/z, [x10, x11, lsl #3]
    ld1d {z7.d}, p0/z, [x12, x11, lsl #3]
    ld1d {z16.d}, p0/z, [x13, x11, lsl #3]
    ld1d {z17.d}, p0/z, [x14, x11, lsl #3]
    ld1d {z18.d}, p0/z, [x15, x11, lsl #3]
    st1d {z1.d}, p0, [x16, x11, lsl #3]
.endif
    st1d {z0.d}, p0, [x0, x11, lsl #3]
    incd x11
.endm

.macro DEFINE_MEMORY name, streams
.p2align 4
.global \name
.type \name, %function
\name:
    cbz x2, .Lmemory_return\@
    cbz x3, .Lmemory_return\@
    lsl x4, x2, #3
.if \streams == 7
    add x5, x1, x4
    add x6, x5, x4
    add x7, x6, x4
    add x8, x7, x4
    add x9, x8, x4
    add x10, x9, x4
.endif
 .if \streams == 5
    add x5, x1, x4
    add x6, x5, x4
    add x7, x6, x4
    add x8, x7, x4
    add x12, x0, x4
.endif
.if \streams == 11
    add x5, x1, x4
    add x6, x5, x4
    add x7, x6, x4
    add x8, x7, x4
    add x9, x8, x4
    add x10, x9, x4
    add x12, x10, x4
    add x13, x12, x4
    add x14, x13, x4
    add x15, x14, x4
    add x16, x0, x4
.endif
.Lmemory_repeat\@:
    mov x11, #0
.Lmemory_loop\@:
    .rept 4
        MEMORY_GROUP \streams
    .endr
    cmp x11, x2
    b.lo .Lmemory_loop\@
    subs x3, x3, #1
    b.ne .Lmemory_repeat\@
.Lmemory_return\@:
    ret
.size \name, .-\name
.endm

DEFINE_MEMORY roof_copy, 1
DEFINE_MEMORY roof_stream7, 7
DEFINE_MEMORY roof_streammix, 5
DEFINE_MEMORY roof_stream11, 11


// Eight points occupy four source planes of eight doubles; three result planes follow.
// x0=iterations, x1=source, x2=out; all inputs remain unchanged and zero is a no-op.
.macro VARIED_GROUP offset, u, v, h, c, mode
    ldr q\u, [x1, #\offset]
    ldr q\v, [x2, #\offset]
    ldr q\h, [x3, #\offset]
    ldr q\c, [x4, #\offset]
.endm
.macro VARIED_OPERATIONS u, v, h, c, mode
.ifc \mode,sve
    fdiv z\u\().d, p0/m, z\u\().d, z\h\().d
    fdiv z\v\().d, p0/m, z\v\().d, z\h\().d
    fsqrt z\c\().d, p0/m, z\c\().d
.else
    fdiv v\u\().2d, v\u\().2d, v\h\().2d
    fdiv v\v\().2d, v\v\().2d, v\h\().2d
    fsqrt v\c\().2d, v\c\().2d
.endif
.endm
.macro VARIED_RESULT offset, u, v, c
    str q\u, [x5, #\offset]
    str q\v, [x5, #(64+\offset)]
    str q\c, [x5, #(128+\offset)]
.endm
.macro DEFINE_VARIED mode
.p2align 4
.global roof_varied_\mode
.type roof_varied_\mode, %function
roof_varied_\mode:
    movi v0.2d, #0
    cbz x0, .Lvaried_return\@
    mov x5, x2
    add x2, x1, #64
    add x3, x1, #128
    add x4, x1, #192
    ptrue p0.d
.Lvaried_repeat\@:
    VARIED_GROUP 0, 0, 1, 2, 3, \mode
    VARIED_GROUP 16, 4, 5, 6, 7, \mode
    VARIED_GROUP 32, 16, 17, 18, 19, \mode
    VARIED_GROUP 48, 20, 21, 22, 23, \mode
    VARIED_OPERATIONS 0, 1, 2, 3, \mode
    VARIED_OPERATIONS 4, 5, 6, 7, \mode
    VARIED_OPERATIONS 16, 17, 18, 19, \mode
    VARIED_OPERATIONS 20, 21, 22, 23, \mode
    subs x0, x0, #1
    b.ne .Lvaried_repeat\@
    VARIED_RESULT 0, 0, 1, 3
    VARIED_RESULT 16, 4, 5, 7
    VARIED_RESULT 32, 16, 17, 19
    VARIED_RESULT 48, 20, 21, 23
.Lvaried_return\@:
    ret
.size roof_varied_\mode, .-roof_varied_\mode
.endm
DEFINE_VARIED sve
DEFINE_VARIED neon
.section .note.GNU-stack,"",%progbits
